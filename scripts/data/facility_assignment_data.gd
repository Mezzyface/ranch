class_name FacilityAssignmentData
extends Resource

# Assignment identifiers
@export var facility_id: String = ""
@export var creature_id: String = ""

# Training configuration
@export var selected_activity: int = -1  # TrainingActivity enum value
@export var food_type: int = -1          # FoodType enum value (from FoodSystem)

func is_valid() -> bool:
	"""Quick validation check for compatibility."""
	if facility_id.is_empty():
		return false
	if creature_id.is_empty():
		return false
	if selected_activity < 0:
		return false
	if food_type < 0:
		return false
	return true

func validate() -> Dictionary:
	"""Comprehensive validation for facility assignment."""
	var errors: Array[String] = []

	if facility_id.is_empty():
		errors.append("facility_id cannot be empty")
	if creature_id.is_empty():
		errors.append("creature_id cannot be empty")
	if selected_activity < 0 or selected_activity > 3:
		errors.append("selected_activity must be valid TrainingActivity enum value (0-3)")
	if food_type < 0:
		errors.append("food_type must be valid FoodType enum value (>=0)")

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

func get_activity_name() -> String:
	"""Get human-readable name for the selected training activity."""
	var activity_names: Dictionary = {
		0: "Physical Training",  # TrainingActivity.PHYSICAL
		1: "Agility Training",   # TrainingActivity.AGILITY
		2: "Mental Training",    # TrainingActivity.MENTAL
		3: "Discipline Training" # TrainingActivity.DISCIPLINE
	}
	return activity_names.get(selected_activity, "Unknown Activity")

func clear() -> void:
	"""Reset assignment to default/empty state."""
	facility_id = ""
	creature_id = ""
	selected_activity = -1
	food_type = -1