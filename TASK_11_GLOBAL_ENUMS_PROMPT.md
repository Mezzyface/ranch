# Task 11: Global Enums System Implementation

## Prerequisites
- [ ] Tasks 1-10 completed and all tests passing
- [ ] Run preflight check: `godot --headless --scene tests/preflight_check.tscn` - MUST PASS
- [ ] Run integration test: `godot --headless --scene test_setup.tscn` - Should show 100% pass rate

## Task Overview
Implement the Global Enums System to replace string-based constants throughout the codebase with type-safe enumerations. This system provides centralized enum management, type safety improvements, and better IDE support while maintaining backward compatibility during migration.

## Required Files to Create/Modify

### New Files to Create:
1. `scripts/core/global_enums.gd` - Main GlobalEnums autoload singleton
2. `tests/individual/test_enums.gd` - Individual test file
3. `tests/individual/test_enums.tscn` - Test scene

### Files to Modify:
1. `project.godot` - Add GlobalEnums autoload
2. `test_setup.gd` - Add `_test_global_enums()` function
3. `tests/test_all.gd` - Add enums test to TESTS_TO_RUN array

## Implementation Requirements

### Core Functionality:

#### 1. Global Enums Autoload Singleton
```gdscript
extends Node
# GlobalEnums - Centralized enumeration management for type safety
# This is an autoload singleton providing global access to all game enums

# === CREATURE ENUMS ===

# Age categories for creature lifecycle
enum AgeCategory {
	BABY = 0,      # 0-19% of lifespan
	JUVENILE = 1,  # 20-39% of lifespan
	ADULT = 2,     # 40-59% of lifespan
	ELDER = 3,     # 60-79% of lifespan
	ANCIENT = 4    # 80-100% of lifespan
}

# Stat types for creatures
enum StatType {
	STRENGTH = 0,
	CONSTITUTION = 1,
	DEXTERITY = 2,
	INTELLIGENCE = 3,
	WISDOM = 4,
	DISCIPLINE = 5
}

# Stat tiers for performance classification
enum StatTier {
	WEAK = 0,          # 1-199
	BELOW_AVERAGE = 1, # 200-399
	AVERAGE = 2,       # 400-599
	ABOVE_AVERAGE = 3, # 600-799
	EXCEPTIONAL = 4    # 800-1000
}

# Size categories for creatures
enum SizeCategory {
	SMALL = 0,
	MEDIUM = 1,
	LARGE = 2,
	MASSIVE = 3
}

# Species categories for organization
enum SpeciesCategory {
	STARTER = 0,
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	LEGENDARY = 4,
	PREMIUM = 5,
	UTILITY = 6
}

# Species rarity for shop/generation
enum SpeciesRarity {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	LEGENDARY = 3
}

# Generation types for creature creation
enum GenerationType {
	UNIFORM = 0,   # Equal probability across stat range
	GAUSSIAN = 1,  # Bell curve distribution
	HIGH_ROLL = 2, # Max of two rolls (premium)
	LOW_ROLL = 3   # Min of two rolls (discount)
}

# === QUEST ENUMS ===

# Quest difficulty levels
enum QuestDifficulty {
	TUTORIAL = 0,
	EASY = 1,
	MEDIUM = 2,
	HARD = 3,
	EXPERT = 4
}

# Quest status for progression tracking
enum QuestStatus {
	AVAILABLE = 0,
	ACTIVE = 1,
	COMPLETED = 2,
	FAILED = 3,
	LOCKED = 4
}

# Quest types for categorization
enum QuestType {
	TUTORIAL = 0,
	MAIN = 1,
	SIDE = 2,
	DAILY = 3,
	EVENT = 4
}

# === ECONOMY ENUMS ===

# Currency types
enum CurrencyType {
	GOLD = 0,
	GEMS = 1,
	TOKENS = 2
}

# Item types for inventory
enum ItemType {
	FOOD = 0,
	EQUIPMENT = 1,
	CONSUMABLE = 2,
	MATERIAL = 3,
	KEY_ITEM = 4
}

# Item rarity for drops/shop
enum ItemRarity {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4
}

# === COLLECTION ENUMS ===

# Collection types for organization
enum CollectionType {
	ACTIVE = 0,    # Active roster (limited)
	STABLE = 1,    # Stable collection (unlimited)
	TEMP = 2       # Temporary storage
}

# Collection operations for tracking
enum CollectionOperation {
	ADDED = 0,
	REMOVED = 1,
	MOVED = 2,
	UPDATED = 3
}

# === UTILITY FUNCTIONS ===

# Convert age category enum to string
static func age_category_to_string(category: AgeCategory) -> String:
	match category:
		AgeCategory.BABY: return "Baby"
		AgeCategory.JUVENILE: return "Juvenile"
		AgeCategory.ADULT: return "Adult"
		AgeCategory.ELDER: return "Elder"
		AgeCategory.ANCIENT: return "Ancient"
		_: return "Unknown"

# Convert string to age category enum
static func string_to_age_category(category_str: String) -> AgeCategory:
	match category_str.to_lower():
		"baby": return AgeCategory.BABY
		"juvenile": return AgeCategory.JUVENILE
		"adult": return AgeCategory.ADULT
		"elder": return AgeCategory.ELDER
		"ancient": return AgeCategory.ANCIENT
		_: return AgeCategory.ADULT  # Default fallback

# Convert stat type enum to string
static func stat_type_to_string(stat: StatType) -> String:
	match stat:
		StatType.STRENGTH: return "strength"
		StatType.CONSTITUTION: return "constitution"
		StatType.DEXTERITY: return "dexterity"
		StatType.INTELLIGENCE: return "intelligence"
		StatType.WISDOM: return "wisdom"
		StatType.DISCIPLINE: return "discipline"
		_: return "unknown"

# Convert string to stat type enum
static func string_to_stat_type(stat_str: String) -> StatType:
	match stat_str.to_lower():
		"strength", "str": return StatType.STRENGTH
		"constitution", "con": return StatType.CONSTITUTION
		"dexterity", "dex": return StatType.DEXTERITY
		"intelligence", "int": return StatType.INTELLIGENCE
		"wisdom", "wis": return StatType.WISDOM
		"discipline", "dis": return StatType.DISCIPLINE
		_: return StatType.STRENGTH  # Default fallback

# Get all stat types as array
static func get_all_stat_types() -> Array[StatType]:
	return [
		StatType.STRENGTH,
		StatType.CONSTITUTION,
		StatType.DEXTERITY,
		StatType.INTELLIGENCE,
		StatType.WISDOM,
		StatType.DISCIPLINE
	]

# Get stat tier from value
static func get_stat_tier(value: int) -> StatTier:
	if value < 200:
		return StatTier.WEAK
	elif value < 400:
		return StatTier.BELOW_AVERAGE
	elif value < 600:
		return StatTier.AVERAGE
	elif value < 800:
		return StatTier.ABOVE_AVERAGE
	else:
		return StatTier.EXCEPTIONAL

# Convert stat tier to string
static func stat_tier_to_string(tier: StatTier) -> String:
	match tier:
		StatTier.WEAK: return "WEAK"
		StatTier.BELOW_AVERAGE: return "BELOW_AVERAGE"
		StatTier.AVERAGE: return "AVERAGE"
		StatTier.ABOVE_AVERAGE: return "ABOVE_AVERAGE"
		StatTier.EXCEPTIONAL: return "EXCEPTIONAL"
		_: return "UNKNOWN"

# Convert species category enum to string
static func species_category_to_string(category: SpeciesCategory) -> String:
	match category:
		SpeciesCategory.STARTER: return "starter"
		SpeciesCategory.COMMON: return "common"
		SpeciesCategory.UNCOMMON: return "uncommon"
		SpeciesCategory.RARE: return "rare"
		SpeciesCategory.LEGENDARY: return "legendary"
		SpeciesCategory.PREMIUM: return "premium"
		SpeciesCategory.UTILITY: return "utility"
		_: return "common"

# Convert string to species category enum
static func string_to_species_category(category_str: String) -> SpeciesCategory:
	match category_str.to_lower():
		"starter": return SpeciesCategory.STARTER
		"common": return SpeciesCategory.COMMON
		"uncommon": return SpeciesCategory.UNCOMMON
		"rare": return SpeciesCategory.RARE
		"legendary": return SpeciesCategory.LEGENDARY
		"premium": return SpeciesCategory.PREMIUM
		"utility": return SpeciesCategory.UTILITY
		_: return SpeciesCategory.COMMON

# Validation functions
static func is_valid_age_category(category: int) -> bool:
	return category >= 0 and category <= 4

static func is_valid_stat_type(stat: int) -> bool:
	return stat >= 0 and stat <= 5

static func is_valid_stat_value(value: int) -> bool:
	return value >= 1 and value <= 1000
```

