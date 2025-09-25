# Task 03: Stat System Implementation

## Overview
Implement the complete stat system with 6 core stats, their growth patterns, validation, and modification mechanics as defined in the game design.

## Dependencies
- Task 01: Project Setup (complete)
- Task 02: Creature Class (complete)
- Design document: `stats.md`

## Context
From `stats.md`:
- 6 core stats: Strength (STR), Constitution (CON), Dexterity (DEX), Intelligence (INT), Wisdom (WIS), Discipline (DIS)
- Stats range from 0-1000 with logarithmic growth
- Each stat serves specific gameplay purposes
- Stats are modified by age, food, and training
- Stats determine quest eligibility and competition performance

## Requirements

### Stat Definitions
Create a comprehensive stat system that includes:

1. **Stat Enumeration**
   - STR (Strength): Physical power, combat ability
   - CON (Constitution): Health, endurance, stamina
   - DEX (Dexterity): Speed, agility, precision
   - INT (Intelligence): Mental capacity, learning
   - WIS (Wisdom): Awareness, intuition, perception
   - DIS (Discipline): Obedience, reliability, focus

2. **Growth Patterns**
   - Base growth: +5 to +15 per training session
   - Diminishing returns above 500
   - Soft cap at 800 (very slow growth)
   - Hard cap at 1000

3. **Stat Modifiers**
   - Age modifiers (young +10%, adult 0%, elder -10%)
   - Food bonuses (+50% training effectiveness)
   - Temporary effects (competition bonuses, etc.)

4. **Validation Rules**
   - Stats cannot be negative
   - Stats cannot exceed 1000
   - Modified stats respect boundaries
   - Growth calculations prevent overflow

### StatManager Singleton
Create a manager for stat-related operations:
```
StatManager (Node)
├── Stat calculations
├── Growth formulas
├── Modifier tracking
└── Validation methods
```

## Implementation Steps

1. **Create Stat Constants**
   - Define stat enums
   - Set growth constants
   - Define modifier types

2. **Implement Growth System**
   - Base growth calculation
   - Diminishing returns formula
   - Food modifier application
   - Age modifier application

3. **Create StatModifier Class**
   - Temporary stat modifications
   - Duration tracking
   - Stacking rules

4. **Implement Validation System**
   - Boundary checking
   - Growth validation
   - Modifier validation

5. **Add Utility Functions**
   - Stat comparison methods
   - Requirement checking
   - Performance calculations

## Test Criteria

### Unit Tests
- [ ] Stats initialize at correct default values
- [ ] Stat growth stays within expected ranges
- [ ] Diminishing returns apply correctly above 500
- [ ] Stats cannot exceed 1000
- [ ] Stats cannot go below 0
- [ ] Age modifiers apply correctly
- [ ] Food bonuses calculate properly
- [ ] Multiple modifiers stack correctly

### Growth Pattern Tests
- [ ] Training from 0-100: +10-15 per session
- [ ] Training from 100-500: +7-12 per session
- [ ] Training from 500-800: +3-7 per session
- [ ] Training from 800-1000: +1-3 per session

### Integration Tests
- [ ] Creature stats update correctly
- [ ] Modified stats calculate properly for requirements
- [ ] Performance scores use modified stats
- [ ] Stat changes persist through save/load

## Code Implementation

### Stat Constants (`scripts/systems/stat_constants.gd`)
```gdscript
class_name StatConstants
extends Resource

enum StatType {
    STRENGTH,
    CONSTITUTION,
    DEXTERITY,
    INTELLIGENCE,
    WISDOM,
    DISCIPLINE
}

const STAT_NAMES = {
    StatType.STRENGTH: "STR",
    StatType.CONSTITUTION: "CON",
    StatType.DEXTERITY: "DEX",
    StatType.INTELLIGENCE: "INT",
    StatType.WISDOM: "WIS",
    StatType.DISCIPLINE: "DIS"
}

const STAT_DESCRIPTIONS = {
    StatType.STRENGTH: "Physical power and combat ability",
    StatType.CONSTITUTION: "Health, endurance, and stamina",
    StatType.DEXTERITY: "Speed, agility, and precision",
    StatType.INTELLIGENCE: "Mental capacity and learning",
    StatType.WISDOM: "Awareness, intuition, and perception",
    StatType.DISCIPLINE: "Obedience, reliability, and focus"
}

# Growth Constants
const BASE_GROWTH_MIN = 5
const BASE_GROWTH_MAX = 15
const DIMINISHING_THRESHOLD = 500
const SOFT_CAP = 800
const HARD_CAP = 1000

# Modifier Types
enum ModifierType {
    AGE,
    FOOD,
    TEMPORARY,
    EQUIPMENT,
    STATUS_EFFECT
}
```

