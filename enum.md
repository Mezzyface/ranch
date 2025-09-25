# Global Enums Documentation

## Overview

This document defines all global enums for the creature collection/breeding game. These enums should be implemented in a single global script file (e.g., `res://scripts/utils/Enums.gd`) and referenced throughout the codebase to ensure consistency and type safety.

## Core Stats

### StatType
Defines the six primary creature statistics.
```gdscript
enum StatType {
    STRENGTH,      # STR - Physical power, combat, construction
    CONSTITUTION,  # CON - Health, durability, endurance
    DEXTERITY,     # DEX - Speed, agility, precision
    INTELLIGENCE,  # INT - Problem solving, learning, complex tasks
    WISDOM,        # WIS - Awareness, perception, instinct
    DISCIPLINE     # DIS - Obedience, focus, reliability
}
```

## Creature Management

### CreatureState
Defines the active/stable state of creatures.
```gdscript
enum CreatureState {
    ACTIVE,   # Participating in weekly time progression
    STABLE    # In stasis, unaffected by time passage
}
```

### AgeCategory
Defines creature life stages with training modifiers.
```gdscript
enum AgeCategory {
    YOUNG,   # 0-25% of lifespan, +20% training effectiveness
    ADULT,   # 25-75% of lifespan, standard effectiveness
    ELDER    # 75-100% of lifespan, -20% training, +10% wisdom
}
```

### CreatureSize
Physical size categories for creatures.
```gdscript
enum CreatureSize {
    TINY,     # Smallest creatures
    SMALL,    # Small creatures (most common early game)
    MEDIUM,   # Medium-sized creatures
    LARGE,    # Large creatures
    MASSIVE   # Largest creatures
}
```

## Tag System

### TagCategory
Categorizes different types of tags.
```gdscript
enum TagCategory {
    SPECIES,    # Immutable species-specific traits
    HERITABLE,  # Can be passed through breeding
    TRAINABLE,  # Can be acquired through training
    EQUIPMENT   # Temporary, granted by items
}
```

### CreatureTag
All possible creature tags (used for quest requirements and abilities).
```gdscript
enum CreatureTag {
    # Size Tags (Species)
    TINY,
    SMALL,
    MEDIUM,
    LARGE,
    MASSIVE,

    # Anatomical Tags (Species)
    WINGED,
    AQUATIC,
    BIPEDAL,
    QUADRUPED,

    # Natural Abilities (Species)
    ECHOLOCATION,
    VENOM,
    NATURAL_ARMOR,
    BIOLUMINESCENT,
    DARK_VISION,
    ENHANCED_HEARING,
    MAGNETIC_SENSE,

    # Movement Tags (Species/Trainable)
    FLIES,
    SURE_FOOTED,

    # Behavioral Tags (Heritable)
    TERRITORIAL,
    DOCILE,
    AGGRESSIVE,
    SOCIAL,
    STEALTHY,
    NOCTURNAL,
    DIURNAL,
    HOARDER,
    MIGRATORY,

    # Intelligence Tags (Heritable/Trainable)
    SENTIENT,
    PROBLEM_SOLVER,
    PACK_COORDINATION,

    # Environmental Tags (Heritable)
    COLD_RESISTANT,
    HEAT_RESISTANT,
    PRESSURE_ADAPTED,

    # Utility Tags (Trainable)
    GUARDIAN,
    INTIMIDATING,
    TRACKER,
    CONSTRUCTOR,
    CLEANSER,
    MESSENGER,
    CAMOUFLAGE,
    DIPLOMATIC,
    PERFORMANCE,
    SERVICE_ANIMAL,

    # Equipment Tags (Equipment)
    FLIGHT_HARNESS,
    SPEED_BOOST,
    WATER_WALKING,
    NIGHT_VISION_GOGGLES,
    SCENT_AMPLIFIER,
    ARMORED,
    ENVIRONMENTAL_SUIT,
    MAGIC_WARD,
    WEAPON_MOUNT,
    UTILITY_BELT,
    COMMUNICATION_DEVICE
}
```

## Training System

