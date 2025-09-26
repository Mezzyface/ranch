extends Node

func _ready() -> void:
	print("=== StatSystem Test ===")
	await get_tree().process_frame

	# Load StatSystem
	var stat_system = GameCore.get_system("stat")
	if not stat_system:
		print("❌ FAILED: StatSystem not loaded")
		get_tree().quit(1)
		return

	print("✅ StatSystem loaded successfully")

	# Test stat validation
	var valid_result: Dictionary = stat_system.validate_stat_value("STR", 500)
	if valid_result.valid:
		print("✅ Stat validation working for valid values")
	else:
		print("❌ Stat validation failed for valid values")

	var invalid_result: Dictionary = stat_system.validate_stat_value("STR", 1500)
	if not invalid_result.valid:
		print("✅ Stat validation correctly rejects invalid values")
	else:
		print("❌ Stat validation failed to reject invalid values")

	# Test stat clamping
	var clamped: int = stat_system.clamp_stat_value(1500)
	if clamped == 1000:
		print("✅ Stat clamping working: %d -> %d" % [1500, clamped])
	else:
		print("❌ Stat clamping failed: expected 1000, got %d" % clamped)

	var clamped_low: int = stat_system.clamp_stat_value(-10)
	if clamped_low == 1:
		print("✅ Lower bound clamping working: -10 -> %d" % clamped_low)
	else:
		print("❌ Lower bound clamping failed: expected 1, got %d" % clamped_low)

	# Test stat breakdown
	var breakdown: Dictionary = stat_system.get_stat_breakdown(750)
	if breakdown.has("tier") and breakdown.has("description"):
		print("✅ Stat breakdown working: %s tier" % breakdown.tier)
	else:
		print("❌ Stat breakdown failed")

	# Test stat caps
	var cap_info: Dictionary = stat_system.get_stat_caps()
	if cap_info.min == 1 and cap_info.max == 1000:
		print("✅ Stat caps correct: %d-%d" % [cap_info.min, cap_info.max])
	else:
		print("❌ Stat caps incorrect: %d-%d" % [cap_info.min, cap_info.max])

	print("\n✅ StatSystem test complete!")
	get_tree().quit()