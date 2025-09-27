# Collection System API Reference

## Overview

The PlayerCollection system manages the player's creature roster, handling both active creatures (up to 6) and stable storage. It provides comprehensive creature management with performance optimization and milestone tracking.

**Important**: Only active creatures are affected by weekly aging - stable creatures remain in stasis and do not age during weekly updates.

## Core Components

### PlayerCollection (`scripts/systems/player_collection.gd`)

Central system for managing creature ownership and organization.

#### Key Properties
```gdscript
# Constants
MAX_ACTIVE_CREATURES: int = 6      # Active roster limit
COLLECTION_SAVE_KEY: String         # Save system identifier

# Collection Data
active_roster: Array[CreatureData]  # Currently active creatures
stable_collection: Dictionary       # creature_id -> CreatureData
collection_metadata: Dictionary     # Statistics and history

# Performance Caches
_active_lookup: Dictionary          # Fast active roster access
_stable_lookup: Dictionary          # Fast stable access
_stats_cache: Dictionary           # Cached statistics
```

#### Core Methods

##### Roster Management
```gdscript
add_to_active(creature_data: CreatureData) -> bool
# Add creature to active roster (6 creature limit)
# Returns: true if successful

remove_from_active(creature_id: String) -> CreatureData
# Remove creature from active roster
# Returns: removed creature or null

move_to_stable(creature_id: String) -> bool
# Move creature from active to stable
# Returns: true if successful

retrieve_from_stable(creature_id: String) -> bool
# Move creature from stable to active
# Returns: true if successful

swap_active_positions(index1: int, index2: int) -> bool
# Swap positions of two active creatures
# Returns: true if successful
```

##### Collection Operations
```gdscript
add_creature(creature_data: CreatureData, to_active: bool = true) -> bool
# Add new creature to collection
# to_active: true for active roster, false for stable
# Returns: true if successful

remove_creature(creature_id: String, permanent: bool = false) -> bool
# Remove creature from collection
# permanent: true to delete, false to release
# Returns: true if successful

transfer_creature(creature_id: String, to_player: String) -> bool
# Transfer creature to another player (multiplayer)
# Returns: true if transfer successful

release_creature(creature_id: String) -> bool
# Release creature back to wild
# Returns: true if successful
```

##### Query Methods
```gdscript
get_creature(creature_id: String) -> CreatureData
# Get creature from anywhere in collection
# Returns: creature data or null

get_active_creatures() -> Array[CreatureData]
# Get all active roster creatures
# Returns: array of active creatures

get_stable_creatures() -> Array[CreatureData]
# Get all stable creatures
# Returns: array of stable creatures

get_all_creatures() -> Array[CreatureData]
# Get entire collection (active + stable)
# Returns: combined array

has_creature(creature_id: String) -> bool
# Check if creature is in collection
# Returns: true if owned

is_creature_active(creature_id: String) -> bool
# Check if creature is in active roster
# Returns: true if active
```

##### Filtering and Search
```gdscript
get_creatures_by_species(species_id: String) -> Array[CreatureData]
# Get all creatures of specific species
# Returns: filtered array

get_creatures_by_tag(tag: String) -> Array[CreatureData]
# Get all creatures with specific tag
# Returns: filtered array

get_creatures_by_filter(filter: Dictionary) -> Array[CreatureData]
# Complex filtering with multiple criteria
# filter: {species_id, tags, min_age, max_age, etc.}
# Returns: filtered array

search_creatures(query: String) -> Array[CreatureData]
# Search by name or description
# Returns: matching creatures
```

##### Statistics
```gdscript
get_collection_stats() -> Dictionary
# Get comprehensive collection statistics
# Returns: {total, active_count, stable_count, species_breakdown, etc.}

get_species_count(species_id: String) -> int
# Count creatures of specific species
# Returns: count

get_total_count() -> int
# Get total creature count
# Returns: active + stable count

get_milestone_progress() -> Dictionary
# Get milestone achievement status
# Returns: {milestone_name: achieved}
```

##### Batch Operations
```gdscript
batch_add_creatures(creatures: Array[CreatureData], quiet: bool = true) -> int
# Add multiple creatures efficiently
# Returns: number successfully added

batch_remove_creatures(creature_ids: Array[String]) -> int
# Remove multiple creatures
# Returns: number removed

batch_move_to_stable(creature_ids: Array[String]) -> int
# Move multiple creatures to stable
# Returns: number moved
```

