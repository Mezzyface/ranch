# 🚀 Quick Reference Guide

## System Access Patterns

```gdscript
# Get any system (lazy loaded)
var stat_system = GameCore.get_system("stat")
var save_system = GameCore.get_system("save")
var tag_system = GameCore.get_system("tag")
var creature_system = GameCore.get_system("creature")  # Future
var quest_system = GameCore.get_system("quest")        # Future

# Get SignalBus (always available)
var signal_bus = GameCore.get_signal_bus()
```

## CreatureEntity Usage

```gdscript
# Create creature entity
var entity = CreatureEntity.new(creature_data)
add_child(entity)  # Must add to scene tree!

# Stat operations (for quest eligibility)
var quest_strength = entity.get_effective_stat("strength")     # No age modifier
var meets_quest = entity.matches_requirements(stat_reqs, tag_reqs)

# Performance operations (for competitions)
var comp_strength = entity.get_competition_stat("strength")    # With age modifier
var performance = entity.get_performance_score()              # Age-affected

# Modifier management
entity.apply_stat_modifier("strength", 100, ModifierType.EQUIPMENT, StackingMode.ADDITIVE, -1, "sword")
entity.remove_stat_modifier("strength", "sword")
entity.clear_all_modifiers()

# Tag management (Task 4)
var success = entity.add_tag("Dark Vision")           # Validated through TagSystem
var removed = entity.remove_tag("Nocturnal")          # Safe removal
var can_add_result = entity.can_add_tag("Large")      # Check before adding
var size_tags = entity.get_tags_by_category(TagSystem.TagCategory.SIZE)
```

## StatSystem Direct Usage

```gdscript
var stat_system = GameCore.get_system("stat")

# Validation
var valid_value = stat_system.validate_stat_value("strength", 2000)  # Returns 1000
var tier = stat_system.get_stat_tier(750)  # Returns "STRONG"

# Requirements
var eligible = stat_system.meets_requirements(creature_data, {"strength": 400})

# Modifiers
stat_system.apply_modifier(creature_id, "strength", 50, ModifierType.TEMPORARY, StackingMode.ADDITIVE, 3, "blessing")
var breakdown = stat_system.get_stat_breakdown(creature_data, "strength")
```

## TagSystem Direct Usage (Task 4)

```gdscript
var tag_system = GameCore.get_system("tag")

# Tag validation
var validation = tag_system.validate_tag_combination(["Medium", "Flies", "Winged"])
if validation.valid:
    print("Valid tag combination")
else:
    print("Errors: ", validation.errors)

# Tag queries
var all_tags = tag_system.get_all_tags()                              # 25 tags
var size_tags = tag_system.get_tags_by_category(TagSystem.TagCategory.SIZE)  # [Small, Medium, Large]
var description = tag_system.get_tag_description("Dark Vision")

# Quest requirements
var meets_reqs = tag_system.meets_tag_requirements(creature_data, ["Dark Vision", "Stealthy"])

# Collection filtering (0ms performance for 100+ creatures)
var stealth_creatures = tag_system.filter_creatures_by_tags(creature_list, ["Stealthy"])
var non_aquatic = tag_system.filter_creatures_by_tags(creature_list, [], ["Aquatic"])

# Tag scoring
var match_score = tag_system.calculate_tag_match_score(creature_tags, required_tags)  # 0.0-1.0

# Breeding inheritance (future)
var inherited = tag_system.calculate_inherited_tags(parent1_tags, parent2_tags)
```

## Signal Patterns

```gdscript
# Connect to signals
var signal_bus = GameCore.get_signal_bus()
signal_bus.creature_stats_changed.connect(_on_stats_changed)
signal_bus.creature_modifiers_changed.connect(_on_modifiers_changed)

# Tag signals (Task 4)
signal_bus.creature_tag_added.connect(_on_tag_added)
signal_bus.creature_tag_removed.connect(_on_tag_removed)
signal_bus.tag_add_failed.connect(_on_tag_failed)

# Emit signals (usually done by systems)
signal_bus.emit_creature_stats_changed(creature_data, "strength", old_val, new_val)
signal_bus.emit_creature_tag_added(creature_data, "Dark Vision")
```

## Common Modifiers

```gdscript
# Equipment bonus (permanent)
stat_system.apply_modifier(id, "strength", 75, ModifierType.EQUIPMENT, StackingMode.ADDITIVE, -1, "steel_sword")

# Temporary buff (3 weeks)
stat_system.apply_modifier(id, "dexterity", 20, ModifierType.TEMPORARY, StackingMode.MULTIPLICATIVE, 3, "haste_potion")

# Trait modifier (permanent)
stat_system.apply_modifier(id, "intelligence", 50, ModifierType.TRAIT, StackingMode.ADDITIVE, -1, "genius_trait")
```

