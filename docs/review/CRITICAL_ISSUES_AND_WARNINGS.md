# Critical Issues, Warnings, and Gotchas

## 🔴 CRITICAL ISSUES TO ADDRESS

### 1. Missing Null Safety in Signal Chains
**Issue:** When `stamina_activity_performed` is emitted, TrainingSystem assumes creature data is valid
```gdscript
# PROBLEM: No null check before accessing creature_data
func _on_training_activity_performed(creature_data: CreatureData, activity: String, cost: int) -> void:
    var assignment = creature_training_assignments[creature_data.id]  # Can crash if creature_data is null
```
**Fix Required:** Add null checks at the beginning of all signal handlers

### 2. Race Condition: Food Consumption vs Training
**Issue:** Food is consumed immediately when training is scheduled, but training happens during weekly update
```
Timeline:
1. Monday: Schedule training, consume food ✓
2. Tuesday-Saturday: Player might sell/lose the creature
3. Sunday: Weekly update tries to train non-existent creature
```
**Current State:** System will fail silently but food is already consumed
**Fix Required:** Either:
- Refund food if creature removed before training
- Block creature removal/sale when training scheduled

### 3. System Dependency Initialization
**Issue:** Systems lazily load dependencies, can fail silently
```gdscript
# In multiple systems:
if not _collection_system:
    _collection_system = GameCore.get_system("collection")
    if not _collection_system:
        push_error("...")
        return results  # Returns partial/empty results
```
**Problem:** Downstream systems may not handle empty results correctly
**Fix Required:** Fail-fast initialization or mandatory dependency injection

### 4. Expired Creatures Still Process Activities
**Issue:** In WeeklyUpdateOrchestrator, activities are processed in STAMINA phase before expired creatures are removed in POST_UPDATE phase
```
AGING → creature expires (marked but not removed)
STAMINA → expired creature still processes training/activities
POST_UPDATE → creature finally removed
```
**Impact:** Dead creatures can gain stats and consume resources
**Fix Required:** Skip activity processing for expired creatures or remove immediately after aging

## ⚠️ IMPORTANT WARNINGS

### 1. Signal Emission During Iteration
**Warning:** Multiple places emit signals while iterating over creatures
```gdscript
for creature in active_creatures:
    perform_activity(creature, activity)  # Emits signals
    # If a listener modifies active_creatures, iteration breaks
```
**Best Practice:** Collect all changes, then apply after iteration completes

### 2. Double Signal Processing
**Warning:** Some operations trigger multiple signal paths
```
Training completion triggers:
├── stamina_activity_performed → TrainingSystem processes
├── stamina_depleted → UI updates stamina bar
├── creature_stats_changed → UI updates stats (multiple times)
└── training_completed → UI shows completion message
```
**Impact:** UI might update 4+ times for one training action
**Recommendation:** Batch UI updates or use dirty flag pattern

### 3. Stable Creatures in Limbo
**Current Design:** Stable creatures don't age, don't eat, don't train
**Problem:** No clear documentation on what happens to their:
- Stamina (does it reset?)
- Training food effects (do they expire?)
- Temporary buffs (are they paused or removed?)
**Need:** Clear stable creature state policy

### 4. Save System Rollback Incomplete
**Issue:** WeeklyUpdateOrchestrator has rollback but only snapshots some data
```gdscript
rollback_data = {
    "creatures": _snapshot_creatures(),
    "resources": _snapshot_resources(),
    "time": _snapshot_time()
    # Missing: training assignments, food effects, shop state, etc.
}
```
**Risk:** Partial rollback can leave game in inconsistent state

## 🟡 GOTCHAS AND EDGE CASES

### 1. Activity Assignment Overwrites
**Gotcha:** Assigning a new activity silently overwrites the previous one
```gdscript
assign_activity(creature, TRAINING)  # Set to training
assign_activity(creature, REST)      # Training cancelled, no warning
```
**No signals emitted for cancellation**

