extends Control

# Facility View Controller - Main facility management screen
# Displays all facilities in a grid, handles assignment/removal, unlock flow

# Note: Food items are now dynamically loaded from ItemManager

@onready var facility_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/FacilityGrid
@onready var warning_container: HBoxContainer = $MarginContainer/VBoxContainer/Header/StatusBar/WarningContainer
@onready var warning_label: Label = $MarginContainer/VBoxContainer/Header/StatusBar/WarningContainer/WarningLabel
@onready var processing_label: Label = $MarginContainer/VBoxContainer/Header/StatusBar/ProcessingLabel
@onready var notification_panel: PanelContainer = $NotificationPanel
@onready var notification_label: Label = $NotificationPanel/VBoxContainer/NotificationLabel
@onready var creature_area: Control = $MarginContainer/VBoxContainer/CreaturePanel/VBoxContainer/CreatureArea
@onready var next_week_button: Button = $NextWeekButtonOverlay/NextWeekButton

var facility_system: Node
var resource_tracker: Node
var signal_bus: Node
var time_system: Node
var player_collection: Node
var facility_cards: Array[Control] = []
var creature_entities: Array[Node2D] = []

var _is_processing_week: bool = false
var _has_interacted_with_facility: bool = false

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_load_facilities()
	load_unassigned_creatures()
	_update_next_week_button()

	# Connect to visibility changes to refresh when shown
	visibility_changed.connect(_on_visibility_changed)

func _initialize_systems() -> void:
	facility_system = GameCore.get_system("facility")
	resource_tracker = GameCore.get_system("resource")
	time_system = GameCore.get_system("time")
	player_collection = GameCore.get_system("collection")
	signal_bus = GameCore.get_signal_bus()

	if not facility_system:
		push_error("FacilityViewController: FacilitySystem not found")
		return

	if not resource_tracker:
		push_error("FacilityViewController: ResourceTracker not found")
		return

	if not time_system:
		push_error("FacilityViewController: TimeSystem not found")
		return

	if not player_collection:
		push_error("FacilityViewController: PlayerCollection not found")
		return

func _setup_signals() -> void:
	if not signal_bus:
		return

	# Connect to facility events
	if signal_bus.has_signal("facility_unlocked"):
		signal_bus.facility_unlocked.connect(_on_facility_unlocked)

	if signal_bus.has_signal("creature_assigned_to_facility"):
		signal_bus.creature_assigned_to_facility.connect(_on_creature_assigned_to_facility)

	if signal_bus.has_signal("facility_assignment_removed"):
		signal_bus.facility_assignment_removed.connect(_on_facility_assignment_removed)

	# Connect to resource changes
	if signal_bus.has_signal("gold_changed"):
		signal_bus.gold_changed.connect(_on_gold_changed)

	# Connect to resource inventory changes
	if signal_bus.has_signal("item_quantity_changed"):
		signal_bus.item_quantity_changed.connect(_on_item_quantity_changed)

	# Connect to week advance events
	if signal_bus.has_signal("week_advance_started"):
		signal_bus.week_advance_started.connect(_on_week_advance_started)

	if signal_bus.has_signal("week_advance_completed"):
		signal_bus.week_advance_completed.connect(_on_week_advance_completed)

	if signal_bus.has_signal("week_advance_blocked"):
		signal_bus.week_advance_blocked.connect(_on_week_advance_blocked)

	# Connect to time advance blocked events
	if signal_bus.has_signal("time_advance_blocked"):
		signal_bus.time_advance_blocked.connect(_on_time_advance_blocked)

	# Connect to creature acquisition events to refresh the area
	if signal_bus.has_signal("creature_acquired"):
		signal_bus.creature_acquired.connect(_on_creature_acquired)

	if signal_bus.has_signal("active_roster_changed"):
		signal_bus.active_roster_changed.connect(_on_roster_changed)

	if signal_bus.has_signal("stable_collection_updated"):
		signal_bus.stable_collection_updated.connect(_on_stable_updated)

