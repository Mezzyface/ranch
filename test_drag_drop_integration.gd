extends Control

# Test drag-drop integration with food/activity selection system

func _ready() -> void:
	print("=== DRAG-DROP INTEGRATION TEST ===")

	# Wait for game systems to initialize
	await get_tree().process_frame
	await get_tree().process_frame

	var success = await _run_tests()

	if success:
		print("✅ All drag-drop integration tests PASSED")
	else:
		print("❌ Some drag-drop integration tests FAILED")

	# Exit after testing
	get_tree().quit()

func _run_tests() -> bool:
	var all_passed = true

	print("\n--- Test 1: System Integration ---")
	all_passed = all_passed and _test_system_integration()

	print("\n--- Test 2: Facility Card State ---")
	all_passed = all_passed and _test_facility_card_state()

	print("\n--- Test 3: Food/Activity Selection ---")
	all_passed = all_passed and _test_food_activity_selection()

	print("\n--- Test 4: Drop Validation ---")
	all_passed = all_passed and _test_drop_validation()

	print("\n--- Test 5: Assignment Creation ---")
	all_passed = all_passed and _test_assignment_creation()

	return all_passed

func _test_system_integration() -> bool:
	# Test that required systems are available
	var facility_system = GameCore.get_system("facility")
	var collection = GameCore.get_system("collection")
	var signal_bus = GameCore.get_signal_bus()

	if not facility_system:
		print("❌ FacilitySystem not available")
		return false

	if not collection:
		print("❌ PlayerCollection not available")
		return false

	if not signal_bus:
		print("❌ SignalBus not available")
		return false

	print("✅ All required systems available")
	return true

func _test_facility_card_state() -> bool:
	# Create a test facility card
	var facility_card_scene = preload("res://scenes/ui/components/facility_card.tscn")
	var facility_card = facility_card_scene.instantiate()
	add_child(facility_card)

	# Get a test facility
	var facility_system = GameCore.get_system("facility")
	var facilities = facility_system.get_all_facilities()

	if facilities.is_empty():
		print("❌ No facilities available for testing")
		facility_card.queue_free()
		return false

	var test_facility = facilities[0]
	facility_card.set_facility(test_facility)
	facility_card.set_unlock_status(true)  # Ensure it's unlocked for testing

	# Wait for card to initialize
	await get_tree().process_frame

	# Test initial state
	if not facility_card.can_accept_creature():
		print("❌ Facility card should accept creatures when unlocked and empty")
		facility_card.queue_free()
		return false

	# Test food/activity selection methods
	facility_card.set_selected_food_type(0)
	facility_card.set_selected_activity(0)

	if facility_card.get_selected_food_type() != 0:
		print("❌ Food type selection not working")
		facility_card.queue_free()
		return false

	if facility_card.get_selected_activity() != 0:
		print("❌ Activity selection not working")
		facility_card.queue_free()
		return false

	facility_card.queue_free()
	print("✅ Facility card state management working")
	return true

func _test_food_activity_selection() -> bool:
	# Test food selection logic
	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")

	if not item_manager or not resource_tracker:
		print("❌ ItemManager or ResourceTracker not available")
		return false

	# Ensure we have some food items
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)
	if food_items.is_empty():
		print("❌ No food items available")
		return false

	# Add some food to inventory for testing
	var first_food = food_items[0]
	resource_tracker.add_item(first_food.item_id, 5)

	# Test facility selection defaults
	var facility_card_scene = preload("res://scenes/ui/components/facility_card.tscn")
	var facility_card = facility_card_scene.instantiate()
	add_child(facility_card)

	var facility_system = GameCore.get_system("facility")
	var facilities = facility_system.get_all_facilities()
	var test_facility = facilities[0]
	facility_card.set_facility(test_facility)
	facility_card.set_unlock_status(true)

	await get_tree().process_frame

	# Test that defaults are available
	var default_food = facility_card.get_selected_food_type()
	var default_activity = facility_card.get_selected_activity()

	if default_food < 0:
		print("❌ No default food available")
		facility_card.queue_free()
		return false

	if default_activity < 0:
		print("❌ No default activity available")
		facility_card.queue_free()
		return false

	facility_card.queue_free()
	print("✅ Food/activity selection working")
	return true