### StatModifier Class (`scripts/creatures/stat_modifier.gd`)
```gdscript
class_name StatModifier
extends Resource

@export var modifier_type: StatConstants.ModifierType
@export var stat_type: StatConstants.StatType
@export var value: float = 0.0  # Percentage or flat value
@export var is_percentage: bool = true
@export var duration_weeks: int = -1  # -1 for permanent
@export var remaining_weeks: int = 0

func _init(
    type: StatConstants.ModifierType = StatConstants.ModifierType.TEMPORARY,
    stat: StatConstants.StatType = StatConstants.StatType.STRENGTH,
    mod_value: float = 0.0,
    percentage: bool = true,
    duration: int = -1
):
    modifier_type = type
    stat_type = stat
    value = mod_value
    is_percentage = percentage
    duration_weeks = duration
    remaining_weeks = duration

func apply_to_value(base_value: int) -> int:
    if is_percentage:
        return int(base_value * (1.0 + value))
    else:
        return base_value + int(value)

func tick_week():
    if duration_weeks > 0 and remaining_weeks > 0:
        remaining_weeks -= 1

func is_expired() -> bool:
    return duration_weeks > 0 and remaining_weeks <= 0

func to_dict() -> Dictionary:
    return {
        "modifier_type": modifier_type,
        "stat_type": stat_type,
        "value": value,
        "is_percentage": is_percentage,
        "duration_weeks": duration_weeks,
        "remaining_weeks": remaining_weeks
    }

static func from_dict(data: Dictionary) -> StatModifier:
    var modifier = StatModifier.new()
    modifier.modifier_type = data.get("modifier_type", 0)
    modifier.stat_type = data.get("stat_type", 0)
    modifier.value = data.get("value", 0.0)
    modifier.is_percentage = data.get("is_percentage", true)
    modifier.duration_weeks = data.get("duration_weeks", -1)
    modifier.remaining_weeks = data.get("remaining_weeks", 0)
    return modifier
```

