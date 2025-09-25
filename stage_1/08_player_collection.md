# Task 08: Player Collection Management

## Overview
Implement the player's creature collection system that manages active and stable creatures, enforces limits, and provides collection operations.

## Dependencies
- Task 02: Creature Class (complete)
- Task 05: Creature Generation (complete)
- Task 07: Save/Load System (complete)
- Design documents: `creature.md`, `time.md`

## Context
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

1. **Create Collection Manager**
   - Active/stable lists
   - Collection operations
   - Limit enforcement
   - Event signals

2. **Implement Roster System**
   - Active slot management
   - Swap mechanics
   - Validation rules
   - Quick operations

3. **Add Collection Tools**
   - Sorting algorithms
   - Filter system
   - Search functionality
   - Statistics calculator

4. **Create Collection UI Helper**
   - Display formatting
   - Collection views
   - Operation shortcuts
   - Visual indicators

## Test Criteria

### Unit Tests
- [ ] Add creatures to collection
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
- [ ] Active creatures age properly
- [ ] Stable creatures don't age
- [ ] Collection integrates with save system
- [ ] UI updates reflect collection changes
- [ ] Memory efficient with large collections

## Code Implementation

### CollectionManager Singleton (`scripts/systems/collection_manager.gd`)
```gdscript
extends Node

signal creature_added(creature: Creature)
signal creature_removed(creature: Creature)
signal creature_moved_to_active(creature: Creature)
signal creature_moved_to_stable(creature: Creature)
signal collection_changed()

const DEFAULT_ACTIVE_SLOTS = 5
const MAX_ACTIVE_SLOTS = 10

var active_creatures: Array[Creature] = []
var stable_creatures: Array[Creature] = []
var max_active_slots: int = DEFAULT_ACTIVE_SLOTS

# Collection Management
func add_creature(creature: Creature, add_to_active: bool = false) -> bool:
    if add_to_active and active_creatures.size() >= max_active_slots:
        push_warning("Active roster is full")
        add_to_active = false

    if add_to_active:
        active_creatures.append(creature)
        # NOTE: Using CreatureState enum would be cleaner here
        # TODO: Update to creature.state = Enums.CreatureState.ACTIVE when enum is implemented
        creature.is_active = true
        emit_signal("creature_added", creature)
        emit_signal("creature_moved_to_active", creature)
    else:
        stable_creatures.append(creature)
        creature.is_active = false
        emit_signal("creature_added", creature)
        emit_signal("creature_moved_to_stable", creature)

    emit_signal("collection_changed")
    return true

func remove_creature(creature: Creature) -> bool:
    var removed = false

    if creature in active_creatures:
        active_creatures.erase(creature)
        removed = true
    elif creature in stable_creatures:
        stable_creatures.erase(creature)
        removed = true

    if removed:
        emit_signal("creature_removed", creature)
        emit_signal("collection_changed")

    return removed

# Roster Management
func move_to_active(creature: Creature) -> bool:
    if active_creatures.size() >= max_active_slots:
        push_warning("Active roster is full")
        return false

    if creature in active_creatures:
        return true  # Already active

    if creature in stable_creatures:
        stable_creatures.erase(creature)
        active_creatures.append(creature)
        creature.is_active = true
        emit_signal("creature_moved_to_active", creature)
        emit_signal("collection_changed")
        return true

    return false

func move_to_stable(creature: Creature) -> bool:
    if creature in stable_creatures:
        return true  # Already stable

    if creature in active_creatures:
        active_creatures.erase(creature)
        stable_creatures.append(creature)
        creature.is_active = false
        emit_signal("creature_moved_to_stable", creature)
        emit_signal("collection_changed")
        return true

    return false

func swap_creatures(creature1: Creature, creature2: Creature) -> bool:
    var c1_active = creature1 in active_creatures
    var c2_active = creature2 in active_creatures

    if c1_active and c2_active:
        # Both active, just swap positions
        var idx1 = active_creatures.find(creature1)
        var idx2 = active_creatures.find(creature2)
        active_creatures[idx1] = creature2
        active_creatures[idx2] = creature1
    elif not c1_active and not c2_active:
        # Both stable, just swap positions
        var idx1 = stable_creatures.find(creature1)
        var idx2 = stable_creatures.find(creature2)
        stable_creatures[idx1] = creature2
        stable_creatures[idx2] = creature1
    else:
        # One active, one stable - swap states
        if c1_active:
            move_to_stable(creature1)
            move_to_active(creature2)
        else:
            move_to_stable(creature2)
            move_to_active(creature1)

    emit_signal("collection_changed")
    return true

# Collection Queries
func get_all_creatures() -> Array[Creature]:
    return active_creatures + stable_creatures

func get_creature_by_id(id: String) -> Creature:
    for creature in active_creatures:
        if creature.id == id:
            return creature

    for creature in stable_creatures:
        if creature.id == id:
            return creature

    return null

func get_creatures_by_species(species: String) -> Array[Creature]:
    var result: Array[Creature] = []

    for creature in get_all_creatures():
        if creature.species == species:
            result.append(creature)

    return result

func get_creatures_with_tag(tag: String) -> Array[Creature]:
    var result: Array[Creature] = []

    for creature in get_all_creatures():
        if creature.has_tag(tag):
            result.append(creature)

    return result

func get_creatures_meeting_requirements(
    min_stats: Dictionary = {},
    required_tags: Array[String] = []
) -> Array[Creature]:
    var result: Array[Creature] = []

    for creature in get_all_creatures():
        var meets_requirements = true

        # Check stat requirements
        for stat_name in min_stats:
            if creature.get_stat(stat_name) < min_stats[stat_name]:
                meets_requirements = false
                break

        # Check tag requirements
        if meets_requirements:
            for tag in required_tags:
                if not creature.has_tag(tag):
                    meets_requirements = false
                    break

        if meets_requirements:
            result.append(creature)

    return result

# Sorting Functions
func sort_by_stat(creatures: Array[Creature], stat_name: String, descending: bool = true) -> Array[Creature]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        var a_val = a.get_stat(stat_name)
        var b_val = b.get_stat(stat_name)
        return a_val > b_val if descending else a_val < b_val
    )

    return sorted

func sort_by_total_stats(creatures: Array[Creature], descending: bool = true) -> Array[Creature]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        var a_total = StatManager.calculate_total_stats(a)
        var b_total = StatManager.calculate_total_stats(b)
        return a_total > b_total if descending else a_total < b_total
    )

    return sorted

func sort_by_age(creatures: Array[Creature], descending: bool = false) -> Array[Creature]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        return a.age_weeks > b.age_weeks if descending else a.age_weeks < b.age_weeks
    )

    return sorted

func sort_by_name(creatures: Array[Creature]) -> Array[Creature]:
    var sorted = creatures.duplicate()

    sorted.sort_custom(func(a, b):
        return a.name.naturalnocasecmp_to(b.name) < 0
    )

    return sorted

# Collection Statistics
func get_collection_stats() -> Dictionary:
    var all_creatures = get_all_creatures()

    if all_creatures.is_empty():
        return {
            "total_count": 0,
            "active_count": 0,
            "stable_count": 0
        }

    var stats = {
        "total_count": all_creatures.size(),
        "active_count": active_creatures.size(),
        "stable_count": stable_creatures.size(),
        "species_distribution": {},
        "age_distribution": {"young": 0, "adult": 0, "elder": 0},
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

    for creature in all_creatures:
        # Species distribution
        if not stats.species_distribution.has(creature.species):
            stats.species_distribution[creature.species] = 0
        stats.species_distribution[creature.species] += 1

        # Age distribution
        match creature.get_age_category():
            Creature.AgeCategory.YOUNG:
                stats.age_distribution.young += 1
            Creature.AgeCategory.ADULT:
                stats.age_distribution.adult += 1
            Creature.AgeCategory.ELDER:
                stats.age_distribution.elder += 1

        # Tag frequency
        for tag in creature.tags:
            if not stats.tag_frequency.has(tag):
                stats.tag_frequency[tag] = 0
            stats.tag_frequency[tag] += 1

        # Average stats
        stats.average_stats.strength += creature.strength
        stats.average_stats.constitution += creature.constitution
        stats.average_stats.dexterity += creature.dexterity
        stats.average_stats.intelligence += creature.intelligence
        stats.average_stats.wisdom += creature.wisdom
        stats.average_stats.discipline += creature.discipline

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
    return active_creatures.size() < max_active_slots

func get_available_active_slots() -> int:
    return max_active_slots - active_creatures.size()

func expand_active_slots(additional_slots: int = 1):
    max_active_slots = mini(max_active_slots + additional_slots, MAX_ACTIVE_SLOTS)

func release_creature(creature: Creature) -> bool:
    return remove_creature(creature)

func release_multiple(creatures: Array[Creature]):
    for creature in creatures:
        release_creature(creature)

# Team Building Helpers
func find_best_team_for_quest(requirements: Dictionary) -> Array[Creature]:
    var candidates = get_creatures_meeting_requirements(
        requirements.get("min_stats", {}),
        requirements.get("required_tags", [])
    )

    # Sort by total stats to get best candidates
    candidates = sort_by_total_stats(candidates)

    # Return top candidates up to active slot limit
    var team: Array[Creature] = []
    for i in mini(candidates.size(), max_active_slots):
        team.append(candidates[i])

    return team

func find_breeding_pairs(egg_group: String = "") -> Array[Dictionary]:
    var pairs: Array[Dictionary] = []
    var all_creatures = get_all_creatures()

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
func activate_all_of_species(species: String):
    var creatures = get_creatures_by_species(species)
    for creature in creatures:
        if has_active_slots():
            move_to_active(creature)

func retire_elderly():
    var elderly: Array[Creature] = []

    for creature in active_creatures:
        if AgeManager.should_retire(creature):
            elderly.append(creature)

    for creature in elderly:
        move_to_stable(creature)

# Save/Load Integration
func save_collection() -> Dictionary:
    var data = {
        "active_creatures": [],
        "stable_creatures": [],
        "max_active_slots": max_active_slots
    }

    for creature in active_creatures:
        data.active_creatures.append(creature.to_dict())

    for creature in stable_creatures:
        data.stable_creatures.append(creature.to_dict())

    return data

func load_collection(data: Dictionary):
    active_creatures.clear()
    stable_creatures.clear()

    max_active_slots = data.get("max_active_slots", DEFAULT_ACTIVE_SLOTS)

    for creature_data in data.get("active_creatures", []):
        var creature = Creature.from_dict(creature_data)
        creature.is_active = true
        active_creatures.append(creature)

    for creature_data in data.get("stable_creatures", []):
        var creature = Creature.from_dict(creature_data)
        creature.is_active = false
        stable_creatures.append(creature)

    emit_signal("collection_changed")
```

