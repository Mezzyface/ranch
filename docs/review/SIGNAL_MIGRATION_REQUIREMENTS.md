# Signal Pattern Migration Requirements

## Overview
This document identifies all places where the codebase violates the central SignalBus pattern and needs migration.

## ❌ VIOLATIONS FOUND

### 1. GameController - Local Signals (HIGH PRIORITY)
**Location:** `scripts/controllers/game_controller.gd`

**Violations:**
```gdscript
# Lines 4-9: Defines its own signals
signal game_state_changed()
signal creatures_updated()
signal resources_updated()
signal time_updated()
signal training_data_updated()
signal food_inventory_updated()

# Lines 125-238: Emits directly
time_updated.emit()
game_state_changed.emit()
creatures_updated.emit()
resources_updated.emit()
```

**Impact:** UI components connect directly to GameController instead of SignalBus, creating tight coupling

**Migration Required:**
1. Move these signals to SignalBus
2. Add emission helpers in SignalBus
3. Update GameController to use `signal_bus.emit_*()` pattern
4. Update all UI components that connect to GameController signals

### 2. UIManager - Local UI Signals
**Location:** `scripts/ui/ui_manager.gd`

**Violations:**
```gdscript
# Lines 4-8: Defines its own signals
signal scene_changed(new_scene: String)
signal window_opened(window_name: String)
signal window_closed(window_name: String)
signal transition_started()
signal transition_completed()

# Direct emissions throughout file
scene_changed.emit(scene_path)
window_opened.emit(window_name)
window_closed.emit(window_name)
transition_started.emit()
transition_completed.emit()
```

**Impact:** UI state changes bypass central signal routing, making debugging difficult

**Migration Required:**
1. Add UI signals to SignalBus
2. Create UI section in SignalBus
3. Implement validation helpers
4. Update all UI listeners

### 3. UI Components - Widget-Level Signals
**Location:** Multiple UI components

#### CreatureCard (`scripts/ui/creature_card.gd`)
```gdscript
signal dragged(creature: CreatureData, card: CreatureCard)
signal dropped(creature: CreatureData, slot: int)
signal clicked(creature: CreatureData)
```

#### CreatureListItem (`scripts/ui/creature_list_item.gd`)
```gdscript
signal dragged(creature: CreatureData, item: CreatureListItem)
signal clicked(creature: CreatureData)
signal double_clicked(creature: CreatureData)
```

#### ShopItemCard (`scripts/ui/shop_item_card.gd`)
```gdscript
signal item_selected(item: Dictionary)
```

#### SceneTransition (`scripts/ui/scene_transition.gd`)
```gdscript
signal transition_started()
signal transition_halfway()
signal transition_completed()
```

**Impact:** UI interactions not centrally trackable, can't implement global UI event handling

**Migration Decision Needed:**
- Option A: Keep widget signals local (standard Godot pattern for UI)
- Option B: Route through SignalBus for consistency (unusual but centralized)

### 4. WeeklyEvent - Direct Signal Emissions
**Location:** `scripts/core/weekly_event.gd`

**Pattern Found:**
```gdscript
# Likely emitting directly to SignalBus
signal_bus.weekly_event_triggered.emit(self)
```

**Status:** Already using SignalBus correctly ✓

## ✅ CORRECT IMPLEMENTATIONS (For Reference)

These systems follow the pattern correctly:

### StaminaSystem
```gdscript
# Correct pattern:
if _signal_bus:
    _signal_bus.stamina_depleted.emit(creature, actual_depletion)
    _signal_bus.stamina_restored.emit(creature, actual_recovery)
```

### TrainingSystem
```gdscript
# Correct pattern:
if _signal_bus:
    _signal_bus.training_scheduled.emit(creature, activity, facility)
    _signal_bus.training_completed.emit(creature, activity, gains)
```

### PlayerCollection
```gdscript
# Uses emission helpers (best practice):
signal_bus.emit_creature_activated(creature_data)
signal_bus.emit_active_roster_changed(active_roster.duplicate())
```

## 📋 MIGRATION PRIORITY

### Phase 1: Core System Signals (CRITICAL)
1. **GameController signals** → SignalBus
   - These affect game state and need central routing
   - Many systems likely listen to these

### Phase 2: UI State Signals (HIGH)
2. **UIManager signals** → SignalBus
   - Scene transitions should be trackable
   - Window management needs central control

