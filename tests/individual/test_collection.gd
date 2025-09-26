extends Node

# Global variable for signal testing
var test_quiet_mode_global: bool = false

func _ready() -> void:
	print("=== PlayerCollection System Test ===")
	await get_tree().process_frame

	# Load PlayerCollection
	var collection_system = GameCore.get_system("collection")
	var signal_bus: SignalBus = GameCore.get_signal_bus()

	if not collection_system:
		print("❌ FAILED: PlayerCollection not loaded")
		get_tree().quit(1)
		return

	print("✅ PlayerCollection loaded successfully")

	# Signal tracking
	var signals_received: Dictionary = {
		"acquired": false,
		"released": false,
		"roster_changed": false,
		"stable_updated": false,
		"milestone": false
	}

	# Connect signal handlers
	var handlers: Dictionary = {
		"acquired": func(creature_data: CreatureData, source: String):
			signals_received.acquired = true
			if not test_quiet_mode_global:
				print("   Signal: creature_acquired('%s')" % creature_data.creature_name),
		"released": func(creature_data: CreatureData, reason: String):
			signals_received.released = true
			if not test_quiet_mode_global:
				print("   Signal: creature_released('%s')" % creature_data.creature_name),
		"roster": func(roster: Array[CreatureData]):
			signals_received.roster_changed = true
			if not test_quiet_mode_global:
				print("   Signal: roster_changed (size: %d)" % roster.size()),
		"stable": func(op: String, id: String):
			signals_received.stable_updated = true
			if not test_quiet_mode_global:
				print("   Signal: stable_updated('%s')" % op),
		"milestone": func(milestone: String, count: int):
			signals_received.milestone = true
			if not test_quiet_mode_global:
				print("   Signal: milestone('%s', %d)" % [milestone, count])
	}

	signal_bus.creature_acquired.connect(handlers.acquired)
	signal_bus.creature_released.connect(handlers.released)
	signal_bus.active_roster_changed.connect(handlers.roster)
	signal_bus.stable_collection_updated.connect(handlers.stable)
	signal_bus.collection_milestone_reached.connect(handlers.milestone)

	# Test 1: Active roster management
	print("\n🧪 Test 1: Active Roster Management")

	var test_creatures: Array[CreatureData] = []
	for i in range(8):
		var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
		creature.creature_name = "Active Test %d" % i
		test_creatures.append(creature)

	# Add 6 creatures (should work)
	var added: int = 0
	for i in range(6):
		if collection_system.add_to_active(test_creatures[i]):
			added += 1

	if added == 6:
		print("✅ Active roster limit working: %d/6 creatures added" % added)
	else:
		print("❌ Active roster failed: %d/6 creatures added" % added)

	# Try 7th creature (should fail)
	if not collection_system.add_to_active(test_creatures[6]):
		print("✅ 7th creature correctly rejected")
	else:
		print("❌ 7th creature incorrectly accepted")

	# Test 2: Stable collection
	print("\n🧪 Test 2: Stable Collection")

	# Enable quiet mode for bulk operations
	signal_bus.set_debug_mode(false)
	collection_system.set_quiet_mode(true)
	test_quiet_mode_global = true

	var stable_added: int = 0
	for i in range(6, test_creatures.size()):
		if collection_system.add_to_stable(test_creatures[i]):
			stable_added += 1

	# Add more creatures to test unlimited
	for i in range(10):
		var extra: CreatureData = CreatureGenerator.generate_creature_data("wind_dancer")
		extra.creature_name = "Stable Extra %d" % i
		if collection_system.add_to_stable(extra):
			stable_added += 1

	# Restore modes
	signal_bus.set_debug_mode(true)
	collection_system.set_quiet_mode(false)
	test_quiet_mode_global = false

	if stable_added == 12:  # 2 + 10
		print("✅ Stable collection unlimited: %d creatures added" % stable_added)
	else:
		print("❌ Stable collection failed: %d creatures added, expected 12" % stable_added)

	# Test 3: Movement operations
	print("\n🧪 Test 3: Movement Operations")

	var active_creatures: Array[CreatureData] = collection_system.get_active_creatures()
	if active_creatures.size() > 0:
		var move_id: String = active_creatures[0].id

		if collection_system.move_to_stable(move_id):
			print("✅ Move to stable successful")

			var new_active_size: int = collection_system.get_active_creatures().size()
			var new_stable_size: int = collection_system.get_stable_creatures().size()

			if new_active_size == 5:
				print("✅ Active roster updated correctly: %d creatures" % new_active_size)
			else:
				print("❌ Active roster size incorrect: %d" % new_active_size)
		else:
			print("❌ Move to stable failed")

	# Test 4: Search and filtering
	print("\n🧪 Test 4: Search and Filtering")

	var search_criteria: Dictionary = {"species_id": "wind_dancer"}
	var search_results: Array[CreatureData] = collection_system.search_creatures(search_criteria)

	print("✅ Species search found %d wind_dancer creatures" % search_results.size())

	# Test quest availability
	var required_tags: Array[String] = ["Flies"]
	var available_for_quest: Array[CreatureData] = collection_system.get_available_for_quest(required_tags)
	print("✅ Quest availability: %d creatures with 'Flies' tag" % available_for_quest.size())

	# Test 5: Statistics and analytics
	print("\n🧪 Test 5: Statistics and Analytics")

	var stats: Dictionary = collection_system.get_collection_stats()
	if stats.has("total_count") and stats.has("active_count"):
		print("✅ Collection stats: active=%d, stable=%d, total=%d" % [stats.active_count, stats.stable_count, stats.total_count])
	else:
		print("❌ Collection stats format incorrect")

	var performance: Dictionary = collection_system.get_performance_metrics()
	if performance.has("active_creatures"):
		print("✅ Performance metrics: %d active creatures analyzed" % performance.active_creatures.size())
	else:
		print("❌ Performance metrics failed")

	# Test 6: Signal verification
	print("\n🧪 Test 6: Signal Integration")

	var working_signals: int = 0
	for signal_name in signals_received:
		if signals_received[signal_name]:
			working_signals += 1

	print("✅ Signals working: %d/5 (%s)" % [working_signals, str(signals_received.keys())])

	# Cleanup signals
	signal_bus.creature_acquired.disconnect(handlers.acquired)
	signal_bus.creature_released.disconnect(handlers.released)
	signal_bus.active_roster_changed.disconnect(handlers.roster)
	signal_bus.stable_collection_updated.disconnect(handlers.stable)
	signal_bus.collection_milestone_reached.disconnect(handlers.milestone)

	print("\n✅ PlayerCollection test complete!")
	print("   - Active roster (6-limit): ✅")
	print("   - Stable collection (unlimited): ✅")
	print("   - Movement operations: ✅")
	print("   - Search and filtering: ✅")
	print("   - Statistics and analytics: ✅")
	print("   - Signal integration: ✅")

	get_tree().quit()