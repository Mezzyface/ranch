@tool
class_name ShopItemResource
extends Resource

# Core shop item information
@export var item_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var category: String = "" # creatures/food/equipment/facilities
@export var base_price: int = 0
@export var icon_path: String = ""
@export var stock_quantity: int = -1 # -1 for unlimited stock
@export var unlock_requirements: Dictionary = {}

# Category-specific data
@export var species_id: String = "" # For creatures category
@export var item_data: Resource # For other categories

func _init() -> void:
	_setup_defaults()

func _setup_defaults() -> void:
	"""Set up default values if not configured."""
	if stock_quantity == 0:
		stock_quantity = -1  # Default to unlimited

# Validation
func is_valid() -> bool:
	"""Quick validation check for shop item."""
	if item_id.is_empty() or display_name.is_empty():
		return false
	if category.is_empty():
		return false
	if base_price < 0:
		return false
	if not category in ["creatures", "food", "equipment", "facilities"]:
		return false
	# item_data can be null for some categories like facilities
	return true

func validate() -> Dictionary:
	"""Comprehensive validation with detailed error reporting."""
	var errors: Array[String] = []

	if item_id.is_empty():
		errors.append("item_id cannot be empty")
	if display_name.is_empty():
		errors.append("display_name cannot be empty")
	if category.is_empty():
		errors.append("category cannot be empty")
	elif not category in ["creatures", "food", "equipment", "facilities"]:
		errors.append("category must be one of: creatures, food, equipment, facilities")
	if base_price < 0:
		errors.append("base_price cannot be negative")
	if stock_quantity < -1:
		errors.append("stock_quantity must be -1 (unlimited) or positive")

	# Category-specific validation
	match category:
		"creatures":
			# For creatures, either species_id should be set or item_data should contain creature info
			if species_id.is_empty() and not item_data:
				errors.append("creatures category requires either species_id or item_data")
		"food", "equipment":
			if not item_data or not item_data is ItemResource:
				errors.append("%s category requires ItemResource as item_data" % category)
		"facilities":
			# Facilities might not need item_data, or could have FacilityResource
			pass

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

# Helper methods
func get_category_display_name() -> String:
	"""Get human-readable category name."""
	match category:
		"creatures":
			return "Creatures"
		"food":
			return "Food"
		"equipment":
			return "Equipment"
		"facilities":
			return "Facilities"
		_:
			return "Unknown"

func is_in_stock() -> bool:
	"""Check if item is available for purchase."""
	return stock_quantity == -1 or stock_quantity > 0

func can_afford(gold_amount: int) -> bool:
	"""Check if player can afford this item."""
	return gold_amount >= base_price

func meets_unlock_requirements(player_data: Dictionary = {}) -> bool:
	"""Check if unlock requirements are met. Override with actual implementation."""
	if unlock_requirements.is_empty():
		return true

	# Basic requirement checking - extend as needed
	for requirement in unlock_requirements:
		match requirement:
			"min_level":
				var required_level = unlock_requirements[requirement]
				var player_level = player_data.get("level", 1)
				if player_level < required_level:
					return false
			"completed_quest":
				var required_quest = unlock_requirements[requirement]
				var completed_quests = player_data.get("completed_quests", [])
				if not required_quest in completed_quests:
					return false
			"owned_creatures":
				var required_count = unlock_requirements[requirement]
				var creature_count = player_data.get("creature_count", 0)
				if creature_count < required_count:
					return false

	return true

func consume_stock() -> bool:
	"""Consume one unit of stock. Returns false if not in stock."""
	if not is_in_stock():
		return false

	if stock_quantity > 0:
		stock_quantity -= 1

	return true

func restock(amount: int = 1) -> void:
	"""Add stock (for limited items)."""
	if stock_quantity == -1:
		return  # Unlimited stock

	stock_quantity = max(0, stock_quantity + amount)

# Serialization for save compatibility
func to_dict() -> Dictionary:
	var result = {
		"item_id": item_id,
		"display_name": display_name,
		"description": description,
		"category": category,
		"base_price": base_price,
		"icon_path": icon_path,
		"stock_quantity": stock_quantity,
		"unlock_requirements": unlock_requirements,
		"species_id": species_id
	}

	# Serialize item_data if present
	if item_data:
		if item_data.has_method("to_dict"):
			result["item_data"] = item_data.to_dict()
		else:
			result["item_data"] = var_to_str(item_data)

	return result

static func from_dict(data: Dictionary) -> ShopItemResource:
	"""Create ShopItemResource from dictionary data."""
	var resource = ShopItemResource.new()

	resource.item_id = data.get("item_id", "")
	resource.display_name = data.get("display_name", "")
	resource.description = data.get("description", "")
	resource.category = data.get("category", "")
	resource.base_price = data.get("base_price", 0)
	resource.icon_path = data.get("icon_path", "")
	resource.stock_quantity = data.get("stock_quantity", -1)
	resource.unlock_requirements = data.get("unlock_requirements", {})
	resource.species_id = data.get("species_id", "")

	# Handle item_data restoration - this would need more sophisticated handling
	var item_data_raw = data.get("item_data")
	if item_data_raw:
		# This would need proper type restoration logic
		pass

	return resource