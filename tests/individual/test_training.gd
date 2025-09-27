extends Node

# Test script for TrainingSystem functionality

func _ready() -> void:
	print("=== TRAINING SYSTEM TEST ===")

	# Load required systems
	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")
	var stamina_system = GameCore.get_system("stamina")
	var species_system = GameCore.get_system("species")

	if not training_system:
		push_error("TrainingSystem not loaded")
		get_tree().quit()
		return

	if not collection_system:
		push_error("Collection system not loaded")
		get_tree().quit()
		return

	if not stamina_system:
		push_error("Stamina system not loaded")
		get_tree().quit()
		return

	print("✅ All required systems loaded")

	# Run tests
	test_training_scheduling()
	test_facility_tiers()
	test_training_processing()
	test_batch_training()
	test_performance_target()
	test_integration_with_stamina()
	test_save_load()

	print("=== TRAINING SYSTEM TEST COMPLETE ===")
	get_tree().quit()

func test_training_scheduling() -> void:
	print("\n📋 Testing Training Scheduling...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")

	# Create test creature
	var creature = CreatureData.new()
	creature.id = "test_trainee"
	creature.creature_name = "Training Test"
	creature.species_id = "scuttleguard"
	creature.stamina_current = 100
	creature.stamina_max = 100

	# Add to collection
	collection_system.add_to_active(creature)

	# Test basic training scheduling
	var result = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.PHYSICAL)
	if result.success:
		print("  ✅ Successfully scheduled physical training")
	else:
		print("  ❌ Failed to schedule training: %s" % result.reason)

	# Test duplicate scheduling (should fail)
	var duplicate_result = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.MENTAL)
	if not duplicate_result.success and duplicate_result.reason.contains("already in training"):
		print("  ✅ Correctly prevented duplicate training")
	else:
		print("  ❌ Should have prevented duplicate training")

	# Test training status
	var status = training_system.get_training_status(creature.id)
	if status.status == "scheduled":
		print("  ✅ Training status correctly reported as scheduled")
	else:
		print("  ❌ Training status incorrect: %s" % status.status)

	# Test cancellation
	var cancelled = training_system.cancel_training(creature.id)
	if cancelled:
		print("  ✅ Training successfully cancelled")
	else:
		print("  ❌ Failed to cancel training")

func test_facility_tiers() -> void:
	print("\n🏗️ Testing Facility Tiers...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")

	# Create test creature
	var creature = CreatureData.new()
	creature.id = "test_facility"
	creature.creature_name = "Facility Test"
	creature.species_id = "scuttleguard"
	creature.stamina_current = 100
	creature.stamina_max = 100

	collection_system.add_to_active(creature)

	# Test each facility tier
	var tiers = [
		TrainingSystem.FacilityTier.BASIC,
		TrainingSystem.FacilityTier.ADVANCED,
		TrainingSystem.FacilityTier.ELITE
	]

	for tier in tiers:
		var tier_name = training_system.get_facility_name(tier)
		var available_slots = training_system.get_available_slots(tier)
		print("  📊 %s facility: %d available slots" % [tier_name, available_slots])

		# Schedule training with this tier
		var result = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.DISCIPLINE, tier)
		if result.success:
			print("  ✅ Successfully scheduled training at %s facility" % tier_name)

			# Check slot usage
			var new_slots = training_system.get_available_slots(tier)
			if new_slots == available_slots - 1:
				print("  ✅ Facility slot correctly consumed")
			else:
				print("  ❌ Facility slot not properly tracked")

			# Cancel to free up slot
			training_system.cancel_training(creature.id)
		else:
			print("  ❌ Failed to schedule at %s facility: %s" % [tier_name, result.reason])