### 2. Training Food Waste
**Gotcha:** Training food consumed immediately, even if:
- Creature has insufficient stamina (training will fail)
- Training facility is at capacity (shouldn't happen but no double-check)
- Weekly update is blocked

### 3. Signal Bus Connection Order
**Gotcha:** Although Godot processes signals synchronously in connection order:
```gdscript
# System A connects first
signal_bus.week_advanced.connect(_on_week_advanced_A)
# System B connects second
signal_bus.week_advanced.connect(_on_week_advanced_B)
# B processes after A completes (not parallel!)
```
**BUT:** Connection order depends on system initialization order, which can change

### 4. Performance Mode Silencing
**Gotcha:** Many systems have `_performance_mode` that silences logging
```gdscript
if not _performance_mode:
    print("AI_NOTE: performance...")
```
**Problem:** When enabled, you lose visibility into performance issues

## 🔵 BEST PRACTICES REMINDERS

### 1. Always Check System Availability
```gdscript
# GOOD
var system = GameCore.get_system("system_name")
if not system:
    push_error("System not available")
    return default_value

# BAD
GameCore.get_system("system_name").some_method()  # Can crash
```

### 2. Validate Before Emitting Signals
```gdscript
# GOOD
if creature_data and creature_data.is_valid():
    signal_bus.creature_updated.emit(creature_data)

# BAD
signal_bus.creature_updated.emit(creature_data)  # Might emit null
```

### 3. Handle Partial System Failures
```gdscript
# GOOD
var result = stamina_system.process_weekly_activities()
if result.get("activities_performed", []).is_empty():
    print("Warning: No activities processed")

# BAD
var result = stamina_system.process_weekly_activities()
for activity in result.activities_performed:  # Crashes if key missing
```

### 4. Document Assumed State
```gdscript
# GOOD
func process_training():
    # Assumes: creature is in active roster
    # Assumes: training was scheduled this week
    # Assumes: stamina > training cost

# BAD
func process_training():
    # No documentation of assumptions
```

## 📋 RECOMMENDED FIXES PRIORITY

### High Priority (Game-Breaking)
1. Fix expired creature activity processing
2. Add null safety to all signal handlers
3. Fix system initialization dependencies

### Medium Priority (Data Loss/Confusion)
1. Clarify stable creature state handling
2. Complete rollback system snapshots
3. Handle food consumption race condition

### Low Priority (Polish)
1. Batch UI updates for performance
2. Add activity cancellation signals
3. Document all system assumptions

## 🔍 AREAS NEEDING INVESTIGATION

### 1. Memory Leaks
- Creatures removed from collection but still referenced in:
  - creature_training_assignments
  - creature_stamina
  - active_effects (food system)
  - creature_activities
- Need cleanup when creatures are released/expired

### 2. Signal Memory
- SignalBus tracks connections but never cleans them
- Long play sessions might accumulate dead connections

### 3. Save File Growth
- Transaction history never pruned
- Completed trainings array grows indefinitely
- Need rotation/cleanup policy

### 4. Edge Case: Week Overflow
```gdscript
if current_week > WEEKS_PER_YEAR:
    current_week = 1
    current_year += 1
```
- What happens to scheduled events at week 53+?
- Food effects with expires_week > 52?

## 🎮 PLAYER-FACING ISSUES

### 1. Confusing Feedback
- Training scheduled → immediate "food consumed" message
- Week later → "training complete" message
- Players might forget what training was scheduled

### 2. No Undo/Cancel
- Can't cancel scheduled training
- Can't refund consumed food
- Can't undo accidental creature release

### 3. Hidden State
- No UI indication of which creatures have training scheduled
- No visibility into food effect expiration
- No warning when activities will fail (insufficient stamina)

## 💡 ARCHITECTURAL RECOMMENDATIONS

### 1. Consider Command Pattern
Instead of direct signal emissions, use commands:
```gdscript
class TrainCommand:
    var creature_id: String
    var activity: int
    var food: int

    func validate() -> bool
    func execute() -> bool
    func undo() -> void
```

### 2. Add System State Validation
```gdscript
class SystemHealth:
    static func validate_all() -> Dictionary:
        return {
            "collection": _validate_collection(),
            "training": _validate_training_assignments(),
            "resources": _validate_resources()
        }
```

### 3. Implement Dirty Flag System
Instead of immediate updates on every signal:
```gdscript
var needs_ui_update: bool = false

func _on_any_change():
    needs_ui_update = true

func _process(delta):
    if needs_ui_update:
        update_ui()
        needs_ui_update = false
```

### 4. Add Transaction System
Wrap related operations in transactions:
```gdscript
var transaction = GameTransaction.begin()
transaction.consume_food(food_id)
transaction.schedule_training(creature_id, activity)
transaction.spend_gold(cost)

if transaction.can_commit():
    transaction.commit()
else:
    transaction.rollback()
```