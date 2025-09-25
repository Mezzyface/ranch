# Task 04: Tag System Implementation

## Overview
Implement the complete tag system that defines creature traits, behaviors, and environmental adaptations as a GameCore subsystem. Tags are essential for quest requirements and creature specialization.

## Dependencies
- Task 01: GameCore Setup (complete)
- Task 02: CreatureData/CreatureEntity separation (complete)
- Design document: `tags.md`

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- TagSystem as GameCore subsystem (NOT autoload)
- All signals go through SignalBus
- Works with CreatureData (pure data) and CreatureEntity (behavior)
- Lazy-loaded by GameCore when needed

From `tags.md` and quest documentation:
- Tags define creature capabilities and behaviors
- Essential for quest requirement matching
- 12+ core tags covering size, behavior, abilities, and traits
- Tags affect breeding compatibility and inheritance
- Some tags are mutually exclusive

## Requirements

### Tag Categories

1. **Size Tags** (Mutually Exclusive)
   - `Small`: Compact creatures (under 50cm)
   - `Medium`: Standard size (50-150cm)
   - `Large`: Big creatures (over 150cm)

2. **Behavioral Tags**
   - `Territorial`: Guards and defends areas
   - `Social`: Works well in groups
   - `Solitary`: Prefers working alone
   - `Nocturnal`: Active at night
   - `Diurnal`: Active during day
   - `Crepuscular`: Active at dawn/dusk

3. **Physical Traits**
   - `Winged`: Has wings (may not fly)
   - `Flies`: Can fly (requires Winged)
   - `Aquatic`: Water-adapted
   - `Terrestrial`: Land-based
   - `Natural Armor`: Built-in protection
   - `Camouflage`: Blending abilities

4. **Ability Tags**
   - `Dark Vision`: See in darkness
   - `Enhanced Hearing`: Superior audio perception
   - `Bioluminescent`: Produces light
   - `Stealthy`: Moves quietly
   - `Sure-Footed`: Excellent balance

5. **Utility Tags**
   - `Constructor`: Can build/dig
   - `Cleanser`: Sanitation abilities
   - `Messenger`: Communication/delivery
   - `Problem Solver`: High intelligence
   - `Sentient`: Self-aware intelligence

### Tag Rules
1. **Mutual Exclusions**
   - Size tags (Small/Medium/Large)
   - Activity patterns (Nocturnal/Diurnal/Crepuscular)
   - Some behavioral traits (Social/Solitary)

2. **Dependencies**
   - `Flies` requires `Winged`
   - `Sentient` requires `Problem Solver`

3. **Incompatibilities**
   - `Aquatic` incompatible with `Flies`
   - `Natural Armor` incompatible with `Stealthy` (usually)

## Implementation Steps

1. **Create TagSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for all signals
   - Lazy-loaded subsystem

2. **Implement Tag Validation**
   - Tag compatibility checking
   - Mutual exclusion logic
   - Dependency resolution

3. **Create Tag Utilities**
   - Tag inheritance for breeding
   - Tag-based filtering
   - Quest requirement matching

4. **Integrate with CreatureEntity**
   - Tag modification through CreatureEntity
   - SignalBus notifications
   - Validation before changes

## Test Criteria

### Unit Tests
- [ ] All tags can be created and assigned
- [ ] Mutually exclusive tags prevent conflicts
- [ ] Dependent tags enforce requirements
- [ ] Invalid tags are rejected
- [ ] Tag queries return correct results

### Validation Tests
- [ ] Cannot have multiple size tags
- [ ] Cannot have conflicting activity patterns
- [ ] Cannot add Flies without Winged
- [ ] Incompatible tags are prevented

### Integration Tests
- [ ] CreatureEntity can modify tags through TagSystem
- [ ] Tag requirements match correctly for quests
- [ ] Tag filtering works on creature collections
- [ ] Tags persist through save/load
- [ ] SignalBus properly routes tag change events

## Code Implementation

