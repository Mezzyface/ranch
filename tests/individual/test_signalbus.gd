extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success: bool = true
	print("=== SignalBus System Test ===")
	await get_tree().process_frame
	var signal_bus: SignalBus = GameCore.get_signal_bus()
	if not signal_bus:
		print("❌ FAILED: SignalBus not accessible")
		details.append("SignalBus not accessible")
		success = false
		_finalize(success, details)
		return
	print("✅ SignalBus accessible through GameCore")
	var creature_signals: Array[String] = ["creature_created","creature_stats_changed","creature_aged","creature_activated","creature_deactivated","creature_tag_added","creature_tag_removed","tag_add_failed","tag_validation_failed","creature_category_changed","creature_expired","aging_batch_completed","creature_acquired","creature_released","active_roster_changed","stable_collection_updated","collection_milestone_reached"]
	var system_signals: Array[String] = ["save_requested","load_requested","auto_save_triggered"]
	var expected_total: int = creature_signals.size() + system_signals.size()
	var signals_found: int = 0
	for signal_name in creature_signals + system_signals:
		if signal_bus.has_signal(signal_name):
			signals_found += 1
		else:
			var msg = "Missing signal: %s" % signal_name
			print("⚠️ %s" % msg)
			details.append(msg)
	if signals_found != expected_total:
		success = false
	print("✅ Found %d/%d expected signals" % [signals_found, expected_total])
	var test_state := {"connected": false}
	var test_handler = func(): test_state.connected = true
	if signal_bus.connect_signal_safe("save_requested", test_handler):
		print("✅ Safe signal connection successful")
		signal_bus.save_requested.emit()
		await get_tree().process_frame
		if test_state.connected:
			print("✅ Signal emission and handling working")
		else:
			print("❌ Signal emission failed")
			details.append("Emission failure for save_requested")
			success = false
		signal_bus.disconnect_signal_safe("save_requested", test_handler)
	else:
		print("❌ Safe signal connection failed")
		details.append("Safe connection failed")
		success = false
	signal_bus.set_debug_mode(true)
	print("✅ Debug mode enabled")
	signal_bus.set_debug_mode(false)
	print("✅ Debug mode disabled")
	print("\n✅ SignalBus test complete!")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()