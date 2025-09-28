extends Node

func _ready() -> void:
	print("=== Testing Gold Signal Flow ===")
	test_gold_signal_flow()
	get_tree().quit()

func test_gold_signal_flow() -> void:
	# Get systems
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")
	var signal_bus = GameCore.get_signal_bus()

	print("Initial gold: %d" % resource_tracker.get_balance())

	# Set up signal monitoring
	var gold_changed_received = false
	var gold_spent_received = false

	signal_bus.gold_changed.connect(func(old_amount, new_amount, change):
		print("Signal received: gold_changed from %d to %d (change: %d)" % [old_amount, new_amount, change])
		gold_changed_received = true
	)

	signal_bus.gold_spent.connect(func(amount, purpose):
		print("Signal received: gold_spent %d for %s" % [amount, purpose])
		gold_spent_received = true
	)

	# Test purchase
	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		print("Attempting to purchase: %s for %d gold" % [test_item.item_id, shop_system.get_item_price(test_item.item_id)])

		var success = shop_system.purchase_item(test_item.item_id, 1)
		print("Purchase success: %s" % success)
		print("Final gold: %d" % resource_tracker.get_balance())
		print("Gold changed signal received: %s" % gold_changed_received)
		print("Gold spent signal received: %s" % gold_spent_received)
	else:
		print("No items available for testing")

	print("=== Test Complete ===")