# Stage 2 API Contracts

## System Interface Definitions
This document defines the exact API contracts between Stage 2 systems to prevent integration issues.

## 1. TimeSystem API

### Public Methods
```gdscript
# Core time advancement
func advance_week() -> bool
func advance_weeks(count: int) -> bool
func advance_to_week(target_week: int) -> bool
func can_advance_time() -> Dictionary  # {can_advance: bool, reasons: Array[String]}

# Time queries
func get_current_week() -> int
func get_current_month() -> int
func get_current_year() -> int
func get_total_weeks_elapsed() -> int
func get_weeks_until(target_week: int) -> int
func get_current_date_string() -> String  # "Year 1, Month 3, Week 2"

# Event management
func schedule_event(event: WeeklyEvent, week: int) -> void
func cancel_event(event_id: String) -> bool
func get_scheduled_events(week: int) -> Array[WeeklyEvent]

# System control
func block_advancement(reason: String) -> void
func unblock_advancement(reason: String) -> void
func is_advancement_blocked() -> bool
```

### Signals (via SignalBus)
```gdscript
signal week_advanced(new_week: int, total_weeks: int)
signal month_completed(month: int, year: int)
signal year_completed(year: int)
signal time_advance_blocked(reasons: Array[String])
signal weekly_update_started()
signal weekly_update_completed(duration_ms: int)
```

### Expected Integration
```gdscript
# Other systems register for weekly updates
func _ready():
    SignalBus.week_advanced.connect(_on_week_advanced)

func _on_week_advanced(new_week: int, total_weeks: int):
    # Process weekly changes
```

## 2. StaminaSystem API

### Public Methods
```gdscript
# Stamina management
func get_stamina(creature: CreatureData) -> int
func set_stamina(creature: CreatureData, value: int) -> void
func get_max_stamina(creature: CreatureData) -> int
func get_stamina_percentage(creature: CreatureData) -> float

# Stamina modification
func deplete_stamina(creature: CreatureData, amount: int) -> bool
func restore_stamina(creature: CreatureData, amount: int) -> void
func restore_stamina_percentage(creature: CreatureData, percentage: float) -> void
func reset_stamina(creature: CreatureData) -> void

# Status queries
func is_exhausted(creature: CreatureData) -> bool
func can_perform_activity(creature: CreatureData, cost: int) -> bool
func get_exhausted_creatures() -> Array[CreatureData]

# Activity management
func perform_activity(creature: CreatureData, activity_type: String, cost: int) -> bool
func get_activity_cost(activity_type: String) -> int

# Weekly processing
func process_weekly_stamina() -> Dictionary  # {depleted: Array, recovered: Array}

# Modifiers
func set_depletion_modifier(creature: CreatureData, modifier: float) -> void
func set_recovery_modifier(creature: CreatureData, modifier: float) -> void
func clear_modifiers(creature: CreatureData) -> void
```

### Signals (via SignalBus)
```gdscript
signal stamina_depleted(creature: CreatureData, amount: int)
signal stamina_restored(creature: CreatureData, amount: int)
signal creature_exhausted(creature: CreatureData)
signal creature_recovered(creature: CreatureData)
```

## 3. FoodSystem API

### Public Methods
```gdscript
# Food inventory
func get_food_amount(food_type: String) -> int
func add_food(food_type: String, amount: int) -> void
func remove_food(food_type: String, amount: int) -> bool
func has_food(food_type: String, amount: int) -> bool
func get_total_food() -> int
func get_food_types() -> Array[String]

# Consumption
func feed_creature(creature: CreatureData, food_type: String) -> bool
func feed_all_active() -> Dictionary  # {fed: int, unfed: int, food_used: Dictionary}
func calculate_weekly_consumption() -> int
func can_sustain_creatures(weeks: int) -> bool

# Food effects
func get_food_stamina_value(food_type: String) -> int
func get_food_health_value(food_type: String) -> int
func get_food_mood_bonus(food_type: String) -> float
func apply_food_effects(creature: CreatureData, food_type: String) -> void

# Weekly processing
func process_weekly_consumption() -> Dictionary  # {consumed: Dictionary, shortage: bool}

# Spoilage (optional for Stage 2)
func process_spoilage() -> Dictionary  # {spoiled: Dictionary}
func get_spoilage_time(food_type: String) -> int
```

### Signals (via SignalBus)
```gdscript
signal food_consumed(food_type: String, amount: int)
signal food_added(food_type: String, amount: int)
signal food_spoiled(food_type: String, amount: int)
signal food_shortage_warning(weeks_remaining: int)
signal creature_fed(creature: CreatureData, food_type: String)
```

## 4. UIManager API

