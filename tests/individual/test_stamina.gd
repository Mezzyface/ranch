extends Node

var stamina_system: StaminaSystem
var collection_system
var time_system
var signal_bus: SignalBus

func _ready() -> void:
	print("\n========================================")
	print("STAMINA SYSTEM TEST")
	print("========================================")

	# Initialize core systems
	signal_bus = GameCore.get_signal_bus()
	stamina_system = GameCore.get_system("stamina")
	collection_system = GameCore.get_system("collection")
	time_system = GameCore.get_system("time")

	stamina_system.set_performance_mode(true)

	# Run tests
	test_basic_stamina_operations()
	test_activity_system()
	test_food_restoration()
	test_modifiers()
	test_exhaustion_tracking()
	test_weekly_processing()
	test_performance()
	test_save_load()

	print("\n========================================")
	print("ALL STAMINA TESTS COMPLETED")
	print("========================================")

	get_tree().quit()

func test_basic_stamina_operations() -> void:
	print("\nTesting Basic Stamina Operations...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Test Creature"
	creature.id = "test_basic_%d" % randi()
	creature.stamina_max = 100
	creature.stamina_current = 100

	# Test get/set
	assert(stamina_system.get_stamina(creature) == 100, "Initial stamina should be 100")

	stamina_system.set_stamina(creature, 50)
	assert(stamina_system.get_stamina(creature) == 50, "Stamina should be 50 after set")
	assert(creature.stamina_current == 50, "Creature data should sync")

	# Test clamping
	stamina_system.set_stamina(creature, 200)
	assert(stamina_system.get_stamina(creature) == 100, "Stamina should clamp to max")

	stamina_system.set_stamina(creature, -50)
	assert(stamina_system.get_stamina(creature) == 0, "Stamina should clamp to min")

	print("  ✓ Get/Set operations work correctly")
	print("  ✓ Stamina clamping works")

func test_activity_system() -> void:
	print("\nTesting Activity System...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Activity Test"
	creature.id = "test_activity_%d" % randi()
	creature.stamina_max = 100
	creature.stamina_current = 100

	# Test activity performance
	assert(stamina_system.can_perform_activity(creature, StaminaSystem.Activity.TRAINING),
		"Should be able to perform training with full stamina")

	var success: bool = stamina_system.perform_activity(creature, StaminaSystem.Activity.TRAINING)
	assert(success, "Training activity should succeed")
	assert(stamina_system.get_stamina(creature) == 90, "Stamina should be 90 after training")

	# Test quest activity
	success = stamina_system.perform_activity(creature, StaminaSystem.Activity.QUEST, "Test Quest")
	assert(success, "Quest activity should succeed")
	assert(stamina_system.get_stamina(creature) == 75, "Stamina should be 75 after quest")

	# Test insufficient stamina
	stamina_system.set_stamina(creature, 20)
	assert(not stamina_system.can_perform_activity(creature, StaminaSystem.Activity.BREEDING),
		"Should not be able to breed with low stamina")

	success = stamina_system.perform_activity(creature, StaminaSystem.Activity.BREEDING)
	assert(not success, "Breeding should fail with insufficient stamina")

	print("  ✓ Activity costs work correctly")
	print("  ✓ Activity validation works")
	print("  ✓ Named activities work")

func test_food_restoration() -> void:
	print("\nTesting Food Restoration...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Food Test"
	creature.id = "test_food_%d" % randi()
	creature.stamina_max = 100
	creature.stamina_current = 30

	stamina_system.set_stamina(creature, 30)

	# Test basic food
	stamina_system.apply_food_effect(creature, "basic_food")
	assert(stamina_system.get_stamina(creature) == 40, "Should gain 10 stamina from basic food")

	# Test quality food
	stamina_system.apply_food_effect(creature, "quality_food")
	assert(stamina_system.get_stamina(creature) == 70, "Should gain 30 stamina from quality food")

	# Test stamina potion (full restore)
	stamina_system.apply_food_effect(creature, "stamina_potion")
	assert(stamina_system.get_stamina(creature) == 100, "Stamina potion should restore to max")

	# Test unknown food (defaults to 10)
	stamina_system.set_stamina(creature, 50)
	stamina_system.apply_food_effect(creature, "unknown_food")
	assert(stamina_system.get_stamina(creature) == 60, "Unknown food should restore 10")

	print("  ✓ Food restoration works correctly")
	print("  ✓ Different food types have correct values")
	print("  ✓ Unknown food defaults to 10")

func test_modifiers() -> void:
	print("\nTesting Stamina Modifiers...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Modifier Test"
	creature.id = "test_modifier_%d" % randi()
	creature.stamina_max = 100
	creature.stamina_current = 100

	# Test depletion modifier
	stamina_system.set_depletion_modifier(creature, 0.5)
	stamina_system.deplete_stamina(creature, 20)
	assert(stamina_system.get_stamina(creature) == 90, "50% depletion modifier should halve cost")

	# Test recovery modifier
	stamina_system.set_recovery_modifier(creature, 2.0)
	stamina_system.restore_stamina(creature, 10)
	assert(stamina_system.get_stamina(creature) == 100, "2x recovery modifier should double gain")

	# Test clear modifiers
	stamina_system.clear_modifiers(creature)
	stamina_system.set_stamina(creature, 50)
	stamina_system.deplete_stamina(creature, 10)
	assert(stamina_system.get_stamina(creature) == 40, "No modifier should apply normal cost")

	print("  ✓ Depletion modifiers work")
	print("  ✓ Recovery modifiers work")
	print("  ✓ Clear modifiers works")

func test_exhaustion_tracking() -> void:
	print("\nTesting Exhaustion Tracking...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Exhaustion Test"
	creature.id = "test_exhaustion_%d" % randi()
	creature.stamina_max = 100
	creature.stamina_current = 100

	# Test not exhausted
	assert(not stamina_system.is_exhausted(creature), "Full stamina should not be exhausted")

	# Test exhaustion threshold
	stamina_system.set_stamina(creature, 20)
	assert(stamina_system.is_exhausted(creature), "20 stamina should be exhausted")

	stamina_system.set_stamina(creature, 21)
	assert(not stamina_system.is_exhausted(creature), "21 stamina should not be exhausted")

	# Test exhaustion signal tracking
	stamina_system.set_stamina(creature, 15)
	assert(stamina_system.exhausted_creatures.get(creature.id, false), "Should track exhausted state")

	stamina_system.set_stamina(creature, 50)
	assert(not stamina_system.exhausted_creatures.get(creature.id, false), "Should clear exhausted state")

	print("  ✓ Exhaustion detection works")
	print("  ✓ Exhaustion threshold correct (20)")
	print("  ✓ Exhaustion tracking works")

func test_weekly_processing() -> void:
	print("\nTesting Weekly Processing...")

	# Clear any existing active creatures
	var existing_active = collection_system.get_active_creatures()
	for c in existing_active:
		collection_system.remove_from_active(c.id)

	# Setup test creatures
	var active1: CreatureData = CreatureData.new()
	active1.creature_name = "Active 1"
	active1.id = "test_active1_%d" % randi()
	active1.stamina_current = 100
	active1.stamina_max = 100

	var active2: CreatureData = CreatureData.new()
	active2.creature_name = "Active 2"
	active2.id = "test_active2_%d" % randi()
	active2.stamina_current = 100
	active2.stamina_max = 100

	var stable1: CreatureData = CreatureData.new()
	stable1.creature_name = "Stable 1"
	stable1.id = "test_stable1_%d" % randi()
	stable1.stamina_current = 50
	stable1.stamina_max = 100

	# Add to collection
	collection_system.add_to_stable(active1)
	collection_system.add_to_stable(active2)
	collection_system.add_to_stable(stable1)

	collection_system.add_to_active(active1)
	collection_system.add_to_active(active2)

	# Set initial stamina
	stamina_system.set_stamina(active1, 100)
	stamina_system.set_stamina(active2, 100)
	stamina_system.set_stamina(stable1, 50)

	# Process weekly update
	stamina_system.process_weekly_stamina()

	# Check active creatures depleted
	assert(stamina_system.get_stamina(active1) == 80, "Active creature 1 should lose 20 stamina")
	assert(stamina_system.get_stamina(active2) == 80, "Active creature 2 should lose 20 stamina")

	# Check stable creature recovered
	assert(stamina_system.get_stamina(stable1) == 80, "Stable creature should gain 30 stamina")

	# Test with modifiers
	stamina_system.set_depletion_modifier(active1, 0.5)
	stamina_system.set_recovery_modifier(stable1, 2.0)

	stamina_system.process_weekly_stamina()

	assert(stamina_system.get_stamina(active1) == 70 or stamina_system.get_stamina(active1) == 69,
		"Active with 0.5x modifier should lose 10 (got %d)" % stamina_system.get_stamina(active1))
	assert(stamina_system.get_stamina(stable1) == 100, "Stable with 2x modifier should be at max")

	# Cleanup
	collection_system.remove_from_active(active1.id)
	collection_system.remove_from_active(active2.id)

	print("  ✓ Weekly depletion for active creatures")
	print("  ✓ Weekly recovery for stable creatures")
	print("  ✓ Modifiers apply to weekly processing")

func test_performance() -> void:
	print("\nTesting Performance...")

	# Clear any existing active creatures to make room
	var existing_active = collection_system.get_active_creatures()
	for c in existing_active:
		collection_system.remove_from_active(c.id)

	var creatures: Array[CreatureData] = []

	# Create 100 test creatures
	for i in range(100):
		var creature: CreatureData = CreatureData.new()
		creature.id = "perf_test_%d" % i
		creature.creature_name = "Perf %d" % i
		creature.stamina_current = 100
		creature.stamina_max = 100
		creatures.append(creature)
		collection_system.add_to_stable(creature)

		# Half are active
		if i < 50:
			collection_system.add_to_active(creature)

	# Test update performance
	var t0: int = Time.get_ticks_msec()
	stamina_system.process_weekly_stamina()
	var dt: int = Time.get_ticks_msec() - t0

	assert(dt < 50, "Should process 100 creatures in under 50ms (took %d ms)" % dt)
	print("  ✓ Processed 100 creatures in %d ms (target <50ms)" % dt)

	# Test batch operations
	t0 = Time.get_ticks_msec()
	for creature in creatures:
		stamina_system.deplete_stamina(creature, 10)
	dt = Time.get_ticks_msec() - t0

	assert(dt < 50, "Should deplete 100 creatures in under 50ms (took %d ms)" % dt)
	print("  ✓ Batch depletion of 100 creatures in %d ms" % dt)

	# Cleanup
	for i in range(50):
		collection_system.remove_from_active(creatures[i].id)

func test_save_load() -> void:
	print("\nTesting Save/Load...")

	var creature: CreatureData = CreatureData.new()
	creature.creature_name = "Save Test"
	creature.id = "test_save_%d" % randi()
	creature.stamina_max = 100

	# Setup state
	stamina_system.set_stamina(creature, 75)
	stamina_system.set_depletion_modifier(creature, 0.8)
	stamina_system.set_recovery_modifier(creature, 1.5)
	stamina_system.set_stamina(creature, 15)  # Make exhausted

	# Save state
	var saved_data: Dictionary = stamina_system.save_state()

	# Clear and verify cleared
	stamina_system.creature_stamina.clear()
	stamina_system.depletion_modifiers.clear()
	stamina_system.recovery_modifiers.clear()
	stamina_system.exhausted_creatures.clear()

	assert(stamina_system.creature_stamina.is_empty(), "Stamina should be cleared")

	# Load state
	stamina_system.load_state(saved_data)

	# Verify restored
	assert(stamina_system.creature_stamina.has(creature.id), "Creature stamina should be restored")
	assert(stamina_system.creature_stamina[creature.id] == 15, "Stamina value should be restored")
	assert(stamina_system.depletion_modifiers[creature.id] == 0.8, "Depletion modifier should be restored")
	assert(stamina_system.recovery_modifiers[creature.id] == 1.5, "Recovery modifier should be restored")
	assert(stamina_system.exhausted_creatures[creature.id] == true, "Exhausted state should be restored")

	print("  ✓ Save state works")
	print("  ✓ Load state works")
	print("  ✓ All data preserved correctly")