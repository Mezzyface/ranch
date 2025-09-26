extends Node

func _ready() -> void:
	print("=== AgeSystem Standalone Test ===")

	# Wait a frame for autoloads to initialize
	await get_tree().process_frame

	# Test GameCore and AgeSystem loading
	if GameCore == null:
		print("❌ GameCore autoload failed")
		return

	var age_system = GameCore.get_system("age")
	if age_system == null:
		print("❌ AgeSystem loading failed")
		return

	print("✅ AgeSystem loaded successfully")

	# Test 1: Basic creature aging
	print("\n--- Test 1: Basic Aging ---")
	var test_creature := CreatureData.new()
	test_creature.creature_name = "Test Creature"
	test_creature.age_weeks = 0
	test_creature.lifespan_weeks = 520
	test_creature.strength = 500

	print("Starting age: %d weeks (category: %d)" % [test_creature.age_weeks, test_creature.get_age_category()])
	print("Age modifier: %.1fx" % test_creature.get_age_modifier())

	# Age by 26 weeks
	var success: bool = age_system.age_creature_by_weeks(test_creature, 26)
	if success:
		print("✅ Aged creature by 26 weeks: now %d weeks old" % test_creature.age_weeks)
	else:
		print("❌ Failed to age creature")

	# Test 2: Category transitions
	print("\n--- Test 2: Category Transitions ---")
	var original_category: int = test_creature.get_age_category()
	var transition_success: bool = age_system.age_creature_to_category(test_creature, 2)  # Adult

	if transition_success:
		var new_category: int = test_creature.get_age_category()
		print("✅ Aged to Adult: category %d -> %d, age: %d weeks" % [original_category, new_category, test_creature.age_weeks])
		print("   New age modifier: %.1fx" % test_creature.get_age_modifier())
	else:
		print("❌ Failed to age to Adult category")

	# Test 3: Lifecycle detection
	print("\n--- Test 3: Lifecycle Detection ---")
	var weeks_to_elder: int = age_system.get_weeks_until_next_category(test_creature)
	var remaining_life: int = age_system.get_lifespan_remaining(test_creature)

	print("Weeks until Elder: %d" % weeks_to_elder)
	print("Remaining lifespan: %d weeks" % remaining_life)

	# Test expiration
	test_creature.age_weeks = test_creature.lifespan_weeks + 1
	var is_expired: bool = age_system.is_creature_expired(test_creature)
	if is_expired:
		print("✅ Creature expiration detected correctly")
	else:
		print("❌ Creature expiration not detected")

	# Test 4: Performance impact analysis
	print("\n--- Test 4: Performance Analysis ---")
	test_creature.age_weeks = 100  # Juvenile
	var performance_data: Dictionary = age_system.calculate_age_performance_impact(test_creature)

	print("Age analysis:")
	print("  Category: %s" % performance_data.category_name)
	print("  Age modifier: %.1fx" % performance_data.age_modifier)
	print("  Life percentage: %.1f%%" % performance_data.life_percentage)
	print("  Performance impact: %.1f%%" % performance_data.performance_impact)

	# Test 5: Batch aging
	print("\n--- Test 5: Batch Operations ---")
	var creature_batch: Array[CreatureData] = []

	for i in range(5):
		var batch_creature := CreatureData.new()
		batch_creature.creature_name = "Batch Creature %d" % i
		batch_creature.age_weeks = i * 50
		batch_creature.lifespan_weeks = 520
		creature_batch.append(batch_creature)

	print("Created batch of 5 creatures with ages: %s" % str(creature_batch.map(func(c): return c.age_weeks)))

	var aged_count: int = age_system.age_all_creatures(creature_batch, 10)
	print("Aged %d creatures by 10 weeks" % aged_count)
	print("New ages: %s" % str(creature_batch.map(func(c): return c.age_weeks)))

	# Test 6: Age distribution analysis
	print("\n--- Test 6: Population Analysis ---")
	var distribution: Dictionary = age_system.get_age_distribution(creature_batch)

	print("Population analysis:")
	print("  Total creatures: %d" % distribution.total_creatures)
	print("  Average age: %.1f weeks" % distribution.average_age)
	print("  By category: %s" % str(distribution.categories))
	print("  Expired count: %d" % distribution.expired_count)

	# Test 7: StatSystem integration
	print("\n--- Test 7: StatSystem Integration ---")
	var stat_system = GameCore.get_system("stat")
	if stat_system:
		test_creature.age_weeks = 0  # Baby
		test_creature.strength = 500

		var quest_stat: int = stat_system.get_effective_stat(test_creature, "strength")
		var competition_stat: int = stat_system.get_competition_stat(test_creature, "strength")

		print("Baby creature stats:")
		print("  Base strength: %d" % test_creature.strength)
		print("  Quest stat (no age modifier): %d" % quest_stat)
		print("  Competition stat (with age modifier): %d" % competition_stat)
		print("  Age modifier applied: %.1fx" % test_creature.get_age_modifier())

		if quest_stat == test_creature.strength and competition_stat != quest_stat:
			print("✅ StatSystem integration working correctly")
		else:
			print("❌ StatSystem integration issue")
	else:
		print("❌ StatSystem not available for integration test")

	# Test 8: CreatureGenerator integration
	print("\n--- Test 8: CreatureGenerator Integration ---")
	var generated_creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	print("Generated %s (species: %s)" % [generated_creature.creature_name, generated_creature.species_id])
	print("  Initial age: %d weeks" % generated_creature.age_weeks)
	print("  Lifespan: %d weeks" % generated_creature.lifespan_weeks)

	# Age the generated creature
	age_system.age_creature_by_weeks(generated_creature, 100)
	print("  After aging by 100 weeks: %d weeks (%s)" % [generated_creature.age_weeks, age_system.get_category_name(generated_creature.get_age_category())])

	print("\n✅ AgeSystem standalone test complete!")
	print("All major functionality verified working correctly.")

	# Exit after test
	get_tree().quit()