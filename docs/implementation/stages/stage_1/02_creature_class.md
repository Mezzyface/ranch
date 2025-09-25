# Task 02: Creature Class Implementation

## Overview
Create the core Creature class that represents individual creatures with their properties, stats, tags, and behaviors. This is the fundamental data structure for the entire game.

## Dependencies
- Task 01: Project Setup (must be complete)
- Access to design documents: `creature.md`, `stats.md`, `tags.md`

## Context
From `creature.md` and related documentation:
- Creatures have 6 core stats (STR, CON, DEX, INT, WIS, DIS)
- Stats range from 0-1000 with different growth patterns
- Creatures have tags that define behaviors and capabilities
- Each creature has an age that affects performance
- Creatures can be in active or stable states

## Requirements

### Creature Class Structure
The Creature class must include:

1. **Identity Properties**
   - `id`: Unique identifier (UUID)
   - `name`: Display name
   - `species`: Species identifier
   - `owner`: Reference to owning player

2. **Stats System**
   - `strength` (STR): Physical power
   - `constitution` (CON): Health and endurance
   - `dexterity` (DEX): Speed and agility
   - `intelligence` (INT): Mental capacity
   - `wisdom` (WIS): Awareness and intuition
   - `discipline` (DIS): Obedience and reliability

3. **Tag System**
   - `tags`: Array of string tags
   - Support for 12 essential tags from design

4. **Age System**
   - `age_weeks`: Age in weeks
   - `age_category`: Calculated (young/adult/elder)
   - `lifespan`: Expected lifespan in weeks

5. **State Management**
   - `is_active`: Active vs stable state
   - `stamina_current`: Current stamina points
   - `stamina_max`: Maximum stamina points
   - `status_effects`: Array of active effects

6. **Breeding Properties**
   - `egg_group`: Breeding compatibility group
   - `parent_ids`: Array of parent creature IDs
   - `generation`: Breeding generation number

### Resource Definition
Create a custom resource for creature data persistence:
```
CreatureResource (Resource)
├── All creature properties
├── Serialization methods
└── Validation methods
```

## Implementation Steps

1. **Create Base Creature Script**
   - Location: `scripts/creatures/creature.gd`
   - Extends: Resource (for easy serialization)
   - Include all required properties

2. **Implement Stat Management**
   - Stat getters/setters with validation
   - Ensure stats stay within 0-1000 range
   - Calculate modified stats based on age

3. **Implement Tag System**
   - Tag addition/removal methods
   - Tag query methods
   - Validation against allowed tags

4. **Implement Age System**
   - Age progression method
   - Age category calculation
   - Performance modifier calculation

5. **Add Utility Methods**
   - `matches_requirements()` - Check against quest requirements
   - `get_performance_score()` - Calculate competition performance
   - `can_breed_with()` - Check breeding compatibility
   - `to_dict()` / `from_dict()` - Serialization

## Test Criteria

### Unit Tests
- [ ] Create creature with default values
- [ ] Create creature with specific stat values
- [ ] Verify stat clamping (0-1000)
- [ ] Add and remove tags successfully
- [ ] Age progression increases age_weeks
- [ ] Age category updates correctly at thresholds
- [ ] Stamina updates within bounds
- [ ] Serialization and deserialization preserve data

### Validation Tests
- [ ] Stats cannot exceed 1000
- [ ] Stats cannot go below 0
- [ ] Invalid tags are rejected
- [ ] Age cannot be negative
- [ ] Stamina cannot exceed maximum

### Integration Tests
- [ ] Creature can be saved to disk
- [ ] Creature can be loaded from disk
- [ ] Multiple creatures can exist simultaneously
- [ ] Creature references remain stable

## Code Template