### Collection Filter System (`scripts/ui/collection_filter.gd`)
```gdscript
class_name CollectionFilter
extends RefCounted

enum FilterType {
    NONE,
    SPECIES,
    TAG,
    STAT_MINIMUM,
    STAT_MAXIMUM,
    AGE_CATEGORY,
    EGG_GROUP
}

var filters: Array[Dictionary] = []

func add_filter(type: FilterType, value):
    filters.append({
        "type": type,
        "value": value
    })

func clear_filters():
    filters.clear()

func apply_filters(creatures: Array[Creature]) -> Array[Creature]:
    var filtered = creatures.duplicate()

    for filter in filters:
        filtered = _apply_single_filter(filtered, filter)

    return filtered

func _apply_single_filter(creatures: Array[Creature], filter: Dictionary) -> Array[Creature]:
    var result: Array[Creature] = []

    for creature in creatures:
        var passes = false

        match filter.type:
            FilterType.SPECIES:
                passes = creature.species == filter.value

            FilterType.TAG:
                passes = creature.has_tag(filter.value)

            FilterType.STAT_MINIMUM:
                var stat_name = filter.value.stat
                var min_value = filter.value.min
                passes = creature.get_stat(stat_name) >= min_value

            FilterType.STAT_MAXIMUM:
                var stat_name = filter.value.stat
                var max_value = filter.value.max
                passes = creature.get_stat(stat_name) <= max_value

            FilterType.AGE_CATEGORY:
                passes = creature.get_age_category() == filter.value

            FilterType.EGG_GROUP:
                passes = creature.egg_group == filter.value

            FilterType.NONE:
                passes = true

        if passes:
            result.append(creature)

    return result
```

## Success Metrics
- Collection operations complete in < 10ms
- Handle 1000+ creatures efficiently
- Sorting/filtering responsive with large collections
- No memory leaks with collection operations
- Save/load preserves collection integrity

## Notes
- Consider pagination for large collections
- Cache statistics for performance
- Add collection achievements/milestones
- Plan for collection sharing features

## Estimated Time
4-5 hours for implementation and testing