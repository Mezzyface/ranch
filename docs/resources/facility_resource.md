# FacilityResource Documentation

## Overview

`FacilityResource` defines training facilities that creatures can use to improve their stats through various training activities. This resource-based system allows for data-driven facility management with proper validation and integration with the existing training system.

## Location
- **Script**: `scripts/resources/facility_resource.gd`
- **Data Files**: `data/facilities/*.tres`

## Properties

### Core Identity
- **facility_id** (String): Unique identifier for the facility
- **display_name** (String): Human-readable name displayed in UI
- **description** (String): Longer description of facility capabilities
- **icon_path** (String): Path to facility icon asset

### Unlock Mechanics
- **unlock_cost** (int): Gold cost required to unlock facility (default: 0)
- **is_unlocked** (bool): Current unlock status (default: false)

### Training Configuration
- **supported_activities** (Array[int]): List of TrainingActivity enum values this facility supports
- **max_creatures** (int): Maximum number of creatures that can use this facility simultaneously (default: 1)

## Methods

### Validation
```gdscript
func is_valid() -> bool
```
Quick validation check for basic requirements:
- facility_id is non-empty
- display_name is non-empty
- max_creatures is positive

```gdscript
func validate() -> Dictionary
```
Comprehensive validation returning `{valid: bool, errors: Array[String]}`:
- All is_valid() checks
- unlock_cost is non-negative
- supported_activities is not empty
- Activity values are within range 0-3

### Activity Support
```gdscript
func supports_activity(activity: int) -> bool
```
Check if facility supports a specific TrainingActivity enum value.

```gdscript
func get_activity_names() -> Array[String]
```
Get human-readable names for all supported activities.

## Training Activity Integration

Facilities integrate with the existing TrainingSystem activity enum:

| Enum Value | Activity | Stats Targeted |
|------------|----------|---------------|
| 0 | PHYSICAL | Strength, Constitution |
| 1 | AGILITY | Dexterity |
| 2 | MENTAL | Intelligence, Wisdom |
| 3 | DISCIPLINE | Discipline |

## Resource File Format

Facilities are defined as Godot `.tres` resources:

```tres
[gd_resource type="Resource" script_class="FacilityResource" load_steps=2 format=3 uid="uid://..."]

[ext_resource type="Script" path="res://scripts/resources/facility_resource.gd" id="1_facility"]

[resource]
script = ExtResource("1_facility")
facility_id = "gym"
display_name = "Training Gym"
description = "Train strength and agility"
icon_path = ""
unlock_cost = 0
is_unlocked = true
supported_activities = Array[int]([0, 1])
max_creatures = 1
```

## Built-in Facilities

### Gym
- **ID**: "gym"
- **Activities**: Physical (0), Agility (1)
- **Unlock Cost**: 0 (free)
- **Default Status**: Unlocked

### Library
- **ID**: "library"
- **Activities**: Mental (2), Discipline (3)
- **Unlock Cost**: 500 gold
- **Default Status**: Locked

## Usage Patterns

### Loading Facilities
```gdscript
var facility = load("res://data/facilities/gym.tres") as FacilityResource
if facility and facility.is_valid():
    print("Loaded facility: ", facility.display_name)
```

### Validation Before Use
```gdscript
var validation = facility.validate()
if not validation.valid:
    push_error("Invalid facility: " + str(validation.errors))
    return
```

### Activity Checking
```gdscript
if facility.supports_activity(TrainingSystem.TrainingActivity.PHYSICAL):
    print("Can train physical stats here")
```

## Integration Points

### TrainingSystem
- Facilities define which training activities are available
- Activity enum values must match TrainingSystem.TrainingActivity

### Economy System
- unlock_cost integrates with ResourceTracker for facility purchases
- is_unlocked status controls availability

### UI System
- display_name and description for facility selection interfaces
- icon_path for visual representation
- get_activity_names() for user-friendly activity lists

## Validation Rules

1. **Required Fields**: facility_id and display_name must be non-empty
2. **Positive Values**: max_creatures must be greater than 0
3. **Non-negative**: unlock_cost cannot be negative
4. **Activity Range**: supported_activities values must be 0-3
5. **Non-empty Activities**: supported_activities array cannot be empty

## Extension Guidelines

When adding new facilities:

1. Create new `.tres` file in `data/facilities/`
2. Use unique facility_id
3. Ensure supported_activities match existing TrainingActivity enum
4. Set appropriate unlock_cost and default unlock status
5. Validate using `validate()` method before deployment

When extending the system:

1. New properties should have sensible defaults
2. Update validation rules in both `is_valid()` and `validate()`
3. Maintain backward compatibility with existing `.tres` files
4. Document new properties in this file