### StatManager Singleton (`scripts/systems/stat_manager.gd`)
```gdscript
extends Node

# Growth calculation with diminishing returns
func calculate_stat_growth(current_value: int, base_growth: int, food_bonus: float = 0.0) -> int:
    # Apply diminishing returns based on current value
    var growth_multiplier = 1.0

    if current_value >= StatConstants.SOFT_CAP:
        growth_multiplier = 0.2  # 80% reduction above soft cap
    elif current_value >= StatConstants.DIMINISHING_THRESHOLD:
        # Linear reduction from 100% to 50% between 500 and 800
        var progress = (current_value - StatConstants.DIMINISHING_THRESHOLD) / 300.0
        growth_multiplier = 1.0 - (0.5 * progress)

    # Calculate final growth
    var modified_growth = base_growth * growth_multiplier

    # Apply food bonus
    if food_bonus > 0:
        modified_growth *= (1.0 + food_bonus)

    # Ensure we don't exceed hard cap
    var final_value = current_value + int(modified_growth)
    if final_value > StatConstants.HARD_CAP:
        return StatConstants.HARD_CAP - current_value

    return int(modified_growth)

# Generate random base growth value
func get_random_base_growth() -> int:
    return randi_range(StatConstants.BASE_GROWTH_MIN, StatConstants.BASE_GROWTH_MAX)

# Apply all modifiers to a base stat value
func apply_modifiers(base_value: int, modifiers: Array[StatModifier]) -> int:
    var modified_value = base_value
    var percentage_mod = 1.0
    var flat_mod = 0

    for modifier in modifiers:
        if modifier.is_expired():
            continue

        if modifier.is_percentage:
            percentage_mod += modifier.value
        else:
            flat_mod += int(modifier.value)

    # Apply percentage modifiers first, then flat
    modified_value = int(modified_value * percentage_mod)
    modified_value += flat_mod

    # Clamp to valid range
    return clampi(modified_value, 0, StatConstants.HARD_CAP)

# Check if creature meets stat requirement
func meets_requirement(creature_stat: int, required_stat: int, comparison: String = ">=") -> bool:
    match comparison:
        ">=": return creature_stat >= required_stat
        ">": return creature_stat > required_stat
        "<=": return creature_stat <= required_stat
        "<": return creature_stat < required_stat
        "==": return creature_stat == required_stat
        _: return false

# Calculate performance score for competitions
func calculate_performance_score(
    primary_stat: int,
    secondary_stats: Array[int],
    modifiers: Array[StatModifier] = []
) -> float:
    # Apply modifiers to primary stat
    var modified_primary = apply_modifiers(primary_stat, modifiers)

    # Base formula: Primary × 3 + Secondary × 1.5 each
    var score = modified_primary * 3.0

    for secondary in secondary_stats:
        score += secondary * 1.5

    # Add random variance (±15%)
    var variance = randf_range(0.85, 1.15)
    score *= variance

    return score

# Get stat growth description for UI
func get_growth_description(current_value: int) -> String:
    if current_value >= StatConstants.SOFT_CAP:
        return "Very Slow (soft capped)"
    elif current_value >= 700:
        return "Slow"
    elif current_value >= StatConstants.DIMINISHING_THRESHOLD:
        return "Moderate"
    elif current_value >= 200:
        return "Good"
    else:
        return "Excellent"

# Training effectiveness based on current stat
func get_training_effectiveness(current_value: int) -> float:
    if current_value >= StatConstants.SOFT_CAP:
        return 0.2
    elif current_value >= StatConstants.DIMINISHING_THRESHOLD:
        var progress = (current_value - StatConstants.DIMINISHING_THRESHOLD) / 300.0
        return 1.0 - (0.5 * progress)
    else:
        return 1.0

# Validate stat value
func validate_stat_value(value: int) -> int:
    return clampi(value, 0, StatConstants.HARD_CAP)

# Get age modifier for creature
func get_age_modifier(age_category: Creature.AgeCategory) -> float:
    match age_category:
        Creature.AgeCategory.YOUNG:
            return 0.1  # +10%
        Creature.AgeCategory.ADULT:
            return 0.0  # No modifier
        Creature.AgeCategory.ELDER:
            return -0.1  # -10%
        _:
            return 0.0

# Calculate total stats for creature evaluation
func calculate_total_stats(creature: Creature, include_modifiers: bool = false) -> int:
    var total = 0
    total += creature.strength
    total += creature.constitution
    total += creature.dexterity
    total += creature.intelligence
    total += creature.wisdom
    total += creature.discipline

    if include_modifiers:
        var age_mod = get_age_modifier(creature.get_age_category())
        total = int(total * (1.0 + age_mod))

    return total

# Get stat distribution analysis
func analyze_stat_distribution(creature: Creature) -> Dictionary:
    var stats = [
        creature.strength,
        creature.constitution,
        creature.dexterity,
        creature.intelligence,
        creature.wisdom,
        creature.discipline
    ]

    stats.sort()

    return {
        "min": stats[0],
        "max": stats[5],
        "average": calculate_total_stats(creature) / 6,
        "median": (stats[2] + stats[3]) / 2,
        "spread": stats[5] - stats[0]
    }
```

## Success Metrics
- Stat calculations complete in < 1ms
- Growth patterns match design specifications
- Modifiers apply correctly without overflow
- All edge cases handled (0, 1000, negative inputs)
- Clear error messages for invalid operations

## Notes
- Keep calculations deterministic where possible
- Use integer math to avoid floating point issues
- Consider caching frequently calculated values
- Ensure thread safety for concurrent access

## Estimated Time
3-4 hours for implementation and testing