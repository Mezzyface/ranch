extends Window
class_name QuestTurnInDialogController

# === QUEST TURN-IN DIALOG CONTROLLER ===
# Handles quest completion UI with creature selection and validation

# === DEPENDENCIES ===
var _signal_bus: SignalBus
var _collection_system: Node
var _quest_system: Node

# === UI REFERENCES ===
@onready var quest_title: Label = $MarginContainer/VBoxContainer/QuestInfoSection/QuestTitle
@onready var quest_description: RichTextLabel = $MarginContainer/VBoxContainer/QuestInfoSection/QuestDescription
@onready var objectives_list: VBoxContainer = $MarginContainer/VBoxContainer/RequirementsSection/ObjectivesList
@onready var available_list: VBoxContainer = $MarginContainer/VBoxContainer/CreatureSelectionSection/SelectionContainer/AvailableCreatures/AvailableScrollContainer/AvailableList
@onready var selected_list: VBoxContainer = $MarginContainer/VBoxContainer/CreatureSelectionSection/SelectionContainer/SelectedCreatures/SelectedScrollContainer/SelectedList
@onready var add_button: Button = $MarginContainer/VBoxContainer/CreatureSelectionSection/SelectionContainer/ArrowContainer/AddButton
@onready var remove_button: Button = $MarginContainer/VBoxContainer/CreatureSelectionSection/SelectionContainer/ArrowContainer/RemoveButton
@onready var status_label: RichTextLabel = $MarginContainer/VBoxContainer/StatusSection/StatusLabel
@onready var complete_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/CompleteButton

# === STATE ===
var current_quest_id: String = ""
var current_objectives: Array[QuestObjective] = []
var available_creatures: Array[CreatureData] = []
var selected_creatures: Array[CreatureData] = []
var selected_available_index: int = -1
var selected_chosen_index: int = -1

# === INITIALIZATION ===

func _ready() -> void:
	_signal_bus = GameCore.get_signal_bus()
	_collection_system = GameCore.get_system("collection")
	_quest_system = GameCore.get_system("quest")

	# Connect window close signal
	close_requested.connect(_on_cancel_button_pressed)

## Show dialog for a specific quest
func show_quest(quest_id: String) -> void:
	if quest_id.is_empty():
		push_error("QuestTurnInDialogController.show_quest: quest_id cannot be empty")
		return

	if not _quest_system.is_quest_active(quest_id):
		push_error("QuestTurnInDialogController.show_quest: Quest '%s' is not active" % quest_id)
		return

	current_quest_id = quest_id
	_load_quest_data()
	_populate_available_creatures()
	_update_ui()
	popup_centered()

# === QUEST LOADING ===

func _load_quest_data() -> void:
	"""Load quest information and objectives."""
	var quest_data: Dictionary = _quest_system.get_active_quest_data(current_quest_id)

	# Update quest info
	quest_title.text = quest_data.get("title", "Unknown Quest")
	quest_description.text = quest_data.get("description", "No description available.")

	# Load objectives (simplified - assuming first incomplete objective)
	var objectives_data: Array = quest_data.get("objectives", [])
	current_objectives.clear()

	for obj_data in objectives_data:
		if obj_data.get("completed", false):
			continue  # Skip completed objectives

		# Create QuestObjective from the data
		var objective: QuestObjective = QuestObjective.new()
		objective.description = obj_data.get("description", "")
		objective.required_tags = Array(obj_data.get("tags", []), TYPE_STRING, "", null)
		objective.required_stats = obj_data.get("stats", {})
		objective.quantity = obj_data.get("count", 1)
		# Assume PROVIDE_CREATURE type for simplicity
		objective.type = QuestObjective.ObjectiveType.PROVIDE_CREATURE if objective.quantity == 1 else QuestObjective.ObjectiveType.PROVIDE_MULTIPLE

		current_objectives.append(objective)

	_display_objectives()

func _display_objectives() -> void:
	"""Display quest objectives in the UI."""
	# Clear existing objective displays
	for child in objectives_list.get_children():
		child.queue_free()

	for i in range(current_objectives.size()):
		var objective: QuestObjective = current_objectives[i]
		var obj_container: VBoxContainer = VBoxContainer.new()
		obj_container.set("theme_override_constants/separation", 3)  # Will use theme if available

		# Objective description
		var desc_label: Label = Label.new()
		desc_label.text = "• " + objective.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		obj_container.add_child(desc_label)

		# Required tags
		if not objective.required_tags.is_empty():
			var tags_label: Label = Label.new()
			tags_label.text = "  Tags: " + ", ".join(objective.required_tags)
			tags_label.modulate = Color(0.8, 0.8, 1.0)
			# Using default theme font size
			obj_container.add_child(tags_label)

		# Required stats
		if not objective.required_stats.is_empty():
			var stats_label: Label = Label.new()
			var stat_strings: Array[String] = []
			for stat_name in objective.required_stats.keys():
				stat_strings.append("%s ≥ %d" % [stat_name.capitalize(), objective.required_stats[stat_name]])
			stats_label.text = "  Stats: " + ", ".join(stat_strings)
			stats_label.modulate = Color(1.0, 0.8, 0.8)
			# Using default theme font size
			obj_container.add_child(stats_label)

		# Quantity
		if objective.quantity > 1:
			var quantity_label: Label = Label.new()
			quantity_label.text = "  Required: %d creatures" % objective.quantity
			quantity_label.modulate = Color(0.8, 1.0, 0.8)
			# Using default theme font size
			obj_container.add_child(quantity_label)

		objectives_list.add_child(obj_container)