### TrainingActivity
Weekly training activities for stat improvement.
```gdscript
enum TrainingActivity {
    # Strength Training
    WEIGHT_LIFTING,     # Basic STR training
    COMBAT_PRACTICE,    # Advanced STR training
    HEAVY_LABOR,        # Elite STR training
    BOULDER_PUSHING,    # Master STR training

    # Constitution Training
    ENDURANCE_RUNNING,  # Basic CON training
    EXPOSURE_TRAINING,  # Advanced CON training
    SURVIVAL_CHALLENGES,# Elite CON training
    MARATHON_TRAINING,  # Master CON training

    # Dexterity Training
    AGILITY_COURSES,    # Basic DEX training
    PRECISION_TASKS,    # Advanced DEX training
    REACTION_TRAINING,  # Elite DEX training
    ACROBATICS,         # Master DEX training

    # Intelligence Training
    PUZZLE_SOLVING,     # Basic INT training
    LEARNING_EXERCISES, # Advanced INT training
    COGNITIVE_CHALLENGES,# Elite INT training
    STRATEGY_GAMES,     # Master INT training

    # Wisdom Training
    OBSERVATION_EXERCISES,# Basic WIS training
    ENVIRONMENTAL_EXPOSURE,# Advanced WIS training
    ALERTNESS_DRILLS,   # Elite WIS training
    MEDITATION,         # Master WIS training

    # Discipline Training
    OBEDIENCE_TRAINING, # Basic DIS training
    FOCUS_EXERCISES,    # Advanced DIS training
    COMMAND_DRILLS,     # Elite DIS training
    MILITARY_TRAINING,  # Master DIS training

    # Rest Activity
    RESTING            # Recover stamina, no stat gains
}
```

### TrainingFacility
Training facility tiers with different activities.
```gdscript
enum TrainingFacility {
    BASIC_GROUNDS,    # Free, basic activities
    ADVANCED_CENTER,  # 50g/session, advanced activities
    ELITE_ACADEMY,    # 150g/session, elite activities
    MASTER_DOJO       # 500g/session, master activities
}
```

## Food System

### FoodType
All available food items and their primary effects.
```gdscript
enum FoodType {
    # Basic Foods
    GRAIN_RATIONS,      # Standard food, no bonus
    FRESH_HAY,          # +5 stamina recovery
    WILD_BERRIES,       # +2 to all training gains
    SPRING_WATER,       # Removes negative effects

    # Training Foods
    PROTEIN_MIX,        # +50% STR training
    ENDURANCE_BLEND,    # +50% CON training
    AGILITY_FEED,       # +50% DEX training
    BRAIN_FOOD,         # +50% INT training
    FOCUS_FORMULA,      # +50% WIS training
    DISCIPLINE_DIET,    # +50% DIS training

    # Premium Foods
    GOLDEN_NECTAR,      # +100% any training
    VITALITY_ELIXIR,    # +20 stamina, immunity
    YOUTH_SERUM,        # Treats as younger age
    ANCIENT_GRAINS,     # +3 all stats, +10 stamina

    # Specialty Foods
    BREEDING_SUPPLEMENT,# +50% breeding success
    COMBAT_RATIONS,     # +25% competition performance
    TASK_FUEL,          # +30% task effectiveness
    RECOVERY_MEAL,      # Doubles rest recovery

    # Exotic Foods
    DRAGON_FRUIT,       # Rare tag chance in breeding
    PHOENIX_ASH,        # Prevents aging one week
    LUNAR_MOSS,         # Doubles effects, -10 stamina
    MYSTIC_HERBS        # Random powerful effect
}
```

### FoodCategory
Categories for organizing food items.
```gdscript
enum FoodCategory {
    BASIC,      # Low cost, mild effects
    TRAINING,   # Stat-focused bonuses
    PREMIUM,    # High cost, strong effects
    SPECIALTY,  # Activity-specific
    EXOTIC      # Rare, unique effects
}
```

## Competition System

