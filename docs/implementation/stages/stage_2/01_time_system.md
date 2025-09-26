# Stage 2 Task 1: TimeSystem Implementation

## Overview
Implement a comprehensive time management system that tracks weekly progression, handles manual time advancement, triggers weekly events, and integrates with all time-dependent systems (aging, stamina, food consumption).

## Success Criteria
- [ ] TimeSystem loads via GameCore lazy loading pattern
- [ ] Manual week advancement with validation
- [ ] Weekly event scheduling and triggering
- [ ] Integration with AgeSystem for creature aging
- [ ] Save/load persistence of time state
- [ ] Performance: Process weekly update for 100 creatures in <200ms
- [ ] Comprehensive test coverage with edge cases

## Files to Create/Modify

### New Files
- `scripts/systems/time_system.gd` - Main TimeSystem class
- `scripts/data/time_data.gd` - Time-related data structures
- `scripts/core/weekly_event.gd` - Weekly event definitions
- `tests/individual/test_time.tscn` - Time system test scene
- `tests/individual/test_time.gd` - Time system test script

### Modified Files
- `scripts/core/game_core.gd` - Register TimeSystem
- `scripts/core/signal_bus.gd` - Add time-related signals
- `scripts/systems/save_system.gd` - Add time persistence
- `tests/test_all.gd` - Include time tests

## Implementation Details

### 1. TimeSystem Class Structure
```gdscript
class_name TimeSystem extends Node

# Constants
const WEEKS_PER_MONTH: int = 4
const WEEKS_PER_YEAR: int = 52
const MONTHS_PER_YEAR: int = 13  # 52 weeks / 4 = 13 months

# Time tracking
var current_week: int = 1
var current_month: int = 1
var current_year: int = 1
var total_weeks_elapsed: int = 0

# Event management
var scheduled_events: Dictionary = {}  # week -> Array[WeeklyEvent]
var recurring_events: Array[WeeklyEvent] = []

# System state
var is_processing_week: bool = false
var week_advance_blocked: bool = false
var block_reasons: Array[String] = []

# Performance tracking
var last_update_duration_ms: int = 0
var average_update_duration_ms: float = 0.0

# Debug mode
var debug_mode: bool = false
var time_scale: float = 1.0  # For debug fast-forward

# Methods
func advance_week() -> bool
func advance_weeks(count: int) -> bool
func advance_to_week(target_week: int) -> bool
func schedule_event(event: WeeklyEvent, week: int) -> void
func cancel_event(event_id: String) -> bool
func get_current_date_string() -> String
func get_weeks_until(target_week: int) -> int
func can_advance_time() -> Dictionary  # {can_advance: bool, reasons: Array[String]}
```

### 2. Time Data Structures
```gdscript
class_name TimeData extends Resource

@export var week: int = 1
@export var month: int = 1
@export var year: int = 1
@export var total_weeks: int = 0
@export var last_save_week: int = 0

func to_dict() -> Dictionary
func from_dict(data: Dictionary) -> void
func get_formatted_date() -> String
```

### 3. Weekly Event System
```gdscript
class_name WeeklyEvent extends Resource

enum EventType {
    CREATURE_AGING,
    STAMINA_DEPLETION,
    FOOD_CONSUMPTION,
    QUEST_DEADLINE,
    COMPETITION_START,
    SHOP_REFRESH,
    CUSTOM
}

@export var event_id: String = ""
@export var event_type: EventType = EventType.CUSTOM
@export var event_name: String = ""
@export var trigger_week: int = -1
@export var is_recurring: bool = false
@export var recurrence_interval: int = 1
@export var event_data: Dictionary = {}
@export var priority: int = 0  # Lower = higher priority

func execute() -> void
func can_execute() -> bool
```

### 4. SignalBus Integration
```gdscript
# New signals in SignalBus
signal week_advanced(new_week: int, total_weeks: int)
signal month_completed(month: int, year: int)
signal year_completed(year: int)
signal time_advance_blocked(reasons: Array[String])
signal weekly_event_triggered(event: WeeklyEvent)
signal weekly_update_started()
signal weekly_update_completed(duration_ms: int)
```

### 5. Weekly Update Sequence
```gdscript
func advance_week() -> bool:
    if is_processing_week:
        push_error("Already processing week advancement")
        return false

    var can_advance = can_advance_time()
    if not can_advance.can_advance:
        SignalBus.time_advance_blocked.emit(can_advance.reasons)
        return false

    is_processing_week = true
    var start_time = Time.get_ticks_msec()

    SignalBus.weekly_update_started.emit()

    # Update time counters
    current_week += 1
    total_weeks_elapsed += 1

    # Update month/year
    if current_week > WEEKS_PER_YEAR:
        current_week = 1
        current_year += 1
        SignalBus.year_completed.emit(current_year - 1)

    current_month = (current_week - 1) / WEEKS_PER_MONTH + 1
    if current_week % WEEKS_PER_MONTH == 1 and current_week > 1:
        SignalBus.month_completed.emit(current_month - 1, current_year)

    # Process scheduled events by priority
    _process_weekly_events()

    # Trigger system updates in order
    _trigger_system_updates()

    # Emit completion signal
    SignalBus.week_advanced.emit(current_week, total_weeks_elapsed)

    # Track performance
    var duration = Time.get_ticks_msec() - start_time
    last_update_duration_ms = duration
    _update_average_duration(duration)

    SignalBus.weekly_update_completed.emit(duration)

    is_processing_week = false
    return true
```