### Public Methods
```gdscript
# Scene management
func change_scene(scene_path: String, transition_type: String = "fade") -> void
func push_scene(scene_path: String) -> void
func pop_scene() -> void
func get_current_scene() -> Control

# Window management
func show_window(window_name: String, data: Dictionary = {}) -> Window
func hide_window(window_name: String) -> void
func is_window_open(window_name: String) -> bool
func close_all_windows() -> void

# Notifications
func show_notification(text: String, type: String = "info", duration: float = 3.0) -> void
func show_error(text: String) -> void
func show_success(text: String) -> void
func clear_notifications() -> void

# Dialogs
func show_confirm_dialog(text: String, on_confirm: Callable, on_cancel: Callable = Callable()) -> void
func show_input_dialog(prompt: String, on_submit: Callable, default_text: String = "") -> void
func show_choice_dialog(text: String, choices: Array[String], on_choice: Callable) -> void

# UI state
func set_ui_enabled(enabled: bool) -> void
func is_ui_enabled() -> bool
func save_ui_state() -> Dictionary
func restore_ui_state(state: Dictionary) -> void
```

### Signals
```gdscript
signal scene_changed(scene_name: String)
signal window_opened(window_name: String)
signal window_closed(window_name: String)
signal notification_shown(text: String, type: String)
signal ui_state_changed(enabled: bool)
```

## 5. WeeklyUpdateOrchestrator API

### Public Methods
```gdscript
# Update execution
func execute_weekly_update() -> Dictionary  # {success: bool, summary: WeeklySummary}
func can_update() -> Dictionary  # {can_update: bool, blockers: Array[String]}

# Phase management
func register_phase_handler(phase: UpdatePhase, handler: Callable) -> void
func unregister_phase_handler(phase: UpdatePhase) -> void
func skip_phase(phase: UpdatePhase) -> void
func reset_phases() -> void

# Summary access
func get_last_summary() -> WeeklySummary
func get_summary_history(weeks: int) -> Array[WeeklySummary]

# Rollback
func can_rollback() -> bool
func rollback_last_update() -> bool

# Configuration
func set_auto_save(enabled: bool) -> void
func set_show_summary(enabled: bool) -> void
func set_phase_order(phases: Array[UpdatePhase]) -> void
```

### Signals (via SignalBus)
```gdscript
signal weekly_update_phase_started(phase: String)
signal weekly_update_phase_completed(phase: String, success: bool)
signal weekly_update_failed(phase: String, error: String)
signal weekly_summary_ready(summary: WeeklySummary)
```

## Integration Examples

### Example 1: Time Advancement with Validation
```gdscript
# In UI controller
func _on_advance_time_pressed():
    var time_system = GameCore.get_system("time")
    var can_advance = time_system.can_advance_time()

    if not can_advance.can_advance:
        UIManager.show_error("Cannot advance time: " + str(can_advance.reasons))
        return

    if time_system.advance_week():
        UIManager.show_success("Advanced to week " + str(time_system.get_current_week()))
```

### Example 2: Stamina Check Before Activity
```gdscript
# In training system
func start_training(creature: CreatureData):
    var stamina_system = GameCore.get_system("stamina")
    var cost = stamina_system.get_activity_cost("training")

    if not stamina_system.can_perform_activity(creature, cost):
        UIManager.show_notification(creature.creature_name + " is too exhausted to train")
        return

    if stamina_system.perform_activity(creature, "training", cost):
        # Proceed with training
        _execute_training(creature)
```

### Example 3: Weekly Food Consumption
```gdscript
# In weekly orchestrator
func _handle_food_phase() -> bool:
    var food_system = GameCore.get_system("food")
    var collection = GameCore.get_system("collection")

    # Check if we have enough food
    var active_count = collection.get_active_creatures().size()
    var needed = active_count * food_system.FOOD_PER_CREATURE_PER_WEEK

    if food_system.get_total_food() < needed:
        SignalBus.food_shortage_warning.emit(0)
        return false

    # Consume food
    var result = food_system.feed_all_active()
    update_results["food"] = result
    return result.unfed == 0
```

## Contract Validation Tests

### Test Template
```gdscript
extends Node

func test_api_contract_[system_name]():
    var system = GameCore.get_system("[system_name]")

    # Test all public methods exist
    assert(system.has_method("method_name"))

    # Test return types
    var result = system.method_name()
    assert(typeof(result) == expected_type)

    # Test signal connections
    assert(SignalBus.has_signal("signal_name"))
```

## Breaking Changes Policy
- Any changes to these contracts require updating all dependent systems
- Add new methods/signals without removing old ones (deprecate instead)
- Document migration path for any breaking changes
- Run integration tests after any API modifications