### CompetitionType
Different types of weekly competitions.
```gdscript
enum CompetitionType {
    # Combat Competitions
    STRENGTH_CONTEST,   # STR focus
    ENDURANCE_CHALLENGE,# CON focus

    # Agility Competitions
    SPEED_RACE,         # DEX focus
    OBSTACLE_COURSE,    # DEX + INT focus

    # Intelligence Competitions
    LOGIC_TOURNAMENT,   # INT focus
    STRATEGY_GAME,      # INT + DIS focus

    # Awareness Competitions
    TRACKING_CONTEST,   # WIS focus
    GUARD_TRIAL,        # WIS + DIS focus

    # Discipline Competitions
    OBEDIENCE_TRIAL,    # DIS focus
    SERVICE_COMPETITION # DIS + STR focus
}
```

### CompetitionTier
Competition difficulty tiers.
```gdscript
enum CompetitionTier {
    BEGINNER,      # Available from start
    INTERMEDIATE,  # Unlock after TIM-02
    ADVANCED,      # Unlock after TIM-04
    ELITE          # Unlock after TIM-06
}
```

### CompetitionPlacement
Competition result rankings.
```gdscript
enum CompetitionPlacement {
    FIRST,         # Top 10%, max rewards
    PODIUM,        # Top 30%, good rewards
    TOP_HALF,      # Top 50%, decent rewards
    BOTTOM_HALF    # Bottom 50%, participation prize
}
```

## Breeding System

### EggGroup
Breeding compatibility groups.
```gdscript
enum EggGroup {
    MAMMALIAN,   # Warm-blooded with fur/skin
    AVIAN,       # Birds and flying creatures
    REPTILIAN,   # Cold-blooded scaled creatures
    AQUATIC,     # Water-dwelling creatures
    ARTHROPOD,   # Exoskeleton creatures
    MAGICAL,     # Innate magical properties
    ELEMENTAL,   # Elemental force creatures
    CONSTRUCT    # Artificial beings
}
```

### BreedingQuality
Quality levels for breeding outcomes.
```gdscript
enum BreedingQuality {
    POOR,        # Below average inheritance
    STANDARD,    # Normal inheritance
    GOOD,        # Above average inheritance
    EXCELLENT,   # Superior inheritance
    PERFECT      # Maximum inheritance potential
}
```

## Quest System

### QuestStatus
Quest progression states.
```gdscript
enum QuestStatus {
    LOCKED,      # Not available yet
    AVAILABLE,   # Can be started
    ACTIVE,      # Currently in progress
    READY,       # Requirements met, can turn in
    COMPLETED,   # Successfully completed
    FAILED       # Failed or abandoned
}
```

### QuestCategory
Types of quests.
```gdscript
enum QuestCategory {
    TUTORIAL,    # Teaching mechanics (TIM quests)
    STORY,       # Main narrative quests
    SIDE,        # Optional content
    RADIANT      # Repeatable procedural quests
}
```

### RequirementType
Types of quest requirements.
```gdscript
enum RequirementType {
    STAT_MINIMUM,     # Minimum stat value
    TAG_REQUIRED,     # Must have specific tag
    TAG_EXCLUDED,     # Must NOT have specific tag
    CREATURE_COUNT,   # Number of creatures needed
    SPECIFIC_SPECIES, # Specific creature species
    AGE_CATEGORY,     # Specific age range
    CUSTOM            # Special requirement logic
}
```

## Shop System

### VendorType
Categories of shop vendors.
```gdscript
enum VendorType {
    CREATURE_EGG,    # Sells creature eggs
    FOOD_SUPPLIER,   # Sells food items
    EQUIPMENT,       # Sells equipment
    SERVICE,         # Provides services
    SPECIAL          # Limited time or unique
}
```

### ShopTier
Shop unlock progression.
```gdscript
enum ShopTier {
    STARTER,     # Available from game start
    EARLY,       # Unlock after TIM-01
    MID,         # Unlock after TIM-03
    LATE,        # Unlock after TIM-05
    ENDGAME      # Unlock after TIM-06
}
```

## Time Management

### WeeklyActivity
All possible weekly activities for creatures.
```gdscript
enum WeeklyActivity {
    TRAINING,      # Any training activity
    COMPETITION,   # Participating in competition
    BREEDING,      # Breeding activity
    QUEST,         # Assigned to quest
    RESTING,       # Recovery week
    IDLE           # No activity assigned
}
```

