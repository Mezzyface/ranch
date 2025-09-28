extends Node

func _ready() -> void:
	print("=== Testing Overlay Menu Gold Update ===")

	# Wait a frame for everything to initialize
	await get_tree().process_frame

	test_overlay_gold_update()
	get_tree().quit()

func test_overlay_gold_update() -> void:
	# Get systems
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")
	var ui_manager = GameCore.get_system("ui")
	var signal_bus = GameCore.get_signal_bus()

	print("Initial setup:")
	print("- Shop system loaded: %s" % (shop_system != null))
	print("- Resource tracker loaded: %s" % (resource_tracker != null))
	print("- UI manager loaded: %s" % (ui_manager != null))
	print("- Signal bus loaded: %s" % (signal_bus != null))

	if not shop_system or not resource_tracker:
		print("ERROR: Required systems not loaded")
		return

	print("Initial gold: %d" % resource_tracker.get_balance())

	# Monitor gold_changed signal
	var signal_count = 0
	signal_bus.gold_changed.connect(func(old_amount, new_amount, change):
		signal_count += 1
		print("Gold change signal #%d: %d -> %d (change: %d)" % [signal_count, old_amount, new_amount, change])
	)

	# Test multiple purchases to see the signal pattern
	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_price = shop_system.get_item_price(test_item.item_id)

		print("\nTesting purchase of %s (price: %d)" % [test_item.item_id, item_price])

		# Make purchase
		var success = shop_system.purchase_item(test_item.item_id, 1)
		print("Purchase result: %s" % success)
		print("Gold after purchase: %d" % resource_tracker.get_balance())
		print("Total signals received: %d" % signal_count)

		# Test second purchase
		if shop_system.is_item_available(test_item.item_id, 1):
			print("\nSecond purchase test:")
			var success2 = shop_system.purchase_item(test_item.item_id, 1)
			print("Second purchase result: %s" % success2)
			print("Gold after second purchase: %d" % resource_tracker.get_balance())
			print("Total signals received: %d" % signal_count)

	print("\n=== Test Complete ===")