extends Node

func _ready() -> void:
	print("=== AgeSystem Test ===")
	await get_tree().process_frame

	# Load AgeSystem
	var age_system = GameCore.get_system("age")
	if not age_system:
		print("❌ FAILED: AgeSystem not loaded")
		get_tree().quit(1)
		return

	print("✅ AgeSystem loaded successfully")

	# Test age category calculation
	var creature: CreatureData = CreatureData.new()
	creature.lifespan_weeks = 100
	creature.age_weeks = 20  # 20% = juvenile

	var age_category: int = creature.get_age_category()
	if age_category == 1:  # Juvenile
		print("✅ Age category calculation working: %d%% = juvenile" % (20))
	else:
		print("❌ Age category calculation failed: got category %d, expected 1" % age_category)

	# Test age modifier
	var modifier: float = creature.get_age_modifier()
	if modifier == 0.8:  # Juvenile modifier
		print("✅ Age modifier calculation working: juvenile = %.1f" % modifier)
	else:
		print("❌ Age modifier calculation failed: got %.2f, expected 0.8" % modifier)

	# Test aging
	var old_age: int = creature.age_weeks
	if age_system.age_creature_by_weeks(creature, 10):
		var new_age: int = creature.age_weeks
		if new_age == old_age + 10:
			print("✅ Creature aging working: %d -> %d weeks" % [old_age, new_age])
		else:
			print("❌ Creature aging failed: expected %d, got %d" % [old_age + 10, new_age])
	else:
		print("❌ Creature aging method failed")

	# Test category transitions
	creature.age_weeks = 0  # Reset
	if age_system.age_creature_to_category(creature, 2):  # Age to adult
		var final_category: int = creature.get_age_category()
		if final_category == 2:
			print("✅ Age category transition working: aged to adult")
		else:
			print("❌ Age category transition failed: got category %d, expected 2" % final_category)
	else:
		print("❌ Age category transition method failed")

	# Test batch aging
	var creatures: Array[CreatureData] = []
	for i in range(10):
		var batch_creature: CreatureData = CreatureData.new()
		batch_creature.lifespan_weeks = 100
		batch_creature.age_weeks = i * 5
		creatures.append(batch_creature)

	var aged_count: int = age_system.age_all_creatures(creatures, 5)
	if aged_count == 10:
		print("✅ Batch aging working: aged %d creatures" % aged_count)
	else:
		print("❌ Batch aging failed: aged %d creatures, expected 10" % aged_count)

	# Test age distribution analysis
	var distribution: Dictionary = age_system.get_age_distribution(creatures)
	if distribution.has("total") and distribution.has("categories"):
		print("✅ Age distribution analysis working: %s" % str(distribution.categories))
	else:
		print("❌ Age distribution analysis failed")

	# Test expiration check
	var old_creature: CreatureData = CreatureData.new()
	old_creature.lifespan_weeks = 50
	old_creature.age_weeks = 60  # Over lifespan

	if age_system.is_creature_expired(old_creature):
		print("✅ Expiration detection working: creature over lifespan")
	else:
		print("❌ Expiration detection failed")

	var young_creature: CreatureData = CreatureData.new()
	young_creature.lifespan_weeks = 100
	young_creature.age_weeks = 20

	if not age_system.is_creature_expired(young_creature):
		print("✅ Expiration detection correct: young creature not expired")
	else:
		print("❌ Expiration detection failed: young creature marked as expired")

	print("\n✅ AgeSystem test complete!")
	get_tree().quit()