func test_training_processing() -> void:
	print("\n⚙️ Testing Training Processing...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")

	# Create test creature
	var creature = CreatureData.new()
	creature.id = "test_processor"
	creature.creature_name = "Processing Test"
	creature.species_id = "scuttleguard"
	creature.stamina_current = 100
	creature.stamina_max = 100
	creature.strength = 100  # Set baseline stats
	creature.constitution = 100

	collection_system.add_to_active(creature)

	# Schedule training
	var result = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.PHYSICAL, TrainingSystem.FacilityTier.ADVANCED)
	if not result.success:
		print("  ❌ Failed to schedule training for processing test")
		return

	# Capture initial stats
	var initial_strength = creature.strength
	var initial_constitution = creature.constitution
	var initial_stamina = creature.stamina_current

	# Get stamina system to simulate weekly processing
	var stamina_system = GameCore.get_system("stamina")
	if not stamina_system:
		print("  ❌ Stamina system not available")
		return

	# Simulate the weekly update by calling the stamina activity processing
	# This will trigger the training through the signal
	var signal_bus = GameCore.get_signal_bus()
	signal_bus.stamina_activity_performed.emit(creature, stamina_system.Activity.TRAINING, 10)

	print("  📊 Processing training activity signal...")

	# Check if training was processed
	var assignments = training_system.get_training_assignments()
	if not assignments.has(creature.id):
		print("  ✅ Training assignment cleared after processing")

		# Check stat gains
		var strength_gained = creature.strength - initial_strength
		var constitution_gained = creature.constitution - initial_constitution

		if strength_gained > 0 and constitution_gained > 0:
			print("  ✅ Stat gains applied: STR +%d, CON +%d" % [strength_gained, constitution_gained])
		else:
			print("  ❌ No stat gains detected")

		# Check completed trainings list
		var completed = training_system.get_completed_trainings()
		if completed.size() > 0:
			print("  ✅ Training recorded in completed list")
		else:
			print("  ❌ Training not recorded as completed")
	else:
		print("  ❌ Training assignment not cleared after processing")

func test_batch_training() -> void:
	print("\n📦 Testing Batch Training...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")

	# Create multiple test creatures
	var creatures: Array[CreatureData] = []
	var requests: Array[Dictionary] = []

	for i in range(5):
		var creature = CreatureData.new()
		creature.id = "batch_test_%d" % i
		creature.creature_name = "Batch Test %d" % i
		creature.species_id = "scuttleguard"
		creature.stamina_current = 100
		creature.stamina_max = 100

		collection_system.add_to_active(creature)
		creatures.append(creature)

		# Create training request
		requests.append({
			"creature_id": creature.id,
			"activity": TrainingSystem.TrainingActivity.MENTAL,
			"facility_tier": TrainingSystem.FacilityTier.BASIC
		})

	# Batch schedule training
	var t0 = Time.get_ticks_msec()
	var batch_result = training_system.batch_schedule_training(requests)
	var dt = Time.get_ticks_msec() - t0

	print("  📊 Batch scheduling results:")
	print("    - Successful: %d" % batch_result.successful)
	print("    - Failed: %d" % batch_result.failed)
	print("    - Time: %d ms" % dt)

	if batch_result.successful == 5 and batch_result.failed == 0:
		print("  ✅ All batch trainings scheduled successfully")
	else:
		print("  ❌ Batch scheduling had failures")
		for error in batch_result.errors:
			print("    - Error: %s" % error)

