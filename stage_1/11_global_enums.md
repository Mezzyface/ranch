# Task 11: Global Enums Setup

## Overview
Create the global enums file that will be used throughout the entire codebase. This provides type safety and prevents typos in string-based systems.

## Dependencies
- Task 01: Project Setup (complete)
- Design document: `enum.md`

## Context
From `enum.md`:
- All game enums should be in a single global file
- Registered as autoload for easy access
- Provides type safety and autocomplete
- Stage 1 uses strings that will migrate to enums later

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
   - Location: `scripts/utils/Enums.gd`
   - Add all enum definitions from enum.md

2. **Register as Autoload**
   - Project Settings → Autoload
   - Name: "Enums"
   - Path: res://scripts/utils/Enums.gd

3. **Test Access**
   - Verify enums accessible from any script
   - Test autocomplete works
   - Ensure no conflicts

## Test Criteria

### Unit Tests
- [ ] All enums defined correctly
- [ ] No duplicate values within enums
- [ ] Enums accessible globally
- [ ] Values match design specs

### Integration Tests
- [ ] Can use Enums.StatType in scripts
- [ ] Can use Enums.CreatureTag in arrays
- [ ] Can use enums in match statements
- [ ] Can save/load enum values

## Code Implementation

### Global Enums (`scripts/utils/Enums.gd`)
```gdscript
# Global Enums for Creature Collection Game
# This file contains all game enums for type safety and consistency
extends Node

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

# Creature Management
enum CreatureState {
    ACTIVE,   # Participating in weekly progression
    STABLE    # In stasis, not aging
}

enum AgeCategory {
    YOUNG,   # 0-25% of lifespan, +20% training
    ADULT,   # 25-75% of lifespan, normal
    ELDER    # 75-100% of lifespan, -20% training
}

enum CreatureSize {
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
    MASSIVE
}

# Tag System
enum TagCategory {
    SPECIES,    # Immutable species traits
    HERITABLE,  # Can be inherited
    TRAINABLE,  # Can be trained
    EQUIPMENT   # From equipment
}

enum CreatureTag {
    # Size Tags
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
    MASSIVE,

    # Anatomical Tags
    WINGED,
    AQUATIC,
    BIPEDAL,
    QUADRUPED,

    # Natural Abilities
    ECHOLOCATION,
    VENOM,
    NATURAL_ARMOR,
    BIOLUMINESCENT,
    DARK_VISION,
    ENHANCED_HEARING,
    MAGNETIC_SENSE,

    # Movement Tags
    FLIES,
    SURE_FOOTED,

    # Behavioral Tags
    TERRITORIAL,
    DOCILE,
    AGGRESSIVE,
    SOCIAL,
    STEALTHY,
    NOCTURNAL,
    DIURNAL,
    HOARDER,
    MIGRATORY,

    # Intelligence Tags
    SENTIENT,
    PROBLEM_SOLVER,
    PACK_COORDINATION,

    # Environmental Tags
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
    CAMOUFLAGE,
    DIPLOMATIC,
    PERFORMANCE,
    SERVICE_ANIMAL
}

# Training System
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

# Food System
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

# Competition System
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
    PODIUM,
    TOP_HALF,
    BOTTOM_HALF
}

# Breeding System
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

# Quest System
enum QuestStatus {
    LOCKED,
    AVAILABLE,
    ACTIVE,
    READY,
    COMPLETED,
    FAILED
}

enum QuestCategory {
    TUTORIAL,
    STORY,
    SIDE,
    RADIANT
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

# Shop System
enum VendorType {
    CREATURE_EGG,
    FOOD_SUPPLIER,
    EQUIPMENT,
    SERVICE,
    SPECIAL
}

enum ShopTier {
    STARTER,
    EARLY,
    MID,
    LATE,
    ENDGAME
}

# Time Management
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

# UI and System
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

# Utility functions
func get_stat_name(stat: StatType) -> String:
    return STAT_NAMES.get(stat, "UNKNOWN")

func get_stat_from_string(stat_str: String) -> StatType:
    stat_str = stat_str.to_upper()
    for stat in STAT_NAMES:
        if STAT_NAMES[stat] == stat_str:
            return stat
    return StatType.STRENGTH  # Default

# Ready function for initialization
func _ready():
    print("Global Enums loaded successfully")
    print("Available enums: StatType, CreatureTag, FoodType, etc.")
```

## Success Metrics
- Enums load without errors
- All enum values accessible
- No naming conflicts
- Autocomplete works in editor
- Can be used in any script

## Notes
- This is a foundational file used by all other systems
- Keep organized by category
- Add comments for clarity
- Update when new enums needed
- Consider using enum flags for combinable properties in future

## Estimated Time
1-2 hours for implementation and testing