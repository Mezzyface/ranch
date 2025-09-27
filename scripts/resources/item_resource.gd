@tool
class_name ItemResource
extends Resource

# Core Item Information
@export var item_id: String = ""
@export var display_name: String = ""
@export var item_type: GlobalEnums.ItemType = GlobalEnums.ItemType.CONSUMABLE
@export var rarity: GlobalEnums.ItemRarity = GlobalEnums.ItemRarity.COMMON

# Economy
@export var base_price: int = 0
@export var sell_value: int = 0  # Usually base_price * 0.6
@export var stack_size: int = 1  # Max items per inventory slot

# Properties
@export var is_consumable: bool = true
@export var is_tradeable: bool = true
@export var is_quest_item: bool = false

# Effects (for consumables)
@export var stamina_restore: int = 0
@export var stat_boosts: Dictionary = {}  # stat_name -> boost_amount
@export var stat_boost_duration_hours: int = 0  # 0 = permanent
@export var healing_amount: int = 0

# Requirements
@export var required_level: int = 1
@export var required_tags: Array[String] = []  # Creature must have these tags to use

# Description & Lore
@export_multiline var description: String = ""
@export_multiline var flavor_text: String = ""
@export var icon_path: String = ""

# Crafting (for future expansion)
@export var crafting_recipe: Array[Dictionary] = []  # [{item_id: String, quantity: int}]
@export var crafting_time_minutes: int = 0

# Drop Information
@export var drop_sources: Array[String] = []  # Quest IDs, creature types, etc.
@export var drop_chance: float = 0.0  # 0.0-1.0

func _init() -> void:
	_setup_defaults()

func _setup_defaults() -> void:
	"""Set up default values if not configured."""
	if sell_value == 0 and base_price > 0:
		sell_value = int(base_price * 0.6)

# Validation
func is_valid() -> bool:
	"""Quick validation check."""
	if item_id.is_empty() or display_name.is_empty():
		return false
	if base_price < 0 or sell_value < 0:
		return false
	if stack_size < 1:
		return false
	return true

func validate() -> Dictionary:
	"""Comprehensive validation with detailed error reporting."""
	var errors: Array[String] = []

	if item_id.is_empty():
		errors.append("item_id cannot be empty")
	if display_name.is_empty():
		errors.append("display_name cannot be empty")
	if base_price < 0:
		errors.append("base_price cannot be negative")
	if sell_value < 0:
		errors.append("sell_value cannot be negative")
	if stack_size < 1:
		errors.append("stack_size must be at least 1")
	if drop_chance < 0.0 or drop_chance > 1.0:
		errors.append("drop_chance must be between 0.0 and 1.0")

	# Validate stat boosts
	for stat_name in stat_boosts:
		var boost_value = stat_boosts[stat_name]
		if not boost_value is int:
			errors.append("Stat boost for %s must be an integer" % stat_name)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

# Helper methods
func get_type_string() -> String:
	match item_type:
		GlobalEnums.ItemType.FOOD:
			return "Food"
		GlobalEnums.ItemType.EQUIPMENT:
			return "Equipment"
		GlobalEnums.ItemType.CONSUMABLE:
			return "Consumable"
		GlobalEnums.ItemType.MATERIAL:
			return "Material"
		GlobalEnums.ItemType.KEY_ITEM:
			return "Key Item"
		_:
			return "Unknown"

func get_rarity_string() -> String:
	match rarity:
		GlobalEnums.ItemRarity.COMMON:
			return "Common"
		GlobalEnums.ItemRarity.UNCOMMON:
			return "Uncommon"
		GlobalEnums.ItemRarity.RARE:
			return "Rare"
		GlobalEnums.ItemRarity.EPIC:
			return "Epic"
		GlobalEnums.ItemRarity.LEGENDARY:
			return "Legendary"
		_:
			return "Unknown"

