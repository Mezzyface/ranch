# Signal Flow & Process Documentation

## Overview
This document details how signals flow through the game systems, particularly during weekly progression and activity management.

## Core Architecture

### Signal Hub
- **SignalBus** (`scripts/core/signal_bus.gd`): Central signal router
  - All systems emit signals through `GameCore.get_signal_bus()`
  - No direct system-to-system signal connections
  - Provides centralized debugging and validation

### System Access Pattern
```gdscript
var system = GameCore.get_system("system_name")
var signal_bus = GameCore.get_signal_bus()
```

## Weekly Progression Flow

### 1. Week Advance Trigger
**User Action:** Click "Next Week" button in UI

**Flow:**
1. **UI Button** → `GameController.advance_time()`
2. **GameController** → `TimeSystem.advance_week()`
3. **TimeSystem** performs:
   - Validation checks via `can_advance_time()`
   - If blocked: emits `time_advance_blocked` signal
   - If allowed: continues with update

### 2. Weekly Update Pipeline

**TimeSystem** coordinates the weekly update:

```
TimeSystem.advance_week()
├── emit: weekly_update_started
├── increment week/month/year counters
├── _process_weekly_events()
├── _trigger_system_updates()
│   └── WeeklyUpdateOrchestrator.execute_weekly_update()
├── emit: week_advanced(new_week, total_weeks)
└── emit: weekly_update_completed(duration_ms)
```

### 3. WeeklyUpdateOrchestrator Phases

**EXECUTION ORDER: STRICTLY SEQUENTIAL**
The orchestrator processes updates in this guaranteed order (each phase must complete before next begins):

```
PRE_UPDATE → AGING → STAMINA → FOOD → QUESTS → COMPETITIONS → ECONOMY → POST_UPDATE → SAVE
```

⚠️ **Important:** Each phase runs to completion before the next phase starts. This is enforced by the `for phase in update_pipeline` loop in `execute_weekly_update()`.

#### Phase Details:

**PRE_UPDATE Phase:**
- Takes snapshot for potential rollback
- Counts active/stable creatures
- No signals emitted

**AGING Phase:**
- Only ages ACTIVE creatures (stable creatures remain in stasis)
- Increments `age_weeks` by 1
- Checks for category changes
- Identifies expired creatures
- Signals: `creature_aged`, `creature_category_changed`, `creature_expired`

**STAMINA Phase (Activity Processing):**
- **Critical:** This is where activities actually happen
- Calls `StaminaSystem.process_weekly_activities()`
- **EXECUTION: SEQUENTIAL** - Creatures processed one-by-one in loop
- For each active creature with assigned activity:
  - Performs the activity (depletes/restores stamina)
  - Emits `stamina_activity_performed` signal
  - **PARALLEL LISTENERS:** Multiple systems can listen to this signal
    - TrainingSystem processes training gains
    - UI updates may occur
    - Stats tracking happens
  - All listeners process simultaneously (order not guaranteed between listeners)
- Signals: `stamina_depleted`, `stamina_restored`, `stamina_activity_performed`

**FOOD Phase:**
- Tracks food consumption for active creatures
- Food is consumed when activities are assigned (not during weekly update)
- Mainly for tracking/summary purposes

**POST_UPDATE Phase:**
- Removes expired creatures from collection
- Cleanup operations

**SAVE Phase:**
- Auto-saves game state
- Signal: `save_completed`

## Activity System Architecture

### Current Implementation (Activity-Based)

The system has been refactored from direct weekly processing to an activity-assignment model:

```
User assigns activity → StaminaSystem stores assignment → Weekly update processes assignments
```

### Activity Assignment Flow

1. **User assigns training to creature:**
   ```
   UI → TrainingSystem.schedule_training(creature, activity, facility, food)
   ├── Validate creature & facility availability
   ├── Store training details in creature_training_assignments
   ├── StaminaSystem.assign_activity(creature, TRAINING)
   ├── Consume training food immediately (if provided)
   ├── emit: training_scheduled
   └── emit: activity_assigned
   ```

2. **During weekly update (STAMINA phase):**
   ```
   StaminaSystem.process_weekly_activities()
   ├── For each active creature:
   │   ├── Get assigned activity
   │   ├── perform_activity(creature, activity)
   │   │   ├── Deplete/restore stamina based on activity
   │   │   └── emit: stamina_activity_performed
   │   └── TrainingSystem listens to stamina_activity_performed
   │       ├── If activity == "TRAINING":
   │       ├── Apply training gains based on stored assignment
   │       ├── Apply facility multipliers
   │       ├── Apply food bonuses (if active)
   │       ├── emit: training_completed
   │       └── Clear assignment (training is one-time)
   └── emit: stamina_weekly_processed
   ```

