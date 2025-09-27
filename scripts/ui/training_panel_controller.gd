extends Control

# Controller reference - NO direct system access
var game_controller: GameController = null

# UI References
@onready var facilities_grid = $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid
@onready var creature_dropdown = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/CreatureSelection/CreatureDropdown
@onready var schedule_list = $VSplitContainer/BottomSection/SchedulePanel/ScheduleContent/ScheduleList
@onready var progress_list = $VSplitContainer/BottomSection/ProgressPanel/ProgressContent/ProgressList

# Training Food Buttons
@onready var power_bar_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/TrainingFoodsSection/FoodsGrid/PowerBarButton
@onready var speed_snack_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/TrainingFoodsSection/FoodsGrid/SpeedSnackButton
@onready var brain_food_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/TrainingFoodsSection/FoodsGrid/BrainFoodButton
@onready var focus_tea_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/TrainingFoodsSection/FoodsGrid/FocusTeaButton

# Activity Buttons
@onready var physical_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/ActivitySelection/ActivityButtons/PhysicalButton
@onready var agility_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/ActivitySelection/ActivityButtons/AgilityButton
@onready var mental_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/ActivitySelection/ActivityButtons/MentalButton
@onready var discipline_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/ActivitySelection/ActivityButtons/DisciplineButton
@onready var schedule_training_button = $VSplitContainer/TopSection/AssignmentPanel/AssignmentContent/ScheduleTrainingButton

# Facility UI References
@onready var physical_facility = {
	"tier": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/PhysicalFacility/PhysicalContent/PhysicalTier,
	"capacity": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/PhysicalFacility/PhysicalContent/PhysicalCapacity
}
@onready var agility_facility = {
	"tier": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/AgilityFacility/AgilityContent/AgilityTier,
	"capacity": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/AgilityFacility/AgilityContent/AgilityCapacity
}
@onready var mental_facility = {
	"tier": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/MentalFacility/MentalContent/MentalTier,
	"capacity": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/MentalFacility/MentalContent/MentalCapacity
}
@onready var discipline_facility = {
	"tier": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/DisciplineFacility/DisciplineContent/DisciplineTier,
	"capacity": $VSplitContainer/TopSection/FacilitiesPanel/FacilitiesContent/FacilitiesGrid/DisciplineFacility/DisciplineContent/DisciplineCapacity
}

# State tracking
var selected_creature_id: String = ""
var selected_activity: int = -1
var selected_facility_tier: int = 0  # Basic by default
var selected_food_type: int = -1  # Track selected food instead of consuming

# Activity names for display
const ACTIVITY_NAMES = ["Physical Training", "Agility Training", "Mental Training", "Discipline Training"]
const FACILITY_NAMES = ["Basic", "Advanced", "Elite"]
const FOOD_NAMES = ["Power Bar", "Speed Snack", "Brain Food", "Focus Tea"]

func _ready() -> void:
	print("TrainingPanelController initialized")
	_connect_ui_signals()

func set_game_controller(controller: GameController) -> void:
	"""Set the game controller reference and connect signals"""
	# Get SignalBus for connections (signals migrated from GameController)
	var signal_bus = GameCore.get_signal_bus()

	# Disconnect existing signals if connected
	if signal_bus:
		if signal_bus.training_data_updated.is_connected(_on_training_data_updated):
			signal_bus.training_data_updated.disconnect(_on_training_data_updated)
		if signal_bus.food_inventory_updated.is_connected(_on_food_inventory_updated):
			signal_bus.food_inventory_updated.disconnect(_on_food_inventory_updated)
		if signal_bus.creatures_updated.is_connected(_on_creatures_updated):
			signal_bus.creatures_updated.disconnect(_on_creatures_updated)

	game_controller = controller
	if game_controller and signal_bus:
		signal_bus.training_data_updated.connect(_on_training_data_updated)
		signal_bus.food_inventory_updated.connect(_on_food_inventory_updated)
		signal_bus.creatures_updated.connect(_on_creatures_updated)
	_refresh_display()