func _load_facilities() -> void:
	if not facility_system:
		return

	# Clear existing cards
	_clear_facility_cards()

	# Get all facilities from the system
	var facilities = facility_system.get_all_facilities()

	# Create a card for each facility
	for facility_resource in facilities:
		_create_facility_card(facility_resource)

	# Update grid columns based on number of facilities
	_update_grid_columns()

func load_unassigned_creatures() -> void:
	"""Load and display all creatures not currently assigned to facilities"""
	if not player_collection or not creature_area:
		return

	# Clear existing creature entities
	_clear_creature_entities()

	# Get all creatures from collection
	var all_creatures = player_collection.get_all_creatures()
	print("[FacilityView] Found ", all_creatures.size(), " total creatures in collection")

	# Filter to get only unassigned creatures
	var unassigned_creatures: Array[CreatureData] = []
	for creature in all_creatures:
		if not _is_creature_assigned_to_facility(creature.id):
			unassigned_creatures.append(creature)

	print("[FacilityView] ", unassigned_creatures.size(), " creatures are unassigned")

	# Create creature entities for unassigned creatures
	for creature in unassigned_creatures:
		_create_creature_entity(creature)

	# Show message if no unassigned creatures
	if unassigned_creatures.is_empty():
		var label = Label.new()
		label.text = "All creatures are assigned to facilities"
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		label.anchor_left = 0.5
		label.anchor_top = 0.5
		label.anchor_right = 0.5
		label.anchor_bottom = 0.5
		creature_area.add_child(label)

func _clear_creature_entities() -> void:
	"""Clear all creature entities from the area"""
	for entity in creature_entities:
		if is_instance_valid(entity):
			entity.queue_free()
	creature_entities.clear()

	# Also clear any other children in the area
	for child in creature_area.get_children():
		if not child.name == "Background":
			child.queue_free()

func _create_creature_entity(creature: CreatureData) -> void:
	"""Create a creature entity for dragging and display"""
	var entity_scene = preload("res://scenes/entities/creature_entity.tscn")
	var entity = entity_scene.instantiate()
	entity.name = "CreatureEntity_" + creature.id  # Give it a unique name

	# Add to the creature area
	creature_area.add_child(entity)

	# Set creature data and configure
	if entity.has_method("set_creature_data"):
		entity.set_creature_data(creature)

	# Connect drag signals
	if entity.has_signal("drag_started"):
		entity.drag_started.connect(_on_creature_entity_drag_started)
	if entity.has_signal("drag_ended"):
		entity.drag_ended.connect(_on_creature_entity_drag_ended)

	# Position randomly in container
	var container_size = creature_area.size
	entity.position = Vector2(
		randf_range(30, container_size.x - 30),
		randf_range(30, container_size.y - 30)
	)

	# Set the area bounds for entity movement
	if entity.has_method("set_area_bounds"):
		var area_rect = Rect2(Vector2.ZERO, creature_area.size)
		entity.set_area_bounds(area_rect)

	creature_entities.append(entity)
	print("[FacilityView] Created entity for creature: ", creature.creature_name, " (", creature.id, ")")

func _on_creature_entity_drag_started(creature: CreatureData) -> void:
	"""Handle start of creature entity drag"""
	# Set drag preview cursor
	Input.set_default_cursor_shape(Input.CURSOR_MOVE)
	print("[FacilityView] Drag started for creature: ", creature.creature_name if creature else "null")

func _on_creature_entity_drag_ended(creature: CreatureData, dropped: bool) -> void:
	"""Handle end of creature entity drag"""
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if dropped:
		# Check if dropped on a facility card
		var dropped_on_facility = _get_facility_under_mouse()
		if dropped_on_facility and creature:
			# Check if facility is unlocked
			if facility_system and facility_system.is_facility_unlocked(dropped_on_facility):
				# Show assignment dialog for this creature and facility
				_show_assignment_dialog_for_creature(dropped_on_facility, creature.id)
			else:
				_show_notification("Facility is locked")

	print("[FacilityView] Drag ended for creature: ", creature.creature_name if creature else "null", " dropped: ", dropped)

