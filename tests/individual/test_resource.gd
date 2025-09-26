extends Node

const ItemDatabaseScript = preload("res://scripts/data/item_database.gd")

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== Resource Tracker Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var resource_system = GameCore.get_system("resource")
	if not resource_system:
		print("❌ Resource system failed to load")
		details.append("Resource system not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ Resource system loaded successfully")

	# Test 2: Gold Management
	var initial_gold: int = resource_system.get_balance()
	if not resource_system.add_gold(100, "test") or resource_system.gold != initial_gold + 100:
		print("❌ Gold addition failed")
		details.append("Gold addition failed")
		success = false
	else:
		print("✅ Gold addition works (added 100 gold)")

	if not resource_system.spend_gold(50, "test") or resource_system.gold != initial_gold + 50:
		print("❌ Gold spending failed")
		details.append("Gold spending failed")
		success = false
	else:
		print("✅ Gold spending works (spent 50 gold)")

	if resource_system.spend_gold(99999, "test"):
		print("❌ Overspend protection failed (allowed spending more than available)")
		details.append("Overspend allowed")
		success = false
	else:
		print("✅ Overspend protection works")

	# Test 3: Item Management
	if not resource_system.add_item("grain", 5) or resource_system.get_item_count("grain") != 5:
		print("❌ Item addition failed (grain)")
		details.append("Item add failed")
		success = false
	else:
		print("✅ Item addition works (added 5 grain)")

	if not resource_system.remove_item("grain", 2) or resource_system.get_item_count("grain") != 3:
		print("❌ Item removal failed (grain)")
		details.append("Item remove failed")
		success = false
	else:
		print("✅ Item removal works (removed 2 grain, 3 remaining)")

	if resource_system.add_item("invalid_item", 1):
		print("❌ Invalid item validation failed (allowed adding invalid_item)")
		details.append("Invalid item added")
		success = false
	else:
		print("✅ Invalid item validation works")

	if resource_system.remove_item("nonexistent", 1):
		print("❌ Nonexistent item validation failed (allowed removing nonexistent)")
		details.append("Removed nonexistent item")
		success = false
	else:
		print("✅ Nonexistent item validation works")

	# Test 4: Item Database Validation
	if not ItemDatabaseScript.is_valid_item("grain") or ItemDatabaseScript.is_valid_item("fake_item"):
		print("❌ ItemDatabase validation failed")
		details.append("ItemDatabase validation failed")
		success = false
	else:
		print("✅ ItemDatabase validation works correctly")

	# Test 5: Creature Feeding
	resource_system.add_item("berries", 3)
	if not resource_system.feed_creature("test_creature_123", "berries") or resource_system.get_item_count("berries") != 2:
		print("❌ Creature feeding failed")
		details.append("Feeding failed")
		success = false
	else:
		print("✅ Creature feeding works (fed berries, 2 remaining)")

	# Test 6: Economic Statistics
	var stats: Dictionary = resource_system.get_economic_stats()
	var stats_failed := false
	for key in ["current_gold","total_earned","total_spent","inventory_items"]:
		if not stats.has(key):
			print("❌ Economic stats missing key: %s" % key)
			details.append("Stats missing %s" % key)
			success = false
			stats_failed = true
	if not stats_failed:
		print("✅ Economic statistics complete")

	# Test 7: State Save/Load
	var saved_state: Dictionary = resource_system.save_state()
	var saved_gold: int = saved_state.get("gold", 0)
	var saved_inventory: Dictionary = saved_state.get("inventory", {})
	resource_system.gold = 999
	resource_system.inventory.clear()
	resource_system.load_state(saved_state)
	if resource_system.gold != saved_gold or resource_system.inventory.size() != saved_inventory.size():
		print("❌ State save/load failed (gold: %d vs %d, inventory: %d vs %d)" % [resource_system.gold, saved_gold, resource_system.inventory.size(), saved_inventory.size()])
		details.append("Restore failed")
		success = false
	else:
		print("✅ State save/load works correctly")

	# Test 8: Transaction History
	var history: Array[Dictionary] = resource_system.get_transaction_history()
	if history.size() == 0:
		print("❌ Transaction history empty")
		details.append("History empty")
		success = false
	else:
		var h0 := history[0]
		var history_failed := false
		for hk in ["type","amount","timestamp"]:
			if not h0.has(hk):
				print("❌ Transaction history missing key: %s" % hk)
				details.append("History missing %s" % hk)
				success = false
				history_failed = true
		if not history_failed:
			print("✅ Transaction history works (%d transactions recorded)" % history.size())

	# Test 9: Affordability Check
	if not resource_system.can_afford(10) or resource_system.can_afford(999999):
		print("❌ Affordability check failed")
		details.append("Affordability failed")
		success = false
	else:
		print("✅ Affordability check works correctly")

	# Test 10: Stack Size Management
	var add_amount: int = min(250, resource_system.max_stack_size)
	resource_system.add_item("water", add_amount)
	if resource_system.get_item_count("water") != add_amount:
		print("❌ Stack size management failed: expected %d got %d" % [add_amount, resource_system.get_item_count("water")])
		details.append("Water add mismatch expected %d got %d" % [add_amount, resource_system.get_item_count("water")])
		success = false
	else:
		print("✅ Stack size management works (added %d water)" % add_amount)

	# Final summary
	if success:
		print("\n✅ All Resource Tracker tests passed!")
	else:
		print("\n❌ Some Resource Tracker tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()