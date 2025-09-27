# Data Classes API Reference

## Overview

Data classes are Resource-based structures that hold game data without behavior or signals. They follow the principle of data/behavior separation, with all logic and signaling handled by corresponding systems and entities.

## Core Data Classes

### CreatureData (`scripts/data/creature_data.gd`)

Core creature information and statistics.

#### Properties
```gdscript
# Identity
id: String                    # Unique identifier
creature_name: String         # Display name
species_id: String           # Species reference

# Core Stats (1-1000)
strength: int                # Physical power
constitution: int            # Health/endurance
dexterity: int              # Speed/agility
intelligence: int           # Mental capacity
wisdom: int                 # Experience/intuition
discipline: int             # Training/focus

# Age System
age_weeks: int              # Current age in weeks
lifespan_weeks: int         # Maximum lifespan

# State
is_active: bool             # In active roster
stamina_current: int        # Current stamina
stamina_max: int           # Maximum stamina

# Tags
tags: Array[String]         # Applied tags

# Breeding
egg_group: String           # Breeding compatibility
parent_ids: Array[String]   # Parent creature IDs
generation: int             # Generation number
```

#### Methods
```gdscript
get_age_category() -> GlobalEnums.AgeCategory
# Calculate age category based on lifespan percentage

get_age_modifier() -> float
# Get stat modifier based on age (0.6-1.0)

get_stat(stat_name: String) -> int
# Get stat value by name

get_stat_by_type(stat_type: GlobalEnums.StatType) -> int
# Get stat value by enum (preferred)

get_effective_stat(stat_type: GlobalEnums.StatType) -> int
# Get stat with age modifier applied

has_tag(tag: String) -> bool
# Check if creature has specific tag

is_expired() -> bool
# Check if creature exceeded lifespan

get_stamina_percentage() -> float
# Get stamina as percentage (0.0-1.0)
```

#### Usage Example
```gdscript
# Create new creature
var creature = CreatureData.new()
creature.creature_name = "Fluffy"
creature.species_id = "forest_sprite"
creature.strength = 75
creature.age_weeks = 52

# Check age status
var category = creature.get_age_category()
if category == GlobalEnums.AgeCategory.ADULT:
    print("%s is an adult" % creature.creature_name)

# Get modified stats
var effective_str = creature.get_effective_stat(GlobalEnums.StatType.STRENGTH)
print("Effective strength: %d" % effective_str)

# Tag management
creature.tags.append("trained")
if creature.has_tag("trained"):
    print("Creature is trained")
```

### StatsData (`scripts/data/stats_data.gd`)

Statistics snapshot for save/load and comparisons.

#### Properties
```gdscript
# Core Stats
strength: int
constitution: int
dexterity: int
intelligence: int
wisdom: int
discipline: int

# Calculated Stats
power_level: int           # Overall power rating
stat_total: int           # Sum of all stats
highest_stat: String      # Name of highest stat
lowest_stat: String       # Name of lowest stat

# Modifiers
age_modifier: float       # Applied age modifier
item_modifiers: Dictionary  # {stat_name: modifier}
temporary_boosts: Dictionary  # {stat_name: {value, duration}}
```

#### Methods
```gdscript
from_creature(creature: CreatureData) -> void
# Copy stats from creature

to_dictionary() -> Dictionary
# Convert to serializable format

from_dictionary(data: Dictionary) -> void
# Load from serialized data

calculate_power_level() -> int
# Calculate overall power rating

get_stat_array() -> Array[int]
# Get all stats as array

compare_to(other: StatsData) -> Dictionary
# Compare stats with another set
# Returns: {stat_name: difference}

apply_modifier(stat: String, value: int, permanent: bool = false) -> void
# Apply stat modifier
```

#### Usage Example
```gdscript
# Create stats snapshot
var stats = StatsData.new()
stats.from_creature(my_creature)

# Save for comparison
var before_training = stats.duplicate()

# Apply training
stats.apply_modifier("strength", 10, true)
stats.apply_modifier("discipline", 5, true)

# Compare changes
var changes = stats.compare_to(before_training)
for stat in changes:
    print("%s: +%d" % [stat, changes[stat]])
```

### TimeData (`scripts/data/time_data.gd`)

Time state for save/load operations.

#### Properties
```gdscript
# Current Time
week: int                 # Current week (1-52)
month: int               # Current month (1-13)
year: int                # Current year
total_weeks: int         # Total elapsed weeks

# Save Metadata
last_save_week: int      # Week of last save
last_save_timestamp: int # Unix timestamp

# Events
scheduled_events: Array[Dictionary]  # Pending events
completed_events: Array[String]      # Event IDs
```

