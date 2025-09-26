extends Node
class_name SystemValidator

# This validator helps AI agents and developers avoid common integration errors
# It provides runtime validation and helpful error messages

static func validate_creature_property_access(creature_data: CreatureData, property_name: String) -> bool:
	var valid_properties: Dictionary = {
		"id": true,  # CORRECT
		"creature_id": false,  # WRONG - common mistake
		"species_id": true,  # CORRECT
		"species": false,  # WRONG - common mistake
		"creature_name": true,
		"age_weeks": true,
		"lifespan_weeks": true,
		"tags": true,
		"is_active": true
	}

	if property_name in valid_properties:
		if not valid_properties[property_name]:
			push_error("WRONG PROPERTY: Use 'id' not 'creature_id', use 'species_id' not 'species'")
			push_error("Correct usage: creature_data.%s" % _get_correct_property(property_name))
			return false
		return true
	else:
		push_warning("Unknown property: %s" % property_name)
		return false

static func _get_correct_property(wrong_property: String) -> String:
	match wrong_property:
		"creature_id": return "id"
		"species": return "species_id"
		_: return wrong_property

static func validate_system_method_call(system_name: String, method_name: String) -> bool:
	var invalid_methods: Dictionary = {
		"age": {
			"get_creature_age_category": "Use creature_data.get_age_category() instead",
			"get_creature_age_modifier": "Use creature_data.get_age_modifier() instead"
		},
		"tag": {
			"creature_meets_requirements": "Use meets_tag_requirements() instead"
		}
	}

	if system_name in invalid_methods:
		if method_name in invalid_methods[system_name]:
			push_error("WRONG METHOD: %s" % invalid_methods[system_name][method_name])
			return false
	return true

static func validate_array_type(array_value: Variant, expected_type: String = "String") -> bool:
	if array_value is Array:
		# Check if it's a typed array
		if array_value.get_typed_builtin() == TYPE_NIL:
			push_error("ARRAY TYPE ERROR: Use Array[%s] not untyped Array" % expected_type)
			push_error("Correct: var tags: Array[String] = ['Flying', 'Fast']")
			push_error("Wrong: var tags = ['Flying', 'Fast']")
			return false
		return true
	return false

static func validate_time_api_usage(code_string: String) -> bool:
	var invalid_patterns: Array[String] = [
		"nanosecond",
		"get_time_dict_from_system().nanosecond",
		".nanosecond"
	]

	for pattern in invalid_patterns:
		if pattern in code_string:
			push_error("TIME API ERROR: '.nanosecond' doesn't exist!")
			push_error("Use: Time.get_ticks_msec() instead")
			return false
	return true

static func validate_system_loading(system_name: String, loaded_via_get_system: bool) -> bool:
	if not loaded_via_get_system:
		push_error("SYSTEM LOADING ERROR: Always use GameCore.get_system('%s')" % system_name)
		push_error("Wrong: GameCore.systems['%s']" % system_name)
		push_error("Correct: GameCore.get_system('%s')" % system_name)
		return false
	return true

# Helper function to validate common integration patterns
static func validate_integration_pattern(pattern_code: String) -> Dictionary:
	var result: Dictionary = {
		"valid": true,
		"errors": [],
		"suggestions": []
	}

	# Check for common mistakes
	var mistakes: Dictionary = {
		"creature.creature_id": "Use creature.id instead",
		"creature.species": "Use creature.species_id instead",
		"age_system.get_creature_age_category": "Use creature.get_age_category() instead",
		"['Flying']": "Use var tags: Array[String] = ['Flying']",
		".nanosecond": "Use Time.get_ticks_msec() instead",
		"GameCore.systems[": "Use GameCore.get_system() instead"
	}

	for mistake in mistakes:
		if mistake in pattern_code:
			result.valid = false
			result.errors.append(mistake)
			result.suggestions.append(mistakes[mistake])

	return result

# Validate all critical patterns at once
static func run_comprehensive_validation() -> bool:
	print("=== System Validator: Checking Common Integration Patterns ===")

	var all_valid: bool = true
	var checks: Array[Dictionary] = []

	# Check 1: Property naming
	checks.append({
		"name": "Property Naming",
		"test": func():
			var creature = CreatureData.new()
			creature.id = "test_123"  # CORRECT
			return creature.id == "test_123",
		"error": "Use 'id' not 'creature_id', 'species_id' not 'species'"
	})

	# Check 2: System loading
	checks.append({
		"name": "System Loading",
		"test": func():
			var system = GameCore.get_system("tag")  # CORRECT
			return system != null,
		"error": "Always use GameCore.get_system() for lazy loading"
	})

	# Check 3: Array typing
	checks.append({
		"name": "Array Typing",
		"test": func():
			var tags: Array[String] = ["Flying", "Fast"]  # CORRECT
			return tags.get_typed_builtin() != TYPE_NIL,
		"error": "Use Array[String] for typed arrays in Godot 4.5"
	})

	# Check 4: Time API
	checks.append({
		"name": "Time Measurement",
		"test": func():
			var time: int = Time.get_ticks_msec()  # CORRECT
			return time > 0,
		"error": "Use Time.get_ticks_msec() not .nanosecond"
	})

	# Run all checks
	for check in checks:
		var test_func: Callable = check.test
		var passed: bool = test_func.call()

		if passed:
			print("✅ %s: PASS" % check.name)
		else:
			print("❌ %s: FAIL - %s" % [check.name, check.error])
			all_valid = false

	print("")
	if all_valid:
		print("✅ All integration patterns validated successfully!")
	else:
		print("⚠️ Some patterns have issues - review errors above")

	return all_valid

# Quick validation for AI agents before running code
static func preflight_check() -> bool:
	print("=== Running Preflight Check for AI Agent Code ===")

	# Test critical systems are accessible
	var systems_to_check: Array[String] = [
		"collection", "save", "tag", "age", "stat"
	]

	for system_name in systems_to_check:
		var system = GameCore.get_system(system_name)
		if system == null:
			push_error("System '%s' failed to load!" % system_name)
			return false
		print("✅ System '%s' loaded successfully" % system_name)

	# Test SignalBus
	var signal_bus: SignalBus = GameCore.get_signal_bus()
	if signal_bus == null:
		push_error("SignalBus not accessible!")
		return false
	print("✅ SignalBus accessible")

	# Test creature generation
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	if creature == null or creature.id.is_empty():
		push_error("Creature generation failed!")
		return false
	print("✅ Creature generation working")

	print("\n✅ Preflight check PASSED - Safe to proceed!")
	return true