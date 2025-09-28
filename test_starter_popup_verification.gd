extends Node

func _ready() -> void:
	print("=== STARTER POPUP VERIFICATION TEST ===")

	# Test that starter popup gives 100g
	var resource_tracker = GameCore.get_system("resource")
	print("Gold before popup: %d" % resource_tracker.get_balance())

	# Create starter popup controller and trigger it
	var popup_controller = preload("res://scripts/ui/starter_popup_controller.gd").new()
	popup_controller._give_starter_items()

	print("Gold after popup: %d" % resource_tracker.get_balance())

	if resource_tracker.get_balance() == 500:
		print("✅ Starter popup correctly gives 500 gold")
	else:
		print("❌ Starter popup gives wrong amount: %d (expected 500)" % resource_tracker.get_balance())

	print("=== TEST COMPLETED ===")
	get_tree().quit()