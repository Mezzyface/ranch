# TimeSystem API Reference

## Overview

The TimeSystem provides weekly-based time progression for the game, handling creature aging, event scheduling, and system coordination.

**Important**: Time progression now uses the WeeklyUpdateOrchestrator for all weekly updates to prevent duplicate aging and ensure proper system coordination. The legacy aging event system has been replaced.

## Core Components

### TimeSystem (`scripts/systems/time_system.gd`)

Main time management system with weekly progression and event handling.

#### Key Properties
```gdscript
current_week: int        # Current week (1-52)
current_month: int       # Current month (1-13)
current_year: int        # Current year (starts at 1)
total_weeks_elapsed: int # Total weeks since game start
```

#### Core Methods

##### Time Progression
```gdscript
advance_week() -> bool
# Advance time by one week with full event processing
# Returns: true if successful, false if blocked

advance_weeks(count: int) -> bool
# Advance time by multiple weeks
# Returns: true if all weeks processed successfully

advance_to_week(target_week: int) -> bool
# Advance to specific absolute week number
# Returns: true if target reached
```

##### Event Management
```gdscript
schedule_event(event: WeeklyEvent, week: int) -> void
# Schedule an event for a specific week
# week: absolute week number (must be > total_weeks_elapsed)

cancel_event(event_id: String) -> bool
# Cancel a scheduled event by ID
# Returns: true if event found and cancelled
```

##### Time Queries
```gdscript
get_current_date_string() -> String
# Returns: "Year X, Month Y, Week Z"

get_weeks_until(target_week: int) -> int
# Returns: weeks remaining until target

can_advance_time() -> Dictionary
# Returns: {"can_advance": bool, "reasons": Array[String]}
```

##### State Management
```gdscript
save_time_state() -> Dictionary
# Export current time state for persistence

load_time_state(data: Dictionary) -> void
# Restore time state from saved data
```

##### Debug Functions
```gdscript
set_debug_mode(enabled: bool) -> void
# Enable/disable debug output

debug_advance_weeks(count: int) -> void
# Debug-only: advance time without validation

debug_set_week(week: int) -> void
# Debug-only: set absolute week
```

### WeeklyEvent (`scripts/core/weekly_event.gd`)

Represents scheduled events that trigger on specific weeks.

#### Event Types
```gdscript
enum EventType {
    CREATURE_AGING,     # Age all active creatures
    STAMINA_DEPLETION,  # Process stamina loss
    FOOD_CONSUMPTION,   # Handle food consumption
    QUEST_DEADLINE,     # Check quest deadlines
    COMPETITION_START,  # Start competitions
    SHOP_REFRESH,       # Refresh shop inventory
    CUSTOM              # Custom event logic
}
```

#### Key Properties
```gdscript
event_id: String           # Unique identifier
event_type: EventType      # Type of event
event_name: String         # Display name
trigger_week: int          # Week to trigger (-1 for recurring)
is_recurring: bool         # If event repeats
recurrence_interval: int   # Weeks between recurrences
priority: int              # Execution order (lower = first)
```

#### Methods
```gdscript
is_valid() -> bool
# Validate event configuration

execute() -> void
# Execute the event (calls type-specific handler)

can_execute() -> bool
# Check if event can run (dependencies available)
```

### TimeData (`scripts/data/time_data.gd`)

Resource class for time state persistence.

#### Properties
```gdscript
week: int            # Current week
month: int           # Current month
year: int            # Current year
total_weeks: int     # Total elapsed weeks
last_save_week: int  # Week of last save
```

#### Methods
```gdscript
is_valid() -> bool
# Validate time data

to_dict() -> Dictionary
# Convert to serializable format

from_dict(data: Dictionary) -> void
# Load from serialized data

get_formatted_date() -> String
# Returns formatted date string
```

## Signal Integration

### TimeSystem Signals

All time signals are emitted through SignalBus:

```gdscript
# Week progression
signal week_advanced(new_week: int, total_weeks: int)
signal month_completed(month: int, year: int)
signal year_completed(year: int)

# Event system
signal weekly_event_triggered(event: WeeklyEvent)
signal weekly_update_started()
signal weekly_update_completed(duration_ms: int)

# Error handling
signal time_advance_blocked(reasons: Array[String])
```

### Signal Usage Examples

```gdscript
var bus = GameCore.get_signal_bus()

# Listen for week changes
bus.week_advanced.connect(_on_week_advanced)

# Listen for year transitions
bus.year_completed.connect(_on_year_completed)

# Monitor update performance
bus.weekly_update_completed.connect(_on_update_completed)
```

## System Integration

### WeeklyUpdateOrchestrator Integration

TimeSystem now uses the WeeklyUpdateOrchestrator for all weekly updates:

```gdscript
# TimeSystem delegates to orchestrator for all updates
func _trigger_system_updates() -> void:
    if weekly_orchestrator:
        var result = weekly_orchestrator.execute_weekly_update()
        # Orchestrator handles aging, stamina, food, economy, etc.
    else:
        # Fallback system (aging excluded to prevent duplication)
        push_warning("WeeklyUpdateOrchestrator not available")
```

### SaveSystem Integration

TimeSystem state is automatically saved/loaded:

```gdscript
# SaveSystem handles TimeSystem persistence
var time_system = GameCore.get_system("time")
var time_state = time_system.save_time_state()

# State includes: week, month, year, total_weeks, scheduled_events
```

## Usage Patterns

### Basic Time Progression

```gdscript
var time_system = GameCore.get_system("time")

# Manual advancement
if time_system.advance_week():
    print("Week advanced successfully")
else:
    print("Time advancement blocked")

# Bulk advancement
time_system.advance_weeks(4)  # Advance one month
```

### Event Scheduling

```gdscript
var time_system = GameCore.get_system("time")

# Create custom event
var event = WeeklyEvent.new()
event.event_id = "shop_refresh"
event.event_type = WeeklyEvent.EventType.SHOP_REFRESH
event.event_name = "Weekly Shop Refresh"

# Schedule for specific week
var target_week = time_system.total_weeks_elapsed + 7
time_system.schedule_event(event, target_week)

# Create recurring event
var recurring_event = WeeklyEvent.new()
recurring_event.event_id = "monthly_competition"
recurring_event.event_type = WeeklyEvent.EventType.COMPETITION_START
recurring_event.is_recurring = true
recurring_event.recurrence_interval = 4  # Every 4 weeks
time_system.recurring_events.append(recurring_event)
```

### Time Queries

```gdscript
var time_system = GameCore.get_system("time")

# Current time info
print("Current: " + time_system.get_current_date_string())
print("Week: %d/%d" % [time_system.current_week, time_system.total_weeks_elapsed])

# Future planning
var quest_deadline = time_system.total_weeks_elapsed + 10
var weeks_remaining = time_system.get_weeks_until(quest_deadline)
print("Quest due in %d weeks" % weeks_remaining)
```

## Performance Considerations

### Baseline Targets

- Weekly progression: < 200ms
- Event processing (100 events): < 50ms
- State save/load: < 50ms

### Optimization Tips

1. **Batch Operations**: Process multiple weeks together when possible
2. **Event Prioritization**: Use priority values to control execution order
3. **System Validation**: Check system availability before calling integration methods
4. **Performance Monitoring**: Use debug mode to track update durations

### Performance Measurement

```gdscript
# TimeSystem automatically tracks performance
var time_system = GameCore.get_system("time")

# Check last update duration
print("Last update: %d ms" % time_system.last_update_duration_ms)
print("Average: %.1f ms" % time_system.average_update_duration_ms)

# Enable performance logging
time_system.set_debug_mode(true)
```

## Error Handling

### Common Error Conditions

1. **Time Advancement Blocked**: System dependencies missing or invalid state
2. **Invalid Event Configuration**: Missing required fields or invalid timing
3. **System Integration Failures**: Required systems not loaded

### Error Recovery

```gdscript
var time_system = GameCore.get_system("time")

# Check if advancement is possible
var status = time_system.can_advance_time()
if not status.can_advance:
    print("Cannot advance time: %s" % str(status.reasons))
    # Handle blocking conditions
    return

# Safe advancement with error handling
if not time_system.advance_week():
    push_error("Time advancement failed despite validation")
```

## Testing

### Individual Test Coverage

The TimeSystem includes comprehensive test coverage:

- **Initialization**: System loading and default state
- **Week Advancement**: Basic progression and validation
- **Month/Year Transitions**: Boundary condition handling
- **Event Scheduling**: Scheduling, cancellation, execution
- **Save/Load**: State persistence and restoration
- **Performance**: Update duration measurement
- **Debug Commands**: Debug functionality validation

### Test File Location

`tests/individual/test_time.tscn` - Complete TimeSystem test suite

### Running Tests

```bash
# Individual TimeSystem tests
godot --headless --scene tests/individual/test_time.tscn

# Full integration tests
godot --headless --scene tests/test_all.tscn
```

## Constants

### Time Configuration

```gdscript
const WEEKS_PER_MONTH: int = 4
const WEEKS_PER_YEAR: int = 52
const MONTHS_PER_YEAR: int = 13
```

### Default Events

**Note**: As of the latest update, TimeSystem no longer creates automatic aging events. All weekly updates including aging are now handled by the WeeklyUpdateOrchestrator to prevent duplication.

## Migration Notes

### From Stage 1

TimeSystem is a new Stage 2 addition. No migration required for existing save files - time state will initialize to default values.

### Save Compatibility

TimeSystem state is optional in save files. Missing time data will initialize to:
- Week 1, Month 1, Year 1
- Total weeks elapsed: 0
- No scheduled events