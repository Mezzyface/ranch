# Training System API

The TrainingSystem manages creature training activities through activity-based architecture, integrating with the StaminaSystem for weekly activity processing.

## Overview

- **System Key**: `training`
- **File**: `scripts/systems/training_system.gd`
- **UI Controller**: `scripts/ui/training_panel_controller.gd`
- **UI Scene**: `scenes/ui/panels/training_panel.tscn`
- **Test**: `tests/individual/test_training.tscn`
- **Architecture**: Activity-based (responds to StaminaSystem events)

## Core Features

### Training Activities
- **Physical Training**: Targets STR, CON (5-15 base gains)
- **Agility Training**: Targets DEX (5-15 base gains)
- **Mental Training**: Targets INT, WIS (5-15 base gains)
- **Discipline Training**: Targets DIS (5-15 base gains)

### Facility Tiers
- **Basic**: 1.0x multiplier, 10 slots per activity
- **Advanced**: 1.5x multiplier, 5 slots per activity
- **Elite**: 2.0x multiplier, 2 slots per activity

### Training Facilities (via FacilityResource system)
- **Gym**: Supports Physical & Agility training (unlocked by default)
- **Library**: Supports Mental & Discipline training (500 gold unlock cost)
- **Custom facilities**: Defined via data/facilities/*.tres files

### Training Foods (50% effectiveness boost for 4 weeks)
- **Power Bar**: Enhances physical training
- **Speed Snack**: Enhances agility training
- **Brain Food**: Enhances mental training
- **Focus Tea**: Enhances discipline training

## API Methods

### Core Training
```gdscript
# Schedule training for a creature (assigns TRAINING activity to StaminaSystem)
func schedule_training(creature: CreatureData, activity: TrainingActivity, facility_tier: FacilityTier = FacilityTier.BASIC, food_type: int = -1) -> Dictionary

# Cancel training assignment for a creature
func cancel_training(creature_id: String) -> bool

# Batch schedule multiple trainings
func batch_schedule_training(training_requests: Array[Dictionary]) -> Dictionary
```

### Status & Information
```gdscript
# Get training status for a creature
func get_training_status(creature_id: String) -> Dictionary

# Get current training assignments
func get_training_assignments() -> Dictionary

# Get facility utilization info
func get_facility_utilization() -> Dictionary

# Get completed trainings from this week
func get_completed_trainings() -> Array[Dictionary]
```

### Utility Methods
```gdscript
# Get activity display name
func get_activity_name(activity: TrainingActivity) -> String

# Get facility display name
func get_facility_name(facility_tier: FacilityTier) -> String

# Check if creature is currently training
func is_creature_in_training(creature_id: String) -> bool
```

## GameController Integration

Access training through GameController for proper MVC architecture:

```gdscript
# Get training system data
var training_data = game_controller.get_training_data()

# Schedule creature training
var result = game_controller.schedule_creature_training(creature_id, activity, facility_tier, food_type)

# Get creature training status
var status = game_controller.get_creature_training_status(creature_id)

# Cancel creature training
var success = game_controller.cancel_creature_training(creature_id)

# Get food inventory
var food_inventory = game_controller.get_food_inventory()
```

## UI Components

### Training Panel Structure
- **Facilities Panel**: Shows facility types, tiers, and capacity
- **Assignment Panel**: Creature selection, food selection, activity buttons
- **Assignments Panel**: Shows current training assignments
- **Progress Panel**: Shows completed trainings with stat gains

### UI Controls
- **Creature Dropdown**: OptionButton for creature selection
- **Training Food Buttons**: Toggle selection (not immediate consumption)
- **Activity Buttons**: Physical, Agility, Mental, Discipline
- **Schedule Button**: Confirms training assignment

## Data Structures

### Training Assignment
```gdscript
{
    "activity": TrainingActivity,
    "facility_tier": FacilityTier,
    "food_type": int   # -1 for none, 0-3 for food types
}
```

### Training Completion Record
```gdscript
{
    "creature_id": String,
    "creature_name": String,
    "activity": TrainingActivity,
    "facility_tier": FacilityTier,
    "stat_gains": Dictionary,  # {"strength": 7, "constitution": 6}
    "week": int
}
```

## Integration Points

### StaminaSystem (Activity-Based Architecture)
- Training assigns TRAINING activity to StaminaSystem
- Training costs 10 stamina per session (Activity.TRAINING)
- Stamina checked before scheduling
- Training executed when StaminaSystem processes weekly activities
- TrainingSystem responds to `stamina_activity_performed` signal

### FoodSystem / ItemManager
- Food items consumed when training is assigned (immediate consumption)
- Food provides 50% effectiveness boost for stat gains
- Items: power_bar, speed_snack, brain_food, focus_tea

### TimeSystem
- Training duration: 1 week (immediate completion)
- Processing triggered by StaminaSystem weekly activity processing
- No queue management - activity-based execution

### SignalBus Events
- `training_scheduled`: When training assignment is made
- `training_completed`: When training finishes with stat gains
- `stamina_activity_performed`: Triggers training execution

## Performance Targets

- **Batch Operations**: 100 trainings scheduled in <100ms
- **Activity Processing**: Training completion in <50ms
- **Current Performance**: ~0ms for activity processing (well under target)

## Testing

Run training system tests:
```bash
godot --headless --scene tests/individual/test_training.tscn
```

Tests cover:
- ✅ Training scheduling and cancellation
- ✅ Facility tier system and capacity limits
- ✅ Weekly processing and progression
- ✅ Batch operations and performance
- ✅ StaminaSystem integration
- ✅ Save/load functionality

## Usage Examples

### Schedule Physical Training with Power Bar
```gdscript
var game_controller = GameCore.get_game_controller()
var result = game_controller.schedule_creature_training(
    "creature_001",
    TrainingSystem.TrainingActivity.PHYSICAL,
    TrainingSystem.FacilityTier.BASIC,
    0  # Power Bar food type
)
```

### Check Training Status
```gdscript
var status = game_controller.get_creature_training_status("creature_001")
# Returns: {"status": "scheduled", "activity": "Physical Training", ...}
```

### Process Weekly Training (automatic via TimeSystem)
```gdscript
# Called automatically when week advances
# - Moves scheduled → active trainings
# - Completes active trainings
# - Consumes food items
# - Applies stat gains with multipliers
```