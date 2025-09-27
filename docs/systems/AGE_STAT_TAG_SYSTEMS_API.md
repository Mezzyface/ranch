# Age, Stat, and Tag Systems API Reference

## Overview

These systems manage creature aging, statistics, and tagging functionality. They work together to provide comprehensive creature state management while maintaining separation of concerns.

**Important**: Only active creatures are affected by aging during weekly updates - stable creatures remain in stasis and do not age.

## AgeSystem (`scripts/systems/age_system.gd`)

Manages creature aging and lifespan mechanics.

### Key Properties
```gdscript
# Configuration
const DEFAULT_LIFESPAN_WEEKS: int = 520  # 10 years
const AGE_VARIANCE: float = 0.1          # ±10% lifespan variance

# State
aging_enabled: bool = true               # Global aging toggle
age_multiplier: float = 1.0             # Speed modifier
```

### Core Methods

#### Age Progression
```gdscript
age_creature(creature: CreatureData, weeks: int = 1) -> void
# Age single creature by specified weeks
# Emits signals for category changes

age_all_creatures(creatures: Array[CreatureData], weeks: int = 1) -> void
# Batch age multiple creatures efficiently

advance_age_with_events(creature: CreatureData, weeks: int) -> Dictionary
# Age with event generation
# Returns: {aged_weeks, events: Array, category_changed: bool}
```

#### Age Queries
```gdscript
get_age_category(creature: CreatureData) -> GlobalEnums.AgeCategory
# Get creature's current age category

get_remaining_lifespan(creature: CreatureData) -> int
# Calculate weeks until natural expiration

get_age_percentage(creature: CreatureData) -> float
# Get age as percentage of lifespan (0.0-1.0)

is_expired(creature: CreatureData) -> bool
# Check if creature exceeded lifespan
```

#### Age Effects
```gdscript
apply_age_modifiers(creature: CreatureData) -> void
# Apply age-based stat modifiers

calculate_age_modifier(category: GlobalEnums.AgeCategory) -> float
# Get modifier for age category (0.6-1.0)

get_age_traits(creature: CreatureData) -> Array[String]
# Get age-specific traits
```

### Usage Example
```gdscript
var age_system = GameCore.get_system("age")
var collection = GameCore.get_system("collection")

# Age all active creatures weekly (stable creatures remain in stasis)
var active = collection.get_active_creatures()
age_system.age_all_creatures(active, 1)

# Check specific creature
var creature = collection.get_creature("creature_123")
if age_system.is_expired(creature):
    print("%s has expired" % creature.creature_name)

# Get age info
var category = age_system.get_age_category(creature)
var remaining = age_system.get_remaining_lifespan(creature)
print("%s is %s with %d weeks remaining" % [
    creature.creature_name,
    GlobalEnums.get_age_category_name(category),
    remaining
])
```

### Signals
```gdscript
# Emitted via SignalBus
signal creature_aged(creature: CreatureData, new_age: int)
signal age_category_changed(creature: CreatureData, new_category: int)
signal creature_expired(creature: CreatureData)
signal batch_aging_completed(count: int, duration_ms: int)
```

## StatSystem (`scripts/systems/stat_system.gd`)

Manages creature statistics and stat modifications.

### Key Properties
```gdscript
# Stat Limits
const MIN_STAT_VALUE: int = 1
const MAX_STAT_VALUE: int = 1000
const DEFAULT_STAT_VALUE: int = 50

# Modifiers
active_modifiers: Dictionary  # {creature_id: {stat: modifier}}
temporary_boosts: Dictionary  # {creature_id: {stat: {value, expires}}}
```

### Core Methods

#### Stat Management
```gdscript
set_stat(creature: CreatureData, stat: GlobalEnums.StatType, value: int) -> void
# Set base stat value (clamped to limits)

modify_stat(creature: CreatureData, stat: GlobalEnums.StatType, delta: int) -> void
# Adjust stat by delta amount

get_effective_stat(creature: CreatureData, stat: GlobalEnums.StatType) -> int
# Get stat with all modifiers applied

reset_stats(creature: CreatureData) -> void
# Reset all stats to species defaults
```

