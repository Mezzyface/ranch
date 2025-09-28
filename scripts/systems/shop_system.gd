extends Node
class_name ShopSystem

# Vendor-based shop system for creature management game
# Manages vendor inventories, pricing, unlocks, and purchasing

# === PROPERTIES ===
var vendors: Dictionary = {}  # vendor_id -> VendorResource
var vendor_inventories: Dictionary = {}  # vendor_id -> Dictionary[item_id -> VendorItem]
var vendor_reputations: Dictionary = {}  # vendor_id -> int
var restock_timer: int = 1  # weeks until global restock
var purchase_history: Array[Dictionary] = []  # purchase records

# === CONSTANTS ===
const MAX_PURCHASE_HISTORY: int = 100
const DEFAULT_RESTOCK_WEEKS: int = 4
const VENDOR_DATA_PATH: String = "data/vendors/"

# === VENDOR ITEM DATA STRUCTURE ===
class VendorItem:
	var item_id: String
	var vendor_id: String
	var quantity: int
	var max_quantity: int
	var base_price: int
	var current_price: int
	var in_stock: bool

	func _init(id: String, vendor: String, qty: int, max_qty: int, price: int) -> void:
		item_id = id
		vendor_id = vendor
		quantity = qty
		max_quantity = max_qty
		base_price = price
		current_price = price
		in_stock = qty > 0

func _ready() -> void:
	print("ShopSystem initialized")
	_load_vendors()
	_initialize_vendor_inventories()
	_connect_signals()

func _load_vendors() -> void:
	"""Load all vendor resources from data/vendors/ directory."""
	var vendor_files = [
		"starter_stable.tres",
		"mystical_menagerie.tres",
		"armored_ace.tres",
		"sky_sailor.tres",
		"shadow_market.tres",
		"savage_supplies.tres"
	]

	for file_name in vendor_files:
		var vendor_path = VENDOR_DATA_PATH + file_name
		var vendor_resource = load(vendor_path) as VendorResource

		if vendor_resource and vendor_resource.is_valid():
			vendors[vendor_resource.vendor_id] = vendor_resource
			vendor_reputations[vendor_resource.vendor_id] = 0
			print("ShopSystem: Loaded vendor '%s'" % vendor_resource.display_name)
		else:
			push_error("ShopSystem: Failed to load vendor from %s" % vendor_path)

	print("ShopSystem: Loaded %d vendors" % vendors.size())

func _initialize_vendor_inventories() -> void:
	"""Initialize inventories for all vendors."""
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		push_error("ShopSystem: ItemManager required but not loaded")
		return

	for vendor_id in vendors:
		var vendor = vendors[vendor_id]
		vendor_inventories[vendor_id] = {}

		# Stock base inventory items
		for item_id in vendor.base_inventory:
			_add_vendor_item(vendor_id, item_id, item_manager)

		# Stock specialized creature items if they exist
		for creature_type in vendor.specialization_creature_types:
			var egg_id = creature_type + "_egg"
			if item_manager.is_valid_item(egg_id):
				_add_vendor_item(vendor_id, egg_id, item_manager)

func _add_vendor_item(vendor_id: String, item_id: String, item_manager) -> void:
	"""Add an item to a vendor's inventory."""
	var vendor = vendors[vendor_id]
	if not vendor:
		return

	var item_resource = item_manager.get_item_resource(item_id)
	if not item_resource:
		# Create basic item for hardcoded items (grain, hay, etc.)
		var base_price = 50  # Default price
		if item_id == "grain": base_price = 5
		elif item_id == "hay": base_price = 8
		elif item_id == "berries": base_price = 12
		elif item_id == "water": base_price = 3

		var quantity = int(10 * vendor.inventory_size_multiplier)
		var max_quantity = int(15 * vendor.inventory_size_multiplier)
		var final_price = int(base_price * vendor.markup_modifier)

		var vendor_item = VendorItem.new(item_id, vendor_id, quantity, max_quantity, final_price)
		vendor_inventories[vendor_id][item_id] = vendor_item
	else:
		# Use ItemManager resource
		var quantity = int(5 * vendor.inventory_size_multiplier)
		var max_quantity = int(10 * vendor.inventory_size_multiplier)

		# Special quantities for creature eggs
		if "egg" in item_id:
			if item_id == "wind_dancer_egg": quantity = 3; max_quantity = 5
			elif item_id == "crystal_prowler_egg": quantity = 2; max_quantity = 3
			elif item_id == "shadow_stalker_egg": quantity = 1; max_quantity = 2

		var final_price = vendor.calculate_item_price(item_resource.base_price, vendor_reputations[vendor_id])

		var vendor_item = VendorItem.new(item_id, vendor_id, quantity, max_quantity, final_price)
		vendor_inventories[vendor_id][item_id] = vendor_item

