class_name WeeklySummary extends Resource

@export var week: int = 0
@export var creatures_aged: int = 0
@export var category_changes: Array[Dictionary] = []
@export var stamina_changes: Dictionary = {}
@export var food_consumed: int = 0
@export var food_remaining: int = 0
@export var gold_spent: int = 0
@export var gold_earned: int = 0
@export var quest_completions: Array[String] = []
@export var competition_results: Array[Dictionary] = []
@export var events_triggered: Array[String] = []
@export var creatures_expired: Array[String] = []

func _init():
	stamina_changes = {
		"depleted": [],
		"recovered": []
	}

func get_summary_text() -> String:
	var text = "Week %d Summary:\n" % week

	if creatures_aged > 0:
		text += "• %d creatures aged\n" % creatures_aged

	if category_changes.size() > 0:
		text += "• %d creatures changed age category\n" % category_changes.size()

	if creatures_expired.size() > 0:
		text += "• %d creatures reached end of lifespan\n" % creatures_expired.size()

	if stamina_changes.has("depleted") and stamina_changes.depleted.size() > 0:
		text += "• %d creatures lost stamina\n" % stamina_changes.depleted.size()

	if stamina_changes.has("recovered") and stamina_changes.recovered.size() > 0:
		text += "• %d creatures recovered stamina\n" % stamina_changes.recovered.size()

	if food_consumed > 0:
		text += "• %d food consumed\n" % food_consumed

	var net_gold = gold_earned - gold_spent
	if net_gold != 0:
		text += "• Gold: %+d\n" % net_gold

	if quest_completions.size() > 0:
		text += "• %d quests completed\n" % quest_completions.size()

	if competition_results.size() > 0:
		text += "• %d competitions finished\n" % competition_results.size()

	return text

func to_dict() -> Dictionary:
	return {
		"week": week,
		"creatures_aged": creatures_aged,
		"category_changes": category_changes,
		"stamina_changes": stamina_changes,
		"food_consumed": food_consumed,
		"food_remaining": food_remaining,
		"gold_spent": gold_spent,
		"gold_earned": gold_earned,
		"quest_completions": quest_completions,
		"competition_results": competition_results,
		"events_triggered": events_triggered,
		"creatures_expired": creatures_expired
	}

func from_dict(data: Dictionary) -> void:
	week = data.get("week", 0)
	creatures_aged = data.get("creatures_aged", 0)
	category_changes = data.get("category_changes", [])
	stamina_changes = data.get("stamina_changes", {})
	food_consumed = data.get("food_consumed", 0)
	food_remaining = data.get("food_remaining", 0)
	gold_spent = data.get("gold_spent", 0)
	gold_earned = data.get("gold_earned", 0)
	quest_completions = data.get("quest_completions", [])
	competition_results = data.get("competition_results", [])
	events_triggered = data.get("events_triggered", [])
	creatures_expired = data.get("creatures_expired", [])