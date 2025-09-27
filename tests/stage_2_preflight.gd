extends Node

## Stage 2 Preflight Check Script
## Run this before starting Stage 2 implementation to verify all prerequisites

var checks_passed: int = 0
var checks_failed: int = 0
var warnings: Array[String] = []

func _ready():
	print("\n" + "=".repeat(60))
	print("STAGE 2 PREFLIGHT CHECK - Validating Prerequisites")
	print("=".repeat(60) + "\n")

	# Check Stage 1 Systems
	check_stage_1_systems()

	# Check Stage 1 Tests
	check_stage_1_tests()

	# Check File Structure
	check_file_structure()

	# Check Dependencies
	check_dependencies()

	# Check Performance Baseline
	check_performance_baseline()

	# Print Summary
	print_summary()

	# Exit with appropriate code
	get_tree().quit(checks_failed)

func check_stage_1_systems():
	print("Checking Stage 1 Systems...")

	# Check GameCore
	if not GameCore:
		fail_check("GameCore not found as autoload")
		return

	# Check required systems
	var required_systems = [
		"signal_bus",
		"stat",
		"tag",
		"age",
		"save",
		"collection"
	]

	for system_name in required_systems:
		if system_name == "signal_bus":
			if GameCore.get_signal_bus():
				pass_check("SignalBus available")
			else:
				fail_check("SignalBus not available")
		else:
			if GameCore.has_system(system_name):
				pass_check("System '%s' registered" % system_name)
			else:
				fail_check("System '%s' not found" % system_name)

	# Check SpeciesSystem (replaced hardcoded SPECIES_DATA)
	var species_system = GameCore.get_system("species")
	if species_system and species_system.get_all_species().size() >= 4:
		pass_check("SpeciesSystem has 4+ species")
	else:
		fail_check("SpeciesSystem missing species")

	print("")

func check_stage_1_tests():
	print("Checking Stage 1 Test Status...")

	var test_files = [
		"tests/individual/test_signalbus.gd",
		"tests/individual/test_creature.gd",
		"tests/individual/test_stats.gd",
		"tests/individual/test_tags.gd",
		"tests/individual/test_generator.gd",
		"tests/individual/test_age.gd",
		"tests/individual/test_save.gd",
		"tests/individual/test_collection.gd"
	]

	for test_file in test_files:
		if FileAccess.file_exists(test_file):
			pass_check("Test file exists: %s" % test_file.get_file())
		else:
			warn_check("Test file missing: %s" % test_file.get_file())

	print("")

func check_file_structure():
	print("Checking File Structure...")

	var required_dirs = [
		"scripts/core",
		"scripts/systems",
		"scripts/data",
		"scripts/entities",
		"tests/individual",
		"docs/implementation/stages/stage_2"
	]

	for dir_path in required_dirs:
		var dir = DirAccess.open(dir_path)
		if dir:
			pass_check("Directory exists: %s" % dir_path)
		else:
			fail_check("Directory missing: %s" % dir_path)

	# Check for Stage 2 planning docs
	if FileAccess.file_exists("docs/implementation/stages/stage_2/00_stage_2_overview.md"):
		pass_check("Stage 2 overview document exists")
	else:
		warn_check("Stage 2 overview document missing")

	print("")

func check_dependencies():
	print("Checking Dependencies...")

	# Check ResourceTracking status (Stage 1 Task 9)
	if GameCore.has_system("resource"):
		pass_check("ResourceTracking system available")
	else:
		warn_check("ResourceTracking not complete (Stage 1 Task 9)")
		warnings.append("Complete Stage 1 Task 9 before starting Stage 2 Task 6 (FoodSystem)")

	# Check for SignalBus signals
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		var expected_signals = [
			"creature_created",
			"creature_updated",
			"creature_deleted",
			"collection_changed",
			"save_completed",
			"load_completed"
		]

		var missing_signals = []
		for signal_name in expected_signals:
			if not signal_bus.has_signal(signal_name):
				missing_signals.append(signal_name)

		if missing_signals.is_empty():
			pass_check("All Stage 1 signals present")
		else:
			warn_check("Missing signals: %s" % str(missing_signals))

	print("")

func check_performance_baseline():
	print("Checking Performance Baseline...")

	var start_time = Time.get_ticks_msec()

	# Generate test creatures
	var creatures = []
	for i in 100:
		creatures.append(CreatureGenerator.generate_creature_data("scuttleguard"))

	var generation_time = Time.get_ticks_msec() - start_time

	if generation_time < 100:
		pass_check("Creature generation: %dms (target: <100ms)" % generation_time)
	else:
		warn_check("Creature generation slow: %dms (target: <100ms)" % generation_time)

	# Test save performance
	start_time = Time.get_ticks_msec()
	var save_system = GameCore.get_system("save") if GameCore.has_system("save") else null
	if save_system:
		save_system.save_creature_collection(creatures, "preflight_test")
		var save_time = Time.get_ticks_msec() - start_time

		if save_time < 200:
			pass_check("Save performance: %dms (target: <200ms)" % save_time)
		else:
			warn_check("Save performance slow: %dms (target: <200ms)" % save_time)

		# Cleanup test save
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("preflight_test_creatures.cfg")

	print("")

func pass_check(message: String):
	checks_passed += 1
	print("  ✓ " + message)

func fail_check(message: String):
	checks_failed += 1
	print("  ✗ " + message)
	push_error("Preflight check failed: " + message)

func warn_check(message: String):
	warnings.append(message)
	print("  ⚠ " + message)
	push_warning("Preflight warning: " + message)

func print_summary():
	print("\n" + "=".repeat(60))
	print("PREFLIGHT CHECK SUMMARY")
	print("=".repeat(60))

	print("\nResults:")
	print("  Passed: %d checks" % checks_passed)
	print("  Failed: %d checks" % checks_failed)
	print("  Warnings: %d issues" % warnings.size())

	if not warnings.is_empty():
		print("\nWarnings to address:")
		for warning in warnings:
			print("  - " + warning)

	print("")

	if checks_failed == 0:
		print("✅ READY FOR STAGE 2 IMPLEMENTATION")
		if not warnings.is_empty():
			print("   (Address warnings for best results)")
	else:
		print("❌ NOT READY FOR STAGE 2")
		print("   Fix failed checks before proceeding")

	print("\n" + "=".repeat(60) + "\n")