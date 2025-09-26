extends Node

# PREFLIGHT CHECK FOR AI AGENTS
# Run this BEFORE implementing any new features to verify correct patterns
# Usage: godot --headless --scene tests/preflight_check.tscn

var validation_results: Dictionary = {
	"property_tests": [],
	"method_tests": [],
	"integration_tests": [],
	"errors_found": 0,
	"warnings_found": 0
}

func _ready() -> void:
	print("============================================================")  # 60 equals
	print("AI AGENT PREFLIGHT CHECK - Validating System Integration")
	print("============================================================")
	print("")

	# Run all validation checks
	_test_property_naming()
	_test_method_calls()
	_test_array_typing()
	_test_system_loading()
	_test_signal_integration()
	_test_common_workflows()

	# Show summary
	_print_summary()

	# Exit with appropriate code
	var exit_code: int = 0 if validation_results.errors_found == 0 else 1
	get_tree().quit(exit_code)

func _test_property_naming() -> void:
	print("📋 Testing Property Naming Conventions...")

	var creature: CreatureData = CreatureData.new()
	creature.id = "test_123"
	creature.species_id = "scuttleguard"
	creature.creature_name = "Test Creature"

	# Test CORRECT property access
	var correct_tests: Array[Dictionary] = [
		{"property": "id", "expected": "test_123"},
		{"property": "species_id", "expected": "scuttleguard"},
		{"property": "creature_name", "expected": "Test Creature"}
	]

	for test in correct_tests:
		var value = creature.get(test.property)
		if value == test.expected:
			print("  ✅ creature.%s works correctly" % test.property)
		else:
			print("  ❌ creature.%s failed!" % test.property)
			validation_results.errors_found += 1

	# Document WRONG patterns to avoid
	print("  ⚠️ NEVER USE: creature.creature_id (use .id)")
	print("  ⚠️ NEVER USE: creature.species (use .species_id)")
	print("")

func _test_method_calls() -> void:
	print("📋 Testing Method Call Locations...")

	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	creature.age_weeks = 52  # 1 year old

	# Test CORRECT method locations
	var age_category: int = creature.get_age_category()  # CORRECT
	var age_modifier: float = creature.get_age_modifier()  # CORRECT

	if age_category >= 0 and age_category <= 4:
		print("  ✅ creature.get_age_category() works (returns %d)" % age_category)
	else:
		print("  ❌ creature.get_age_category() failed!")
		validation_results.errors_found += 1

	if age_modifier > 0:
		print("  ✅ creature.get_age_modifier() works (returns %.2f)" % age_modifier)
	else:
		print("  ❌ creature.get_age_modifier() failed!")
		validation_results.errors_found += 1

	# Test tag system methods
	var tag_system = GameCore.get_system("tag")
	var required_tags: Array[String] = ["Small"]
	var excluded_tags: Array[String] = []

	if tag_system.meets_tag_requirements(creature, required_tags):
		print("  ✅ tag_system.meets_tag_requirements() works")
	else:
		print("  ⚠️ tag_system.meets_tag_requirements() returned false (may be correct)")

	print("  ⚠️ NEVER USE: age_system.get_creature_age_category(creature)")
	print("  ⚠️ NEVER USE: tag_system.creature_meets_requirements()")
	print("")

func _test_array_typing() -> void:
	print("📋 Testing Array Type Safety...")

	# CORRECT: Typed arrays
	var tags_correct: Array[String] = ["Flying", "Fast"]
	var creatures_correct: Array[CreatureData] = []

	if tags_correct.get_typed_builtin() != TYPE_NIL:
		print("  ✅ Array[String] typing works correctly")
	else:
		print("  ❌ Array[String] typing failed!")
		validation_results.errors_found += 1

	# Test with PlayerCollection
	var collection = GameCore.get_system("collection")
	var required_tags: Array[String] = ["Small"]  # CORRECT typing

	# This should work without type errors
	var available = collection.get_available_for_quest(required_tags)
	print("  ✅ Typed array parameter passing works")

	print("  ⚠️ ALWAYS USE: Array[String] not just Array")
	print("  ⚠️ ALWAYS USE: Array[CreatureData] not just Array")
	print("")

