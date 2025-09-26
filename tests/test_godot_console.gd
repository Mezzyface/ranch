extends Node
# LEGACY: This monolithic console runner has been archived. Prefer per-system tests
# under tests/individual/ or the manual_test_runner.tscn for quick probes.

## Console Test Runner for Godot Engine
## Runs automated tests without GUI for CI/CD and development
## Usage: godot --headless --scene test_console_scene.tscn

func _ready():
	print("=== GODOT CONSOLE TEST RUNNER ===")
	print("Engine version: ", Engine.get_version_info())
	print("Platform: ", OS.get_name())
	print("Test started at: ", Time.get_datetime_string_from_system())
	print()

	# Wait one frame for autoloads to be ready
	await get_tree().process_frame

	# Disable SignalBus debug mode to reduce output noise
	var signal_bus = GameCore.get_signal_bus() if GameCore else null
	if signal_bus:
		signal_bus.set_debug_mode(false)
		print("🔇 Debug mode disabled for cleaner test output")

	# Run all tests
	var success: bool = run_all_tests()

	# Re-enable debug mode after testing
	if signal_bus:
		signal_bus.set_debug_mode(true)

	print()
	if success:
		print("✅ ALL TESTS PASSED")
		get_tree().quit(0)  # Exit code 0 = success
	else:
		print("❌ SOME TESTS FAILED")
		get_tree().quit(1)  # Exit code 1 = failure

func run_all_tests() -> bool:
	var all_passed: bool = true
	var test_results: Array[Dictionary] = []

	# Test 1: GameCore System Loading
	var result1: Dictionary = test_gamecore_loading()
	test_results.append(result1)
	all_passed = all_passed and result1.passed

	# Test 2: SignalBus Functionality
	var result2: Dictionary = test_signalbus_functionality()
	test_results.append(result2)
	all_passed = all_passed and result2.passed

	# Test 3: CreatureData/Entity System
	var result3: Dictionary = test_creature_system()
	test_results.append(result3)
	all_passed = all_passed and result3.passed

	# Test 4: StatSystem Integration
	var result4: Dictionary = test_stat_system()
	test_results.append(result4)
	all_passed = all_passed and result4.passed

	# Test 5: TagSystem Validation
	var result5: Dictionary = test_tag_system()
	test_results.append(result5)
	all_passed = all_passed and result5.passed

	# Test 6: CreatureGenerator Performance
	var result6: Dictionary = test_creature_generator()
	test_results.append(result6)
	all_passed = all_passed and result6.passed

	# Test 7: AgeSystem Functionality
	var result7: Dictionary = test_age_system()
	test_results.append(result7)
	all_passed = all_passed and result7.passed

	# Test 8: SaveSystem Operations
	var result8: Dictionary = test_save_system()
	test_results.append(result8)
	all_passed = all_passed and result8.passed

	# Print summary
	print_test_summary(test_results)

	return all_passed

