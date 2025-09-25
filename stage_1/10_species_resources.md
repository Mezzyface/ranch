# Task 10: Species Resource Implementation

## Overview
Create the Species resource system that defines all creature species with their characteristics, stat ranges, visual assets, and generation rules. This provides a centralized, data-driven approach to species management.

## Dependencies
- Task 02: Creature Class (complete)
- Task 03: Stat System (complete)
- Task 04: Tag System (complete)
- Task 05: Creature Generation (complete)
- Design document: `species.md`

## Context
From `species.md` and design documents:
- Each species needs comprehensive data (stats, tags, visuals, breeding info)
- Species data should be easily editable without code changes
- Resources allow visual editing in Godot's inspector
- Centralized species management improves maintainability

## Requirements

### SpeciesResource Class
Create a comprehensive resource class with:

1. **Identity Information**
   - Species ID (unique identifier)
   - Display name and description
   - Lore and flavor text

2. **Visual Assets**
   - Sprite frames for animations
   - Icon for UI/menus
   - Egg sprite
   - Color variants

3. **Stat Configuration**
   - Stat ranges for generation
   - Base stats for reference
   - Training affinities

4. **Tag System**
   - Guaranteed tags
   - Possible tags with weights
   - Tag inheritance rules

5. **Breeding Data**
   - Egg groups
   - Gender ratio
   - Breeding compatibility
   - Maturity age

6. **Life Cycle**
   - Lifespan and variance
   - Growth rate
   - Age categories

7. **Economic Data**
   - Base price
   - Rarity tier
   - Unlock requirements

### Species Manager
Singleton to manage all species:
- Load species resources
- Query species by various criteria
- Generate creatures from species
- Handle unlocks and availability

## Implementation Steps

1. **Create SpeciesResource Script**
   - Define all exported properties
   - Implement generation methods
   - Add validation logic
   - Include helper methods

2. **Create Initial Species Resources**
   - Scuttleguard.tres
   - Stone Sentinel.tres
   - Wind Dancer.tres
   - Glow Grub.tres

3. **Implement Species Manager**
   - Resource loading system
   - Database management
   - Query methods
   - Generation functions

4. **Update Creature Generation**
   - Use SpeciesResource for generation
   - Remove hardcoded species data
   - Integrate with existing systems

## Test Criteria

### Unit Tests
- [ ] Species resources load correctly
- [ ] Creature generation uses species data
- [ ] Stat ranges are respected
- [ ] Tags are properly assigned
- [ ] Species manager queries work

### Resource Validation
- [ ] All required fields populated
- [ ] Stat ranges are valid (min < max)
- [ ] Tag arrays are properly formatted
- [ ] Visual assets load correctly
- [ ] Price and rarity are set

### Integration Tests
- [ ] Generated creatures match species specs
- [ ] Shop system uses species prices
- [ ] Breeding checks egg groups
- [ ] Quest system recognizes species tags
- [ ] Save/load preserves species references

## Code Implementation

