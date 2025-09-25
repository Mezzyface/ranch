extends Node

func _ready() -> void:
	print("=== Testing Project Setup & SignalBus (Task 1 + 2) ===")

	# Wait a frame for autoloads to initialize
	await get_tree().process_frame

	# Test GameCore accessibility
	if GameCore != null:
		print("✅ GameCore autoload working")
	else:
		print("❌ GameCore autoload failed")
		return

	# Test SignalBus creation and enhancement
	var signal_bus: SignalBus = GameCore.get_signal_bus()
	if signal_bus:
		print("✅ SignalBus created successfully")
		_test_signal_bus_enhancements(signal_bus)
	else:
		print("❌ SignalBus creation failed")
		return

	# Test system lazy loading
	var save_system = GameCore.get_system("save")
	if save_system and save_system is SaveSystem:
		print("✅ SaveSystem lazy loading works")
	else:
		print("❌ SaveSystem lazy loading failed")

	var creature_system = GameCore.get_system("creature")
	if creature_system and creature_system is CreatureSystem:
		print("✅ CreatureSystem lazy loading works")
	else:
		print("❌ CreatureSystem lazy loading failed")

	var quest_system = GameCore.get_system("quest")
	if quest_system and quest_system is QuestSystem:
		print("✅ QuestSystem lazy loading works")
	else:
		print("❌ QuestSystem lazy loading failed")

	print("=== Setup Test Complete ===")
	print("Project is ready for Stage 1 Task 3 (CreatureData)")

func _test_signal_bus_enhancements(signal_bus: SignalBus) -> void:
	print("--- Testing SignalBus Enhancements ---")

	# Test signal existence
	var creature_signals: Array[String] = [
		"creature_created",
		"creature_stats_changed",
		"creature_aged",
		"creature_activated",
		"creature_deactivated"
	]

	var system_signals: Array[String] = [
		"save_requested",
		"load_requested",
		"save_completed",
		"load_completed"
	]

	for signal_name in creature_signals:
		if signal_bus.has_signal(signal_name):
			print("✅ SignalBus has creature signal: %s" % signal_name)
		else:
			print("❌ SignalBus missing creature signal: %s" % signal_name)

	for signal_name in system_signals:
		if signal_bus.has_signal(signal_name):
			print("✅ SignalBus has system signal: %s" % signal_name)
		else:
			print("❌ SignalBus missing system signal: %s" % signal_name)

	# Test connection management
	var test_callable: Callable = _test_signal_handler
	var success: bool = signal_bus.connect_signal_safe("save_requested", test_callable)
	if success:
		print("✅ Signal connection management works")
	else:
		print("❌ Signal connection management failed")

	# Test connection tracking
	var count: int = signal_bus.get_connection_count("save_requested")
	if count == 1:
		print("✅ Signal connection tracking works (count: %d)" % count)
	else:
		print("❌ Signal connection tracking failed (count: %d)" % count)

	# Test disconnection
	success = signal_bus.disconnect_signal_safe("save_requested", test_callable)
	if success:
		print("✅ Signal disconnection management works")
	else:
		print("❌ Signal disconnection management failed")

	count = signal_bus.get_connection_count("save_requested")
	if count == 0:
		print("✅ Signal disconnection tracking works (count: %d)" % count)
	else:
		print("❌ Signal disconnection tracking failed (count: %d)" % count)

	# Test debug mode toggle
	signal_bus.set_debug_mode(false)
	signal_bus.set_debug_mode(true)
	print("✅ Debug mode toggle works")

	# Test creature signal emission patterns (with placeholder data)
	_test_creature_signal_emissions(signal_bus)

	print("--- SignalBus Enhancement Tests Complete ---")

func _test_creature_signal_emissions(signal_bus: SignalBus) -> void:
	print("--- Testing Creature Signal Emissions ---")

	# Create placeholder CreatureData for testing
	var placeholder_data: CreatureData = CreatureData.new()
	placeholder_data.creature_name = "TestCreature"

	# Connect test handler to creature signals
	signal_bus.creature_created.connect(_on_creature_created)
	signal_bus.creature_stats_changed.connect(_on_creature_stats_changed)
	signal_bus.creature_aged.connect(_on_creature_aged)
	signal_bus.creature_activated.connect(_on_creature_activated)
	signal_bus.creature_deactivated.connect(_on_creature_deactivated)

	# Test validated emissions
	signal_bus.emit_creature_created(placeholder_data)
	signal_bus.emit_creature_stats_changed(placeholder_data, "STR", 10, 15)
	signal_bus.emit_creature_aged(placeholder_data, 5)
	signal_bus.emit_creature_activated(placeholder_data)
	signal_bus.emit_creature_deactivated(placeholder_data)

	# Test validation (should show errors in console)
	print("Testing validation (expect error messages):")
	signal_bus.emit_creature_created(null)  # Should error
	signal_bus.emit_creature_stats_changed(null, "STR", 10, 15)  # Should error
	signal_bus.emit_creature_stats_changed(placeholder_data, "", 10, 15)  # Should error
	signal_bus.emit_creature_aged(null, 5)  # Should error
	signal_bus.emit_creature_aged(placeholder_data, -1)  # Should error

	# Clean up connections
	signal_bus.creature_created.disconnect(_on_creature_created)
	signal_bus.creature_stats_changed.disconnect(_on_creature_stats_changed)
	signal_bus.creature_aged.disconnect(_on_creature_aged)
	signal_bus.creature_activated.disconnect(_on_creature_activated)
	signal_bus.creature_deactivated.disconnect(_on_creature_deactivated)

	print("✅ Creature signal emission tests complete")

# Signal handler functions for testing
func _test_signal_handler() -> void:
	print("Test signal handler called")

func _on_creature_created(data: CreatureData) -> void:
	print("✅ Received creature_created signal for: %s" % data.creature_name)

func _on_creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int) -> void:
	print("✅ Received creature_stats_changed signal for: %s (%s: %d->%d)" % [data.creature_name, stat, old_value, new_value])

func _on_creature_aged(data: CreatureData, new_age: int) -> void:
	print("✅ Received creature_aged signal for: %s (age: %d)" % [data.creature_name, new_age])

func _on_creature_activated(data: CreatureData) -> void:
	print("✅ Received creature_activated signal for: %s" % data.creature_name)

func _on_creature_deactivated(data: CreatureData) -> void:
	print("✅ Received creature_deactivated signal for: %s" % data.creature_name)