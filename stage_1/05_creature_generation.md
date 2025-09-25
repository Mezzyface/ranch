# Task 05: Creature Generation System

## Overview
Implement the creature generation system that creates new creatures with randomized stats within defined ranges, appropriate tags, and species-specific characteristics.

## Dependencies
- Task 02: Creature Class (complete)
- Task 03: Stat System (complete)
- Task 04: Tag System (complete)
- Design documents: `creature.md`, `shop.md`

## Context
From the design documents:
- Creatures are generated from eggs with guaranteed stat ranges
- Each species has defined stat distributions and tag sets
- Starter creatures and shop purchases need consistent generation
- Stats follow specific ranges based on species and rarity

## Requirements

### Species Definitions
Define creature species with their characteristics:

1. **Scuttleguard** (Starter/Shop)
   - Tags: [Small, Territorial, Dark Vision]
   - STR: 70-130, CON: 80-140, DEX: 90-150
   - INT: 40-70, WIS: 110-170, DIS: 90-150
   - Lifespan: 520 weeks
   - Egg Group: Field

2. **Stone Sentinel** (Shop - Premium)
   - Tags: [Medium, Camouflage, Natural Armor, Territorial]
   - STR: 130-190, CON: 190-280, DEX: 50-110
   - INT: 50-90, WIS: 130-220, DIS: 160-250
   - Lifespan: 780 weeks
   - Egg Group: Mineral

3. **Wind Dancer** (Shop)
   - Tags: [Small, Winged, Flies, Enhanced Hearing]
   - STR: 70-110, CON: 80-130, DEX: 190-280
   - INT: 90-140, WIS: 150-250, DIS: 90-150
   - Lifespan: 390 weeks
   - Egg Group: Flying

4. **Glow Grub** (Shop)
   - Tags: [Small, Bioluminescent, Cleanser, Nocturnal]
   - STR: 50-90, CON: 90-150, DEX: 70-130
   - INT: 70-110, WIS: 130-190, DIS: 110-170
   - Lifespan: 260 weeks
   - Egg Group: Bug

### Generation Rules
1. **Stat Generation**
   - Random value within species range
   - Gaussian distribution (bell curve) option
   - Minimum stat guarantees

2. **Name Generation**
   - Random from species name pool
   - Optional custom naming

3. **Age Categories**
   - Eggs hatch at 0 weeks (newborn)
   - Shop creatures start at young age (5-10% lifespan)
   - Wild creatures have varied ages

## Implementation Steps

1. **Create Species Database**
   - Species definitions with all parameters
   - Stat ranges and tag sets
   - Lifespan and egg groups

2. **Implement Generation Algorithm**
   - Stat randomization within ranges
   - Tag assignment
   - Name generation

3. **Create Factory Methods**
   - Generate from species ID
   - Generate from egg
   - Generate starter creatures

4. **Add Validation**
   - Verify generated stats within bounds
   - Ensure required tags present
   - Validate species parameters

## Test Criteria

### Unit Tests
- [ ] Generate 100 Scuttleguards with valid stats
- [ ] All generated stats within species ranges
- [ ] Required tags always present
- [ ] Names generated correctly
- [ ] Age categories set appropriately

### Statistical Tests
- [ ] Stat distribution follows expected pattern
- [ ] No stats exceed boundaries
- [ ] Average stats near range midpoint
- [ ] Edge cases handled (min/max values)

### Integration Tests
- [ ] Generated creatures work with stat system
- [ ] Generated creatures work with tag system
- [ ] Generated creatures can be saved/loaded
- [ ] Generated creatures meet quest requirements

## Code Implementation

