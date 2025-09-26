extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success: bool = true
	print("=== CreatureData/Entity System Test ===")
	await get_tree().process_frame

	# Test 1: CreatureData Creation
	var creature_data: CreatureData = CreatureData.new()
	if not creature_data:
		print("❌ CreatureData creation failed")
		details.append("CreatureData creation failed")
		success = false
		_finalize(success, details)
		return
	print("✅ CreatureData creation successful")

	# Test 2: Property Assignment
	creature_data.creature_name = "Test Creature"
	creature_data.strength = 150
	creature_data.age_weeks = 20
	if creature_data.creature_name != "Test Creature":
		print("❌ Name assignment failed")
		details.append("Name assignment failed")
		success = false
	else:
		print("✅ Name assignment works")

	if creature_data.strength != 150:
		print("❌ Initial strength assignment failed")
		details.append("Initial strength assignment failed")
		success = false
	else:
		print("✅ Strength assignment works")

	# Test 3: Stat Clamping
	creature_data.strength = 2000
	if creature_data.strength != 1000:
		print("❌ Clamping failed: %d" % creature_data.strength)
		details.append("Clamping failed: %d" % creature_data.strength)
		success = false
	else:
		print("✅ Stat clamping works (2000 → 1000)")

	# Test 4: Stat Accessors
	var str_value: int = creature_data.get_stat("STR")
	if str_value != 1000:
		print("❌ Accessor mismatch: %d" % str_value)
		details.append("Accessor mismatch: %d" % str_value)
		success = false
	else:
		print("✅ Stat accessor works correctly")

	# Test 5: Age Category
	creature_data.lifespan_weeks = 100
	creature_data.age_weeks = 20
	if creature_data.get_age_category() != 1:
		print("❌ Age category expected 1 got %d" % creature_data.get_age_category())
		details.append("Age category expected 1 got %d" % creature_data.get_age_category())
		success = false
	else:
		print("✅ Age category calculation works")

	# Test 6: Serialization
	var dict: Dictionary = creature_data.to_dict()
	if not (dict.has("id") and dict.has("creature_name")):
		print("❌ Serialization missing keys")
		details.append("Serialization missing keys")
		success = false
	else:
		print("✅ Serialization works")

	# Test 7: Deserialization
	var restored: CreatureData = CreatureData.from_dict(dict)
	if restored.creature_name != "Test Creature":
		print("❌ Deserialization name mismatch")
		details.append("Deserialization name mismatch")
		success = false
	else:
		print("✅ Deserialization works")

	# Test 8: CreatureEntity Integration
	var creature_entity: CreatureEntity = CreatureEntity.new()
	creature_entity.data = creature_data
	if creature_entity.data.creature_name != "Test Creature":
		print("❌ CreatureEntity assignment failed")
		details.append("CreatureEntity assignment failed")
		success = false
	else:
		print("✅ CreatureEntity integration works")

	if success:
		print("\n✅ All CreatureData/Entity tests passed!")
	else:
		print("\n❌ Some CreatureData/Entity tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()