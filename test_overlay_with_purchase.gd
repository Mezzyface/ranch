extends Node

func _ready() -> void:
	print("=== Testing Overlay Menu with Purchase ===")

	# Wait for initialization
	await get_tree().process_frame
	await get_tree().process_frame

	test_overlay_with_purchase()
	get_tree().quit()

func test_overlay_with_purchase() -> void:
	# Load the overlay menu scene like the main game does
	var overlay_scene = load("res://scenes/ui/overlay_menu.tscn")
	if not overlay_scene:
		print("ERROR: Could not load overlay menu scene")
		return

	var overlay_instance = overlay_scene.instantiate()
	add_child(overlay_instance)

	# Wait for overlay to initialize
	await get_tree().process_frame

	# Get systems
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")
	var signal_bus = GameCore.get_signal_bus()

	print("Systems loaded:")
	print("- Shop: %s" % (shop_system != null))
	print("- ResourceTracker: %s" % (resource_tracker != null))
	print("- SignalBus: %s" % (signal_bus != null))
	print("- Overlay instance: %s" % (overlay_instance != null))

	# Check if overlay has the gold label
	var gold_label = overlay_instance.get_node_or_null("VBoxContainer/Panel/MarginContainer/Gold")
	print("- Gold label found: %s" % (gold_label != null))
	if gold_label:
		print("- Initial gold display: '%s'" % gold_label.text)

	print("Initial gold: %d" % resource_tracker.get_balance())

	# Make a purchase and check if overlay updates
	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_price = shop_system.get_item_price(test_item.item_id)

		print("Making purchase: %s for %d gold" % [test_item.item_id, item_price])

		var success = shop_system.purchase_item(test_item.item_id, 1)
		print("Purchase success: %s" % success)
		print("Gold after purchase: %d" % resource_tracker.get_balance())

		# Wait a frame for UI to update
		await get_tree().process_frame

		if gold_label:
			print("Gold display after purchase: '%s'" % gold_label.text)

	print("=== Test Complete ===")