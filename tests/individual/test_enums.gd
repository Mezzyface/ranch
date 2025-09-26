extends Node

const GlobalEnumsScript = preload("res://scripts/core/global_enums.gd")

signal test_completed(success: bool, details: Array)

func _ready() -> void:
	var details: Array = []
	var success := true
	print("=== Global Enums System Test ===")

	# Test 1: GlobalEnums Autoload Availability
	if GlobalEnums == null:
		print("❌ GlobalEnums autoload missing")
		details.append("GlobalEnums autoload missing")
		success = false
		_finalize(success, details)
		return
	print("✅ GlobalEnums autoload available")

	# Test 2: AgeCategory Enum Values
	var age_enum_valid := true
	for pair in [
		[GlobalEnums.AgeCategory.BABY,0,"BABY"],
		[GlobalEnums.AgeCategory.JUVENILE,1,"JUVENILE"],
		[GlobalEnums.AgeCategory.ADULT,2,"ADULT"],
		[GlobalEnums.AgeCategory.ELDER,3,"ELDER"],
		[GlobalEnums.AgeCategory.ANCIENT,4,"ANCIENT"]]:
		if pair[0] != pair[1]:
			details.append("Age enum %s mismatch" % pair[2])
			success = false
			age_enum_valid = false
	if age_enum_valid:
		print("✅ AgeCategory enum values correct")
	else:
		print("❌ AgeCategory enum values incorrect")

	# Test 3: StatType Enum Values
	var stat_enum_valid := true
	for pair in [
		[GlobalEnums.StatType.STRENGTH,0,"STR"],
		[GlobalEnums.StatType.CONSTITUTION,1,"CON"],
		[GlobalEnums.StatType.DEXTERITY,2,"DEX"],
		[GlobalEnums.StatType.INTELLIGENCE,3,"INT"],
		[GlobalEnums.StatType.WISDOM,4,"WIS"],
		[GlobalEnums.StatType.DISCIPLINE,5,"DIS"]]:
		if pair[0] != pair[1]:
			details.append("Stat enum %s mismatch" % pair[2])
			success = false
			stat_enum_valid = false
	if stat_enum_valid:
		print("✅ StatType enum values correct")
	else:
		print("❌ StatType enum values incorrect")

	# Test 4: Age Category String Conversion
	if GlobalEnumsScript.age_category_to_string(GlobalEnums.AgeCategory.ADULT) != "Adult":
		print("❌ Age category to string conversion failed")
		details.append("Age to string failed")
		success = false
	else:
		print("✅ Age category to string conversion works")

	if GlobalEnumsScript.string_to_age_category("Adult") != GlobalEnums.AgeCategory.ADULT:
		print("❌ String to age category conversion failed")
		details.append("String to age failed")
		success = false
	else:
		print("✅ String to age category conversion works")

	# Test 5: Stat Type String Conversion
	if GlobalEnumsScript.stat_type_to_string(GlobalEnums.StatType.STRENGTH) != "strength":
		print("❌ Stat type to string conversion failed")
		details.append("Stat to string failed")
		success = false
	else:
		print("✅ Stat type to string conversion works")

	if GlobalEnumsScript.string_to_stat_type("strength") != GlobalEnums.StatType.STRENGTH:
		print("❌ String to stat type conversion failed")
		details.append("String to stat failed")
		success = false
	else:
		print("✅ String to stat type conversion works")

	# Test 6: Stat Tier Calculation
	var tier_valid := true
	for pair in [[100,GlobalEnums.StatTier.WEAK],[300,GlobalEnums.StatTier.BELOW_AVERAGE],[500,GlobalEnums.StatTier.AVERAGE],[700,GlobalEnums.StatTier.ABOVE_AVERAGE],[900,GlobalEnums.StatTier.EXCEPTIONAL]]:
		if GlobalEnumsScript.get_stat_tier(pair[0]) != pair[1]:
			details.append("Tier mismatch for %d" % pair[0])
			success = false
			tier_valid = false
	if tier_valid:
		print("✅ Stat tier calculations correct")
	else:
		print("❌ Stat tier calculations incorrect")

	# Test 7: Validation Functions
	if not GlobalEnumsScript.is_valid_age_category(2) or GlobalEnumsScript.is_valid_age_category(10):
		print("❌ Age category validation failed")
		details.append("Age category validation failed")
		success = false
	else:
		print("✅ Age category validation works")

	if not GlobalEnumsScript.is_valid_stat_type(3) or GlobalEnumsScript.is_valid_stat_type(10):
		print("❌ Stat type validation failed")
		details.append("Stat type validation failed")
		success = false
	else:
		print("✅ Stat type validation works")

	if not GlobalEnumsScript.is_valid_stat_value(500) or GlobalEnumsScript.is_valid_stat_value(2000):
		print("❌ Stat value validation failed")
		details.append("Stat value validation failed")
		success = false
	else:
		print("✅ Stat value validation works")

	# Test 8: All Stat Types Collection
	var all_stats: Array = GlobalEnumsScript.get_all_stat_types()
	if all_stats.size() != 6:
		print("❌ All stat types count incorrect: %d" % all_stats.size())
		details.append("All stat types size %d" % all_stats.size())
		success = false
	else:
		print("✅ All stat types collection correct (6 types)")

	# Test 9: Species Category String Conversion
	if GlobalEnumsScript.species_category_to_string(GlobalEnums.SpeciesCategory.STARTER) != "starter":
		print("❌ Species category to string conversion failed")
		details.append("Species category to string failed")
		success = false
	else:
		print("✅ Species category to string conversion works")

	if GlobalEnumsScript.string_to_species_category("starter") != GlobalEnums.SpeciesCategory.STARTER:
		print("❌ String to species category conversion failed")
		details.append("String to species category failed")
		success = false
	else:
		print("✅ String to species category conversion works")

	# Final summary
	if success:
		print("\n✅ All Global Enums tests passed!")
	else:
		print("\n❌ Some Global Enums tests failed")
	_finalize(success, details)

func _finalize(success: bool, details: Array) -> void:
	emit_signal("test_completed", success, details)
	# Wait one frame then quit to ensure clean exit
	await get_tree().process_frame
	get_tree().quit()