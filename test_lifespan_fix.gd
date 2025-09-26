extends Node

func _ready():
	print("=== Testing Lifespan Property Fix ===")

	# Test each species to ensure lifespan assignment works
	var species_list: Array[String] = ["scuttleguard", "stone_sentinel", "wind_dancer", "glow_grub"]
	var expected_lifespans: Array[int] = [520, 780, 390, 260]

	for i in range(species_list.size()):
		var species_id: String = species_list[i]
		var expected_lifespan: int = expected_lifespans[i]

		print("\n--- Testing %s ---" % species_id)

		# Get species info
		var species_info: Dictionary = CreatureGenerator.get_species_info(species_id)
		print("Species lifespan_weeks: %d" % species_info.lifespan_weeks)

		# Generate creature
		var creature: CreatureData = CreatureGenerator.generate_creature_data(species_id)
		if creature:
			print("Generated creature: %s" % creature.creature_name)
			print("Creature lifespan_weeks: %d" % creature.lifespan_weeks)
			print("Age weeks: %d" % creature.age_weeks)

			# Verify lifespan matches expected
			if creature.lifespan_weeks == expected_lifespan:
				print("✅ Lifespan correctly assigned: %d weeks" % creature.lifespan_weeks)
			else:
				print("❌ Lifespan mismatch: got %d, expected %d" % [creature.lifespan_weeks, expected_lifespan])

			# Test age category calculation
			var age_category: int = creature.get_age_category()
			var age_modifier: float = creature.get_age_modifier()
			print("Age category: %d (modifier: %.1f)" % [age_category, age_modifier])
		else:
			print("❌ Failed to generate creature for %s" % species_id)

	print("\n=== Lifespan Test Complete ===")