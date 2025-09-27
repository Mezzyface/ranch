extends Node
class_name ShopSystem

# ShopSystem - Manages all vendors and shop transactions
# Handles 6 specialized vendors with dynamic inventory management using existing ItemManager

# === CONSTANTS ===
const VENDORS_DATA_PATH: String = "res://data/vendors/"
const FILE_EXTENSION: String = ".tres"

# === VENDOR DATA ===
var vendor_registry: Dictionary = {}  # vendor_id -> VendorResource
var vendor_inventories: Dictionary = {}  # vendor_id -> Dictionary[item_id -> stock_info]
var vendor_unlock_status: Dictionary = {}  # vendor_id -> bool

# === TRANSACTION TRACKING ===
var transaction_history: Array[Dictionary] = []
var weekly_purchase_counts: Dictionary = {}  # item_id -> count_this_week
var vendor_reputation: Dictionary = {}  # vendor_id -> reputation_points

# === CACHING & PERFORMANCE ===
var _price_cache: Dictionary = {}
var _last_restock_week: int = 0

func _init() -> void:
	print("ShopSystem initialized")
	_load_all_vendors()
	_initialize_vendor_inventories()
	_setup_weekly_restock()

func _load_all_vendors() -> void:
	"""Load all vendor resources from data directory."""
	var dir: DirAccess = DirAccess.open(VENDORS_DATA_PATH)
	if not dir:
		push_warning("ShopSystem: Vendors data directory not found: %s" % VENDORS_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(FILE_EXTENSION):
			var vendor_path: String = VENDORS_DATA_PATH + file_name
			_load_vendor_from_file(vendor_path)
		file_name = dir.get_next()

	print("ShopSystem: Loaded %d vendors" % vendor_registry.size())

func _load_vendor_from_file(file_path: String) -> bool:
	"""Load a single vendor from file."""
	var vendor: VendorResource = load(file_path) as VendorResource
	if not vendor:
		push_error("ShopSystem: Failed to load vendor from %s" % file_path)
		return false

	if not vendor.is_valid():
		push_error("ShopSystem: Invalid vendor data in %s" % file_path)
		return false

	vendor_registry[vendor.vendor_id] = vendor
	vendor_unlock_status[vendor.vendor_id] = vendor.is_unlocked_by_default
	vendor_reputation[vendor.vendor_id] = 0
	return true

func _initialize_vendor_inventories() -> void:
	"""Initialize vendor inventories based on their base inventory lists."""
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		push_error("ShopSystem: ItemManager not available")
		return

	for vendor_id in vendor_registry:
		var vendor: VendorResource = vendor_registry[vendor_id]
		var inventory: Dictionary = {}

		for item_id in vendor.base_inventory:
			var item_resource = item_manager.get_item_resource(item_id)
			if item_resource:
				inventory[item_id] = {
					"stock_quantity": int(10 * vendor.inventory_size_multiplier),
					"max_stock": int(15 * vendor.inventory_size_multiplier),
					"restock_rate": 2,
					"base_price": int(item_resource.base_price * vendor.markup_modifier)
				}
			else:
				# For missing items, create placeholder data
				inventory[item_id] = {
					"stock_quantity": int(5 * vendor.inventory_size_multiplier),
					"max_stock": int(10 * vendor.inventory_size_multiplier),
					"restock_rate": 1,
					"base_price": int(100 * vendor.markup_modifier)
				}

		vendor_inventories[vendor_id] = inventory

func _setup_weekly_restock() -> void:
	"""Setup weekly restock system integration with TimeSystem."""
	var time_system = GameCore.get_system("time")
	if time_system:
		_last_restock_week = time_system.current_week

# === PUBLIC API ===

func get_vendor(vendor_id: String) -> VendorResource:
	"""Get vendor resource by ID."""
	return vendor_registry.get(vendor_id, null)

func get_all_vendors() -> Array[VendorResource]:
	"""Get all vendor resources."""
	var vendors: Array[VendorResource] = []
	for vendor in vendor_registry.values():
		vendors.append(vendor)
	return vendors

func get_unlocked_vendors() -> Array[VendorResource]:
	"""Get all unlocked vendors."""
	var unlocked: Array[VendorResource] = []
	for vendor_id in vendor_registry:
		if is_vendor_unlocked(vendor_id):
			var vendor = vendor_registry[vendor_id]
			unlocked.append(vendor)
	return unlocked

func is_vendor_unlocked(vendor_id: String) -> bool:
	"""Check if vendor is unlocked."""
	return vendor_unlock_status.get(vendor_id, false)

func unlock_vendor(vendor_id: String) -> bool:
	"""Unlock a vendor."""
	if vendor_id in vendor_registry:
		vendor_unlock_status[vendor_id] = true
		var bus = GameCore.get_signal_bus()
		if bus and bus.has_signal("vendor_unlocked"):
			bus.emit_signal("vendor_unlocked", vendor_id)
		return true
	return false

func get_vendor_inventory(vendor_id: String) -> Array[Dictionary]:
	"""Get vendor's current inventory as array of item info."""
	var inventory_dict = vendor_inventories.get(vendor_id, {})
	var inventory_array: Array[Dictionary] = []

	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		return inventory_array

	for item_id in inventory_dict:
		var stock_info = inventory_dict[item_id]
		var item_resource = item_manager.get_item_resource(item_id)

		var item_info = {
			"item_id": item_id,
			"display_name": item_resource.display_name if item_resource else item_id,
			"description": item_resource.description if item_resource else "",
			"stock_quantity": stock_info.stock_quantity,
			"base_price": stock_info.base_price,
			"final_price": calculate_item_price(vendor_id, item_id)
		}
		inventory_array.append(item_info)

	return inventory_array

func get_vendor_reputation(vendor_id: String) -> int:
	"""Get reputation with specific vendor."""
	return vendor_reputation.get(vendor_id, 0)

func calculate_item_price(vendor_id: String, item_id: String) -> int:
	"""Calculate final price for item at vendor including reputation discounts."""
	var vendor_inventory = vendor_inventories.get(vendor_id, {})
	var vendor = get_vendor(vendor_id)

	if not vendor or not vendor_inventory.has(item_id):
		return 0

	var stock_info = vendor_inventory[item_id]
	var base_price = stock_info.base_price
	var reputation = get_vendor_reputation(vendor_id)
	var reputation_discount = vendor.get_reputation_discount(reputation)

	var final_price = int(base_price * (100 - reputation_discount) / 100.0)
	return maxi(final_price, 1)

func can_purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary:
	"""Check if player can purchase item. Returns detailed result."""
	var result = {"can_purchase": false, "reason": ""}

	if not is_vendor_unlocked(vendor_id):
		result.reason = "Vendor is locked"
		return result

	var vendor_inventory = vendor_inventories.get(vendor_id, {})
	if not vendor_inventory.has(item_id):
		result.reason = "Item not available at this vendor"
		return result

	var stock_info = vendor_inventory[item_id]
	if stock_info.stock_quantity <= 0:
		result.reason = "Out of stock"
		return result

	var final_price = calculate_item_price(vendor_id, item_id)
	if player_gold < final_price:
		result.reason = "Insufficient funds"
		return result

	result.can_purchase = true
	return result

func purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary:
	"""Attempt to purchase item. Returns transaction result."""
	var _t0: int = Time.get_ticks_msec()

	var result = {"success": false, "gold_spent": 0, "item_received": null, "message": ""}

	var purchase_check = can_purchase_item(vendor_id, item_id, player_gold)
	if not purchase_check.can_purchase:
		result.message = purchase_check.reason
		return result

	var vendor_inventory = vendor_inventories.get(vendor_id, {})
	var stock_info = vendor_inventory[item_id]
	var final_price = calculate_item_price(vendor_id, item_id)

	# Process purchase (ShopSystem only handles shop-side logic)
	stock_info.stock_quantity -= 1
	result.success = true
	result.gold_spent = final_price
	result.item_received = {"item_id": item_id, "quantity": 1}
	result.message = "Purchase successful"

	# Update tracking
	weekly_purchase_counts[item_id] = weekly_purchase_counts.get(item_id, 0) + 1
	_increase_vendor_reputation(vendor_id, 1)

	# Record transaction
	var transaction = {
		"vendor_id": vendor_id,
		"item_id": item_id,
		"price_paid": final_price,
		"timestamp": Time.get_ticks_msec(),
		"week": _get_current_week()
	}
	transaction_history.append(transaction)

	# Emit signals for other systems to handle
	var bus = GameCore.get_signal_bus()
	if bus:
		if bus.has_signal("item_purchased"):
			# Emit comprehensive purchase data
			bus.emit_signal("item_purchased", item_id, 1, vendor_id, final_price)

	var _dt: int = Time.get_ticks_msec() - _t0
	if _dt > 10:  # Log if transaction takes more than 10ms
		print("AI_NOTE: performance(shop_purchase) = %d ms" % _dt)

	return result

func restock_all_vendors() -> void:
	"""Restock all vendor inventories."""
	var _t0: int = Time.get_ticks_msec()

	var current_week = _get_current_week()
	var weeks_passed = current_week - _last_restock_week

	if weeks_passed <= 0:
		return

	for vendor_id in vendor_inventories:
		var inventory = vendor_inventories[vendor_id]
		for item_id in inventory:
			var stock_info = inventory[item_id]
			var new_stock = stock_info.stock_quantity + (stock_info.restock_rate * weeks_passed)
			stock_info.stock_quantity = mini(new_stock, stock_info.max_stock)

	# Reset weekly purchase limits
	weekly_purchase_counts.clear()
	_last_restock_week = current_week

	# Emit restock signal
	var bus = GameCore.get_signal_bus()
	if bus and bus.has_signal("shop_refreshed"):
		bus.emit_signal("shop_refreshed", weeks_passed)

	var _dt: int = Time.get_ticks_msec() - _t0
	print("AI_NOTE: performance(shop_restock) = %d ms (baseline <50ms)" % _dt)

func _increase_vendor_reputation(vendor_id: String, amount: int) -> void:
	"""Increase reputation with vendor."""
	var vendor = get_vendor(vendor_id)
	if not vendor:
		return

	var old_reputation = vendor_reputation.get(vendor_id, 0)
	var new_reputation = mini(old_reputation + amount, vendor.max_reputation)
	vendor_reputation[vendor_id] = new_reputation

func _get_current_week() -> int:
	"""Get current week from TimeSystem."""
	var time_system = GameCore.get_system("time")
	return time_system.current_week if time_system else 0

# === SAVE/LOAD SUPPORT ===

func get_save_data() -> Dictionary:
	"""Get shop system data for saving."""
	return {
		"vendor_unlock_status": vendor_unlock_status.duplicate(),
		"vendor_reputation": vendor_reputation.duplicate(),
		"weekly_purchase_counts": weekly_purchase_counts.duplicate(),
		"last_restock_week": _last_restock_week,
		"transaction_history": transaction_history.duplicate(),
		"vendor_inventories": vendor_inventories.duplicate(true)  # Deep duplicate for nested dictionaries
	}

func load_save_data(data: Dictionary) -> void:
	"""Load shop system data from save."""
	# Clear existing data first
	vendor_unlock_status.clear()
	vendor_reputation.clear()
	weekly_purchase_counts.clear()
	transaction_history.clear()
	vendor_inventories.clear()

	# Load the saved data
	var saved_unlocks = data.get("vendor_unlock_status", {})
	for vendor_id in saved_unlocks:
		vendor_unlock_status[vendor_id] = saved_unlocks[vendor_id]

	var saved_reputation = data.get("vendor_reputation", {})
	for vendor_id in saved_reputation:
		vendor_reputation[vendor_id] = saved_reputation[vendor_id]

	var saved_purchases = data.get("weekly_purchase_counts", {})
	for item_id in saved_purchases:
		weekly_purchase_counts[item_id] = saved_purchases[item_id]

	var saved_transactions = data.get("transaction_history", [])
	for transaction in saved_transactions:
		transaction_history.append(transaction)

	var saved_inventories = data.get("vendor_inventories", {})
	for vendor_id in saved_inventories:
		vendor_inventories[vendor_id] = saved_inventories[vendor_id]

	_last_restock_week = data.get("last_restock_week", 0)

# === STATISTICS ===

func get_shop_statistics() -> Dictionary:
	"""Get shop system statistics."""
	return {
		"total_vendors": vendor_registry.size(),
		"unlocked_vendors": vendor_unlock_status.values().count(true),
		"total_transactions": transaction_history.size(),
		"weekly_purchases": weekly_purchase_counts.size()
	}