func can_be_used_by_creature(creature: CreatureData) -> bool:
	"""Check if creature meets requirements to use this item."""
	# Check required tags
	for required_tag in required_tags:
		if not creature.has_tag(required_tag):
			return false
	return true

func apply_effects_to_creature(creature: CreatureData) -> Dictionary:
	"""Apply item effects to creature. Returns result dictionary."""
	var result = {"success": false, "message": ""}

	if not can_be_used_by_creature(creature):
		result.message = "Creature does not meet requirements to use this item"
		return result

	if not is_consumable:
		result.message = "Item is not consumable"
		return result

	# Apply stamina restoration
	if stamina_restore > 0:
		var old_stamina = creature.stamina_current
		creature.stamina_current = mini(creature.stamina_current + stamina_restore, creature.stamina_max)
		result.message += "Restored %d stamina. " % (creature.stamina_current - old_stamina)

	# Apply healing
	if healing_amount > 0:
		# Future: implement health system
		result.message += "Would heal %d HP. " % healing_amount

	# Apply stat boosts (would need a buff system for temporary effects)
	if not stat_boosts.is_empty():
		for stat_name in stat_boosts:
			var boost_amount = stat_boosts[stat_name]
			result.message += "Would apply %d %s boost. " % [boost_amount, stat_name]

	result.success = true
	if result.message.is_empty():
		result.message = "Item used successfully"

	return result

# Serialization for save compatibility
func to_dict() -> Dictionary:
	return {
		"item_id": item_id,
		"display_name": display_name,
		"item_type": item_type,
		"rarity": rarity,
		"base_price": base_price,
		"sell_value": sell_value,
		"stack_size": stack_size,
		"is_consumable": is_consumable,
		"is_tradeable": is_tradeable,
		"is_quest_item": is_quest_item,
		"stamina_restore": stamina_restore,
		"stat_boosts": stat_boosts,
		"stat_boost_duration_hours": stat_boost_duration_hours,
		"healing_amount": healing_amount,
		"required_level": required_level,
		"required_tags": required_tags,
		"description": description,
		"flavor_text": flavor_text,
		"icon_path": icon_path,
		"crafting_recipe": crafting_recipe,
		"crafting_time_minutes": crafting_time_minutes,
		"drop_sources": drop_sources,
		"drop_chance": drop_chance
	}

static func from_dict(data: Dictionary) -> ItemResource:
	"""Create ItemResource from dictionary data."""
	var resource = ItemResource.new()

	resource.item_id = data.get("item_id", "")
	resource.display_name = data.get("display_name", "")
	resource.item_type = data.get("item_type", GlobalEnums.ItemType.CONSUMABLE)
	resource.rarity = data.get("rarity", GlobalEnums.ItemRarity.COMMON)
	resource.base_price = data.get("base_price", 0)
	resource.sell_value = data.get("sell_value", 0)
	resource.stack_size = data.get("stack_size", 1)
	resource.is_consumable = data.get("is_consumable", true)
	resource.is_tradeable = data.get("is_tradeable", true)
	resource.is_quest_item = data.get("is_quest_item", false)
	resource.stamina_restore = data.get("stamina_restore", 0)
	resource.stat_boosts = data.get("stat_boosts", {})
	resource.stat_boost_duration_hours = data.get("stat_boost_duration_hours", 0)
	resource.healing_amount = data.get("healing_amount", 0)
	resource.required_level = data.get("required_level", 1)
	resource.required_tags = data.get("required_tags", [])
	resource.description = data.get("description", "")
	resource.flavor_text = data.get("flavor_text", "")
	resource.icon_path = data.get("icon_path", "")
	resource.crafting_recipe = data.get("crafting_recipe", [])
	resource.crafting_time_minutes = data.get("crafting_time_minutes", 0)
	resource.drop_sources = data.get("drop_sources", [])
	resource.drop_chance = data.get("drop_chance", 0.0)

	return resource
