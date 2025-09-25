# Task 03: Stat System Implementation

## Overview
Create a stat management system as a GameCore subsystem (NOT an autoload) that handles all stat calculations, modifications, and validations for creatures. Works with CreatureData resources and CreatureEntity nodes.

## Dependencies
- Task 01: Project Setup with GameCore (complete)
- Task 02: CreatureData and CreatureEntity (complete)
- Access to design documents: `stats.md`

## Context
From the design documentation:
- 6 core stats: STR, CON, DEX, INT, WIS, DIS
- Stat range: 0-1000
- Stats affected by age modifiers
- Stats used in quest requirements and competitions

**CRITICAL**: This is a subsystem of GameCore, NOT a separate autoload!

## Requirements

### StatSystem Subsystem
Location: `scripts/systems/stat_system.gd`
- Lazy-loaded by GameCore when first accessed
- Provides stat calculation utilities
- Handles stat validation and boundaries
- Manages stat modifiers and effects

### Core Functionality
1. **Stat Calculations**
   - Base stat values (0-1000)
   - Age modifiers application
   - Temporary effects tracking
   - Combined stat calculations

2. **Stat Validation**
   - Ensure values stay within bounds
   - Validate stat modifications
   - Check stat requirements for quests

3. **Stat Comparisons**
   - Compare creature stats for competitions
   - Calculate stat-based performance scores
   - Determine stat advantages/disadvantages

## Implementation Steps

1. **Create StatSystem as GameCore Subsystem**
   - Create `scripts/systems/stat_system.gd`
   - Extends Node (NOT autoloaded)
   - Lazy-loaded by GameCore

2. **Add to GameCore Loader**
   - Update GameCore._load_system() to include "stat" case
   - System created only when first requested

3. **Implement Core Methods**
   - Stat calculations with modifiers
   - Validation functions
   - Comparison utilities

4. **Connect to SignalBus**
   - Listen for stat change events
   - Emit stat-related signals through SignalBus

5. **Create Unit Tests**
   - Test stat boundaries
   - Test modifier calculations
   - Test validation logic

## Test Criteria

### Unit Tests
- [ ] Stats clamp to 0-1000 range
- [ ] Age modifiers apply correctly
- [ ] Stat calculations are accurate
- [ ] Invalid stat names are rejected
- [ ] Modifiers stack properly

### Integration Tests
- [ ] StatSystem loads via GameCore
- [ ] Works with CreatureData resources
- [ ] Signals emit through SignalBus
- [ ] No memory leaks with 1000+ creatures

## Code Template

