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

# Identity
@export var id: String = ""
@export var name: String = ""
# NOTE: species is a string ID that references a SpeciesResource
# The SpeciesResource contains all species-specific data (stats, sprites, etc.)
@export var species: String = ""  # References species_id in SpeciesResource

# Core Stats (0-1000)
@export var strength: int = 50:
    set(value):
        strength = clampi(value, 0, 1000)
@export var constitution: int = 50:
    set(value):
        constitution = clampi(value, 0, 1000)
@export var dexterity: int = 50:
    set(value):
        dexterity = clampi(value, 0, 1000)
@export var intelligence: int = 50:
    set(value):
        intelligence = clampi(value, 0, 1000)
@export var wisdom: int = 50:
    set(value):
        wisdom = clampi(value, 0, 1000)
@export var discipline: int = 50:
    set(value):
        discipline = clampi(value, 0, 1000)

# Tags
# NOTE: Using Array[String] for Stage 1 implementation
# TODO: Convert to Array[Enums.CreatureTag] when tag system is fully implemented
@export var tags: Array[String] = []

# Age System
@export var age_weeks: int = 0
@export var lifespan: int = 520  # 10 years default

# State
@export var is_active: bool = false
@export var stamina_current: int = 100
@export var stamina_max: int = 100

# Breeding
# NOTE: Using String for Stage 1 implementation
# TODO: Convert to Enums.EggGroup when breeding system is implemented
@export var egg_group: String = ""
@export var parent_ids: Array[String] = []
@export var generation: int = 1

# Constructor
func _init():
    if id.is_empty():
        id = generate_unique_id()

# Use global enum from Enums.gd
func get_age_category() -> Enums.AgeCategory:
    var life_percentage = (age_weeks / float(lifespan)) * 100
    if life_percentage < 25:  # Updated to match enum.md specification
        return Enums.AgeCategory.YOUNG
    elif life_percentage < 75:  # Updated to match enum.md specification
        return Enums.AgeCategory.ADULT
    else:
        return Enums.AgeCategory.ELDER

func get_age_modifier() -> float:
    match get_age_category():
        Enums.AgeCategory.YOUNG:
            return 1.2  # +20% performance (updated to match design)
        Enums.AgeCategory.ADULT:
            return 1.0  # No modifier
        Enums.AgeCategory.ELDER:
            return 0.8  # -20% performance (updated to match design)
        _:
            return 1.0

# Stat Accessors
func get_stat(stat_name: String) -> int:
    match stat_name.to_upper():
        "STR": return strength
        "CON": return constitution
        "DEX": return dexterity
        "INT": return intelligence
        "WIS": return wisdom
        "DIS": return discipline
        _: return 0

func set_stat(stat_name: String, value: int):
    match stat_name.to_upper():
        "STR": strength = value
        "CON": constitution = value
        "DEX": dexterity = value
        "INT": intelligence = value
        "WIS": wisdom = value
        "DIS": discipline = value

# Tag Management
func add_tag(tag: String) -> bool:
    if not tag in tags and is_valid_tag(tag):
        tags.append(tag)
        return true
    return false

func remove_tag(tag: String) -> bool:
    return tags.erase(tag)

func has_tag(tag: String) -> bool:
    return tag in tags

func has_all_tags(required_tags: Array[String]) -> bool:
    for tag in required_tags:
        if not has_tag(tag):
            return false
    return true

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

# Age Progression
func age_one_week():
    age_weeks += 1
    # Additional aging effects in future

# Stamina Management
func consume_stamina(amount: int) -> bool:
    if stamina_current >= amount:
        stamina_current -= amount
        return true
    return false

func restore_stamina(amount: int):
    stamina_current = mini(stamina_current + amount, stamina_max)

# Utility
func generate_unique_id() -> String:
    # Simple UUID generation
    randomize()
    return "creature_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

# Serialization
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "species": species,
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
    var creature = Creature.new()
    creature.id = data.get("id", "")
    creature.name = data.get("name", "")
    creature.species = data.get("species", "")

    var stats = data.get("stats", {})
    creature.strength = stats.get("strength", 50)
    creature.constitution = stats.get("constitution", 50)
    creature.dexterity = stats.get("dexterity", 50)
    creature.intelligence = stats.get("intelligence", 50)
    creature.wisdom = stats.get("wisdom", 50)
    creature.discipline = stats.get("discipline", 50)

    creature.tags = data.get("tags", [])
    creature.age_weeks = data.get("age_weeks", 0)
    creature.lifespan = data.get("lifespan", 520)
    creature.is_active = data.get("is_active", false)
    creature.stamina_current = data.get("stamina_current", 100)
    creature.stamina_max = data.get("stamina_max", 100)
    creature.egg_group = data.get("egg_group", "")
    creature.parent_ids = data.get("parent_ids", [])
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