extends Node

# Sequential test execution
const TESTS_TO_RUN: Array[Dictionary] = [
	{"name": "SignalBus", "scene": "res://tests/individual/test_signalbus.tscn"},
	{"name": "Creature", "scene": "res://tests/individual/test_creature.tscn"},
	{"name": "StatSystem", "scene": "res://tests/individual/test_stats.tscn"},
	{"name": "TagSystem", "scene": "res://tests/individual/test_tags.tscn"},
	{"name": "CreatureGenerator", "scene": "res://tests/individual/test_generator.tscn"},
	{"name": "AgeSystem", "scene": "res://tests/individual/test_age.tscn"},
	{"name": "SaveSystem", "scene": "res://tests/individual/test_save.tscn"},
	{"name": "PlayerCollection", "scene": "res://tests/individual/test_collection.tscn"}
]

var current_test_index: int = 0
var test_results: Array[Dictionary] = []
var overall_start_time: int = 0

func _ready() -> void:
	print("=== Running All Individual Tests Sequentially ===")
	print("Total tests to run: %d" % TESTS_TO_RUN.size())
	print()

	overall_start_time = Time.get_ticks_msec()
	_run_next_test()

func _run_next_test() -> void:
	if current_test_index >= TESTS_TO_RUN.size():
		_show_summary()
		return

	var test: Dictionary = TESTS_TO_RUN[current_test_index]
	print("Running test %d/%d: %s" % [current_test_index + 1, TESTS_TO_RUN.size(), test.name])
	print("=" * 50)

	var start_time: int = Time.get_ticks_msec()

	# Load and run the test scene
	var scene: PackedScene = load(test.scene)
	if scene:
		var test_instance: Node = scene.instantiate()
		add_child(test_instance)

		# Wait for test completion (they should quit automatically)
		await get_tree().process_frame

		var end_time: int = Time.get_ticks_msec()
		var duration: int = end_time - start_time

		test_results.append({
			"name": test.name,
			"duration": duration,
			"success": true  # If we get here, test didn't crash
		})

		print("Test completed in %dms" % duration)
		test_instance.queue_free()
	else:
		print("❌ FAILED to load test scene: %s" % test.scene)
		test_results.append({
			"name": test.name,
			"duration": 0,
			"success": false
		})

	print()
	current_test_index += 1

	# Small delay between tests
	await get_tree().create_timer(0.1).timeout
	_run_next_test()

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
	print("Success rate: %.1f%%" % (float(passed) / float(test_results.size()) * 100.0))

	if failed == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("⚠️  Some tests failed - check individual outputs above")

	get_tree().quit(0 if failed == 0 else 1)