## Testing Pattern

```gdscript
# Add to test_setup.gd
func _test_my_feature():
    print("\n=== Test My Feature ===")
    # Test setup
    var system = GameCore.get_system("my_system")

    # Test cases with comprehensive validation
    if expected_result == actual_result:
        print("✅ My feature works")
    else:
        print("❌ My feature failed")

    # Performance testing (established pattern)
    var start_time = Time.get_unix_time_from_system()
    # ... performance test code ...
    var end_time = Time.get_unix_time_from_system()
    var duration = end_time - start_time
    print("✅ Performance test: completed in %dms" % duration)

    # Integration testing
    # Test system interaction with CreatureEntity, TagSystem, StatSystem

    # Edge case testing
    # Test null inputs, boundary values, invalid data
```

## Established Test Categories

```gdscript
# From Tasks 1-4 success patterns:
# 1. Basic functionality tests
# 2. Validation tests (conflicts, dependencies)
# 3. Integration tests (system interactions)
# 4. Performance tests (0ms targets achieved)
# 5. Edge case tests (null/invalid data)
# 6. Statistical tests (distribution validation)
# 7. Memory management tests (cleanup)
# 8. Signal flow tests (emission validation)
```

## Age Modifier Rules

- **Quest Requirements**: Use `get_effective_stat()` - NO age modifier
- **Competition Performance**: Use `get_competition_stat()` - WITH age modifier
- **Training Gains**: Age affects learning rates (future implementation)
- **Stamina Recovery**: Age affects recovery speed (future implementation)

## Stat Boundaries

- **Range**: 1-1000 (automatically clamped)
- **Tiers**: WEAK(0-199), BELOW_AVERAGE(200-399), AVERAGE(400-599), ABOVE_AVERAGE(600-749), STRONG(750-899), EXCEPTIONAL(900-1000)
- **Modifier Stacking**: Additive first, then multiplicative, then clamp to 1-1000

## CreatureGenerator Usage (Task 5)

```gdscript
# Generate lightweight CreatureData (for save/serialization)
var creature_data = CreatureGenerator.generate_creature_data("scuttleguard")

# Generate full CreatureEntity (for gameplay/behavior)
var creature_entity = CreatureGenerator.generate_creature_entity("wind_dancer")
add_child(creature_entity)  # Must add to scene tree

# Generation algorithms
var uniform_creature = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.UNIFORM)
var premium_creature = CreatureGenerator.generate_creature_data("glow_grub", CreatureGenerator.GenerationType.HIGH_ROLL)
var gaussian_creature = CreatureGenerator.generate_creature_data("scuttleguard", CreatureGenerator.GenerationType.GAUSSIAN)

# Special generation methods
var starter = CreatureGenerator.generate_starter_creature("scuttleguard")    # Stat boost for new players
var egg_hatch = CreatureGenerator.generate_from_egg("wind_dancer", "premium")  # Shop eggs
var population = CreatureGenerator.generate_population_data("stone_sentinel", 100)  # Batch generation

# Species information
var species_data = CreatureGenerator.get_species_data("glow_grub")
var all_species = CreatureGenerator.get_all_species()                        # 4 species
var valid_species = CreatureGenerator.species_exists("scuttleguard")

# Validation and statistics
var validation = CreatureGenerator.validate_creature_data(creature_data)
var stats = CreatureGenerator.get_generation_statistics(creature_array)     # Min/max/avg analysis
```

## Species Quick Reference

```gdscript
# 4 Species Available in Stage 1:
# - scuttleguard: Small guardian (200g, Common, Dark Vision)
# - stone_sentinel: Medium tank (800g, Uncommon, Natural Armor)
# - wind_dancer: Small flyer (500g, Common, Flies + Enhanced Hearing)
# - glow_grub: Small utility (400g, Common, Bioluminescent + Cleanser)

# Example stat ranges:
# Scuttleguard STR: 70-130, Wind Dancer DEX: 190-280, Stone Sentinel CON: 190-280
```

## System Creation Template

```gdscript
class_name MySystem
extends Node

var signal_bus: SignalBus

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    # Connect to signals if needed
    print("MySystem initialized")

# Add system to GameCore._load_system():
"my_system":
    system = preload("res://scripts/systems/my_system.gd").new()
```