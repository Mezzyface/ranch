extends Node

func _ready() -> void:
	print("=== Global Enums System Test ===")

	# Test 1: Autoload accessibility
	assert(GlobalEnums != null, "GlobalEnums should be accessible as autoload")
	print("✅ GlobalEnums autoload accessible")

	# Test 2: Age category enum values
	assert(GlobalEnums.AgeCategory.BABY == 0, "Baby should be 0")
	assert(GlobalEnums.AgeCategory.JUVENILE == 1, "Juvenile should be 1")
	assert(GlobalEnums.AgeCategory.ADULT == 2, "Adult should be 2")
	assert(GlobalEnums.AgeCategory.ELDER == 3, "Elder should be 3")
	assert(GlobalEnums.AgeCategory.ANCIENT == 4, "Ancient should be 4")
	print("✅ Age category enums defined correctly")

	# Test 3: Stat type enum values
	assert(GlobalEnums.StatType.STRENGTH == 0, "Strength should be 0")
	assert(GlobalEnums.StatType.CONSTITUTION == 1, "Constitution should be 1")
	assert(GlobalEnums.StatType.DEXTERITY == 2, "Dexterity should be 2")
	assert(GlobalEnums.StatType.INTELLIGENCE == 3, "Intelligence should be 3")
	assert(GlobalEnums.StatType.WISDOM == 4, "Wisdom should be 4")
	assert(GlobalEnums.StatType.DISCIPLINE == 5, "Discipline should be 5")
	print("✅ Stat type enums defined correctly")

	# Test 4: String conversion functions
	assert(GlobalEnums.age_category_to_string(GlobalEnums.AgeCategory.ADULT) == "Adult", "Age category to string should work")
	assert(GlobalEnums.string_to_age_category("Adult") == GlobalEnums.AgeCategory.ADULT, "String to age category should work")
	assert(GlobalEnums.stat_type_to_string(GlobalEnums.StatType.STRENGTH) == "strength", "Stat type to string should work")
	assert(GlobalEnums.string_to_stat_type("strength") == GlobalEnums.StatType.STRENGTH, "String to stat type should work")
	print("✅ String conversion functions working")

	# Test 5: Stat tier calculation
	assert(GlobalEnums.get_stat_tier(100) == GlobalEnums.StatTier.WEAK, "Low stat should be WEAK")
	assert(GlobalEnums.get_stat_tier(300) == GlobalEnums.StatTier.BELOW_AVERAGE, "Medium-low stat should be BELOW_AVERAGE")
	assert(GlobalEnums.get_stat_tier(500) == GlobalEnums.StatTier.AVERAGE, "Medium stat should be AVERAGE")
	assert(GlobalEnums.get_stat_tier(700) == GlobalEnums.StatTier.ABOVE_AVERAGE, "Medium-high stat should be ABOVE_AVERAGE")
	assert(GlobalEnums.get_stat_tier(900) == GlobalEnums.StatTier.EXCEPTIONAL, "High stat should be EXCEPTIONAL")
	print("✅ Stat tier calculation working")

	# Test 6: Validation functions
	assert(GlobalEnums.is_valid_age_category(2), "Valid age category should pass")
	assert(not GlobalEnums.is_valid_age_category(10), "Invalid age category should fail")
	assert(GlobalEnums.is_valid_stat_type(3), "Valid stat type should pass")
	assert(not GlobalEnums.is_valid_stat_type(10), "Invalid stat type should fail")
	assert(GlobalEnums.is_valid_stat_value(500), "Valid stat value should pass")
	assert(not GlobalEnums.is_valid_stat_value(2000), "Invalid stat value should fail")
	print("✅ Validation functions working")

	# Test 7: All stat types array
	var all_stats: Array[GlobalEnums.StatType] = GlobalEnums.get_all_stat_types()
	assert(all_stats.size() == 6, "Should have 6 stat types")
	assert(GlobalEnums.StatType.STRENGTH in all_stats, "Should contain STRENGTH")
	assert(GlobalEnums.StatType.DISCIPLINE in all_stats, "Should contain DISCIPLINE")
	print("✅ All stat types array working")

	# Test 8: Species category conversions
	assert(GlobalEnums.species_category_to_string(GlobalEnums.SpeciesCategory.STARTER) == "starter", "Species category to string should work")
	assert(GlobalEnums.string_to_species_category("starter") == GlobalEnums.SpeciesCategory.STARTER, "String to species category should work")
	print("✅ Species category conversions working")

	print("✅ Global Enums System test complete!")
	get_tree().quit(0)