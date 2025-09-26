extends Node

func _ready() -> void:
	print("=== CreatureGenerator Test ===")
	await get_tree().process_frame

	# Test basic generation
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	if not creature:
		print("❌ FAILED: Creature generation failed")
		get_tree().quit(1)
		return

	print("✅ Basic creature generation working")
	print("   Generated: %s (%s)" % [creature.creature_name, creature.species_id])

	# Test species validation
	if CreatureGenerator.is_valid_species("scuttleguard"):
		print("✅ Species validation working")
	else:
		print("❌ Species validation failed")

	if not CreatureGenerator.is_valid_species("invalid_species"):
		print("✅ Invalid species rejection working")
	else:
		print("❌ Invalid species rejection failed")

	# Test all species
	var species_list: Array[String] = ["scuttleguard", "stone_sentinel", "wind_dancer", "glow_grub"]
	var species_created: int = 0

	for species in species_list:
		var test_creature: CreatureData = CreatureGenerator.generate_creature_data(species)
		if test_creature and test_creature.species_id == species:
			species_created += 1
		else:
			print("❌ Failed to generate %s" % species)

	print("✅ Generated %d/%d species successfully" % [species_created, species_list.size()])

	# Test generation algorithms
	var uniform_creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard", CreatureGenerator.GenerationType.UNIFORM)
	var gaussian_creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard", CreatureGenerator.GenerationType.GAUSSIAN)

	if uniform_creature and gaussian_creature:
		print("✅ Generation algorithms working")
		print("   UNIFORM stats: STR=%d, CON=%d" % [uniform_creature.strength, uniform_creature.constitution])
		print("   GAUSSIAN stats: STR=%d, CON=%d" % [gaussian_creature.strength, gaussian_creature.constitution])
	else:
		print("❌ Generation algorithms failed")

	# Test performance
	var start_time: int = Time.get_ticks_msec()
	var batch: Array[CreatureData] = []

	for i in range(100):
		var perf_creature: CreatureData = CreatureGenerator.generate_creature_data("glow_grub")
		if perf_creature:
			batch.append(perf_creature)

	var end_time: int = Time.get_ticks_msec()
	var duration: int = end_time - start_time

	if batch.size() == 100 and duration < 100:
		print("✅ Performance target met: %d creatures in %dms" % [batch.size(), duration])
	else:
		print("⚠️ Performance: %d creatures in %dms (target: 100 in <100ms)" % [batch.size(), duration])

	# Test population generation
	var population: Array[CreatureData] = CreatureGenerator.generate_population_data(20)
	if population.size() == 20:
		print("✅ Population generation working: %d creatures" % population.size())

		# Check species distribution
		var species_counts: Dictionary = {}
		for pop_creature in population:
			if not species_counts.has(pop_creature.species_id):
				species_counts[pop_creature.species_id] = 0
			species_counts[pop_creature.species_id] += 1

		print("   Species distribution: %s" % str(species_counts))
	else:
		print("❌ Population generation failed: got %d, expected 20" % population.size())

	print("\n✅ CreatureGenerator test complete!")
	get_tree().quit()