# Weekly Update System Usage Guide

## Overview
The Weekly Update System orchestrates all game systems during weekly time progression, ensuring updates happen in the correct order with proper error handling and rollback capabilities.

## Architecture

### Core Components
- **WeeklyUpdateOrchestrator**: Main coordinator for all weekly updates
- **WeeklySummary**: Data class containing update results
- **TimeSystem Integration**: Automatic triggering via time progression

### Update Pipeline
Updates are processed in the following order:
1. **PRE_UPDATE**: Validation and preparation
2. **AGING**: Process creature aging (active creatures only; stable creatures remain in stasis)
3. **STAMINA**: Update stamina values through activity system
4. **FOOD**: Consume food resources
5. **QUESTS**: Update quest progress
6. **COMPETITIONS**: Process competition results
7. **ECONOMY**: Handle gold/resource changes
8. **POST_UPDATE**: Cleanup and finalization
9. **SAVE**: Auto-save game state

## Basic Usage

### Automatic Weekly Updates
```gdscript
# Updates trigger automatically when time advances
var time_system = GameCore.get_system("time")
time_system.advance_week()  # Orchestrator handles all updates
```

### Manual Orchestration
```gdscript
# Access orchestrator directly for manual control
var time_system = GameCore.get_system("time")
var orchestrator = time_system.weekly_orchestrator

# Execute weekly update manually
var result = orchestrator.execute_weekly_update()
if result.success:
    var summary: WeeklySummary = result.summary
    print(summary.get_summary_text())
else:
    print("Update failed at phase: " + result.failed_phase)
```

### Accessing Update Results
```gdscript
# Get detailed update information
var summary = result.summary
print("Creatures aged: %d" % summary.creatures_aged)
print("Food consumed: %d" % summary.food_consumed)
print("Gold spent: %d" % summary.gold_spent)

# Get full summary as dictionary
var data = summary.to_dict()
```

## System Integration

### Adding Custom Update Phase
```gdscript
# In your system's _ready()
func _ready() -> void:
    var signal_bus = GameCore.get_signal_bus()
    signal_bus.weekly_update_started.connect(_on_weekly_update)

func _on_weekly_update() -> void:
    # Perform weekly updates for your system
    process_weekly_changes()
```

### Stamina System Integration
```gdscript
# Stamina updates automatically during weekly cycle through activity system
var stamina_system = GameCore.get_system("stamina")

# Stamina changes only through assigned activities:
# - Active creatures: process assigned activities (training, quests, etc.)
# - Stable creatures: remain in stasis (no aging, no stamina changes)
var activity_results = stamina_system.process_weekly_activities()
```

### Resource Consumption
```gdscript
# Food and gold are automatically consumed
# 1 food unit per creature per week
# 10 gold weekly upkeep
# Handled automatically by orchestrator
```

## Error Handling

### Rollback System
The orchestrator maintains snapshots for rollback:
```gdscript
# Automatic rollback on failure
if update_phase_fails:
    # System automatically:
    # 1. Restores creature states
    # 2. Restores resource values
    # 3. Resets time values
    # 4. Emits weekly_update_failed signal
```

### Handling Update Failures
```gdscript
# Listen for update failures
signal_bus.weekly_update_failed.connect(_on_update_failed)

func _on_update_failed() -> void:
    # Handle failure (show UI notification, etc.)
    print("Weekly update failed and was rolled back")
```

## Performance Monitoring

### Checking Update Performance
```gdscript
# Performance is automatically tracked
var orchestrator = time_system.weekly_orchestrator
var result = orchestrator.execute_weekly_update()
print("Update completed in %d ms" % result.time_ms)

# Target: <200ms for 100 creatures
```

### Optimization Tips
- Use batch operations when possible
- Cache frequently accessed data
- Defer non-critical updates
- Use quiet mode for bulk operations

## Signals

### Available Signals
```gdscript
# Time system signals
signal weekly_update_started()
signal weekly_update_completed(duration_ms: int)
signal weekly_update_failed()
signal week_advanced(new_week: int, total_weeks: int)

# Stamina signals
signal stamina_weekly_processed(active_count: int, stable_count: int)
```