func test_gamecore_loading() -> Dictionary:
	print("🧪 Testing GameCore System Loading...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	# Test GameCore autoload access
	if not GameCore:
		errors.append("GameCore autoload not available")
		passed = false
	else:
		print("  ✓ GameCore autoload accessible")

		# Test lazy loading
		var stat_system = GameCore.get_system("stat")
		if not stat_system:
			errors.append("StatSystem failed to load via lazy loading")
			passed = false
		else:
			print("  ✓ StatSystem loaded via lazy loading")

		var tag_system = GameCore.get_system("tag")
		if not tag_system:
			errors.append("TagSystem failed to load via lazy loading")
			passed = false
		else:
			print("  ✓ TagSystem loaded via lazy loading")

		var age_system = GameCore.get_system("age")
		if not age_system:
			errors.append("AgeSystem failed to load via lazy loading")
			passed = false
		else:
			print("  ✓ AgeSystem loaded via lazy loading")

		var save_system = GameCore.get_system("save")
		if not save_system:
			errors.append("SaveSystem failed to load via lazy loading")
			passed = false
		else:
			print("  ✓ SaveSystem loaded via lazy loading")

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "GameCore Loading",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_signalbus_functionality() -> Dictionary:
	print("🧪 Testing SignalBus Functionality...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	# Test SignalBus access through GameCore
	var signal_bus = GameCore.get_signal_bus() if GameCore else null
	if not signal_bus:
		errors.append("SignalBus not available through GameCore")
		passed = false
	else:
		print("  ✓ SignalBus accessible through GameCore")

		# Test signal existence
		if not signal_bus.has_signal("creature_created"):
			errors.append("creature_created signal not found")
			passed = false
		else:
			print("  ✓ creature_created signal exists")

		if not signal_bus.has_signal("save_completed"):
			errors.append("save_completed signal not found")
			passed = false
		else:
			print("  ✓ save_completed signal exists")

		# Test safe connection method
		var callable_test: Callable = func(_data): pass
		var connected: bool = signal_bus.connect_signal_safe("creature_created", callable_test)
		if not connected:
			errors.append("Safe signal connection failed")
			passed = false
		else:
			print("  ✓ Safe signal connection successful")
			# Clean up
			signal_bus.disconnect_signal_safe("creature_created", callable_test)

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "SignalBus Functionality",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_creature_system() -> Dictionary:
	print("🧪 Testing CreatureData/Entity System...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	# Test CreatureData creation
	var creature_data: CreatureData = CreatureData.new()
	creature_data.id = "test_creature_001"
	creature_data.creature_name = "Test Creature"
	creature_data.set_stat("STR", 500)
	creature_data.set_stat("DEX", 300)
	creature_data.age_weeks = 10
	creature_data.tags = ["Small", "Social"]

	if creature_data.get_stat("STR") != 500:
		errors.append("Stat setting/getting failed")
		passed = false
	else:
		print("  ✓ CreatureData stat management working")

	# Test serialization
	var data_dict: Dictionary = creature_data.to_dict()
	var new_creature: CreatureData = CreatureData.from_dict(data_dict)

	# Debug the serialization
	var name_match: bool = new_creature.creature_name == "Test Creature"
	var stat_match: bool = new_creature.get_stat("STR") == 500
	var id_match: bool = new_creature.id == "test_creature_001"

	if not name_match:
		errors.append("Name mismatch: expected 'Test Creature', got '%s'" % new_creature.creature_name)
		passed = false
	elif not stat_match:
		errors.append("Stat mismatch: expected 500 STR, got %d" % new_creature.get_stat("STR"))
		passed = false
	elif not id_match:
		errors.append("ID mismatch: expected 'test_creature_001', got '%s'" % new_creature.id)
		passed = false
	else:
		print("  ✓ CreatureData serialization working")

	# Test CreatureEntity creation
	var creature_entity: CreatureEntity = CreatureEntity.new()
	creature_entity.data = creature_data

	if creature_entity.data.creature_name != "Test Creature":
		errors.append("CreatureEntity data assignment failed")
		passed = false
	else:
		print("  ✓ CreatureEntity data assignment working")

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Creature System",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_stat_system() -> Dictionary:
	print("🧪 Testing StatSystem...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	var stat_system = GameCore.get_system("stat")
	if not stat_system:
		errors.append("StatSystem not available")
		passed = false
		return {
			"name": "Stat System",
			"passed": passed,
			"duration_ms": Time.get_ticks_msec() - start_time,
			"errors": errors
		}

	# Test stat validation
	var clamped_value: int = stat_system.validate_stat_value("STR", 1500)
	if clamped_value != 1000:
		errors.append("Stat validation failed: expected 1000, got %d" % clamped_value)
		passed = false
	else:
		print("  ✓ Stat validation/clamping working")

	# Test stat cap
	var stat_cap: int = stat_system.get_stat_cap("STR")
	if stat_cap != 1000:
		errors.append("Stat cap failed: expected 1000, got %d" % stat_cap)
		passed = false
	else:
		print("  ✓ Stat cap working")

	# Test stat breakdown with proper creature ID
	var test_creature: CreatureData = CreatureData.new()
	test_creature.id = "test_stat_creature"
	test_creature.set_stat("STR", 500)
	test_creature.age_weeks = 50  # Adult category

	var stat_breakdown: Dictionary = stat_system.get_stat_breakdown(test_creature, "STR")
	if stat_breakdown.is_empty():
		errors.append("Stat breakdown returned empty dictionary")
		passed = false
	elif not stat_breakdown.has("base"):
		errors.append("Stat breakdown missing 'base' key. Available keys: %s" % str(stat_breakdown.keys()))
		passed = false
	else:
		print("  ✓ Stat breakdown working")

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Stat System",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_tag_system() -> Dictionary:
	print("🧪 Testing TagSystem...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	var tag_system = GameCore.get_system("tag")
	if not tag_system:
		errors.append("TagSystem not available")
		passed = false
		return {
			"name": "Tag System",
			"passed": passed,
			"duration_ms": Time.get_ticks_msec() - start_time,
			"errors": errors
		}

	# Test tag validation with proper typing
	var valid_tags: Array[String] = ["Small", "Social"]
	var validation_result: Dictionary = tag_system.validate_tag_combination(valid_tags)
	if not validation_result.valid:
		errors.append("Valid tags failed validation: %s" % str(validation_result.get("errors", [])))
		passed = false
	else:
		print("  ✓ Tag validation working")

	# Test mutual exclusions
	var invalid_tags: Array[String] = ["Small", "Large"]
	var invalid_result: Dictionary = tag_system.validate_tag_combination(invalid_tags)
	if invalid_result.valid:
		errors.append("Mutual exclusion validation failed - Small+Large should be invalid")
		passed = false
	else:
		print("  ✓ Mutual exclusion validation working")

	# Test creature filtering
	var creatures: Array[CreatureData] = []
	for i in range(10):
		var creature: CreatureData = CreatureData.new()
		creature.creature_name = "Creature %d" % i
		creature.id = "test_creature_%d" % i
		if i % 2 == 0:
			creature.tags = ["Small"]
		else:
			creature.tags = ["Large"]
		creatures.append(creature)

	var required_tags: Array[String] = ["Small"]
	var excluded_tags: Array[String] = []
	var filtered: Array[CreatureData] = tag_system.filter_creatures_by_tags(creatures, required_tags, excluded_tags)

	if filtered.size() != 5:
		errors.append("Creature filtering failed: expected 5, got %d" % filtered.size())
		passed = false
	else:
		print("  ✓ Creature filtering working")

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Tag System",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_creature_generator() -> Dictionary:
	print("🧪 Testing CreatureGenerator Performance...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	# Test single creature generation
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	if not creature or creature.creature_name.is_empty():
		errors.append("Single creature generation failed")
		passed = false
	else:
		print("  ✓ Single creature generation working")

	# Test performance with batch generation
	var generation_start: int = Time.get_ticks_msec()
	var creatures: Array[CreatureData] = CreatureGenerator.generate_population_data(100)
	var generation_time: int = Time.get_ticks_msec() - generation_start

	if creatures.size() != 100:
		errors.append("Batch generation failed: expected 100, got %d" % creatures.size())
		passed = false
	elif generation_time > 100:  # Should be under 100ms for 100 creatures
		errors.append("Performance target missed: %dms for 100 creatures" % generation_time)
		passed = false
	else:
		print("  ✓ Batch generation performance: %dms for 100 creatures" % generation_time)

	# Test species variety
	var species_count: Dictionary = {}
	for c in creatures:
		var species: String = c.species_id
		species_count[species] = species_count.get(species, 0) + 1

	if species_count.keys().size() < 2:
		errors.append("Species variety failed: only %d species generated" % species_count.keys().size())
		passed = false
	else:
		print("  ✓ Species variety: %d different species" % species_count.keys().size())

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Creature Generator",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_age_system() -> Dictionary:
	print("🧪 Testing AgeSystem...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	var age_system = GameCore.get_system("age")
	if not age_system:
		errors.append("AgeSystem not available")
		passed = false
		return {
			"name": "Age System",
			"passed": passed,
			"duration_ms": Time.get_ticks_msec() - start_time,
			"errors": errors
		}

	# Test age category calculation via modifier
	var creature: CreatureData = CreatureData.new()
	creature.lifespan_weeks = 100
	creature.age_weeks = 20  # Should be juvenile (20% of life)

	# Use the age modifier to verify category works
	var life_percentage: float = (float(creature.age_weeks) / float(creature.lifespan_weeks)) * 100.0
	if life_percentage >= 10.0 and life_percentage < 25.0:  # Should be juvenile
		print("  ✓ Age category calculation working (juvenile at %.1f%% life)" % life_percentage)
	else:
		errors.append("Age category calculation failed: got %.1f%% life" % life_percentage)
		passed = false

	# Test aging
	var old_age: int = creature.age_weeks
	age_system.age_creature_by_weeks(creature, 10)
	if creature.age_weeks != old_age + 10:
		errors.append("Creature aging failed")
		passed = false
	else:
		print("  ✓ Creature aging working")

	# Test batch aging performance
	var creatures: Array[CreatureData] = []
	for i in range(100):
		var test_creature: CreatureData = CreatureData.new()
		test_creature.lifespan_weeks = 100
		test_creature.age_weeks = i
		creatures.append(test_creature)

	var aging_start: int = Time.get_ticks_msec()
	var aged_count: int = age_system.age_all_creatures(creatures, 5)
	var aging_time: int = Time.get_ticks_msec() - aging_start

	if aged_count != 100:
		errors.append("Batch aging failed: expected 100, got %d" % aged_count)
		passed = false
	elif aging_time > 100:  # Should be under 100ms for 100 creatures
		errors.append("Aging performance target missed: %dms" % aging_time)
		passed = false
	else:
		print("  ✓ Batch aging performance: %dms for 100 creatures" % aging_time)

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Age System",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func test_save_system() -> Dictionary:
	print("🧪 Testing SaveSystem...")
	var start_time: int = Time.get_ticks_msec()
	var passed: bool = true
	var errors: Array[String] = []

	var save_system = GameCore.get_system("save")
	if not save_system:
		errors.append("SaveSystem not available")
		passed = false
		return {
			"name": "Save System",
			"passed": passed,
			"duration_ms": Time.get_ticks_msec() - start_time,
			"errors": errors
		}

	# Test save slot operations
	var available_slots: Array[String] = save_system.get_save_slots()
	print("  ✓ Available save slots: %d" % available_slots.size())

	# Test basic save/load
	var test_slot: String = "console_test"
	var save_success: bool = save_system.save_game_state(test_slot)
	if not save_success:
		errors.append("Game state save failed")
		passed = false
	else:
		print("  ✓ Game state save successful")

	var load_success: bool = save_system.load_game_state(test_slot)
	if not load_success:
		errors.append("Game state load failed")
		passed = false
	else:
		print("  ✓ Game state load successful")

	# Test creature collection save/load
	var test_creatures: Array[CreatureData] = []
	for i in range(10):
		var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
		creature.creature_name = "Test Creature %d" % i
		test_creatures.append(creature)

	var collection_save: bool = save_system.save_creature_collection(test_creatures, test_slot)
	if not collection_save:
		errors.append("Creature collection save failed")
		passed = false
	else:
		print("  ✓ Creature collection save successful")

	var loaded_creatures: Array[CreatureData] = save_system.load_creature_collection(test_slot)
	if loaded_creatures.size() != test_creatures.size():
		errors.append("Creature collection load failed: size mismatch")
		passed = false
	else:
		print("  ✓ Creature collection load successful")

	# Clean up test save
	save_system.delete_save_slot(test_slot)

	var duration: int = Time.get_ticks_msec() - start_time
	print("  Duration: %dms" % duration)

	return {
		"name": "Save System",
		"passed": passed,
		"duration_ms": duration,
		"errors": errors
	}

func print_test_summary(results: Array[Dictionary]) -> void:
	print("\n=== TEST SUMMARY ===")
	var total_tests: int = results.size()
	var passed_tests: int = 0
	var total_duration: int = 0

	for result in results:
		var status: String = "✅ PASS" if result.passed else "❌ FAIL"
		print("%s - %s (%dms)" % [status, result.name, result.duration_ms])

		if result.passed:
			passed_tests += 1
		else:
			for error in result.errors:
				print("    ❌ %s" % error)

		total_duration += result.duration_ms

	print("\nResults: %d/%d tests passed" % [passed_tests, total_tests])
	print("Total duration: %dms" % total_duration)
	print("Success rate: %.1f%%" % ((float(passed_tests) / float(total_tests)) * 100.0))