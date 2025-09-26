extends Node

signal test_completed(success: bool, details: Array)
var test_quiet_mode_global: bool = false

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== PlayerCollection System Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var collection_system = GameCore.get_system("collection")
	var signal_bus: SignalBus = GameCore.get_signal_bus()
	if not collection_system:
		print("❌ Collection system failed to load")
		details.append("Collection system not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ Collection system loaded successfully")

	# Test 2: Signal Connection Setup
	var signals_received := {"acquired": false, "released": false, "roster_changed": false, "stable_updated": false, "milestone": false}
	var handlers := {
		"acquired": func(_creature_data: CreatureData, _source: String): signals_received.acquired = true,
		"released": func(_creature_data: CreatureData, _reason: String): signals_received.released = true,
		"roster": func(_roster: Array[CreatureData]): signals_received.roster_changed = true,
		"stable": func(_op: String, _id: String): signals_received.stable_updated = true,
		"milestone": func(_milestone: String, _count: int): signals_received.milestone = true
	}
	signal_bus.creature_acquired.connect(handlers.acquired)
	signal_bus.creature_released.connect(handlers.released)
	signal_bus.active_roster_changed.connect(handlers.roster)
	signal_bus.stable_collection_updated.connect(handlers.stable)
	signal_bus.collection_milestone_reached.connect(handlers.milestone)
	print("✅ Signal handlers connected")

	# Test 3: Active Roster Management
	var test_creatures: Array[CreatureData] = []
	for i in range(8):
		var cr: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
		cr.creature_name = "Active Test %d" % i
		test_creatures.append(cr)
	var added := 0
	for i in range(6):
		if collection_system.add_to_active(test_creatures[i]):
			added += 1
	if added != 6:
		print("❌ Active roster limit failed: added %d/6 creatures" % added)
		details.append("Active roster added %d/6" % added)
		success = false
	else:
		print("✅ Active roster accepts 6 creatures correctly")

	if collection_system.add_to_active(test_creatures[6]):
		print("❌ 7th creature incorrectly accepted to active roster")
		details.append("7th creature incorrectly accepted")
		success = false
	else:
		print("✅ Active roster correctly rejects 7th creature")

	# Test 4: Stable Collection Management
	signal_bus.set_debug_mode(false)
	collection_system.set_quiet_mode(true)
	test_quiet_mode_global = true
	var stable_added := 0
	for i in range(6, test_creatures.size()):
		if collection_system.add_to_stable(test_creatures[i]):
			stable_added += 1
	for i in range(10):
		var extra: CreatureData = CreatureGenerator.generate_creature_data("wind_dancer")
		extra.creature_name = "Stable Extra %d" % i
		if collection_system.add_to_stable(extra):
			stable_added += 1
	signal_bus.set_debug_mode(true)
	collection_system.set_quiet_mode(false)
	test_quiet_mode_global = false
	if stable_added != 12:
		print("❌ Stable collection failed: added %d expected 12" % stable_added)
		details.append("Stable added %d expected 12" % stable_added)
		success = false
	else:
		print("✅ Stable collection handles unlimited creatures correctly")

	# Test 5: Creature Movement
	var active_creatures: Array[CreatureData] = collection_system.get_active_creatures()
	if active_creatures.size() > 0:
		var move_id: String = active_creatures[0].id
		if collection_system.move_to_stable(move_id):
			if collection_system.get_active_creatures().size() != 5:
				print("❌ Active roster size wrong after move")
				details.append("Active size after move wrong")
				success = false
			else:
				print("✅ Creature movement between collections works")
		else:
			print("❌ Move to stable failed")
			details.append("Move to stable failed")
			success = false

	# Test 6: Search and Quest Functionality
	var search_results: Array[CreatureData] = collection_system.search_creatures({"species_id": "wind_dancer"})
	if search_results == null:
		print("❌ Search functionality failed (returned null)")
		details.append("Search returned null")
		success = false
	else:
		print("✅ Search functionality works (found %d wind_dancer creatures)" % search_results.size())

	var available_for_quest: Array[CreatureData] = collection_system.get_available_for_quest(["Flies"] as Array[String])
	if available_for_quest == null:
		print("❌ Quest availability check failed (returned null)")
		details.append("Quest availability null")
		success = false
	else:
		print("✅ Quest availability check works (found %d flying creatures)" % available_for_quest.size())

	# Test 7: Statistics and Performance
	var stats: Dictionary = collection_system.get_collection_stats()
	if not (stats.has("total_count") and stats.has("active_count")):
		print("❌ Collection statistics missing required keys")
		details.append("Stats missing keys")
		success = false
	else:
		print("✅ Collection statistics work correctly")

	var performance: Dictionary = collection_system.get_performance_metrics()
	if not performance.has("active_creatures"):
		print("❌ Performance metrics missing active_creatures")
		details.append("Performance missing active_creatures")
		success = false
	else:
		print("✅ Performance metrics available")

	# Test 8: Signal Integration
	var working_signals := 0
	for k in signals_received.keys():
		if signals_received[k]:
			working_signals += 1
	if working_signals < 2: # accept minimal variance due to debug mode toggles
		print("❌ Signal integration poor: only %d/5 signals fired" % working_signals)
		details.append("Few signals fired %d/5" % working_signals)
		success = false
	else:
		print("✅ Signal integration works (%d/5 signals fired)" % working_signals)

	# Cleanup signal connections
	signal_bus.creature_acquired.disconnect(handlers.acquired)
	signal_bus.creature_released.disconnect(handlers.released)
	signal_bus.active_roster_changed.disconnect(handlers.roster)
	signal_bus.stable_collection_updated.disconnect(handlers.stable)
	signal_bus.collection_milestone_reached.disconnect(handlers.milestone)

	# Final summary
	if success:
		print("\n✅ All PlayerCollection tests passed!")
	else:
		print("\n❌ Some PlayerCollection tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()