## Signal Integration

### Collection Signals

All collection signals emit through SignalBus:

```gdscript
# Roster changes
signal creature_added_to_active(creature: CreatureData)
signal creature_removed_from_active(creature: CreatureData)
signal creature_moved_to_stable(creature: CreatureData)
signal creature_retrieved_from_stable(creature: CreatureData)

# Collection events
signal creature_acquired(creature: CreatureData, source: String)
signal creature_released(creature: CreatureData)
signal creature_expired(creature: CreatureData)

# Milestones
signal collection_milestone_reached(milestone: String, count: int)

# Updates
signal active_roster_updated(operation: String, creature_id: String)
signal stable_collection_updated(operation: String, creature_id: String)
```

### Signal Usage Example
```gdscript
var bus = GameCore.get_signal_bus()

# Listen for new creatures
bus.creature_acquired.connect(_on_creature_acquired)

# Listen for roster changes
bus.creature_added_to_active.connect(_on_active_updated)

# Monitor milestones
bus.collection_milestone_reached.connect(_on_milestone)

func _on_creature_acquired(creature: CreatureData, source: String):
    print("New creature from %s: %s" % [source, creature.creature_name])
```

## Usage Patterns

### Basic Collection Management
```gdscript
var collection = GameCore.get_system("collection")

# Add new creature
var creature = CreatureData.new()
creature.creature_name = "Fluffy"
creature.species_id = "forest_sprite"

if collection.add_creature(creature, true):  # Add to active
    print("Added %s to active roster" % creature.creature_name)

# Move to stable when roster is full
if collection.active_roster.size() >= 6:
    collection.move_to_stable(oldest_creature.id)
```

### Roster Organization
```gdscript
var collection = GameCore.get_system("collection")

# Swap creature positions
collection.swap_active_positions(0, 2)  # Swap first and third

# Retrieve from stable
if collection.retrieve_from_stable(creature_id):
    print("Retrieved creature from stable")

# Organize by species
var dragons = collection.get_creatures_by_species("fire_dragon")
for dragon in dragons:
    if not collection.is_creature_active(dragon.id):
        collection.retrieve_from_stable(dragon.id)
```

### Advanced Filtering
```gdscript
var collection = GameCore.get_system("collection")

# Complex filter
var filter = {
    "species_id": "crystal_wolf",
    "min_age": 10,
    "max_age": 50,
    "tags": ["trained", "competition_ready"],
    "min_stats": {"strength": 20}
}

var eligible = collection.get_creatures_by_filter(filter)
print("Found %d eligible creatures" % eligible.size())

# Search by name
var results = collection.search_creatures("Dragon")
for creature in results:
    print("Found: %s" % creature.creature_name)
```

### Batch Operations
```gdscript
var collection = GameCore.get_system("collection")

# Batch add from generation
var new_creatures: Array[CreatureData] = []
for i in 10:
    var creature = generate_random_creature()
    new_creatures.append(creature)

collection.set_quiet_mode(true)  # Reduce logging
var added = collection.batch_add_creatures(new_creatures)
collection.set_quiet_mode(false)
print("Added %d/%d creatures" % [added, new_creatures.size()])

# Batch release old creatures
var to_release: Array[String] = []
for creature in collection.get_all_creatures():
    if creature.age_weeks > creature.lifespan_weeks * 0.9:
        to_release.append(creature.id)

var released = collection.batch_remove_creatures(to_release)
print("Released %d old creatures" % released)
```

## Milestones

### Built-in Milestones
```gdscript
const MILESTONES: Dictionary = {
    "first_creature": 1,       # First creature acquired
    "small_collection": 5,     # Beginner collector
    "growing_collection": 10,  # Getting serious
    "large_collection": 25,    # Dedicated collector
    "huge_collection": 50,     # Master collector
    "master_collection": 100   # Ultimate achievement
}
```

