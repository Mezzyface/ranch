# Task 02: CreatureData and CreatureEntity Implementation

## Overview
Create the separated CreatureData (Resource for pure data) and CreatureEntity (Node for behavior) classes following the improved architecture pattern. This separation ensures proper save/load functionality and clean architecture.

## Dependencies
- Task 01: Project Setup with GameCore (must be complete)
- SignalBus must be available via GameCore
- Access to design documents: `creature.md`, `stats.md`, `tags.md`

## Context
**CRITICAL ARCHITECTURE CHANGE**:
- CreatureData (Resource) - Pure data storage, NO signals, serializable
- CreatureEntity (Node) - Behavior and signals, references CreatureData
- All signals go through SignalBus, not the Resource

## Requirements

### Two-Class Architecture

#### 1. CreatureData (Resource) - Pure Data Storage
Location: `scripts/data/creature_data.gd`
- **NO SIGNALS** - Resources with signals break on save/load
- All creature properties as exported vars
- Serialization via to_dict()/from_dict()
- Pure data, no behavior logic

Properties to include:
- Identity (id, name, species_id)
- Stats (STR, CON, DEX, INT, WIS, DIS)
- Tags array
- Age data (weeks, lifespan)
- State data (active, stamina)
- Breeding data (egg_group, parents, generation)

#### 2. CreatureEntity (Node) - Behavior & Signals
Location: `scripts/entities/creature_entity.gd`
- References a CreatureData resource
- Handles all behavior and state changes
- Emits signals via SignalBus
- Manages stat modifications, aging, etc.

Methods to include:
- modify_stat(stat_name, value)
- add_tag(tag)
- age_one_week()
- consume_stamina(amount)
- All methods that change state

## Implementation Steps

1. **Create CreatureData Resource**
   - Location: `scripts/data/creature_data.gd`
   - Extends: Resource
   - Add all data properties (NO signals!)
   - Implement to_dict()/from_dict() for serialization

2. **Create CreatureEntity Node**
   - Location: `scripts/entities/creature_entity.gd`
   - Extends: Node
   - Add reference to CreatureData
   - Implement all behavior methods

3. **Connect to SignalBus**
   - Get SignalBus via GameCore
   - Emit signals for all state changes
   - Never emit signals from CreatureData

4. **Implement Stat Management**
   - In CreatureEntity, not CreatureData
   - Validate 0-1000 range
   - Emit signals via SignalBus

5. **Test Separation**
   - Verify CreatureData has NO signals
   - Verify save/load preserves all data
   - Verify CreatureEntity properly manages behavior

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

## Code Templates

### CreatureData - Pure Data Resource (NO SIGNALS!)
```gdscript
# scripts/data/creature_data.gd
class_name CreatureData
extends Resource

# Identity
@export var id: String = ""
@export var creature_name: String = ""
@export var species_id: String = ""

# Core Stats (0-1000) - Simple validation, NO signals!
@export_range(0, 1000) var strength: int = 50:
    set(value):
        strength = clampi(value, 0, 1000)

@export_range(0, 1000) var constitution: int = 50:
    set(value):
        constitution = clampi(value, 0, 1000)

@export_range(0, 1000) var dexterity: int = 50:
    set(value):
        dexterity = clampi(value, 0, 1000)

@export_range(0, 1000) var intelligence: int = 50:
    set(value):
        intelligence = clampi(value, 0, 1000)

@export_range(0, 1000) var wisdom: int = 50:
    set(value):
        wisdom = clampi(value, 0, 1000)

@export_range(0, 1000) var discipline: int = 50:
    set(value):
        discipline = clampi(value, 0, 1000)

# Tags
@export var tags: Array[String] = []

# Age System
@export_range(0, 1000) var age_weeks: int = 0
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

# Constructor
func _init() -> void:
    if id.is_empty():
        id = "creature_%d_%06d" % [Time.get_unix_time_from_system(), randi() % 999999]

# Utility functions (pure calculations, no state changes)
func get_age_category() -> int:
    var life_percentage := (age_weeks / float(lifespan)) * 100
    if life_percentage < 10:
        return 0  # BABY
    elif life_percentage < 25:
        return 1  # JUVENILE
    elif life_percentage < 75:
        return 2  # ADULT
    elif life_percentage < 90:
        return 3  # ELDER
    else:
        return 4  # ANCIENT

func get_age_modifier() -> float:
    match get_age_category():
        0: return 0.6  # BABY
        1: return 0.8  # JUVENILE
        2: return 1.0  # ADULT
        3: return 0.8  # ELDER
        4: return 0.6  # ANCIENT
        _: return 1.0

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

# Simple tag queries (no state changes)
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

### CreatureEntity - Behavior Controller (Handles Signals)
```gdscript
# scripts/entities/creature_entity.gd
class_name CreatureEntity
extends Node