### SpeciesResource (`scripts/resources/species_resource.gd`)
```gdscript
class_name SpeciesResource
extends Resource

# Identity
@export var species_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_multiline var lore: String = ""

# Visual Assets (can be null in Stage 1)
@export var sprite_frames: SpriteFrames
@export var icon: Texture2D
@export var egg_sprite: Texture2D
@export var color_variants: Array[Color] = []

# Stat Ranges
@export_group("Stat Ranges")
@export var strength_range: Vector2i = Vector2i(50, 150)
@export var constitution_range: Vector2i = Vector2i(50, 150)
@export var dexterity_range: Vector2i = Vector2i(50, 150)
@export var intelligence_range: Vector2i = Vector2i(50, 150)
@export var wisdom_range: Vector2i = Vector2i(50, 150)
@export var discipline_range: Vector2i = Vector2i(50, 150)

# Tags
@export_group("Tags")
# NOTE: Using Array[String] for Stage 1
# TODO: Convert to Array[Enums.CreatureTag] when enum system is implemented
@export var guaranteed_tags: Array[String] = []
@export var possible_tags: Array[String] = []
@export var tag_weights: Array[float] = []

# Breeding
@export_group("Breeding")
# NOTE: Using Array[String] for Stage 1
# TODO: Convert to Array[Enums.EggGroup] when implemented
@export var egg_groups: Array[String] = []
@export var gender_ratio: float = 0.5
@export var is_breedable: bool = true

# Life Cycle
@export_group("Life Cycle")
@export var lifespan_weeks: int = 520
@export var lifespan_variance: float = 0.1
@export var maturity_weeks: int = 52
@export var growth_rate: float = 1.0

# Economy
@export_group("Economy")
@export var base_price: int = 200
@export var rarity: String = "Common"  # TODO: Use Enums.Rarity
@export var unlock_requirement: String = ""

# Generate a new creature from this species
func generate_creature() -> Creature:
    var creature = Creature.new()
    creature.species = species_id
    creature.name = generate_name()

    # Generate stats within ranges
    creature.strength = randi_range(strength_range.x, strength_range.y)
    creature.constitution = randi_range(constitution_range.x, constitution_range.y)
    creature.dexterity = randi_range(dexterity_range.x, dexterity_range.y)
    creature.intelligence = randi_range(intelligence_range.x, intelligence_range.y)
    creature.wisdom = randi_range(wisdom_range.x, wisdom_range.y)
    creature.discipline = randi_range(discipline_range.x, discipline_range.y)

    # Assign guaranteed tags
    for tag in guaranteed_tags:
        creature.add_tag(tag)

    # Randomly assign possible tags
    for i in range(possible_tags.size()):
        if i < tag_weights.size() and randf() < tag_weights[i]:
            creature.add_tag(possible_tags[i])

    # Set lifespan with variance
    var variance = randf_range(-lifespan_variance, lifespan_variance)
    creature.lifespan = int(lifespan_weeks * (1.0 + variance))

    # Set egg group (use first one for now)
    if egg_groups.size() > 0:
        creature.egg_group = egg_groups[0]

    return creature

func generate_name() -> String:
    # Simple name generation - can be enhanced later
    var prefixes = ["Swift", "Brave", "Wise", "Strong", "Clever"]
    var prefix = prefixes[randi() % prefixes.size()]
    return prefix + " " + display_name

func get_stat_range(stat_name: String) -> Vector2i:
    match stat_name.to_lower():
        "strength", "str": return strength_range
        "constitution", "con": return constitution_range
        "dexterity", "dex": return dexterity_range
        "intelligence", "int": return intelligence_range
        "wisdom", "wis": return wisdom_range
        "discipline", "dis": return discipline_range
        _: return Vector2i(50, 150)

func meets_unlock_requirement() -> bool:
    if unlock_requirement.is_empty():
        return true
    # TODO: Check quest completion or other requirements
    return true  # For Stage 1, all unlocked
```

### Species Manager (`scripts/systems/species_manager.gd`)
```gdscript
extends Node

var species_database: Dictionary = {}
var species_load_path = "res://resources/species/"

func _ready():
    load_all_species()

func load_all_species():
    # For Stage 1, manually load known species
    # TODO: Implement directory scanning in Stage 2
    var species_files = [
        "scuttleguard.tres",
        "stone_sentinel.tres",
        "wind_dancer.tres",
        "glow_grub.tres"
    ]

    for file in species_files:
        var path = species_load_path + file
        if ResourceLoader.exists(path):
            var species = load(path) as SpeciesResource
            if species:
                species_database[species.species_id] = species
                print("Loaded species: ", species.display_name)
            else:
                push_warning("Failed to load species: " + path)

func get_species(species_id: String) -> SpeciesResource:
    if species_database.has(species_id):
        return species_database[species_id]
    push_warning("Species not found: " + species_id)
    return null

func get_all_species() -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        result.append(species)
    return result

func get_unlocked_species() -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.meets_unlock_requirement():
            result.append(species)
    return result

func generate_creature_from_species(species_id: String) -> Creature:
    var species = get_species(species_id)
    if species:
        return species.generate_creature()
    push_error("Cannot generate creature - species not found: " + species_id)
    return null

func get_species_by_tag(tag: String) -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if tag in species.guaranteed_tags:
            result.append(species)
    return result

func get_species_by_egg_group(egg_group: String) -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if egg_group in species.egg_groups:
            result.append(species)
    return result

func get_species_by_rarity(rarity: String) -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.rarity == rarity:
            result.append(species)
    return result

func get_starter_species() -> Array[SpeciesResource]:
    # Return common, low-cost species suitable for starting
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.rarity == "Common" and species.base_price <= 300:
            result.append(species)
    return result
```

## Example Species Resource Files

Create these in the Godot editor as .tres files:

### Scuttleguard (`res://resources/species/scuttleguard.tres`)
- species_id: "scuttleguard"
- display_name: "Scuttleguard"
- strength_range: (70, 130)
- constitution_range: (80, 140)
- dexterity_range: (90, 150)
- intelligence_range: (40, 70)
- wisdom_range: (110, 170)
- discipline_range: (90, 150)
- guaranteed_tags: ["Small", "Territorial", "Dark Vision"]
- egg_groups: ["Field", "Bug"]
- base_price: 200
- rarity: "Common"

## Success Metrics
- Species resources load in < 100ms
- Creature generation uses species data correctly
- All species have complete data
- System handles missing species gracefully
- Easy to add new species without code changes

## Notes
- Start with 4-5 core species for Stage 1
- Visual assets can be added later
- Use Godot's resource inspector for easy editing
- Consider version control for resource files
- Plan for modding support in future

## Estimated Time
4-5 hours for implementation and testing