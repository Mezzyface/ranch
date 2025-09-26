extends Node

func _ready() -> void:
	print("=== Resource Tracker Test ===")

	var resource_system = GameCore.get_system("resource")
	assert(resource_system != null, "Failed to load ResourceTracker")

	# Test 1: Gold operations
	var initial_gold: int = resource_system.get_balance()
	print("Initial gold: %d" % initial_gold)

	assert(resource_system.add_gold(100, "test"), "Failed to add gold")
	assert(resource_system.gold == initial_gold + 100, "Gold not added correctly")
	print("✅ Gold addition working")

	assert(resource_system.spend_gold(50, "test"), "Failed to spend gold")
	assert(resource_system.gold == initial_gold + 50, "Gold not spent correctly")
	print("✅ Gold spending working")

	assert(not resource_system.spend_gold(99999, "test"), "Should fail with insufficient gold")
	print("✅ Insufficient gold check working")

	# Test 2: Inventory operations
	assert(resource_system.add_item("grain", 5), "Failed to add item")
	assert(resource_system.get_item_count("grain") == 5, "Item count incorrect")
	print("✅ Item addition working")

	assert(resource_system.remove_item("grain", 2), "Failed to remove item")
	assert(resource_system.get_item_count("grain") == 3, "Item removal incorrect")
	print("✅ Item removal working")

	# Test 3: Invalid operations
	assert(not resource_system.add_item("invalid_item", 1), "Should fail with invalid item")
	print("✅ Invalid item validation working")

	assert(not resource_system.remove_item("nonexistent", 1), "Should fail with nonexistent item")
	print("✅ Nonexistent item check working")

	# Test 4: Item database validation
	assert(ItemDatabase.is_valid_item("grain"), "Grain should be valid")
	assert(not ItemDatabase.is_valid_item("fake_item"), "Fake item should be invalid")
	print("✅ ItemDatabase validation working")

	# Test 5: Food operations
	assert(resource_system.add_item("berries", 3), "Failed to add berries")
	var creature_id: String = "test_creature_123"
	assert(resource_system.feed_creature(creature_id, "berries"), "Failed to feed creature")
	assert(resource_system.get_item_count("berries") == 2, "Food not consumed correctly")
	print("✅ Creature feeding working")

	# Test 6: Economic stats
	var stats: Dictionary = resource_system.get_economic_stats()
	assert(stats.has("current_gold"), "Stats missing current_gold")
	assert(stats.has("total_earned"), "Stats missing total_earned")
	assert(stats.has("total_spent"), "Stats missing total_spent")
	assert(stats.has("inventory_items"), "Stats missing inventory_items")
	print("✅ Economic stats working")

	# Test 7: Save/Load
	var saved_state: Dictionary = resource_system.save_state()
	var saved_gold: int = saved_state.get("gold", 0)
	var saved_inventory: Dictionary = saved_state.get("inventory", {})

	# Modify state
	resource_system.gold = 999
	resource_system.inventory.clear()

	# Restore state
	resource_system.load_state(saved_state)
	assert(resource_system.gold == saved_gold, "Gold not restored correctly")
	assert(resource_system.inventory.size() == saved_inventory.size(), "Inventory not restored correctly")
	print("✅ Save/Load working")

	# Test 8: Transaction history
	var history: Array[Dictionary] = resource_system.get_transaction_history()
	assert(history.size() > 0, "Transaction history should have entries")
	assert(history[0].has("type"), "Transaction missing type")
	assert(history[0].has("amount"), "Transaction missing amount")
	assert(history[0].has("timestamp"), "Transaction missing timestamp")
	print("✅ Transaction history working")

	# Test 9: Affordability checks
	assert(resource_system.can_afford(10), "Should be able to afford 10 gold")
	assert(not resource_system.can_afford(999999), "Should not be able to afford 999999 gold")
	print("✅ Affordability checks working")

	# Test 10: Stack limits
	resource_system.add_item("water", 1000)  # Should cap at max_stack_size
	assert(resource_system.get_item_count("water") == resource_system.max_stack_size, "Stack limit not enforced")
	print("✅ Stack limits working")

	print("✅ Resource Tracker test complete!")
	get_tree().quit(0)