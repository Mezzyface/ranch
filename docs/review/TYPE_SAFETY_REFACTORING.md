# Type Safety Refactoring Requirements

## Overview
This document identifies all places where the codebase uses strings, dictionaries, or other type-unsafe patterns that should be replaced with enums, Resources, or strongly-typed classes.

## 🔴 CRITICAL: Magic Strings

### 1. System Keys (Used Everywhere)
**Current Pattern:**
```gdscript
GameCore.get_system("collection")
GameCore.get_system("time")
GameCore.get_system("save")
GameCore.get_system("training")
GameCore.get_system("food")
GameCore.get_system("resource")
GameCore.get_system("stamina")
GameCore.get_system("shop")
GameCore.get_system("quest")
GameCore.get_system("age")
GameCore.get_system("tag")
GameCore.get_system("stat")
GameCore.get_system("species")
GameCore.get_system("item_manager")
GameCore.get_system("ui")
```

**Problems:**
- Typos cause runtime failures
- No autocomplete
- No compile-time checking
- Inconsistent naming (resource vs resources)

**Solution: Create SystemKeys Enum**
```gdscript
# In global_enums.gd
enum SystemKey {
    COLLECTION,
    TIME,
    SAVE,
    TRAINING,
    FOOD,
    RESOURCE_TRACKER,
    STAMINA,
    SHOP,
    QUEST,
    AGE,
    TAG,
    STAT,
    SPECIES,
    ITEM_MANAGER,
    UI_MANAGER,
    WEEKLY_ORCHESTRATOR
}

# Updated usage:
GameCore.get_system(SystemKey.COLLECTION)
```

### 2. Creature Source/Reason Strings
**Current Pattern:**
```gdscript
signal creature_acquired(creature_data: CreatureData, source: String)  # "shop", "quest", "breeding", "gift"
signal creature_released(creature_data: CreatureData, reason: String)  # "sold", "expired", "released", "sacrificed"
```

**Solution: Create Enums**
```gdscript
enum CreatureSource {
    SHOP,
    QUEST,
    BREEDING,
    GIFT,
    STARTER,
    DEBUG
}

enum ReleaseReason {
    SOLD,
    EXPIRED,
    RELEASED,
    SACRIFICED,
    TRADED
}

# Updated signals:
signal creature_acquired(creature_data: CreatureData, source: CreatureSource)
signal creature_released(creature_data: CreatureData, reason: ReleaseReason)
```

### 3. Transaction/Failure Reasons
**Current Pattern:**
```gdscript
signal transaction_failed(reason: String, amount: int)  # "insufficient_gold", "inventory_full", etc.
spend_gold(amount, "rollback")
add_gold(amount, "quest_reward")
```

**Solution: Create Enums**
```gdscript
enum TransactionFailureReason {
    INSUFFICIENT_GOLD,
    INVENTORY_FULL,
    ITEM_NOT_FOUND,
    INVALID_QUANTITY,
    VENDOR_LOCKED
}

enum GoldSource {
    QUEST_REWARD,
    ITEM_SALE,
    ACHIEVEMENT,
    DEBUG,
    ROLLBACK
}

enum GoldExpense {
    ITEM_PURCHASE,
    TRAINING_FEE,
    HEALING,
    UPGRADE,
    ROLLBACK
}
```

### 4. Activity Names (Partial Implementation)
**Current Issue:**
```gdscript
# StaminaSystem has enum:
enum Activity { IDLE, REST, TRAINING, QUEST, COMPETITION, BREEDING }

# But TrainingSystem checks string:
if activity != "TRAINING":  # Should use enum
```

**Solution: Use Existing Enum Consistently**
```gdscript
# Fix in training_system.gd:
if activity != StaminaSystem.Activity.TRAINING:
```

### 5. UI Window/Scene Names
**Current Pattern:**
```gdscript
ui_manager.show_window("shop")
ui_manager.change_scene("res://scenes/ui/game_ui.tscn")
if _current_view == "shop":
```

**Solution: Create Constants or Enum**
```gdscript
enum UIWindow {
    SHOP,
    INVENTORY,
    COLLECTION,
    SETTINGS,
    HELP
}

class_name UIScenes
const MAIN_MENU = "res://scenes/ui/main_menu.tscn"
const GAME_UI = "res://scenes/ui/game_ui.tscn"
const SETTINGS = "res://scenes/ui/settings.tscn"
```

