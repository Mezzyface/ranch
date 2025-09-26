extends Node

func _ready() -> void:
	print("=== SignalBus System Test ===")
	await get_tree().process_frame

	# Test SignalBus accessibility
	var signal_bus: SignalBus = GameCore.get_signal_bus()
	if not signal_bus:
		print("❌ FAILED: SignalBus not accessible")
		get_tree().quit(1)
		return

	print("✅ SignalBus accessible through GameCore")

	# Test signal existence
	var creature_signals: Array[String] = [
		"creature_created",
		"creature_stats_changed",
		"creature_aged",
		"creature_activated",
		"creature_deactivated",
		"creature_tag_added",
		"creature_tag_removed",
		"tag_add_failed",
		"tag_validation_failed",
		"creature_category_changed",
		"creature_expired",
		"aging_batch_completed",
		"creature_acquired",
		"creature_released",
		"active_roster_changed",
		"stable_collection_updated",
		"collection_milestone_reached"
	]

	var system_signals: Array[String] = [
		"save_requested",
		"load_requested",
		"auto_save_triggered"
	]

	var signals_found: int = 0
	for signal_name in creature_signals + system_signals:
		if signal_bus.has_signal(signal_name):
			signals_found += 1
		else:
			print("⚠️ Signal not found: %s" % signal_name)

	print("✅ Found %d/%d expected signals" % [signals_found, creature_signals.size() + system_signals.size()])

	# Test signal connection
	var test_connected: bool = false
	var test_handler = func(): test_connected = true

	if signal_bus.connect_signal_safe("save_requested", test_handler):
		print("✅ Safe signal connection successful")
		signal_bus.save_requested.emit()
		await get_tree().process_frame

		if test_connected:
			print("✅ Signal emission and handling working")
		else:
			print("❌ Signal emission failed")

		signal_bus.disconnect_signal_safe("save_requested", test_handler)
	else:
		print("❌ Safe signal connection failed")

	# Test debug mode
	signal_bus.set_debug_mode(true)
	print("✅ Debug mode enabled")
	signal_bus.set_debug_mode(false)
	print("✅ Debug mode disabled")

	print("\n✅ SignalBus test complete!")
	get_tree().quit()