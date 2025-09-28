extends Node
class_name ShopInventoryManager

# Shop inventory manager for loading and managing ShopItemResource-based items
# Manages shop items loaded from .tres files with proper validation

# === PROPERTIES ===
var loaded_shop_items: Array[ShopItemResource] = []
var items_by_category: Dictionary = {}  # category -> Array[ShopItemResource]
var items_by_id: Dictionary = {}  # item_id -> ShopItemResource

# === CONSTANTS ===
const SHOP_DATA_PATH: String = "res://data/shop/"
const VALID_CATEGORIES: Array[String] = ["creatures", "food", "equipment", "facilities"]

func _ready() -> void:
	print("ShopInventoryManager initialized")
	_load_shop_items()

func _load_shop_items() -> void:
	"""Load all shop items from data/shop/ directory."""
	# Initialize categories
	for category in VALID_CATEGORIES:
		items_by_category[category] = []

	# Load shop item files
	var dir = DirAccess.open(SHOP_DATA_PATH)
	if not dir:
		push_error("ShopInventoryManager: Cannot access shop data directory: %s" % SHOP_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var loaded_count = 0

	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = SHOP_DATA_PATH + file_name
			var resource = load(full_path)

			if resource and resource is ShopItemResource:
				if _validate_and_add_item(resource):
					loaded_count += 1
				else:
					push_error("ShopInventoryManager: Failed to validate shop item: %s" % file_name)
			else:
				push_error("ShopInventoryManager: Invalid resource type in %s" % file_name)

		file_name = dir.get_next()

	print("ShopInventoryManager: Loaded %d shop items" % loaded_count)

func _validate_and_add_item(item: ShopItemResource) -> bool:
	"""Validate and add a shop item to the inventory."""
	if not item.is_valid():
		var validation = item.validate()
		for error in validation.errors:
			push_error("ShopInventoryManager: Validation error for %s: %s" % [item.item_id, error])
		return false

	# Check for duplicate IDs
	if item.item_id in items_by_id:
		push_error("ShopInventoryManager: Duplicate item ID: %s" % item.item_id)
		return false

	# Add to collections
	loaded_shop_items.append(item)
	items_by_id[item.item_id] = item

	if item.category in items_by_category:
		items_by_category[item.category].append(item)
	else:
		push_error("ShopInventoryManager: Invalid category '%s' for item %s" % [item.category, item.item_id])
		return false

	return true

# === PUBLIC API ===

func get_all_items() -> Array[ShopItemResource]:
	"""Get all loaded shop items."""
	return loaded_shop_items.duplicate()

func get_items_by_category(category: String) -> Array[ShopItemResource]:
	"""Get all items in a specific category."""
	if category in items_by_category:
		var result: Array[ShopItemResource] = []
		result.assign(items_by_category[category])
		return result
	return []

func get_item_by_id(item_id: String) -> ShopItemResource:
	"""Get a specific item by ID."""
	return items_by_id.get(item_id, null)

func get_available_items() -> Array[ShopItemResource]:
	"""Get all items that are currently in stock."""
	var available: Array[ShopItemResource] = []
	for item in loaded_shop_items:
		if item.is_in_stock():
			available.append(item)
	return available

func get_available_items_by_category(category: String) -> Array[ShopItemResource]:
	"""Get available items in a specific category."""
	var available: Array[ShopItemResource] = []
	var category_items = get_items_by_category(category)
	for item in category_items:
		if item.is_in_stock():
			available.append(item)
	return available

func get_affordable_items(gold_amount: int) -> Array[ShopItemResource]:
	"""Get all items the player can afford."""
	var affordable: Array[ShopItemResource] = []
	for item in loaded_shop_items:
		if item.is_in_stock() and item.can_afford(gold_amount):
			affordable.append(item)
	return affordable

func get_unlocked_items(player_data: Dictionary = {}) -> Array[ShopItemResource]:
	"""Get all items that meet unlock requirements."""
	var unlocked: Array[ShopItemResource] = []
	for item in loaded_shop_items:
		if item.meets_unlock_requirements(player_data):
			unlocked.append(item)
	return unlocked

func can_purchase_item(item_id: String, gold_amount: int, player_data: Dictionary = {}) -> Dictionary:
	"""Check if an item can be purchased. Returns detailed result."""
	var item = get_item_by_id(item_id)
	if not item:
		return {"can_purchase": false, "reason": "Item not found"}

	if not item.is_in_stock():
		return {"can_purchase": false, "reason": "Out of stock"}

	if not item.can_afford(gold_amount):
		return {"can_purchase": false, "reason": "Insufficient gold", "required": item.base_price, "available": gold_amount}

	if not item.meets_unlock_requirements(player_data):
		return {"can_purchase": false, "reason": "Requirements not met", "requirements": item.unlock_requirements}

	return {"can_purchase": true, "item": item}

func purchase_item(item_id: String, gold_amount: int, player_data: Dictionary = {}) -> Dictionary:
	"""Attempt to purchase an item. Returns transaction result."""
	var check = can_purchase_item(item_id, gold_amount, player_data)
	if not check.can_purchase:
		return check

	var item: ShopItemResource = check.item

	# Consume stock
	if not item.consume_stock():
		return {"success": false, "reason": "Failed to consume stock"}

	# Transaction successful
	return {
		"success": true,
		"item": item,
		"cost": item.base_price,
		"remaining_gold": gold_amount - item.base_price,
		"item_data": item.item_data
	}

func restock_item(item_id: String, amount: int = 1) -> bool:
	"""Restock an item by adding to its quantity."""
	var item = get_item_by_id(item_id)
	if not item:
		return false

	item.restock(amount)
	return true

func restock_all_items() -> void:
	"""Restock all items to their default quantities."""
	for item in loaded_shop_items:
		if item.stock_quantity > 0:
			# Reset to a default stock level - could be configurable
			item.stock_quantity = 10

# === UTILITY METHODS ===

func get_shop_statistics() -> Dictionary:
	"""Get statistics about the shop inventory."""
	var stats = {
		"total_items": loaded_shop_items.size(),
		"categories": {},
		"in_stock": 0,
		"out_of_stock": 0,
		"unlimited_stock": 0
	}

	for category in VALID_CATEGORIES:
		stats.categories[category] = get_items_by_category(category).size()

	for item in loaded_shop_items:
		if item.stock_quantity == -1:
			stats.unlimited_stock += 1
		elif item.stock_quantity > 0:
			stats.in_stock += 1
		else:
			stats.out_of_stock += 1

	return stats

func reload_shop_items() -> void:
	"""Reload all shop items from disk (useful for development)."""
	loaded_shop_items.clear()
	items_by_category.clear()
	items_by_id.clear()
	_load_shop_items()

# === VALIDATION ===

func validate_all_items() -> Dictionary:
	"""Validate all loaded shop items and return report."""
	var validation_report = {
		"valid_items": 0,
		"invalid_items": 0,
		"errors": []
	}

	for item in loaded_shop_items:
		var validation = item.validate()
		if validation.valid:
			validation_report.valid_items += 1
		else:
			validation_report.invalid_items += 1
			for error in validation.errors:
				validation_report.errors.append("%s: %s" % [item.item_id, error])

	return validation_report