func _get_facility_under_mouse() -> String:
	"""Check if mouse is over a facility card and return its ID"""
	var mouse_pos = get_global_mouse_position()

	for card in facility_cards:
		if not is_instance_valid(card):
			continue

		var card_rect = card.get_global_rect()
		if card_rect.has_point(mouse_pos):
			return card.get_facility_id()

	return ""

func _get_random_position_in_creature_area() -> Vector2:
	"""Get a random position within the creature area"""
	if not creature_area:
		return Vector2(100, 100)

	var margin = 30
	var x = randf_range(margin, creature_area.size.x - margin)
	var y = randf_range(margin, creature_area.size.y - margin)
	return Vector2(x, y)


func _is_creature_assigned_to_facility(creature_id: String) -> bool:
	"""Check if a creature is assigned to any facility"""
	if not facility_system:
		return false

	var all_facilities = facility_system.get_all_facilities()
	for facility_resource in all_facilities:
		var assignment = facility_system.get_assignment(facility_resource.facility_id)
		if assignment and assignment.creature_id == creature_id:
			return true
	return false

func _create_facility_card(facility_resource) -> void:
	# Load the facility card scene
	var facility_card_scene = preload("res://scenes/ui/components/facility_card.tscn")
	var facility_card = facility_card_scene.instantiate()

	# Set up the facility data
	facility_card.set_facility(facility_resource)

	# Set unlock status from FacilitySystem
	var is_unlocked = facility_system.is_facility_unlocked(facility_resource.facility_id)
	facility_card.set_unlock_status(is_unlocked)

	# Get current assignment if any
	var assignment = facility_system.get_assignment(facility_resource.facility_id)
	if assignment:
		facility_card.set_assignment(assignment)

	# Connect card signals
	facility_card.assign_pressed.connect(_on_assign_pressed)
	facility_card.remove_pressed.connect(_on_remove_pressed)
	facility_card.unlock_pressed.connect(_on_unlock_pressed)

	# Add to grid and tracking array
	facility_grid.add_child(facility_card)
	facility_cards.append(facility_card)

func _clear_facility_cards() -> void:
	for card in facility_cards:
		if is_instance_valid(card):
			card.queue_free()
	facility_cards.clear()

func _update_grid_columns() -> void:
	var facility_count = facility_cards.size()

	# Set columns based on facility count
	if facility_count <= 2:
		facility_grid.columns = facility_count
	elif facility_count <= 6:
		facility_grid.columns = 3
	else:
		facility_grid.columns = 4

func refresh_facilities() -> void:
	if not facility_system:
		return

	# Update each facility card
	for card in facility_cards:
		if not is_instance_valid(card):
			continue

		var facility_id = card.get_facility_id()
		if facility_id.is_empty():
			continue

		# Update unlock status from FacilitySystem
		var is_unlocked = facility_system.is_facility_unlocked(facility_id)
		card.set_unlock_status(is_unlocked)

		# Get updated assignment
		var assignment = facility_system.get_assignment(facility_id)
		card.set_assignment(assignment)

		# Update food warning status
		var has_food_warning = false
		if assignment:
			has_food_warning = not _has_required_food_for_assignment(assignment)
		card.set_food_warning(has_food_warning)

	# Update Next Week button state after refreshing facilities
	_update_next_week_button()

func _has_required_food_for_assignment(assignment) -> bool:
	if not assignment or not resource_tracker:
		return true

	var food_item_id = _get_food_item_id(assignment.food_type)
	if food_item_id.is_empty():
		return true

	return resource_tracker.get_item_count(food_item_id) > 0

