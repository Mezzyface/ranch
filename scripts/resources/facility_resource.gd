@tool
class_name FacilityResource
extends Resource

# Basic identity and display
@export var facility_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

# Unlock and availability
@export var unlock_cost: int = 0
@export var is_unlocked: bool = false

# Training capabilities
@export var supported_activities: Array[int] = []  # TrainingActivity enum values
@export var max_creatures: int = 1

func is_valid() -> bool:
	"""Quick validation check for compatibility."""
	if facility_id.is_empty():
		return false
	if display_name.is_empty():
		return false
	if max_creatures <= 0:
		return false
	return true

func validate() -> Dictionary:
	"""Comprehensive validation for facility resource."""
	var errors: Array[String] = []

	if facility_id.is_empty():
		errors.append("facility_id cannot be empty")
	if display_name.is_empty():
		errors.append("display_name cannot be empty")
	if unlock_cost < 0:
		errors.append("unlock_cost cannot be negative")
	if max_creatures <= 0:
		errors.append("max_creatures must be positive")
	if supported_activities.is_empty():
		errors.append("supported_activities cannot be empty")

	# Validate activity values are within TrainingActivity enum range
	for activity in supported_activities:
		if activity < 0 or activity > 3:  # TrainingActivity has values 0-3
			errors.append("Invalid activity value: %d (must be 0-3)" % activity)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

func supports_activity(activity: int) -> bool:
	"""Check if this facility supports the given training activity."""
	return activity in supported_activities

func get_activity_names() -> Array[String]:
	"""Get human-readable names for supported activities."""
	var activity_names: Array[String] = []
	var name_map: Dictionary = {
		0: "Physical Training",  # TrainingActivity.PHYSICAL
		1: "Agility Training",   # TrainingActivity.AGILITY
		2: "Mental Training",    # TrainingActivity.MENTAL
		3: "Discipline Training" # TrainingActivity.DISCIPLINE
	}

	for activity in supported_activities:
		if activity in name_map:
			activity_names.append(name_map[activity])

	return activity_names