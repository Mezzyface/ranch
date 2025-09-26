# Stage 2 Task 5: StaminaSystem Implementation

## Overview
Implement a stamina management system that tracks creature energy levels, handles weekly depletion for active creatures, and provides recovery mechanics through rest and food.

## Success Criteria
- [ ] StaminaSystem loads via GameCore lazy loading
- [ ] Stamina tracking per creature (0-100 scale)
- [ ] Weekly depletion for active roster
- [ ] Recovery mechanics for resting creatures
- [ ] Food-based stamina restoration
- [ ] Integration with creature activities
- [ ] Performance: Update 100 creatures in <50ms

## Files to Create/Modify

### New Files
- `scripts/systems/stamina_system.gd`
- `scripts/data/stamina_data.gd`
- `tests/individual/test_stamina.gd`

### Modified Files
- `scripts/data/creature_data.gd` - Add stamina properties
- `scripts/core/signal_bus.gd` - Add stamina signals
- `scripts/systems/time_system.gd` - Trigger weekly stamina updates

## Implementation Details

### 1. StaminaSystem Architecture
```gdscript
class_name StaminaSystem extends Node

# Constants
const MAX_STAMINA: int = 100
const MIN_STAMINA: int = 0
const ACTIVE_WEEKLY_COST: int = 20
const STABLE_WEEKLY_RECOVERY: int = 30
const EXHAUSTION_THRESHOLD: int = 20

# Stamina tracking
var creature_stamina: Dictionary = {}  # creature_id -> int

# System state
var depletion_modifiers: Dictionary = {}  # creature_id -> float
var recovery_modifiers: Dictionary = {}  # creature_id -> float

func get_stamina(creature: CreatureData) -> int
func set_stamina(creature: CreatureData, value: int) -> void
func deplete_stamina(creature: CreatureData, amount: int) -> bool
func restore_stamina(creature: CreatureData, amount: int) -> void
func is_exhausted(creature: CreatureData) -> bool
func can_perform_activity(creature: CreatureData, cost: int) -> bool
func process_weekly_stamina() -> void
```

### 2. Weekly Stamina Processing
```gdscript
func process_weekly_stamina() -> void:
    var collection = GameCore.get_system("collection")

    # Deplete active creatures
    for creature in collection.get_active_creatures():
        var depletion = ACTIVE_WEEKLY_COST
        depletion *= depletion_modifiers.get(creature.id, 1.0)
        deplete_stamina(creature, depletion)

    # Restore stable creatures
    for creature in collection.get_stable_creatures():
        var recovery = STABLE_WEEKLY_RECOVERY
        recovery *= recovery_modifiers.get(creature.id, 1.0)
        restore_stamina(creature, recovery)
```

### 3. Food Integration
```gdscript
func apply_food_effect(creature: CreatureData, food_type: String) -> void:
    var restoration = _get_food_stamina_value(food_type)
    restore_stamina(creature, restoration)
    SignalBus.food_consumed.emit(creature, food_type)
```

### 4. Activity Cost System
```gdscript
# Activity costs
enum Activity {
    TRAINING = 10,
    QUEST = 15,
    COMPETITION = 25,
    BREEDING = 30
}

func perform_activity(creature: CreatureData, activity: Activity) -> bool:
    if not can_perform_activity(creature, activity):
        return false
    deplete_stamina(creature, activity)
    return true
```

## Integration Points
- TimeSystem: Weekly stamina updates
- FoodSystem: Stamina restoration from food
- PlayerCollection: Active/stable creature lists
- SaveSystem: Persist stamina states
- UI: Display stamina bars and warnings