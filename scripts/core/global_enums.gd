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

# === TAG ENUMS ===

# Tag categories for organization
enum TagCategory {
	SIZE = 0,
	BEHAVIORAL = 1,
	PHYSICAL = 2,
	SENSORY = 3,
	ABILITIES = 4,
	ENVIRONMENTAL = 5
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

# Convert string to age category enum (fail-fast)
static func string_to_age_category(category_str: String) -> AgeCategory:
	match category_str.to_lower():
		"baby": return AgeCategory.BABY
		"juvenile": return AgeCategory.JUVENILE
		"adult": return AgeCategory.ADULT
		"elder": return AgeCategory.ELDER
		"ancient": return AgeCategory.ANCIENT
		_:
			push_error("GlobalEnums.string_to_age_category: Invalid age category '%s'" % category_str)
			return AgeCategory.ADULT  # Return most common but log error

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

# Convert string to stat type enum (fail-fast)
static func string_to_stat_type(stat_str: String) -> StatType:
	match stat_str.to_lower():
		"strength", "str": return StatType.STRENGTH
		"constitution", "con": return StatType.CONSTITUTION
		"dexterity", "dex": return StatType.DEXTERITY
		"intelligence", "int": return StatType.INTELLIGENCE
		"wisdom", "wis": return StatType.WISDOM
		"discipline", "dis": return StatType.DISCIPLINE
		_:
			push_error("GlobalEnums.string_to_stat_type: Invalid stat type '%s'" % stat_str)
			return StatType.STRENGTH  # Return fallback but log error

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

# Convert species category enum to string (fail-fast)
static func species_category_to_string(category: SpeciesCategory) -> String:
	match category:
		SpeciesCategory.STARTER: return "starter"
		SpeciesCategory.COMMON: return "common"
		SpeciesCategory.UNCOMMON: return "uncommon"
		SpeciesCategory.RARE: return "rare"
		SpeciesCategory.LEGENDARY: return "legendary"
		SpeciesCategory.PREMIUM: return "premium"
		SpeciesCategory.UTILITY: return "utility"
		_:
			push_error("GlobalEnums.species_category_to_string: Invalid category enum %d" % category)
			return "unknown"

# Convert string to species category enum (fail-fast)
static func string_to_species_category(category_str: String) -> SpeciesCategory:
	match category_str.to_lower():
		"starter": return SpeciesCategory.STARTER
		"common": return SpeciesCategory.COMMON
		"uncommon": return SpeciesCategory.UNCOMMON
		"rare": return SpeciesCategory.RARE
		"legendary": return SpeciesCategory.LEGENDARY
		"premium": return SpeciesCategory.PREMIUM
		"utility": return SpeciesCategory.UTILITY
		_:
			push_error("GlobalEnums.string_to_species_category: Invalid category '%s'" % category_str)
			return SpeciesCategory.COMMON  # Return fallback but log error

# Convert species rarity enum to string (fail-fast)
static func species_rarity_to_string(rarity: SpeciesRarity) -> String:
	match rarity:
		SpeciesRarity.COMMON: return "common"
		SpeciesRarity.UNCOMMON: return "uncommon"
		SpeciesRarity.RARE: return "rare"
		SpeciesRarity.LEGENDARY: return "legendary"
		_:
			push_error("GlobalEnums.species_rarity_to_string: Invalid rarity enum %d" % rarity)
			return "unknown"

# Convert string to species rarity enum (fail-fast)
static func string_to_species_rarity(rarity_str: String) -> SpeciesRarity:
	match rarity_str.to_lower():
		"common": return SpeciesRarity.COMMON
		"uncommon": return SpeciesRarity.UNCOMMON
		"rare": return SpeciesRarity.RARE
		"legendary": return SpeciesRarity.LEGENDARY
		_:
			push_error("GlobalEnums.string_to_species_rarity: Invalid rarity '%s'" % rarity_str)
			return SpeciesRarity.COMMON  # Return fallback but log error

# Convert tag category enum to string
static func tag_category_to_string(category: TagCategory) -> String:
	match category:
		TagCategory.SIZE: return "SIZE"
		TagCategory.BEHAVIORAL: return "BEHAVIORAL"
		TagCategory.PHYSICAL: return "PHYSICAL"
		TagCategory.SENSORY: return "SENSORY"
		TagCategory.ABILITIES: return "ABILITIES"
		TagCategory.ENVIRONMENTAL: return "ENVIRONMENTAL"
		_: return "UNKNOWN"

# Convert string to tag category enum (fail-fast)
static func string_to_tag_category(category_str: String) -> TagCategory:
	match category_str.to_upper():
		"SIZE": return TagCategory.SIZE
		"BEHAVIORAL": return TagCategory.BEHAVIORAL
		"PHYSICAL": return TagCategory.PHYSICAL
		"SENSORY": return TagCategory.SENSORY
		"ABILITIES": return TagCategory.ABILITIES
		"ENVIRONMENTAL": return TagCategory.ENVIRONMENTAL
		_:
			push_error("GlobalEnums.string_to_tag_category: Invalid category '%s'" % category_str)
			return TagCategory.PHYSICAL  # Return fallback but log error

# Validation functions (fail-fast)
static func is_valid_age_category(category: int) -> bool:
	return category >= 0 and category <= 4

static func is_valid_stat_type(stat: int) -> bool:
	return stat >= 0 and stat <= 5

static func is_valid_stat_value(value: int) -> bool:
	return value >= 1 and value <= 1000

static func is_valid_species_category(category: int) -> bool:
	return category >= 0 and category <= 6

static func is_valid_species_rarity(rarity: int) -> bool:
	return rarity >= 0 and rarity <= 3

static func is_valid_tag_category(category: int) -> bool:
	return category >= 0 and category <= 5

# Enhanced validation with error logging
static func validate_age_category(category: int, context: String = "") -> bool:
	if not is_valid_age_category(category):
		push_error("GlobalEnums: Invalid age category %d in %s" % [category, context])
		return false
	return true

static func validate_stat_type(stat: int, context: String = "") -> bool:
	if not is_valid_stat_type(stat):
		push_error("GlobalEnums: Invalid stat type %d in %s" % [stat, context])
		return false
	return true

static func validate_species_category(category: int, context: String = "") -> bool:
	if not is_valid_species_category(category):
		push_error("GlobalEnums: Invalid species category %d in %s" % [category, context])
		return false
	return true