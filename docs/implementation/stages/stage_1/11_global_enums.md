# Task 11: Global Enums Setup

## Overview
Create the global enums file that will be used throughout the entire codebase. This provides type safety and prevents typos in string-based systems. With the improved architecture, this remains as an autoload for universal access while integrating properly with GameCore systems.

## Dependencies
- Task 01: GameCore Setup (complete)
- Design document: `enum.md`

## Context
**ARCHITECTURE DECISION**:
- GlobalEnums remains as autoload (NOT GameCore subsystem) for universal access
- Provides type safety across all systems
- GameCore subsystems can access GlobalEnums directly
- Stage 1 uses strings that will migrate to enums in future stages
- Essential for preventing typos and providing autocomplete
- No circular dependencies with GameCore

From `enum.md`:
- All game enums should be in a single global file
- Registered as autoload for easy access
- Provides type safety and autocomplete
- Foundation for future enum-based systems

## Requirements

### Enum Categories to Implement
1. **Core Stats** - StatType
2. **Creature Management** - CreatureState, AgeCategory, CreatureSize
3. **Tag System** - TagCategory, CreatureTag (comprehensive list)
4. **Training System** - TrainingActivity, TrainingFacility
5. **Food System** - FoodType, FoodCategory
6. **Competition System** - CompetitionType, CompetitionTier, CompetitionPlacement
7. **Breeding System** - EggGroup, BreedingQuality
8. **Quest System** - QuestStatus, QuestCategory, RequirementType
9. **Shop System** - VendorType, ShopTier
10. **Time Management** - WeeklyActivity, TimeEvent
11. **UI and System** - UIState, SaveSlot, Rarity

## Implementation Steps

1. **Create Enums Script**
   - Location: `scripts/utils/global_enums.gd`
   - Add all enum definitions from enum.md
   - Include utility functions

2. **Register as Autoload**
   - Project Settings → Autoload
   - Name: "GlobalEnums"
   - Path: res://scripts/utils/global_enums.gd

3. **Test Access**
   - Verify enums accessible from GameCore systems
   - Test autocomplete works
   - Ensure no conflicts

4. **Integration with GameCore**
   - GameCore systems can access GlobalEnums directly
   - No circular dependencies
   - Clean separation of concerns

## Test Criteria

### Unit Tests
- [ ] All enums defined correctly
- [ ] No duplicate values within enums
- [ ] Enums accessible globally
- [ ] Values match design specs
- [ ] Utility functions work correctly

### Integration Tests
- [ ] Can use GlobalEnums.StatType in GameCore systems
- [ ] Can use GlobalEnums.CreatureTag in arrays
- [ ] Can use enums in match statements
- [ ] Can save/load enum values
- [ ] GameCore subsystems access enums without issues

## Code Implementation

