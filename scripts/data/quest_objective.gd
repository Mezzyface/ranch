extends RefCounted
class_name QuestObjective

enum ObjectiveType {
	PROVIDE_CREATURE,
	PROVIDE_MULTIPLE
}

var type: ObjectiveType = ObjectiveType.PROVIDE_CREATURE
var required_tags: Array = []
var required_stats: Dictionary = {}
var quantity: int = 1
var description: String = ""

func _init(p_type: ObjectiveType = ObjectiveType.PROVIDE_CREATURE, p_tags: Array[String] = [], p_stats: Dictionary = {}, p_quantity: int = 1, p_description: String = ""):
	type = p_type
	required_tags = p_tags
	required_stats = p_stats
	quantity = p_quantity
	description = p_description

func matches_creature(creature_data: CreatureData) -> bool:
	if not creature_data:
		return false

	for tag: String in required_tags:
		if not creature_data.tags.has(tag):
			return false

	for stat_name: String in required_stats.keys():
		var required_value: int = required_stats[stat_name]
		var creature_stat_value: int = creature_data.get_stat(stat_name)

		if creature_stat_value < required_value:
			return false

	return true