func _get_food_item_id(food_type: int) -> String:
	# Get item ID from ItemManager (matches assignment dialog filtered logic)
	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")
	if not item_manager or not resource_tracker:
		return ""

	var inventory = resource_tracker.get_inventory()

	# Get all consumable food items that are in stock (same logic as assignment dialog)
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

func _on_assign_pressed(facility_id: String) -> void:
	# Check if a creature was dropped onto the facility card
	var dropped_creature_id: String = ""
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			dropped_creature_id = card.get_dropped_creature_id()
			break

	# Open assignment dialog with or without pre-selected creature
	if not dropped_creature_id.is_empty():
		_show_assignment_dialog_for_creature(facility_id, dropped_creature_id)
	else:
		_show_assignment_dialog(facility_id)

func _on_remove_pressed(facility_id: String) -> void:
	if not facility_system:
		return

	var success = facility_system.remove_creature(facility_id)
	if success:
		# Refresh facility cards to show the change
		refresh_facilities()
	else:
		_show_notification("Failed to remove creature from facility")

func _on_unlock_pressed(facility_id: String) -> void:
	if not facility_system or not resource_tracker:
		return

	# Get facility to check unlock cost
	var facility_resource = facility_system.get_facility(facility_id)
	if not facility_resource:
		_show_notification("Facility not found")
		return

	# Check if player can afford it
	var gold_count = resource_tracker.get_balance()
	if gold_count < facility_resource.unlock_cost:
		_show_notification("Insufficient gold to unlock facility")
		return

	# Attempt to unlock
	var success = facility_system.unlock_facility(facility_id)
	if success:
		_show_notification("Facility unlocked!")
	else:
		_show_notification("Failed to unlock facility")

func _check_food_warnings() -> void:
	var has_warnings = false

	for card in facility_cards:
		if not is_instance_valid(card):
			continue

		if card.is_assigned():
			var facility_id = card.get_facility_id()
			var assignment = facility_system.get_assignment(facility_id)

			if assignment and not _has_required_food_for_assignment(assignment):
				has_warnings = true
				break

	# Update warning display
	if warning_container:
		warning_container.visible = has_warnings

func _show_notification(message: String) -> void:
	if notification_panel and notification_label:
		notification_label.text = message
		notification_panel.visible = true

		# Auto-hide after 3 seconds
		get_tree().create_timer(3.0).timeout.connect(_hide_notification)

func _hide_notification() -> void:
	if notification_panel:
		notification_panel.visible = false

func _on_notification_close() -> void:
	_hide_notification()

# Signal handlers
func _on_facility_unlocked(facility_id: String) -> void:
	# Find and update the specific card
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			# Update unlock status from FacilitySystem
			var is_unlocked = facility_system.is_facility_unlocked(facility_id)
			card.set_unlock_status(is_unlocked)
			break

func _on_creature_assigned_to_facility(creature_id: String, facility_id: String, activity: int, food_type: int) -> void:
	# Find and update the specific card
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			var assignment = facility_system.get_assignment(facility_id)
			if assignment:
				card.set_assignment(assignment)
			break

	# Mark that player has interacted with facility system
	_has_interacted_with_facility = true

	# Check for food warnings
	_check_food_warnings()

	# Update Next Week button state
	_update_next_week_button()

	# Refresh unassigned creatures list
	load_unassigned_creatures()

func _on_facility_assignment_removed(facility_id: String, creature_id: String) -> void:
	# Find and update the specific card
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			card.set_assignment(null)
			break

	# Check for food warnings
	_check_food_warnings()

	# Update Next Week button state
	_update_next_week_button()

	# Refresh unassigned creatures list
	load_unassigned_creatures()

func _on_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
	# Update unlock button states on all cards
	refresh_facilities()

