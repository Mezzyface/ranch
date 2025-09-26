# Stage 2 Agent Execution Guide

## Purpose
This guide helps AI agents successfully implement Stage 2 tasks by providing concrete examples, common fixes, and validation steps.

## Critical Pre-Implementation Checklist

### Before Starting ANY Stage 2 Task:
```bash
# 1. Verify Stage 1 completion
godot --headless --scene tests/test_all.tscn

# 2. Check for pending Stage 1 tasks
grep -r "TODO\|FIXME" scripts/

# 3. Ensure clean git state
git status

# 4. Create Stage 2 branch
git checkout -b stage-2-implementation
```

## Task-Specific Implementation Patterns

### Pattern 1: Creating a New GameCore Subsystem
```gdscript
# CORRECT: Follow this exact pattern for TimeSystem, StaminaSystem, FoodSystem
extends Node

var _initialized: bool = false

func _init() -> void:
    # NO class_name for GameCore subsystems!
    pass

func initialize() -> void:
    if _initialized:
        return
    _initialized = true

    # Connect to signals
    var signal_bus = GameCore.get_signal_bus()
    # signal_bus.some_signal.connect(_on_some_signal)

    print("[SystemName] initialized")

func cleanup() -> void:
    _initialized = false
    # Disconnect signals and cleanup
```

### Pattern 2: UI Component Creation
```gdscript
# CORRECT: All UI components extend Control or subclasses
class_name CreatureCard extends PanelContainer

signal clicked(creature: CreatureData)
signal dragged(creature: CreatureData)

@export var creature_data: CreatureData:
    set(value):
        creature_data = value
        if is_inside_tree():
            _update_display()

func _ready() -> void:
    # Connect to SignalBus for updates
    var signal_bus = GameCore.get_signal_bus()
    signal_bus.creature_updated.connect(_on_creature_updated)
    _update_display()

func _update_display() -> void:
    if not creature_data:
        return
    # Update UI elements
```

### Pattern 3: Signal Integration
```gdscript
# CORRECT: Always validate before emission
func emit_week_advanced(new_week: int) -> void:
    if new_week < 1:
        push_error("Invalid week number: " + str(new_week))
        return

    week_advanced.emit(new_week, total_weeks_elapsed)
```

## Common Godot 4.5 Issues & Solutions

### Issue 1: Scene Structure Errors
```gdscript
# WRONG: Creating scenes in code incorrectly
var panel = Panel.new()
add_child(panel)  # May fail if not in tree

# CORRECT: Proper scene instantiation
var panel_scene = preload("res://scenes/ui/panel.tscn")
var panel = panel_scene.instantiate()
add_child(panel)
```

### Issue 2: Timer Usage
```gdscript
# WRONG: Creating timers without proper setup
var timer = Timer.new()
timer.timeout.connect(func(): advance_week())

# CORRECT: Complete timer setup
var timer = Timer.new()
timer.wait_time = 1.0
timer.one_shot = false
add_child(timer)  # Must be in tree!
timer.timeout.connect(_on_timer_timeout)
timer.start()
```

### Issue 3: Input Handling
```gdscript
# WRONG: Hardcoding input checks
if Input.is_key_pressed(KEY_SPACE):
    advance_week()

# CORRECT: Using input actions
if Input.is_action_just_pressed("advance_time"):
    advance_week()

# In project.godot:
# [input]
# advance_time={
# "events": [InputEventKey.new()]
# }
```

## System Integration Checklist

### For EVERY New System:
- [ ] Register in GameCore._create_system()
- [ ] Add to SignalBus with validation methods
- [ ] Create test file in tests/individual/
- [ ] Add to test_all.gd sequence
- [ ] Document in API_REFERENCE.md
- [ ] Add save/load hooks if needed

### For EVERY UI Component:
- [ ] Create .tscn file with proper node structure
- [ ] Set anchors for responsive layout
- [ ] Add theme overrides if needed
- [ ] Connect signals in _ready()
- [ ] Implement _notification() for cleanup
- [ ] Test with different window sizes

## Validation Commands

### After Implementing TimeSystem:
```bash
# Test time advancement
godot --headless --scene tests/individual/test_time.tscn

# Verify signal emissions
godot --headless --script scripts/debug/test_time_signals.gd
```

### After Implementing UI Framework:
```bash
# Check scene loading
godot --check-only scenes/ui/game_ui.tscn

# Test responsive layout
godot --windowed --resolution 1920x1080 scenes/ui/game_ui.tscn
godot --windowed --resolution 1280x720 scenes/ui/game_ui.tscn
```

