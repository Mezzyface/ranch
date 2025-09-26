extends Node

func _ready() -> void:
	print("=== Species System Test ===")

	var species_system = GameCore.get_system("species")
	assert(species_system != null, "Failed to load SpeciesSystem")

	# Test 1: Basic species loading
	var all_species: Array[String] = species_system.get_all_species()
	assert(all_species.size() >= 4, "Should have at least 4 species")
	print("✅ Species loading working (%d species)" % all_species.size())

	# Test 2: Species validation
	for species_id in all_species:
		assert(species_system.is_valid_species(species_id), "Species %s should be valid" % species_id)
	print("✅ Species validation working")

	# Test 3: Species data retrieval
	var scuttleguard_info: Dictionary = species_system.get_species_info("scuttleguard")
	assert(not scuttleguard_info.is_empty(), "Scuttleguard info should not be empty")
	assert(scuttleguard_info.has("stat_ranges"), "Should have stat_ranges")
	print("✅ Species data retrieval working")

	# Test 4: Category organization
	var starter_species: Array[String] = species_system.get_species_by_category("starter")
	assert(starter_species.size() > 0, "Should have starter species")
	print("✅ Category organization working")

	# Test 5: Random species selection
	var random_species: String = species_system.get_random_species()
	assert(not random_species.is_empty(), "Random species should not be empty")
	assert(species_system.is_valid_species(random_species), "Random species should be valid")
	print("✅ Random species selection working")

	# Test 6: CreatureGenerator integration
	var creature_data: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	assert(creature_data != null, "Should generate creature data")
	assert(creature_data.species_id == "scuttleguard", "Should have correct species ID")
	print("✅ CreatureGenerator integration working")

	print("✅ Species System test complete!")
	get_tree().quit(0)