### Phase 3: Decision Required (MEDIUM)
3. **UI Widget signals** → Evaluate
   - May keep local per Godot conventions
   - Or migrate for complete centralization

## 🔧 MIGRATION STEPS

### For GameController:

1. **Add to SignalBus (`signal_bus.gd`):**
```gdscript
# === GAME STATE SIGNALS ===
signal game_state_changed()
signal creatures_updated()
signal resources_updated()
signal time_updated()
signal training_data_updated()
signal food_inventory_updated()

# === EMISSION HELPERS ===
func emit_game_state_changed() -> void:
    if _debug_mode:
        print("SignalBus: Game state changed")
    game_state_changed.emit()

func emit_creatures_updated() -> void:
    if _debug_mode:
        print("SignalBus: Creatures updated")
    creatures_updated.emit()
# ... etc
```

2. **Update GameController:**
```gdscript
# Remove signal definitions (lines 4-9)
# Update emissions:
# OLD: time_updated.emit()
# NEW: signal_bus.emit_time_updated()
```

3. **Update UI Connections:**
Find all UI components connecting to GameController:
```gdscript
# OLD: game_controller.creatures_updated.connect(_on_creatures_updated)
# NEW: signal_bus.creatures_updated.connect(_on_creatures_updated)
```

### For UIManager:

Similar process but add UI-specific validation:
```gdscript
func emit_scene_changed(scene_path: String) -> void:
    if scene_path.is_empty():
        push_error("SignalBus: Cannot emit scene_changed with empty path")
        return
    if _debug_mode:
        print("SignalBus: Scene changed to %s" % scene_path)
    scene_changed.emit(scene_path)
```

## ⚠️ BREAKING CHANGES

### Systems Affected by Migration:
1. **All UI panels** that connect to GameController
2. **SaveSystem** if it listens to game_state_changed
3. **Any custom UI** that uses UIManager signals
4. **Tutorial/Help systems** that track UI state

### Backwards Compatibility Strategy:
```gdscript
# Temporary bridge in GameController:
func _ready():
    # Forward signals during migration
    signal_bus.game_state_changed.connect(func(): game_state_changed.emit())
    # Remove after all listeners migrated
```

## 🎯 BENEFITS AFTER MIGRATION

1. **Centralized Debugging:** All signals flow through one place
2. **Event Recording:** Can implement replay system
3. **Performance Monitoring:** Track signal frequency/timing
4. **Validation:** Consistent null/error checking
5. **Documentation:** All signals in one file

## 📊 METRICS

### Current State:
- **Total Systems:** 17
- **Using SignalBus Correctly:** 13 (76%)
- **Need Migration:** 3 (18%)
- **UI Components (Debatable):** 4+ (6%)

### Target State:
- **Core Systems:** 100% using SignalBus
- **UI State:** 100% using SignalBus
- **UI Widgets:** Decision pending

## 🔍 VALIDATION CHECKLIST

After migration, verify:
- [ ] No `signal` definitions outside SignalBus (except UI widgets if kept local)
- [ ] No direct `.emit()` outside SignalBus emission helpers
- [ ] All systems use `signal_bus.emit_*()` or `_signal_bus.*emit()`
- [ ] Debug mode shows all signal flow
- [ ] No broken UI connections
- [ ] Save/Load still works
- [ ] Weekly updates process correctly

## 💡 RECOMMENDATIONS

1. **Immediate Action:** Migrate GameController signals (breaks save compatibility if delayed)

2. **Next Sprint:** Migrate UIManager for better UI debugging

3. **Design Decision Needed:**
   - Should UI widget signals (clicked, dragged) go through SignalBus?
   - Pros: Complete centralization, global UI event handling
   - Cons: Unusual pattern, more boilerplate, performance overhead

4. **Add Signal Categories to SignalBus:**
```gdscript
# === CATEGORIES ===
# Core System Signals (creature, time, save)
# Game State Signals (from GameController)
# UI State Signals (from UIManager)
# UI Widget Signals (if migrated)
# Economy Signals
# Combat Signals (future)
```

5. **Implement Signal Metrics:**
```gdscript
var _signal_counts: Dictionary = {}

func _track_signal(signal_name: String) -> void:
    if not _signal_counts.has(signal_name):
        _signal_counts[signal_name] = 0
    _signal_counts[signal_name] += 1
```