extends Node

func _ready() -> void:
	print("=== SaveSystem Test ===")
	await get_tree().process_frame

	# Load SaveSystem
	var save_system = GameCore.get_system("save")
	if not save_system:
		print("❌ FAILED: SaveSystem not loaded")
		get_tree().quit(1)
		return

	print("✅ SaveSystem loaded successfully")

	# Test basic game state save/load
	var test_slot: String = "save_test"

	if save_system.save_game_state(test_slot):
		print("✅ Game state save successful")
	else:
		print("❌ Game state save failed")
		get_tree().quit(1)
		return

	if save_system.load_game_state(test_slot):
		print("✅ Game state load successful")
	else:
		print("❌ Game state load failed")

	# Test creature collection save/load
	var test_creatures: Array[CreatureData] = []
	for i in range(5):
		var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
		creature.creature_name = "Save Test %d" % i
		test_creatures.append(creature)

	var start_time: int = Time.get_ticks_msec()

	if save_system.save_creature_collection(test_creatures, test_slot):
		print("✅ Creature collection save successful")
	else:
		print("❌ Creature collection save failed")

	var loaded_creatures: Array[CreatureData] = save_system.load_creature_collection(test_slot)

	var end_time: int = Time.get_ticks_msec()
	var duration: int = end_time - start_time

	if loaded_creatures.size() == test_creatures.size():
		print("✅ Creature collection load successful: %d creatures" % loaded_creatures.size())

		# Verify data integrity
		var data_intact: bool = true
		for i in range(loaded_creatures.size()):
			if loaded_creatures[i].creature_name != test_creatures[i].creature_name:
				data_intact = false
				break

		if data_intact:
			print("✅ Creature data integrity verified")
		else:
			print("❌ Creature data corrupted during save/load")
	else:
		print("❌ Creature collection load failed: got %d, expected %d" % [loaded_creatures.size(), test_creatures.size()])

	if duration < 200:
		print("✅ Save/Load performance acceptable: %dms" % duration)
	else:
		print("⚠️ Save/Load performance slow: %dms (target: <200ms)" % duration)

	# Test individual creature save/load
	var individual_creature: CreatureData = CreatureGenerator.generate_creature_data("wind_dancer")
	individual_creature.creature_name = "Individual Test"

	if save_system.save_individual_creature(individual_creature, "individual_test"):
		print("✅ Individual creature save successful")
	else:
		print("❌ Individual creature save failed")

	var loaded_individual: CreatureData = save_system.load_individual_creature("individual_test")
	if loaded_individual and loaded_individual.creature_name == "Individual Test":
		print("✅ Individual creature load successful: %s" % loaded_individual.creature_name)
	else:
		print("❌ Individual creature load failed")

	# Test auto-save functionality
	save_system.enable_auto_save(1)  # 1 minute interval
	print("✅ Auto-save enabled")

	if save_system.trigger_auto_save():
		print("✅ Manual auto-save trigger successful")
	else:
		print("❌ Manual auto-save trigger failed")

	save_system.disable_auto_save()
	print("✅ Auto-save disabled")

	# Test save validation
	var validation: Dictionary = save_system.validate_save_data(test_slot)
	if validation.has("valid") and validation.has("checks"):
		print("✅ Save validation working: %s (%d checks)" % ["valid" if validation.valid else "invalid", validation.checks])
	else:
		print("❌ Save validation failed")

	# Test backup functionality
	if save_system.create_backup(test_slot, test_slot + "_backup"):
		print("✅ Backup creation successful")
	else:
		print("❌ Backup creation failed")

	# Cleanup
	save_system.delete_save_slot(test_slot)
	save_system.delete_save_slot(test_slot + "_backup")
	print("✅ Test cleanup completed")

	print("\n✅ SaveSystem test complete!")
	get_tree().quit()