### Milestone Tracking
```gdscript
var collection = GameCore.get_system("collection")

# Check milestone progress
var progress = collection.get_milestone_progress()
for milestone in progress:
    if progress[milestone]:
        print("✓ %s achieved!" % milestone)
    else:
        var needed = MILESTONES[milestone] - collection.get_total_count()
        print("  %s: %d more needed" % [milestone, needed])
```

## Save System Integration

### Automatic Persistence
```gdscript
# Collection automatically integrates with SaveSystem
var save_system = GameCore.get_system("save")

# Collection state is saved automatically
save_system.save_game("slot1")

# Collection restored on load
save_system.load_game("slot1")
```

### Manual State Management
```gdscript
var collection = GameCore.get_system("collection")

# Export collection state
var state = collection.serialize_collection_data()

# Restore collection state
collection.deserialize_collection_data(state)
```

## Performance Optimization

### Caching System
```gdscript
# Statistics are cached until invalidated
var stats = collection.get_collection_stats()  # First call: calculates
var stats2 = collection.get_collection_stats() # Second call: uses cache

# Cache invalidated on changes
collection.add_creature(new_creature)  # Cache cleared
var stats3 = collection.get_collection_stats() # Recalculates
```

### Quiet Mode
```gdscript
# Reduce logging during bulk operations
collection.set_quiet_mode(true)

# Perform bulk operations
for i in 100:
    collection.add_creature(generate_creature())

collection.set_quiet_mode(false)
```

### Performance Baselines
- Add/remove creature: < 5ms
- Batch add 100 creatures: < 50ms
- Filter 1000 creatures: < 20ms
- Calculate statistics: < 10ms (cached: < 1ms)

## Error Handling

### Common Errors
1. **Roster Full**: Active roster at 6 creature limit
2. **Creature Not Found**: Invalid creature ID
3. **Duplicate Addition**: Creature already in collection
4. **Invalid Transfer**: Creature expired or invalid state

### Error Recovery
```gdscript
var collection = GameCore.get_system("collection")

# Safe creature addition
func add_creature_safe(creature: CreatureData) -> bool:
    if creature == null:
        push_error("Cannot add null creature")
        return false

    if collection.has_creature(creature.id):
        push_warning("Creature already in collection")
        return true

    # Try active first, fall back to stable
    if not collection.add_to_active(creature):
        return collection.add_creature(creature, false)  # Add to stable

    return true
```

## Testing

### Test Coverage
- Roster management (add, remove, move, swap)
- Collection limits and constraints
- Filtering and search functionality
- Milestone tracking
- Save/load persistence
- Batch operation performance
- Signal emission verification

### Test Files
- `tests/individual/test_collection.tscn` - Core functionality
- `tests/individual/test_collection_ui.tscn` - UI integration

## Common Patterns

### Collection Observer
```gdscript
class_name CollectionObserver
extends Node

var collection: PlayerCollection

func _ready():
    collection = GameCore.get_system("collection")
    var bus = GameCore.get_signal_bus()

    bus.creature_added_to_active.connect(_on_roster_change)
    bus.creature_removed_from_active.connect(_on_roster_change)

func _on_roster_change(creature: CreatureData):
    update_ui()
    check_achievements()
    save_state()
```

### Collection Filter Builder
```gdscript
class_name CollectionFilter

var filters: Dictionary = {}

func with_species(species_id: String) -> CollectionFilter:
    filters["species_id"] = species_id
    return self

func with_min_age(age: int) -> CollectionFilter:
    filters["min_age"] = age
    return self

func with_tags(tags: Array[String]) -> CollectionFilter:
    filters["tags"] = tags
    return self

func apply(collection: PlayerCollection) -> Array[CreatureData]:
    return collection.get_creatures_by_filter(filters)
```

## Migration Notes

### From Legacy System
```gdscript
# Old: Direct array manipulation
player_creatures.append(creature)

# New: Collection system
var collection = GameCore.get_system("collection")
collection.add_creature(creature)
```

### Data Migration
```gdscript
# Migrate old save format
func migrate_legacy_collection(old_data: Dictionary):
    var collection = GameCore.get_system("collection")

    # Clear existing
    collection.clear_collection()

    # Import old creatures
    for creature_data in old_data.get("creatures", []):
        var creature = CreatureData.new()
        creature.deserialize(creature_data)
        collection.add_creature(creature)
```