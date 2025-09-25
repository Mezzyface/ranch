# Task 08: Player Collection Management

## Overview
Implement the player's creature collection system as a GameCore subsystem that manages active and stable creatures, enforces limits, and provides collection operations using the improved CreatureData/CreatureEntity architecture.

## Dependencies
- Task 01: GameCore Setup (complete)
- Task 02: CreatureData/CreatureEntity separation (complete)
- Task 05: Creature Generation (complete)
- Task 07: Save/Load System (complete)
- Design documents: `creature.md`, `time.md`

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- CollectionSystem as GameCore subsystem (NOT autoload)
- Stores CreatureData, creates CreatureEntity only when needed for behavior
- All signals go through SignalBus
- Lazy-loaded by GameCore when needed
- Integrates with SaveSystem for persistence

From the design documents:
- Players have a creature collection with active and stable states
- Active creatures participate in activities and age
- Stable creatures are stored and don't age
- Limited active slots (initially 5, expandable)
- Unlimited stable storage

## Requirements

### Collection Structure
1. **Active Roster**
   - Maximum 5 creatures initially
   - Participate in weekly activities
   - Age each week
   - Consume resources

2. **Stable Storage**
   - Unlimited capacity
   - Creatures don't age
   - Can swap with active roster
   - Organized by various criteria

3. **Collection Operations**
   - Add new creatures
   - Move between active/stable
   - Release creatures
   - Sort and filter
   - Search capabilities

### Management Features
1. **Roster Management**
   - Swap creatures between states
   - Batch operations
   - Quick access to specific creatures
   - Validation for roster limits

2. **Collection Statistics**
   - Total creature count
   - Species distribution
   - Stat averages
   - Age distribution
   - Tag frequency

3. **Collection Tools**
   - Comparison tools
   - Team builder suggestions
   - Quest requirement matcher
   - Breeding pair finder

## Implementation Steps

1. **Create CollectionSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for all signals
   - Lazy-loaded subsystem

2. **Implement Data Management**
   - Store CreatureData arrays
   - Create CreatureEntity on demand
   - Active/stable state management

3. **Add Collection Operations**
   - CRUD operations on creatures
   - State transitions
   - Batch operations

4. **Create Utility Methods**
   - Sorting algorithms
   - Filter system
   - Search functionality
   - Statistics calculator

## Test Criteria

### Unit Tests
- [ ] Add CreatureData to collection
- [ ] Move creatures between active/stable
- [ ] Enforce active roster limits
- [ ] Remove creatures from collection
- [ ] Collection persists through save/load

### Collection Operations
- [ ] Sort by all stat types
- [ ] Filter by tags works correctly
- [ ] Search by name functions
- [ ] Statistics calculate accurately
- [ ] Batch operations work

### Integration Tests
- [ ] Active creatures age properly through AgeSystem
- [ ] Stable creatures don't age
- [ ] Collection integrates with save system
- [ ] SignalBus properly routes collection events
- [ ] CreatureEntity creation on demand works
- [ ] Memory efficient with large collections

## Code Implementation