# === CREATURE MANAGEMENT ===

func _populate_available_creatures() -> void:
	"""Find all eligible creatures from player collection."""
	available_creatures.clear()
	selected_creatures.clear()

	if current_objectives.is_empty():
		return

	# For now, use the first objective to filter creatures
	# TODO: Handle multiple objectives properly
	var primary_objective: QuestObjective = current_objectives[0]

	var all_creatures: Array[CreatureData] = _collection_system.get_all_creatures()
	available_creatures = QuestMatcher.find_matching_creatures(primary_objective, all_creatures)

	# Sort by match quality (best matches first)
	available_creatures = QuestMatcher.sort_by_match_quality(available_creatures, primary_objective)

func _update_creature_lists() -> void:
	"""Update the creature list displays."""
	# Clear existing lists
	for child in available_list.get_children():
		child.queue_free()
	for child in selected_list.get_children():
		child.queue_free()

	# Populate available creatures
	for i in range(available_creatures.size()):
		var creature: CreatureData = available_creatures[i]
		var item: Control = _create_creature_list_item(creature, true, i)
		available_list.add_child(item)

	# Populate selected creatures
	for i in range(selected_creatures.size()):
		var creature: CreatureData = selected_creatures[i]
		var item: Control = _create_creature_list_item(creature, false, i)
		selected_list.add_child(item)

func _create_creature_list_item(creature: CreatureData, is_available: bool, index: int) -> Control:
	"""Create a list item for a creature."""
	var container: PanelContainer = PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 50)

	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(0, 46)
	button.text = creature.creature_name
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Add creature stats as tooltip or subtitle
	var stat_info: String = "STR:%d CON:%d DEX:%d INT:%d WIS:%d DIS:%d" % [
		creature.strength, creature.constitution, creature.dexterity,
		creature.intelligence, creature.wisdom, creature.discipline
	]
	button.tooltip_text = stat_info

	# Color coding based on eligibility
	if is_available:
		button.modulate = Color.WHITE
		button.pressed.connect(_on_available_creature_selected.bind(index))
	else:
		button.modulate = Color(0.9, 0.9, 1.0)
		button.pressed.connect(_on_selected_creature_selected.bind(index))

	container.add_child(button)
	return container

# === UI EVENT HANDLERS ===

func _on_available_creature_selected(index: int) -> void:
	selected_available_index = index
	selected_chosen_index = -1
	_update_button_states()

func _on_selected_creature_selected(index: int) -> void:
	selected_chosen_index = index
	selected_available_index = -1
	_update_button_states()

func _on_add_button_pressed() -> void:
	if selected_available_index >= 0 and selected_available_index < available_creatures.size():
		var creature: CreatureData = available_creatures[selected_available_index]

		# Move creature from available to selected
		available_creatures.remove_at(selected_available_index)
		selected_creatures.append(creature)

		selected_available_index = -1
		_update_creature_lists()
		_update_button_states()
		_update_status()

func _on_remove_button_pressed() -> void:
	if selected_chosen_index >= 0 and selected_chosen_index < selected_creatures.size():
		var creature: CreatureData = selected_creatures[selected_chosen_index]

		# Move creature from selected back to available
		selected_creatures.remove_at(selected_chosen_index)
		available_creatures.append(creature)

		# Re-sort available list
		if not current_objectives.is_empty():
			available_creatures = QuestMatcher.sort_by_match_quality(available_creatures, current_objectives[0])

		selected_chosen_index = -1
		_update_creature_lists()
		_update_button_states()
		_update_status()

func _on_cancel_button_pressed() -> void:
	hide()

func _on_complete_button_pressed() -> void:
	if _can_complete_quest():
		_complete_quest()
		hide()

# === UI STATE MANAGEMENT ===

func _update_button_states() -> void:
	"""Update button enabled states based on selections."""
	add_button.disabled = selected_available_index < 0
	remove_button.disabled = selected_chosen_index < 0

func _update_status() -> void:
	"""Update status message and completion button."""
	if current_objectives.is_empty():
		status_label.text = "[color=red]No objectives available[/color]"
		complete_button.disabled = true
		return

	var can_complete: bool = _can_complete_quest()
	var primary_objective: QuestObjective = current_objectives[0]

	if can_complete:
		status_label.text = "[color=green]Ready to complete quest![/color]"
		complete_button.disabled = false
	else:
		var needed: int = primary_objective.quantity
		var current: int = selected_creatures.size()
		status_label.text = "[color=yellow]Selected %d/%d creatures required[/color]" % [current, needed]
		complete_button.disabled = true

func _can_complete_quest() -> bool:
	"""Check if quest can be completed with selected creatures."""
	if current_objectives.is_empty():
		return false

	# For now, check only the first objective
	var primary_objective: QuestObjective = current_objectives[0]
	return selected_creatures.size() >= primary_objective.quantity

func _complete_quest() -> void:
	"""Complete the quest with selected creatures."""
	if not _can_complete_quest():
		push_error("QuestTurnInDialogController: Cannot complete quest - requirements not met")
		return

	# Complete the first objective (simplified)
	var success: bool = _quest_system.complete_objective(current_quest_id, 0, selected_creatures)

	if success:
		_signal_bus.emit_notification_requested("Quest completed successfully!", "success")
	else:
		_signal_bus.emit_notification_requested("Failed to complete quest.", "error")

func _update_ui() -> void:
	"""Update the entire UI display."""
	_update_creature_lists()
	_update_button_states()
	_update_status()