func _connect_signals() -> void:
	"""Connect to relevant signals."""
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		if signal_bus.has_signal("week_advanced"):
			signal_bus.week_advanced.connect(_on_week_advanced)

# === VENDOR ACCESS METHODS ===

func get_all_vendors() -> Array[VendorResource]:
	"""Get all vendor resources."""
	var result: Array[VendorResource] = []
	for vendor_id in vendors:
		result.append(vendors[vendor_id])
	return result

func get_unlocked_vendors() -> Array[VendorResource]:
	"""Get only unlocked vendor resources."""
	var result: Array[VendorResource] = []
	var quest_system = GameCore.get_system("quest")

	for vendor_id in vendors:
		var vendor = vendors[vendor_id]
		if vendor.is_unlocked(quest_system, null):
			result.append(vendor)

	return result

func get_vendor(vendor_id: String) -> VendorResource:
	"""Get a specific vendor resource."""
	return vendors.get(vendor_id, null)

func is_vendor_unlocked(vendor_id: String) -> bool:
	"""Check if a vendor is unlocked."""
	var vendor = vendors.get(vendor_id, null)
	if not vendor:
		return false

	var quest_system = GameCore.get_system("quest")
	return vendor.is_unlocked(quest_system, null)

func get_vendor_inventory(vendor_id: String) -> Array[Dictionary]:
	"""Get inventory for a specific vendor."""
	var result: Array[Dictionary] = []

	if not vendor_inventories.has(vendor_id):
		return result

	var vendor_items = vendor_inventories[vendor_id]
	for item_id in vendor_items:
		var vendor_item = vendor_items[item_id]
		result.append({
			"item_id": vendor_item.item_id,
			"quantity": vendor_item.quantity,
			"price": vendor_item.current_price,
			"in_stock": vendor_item.in_stock,
			"vendor_id": vendor_item.vendor_id
		})

	return result

# === PURCHASING METHODS ===

func can_purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary:
	"""Check if an item can be purchased from a vendor."""
	var result = {"success": false, "reason": "", "cost": 0}

	# Check vendor exists and is unlocked
	if not is_vendor_unlocked(vendor_id):
		result.reason = "Vendor not available"
		return result

	# Check item exists in vendor inventory
	if not vendor_inventories.has(vendor_id) or not vendor_inventories[vendor_id].has(item_id):
		result.reason = "Item not available from this vendor"
		return result

	var vendor_item = vendor_inventories[vendor_id][item_id]

	# Check stock
	if vendor_item.quantity <= 0:
		result.reason = "Out of stock"
		return result

	# Check affordability
	result.cost = vendor_item.current_price
	if player_gold < result.cost:
		result.reason = "Insufficient funds"
		return result

	result.success = true
	return result

