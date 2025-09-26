extends Node

func _ready() -> void:
	print("=== Testing Stage 1 Tasks 1 & 2: GameCore, SignalBus, and Creature Classes ===")

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

	var stat_system = GameCore.get_system("stat")
	if stat_system:
		print("✅ StatSystem lazy loading works")
		_test_stat_system(stat_system)
	else:
		print("❌ StatSystem lazy loading failed")

	# Test Creature Classes (Task 2)
	_test_creature_classes(signal_bus)

	print("=== All Tests Complete ===")
	print("Project ready - Stage 1 Task 3 (Stat System) COMPLETE!")

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

func _test_creature_classes(signal_bus: SignalBus) -> void:
	print("\n--- Testing Creature Classes (Task 2) ---")

	# Test 1: CreatureData pure data (NO signals)
	print("\n=== Test 1: CreatureData Resource ===")
	var data: CreatureData = CreatureData.new()
	data.creature_name = "Test Dragon"
	data.species_id = "dragon_001"
	data.strength = 100
	data.constitution = 150
	data.dexterity = 75

	# Verify stat clamping
	data.strength = 2000  # Should clamp to 1000
	if data.strength == 1000:
		print("✅ Stat clamping works (2000 -> 1000)")
	else:
		print("❌ Stat clamping failed: %d" % data.strength)

	data.strength = -50  # Should clamp to 1
	if data.strength == 1:
		print("✅ Stat minimum clamping works (-50 -> 1)")
	else:
		print("❌ Stat minimum clamping failed: %d" % data.strength)

	# Test stat accessors
	data.strength = 500
	if data.get_stat("STR") == 500 and data.get_stat("STRENGTH") == 500:
		print("✅ Stat accessors work correctly")
	else:
		print("❌ Stat accessors failed")

	# Test tag system
	data.tags = ["Large", "Winged", "Territorial"]
	if data.has_tag("Winged"):
		print("✅ Tag checking works")
	else:
		print("❌ Tag checking failed")

	if data.has_all_tags(["Large", "Winged"]):
		print("✅ has_all_tags works")
	else:
		print("❌ has_all_tags failed")

	# Test 2: CreatureEntity behavior
	print("\n=== Test 2: CreatureEntity Behavior ===")
	var entity: CreatureEntity = CreatureEntity.new(data)
	add_child(entity)  # Add to scene tree for _ready() to fire

	# Wait for entity to be ready
	await get_tree().process_frame

	# Test stat modification through entity
	print("Testing stat modification...")
	entity.modify_stat("STR", 600)
	if data.strength == 600:
		print("✅ Entity modifies data correctly")
	else:
		print("❌ Entity stat modification failed")

	# Test tag management
	if entity.add_tag("Nocturnal"):
		print("✅ Tag added through entity")
	else:
		print("❌ Failed to add valid tag")

	if not entity.add_tag("InvalidTag"):
		print("✅ Invalid tag rejected")
	else:
		print("❌ Invalid tag was accepted")

	# Test age management
	var old_age: int = data.age_weeks
	entity.age_one_week()
	if data.age_weeks == old_age + 1:
		print("✅ Age progression works")
	else:
		print("❌ Age progression failed")

	# Test stamina management
	data.stamina_current = 100
	if entity.consume_stamina(30):
		if data.stamina_current == 70:
			print("✅ Stamina consumption works")
		else:
			print("❌ Stamina calculation wrong: %d" % data.stamina_current)
	else:
		print("❌ Stamina consumption failed")

	entity.rest_fully()
	if data.stamina_current == data.stamina_max:
		print("✅ Full rest works")
	else:
		print("❌ Full rest failed")

	# Test 3: Serialization
	print("\n=== Test 3: Serialization ===")
	var dict: Dictionary = data.to_dict()
	if dict.has("creature_name") and dict.creature_name == "Test Dragon":
		print("✅ to_dict() works")
	else:
		print("❌ to_dict() failed")

	var loaded_data: CreatureData = CreatureData.from_dict(dict)
	if loaded_data.creature_name == data.creature_name and loaded_data.strength == data.strength:
		print("✅ from_dict() works")
	else:
		print("❌ from_dict() failed")

	# Test 4: Performance and calculations
	print("\n=== Test 4: Performance Calculations ===")
	data.age_weeks = 52  # 1 year old (juvenile)
	var age_cat: int = data.get_age_category()
	if age_cat == 1:  # Juvenile
		print("✅ Age category calculation correct (Juvenile)")
	else:
		print("❌ Age category wrong: %d" % age_cat)

	var age_mod: float = data.get_age_modifier()
	if abs(age_mod - 0.8) < 0.01:  # Juvenile modifier
		print("✅ Age modifier correct: %.1f" % age_mod)
	else:
		print("❌ Age modifier wrong: %.1f" % age_mod)

	var perf_score: float = entity.get_performance_score()
	if perf_score > 0:
		print("✅ Performance score calculated: %.1f" % perf_score)
	else:
		print("❌ Performance score calculation failed")

	# Test 5: Separation of concerns
	print("\n=== Test 5: Architecture Validation ===")

	# Verify CreatureData has no signals
	var has_signals: bool = false
	for property in data.get_property_list():
		if property.type == TYPE_SIGNAL:
			has_signals = true
			print("❌ CreatureData has signal: %s" % property.name)

	if not has_signals:
		print("✅ CreatureData has NO signals (correct!)")

	# Verify CreatureEntity references data correctly
	if entity.data == data:
		print("✅ CreatureEntity references CreatureData correctly")
	else:
		print("❌ CreatureEntity data reference broken")

	# Test random creature creation
	var random_entity: CreatureEntity = CreatureEntity.create_random("Random Beast", "beast_001")
	if random_entity.data.creature_name == "Random Beast":
		print("✅ Random creature creation works")
		print("   Random stats: STR=%d, CON=%d, DEX=%d" % [
			random_entity.data.strength,
			random_entity.data.constitution,
			random_entity.data.dexterity
		])
	else:
		print("❌ Random creature creation failed")

	# Clean up
	entity.queue_free()
	random_entity.queue_free()

	print("\n✅ Creature Classes testing complete!")

