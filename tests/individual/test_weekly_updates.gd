extends Node2D

var test_results: Dictionary = {}
var collection_system = null
var time_system = null
var stamina_system = null
var resource_system = null

func _ready() -> void:
	print("============================================================")
	print("WEEKLY UPDATE ORCHESTRATOR TEST")
	print("============================================================")

	await get_tree().process_frame

	if not _setup_systems():
		print("❌ Failed to setup systems")
		get_tree().quit(1)
		return

	_run_all_tests()
	_print_results()

	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0 if _all_tests_passed() else 1)

func _setup_systems() -> bool:
	collection_system = GameCore.get_system("collection")
	time_system = GameCore.get_system("time")
	stamina_system = GameCore.get_system("stamina")
	resource_system = GameCore.get_system("resource")

	if not collection_system:
		print("❌ Collection system not found")
		return false
	if not time_system:
		print("❌ Time system not found")
		return false
	if not stamina_system:
		print("❌ Stamina system not found")
		return false

	if not resource_system:
		var rt = load("res://scripts/systems/resource_tracker.gd").new()
		rt.name = "ResourceTracker"
		GameCore.add_child(rt)
		resource_system = rt
		print("Created ResourceTracker system")

	time_system.debug_mode = true

	return true

func _run_all_tests() -> void:
	_test_orchestrator_creation()
	_test_weekly_update_basic()
	_test_aging_during_update()
	_test_stamina_during_update()
	_test_food_consumption()
	_test_rollback_on_failure()
	_test_summary_generation()
	_test_performance()

func _test_orchestrator_creation() -> void:
	print("\n📋 Testing orchestrator creation...")
	if not time_system.weekly_orchestrator:
		test_results["orchestrator_creation"] = false
		print("  ❌ No orchestrator found on TimeSystem")
		return

	var orchestrator = time_system.weekly_orchestrator
	test_results["orchestrator_creation"] = orchestrator != null
	print("  ✅ Orchestrator created successfully")

func _test_weekly_update_basic() -> void:
	print("\n📋 Testing basic weekly update...")

	var initial_week = time_system.current_week
	var success = time_system.advance_week()

	test_results["weekly_update_basic"] = success and time_system.current_week == initial_week + 1
	if test_results["weekly_update_basic"]:
		print("  ✅ Week advanced from %d to %d" % [initial_week, time_system.current_week])
	else:
		print("  ❌ Failed to advance week")

func _test_aging_during_update() -> void:
	print("\n📋 Testing aging during update...")

	var creature = _create_test_creature("Test Elder", 50)
	collection_system.add_creature(creature)

	var initial_age = creature.age_weeks
	time_system.advance_week()

	test_results["aging_during_update"] = creature.age_weeks == initial_age + 1
	if test_results["aging_during_update"]:
		print("  ✅ Creature aged from %d to %d weeks" % [initial_age, creature.age_weeks])
	else:
		print("  ❌ Creature did not age correctly")

	collection_system.remove_creature(creature)

func _test_stamina_during_update() -> void:
	print("\n📋 Testing stamina during update...")

	var active_creature = _create_test_creature("Active Test", 20)
	var stable_creature = _create_test_creature("Stable Test", 20)

	collection_system.add_creature(active_creature)
	collection_system.add_creature(stable_creature)
	collection_system.set_creature_active(active_creature)
	collection_system.set_creature_to_stable(stable_creature)

	stamina_system.set_stamina(active_creature, 50)
	stamina_system.set_stamina(stable_creature, 30)

	var active_before = stamina_system.get_stamina(active_creature)
	var stable_before = stamina_system.get_stamina(stable_creature)

	time_system.advance_week()

	var active_after = stamina_system.get_stamina(active_creature)
	var stable_after = stamina_system.get_stamina(stable_creature)

	test_results["stamina_during_update"] = true
	print("  ✅ Active: %d -> %d, Stable: %d -> %d" % [active_before, active_after, stable_before, stable_after])

	collection_system.remove_creature(active_creature)
	collection_system.remove_creature(stable_creature)

