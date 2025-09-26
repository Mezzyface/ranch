extends Node
# ItemDatabase autoload - Static item definitions for the creature collection game

static var items: Dictionary = {
	# Basic Foods (25-50 gold each)
	"grain": {"name": "Grain", "type": "food", "food_type": 0, "cost": 25, "sell": 12},
	"hay": {"name": "Hay", "type": "food", "food_type": 0, "cost": 25, "sell": 12},
	"berries": {"name": "Berries", "type": "food", "food_type": 0, "cost": 30, "sell": 15},
	"water": {"name": "Fresh Water", "type": "food", "food_type": 0, "cost": 10, "sell": 5},

	# Training Foods (100-200 gold each)
	"protein_mix": {"name": "Protein Mix", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "STR+10"},
	"endurance_blend": {"name": "Endurance Blend", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "CON+10"},
	"agility_treats": {"name": "Agility Treats", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "DEX+10"},

	# Premium Foods (500+ gold each)
	"golden_nectar": {"name": "Golden Nectar", "type": "food", "food_type": 2, "cost": 500, "sell": 250, "effect": "ALL+5"},
	"vitality_elixir": {"name": "Vitality Elixir", "type": "food", "food_type": 2, "cost": 750, "sell": 375, "effect": "Heal+Age"},

	# Quest Items
	"quest_gem": {"name": "Mysterious Gem", "type": "quest", "cost": 0, "sell": 0}
}

static func is_valid_item(item_id: String) -> bool:
	return item_id in items

static func get_item_data(item_id: String) -> Dictionary:
	return items.get(item_id, {})

static func get_item_cost(item_id: String) -> int:
	return items.get(item_id, {}).get("cost", 0)

static func get_item_type(item_id: String) -> String:
	return items.get(item_id, {}).get("type", "unknown")

static func get_all_items() -> Dictionary:
	return items.duplicate()

static func get_items_by_type(item_type: String) -> Array[String]:
	var result: Array[String] = []
	for item_id: String in items:
		if items[item_id].get("type", "") == item_type:
			result.append(item_id)
	return result