## 🟡 DICTIONARIES THAT SHOULD BE RESOURCES

### 1. Training Assignment Data
**Current Pattern:**
```gdscript
creature_training_assignments[creature_id] = {
    "activity": activity,
    "facility_tier": facility_tier,
    "food_type": food_type
}
```

**Solution: Create Resource**
```gdscript
class_name TrainingAssignment extends Resource
@export var activity: TrainingSystem.TrainingActivity
@export var facility_tier: TrainingSystem.FacilityTier
@export var food_type: int
@export var scheduled_week: int
```

### 2. Food Effect Data
**Current Pattern:**
```gdscript
active_effects[creature_id] = {
    "food_type": food_type,
    "expires_week": expires_week
}
```

**Solution: Create Resource**
```gdscript
class_name FoodEffect extends Resource
@export var food_type: FoodSystem.TrainingFoodType
@export var expires_week: int
@export var multiplier: float = 1.5
```

### 3. Transaction History
**Current Pattern:**
```gdscript
transaction_history.append({
    "type": "income",
    "amount": amount,
    "source": source,
    "timestamp": Time.get_ticks_msec(),
    "balance": gold
})
```

**Solution: Create Resource**
```gdscript
class_name Transaction extends Resource
enum Type { INCOME, EXPENSE }
@export var type: Type
@export var amount: int
@export var source: GoldSource  # or expense: GoldExpense
@export var timestamp: int
@export var balance_after: int
```

### 4. Stock Information
**Current Pattern:**
```gdscript
inventory[item_id] = {
    "stock_quantity": int(10 * vendor.inventory_size_multiplier),
    "max_stock": int(15 * vendor.inventory_size_multiplier),
    "restock_rate": 2,
    "base_price": int(item_resource.base_price * vendor.markup_modifier)
}
```

**Solution: Create Resource**
```gdscript
class_name StockInfo extends Resource
@export var stock_quantity: int
@export var max_stock: int
@export var restock_rate: int
@export var base_price: int
@export var last_restock_week: int = 0
```

### 5. Collection Metadata
**Current Pattern:**
```gdscript
var collection_metadata: Dictionary = {
    "total_acquired": 0,
    "total_released": 0,
    "species_counts": {},
    "acquisition_history": [],
    "milestones_reached": []
}
```

**Solution: Create Resource**
```gdscript
class_name CollectionStats extends Resource
@export var total_acquired: int = 0
@export var total_released: int = 0
@export var species_counts: Dictionary = {}  # species_id -> count
@export var acquisition_history: Array[AcquisitionRecord] = []
@export var milestones_reached: Array[String] = []
```

## 🟠 RETURN TYPE ISSUES

### 1. Functions Returning Generic Dictionaries
**Pattern Found:**
```gdscript
func check_age_category_change() -> Dictionary:
func get_age_distribution() -> Dictionary:
func calculate_age_performance_impact() -> Dictionary:
func advance_week() -> Dictionary:
func process_aging_events() -> Dictionary:
func validate_creature_age() -> Dictionary:
func get_active_food_effect() -> Dictionary:
func get_item_data() -> Dictionary:
func apply_item_to_creature() -> Dictionary:
```

**Problem:** No type safety, unclear what keys exist

**Solution: Create Result Classes**
```gdscript
class_name AgeChangeResult extends Resource
@export var changed: bool = false
@export var old_category: GlobalEnums.AgeCategory
@export var new_category: GlobalEnums.AgeCategory
@export var modifier_change: float = 0.0

class_name ValidationResult extends Resource
@export var valid: bool = true
@export var errors: Array[String] = []
@export var warnings: Array[String] = []

class_name OperationResult extends Resource
@export var success: bool = true
@export var message: String = ""
@export var data: Resource = null  # Polymorphic result data
```

### 2. Search/Filter Criteria
**Current Pattern:**
```gdscript
if criteria.has("species") and creature.species_id != criteria.species:
if matches and criteria.has("required_tags"):
```

**Solution: Create Filter Class**
```gdscript
class_name CreatureFilter extends Resource
@export var species_id: String = ""
@export var min_level: int = 0
@export var max_level: int = 999
@export var required_tags: Array[String] = []
@export var excluded_tags: Array[String] = []
@export var age_category: GlobalEnums.AgeCategory = -1
```

## 🔵 STRING ARRAYS THAT SHOULD BE TYPED