### Signal Usage Example
```gdscript
func _ready() -> void:
    var signal_bus = GameCore.get_signal_bus()
    signal_bus.weekly_update_completed.connect(_on_weekly_complete)
    signal_bus.weekly_update_failed.connect(_on_weekly_failed)

func _on_weekly_complete(duration_ms: int) -> void:
    print("Weekly update completed in %d ms" % duration_ms)
    _update_ui_with_results()

func _on_weekly_failed() -> void:
    _show_error_notification("Weekly update failed")
```

## Weekly Summary

### Summary Data Structure
```gdscript
class_name WeeklySummary extends Resource

@export var week: int = 0
@export var creatures_aged: int = 0
@export var category_changes: Array[Dictionary] = []
@export var stamina_changes: Dictionary = {}
@export var food_consumed: int = 0
@export var food_remaining: int = 0
@export var gold_spent: int = 0
@export var gold_earned: int = 0
@export var quest_completions: Array[String] = []
@export var competition_results: Array[Dictionary] = []
@export var creatures_expired: Array[String] = []
```

### Displaying Summary
```gdscript
# Get formatted summary text
var summary_text = summary.get_summary_text()
# Output:
# Week 5 Summary:
# • 10 creatures aged
# • 2 creatures changed age category
# • 5 creatures lost stamina
# • 3 creatures recovered stamina
# • 10 food consumed
# • Gold: -20

# Or build custom display
func display_custom_summary(summary: WeeklySummary) -> void:
    var ui_label = $SummaryLabel
    ui_label.text = "Week %d Results:\n" % summary.week

    if summary.creatures_expired.size() > 0:
        ui_label.text += "⚠️ %d creatures reached end of lifespan\n" % summary.creatures_expired.size()

    if summary.food_consumed > summary.food_remaining:
        ui_label.text += "⚠️ Food shortage detected!\n"
```

## Common Use Cases

### 1. Skip Multiple Weeks
```gdscript
# Advance multiple weeks at once
var time_system = GameCore.get_system("time")
for i in range(4):
    if not time_system.advance_week():
        print("Failed to advance week %d" % i)
        break
```

### 2. Conditional Updates
```gdscript
# Check conditions before allowing update
func can_advance_week() -> bool:
    var resource_system = GameCore.get_system("resource")
    if resource_system.get_balance() < 10:
        show_warning("Insufficient gold for weekly upkeep")
        return false
    return true
```

### 3. Custom Phase Handler
```gdscript
# Add custom handling for specific phases
func _on_weekly_update_started() -> void:
    # Pre-process before standard updates
    prepare_special_events()

func _on_weekly_update_completed(duration_ms: int) -> void:
    # Post-process after standard updates
    trigger_random_events()
    update_achievements()
```

## Debug Mode

### Enable Debug Output
```gdscript
# Enable debug mode for detailed logging
var time_system = GameCore.get_system("time")
time_system.debug_mode = true

# Orchestrator will print detailed update information
# Including performance metrics and phase results
```

## Best Practices

1. **Always check return values** when manually triggering updates
2. **Listen for signals** to update UI components
3. **Use rollback data** carefully - don't modify during updates
4. **Test with large datasets** to ensure performance targets are met
5. **Implement graceful degradation** for missing systems
6. **Cache system references** to avoid repeated lookups
7. **Use batch operations** for better performance

## Troubleshooting

### Update Fails Immediately
- Check all required systems are loaded
- Verify creature collection has valid data
- Ensure resource system is initialized

### Performance Issues
- Check creature count (target: <200ms for 100 creatures)
- Review custom update handlers for bottlenecks
- Use performance mode for large operations
- Batch similar operations together

### Rollback Not Working
- Ensure all modified data is included in snapshots
- Check that restore methods properly apply saved state
- Verify signal connections are established

## Related Systems
- [TimeSystem](TIME_SYSTEM.md) - Core time management
- [StaminaSystem](STAMINA_SYSTEM.md) - Stamina management
- [PlayerCollection](PLAYER_COLLECTION.md) - Creature management
- [ResourceTracker](RESOURCE_TRACKER.md) - Resource management
- [SaveSystem](SAVE_SYSTEM.md) - Save/load functionality