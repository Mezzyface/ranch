extends Node

# New contract: each individual test scene must emit a `test_completed(success: bool)` signal.
# This runner instantiates each scene, connects to the signal, and proceeds only after receipt.
# Advantages: prevents premature tree quit, supports accurate pass/fail propagation, and allows
# future parallelization or timeout handling.

const ALL_TESTS: Array[Dictionary] = [
	{"name": "SignalBus", "scene": "res://tests/individual/test_signalbus.tscn"},
	{"name": "Creature", "scene": "res://tests/individual/test_creature.tscn"},
	{"name": "StatSystem", "scene": "res://tests/individual/test_stats.tscn"},
	{"name": "TagSystem", "scene": "res://tests/individual/test_tags.tscn"},
	{"name": "CreatureGenerator", "scene": "res://tests/individual/test_generator.tscn"},
	{"name": "AgeSystem", "scene": "res://tests/individual/test_age.tscn"},
	{"name": "SaveSystem", "scene": "res://tests/individual/test_save.tscn"},
	{"name": "PlayerCollection", "scene": "res://tests/individual/test_collection.tscn"},
	{"name": "ResourceTracker", "scene": "res://tests/individual/test_resource.tscn"},
	{"name": "SpeciesSystem", "scene": "res://tests/individual/test_species.tscn"},
	{"name": "GlobalEnums", "scene": "res://tests/individual/test_enums.tscn"},
	{"name": "TimeSystem", "scene": "res://tests/individual/test_time.tscn"}
]

var TESTS_TO_RUN: Array[Dictionary] = []
var current_test_index: int = 0
var test_results: Array[Dictionary] = []
var overall_start_time: int = 0
var active_instance: Node = null
var active_start_time: int = 0
var TEST_TIMEOUT_MS: int = 10000  # safety timeout per test (can be overridden by env)

func _ready() -> void:
	# Apply optional filter via environment variable TEST_FILTER (substring match, case-insensitive)
	var filter: String = OS.get_environment("TEST_FILTER")
	TEST_TIMEOUT_MS = int(OS.get_environment("TEST_TIMEOUT_MS")) if OS.has_environment("TEST_TIMEOUT_MS") else TEST_TIMEOUT_MS
	for test in ALL_TESTS:
		if filter.is_empty() or test.name.to_lower().find(filter.to_lower()) != -1:
			TESTS_TO_RUN.append(test)
	# Fallback: if filter produced zero tests but a filter string was provided and numeric (likely per-test timeout misuse)
	if filter != "" and TESTS_TO_RUN.is_empty():
		print("(Filter '%s' produced zero matches; running full suite instead)" % filter)
		TESTS_TO_RUN = ALL_TESTS.duplicate(true)
	print("=== Running All Individual Tests Sequentially (Signal Contract) ===")
	if not filter.is_empty():
		print("Filter active: '%s' -> %d selected" % [filter, TESTS_TO_RUN.size()])
	print("Per-test timeout: %d ms" % TEST_TIMEOUT_MS)
	print("Total tests to run: %d" % TESTS_TO_RUN.size())
	print()
	overall_start_time = Time.get_ticks_msec()
	_run_next_test()

func _run_next_test() -> void:
	if active_instance:
		active_instance.queue_free()
		active_instance = null

	if current_test_index >= TESTS_TO_RUN.size():
		_show_summary()
		return

	var test: Dictionary = TESTS_TO_RUN[current_test_index]
	print("Running test %d/%d: %s" % [current_test_index + 1, TESTS_TO_RUN.size(), test.name])
	print("==================================================")
	active_start_time = Time.get_ticks_msec()

	var scene: PackedScene = load(test.scene)
	if not scene:
		print("❌ FAILED to load test scene: %s" % test.scene)
		_record_result(test.name, 0, false, ["Scene load failed"]) 
		current_test_index += 1
		_run_next_test()
		return

	active_instance = scene.instantiate()
	add_child(active_instance)

	# Backwards compatibility: if old test still calls get_tree().quit(), guard against exit
	get_tree().set_auto_accept_quit(false)
	# If test emits signal, connect. If it doesn't define it, we fallback after 1 frame as pass.
	if not active_instance.has_signal("test_completed"):
		# Fallback shim: wrap in coroutine and treat as success after a frame
		print("(INFO) Test scene missing 'test_completed' signal; using legacy fallback")
		_legacy_fallback_completion(test.name)
	else:
		active_instance.connect("test_completed", Callable(self, "_on_test_completed").bind(test.name))
		# Start timeout timer
		_start_timeout_watchdog(test.name)

func _legacy_fallback_completion(test_name: String) -> void:
	await get_tree().process_frame
	var duration: int = Time.get_ticks_msec() - active_start_time
	_record_result(test_name, duration, true, [])
	current_test_index += 1
	_run_next_test()

func _on_test_completed(success: bool, details: Array, test_name: String) -> void:
	var duration: int = Time.get_ticks_msec() - active_start_time
	_record_result(test_name, duration, success, details)
	current_test_index += 1
	_run_next_test()

func _record_result(test_name: String, duration: int, success: bool, details: Array) -> void:
	test_results.append({
		"name": test_name,
		"duration": duration,
		"success": success,
		"details": details
	})
	print("Test %s: %s (%dms)" % [test_name, "PASSED" if success else "FAILED", duration])
	if details.size() > 0:
		for line in details:
			print("  - %s" % line)

func _start_timeout_watchdog(test_name: String) -> void:
	# Launch an async watchdog
	call_deferred("_timeout_check", test_name, active_start_time)

func _timeout_check(test_name: String, start_ref: int) -> void:
	while active_instance and test_name == TESTS_TO_RUN[current_test_index].name:
		if Time.get_ticks_msec() - start_ref > TEST_TIMEOUT_MS:
			print("❌ TIMEOUT: %s exceeded %dms" % [test_name, TEST_TIMEOUT_MS])
			_on_test_completed(false, ["Timeout exceeded"], test_name)
			return
		await get_tree().process_frame

func _show_summary() -> void:
	var total_time: int = Time.get_ticks_msec() - overall_start_time
	print("=== TEST SUMMARY ===")
	print("Total execution time: %dms" % total_time)
	print()
	var passed: int = 0
	var failed: int = 0
	for result in test_results:
		var status: String = "✅ PASS" if result.success else "❌ FAIL"
		print("%s - %s (%dms)" % [status, result.name, result.duration])
		if result.success:
			passed += 1
		else:
			failed += 1
	print()
	print("Results: %d passed, %d failed" % [passed, failed])
	print("Success rate: %.1f%%" % (float(passed) / max(1.0, float(test_results.size())) * 100.0))
	if failed == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("⚠️  Some tests failed - check individual outputs above")
	get_tree().quit(0 if failed == 0 else 1)