func test_performance_target() -> void:
	print("\n🚀 Testing Performance Target (100 trainings <100ms)...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")
	training_system.set_performance_mode(true)  # Reduce logging

	# Create 100 test creatures
	var creatures: Array[CreatureData] = []
	var requests: Array[Dictionary] = []

	for i in range(100):
		var creature = CreatureData.new()
		creature.id = "perf_test_%d" % i
		creature.creature_name = "Perf Test %d" % i
		creature.species_id = "scuttleguard"
		creature.stamina_current = 100
		creature.stamina_max = 100

		# Don't add all to active roster (limit is 6), just add to stable
		collection_system.add_to_stable(creature)
		creatures.append(creature)

		# Vary activities and facilities
		var activity = [
			TrainingSystem.TrainingActivity.PHYSICAL,
			TrainingSystem.TrainingActivity.AGILITY,
			TrainingSystem.TrainingActivity.MENTAL,
			TrainingSystem.TrainingActivity.DISCIPLINE
		][i % 4]

		var facility = [
			TrainingSystem.FacilityTier.BASIC,
			TrainingSystem.FacilityTier.BASIC,  # More basic slots
			TrainingSystem.FacilityTier.ADVANCED,
			TrainingSystem.FacilityTier.ELITE
		][i % 4]

		requests.append({
			"creature_id": creature.id,
			"activity": activity,
			"facility_tier": facility
		})

	# Measure batch scheduling performance
	var t0 = Time.get_ticks_msec()
	var batch_result = training_system.batch_schedule_training(requests)
	var dt = Time.get_ticks_msec() - t0

	print("  📊 Performance test results:")
	print("    - Scheduled: %d trainings" % batch_result.successful)
	print("    - Time: %d ms" % dt)
	print("    - Target: <100ms")

	if dt < 100:
		print("  ✅ Performance target met (%d ms < 100ms)" % dt)
	else:
		print("  ⚠️ Performance target missed (%d ms >= 100ms)" % dt)

	training_system.set_performance_mode(false)  # Re-enable logging

func test_integration_with_stamina() -> void:
	print("\n🔋 Testing Stamina Integration...")

	var training_system = GameCore.get_system("training")
	var stamina_system = GameCore.get_system("stamina")
	var collection_system = GameCore.get_system("collection")

	# Create low-stamina creature
	var creature = CreatureData.new()
	creature.id = "low_stamina_test"
	creature.creature_name = "Low Stamina Test"
	creature.species_id = "scuttleguard"
	creature.stamina_current = 5  # Too low for training
	creature.stamina_max = 100

	collection_system.add_to_active(creature)

	# Try to schedule training with insufficient stamina
	var result = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.PHYSICAL)
	if not result.success and result.reason.contains("stamina"):
		print("  ✅ Correctly blocked training due to insufficient stamina")
	else:
		print("  ❌ Should have blocked training due to insufficient stamina")

	# Restore stamina and try again
	stamina_system.set_stamina(creature, 100)
	var result2 = training_system.schedule_training(creature, TrainingSystem.TrainingActivity.PHYSICAL)
	if result2.success:
		print("  ✅ Training allowed after stamina restoration")
	else:
		print("  ❌ Training blocked despite sufficient stamina: %s" % result2.reason)

func test_save_load() -> void:
	print("\n💾 Testing Save/Load Functionality...")

	var training_system = GameCore.get_system("training")
	var collection_system = GameCore.get_system("collection")

	# Create test creature and schedule training
	var creature = CreatureData.new()
	creature.id = "save_test"
	creature.creature_name = "Save Test"
	creature.species_id = "scuttleguard"
	creature.stamina_current = 100
	creature.stamina_max = 100

	collection_system.add_to_active(creature)
	training_system.schedule_training(creature, TrainingSystem.TrainingActivity.AGILITY, TrainingSystem.FacilityTier.ADVANCED)

	# Save state
	var save_data = training_system.save_state()

	# Verify save data structure
	var expected_keys = ["creature_training_assignments", "completed_trainings", "used_facilities", "statistics"]
	var has_all_keys = true
	for key in expected_keys:
		if not save_data.has(key):
			print("  ❌ Missing save key: %s" % key)
			has_all_keys = false

	if has_all_keys:
		print("  ✅ Save data contains all expected keys")

	# Check that training assignments were saved
	if save_data.has("creature_training_assignments") and save_data.creature_training_assignments.size() > 0:
		print("  ✅ Training assignments saved (%d entries)" % save_data.creature_training_assignments.size())
	else:
		print("  ❌ Training assignments not saved")

	# Clear system and load
	training_system.load_state({})  # Reset
	var empty_assignments = training_system.get_training_assignments()
	if empty_assignments.size() == 0:
		print("  ✅ System correctly reset")

	# Load saved data
	training_system.load_state(save_data)
	var restored_assignments = training_system.get_training_assignments()
	if restored_assignments.size() > 0:
		print("  ✅ Training assignments restored (%d entries)" % restored_assignments.size())
	else:
		print("  ❌ Training assignments not restored")