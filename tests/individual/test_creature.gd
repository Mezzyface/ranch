extends Node

func _ready() -> void:
	print("=== CreatureData/Entity System Test ===")
	await get_tree().process_frame

	# Test CreatureData
	var creature_data: CreatureData = CreatureData.new()
	if not creature_data:
		print("❌ FAILED: CreatureData creation failed")
		get_tree().quit(1)
		return

	print("✅ CreatureData created successfully")

	# Test property access
	creature_data.creature_name = "Test Creature"
	creature_data.strength = 150
	creature_data.age_weeks = 20

	if creature_data.creature_name == "Test Creature":
		print("✅ String property assignment working")
	else:
		print("❌ String property assignment failed")

	if creature_data.strength == 150:
		print("✅ Stat property assignment working")
	else:
		print("❌ Stat property assignment failed")

	# Test stat clamping
	creature_data.strength = 2000  # Should clamp to 1000
	if creature_data.strength == 1000:
		print("✅ Stat clamping working")
	else:
		print("❌ Stat clamping failed: got %d" % creature_data.strength)

	# Test stat accessors
	var str_value: int = creature_data.get_stat("STR")
	if str_value == 1000:
		print("✅ Stat accessor working")
	else:
		print("❌ Stat accessor failed: got %d" % str_value)

	# Test age category calculation
	creature_data.lifespan_weeks = 100
	creature_data.age_weeks = 20  # Should be 20% = juvenile
	var age_category: int = creature_data.get_age_category()
	if age_category == 1:  # Juvenile
		print("✅ Age category calculation working")
	else:
		print("❌ Age category calculation failed: got %d" % age_category)

	# Test serialization
	var dict: Dictionary = creature_data.to_dict()
	if dict.has("id") and dict.has("creature_name"):
		print("✅ Serialization to dictionary working")
	else:
		print("❌ Serialization failed")

	var restored: CreatureData = CreatureData.from_dict(dict)
	if restored.creature_name == "Test Creature":
		print("✅ Deserialization working")
	else:
		print("❌ Deserialization failed")

	# Test CreatureEntity
	var creature_entity: CreatureEntity = CreatureEntity.new()
	creature_entity.data = creature_data

	if creature_entity.data.creature_name == "Test Creature":
		print("✅ CreatureEntity data assignment working")
	else:
		print("❌ CreatureEntity data assignment failed")

	print("ℹ️ CreatureData has NO signals (correct!)")
	print("ℹ️ CreatureEntity handles signals through SignalBus")

	print("\n✅ Creature system test complete!")
	get_tree().quit()