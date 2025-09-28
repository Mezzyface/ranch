@tool
extends Control
class_name QuestLogController

# === DEPENDENCIES ===
var _signal_bus: SignalBus
var _quest_system: Node

# === UI REFERENCES ===
@onready var refresh_button: Button = $Background/VBoxContainer/HeaderContainer/RefreshButton
@onready var tab_container: TabContainer = $Background/VBoxContainer/MainContainer/LeftPanel/TabContainer
@onready var active_quest_list: VBoxContainer = $Background/VBoxContainer/MainContainer/LeftPanel/TabContainer/Active/ActiveQuestScroll/ActiveQuestList
@onready var completed_quest_list: VBoxContainer = $Background/VBoxContainer/MainContainer/LeftPanel/TabContainer/Completed/CompletedQuestScroll/CompletedQuestList
@onready var available_quest_list: VBoxContainer = $Background/VBoxContainer/MainContainer/LeftPanel/TabContainer/Available/AvailableQuestScroll/AvailableQuestList
@onready var details_container: VBoxContainer = $Background/VBoxContainer/MainContainer/RightPanel/DetailsScroll/DetailsContainer
@onready var no_quest_label: Label = $Background/VBoxContainer/MainContainer/RightPanel/DetailsScroll/DetailsContainer/NoQuestLabel
@onready var selected_quest_card: Control = $Background/VBoxContainer/MainContainer/RightPanel/DetailsScroll/DetailsContainer/SelectedQuestCard
@onready var start_quest_button: Button = $Background/VBoxContainer/MainContainer/RightPanel/ActionContainer/StartQuestButton
@onready var abandon_quest_button: Button = $Background/VBoxContainer/MainContainer/RightPanel/ActionContainer/AbandonQuestButton

# === STATE ===
var selected_quest_id: String = ""
var quest_card_scene: PackedScene

# === QUEST CARDS ===
var quest_cards: Dictionary = {}  # quest_id -> QuestCard
var quest_list_items: Dictionary = {}  # quest_id -> Control (list item buttons)

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# Load quest card scene
	quest_card_scene = preload("res://scenes/ui/components/quest_card.tscn")

	# Initialize systems
	_signal_bus = GameCore.get_signal_bus()
	_quest_system = GameCore.get_system("quest")

	if not _quest_system:
		push_error("QuestLogController: QuestSystem not available")
		return

	# Connect UI signals
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)

	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)

	if start_quest_button:
		start_quest_button.pressed.connect(_on_start_quest_pressed)

	if abandon_quest_button:
		abandon_quest_button.pressed.connect(_on_abandon_quest_pressed)

	# Connect quest system signals
	if _signal_bus:
		_signal_bus.quest_started.connect(_on_quest_started)
		_signal_bus.quest_completed.connect(_on_quest_completed)
		_signal_bus.quest_progress_updated.connect(_on_quest_progress_updated)

	# Initial load
	_load_quests()

func _load_quests() -> void:
	"""Load and display all quests from the quest system."""
	if not _quest_system:
		return

	_clear_quest_lists()

	# Load active quests
	for quest_id in _quest_system.active_quests.keys():
		var quest_data: Dictionary = _quest_system.get_active_quest_data(quest_id)
		_add_quest_to_list(quest_id, quest_data, "active")

	# Load completed quests
	for quest_id in _quest_system.completed_quests:
		var quest_resource: Dictionary = _quest_system.get_quest_resource(quest_id)
		_add_quest_to_list(quest_id, quest_resource, "completed")

	# Load available quests
	var available_quests: Array[String] = _quest_system.get_available_quests()
	for quest_id in available_quests:
		var quest_resource: Dictionary = _quest_system.get_quest_resource(quest_id)
		_add_quest_to_list(quest_id, quest_resource, "available")

	_update_details_panel()

func _clear_quest_lists() -> void:
	"""Clear all quest list containers."""
	_clear_container(active_quest_list)
	_clear_container(completed_quest_list)
	_clear_container(available_quest_list)

	quest_cards.clear()
	quest_list_items.clear()

func _clear_container(container: Node) -> void:
	"""Clear all children from a container."""
	if not container:
		return

	for child in container.get_children():
		child.queue_free()

func _add_quest_to_list(quest_id: String, quest_data: Dictionary, list_type: String) -> void:
	"""Add a quest to the appropriate list."""
	var target_container: VBoxContainer

	match list_type:
		"active":
			target_container = active_quest_list
		"completed":
			target_container = completed_quest_list
		"available":
			target_container = available_quest_list
		_:
			push_error("QuestLogController: Invalid list type '%s'" % list_type)
			return

	if not target_container:
		return

	# Create list item button
	var list_item: Button = Button.new()
	list_item.text = quest_data.get("title", "Unknown Quest")
	list_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_item.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Style based on type
	match list_type:
		"active":
			list_item.modulate = Color(1, 1, 1, 1)  # Normal
		"completed":
			list_item.modulate = Color(0.7, 0.7, 0.7, 1)  # Dimmed
		"available":
			list_item.modulate = Color(0.8, 1, 0.8, 1)  # Light green

	# Connect selection signal
	list_item.pressed.connect(func(): _on_quest_selected(quest_id))

	target_container.add_child(list_item)
	quest_list_items[quest_id] = list_item

	# Create quest card for details
	if quest_card_scene:
		var quest_card: QuestCard = quest_card_scene.instantiate()
		# Convert Dictionary to QuestResource (simplified)
		var quest_resource: QuestResource = _dict_to_quest_resource(quest_data)
		quest_card.quest_data = quest_resource
		quest_card.is_active = (list_type == "active")
		quest_cards[quest_id] = quest_card

