extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== Quest System Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var quest_system = GameCore.get_system("quest")
	if not quest_system:
		print("❌ Quest system failed to load")
		details.append("Quest system not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ Quest system loaded successfully")

	# Test 2: Quest Resource Loading
	var available_quests: Array[String] = quest_system.get_available_quests()
	if available_quests.size() < 1:
		print("❌ No quests loaded from data/quests/")
		details.append("No quest resources loaded")
		success = false
	else:
		print("✅ Found %d quest resources" % available_quests.size())

	# Test 3: Quest Status Methods
	var test_quest_id: String = "test_nonexistent"
	if quest_system.is_quest_active(test_quest_id):
		print("❌ is_quest_active should return false for nonexistent quest")
		details.append("is_quest_active validation failed")
		success = false
	else:
		print("✅ is_quest_active correctly returns false for nonexistent quest")

	if quest_system.is_quest_completed(test_quest_id):
		print("❌ is_quest_completed should return false for nonexistent quest")
		details.append("is_quest_completed validation failed")
		success = false
	else:
		print("✅ is_quest_completed correctly returns false for nonexistent quest")

	# Test 4: SignalBus Integration
	var signal_bus = GameCore.get_signal_bus()
	var required_signals: Array[String] = [
		"quest_started",
		"quest_completed",
		"quest_objective_completed",
		"quest_failed",
		"quest_requirements_met",
		"quest_progress_updated"
	]

	for signal_name in required_signals:
		if not signal_bus.has_signal(signal_name):
			print("❌ Missing signal: %s" % signal_name)
			details.append("Missing signal: %s" % signal_name)
			success = false
		else:
			print("✅ Signal exists: %s" % signal_name)

	# Test 5: Signal Emission with Validation
	print("Testing signal emission validation...")

	# Test empty quest_id validation
	var original_debug_mode = signal_bus._debug_mode
	signal_bus.set_debug_mode(false)  # Reduce noise for validation tests

	# These should fail validation and not crash
	signal_bus.emit_quest_started("")  # Should fail
	signal_bus.emit_quest_completed("")  # Should fail
	signal_bus.emit_quest_objective_completed("", -1)  # Should fail (negative index)
	signal_bus.emit_quest_failed("", "")  # Should fail (empty fields)

	signal_bus.set_debug_mode(original_debug_mode)
	print("✅ Signal validation works correctly")

	# Test 6: Valid Signal Emission
	signal_bus.emit_quest_started("test_quest")
	signal_bus.emit_quest_objective_completed("test_quest", 0)
	signal_bus.emit_quest_completed("test_quest")
	print("✅ Valid signal emission works")

	# Test 7: Quest Methods with Invalid Input
	if quest_system.start_quest(""):
		print("❌ start_quest should fail with empty quest_id")
		details.append("start_quest validation failed")
		success = false
	else:
		print("✅ start_quest correctly validates empty quest_id")

	var empty_creatures: Array[CreatureData] = []
	if quest_system.complete_objective("", 0, empty_creatures):
		print("❌ complete_objective should fail with empty quest_id")
		details.append("complete_objective validation failed")
		success = false
	else:
		print("✅ complete_objective correctly validates empty quest_id")

	# Test 8: Quest Resource Access
	var quest_resource: Dictionary = quest_system.get_quest_resource("nonexistent")
	if not quest_resource.is_empty():
		print("❌ get_quest_resource should return empty dict for nonexistent quest")
		details.append("get_quest_resource validation failed")
		success = false
	else:
		print("✅ get_quest_resource correctly returns empty for nonexistent quest")

	var quest_data: Dictionary = quest_system.get_active_quest_data("nonexistent")
	if not quest_data.is_empty():
		print("❌ get_active_quest_data should return empty dict for nonexistent quest")
		details.append("get_active_quest_data validation failed")
		success = false
	else:
		print("✅ get_active_quest_data correctly returns empty for nonexistent quest")

	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	print("\n=== Quest System Test Results ===")
	if success:
		print("✅ ALL TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED:")
		for detail in details:
			print("  • %s" % detail)
	print("================================")

	test_completed.emit(success, details)

	# Auto-quit for individual test
	get_tree().quit(0 if success else 1)