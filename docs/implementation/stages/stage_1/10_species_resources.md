# Task 10: Species Resource System

## Overview
Implement the species resource system as a GameCore subsystem with caching that defines all creature species with their characteristics, stat ranges, visual assets, and generation rules. This provides a centralized, data-driven approach to species management.

## Dependencies
- Task 01: GameCore Setup (complete)
- Task 02: CreatureData/CreatureEntity separation (complete)
- Task 03: Stat System (complete)
- Task 04: Tag System (complete)
- Task 05: Creature Generation (complete)
- Design document: `species.md`

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- SpeciesSystem as GameCore subsystem (NOT autoload)
- All signals go through SignalBus
- Resource caching for performance
- Lazy-loaded by GameCore when needed
- Integrates with CreatureGenerator for species-based generation

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

### Species System
GameCore subsystem to manage all species:
- Load species resources with caching
- Query species by various criteria
- Generate creatures from species
- Handle unlocks and availability

## Implementation Steps

1. **Create SpeciesSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for all signals
   - Lazy-loaded subsystem with caching

2. **Create SpeciesResource Script**
   - Define all exported properties
   - Implement generation methods
   - Add validation logic
   - Include helper methods

3. **Implement Caching System**
   - Resource loading optimization
   - Query result caching
   - Memory management

4. **Update Creature Generation**
   - Use SpeciesSystem for generation
   - Remove hardcoded species data
   - Integrate with existing systems

## Test Criteria

### Unit Tests
- [ ] Species resources load correctly
- [ ] Creature generation uses species data
- [ ] Stat ranges are respected
- [ ] Tags are properly assigned
- [ ] Species system queries work

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
- [ ] Caching improves performance

## Code Implementation

### SpeciesResource - Data Definition
```gdscript
# scripts/resources/species_resource.gd
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

# Training affinities (multipliers for training effectiveness)
@export_group("Training")
@export var training_affinities: Dictionary = {
    "strength": 1.0,
    "constitution": 1.0,
    "dexterity": 1.0,
    "intelligence": 1.0,
    "wisdom": 1.0,
    "discipline": 1.0
}

# Tags
@export_group("Tags")
# NOTE: Using Array[String] for Stage 1
# TODO: Convert to Array[GlobalEnums.CreatureTag] when Task 11 is complete
@export var guaranteed_tags: Array[String] = []
@export var possible_tags: Array[String] = []
@export var tag_weights: Array[float] = []

# Breeding
@export_group("Breeding")
# NOTE: Using Array[String] for Stage 1
# TODO: Convert to Array[GlobalEnums.EggGroup] when Task 11 is complete
@export var egg_groups: Array[String] = []
@export var gender_ratio: float = 0.5
@export var is_breedable: bool = true
@export var maturity_weeks: int = 52

# Life Cycle
@export_group("Life Cycle")
@export var lifespan_weeks: int = 520
@export var lifespan_variance: float = 0.1
@export var growth_rate: float = 1.0

# Economy
@export_group("Economy")
@export var base_price: int = 200
@export var rarity: String = "Common"  # TODO: Use GlobalEnums.Rarity after Task 11
@export var unlock_requirement: String = ""

# Generation helper methods
func get_stat_range(stat_name: String) -> Vector2i:
    match stat_name.to_lower():
        "strength", "str": return strength_range
        "constitution", "con": return constitution_range
        "dexterity", "dex": return dexterity_range
        "intelligence", "int": return intelligence_range
        "wisdom", "wis": return wisdom_range
        "discipline", "dis": return discipline_range
        _: return Vector2i(50, 150)

func get_training_affinity(stat_name: String) -> float:
    return training_affinities.get(stat_name.to_lower(), 1.0)

func meets_unlock_requirement() -> bool:
    if unlock_requirement.is_empty():
        return true
    # TODO: Check quest completion or other requirements
    return true  # For Stage 1, all unlocked

func generate_lifespan() -> int:
    var variance = randf_range(-lifespan_variance, lifespan_variance)
    return int(lifespan_weeks * (1.0 + variance))

func get_possible_tag_at_index(index: int) -> String:
    if index >= 0 and index < possible_tags.size():
        return possible_tags[index]
    return ""

func get_tag_weight_at_index(index: int) -> float:
    if index >= 0 and index < tag_weights.size():
        return tag_weights[index]
    return 0.0

# Validation
func validate() -> Dictionary:
    var result = {
        "valid": true,
        "errors": [],
        "warnings": []
    }

    # Check required fields
    if species_id.is_empty():
        result.valid = false
        result.errors.append("Species ID is required")

    if display_name.is_empty():
        result.valid = false
        result.errors.append("Display name is required")

    # Validate stat ranges
    var stats = ["strength", "constitution", "dexterity", "intelligence", "wisdom", "discipline"]
    for stat in stats:
        var range = get_stat_range(stat)
        if range.x >= range.y:
            result.valid = false
            result.errors.append("%s range invalid: min (%d) must be less than max (%d)" % [stat, range.x, range.y])

    # Check tag weights match possible tags
    if tag_weights.size() != possible_tags.size():
        result.warnings.append("Tag weights count (%d) doesn't match possible tags count (%d)" % [tag_weights.size(), possible_tags.size()])

    # Validate economic values
    if base_price < 0:
        result.valid = false
        result.errors.append("Base price cannot be negative")

    if lifespan_weeks <= 0:
        result.valid = false
        result.errors.append("Lifespan must be positive")

    return result
```

