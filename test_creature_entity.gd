extends Control

# Test script for creature entity functionality

@onready var creature_entity = $TestArea/CreatureEntity
var test_creature: CreatureData

func _ready() -> void:
	print("=== Creature Entity Test ===")

	# Create test creature data
	test_creature = CreatureData.new()
	test_creature.id = "test_creature_001"
	test_creature.creature_name = "Test Creature"
	test_creature.species_id = "scuttleguard"
	test_creature.age_weeks = 10
	test_creature.is_active = true

	# Set the creature data on the entity
	if creature_entity and creature_entity.has_method("set_creature_data"):
		creature_entity.set_creature_data(test_creature)
		print("✅ Creature data set successfully")
	else:
		push_error("❌ Could not set creature data")
		return

	# Set area bounds for the entity
	if creature_entity and creature_entity.has_method("set_area_bounds"):
		var test_area = $TestArea
		var bounds = Rect2(Vector2.ZERO, test_area.size)
		creature_entity.set_area_bounds(bounds)
		print("✅ Area bounds set: ", bounds)

	# Wait a moment then test state transitions
	await get_tree().create_timer(2.0).timeout
	_test_state_transitions()

func _test_state_transitions() -> void:
	print("\n--- Testing State Transitions ---")

	if not creature_entity:
		push_error("❌ Creature entity not available")
		return

	print("Current state: ", creature_entity.current_state)

	# Test walking state
	print("Testing walking to random position...")
	if creature_entity.has_method("_get_random_position_in_bounds"):
		var target = creature_entity._get_random_position_in_bounds()
		creature_entity.target_position = target
		creature_entity.current_state = creature_entity.State.WALKING
		print("✅ Transitioned to Walking state, target: ", target)

	# Wait and test assignment
	await get_tree().create_timer(3.0).timeout
	_test_facility_assignment()

func _test_facility_assignment() -> void:
	print("\n--- Testing Facility Assignment ---")

	if not creature_entity:
		return

	# Test facility assignment
	var facility_position = Vector2(400, 300)
	if creature_entity.has_method("assign_to_facility"):
		creature_entity.assign_to_facility("test_facility", facility_position)
		print("✅ Assigned to facility at position: ", facility_position)

	# Wait and test unassignment
	await get_tree().create_timer(5.0).timeout
	if creature_entity.has_method("unassign_from_facility"):
		creature_entity.unassign_from_facility()
		print("✅ Unassigned from facility")

	print("\n=== Test Complete ===")
	print("Try clicking and dragging the creature!")

func _input(event: InputEvent) -> void:
	# Pass input to the creature for drag testing
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("Test ended by user")
			get_tree().quit()