func purchase_item_from_vendor(vendor_id: String, item_id: String, player_gold: int) -> Dictionary:
	"""Purchase an item from a vendor."""
	var result = {"success": false, "reason": "", "cost": 0, "item_id": item_id}
	var creature_data = null  # Store creature data for signal emission

	# Validate purchase
	var can_purchase = can_purchase_item(vendor_id, item_id, player_gold)
	if not can_purchase.success:
		result.reason = can_purchase.reason
		return result

	var vendor_item = vendor_inventories[vendor_id][item_id]
	result.cost = vendor_item.current_price

	# Process purchase through ResourceTracker
	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		result.reason = "ResourceTracker not available"
		return result

	if not resource_tracker.spend_gold(result.cost):
		result.reason = "Failed to deduct gold"
		return result

	# Handle eggs specially - hatch them immediately into creatures
	if _is_egg_item(item_id):
		creature_data = _hatch_egg(item_id)
		if not creature_data:
			# Refund gold if hatching failed
			resource_tracker.add_gold(result.cost)
			result.reason = "Failed to hatch egg"
			return result

		# Add creature to collection instead of item to inventory
		var collection = GameCore.get_system("collection")
		if collection:
			if collection.add_to_stable(creature_data):
				print("ShopSystem: Hatched %s into %s (%s)" % [item_id, creature_data.creature_name, creature_data.species_id])
			else:
				# Refund gold if adding to stable failed
				resource_tracker.add_gold(result.cost)
				result.reason = "Failed to add creature to stable"
				return result
		else:
			# Refund gold if collection failed
			resource_tracker.add_gold(result.cost)
			result.reason = "Failed to add creature to collection"
			return result
	else:
		# Add regular item to player inventory
		if not resource_tracker.add_item(item_id, 1):
			# Refund gold if item addition failed
			resource_tracker.add_gold(result.cost)
			result.reason = "Failed to add item to inventory"
			return result

	# Update vendor stock
	vendor_item.quantity -= 1
	vendor_item.in_stock = vendor_item.quantity > 0

	# Record purchase
	_record_purchase(vendor_id, item_id, result.cost)

	# Emit appropriate signals
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		if _is_egg_item(item_id):
			# For eggs, emit a creature acquisition signal instead
			if creature_data:
				signal_bus.creature_acquired.emit(creature_data, "shop_hatch")
		else:
			# For regular items, emit the standard purchase signal
			signal_bus.item_purchased.emit(item_id, 1, vendor_id, result.cost)

	result.success = true
	print("ShopSystem: Purchased 1 x %s from %s for %d gold" % [item_id, vendor_id, result.cost])
	return result

func _is_egg_item(item_id: String) -> bool:
	"""Check if an item is an egg."""
	return item_id.ends_with("_egg")

func _hatch_egg(item_id: String) -> CreatureData:
	"""Hatch an egg into a creature."""
	# Extract species ID from egg ID (remove "_egg" suffix)
	var species_id = item_id.replace("_egg", "")

	# Use CreatureGenerator to create the creature
	var creature_data = CreatureGenerator.generate_creature_data(species_id, GlobalEnums.GenerationType.UNIFORM)
	if not creature_data:
		push_error("ShopSystem: Failed to generate creature from egg %s (species: %s)" % [item_id, species_id])
		return null

	print("ShopSystem: Successfully hatched %s -> %s (%s)" % [item_id, creature_data.creature_name, species_id])
	return creature_data

func _record_purchase(vendor_id: String, item_id: String, cost: int) -> void:
	"""Record a purchase in history."""
	var purchase_record = {
		"vendor_id": vendor_id,
		"item_id": item_id,
		"cost": cost,
		"timestamp": Time.get_ticks_msec()
	}

	purchase_history.append(purchase_record)

	# Limit history size
	if purchase_history.size() > MAX_PURCHASE_HISTORY:
		purchase_history = purchase_history.slice(-MAX_PURCHASE_HISTORY)

# === BACKWARD COMPATIBILITY METHODS ===

func get_category_items(category: String) -> Array:
	"""Get items by category across all unlocked vendors (for backward compatibility)."""
	var result: Array = []
	var unlocked_vendors = get_unlocked_vendors()

	for vendor in unlocked_vendors:
		var inventory = get_vendor_inventory(vendor.vendor_id)
		for item_data in inventory:
			# Convert to old ShopItem format
			var shop_item = _create_legacy_shop_item(item_data)
			if _item_matches_category(shop_item.item_id, category):
				result.append(shop_item)

	return result