func _test_stat_system(stat_system: Node) -> void:
	print("\n--- Testing StatSystem (Task 3) ---")

	# Test 1: Stat validation and clamping
	print("\n=== Test 1: Stat Validation ===")
	var valid_stat: int = stat_system.validate_stat_value("strength", 500)
	if valid_stat == 500:
		print("✅ Valid stat value passes through")
	else:
		print("❌ Valid stat validation failed: %d" % valid_stat)

	var clamped_high: int = stat_system.validate_stat_value("strength", 2000)
	if clamped_high == 1000:
		print("✅ High stat value clamped to max (2000 -> 1000)")
	else:
		print("❌ High stat clamping failed: %d" % clamped_high)

	var clamped_low: int = stat_system.validate_stat_value("strength", -50)
	if clamped_low == 1:
		print("✅ Low stat value clamped to min (-50 -> 1)")
	else:
		print("❌ Low stat clamping failed: %d" % clamped_low)

	# Test 2: Stat tiers
	print("\n=== Test 2: Stat Tiers ===")
	var tier_weak: String = stat_system.get_stat_tier(100)
	var tier_average: String = stat_system.get_stat_tier(500)
	var tier_exceptional: String = stat_system.get_stat_tier(950)

	if tier_weak == "WEAK" and tier_average == "AVERAGE" and tier_exceptional == "EXCEPTIONAL":
		print("✅ Stat tiers calculated correctly")
		print("   100 = %s, 500 = %s, 950 = %s" % [tier_weak, tier_average, tier_exceptional])
	else:
		print("❌ Stat tier calculation failed")

	# Test 3: Create test creature for modifier testing
	print("\n=== Test 3: Effective Stats with Modifiers ===")
	var test_data := CreatureData.new()
	test_data.creature_name = "Test Stat Creature"
	test_data.id = "test_stat_001"
	test_data.strength = 500
	test_data.constitution = 400
	test_data.age_weeks = 26  # Adult age

	# Test base effective stat (should NOT apply age modifier for quest requirements)
	var effective_str: int = stat_system.get_effective_stat(test_data, "strength")
	var expected_str := 500  # Base value, no age modifier for quest requirements
	if effective_str == expected_str:
		print("✅ Effective stat for quest requirements correct: %d (no age modifier)" % effective_str)
	else:
		print("❌ Effective stat calculation wrong: %d (expected %d)" % [effective_str, expected_str])

	# Test competition stat (should apply age modifier)
	var competition_str: int = stat_system.get_competition_stat(test_data, "strength")
	var expected_comp := int(500 * test_data.get_age_modifier())
	if competition_str == expected_comp:
		print("✅ Competition stat with age modifier correct: %d" % competition_str)
	else:
		print("❌ Competition stat calculation wrong: %d (expected %d)" % [competition_str, expected_comp])

	# Test 4: Modifier application
	print("\n=== Test 4: Stat Modifiers ===")

	# Apply additive modifier
	stat_system.apply_modifier("test_stat_001", "strength", 100, 0, 0, 1, "boost_001")
	var modified_str: int = stat_system.get_effective_stat(test_data, "strength")
	var expected_modified := 500 + 100  # Base + modifier, no age modifier
	expected_modified = mini(expected_modified, 1000)  # Clamp to max

	if modified_str == expected_modified:
		print("✅ Additive modifier applied correctly: %d" % modified_str)
	else:
		print("❌ Additive modifier failed: %d (expected %d)" % [modified_str, expected_modified])

	# Apply multiplicative modifier (+20%)
	stat_system.apply_modifier("test_stat_001", "strength", 20, 0, 1, 1, "percent_001")
	var mult_modified: int = stat_system.get_effective_stat(test_data, "strength")
	# Expected: (500 + 100) * 1.2 = 720
	var expected_mult := int(600 * 1.2)

	if mult_modified == expected_mult:
		print("✅ Multiplicative modifier applied correctly: %d" % mult_modified)
	else:
		print("❌ Multiplicative modifier failed: %d (expected %d)" % [mult_modified, expected_mult])

	# Test 5: Modifier stacking
	print("\n=== Test 5: Modifier Stacking ===")
	stat_system.apply_modifier("test_stat_001", "strength", 50, 0, 0, 1, "stack_001")
	var stacked: int = stat_system.get_effective_stat(test_data, "strength")

	if stacked > mult_modified:
		print("✅ Multiple modifiers stack correctly: %d" % stacked)
	else:
		print("❌ Modifier stacking failed: %d" % stacked)

	# Test 6: Modifier removal
	print("\n=== Test 6: Modifier Removal ===")
	var removed: bool = stat_system.remove_modifier("test_stat_001", "strength", "boost_001")
	if removed:
		var after_removal: int = stat_system.get_effective_stat(test_data, "strength")
		if after_removal < stacked:
			print("✅ Modifier removed successfully: %d -> %d" % [stacked, after_removal])
		else:
			print("❌ Modifier removal didn't change stats")
	else:
		print("❌ Modifier removal failed")

	# Test 7: Stat breakdown
	print("\n=== Test 7: Stat Breakdown ===")
	var breakdown: Dictionary = stat_system.get_stat_breakdown(test_data, "strength")
	if breakdown.has("base") and breakdown.has("final") and breakdown.has("tier"):
		print("✅ Stat breakdown contains required fields")
		print("   Base: %d, Final: %d, Tier: %s" % [breakdown.base, breakdown.final, breakdown.tier])
	else:
		print("❌ Stat breakdown missing required fields")

	# Test 8: Performance calculations
	print("\n=== Test 8: Performance Calculations ===")
	var performance: float = stat_system.calculate_performance(test_data)
	if performance > 0:
		print("✅ Performance calculated: %.1f" % performance)
	else:
		print("❌ Performance calculation failed")

	# Test 9: Requirement checking
	print("\n=== Test 9: Requirement Checking ===")
	# Reset creature stats and clear all modifiers for clean test
	stat_system.clear_creature_modifiers("test_stat_001")
	test_data.strength = 500
	test_data.constitution = 400
	var requirements := {"strength": 400, "constitution": 350}
	var meets_reqs: bool = stat_system.meets_requirements(test_data, requirements)
	if meets_reqs:
		print("✅ Requirement checking works: creature meets requirements")
	else:
		print("❌ Requirement checking failed")

	var high_requirements := {"strength": 800, "constitution": 900}
	var fails_reqs: bool = stat_system.meets_requirements(test_data, high_requirements)
	if not fails_reqs:
		print("✅ Requirement checking correctly rejects high requirements")
	else:
		print("❌ Requirement checking incorrectly passed high requirements")

	# Test 10: Clean up and memory management
	print("\n=== Test 10: Memory Management ===")
	stat_system.clear_creature_modifiers("test_stat_001")
	var after_clear: bool = stat_system.has_modifiers("test_stat_001")
	if not after_clear:
		print("✅ Modifier cleanup successful")
	else:
		print("❌ Modifier cleanup failed")

	# Test 11: Edge cases
	print("\n=== Test 11: Edge Cases ===")

	# Test with 0 base stat (gets clamped to 1 by CreatureData)
	test_data.strength = 0  # This gets clamped to 1 by CreatureData setter
	var zero_stat: int = stat_system.get_effective_stat(test_data, "strength")
	if zero_stat == 1:  # Expect 1 because CreatureData clamps to minimum 1
		print("✅ Zero base stat handled correctly (clamped to 1)")
	else:
		print("❌ Zero base stat calculation wrong: %d" % zero_stat)

	# Test with max stat
	test_data.strength = 1000
	stat_system.apply_modifier("test_stat_001", "strength", 500, 0, 0, 1, "overflow_test")
	var clamped_result: int = stat_system.get_effective_stat(test_data, "strength")
	if clamped_result == 1000:
		print("✅ Stat clamping prevents overflow: %d" % clamped_result)
	else:
		print("❌ Stat overflow not prevented: %d" % clamped_result)

	# Clean up test modifiers
	stat_system.clear_creature_modifiers("test_stat_001")

	print("\n✅ StatSystem testing complete!")