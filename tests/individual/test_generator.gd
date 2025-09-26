extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== CreatureGenerator Test ===")
	await get_tree().process_frame

	# Test 1: Basic Creature Generation
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	if not creature:
		print("❌ Basic creature generation failed")
		details.append("Basic generation failed")
		success = false
		_finalize(success, details)
		return
	print("✅ Basic creature generation works")

	# Test 2: Species Validation
	if not CreatureGenerator.is_valid_species("scuttleguard"):
		print("❌ Valid species validation failed")
		details.append("Species validation failed")
		success = false
	else:
		print("✅ Valid species validation works")

	if CreatureGenerator.is_valid_species("invalid_species"):
		print("❌ Invalid species incorrectly accepted")
		details.append("Invalid species accepted")
		success = false
	else:
		print("✅ Invalid species correctly rejected")

	# Test 3: All Species Generation
	var species_list: Array[String] = ["scuttleguard","stone_sentinel","wind_dancer","glow_grub"]
	var all_species_valid := true
	for s in species_list:
		var tc: CreatureData = CreatureGenerator.generate_creature_data(s)
		if not (tc and tc.species_id == s):
			details.append("Failed to generate %s" % s)
			success = false
			all_species_valid = false
	if all_species_valid:
		print("✅ All 4 species generate correctly")
	else:
		print("❌ Some species failed to generate")

	# Test 4: Generation Algorithm Variants
	var uniform_creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard", CreatureGenerator.GenerationType.UNIFORM)
	var gaussian_creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard", CreatureGenerator.GenerationType.GAUSSIAN)
	if not (uniform_creature and gaussian_creature):
		print("❌ Algorithm generation variants failed")
		details.append("Algorithm generation failed")
		success = false
	else:
		print("✅ Generation algorithm variants work (UNIFORM, GAUSSIAN)")

	# Test 5: Performance Measurement
	var start_time: int = Time.get_ticks_msec()
	var batch: Array[CreatureData] = []
	for i in range(100):
		var perf: CreatureData = CreatureGenerator.generate_creature_data("glow_grub")
		if perf:
			batch.append(perf)
	var duration: int = Time.get_ticks_msec() - start_time

	if batch.size() != 100:
		print("❌ Performance test failed - only generated %d/100 creatures" % batch.size())
		details.append("Performance: %d in %dms" % [batch.size(), duration])
		success = false
	elif duration < 100:
		print("✅ Performance target met (100 creatures in %dms < 100ms)" % duration)
	else:
		print("⚠️  Performance target exceeded (100 creatures in %dms >= 100ms)" % duration)
		details.append("Performance: %d in %dms" % [batch.size(), duration])
		# Not marking as failure for performance, just noting

	# Test 6: Population Generation
	var population: Array[CreatureData] = CreatureGenerator.generate_population_data(20)
	if population.size() != 20:
		print("❌ Population generation failed - expected 20 got %d" % population.size())
		details.append("Population size mismatch %d" % population.size())
		success = false
	else:
		print("✅ Population generation works (20 random creatures)")

	# Final summary
	if success:
		print("\n✅ All CreatureGenerator tests passed!")
	else:
		print("\n❌ Some CreatureGenerator tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()