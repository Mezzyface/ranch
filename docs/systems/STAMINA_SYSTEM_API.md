# Stamina System API Reference

## Overview

The StaminaSystem manages creature energy levels through an activity-based model. Stamina only changes when creatures are assigned to specific activities - there is no passive drain or recovery. This ensures strategic resource management where players must balance work activities with rest periods.

## Core Components

### StaminaSystem (`scripts/systems/stamina_system.gd`)

Activity-based stamina management system.

#### Key Properties
```gdscript
# Constants
const MAX_STAMINA: int = 100
const MIN_STAMINA: int = 0
const EXHAUSTION_THRESHOLD: int = 20

# Activity costs (positive = depletion, negative = restoration)
enum Activity {
    IDLE = 0,        # No stamina change
    REST = -20,      # Restores 20 stamina
    TRAINING = 10,   # Costs 10 stamina
    QUEST = 15,      # Costs 15 stamina
    COMPETITION = 25,# Costs 25 stamina
    BREEDING = 30    # Costs 30 stamina
}

# State tracking
creature_stamina: Dictionary      # creature_id -> int
creature_activities: Dictionary   # creature_id -> Activity
exhausted_creatures: Dictionary   # creature_id -> bool
depletion_modifiers: Dictionary   # creature_id -> float
recovery_modifiers: Dictionary    # creature_id -> float
```

#### Core Methods

##### Stamina Management
```gdscript
get_stamina(creature: CreatureData) -> int
# Get current stamina level
# Returns: 0-100 (or max_stamina)

set_stamina(creature: CreatureData, value: int) -> void
# Set stamina to specific value (clamped to valid range)

deplete_stamina(creature: CreatureData, amount: int) -> bool
# Reduce stamina by amount (applies modifiers)
# Returns: true if successful

restore_stamina(creature: CreatureData, amount: int) -> void
# Increase stamina by amount (applies modifiers)

is_exhausted(creature: CreatureData) -> bool
# Check if creature is exhausted (≤20 stamina)
```

##### Activity System
```gdscript
assign_activity(creature: CreatureData, activity: Activity) -> bool
# Assign an activity to a creature
# Returns: false if insufficient stamina for activity

get_assigned_activity(creature: CreatureData) -> Activity
# Get creature's current activity
# Returns: Activity.IDLE if none assigned

perform_activity(creature: CreatureData, activity: Activity, activity_name: String = "") -> bool
# Execute an activity immediately
# Returns: true if successful

can_perform_activity(creature: CreatureData, cost: int) -> bool
# Check if creature has enough stamina for activity

get_activity_name(activity: Activity) -> String
# Get display name for activity
```

##### Weekly Processing
```gdscript
process_weekly_activities() -> Dictionary
# Process all assigned activities during weekly update
# Returns: {activities_performed: Array, stamina_changes: Array}

auto_assign_activities() -> void
# Automatically assign activities based on stamina levels
# Low stamina (<30) → REST
# High stamina (≥80) → Can do TRAINING
# Otherwise → IDLE
```

##### Food Effects
```gdscript
apply_food_effect(creature: CreatureData, food_type: String) -> void
# Apply food restoration effect
# Food types: basic_food(10), standard_food(20), quality_food(30),
#            premium_food(50), energy_drink(40), stamina_potion(100)
```

##### Modifiers
```gdscript
set_depletion_modifier(creature: CreatureData, modifier: float) -> void
# Set stamina depletion rate modifier (1.0 = normal)

set_recovery_modifier(creature: CreatureData, modifier: float) -> void
# Set stamina recovery rate modifier (1.0 = normal)

clear_modifiers(creature: CreatureData) -> void
# Remove all modifiers for creature
```

## Activity System

### Activity Types

| Activity | Stamina Change | Description |
|----------|---------------|-------------|
| IDLE | 0 | No activity, no stamina change |
| REST | +20 | Recovers stamina through rest |
| TRAINING | -10 | Improves stats through practice |
| QUEST | -15 | Participates in quest activities |
| COMPETITION | -25 | Competes in events |
| BREEDING | -30 | Breeding activities |

### Activity Assignment

