@tool
extends Resource
class_name QuestResource

@export var quest_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var prerequisites: Array[String] = []
@export var dialogue_snippet: String = ""
@export var rewards: Dictionary = {
	"gold": 0,
	"xp": 0,
	"items": [],
	"unlocks": []
}

func is_valid() -> bool:
	if quest_id.is_empty():
		push_error("QuestResource: quest_id cannot be empty")
		return false

	if title.is_empty():
		push_error("QuestResource: title cannot be empty")
		return false

	if description.is_empty():
		push_error("QuestResource: description cannot be empty")
		return false

	if not rewards.has("gold") or not rewards.has("xp") or not rewards.has("items") or not rewards.has("unlocks"):
		push_error("QuestResource: rewards must contain gold, xp, items, and unlocks keys")
		return false

	if not rewards["gold"] is int or rewards["gold"] < 0:
		push_error("QuestResource: rewards.gold must be a non-negative integer")
		return false

	if not rewards["xp"] is int or rewards["xp"] < 0:
		push_error("QuestResource: rewards.xp must be a non-negative integer")
		return false

	if not rewards["items"] is Array:
		push_error("QuestResource: rewards.items must be an Array")
		return false

	if not rewards["unlocks"] is Array:
		push_error("QuestResource: rewards.unlocks must be an Array")
		return false

	return true