func _create_legacy_shop_item(item_data: Dictionary):
	"""Create a legacy ShopItem for backward compatibility."""
	var shop_item = ShopItem.new(
		item_data.item_id,
		item_data.quantity,
		item_data.price,
		_get_item_category(item_data.item_id)
	)
	return shop_item

func _get_item_category(item_id: String) -> String:
	"""Get category for an item."""
	var item_manager = GameCore.get_system("item_manager")
	if item_manager:
		var item_type = item_manager.get_item_type(item_id)
		if item_type == "creature": return "creatures"
		return item_type

	# Fallback categorization
	if "egg" in item_id: return "creatures"
	if item_id in ["grain", "hay", "berries", "water"]: return "food"
	return "consumable"

func _item_matches_category(item_id: String, category: String) -> bool:
	"""Check if item matches category."""
	return _get_item_category(item_id) == category

# Legacy ShopItem class for backward compatibility
class ShopItem:
	var item_id: String
	var quantity: int
	var base_price: int
	var current_price: int
	var category: String
	var in_stock: bool

	func _init(id: String, qty: int, price: int, cat: String) -> void:
		item_id = id
		quantity = qty
		base_price = price
		current_price = price
		category = cat
		in_stock = qty > 0

# === LEGACY METHODS FOR BACKWARD COMPATIBILITY ===

func get_shop_inventory() -> Dictionary:
	"""Legacy method - returns aggregated inventory across all vendors."""
	var legacy_inventory = {}
	for vendor in get_unlocked_vendors():
		var inventory = get_vendor_inventory(vendor.vendor_id)
		for item_data in inventory:
			if not legacy_inventory.has(item_data.item_id):
				legacy_inventory[item_data.item_id] = item_data
			else:
				# Aggregate quantities from multiple vendors
				legacy_inventory[item_data.item_id].quantity += item_data.quantity
	return legacy_inventory

func get_available_items() -> Array:
	"""Legacy method - returns all available items across vendors."""
	var result: Array = []
	for vendor in get_unlocked_vendors():
		var inventory = get_vendor_inventory(vendor.vendor_id)
		for item_data in inventory:
			var shop_item = _create_legacy_shop_item(item_data)
			result.append(shop_item)
	return result

func restock_shop() -> void:
	"""Legacy method - restock all vendors."""
	restock_all_vendors()

func set_discount(rate: float) -> void:
	"""Legacy method - set discount for all vendors (simplified)."""
	# In vendor system, discounts are per-vendor and reputation-based
	# This is a simplified version for backward compatibility
	pass

func get_item_price(item_id: String) -> int:
	"""Legacy method - get price for an item from any unlocked vendor."""
	for vendor in get_unlocked_vendors():
		if vendor_inventories.has(vendor.vendor_id) and vendor_inventories[vendor.vendor_id].has(item_id):
			var vendor_item = vendor_inventories[vendor.vendor_id][item_id]
			return vendor_item.current_price
	return 0

func is_item_available(item_id: String) -> bool:
	"""Legacy method - check if item is available from any unlocked vendor."""
	for vendor in get_unlocked_vendors():
		if vendor_inventories.has(vendor.vendor_id) and vendor_inventories[vendor.vendor_id].has(item_id):
			var vendor_item = vendor_inventories[vendor.vendor_id][item_id]
			if vendor_item.quantity > 0:
				return true
	return false

var discount_rate: float:
	get:
		return 0.0  # Simplified for backward compatibility
	set(value):
		pass  # Ignore discount setting in vendor system

var SHOP_CATEGORIES: Array[String]:
	get:
		return ["food", "equipment", "consumable", "material", "creatures"]

var shop_inventory: Dictionary:
	get:
		return get_shop_inventory()

