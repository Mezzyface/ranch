extends Node
class_name ItemManager

# ItemManager - Resource-based item management system
# Loads and manages ItemResource instances instead of static dictionaries

# === CONSTANTS ===
const ITEMS_DATA_PATH: String = "res://data/items/"
const ITEMS_FILE_EXTENSION: String = ".tres"

# === ITEM DATA ===
var item_registry: Dictionary = {}  # item_id -> ItemResource
var items_by_type: Dictionary = {}  # ItemType -> Array[String]
var items_by_rarity: Dictionary = {} # ItemRarity -> Array[String]

# === CACHING ===
var _loading_cache: Dictionary = {}
var _validation_cache: Dictionary = {}

func _init() -> void:
	print("ItemManager initialized")
	_load_all_items()

func _load_all_items() -> void:
	"""Load all items from the items data directory."""
	var dir: DirAccess = DirAccess.open(ITEMS_DATA_PATH)
	if not dir:
		push_warning("ItemManager: Items data directory not found: %s" % ITEMS_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(ITEMS_FILE_EXTENSION):
			var item_path: String = ITEMS_DATA_PATH + file_name
			_load_item_from_file(item_path)
		file_name = dir.get_next()

	_organize_items_data()
	print("ItemManager: Loaded %d items" % item_registry.size())

func _load_item_from_file(file_path: String) -> bool:
	"""Load a single item from file."""
	var item: ItemResource = load(file_path) as ItemResource
	if not item:
		push_error("ItemManager: Failed to load item from %s" % file_path)
		return false

	# Validate item data
	var validation: Dictionary = item.validate()
	if not validation.valid:
		push_error("ItemManager: Invalid item %s: %s" % [item.item_id, str(validation.errors)])
		return false

	# Register item
	item_registry[item.item_id] = item
	return true

func _organize_items_data() -> void:
	"""Organize items by types and rarities for efficient lookup."""
	items_by_type.clear()
	items_by_rarity.clear()

	for item_id in item_registry:
		var item: ItemResource = item_registry[item_id]

		# Organize by type (store by enum value)
		if not items_by_type.has(item.item_type):
			items_by_type[item.item_type] = []
		items_by_type[item.item_type].append(item_id)

		# Organize by rarity (store by enum value)
		if not items_by_rarity.has(item.rarity):
			items_by_rarity[item.rarity] = []
		items_by_rarity[item.rarity].append(item_id)

# === PUBLIC API ===

func is_valid_item(item_id: String) -> bool:
	"""Check if item ID exists."""
	return item_id in item_registry

func get_item_data(item_id: String) -> Dictionary:
	"""Get item data as dictionary for backward compatibility."""
	var item: ItemResource = get_item_resource(item_id)
	if not item:
		return {}

	# Convert to legacy format for compatibility
	return {
		"name": item.display_name,
		"type": _get_legacy_type_string(item.item_type),
		"food_type": _get_legacy_food_type(item),
		"cost": item.base_price,
		"sell": item.sell_value,
		"effect": _get_legacy_effect_string(item)
	}

func get_item_cost(item_id: String) -> int:
	"""Get item cost."""
	var item: ItemResource = get_item_resource(item_id)
	return item.base_price if item else 0

func get_item_type(item_id: String) -> String:
	"""Get item type as string."""
	var item: ItemResource = get_item_resource(item_id)
	if not item:
		return "unknown"
	return _get_legacy_type_string(item.item_type)

func get_all_items() -> Dictionary:
	"""Get all items as dictionary for backward compatibility."""
	var result: Dictionary = {}
	for item_id in item_registry:
		result[item_id] = get_item_data(item_id)
	return result

func get_items_by_type(item_type_str: String) -> Array[String]:
	"""Get items by type string."""
	var result: Array[String] = []

	# Convert string to enum
	var type_enum: GlobalEnums.ItemType = _string_to_item_type(item_type_str)
	var type_items = items_by_type.get(type_enum, [])

	for item_id in type_items:
		result.append(item_id as String)
	return result

# === NEW RESOURCE-BASED API ===

func get_item_resource(item_id: String) -> ItemResource:
	"""Get ItemResource by ID. (Preferred new API)"""
	return item_registry.get(item_id, null)

func get_all_item_resources() -> Array[ItemResource]:
	"""Get array of all ItemResource objects."""
	var items: Array[ItemResource] = []
	for item_resource in item_registry.values():
		items.append(item_resource)
	return items

func get_items_by_type_enum(item_type: GlobalEnums.ItemType) -> Array[ItemResource]:
	"""Get ItemResource objects by type enum."""
	var result: Array[ItemResource] = []
	var type_items = items_by_type.get(item_type, [])

	for item_id in type_items:
		var item_resource = item_registry.get(item_id)
		if item_resource:
			result.append(item_resource)
	return result

func get_items_by_rarity_enum(rarity: GlobalEnums.ItemRarity) -> Array[ItemResource]:
	"""Get ItemResource objects by rarity enum."""
	var result: Array[ItemResource] = []
	var rarity_items = items_by_rarity.get(rarity, [])

	for item_id in rarity_items:
		var item_resource = item_registry.get(item_id)
		if item_resource:
			result.append(item_resource)
	return result

func can_creature_use_item(creature: CreatureData, item_id: String) -> bool:
	"""Check if creature can use this item."""
	var item: ItemResource = get_item_resource(item_id)
	if not item:
		return false
	return item.can_be_used_by_creature(creature)

func apply_item_to_creature(creature: CreatureData, item_id: String) -> Dictionary:
	"""Apply item effects to creature."""
	var item: ItemResource = get_item_resource(item_id)
	if not item:
		return {"success": false, "message": "Item not found"}
	return item.apply_effects_to_creature(creature)

# === STATISTICS ===

func get_item_statistics() -> Dictionary:
	"""Get statistics about loaded items."""
	var stats = {
		"total_items": item_registry.size(),
		"by_type": {},
		"by_rarity": {}
	}

	for type_enum in items_by_type:
		var type_name = _get_legacy_type_string(type_enum)
		stats.by_type[type_name] = items_by_type[type_enum].size()

	for rarity_enum in items_by_rarity:
		var rarity_name = GlobalEnums.ItemRarity.keys()[rarity_enum]
		stats.by_rarity[rarity_name] = items_by_rarity[rarity_enum].size()

	return stats

# === PRIVATE HELPER METHODS ===

func _get_legacy_type_string(item_type: GlobalEnums.ItemType) -> String:
	"""Convert ItemType enum to legacy string format."""
	match item_type:
		GlobalEnums.ItemType.FOOD:
			return "food"
		GlobalEnums.ItemType.EQUIPMENT:
			return "equipment"
		GlobalEnums.ItemType.CONSUMABLE:
			return "consumable"
		GlobalEnums.ItemType.MATERIAL:
			return "material"
		GlobalEnums.ItemType.KEY_ITEM:
			return "quest"
		_:
			return "unknown"

func _string_to_item_type(type_str: String) -> GlobalEnums.ItemType:
	"""Convert legacy type string to ItemType enum."""
	match type_str.to_lower():
		"food":
			return GlobalEnums.ItemType.FOOD
		"equipment":
			return GlobalEnums.ItemType.EQUIPMENT
		"consumable":
			return GlobalEnums.ItemType.CONSUMABLE
		"material":
			return GlobalEnums.ItemType.MATERIAL
		"quest":
			return GlobalEnums.ItemType.KEY_ITEM
		_:
			return GlobalEnums.ItemType.CONSUMABLE

func _get_legacy_food_type(item: ItemResource) -> int:
	"""Get legacy food_type integer for backward compatibility."""
	if item.item_type != GlobalEnums.ItemType.FOOD:
		return -1

	# Map based on item rarity/effects for compatibility
	if item.stat_boosts.is_empty():
		return 0  # Basic food
	elif item.rarity <= GlobalEnums.ItemRarity.UNCOMMON:
		return 1  # Training food
	else:
		return 2  # Premium food

func _get_legacy_effect_string(item: ItemResource) -> String:
	"""Generate legacy effect string for backward compatibility."""
	if item.stat_boosts.is_empty():
		return ""

	var effects: Array[String] = []
	for stat_name in item.stat_boosts:
		var boost_amount = item.stat_boosts[stat_name]
		var stat_short = stat_name.left(3).to_upper()
		effects.append("%s+%d" % [stat_short, boost_amount])

	if effects.size() == 6:  # All stats boosted
		return "ALL+%d" % item.stat_boosts.values()[0]

	return effects[0] if not effects.is_empty() else ""