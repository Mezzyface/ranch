extends Node

func _ready() -> void:
	print("=== SIMPLE NEW GAME TEST ===")

	# Clean up any existing save
	var save_system = GameCore.get_system("save")
	if save_system and save_system._validate_slot_exists("default"):
		save_system.delete_save_slot("default")

	# Create game controller and check new game detection
	var game_controller = GameController.new()
	game_controller._setup_systems()

	print("Has existing save: %s" % game_controller.has_existing_save("default"))

	# Initialize new game
	print("Initializing new game...")
	var success = game_controller.initialize_new_game()
	print("New game initialization success: %s" % success)

	# Check results
	var resource_tracker = GameCore.get_system("resource")
	var collection_system = GameCore.get_system("collection")

	print("Gold after initialization: %d" % resource_tracker.get_balance())
	print("Power bars after initialization: %d" % resource_tracker.get_item_count("power_bar"))
	print("Active creatures after initialization: %d" % collection_system.get_active_creatures().size())

	if collection_system.get_active_creatures().size() > 0:
		var creature = collection_system.get_active_creatures()[0]
		print("First creature: %s (%s)" % [creature.creature_name, creature.species_id])

	print("=== TEST COMPLETED ===")
	get_tree().quit()