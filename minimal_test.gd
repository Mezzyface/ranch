extends Node

func _ready():
	print("=== Minimal CreatureGenerator Test ===")

	# Test class exists and can be accessed
	if CreatureGenerator:
		print("✅ CreatureGenerator class accessible")

		# Test basic species info
		var species_list = CreatureGenerator.get_available_species()
		print("Available species: %s" % str(species_list))

		if species_list.size() == 4:
			print("✅ All 4 species defined")
		else:
			print("❌ Wrong species count: %d" % species_list.size())

		# Test species info retrieval
		var scuttleguard_info = CreatureGenerator.get_species_info("scuttleguard")
		if scuttleguard_info.has("display_name"):
			print("✅ Species info retrieval works: %s" % scuttleguard_info.display_name)
		else:
			print("❌ Species info retrieval failed")

		# Test creature generation (basic)
		var test_creature = CreatureGenerator.generate_creature_data("scuttleguard")
		if test_creature and test_creature.species_id == "scuttleguard":
			print("✅ Basic creature generation works: %s" % test_creature.creature_name)
			print("   STR: %d, CON: %d, DEX: %d" % [test_creature.strength, test_creature.constitution, test_creature.dexterity])
		else:
			print("❌ Basic creature generation failed")

	else:
		print("❌ CreatureGenerator class not found")

	print("=== Test Complete ===")