### SpeciesSystem - GameCore Subsystem with Caching
```gdscript
# scripts/systems/species_system.gd
class_name SpeciesSystem
extends Node

var signal_bus: SignalBus

# Species storage with caching
var species_database: Dictionary = {}  # species_id -> SpeciesResource
var species_cache: Dictionary = {}     # Various cached queries

# Resource paths
var species_load_path: String = "res://resources/species/"

# Preloaded species for Stage 1
const PRELOADED_SPECIES = [
    "scuttleguard",
    "stone_sentinel",
    "wind_dancer",
    "glow_grub"
]

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    load_all_species()
    print("SpeciesSystem initialized with %d species" % species_database.size())

# Resource Loading with Caching
func load_all_species() -> void:
    # Clear existing data
    species_database.clear()
    species_cache.clear()

    # For Stage 1, load preloaded species
    for species_id in PRELOADED_SPECIES:
        load_species(species_id)

    # Emit signal for systems that depend on species data
    if signal_bus:
        signal_bus.species_database_loaded.emit()

func load_species(species_id: String) -> bool:
    var path = species_load_path + species_id + ".tres"

    if not ResourceLoader.exists(path):
        push_warning("Species file not found: " + path)
        return false

    var species = load(path) as SpeciesResource
    if not species:
        push_error("Failed to load species: " + path)
        return false

    # Validate species data
    var validation = species.validate()
    if not validation.valid:
        push_error("Invalid species data for %s: %s" % [species_id, validation.errors])
        return false

    if validation.warnings.size() > 0:
        push_warning("Species %s has warnings: %s" % [species_id, validation.warnings])

    species_database[species_id] = species

    if signal_bus:
        signal_bus.species_loaded.emit(species)

    return true

func reload_species(species_id: String) -> bool:
    if species_database.has(species_id):
        # Clear related caches
        _clear_species_cache(species_id)
        return load_species(species_id)
    return false

# Core Access Methods
func get_species(species_id: String) -> SpeciesResource:
    return species_database.get(species_id, null)

func has_species(species_id: String) -> bool:
    return species_database.has(species_id)

func get_all_species() -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        result.append(species)
    return result

func get_all_species_ids() -> Array[String]:
    var result: Array[String] = []
    for species_id in species_database.keys():
        result.append(species_id)
    return result

# Filtered Queries with Caching
func get_unlocked_species() -> Array[SpeciesResource]:
    var cache_key = "unlocked_species"

    if species_cache.has(cache_key):
        return species_cache[cache_key]

    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.meets_unlock_requirement():
            result.append(species)

    species_cache[cache_key] = result
    return result

func get_species_by_rarity(rarity: String) -> Array[SpeciesResource]:
    var cache_key = "rarity_" + rarity

    if species_cache.has(cache_key):
        return species_cache[cache_key]

    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.rarity == rarity:
            result.append(species)

    species_cache[cache_key] = result
    return result

func get_species_by_egg_group(egg_group: String) -> Array[SpeciesResource]:
    var cache_key = "egg_group_" + egg_group

    if species_cache.has(cache_key):
        return species_cache[cache_key]

    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if egg_group in species.egg_groups:
            result.append(species)

    species_cache[cache_key] = result
    return result

func get_species_with_tag(tag: String) -> Array[SpeciesResource]:
    var cache_key = "tag_" + tag

    if species_cache.has(cache_key):
        return species_cache[cache_key]

    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if tag in species.guaranteed_tags or tag in species.possible_tags:
            result.append(species)

    species_cache[cache_key] = result
    return result

func get_affordable_species(gold_amount: int) -> Array[SpeciesResource]:
    var cache_key = "affordable_%d" % gold_amount

    # Don't cache this as it changes frequently
    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        if species.base_price <= gold_amount and species.meets_unlock_requirement():
            result.append(species)

    return result

func get_starter_species() -> Array[SpeciesResource]:
    var cache_key = "starter_species"

    if species_cache.has(cache_key):
        return species_cache[cache_key]

    var result: Array[SpeciesResource] = []
    for species in species_database.values():
        # Starters are common, affordable, and unlocked
        if species.rarity == "Common" and species.base_price <= 300 and species.meets_unlock_requirement():
            result.append(species)

    species_cache[cache_key] = result
    return result

# Generation Integration
func generate_creature_data_from_species(species_id: String, age_weeks: int = 0) -> CreatureData:
    var species = get_species(species_id)
    if not species:
        push_error("Cannot generate creature - species not found: " + species_id)
        return null

    var creature_data = CreatureData.new()

    # Set basic properties
    creature_data.species_id = species_id
    creature_data.creature_name = _generate_species_name(species)
    creature_data.lifespan = species.generate_lifespan()
    creature_data.age_weeks = age_weeks

    # Generate stats within species ranges
    creature_data.strength = randi_range(species.strength_range.x, species.strength_range.y)
    creature_data.constitution = randi_range(species.constitution_range.x, species.constitution_range.y)
    creature_data.dexterity = randi_range(species.dexterity_range.x, species.dexterity_range.y)
    creature_data.intelligence = randi_range(species.intelligence_range.x, species.intelligence_range.y)
    creature_data.wisdom = randi_range(species.wisdom_range.x, species.wisdom_range.y)
    creature_data.discipline = randi_range(species.discipline_range.x, species.discipline_range.y)

    # Assign guaranteed tags
    for tag in species.guaranteed_tags:
        creature_data.tags.append(tag)

    # Apply possible tags based on weights
    for i in species.possible_tags.size():
        var tag = species.possible_tags[i]
        var weight = species.get_tag_weight_at_index(i)

        if randf() < weight:
            # Validate through TagSystem if available
            var tag_system = GameCore.get_system("tag") as TagSystem
            if tag_system:
                var can_add = tag_system.can_add_tag_to_creature(creature_data, tag)
                if can_add.can_add:
                    creature_data.tags.append(tag)
            else:
                creature_data.tags.append(tag)

    # Set egg group (use first one for now)
    if species.egg_groups.size() > 0:
        creature_data.egg_group = species.egg_groups[0]

    # Set stamina based on constitution
    creature_data.stamina_max = 50 + (creature_data.constitution / 10)
    creature_data.stamina_current = creature_data.stamina_max

    if signal_bus:
        signal_bus.creature_generated_from_species.emit(creature_data, species)

    return creature_data

# Species Analysis
func get_species_stats() -> Dictionary:
    var stats = {
        "total_species": species_database.size(),
        "unlocked_species": get_unlocked_species().size(),
        "rarity_distribution": {},
        "price_range": {"min": 999999, "max": 0, "average": 0},
        "egg_groups": {}
    }

    var total_price = 0

    for species in species_database.values():
        # Rarity distribution
        var rarity = species.rarity
        if not stats.rarity_distribution.has(rarity):
            stats.rarity_distribution[rarity] = 0
        stats.rarity_distribution[rarity] += 1

        # Price analysis
        stats.price_range.min = mini(stats.price_range.min, species.base_price)
        stats.price_range.max = maxi(stats.price_range.max, species.base_price)
        total_price += species.base_price

        # Egg groups
        for egg_group in species.egg_groups:
            if not stats.egg_groups.has(egg_group):
                stats.egg_groups[egg_group] = 0
            stats.egg_groups[egg_group] += 1

    if species_database.size() > 0:
        stats.price_range.average = total_price / species_database.size()

    return stats

# Breeding compatibility
func are_species_compatible(species1_id: String, species2_id: String) -> bool:
    var species1 = get_species(species1_id)
    var species2 = get_species(species2_id)

    if not species1 or not species2:
        return false

    if not species1.is_breedable or not species2.is_breedable:
        return false

    # Check for shared egg groups
    for egg_group in species1.egg_groups:
        if egg_group in species2.egg_groups:
            return true

    return false

func get_compatible_species(species_id: String) -> Array[SpeciesResource]:
    var result: Array[SpeciesResource] = []
    var species = get_species(species_id)

    if not species or not species.is_breedable:
        return result

    for other_species in species_database.values():
        if other_species.species_id != species_id and are_species_compatible(species_id, other_species.species_id):
            result.append(other_species)

    return result

# Shop Integration
func get_species_price(species_id: String) -> int:
    var species = get_species(species_id)
    return species.base_price if species else 0

func can_purchase_species(species_id: String, available_gold: int) -> Dictionary:
    var species = get_species(species_id)

    if not species:
        return {"can_purchase": false, "reason": "Species not found"}

    if not species.meets_unlock_requirement():
        return {"can_purchase": false, "reason": "Species locked"}

    if species.base_price > available_gold:
        return {"can_purchase": false, "reason": "Insufficient gold", "required": species.base_price}

    return {"can_purchase": true, "cost": species.base_price}

# Cache Management
func _clear_species_cache(species_id: String = "") -> void:
    if species_id.is_empty():
        # Clear all cache
        species_cache.clear()
    else:
        # Clear cache entries related to specific species
        var keys_to_remove: Array[String] = []
        for key in species_cache.keys():
            if key.contains(species_id):
                keys_to_remove.append(key)

        for key in keys_to_remove:
            species_cache.erase(key)

func clear_cache() -> void:
    _clear_species_cache()

func get_cache_stats() -> Dictionary:
    return {
        "cache_size": species_cache.size(),
        "cached_queries": species_cache.keys()
    }

# Helper Methods
func _generate_species_name(species: SpeciesResource) -> String:
    # Simple name generation based on species
    var prefixes = []
    var suffixes = []

    match species.species_id:
        "scuttleguard":
            prefixes = ["Brave", "Swift", "Alert", "Keen", "Bold"]
            suffixes = ["guard", "watcher", "scout", "sentinel"]
        "stone_sentinel":
            prefixes = ["Rocky", "Granite", "Stone", "Marble", "Solid"]
            suffixes = ["guard", "keeper", "wall", "shield"]
        "wind_dancer":
            prefixes = ["Swift", "Airy", "Light", "Fleet", "Nimble"]
            suffixes = ["wing", "breeze", "gust", "zephyr"]
        "glow_grub":
            prefixes = ["Bright", "Shiny", "Glowing", "Radiant", "Luminous"]
            suffixes = ["bug", "glow", "spark", "beam"]
        _:
            prefixes = ["Noble", "Brave", "Swift", "Wise", "Strong"]
            suffixes = [species.display_name.to_lower()]

    var prefix = prefixes[randi() % prefixes.size()]
    var suffix = suffixes[randi() % suffixes.size()]

    return prefix + " " + suffix.capitalize()

# Debug and Development
func debug_species_info(species_id: String) -> String:
    var species = get_species(species_id)
    if not species:
        return "Species not found: " + species_id

    var info = "Species: %s\n" % species.display_name
    info += "ID: %s\n" % species.species_id
    info += "Price: %d gold\n" % species.base_price
    info += "Rarity: %s\n" % species.rarity
    info += "Lifespan: %d weeks\n" % species.lifespan_weeks
    info += "Tags: %s\n" % species.guaranteed_tags
    info += "Egg Groups: %s\n" % species.egg_groups

    return info

func validate_all_species() -> Dictionary:
    var results = {
        "valid_count": 0,
        "invalid_species": [],
        "total_errors": 0,
        "total_warnings": 0
    }

    for species_id in species_database:
        var species = species_database[species_id]
        var validation = species.validate()

        if validation.valid:
            results.valid_count += 1
        else:
            results.invalid_species.append({
                "species_id": species_id,
                "errors": validation.errors,
                "warnings": validation.warnings
            })

        results.total_errors += validation.errors.size()
        results.total_warnings += validation.warnings.size()

    return results
```