### TimeEvent
Special time-based events.
```gdscript
enum TimeEvent {
    NONE,             # No special event
    MARKET_DISCOUNT,  # Reduced shop prices
    BONUS_TRAINING,   # Enhanced training gains
    COMPETITION_BONUS,# Increased competition rewards
    RANDOM_ENCOUNTER, # Special creature appearance
    SEASONAL_EVENT    # Holiday or seasonal content
}
```

## UI and System

### UIState
Game UI states for navigation.
```gdscript
enum UIState {
    MAIN_MENU,       # Main menu screen
    GAME_VIEW,       # Main gameplay view
    CREATURE_LIST,   # Creature collection view
    CREATURE_DETAIL, # Individual creature view
    SHOP_VIEW,       # Shop interface
    QUEST_VIEW,      # Quest journal
    TRAINING_VIEW,   # Training planning
    COMPETITION_VIEW,# Competition interface
    BREEDING_VIEW,   # Breeding interface
    TIME_ADVANCE,    # Week progression screen
    SETTINGS         # Game settings
}
```

### SaveSlot
Save game slot identifiers.
```gdscript
enum SaveSlot {
    SLOT_1,
    SLOT_2,
    SLOT_3,
    AUTOSAVE,
    QUICKSAVE
}
```

### Rarity
General rarity tiers for items/creatures.
```gdscript
enum Rarity {
    COMMON,      # Easily obtained
    UNCOMMON,    # Somewhat rare
    RARE,        # Hard to find
    EPIC,        # Very rare
    LEGENDARY,   # Extremely rare
    UNIQUE       # One of a kind
}
```

## Usage Guidelines

### Implementation in Godot 4.5

1. **Create Global Enum Script**: Save all enums in `res://scripts/utils/Enums.gd`
2. **Register as Autoload**: Add to Project Settings → Autoload as "Enums"
3. **Access Pattern**: Use `Enums.StatType.STRENGTH` throughout the codebase
4. **Type Safety**: Always use enum types in function signatures and exports

### Example Usage
```gdscript
# In creature script
@export var current_state: Enums.CreatureState = Enums.CreatureState.STABLE
@export var age_category: Enums.AgeCategory = Enums.AgeCategory.YOUNG
@export var assigned_food: Enums.FoodType = Enums.FoodType.GRAIN_RATIONS

# In function signatures
func train_stat(stat: Enums.StatType, activity: Enums.TrainingActivity) -> int:
    # Implementation
    pass

func has_tag(tag: Enums.CreatureTag) -> bool:
    # Implementation
    pass
```

### Benefits of Global Enums
- **Type Safety**: Prevents invalid values and typos
- **Autocomplete**: IDE support for all enum values
- **Maintainability**: Single source of truth for all game constants
- **Refactoring**: Easy to rename or reorganize values
- **Documentation**: Self-documenting code with meaningful names
- **Consistency**: Ensures all systems use the same values

## Notes for Implementation

- All enum values should be in SCREAMING_SNAKE_CASE
- Group related enums together in the global script
- Add comments for clarity where enum purpose isn't obvious
- Consider using enum flags for combinable properties if needed
- Validate enum usage during save/load operations
- Use match statements with enum values for cleaner code

## Stage 1 Migration Strategy

During Stage 1 implementation, several systems use string placeholders that will be migrated to enums in later stages:

1. **Creature Tags**: Currently `Array[String]` → Will become `Array[Enums.CreatureTag]`
2. **Egg Groups**: Currently `String` → Will become `Enums.EggGroup`
3. **Food Items**: Currently string keys → Will become `Enums.FoodType` keys
4. **Species IDs**: Will remain as strings to reference SpeciesResource files for flexibility
5. **Activity States**: Currently boolean `is_active` → Could become `Enums.CreatureState`

This staged approach allows for:
- Faster initial prototyping without rigid type constraints
- Easier testing and debugging with readable string values
- Gradual migration to type-safe enums as systems mature
- Flexibility to adjust enum values based on early testing feedback

Migration will occur in Stage 2-3 when core systems are stable and enum requirements are fully understood.