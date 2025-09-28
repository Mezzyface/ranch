extends Node

func _ready() -> void:
	print("=== STARTER CREATURE COLLECTION TEST ===")

	var collection_system = GameCore.get_system("collection")
	var resource_tracker = GameCore.get_system("resource")

	print("Initial state:")
	print("  Active creatures: %d" % collection_system.get_active_creatures().size())
	print("  Total collection: %d" % collection_system.get_all_creatures().size())
	print("  Gold: %d" % resource_tracker.get_balance())

	# Simulate starter popup giving resources
	print("\nSimulating starter popup...")
	var popup_controller = preload("res://scripts/ui/starter_popup_controller.gd").new()
	# Initialize the popup properly
	popup_controller._setup_starter_data()
	popup_controller._give_starter_items()

	print("\nAfter starter popup:")
	print("  Active creatures: %d" % collection_system.get_active_creatures().size())
	print("  Total collection: %d" % collection_system.get_all_creatures().size())
	print("  Gold: %d" % resource_tracker.get_balance())

	# Check if creature was added to total collection
	var all_creatures = collection_system.get_all_creatures()
	if all_creatures.size() > 0:
		var creature = all_creatures[0]
		print("  First creature: %s (%s, Age: %d)" % [
			creature.creature_name,
			creature.species_id,
			creature.age_weeks
		])
		print("✅ Starter creature successfully added to collection")
	else:
		print("❌ No starter creature found in collection")

	print("\n=== TEST COMPLETED ===")
	get_tree().quit()
