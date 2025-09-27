@tool
class_name VendorResource
extends Resource

# Core Vendor Information
@export var vendor_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var location: String = ""

# Unlock System
@export var unlock_requirements: Dictionary = {}  # quest_id -> bool, level -> int, etc.
@export var is_unlocked_by_default: bool = false

# Inventory Management
@export var base_inventory: Array = []  # Array of item IDs (strings)
@export var specialization_tags: Array = []  # Tags this vendor specializes in (strings)
@export var specialization_creature_types: Array = []  # Species this vendor focuses on (strings)

# Reputation System
@export var reputation_bonuses: Dictionary = {}  # reputation_level -> discount_percent
@export var max_reputation: int = 100

# Economic Properties
@export var markup_modifier: float = 1.0  # Price multiplier for this vendor
@export var restock_frequency_days: int = 7  # How often inventory restocks
@export var inventory_size_multiplier: float = 1.0  # Affects stock quantities

# Vendor Personality & Dialogue
@export_multiline var greeting_text: String = ""
@export_multiline var purchase_success_text: String = ""
@export_multiline var insufficient_funds_text: String = ""
@export_multiline var out_of_stock_text: String = ""
@export_multiline var reputation_unlock_text: String = ""

# Visual Properties
@export var vendor_portrait_path: String = ""
@export var shop_background_path: String = ""
@export var theme_color: Color = Color.WHITE

# Special Features
@export var has_special_deals: bool = false
@export var deal_rotation_days: int = 14
@export var exclusive_items: Array = []  # Items only this vendor sells (strings)

func _init() -> void:
	_setup_defaults()

func _setup_defaults() -> void:
	if greeting_text.is_empty():
		greeting_text = "Welcome to my shop!"
	if purchase_success_text.is_empty():
		purchase_success_text = "Thank you for your purchase!"
	if insufficient_funds_text.is_empty():
		insufficient_funds_text = "I'm afraid you don't have enough gold for that."
	if out_of_stock_text.is_empty():
		out_of_stock_text = "Sorry, I'm out of stock on that item."

func is_valid() -> bool:
	if vendor_id.is_empty() or display_name.is_empty():
		return false
	if markup_modifier <= 0.0:
		return false
	if restock_frequency_days <= 0:
		return false
	if inventory_size_multiplier <= 0.0:
		return false
	return true

func is_unlocked(quest_system = null, player_data = null) -> bool:
	if is_unlocked_by_default:
		return true

	# Check unlock requirements
	for requirement in unlock_requirements:
		match requirement:
			"quest_completed":
				var quest_id = unlock_requirements[requirement]
				if quest_system and not quest_system.is_quest_completed(quest_id):
					return false
			"player_level":
				var required_level = unlock_requirements[requirement]
				if player_data and player_data.get("level", 0) < required_level:
					return false
			"reputation":
				var required_rep = unlock_requirements[requirement]
				if player_data and player_data.get("reputation", {}).get(vendor_id, 0) < required_rep:
					return false

	return true

func get_reputation_discount(reputation: int) -> int:
	var discount = 0
	for rep_level in reputation_bonuses:
		if reputation >= rep_level:
			discount = reputation_bonuses[rep_level]
	return discount

func calculate_item_price(base_price: int, reputation: int = 0) -> int:
	var price = int(base_price * markup_modifier)
	var discount = get_reputation_discount(reputation)
	price = int(price * (100 - discount) / 100.0)
	return maxi(price, 1)

func specializes_in_creature_type(species_id: String) -> bool:
	return species_id in specialization_creature_types

func specializes_in_tags(tags: Array[String]) -> bool:
	for tag in tags:
		if tag in specialization_tags:
			return true
	return false

func get_unlock_status_text() -> String:
	if is_unlocked_by_default:
		return "Available"

	var requirements_text: Array[String] = []
	for requirement in unlock_requirements:
		match requirement:
			"quest_completed":
				requirements_text.append("Complete quest: " + str(unlock_requirements[requirement]))
			"player_level":
				requirements_text.append("Reach level " + str(unlock_requirements[requirement]))
			"reputation":
				requirements_text.append("Gain " + str(unlock_requirements[requirement]) + " reputation")

	if requirements_text.is_empty():
		return "Requirements unknown"
	else:
		return "Requires: " + ", ".join(requirements_text)

# Serialization
func to_dict() -> Dictionary:
	return {
		"vendor_id": vendor_id,
		"display_name": display_name,
		"description": description,
		"location": location,
		"unlock_requirements": unlock_requirements,
		"is_unlocked_by_default": is_unlocked_by_default,
		"base_inventory": base_inventory,
		"specialization_tags": specialization_tags,
		"specialization_creature_types": specialization_creature_types,
		"reputation_bonuses": reputation_bonuses,
		"max_reputation": max_reputation,
		"markup_modifier": markup_modifier,
		"restock_frequency_days": restock_frequency_days,
		"inventory_size_multiplier": inventory_size_multiplier,
		"greeting_text": greeting_text,
		"purchase_success_text": purchase_success_text,
		"insufficient_funds_text": insufficient_funds_text,
		"out_of_stock_text": out_of_stock_text,
		"reputation_unlock_text": reputation_unlock_text,
		"vendor_portrait_path": vendor_portrait_path,
		"shop_background_path": shop_background_path,
		"theme_color": [theme_color.r, theme_color.g, theme_color.b, theme_color.a],
		"has_special_deals": has_special_deals,
		"deal_rotation_days": deal_rotation_days,
		"exclusive_items": exclusive_items
	}

static func from_dict(data: Dictionary) -> VendorResource:
	var resource = VendorResource.new()

	resource.vendor_id = data.get("vendor_id", "")
	resource.display_name = data.get("display_name", "")
	resource.description = data.get("description", "")
	resource.location = data.get("location", "")
	resource.unlock_requirements = data.get("unlock_requirements", {})
	resource.is_unlocked_by_default = data.get("is_unlocked_by_default", false)
	resource.base_inventory = data.get("base_inventory", [])
	resource.specialization_tags = data.get("specialization_tags", [])
	resource.specialization_creature_types = data.get("specialization_creature_types", [])
	resource.reputation_bonuses = data.get("reputation_bonuses", {})
	resource.max_reputation = data.get("max_reputation", 100)
	resource.markup_modifier = data.get("markup_modifier", 1.0)
	resource.restock_frequency_days = data.get("restock_frequency_days", 7)
	resource.inventory_size_multiplier = data.get("inventory_size_multiplier", 1.0)
	resource.greeting_text = data.get("greeting_text", "")
	resource.purchase_success_text = data.get("purchase_success_text", "")
	resource.insufficient_funds_text = data.get("insufficient_funds_text", "")
	resource.out_of_stock_text = data.get("out_of_stock_text", "")
	resource.reputation_unlock_text = data.get("reputation_unlock_text", "")
	resource.vendor_portrait_path = data.get("vendor_portrait_path", "")
	resource.shop_background_path = data.get("shop_background_path", "")

	var color_data = data.get("theme_color", [1.0, 1.0, 1.0, 1.0])
	resource.theme_color = Color(color_data[0], color_data[1], color_data[2], color_data[3])

	resource.has_special_deals = data.get("has_special_deals", false)
	resource.deal_rotation_days = data.get("deal_rotation_days", 14)
	resource.exclusive_items = data.get("exclusive_items", [])

	return resource