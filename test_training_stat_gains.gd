extends Node

func _ready():
	print("=== TRAINING STAT GAINS VERIFICATION TEST ===")

	# Initialize required systems
	var game_core = GameCore
	var training_system = game_core.get_system("training")
	var collection_system = game_core.get_system("collection")
	var time_system = game_core.get_system("time")
	var resource_tracker = game_core.get_system("resource")

	# Create a test creature
	var creature_data = CreatureData.new()
	creature_data.creature_name = "Test Training Creature"
	creature_data.species_id = "scuttleguard"
	creature_data.strength = 50
	creature_data.constitution = 45
	creature_data.dexterity = 40
	creature_data.stamina_current = 100

	print("📊 Initial stats:")
	print("  STR: %d, CON: %d, DEX: %d" % [creature_data.strength, creature_data.constitution, creature_data.dexterity])

	# Add creature to active collection
	collection_system.add_to_active(creature_data)

	# Add some training food for testing
	resource_tracker.add_item("power_bar", 5)
	print("📦 Added 5 power bars to inventory")

	# Schedule physical training with food
	var result = training_system.schedule_training(creature_data, TrainingSystem.TrainingActivity.PHYSICAL, TrainingSystem.FacilityTier.BASIC, 0)
	print("🏋️ Scheduled physical training: %s" % ("SUCCESS" if result.get("success", false) else "FAILED"))

	if not result.get("success", false):
		print("❌ Training scheduling failed: %s" % result.get("reason", "Unknown"))
		return

	# Check initial food inventory
	var inventory = resource_tracker.get_inventory()
	print("📦 Food inventory before training starts: power_bar = %d" % inventory.get("power_bar", 0))

	# Advance one week to start training
	print("\n⏰ Advancing week to start training...")
	time_system.advance_week()

	# Check if food was consumed
	inventory = resource_tracker.get_inventory()
	print("📦 Food inventory after training starts: power_bar = %d" % inventory.get("power_bar", 0))

	# Get current stats (should still be unchanged as training hasn't completed)
	print("📊 Stats during training:")
	print("  STR: %d, CON: %d, DEX: %d" % [creature_data.strength, creature_data.constitution, creature_data.dexterity])

	# Advance another week to complete training
	print("\n⏰ Advancing week to complete training...")
	time_system.advance_week()

	# Check final stats
	print("📊 Final stats after training completion:")
	print("  STR: %d, CON: %d, DEX: %d" % [creature_data.strength, creature_data.constitution, creature_data.dexterity])

	# Calculate gains
	var str_gain = creature_data.strength - 50
	var con_gain = creature_data.constitution - 45
	var total_gains = str_gain + con_gain

	print("\n🎯 Training results:")
	print("  STR gained: +%d" % str_gain)
	print("  CON gained: +%d" % con_gain)
	print("  Total gains: +%d" % total_gains)

	# Verify results
	if str_gain > 0 and con_gain > 0:
		print("✅ SUCCESS: Creature stats increased from physical training!")
		print("✅ Food effect should have provided 50%% boost (base 5-15 → enhanced 7-22 per stat)")
	else:
		print("❌ FAILED: No stat gains detected")

	# Check training status
	var status = training_system.get_training_status(creature_data.id)
	print("\n📋 Training status: %s" % status.get("status", "unknown"))

	print("\n=== TEST COMPLETE ===")
	get_tree().quit()