```gdscript
var stamina_system = GameCore.get_system("stamina")

# Assign specific activity
stamina_system.assign_activity(creature, StaminaSystem.Activity.TRAINING)

# Check current activity
var current = stamina_system.get_assigned_activity(creature)
if current == StaminaSystem.Activity.IDLE:
    print("Creature is idle")

# Auto-assign based on stamina
stamina_system.auto_assign_activities()
```

### Weekly Activity Processing

During weekly updates, all assigned activities are automatically processed:

```gdscript
# In WeeklyUpdateOrchestrator
func _handle_stamina() -> bool:
    var stamina_system = GameCore.get_system("stamina")
    var results = stamina_system.process_weekly_activities()

    # results contains:
    # - activities_performed: Array of activity records
    # - stamina_changes: Array of stamina changes
```

## Signal Integration

### Stamina Signals

All stamina signals emit through SignalBus:

```gdscript
# Stamina changes
signal stamina_depleted(creature: CreatureData, amount: int)
signal stamina_restored(creature: CreatureData, amount: int)

# Exhaustion events
signal creature_exhausted(creature: CreatureData)
signal creature_recovered(creature: CreatureData)

# Activity events
signal activity_assigned(creature: CreatureData, activity: int)  # activity is Activity enum value
signal stamina_activity_performed(creature: CreatureData, activity: int, cost: int)  # activity is Activity enum value

# Food consumption
signal food_consumed(creature: CreatureData, food_type: String)

# Weekly processing
signal stamina_weekly_processed(active_count: int, stable_count: int)
```

### Signal Usage Example
```gdscript
var bus = GameCore.get_signal_bus()

# Monitor exhaustion
bus.creature_exhausted.connect(_on_creature_exhausted)
bus.creature_recovered.connect(_on_creature_recovered)

# Track activities
bus.activity_assigned.connect(_on_activity_assigned)
bus.stamina_activity_performed.connect(_on_activity_performed)

func _on_creature_exhausted(creature: CreatureData):
    print("%s is exhausted! Assigning rest." % creature.creature_name)
    var stamina_system = GameCore.get_system("stamina")
    stamina_system.assign_activity(creature, StaminaSystem.Activity.REST)
```

## Usage Patterns

### Basic Stamina Management
```gdscript
var stamina_system = GameCore.get_system("stamina")
var creature = get_creature()

# Check stamina
var current = stamina_system.get_stamina(creature)
if stamina_system.is_exhausted(creature):
    print("Creature needs rest!")

# Direct stamina modification (rare)
stamina_system.set_stamina(creature, 100)  # Full restore
stamina_system.deplete_stamina(creature, 20)  # Manual depletion
stamina_system.restore_stamina(creature, 30)  # Manual restore
```

### Activity-Based Workflow
```gdscript
var stamina_system = GameCore.get_system("stamina")

# Morning: Check stamina and assign activities
for creature in active_creatures:
    var stamina = stamina_system.get_stamina(creature)

    if stamina < 30:
        # Low stamina - needs rest
        stamina_system.assign_activity(creature, StaminaSystem.Activity.REST)
    elif stamina >= 80:
        # High stamina - can work
        stamina_system.assign_activity(creature, StaminaSystem.Activity.TRAINING)
    else:
        # Medium stamina - light work
        stamina_system.assign_activity(creature, StaminaSystem.Activity.QUEST)

# Activities process automatically during weekly update
```

### Food System Integration
```gdscript
var stamina_system = GameCore.get_system("stamina")

# Apply food effect
stamina_system.apply_food_effect(creature, "quality_food")  # +30 stamina

# Custom food handling
func use_special_food(creature: CreatureData, food_item: ItemResource):
    if food_item.stamina_restore > 0:
        stamina_system.restore_stamina(creature, food_item.stamina_restore)
```

### Performance Optimization
```gdscript
var stamina_system = GameCore.get_system("stamina")

# Enable performance mode (reduces logging)
stamina_system.set_performance_mode(true)

# Batch activity assignment
stamina_system.auto_assign_activities()  # Assigns to all creatures at once

# Process all activities in one pass
var results = stamina_system.process_weekly_activities()
```

## Exhaustion Mechanics

### Exhaustion States
- **Normal**: Stamina > 20
- **Exhausted**: Stamina ≤ 20
- **Empty**: Stamina = 0

### Exhaustion Effects
```gdscript
# Exhausted creatures cannot perform most activities
if stamina_system.is_exhausted(creature):
    # Can only REST or IDLE
    stamina_system.assign_activity(creature, StaminaSystem.Activity.REST)
```

