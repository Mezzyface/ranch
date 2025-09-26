extends Node

func _ready() -> void:
	print("=== TagSystem Test ===")
	await get_tree().process_frame

	# Load TagSystem
	var tag_system = GameCore.get_system("tag")
	if not tag_system:
		print("❌ FAILED: TagSystem not loaded")
		get_tree().quit(1)
		return

	print("✅ TagSystem loaded successfully")

	# Test tag validation
	if tag_system.is_valid_tag("Small"):
		print("✅ Valid tag recognition working")
	else:
		print("❌ Valid tag recognition failed")

	if not tag_system.is_valid_tag("InvalidTag"):
		print("✅ Invalid tag rejection working")
	else:
		print("❌ Invalid tag rejection failed")

	# Test tag combination validation
	var valid_combo: Dictionary = tag_system.validate_tag_combination(["Small", "Fast", "Nocturnal"])
	if valid_combo.valid:
		print("✅ Valid tag combination accepted")
	else:
		print("❌ Valid tag combination rejected: %s" % valid_combo.reason)

	# Test mutual exclusion
	var invalid_combo: Dictionary = tag_system.validate_tag_combination(["Small", "Large"])
	if not invalid_combo.valid and invalid_combo.has("conflicts"):
		print("✅ Mutual exclusion working: %s" % invalid_combo.reason)
	else:
		print("❌ Mutual exclusion failed")

	# Test tag requirements
	var creature_data: CreatureData = CreatureData.new()
	creature_data.tags = ["Small", "Flies", "Winged"]

	if tag_system.meets_tag_requirements(creature_data, ["Small"]):
		print("✅ Tag requirements check working")
	else:
		print("❌ Tag requirements check failed")

	if not tag_system.meets_tag_requirements(creature_data, ["Large"]):
		print("✅ Missing tag requirements correctly detected")
	else:
		print("❌ Missing tag requirements not detected")

	# Test creature filtering
	var creatures: Array[CreatureData] = []
	for i in range(5):
		var creature: CreatureData = CreatureData.new()
		creature.creature_name = "Test Creature %d" % i
		creature.tags = ["Small"] if i < 3 else ["Large"]
		creatures.append(creature)

	var filtered: Array[CreatureData] = tag_system.filter_creatures_by_tags(
		creatures,
		["Small"],
		[]
	)

	if filtered.size() == 3:
		print("✅ Creature filtering working: %d creatures match 'Small'" % filtered.size())
	else:
		print("❌ Creature filtering failed: expected 3, got %d" % filtered.size())

	print("\n✅ TagSystem test complete!")
	get_tree().quit()