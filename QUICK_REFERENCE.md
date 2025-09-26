# 🚀 Quick Reference Guide

## System Access Patterns

```gdscript
# Get any system (lazy loaded)
var stat_system = GameCore.get_system("stat")
var save_system = GameCore.get_system("save")
var tag_system = GameCore.get_system("tag")    # Future

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

## Signal Patterns

```gdscript
# Connect to signals
var signal_bus = GameCore.get_signal_bus()
signal_bus.creature_stats_changed.connect(_on_stats_changed)
signal_bus.creature_modifiers_changed.connect(_on_modifiers_changed)

# Emit signals (usually done by systems)
signal_bus.emit_creature_stats_changed(creature_data, "strength", old_val, new_val)
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
    # Test cases
    if expected_result == actual_result:
        print("✅ My feature works")
    else:
        print("❌ My feature failed")
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