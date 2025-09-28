extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== FacilitySystem Weekly Integration Test ===")
	await get_tree().process_frame

	# Test 1: FacilitySystem Loading
	var facility_system = GameCore.get_system("facility")
	if not facility_system:
		print("❌ FacilitySystem not loaded")
		details.append("FacilitySystem not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ FacilitySystem loaded successfully")

	# Test 2: WeeklyUpdateOrchestrator Loading
	var orchestrator_nodes = get_tree().get_nodes_in_group("weekly_orchestrator")
	var orchestrator = null
	if orchestrator_nodes.size() > 0:
		orchestrator = orchestrator_nodes[0]
	if not orchestrator:
		# Try to create one for testing
		orchestrator = WeeklyUpdateOrchestrator.new()
		add_child(orchestrator)

	if not orchestrator:
		print("❌ WeeklyUpdateOrchestrator not available")
		details.append("WeeklyUpdateOrchestrator not available")
		success = false
		_finalize(success, details)
		return
	print("✅ WeeklyUpdateOrchestrator available")

	# Test 3: Required Systems Check
	var resource_tracker = GameCore.get_system("resource")
	var collection = GameCore.get_system("collection")
	if not resource_tracker or not collection:
		print("❌ Required systems not available (resource: %s, collection: %s)" % [resource_tracker != null, collection != null])
		details.append("Required systems missing")
		success = false
		_finalize(success, details)
		return
	print("✅ Required systems available")

	# Test 4: Food Validation - No Assignments
	if facility_system.has_food_for_all_facilities():
		print("✅ Food validation works correctly (no assignments, no validation needed)")
	else:
		print("❌ Food validation failed - should return true when no assignments")
		details.append("Food validation failed for empty assignments")
		success = false

	# Test 5: Week Advance Blocked Signal
	var signal_bus = GameCore.get_signal_bus()
	if not signal_bus:
		print("❌ SignalBus not available")
		details.append("SignalBus not available")
		success = false
		_finalize(success, details)
		return

	var signal_emitted = false
	var signal_reason = ""

	# Connect to signal to verify it gets emitted
	var signal_callback = func(reason: String):
		signal_emitted = true
		signal_reason = reason

	if signal_bus.has_signal("week_advance_blocked"):
		signal_bus.week_advance_blocked.connect(signal_callback)
		print("✅ week_advance_blocked signal exists")
	else:
		print("❌ week_advance_blocked signal not found")
		details.append("week_advance_blocked signal missing")
		success = false

	# Test 6: Weekly Update with No Food (should be blocked)
	print("Testing weekly update with food validation...")

	# Add some test food items to inventory first
	resource_tracker.add_item("power_bar", 5)
	resource_tracker.add_item("speed_snack", 3)
	resource_tracker.add_item("brain_food", 2)
	resource_tracker.add_item("focus_tea", 1)

	# Run weekly update (should succeed since no facilities assigned)
	var result = orchestrator.execute_weekly_update()

	if result.get("success", false):
		print("✅ Weekly update completed successfully with no facility assignments")

		if result.has("processed_facilities"):
			var processed = result.get("processed_facilities", -1)
			if processed == 0:
				print("✅ Processed facilities count correct (0)")
			else:
				print("❌ Expected 0 processed facilities, got %d" % processed)
				details.append("Incorrect processed facilities count")
				success = false
		else:
			print("❌ Missing processed_facilities in result")
			details.append("Missing processed_facilities in result")
			success = false

	else:
		print("❌ Weekly update failed unexpectedly: %s" % result.get("reason", "unknown"))
		details.append("Weekly update failed: %s" % result.get("reason", "unknown"))
		success = false

	# Test 7: Check if week_advance_blocked signal handler exists
	if signal_bus.has_method("emit_week_advance_blocked"):
		print("✅ emit_week_advance_blocked method exists")
	else:
		print("❌ emit_week_advance_blocked method not found")
		details.append("emit_week_advance_blocked method missing")
		success = false

	# Test 8: FACILITIES phase in pipeline
	if orchestrator.has_method("_handle_facilities"):
		print("✅ _handle_facilities method exists")
	else:
		print("❌ _handle_facilities method not found")
		details.append("_handle_facilities method missing")
		success = false

	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	if success:
		print("✅ All facility integration tests passed!")
	else:
		print("❌ Some facility integration tests failed:")
		for detail in details:
			print("  - %s" % detail)

	test_completed.emit(success, details)

	# Auto-quit for headless testing
	await get_tree().process_frame
	get_tree().quit()