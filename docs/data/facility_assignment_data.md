# FacilityAssignmentData Documentation

## Overview

`FacilityAssignmentData` represents the assignment of a creature to a specific training facility with a selected activity and optional food enhancement. This data class enables persistent tracking of training assignments between sessions.

## Location
- **Script**: `scripts/data/facility_assignment_data.gd`

## Purpose

This class serves as a data container for:
- Linking creatures to specific training facilities
- Storing selected training activities for each assignment
- Tracking food type selection for training enhancement
- Providing validation for assignment completeness

## Properties

### Assignment Identifiers
- **facility_id** (String): ID of the target training facility (default: "")
- **creature_id** (String): ID of the assigned creature (default: "")

### Training Configuration
- **selected_activity** (int): TrainingActivity enum value (-1 = unassigned)
- **food_type** (int): FoodType enum value (-1 = no food)

## Methods

### Validation
```gdscript
func is_valid() -> bool
```
Quick validation check for assignment completeness:
- facility_id is non-empty
- creature_id is non-empty
- selected_activity is valid (≥0)
- food_type is valid (≥0)

```gdscript
func validate() -> Dictionary
```
Comprehensive validation returning `{valid: bool, errors: Array[String]}`:
- All is_valid() checks
- selected_activity within TrainingActivity range (0-3)
- Detailed error messages for each validation failure

### Utility Methods
```gdscript
func get_activity_name() -> String
```
Returns human-readable name for the selected training activity:
- "Physical Training" (0)
- "Agility Training" (1)
- "Mental Training" (2)
- "Discipline Training" (3)
- "Unknown Activity" (invalid)

```gdscript
func clear() -> void
```
Resets assignment to default/empty state:
- facility_id = ""
- creature_id = ""
- selected_activity = -1
- food_type = -1

## Training Activity Integration

Activities correspond to TrainingSystem enum values:

| Value | Activity | Target Stats |
|-------|----------|-------------|
| 0 | Physical Training | Strength, Constitution |
| 1 | Agility Training | Dexterity |
| 2 | Mental Training | Intelligence, Wisdom |
| 3 | Discipline Training | Discipline |

## Food Type Integration

Food types enhance training effectiveness (from FoodSystem):

| Value | Food Item | Enhanced Activity |
|-------|-----------|------------------|
| 0 | power_bar | Physical Training |
| 1 | speed_snack | Agility Training |
| 2 | brain_food | Mental Training |
| 3 | focus_tea | Discipline Training |

## Usage Patterns

### Creating Assignment
```gdscript
var assignment = FacilityAssignmentData.new()
assignment.facility_id = "gym"
assignment.creature_id = "creature_123"
assignment.selected_activity = 0  # Physical training
assignment.food_type = 0  # Power bar
```

### Validation Before Processing
```gdscript
if assignment.is_valid():
    # Process training assignment
    process_training(assignment)
else:
    print("Invalid assignment configuration")
```

### Detailed Validation
```gdscript
var validation = assignment.validate()
if not validation.valid:
    for error in validation.errors:
        push_error("Assignment error: " + error)
```

### Clearing Assignment
```gdscript
# Reset to empty state
assignment.clear()
```

## State Transitions

### Valid States
1. **Empty**: All fields at default values (-1, "")
2. **Partial**: Some fields set, validation may fail
3. **Complete**: All required fields set, passes validation

### State Flow
```
Empty → Partial → Complete
  ↑                   ↓
  ← ← ← ← ← ← ← ← ← Clear
```

## Integration Points

### Training System
- selected_activity must match TrainingSystem.TrainingActivity enum
- Used to configure training sessions

### Food System
- food_type integrates with FoodSystem for effectiveness bonuses
- -1 indicates no food enhancement

### Facility System
- facility_id references FacilityResource instances
- Validates against available facilities

### Creature System
- creature_id references CreatureData instances
- Links training to specific creatures

## Validation Rules

1. **Non-empty Strings**: facility_id and creature_id must be set
2. **Valid Activity**: selected_activity must be 0-3 (TrainingActivity range)
3. **Valid Food**: food_type must be ≥0 or -1 (no food)
4. **Completeness**: All fields must be properly set for valid assignment

## Persistence Considerations

As a Resource class, FacilityAssignmentData can be:
- Saved to `.tres` files for persistent storage
- Serialized with game save data
- Passed between systems as a complete assignment package

## Error Handling

Invalid assignments should:
- Log specific validation errors
- Prevent training session creation
- Provide clear feedback for correction

## Extension Guidelines

When extending assignment data:

1. Add new properties with sensible defaults
2. Update validation methods for new fields
3. Maintain backward compatibility
4. Document new properties and their purpose
5. Update integration systems that consume assignments