func _test_drop_validation() -> bool:
	# Create test creature data
	var test_creature = CreatureData.new()
	test_creature.id = "test_creature_" + str(randi())
	test_creature.creature_name = "Test Creature"
	test_creature.species_id = "basic_species"

	# Create test facility card
	var facility_card_scene = preload("res://scenes/ui/components/facility_card.tscn")
	var facility_card = facility_card_scene.instantiate()
	add_child(facility_card)

	var facility_system = GameCore.get_system("facility")
	var facilities = facility_system.get_all_facilities()
	var test_facility = facilities[0]
	facility_card.set_facility(test_facility)
	facility_card.set_unlock_status(true)

	await get_tree().process_frame

	# Test valid drop data
	var valid_data = {
		"creature_data": test_creature,
		"source": null
	}

	var can_drop = facility_card._can_drop_data(Vector2.ZERO, valid_data)
	if not can_drop:
		print("❌ Should accept valid creature data")
		facility_card.queue_free()
		return false

	# Test invalid drop data
	var invalid_data = {"invalid": "data"}
	can_drop = facility_card._can_drop_data(Vector2.ZERO, invalid_data)
	if can_drop:
		print("❌ Should reject invalid data")
		facility_card.queue_free()
		return false

	# Test locked facility
	facility_card.set_unlock_status(false)
	can_drop = facility_card._can_drop_data(Vector2.ZERO, valid_data)
	if can_drop:
		print("❌ Should reject drops on locked facility")
		facility_card.queue_free()
		return false

	facility_card.queue_free()
	print("✅ Drop validation working correctly")
	return true

func _test_assignment_creation() -> bool:
	# Create test creature and add to collection
	var test_creature = CreatureData.new()
	test_creature.id = "test_assignment_creature_" + str(randi())
	test_creature.creature_name = "Test Assignment Creature"
	test_creature.species_id = "basic_species"
	test_creature.age_weeks = 5
	test_creature.lifespan_weeks = 52

	var collection = GameCore.get_system("collection")
	collection.add_creature(test_creature)

	# Get facility system
	var facility_system = GameCore.get_system("facility")
	var facilities = facility_system.get_all_facilities()
	var test_facility = facilities[0]

	# Ensure facility is unlocked
	if not facility_system.is_facility_unlocked(test_facility.facility_id):
		# Add gold and unlock facility for testing
		var resource_tracker = GameCore.get_system("resource")
		resource_tracker.add_gold(1000)
		facility_system.unlock_facility(test_facility.facility_id)

	# Create facility card
	var facility_card_scene = preload("res://scenes/ui/components/facility_card.tscn")
	var facility_card = facility_card_scene.instantiate()
	add_child(facility_card)

	facility_card.set_facility(test_facility)
	facility_card.set_unlock_status(true)
	facility_card.set_selected_food_type(0)  # Set valid selections
	facility_card.set_selected_activity(0)

	await get_tree().process_frame

	# Test assignment creation
	var success = facility_card._create_immediate_assignment(test_creature, 0, 0)

	if not success:
		print("❌ Failed to create assignment")
		facility_card.queue_free()
		return false

	# Verify assignment was created
	var assignment = facility_system.get_assignment(test_facility.facility_id)
	if not assignment:
		print("❌ Assignment not found after creation")
		facility_card.queue_free()
		return false

	if assignment.creature_id != test_creature.id:
		print("❌ Assignment has wrong creature ID")
		facility_card.queue_free()
		return false

	# Clean up
	facility_system.remove_creature(test_facility.facility_id)
	collection.remove_creature(test_creature.id)
	facility_card.queue_free()

	print("✅ Assignment creation working correctly")
	return true