### CollectionSystem - GameCore Subsystem
```gdscript
# scripts/systems/collection_system.gd
class_name CollectionSystem
extends Node

var signal_bus: SignalBus

const DEFAULT_ACTIVE_SLOTS = 5
const MAX_ACTIVE_SLOTS = 10

# Data storage - only CreatureData, not entities
var active_creature_data: Array[CreatureData] = []
var stable_creature_data: Array[CreatureData] = []
var max_active_slots: int = DEFAULT_ACTIVE_SLOTS

# Entity cache - created on demand
var _active_entities: Dictionary = {}  # id -> CreatureEntity

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    print("CollectionSystem initialized")

# Collection Management - Data Level
func add_creature_data(creature_data: CreatureData, add_to_active: bool = false) -> bool:
    if add_to_active and active_creature_data.size() >= max_active_slots:
        push_warning("Active roster is full")
        add_to_active = false

    if add_to_active:
        active_creature_data.append(creature_data)
        creature_data.is_active = true
        if signal_bus:
            signal_bus.creature_added_to_active.emit(creature_data)
    else:
        stable_creature_data.append(creature_data)
        creature_data.is_active = false
        if signal_bus:
            signal_bus.creature_added_to_stable.emit(creature_data)

    if signal_bus:
        signal_bus.creature_added_to_collection.emit(creature_data)
        signal_bus.collection_changed.emit()

    return true

func remove_creature_data(creature_data: CreatureData) -> bool:
    var removed = false

    if creature_data in active_creature_data:
        active_creature_data.erase(creature_data)
        # Clean up entity cache
        if _active_entities.has(creature_data.id):
            _active_entities.erase(creature_data.id)
        removed = true
    elif creature_data in stable_creature_data:
        stable_creature_data.erase(creature_data)
        removed = true

    if removed:
        if signal_bus:
            signal_bus.creature_removed_from_collection.emit(creature_data)
            signal_bus.collection_changed.emit()

    return removed

# Roster Management - Data Level
func move_to_active(creature_data: CreatureData) -> bool:
    if active_creature_data.size() >= max_active_slots:
        push_warning("Active roster is full")
        return false

    if creature_data in active_creature_data:
        return true  # Already active

    if creature_data in stable_creature_data:
        stable_creature_data.erase(creature_data)
        active_creature_data.append(creature_data)
        creature_data.is_active = true

        if signal_bus:
            signal_bus.creature_moved_to_active.emit(creature_data)
            signal_bus.collection_changed.emit()
        return true

    return false

func move_to_stable(creature_data: CreatureData) -> bool:
    if creature_data in stable_creature_data:
        return true  # Already stable

    if creature_data in active_creature_data:
        active_creature_data.erase(creature_data)
        stable_creature_data.append(creature_data)
        creature_data.is_active = false

        # Clean up entity cache
        if _active_entities.has(creature_data.id):
            _active_entities.erase(creature_data.id)

        if signal_bus:
            signal_bus.creature_moved_to_stable.emit(creature_data)
            signal_bus.collection_changed.emit()
        return true

    return false

func swap_creatures(creature1_data: CreatureData, creature2_data: CreatureData) -> bool:
    var c1_active = creature1_data in active_creature_data
    var c2_active = creature2_data in active_creature_data

    if c1_active and c2_active:
        # Both active, just swap positions
        var idx1 = active_creature_data.find(creature1_data)
        var idx2 = active_creature_data.find(creature2_data)
        active_creature_data[idx1] = creature2_data
        active_creature_data[idx2] = creature1_data
    elif not c1_active and not c2_active:
        # Both stable, just swap positions
        var idx1 = stable_creature_data.find(creature1_data)
        var idx2 = stable_creature_data.find(creature2_data)
        stable_creature_data[idx1] = creature2_data
        stable_creature_data[idx2] = creature1_data
    else:
        # One active, one stable - swap states
        if c1_active:
            move_to_stable(creature1_data)
            move_to_active(creature2_data)
        else:
            move_to_stable(creature2_data)
            move_to_active(creature1_data)

    if signal_bus:
        signal_bus.collection_changed.emit()
    return true

# Entity Management - On-Demand Creation
func get_active_creature_entities() -> Array[CreatureEntity]:
    var entities: Array[CreatureEntity] = []

    for creature_data in active_creature_data:
        var entity = get_or_create_entity(creature_data)
        if entity:
            entities.append(entity)

    return entities

func get_or_create_entity(creature_data: CreatureData) -> CreatureEntity:
    # Return cached entity if exists
    if _active_entities.has(creature_data.id):
        return _active_entities[creature_data.id]

    # Create new entity for active creature
    if creature_data.is_active:
        var entity = CreatureEntity.new(creature_data)
        _active_entities[creature_data.id] = entity
        return entity

    # Don't create entities for stable creatures
    return null

# Collection Queries - Data Level
func get_all_creature_data() -> Array[CreatureData]:
    return active_creature_data + stable_creature_data

func get_active_creature_data() -> Array[CreatureData]:
    return active_creature_data.duplicate()

func get_stable_creature_data() -> Array[CreatureData]:
    return stable_creature_data.duplicate()

func get_creature_data_by_id(id: String) -> CreatureData:
    for creature_data in active_creature_data:
        if creature_data.id == id:
            return creature_data

    for creature_data in stable_creature_data:
        if creature_data.id == id:
            return creature_data

    return null

func get_active_creature_ids() -> Array[String]:
    var ids: Array[String] = []
    for creature_data in active_creature_data:
        ids.append(creature_data.id)
    return ids

func set_active_creature_ids(ids: Array[String]) -> void:
    # Used by SaveSystem for loading
    for creature_data in get_all_creature_data():
        if creature_data.id in ids:
            move_to_active(creature_data)
        else:
            move_to_stable(creature_data)

func get_creatures_by_species(species_id: String) -> Array[CreatureData]:
    var result: Array[CreatureData] = []

    for creature_data in get_all_creature_data():
        if creature_data.species_id == species_id:
            result.append(creature_data)

    return result

func get_creatures_with_tag(tag: String) -> Array[CreatureData]:
    var result: Array[CreatureData] = []

    for creature_data in get_all_creature_data():
        if creature_data.has_tag(tag):
            result.append(creature_data)

    return result

func get_creatures_meeting_requirements(
    min_stats: Dictionary = {},
    required_tags: Array[String] = []
) -> Array[CreatureData]:
    var result: Array[CreatureData] = []

    for creature_data in get_all_creature_data():
        var meets_requirements = true

        # Check stat requirements
        for stat_name in min_stats:
            if creature_data.get_stat(stat_name) < min_stats[stat_name]:
                meets_requirements = false
                break

        # Check tag requirements
        if meets_requirements:
            for tag in required_tags:
                if not creature_data.has_tag(tag):
                    meets_requirements = false
                    break

        if meets_requirements:
            result.append(creature_data)

    return result

# Sorting Functions
func sort_by_stat(creatures: Array[CreatureData], stat_name: String, descending: bool = true) -> Array[CreatureData]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        var a_val = a.get_stat(stat_name)
        var b_val = b.get_stat(stat_name)
        return a_val > b_val if descending else a_val < b_val
    )

    return sorted

func sort_by_total_stats(creatures: Array[CreatureData], descending: bool = true) -> Array[CreatureData]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        var a_total = _calculate_total_stats(a)
        var b_total = _calculate_total_stats(b)
        return a_total > b_total if descending else a_total < b_total
    )

    return sorted

func sort_by_age(creatures: Array[CreatureData], descending: bool = false) -> Array[CreatureData]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        return a.age_weeks > b.age_weeks if descending else a.age_weeks < b.age_weeks
    )

    return sorted

func sort_by_name(creatures: Array[CreatureData]) -> Array[CreatureData]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        return a.creature_name.naturalnocasecmp_to(b.creature_name) < 0
    )

    return sorted

# Collection Statistics
func get_collection_stats() -> Dictionary:
    var all_creatures = get_all_creature_data()

    if all_creatures.is_empty():
        return {
            "total_count": 0,
            "active_count": 0,
            "stable_count": 0
        }

    var stats = {
        "total_count": all_creatures.size(),
        "active_count": active_creature_data.size(),
        "stable_count": stable_creature_data.size(),
        "species_distribution": {},
        "age_distribution": {"baby": 0, "juvenile": 0, "adult": 0, "elder": 0, "ancient": 0},
        "tag_frequency": {},
        "average_stats": {
            "strength": 0,
            "constitution": 0,
            "dexterity": 0,
            "intelligence": 0,
            "wisdom": 0,
            "discipline": 0
        }
    }

    for creature_data in all_creatures:
        # Species distribution
        if not stats.species_distribution.has(creature_data.species_id):
            stats.species_distribution[creature_data.species_id] = 0
        stats.species_distribution[creature_data.species_id] += 1

        # Age distribution using AgeSystem
        var age_system = GameCore.get_system("age") as AgeSystem
        if age_system:
            var age_category = age_system.get_age_category(creature_data)
            match age_category:
                0: stats.age_distribution.baby += 1
                1: stats.age_distribution.juvenile += 1
                2: stats.age_distribution.adult += 1
                3: stats.age_distribution.elder += 1
                4: stats.age_distribution.ancient += 1

        # Tag frequency
        for tag in creature_data.tags:
            if not stats.tag_frequency.has(tag):
                stats.tag_frequency[tag] = 0
            stats.tag_frequency[tag] += 1

        # Average stats
        stats.average_stats.strength += creature_data.strength
        stats.average_stats.constitution += creature_data.constitution
        stats.average_stats.dexterity += creature_data.dexterity
        stats.average_stats.intelligence += creature_data.intelligence
        stats.average_stats.wisdom += creature_data.wisdom
        stats.average_stats.discipline += creature_data.discipline

    # Calculate averages
    var count = all_creatures.size()
    stats.average_stats.strength /= count
    stats.average_stats.constitution /= count
    stats.average_stats.dexterity /= count
    stats.average_stats.intelligence /= count
    stats.average_stats.wisdom /= count
    stats.average_stats.discipline /= count

    return stats

# Utility Functions
func has_active_slots() -> bool:
    return active_creature_data.size() < max_active_slots

func get_available_active_slots() -> int:
    return max_active_slots - active_creature_data.size()

func expand_active_slots(additional_slots: int = 1) -> void:
    max_active_slots = mini(max_active_slots + additional_slots, MAX_ACTIVE_SLOTS)

func release_creature(creature_data: CreatureData) -> bool:
    return remove_creature_data(creature_data)

func release_multiple(creatures: Array[CreatureData]) -> void:
    for creature_data in creatures:
        release_creature(creature_data)

# Team Building Helpers
func find_best_team_for_quest(requirements: Dictionary) -> Array[CreatureData]:
    var candidates = get_creatures_meeting_requirements(
        requirements.get("min_stats", {}),
        requirements.get("required_tags", [])
    )

    # Sort by total stats to get best candidates
    candidates = sort_by_total_stats(candidates)

    # Return top candidates up to active slot limit
    var team: Array[CreatureData] = []
    for i in mini(candidates.size(), max_active_slots):
        team.append(candidates[i])

    return team

func find_breeding_pairs(egg_group: String = "") -> Array[Dictionary]:
    var pairs: Array[Dictionary] = []
    var all_creatures = get_all_creature_data()

    for i in range(all_creatures.size()):
        for j in range(i + 1, all_creatures.size()):
            var c1 = all_creatures[i]
            var c2 = all_creatures[j]

            # Check egg group compatibility
            if egg_group.is_empty() or (c1.egg_group == egg_group and c2.egg_group == egg_group):
                if c1.egg_group == c2.egg_group:
                    pairs.append({
                        "parent1": c1,
                        "parent2": c2,
                        "compatibility": 1.0  # Placeholder for compatibility calculation
                    })

    return pairs

# Batch Operations
func activate_all_of_species(species_id: String) -> void:
    var creatures = get_creatures_by_species(species_id)
    for creature_data in creatures:
        if has_active_slots():
            move_to_active(creature_data)

func retire_elderly() -> void:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return

    var elderly: Array[CreatureData] = []

    for creature_data in active_creature_data:
        if age_system.should_retire(creature_data):
            elderly.append(creature_data)

    for creature_data in elderly:
        move_to_stable(creature_data)

# Save/Load Integration
func clear_all_creatures() -> void:
    active_creature_data.clear()
    stable_creature_data.clear()
    _active_entities.clear()

# Helper methods
func _calculate_total_stats(creature_data: CreatureData) -> int:
    return creature_data.strength + creature_data.constitution + creature_data.dexterity + \
           creature_data.intelligence + creature_data.wisdom + creature_data.discipline
```