### Global Enums - Universal Autoload
```gdscript
# scripts/utils/global_enums.gd
# Global Enums for Creature Collection Game
# This file contains all game enums for type safety and consistency
extends Node

# ============================================================================
# CORE GAME ENUMS
# ============================================================================

# Core Stats
enum StatType {
    STRENGTH,      # STR - Physical power
    CONSTITUTION,  # CON - Health, durability
    DEXTERITY,     # DEX - Speed, agility
    INTELLIGENCE,  # INT - Problem solving
    WISDOM,        # WIS - Awareness, perception
    DISCIPLINE     # DIS - Obedience, reliability
}

# Helper dictionary for stat name conversions
const STAT_NAMES = {
    StatType.STRENGTH: "STR",
    StatType.CONSTITUTION: "CON",
    StatType.DEXTERITY: "DEX",
    StatType.INTELLIGENCE: "INT",
    StatType.WISDOM: "WIS",
    StatType.DISCIPLINE: "DIS"
}

const STAT_FULL_NAMES = {
    StatType.STRENGTH: "Strength",
    StatType.CONSTITUTION: "Constitution",
    StatType.DEXTERITY: "Dexterity",
    StatType.INTELLIGENCE: "Intelligence",
    StatType.WISDOM: "Wisdom",
    StatType.DISCIPLINE: "Discipline"
}

# ============================================================================
# CREATURE MANAGEMENT
# ============================================================================

enum CreatureState {
    ACTIVE,   # Participating in weekly progression
    STABLE    # In stasis, not aging
}

enum AgeCategory {
    BABY,     # 0-10% of lifespan, +50% training, -40% performance
    JUVENILE, # 10-25% of lifespan, +20% training, -20% performance
    ADULT,    # 25-75% of lifespan, normal rates
    ELDER,    # 75-90% of lifespan, -20% training, +wisdom bonus
    ANCIENT   # 90-100% of lifespan, -50% training, +experience bonus
}

enum CreatureSize {
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
    MASSIVE
}

# ============================================================================
# TAG SYSTEM
# ============================================================================

enum TagCategory {
    SIZE,        # Creature size tags
    PHYSICAL,    # Physical traits and abilities
    BEHAVIORAL,  # Behavioral characteristics
    ABILITY,     # Special abilities
    UTILITY      # Utility and work-related tags
}

enum CreatureTag {
    # Size Tags (mutually exclusive)
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
    MASSIVE,

    # Physical Traits
    WINGED,
    FLIES,
    AQUATIC,
    TERRESTRIAL,
    NATURAL_ARMOR,
    CAMOUFLAGE,
    BIPEDAL,
    QUADRUPED,

    # Natural Abilities
    ECHOLOCATION,
    VENOM,
    BIOLUMINESCENT,
    DARK_VISION,
    ENHANCED_HEARING,
    MAGNETIC_SENSE,
    SURE_FOOTED,

    # Behavioral Tags
    TERRITORIAL,
    DOCILE,
    AGGRESSIVE,
    SOCIAL,
    SOLITARY,
    STEALTHY,
    NOCTURNAL,
    DIURNAL,
    CREPUSCULAR,
    HOARDER,
    MIGRATORY,

    # Intelligence Tags
    SENTIENT,
    PROBLEM_SOLVER,
    PACK_COORDINATION,

    # Environmental Adaptations
    COLD_RESISTANT,
    HEAT_RESISTANT,
    PRESSURE_ADAPTED,

    # Utility Tags
    GUARDIAN,
    INTIMIDATING,
    TRACKER,
    CONSTRUCTOR,
    CLEANSER,
    MESSENGER,
    DIPLOMATIC,
    PERFORMANCE,
    SERVICE_ANIMAL
}

# ============================================================================
# TRAINING SYSTEM
# ============================================================================

enum TrainingActivity {
    # Strength Training
    WEIGHT_LIFTING,
    COMBAT_PRACTICE,
    HEAVY_LABOR,
    BOULDER_PUSHING,

    # Constitution Training
    ENDURANCE_RUNNING,
    EXPOSURE_TRAINING,
    SURVIVAL_CHALLENGES,
    MARATHON_TRAINING,

    # Dexterity Training
    AGILITY_COURSES,
    PRECISION_TASKS,
    REACTION_TRAINING,
    ACROBATICS,

    # Intelligence Training
    PUZZLE_SOLVING,
    LEARNING_EXERCISES,
    COGNITIVE_CHALLENGES,
    STRATEGY_GAMES,

    # Wisdom Training
    OBSERVATION_EXERCISES,
    ENVIRONMENTAL_EXPOSURE,
    ALERTNESS_DRILLS,
    MEDITATION,

    # Discipline Training
    OBEDIENCE_TRAINING,
    FOCUS_EXERCISES,
    COMMAND_DRILLS,
    MILITARY_TRAINING,

    # Rest
    RESTING
}

enum TrainingFacility {
    BASIC_GROUNDS,    # Free
    ADVANCED_CENTER,  # 50g/session
    ELITE_ACADEMY,    # 150g/session
    MASTER_DOJO       # 500g/session
}

# ============================================================================
# FOOD SYSTEM
# ============================================================================

enum FoodType {
    # Basic Foods
    GRAIN_RATIONS,
    FRESH_HAY,
    WILD_BERRIES,
    SPRING_WATER,

    # Training Foods
    PROTEIN_MIX,
    ENDURANCE_BLEND,
    AGILITY_FEED,
    BRAIN_FOOD,
    FOCUS_FORMULA,
    DISCIPLINE_DIET,

    # Premium Foods
    GOLDEN_NECTAR,
    VITALITY_ELIXIR,
    YOUTH_SERUM,
    ANCIENT_GRAINS,

    # Specialty Foods
    BREEDING_SUPPLEMENT,
    COMBAT_RATIONS,
    TASK_FUEL,
    RECOVERY_MEAL,

    # Exotic Foods
    DRAGON_FRUIT,
    PHOENIX_ASH,
    LUNAR_MOSS,
    MYSTIC_HERBS
}

enum FoodCategory {
    BASIC,
    TRAINING,
    PREMIUM,
    SPECIALTY,
    EXOTIC
}

# ============================================================================
# COMPETITION SYSTEM
# ============================================================================

enum CompetitionType {
    STRENGTH_CONTEST,
    ENDURANCE_CHALLENGE,
    SPEED_RACE,
    OBSTACLE_COURSE,
    LOGIC_TOURNAMENT,
    STRATEGY_GAME,
    TRACKING_CONTEST,
    GUARD_TRIAL,
    OBEDIENCE_TRIAL,
    SERVICE_COMPETITION
}

enum CompetitionTier {
    BEGINNER,
    INTERMEDIATE,
    ADVANCED,
    ELITE
}

enum CompetitionPlacement {
    FIRST,
    PODIUM,       # 2nd-3rd
    TOP_HALF,     # 4th-50%
    BOTTOM_HALF   # Below 50%
}

# ============================================================================
# BREEDING SYSTEM
# ============================================================================

enum EggGroup {
    MAMMALIAN,
    AVIAN,
    REPTILIAN,
    AQUATIC,
    ARTHROPOD,
    MAGICAL,
    ELEMENTAL,
    CONSTRUCT,
    FIELD,      # Common/general group
    BUG,        # Insect-like creatures
    MINERAL,    # Rock/crystal creatures
    MONSTER,    # Large/powerful creatures
    FLYING      # All flying creatures
}

enum BreedingQuality {
    POOR,
    STANDARD,
    GOOD,
    EXCELLENT,
    PERFECT
}

# ============================================================================
# QUEST SYSTEM
# ============================================================================

enum QuestStatus {
    LOCKED,
    AVAILABLE,
    ACTIVE,
    READY,      # Can be completed
    COMPLETED,
    FAILED
}

enum QuestCategory {
    TUTORIAL,
    STORY,
    SIDE,
    RADIANT     # Repeatable/procedural
}

enum RequirementType {
    STAT_MINIMUM,
    TAG_REQUIRED,
    TAG_EXCLUDED,
    CREATURE_COUNT,
    SPECIFIC_SPECIES,
    AGE_CATEGORY,
    CUSTOM
}

# ============================================================================
# SHOP SYSTEM
# ============================================================================

enum VendorType {
    CREATURE_EGG,
    FOOD_SUPPLIER,
    EQUIPMENT,
    SERVICE,
    SPECIAL
}

enum ShopTier {
    STARTER,    # Available from start
    EARLY,      # Unlocked early game
    MID,        # Mid-game content
    LATE,       # Late game content
    ENDGAME     # Endgame/luxury items
}

# ============================================================================
# TIME MANAGEMENT
# ============================================================================

enum WeeklyActivity {
    TRAINING,
    COMPETITION,
    BREEDING,
    QUEST,
    RESTING,
    IDLE
}

enum TimeEvent {
    NONE,
    MARKET_DISCOUNT,
    BONUS_TRAINING,
    COMPETITION_BONUS,
    RANDOM_ENCOUNTER,
    SEASONAL_EVENT
}

# ============================================================================
# UI AND SYSTEM
# ============================================================================

enum UIState {
    MAIN_MENU,
    GAME_VIEW,
    CREATURE_LIST,
    CREATURE_DETAIL,
    SHOP_VIEW,
    QUEST_VIEW,
    TRAINING_VIEW,
    COMPETITION_VIEW,
    BREEDING_VIEW,
    TIME_ADVANCE,
    SETTINGS
}

enum SaveSlot {
    SLOT_1,
    SLOT_2,
    SLOT_3,
    AUTOSAVE,
    QUICKSAVE
}

enum Rarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY,
    UNIQUE
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Stat utilities
func get_stat_name(stat: StatType) -> String:
    return STAT_NAMES.get(stat, "UNKNOWN")

func get_stat_full_name(stat: StatType) -> String:
    return STAT_FULL_NAMES.get(stat, "Unknown")

func get_stat_from_string(stat_str: String) -> StatType:
    stat_str = stat_str.to_upper()
    for stat in STAT_NAMES:
        if STAT_NAMES[stat] == stat_str or STAT_FULL_NAMES[stat].to_upper() == stat_str:
            return stat
    return StatType.STRENGTH  # Default

func get_all_stats() -> Array[StatType]:
    return [
        StatType.STRENGTH,
        StatType.CONSTITUTION,
        StatType.DEXTERITY,
        StatType.INTELLIGENCE,
        StatType.WISDOM,
        StatType.DISCIPLINE
    ]

# Age utilities
func get_age_category_name(category: AgeCategory) -> String:
    match category:
        AgeCategory.BABY: return "Baby"
        AgeCategory.JUVENILE: return "Juvenile"
        AgeCategory.ADULT: return "Adult"
        AgeCategory.ELDER: return "Elder"
        AgeCategory.ANCIENT: return "Ancient"
        _: return "Unknown"

# Tag utilities
func get_tag_name(tag: CreatureTag) -> String:
    return CreatureTag.keys()[tag].replace("_", " ").capitalize()

func get_tag_category_for_tag(tag: CreatureTag) -> TagCategory:
    # Size tags
    if tag in [CreatureTag.TINY, CreatureTag.SMALL, CreatureTag.MEDIUM, CreatureTag.LARGE, CreatureTag.MASSIVE]:
        return TagCategory.SIZE

    # Physical traits
    if tag in [CreatureTag.WINGED, CreatureTag.FLIES, CreatureTag.AQUATIC, CreatureTag.TERRESTRIAL,
               CreatureTag.NATURAL_ARMOR, CreatureTag.CAMOUFLAGE, CreatureTag.BIPEDAL, CreatureTag.QUADRUPED]:
        return TagCategory.PHYSICAL

    # Behavioral
    if tag in [CreatureTag.TERRITORIAL, CreatureTag.DOCILE, CreatureTag.AGGRESSIVE, CreatureTag.SOCIAL,
               CreatureTag.SOLITARY, CreatureTag.STEALTHY, CreatureTag.NOCTURNAL, CreatureTag.DIURNAL,
               CreatureTag.CREPUSCULAR, CreatureTag.HOARDER, CreatureTag.MIGRATORY]:
        return TagCategory.BEHAVIORAL

    # Abilities
    if tag in [CreatureTag.ECHOLOCATION, CreatureTag.VENOM, CreatureTag.BIOLUMINESCENT, CreatureTag.DARK_VISION,
               CreatureTag.ENHANCED_HEARING, CreatureTag.MAGNETIC_SENSE, CreatureTag.SURE_FOOTED,
               CreatureTag.SENTIENT, CreatureTag.PROBLEM_SOLVER, CreatureTag.PACK_COORDINATION,
               CreatureTag.COLD_RESISTANT, CreatureTag.HEAT_RESISTANT, CreatureTag.PRESSURE_ADAPTED]:
        return TagCategory.ABILITY

    # Utility
    if tag in [CreatureTag.GUARDIAN, CreatureTag.INTIMIDATING, CreatureTag.TRACKER, CreatureTag.CONSTRUCTOR,
               CreatureTag.CLEANSER, CreatureTag.MESSENGER, CreatureTag.DIPLOMATIC, CreatureTag.PERFORMANCE,
               CreatureTag.SERVICE_ANIMAL]:
        return TagCategory.UTILITY

    return TagCategory.UTILITY  # Default

# Rarity utilities
func get_rarity_name(rarity: Rarity) -> String:
    match rarity:
        Rarity.COMMON: return "Common"
        Rarity.UNCOMMON: return "Uncommon"
        Rarity.RARE: return "Rare"
        Rarity.EPIC: return "Epic"
        Rarity.LEGENDARY: return "Legendary"
        Rarity.UNIQUE: return "Unique"
        _: return "Unknown"

func get_rarity_color(rarity: Rarity) -> Color:
    match rarity:
        Rarity.COMMON: return Color.WHITE
        Rarity.UNCOMMON: return Color.GREEN
        Rarity.RARE: return Color.BLUE
        Rarity.EPIC: return Color.PURPLE
        Rarity.LEGENDARY: return Color.ORANGE
        Rarity.UNIQUE: return Color.RED
        _: return Color.GRAY

# Quest utilities
func get_quest_status_name(status: QuestStatus) -> String:
    match status:
        QuestStatus.LOCKED: return "Locked"
        QuestStatus.AVAILABLE: return "Available"
        QuestStatus.ACTIVE: return "Active"
        QuestStatus.READY: return "Ready"
        QuestStatus.COMPLETED: return "Completed"
        QuestStatus.FAILED: return "Failed"
        _: return "Unknown"

# Food utilities
func get_food_category_for_type(food_type: FoodType) -> FoodCategory:
    if food_type in [FoodType.GRAIN_RATIONS, FoodType.FRESH_HAY, FoodType.WILD_BERRIES, FoodType.SPRING_WATER]:
        return FoodCategory.BASIC
    elif food_type in [FoodType.PROTEIN_MIX, FoodType.ENDURANCE_BLEND, FoodType.AGILITY_FEED,
                       FoodType.BRAIN_FOOD, FoodType.FOCUS_FORMULA, FoodType.DISCIPLINE_DIET]:
        return FoodCategory.TRAINING
    elif food_type in [FoodType.GOLDEN_NECTAR, FoodType.VITALITY_ELIXIR, FoodType.YOUTH_SERUM, FoodType.ANCIENT_GRAINS]:
        return FoodCategory.PREMIUM
    elif food_type in [FoodType.BREEDING_SUPPLEMENT, FoodType.COMBAT_RATIONS, FoodType.TASK_FUEL, FoodType.RECOVERY_MEAL]:
        return FoodCategory.SPECIALTY
    else:
        return FoodCategory.EXOTIC

# Validation utilities
func is_valid_enum_value(enum_type: String, value: int) -> bool:
    match enum_type.to_lower():
        "stattype": return value >= 0 and value < StatType.size()
        "agecategory": return value >= 0 and value < AgeCategory.size()
        "creaturetag": return value >= 0 and value < CreatureTag.size()
        "rarity": return value >= 0 and value < Rarity.size()
        _: return false

# Debug utilities
func get_enum_info(enum_name: String) -> Dictionary:
    var info = {"name": enum_name, "values": {}}

    match enum_name.to_lower():
        "stattype":
            for i in StatType.size():
                info.values[i] = get_stat_name(i)
        "agecategory":
            for i in AgeCategory.size():
                info.values[i] = get_age_category_name(i)
        "rarity":
            for i in Rarity.size():
                info.values[i] = get_rarity_name(i)

    return info

# String-to-Enum conversion helpers (for Stage 1 migration)
func tag_string_to_enum(tag_string: String) -> CreatureTag:
    var enum_name = tag_string.to_upper().replace(" ", "_")

    # Try to find matching enum
    for tag_value in CreatureTag.values():
        if CreatureTag.keys()[tag_value] == enum_name:
            return tag_value

    # Return a default if not found
    push_warning("Tag string '%s' not found in CreatureTag enum" % tag_string)
    return CreatureTag.SMALL  # Safe default

func tag_enum_to_string(tag_enum: CreatureTag) -> String:
    return CreatureTag.keys()[tag_enum].replace("_", " ").capitalize()

# Ready function for initialization
func _ready() -> void:
    print("GlobalEnums loaded successfully")
    print("Available enums: StatType (%d), CreatureTag (%d), Rarity (%d), etc." % [
        StatType.size(),
        CreatureTag.size(),
        Rarity.size()
    ])

# Migration helpers for Stage 1 systems
func migrate_string_array_to_tag_enums(string_tags: Array[String]) -> Array[CreatureTag]:
    var enum_tags: Array[CreatureTag] = []

    for tag_string in string_tags:
        var tag_enum = tag_string_to_enum(tag_string)
        enum_tags.append(tag_enum)

    return enum_tags

func migrate_tag_enums_to_string_array(tag_enums: Array[CreatureTag]) -> Array[String]:
    var string_tags: Array[String] = []

    for tag_enum in tag_enums:
        string_tags.append(tag_enum_to_string(tag_enum))

    return string_tags

# Performance: Cache frequently used values
var _cached_stat_names: Dictionary = {}
var _cached_tag_names: Dictionary = {}

func _cache_enum_names() -> void:
    # Cache stat names
    for stat in StatType.values():
        _cached_stat_names[stat] = get_stat_name(stat)

    # Cache tag names
    for tag in CreatureTag.values():
        _cached_tag_names[tag] = get_tag_name(tag)

func get_cached_stat_name(stat: StatType) -> String:
    if _cached_stat_names.is_empty():
        _cache_enum_names()
    return _cached_stat_names.get(stat, "UNKNOWN")

func get_cached_tag_name(tag: CreatureTag) -> String:
    if _cached_tag_names.is_empty():
        _cache_enum_names()
    return _cached_tag_names.get(tag, "Unknown")
```

