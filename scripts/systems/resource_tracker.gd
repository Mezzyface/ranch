extends Node
class_name ResourceTracker

# Currency tracking
var gold: int = 500  # Starting gold from design doc
var transaction_history: Array[Dictionary] = []
var total_earned: int = 500
var total_spent: int = 0

# Inventory tracking
var inventory: Dictionary = {}  # item_id -> quantity
var max_stack_size: int = 999

# Food categories from design
enum FoodType {
	BASIC,      # Grain, Hay, Berries, Water
	TRAINING,   # Protein Mix, Endurance Blend, etc.
	PREMIUM,    # Golden Nectar, Vitality Elixir
	SPECIALTY   # Breeding Supplements, Combat Rations
}

func _init() -> void:
	print("ResourceTracker initialized with %d starting gold" % gold)

# Currency management
func add_gold(amount: int, source: String = "unknown") -> bool:
	if amount <= 0:
		push_error("Cannot add negative or zero gold")
		return false

	var old_gold: int = gold
	gold += amount
	total_earned += amount

	# Log transaction
	transaction_history.append({
		"type": "income",
		"amount": amount,
		"source": source,
		"timestamp": Time.get_ticks_msec(),
		"balance": gold
	})

	# Emit signal through SignalBus
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.emit_gold_changed(old_gold, gold, amount)

	return true

func spend_gold(amount: int, purpose: String = "unknown") -> bool:
	if amount <= 0:
		push_error("Cannot spend negative or zero gold")
		return false

	if gold < amount:
		push_error("Insufficient gold: have %d, need %d" % [gold, amount])
		var signal_bus = GameCore.get_signal_bus()
		if signal_bus:
			signal_bus.emit_transaction_failed("insufficient_gold", amount)
		return false

	var old_gold: int = gold
	gold -= amount
	total_spent += amount

	# Log transaction
	transaction_history.append({
		"type": "expense",
		"amount": amount,
		"purpose": purpose,
		"timestamp": Time.get_ticks_msec(),
		"balance": gold
	})

	# Emit signal
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.emit_gold_changed(old_gold, gold, -amount)

	return true

func can_afford(cost: int) -> bool:
	return gold >= cost

func get_balance() -> int:
	return gold

# Inventory management
func add_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		push_error("Cannot add negative or zero quantity")
		return false

	var item_manager = GameCore.get_system("item_manager")
	if not item_manager or not item_manager.is_valid_item(item_id):
		push_error("Invalid item ID: %s" % item_id)
		return false

	if item_id in inventory:
		inventory[item_id] = min(inventory[item_id] + quantity, max_stack_size)
	else:
		inventory[item_id] = min(quantity, max_stack_size)

	# Emit signal
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.emit_item_added(item_id, quantity, inventory[item_id])

	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		push_error("Cannot remove negative or zero quantity")
		return false

	if not item_id in inventory:
		push_error("Item not in inventory: %s" % item_id)
		return false

	if inventory[item_id] < quantity:
		push_error("Insufficient quantity: have %d, need %d" % [inventory[item_id], quantity])
		return false

	inventory[item_id] -= quantity
	if inventory[item_id] == 0:
		inventory.erase(item_id)

	# Emit signal
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.emit_item_removed(item_id, quantity, inventory.get(item_id, 0))

	return true

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity

func get_inventory() -> Dictionary:
	return inventory.duplicate()

# Food management
func feed_creature(creature_id: String, food_id: String) -> bool:
	if not has_item(food_id, 1):
		push_error("No %s in inventory" % food_id)
		return false

	var item_manager = GameCore.get_system("item_manager")
	var item_resource: ItemResource = item_manager.get_item_resource(food_id) if item_manager else null
	if not item_resource or item_resource.item_type != GlobalEnums.ItemType.FOOD:
		push_error("Item %s is not food" % food_id)
		return false

	# Remove food from inventory
	if not remove_item(food_id, 1):
		return false

	# Emit feeding signal for other systems to handle effects
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		# Convert ItemResource to legacy format for signal compatibility
		var food_data = item_manager.get_item_data(food_id)
		signal_bus.emit_creature_fed(creature_id, food_id, food_data)

	return true

# Transaction management
func get_transaction_history() -> Array[Dictionary]:
	return transaction_history.duplicate()

func get_economic_stats() -> Dictionary:
	return {
		"current_gold": gold,
		"total_earned": total_earned,
		"total_spent": total_spent,
		"net_worth": total_earned - total_spent,
		"transaction_count": transaction_history.size(),
		"inventory_items": inventory.size()
	}

# Save/Load integration
func save_state() -> Dictionary:
	return {
		"gold": gold,
		"inventory": inventory,
		"total_earned": total_earned,
		"total_spent": total_spent,
		"transaction_history": transaction_history.slice(max(0, transaction_history.size() - 100))  # Last 100 transactions
	}

func load_state(data: Dictionary) -> void:
	gold = data.get("gold", 500)
	inventory = data.get("inventory", {})
	total_earned = data.get("total_earned", gold)
	total_spent = data.get("total_spent", 0)
	transaction_history = data.get("transaction_history", [])

	print("ResourceTracker loaded: %d gold, %d items" % [gold, inventory.size()])