func _connect_ui_signals() -> void:
	"""Connect UI button signals"""
	# Training food buttons
	power_bar_button.pressed.connect(_on_training_food_selected.bind(0))  # POWER_BAR
	speed_snack_button.pressed.connect(_on_training_food_selected.bind(1))  # SPEED_SNACK
	brain_food_button.pressed.connect(_on_training_food_selected.bind(2))  # BRAIN_FOOD
	focus_tea_button.pressed.connect(_on_training_food_selected.bind(3))  # FOCUS_TEA

	# Activity selection buttons
	physical_button.pressed.connect(_on_activity_selected.bind(0))  # PHYSICAL
	agility_button.pressed.connect(_on_activity_selected.bind(1))   # AGILITY
	mental_button.pressed.connect(_on_activity_selected.bind(2))    # MENTAL
	discipline_button.pressed.connect(_on_activity_selected.bind(3)) # DISCIPLINE

	# Schedule training button
	schedule_training_button.pressed.connect(_on_schedule_training)

	# Creature selection
	creature_dropdown.item_selected.connect(_on_creature_selected)

# === UI UPDATE METHODS ===

func _refresh_display() -> void:
	"""Refresh all UI displays"""
	if not game_controller:
		return
	_update_facility_display()
	_update_creature_list()
	_update_schedule_display()
	_update_progress_display()
	_update_training_food_buttons()

func _update_facility_display() -> void:
	"""Update facility information display"""
	if not game_controller:
		return

	var training_data = game_controller.get_training_data()
	var utilization = training_data.get("facility_utilization", {})

	# Update facility displays (all use BASIC tier for now)
	var facilities = [
		{"ui": physical_facility, "tier": 0},  # BASIC
		{"ui": agility_facility, "tier": 0},  # BASIC
		{"ui": mental_facility, "tier": 0},   # BASIC
		{"ui": discipline_facility, "tier": 0} # BASIC
	]

	for facility in facilities:
		var tier_data = utilization.get(facility.tier, {})
		var tier_name = tier_data.get("tier_name", "Basic")
		var used = tier_data.get("used", 0)
		var available = tier_data.get("available", 10)

		facility.ui.tier.text = "Tier: %s" % tier_name
		facility.ui.capacity.text = "Capacity: %d/%d" % [used, available]

func _update_creature_list() -> void:
	"""Update the dropdown of available creatures"""
	creature_dropdown.clear()

	if not game_controller:
		return

	# Add default "Select Creature" option
	creature_dropdown.add_item("Select Creature...")
	creature_dropdown.set_item_metadata(0, "")

	# Get active creatures with full data
	var creatures_data = game_controller.get_active_creatures_data()

	for creature_data in creatures_data:
		creature_dropdown.add_item(creature_data.display_text)
		# Store creature ID as metadata for proper lookup
		creature_dropdown.set_item_metadata(creature_dropdown.get_item_count() - 1, creature_data.id)

func _update_schedule_display() -> void:
	"""Update the training schedule display"""
	schedule_list.clear()

	if not game_controller:
		return

	var training_data = game_controller.get_training_data()
	var training_assignments = training_data.get("training_assignments", {})

	# Add current training assignments
	for creature_id in training_assignments:
		var assignment = training_assignments[creature_id]
		var activity_name = ACTIVITY_NAMES[assignment.get("activity", 0)] if assignment.get("activity", 0) < ACTIVITY_NAMES.size() else "Unknown"
		var facility_name = FACILITY_NAMES[assignment.get("facility_tier", 0)] if assignment.get("facility_tier", 0) < FACILITY_NAMES.size() else "Basic"

		# Get creature name from collection
		var creature_name = "Unknown"
		var active_creatures = game_controller.get_active_creatures_data()
		for creature in active_creatures:
			if creature.get("id") == creature_id:
				creature_name = creature.get("creature_name", "Unknown")
				break

		var text = "ASSIGNED: %s - %s (%s)" % [creature_name, activity_name, facility_name]
		schedule_list.add_item(text)

func _update_progress_display() -> void:
	"""Update the training progress display"""
	progress_list.clear()

	if not game_controller:
		return

	var training_data = game_controller.get_training_data()
	var completed_trainings = training_data.get("completed_trainings", [])

	for entry in completed_trainings:
		var activity_name = ACTIVITY_NAMES[entry.get("activity", 0)] if entry.get("activity", 0) < ACTIVITY_NAMES.size() else "Unknown"
		var gains_text = ""
		if entry.has("stat_gains"):
			var gains = []
			for stat_name in entry.stat_gains:
				gains.append("%s +%d" % [stat_name.to_upper(), entry.stat_gains[stat_name]])
			gains_text = " (%s)" % ", ".join(gains)

		var text = "COMPLETED: %s - %s%s" % [entry.get("creature_name", "Unknown"), activity_name, gains_text]
		progress_list.add_item(text)