### Project Configuration:

#### 1. Autoload Registration
In `project.godot`, add the GlobalEnums autoload:
```ini
[autoload]
GameCore="*res://scripts/core/game_core.gd"
GlobalEnums="*res://scripts/core/global_enums.gd"
```

### Migration Strategy:

#### 1. Backward Compatibility Layer
The system should provide methods to convert between string constants and enums:

```gdscript
# Example usage in existing systems:
# OLD: creature.age_category = "Adult"
# NEW: creature.age_category = GlobalEnums.AgeCategory.ADULT
# MIGRATION: creature.age_category = GlobalEnums.string_to_age_category("Adult")
```

#### 2. Gradual Migration Approach
1. **Phase 1**: Create GlobalEnums with utility functions
2. **Phase 2**: Update core systems to accept both strings and enums
3. **Phase 3**: Migrate systems one by one to use enums
4. **Phase 4**: Remove string-based fallbacks after full migration

## Testing Requirements

### Individual Test (`tests/individual/test_enums.gd`):
```gdscript
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
```

## Performance Targets
- [ ] Enum access: <1ms for any enum lookup
- [ ] String conversion: <5ms for batch conversions
- [ ] Validation functions: <1ms per validation
- [ ] No performance regression in existing systems

## Success Criteria
- [ ] GlobalEnums autoload accessible throughout codebase
- [ ] All enum types defined with correct values
- [ ] String conversion functions work bidirectionally
- [ ] Validation functions prevent invalid values
- [ ] Individual test passes all scenarios
- [ ] Integration test passes with no regressions
- [ ] No parse errors or warnings
- [ ] Foundation ready for gradual string-to-enum migration