### Activity Types (StaminaSystem)
- **IDLE** (0): No stamina change
- **REST** (-20): Restores 20 stamina
- **TRAINING** (10): Costs 10 stamina, triggers training gains
- **QUEST** (15): Costs 15 stamina (future implementation)
- **COMPETITION** (25): Costs 25 stamina (future implementation)
- **BREEDING** (30): Costs 30 stamina (future implementation)

## Training System Integration

### Training Flow with Signals

1. **Schedule Training:**
   - User selects: creature, training type, facility tier, optional food
   - `training_scheduled` signal emitted
   - Training food consumed immediately
   - `training_food_consumed` signal emitted

2. **Weekly Processing:**
   - StaminaSystem performs TRAINING activity
   - `stamina_activity_performed` emitted with "TRAINING"
   - TrainingSystem catches signal, applies gains
   - `creature_stats_changed` emitted for each stat gain
   - `training_completed` emitted with gains summary

3. **Food Bonuses:**
   - FoodSystem tracks active food effects per creature
   - During training gain calculation:
     - Base gain × facility multiplier × food multiplier
   - Food effects expire after 4 weeks

## Signal Chain Examples

### Example 1: Complete Training Flow
```
User clicks "Train" button
└── UI calls TrainingSystem.schedule_training()
    ├── emit: training_scheduled
    ├── emit: activity_assigned
    └── emit: training_food_consumed (if food used)

User clicks "Next Week"
└── TimeSystem.advance_week()
    └── WeeklyUpdateOrchestrator (STAMINA phase)
        └── StaminaSystem.process_weekly_activities()
            ├── emit: stamina_activity_performed("TRAINING")
            └── TrainingSystem._on_training_activity_performed()
                ├── Apply stat gains
                ├── emit: creature_stats_changed (per stat)
                ├── emit: stamina_depleted
                └── emit: training_completed
```

### Example 2: Aging with Category Change
```
TimeSystem.advance_week()
└── WeeklyUpdateOrchestrator (AGING phase)
    ├── Increment creature.age_weeks
    ├── Check age category
    ├── emit: creature_aged
    └── emit: creature_category_changed (if category changed)
```

### Example 3: Resource Purchase
```
User buys item in shop
└── ShopSystem.purchase_item()
    ├── ResourceTracker.spend_gold()
    │   └── emit: gold_changed
    ├── ResourceTracker.add_item()
    │   └── emit: item_added
    └── emit: item_purchased
```

## Key Design Principles

1. **Centralized Signal Routing:**
   - All signals go through SignalBus
   - No direct system connections

2. **Activity-Based Processing:**
   - Activities assigned ahead of time
   - Processed during weekly update
   - One-time activities clear after processing

3. **Phase Isolation:**
   - Each update phase is independent
   - Rollback capability via snapshots
   - Clear success/failure propagation

4. **Active vs Stable Creatures:**
   - Active: participate in activities, age, consume resources
   - Stable: remain in stasis, no aging or activities

5. **Immediate vs Deferred Actions:**
   - Immediate: food consumption when training scheduled
   - Deferred: stat gains during weekly update

## Common Signal Patterns

### Validation Pattern
```gdscript
if not can_perform_action():
    emit: action_blocked(reasons)
    return false
perform_action()
emit: action_completed(result)
```

### State Change Pattern
```gdscript
var old_value = get_current_value()
apply_change()
var new_value = get_current_value()
emit: value_changed(old_value, new_value)
```

### Batch Processing Pattern
```gdscript
emit: batch_started()
for item in items:
    process_item()
    emit: item_processed(item)
emit: batch_completed(count, duration)
```

## Additional System Flows

### Shop System

**Purchase Flow:**
```
User selects item to purchase
└── ShopSystem.purchase_item(vendor_id, item_id, quantity)
    ├── Validate vendor unlocked
    ├── Check stock availability
    ├── Calculate price with modifiers
    ├── ResourceTracker.spend_gold(cost)
    │   ├── emit: transaction_failed (if insufficient)
    │   ├── emit: gold_changed
    │   └── emit: gold_spent
    ├── ResourceTracker.add_item(item_id, quantity)
    │   └── emit: item_added
    ├── Update vendor inventory
    ├── emit: item_purchased
    └── Process reputation changes
```

**Weekly Restock:**
```
TimeSystem.advance_week()
└── ShopSystem listens to week_advanced
    ├── Check weeks since last restock
    ├── For each vendor:
    │   ├── Restock items based on restock_rate
    │   └── Add special/seasonal items
    └── emit: shop_refreshed
```