func _on_item_quantity_changed(item_id: String, old_quantity: int, new_quantity: int) -> void:
	"""Handle item quantity changes that might affect facility food availability"""
	# Update button state when items change (affects food availability)
	_update_next_week_button()

	# Also refresh facilities to update food warnings
	_check_food_warnings()

func _on_week_advance_started() -> void:
	_is_processing_week = true
	if processing_label:
		processing_label.visible = true

func _on_week_advance_completed() -> void:
	_is_processing_week = false
	if processing_label:
		processing_label.visible = false

	# Refresh all facilities after week advance
	refresh_facilities()

func _on_week_advance_blocked(reason: String, missing_food_facilities: Array[String]) -> void:
	# Highlight facilities that are missing food
	for card in facility_cards:
		if not is_instance_valid(card):
			continue

		var facility_id = card.get_facility_id()
		var has_warning = facility_id in missing_food_facilities
		card.set_food_warning(has_warning)

	# Show warning message
	if warning_container and warning_label:
		warning_container.visible = true
		warning_label.text = reason

	_show_notification("Week advance blocked: " + reason)

func _on_time_advance_blocked(reasons: Array[String]) -> void:
	"""Handle time advancement being blocked by the time system"""
	_is_processing_week = false
	if processing_label:
		processing_label.visible = false

	# Update button state
	_update_next_week_button()

	# Show notification with first reason
	if reasons.size() > 0:
		_show_notification("Time blocked: " + reasons[0])
	else:
		_show_notification("Time advancement blocked")

func _show_assignment_dialog(facility_id: String) -> void:
	"""Show the creature assignment dialog for the specified facility"""
	if not facility_system:
		return

	# Get the facility resource
	var facility_resource = facility_system.get_facility(facility_id)
	if not facility_resource:
		_show_notification("Facility not found")
		return

	# Load and instantiate the dialog
	var dialog_scene = preload("res://scenes/ui/facility_assignment_dialog.tscn")
	var dialog = dialog_scene.instantiate()

	# Add to scene tree
	get_tree().root.add_child(dialog)

	# Setup the dialog with facility data
	dialog.setup(facility_resource)

	# Connect to assignment confirmation
	dialog.assignment_confirmed.connect(_on_assignment_confirmed)

	# Show the dialog
	dialog.popup_centered()

func _on_assignment_confirmed(facility_id: String, creature_id: String, activity: int, food_type: int) -> void:
	"""Handle successful creature assignment from dialog"""
	_show_notification("Creature assigned successfully!")

	# Refresh the facility display to show the new assignment
	refresh_facilities()

func get_facility_cards() -> Array[Control]:
	return facility_cards.duplicate()

func has_food_warnings() -> bool:
	for card in facility_cards:
		if is_instance_valid(card) and card.is_assigned():
			var facility_id = card.get_facility_id()
			var assignment = facility_system.get_assignment(facility_id)
			if assignment and not _has_required_food_for_assignment(assignment):
				return true
	return false

func _update_next_week_button() -> void:
	"""Update the Next Week button state and tooltip based on time advancement capability"""
	if not next_week_button or not time_system:
		return

	var can_advance = _can_advance_time()
	var tooltip = _get_next_week_tooltip()

	next_week_button.disabled = not can_advance
	next_week_button.tooltip_text = tooltip

func _can_advance_time() -> bool:
	"""Check if time advancement is currently possible"""
	if not time_system or not facility_system:
		return false

	# Check with the time system if advancement is possible
	var advance_check = time_system.can_advance_time()
	if not advance_check.can_advance:
		return false

	# Check for creature assignment and food selection (tutorial requirements)
	var has_training_assignment = false
	var has_food_selected = false

	var all_facilities = facility_system.get_all_facilities()
	for facility in all_facilities:
		var assignment = facility_system.get_assignment(facility.facility_id)
		if assignment:
			has_training_assignment = true
			if assignment.food_type >= 0:
				has_food_selected = true

	# Must have at least one assignment with food selected
	if not has_training_assignment or not has_food_selected:
		return false

	# Check if all facilities have required food for advancement
	if not facility_system.has_food_for_all_facilities():
		return false

	return true