func _dict_to_quest_resource(quest_data: Dictionary) -> QuestResource:
	"""Convert quest dictionary to QuestResource."""
	var resource: QuestResource = QuestResource.new()
	resource.quest_id = quest_data.get("quest_id", "")
	resource.title = quest_data.get("title", "")
	resource.description = quest_data.get("description", "")
	resource.rewards = quest_data.get("rewards", {})
	return resource

func _on_quest_selected(quest_id: String) -> void:
	"""Handle quest selection from list."""
	selected_quest_id = quest_id
	_update_details_panel()

func _update_details_panel() -> void:
	"""Update the quest details panel based on current selection."""
	if selected_quest_id.is_empty() or not quest_cards.has(selected_quest_id):
		# Show no selection state
		if no_quest_label:
			no_quest_label.visible = true
		if selected_quest_card:
			selected_quest_card.visible = false
		_update_action_buttons("")
		return

	# Show selected quest
	if no_quest_label:
		no_quest_label.visible = false

	if selected_quest_card:
		# Clear previous quest card
		for child in selected_quest_card.get_children():
			child.queue_free()

		# Add selected quest card
		var quest_card: QuestCard = quest_cards[selected_quest_id]
		if quest_card:
			# Remove from previous parent if any
			if quest_card.get_parent():
				quest_card.get_parent().remove_child(quest_card)

			selected_quest_card.add_child(quest_card)
			selected_quest_card.visible = true

	_update_action_buttons(selected_quest_id)

func _update_action_buttons(quest_id: String) -> void:
	"""Update action button visibility based on quest status."""
	if not start_quest_button or not abandon_quest_button:
		return

	if quest_id.is_empty():
		start_quest_button.visible = false
		abandon_quest_button.visible = false
		return

	var is_available: bool = quest_id in _quest_system.get_available_quests()
	var is_active: bool = _quest_system.is_quest_active(quest_id)

	start_quest_button.visible = is_available
	abandon_quest_button.visible = is_active

func _on_refresh_pressed() -> void:
	"""Handle refresh button press."""
	_load_quests()

func _on_tab_changed(tab: int) -> void:
	"""Handle tab change in the quest log."""
	# Clear selection when switching tabs
	selected_quest_id = ""
	_update_details_panel()

func _on_start_quest_pressed() -> void:
	"""Handle start quest button press."""
	if selected_quest_id.is_empty() or not _quest_system:
		return

	if _quest_system.start_quest(selected_quest_id):
		print("QuestLogController: Started quest '%s'" % selected_quest_id)
		_load_quests()  # Refresh display
	else:
		print("QuestLogController: Failed to start quest '%s'" % selected_quest_id)

func _on_abandon_quest_pressed() -> void:
	"""Handle abandon quest button press."""
	if selected_quest_id.is_empty() or not _quest_system:
		return

	# TODO: Implement quest abandonment in QuestSystem
	print("QuestLogController: Quest abandonment not yet implemented")

func _on_quest_started(quest_id: String) -> void:
	"""Handle quest started signal."""
	_load_quests()

func _on_quest_completed(quest_id: String) -> void:
	"""Handle quest completed signal."""
	_load_quests()

func _on_quest_progress_updated(quest_id: String, progress: Dictionary) -> void:
	"""Handle quest progress update signal."""
	# Update the specific quest card if it's currently displayed
	if quest_id == selected_quest_id and quest_cards.has(quest_id):
		var quest_card: QuestCard = quest_cards[quest_id]
		if quest_card:
			quest_card.update_progress()

# === INTEGRATION METHODS ===

func show_quest_log() -> void:
	"""Show the quest log interface."""
	visible = true
	_load_quests()

func hide_quest_log() -> void:
	"""Hide the quest log interface."""
	visible = false

func select_quest(quest_id: String) -> void:
	"""Programmatically select a quest for display."""
	selected_quest_id = quest_id
	_update_details_panel()

	# Switch to appropriate tab
	if _quest_system.is_quest_active(quest_id):
		tab_container.current_tab = 0  # Active tab
	elif _quest_system.is_quest_completed(quest_id):
		tab_container.current_tab = 1  # Completed tab
	else:
		tab_container.current_tab = 2  # Available tab