### Collection System (PlayerCollection)

**Add Creature Flow:**
```
Creature acquisition (shop/quest/etc)
└── PlayerCollection.add_to_active(creature)
    ├── Validate roster space (max 6)
    ├── Remove from stable if present
    │   └── emit: stable_collection_updated
    ├── Add to active roster
    ├── Update species tracking
    ├── emit: creature_activated
    ├── emit: active_roster_changed
    └── Check/emit milestones
        └── emit: collection_milestone_reached
```

**Move to Stable:**
```
User moves creature to stable
└── PlayerCollection.move_to_stable(creature_id)
    ├── Remove from active roster
    ├── Add to stable collection
    ├── emit: creature_deactivated
    ├── emit: stable_collection_updated
    └── emit: active_roster_changed
```

### Save System

**Save Game Flow:**
```
User/System triggers save
└── SaveSystem.save_game_state(slot_name)
    ├── emit: save_progress(0%)
    ├── Create backup if exists
    │   └── emit: backup_created
    ├── Save main game data (ConfigFile)
    ├── Save creature collection
    │   ├── Active roster → ConfigFile
    │   └── Stable creatures → ResourceSaver (.tres)
    ├── Save system states
    │   ├── TimeSystem.save_time_state()
    │   ├── ResourceTracker.save_state()
    │   ├── StaminaSystem.save_state()
    │   └── TrainingSystem.save_state()
    ├── emit: save_progress(100%)
    └── emit: save_completed(success)
```

**Load Game Flow:**
```
User selects save to load
└── SaveSystem.load_game_state(slot_name)
    ├── Validate save integrity
    │   └── emit: data_corrupted (if invalid)
    ├── Load main game data
    ├── Load creature collection
    ├── Load system states
    │   └── Each system restores from data
    ├── emit: load_progress(percentage)
    └── emit: load_completed(success)
```

### Resource Tracker

**Gold Management:**
```
Any gold transaction
├── add_gold(amount, source)
│   ├── Update balance
│   ├── Log transaction
│   └── emit: gold_changed(old, new, change)
└── spend_gold(amount, purpose)
    ├── Validate sufficient funds
    ├── emit: transaction_failed (if insufficient)
    ├── Update balance
    ├── emit: gold_changed
    └── emit: gold_spent
```

**Inventory Management:**
```
Item operations
├── add_item(item_id, quantity)
│   ├── Check stack limits
│   ├── Update inventory
│   └── emit: item_added
└── remove_item(item_id, quantity)
    ├── Validate availability
    ├── Update inventory
    └── emit: item_removed
```

### Age System

**Creature Aging:**
```
Weekly update or manual aging
└── AgeSystem.age_creature_by_weeks(creature, weeks)
    ├── Calculate new age
    ├── emit: creature_aged
    ├── Check category change
    │   └── emit: creature_category_changed
    ├── Check expiration
    │   └── emit: creature_expired
    └── Apply stat modifiers if category changed
```

**Batch Aging:**
```
AgeSystem.age_all_creatures(creature_list, weeks)
├── For each creature:
│   └── age_creature_by_weeks()
└── emit: aging_batch_completed
```

### Tag System

**Tag Management:**
```
Add tag to creature
└── TagSystem.add_tag(creature, tag_name)
    ├── Validate tag exists
    ├── Check prerequisites
    ├── Check incompatibilities
    ├── Check exclusive groups
    ├── Add to creature.tags
    ├── emit: creature_tag_added
    └── emit: tag_validation_failed (if invalid)

Remove tag from creature
└── TagSystem.remove_tag(creature, tag_name)
    ├── Validate tag exists on creature
    ├── Check dependencies
    ├── Remove from creature.tags
    └── emit: creature_tag_removed
```

## Execution Order: Sequential vs Parallel

### Sequential Execution (Order Guaranteed)

These operations execute in strict sequence, one after another:

1. **Weekly Update Phases**
   - Each phase in WeeklyUpdateOrchestrator completes before next begins
   - Order: PRE_UPDATE → AGING → STAMINA → FOOD → QUESTS → COMPETITIONS → ECONOMY → POST_UPDATE → SAVE
   - Enforced by: `for phase in update_pipeline` loop

2. **Creature Processing Within Phases**
   - During AGING: creatures aged one-by-one in collection order
   - During STAMINA: activities processed creature-by-creature
   - During FOOD: consumption tracked sequentially

3. **Training Assignment Flow**
   ```
   schedule_training() [MUST COMPLETE]
   └── then → assign_activity() [MUST COMPLETE]
       └── then → consume_food() [MUST COMPLETE]
           └── then → emit signals
   ```

