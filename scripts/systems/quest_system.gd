extends Node
class_name QuestSystem

# === CONSTANTS ===
const QUEST_DATA_PATH: String = "res://data/quests/"
const QUEST_FILE_EXTENSION: String = ".tres"

# === QUEST DATA ===
var active_quests: Dictionary = {}  # quest_id -> Dictionary (quest data)
var completed_quests: Array[String] = []
var quest_resources: Dictionary = {}  # quest_id -> Dictionary (quest resource data)

# === DEPENDENCIES ===
var _signal_bus: SignalBus
var _collection_system: Node

func _init() -> void:
	print("QuestSystem initialized")

func _ready() -> void:
	_signal_bus = GameCore.get_signal_bus()
	_load_all_quests()

	# Connect to collection system for quest validation
	_collection_system = GameCore.get_system("collection")

func _load_all_quests() -> void:
	"""Load all quest resources from the quest data directory."""
	var dir: DirAccess = DirAccess.open(QUEST_DATA_PATH)
	if not dir:
		print("QuestSystem: Quest data directory not found: %s" % QUEST_DATA_PATH)
		_create_default_quests()
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	var loaded_count: int = 0

	while file_name != "":
		if file_name.ends_with(QUEST_FILE_EXTENSION):
			var quest_path: String = QUEST_DATA_PATH + file_name
			if _load_quest_from_file(quest_path):
				loaded_count += 1
		file_name = dir.get_next()

	print("QuestSystem: Loaded %d quests" % loaded_count)

func _load_quest_from_file(file_path: String) -> bool:
	"""Load a single quest from file."""
	# For now, create a simple quest structure until proper resource files exist
	var quest_id: String = file_path.get_file().get_basename()
	var quest_data: Dictionary = {
		"quest_id": quest_id,
		"title": "Sample Quest",
		"description": "A sample quest for testing",
		"objectives": [
			{
				"description": "Collect 1 creature",
				"type": "collect",
				"count": 1,
				"species": "",
				"tags": []
			}
		],
		"rewards": {
			"gold": 100,
			"items": []
		},
		"required_completed_quests": [],
		"required_collection_size": 0,
		"required_creatures": []
	}

	quest_resources[quest_id] = quest_data
	return true

func _create_default_quests() -> void:
	"""Create default quest data directory and sample quest if it doesn't exist."""
	print("QuestSystem: Creating default quest data directory")
	var dir: DirAccess = DirAccess.open("res://data/")
	if dir:
		dir.make_dir("quests")
		print("QuestSystem: Created data/quests/ directory")

func start_quest(quest_id: String) -> bool:
	"""Start a quest if prerequisites are met."""
	if quest_id.is_empty():
		push_error("QuestSystem.start_quest: quest_id cannot be empty")
		return false

	if not quest_resources.has(quest_id):
		push_error("QuestSystem.start_quest: Unknown quest '%s'" % quest_id)
		return false

	if is_quest_active(quest_id):
		push_error("QuestSystem.start_quest: Quest '%s' is already active" % quest_id)
		return false

	if is_quest_completed(quest_id):
		push_error("QuestSystem.start_quest: Quest '%s' is already completed" % quest_id)
		return false

	if not check_prerequisites(quest_id):
		push_error("QuestSystem.start_quest: Prerequisites not met for quest '%s'" % quest_id)
		return false

	var quest_resource: Dictionary = quest_resources[quest_id]
	var quest_data: Dictionary = {
		"quest_id": quest_id,
		"title": quest_resource.get("title", ""),
		"description": quest_resource.get("description", ""),
		"objectives": quest_resource.get("objectives", []).duplicate(true),
		"rewards": quest_resource.get("rewards", {}).duplicate(true),
		"started_at": Time.get_ticks_msec(),
		"completed_at": 0
	}

	active_quests[quest_id] = quest_data
	_signal_bus.emit_quest_started(quest_id)

	return true

func complete_objective(quest_id: String, objective_index: int, creatures: Array[CreatureData]) -> bool:
	"""Complete an objective for an active quest."""
	if quest_id.is_empty():
		push_error("QuestSystem.complete_objective: quest_id cannot be empty")
		return false

	if not is_quest_active(quest_id):
		push_error("QuestSystem.complete_objective: Quest '%s' is not active" % quest_id)
		return false

	var quest: Dictionary = active_quests[quest_id]
	var objectives: Array = quest.get("objectives", [])

	if objective_index < 0 or objective_index >= objectives.size():
		push_error("QuestSystem.complete_objective: Invalid objective index %d for quest '%s'" % [objective_index, quest_id])
		return false

	var objective: Dictionary = objectives[objective_index]
	if objective.get("completed", false):
		push_error("QuestSystem.complete_objective: Objective %d already completed for quest '%s'" % [objective_index, quest_id])
		return false

	# Validate creatures meet objective requirements
	if not _validate_objective_completion(objective, creatures):
		push_error("QuestSystem.complete_objective: Creatures do not meet objective requirements")
		return false

	# Mark objective as completed
	objective["completed"] = true
	objective["completed_at"] = Time.get_ticks_msec()
	objective["creatures_used"] = []
	for creature in creatures:
		if creature != null:
			objective["creatures_used"].append(creature.id)

	_signal_bus.emit_quest_objective_completed(quest_id, objective_index)

	# Check if quest is fully completed
	if _check_quest_completion(quest_id):
		_complete_quest(quest_id)

	return true