#### Stat Modifiers
```gdscript
apply_modifier(creature_id: String, stat: GlobalEnums.StatType, modifier: float) -> void
# Apply permanent modifier (multiplicative)

apply_temporary_boost(
    creature_id: String,
    stat: GlobalEnums.StatType,
    boost: int,
    duration_weeks: int
) -> void
# Apply temporary stat boost

remove_modifier(creature_id: String, stat: GlobalEnums.StatType) -> void
# Remove specific modifier

clear_all_modifiers(creature_id: String) -> void
# Remove all modifiers for creature
```

#### Stat Calculations
```gdscript
calculate_power_level(creature: CreatureData) -> int
# Calculate overall power rating

get_stat_distribution(creature: CreatureData) -> Dictionary
# Get stat percentages for visualization

compare_stats(creature_a: CreatureData, creature_b: CreatureData) -> Dictionary
# Compare two creatures' stats
# Returns: {stat: difference}

get_stat_growth(creature: CreatureData, levels: int) -> Dictionary
# Predict stat growth over levels
```

#### Batch Operations
```gdscript
batch_modify_stats(
    creatures: Array[CreatureData],
    stat: GlobalEnums.StatType,
    delta: int
) -> void
# Modify stat for multiple creatures

apply_training_session(
    creatures: Array[CreatureData],
    training_type: String
) -> Dictionary
# Apply training effects
# Returns: {creature_id: stat_changes}
```

### Usage Example
```gdscript
var stat_system = GameCore.get_system("stat")

# Modify creature stats
var creature = get_creature()
stat_system.modify_stat(creature, GlobalEnums.StatType.STRENGTH, 10)

# Apply temporary boost
stat_system.apply_temporary_boost(
    creature.id,
    GlobalEnums.StatType.SPEED,
    20,
    4  # 4 weeks duration
)

# Get effective stats
var strength = stat_system.get_effective_stat(
    creature,
    GlobalEnums.StatType.STRENGTH
)
print("Effective strength: %d" % strength)

# Training session
var trainees = [creature1, creature2, creature3]
var results = stat_system.apply_training_session(trainees, "strength")
for id in results:
    print("Creature %s gained: %s" % [id, results[id]])
```

### Signals
```gdscript
# Emitted via SignalBus
signal stat_modified(creature: CreatureData, stat: int, old_value: int, new_value: int)
signal modifier_applied(creature_id: String, stat: int, modifier: float)
signal boost_expired(creature_id: String, stat: int)
signal power_level_changed(creature: CreatureData, new_level: int)
```

## TagSystem (`scripts/systems/tag_system.gd`)

Manages creature tags for categorization and filtering.

### Key Properties
```gdscript
# Tag Categories
const SYSTEM_TAGS: Array[String] = ["starter", "legendary", "shiny"]
const MAX_TAGS_PER_CREATURE: int = 20

# Tag Registry
registered_tags: Dictionary  # {tag_name: tag_data}
creature_tags: Dictionary    # {creature_id: Array[String]}
```

### Core Methods

#### Tag Management
```gdscript
add_tag(creature: CreatureData, tag: String) -> bool
# Add tag to creature
# Returns: success status

remove_tag(creature: CreatureData, tag: String) -> bool
# Remove tag from creature
# Returns: success status

has_tag(creature: CreatureData, tag: String) -> bool
# Check if creature has tag

get_tags(creature: CreatureData) -> Array[String]
# Get all creature tags

clear_tags(creature: CreatureData) -> void
# Remove all tags from creature
```

#### Tag Registry
```gdscript
register_tag(tag_name: String, data: Dictionary = {}) -> void
# Register new tag type
# data: {color, icon, description, category}

is_tag_registered(tag_name: String) -> bool
# Check if tag is registered

get_tag_data(tag_name: String) -> Dictionary
# Get tag metadata

get_all_registered_tags() -> Array[String]
# Get list of all tags
```

