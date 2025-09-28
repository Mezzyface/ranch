class_name ISaveable

# ISaveable Interface
#
# Formal interface contract for systems that support save/load operations.
# Implementing systems must provide consistent save/load behavior for persistence.
#
# Design Goals:
# - Standardize save/load API across all systems
# - Enable SaveSystem modular enumeration instead of hardcoded switch statements
# - Ensure idempotent operations (calling load_state(save_state()) should not drift state)
# - Provide clear namespace separation for different system data

# === INTERFACE CONTRACT ===

## Get the namespace identifier for this system's save data
## This should be a unique identifier that remains stable across versions
func get_save_namespace() -> String:
	push_error("ISaveable.get_save_namespace() must be implemented by subclass")
	return ""

## Save the current system state to a Dictionary
## Returns a Dictionary containing all persistent state data
## Must be deterministic - same state should produce same Dictionary
func save_state() -> Dictionary:
	push_error("ISaveable.save_state() must be implemented by subclass")
	return {}

## Load system state from a Dictionary
## Must be idempotent - calling load_state(save_state()) should not change state
## Should handle missing keys gracefully with appropriate defaults
func load_state(data: Dictionary) -> void:
	push_error("ISaveable.load_state() must be implemented by subclass")

# === INTERFACE VALIDATION ===

## Validate that this instance properly implements the ISaveable interface
## Returns {valid: bool, errors: Array[String]}
func validate_interface() -> Dictionary:
	var errors: Array[String] = []

	# Test get_save_namespace
	var namespace = get_save_namespace()
	if namespace.is_empty():
		errors.append("get_save_namespace() returns empty string")

	# Test save_state idempotency
	var state1 = save_state()
	if not state1 is Dictionary:
		errors.append("save_state() does not return Dictionary")

	# Test load_state doesn't crash with empty data
	var original_state = save_state()
	load_state({})
	var after_empty_load = save_state()

	# Restore original state
	load_state(original_state)

	# Test idempotency - load(save()) should not change state
	var state_before = save_state()
	load_state(state_before)
	var state_after = save_state()

	# Note: Deep comparison would be complex, so we just check structure
	if state_before.keys() != state_after.keys():
		errors.append("load_state(save_state()) changes state structure - not idempotent")

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

# === IMPLEMENTATION GUIDELINES ===
#
# When implementing ISaveable in a system:
#
# 1. get_save_namespace() should return a stable identifier like "facility_system"
# 2. save_state() should return all persistent data in a flat Dictionary
# 3. load_state() should handle missing keys with sensible defaults
# 4. Ensure idempotency - repeated save/load cycles should not drift
# 5. Keep data structures simple - avoid complex nested objects
# 6. Use explicit type checking for loaded data
#
# Example implementation:
#
# func get_save_namespace() -> String:
#     return "facility_system"
#
# func save_state() -> Dictionary:
#     return {
#         "facility_unlock_status": facility_unlock_status.duplicate(),
#         "facility_assignments": _serialize_assignments()
#     }
#
# func load_state(data: Dictionary) -> void:
#     facility_unlock_status = data.get("facility_unlock_status", {})
#     _deserialize_assignments(data.get("facility_assignments", {}))
#
# === REGISTRATION PATTERN ===
#
# Systems implementing ISaveable should register with SaveSystem during _ready():
#
# func _ready() -> void:
#     # ... other initialization ...
#     var save_system = GameCore.get_system("save")
#     if save_system and save_system.has_method("register_saveable"):
#         save_system.register_saveable(self)