func _get_next_week_tooltip() -> String:
	"""Get the appropriate tooltip message for the Next Week button"""
	if not time_system:
		return "Time system not ready"

	# First check if time advancement is blocked by the time system
	var advance_check = time_system.can_advance_time()
	if not advance_check.can_advance:
		if advance_check.reasons.size() > 0:
			return advance_check.reasons[0]  # Show the first blocking reason
		else:
			return "Time advancement blocked"

	# Check facility system
	if not facility_system:
		return "Facility system not ready"

	# Check if all facilities have required food
	if not facility_system.has_food_for_all_facilities():
		return "Some facilities are missing food"

	# Check for creature assignment and food selection
	var has_training_assignment = false
	var has_food_selected = false

	var all_facilities = facility_system.get_all_facilities()
	for facility in all_facilities:
		var assignment = facility_system.get_assignment(facility.facility_id)
		if assignment:
			has_training_assignment = true
			if assignment.food_type >= 0:
				has_food_selected = true

	if not has_training_assignment:
		return "Assign a creature to training"

	if not has_food_selected:
		return "Select food for training"

	# If all conditions met
	return "Click to advance time"

func _on_next_week_pressed() -> void:
	"""Handle Next Week button press - advance time via time system"""
	if not _can_advance_time():
		return

	if not time_system:
		_show_notification("Time system not available")
		return

	# Advance the week
	var success = time_system.advance_week()

	if success:
		_show_notification("Week advanced!")
	else:
		_show_notification("Failed to advance week")

# Drag and drop handling moved to entity drag signal callbacks above

func _on_creature_acquired(creature_data: CreatureData, source: String) -> void:
	"""Handle when a new creature is acquired"""
	print("[FacilityView] Creature acquired: ", creature_data.creature_name if creature_data else "null", " from ", source)
	# Refresh the unassigned creatures display if we're visible
	if is_visible_in_tree():
		load_unassigned_creatures()

func _on_roster_changed(active_creatures: Array[CreatureData]) -> void:
	"""Handle when the active roster changes"""
	print("[FacilityView] Roster changed, refreshing creatures")
	# Refresh if visible
	if is_visible_in_tree():
		load_unassigned_creatures()

func _on_stable_updated(action: String, creature_id: String) -> void:
	"""Handle when the stable collection is updated"""
	print("[FacilityView] Stable updated: ", action, " for creature: ", creature_id)
	# Refresh if visible
	if is_visible_in_tree():
		load_unassigned_creatures()

func _on_visibility_changed() -> void:
	"""Handle when the facility view becomes visible or hidden"""
	if is_visible_in_tree():
		print("[FacilityView] Became visible, refreshing creatures")
		# Refresh creatures when we become visible
		load_unassigned_creatures()
		# Also refresh facilities in case assignments changed
		refresh_facilities()

func _show_assignment_dialog_for_creature(facility_id: String, creature_id: String) -> void:
	"""Show the assignment dialog with a pre-selected creature"""
	if not facility_system:
		return

	# Get the facility resource
	var facility_resource = facility_system.get_facility(facility_id)
	if not facility_resource:
		_show_notification("Facility not found")
		return

	# Load and instantiate the dialog
	var dialog_scene = preload("res://scenes/ui/facility_assignment_dialog.tscn")
	var dialog = dialog_scene.instantiate()

	# Add to scene tree
	get_tree().root.add_child(dialog)

	# Setup the dialog with facility data
	dialog.setup(facility_resource)

	# Pre-select the creature if the dialog supports it
	if dialog.has_method("set_selected_creature"):
		dialog.set_selected_creature(creature_id)

	# Connect to assignment confirmation
	dialog.assignment_confirmed.connect(_on_assignment_confirmed)

	# Show the dialog
	dialog.popup_centered()