## Future Migration Plan
This system prepares for:
- **Phase 2**: Update StatSystem to accept both strings and StatType enums
- **Phase 3**: Update TagSystem with enum-based tag categories
- **Phase 4**: Update CreatureGenerator with enum parameters
- **Phase 5**: Update SaveSystem with enum serialization
- **Phase 6**: Remove all string-based constants

## Example Usage After Implementation
```gdscript
# Type-safe enum usage
var age: GlobalEnums.AgeCategory = GlobalEnums.AgeCategory.ADULT
var stat: GlobalEnums.StatType = GlobalEnums.StatType.STRENGTH
var tier: GlobalEnums.StatTier = GlobalEnums.get_stat_tier(750)

# String compatibility during migration
var age_from_string: GlobalEnums.AgeCategory = GlobalEnums.string_to_age_category("Adult")
var stat_string: String = GlobalEnums.stat_type_to_string(GlobalEnums.StatType.STRENGTH)

# Validation
if GlobalEnums.is_valid_stat_value(creature.strength):
    var tier: GlobalEnums.StatTier = GlobalEnums.get_stat_tier(creature.strength)
    print("Strength tier: %s" % GlobalEnums.stat_tier_to_string(tier))

# Iterator support
for stat_type in GlobalEnums.get_all_stat_types():
    var stat_name: String = GlobalEnums.stat_type_to_string(stat_type)
    print("Processing stat: %s" % stat_name)
```

## Notes
- GlobalEnums is an autoload singleton for global access without dependencies
- All enums use explicit integer values for save/load stability
- String conversion functions provide migration compatibility
- Validation functions prevent invalid enum usage
- Ready for gradual migration from string constants to type-safe enums
- Foundation supports IDE autocompletion and type checking improvements