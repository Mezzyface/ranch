extends Node

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success: bool = true
	print("=== StatSystem Test ===")
	await get_tree().process_frame

	# Test 1: System Loading
	var stat_system = GameCore.get_system("stat")
	if not stat_system:
		print("❌ StatSystem missing")
		details.append("StatSystem missing")
		success = false
		_finalize(success, details)
		return
	print("✅ StatSystem loaded successfully")

	# Test 2: Valid Value Validation
	var valid_value: int = stat_system.validate_stat_value("STR", 500)
	if valid_value != 500:
		print("❌ Validation altered valid value: %d" % valid_value)
		details.append("Validation altered valid value: %d" % valid_value)
		success = false
	else:
		print("✅ Valid stat value passes through unchanged")

	# Test 3: High Value Clamping
	var invalid_clamped: int = stat_system.validate_stat_value("STR", 1500)
	if invalid_clamped != 1000:
		print("❌ Validation failed to clamp high: %d" % invalid_clamped)
		details.append("Validation failed to clamp high: %d" % invalid_clamped)
		success = false
	else:
		print("✅ High stat value clamped correctly (1500 → 1000)")

	# Test 4: Stat Breakdown
	var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	var breakdown: Dictionary = stat_system.get_stat_breakdown(creature, "STR")
	var breakdown_valid = true
	for required_key in ["base","final","tier","age_modifier"]:
		if not breakdown.has(required_key):
			print("❌ Breakdown missing key: %s" % required_key)
			details.append("Breakdown missing key: %s" % required_key)
			success = false
			breakdown_valid = false
	if breakdown_valid:
		print("✅ Stat breakdown contains all required keys")

	# Test 5: Extreme Value Clamping
	var over: int = stat_system.validate_stat_value("STR", 5000)
	if over != 1000:
		print("❌ Over-clamp failed: %d" % over)
		details.append("Over-clamp failed: %d" % over)
		success = false
	else:
		print("✅ Extreme high value clamped correctly (5000 → 1000)")

	var under: int = stat_system.validate_stat_value("STR", -50)
	if under != 1:
		print("❌ Under-clamp failed: %d" % under)
		details.append("Under-clamp failed: %d" % under)
		success = false
	else:
		print("✅ Negative value clamped correctly (-50 → 1)")

	if success:
		print("\n✅ All StatSystem tests passed!")
	else:
		print("\n❌ Some StatSystem tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()