func purchase_item(item_id: String, quantity: int) -> bool:
	"""Legacy purchase method - finds item across all vendors."""
	if quantity != 1:
		push_error("ShopSystem: Multi-quantity purchases not supported yet")
		return false

	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		return false

	var player_gold = resource_tracker.get_balance()

	# Find item in any unlocked vendor
	for vendor in get_unlocked_vendors():
		var can_purchase = can_purchase_item(vendor.vendor_id, item_id, player_gold)
		if can_purchase.success:
			var result = purchase_item_from_vendor(vendor.vendor_id, item_id, player_gold)
			return result.success

	push_error("ShopSystem: Item '%s' not found in any unlocked vendor" % item_id)
	return false

func calculate_total_cost(item_id: String, quantity: int) -> int:
	"""Legacy cost calculation."""
	for vendor in get_unlocked_vendors():
		if vendor_inventories.has(vendor.vendor_id) and vendor_inventories[vendor.vendor_id].has(item_id):
			var vendor_item = vendor_inventories[vendor.vendor_id][item_id]
			return vendor_item.current_price * quantity

	return 0

func can_afford(item_id: String, quantity: int) -> bool:
	"""Legacy affordability check."""
	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		return false

	var cost = calculate_total_cost(item_id, quantity)
	return resource_tracker.get_balance() >= cost

# === TIME MANAGEMENT ===

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	"""Handle weekly progression."""
	restock_timer -= 1

	if restock_timer <= 0:
		restock_all_vendors()
		restock_timer = DEFAULT_RESTOCK_WEEKS

func restock_vendor(vendor_id: String) -> void:
	"""Restock a specific vendor."""
	if not vendor_inventories.has(vendor_id):
		return

	var vendor_items = vendor_inventories[vendor_id]
	for item_id in vendor_items:
		var vendor_item = vendor_items[item_id]
		vendor_item.quantity = vendor_item.max_quantity
		vendor_item.in_stock = true

	print("ShopSystem: Restocked vendor '%s'" % vendor_id)

func restock_all_vendors() -> void:
	"""Restock all vendors."""
	for vendor_id in vendor_inventories:
		restock_vendor(vendor_id)

	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.shop_refreshed.emit(restock_timer)

	print("ShopSystem: All vendors restocked")

# === SAVE/LOAD ===

func save_state() -> Dictionary:
	"""Save shop state."""
	var vendor_inventory_data = {}
	for vendor_id in vendor_inventories:
		vendor_inventory_data[vendor_id] = {}
		for item_id in vendor_inventories[vendor_id]:
			var item = vendor_inventories[vendor_id][item_id]
			vendor_inventory_data[vendor_id][item_id] = {
				"quantity": item.quantity,
				"current_price": item.current_price
			}

	return {
		"vendor_inventories": vendor_inventory_data,
		"vendor_reputations": vendor_reputations,
		"restock_timer": restock_timer,
		"purchase_history": purchase_history.slice(-20)  # Save last 20 purchases
	}

func load_state(data: Dictionary) -> void:
	"""Load shop state."""
	if data.has("vendor_inventories"):
		var inventory_data = data.vendor_inventories
		for vendor_id in inventory_data:
			if vendor_inventories.has(vendor_id):
				for item_id in inventory_data[vendor_id]:
					if vendor_inventories[vendor_id].has(item_id):
						var item_data = inventory_data[vendor_id][item_id]
						var vendor_item = vendor_inventories[vendor_id][item_id]
						vendor_item.quantity = item_data.get("quantity", vendor_item.quantity)
						vendor_item.current_price = item_data.get("current_price", vendor_item.current_price)
						vendor_item.in_stock = vendor_item.quantity > 0

	vendor_reputations = data.get("vendor_reputations", {})
	restock_timer = data.get("restock_timer", DEFAULT_RESTOCK_WEEKS)
	purchase_history = data.get("purchase_history", [])

	print("ShopSystem loaded: %d vendors with inventories" % vendor_inventories.size())