var data: CreatureData
var signal_bus: SignalBus

func _init(creature_data: CreatureData = null) -> void:
    if creature_data:
        data = creature_data
    else:
        data = CreatureData.new()

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()

# Stat modification with signals
func modify_stat(stat_name: String, value: int) -> void:
    var old_value := data.get_stat(stat_name)
    data.set_stat(stat_name, value)
    var new_value := data.get_stat(stat_name)

    if old_value != new_value and signal_bus:
        signal_bus.creature_stats_changed.emit(data, stat_name, old_value, new_value)

func increase_stat(stat_name: String, amount: int) -> void:
    var current := data.get_stat(stat_name)
    modify_stat(stat_name, current + amount)

# Tag management with signals
func add_tag(tag: String) -> bool:
    if not data.has_tag(tag) and _is_valid_tag(tag):
        data.tags.append(tag)
        if signal_bus:
            signal_bus.creature_tag_added.emit(data, tag)
        return true
    return false

func remove_tag(tag: String) -> bool:
    if data.tags.erase(tag):
        if signal_bus:
            signal_bus.creature_tag_removed.emit(data, tag)
        return true
    return false

# Age management with signals
func age_one_week() -> void:
    var old_age := data.age_weeks
    data.age_weeks += 1

    # Apply aging effects
    if data.is_active:
        data.stamina_current = maxi(0, data.stamina_current - 10)

    if signal_bus:
        signal_bus.creature_aged.emit(data, data.age_weeks)

# Stamina management
func consume_stamina(amount: int) -> bool:
    if data.stamina_current >= amount:
        data.stamina_current -= amount
        if signal_bus:
            signal_bus.creature_stamina_changed.emit(data, data.stamina_current)
        return true
    return false

func restore_stamina(amount: int) -> void:
    var old_stamina := data.stamina_current
    data.stamina_current = mini(data.stamina_current + amount, data.stamina_max)

    if old_stamina != data.stamina_current and signal_bus:
        signal_bus.creature_stamina_changed.emit(data, data.stamina_current)

func rest_fully() -> void:
    data.stamina_current = data.stamina_max
    if signal_bus:
        signal_bus.creature_stamina_changed.emit(data, data.stamina_current)

# State management
func set_active(active: bool) -> void:
    if data.is_active != active:
        data.is_active = active
        if signal_bus:
            if active:
                signal_bus.creature_activated.emit(data)
            else:
                signal_bus.creature_deactivated.emit(data)

# Validation
func _is_valid_tag(tag: String) -> bool:
    const VALID_TAGS = [
        "Small", "Medium", "Large",
        "Territorial", "Social", "Solitary",
        "Winged", "Aquatic", "Terrestrial",
        "Nocturnal", "Diurnal", "Crepuscular"
    ]
    return tag in VALID_TAGS

# Quest requirement matching
func matches_requirements(req_stats: Dictionary, req_tags: Array[String]) -> bool:
    # Check stats
    for stat_name in req_stats:
        if data.get_stat(stat_name) < req_stats[stat_name]:
            return false

    # Check tags
    return data.has_all_tags(req_tags)

# Performance calculations
func get_performance_score() -> float:
    var base_score := 0.0
    base_score += data.strength * 0.15
    base_score += data.constitution * 0.15
    base_score += data.dexterity * 0.15
    base_score += data.intelligence * 0.15
    base_score += data.wisdom * 0.15
    base_score += data.discipline * 0.25

    # Apply age modifier
    return base_score * data.get_age_modifier()
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