4. **Save/Load Operations**
   - Systems saved/loaded in specific order
   - Each system's save() must complete before next

### Parallel Execution (Order NOT Guaranteed)

These operations can happen simultaneously when triggered:

1. **Signal Listeners (Most Common Parallel Pattern)**
   ```
   stamina_activity_performed.emit()
   ├── [PARALLEL] TrainingSystem._on_training_activity_performed()
   ├── [PARALLEL] UIManager._on_activity_performed()
   ├── [PARALLEL] StatTracker._on_activity_performed()
   └── [PARALLEL] AchievementSystem._on_activity_performed()
   ```
   ⚠️ **All connected listeners fire immediately and process in parallel**

2. **Multiple Signal Emissions**
   ```
   When creature gains stats:
   ├── [PARALLEL] creature_stats_changed.emit("strength")
   ├── [PARALLEL] creature_stats_changed.emit("constitution")
   └── [PARALLEL] training_completed.emit()
   ```

3. **Cross-System Reactions**
   - Shop restock when `week_advanced` emitted
   - Auto-save when `weekly_update_completed` emitted
   - UI updates when any game state signal emitted
   - All happen independently, order varies

### Mixed Sequential/Parallel Patterns

1. **Activity Processing**
   ```
   SEQUENTIAL: For each creature in active_roster:
       └── perform_activity(creature)
           └── emit: stamina_activity_performed
               ├── [PARALLEL] All listeners process
               └── [WAIT] Next creature only after signal handled
   ```

2. **Aging with Effects**
   ```
   SEQUENTIAL: For each creature:
       └── age_creature()
           ├── emit: creature_aged [listeners process in parallel]
           ├── if category changed:
           │   └── emit: creature_category_changed [parallel]
           └── if expired:
               └── emit: creature_expired [parallel]
   ```

### Important Timing Considerations

1. **Signal Processing is Synchronous**
   - Even though listeners are "parallel", Godot processes them synchronously
   - They execute in connection order (order of `.connect()` calls)
   - But you should NEVER rely on this order

2. **Deferred Signals**
   - Some signals may use `call_deferred()` for next frame
   - These break the synchronous chain
   - Example: UI updates often deferred to avoid mid-frame changes

3. **Race Conditions to Avoid**
   - Don't assume TrainingSystem processes before UI updates
   - Don't assume one stat change completes before another
   - Always check system state, don't assume based on signal order

### Best Practices

1. **When Order Matters:** Use sequential phases (like WeeklyUpdateOrchestrator)
2. **When Order Doesn't Matter:** Use signals (multiple systems can react)
3. **Never Assume:** Signal listener execution order
4. **Always Validate:** System state before processing
5. **Use Phases:** When operations must happen in specific order

## System Dependencies & Initialization

### Initialization Order (GameCore)
```
1. SignalBus (always first)
2. Core Data Systems:
   - TagSystem
   - StatSystem
   - AgeSystem
3. Resource Systems:
   - ItemManager
   - SpeciesSystem
   - ResourceTracker
4. Creature Systems:
   - PlayerCollection
   - StaminaSystem
   - FoodSystem
5. Feature Systems:
   - TimeSystem
   - WeeklyUpdateOrchestrator
   - ShopSystem
   - TrainingSystem
6. SaveSystem (always last)
```

### System Cross-Dependencies
- **TrainingSystem** → StaminaSystem, FoodSystem, ResourceTracker
- **StaminaSystem** → PlayerCollection, TimeSystem
- **ShopSystem** → ResourceTracker, ItemManager
- **WeeklyUpdateOrchestrator** → All gameplay systems
- **SaveSystem** → All systems with persistent data
- **TimeSystem** → WeeklyUpdateOrchestrator

## Debugging Signal Flow

### Enable Debug Mode
```gdscript
var signal_bus = GameCore.get_signal_bus()
signal_bus._debug_mode = true  # Logs all connections
```

### Track Specific Signals
```gdscript
# In any system's _ready():
signal_bus.stamina_activity_performed.connect(func(c, a, cost):
    print("Activity performed: %s - %s (cost: %d)" % [c.creature_name, a, cost])
)
```

### Performance Monitoring
- TimeSystem tracks weekly update duration
- Each system can enable performance mode
- Look for "AI_NOTE: performance(...)" in output

## Future Considerations

### Planned Enhancements
1. Generic activity system for all weekly tasks
2. Priority-based activity queue
3. Multi-week activities (ongoing training programs)
4. Activity interruption/cancellation during week

### Potential Refactors
1. Move all activity processing to dedicated ActivityManager
2. Implement ISaveable interface for all systems
3. Add activity validation pipeline before week advance
4. Implement activity prerequisites and dependencies