func check_prerequisites(quest_id: String) -> bool:
	"""Check if a quest's prerequisites are met."""
	if not quest_resources.has(quest_id):
		return false

	var quest_resource: Dictionary = quest_resources[quest_id]

	# Check completed quest prerequisites
	var required_quests: Array = quest_resource.get("required_completed_quests", [])
	for required_quest in required_quests:
		if not is_quest_completed(required_quest):
			return false

	# Check collection size requirements
	var required_size: int = quest_resource.get("required_collection_size", 0)
	if required_size > 0:
		var collection_size: int = _collection_system.get_total_collection_size()
		if collection_size < required_size:
			return false

	return true

func get_available_quests() -> Array[String]:
	"""Get all quests that can be started (prerequisites met, not active/completed)."""
	var available: Array[String] = []

	for quest_id in quest_resources.keys():
		if not is_quest_active(quest_id) and not is_quest_completed(quest_id):
			if check_prerequisites(quest_id):
				available.append(quest_id)

	return available

func is_quest_active(quest_id: String) -> bool:
	"""Check if a quest is currently active."""
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	"""Check if a quest has been completed."""
	return quest_id in completed_quests

func get_active_quest_data(quest_id: String) -> Dictionary:
	"""Get the data for an active quest."""
	return active_quests.get(quest_id, {})

func get_quest_resource(quest_id: String) -> Dictionary:
	"""Get the resource data for a quest."""
	return quest_resources.get(quest_id, {})

func get_quest_progress(quest_id: String) -> Dictionary:
	"""Get progress information for an active quest."""
	if not is_quest_active(quest_id):
		return {}

	var quest: Dictionary = active_quests[quest_id]
	var objectives: Array = quest.get("objectives", [])
	var progress: Dictionary = {
		"quest_id": quest_id,
		"total_objectives": objectives.size(),
		"completed_objectives": 0,
		"objectives": []
	}

	for i in range(objectives.size()):
		var objective: Dictionary = objectives[i]
		var obj_progress: Dictionary = {
			"index": i,
			"description": objective.get("description", ""),
			"completed": objective.get("completed", false),
			"completed_at": objective.get("completed_at", 0)
		}
		progress.objectives.append(obj_progress)

		if objective.get("completed", false):
			progress.completed_objectives += 1

	return progress

func _validate_objective_completion(objective: Dictionary, creatures: Array[CreatureData]) -> bool:
	"""Validate that provided creatures meet the objective requirements."""
	var required_type: String = objective.get("type", "")
	var required_count: int = objective.get("count", 1)
	var required_tags: Array = objective.get("tags", [])
	var required_species: String = objective.get("species", "")

	if creatures.size() < required_count:
		return false

	# Validate each creature meets requirements
	var valid_creatures: int = 0
	for creature in creatures:
		if creature == null:
			continue

		# Check species requirement
		if not required_species.is_empty() and creature.species_id != required_species:
			continue

		# Check tag requirements
		var meets_tags: bool = true
		for tag in required_tags:
			if not creature.tags.has(tag):
				meets_tags = false
				break

		if not meets_tags:
			continue

		valid_creatures += 1

	return valid_creatures >= required_count

func _check_quest_completion(quest_id: String) -> bool:
	"""Check if all objectives for a quest are completed."""
	if not is_quest_active(quest_id):
		return false

	var quest: Dictionary = active_quests[quest_id]
	var objectives: Array = quest.get("objectives", [])

	for objective in objectives:
		if not objective.get("completed", false):
			return false

	return true

func _complete_quest(quest_id: String) -> void:
	"""Mark a quest as completed and handle rewards."""
	if not is_quest_active(quest_id):
		return

	var quest: Dictionary = active_quests[quest_id]
	quest["completed_at"] = Time.get_ticks_msec()

	# Move from active to completed
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)

	# Grant rewards
	var rewards: Dictionary = quest.get("rewards", {})
	_grant_quest_rewards(quest_id, rewards)

	_signal_bus.emit_quest_completed(quest_id)

func _grant_quest_rewards(quest_id: String, rewards: Dictionary) -> void:
	"""Grant rewards for completing a quest."""
	# TODO: Integrate with resource system when available
	# For now, just log the rewards
	print("QuestSystem: Granting rewards for quest '%s': %s" % [quest_id, str(rewards)])
