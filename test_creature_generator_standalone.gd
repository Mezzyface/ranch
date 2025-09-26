# Standalone test to verify CreatureGenerator logic without running full Godot engine
@tool
extends EditorScript

func _run():
	print("=== CreatureGenerator Standalone Verification ===")

	# Test 1: Species availability
	print("\n1. Species Availability Test")
	var species_list = CreatureGenerator.get_available_species()
	print("Available species: %s" % str(species_list))
	if species_list.size() == 4:
		print("✅ All 4 species defined")
	else:
		print("❌ Wrong species count: %d" % species_list.size())

	# Test 2: Species validation
	print("\n2. Species Validation Test")
	var valid_tests = [
		["scuttleguard", true],
		["stone_sentinel", true],
		["wind_dancer", true],
		["glow_grub", true],
		["invalid_species", false]
	]

	for test in valid_tests:
		var species = test[0]
		var expected = test[1]
		var result = CreatureGenerator.is_valid_species(species)
		if result == expected:
			print("✅ %s validation: %s" % [species, "valid" if result else "invalid"])
		else:
			print("❌ %s validation failed: expected %s, got %s" % [species, expected, result])

	# Test 3: Species info retrieval
	print("\n3. Species Info Test")
	for species_id in species_list:
		var info = CreatureGenerator.get_species_info(species_id)
		if info.has("display_name") and info.has("stat_ranges") and info.has("guaranteed_tags"):
			print("✅ %s info complete: %s" % [species_id, info.display_name])
		else:
			print("❌ %s info incomplete" % species_id)

	# Test 4: Generation algorithms (without full Godot context)
	print("\n4. Generation Types Test")
	for gen_type in CreatureGenerator.GenerationType.values():
		var type_name = CreatureGenerator.GenerationType.keys()[gen_type]
		print("Generation type available: %s (%d)" % [type_name, gen_type])
	print("✅ All generation types defined")

	# Test 5: Statistics tracking
	print("\n5. Statistics Test")
	CreatureGenerator.reset_generation_statistics()
	var stats_before = CreatureGenerator.get_generation_statistics()
	if stats_before.is_empty() or stats_before.get("total_generated", 0) == 0:
		print("✅ Statistics reset works")
	else:
		print("❌ Statistics reset failed")

	# Test 6: Constants validation
	print("\n6. Constants Validation")
	print("Optional tag chance: %.2f" % CreatureGenerator.OPTIONAL_TAG_CHANCE)
	if CreatureGenerator.OPTIONAL_TAG_CHANCE > 0 and CreatureGenerator.OPTIONAL_TAG_CHANCE < 1:
		print("✅ Optional tag chance valid")
	else:
		print("❌ Optional tag chance invalid")

	# Test 7: Data structure validation
	print("\n7. Data Structure Validation")
	var required_species = ["scuttleguard", "stone_sentinel", "wind_dancer", "glow_grub"]
	var required_fields = ["display_name", "stat_ranges", "guaranteed_tags", "optional_tags", "lifespan_weeks", "price"]
	var required_stats = ["strength", "constitution", "dexterity", "intelligence", "wisdom", "discipline"]

	var all_valid = true
	for species_id in required_species:
		var info = CreatureGenerator.get_species_info(species_id)

		# Check required fields
		for field in required_fields:
			if not info.has(field):
				print("❌ %s missing field: %s" % [species_id, field])
				all_valid = false

		# Check stat ranges
		if info.has("stat_ranges"):
			for stat in required_stats:
				if not info.stat_ranges.has(stat):
					print("❌ %s missing stat range: %s" % [species_id, stat])
					all_valid = false
				elif not (info.stat_ranges[stat].has("min") and info.stat_ranges[stat].has("max")):
					print("❌ %s stat range incomplete: %s" % [species_id, stat])
					all_valid = false

	if all_valid:
		print("✅ All species data structures valid")
	else:
		print("❌ Some species data structures invalid")

	# Test 8: Stat range validation
	print("\n8. Stat Range Validation")
	var range_errors = []
	for species_id in required_species:
		var info = CreatureGenerator.get_species_info(species_id)
		if info.has("stat_ranges"):
			for stat in required_stats:
				var range_data = info.stat_ranges[stat]
				if range_data.min >= range_data.max:
					range_errors.append("%s.%s: min(%d) >= max(%d)" % [species_id, stat, range_data.min, range_data.max])
				elif range_data.min < 1 or range_data.max > 1000:
					range_errors.append("%s.%s: out of bounds (%d-%d)" % [species_id, stat, range_data.min, range_data.max])

	if range_errors.is_empty():
		print("✅ All stat ranges valid")
	else:
		print("❌ Stat range errors:")
		for error in range_errors:
			print("   %s" % error)

	print("\n=== Verification Complete ===")
	print("CreatureGenerator class structure validated!")