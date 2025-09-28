extends Control

# Facility View Controller - Main facility management screen
# Displays all facilities in a grid, handles assignment/removal, unlock flow

@onready var facility_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/FacilityGrid
@onready var warning_container: HBoxContainer = $MarginContainer/VBoxContainer/Header/StatusBar/WarningContainer
@onready var warning_label: Label = $MarginContainer/VBoxContainer/Header/StatusBar/WarningContainer/WarningLabel
@onready var processing_label: Label = $MarginContainer/VBoxContainer/Header/StatusBar/ProcessingLabel
@onready var notification_panel: PanelContainer = $NotificationPanel
@onready var notification_label: Label = $NotificationPanel/VBoxContainer/NotificationLabel

var facility_system: Node
var resource_tracker: Node
var signal_bus: Node
var facility_cards: Array[Control] = []

var _is_processing_week: bool = false

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_load_facilities()

func _initialize_systems() -> void:
	facility_system = GameCore.get_system("facility")
	resource_tracker = GameCore.get_system("resource")
	signal_bus = GameCore.get_signal_bus()

	if not facility_system:
		push_error("FacilityViewController: FacilitySystem not found")
		return

	if not resource_tracker:
		push_error("FacilityViewController: ResourceTracker not found")
		return

func _setup_signals() -> void:
	if not signal_bus:
		return

	# Connect to facility events
	if signal_bus.has_signal("facility_unlocked"):
		signal_bus.facility_unlocked.connect(_on_facility_unlocked)

	if signal_bus.has_signal("facility_assigned"):
		signal_bus.facility_assigned.connect(_on_facility_assigned)

	if signal_bus.has_signal("facility_unassigned"):
		signal_bus.facility_unassigned.connect(_on_facility_unassigned)

	# Connect to resource changes
	if signal_bus.has_signal("gold_changed"):
		signal_bus.gold_changed.connect(_on_gold_changed)

	# Connect to week advance events
	if signal_bus.has_signal("week_advance_started"):
		signal_bus.week_advance_started.connect(_on_week_advance_started)

	if signal_bus.has_signal("week_advance_completed"):
		signal_bus.week_advance_completed.connect(_on_week_advance_completed)

	if signal_bus.has_signal("week_advance_blocked"):
		signal_bus.week_advance_blocked.connect(_on_week_advance_blocked)

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

func _has_required_food_for_assignment(assignment) -> bool:
	if not assignment or not resource_tracker:
		return true

	var food_item_id = _get_food_item_id(assignment.food_type)
	if food_item_id.is_empty():
		return true

	return resource_tracker.get_item_count(food_item_id) > 0

func _get_food_item_id(food_type: int) -> String:
	# Map food types to actual item IDs - matches facility_card.gd
	match food_type:
		0: return "food_basic"
		1: return "food_premium"
		2: return "food_special"
		_: return ""

func _on_assign_pressed(facility_id: String) -> void:
	# Open creature selection UI or directly assign if only one option
	# For now, emit a signal that UI manager can handle
	if signal_bus and signal_bus.has_signal("facility_assignment_requested"):
		signal_bus.facility_assignment_requested.emit(facility_id)

func _on_remove_pressed(facility_id: String) -> void:
	if not facility_system:
		return

	var success = facility_system.unassign_creature(facility_id)
	if not success:
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

func _on_facility_assigned(facility_id: String, creature_id: String) -> void:
	# Find and update the specific card
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			var assignment = facility_system.get_assignment(facility_id)
			if assignment:
				card.set_assignment(assignment)
			break

	# Check for food warnings
	_check_food_warnings()

func _on_facility_unassigned(facility_id: String, creature_id: String) -> void:
	# Find and update the specific card
	for card in facility_cards:
		if is_instance_valid(card) and card.get_facility_id() == facility_id:
			card.set_assignment(null)
			break

	# Check for food warnings
	_check_food_warnings()

func _on_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
	# Update unlock button states on all cards
	refresh_facilities()

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