#### Tag Queries
```gdscript
get_creatures_with_tag(tag: String) -> Array[CreatureData]
# Find all creatures with specific tag

get_creatures_with_tags(tags: Array[String], match_all: bool = false) -> Array[CreatureData]
# Find creatures with multiple tags
# match_all: true = AND, false = OR

get_tag_statistics() -> Dictionary
# Get tag usage statistics
# Returns: {tag_name: count}

get_related_tags(tag: String) -> Array[String]
# Find commonly co-occurring tags
```

#### Batch Operations
```gdscript
batch_add_tag(creatures: Array[CreatureData], tag: String) -> int
# Add tag to multiple creatures
# Returns: number tagged

batch_remove_tag(creatures: Array[CreatureData], tag: String) -> int
# Remove tag from multiple creatures
# Returns: number untagged

apply_auto_tags(creature: CreatureData) -> Array[String]
# Apply automatic tags based on stats/properties
# Returns: applied tags
```

### Tag Categories
```gdscript
enum TagCategory {
    SYSTEM,      # System-assigned
    RARITY,      # Rarity indicators
    TRAINING,    # Training status
    COMBAT,      # Battle-related
    BREEDING,    # Breeding tags
    CUSTOM,      # User-defined
    EVENT        # Event-specific
}
```

### Usage Example
```gdscript
var tag_system = GameCore.get_system("tag")

# Register custom tag
tag_system.register_tag("champion", {
    "color": Color.GOLD,
    "icon": "crown",
    "description": "Competition winner",
    "category": TagCategory.COMBAT
})

# Tag creature
var creature = get_creature()
tag_system.add_tag(creature, "trained")
tag_system.add_tag(creature, "champion")

# Query by tags
var trained = tag_system.get_creatures_with_tag("trained")
print("Found %d trained creatures" % trained.size())

# Multiple tag query
var elite = tag_system.get_creatures_with_tags(
    ["trained", "champion"],
    true  # Must have both
)

# Auto-tagging
var auto_tags = tag_system.apply_auto_tags(creature)
print("Auto-applied tags: %s" % auto_tags)
```

### Signals
```gdscript
# Emitted via SignalBus
signal tag_added(creature: CreatureData, tag: String)
signal tag_removed(creature: CreatureData, tag: String)
signal tags_cleared(creature: CreatureData)
signal tag_registered(tag_name: String, data: Dictionary)
```

## System Integration

### Cross-System Operations

#### Age-Stat Integration
```gdscript
# Age affects stats through modifiers
var age_system = GameCore.get_system("age")
var stat_system = GameCore.get_system("stat")

func update_age_modifiers(creature: CreatureData):
    var age_mod = age_system.calculate_age_modifier(
        creature.get_age_category()
    )
    stat_system.apply_modifier(
        creature.id,
        GlobalEnums.StatType.ALL,  # Apply to all stats
        age_mod
    )
```

#### Tag-Based Stat Bonuses
```gdscript
# Tags can provide stat bonuses
var tag_system = GameCore.get_system("tag")
var stat_system = GameCore.get_system("stat")

func apply_tag_bonuses(creature: CreatureData):
    if tag_system.has_tag(creature, "trained"):
        stat_system.apply_modifier(creature.id, GlobalEnums.StatType.DISCIPLINE, 1.2)

    if tag_system.has_tag(creature, "wild"):
        stat_system.apply_modifier(creature.id, GlobalEnums.StatType.STRENGTH, 1.1)
```

#### Age-Based Tagging
```gdscript
# Auto-apply age tags
var age_system = GameCore.get_system("age")
var tag_system = GameCore.get_system("tag")

func update_age_tags(creature: CreatureData):
    var category = age_system.get_age_category(creature)

    # Remove old age tags
    for tag in ["young", "mature", "elder"]:
        tag_system.remove_tag(creature, tag)

    # Add appropriate age tag
    match category:
        GlobalEnums.AgeCategory.BABY, GlobalEnums.AgeCategory.JUVENILE:
            tag_system.add_tag(creature, "young")
        GlobalEnums.AgeCategory.ADULT:
            tag_system.add_tag(creature, "mature")
        GlobalEnums.AgeCategory.ELDER, GlobalEnums.AgeCategory.ANCIENT:
            tag_system.add_tag(creature, "elder")
```