### After Implementing StaminaSystem:
```bash
# Test stamina depletion
godot --headless --scene tests/individual/test_stamina.tscn

# Verify weekly updates
godot --headless --script scripts/debug/test_weekly_stamina.gd
```

## Performance Validation

### Required Benchmarks:
```gdscript
# Add to each system test:
func test_performance():
    var start = Time.get_ticks_msec()

    # Generate 100 creatures
    var creatures = []
    for i in 100:
        creatures.append(CreatureGenerator.generate_creature_data("scuttleguard"))

    # Test system operation
    system.process_weekly_update(creatures)

    var duration = Time.get_ticks_msec() - start
    assert(duration < 200, "Performance requirement failed: " + str(duration) + "ms")
```

## Debug Helpers

### Add to EVERY System:
```gdscript
var debug_mode: bool = false

func set_debug_mode(enabled: bool) -> void:
    debug_mode = enabled
    if debug_mode:
        print("[%s] Debug mode enabled" % get_class())

func debug_print(message: String) -> void:
    if debug_mode:
        print("[%s] %s" % [get_class(), message])
```

### Add to UI Components:
```gdscript
func _input(event: InputEvent) -> void:
    if OS.is_debug_build():
        if event.is_action_pressed("ui_debug"):
            _show_debug_info()
```

## Common Validation Failures & Fixes

### "Signal not found" Error
```gdscript
# Check SignalBus has the signal defined
# In signal_bus.gd:
signal week_advanced(new_week: int, total_weeks: int)
```

### "Invalid type in setter" Warning
```gdscript
# Use explicit typing
@export var stamina: int = 100:
    set(value):
        stamina = clamp(value, 0, 100)
```

### "Node not found" Error
```gdscript
# Use @onready with proper paths
@onready var label: Label = $VBox/Header/Label
# OR safe access:
var label = get_node_or_null("VBox/Header/Label")
if label:
    label.text = "Text"
```

## Testing Workflow for Agents

### 1. Unit Test First
```bash
# Create test before implementation
godot --headless --script scripts/tests/test_[system].gd
```

### 2. Integration Test
```bash
# Test with other systems
godot --headless --scene tests/stage_2_integration.tscn
```

### 3. Performance Test
```bash
# Verify performance targets
godot --headless --script scripts/tests/benchmark_[system].gd
```

### 4. UI Visual Test
```bash
# Manual visual verification
godot scenes/ui/test_ui.tscn
```

## Success Indicators

### Green Flags (System is working):
- ✅ No compilation errors in console
- ✅ All tests passing
- ✅ Signals emitting with debug output
- ✅ Save/load preserves state
- ✅ Performance under target threshold
- ✅ UI updates smoothly at 60 FPS

### Red Flags (Needs fixing):
- ❌ "Parser Error" in console
- ❌ "Signal not found" warnings
- ❌ Memory continuously increasing
- ❌ FPS drops below 30
- ❌ Save file size > 1MB
- ❌ Weekly update takes > 200ms

## Quick Fixes Reference

### Fix 1: Autoload Not Working
```gdscript
# In project.godot:
[autoload]
GameCore="*res://scripts/core/game_core.gd"
# Restart Godot after changes!
```

### Fix 2: Scene Won't Load
```bash
# Check scene file for corruption
godot --check-only path/to/scene.tscn

# If corrupted, recreate from scratch
```

### Fix 3: Signals Not Connecting
```gdscript
# Ensure object is in tree before connecting
func _ready():
    call_deferred("_connect_signals")

func _connect_signals():
    SignalBus.some_signal.connect(_handler)
```

## Final Validation Before Task Completion

### Run this checklist for EVERY task:
```bash
# 1. Compilation check
godot --check-only project.godot

# 2. Run specific test
godot --headless --scene tests/individual/test_[system].tscn

# 3. Run integration test
godot --headless --scene tests/test_all.tscn

# 4. Check for memory leaks
godot --verbose scenes/ui/game_ui.tscn 2>&1 | grep -i "leak\|error"

# 5. Verify save/load
godot --headless --script scripts/debug/test_save_load.gd
```

## Notes for Agent Success
- ALWAYS test after each file creation
- NEVER skip the validation steps
- USE debug output liberally during development
- FOLLOW Stage 1 patterns exactly
- ASK if patterns seem unclear
- DOCUMENT edge cases discovered
- COMMIT working code frequently