extends RefCounted
class_name ShopKeeperData

var name: String = "Merchant Mallow"
var portrait_path: String = ""
var dialogue_lines: Dictionary = {}
var mood: String = "happy"

func _init():
	_setup_dialogue_lines()

func _setup_dialogue_lines():
	dialogue_lines = {
		"greeting": [
			"Welcome!",
			"Looking for something special?",
			"Step right up! Fresh supplies today!",
			"What brings you to my humble shop?"
		],
		"purchase_success": [
			"Excellent choice!",
			"Thank you for your business!",
			"A wise purchase indeed!",
			"That'll serve you well!"
		],
		"insufficient_funds": [
			"You'll need more gold for that.",
			"Perhaps something more affordable?",
			"Save up a bit more and come back!",
			"Your purse is a bit light for that item."
		],
		"browse": [
			"Take your time.",
			"Let me know if you need help.",
			"Browse to your heart's content!",
			"Everything's clearly marked with prices."
		],
		"farewell": [
			"Come again soon!",
			"Safe travels!",
			"May fortune smile upon you!",
			"Until next time, friend!"
		],
		"special_deal": [
			"I have a special offer today!",
			"Limited time discount!",
			"This won't last long at this price!",
			"A deal you can't refuse!"
		]
	}

func get_dialogue(context: String) -> String:
	if not dialogue_lines.has(context):
		return "..."

	var lines = dialogue_lines[context]
	if lines.is_empty():
		return "..."

	return lines[randi() % lines.size()]

func set_mood(new_mood: String):
	if new_mood in ["happy", "neutral", "annoyed"]:
		mood = new_mood

func get_mood_modifier() -> String:
	match mood:
		"happy": return "cheerful"
		"neutral": return "polite"
		"annoyed": return "curt"
		_: return "polite"