### GameCore Integration Example
```gdscript
# Example of how GameCore systems access GlobalEnums

# In TagSystem (GameCore subsystem):
func validate_tag_enum(tag: GlobalEnums.CreatureTag) -> bool:
    return GlobalEnums.is_valid_enum_value("creaturetag", tag)

# In AgeSystem (GameCore subsystem):
func get_age_modifier(category: GlobalEnums.AgeCategory) -> float:
    match category:
        GlobalEnums.AgeCategory.BABY: return 0.6
        GlobalEnums.AgeCategory.JUVENILE: return 0.8
        GlobalEnums.AgeCategory.ADULT: return 1.0
        GlobalEnums.AgeCategory.ELDER: return 0.8
        GlobalEnums.AgeCategory.ANCIENT: return 0.6
        _: return 1.0

# In CreatureData (Resource):
var stat_type: GlobalEnums.StatType = GlobalEnums.StatType.STRENGTH
var creature_tags: Array[GlobalEnums.CreatureTag] = []

# GameCore can access GlobalEnums without issues:
func _ready() -> void:
    var available_stats = GlobalEnums.get_all_stats()
    print("Available stats: ", available_stats)
```

## Success Metrics
- GlobalEnums loads as autoload without errors
- All enum values accessible from GameCore systems
- No naming conflicts with existing code
- Autocomplete works in Godot editor
- Can be used in any script throughout the project
- Utility functions provide easy conversion
- Migration helpers assist Stage 1 transition

## Notes
- This is a foundational file used by all other systems
- GlobalEnums is an autoload, not a GameCore subsystem
- Keep organized by category with clear documentation
- Add comments for clarity and purpose
- Update when new enums are needed
- Consider using enum flags for combinable properties in future
- Provides type safety for the entire codebase
- Essential for preventing string-based bugs
- Migration helpers assist transition from Stage 1 strings
- Can be accessed from any GameCore subsystem without issues

## Estimated Time
2-3 hours for implementation and testing