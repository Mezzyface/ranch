extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== SaveSystem Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var save_system = GameCore.get_system("save")
	if not save_system:
		print("❌ SaveSystem failed to load")
		details.append("SaveSystem not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ SaveSystem loaded successfully")

	# Test 2: Game State Save/Load
	var test_slot := "save_test"
	if not save_system.save_game_state(test_slot):
		print("❌ Game state save failed")
		details.append("Game state save failed")
		success = false
	else:
		print("✅ Game state save successful")

	if not save_system.load_game_state(test_slot):
		print("❌ Game state load failed")
		details.append("Game state load failed")
		success = false
	else:
		print("✅ Game state load successful")

	# Test 3: Creature Collection Save/Load
	var test_creatures: Array[CreatureData] = []
	for i in range(5):
		var c: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
		c.creature_name = "Save Test %d" % i
		test_creatures.append(c)

	var start: int = Time.get_ticks_msec()
	if not save_system.save_creature_collection(test_creatures, test_slot):
		print("❌ Creature collection save failed")
		details.append("Collection save failed")
		success = false
	else:
		print("✅ Creature collection save successful")

	var loaded_creatures: Array[CreatureData] = save_system.load_creature_collection(test_slot)
	var dur: int = Time.get_ticks_msec() - start

	if loaded_creatures.size() < test_creatures.size():
		print("❌ Collection load size mismatch: %d < %d" % [loaded_creatures.size(), test_creatures.size()])
		details.append("Collection load mismatch %d<%d" % [loaded_creatures.size(), test_creatures.size()])
		success = false
	else:
		var expected_names: Array[String] = []
		for c in test_creatures:
			expected_names.append(c.creature_name)
		for lc in loaded_creatures:
			if lc.creature_name in expected_names:
				expected_names.erase(lc.creature_name)
		if expected_names.size() > 0:
			print("❌ Missing creature names in loaded data: %s" % ", ".join(expected_names))
			details.append("Missing loaded names: %s" % ", ".join(expected_names))
			success = false
		else:
			print("✅ Creature collection load successful with all names preserved")

	if dur >= 200:
		print("⚠️ Performance warning: collection save/load took %dms (target <200ms)" % dur)
		details.append("Performance slow %dms" % dur)
	else:
		print("✅ Performance good: collection save/load took %dms" % dur)

	# Test 4: Individual Creature Save/Load
	var indiv: CreatureData = CreatureGenerator.generate_creature_data("wind_dancer")
	indiv.creature_name = "Individual Test"
	if not save_system.save_individual_creature(indiv, "individual_test"):
		print("❌ Individual creature save failed")
		details.append("Individual save failed")
		success = false
	else:
		print("✅ Individual creature save successful")

	var loaded_individual: CreatureData = save_system.load_individual_creature(indiv.id, "individual_test")
	if not (loaded_individual and loaded_individual.creature_name == "Individual Test"):
		print("❌ Individual creature load failed")
		details.append("Individual load failed")
		success = false
	else:
		print("✅ Individual creature load successful")

	# Test 5: Auto-Save Functionality
	save_system.enable_auto_save(1)
	if not save_system.trigger_auto_save():
		print("❌ Auto-save trigger failed")
		details.append("Auto-save trigger failed")
		success = false
	else:
		print("✅ Auto-save functionality works")
	save_system.disable_auto_save()

	# Test 6: Save Data Validation
	var validation: Dictionary = save_system.validate_save_data(test_slot)
	var validation_failed := false
	for key in ["valid","checks_performed","checks_passed"]:
		if not validation.has(key):
			print("❌ Validation missing key: %s" % key)
			details.append("Validation missing key: %s" % key)
			success = false
			validation_failed = true
	if not validation_failed:
		print("✅ Save data validation works")

	# Test 7: Backup Creation
	if not save_system.create_backup(test_slot):
		print("❌ Backup creation failed")
		details.append("Backup creation failed")
		success = false
	else:
		print("✅ Backup creation successful")

	# Cleanup
	save_system.delete_save_slot(test_slot)
	save_system.delete_save_slot(test_slot + "_backup")

	# Final summary
	if success:
		print("\n✅ All SaveSystem tests passed!")
	else:
		print("\n❌ Some SaveSystem tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()