### 1. Tag Arrays
**Current:**
```gdscript
@export var tags: Array[String] = []
```

**Future (when tag system migrated):**
```gdscript
@export var tags: Array[GlobalEnums.CreatureTag] = []
```

### 2. Milestone Names
**Current:**
```gdscript
const MILESTONES: Dictionary = {
    "first_creature": 1,
    "small_collection": 5,
    # etc
}
```

**Should Be:**
```gdscript
enum CollectionMilestone {
    FIRST_CREATURE = 1,
    SMALL_COLLECTION = 5,
    GROWING_COLLECTION = 10,
    LARGE_COLLECTION = 25,
    HUGE_COLLECTION = 50,
    MASTER_COLLECTION = 100
}
```

## 📊 IMPACT ANALYSIS

### High Impact Refactors (Breaking Changes):
1. **System Keys** - Touches every system (17+ files)
2. **Creature Source/Reason** - Affects signals and save data
3. **Activity String Checks** - Minor but critical for correctness

### Medium Impact:
1. **Transaction History** - Save data format change
2. **Training Assignments** - Active game state
3. **Food Effects** - Active buffs system

### Low Impact (Internal Only):
1. **Return Types** - API improvement, no data changes
2. **UI Constants** - Frontend only
3. **Filter Criteria** - New feature support

## 🎯 REFACTORING PRIORITY

### Phase 1: Non-Breaking Improvements
1. Fix `activity != "TRAINING"` to use enum ✓ Easy
2. Create result classes for return types
3. Add enums alongside strings (backwards compatible)

### Phase 2: System Keys (Most Value)
1. Create SystemKey enum
2. Update GameCore to accept both string and enum
3. Migrate all systems to use enum
4. Deprecate string access

### Phase 3: Signal Parameters
1. Add source/reason enums
2. Update signal signatures
3. Migrate all emitters and listeners
4. Update save/load

### Phase 4: Data Structures
1. Create Resource classes
2. Add migration functions
3. Update systems to use Resources
4. Migrate save data

## 💡 IMPLEMENTATION STRATEGY

### 1. Backwards Compatibility Approach
```gdscript
# In GameCore
func get_system(key):
    if key is String:
        push_warning("String system keys deprecated, use SystemKey enum")
        key = _string_to_system_key(key)

    if key is SystemKey:
        return _systems.get(_system_key_to_string(key))
```

### 2. Migration Helpers
```gdscript
# For save data migration
static func migrate_dictionary_to_resource(dict: Dictionary, resource_type: GDScript) -> Resource:
    var resource = resource_type.new()
    for key in dict:
        if resource.has(key):
            resource.set(key, dict[key])
    return resource
```

### 3. Validation Functions
```gdscript
# Add to each system
func validate_types() -> bool:
    var valid = true
    for assignment in creature_training_assignments.values():
        if not assignment is TrainingAssignment:
            push_error("Invalid assignment type")
            valid = false
    return valid
```

## ⚠️ WARNINGS

1. **Save Compatibility:** Many changes affect save format
2. **Signal Compatibility:** Changing parameters breaks listeners
3. **Mod Support:** If planning mod support, string keys might be needed
4. **Performance:** Resources are heavier than Dictionaries
5. **Editor Integration:** Resources show better in Inspector

## 📋 CHECKLIST

### Immediate Actions (No Breaking Changes):
- [ ] Fix `activity != "TRAINING"` string comparison
- [ ] Create GlobalEnums entries for all magic strings
- [ ] Add type hints to all Dictionary parameters
- [ ] Document expected Dictionary keys in comments

### Short Term (Minor Breaking Changes):
- [ ] Implement SystemKey enum
- [ ] Create result classes for return types
- [ ] Add source/reason enums

### Long Term (Major Refactor):
- [ ] Convert all data Dictionaries to Resources
- [ ] Implement full type safety
- [ ] Remove all magic strings
- [ ] Add compile-time type checking

## 🚀 BENEFITS AFTER REFACTORING

1. **Autocomplete:** IDEs can suggest valid values
2. **Compile-time Checks:** Errors caught before runtime
3. **Refactoring Safety:** Rename enums updates all uses
4. **Documentation:** Types are self-documenting
5. **Performance:** Enum comparisons faster than strings
6. **Debugging:** Easier to track valid values
7. **Maintenance:** Fewer typo-related bugs