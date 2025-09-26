# Stage 2 Task 9: Weekly Update System

## Overview
Orchestrate all weekly updates across systems in the correct order, handle dependencies, generate summary reports, and ensure data consistency through the update process.

## Success Criteria
- [ ] Coordinate all system updates in proper sequence
- [ ] Generate comprehensive weekly summary
- [ ] Handle update failures gracefully
- [ ] Emit appropriate signals for UI updates
- [ ] Maintain data consistency across updates
- [ ] Performance: Complete all updates in <200ms for 100 creatures

## Files to Create/Modify

### New Files
- `scripts/systems/weekly_update_orchestrator.gd`
- `scripts/data/weekly_summary.gd`
- `scenes/ui/dialogs/weekly_summary_dialog.tscn`

### Modified Files
- `scripts/systems/time_system.gd` - Integrate orchestrator
- All system files - Add weekly update hooks

## Implementation Details

### 1. Update Orchestrator
```gdscript
class_name WeeklyUpdateOrchestrator extends Node

# Update phases in execution order
enum UpdatePhase {
    PRE_UPDATE,      # Validation and preparation
    AGING,           # Age all creatures
    STAMINA,         # Process stamina changes
    FOOD,            # Consume food
    QUESTS,          # Update quest progress
    COMPETITIONS,    # Process competition results
    ECONOMY,         # Update gold and resources
    POST_UPDATE,     # Cleanup and summary
    SAVE             # Auto-save after updates
}

var update_pipeline: Array[UpdatePhase] = []
var phase_handlers: Dictionary = {}  # UpdatePhase -> Callable
var update_results: Dictionary = {}
var rollback_data: Dictionary = {}

func execute_weekly_update() -> Dictionary:
    _prepare_update()

    for phase in update_pipeline:
        if not _execute_phase(phase):
            _rollback_update()
            return {"success": false, "failed_phase": phase}

    _finalize_update()
    return {"success": true, "summary": _generate_summary()}
```

### 2. Update Sequence
```gdscript
func _initialize_pipeline():
    update_pipeline = [
        UpdatePhase.PRE_UPDATE,
        UpdatePhase.AGING,
        UpdatePhase.STAMINA,
        UpdatePhase.FOOD,
        UpdatePhase.QUESTS,
        UpdatePhase.COMPETITIONS,
        UpdatePhase.ECONOMY,
        UpdatePhase.POST_UPDATE,
        UpdatePhase.SAVE
    ]

    phase_handlers = {
        UpdatePhase.PRE_UPDATE: _handle_pre_update,
        UpdatePhase.AGING: _handle_aging,
        UpdatePhase.STAMINA: _handle_stamina,
        UpdatePhase.FOOD: _handle_food,
        UpdatePhase.QUESTS: _handle_quests,
        UpdatePhase.COMPETITIONS: _handle_competitions,
        UpdatePhase.ECONOMY: _handle_economy,
        UpdatePhase.POST_UPDATE: _handle_post_update,
        UpdatePhase.SAVE: _handle_save
    }
```

### 3. Phase Handlers
```gdscript
func _handle_aging() -> bool:
    if not GameCore.has_system("age"):
        return true  # Skip if system not available

    var age_system = GameCore.get_system("age")
    var results = age_system.process_weekly_aging()

    update_results["aging"] = {
        "aged_creatures": results.aged_count,
        "category_changes": results.category_changes,
        "expired_creatures": results.expired
    }

    return results.success

func _handle_stamina() -> bool:
    if not GameCore.has_system("stamina"):
        return true

    var stamina_system = GameCore.get_system("stamina")
    var collection = GameCore.get_system("collection")

    # Track changes for summary
    var depleted = []
    var recovered = []

    # Process active creatures
    for creature in collection.get_active_creatures():
        var before = stamina_system.get_stamina(creature)
        stamina_system.deplete_weekly(creature)
        var after = stamina_system.get_stamina(creature)
        if after < before:
            depleted.append({"creature": creature, "amount": before - after})

    # Process stable creatures
    for creature in collection.get_stable_creatures():
        var before = stamina_system.get_stamina(creature)
        stamina_system.restore_weekly(creature)
        var after = stamina_system.get_stamina(creature)
        if after > before:
            recovered.append({"creature": creature, "amount": after - before})

    update_results["stamina"] = {
        "depleted": depleted,
        "recovered": recovered
    }

    return true
```

### 4. Weekly Summary Generation
```gdscript
func _generate_summary() -> WeeklySummary:
    var summary = WeeklySummary.new()
    summary.week = GameCore.get_system("time").current_week

    # Compile results from all phases
    if update_results.has("aging"):
        summary.creatures_aged = update_results.aging.aged_creatures
        summary.category_changes = update_results.aging.category_changes

    if update_results.has("stamina"):
        summary.stamina_changes = update_results.stamina

    if update_results.has("food"):
        summary.food_consumed = update_results.food.consumed
        summary.food_remaining = update_results.food.remaining

    if update_results.has("economy"):
        summary.gold_spent = update_results.economy.spent
        summary.gold_earned = update_results.economy.earned

    return summary
```

### 5. Rollback System
```gdscript
func _prepare_update():
    # Save current state for potential rollback
    rollback_data = {
        "creatures": _snapshot_creatures(),
        "resources": _snapshot_resources(),
        "time": GameCore.get_system("time").get_state()
    }

func _rollback_update():
    push_warning("Rolling back weekly update due to error")

    # Restore creature states
    for creature_id in rollback_data.creatures:
        var creature = _get_creature_by_id(creature_id)
        creature.from_dict(rollback_data.creatures[creature_id])

    # Restore resources
    var resource_system = GameCore.get_system("resource")
    resource_system.load_state(rollback_data.resources)

    SignalBus.weekly_update_failed.emit()
```

## Error Handling
- Validate all systems before update
- Check resource availability
- Handle missing creatures gracefully
- Log all errors with context
- Provide rollback on critical failures

## Performance Optimization
- Batch similar operations
- Use object pooling for UI updates
- Defer non-critical updates
- Cache frequently accessed data
- Minimize signal emissions during update