## Performance Optimization

### Batch Processing
```gdscript
# Efficient batch operations
func weekly_update():
    var collection = GameCore.get_system("collection")
    var creatures = collection.get_active_creatures()

    # Batch age
    age_system.set_quiet_mode(true)
    age_system.age_all_creatures(creatures, 1)

    # Batch stat updates
    stat_system.batch_process_modifier_expiry()

    # Batch auto-tagging
    for creature in creatures:
        tag_system.apply_auto_tags(creature)

    age_system.set_quiet_mode(false)
```

### Caching
```gdscript
# Systems cache frequently accessed data
var _stat_cache: Dictionary = {}
var _tag_lookup: Dictionary = {}

func get_cached_stat(creature_id: String, stat: int) -> int:
    var key = "%s_%d" % [creature_id, stat]
    if not _stat_cache.has(key):
        _stat_cache[key] = calculate_stat(creature_id, stat)
    return _stat_cache[key]

func invalidate_cache(creature_id: String = ""):
    if creature_id.is_empty():
        _stat_cache.clear()
    else:
        var keys_to_remove = []
        for key in _stat_cache:
            if key.begins_with(creature_id):
                keys_to_remove.append(key)
        for key in keys_to_remove:
            _stat_cache.erase(key)
```

## Testing

### Test Files
- `tests/individual/test_age.tscn` - Age system tests
- `tests/individual/test_stats.tscn` - Stat system tests
- `tests/individual/test_tags.tscn` - Tag system tests

### Test Patterns
```gdscript
func test_age_progression():
    var age_system = GameCore.get_system("age")
    var creature = create_test_creature()
    creature.age_weeks = 50
    creature.lifespan_weeks = 520

    # Test aging
    age_system.age_creature(creature, 10)
    assert(creature.age_weeks == 60)

    # Test category
    var category = age_system.get_age_category(creature)
    assert(category == GlobalEnums.AgeCategory.JUVENILE)

func test_stat_modifiers():
    var stat_system = GameCore.get_system("stat")
    var creature = create_test_creature()
    creature.strength = 100

    # Apply modifier
    stat_system.apply_modifier(creature.id, GlobalEnums.StatType.STRENGTH, 1.5)

    # Check effective stat
    var effective = stat_system.get_effective_stat(creature, GlobalEnums.StatType.STRENGTH)
    assert(effective == 150)

func test_tag_operations():
    var tag_system = GameCore.get_system("tag")
    var creature = create_test_creature()

    # Add tags
    assert(tag_system.add_tag(creature, "test_tag"))
    assert(tag_system.has_tag(creature, "test_tag"))

    # Remove tags
    assert(tag_system.remove_tag(creature, "test_tag"))
    assert(not tag_system.has_tag(creature, "test_tag"))
```

## Common Patterns

### System Facade
```gdscript
class_name CreatureSystemFacade

static func get_creature_summary(creature: CreatureData) -> Dictionary:
    var age_system = GameCore.get_system("age")
    var stat_system = GameCore.get_system("stat")
    var tag_system = GameCore.get_system("tag")

    return {
        "age_category": age_system.get_age_category(creature),
        "remaining_life": age_system.get_remaining_lifespan(creature),
        "power_level": stat_system.calculate_power_level(creature),
        "tags": tag_system.get_tags(creature),
        "effective_stats": stat_system.get_all_effective_stats(creature)
    }
```

### Event Chain
```gdscript
# Age change triggers stat update triggers tag update
func setup_event_chain():
    var bus = GameCore.get_signal_bus()

    bus.age_category_changed.connect(_on_age_changed)
    bus.stat_modified.connect(_on_stat_changed)

func _on_age_changed(creature: CreatureData, category: int):
    # Update age-based stat modifiers
    update_age_modifiers(creature)

func _on_stat_changed(creature: CreatureData, stat: int, old: int, new: int):
    # Update stat-based tags
    update_stat_tags(creature)
```