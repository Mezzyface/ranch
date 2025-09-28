extends Window

# Facility Assignment Dialog Controller
# Handles creature assignment to training facilities

# Note: Food items are now dynamically loaded from ItemManager

signal assignment_confirmed(facility_id: String, creature_id: String, activity: int, food_type: int)

@onready var facility_label: Label = $MarginContainer/VBoxContainer/FacilityLabel
@onready var creature_list: VBoxContainer = $MarginContainer/VBoxContainer/CreatureSection/CreatureScrollContainer/CreatureList
@onready var activity_option: OptionButton = $MarginContainer/VBoxContainer/ActivitySection/ActivityOption
@onready var food_grid: GridContainer = $MarginContainer/VBoxContainer/FoodSection/FoodScrollContainer/FoodGrid
@onready var confirm_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/ConfirmButton

# System references
var facility_system: Node
var player_collection: Node
var resource_tracker: Node
var training_system: Node
var signal_bus: Node

# Current dialog state
var current_facility: FacilityResource
var selected_creature_id: String = ""
var selected_activity: int = -1
var selected_food_type: int = -1

# UI tracking
var creature_buttons: Array[Button] = []
var food_buttons: Array[Button] = []
var creature_button_group: ButtonGroup
var food_button_group: ButtonGroup

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_create_button_groups()

func _initialize_systems() -> void:
	facility_system = GameCore.get_system("facility")
	player_collection = GameCore.get_system("collection")
	resource_tracker = GameCore.get_system("resource")
	training_system = GameCore.get_system("training")
	signal_bus = GameCore.get_signal_bus()

	if not facility_system:
		push_error("FacilityAssignmentDialog: FacilitySystem not found")
	if not player_collection:
		push_error("FacilityAssignmentDialog: PlayerCollection not found")
	if not resource_tracker:
		push_error("FacilityAssignmentDialog: ResourceTracker not found")
	if not training_system:
		push_error("FacilityAssignmentDialog: TrainingSystem not found")

func _setup_signals() -> void:
	if activity_option:
		activity_option.item_selected.connect(_on_activity_selected)

func _create_button_groups() -> void:
	"""Create button groups for exclusive selection"""
	creature_button_group = ButtonGroup.new()
	food_button_group = ButtonGroup.new()

func setup(facility: FacilityResource) -> void:
	"""Initialize dialog with facility data"""
	current_facility = facility
	if not current_facility:
		push_error("FacilityAssignmentDialog: No facility provided")
		return

	_reset_selections()
	_update_facility_display()
	populate_creatures()
	populate_activities()
	populate_food_items()
	_update_confirm_button()

func _reset_selections() -> void:
	"""Reset all selection state"""
	selected_creature_id = ""
	selected_activity = -1
	selected_food_type = -1

func _update_facility_display() -> void:
	"""Update facility name display"""
	if facility_label and current_facility:
		facility_label.text = current_facility.display_name

func populate_creatures() -> void:
	"""Populate creature selection list"""
	_clear_creature_buttons()

	if not player_collection:
		return

	var active_creatures = player_collection.get_active_creatures()
	var available_creatures: Array[CreatureData] = []

	# Filter out creatures already assigned to facilities
	for creature in active_creatures:
		if not _is_creature_assigned_to_facility(creature.id):
			available_creatures.append(creature)

	# Create button for each available creature
	for creature in available_creatures:
		_create_creature_button(creature)

	# Show message if no creatures available
	if available_creatures.is_empty():
		var no_creatures_label = Label.new()
		no_creatures_label.text = "No available creatures for assignment"
		no_creatures_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_creatures_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		creature_list.add_child(no_creatures_label)

func _is_creature_assigned_to_facility(creature_id: String) -> bool:
	"""Check if creature is already assigned to any facility"""
	if not facility_system:
		return false

	var all_facilities = facility_system.get_all_facilities()
	for facility_resource in all_facilities:
		var assignment = facility_system.get_assignment(facility_resource.facility_id)
		if assignment and assignment.creature_id == creature_id:
			return true
	return false

