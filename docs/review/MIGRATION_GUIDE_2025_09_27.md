# Migration Guide - 2025-09-27 Architecture Improvements

This guide documents architectural changes made to address critical issues identified in the codebase review.

## Overview of Changes

### 1. Type-Safe System Access via SystemKey Enum
- **What changed**: Added `GlobalEnums.SystemKey` enum for type-safe system access
- **Why**: Eliminates magic strings, prevents typos, enables compile-time checking
- **Migration required**: Optional - string access still works for backwards compatibility

### 2. Signal Migration to Centralized SignalBus
- **What changed**: Migrated GameController and UIManager signals to SignalBus
- **Why**: Centralizes signal routing, adds validation, prevents signal routing issues
- **Migration required**: Yes - update signal connections in UI code

### 3. Memory Cleanup via creature_cleanup_required Signal
- **What changed**: Added cleanup signal system for proper memory management
- **Why**: Prevents memory leaks when creatures are removed from collection
- **Migration required**: No - systems already updated

### 4. Expired Creature Processing Fix
- **What changed**: WeeklyUpdateOrchestrator now tracks and skips expired creatures
- **Why**: Prevents dead creatures from gaining stats and processing activities
- **Migration required**: No - transparent fix

### 5. Fail-Fast System Initialization
- **What changed**: Systems now explicitly report initialization failures
- **Why**: Makes debugging easier, prevents silent failures
- **Migration required**: No - internal improvement

## Migration Steps

### Step 1: Update System Access (Optional but Recommended)

**Before:**
```gdscript
var collection = GameCore.get_system("collection")
var time = GameCore.get_system("time")
var stamina = GameCore.get_system("stamina")
```

**After:**
```gdscript
var collection = GameCore.get_system(GlobalEnums.SystemKey.COLLECTION)
var time = GameCore.get_system(GlobalEnums.SystemKey.TIME)
var stamina = GameCore.get_system(GlobalEnums.SystemKey.STAMINA)
```

Available SystemKey values:
- `COLLECTION`, `TIME`, `SAVE`, `TRAINING`, `FOOD`
- `RESOURCE_TRACKER`, `STAMINA`, `SHOP`, `QUEST`
- `AGE`, `TAG`, `STAT`, `SPECIES`
- `ITEM_MANAGER`, `UI_MANAGER`, `WEEKLY_ORCHESTRATOR`

### Step 2: Update Signal Connections (Required)

**GameController Signals**

Before:
```gdscript
# In UI code
game_controller.creatures_updated.connect(_on_creatures_updated)
game_controller.scene_change_requested.connect(_on_scene_change)
game_controller.game_loaded.connect(_on_game_loaded)
game_controller.game_saved.connect(_on_game_saved)
game_controller.main_menu_requested.connect(_on_main_menu)
game_controller.quit_requested.connect(_on_quit)
```

After:
```gdscript
# In UI code
var signal_bus = GameCore.get_signal_bus()
signal_bus.creatures_updated.connect(_on_creatures_updated)
signal_bus.scene_change_requested.connect(_on_scene_change)
signal_bus.game_loaded.connect(_on_game_loaded)
signal_bus.game_saved.connect(_on_game_saved)
signal_bus.main_menu_requested.connect(_on_main_menu)
signal_bus.quit_requested.connect(_on_quit)
```

**UIManager Signals**

Before:
```gdscript
# In UI code
ui_manager.scene_changed.connect(_on_scene_changed)
ui_manager.scene_load_failed.connect(_on_load_failed)
ui_manager.window_shown.connect(_on_window_shown)
ui_manager.window_hidden.connect(_on_window_hidden)
ui_manager.all_windows_closed.connect(_on_all_closed)
```

After:
```gdscript
# In UI code
var signal_bus = GameCore.get_signal_bus()
signal_bus.scene_changed.connect(_on_scene_changed)
signal_bus.scene_load_failed.connect(_on_load_failed)
signal_bus.window_shown.connect(_on_window_shown)
signal_bus.window_hidden.connect(_on_window_hidden)
signal_bus.all_windows_closed.connect(_on_all_closed)
```

### Step 3: Update Signal Emissions (Required)

**GameController Emissions**

Before:
```gdscript
# In GameController
creatures_updated.emit()
scene_change_requested.emit(path)
game_loaded.emit()
game_saved.emit()
main_menu_requested.emit()
quit_requested.emit()
```

After:
```gdscript
# In GameController
_signal_bus.emit_creatures_updated()
_signal_bus.emit_scene_change_requested(path)
_signal_bus.emit_game_loaded()
_signal_bus.emit_game_saved()
_signal_bus.emit_main_menu_requested()
_signal_bus.emit_quit_requested()
```

**UIManager Emissions**

Before:
```gdscript
# In UIManager
scene_changed.emit(new_scene_path)
scene_load_failed.emit(scene_path, "Failed to load")
window_shown.emit(window_name)
window_hidden.emit(window_name)
all_windows_closed.emit()
```

After:
```gdscript
# In UIManager
_signal_bus.emit_scene_changed(new_scene_path)
_signal_bus.emit_scene_load_failed(scene_path, "Failed to load")
_signal_bus.emit_window_shown(window_name)
_signal_bus.emit_window_hidden(window_name)
_signal_bus.emit_all_windows_closed()
```

## New System Behavior

### Memory Cleanup
Systems now automatically clean up when creatures are removed:
- StaminaSystem clears stamina and activity data
- TrainingSystem clears training assignments
- FoodSystem clears active food effects
- No action required - this happens automatically

### Expired Creature Handling
Expired creatures are now properly handled:
- Tracked in `expired_creature_ids` array during weekly updates
- Skipped in all processing phases after expiration
- Cleanup signal emitted for each expired creature
- No action required - this is transparent

### Fail-Fast Dependencies
Systems now report initialization failures clearly:
```
StaminaSystem: CRITICAL - Collection system not available. Cannot initialize.
```
Instead of silent failures, making debugging much easier.

## Testing Your Migration

After migrating, test the following:

1. **Signal Connections**: Verify all UI updates still work
2. **System Access**: Check that systems load correctly
3. **Weekly Updates**: Run a few weekly cycles and verify no errors
4. **Memory Usage**: Monitor for any unusual memory growth
5. **Error Messages**: Check console for any new error messages

## Rollback Plan

If issues occur:

1. **System Access**: String-based access still works, no rollback needed
2. **Signals**: Keep both old and new connections temporarily:
```gdscript
# Temporary dual connection during migration
game_controller.creatures_updated.connect(_on_creatures_updated)  # Old
signal_bus.creatures_updated.connect(_on_creatures_updated)       # New
```
3. **Test thoroughly** before removing old connections

## Benefits After Migration

- **Type Safety**: Compile-time checking of system names
- **Better Debugging**: Clear error messages for initialization failures
- **Memory Efficiency**: Proper cleanup of removed creatures
- **Signal Validation**: All signals validated before emission
- **No Dead Creature Bugs**: Expired creatures can't gain stats or perform activities

## Questions or Issues?

If you encounter any problems during migration:
1. Check error messages in the console
2. Verify signal connections are updated
3. Ensure UI code uses SignalBus instead of direct controller signals
4. Report issues at https://github.com/anthropics/claude-code/issues