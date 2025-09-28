# FacilitySystem API Documentation

## Overview

The `FacilitySystem` manages training facilities where creatures can be assigned for various training activities. It handles facility unlocking, creature assignments, resource management, and persistence of facility states.

## Location
- **Script**: `scripts/systems/facility_system.gd`
- **System Key**: `"facility"`
- **Class Name**: `FacilitySystem`

## Dependencies

- **ResourceTracker**: For gold spending and validation
- **PlayerCollection**: For creature existence validation
- **SignalBus**: For event emission
- **FacilityResource**: Resource class for facility definitions
- **FacilityAssignmentData**: Data class for assignment tracking

## Core Responsibilities

1. **Facility Management**: Load and manage facility resources from data files
2. **Unlock System**: Handle gold-based facility unlocking
3. **Assignment Tracking**: Manage creature-to-facility assignments
4. **Resource Integration**: Validate gold costs and food requirements
5. **State Persistence**: Save/load facility unlock status and assignments

## Public API

### Facility Access

#### get_all_facilities()
```gdscript
func get_all_facilities() -> Array[FacilityResource]
```
Returns all facility resources (both locked and unlocked).

**Returns**: Array of FacilityResource objects
**Side Effects**: None
**Usage**: Displaying all facilities in UI, including locked ones

#### get_unlocked_facilities()
```gdscript
func get_unlocked_facilities() -> Array[FacilityResource]
```
Returns only unlocked facilities available for use.

**Returns**: Array of unlocked FacilityResource objects
**Side Effects**: None
**Usage**: Showing available facilities for creature assignment

#### get_facility()
```gdscript
func get_facility(facility_id: String) -> FacilityResource
```
Retrieves a specific facility by ID.

**Parameters**:
- `facility_id`: Unique facility identifier

**Returns**: FacilityResource or null if not found
**Side Effects**: None
**Usage**: Getting specific facility data for UI or validation

### Unlock Management

#### is_facility_unlocked()
```gdscript
func is_facility_unlocked(facility_id: String) -> bool
```
Checks if a facility is currently unlocked.

**Parameters**:
- `facility_id`: Facility to check

**Returns**: true if unlocked, false otherwise
**Side Effects**: None
**Usage**: Conditional UI display, assignment validation

#### unlock_facility()
```gdscript
func unlock_facility(facility_id: String) -> bool
```
Attempts to unlock a facility by spending gold.

**Parameters**:
- `facility_id`: Facility to unlock

**Returns**: true if successfully unlocked, false on failure
**Side Effects**:
- Deducts gold via ResourceTracker
- Emits `facility_unlocked` signal
- Updates unlock status

**Validation**:
- Facility must exist
- Must not already be unlocked
- Player must have sufficient gold
- ResourceTracker must be available

**Usage**: Processing facility purchase requests

### Assignment Management

#### assign_creature()
```gdscript
func assign_creature(facility_id: String, creature_id: String, activity: int, food_type: int) -> bool
```
Assigns a creature to a facility with specified training activity and food.

**Parameters**:
- `facility_id`: Target facility identifier
- `creature_id`: Creature to assign
- `activity`: TrainingActivity enum value (0-3)
- `food_type`: FoodType enum value (-1 for none)

**Returns**: true if assignment successful, false on failure
**Side Effects**:
- Creates assignment record
- Emits `creature_assigned_to_facility` signal

**Validation**:
- Facility must exist and be unlocked
- Activity must be supported by facility
- Creature must exist in PlayerCollection
- Creature cannot already be assigned elsewhere
- Facility cannot already have a creature assigned

**Usage**: Processing training assignment requests

#### remove_creature()
```gdscript
func remove_creature(facility_id: String) -> bool
```
Removes creature assignment from a facility.

**Parameters**:
- `facility_id`: Facility to clear

**Returns**: true if removal successful, false if no assignment exists
**Side Effects**:
- Clears assignment record
- Emits `facility_assignment_removed` signal

**Usage**: Canceling training assignments

#### get_assignment()
```gdscript
func get_assignment(facility_id: String) -> FacilityAssignmentData
```
Retrieves assignment data for a facility.

**Parameters**:
- `facility_id`: Facility to query

**Returns**: FacilityAssignmentData or null if no assignment
**Side Effects**: None
**Usage**: Displaying current assignments in UI