### Species Database (`scripts/data/species_database.gd`)
```gdscript
# NOTE: This is a simplified version for Stage 1
# TODO: Migrate to using SpeciesResource system (see species.md)
# The SpeciesResource system provides better organization with:
# - Visual assets (sprite frames, icons)
# - Stat ranges and generation rules
# - Tags and breeding information
# - Economic data (prices, rarity)
# For now, using dictionary-based data for quick prototyping

class_name SpeciesDatabase
extends Resource

const SPECIES_DATA = {
    "scuttleguard": {
        "display_name": "Scuttleguard",
        "description": "Small territorial guardian with excellent night vision",
        "stat_ranges": {
            "strength": {"min": 70, "max": 130},
            "constitution": {"min": 80, "max": 140},
            "dexterity": {"min": 90, "max": 150},
            "intelligence": {"min": 40, "max": 70},
            "wisdom": {"min": 110, "max": 170},
            "discipline": {"min": 90, "max": 150}
        },
        # NOTE: Using strings for tags in Stage 1
        # TODO: Convert to Enums.CreatureTag values when enum system is implemented
        "guaranteed_tags": ["Small", "Territorial", "Dark Vision"],
        "optional_tags": ["Nocturnal"],
        "lifespan_weeks": 520,
        # NOTE: Using string for egg_group in Stage 1
        # TODO: Convert to Enums.EggGroup when breeding system is implemented
        "egg_group": "Field",
        "rarity": "common",
        "base_price": 200
    },

    "stone_sentinel": {
        "display_name": "Stone Sentinel",
        "description": "Medium-sized guardian with natural armor",
        "stat_ranges": {
            "strength": {"min": 130, "max": 190},
            "constitution": {"min": 190, "max": 280},
            "dexterity": {"min": 50, "max": 110},
            "intelligence": {"min": 50, "max": 90},
            "wisdom": {"min": 130, "max": 220},
            "discipline": {"min": 160, "max": 250}
        },
        "guaranteed_tags": ["Medium", "Camouflage", "Natural Armor", "Territorial"],
        "optional_tags": [],
        "lifespan_weeks": 780,
        "egg_group": "Mineral",
        "rarity": "uncommon",
        "base_price": 800
    },

    "wind_dancer": {
        "display_name": "Wind Dancer",
        "description": "Agile flying creature with enhanced senses",
        "stat_ranges": {
            "strength": {"min": 70, "max": 110},
            "constitution": {"min": 80, "max": 130},
            "dexterity": {"min": 190, "max": 280},
            "intelligence": {"min": 90, "max": 140},
            "wisdom": {"min": 150, "max": 250},
            "discipline": {"min": 90, "max": 150}
        },
        "guaranteed_tags": ["Small", "Winged", "Flies", "Enhanced Hearing"],
        "optional_tags": ["Diurnal"],
        "lifespan_weeks": 390,
        "egg_group": "Flying",
        "rarity": "common",
        "base_price": 500
    },

    "glow_grub": {
        "display_name": "Glow Grub",
        "description": "Bioluminescent creature with cleaning abilities",
        "stat_ranges": {
            "strength": {"min": 50, "max": 90},
            "constitution": {"min": 90, "max": 150},
            "dexterity": {"min": 70, "max": 130},
            "intelligence": {"min": 70, "max": 110},
            "wisdom": {"min": 130, "max": 190},
            "discipline": {"min": 110, "max": 170}
        },
        "guaranteed_tags": ["Small", "Bioluminescent", "Cleanser", "Nocturnal"],
        "optional_tags": [],
        "lifespan_weeks": 260,
        "egg_group": "Bug",
        "rarity": "common",
        "base_price": 400
    },

    "cave_stalker": {
        "display_name": "Cave Stalker",
        "description": "Stealthy cave dweller with excellent mobility",
        "stat_ranges": {
            "strength": {"min": 90, "max": 150},
            "constitution": {"min": 110, "max": 170},
            "dexterity": {"min": 150, "max": 250},
            "intelligence": {"min": 80, "max": 130},
            "wisdom": {"min": 140, "max": 230},
            "discipline": {"min": 130, "max": 190}
        },
        "guaranteed_tags": ["Small", "Dark Vision", "Stealthy", "Sure-Footed"],
        "optional_tags": ["Nocturnal"],
        "lifespan_weeks": 520,
        "egg_group": "Field",
        "rarity": "uncommon",
        "base_price": 600
    }
}

# Name pools for each species
const NAME_POOLS = {
    "scuttleguard": [
        "Shelly", "Guardy", "Scuttle", "Pincer", "Armor", "Shield",
        "Defender", "Watcher", "Sentinel", "Protector"
    ],
    "stone_sentinel": [
        "Rocky", "Granite", "Boulder", "Pebble", "Cliff", "Mountain",
        "Fortress", "Bastion", "Rampart", "Stronghold"
    ],
    "wind_dancer": [
        "Zephyr", "Breeze", "Gale", "Whirl", "Sky", "Cloud",
        "Feather", "Wing", "Soar", "Glide"
    ],
    "glow_grub": [
        "Glow", "Lumina", "Spark", "Shimmer", "Gleam", "Radiance",
        "Beacon", "Flash", "Bright", "Flicker"
    ],
    "cave_stalker": [
        "Shadow", "Shade", "Prowl", "Stealth", "Silent", "Whisper",
        "Phantom", "Ghost", "Specter", "Wraith"
    ]
}

static func get_species_data(species_id: String) -> Dictionary:
    return SPECIES_DATA.get(species_id, {})

static func species_exists(species_id: String) -> bool:
    return SPECIES_DATA.has(species_id)

static func get_all_species() -> Array[String]:
    var result: Array[String] = []
    for species in SPECIES_DATA:
        result.append(species)
    return result

static func get_random_name(species_id: String) -> String:
    if NAME_POOLS.has(species_id):
        var names = NAME_POOLS[species_id]
        return names[randi() % names.size()]
    return "Unknown"
```

