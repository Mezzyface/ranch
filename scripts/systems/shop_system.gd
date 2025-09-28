extends Node
class_name ShopSystem

# Shop system for creature management game
# Manages item inventory, pricing, and purchasing

# === PROPERTIES ===
var shop_inventory: Dictionary = {}  # category -> Array[ShopItem]
var restock_timer: int = 1  # weeks until restock
var discount_rate: float = 0.0  # current sale percentage (0.0 - 1.0)
var purchase_history: Array[String] = []  # item IDs purchased

# === CONSTANTS ===
const MAX_PURCHASE_HISTORY: int = 100
const DEFAULT_RESTOCK_WEEKS: int = 4
const SHOP_CATEGORIES: Array[String] = ["food", "equipment", "consumable", "material"]

# === SHOP ITEM DATA STRUCTURE ===
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

func _ready() -> void:
	print("ShopSystem initialized")
	_initialize_shop()
	_connect_signals()

func _initialize_shop() -> void:
	"""Initialize shop with default inventory."""
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		push_error("ShopSystem: ItemManager required but not loaded")
		return

	# Initialize categories
	for category in SHOP_CATEGORIES:
		shop_inventory[category] = []

	# Load initial inventory from ItemManager
	_stock_initial_inventory()

	print("ShopSystem: Shop initialized with %d categories" % shop_inventory.size())

func _connect_signals() -> void:
	"""Connect to relevant signals."""
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		# Connect to time progression for restocking
		if signal_bus.has_signal("week_advanced"):
			signal_bus.week_advanced.connect(_on_week_advanced)

func _stock_initial_inventory() -> void:
	"""Stock initial inventory with items from ItemManager."""
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		return

	# Stock basic food items
	_add_shop_item("grain", 20, 5, "food")
	_add_shop_item("hay", 15, 8, "food")
	_add_shop_item("berries", 10, 12, "food")
	_add_shop_item("water", 25, 3, "food")

	# Stock some consumables if they exist
	var all_items = item_manager.get_all_item_resources()
	for item_resource in all_items:
		# Use string comparison for now to avoid GlobalEnums dependency
		var item_type_str = item_manager.get_item_type(item_resource.item_id)
		if item_type_str == "consumable":
			_add_shop_item(item_resource.item_id, 5, item_resource.base_price, "consumable")
		elif item_type_str == "material":
			_add_shop_item(item_resource.item_id, 3, item_resource.base_price, "material")

func _add_shop_item(item_id: String, quantity: int, price: int, category: String) -> void:
	"""Add an item to shop inventory."""
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager or not item_manager.is_valid_item(item_id):
		# Create basic shop item even if not in ItemManager (for basic foods)
		pass

	if not shop_inventory.has(category):
		shop_inventory[category] = []

	var shop_item = ShopItem.new(item_id, quantity, price, category)
	shop_inventory[category].append(shop_item)

# === CORE METHODS ===

func purchase_item(item_id: String, quantity: int) -> bool:
	"""Purchase an item from the shop."""
	if quantity <= 0:
		push_error("ShopSystem: Cannot purchase negative or zero quantity")
		return false

	var shop_item = _find_shop_item(item_id)
	if not shop_item:
		push_error("ShopSystem: Item not found in shop: %s" % item_id)
		return false

	if not shop_item.in_stock or shop_item.quantity < quantity:
		push_error("ShopSystem: Insufficient stock for %s (have %d, need %d)" % [item_id, shop_item.quantity, quantity])
		return false

	var total_cost = calculate_total_cost(item_id, quantity)
	if not can_afford(item_id, quantity):
		push_error("ShopSystem: Cannot afford %d x %s (cost: %d)" % [quantity, item_id, total_cost])
		return false

	# Process the purchase
	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		push_error("ShopSystem: ResourceTracker required but not loaded")
		return false

	# Deduct from shop inventory
	shop_item.quantity -= quantity
	if shop_item.quantity <= 0:
		shop_item.in_stock = false

	# Add to purchase history
	for i in quantity:
		purchase_history.append(item_id)
		if purchase_history.size() > MAX_PURCHASE_HISTORY:
			purchase_history.pop_front()

	# Emit purchase signal for ResourceTracker to handle payment and inventory
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.item_purchased.emit(item_id, quantity, "shop", total_cost)

	print("ShopSystem: Purchased %d x %s for %d gold" % [quantity, item_id, total_cost])
	return true

func can_afford(item_id: String, quantity: int) -> bool:
	"""Check if player can afford the purchase."""
	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		return false

	var total_cost = calculate_total_cost(item_id, quantity)
	return resource_tracker.can_afford(total_cost)

func calculate_total_cost(item_id: String, quantity: int) -> int:
	"""Calculate total cost including discounts."""
	var shop_item = _find_shop_item(item_id)
	if not shop_item:
		return 0

	var base_cost = shop_item.current_price * quantity
	var discount_amount = int(base_cost * discount_rate)
	return base_cost - discount_amount

func is_item_available(item_id: String, quantity: int = 1) -> bool:
	"""Check if item is available in sufficient quantity."""
	var shop_item = _find_shop_item(item_id)
	if not shop_item:
		return false

	return shop_item.in_stock and shop_item.quantity >= quantity