#### get_creature_facility()
```gdscript
func get_creature_facility(creature_id: String) -> String
```
Finds which facility a creature is assigned to.

**Parameters**:
- `creature_id`: Creature to search for

**Returns**: facility_id if assigned, empty string if not assigned
**Side Effects**: None
**Usage**: Checking creature assignment status

### Resource Validation

#### has_food_for_all_facilities()
```gdscript
func has_food_for_all_facilities() -> bool
```
Checks if all assigned facilities have required food available.

**Returns**: true if all food requirements met, false otherwise
**Side Effects**: None
**Usage**: Pre-validation before weekly training processing

**Food Mapping**:
- `power_bar` (0): Physical training enhancement
- `speed_snack` (1): Agility training enhancement
- `brain_food` (2): Mental training enhancement
- `focus_tea` (3): Discipline training enhancement

## Signals Emitted

### facility_unlocked
```gdscript
signal facility_unlocked(facility_id: String)
```
Emitted when a facility is successfully unlocked.

### creature_assigned_to_facility
```gdscript
signal creature_assigned_to_facility(creature_id: String, facility_id: String, activity: int, food_type: int)
```
Emitted when a creature is assigned to a facility.

### facility_assignment_removed
```gdscript
signal facility_assignment_removed(facility_id: String, creature_id: String)
```
Emitted when a creature assignment is removed from a facility.

## Data Structures

### Facility Assignment Structure
```gdscript
# Stored as FacilityAssignmentData with properties:
{
    facility_id: String,      # Target facility
    creature_id: String,      # Assigned creature
    selected_activity: int,   # TrainingActivity enum (0-3)
    food_type: int           # FoodType enum (-1 for none)
}
```

### Unlock Status Structure
```gdscript
# Internal tracking:
facility_unlock_status = {
    "facility_id": bool,  # true = unlocked, false = locked
    # ...
}
```

## Training Activity Integration

The system integrates with TrainingSystem activities:

| Activity Value | Name | Target Stats |
|---------------|------|-------------|
| 0 | PHYSICAL | Strength, Constitution |
| 1 | AGILITY | Dexterity |
| 2 | MENTAL | Intelligence, Wisdom |
| 3 | DISCIPLINE | Discipline |

## Built-in Facilities

### Gym (Free)
- **ID**: "gym"
- **Activities**: Physical (0), Agility (1)
- **Cost**: 0 gold (free)
- **Default**: Unlocked

### Library (Premium)
- **ID**: "library"
- **Activities**: Mental (2), Discipline (3)
- **Cost**: 500 gold
- **Default**: Locked

## Save/Load Support

The FacilitySystem implements comprehensive save/load functionality with validation, versioning, and automatic cleanup of orphaned data.

### save_state()
```gdscript
func save_state() -> Dictionary
```
Saves complete facility system state with validation and versioning.

**Returns**: Dictionary containing versioned facility state
**Structure**:
```gdscript
{
    "version": 1,                           # Save format version for migration
    "unlocked_facilities": Array[String],   # Array of unlocked facility IDs
    "facility_assignments": Dictionary,     # facility_id -> assignment_data
    "facility_unlock_status": Dictionary    # Legacy compatibility - facility_id -> bool
}
```

**Features**:
- Version number for future migration support
- Compact array format for unlocked facilities
- Full assignment data preservation
- Legacy format compatibility

### load_state()
```gdscript
func load_state(data: Dictionary) -> void
```
Loads facility system state with comprehensive validation and cleanup.

**Parameters**:
- `data`: Dictionary from save_state() or legacy format

**Validation & Cleanup**:
- **Missing Data**: Handles empty/missing save data gracefully
- **Version Migration**: Supports loading older save formats
- **Creature Validation**: Verifies assigned creatures still exist in PlayerCollection
- **Facility Validation**: Ensures referenced facilities still exist in registry
- **Orphaned Assignment Cleanup**: Automatically removes assignments for missing creatures
- **Logging**: Reports all cleanup actions and data issues

**Error Handling**:
- Fail-safe: Invalid data results in clean defaults, not crashes
- Comprehensive logging of all validation failures
- Automatic cleanup with detailed warnings

### Legacy Support

#### get_save_data()
```gdscript
func get_save_data() -> Dictionary
```
Legacy save method - delegates to save_state() for compatibility.