### Creature Generator (`scripts/creatures/creature_generator.gd`)
```gdscript
class_name CreatureGenerator
extends RefCounted

enum GenerationType {
    UNIFORM,    # Equal probability across range
    GAUSSIAN,   # Bell curve distribution
    HIGH_ROLL,  # Favor higher values
    LOW_ROLL    # Favor lower values
}

# Generate a creature from species ID
static func generate_creature(
    species_id: String,
    generation_type: GenerationType = GenerationType.UNIFORM,
    age_weeks: int = 0
) -> Creature:
    if not SpeciesDatabase.species_exists(species_id):
        push_error("Unknown species: " + species_id)
        return null

    var species_data = SpeciesDatabase.get_species_data(species_id)
    var creature = Creature.new()

    # Set basic properties
    creature.species = species_id
    creature.name = SpeciesDatabase.get_random_name(species_id)
    creature.lifespan = species_data.lifespan_weeks
    creature.egg_group = species_data.egg_group
    creature.age_weeks = age_weeks

    # Generate stats
    var stat_ranges = species_data.stat_ranges
    creature.strength = _generate_stat(stat_ranges.strength, generation_type)
    creature.constitution = _generate_stat(stat_ranges.constitution, generation_type)
    creature.dexterity = _generate_stat(stat_ranges.dexterity, generation_type)
    creature.intelligence = _generate_stat(stat_ranges.intelligence, generation_type)
    creature.wisdom = _generate_stat(stat_ranges.wisdom, generation_type)
    creature.discipline = _generate_stat(stat_ranges.discipline, generation_type)

    # Assign tags
    for tag in species_data.guaranteed_tags:
        creature.add_tag(tag)

    # Optional tags (25% chance each)
    for tag in species_data.get("optional_tags", []):
        if randf() < 0.25:
            creature.add_tag(tag)

    # Set stamina based on constitution
    creature.stamina_max = 50 + (creature.constitution / 10)
    creature.stamina_current = creature.stamina_max

    return creature

# Generate stat value based on range and type
static func _generate_stat(stat_range: Dictionary, generation_type: GenerationType) -> int:
    var min_val = stat_range.min
    var max_val = stat_range.max
    var range_size = max_val - min_val

    var normalized_value: float

    match generation_type:
        GenerationType.UNIFORM:
            normalized_value = randf()

        GenerationType.GAUSSIAN:
            # Box-Muller transform for normal distribution
            var u1 = randf()
            var u2 = randf()
            var z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * PI * u2)
            # Convert to 0-1 range (clamp to 3 standard deviations)
            normalized_value = clamp((z0 + 3.0) / 6.0, 0.0, 1.0)

        GenerationType.HIGH_ROLL:
            # Use maximum of two rolls
            normalized_value = max(randf(), randf())

        GenerationType.LOW_ROLL:
            # Use minimum of two rolls
            normalized_value = min(randf(), randf())

    return min_val + int(normalized_value * range_size)

# Generate a starter creature for new players
static func generate_starter_creature(species_id: String) -> Creature:
    var creature = generate_creature(species_id, GenerationType.GAUSSIAN, 26)  # 6 months old
    creature.is_active = true
    # Starters get a slight stat boost
    creature.strength = mini(creature.strength + 5, 1000)
    creature.constitution = mini(creature.constitution + 5, 1000)
    creature.wisdom = mini(creature.wisdom + 5, 1000)
    creature.discipline = mini(creature.discipline + 5, 1000)
    return creature

# Generate creature from shop egg
static func generate_from_egg(species_id: String, quality: String = "normal") -> Creature:
    var generation_type = GenerationType.UNIFORM

    match quality:
        "premium":
            generation_type = GenerationType.HIGH_ROLL
        "discount":
            generation_type = GenerationType.LOW_ROLL
        _:
            generation_type = GenerationType.GAUSSIAN

    # Eggs hatch as young creatures (5% of lifespan)
    var species_data = SpeciesDatabase.get_species_data(species_id)
    var age = int(species_data.lifespan_weeks * 0.05)

    return generate_creature(species_id, generation_type, age)

# Batch generation for testing or population
static func generate_population(
    species_id: String,
    count: int,
    generation_type: GenerationType = GenerationType.UNIFORM
) -> Array[Creature]:
    var population: Array[Creature] = []

    for i in count:
        var age = randi_range(26, 260)  # Random ages 6 months to 5 years
        var creature = generate_creature(species_id, generation_type, age)
        if creature:
            population.append(creature)

    return population

# Validate generated creature meets species specifications
static func validate_creature(creature: Creature) -> Dictionary:
    var result = {
        "valid": true,
        "errors": []
    }

    if not SpeciesDatabase.species_exists(creature.species):
        result.valid = false
        result.errors.append("Invalid species: " + creature.species)
        return result

    var species_data = SpeciesDatabase.get_species_data(creature.species)
    var stat_ranges = species_data.stat_ranges

    # Check stat ranges
    if creature.strength < stat_ranges.strength.min or creature.strength > stat_ranges.strength.max:
        result.valid = false
        result.errors.append("Strength out of range")

    if creature.constitution < stat_ranges.constitution.min or creature.constitution > stat_ranges.constitution.max:
        result.valid = false
        result.errors.append("Constitution out of range")

    if creature.dexterity < stat_ranges.dexterity.min or creature.dexterity > stat_ranges.dexterity.max:
        result.valid = false
        result.errors.append("Dexterity out of range")

    if creature.intelligence < stat_ranges.intelligence.min or creature.intelligence > stat_ranges.intelligence.max:
        result.valid = false
        result.errors.append("Intelligence out of range")

    if creature.wisdom < stat_ranges.wisdom.min or creature.wisdom > stat_ranges.wisdom.max:
        result.valid = false
        result.errors.append("Wisdom out of range")

    if creature.discipline < stat_ranges.discipline.min or creature.discipline > stat_ranges.discipline.max:
        result.valid = false
        result.errors.append("Discipline out of range")

    # Check required tags
    for tag in species_data.guaranteed_tags:
        if not creature.has_tag(tag):
            result.valid = false
            result.errors.append("Missing required tag: " + tag)

    return result

# Generate stats summary for debugging
static func get_generation_statistics(creatures: Array[Creature]) -> Dictionary:
    if creatures.is_empty():
        return {}

    var stats = {
        "count": creatures.size(),
        "strength": {"min": 9999, "max": 0, "total": 0},
        "constitution": {"min": 9999, "max": 0, "total": 0},
        "dexterity": {"min": 9999, "max": 0, "total": 0},
        "intelligence": {"min": 9999, "max": 0, "total": 0},
        "wisdom": {"min": 9999, "max": 0, "total": 0},
        "discipline": {"min": 9999, "max": 0, "total": 0}
    }

    for creature in creatures:
        # Strength
        stats.strength.min = mini(stats.strength.min, creature.strength)
        stats.strength.max = maxi(stats.strength.max, creature.strength)
        stats.strength.total += creature.strength

        # Constitution
        stats.constitution.min = mini(stats.constitution.min, creature.constitution)
        stats.constitution.max = maxi(stats.constitution.max, creature.constitution)
        stats.constitution.total += creature.constitution

        # Dexterity
        stats.dexterity.min = mini(stats.dexterity.min, creature.dexterity)
        stats.dexterity.max = maxi(stats.dexterity.max, creature.dexterity)
        stats.dexterity.total += creature.dexterity

        # Intelligence
        stats.intelligence.min = mini(stats.intelligence.min, creature.intelligence)
        stats.intelligence.max = maxi(stats.intelligence.max, creature.intelligence)
        stats.intelligence.total += creature.intelligence

        # Wisdom
        stats.wisdom.min = mini(stats.wisdom.min, creature.wisdom)
        stats.wisdom.max = maxi(stats.wisdom.max, creature.wisdom)
        stats.wisdom.total += creature.wisdom

        # Discipline
        stats.discipline.min = mini(stats.discipline.min, creature.discipline)
        stats.discipline.max = maxi(stats.discipline.max, creature.discipline)
        stats.discipline.total += creature.discipline

    # Calculate averages
    for stat_name in ["strength", "constitution", "dexterity", "intelligence", "wisdom", "discipline"]:
        stats[stat_name]["average"] = stats[stat_name].total / creatures.size()

    return stats
```

## Success Metrics
- Generation of 1000 creatures takes < 100ms
- All generated creatures pass validation
- Stat distributions match expected patterns
- No memory leaks with large populations
- Generated creatures work in game systems

## Notes
- Consider seed-based generation for reproducibility
- Cache species data for performance
- Add more species as game expands
- Consider rare/legendary generation types

## Estimated Time
4-5 hours for implementation and testing