### SpeciesDisplayHelper - Utility Class
```gdscript
# scripts/utils/species_display_helper.gd
class_name SpeciesDisplayHelper
extends RefCounted

# Get rarity color for display
static func get_rarity_color(rarity: String) -> Color:
    match rarity.to_lower():
        "common":
            return Color.WHITE
        "uncommon":
            return Color.GREEN
        "rare":
            return Color.BLUE
        "epic":
            return Color.PURPLE
        "legendary":
            return Color.ORANGE
        "unique":
            return Color.RED
        _:
            return Color.GRAY

# Format species info for tooltip
static func get_species_tooltip(species: SpeciesResource) -> String:
    if not species:
        return "Unknown Species"

    var tooltip = "[b]%s[/b]\n" % species.display_name
    tooltip += "%s\n\n" % species.description

    tooltip += "[b]Stats:[/b]\n"
    tooltip += "STR: %d-%d\n" % [species.strength_range.x, species.strength_range.y]
    tooltip += "CON: %d-%d\n" % [species.constitution_range.x, species.constitution_range.y]
    tooltip += "DEX: %d-%d\n" % [species.dexterity_range.x, species.dexterity_range.y]
    tooltip += "INT: %d-%d\n" % [species.intelligence_range.x, species.intelligence_range.y]
    tooltip += "WIS: %d-%d\n" % [species.wisdom_range.x, species.wisdom_range.y]
    tooltip += "DIS: %d-%d\n\n" % [species.discipline_range.x, species.discipline_range.y]

    if species.guaranteed_tags.size() > 0:
        tooltip += "[b]Tags:[/b] %s\n" % ", ".join(species.guaranteed_tags)

    tooltip += "[b]Price:[/b] %d gold\n" % species.base_price
    tooltip += "[b]Rarity:[/b] %s" % species.rarity

    return tooltip

# Get formatted stat range
static func format_stat_range(stat_range: Vector2i) -> String:
    return "%d-%d" % [stat_range.x, stat_range.y]

# Create rich text for species name
static func get_species_name_rich_text(species: SpeciesResource) -> String:
    if not species:
        return "[color=gray]Unknown Species[/color]"

    var color = get_rarity_color(species.rarity)
    return "[color=#%s]%s[/color]" % [color.to_html(false), species.display_name]
```

## Success Metrics
- SpeciesSystem loads as GameCore subsystem in < 10ms
- Species resources load in < 100ms total
- Cache improves query performance by 50%+
- Creature generation uses species data correctly
- All species have complete, valid data
- System handles missing species gracefully
- Easy to add new species without code changes
- All signals properly routed through SignalBus

## Notes
- SpeciesSystem is a GameCore subsystem, not an autoload
- Start with 4-5 core species for Stage 1
- Visual assets can be added later
- Use Godot's resource inspector for easy editing
- Consider version control for resource files
- Plan for modding support in future
- Caching significantly improves performance
- Resource validation prevents invalid data

## Estimated Time
4-5 hours for implementation and testing