#### load_save_data()
```gdscript
func load_save_data(data: Dictionary) -> void
```
Legacy load method - delegates to load_state() for compatibility.

### ISaveable Interface

The FacilitySystem implements the ISaveable interface pattern:

#### get_save_namespace()
```gdscript
func get_save_namespace() -> String
```
Returns "facility_system" as the unique namespace for save data.

### SaveSystem Integration

The FacilitySystem is fully integrated with the central SaveSystem:

1. **Automatic Save**: Facility state is automatically saved during `SaveSystem.save_game_state()`
2. **Automatic Load**: Facility state is automatically restored during `SaveSystem.load_game_state()`
3. **Error Handling**: Follows SaveSystem patterns for error reporting and recovery
4. **Performance**: Facility save/load operations are included in SaveSystem timing metrics

### Migration Support

The system supports migrating between save format versions:

- **Version 1**: Current format with versioned data and array-based unlock tracking
- **Legacy**: Original dictionary-based format (automatically migrated)
- **Future**: Framework in place for additional migrations as needed

### Data Integrity Validation

During load operations, the system performs extensive validation:

1. **Creature Existence**: Validates all assigned creatures exist in PlayerCollection
2. **Facility Registry**: Ensures all referenced facilities exist in the facility registry
3. **Assignment Structure**: Validates FacilityAssignmentData integrity
4. **Activity Support**: Verifies activities are still supported by facilities

### Cleanup Behavior

When orphaned data is detected during load:

- **Orphaned Assignments**: Removed with warning logged
- **Missing Creatures**: Assignment automatically cleared
- **Invalid Facilities**: References removed from assignments
- **Cleanup Summary**: Total cleanup actions reported in logs

## Usage Patterns

### Basic Facility Listing
```gdscript
var facility_system = GameCore.get_system("facility")
var all_facilities = facility_system.get_all_facilities()
var unlocked = facility_system.get_unlocked_facilities()

for facility in unlocked:
    print("Available: ", facility.display_name)
```

### Unlocking Facility
```gdscript
var facility_system = GameCore.get_system("facility")
if facility_system.unlock_facility("library"):
    print("Library unlocked!")
else:
    print("Cannot unlock library")
```

### Creature Assignment
```gdscript
var facility_system = GameCore.get_system("facility")
var success = facility_system.assign_creature(
    "gym",           # facility_id
    "creature_123",  # creature_id
    0,              # Physical training
    0               # Power bar food
)
if success:
    print("Creature assigned for training")
```

### Assignment Status Check
```gdscript
var facility_system = GameCore.get_system("facility")
var assignment = facility_system.get_assignment("gym")
if assignment:
    print("Creature %s training %s" % [assignment.creature_id, assignment.get_activity_name()])
```

## Error Handling

The system uses fail-fast validation with explicit error logging:

### Common Error Cases
- **Unknown facility**: Invalid facility_id provided
- **Already unlocked**: Attempting to unlock an already unlocked facility
- **Insufficient funds**: Not enough gold for facility unlock
- **Invalid activity**: Activity not supported by facility
- **Creature not found**: Invalid creature_id provided
- **Double assignment**: Creature already assigned elsewhere
- **Facility occupied**: Facility already has creature assigned

### Error Response Pattern
```gdscript
if not facility_system.assign_creature(facility_id, creature_id, activity, food_type):
    # Check specific error via push_error() logs
    # UI should display appropriate error message
```

## Weekly Update Integration

### Food Validation Flow

The FacilitySystem integrates with the WeeklyUpdateOrchestrator to create a hard stop mechanism when food is missing:

1. **Pre-Validation**: `WeeklyUpdateOrchestrator.execute_weekly_update()` calls `has_food_for_all_facilities()` before any processing
2. **Hard Stop**: If food validation fails, emits `week_advance_blocked("Missing food for facilities")` signal
3. **Error Return**: Returns `{success: false, reason: "Missing food for facilities", processed_facilities: 0}`
4. **No State Changes**: Week does not advance; no aging, training, or other updates occur

### Facility Processing Phase

During successful weekly updates, facilities are processed in the new FACILITIES phase:

1. **Food Consumption**: Consumes assigned food via ResourceTracker.remove_item()
2. **Training Delegation**: Calls TrainingSystem.schedule_training() for stat gains
3. **Dead Creature Handling**: Skips creatures in expired_creature_ids list
4. **Result Tracking**: Builds training results for summary

### Dead Creature Cleanup

After the aging phase, the WeeklyUpdateOrchestrator automatically:

1. **Detection**: Identifies creatures that died during aging
2. **Facility Cleanup**: Calls `remove_creature(facility_id)` for any dead creatures in facilities
3. **Automatic**: No manual intervention required; happens every week

### Player Response Required

When week advance is blocked, players must take action:

- **Provide Food**: Add required food items to inventory
- **Remove Creatures**: Unassign creatures from facilities that lack food
- **Clear Assignments**: Remove all facility assignments

### Integration Signals

- **Emits**: `week_advance_blocked(reason: String)` when validation fails
- **Listens**: No signals (read-only during validation)
- **Uses**: Existing facility assignment signals during processing

## Performance Characteristics

- **Facility Loading**: O(n) where n = number of .tres files
- **Assignment Lookup**: O(1) dictionary access
- **Creature Search**: O(n) where n = number of assignments
- **Validation**: O(1) for most checks

## UI Integration

### FacilityCard Component

The FacilitySystem is designed to work seamlessly with the `FacilityCard` UI component (`scenes/ui/components/facility_card.tscn`):

#### Component Setup
```gdscript
# Load facility data into card
var facility_system = GameCore.get_system("facility")
var facility = facility_system.get_facility("gym")
facility_card.set_facility(facility)

# Update assignment if creature is assigned
var assignment = facility_system.get_assignment("gym")
if assignment:
    facility_card.set_assignment(assignment)
```

#### Signal Integration
```gdscript
# Connect facility card signals to system operations
facility_card.assign_pressed.connect(_on_assign_creature_to_facility)
facility_card.remove_pressed.connect(_on_remove_creature_from_facility)
facility_card.unlock_pressed.connect(_on_unlock_facility)

func _on_assign_creature_to_facility(facility_id: String):
    # Show creature selection dialog, then:
    facility_system.assign_creature(facility_id, selected_creature_id, activity, food_type)

func _on_remove_creature_from_facility(facility_id: String):
    facility_system.remove_creature(facility_id)

func _on_unlock_facility(facility_id: String):
    facility_system.unlock_facility(facility_id)
```

#### Visual State Management
The FacilityCard automatically handles four visual states based on system data:
- **Locked**: Displays unlock cost and grayed appearance
- **Empty**: Shows "Assign" button and empty placeholder
- **Occupied**: Shows creature portrait, activity, and food information
- **No Food Warning**: Animated red border when required food is missing

#### Food Warning Integration
```gdscript
# Update food warnings based on resource availability
func update_facility_cards():
    for facility_card in facility_cards:
        var facility_id = facility_card.get_facility_id()
        var assignment = facility_system.get_assignment(facility_id)
        if assignment:
            var has_food = facility_system.has_food_for_facility(facility_id)
            facility_card.set_food_warning(not has_food)
```

## Integration Points

### TrainingSystem
- Activities must match TrainingSystem.TrainingActivity enum
- Assignments feed into training session creation

### ResourceTracker
- Gold validation and spending for facility unlocks
- Food availability checking for assignments

### PlayerCollection
- Creature existence validation
- Integration with creature management

### FoodSystem
- Food type validation and consumption
- Training effectiveness enhancement

## Extension Guidelines

### Adding New Facilities
1. Create `.tres` file in `data/facilities/`
2. Use unique facility_id
3. Set appropriate unlock cost and activities
4. Test validation and unlocking

### Adding New Features
1. Maintain backward compatibility with save data
2. Follow fail-fast validation patterns
3. Emit appropriate signals for UI updates
4. Update documentation and interfaces

## Validation Rules

1. **Facility Resources**: Must pass `is_valid()` check on load
2. **Assignments**: Must pass FacilityAssignmentData validation
3. **Gold Transactions**: Validated through ResourceTracker
4. **Activity Support**: Facilities must support assigned activities
5. **Single Assignment**: One creature per facility, one facility per creature

## Thread Safety

The FacilitySystem is designed for single-threaded use within Godot's main thread. All operations should be performed on the main thread to avoid race conditions with UI updates and signal emission.