#### Methods
```gdscript
is_valid() -> bool
# Validate time data integrity

to_dict() -> Dictionary
# Serialize for saving

from_dict(data: Dictionary) -> void
# Deserialize from save

get_formatted_date() -> String
# Get human-readable date

get_season() -> String
# Get current season name

weeks_since_save() -> int
# Calculate weeks elapsed since save
```

### QuestData (`scripts/data/quest_data.gd`)

Quest definition and progress tracking.

#### Properties
```gdscript
# Identity
quest_id: String
quest_name: String
quest_type: GlobalEnums.QuestType
difficulty: GlobalEnums.Difficulty

# Description
description: String
narrative_text: String
giver_npc: String

# Requirements
level_requirement: int
prerequisite_quests: Array[String]
required_items: Array[Dictionary]  # [{item_id, quantity}]

# Objectives
objectives: Array[QuestObjective]
current_objective_index: int
is_completed: bool
is_failed: bool

# Rewards
gold_reward: int
exp_reward: int
item_rewards: Array[Dictionary]  # [{item_id, quantity}]
unlock_rewards: Array[String]  # Unlocked features/areas

# Time Limits
has_deadline: bool
deadline_week: int
accepted_week: int
```

#### Methods
```gdscript
is_available(player_data: Dictionary) -> bool
# Check if quest can be accepted

get_current_objective() -> QuestObjective
# Get active objective

advance_objective() -> bool
# Move to next objective
# Returns: true if quest completed

check_completion() -> bool
# Evaluate if all objectives met

calculate_reward_multiplier(completion_time: int) -> float
# Bonus for fast completion

to_save_data() -> Dictionary
# Serialize quest progress
```

### QuestObjective (`scripts/data/quest_objective.gd`)

Individual quest objective.

#### Properties
```gdscript
# Definition
objective_id: String
description: String
objective_type: ObjectiveType

enum ObjectiveType {
    COLLECT,     # Gather items
    DEFEAT,      # Battle creatures
    DELIVER,     # Transport items
    REACH,       # Go to location
    SURVIVE,     # Time-based
    TRAIN,       # Raise stats
    BREED,       # Breeding task
    CUSTOM       # Special logic
}

# Requirements
target_id: String        # Item/creature/location ID
target_quantity: int     # Required amount
current_progress: int    # Current amount

# Optional
optional: bool          # Can skip
hidden: bool           # Not shown until active
bonus_objective: bool  # Extra rewards
```

#### Methods
```gdscript
update_progress(amount: int = 1) -> bool
# Increment progress
# Returns: true if completed

get_progress_text() -> String
# Format progress display

is_complete() -> bool
# Check completion status

reset() -> void
# Clear progress
```

## Collection Data Classes

### CollectionMetadata (`scripts/data/collection_metadata.gd`)

Collection statistics and history.

#### Properties
```gdscript
# Statistics
total_acquired: int
total_released: int
total_traded: int
total_bred: int

# Species Tracking
species_counts: Dictionary  # {species_id: count}
species_discovered: Array[String]
species_completed: Array[String]  # All evolutions obtained

# History
acquisition_history: Array[Dictionary]  # [{creature_id, source, timestamp}]
release_history: Array[Dictionary]
trade_history: Array[Dictionary]

# Milestones
milestones_reached: Array[String]
achievements_unlocked: Array[String]
collection_level: int
collection_exp: int
```

#### Methods
```gdscript
track_acquisition(creature: CreatureData, source: String) -> void
# Record new creature

track_release(creature_id: String) -> void
# Record creature release

get_species_completion() -> float
# Calculate completion percentage

get_rarity_breakdown() -> Dictionary
# Count by rarity tier

calculate_collection_value() -> int
# Estimate total value
```

## Economy Data Classes

### TransactionData (`scripts/data/transaction_data.gd`)

Economic transaction records.

#### Properties
```gdscript
# Transaction Info
transaction_id: String
transaction_type: TransactionType
timestamp: int

enum TransactionType {
    PURCHASE,
    SALE,
    TRADE,
    REWARD,
    PENALTY,
    TRANSFER
}

# Parties
from_entity: String  # Player, NPC, System
to_entity: String

# Value
gold_amount: int
items: Array[Dictionary]  # [{item_id, quantity, unit_price}]
creatures: Array[String]  # Creature IDs

# Metadata
location: String
description: String
tags: Array[String]
```

#### Methods
```gdscript
calculate_total_value() -> int
# Sum transaction value

is_valid() -> bool
# Validate transaction integrity

reverse() -> TransactionData
# Create reverse transaction

to_log_entry() -> String
# Format for transaction log
```

### MarketData (`scripts/data/market_data.gd`)

Market pricing and availability.