### 6. System Update Order
```gdscript
func _trigger_system_updates() -> void:
    # Order matters for dependencies!

    # 1. Age creatures (affects stats)
    if GameCore.has_system("age"):
        var age_system = GameCore.get_system("age")
        age_system.process_weekly_aging()

    # 2. Process stamina depletion
    if GameCore.has_system("stamina"):
        var stamina_system = GameCore.get_system("stamina")
        stamina_system.process_weekly_stamina()

    # 3. Consume food
    if GameCore.has_system("food"):
        var food_system = GameCore.get_system("food")
        food_system.process_weekly_consumption()

    # 4. Update quests
    if GameCore.has_system("quest"):
        var quest_system = GameCore.get_system("quest")
        quest_system.process_weekly_updates()

    # 5. Save after all updates
    if GameCore.has_system("save"):
        var save_system = GameCore.get_system("save")
        save_system.trigger_auto_save()
```

### 7. Save/Load Integration
```gdscript
func save_time_state() -> Dictionary:
    return {
        "current_week": current_week,
        "current_month": current_month,
        "current_year": current_year,
        "total_weeks": total_weeks_elapsed,
        "scheduled_events": _serialize_events(scheduled_events),
        "settings": {
            "debug_mode": debug_mode,
            "time_scale": time_scale
        }
    }

func load_time_state(data: Dictionary) -> void:
    current_week = data.get("current_week", 1)
    current_month = data.get("current_month", 1)
    current_year = data.get("current_year", 1)
    total_weeks_elapsed = data.get("total_weeks", 0)

    if data.has("scheduled_events"):
        scheduled_events = _deserialize_events(data.scheduled_events)

    if data.has("settings"):
        debug_mode = data.settings.get("debug_mode", false)
        time_scale = data.settings.get("time_scale", 1.0)
```

## Testing Requirements

### Unit Tests
```gdscript
extends Node

func test_week_advancement():
    var time_system = TimeSystem.new()
    assert(time_system.current_week == 1)
    assert(time_system.advance_week() == true)
    assert(time_system.current_week == 2)

func test_month_transition():
    var time_system = TimeSystem.new()
    time_system.advance_weeks(4)
    assert(time_system.current_month == 2)

func test_year_transition():
    var time_system = TimeSystem.new()
    time_system.advance_weeks(52)
    assert(time_system.current_year == 2)
    assert(time_system.current_week == 1)

func test_event_scheduling():
    var time_system = TimeSystem.new()
    var event = WeeklyEvent.new()
    event.trigger_week = 5
    time_system.schedule_event(event, 5)
    # Verify event triggers at week 5

func test_performance():
    var time_system = TimeSystem.new()
    # Generate 100 creatures
    # Advance week and measure time
    assert(time_system.last_update_duration_ms < 200)
```

### Integration Tests
- 52-week progression without errors
- Save/load preserves time state
- Events trigger at correct times
- System updates occur in proper order
- Performance with full creature population

## Performance Considerations

### Optimization Strategies
1. **Event Priority Queue**: Process events by priority
2. **Batch Updates**: Group similar operations
3. **Lazy Evaluation**: Only update visible UI elements
4. **Caching**: Store computed values for the week
5. **Async Processing**: Use deferred calls for non-critical updates

### Benchmarks
- Single week advancement: <50ms base overhead
- 100 creature updates: <150ms additional
- Event processing: <1ms per event
- Save state: <10ms
- Total target: <200ms for full update

## Error Handling

### Validation Checks
- Prevent negative week values
- Validate event data before execution
- Check system availability before updates
- Verify save data integrity
- Handle circular event dependencies

### Recovery Strategies
- Rollback on failed week advancement
- Skip missing events with logging
- Graceful degradation if systems unavailable
- Auto-save before risky operations
- Debug mode for testing edge cases

## Debug Features

### Debug Commands
```gdscript
func debug_advance_weeks(count: int) -> void
func debug_set_week(week: int) -> void
func debug_trigger_event(event_type: WeeklyEvent.EventType) -> void
func debug_print_schedule() -> void
func debug_measure_performance() -> void
```

### Debug UI Integration
- Time control panel in debug mode
- Event schedule viewer
- Performance metrics display
- System update order visualization
- Time manipulation shortcuts (F9-F12)

## Dependencies

### Required Systems
- GameCore (for registration)
- SignalBus (for event emission)
- SaveSystem (for persistence)

### Optional Integrations
- AgeSystem (for creature aging)
- StaminaSystem (when implemented)
- FoodSystem (when implemented)
- QuestSystem (future stage)

## Future Enhancements (Post-Stage 2)
- Seasonal events and bonuses
- Weather system integration
- Market price fluctuations
- Breeding season mechanics
- Competition schedules
- Holiday events