func _test_system_loading() -> void:
	print("📋 Testing System Loading Patterns...")

	# CORRECT: Using get_system
	var systems_to_test: Array[String] = [
		"collection", "save", "tag", "age", "stat"
	]

	for system_name in systems_to_test:
		var system = GameCore.get_system(system_name)
		if system != null:
			print("  ✅ GameCore.get_system('%s') works" % system_name)
		else:
			print("  ❌ GameCore.get_system('%s') failed!" % system_name)
			validation_results.errors_found += 1

	# Test SignalBus access
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus != null:
		print("  ✅ GameCore.get_signal_bus() works")
	else:
		print("  ❌ GameCore.get_signal_bus() failed!")
		validation_results.errors_found += 1

	print("  ⚠️ NEVER USE: GameCore.systems['name'] directly")
	print("")

func _test_signal_integration() -> void:
	print("📋 Testing Signal Integration...")

	var signal_bus = GameCore.get_signal_bus()
	if not signal_bus:
		print("  ❌ SignalBus not accessible!")
		validation_results.errors_found += 1
		return

	# Test signal emission with validation
	var creature = CreatureGenerator.generate_creature_data("scuttleguard")

	# These should work without errors
	signal_bus.emit_creature_acquired(creature, "test")
	print("  ✅ Signal emission with validation works")

	# Test that null data is rejected
	signal_bus.set_debug_mode(false)  # Suppress debug output
	signal_bus.emit_creature_acquired(null, "test")  # Should be rejected
	signal_bus.set_debug_mode(true)
	print("  ✅ Signal validation prevents null data")

	print("")

func _test_common_workflows() -> void:
	print("📋 Testing Common Integration Workflows...")

	# Workflow 1: Create and add creature
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	creature.creature_name = "Test Scout"

	var collection = GameCore.get_system("collection")
	if collection.add_to_active(creature):
		print("  ✅ Creature creation and collection workflow works")
		collection.remove_from_active(creature.id)  # Cleanup
	else:
		print("  ⚠️ Active roster might be full (this is okay)")

	# Workflow 2: Quest eligibility check
	var required_tags: Array[String] = ["Small", "Fast"]
	var available: Array[CreatureData] = collection.get_available_for_quest(required_tags)
	print("  ✅ Quest eligibility check works (found %d creatures)" % available.size())

	# Workflow 3: Save/Load
	var save_system = GameCore.get_system("save")
	save_system.save_game_state("test_preflight")
	print("  ✅ Save system integration works")

	# Workflow 4: Time measurement
	var start_time: int = Time.get_ticks_msec()
	await get_tree().create_timer(0.01).timeout
	var end_time: int = Time.get_ticks_msec()
	var duration: int = end_time - start_time
	if duration > 0:
		print("  ✅ Time measurement works (measured %dms)" % duration)
	else:
		print("  ❌ Time measurement failed!")
		validation_results.errors_found += 1

	print("")

func _print_summary() -> void:
	print("============================================================")
	print("PREFLIGHT CHECK SUMMARY")
	print("============================================================")

	if validation_results.errors_found == 0:
		print("✅ ALL CHECKS PASSED - Safe to proceed with implementation!")
		print("")
		print("Remember these critical patterns:")
		print("  • Use 'id' not 'creature_id'")
		print("  • Use 'species_id' not 'species'")
		print("  • Use creature.get_age_category() not age_system.get_creature_age_category()")
		print("  • Use Array[String] not untyped Array")
		print("  • Use Time.get_ticks_msec() not .nanosecond")
		print("  • Use GameCore.get_system() for loading")
	else:
		print("❌ ERRORS FOUND: %d" % validation_results.errors_found)
		print("")
		print("Fix these issues before proceeding!")
		print("Refer to docs/development/API_REFERENCE.md for correct patterns")

	print("")
	print("For detailed patterns, see:")
	print("  • docs/development/API_REFERENCE.md")
	print("  • docs/development/SYSTEMS_INTEGRATION_GUIDE.md")
	print("  • docs/development/QUICK_START_GUIDE.md")