### StatSystem - GameCore Subsystem
```gdscript
# scripts/systems/stat_system.gd
class_name StatSystem
extends Node

# Stat name constants
const STAT_NAMES := {
    "STR": "strength",
    "CON": "constitution",
    "DEX": "dexterity",
    "INT": "intelligence",
    "WIS": "wisdom",
    "DIS": "discipline"
}

const STAT_MIN := 0
const STAT_MAX := 1000

var signal_bus: SignalBus
var active_modifiers: Dictionary = {} # creature_id -> modifiers

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    print("StatSystem initialized")

# Calculate effective stat value with all modifiers
func get_effective_stat(creature_data: CreatureData, stat_name: String) -> int:
    var base_value := creature_data.get_stat(stat_name)
    if base_value == 0:
        return 0

    # Apply age modifier
    var age_modifier := creature_data.get_age_modifier()
    var modified_value := int(base_value * age_modifier)

    # Apply temporary modifiers if any
    if creature_data.id in active_modifiers:
        var mods = active_modifiers[creature_data.id]
        if stat_name in mods:
            modified_value += mods[stat_name]

    return clampi(modified_value, STAT_MIN, STAT_MAX)

# Validate a stat modification
func validate_stat_change(current_value: int, change: int) -> int:
    return clampi(current_value + change, STAT_MIN, STAT_MAX)

# Apply temporary modifier to creature
func apply_modifier(creature_id: String, stat_name: String, value: int, duration_weeks: int = 1) -> void:
    if not creature_id in active_modifiers:
        active_modifiers[creature_id] = {}

    active_modifiers[creature_id][stat_name] = value

    # Schedule removal (would connect to time system)
    if duration_weeks > 0:
        _schedule_modifier_removal(creature_id, stat_name, duration_weeks)

# Remove modifier
func remove_modifier(creature_id: String, stat_name: String) -> void:
    if creature_id in active_modifiers:
        active_modifiers[creature_id].erase(stat_name)
        if active_modifiers[creature_id].is_empty():
            active_modifiers.erase(creature_id)

# Calculate total stats for performance
func calculate_total_stats(creature_data: CreatureData) -> int:
    var total := 0
    for stat_key in STAT_NAMES:
        total += get_effective_stat(creature_data, STAT_NAMES[stat_key])
    return total

# Check if creature meets stat requirements
func meets_requirements(creature_data: CreatureData, requirements: Dictionary) -> bool:
    for stat_name in requirements:
        var required_value = requirements[stat_name]
        var creature_value = get_effective_stat(creature_data, stat_name)
        if creature_value < required_value:
            return false
    return true

# Compare two creatures' stats
func compare_stats(creature_a: CreatureData, creature_b: CreatureData, stat_name: String) -> int:
    var a_value := get_effective_stat(creature_a, stat_name)
    var b_value := get_effective_stat(creature_b, stat_name)
    return a_value - b_value

# Calculate stat-based performance score
func calculate_performance(creature_data: CreatureData, weights: Dictionary = {}) -> float:
    var default_weights := {
        "strength": 0.15,
        "constitution": 0.15,
        "dexterity": 0.15,
        "intelligence": 0.15,
        "wisdom": 0.15,
        "discipline": 0.25
    }

    if weights.is_empty():
        weights = default_weights

    var score := 0.0
    for stat_name in weights:
        var stat_value := get_effective_stat(creature_data, stat_name)
        score += stat_value * weights[stat_name]

    return score

# Get stat growth rate based on training
func calculate_growth_rate(current_value: int, trainer_skill: int = 50) -> int:
    # Higher current values grow slower (diminishing returns)
    var difficulty_modifier := 1.0 - (current_value / float(STAT_MAX))
    var trainer_modifier := trainer_skill / 100.0
    var base_growth := randi_range(1, 5)

    return int(base_growth * difficulty_modifier * trainer_modifier)

# Validate stat distribution for new creatures
func validate_stat_distribution(stats: Dictionary) -> bool:
    var total := 0
    for stat_name in stats:
        var value = stats[stat_name]
        if value < STAT_MIN or value > STAT_MAX:
            return false
        total += value

    # Check if total is reasonable for starting creature
    var max_starting_total := 300  # 50 average per stat
    return total <= max_starting_total

# Get readable stat name
func get_stat_display_name(stat_key: String) -> String:
    match stat_key.to_upper():
        "STR", "STRENGTH": return "Strength"
        "CON", "CONSTITUTION": return "Constitution"
        "DEX", "DEXTERITY": return "Dexterity"
        "INT", "INTELLIGENCE": return "Intelligence"
        "WIS", "WISDOM": return "Wisdom"
        "DIS", "DISCIPLINE": return "Discipline"
        _: return stat_key.capitalize()

# Schedule modifier removal (placeholder for time system integration)
func _schedule_modifier_removal(creature_id: String, stat_name: String, duration_weeks: int) -> void:
    # Will connect to time system in later task
    pass

# Get stat breakdown for UI display
func get_stat_breakdown(creature_data: CreatureData, stat_name: String) -> Dictionary:
    var base := creature_data.get_stat(stat_name)
    var age_mod := creature_data.get_age_modifier()
    var age_adjusted := int(base * age_mod)
    var temp_mod := 0

    if creature_data.id in active_modifiers and stat_name in active_modifiers[creature_data.id]:
        temp_mod = active_modifiers[creature_data.id][stat_name]

    return {
        "base": base,
        "age_modifier": age_mod,
        "age_adjusted": age_adjusted,
        "temporary_modifier": temp_mod,
        "final": get_effective_stat(creature_data, stat_name)
    }
```

### Update GameCore to Include StatSystem
```gdscript
# In GameCore._load_system() method, add:
"stat":
    system = preload("res://scripts/systems/stat_system.gd").new()
```

### Example Usage
```gdscript
# From any script:
var stat_system = GameCore.get_system("stat") as StatSystem

# Get effective stat
var strength = stat_system.get_effective_stat(creature_data, "strength")

# Check requirements
var meets_reqs = stat_system.meets_requirements(creature_data, {"strength": 100, "dexterity": 75})

# Apply temporary boost
stat_system.apply_modifier(creature_data.id, "strength", 50, 4)  # +50 STR for 4 weeks
```

## Success Metrics
- Stat calculations complete in < 1ms per creature
- System handles 10,000+ stat queries per second
- Memory usage < 1MB for tracking modifiers
- All stat operations maintain data integrity

## Notes
- StatSystem is stateless except for temporary modifiers
- All permanent stat changes go through CreatureEntity
- System designed for future expansion (buffs/debuffs)
- Thread-safe for potential multiplayer

## Estimated Time
2-3 hours for implementation and testing