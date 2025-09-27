# Stage 2 Task 5: StaminaSystem Implementation

## Overview
Implement a stamina management system that tracks creature energy levels, handles activity-based stamina consumption, and provides recovery mechanics through food.

## Success Criteria
- [x] StaminaSystem loads via GameCore lazy loading
- [x] Stamina tracking per creature (0-100 scale)
- [x] Activity-based stamina consumption (no passive drain)
- [x] Stasis for stable creatures (no stamina changes)
- [x] Food-based stamina restoration
- [x] Integration with creature activities
- [x] Performance: Update 100 creatures in <50ms

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

    # Active creatures: No passive stamina changes
    # Stamina only changes when performing specific activities
    var active_count = collection.get_active_creatures().size()

    # Stable creatures: In complete stasis - no changes
    var stable_count = collection.get_stable_creatures().size()

    # Emit signal for tracking purposes
    SignalBus.stamina_weekly_processed.emit(active_count, stable_count)
```

**Design Notes:**
- Active creatures only lose stamina when performing activities (Training, Quest, etc.)
- Stable creatures are in stasis - stamina remains frozen
- No passive stamina drain or recovery
- Food items are the primary recovery method

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