extends Node

var main_controller
var current_ui: Control

func _ready() -> void:
	print("=== Testing Full UI Flow with Shop Purchase ===")

	# Wait for initialization
	await get_tree().process_frame

	test_ui_flow()

	# Keep running a bit longer to see results
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func test_ui_flow() -> void:
	# Simulate the normal game flow
	print("1. Setting up main controller...")
	main_controller = load("res://scripts/controllers/main_controller.gd").new()
	add_child(main_controller)

	# Wait for initialization
	await get_tree().process_frame

	print("2. Loading game UI (overlay menu)...")
	# Load the game UI directly (which should be overlay_menu.tscn)
	if main_controller.has_method("change_ui_scene"):
		main_controller.change_ui_scene("res://scenes/ui/overlay_menu.tscn")

	# Wait for UI to load
	await get_tree().process_frame
	await get_tree().process_frame

	print("3. UI loaded, checking systems...")
	var shop_system = GameCore.get_system("shop")
	var resource_tracker = GameCore.get_system("resource")

	print("- Shop system: %s" % (shop_system != null))
	print("- Resource tracker: %s" % (resource_tracker != null))
	print("- Initial gold: %d" % resource_tracker.get_balance())

	print("4. Making shop purchase...")
	var available_items = shop_system.get_available_items()
	if available_items.size() > 0:
		var test_item = available_items[0]
		var item_price = shop_system.get_item_price(test_item.item_id)

		print("Purchasing: %s for %d gold" % [test_item.item_id, item_price])
		var success = shop_system.purchase_item(test_item.item_id, 1)
		print("Purchase result: %s" % success)
		print("Gold after purchase: %d" % resource_tracker.get_balance())

		# Wait for UI updates
		await get_tree().process_frame

	print("5. Test complete")

func _input(event):
	# Exit on any key press
	if event.is_pressed():
		get_tree().quit()