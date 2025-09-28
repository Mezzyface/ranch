@tool
extends Control
class_name QuestCard

# === PROPERTIES ===
@export var quest_data: QuestResource: set = set_quest_data
@export var is_active: bool = true: set = set_is_active

# === DEPENDENCIES ===
var _signal_bus: SignalBus
var _quest_system: Node

# === UI REFERENCES ===
@onready var quest_title: Label = $Background/VBoxContainer/HeaderContainer/QuestTitle
@onready var status_label: Label = $Background/VBoxContainer/HeaderContainer/StatusLabel
@onready var description_label: Label = $Background/VBoxContainer/DescriptionLabel
@onready var objectives_list: VBoxContainer = $Background/VBoxContainer/ObjectivesContainer/ObjectivesList
@onready var progress_bar: ProgressBar = $Background/VBoxContainer/ProgressBar
@onready var progress_label: Label = $Background/VBoxContainer/ProgressLabel
@onready var gold_reward: Label = $Background/VBoxContainer/RewardContainer/GoldReward
@onready var xp_reward: Label = $Background/VBoxContainer/RewardContainer/XPReward
@onready var track_button: Button = $Background/VBoxContainer/ButtonContainer/TrackButton
@onready var turn_in_button: Button = $Background/VBoxContainer/ButtonContainer/TurnInButton

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_signal_bus = GameCore.get_signal_bus()
	_quest_system = GameCore.get_system("quest")

	# Connect button signals
	if track_button:
		track_button.pressed.connect(_on_track_pressed)
	if turn_in_button:
		turn_in_button.pressed.connect(_on_turn_in_pressed)

	# Connect to quest progress updates
	if _signal_bus:
		_signal_bus.quest_progress_updated.connect(_on_quest_progress_updated)
		_signal_bus.quest_objective_completed.connect(_on_quest_objective_completed)
		_signal_bus.quest_completed.connect(_on_quest_completed)

	# Update display if quest_data is already set
	if quest_data:
		_update_quest_display()

func set_quest_data(value: QuestResource) -> void:
	quest_data = value
	if is_node_ready() and not Engine.is_editor_hint():
		_update_quest_display()

func set_is_active(value: bool) -> void:
	is_active = value
	if is_node_ready() and not Engine.is_editor_hint():
		_update_quest_display()

func _update_quest_display() -> void:
	"""Update all UI elements to reflect current quest data."""
	if not quest_data or Engine.is_editor_hint():
		return

	# Update basic info
	if quest_title:
		quest_title.text = quest_data.title

	if description_label:
		description_label.text = quest_data.description

	# Update status
	if status_label:
		if is_active:
			status_label.text = "Active"
			status_label.modulate = Color(0.5, 1, 0.5, 1)  # Green
		else:
			status_label.text = "Completed"
			status_label.modulate = Color(0.5, 0.5, 1, 1)  # Blue

	# Update rewards display
	if quest_data.rewards.has("gold") and gold_reward:
		gold_reward.text = "%d g" % quest_data.rewards["gold"]

	if quest_data.rewards.has("xp") and xp_reward:
		xp_reward.text = "%d XP" % quest_data.rewards["xp"]

	# Update button states
	_update_button_states()

	# Update progress
	update_progress()

func update_progress() -> void:
	"""Update progress indicators for the quest."""
	if not quest_data or not _quest_system or Engine.is_editor_hint():
		return

	# Clear existing objectives display
	if objectives_list:
		for child in objectives_list.get_children():
			child.queue_free()

	if is_active:
		# Get current progress from quest system
		var progress: Dictionary = _quest_system.get_quest_progress(quest_data.quest_id)

		if progress.is_empty():
			return

		# Update progress bar and label
		var total_objectives: int = progress.get("total_objectives", 0)
		var completed_objectives: int = progress.get("completed_objectives", 0)

		if progress_bar and total_objectives > 0:
			progress_bar.value = (float(completed_objectives) / float(total_objectives)) * 100.0

		if progress_label:
			progress_label.text = "Progress: %d/%d objectives completed" % [completed_objectives, total_objectives]

		# Display objectives
		var objectives: Array = progress.get("objectives", [])
		for obj_data in objectives:
			_create_objective_display(obj_data)
	else:
		# Quest completed - show all objectives as done
		if progress_bar:
			progress_bar.value = 100.0
		if progress_label:
			progress_label.text = "Quest completed!"