### TagSystem - GameCore Subsystem
```gdscript
# scripts/systems/tag_system.gd
class_name TagSystem
extends Node

var signal_bus: SignalBus

# NOTE: Stage 1 uses string-based tags for simplicity
# TODO: In later stages, update to use Enums.CreatureTag from global enums
# TODO: Update CreatureData tags from Array[String] to Array[Enums.CreatureTag]
# This will provide type safety and prevent typos in tag names

enum TagCategory {
    SIZE,
    BEHAVIORAL,
    PHYSICAL,
    ABILITY,
    UTILITY
}

# NOTE: Using string keys for Stage 1 - will migrate to enum-based system later
const TAGS = {
    # Size Tags (Mutually Exclusive)
    "Small": {
        "category": TagCategory.SIZE,
        "description": "Compact creature under 50cm",
        "exclusive_group": "size"
    },
    "Medium": {
        "category": TagCategory.SIZE,
        "description": "Standard size 50-150cm",
        "exclusive_group": "size"
    },
    "Large": {
        "category": TagCategory.SIZE,
        "description": "Big creature over 150cm",
        "exclusive_group": "size"
    },

    # Behavioral Tags
    "Territorial": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Guards and defends specific areas"
    },
    "Social": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Works well with other creatures",
        "incompatible": ["Solitary"]
    },
    "Solitary": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Prefers to work alone",
        "incompatible": ["Social"]
    },
    "Nocturnal": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Active during nighttime",
        "exclusive_group": "activity"
    },
    "Diurnal": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Active during daytime",
        "exclusive_group": "activity"
    },
    "Crepuscular": {
        "category": TagCategory.BEHAVIORAL,
        "description": "Active at dawn and dusk",
        "exclusive_group": "activity"
    },

    # Physical Traits
    "Winged": {
        "category": TagCategory.PHYSICAL,
        "description": "Has wings (may not fly)"
    },
    "Flies": {
        "category": TagCategory.PHYSICAL,
        "description": "Capable of flight",
        "requires": ["Winged"],
        "incompatible": ["Aquatic"]
    },
    "Aquatic": {
        "category": TagCategory.PHYSICAL,
        "description": "Adapted for water environments",
        "incompatible": ["Flies"]
    },
    "Terrestrial": {
        "category": TagCategory.PHYSICAL,
        "description": "Land-based creature"
    },
    "Natural Armor": {
        "category": TagCategory.PHYSICAL,
        "description": "Built-in protective covering"
    },
    "Camouflage": {
        "category": TagCategory.PHYSICAL,
        "description": "Can blend with surroundings"
    },

    # Ability Tags
    "Dark Vision": {
        "category": TagCategory.ABILITY,
        "description": "Can see in complete darkness"
    },
    "Enhanced Hearing": {
        "category": TagCategory.ABILITY,
        "description": "Superior audio perception"
    },
    "Bioluminescent": {
        "category": TagCategory.ABILITY,
        "description": "Produces natural light"
    },
    "Stealthy": {
        "category": TagCategory.ABILITY,
        "description": "Moves quietly and unseen"
    },
    "Sure-Footed": {
        "category": TagCategory.ABILITY,
        "description": "Excellent balance and grip"
    },

    # Utility Tags
    "Constructor": {
        "category": TagCategory.UTILITY,
        "description": "Can build and dig structures"
    },
    "Cleanser": {
        "category": TagCategory.UTILITY,
        "description": "Sanitation and cleaning abilities"
    },
    "Messenger": {
        "category": TagCategory.UTILITY,
        "description": "Communication and delivery skills"
    },
    "Problem Solver": {
        "category": TagCategory.UTILITY,
        "description": "High intelligence and reasoning"
    },
    "Sentient": {
        "category": TagCategory.UTILITY,
        "description": "Self-aware intelligence",
        "requires": ["Problem Solver"]
    }
}

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    print("TagSystem initialized")

# Tag data access
func get_tag_data(tag_name: String) -> Dictionary:
    return TAGS.get(tag_name, {})

func is_valid_tag(tag_name: String) -> bool:
    return TAGS.has(tag_name)

func get_tags_by_category(category: TagCategory) -> Array[String]:
    var result: Array[String] = []
    for tag_name in TAGS:
        if TAGS[tag_name].category == category:
            result.append(tag_name)
    return result

func get_all_tags() -> Array[String]:
    var result: Array[String] = []
    for tag_name in TAGS:
        result.append(tag_name)
    return result

# Validation methods
func validate_tag_combination(tags: Array[String]) -> Dictionary:
    var result = {
        "valid": true,
        "errors": []
    }

    var exclusive_groups = {}

    for tag in tags:
        if not is_valid_tag(tag):
            result.valid = false
            result.errors.append("Invalid tag: " + tag)
            continue

        var tag_data = get_tag_data(tag)

        # Check exclusive groups
        if tag_data.has("exclusive_group"):
            var group = tag_data.exclusive_group
            if exclusive_groups.has(group):
                result.valid = false
                result.errors.append("Cannot have both " + exclusive_groups[group] + " and " + tag)
            else:
                exclusive_groups[group] = tag

        # Check requirements
        if tag_data.has("requires"):
            for required_tag in tag_data.requires:
                if not required_tag in tags:
                    result.valid = false
                    result.errors.append(tag + " requires " + required_tag)

        # Check incompatibilities
        if tag_data.has("incompatible"):
            for incompatible_tag in tag_data.incompatible:
                if incompatible_tag in tags:
                    result.valid = false
                    result.errors.append(tag + " is incompatible with " + incompatible_tag)

    return result

# CreatureEntity integration
func can_add_tag_to_creature(creature_data: CreatureData, new_tag: String) -> Dictionary:
    if not is_valid_tag(new_tag):
        return {"can_add": false, "reason": "Invalid tag"}

    if creature_data.has_tag(new_tag):
        return {"can_add": false, "reason": "Creature already has this tag"}

    var test_tags = creature_data.tags.duplicate()
    test_tags.append(new_tag)

    var validation = validate_tag_combination(test_tags)
    if not validation.valid:
        return {"can_add": false, "reason": validation.errors[0]}

    return {"can_add": true, "reason": ""}

func add_tag_to_creature(creature_entity: CreatureEntity, tag: String) -> bool:
    var check = can_add_tag_to_creature(creature_entity.data, tag)
    if not check.can_add:
        if signal_bus:
            signal_bus.tag_add_failed.emit(creature_entity.data, tag, check.reason)
        return false

    # Add to the data
    creature_entity.data.tags.append(tag)

    # Emit signal via SignalBus
    if signal_bus:
        signal_bus.creature_tag_added.emit(creature_entity.data, tag)

    return true

func remove_tag_from_creature(creature_entity: CreatureEntity, tag: String) -> bool:
    if not creature_entity.data.has_tag(tag):
        return false

    creature_entity.data.tags.erase(tag)

    if signal_bus:
        signal_bus.creature_tag_removed.emit(creature_entity.data, tag)

    return true

# Remove tags that would conflict with a new tag
func get_tags_to_remove_for(current_tags: Array[String], new_tag: String) -> Array[String]:
    var to_remove: Array[String] = []
    var tag_data = get_tag_data(new_tag)

    # Check exclusive group
    if tag_data.has("exclusive_group"):
        var group = tag_data.exclusive_group
        for existing_tag in current_tags:
            var existing_data = get_tag_data(existing_tag)
            if existing_data.has("exclusive_group") and existing_data.exclusive_group == group:
                to_remove.append(existing_tag)

    # Check incompatibilities
    if tag_data.has("incompatible"):
        for incompatible in tag_data.incompatible:
            if incompatible in current_tags:
                to_remove.append(incompatible)

    return to_remove

# Quest requirement matching
func meets_tag_requirements(creature_data: CreatureData, required_tags: Array[String]) -> bool:
    for tag in required_tags:
        if not creature_data.has_tag(tag):
            return false
    return true

# Collection filtering
func filter_creatures_by_tags(
    creatures: Array[CreatureData],
    required_tags: Array[String],
    excluded_tags: Array[String] = []
) -> Array[CreatureData]:
    var filtered: Array[CreatureData] = []

    for creature_data in creatures:
        var meets_requirements = true

        # Check required tags
        for tag in required_tags:
            if not creature_data.has_tag(tag):
                meets_requirements = false
                break

        # Check excluded tags
        if meets_requirements:
            for tag in excluded_tags:
                if creature_data.has_tag(tag):
                    meets_requirements = false
                    break

        if meets_requirements:
            filtered.append(creature_data)

    return filtered

# Breeding inheritance
func calculate_inherited_tags(parent1_tags: Array[String], parent2_tags: Array[String]) -> Array[String]:
    var inherited: Array[String] = []
    var all_parent_tags = {}

    # Count occurrences
    for tag in parent1_tags:
        all_parent_tags[tag] = all_parent_tags.get(tag, 0) + 1
    for tag in parent2_tags:
        all_parent_tags[tag] = all_parent_tags.get(tag, 0) + 1

    # Inherit tags based on rules
    for tag in all_parent_tags:
        var tag_data = get_tag_data(tag)
        var inherit_chance = 0.5  # Base 50% chance if one parent has it

        if all_parent_tags[tag] == 2:
            inherit_chance = 0.9  # 90% if both parents have it

        # Size tags special handling - always inherit one
        if tag_data.has("exclusive_group") and tag_data.exclusive_group == "size":
            if all_parent_tags[tag] == 2:
                inherited.append(tag)  # Both parents same size
                break

        # Physical traits have higher inheritance
        if tag_data.category == TagCategory.PHYSICAL:
            inherit_chance += 0.1

        if randf() < inherit_chance:
            inherited.append(tag)

    # Ensure valid combination
    var validation = validate_tag_combination(inherited)
    if not validation.valid:
        # Remove conflicting tags
        for error in validation.errors:
            # Simple conflict resolution - remove last added conflicting tag
            if inherited.size() > 0:
                inherited.pop_back()

    # Ensure at least one size tag
    if not has_size_tag(inherited):
        inherited.append("Medium")  # Default to medium

    return inherited

# Utility methods
func has_size_tag(tags: Array[String]) -> bool:
    for tag in tags:
        var tag_data = get_tag_data(tag)
        if tag_data.has("exclusive_group") and tag_data.exclusive_group == "size":
            return true
    return false

func get_tag_description(tag_name: String) -> String:
    var tag_data = get_tag_data(tag_name)
    return tag_data.get("description", "Unknown tag")

func get_tag_category(tag_name: String) -> TagCategory:
    var tag_data = get_tag_data(tag_name)
    return tag_data.get("category", -1)

func calculate_tag_match_score(creature_tags: Array[String], required_tags: Array[String]) -> float:
    if required_tags.is_empty():
        return 1.0

    var matches = 0
    for tag in required_tags:
        if tag in creature_tags:
            matches += 1

    return float(matches) / float(required_tags.size())

# Team building suggestions
func get_complementary_tags(existing_tags: Array[String]) -> Array[String]:
    var complementary: Array[String] = []

    # If we have stealth, flight complements well
    if "Stealthy" in existing_tags and not "Flies" in existing_tags:
        complementary.append("Flies")

    # If we have strength, armor complements
    if "Large" in existing_tags and not "Natural Armor" in existing_tags:
        complementary.append("Natural Armor")

    # If we have intelligence, communication helps
    if "Problem Solver" in existing_tags and not "Messenger" in existing_tags:
        complementary.append("Messenger")

    return complementary
```

## Success Metrics
- TagSystem loads as GameCore subsystem in < 1ms
- Tag validation completes in < 1ms
- All tag rules enforced correctly
- Tag filtering handles 1000+ creatures efficiently
- Inheritance produces valid tag combinations
- Clear error messages for conflicts
- All signals properly routed through SignalBus

## Notes
- Keep tag definitions data-driven for easy updates
- Consider localization for tag names/descriptions
- Cache validation results when possible
- Ensure thread safety for tag queries
- TagSystem is lazy-loaded by GameCore when needed

## Estimated Time
3-4 hours for implementation and testing