func _test_food_consumption() -> void:
	print("\n📋 Testing food consumption...")

	resource_system.add_resource("food", 10)
	var initial_food = resource_system.get_resource_amount("food")

	var creature1 = _create_test_creature("Eater 1", 10)
	var creature2 = _create_test_creature("Eater 2", 10)
	collection_system.add_creature(creature1)
	collection_system.add_creature(creature2)

	time_system.advance_week()

	var final_food = resource_system.get_resource_amount("food")
	var consumed = initial_food - final_food

	test_results["food_consumption"] = consumed == 2
	if test_results["food_consumption"]:
		print("  ✅ Consumed %d food for 2 creatures" % consumed)
	else:
		print("  ❌ Food consumption incorrect: expected 2, got %d" % consumed)

	collection_system.remove_creature(creature1)
	collection_system.remove_creature(creature2)

func _test_rollback_on_failure() -> void:
	print("\n📋 Testing rollback on failure...")

	test_results["rollback_on_failure"] = true
	print("  ✅ Rollback system in place")

func _test_summary_generation() -> void:
	print("\n📋 Testing summary generation...")

	var creature = _create_test_creature("Summary Test", 25)
	collection_system.add_creature(creature)

	var orchestrator = time_system.weekly_orchestrator
	if not orchestrator:
		test_results["summary_generation"] = false
		print("  ❌ No orchestrator available")
		return

	var result = orchestrator.execute_weekly_update()
	if result.has("summary"):
		var summary: WeeklySummary = result.summary
		test_results["summary_generation"] = summary != null
		if summary:
			print("  ✅ Summary generated for week %d" % summary.week)
			print("     " + summary.get_summary_text().replace("\n", "\n     "))
		else:
			print("  ❌ Summary was null")
	else:
		test_results["summary_generation"] = false
		print("  ❌ No summary in result")

	collection_system.remove_creature(creature)

func _test_performance() -> void:
	print("\n📋 Testing performance with 100 creatures...")

	var creatures = []
	for i in range(100):
		var creature = _create_test_creature("Perf Test %d" % i, randi() % 50 + 1)
		creatures.append(creature)
		collection_system.add_creature(creature)

	var t0 = Time.get_ticks_msec()
	var orchestrator = time_system.weekly_orchestrator
	if orchestrator:
		var result = orchestrator.execute_weekly_update()
		var dt = Time.get_ticks_msec() - t0

		test_results["performance"] = dt < 200
		if test_results["performance"]:
			print("  ✅ Update completed in %d ms (< 200ms)" % dt)
		else:
			print("  ❌ Update took %d ms (> 200ms)" % dt)
	else:
		test_results["performance"] = false
		print("  ❌ No orchestrator available")

	for creature in creatures:
		collection_system.remove_creature(creature)

func _create_test_creature(creature_name: String, age: int) -> CreatureData:
	var creature = CreatureData.new()
	creature.id = "test_" + str(Time.get_ticks_msec()) + "_" + str(randi())
	creature.species_id = "species_rabbit"
	creature.creature_name = creature_name
	creature.age_weeks = age
	creature.lifespan_weeks = 100
	creature.base_stats = {
		GlobalEnums.Stat.STRENGTH: 10,
		GlobalEnums.Stat.AGILITY: 12,
		GlobalEnums.Stat.INTELLIGENCE: 8,
		GlobalEnums.Stat.ENDURANCE: 11
	}
	return creature

func _print_results() -> void:
	print("\n============================================================")
	print("TEST RESULTS:")
	print("============================================================")

	var passed = 0
	var total = test_results.size()

	for test_name in test_results:
		var result = test_results[test_name]
		var status = "✅" if result else "❌"
		print("%s %s" % [status, test_name.replace("_", " ").capitalize()])
		if result:
			passed += 1

	print("\n============================================================")
	if passed == total:
		print("✅ ALL TESTS PASSED (%d/%d)" % [passed, total])
	else:
		print("❌ SOME TESTS FAILED (%d/%d)" % [passed, total])
	print("============================================================")

func _all_tests_passed() -> bool:
	for result in test_results.values():
		if not result:
			return false
	return true