func _create_objective_display(objective_data: Dictionary) -> void:
	"""Create a UI element for displaying an objective."""
	if not objectives_list:
		return

	var objective_container: HBoxContainer = HBoxContainer.new()
	objectives_list.add_child(objective_container)

	# Status indicator
	var status_icon: Label = Label.new()
	status_icon.custom_minimum_size = Vector2(20, 20)
	objective_container.add_child(status_icon)

	if objective_data.get("completed", false):
		status_icon.text = "✓"
		status_icon.modulate = Color(0.5, 1, 0.5, 1)  # Green
	else:
		status_icon.text = "○"
		status_icon.modulate = Color(1, 1, 1, 0.7)  # Gray

	# Objective description
	var description: Label = Label.new()
	description.text = objective_data.get("description", "Unknown objective")
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_container.add_child(description)

func _update_button_states() -> void:
	"""Update button visibility and enabled states based on quest status."""
	if not track_button or not turn_in_button:
		return

	if is_active:
		track_button.visible = true
		turn_in_button.visible = true

		# Check if quest can be turned in
		if _quest_system:
			var progress: Dictionary = _quest_system.get_quest_progress(quest_data.quest_id)
			var total_objectives: int = progress.get("total_objectives", 0)
			var completed_objectives: int = progress.get("completed_objectives", 0)

			turn_in_button.disabled = (completed_objectives < total_objectives)
		else:
			turn_in_button.disabled = true
	else:
		# Quest is completed
		track_button.visible = false
		turn_in_button.visible = false

func _on_track_pressed() -> void:
	"""Handle track quest button press."""
	if not quest_data:
		return

	print("QuestCard: Tracking quest '%s'" % quest_data.quest_id)
	# TODO: Implement quest tracking UI integration
	# For now, just provide user feedback
	track_button.text = "Tracked"
	track_button.disabled = true

	# Re-enable after a short delay
	await get_tree().create_timer(1.0).timeout
	track_button.text = "Track Quest"
	track_button.disabled = false

func _on_turn_in_pressed() -> void:
	"""Handle turn in quest button press."""
	if not quest_data or not _quest_system:
		return

	print("QuestCard: Attempting to turn in quest '%s'" % quest_data.quest_id)

	# Get required creatures for turn-in (simplified implementation)
	var collection_system: Node = GameCore.get_system("collection")
	if not collection_system:
		push_error("QuestCard: CollectionSystem not available for quest turn-in")
		return

	# For now, just complete the quest directly
	# In a full implementation, this would open a creature selection dialog
	var active_creatures: Array[CreatureData] = collection_system.get_active_roster()

	# Find the first incomplete objective and attempt completion
	var progress: Dictionary = _quest_system.get_quest_progress(quest_data.quest_id)
	var objectives: Array = progress.get("objectives", [])

	for i in range(objectives.size()):
		var obj_data: Dictionary = objectives[i]
		if not obj_data.get("completed", false):
			# Try to complete this objective with first available creature
			if active_creatures.size() > 0:
				_quest_system.complete_objective(quest_data.quest_id, i, [active_creatures[0]])
				break

func _on_quest_progress_updated(quest_id: String, progress: Dictionary) -> void:
	"""Handle quest progress updates from the signal bus."""
	if quest_data and quest_data.quest_id == quest_id:
		update_progress()

func _on_quest_objective_completed(quest_id: String, objective_index: int) -> void:
	"""Handle quest objective completion from the signal bus."""
	if quest_data and quest_data.quest_id == quest_id:
		update_progress()

func _on_quest_completed(quest_id: String) -> void:
	"""Handle quest completion from the signal bus."""
	if quest_data and quest_data.quest_id == quest_id:
		is_active = false
		_update_quest_display()