func _create_creature_button(creature: CreatureData) -> void:
	"""Create a selectable button for a creature"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.toggle_mode = true
	button.button_group = creature_button_group

	# Set button text with creature info
	var age_category_name = _get_age_category_name(creature.get_age_category())
	button.text = "%s (%s, %d weeks)" % [creature.creature_name, age_category_name, creature.age_weeks]

	# Connect signal with correct parameter order
	button.toggled.connect(func(pressed: bool): _on_creature_button_toggled(creature.id, pressed))

	creature_list.add_child(button)
	creature_buttons.append(button)


func _get_age_category_name(category: int) -> String:
	"""Convert age category enum to display name"""
	match category:
		0: return "Baby"
		1: return "Juvenile"
		2: return "Adult"
		3: return "Elder"
		4: return "Ancient"
		_: return "Unknown"

func populate_activities() -> void:
	"""Populate activity selection dropdown"""
	if not activity_option or not current_facility or not training_system:
		return

	activity_option.clear()

	# Get supported activities for this facility type
	var supported_activities = _get_supported_activities()

	for activity in supported_activities:
		var activity_name = training_system.get_activity_name(activity)
		activity_option.add_item(activity_name)
		activity_option.set_item_metadata(activity_option.get_item_count() - 1, activity)

func _get_supported_activities() -> Array[int]:
	"""Get activities supported by current facility"""
	if not current_facility:
		return []

	# Return the facility's supported activities
	return current_facility.supported_activities

func populate_food_items() -> void:
	"""Populate food item selection grid"""
	_clear_food_buttons()

	if not resource_tracker:
		return

	var inventory = resource_tracker.get_inventory()
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		return

	# Get all consumable food items from ItemManager
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)

	# Filter for consumable food items that are in stock
	var available_foods: Array[ItemResource] = []
	for item_resource in food_items:
		if item_resource.is_consumable:
			var quantity = inventory.get(item_resource.item_id, 0)
			if quantity > 0:  # Only include items we have in stock
				available_foods.append(item_resource)

	# Create buttons for each available food item
	for i in range(available_foods.size()):
		var item_resource = available_foods[i]
		var quantity = inventory.get(item_resource.item_id, 0)
		_create_food_button(item_resource.item_id, item_resource.display_name, quantity, i)

func get_food_item_id_by_index(food_type: int) -> String:
	"""Get food item ID by food type index"""
	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")
	if not item_manager or not resource_tracker:
		return ""

	var inventory = resource_tracker.get_inventory()

	# Get all consumable food items that are in stock (same as populate_food_items)
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)
	var available_foods: Array[ItemResource] = []
	for item_resource in food_items:
		if item_resource.is_consumable:
			var quantity = inventory.get(item_resource.item_id, 0)
			if quantity > 0:  # Only include items we have in stock
				available_foods.append(item_resource)

	# Return item ID at the specified index
	if food_type >= 0 and food_type < available_foods.size():
		return available_foods[food_type].item_id
	return ""

func _create_food_button(item_id: String, display_name: String, quantity: int, food_type: int) -> void:
	"""Create a selectable button for a food item"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.toggle_mode = true
	button.button_group = food_button_group

	# Set button text with food info and quantity
	button.text = "%s\n(%d available)" % [display_name, quantity]

	# Disable if no quantity available
	if quantity <= 0:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5)

	# Connect signal with correct parameter order
	button.toggled.connect(func(pressed: bool): _on_food_button_toggled(food_type, pressed))

	food_grid.add_child(button)
	food_buttons.append(button)


func _clear_creature_buttons() -> void:
	"""Clear all creature selection buttons"""
	for button in creature_buttons:
		if is_instance_valid(button):
			button.queue_free()
	creature_buttons.clear()

	# Clear any existing children
	for child in creature_list.get_children():
		child.queue_free()

func _clear_food_buttons() -> void:
	"""Clear all food selection buttons"""
	for button in food_buttons:
		if is_instance_valid(button):
			button.queue_free()
	food_buttons.clear()

	# Clear any existing children
	for child in food_grid.get_children():
		child.queue_free()

func _update_confirm_button() -> void:
	"""Update confirm button enabled state"""
	if not confirm_button:
		return

	var has_creature = not selected_creature_id.is_empty()
	var has_activity = selected_activity >= 0
	var has_food = selected_food_type >= 0

	confirm_button.disabled = not (has_creature and has_activity and has_food)

# Signal handlers
func _on_creature_button_toggled(creature_id: String, pressed: bool) -> void:
	"""Handle creature selection"""
	if pressed:
		selected_creature_id = creature_id
	else:
		selected_creature_id = ""
	_update_confirm_button()

func _on_activity_selected(index: int) -> void:
	"""Handle activity selection"""
	if activity_option and index >= 0 and index < activity_option.get_item_count():
		selected_activity = activity_option.get_item_metadata(index)
	else:
		selected_activity = -1
	_update_confirm_button()

func _on_food_button_toggled(food_type: int, pressed: bool) -> void:
	"""Handle food selection"""
	if pressed:
		selected_food_type = food_type
	else:
		selected_food_type = -1
	_update_confirm_button()

func _on_confirm_pressed() -> void:
	"""Handle confirm button press"""
	print("Assignment Dialog: Attempting to assign creature to facility")
	print("  Facility: " + (current_facility.facility_id if current_facility else "None"))
	print("  Creature: " + selected_creature_id)
	print("  Activity: " + str(selected_activity))
	print("  Food: " + str(selected_food_type))

	if not _validate_selections():
		print("Assignment Dialog: Validation failed")
		return

	# Attempt to assign creature through FacilitySystem
	if facility_system:
		var success = facility_system.assign_creature(
			current_facility.facility_id,
			selected_creature_id,
			selected_activity,
			selected_food_type
		)

		if success:
			print("Assignment Dialog: Assignment successful!")
			# Emit signal for any listeners
			assignment_confirmed.emit(
				current_facility.facility_id,
				selected_creature_id,
				selected_activity,
				selected_food_type
			)
			hide()
		else:
			print("Assignment Dialog: Assignment failed - check error messages above")
			push_error("Failed to assign creature to facility")
	else:
		push_error("FacilitySystem not available for assignment")

func _validate_selections() -> bool:
	"""Validate all required selections are made"""
	if selected_creature_id.is_empty():
		push_error("No creature selected")
		return false

	if selected_activity < 0:
		push_error("No activity selected")
		return false

	if selected_food_type < 0:
		push_error("No food selected")
		return false

	if not current_facility:
		push_error("No facility set")
		return false

	return true

func _on_cancel_pressed() -> void:
	"""Handle cancel button press"""
	hide()

func _on_close_requested() -> void:
	"""Handle window close request"""
	hide()