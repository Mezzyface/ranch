extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== Species System Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var species_system = GameCore.get_system("species")
	if not species_system:
		print("❌ Species system failed to load")
		details.append("Species system not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ Species system loaded successfully")

	# Test 2: Species Collection
	var all_species: Array[String] = species_system.get_all_species()
	if all_species.size() < 4:
		print("❌ Not enough species: only %d found" % all_species.size())
		details.append("Only %d species" % all_species.size())
		success = false
	else:
		print("✅ Found %d species in system" % all_species.size())

	# Test 3: Species Validation
	var validation_failed := false
	for sid in all_species:
		if not species_system.is_valid_species(sid):
			print("❌ Invalid species listed: %s" % sid)
			details.append("Invalid species listed %s" % sid)
			success = false
			validation_failed = true
	if not validation_failed:
		print("✅ All listed species are valid")

	# Test 4: Species Information Retrieval
	var sg: Dictionary = species_system.get_species_info("scuttleguard")
	if sg.is_empty() or not sg.has("stat_ranges"):
		print("❌ Scuttleguard info missing or incomplete")
		details.append("Scuttleguard info missing")
		success = false
	else:
		print("✅ Species info retrieval works (scuttleguard)")

	# Test 5: Category Filtering
	var starters: Array[String] = species_system.get_species_by_category("starter")
	if starters.is_empty():
		print("❌ No starter species found")
		details.append("No starter species")
		success = false
	else:
		print("✅ Found %d starter species" % starters.size())

	# Test 6: Random Species Selection
	var random_species: String = species_system.get_random_species()
	if random_species.is_empty() or not species_system.is_valid_species(random_species):
		print("❌ Random species selection failed")
		details.append("Random species invalid")
		success = false
	else:
		print("✅ Random species selection works (%s)" % random_species)

	# Test 7: CreatureGenerator Integration
	var creature_data: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	if not (creature_data and creature_data.species_id == "scuttleguard"):
		print("❌ CreatureGenerator integration failed")
		details.append("Generator integration failed")
		success = false
	else:
		print("✅ CreatureGenerator integration works")

	# Test 8: Lifespan Validation (check consistency between SpeciesSystem and CreatureGenerator)
	var lifespan_failed := false
	for species_id in all_species:
		var info: Dictionary = species_system.get_species_info(species_id)
		var generated: CreatureData = CreatureGenerator.generate_creature_data(species_id)
		if info.is_empty() or not generated:
			print("❌ Failed to get species info or generate creature for %s" % species_id)
			details.append("Failed to get info for %s" % species_id)
			success = false
			lifespan_failed = true
		elif info.get("lifespan_weeks", 0) != generated.lifespan_weeks:
			print("❌ Lifespan mismatch for %s: system=%d, generated=%d" % [species_id, info.get("lifespan_weeks", 0), generated.lifespan_weeks])
			details.append("Lifespan mismatch %s" % species_id)
			success = false
			lifespan_failed = true
	if not lifespan_failed:
		print("✅ All species have correct lifespans")

	# Final summary
	if success:
		print("\n✅ All Species System tests passed!")
	else:
		print("\n❌ Some Species System tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()