## Modifiers System

### Applying Modifiers
```gdscript
var stamina_system = GameCore.get_system("stamina")

# Make creature tire faster (1.5x depletion rate)
stamina_system.set_depletion_modifier(creature, 1.5)

# Make creature recover faster (2x recovery rate)
stamina_system.set_recovery_modifier(creature, 2.0)

# Remove all modifiers
stamina_system.clear_modifiers(creature)
```

### Modifier Sources
- **Traits**: Some creatures may have natural stamina efficiency
- **Items**: Equipment that affects stamina usage
- **Buffs/Debuffs**: Temporary effects from abilities or events
- **Age**: Older creatures might have different stamina efficiency

## Save/Load Support

### State Persistence
```gdscript
# Automatic save/load through SaveSystem
# StaminaSystem saves:
# - creature_stamina
# - creature_activities
# - depletion_modifiers
# - recovery_modifiers
# - exhausted_creatures

# Manual state access
var state = stamina_system.save_state()
stamina_system.load_state(saved_state)
```

## Performance Considerations

### Baselines
- Process 100 creatures: < 50ms
- Batch activity assignment: < 10ms
- Weekly processing: < 50ms

### Optimization Tips
1. Use `auto_assign_activities()` for bulk assignment
2. Enable performance mode during batch operations
3. Process activities once per week, not per frame
4. Cache stamina values when doing multiple checks

## Common Patterns

### Activity Scheduler
```gdscript
class_name ActivityScheduler

static func schedule_day_activities(creatures: Array[CreatureData]):
    var stamina_system = GameCore.get_system("stamina")

    for creature in creatures:
        var stamina = stamina_system.get_stamina(creature)
        var current = stamina_system.get_assigned_activity(creature)

        # Only reschedule if idle
        if current == StaminaSystem.Activity.IDLE:
            if stamina < 20:
                stamina_system.assign_activity(creature, StaminaSystem.Activity.REST)
            elif stamina > 50 and randf() > 0.5:
                stamina_system.assign_activity(creature, StaminaSystem.Activity.TRAINING)
```

### Stamina Monitor
```gdscript
class_name StaminaMonitor
extends Node

var tracked_creatures: Array[CreatureData] = []

func _ready():
    var bus = GameCore.get_signal_bus()
    bus.creature_exhausted.connect(_on_exhaustion)
    bus.stamina_depleted.connect(_on_depletion)

func _on_exhaustion(creature: CreatureData):
    if creature in tracked_creatures:
        auto_rest(creature)

func auto_rest(creature: CreatureData):
    var stamina_system = GameCore.get_system("stamina")
    stamina_system.assign_activity(creature, StaminaSystem.Activity.REST)
    print("Auto-assigned REST to exhausted %s" % creature.creature_name)
```

## Testing

### Test Coverage
- Basic stamina operations (get/set/deplete/restore)
- Activity assignment and validation
- Weekly activity processing
- Exhaustion detection and recovery
- Modifier application
- Food effects
- Save/load persistence
- Performance benchmarks

### Test File
`tests/individual/test_stamina.tscn` - Comprehensive stamina system tests

## Migration Notes

### From Passive System (Old)
```gdscript
# Old: Automatic weekly stamina loss
# Active creatures lost 5 stamina per week
# Stable creatures gained 10 stamina per week

# New: Activity-based only
# No automatic changes
# Must assign activities for any stamina change
```

### Migration Steps
1. Remove any code expecting passive stamina changes
2. Implement activity assignment logic
3. Update UI to show assigned activities
4. Add activity selection interface for players

## Key Design Principles

1. **No Passive Changes**: Stamina only changes through assigned activities
2. **Player Agency**: Players control creature activities
3. **Strategic Planning**: Balance work activities with rest
4. **Clear Feedback**: Exhaustion states clearly communicated
5. **Performance**: Batch processing for efficiency

## Important Notes

⚠️ **Breaking Change**: The stamina system no longer applies automatic weekly stamina changes. All stamina changes must come from assigned activities.

⚠️ **Activity Assignment Required**: Creatures at IDLE will maintain their current stamina indefinitely.

⚠️ **Exhaustion Prevention**: Monitor creature stamina and assign REST activities before exhaustion occurs.