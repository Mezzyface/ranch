extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== AgeSystem Test ===")
	await get_tree().process_frame

	# Test 1: AgeSystem Loading
	var age_system = GameCore.get_system("age")
	if not age_system:
		print("❌ AgeSystem not loaded")
		details.append("AgeSystem not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ AgeSystem loaded successfully")

	# Test 2: Age Category Calculation
	var creature: CreatureData = CreatureData.new()
	creature.lifespan_weeks = 100
	creature.age_weeks = 20
	if creature.get_age_category() != 1:
		print("❌ Age category calculation failed - expected 1 got %d" % creature.get_age_category())
		details.append("Age category juvenile expected 1 got %d" % creature.get_age_category())
		success = false
	else:
		print("✅ Age category calculation works (20/100 weeks → Juvenile)")

	# Test 3: Age Modifier Calculation
	if creature.get_age_modifier() != 0.8:
		print("❌ Age modifier calculation failed - expected 0.8 got %.2f" % creature.get_age_modifier())
		details.append("Age modifier juvenile expected 0.8 got %.2f" % creature.get_age_modifier())
		success = false
	else:
		print("✅ Age modifier calculation works (Juvenile → 0.8)")

	# Test 4: Age Creature by Weeks
	var old_age: int = creature.age_weeks
	if age_system.age_creature_by_weeks(creature, 10):
		if creature.age_weeks != old_age + 10:
			print("❌ Age by weeks failed - expected %d got %d" % [old_age+10, creature.age_weeks])
			details.append("Age by weeks failed expected %d got %d" % [old_age+10, creature.age_weeks])
			success = false
		else:
			print("✅ Age creature by weeks works (+10 weeks)")
	else:
		print("❌ Age creature by weeks returned false")
		details.append("age_creature_by_weeks returned false")
		success = false

	# Test 5: Age Creature to Category
	creature.age_weeks = 0
	if age_system.age_creature_to_category(creature, 2):
		if creature.get_age_category() != 2:
			print("❌ Age to category transition failed - expected category 2 got %d" % creature.get_age_category())
			details.append("Transition to adult failed got %d" % creature.get_age_category())
			success = false
		else:
			print("✅ Age creature to category works (→ Adult)")
	else:
		print("❌ Age creature to category failed")
		details.append("age_creature_to_category failed")
		success = false

	# Test 6: Batch Aging
	var creatures: Array[CreatureData] = []
	for i in range(10):
		var c: CreatureData = CreatureData.new()
		c.lifespan_weeks = 100
		c.age_weeks = i * 5
		creatures.append(c)
	var aged_count: int = age_system.age_all_creatures(creatures, 5)
	if aged_count != 10:
		print("❌ Batch aging failed - expected 10 aged got %d" % aged_count)
		details.append("Batch aging count mismatch")
		success = false
	else:
		print("✅ Batch aging works (10 creatures aged)")

	# Test 7: Age Distribution Analysis
	var distribution: Dictionary = age_system.get_age_distribution(creatures)
	var dist_valid := true
	for req in ["total_creatures","categories","average_age","expired_count"]:
		if not distribution.has(req):
			details.append("Distribution missing key: %s" % req)
			success = false
			dist_valid = false
	if dist_valid:
		print("✅ Age distribution analysis works")
	else:
		print("❌ Age distribution analysis missing keys")

	# Test 8: Expiration Detection (Old Creature)
	var old_creature: CreatureData = CreatureData.new()
	old_creature.lifespan_weeks = 50
	old_creature.age_weeks = 60
	if not age_system.is_creature_expired(old_creature):
		print("❌ Expiration detection failed for old creature (60/50 weeks)")
		details.append("Expiration detection failed (old)")
		success = false
	else:
		print("✅ Expiration detection works for old creature")

	# Test 9: Expiration Detection (Young Creature)
	var young_creature: CreatureData = CreatureData.new()
	young_creature.lifespan_weeks = 100
	young_creature.age_weeks = 20
	if age_system.is_creature_expired(young_creature):
		print("❌ Expiration detection failed for young creature (20/100 weeks)")
		details.append("Expiration detection failed (young)")
		success = false
	else:
		print("✅ Expiration detection works for young creature")

	# Final summary
	if success:
		print("\n✅ All AgeSystem tests passed!")
	else:
		print("\n❌ Some AgeSystem tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()