```gdscript
class_name Creature
extends Resource

# Signals for state changes (Godot 4.x style)
signal stats_changed(stat_name: String, old_value: int, new_value: int)
signal age_changed(new_age_weeks: int)
signal tag_added(tag_name: String)
signal tag_removed(tag_name: String)

# Identity
@export var id: String = ""
@export var creature_name: String = ""  # Renamed to avoid conflict with Resource.name
# NOTE: species_id references a SpeciesResource
@export var species_id: String = ""  # References species_id in SpeciesResource

# Core Stats (0-1000) with Godot 4.x typed setters
@export_range(0, 1000) var strength: int = 50:
    set(value):
        var old_value := strength
        strength = clampi(value, 0, 1000)
        if old_value != strength:
            stats_changed.emit("strength", old_value, strength)

@export_range(0, 1000) var constitution: int = 50:
    set(value):
        var old_value := constitution
        constitution = clampi(value, 0, 1000)
        if old_value != constitution:
            stats_changed.emit("constitution", old_value, constitution)

@export_range(0, 1000) var dexterity: int = 50:
    set(value):
        var old_value := dexterity
        dexterity = clampi(value, 0, 1000)
        if old_value != dexterity:
            stats_changed.emit("dexterity", old_value, dexterity)

@export_range(0, 1000) var intelligence: int = 50:
    set(value):
        var old_value := intelligence
        intelligence = clampi(value, 0, 1000)
        if old_value != intelligence:
            stats_changed.emit("intelligence", old_value, intelligence)

@export_range(0, 1000) var wisdom: int = 50:
    set(value):
        var old_value := wisdom
        wisdom = clampi(value, 0, 1000)
        if old_value != wisdom:
            stats_changed.emit("wisdom", old_value, wisdom)

@export_range(0, 1000) var discipline: int = 50:
    set(value):
        var old_value := discipline
        discipline = clampi(value, 0, 1000)
        if old_value != discipline:
            stats_changed.emit("discipline", old_value, discipline)

# Tags (Godot 4.x typed arrays)
@export var tags: Array[String] = []

# Age System with ranges
@export_range(0, 1000) var age_weeks: int = 0:
    set(value):
        var old_age := age_weeks
        age_weeks = maxi(0, value)
        if old_age != age_weeks:
            age_changed.emit(age_weeks)

@export_range(100, 1000) var lifespan: int = 520  # 10 years default

# State Management
@export var is_active: bool = false
@export_range(0, 200) var stamina_current: int = 100:
    set(value):
        stamina_current = clampi(value, 0, stamina_max)
@export_range(50, 200) var stamina_max: int = 100

# Breeding Properties
@export var egg_group: String = ""
@export var parent_ids: Array[String] = []
@export_range(1, 10) var generation: int = 1

# Constructor with proper initialization
func _init() -> void:
    if id.is_empty():
        id = generate_unique_id()

# Age category calculation with proper enum typing
func get_age_category() -> int:  # Returns int since Enums.AgeCategory will be int-based
    var life_percentage := (age_weeks / float(lifespan)) * 100
    if life_percentage < 10:
        return Enums.AgeCategory.BABY
    elif life_percentage < 25:
        return Enums.AgeCategory.JUVENILE
    elif life_percentage < 75:
        return Enums.AgeCategory.ADULT
    elif life_percentage < 90:
        return Enums.AgeCategory.ELDER
    else:
        return Enums.AgeCategory.ANCIENT

func get_age_modifier() -> float:
    match get_age_category():
        Enums.AgeCategory.BABY:
            return 0.6  # -40% performance
        Enums.AgeCategory.JUVENILE:
            return 0.8  # -20% performance
        Enums.AgeCategory.ADULT:
            return 1.0  # No modifier
        Enums.AgeCategory.ELDER:
            return 0.8  # -20% performance
        Enums.AgeCategory.ANCIENT:
            return 0.6  # -40% performance
        _:
            return 1.0

# Stat Accessors with typed return values
func get_stat(stat_name: String) -> int:
    match stat_name.to_upper():
        "STR", "STRENGTH": return strength
        "CON", "CONSTITUTION": return constitution
        "DEX", "DEXTERITY": return dexterity
        "INT", "INTELLIGENCE": return intelligence
        "WIS", "WISDOM": return wisdom
        "DIS", "DISCIPLINE": return discipline
        _:
            push_warning("Invalid stat name: " + stat_name)
            return 0

func set_stat(stat_name: String, value: int) -> void:
    match stat_name.to_upper():
        "STR", "STRENGTH": strength = value
        "CON", "CONSTITUTION": constitution = value
        "DEX", "DEXTERITY": dexterity = value
        "INT", "INTELLIGENCE": intelligence = value
        "WIS", "WISDOM": wisdom = value
        "DIS", "DISCIPLINE": discipline = value
        _:
            push_warning("Invalid stat name: " + stat_name)

# Tag Management with signals
func add_tag(tag: String) -> bool:
    if not tag in tags and is_valid_tag(tag):
        tags.append(tag)
        tag_added.emit(tag)
        return true
    return false

func remove_tag(tag: String) -> bool:
    var removed := tags.erase(tag)
    if removed:
        tag_removed.emit(tag)
    return removed

func has_tag(tag: String) -> bool:
    return tag in tags

func has_all_tags(required_tags: Array[String]) -> bool:
    for tag in required_tags:
        if not has_tag(tag):
            return false
    return true

func has_any_tag(required_tags: Array[String]) -> bool:
    for tag in required_tags:
        if has_tag(tag):
            return true
    return false

# Validation
func is_valid_tag(tag: String) -> bool:
    # Will be expanded with actual tag list
    const VALID_TAGS = [
        "Small", "Medium", "Large",
        "Territorial", "Social", "Solitary",
        "Winged", "Aquatic", "Terrestrial",
        "Nocturnal", "Diurnal", "Crepuscular"
    ]
    return tag in VALID_TAGS

# Age Progression with stamina effects
func age_one_week() -> void:
    age_weeks += 1
    # Reduce stamina for active creatures
    if is_active:
        stamina_current = maxi(0, stamina_current - 10)

# Stamina Management with typed returns
func consume_stamina(amount: int) -> bool:
    if stamina_current >= amount:
        stamina_current -= amount
        return true
    return false

func restore_stamina(amount: int) -> void:
    stamina_current = mini(stamina_current + amount, stamina_max)

func rest_fully() -> void:
    stamina_current = stamina_max

# Utility with Godot 4.x Time API
func generate_unique_id() -> String:
    # Use Godot 4.x Time API for unique ID
    var timestamp := Time.get_unix_time_from_system()
    var random_suffix := randi() % 999999
    return "creature_%d_%06d" % [timestamp, random_suffix]

# Serialization with proper property names
func to_dict() -> Dictionary:
    return {
        "id": id,
        "creature_name": creature_name,  # Updated property name
        "species_id": species_id,  # Updated property name
        "stats": {
            "strength": strength,
            "constitution": constitution,
            "dexterity": dexterity,
            "intelligence": intelligence,
            "wisdom": wisdom,
            "discipline": discipline
        },
        "tags": tags,
        "age_weeks": age_weeks,
        "lifespan": lifespan,
        "is_active": is_active,
        "stamina_current": stamina_current,
        "stamina_max": stamina_max,
        "egg_group": egg_group,
        "parent_ids": parent_ids,
        "generation": generation
    }

static func from_dict(data: Dictionary) -> Creature:
    var creature := Creature.new()
    creature.id = data.get("id", "")
    creature.creature_name = data.get("creature_name", "")  # Updated property name
    creature.species_id = data.get("species_id", "")  # Updated property name

    var stats := data.get("stats", {}) as Dictionary
    creature.strength = stats.get("strength", 50)
    creature.constitution = stats.get("constitution", 50)
    creature.dexterity = stats.get("dexterity", 50)
    creature.intelligence = stats.get("intelligence", 50)
    creature.wisdom = stats.get("wisdom", 50)
    creature.discipline = stats.get("discipline", 50)

    creature.tags = Array(data.get("tags", []), TYPE_STRING, "", null)
    creature.age_weeks = data.get("age_weeks", 0)
    creature.lifespan = data.get("lifespan", 520)
    creature.is_active = data.get("is_active", false)
    creature.stamina_current = data.get("stamina_current", 100)
    creature.stamina_max = data.get("stamina_max", 100)
    creature.egg_group = data.get("egg_group", "")
    creature.parent_ids = Array(data.get("parent_ids", []), TYPE_STRING, "", null)
    creature.generation = data.get("generation", 1)

    return creature
```

## Success Metrics
- Creature instances use < 1KB memory each
- Creation of 1000 creatures takes < 100ms
- Serialization/deserialization maintains data integrity
- All stat modifications respect boundaries
- Age calculations are accurate

## Notes
- Keep the class focused on data representation
- Business logic will be in manager classes
- Ensure thread safety for future multiplayer consideration
- Document all methods for future reference

## Estimated Time
3-4 hours for implementation and testing