func _update_training_food_buttons() -> void:
	"""Update training food button states based on inventory"""
	if not game_controller:
		return

	var food_inventory = game_controller.get_food_inventory()

	var buttons = [
		{"button": power_bar_button, "item_id": "power_bar", "name": "Power Bar", "type": 0},
		{"button": speed_snack_button, "item_id": "speed_snack", "name": "Speed Snack", "type": 1},
		{"button": brain_food_button, "item_id": "brain_food", "name": "Brain Food", "type": 2},
		{"button": focus_tea_button, "item_id": "focus_tea", "name": "Focus Tea", "type": 3}
	]

	for button_data in buttons:
		var count = food_inventory.get(button_data.item_id, 0)
		var button = button_data.button

		# Show selection state and availability
		var selected_text = " [SELECTED]" if selected_food_type == button_data.type else ""
		button.text = "%s (%d available)%s" % [button_data.name, count, selected_text]
		button.disabled = count == 0

		# Update button appearance based on selection
		if selected_food_type == button_data.type:
			button.modulate = Color.GREEN
		else:
			button.modulate = Color.WHITE

func refresh_food_buttons() -> void:
	"""Public method to refresh just the food buttons"""
	_update_training_food_buttons()

# === EVENT HANDLERS ===

func _on_training_food_selected(food_type: int) -> void:
	"""Handle training food selection - just mark it, don't consume yet"""
	if not game_controller:
		print("Game controller not available")
		return

	# Toggle selection - if already selected, deselect
	if selected_food_type == food_type:
		selected_food_type = -1
		print("Deselected training food")
	else:
		selected_food_type = food_type
		var food_name = FOOD_NAMES[food_type] if food_type < FOOD_NAMES.size() else "Unknown Food"
		print("Selected training food: %s" % food_name)

	# Refresh food buttons to show selection state
	_update_training_food_buttons()

func _on_activity_selected(activity: int) -> void:
	"""Handle training activity selection"""
	selected_activity = activity
	_update_activity_button_states()

	var activity_name = ACTIVITY_NAMES[activity] if activity < ACTIVITY_NAMES.size() else "Unknown"
	print("Selected activity: %s" % activity_name)

func _update_activity_button_states() -> void:
	"""Update activity button visual states based on selection"""
	var buttons = [physical_button, agility_button, mental_button, discipline_button]
	for i in range(buttons.size()):
		if i == selected_activity:
			buttons[i].modulate = Color.GREEN
		else:
			buttons[i].modulate = Color.WHITE

func _on_creature_selected(index: int) -> void:
	"""Handle creature selection from dropdown"""
	if index >= 0 and index < creature_dropdown.get_item_count():
		# Get creature ID from metadata
		selected_creature_id = creature_dropdown.get_item_metadata(index)
		if selected_creature_id == "":
			# Default "Select Creature" option selected
			selected_creature_id = ""
			print("No creature selected")
		else:
			print("Selected creature: %s" % selected_creature_id)

func _on_schedule_training() -> void:
	"""Handle training scheduling"""
	if selected_creature_id.is_empty():
		print("No creature selected")
		return

	if selected_activity < 0:
		print("No training activity selected")
		return

	if not game_controller:
		print("Game controller not available")
		return

	# Schedule training using creature ID, including selected food type
	var result = game_controller.schedule_creature_training(selected_creature_id, selected_activity, selected_facility_tier, selected_food_type)
	if result.get("success", false):
		var food_text = ""
		if selected_food_type >= 0:
			var food_name = FOOD_NAMES[selected_food_type] if selected_food_type < FOOD_NAMES.size() else "Unknown Food"
			food_text = " with %s" % food_name
		print("Training scheduled successfully%s" % food_text)

		# Clear selections after successful scheduling
		selected_food_type = -1
		selected_activity = -1
		_update_training_food_buttons()
		_update_activity_button_states()
	else:
		print("Failed to schedule training: %s" % result.get("reason", "Unknown error"))

# === SIGNAL HANDLERS (from GameController) ===

func _on_training_data_updated() -> void:
	"""Handle training data updates from GameController"""
	_update_facility_display()
	_update_schedule_display()
	_update_progress_display()

func _on_food_inventory_updated() -> void:
	"""Handle food inventory updates from GameController"""
	_update_training_food_buttons()

func _on_creatures_updated() -> void:
	"""Handle creature updates from GameController"""
	_update_creature_list()

# === PUBLIC METHODS ===

func refresh() -> void:
	"""Public method to refresh the panel display"""
	_refresh_display()

func is_panel_active() -> bool:
	"""Check if the training panel is currently active"""
	return visible
