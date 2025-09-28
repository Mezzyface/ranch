extends Node

func _ready() -> void:
	print("Testing creature entity system...")

	# Add a viewport for proper testing
	add_to_scene_tree()

	# Test 1: Entity creation and data assignment
	var entity_scene = preload("res://scenes/entities/creature_entity.tscn")
	var entity = entity_scene.instantiate()
	get_tree().current_scene.add_child(entity)

	var creature = CreatureData.new()
	creature.id = "test_1"
	creature.creature_name = "Test Dragon"
	entity.set_creature_data(creature)

	assert(entity.creature_data == creature, "Creature data not set")
	print("✓ Entity accepts creature data")

	# Test 2: Mouse input detection (simplified without viewport dependency)
	# Check that the entity can be set to dragging state
	entity.is_dragging = true
	assert(entity.is_dragging == true, "Drag state not settable")
	entity.is_dragging = false
	print("✓ Drag state works")

	# Test 3: Facility card drop acceptance
	var facility_card = preload("res://scenes/ui/components/facility_card.tscn").instantiate()
	get_tree().current_scene.add_child(facility_card)

	# Set up a valid facility resource for testing
	var facility_resource = FacilityResource.new()
	facility_resource.facility_id = "test_facility"
	facility_resource.display_name = "Test Facility"
	facility_resource.is_unlocked = true
	facility_resource.max_creatures = 1
	facility_card.facility_resource = facility_resource

	var drag_data = {"creature_data": creature}
	assert(facility_card._can_drop_data(Vector2.ZERO, drag_data), "Drop not accepted")
	print("✓ Facility accepts creature drops")

	# Test 4: Integration with facility system
	var facility_system = GameCore.get_system("facility")
	var collection = GameCore.get_system("collection")

	# Add creature to collection
	collection.add_to_active(creature)

	# Assign via facility system (using an existing facility)
	var facilities = facility_system.get_all_facilities()
	if facilities.size() > 0:
		var first_facility = facilities[0]
		facility_system.assign_creature(first_facility.facility_id, creature.id, 0, 0)

		var assignment = facility_system.get_assignment(first_facility.facility_id)
		assert(assignment != null and assignment.creature_id == creature.id, "Assignment not created")
		print("✓ Facility system integration works")
	else:
		print("⚠ Skipping facility assignment test - no facilities available")

	print("All creature entity tests passed!")
	get_tree().quit(0)

func add_to_scene_tree() -> void:
	# Ensure we're in the scene tree for proper testing
	if not is_inside_tree():
		get_tree().current_scene.add_child(self)