func get_item_price(item_id: String) -> int:
	"""Get current price for an item."""
	var shop_item = _find_shop_item(item_id)
	if not shop_item:
		return 0

	var discounted_price = int(shop_item.current_price * (1.0 - discount_rate))
	return discounted_price

func get_item_stock(item_id: String) -> int:
	"""Get current stock quantity for an item."""
	var shop_item = _find_shop_item(item_id)
	return shop_item.quantity if shop_item else 0

# === SHOP MANAGEMENT ===

func set_discount(discount_percentage: float) -> void:
	"""Set shop-wide discount percentage."""
	discount_rate = clamp(discount_percentage, 0.0, 1.0)
	print("ShopSystem: Discount set to %.1f%%" % (discount_rate * 100))

func restock_shop() -> void:
	"""Restock the shop inventory."""
	print("ShopSystem: Restocking shop...")

	# Restock existing items
	for category in shop_inventory:
		for shop_item in shop_inventory[category]:
			var restock_amount = _calculate_restock_amount(shop_item)
			shop_item.quantity += restock_amount
			shop_item.in_stock = shop_item.quantity > 0

	# Reset restock timer
	restock_timer = DEFAULT_RESTOCK_WEEKS

	# Emit restock signal
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.shop_refreshed.emit(DEFAULT_RESTOCK_WEEKS)

	print("ShopSystem: Shop restocked")

func _calculate_restock_amount(shop_item: ShopItem) -> int:
	"""Calculate how much to restock for an item."""
	# Basic restocking logic - could be enhanced with demand tracking
	match shop_item.category:
		"food":
			return 15  # Food restocks generously
		"consumable":
			return 5   # Consumables restock moderately
		"material":
			return 3   # Materials restock sparingly
		"equipment":
			return 2   # Equipment restocks rarely
		_:
			return 5

# === INVENTORY QUERIES ===

func get_shop_inventory() -> Dictionary:
	"""Get current shop inventory."""
	return shop_inventory.duplicate()

func get_category_items(category: String) -> Array[ShopItem]:
	"""Get all items in a category."""
	var items: Array[ShopItem] = []
	var category_data = shop_inventory.get(category, [])
	for item in category_data:
		items.append(item)
	return items

func get_available_items() -> Array[ShopItem]:
	"""Get all currently available items."""
	var available: Array[ShopItem] = []

	for category in shop_inventory:
		for shop_item in shop_inventory[category]:
			if shop_item.in_stock:
				available.append(shop_item)

	return available

func get_purchase_statistics() -> Dictionary:
	"""Get purchase statistics."""
	var stats = {}
	for item_id in purchase_history:
		stats[item_id] = stats.get(item_id, 0) + 1

	return {
		"total_purchases": purchase_history.size(),
		"unique_items": stats.size(),
		"items_purchased": stats,
		"restock_timer": restock_timer,
		"current_discount": discount_rate
	}

# === SIGNAL HANDLERS ===

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	"""Handle weekly progression for restocking."""
	restock_timer -= 1

	if restock_timer <= 0:
		restock_shop()

	print("ShopSystem: Week %d, restock in %d weeks" % [new_week, restock_timer])

# === HELPER METHODS ===

func _find_shop_item(item_id: String) -> ShopItem:
	"""Find a shop item by ID."""
	for category in shop_inventory:
		for shop_item in shop_inventory[category]:
			if shop_item.item_id == item_id:
				return shop_item
	return null

# === SAVE/LOAD ===

func save_state() -> Dictionary:
	"""Save shop state."""
	var inventory_data = {}
	for category in shop_inventory:
		inventory_data[category] = []
		for shop_item in shop_inventory[category]:
			inventory_data[category].append({
				"item_id": shop_item.item_id,
				"quantity": shop_item.quantity,
				"base_price": shop_item.base_price,
				"current_price": shop_item.current_price,
				"category": shop_item.category,
				"in_stock": shop_item.in_stock
			})

	return {
		"shop_inventory": inventory_data,
		"restock_timer": restock_timer,
		"discount_rate": discount_rate,
		"purchase_history": purchase_history.slice(max(0, purchase_history.size() - MAX_PURCHASE_HISTORY))
	}

func load_state(data: Dictionary) -> void:
	"""Load shop state."""
	restock_timer = data.get("restock_timer", DEFAULT_RESTOCK_WEEKS)
	discount_rate = data.get("discount_rate", 0.0)
	purchase_history = data.get("purchase_history", [])

	var inventory_data = data.get("shop_inventory", {})
	shop_inventory.clear()

	for category in inventory_data:
		shop_inventory[category] = []
		for item_data in inventory_data[category]:
			var shop_item = ShopItem.new(
				item_data.get("item_id", ""),
				item_data.get("quantity", 0),
				item_data.get("base_price", 0),
				item_data.get("category", "")
			)
			shop_item.current_price = item_data.get("current_price", shop_item.base_price)
			shop_item.in_stock = item_data.get("in_stock", shop_item.quantity > 0)
			shop_inventory[category].append(shop_item)

	print("ShopSystem loaded: %d categories, %d purchase history" % [shop_inventory.size(), purchase_history.size()])
