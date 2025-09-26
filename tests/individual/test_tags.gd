extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success: bool = true
	print("=== TagSystem Test ===")
	await get_tree().process_frame

	# Test 1: TagSystem Loading
	var tag_system = GameCore.get_system("tag")
	if not tag_system:
		print("❌ TagSystem not loaded")
		details.append("TagSystem not loaded")
		success = false
		_finalize(success, details)
		return
	print("✅ TagSystem loaded successfully")

	# Test 2: Valid Tag Recognition
	if not tag_system.is_valid_tag("Small"):
		print("❌ Valid tag 'Small' not recognized")
		details.append("Valid tag 'Small' not recognized")
		success = false
	else:
		print("✅ Valid tag recognition works")

	# Test 3: Invalid Tag Rejection
	if tag_system.is_valid_tag("InvalidTag"):
		print("❌ Invalid tag incorrectly accepted")
		details.append("Invalid tag accepted")
		success = false
	else:
		print("✅ Invalid tag correctly rejected")

	# Test 4: Valid Tag Combination
	# Choose a genuinely valid combination: Small (size), Winged (physical), Stealthy (ability)
	var valid_combo: Dictionary = tag_system.validate_tag_combination(["Small","Winged","Stealthy"] as Array[String])
	if not valid_combo.valid:
		print("❌ Valid tag combination rejected")
		details.append("Valid combo rejected (expected true)")
		success = false
	else:
		print("✅ Valid tag combination accepted")

	# Test 5: Invalid Tag Combination
	# Invalid: incompatible pair Social + Solitary and missing requirement (Sentient without Problem Solver)
	var invalid_combo: Dictionary = tag_system.validate_tag_combination(["Social","Solitary","Sentient"] as Array[String])
	if invalid_combo.valid:
		print("❌ Invalid tag combination incorrectly accepted")
		details.append("Invalid combo accepted")
		success = false
	else:
		# Expect at least 2 distinct error reasons
		if invalid_combo.errors.size() < 2:
			print("❌ Invalid combo validation incomplete - expected ≥2 errors got %d" % invalid_combo.errors.size())
			details.append("Invalid combo produced too few errors")
			success = false
		else:
			print("✅ Invalid tag combination correctly rejected (%d errors)" % invalid_combo.errors.size())

	# Test 6: Tag Requirements Checking (Positive)
	var creature_data: CreatureData = CreatureData.new()
	# Assign tags individually to avoid potential typed array assignment edge cases
	creature_data.tags.clear()
	creature_data.tags.append("Small")
	creature_data.tags.append("Flies")
	creature_data.tags.append("Winged")
	if not tag_system.meets_tag_requirements(creature_data, ["Small"] as Array[String]):
		print("❌ Tag requirement check failed - 'Small' should be met")
		details.append("Requirement Small not met")
		success = false
	else:
		print("✅ Tag requirement checking works (positive)")

	# Test 7: Tag Requirements Checking (Negative)
	if tag_system.meets_tag_requirements(creature_data, ["Large"] as Array[String]):
		print("❌ Tag requirement check failed - 'Large' should not be met")
		details.append("Incorrectly met Large requirement")
		success = false
	else:
		print("✅ Tag requirement checking works (negative)")

	# Test 8: Creature Filtering by Tags
	var creatures: Array[CreatureData] = []
	for i in range(5):
		var c: CreatureData = CreatureData.new()
		c.creature_name = "Test Creature %d" % i
		c.tags.clear()
		if i < 3:
			c.tags.append("Small")
		else:
			c.tags.append("Large")
		creatures.append(c)
	var filtered: Array[CreatureData] = tag_system.filter_creatures_by_tags(creatures,["Small"] as Array[String],[] as Array[String])
	if filtered.size() != 3:
		print("❌ Tag filtering failed - expected 3 'Small' creatures got %d" % filtered.size())
		details.append("Filter expected 3 got %d" % filtered.size())
		success = false
	else:
		print("✅ Tag filtering works (3/5 creatures with 'Small' tag)")

	# Final summary
	if success:
		print("\n✅ All TagSystem tests passed!")
	else:
		print("\n❌ Some TagSystem tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()