### Collection Filter System - Utility Class
```gdscript
# scripts/utils/collection_filter.gd
class_name CollectionFilter
extends RefCounted

enum FilterType {
    NONE,
    SPECIES,
    TAG,
    STAT_MINIMUM,
    STAT_MAXIMUM,
    AGE_CATEGORY,
    EGG_GROUP,
    ACTIVE_STATUS
}

var filters: Array[Dictionary] = []

func add_filter(type: FilterType, value) -> void:
    filters.append({
        "type": type,
        "value": value
    })

func clear_filters() -> void:
    filters.clear()

func apply_filters(creatures: Array[CreatureData]) -> Array[CreatureData]:
    var filtered = creatures.duplicate()

    for filter in filters:
        filtered = _apply_single_filter(filtered, filter)

    return filtered

func _apply_single_filter(creatures: Array[CreatureData], filter: Dictionary) -> Array[CreatureData]:
    var result: Array[CreatureData] = []

    for creature_data in creatures:
        var passes = false

        match filter.type:
            FilterType.SPECIES:
                passes = creature_data.species_id == filter.value

            FilterType.TAG:
                passes = creature_data.has_tag(filter.value)

            FilterType.STAT_MINIMUM:
                var stat_name = filter.value.stat
                var min_value = filter.value.min
                passes = creature_data.get_stat(stat_name) >= min_value

            FilterType.STAT_MAXIMUM:
                var stat_name = filter.value.stat
                var max_value = filter.value.max
                passes = creature_data.get_stat(stat_name) <= max_value

            FilterType.AGE_CATEGORY:
                var age_system = GameCore.get_system("age") as AgeSystem
                if age_system:
                    passes = age_system.get_age_category(creature_data) == filter.value

            FilterType.EGG_GROUP:
                passes = creature_data.egg_group == filter.value

            FilterType.ACTIVE_STATUS:
                passes = creature_data.is_active == filter.value

            FilterType.NONE:
                passes = true

        if passes:
            result.append(creature_data)

    return result
```

## Success Metrics
- CollectionSystem loads as GameCore subsystem in < 10ms
- Collection operations complete in < 10ms
- Handle 1000+ creatures efficiently
- Sorting/filtering responsive with large collections
- No memory leaks with collection operations
- Save/load preserves collection integrity
- CreatureEntity creation on-demand works correctly
- All signals properly routed through SignalBus

## Notes
- CollectionSystem is a GameCore subsystem, not an autoload
- Stores CreatureData, creates CreatureEntity only when needed
- Entity cache managed automatically
- Consider pagination for large collections
- Cache statistics for performance
- Add collection achievements/milestones in future stages

## Estimated Time
4-5 hours for implementation and testing