#### Properties
```gdscript
# Pricing
base_prices: Dictionary  # {item_id: price}
price_modifiers: Dictionary  # {item_id: modifier}
demand_levels: Dictionary  # {item_id: 0.5-2.0}

# Availability
stock_levels: Dictionary  # {item_id: quantity}
restock_timers: Dictionary  # {item_id: weeks_until}
limited_items: Array[String]  # One-time purchases

# Trends
price_history: Dictionary  # {item_id: Array[price]}
sales_volume: Dictionary  # {item_id: count}
```

#### Methods
```gdscript
get_current_price(item_id: String) -> int
# Calculate with modifiers

update_demand(item_id: String, sold: int) -> void
# Adjust demand based on sales

process_weekly_update() -> void
# Update prices and restock

get_trending_items(count: int = 5) -> Array[String]
# Get hot items
```

## Breeding Data Classes

### BreedingData (`scripts/data/breeding_data.gd`)

Breeding pair information and offspring potential.

#### Properties
```gdscript
# Parents
parent_a: CreatureData
parent_b: CreatureData
compatibility: float  # 0.0-1.0

# Breeding Stats
breeding_power: int
egg_quality: String  # Common, Rare, Perfect
incubation_weeks: int

# Offspring Potential
possible_species: Array[String]
stat_inheritance: Dictionary  # {stat: inherited_value}
trait_inheritance: Array[String]
mutation_chance: float
```

#### Methods
```gdscript
calculate_compatibility() -> float
# Determine breeding compatibility

predict_offspring_stats() -> Dictionary
# Calculate potential stats

get_inherited_traits() -> Array[String]
# Determine trait inheritance

roll_mutation() -> Dictionary
# Check for mutations
```

## Serialization Patterns

### Standard Serialization
```gdscript
# All data classes implement these
func to_dict() -> Dictionary:
    return {
        "version": 1,
        "id": id,
        "data": _serialize_data()
    }

func from_dict(data: Dictionary) -> bool:
    if not _validate_version(data.get("version", 0)):
        return false

    id = data.get("id", "")
    _deserialize_data(data.get("data", {}))
    return true

func _serialize_data() -> Dictionary:
    # Custom serialization logic
    return {}

func _deserialize_data(data: Dictionary) -> void:
    # Custom deserialization logic
    pass
```

## Validation Patterns

### Data Validation
```gdscript
# All data classes should validate
func is_valid() -> bool:
    # Check required fields
    if id.is_empty():
        push_error("Missing ID")
        return false

    # Check value ranges
    if age_weeks < 0 or age_weeks > lifespan_weeks * 2:
        push_error("Invalid age")
        return false

    # Check references
    if not _validate_references():
        return false

    return true

func _validate_references() -> bool:
    # Validate external references
    return true
```

## Performance Considerations

### Data Class Guidelines
1. **No Signals**: Data classes never emit signals
2. **No Systems**: Never reference systems directly
3. **Pure Functions**: Methods should be side-effect free
4. **Immutable Defaults**: Use const for default values
5. **Efficient Storage**: Use appropriate types (int vs float)

### Memory Optimization
```gdscript
# Use packed arrays for large data sets
var large_dataset: PackedInt32Array

# Use dictionaries sparingly
var sparse_data: Dictionary  # Only for truly dynamic data

# Clear unused references
func cleanup() -> void:
    large_dataset.clear()
    sparse_data.clear()
```

## Testing Data Classes

### Test Patterns
```gdscript
func test_creature_data():
    var creature = CreatureData.new()

    # Test initialization
    assert(not creature.id.is_empty())

    # Test stat clamping
    creature.strength = 2000
    assert(creature.strength == 1000)

    # Test age calculation
    creature.age_weeks = 260
    creature.lifespan_weeks = 520
    assert(creature.get_age_category() == GlobalEnums.AgeCategory.ADULT)

    # Test serialization
    var data = creature.to_dict()
    var loaded = CreatureData.new()
    assert(loaded.from_dict(data))
    assert(loaded.id == creature.id)
```

## Common Patterns

### Data Factory
```gdscript
class_name DataFactory

static func create_creature(species_id: String) -> CreatureData:
    var creature = CreatureData.new()
    creature.species_id = species_id
    creature.creature_name = generate_name()
    randomize_stats(creature)
    return creature

static func create_quest(type: GlobalEnums.QuestType) -> QuestData:
    var quest = QuestData.new()
    quest.quest_type = type
    setup_objectives(quest)
    return quest
```

### Data Validation Service
```gdscript
class_name DataValidator

static func validate_creature(creature: CreatureData) -> Array[String]:
    var errors: Array[String] = []

    if creature.id.is_empty():
        errors.append("Missing creature ID")

    if creature.species_id.is_empty():
        errors.append("Missing species ID")

    if creature.age_weeks > creature.lifespan_weeks:
        errors.append("Age exceeds lifespan")

    return errors
```