# Task 9: Resource Tracking System Implementation

## Prerequisites
- [ ] Tasks 1-8 completed and all tests passing
- [ ] Run preflight check: `godot --headless --scene tests/preflight_check.tscn` - MUST PASS
- [ ] Run integration test: `godot --headless --scene test_setup.tscn` - Should show 100% pass rate

## Task Overview
Implement a resource tracking system that manages the game's economy: gold currency, food inventory, and consumable items. This system is critical for the shop, feeding, and quest reward mechanics. It must track resources, validate transactions, prevent cheating (negative balances), and integrate with the save system for persistence.

## Required Files to Create/Modify

### New Files to Create:
1. `scripts/systems/resource_tracker.gd` - Main ResourceTracker system
2. `tests/individual/test_resource.gd` - Individual test file
3. `tests/individual/test_resource.tscn` - Test scene
4. `scripts/data/item_database.gd` - Item definitions and metadata

### Files to Modify:
1. `scripts/core/game_core.gd` - Add ResourceTracker to lazy loading (line ~50)
2. `scripts/core/signal_bus.gd` - Add resource signals (after line ~100)
3. `test_setup.gd` - Add `_test_resource_system()` function
4. `tests/test_all.gd` - Add resource test to TESTS_TO_RUN array

## Implementation Requirements

### Core Functionality:

#### 1. Currency System
```gdscript
extends Node
class_name ResourceTracker

# Currency tracking
var gold: int = 500  # Starting gold from design doc
var transaction_history: Array[Dictionary] = []
var total_earned: int = 500
var total_spent: int = 0

func _init() -> void:
    print("ResourceTracker initialized with %d starting gold" % gold)

func add_gold(amount: int, source: String = "unknown") -> bool:
    if amount <= 0:
        push_error("Cannot add negative or zero gold")
        return false

    var old_gold: int = gold
    gold += amount
    total_earned += amount

    # Log transaction
    transaction_history.append({
        "type": "income",
        "amount": amount,
        "source": source,
        "timestamp": Time.get_ticks_msec(),
        "balance": gold
    })

    # Emit signal through SignalBus
    var signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.emit_gold_changed(old_gold, gold, amount)

    return true

func spend_gold(amount: int, purpose: String = "unknown") -> bool:
    if amount <= 0:
        push_error("Cannot spend negative or zero gold")
        return false

    if gold < amount:
        push_error("Insufficient gold: have %d, need %d" % [gold, amount])
        var signal_bus = GameCore.get_signal_bus()
        if signal_bus:
            signal_bus.emit_transaction_failed("insufficient_gold", amount)
        return false

    var old_gold: int = gold
    gold -= amount
    total_spent += amount

    # Log transaction
    transaction_history.append({
        "type": "expense",
        "amount": amount,
        "purpose": purpose,
        "timestamp": Time.get_ticks_msec(),
        "balance": gold
    })

    # Emit signal
    var signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.emit_gold_changed(old_gold, gold, -amount)

    return true

func can_afford(cost: int) -> bool:
    return gold >= cost

func get_balance() -> int:
    return gold
```

#### 2. Inventory System
```gdscript
# Inventory tracking
var inventory: Dictionary = {}  # item_id -> quantity
var max_stack_size: int = 999

func add_item(item_id: String, quantity: int = 1) -> bool:
    if quantity <= 0:
        push_error("Cannot add negative or zero quantity")
        return false

    if not ItemDatabase.is_valid_item(item_id):
        push_error("Invalid item ID: %s" % item_id)
        return false

    if item_id in inventory:
        inventory[item_id] = min(inventory[item_id] + quantity, max_stack_size)
    else:
        inventory[item_id] = quantity

    # Emit signal
    var signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.emit_item_added(item_id, quantity, inventory[item_id])

    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    if quantity <= 0:
        push_error("Cannot remove negative or zero quantity")
        return false

    if not item_id in inventory:
        push_error("Item not in inventory: %s" % item_id)
        return false

    if inventory[item_id] < quantity:
        push_error("Insufficient quantity: have %d, need %d" % [inventory[item_id], quantity])
        return false

    inventory[item_id] -= quantity
    if inventory[item_id] == 0:
        inventory.erase(item_id)

    # Emit signal
    var signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.emit_item_removed(item_id, quantity, inventory.get(item_id, 0))

    return true

func get_item_count(item_id: String) -> int:
    return inventory.get(item_id, 0)

func has_item(item_id: String, quantity: int = 1) -> bool:
    return get_item_count(item_id) >= quantity
```

#### 3. Food Management
```gdscript
# Food categories from design
enum FoodType {
    BASIC,      # Grain, Hay, Berries, Water
    TRAINING,   # Protein Mix, Endurance Blend, etc.
    PREMIUM,    # Golden Nectar, Vitality Elixir
    SPECIALTY   # Breeding Supplements, Combat Rations
}

func feed_creature(creature_id: String, food_id: String) -> bool:
    if not has_item(food_id, 1):
        push_error("No %s in inventory" % food_id)
        return false

    var food_data: Dictionary = ItemDatabase.get_item_data(food_id)
    if not food_data.has("food_type"):
        push_error("Item %s is not food" % food_id)
        return false

    # Remove food from inventory
    if not remove_item(food_id, 1):
        return false

    # Emit feeding signal for other systems to handle effects
    var signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.emit_creature_fed(creature_id, food_id, food_data)

    return true
```

#### 4. Save/Load Integration
```gdscript
func save_state() -> Dictionary:
    return {
        "gold": gold,
        "inventory": inventory,
        "total_earned": total_earned,
        "total_spent": total_spent,
        "transaction_history": transaction_history.slice(max(0, transaction_history.size() - 100))  # Last 100 transactions
    }

func load_state(data: Dictionary) -> void:
    gold = data.get("gold", 500)
    inventory = data.get("inventory", {})
    total_earned = data.get("total_earned", gold)
    total_spent = data.get("total_spent", 0)
    transaction_history = data.get("transaction_history", [])

    print("ResourceTracker loaded: %d gold, %d items" % [gold, inventory.size()])
```

### GameCore Integration:
In `scripts/core/game_core.gd`, add to `_load_system()`:
```gdscript
"resource", "resources":
    system = preload("res://scripts/systems/resource_tracker.gd").new()
```

### SignalBus Integration:
Add to `scripts/core/signal_bus.gd`:
```gdscript
# Resource signals
signal gold_changed(old_amount: int, new_amount: int, change: int)
signal item_added(item_id: String, quantity: int, total: int)
signal item_removed(item_id: String, quantity: int, remaining: int)
signal transaction_failed(reason: String, amount: int)
signal creature_fed(creature_id: String, food_id: String, food_data: Dictionary)

func emit_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
    if _validate_number_positive(old_amount, "gold_changed", "old_amount") and \
       _validate_number_positive(new_amount, "gold_changed", "new_amount"):
        gold_changed.emit(old_amount, new_amount, change)
        if _debug_mode:
            print("SignalBus: Gold changed from %d to %d (change: %d)" % [old_amount, new_amount, change])

func emit_item_added(item_id: String, quantity: int, total: int) -> void:
    if _validate_not_null(item_id, "item_added"):
        item_added.emit(item_id, quantity, total)
        if _debug_mode:
            print("SignalBus: Item added: %s x%d (total: %d)" % [item_id, quantity, total])

func emit_item_removed(item_id: String, quantity: int, remaining: int) -> void:
    if _validate_not_null(item_id, "item_removed"):
        item_removed.emit(item_id, quantity, remaining)

func emit_transaction_failed(reason: String, amount: int) -> void:
    transaction_failed.emit(reason, amount)
    if _debug_mode:
        print("SignalBus: Transaction failed: %s (amount: %d)" % [reason, amount])

func emit_creature_fed(creature_id: String, food_id: String, food_data: Dictionary) -> void:
    if _validate_not_null(creature_id, "creature_fed") and _validate_not_null(food_id, "creature_fed"):
        creature_fed.emit(creature_id, food_id, food_data)

# Helper validation
func _validate_number_positive(value: int, signal_name: String, param_name: String) -> bool:
    if value < 0:
        push_error("SignalBus: Cannot emit %s with negative %s" % [signal_name, param_name])
        return false
    return true
```

### Item Database:
Create `scripts/data/item_database.gd`:
```gdscript
class_name ItemDatabase

# Static item definitions
static var items: Dictionary = {
    # Basic Foods (25-50 gold each)
    "grain": {"name": "Grain", "type": "food", "food_type": 0, "cost": 25, "sell": 12},
    "hay": {"name": "Hay", "type": "food", "food_type": 0, "cost": 25, "sell": 12},
    "berries": {"name": "Berries", "type": "food", "food_type": 0, "cost": 30, "sell": 15},
    "water": {"name": "Fresh Water", "type": "food", "food_type": 0, "cost": 10, "sell": 5},

    # Training Foods (100-200 gold each)
    "protein_mix": {"name": "Protein Mix", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "STR+10"},
    "endurance_blend": {"name": "Endurance Blend", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "CON+10"},
    "agility_treats": {"name": "Agility Treats", "type": "food", "food_type": 1, "cost": 150, "sell": 75, "effect": "DEX+10"},

    # Premium Foods (500+ gold each)
    "golden_nectar": {"name": "Golden Nectar", "type": "food", "food_type": 2, "cost": 500, "sell": 250, "effect": "ALL+5"},
    "vitality_elixir": {"name": "Vitality Elixir", "type": "food", "food_type": 2, "cost": 750, "sell": 375, "effect": "Heal+Age"},

    # Quest Items
    "quest_gem": {"name": "Mysterious Gem", "type": "quest", "cost": 0, "sell": 0}
}

static func is_valid_item(item_id: String) -> bool:
    return item_id in items

static func get_item_data(item_id: String) -> Dictionary:
    return items.get(item_id, {})

static func get_item_cost(item_id: String) -> int:
    return items.get(item_id, {}).get("cost", 0)

static func get_item_type(item_id: String) -> String:
    return items.get(item_id, {}).get("type", "unknown")
```

## Testing Requirements

### Individual Test (`tests/individual/test_resource.gd`):
```gdscript
extends Node

func _ready() -> void:
    print("=== Resource Tracker Test ===")

    var resource_system = GameCore.get_system("resource")
    assert(resource_system != null, "Failed to load ResourceTracker")

    # Test 1: Gold operations
    var initial_gold: int = resource_system.get_balance()
    print("Initial gold: %d" % initial_gold)

    assert(resource_system.add_gold(100, "test"), "Failed to add gold")
    assert(resource_system.gold == initial_gold + 100, "Gold not added correctly")
    print("✅ Gold addition working")

    assert(resource_system.spend_gold(50, "test"), "Failed to spend gold")
    assert(resource_system.gold == initial_gold + 50, "Gold not spent correctly")
    print("✅ Gold spending working")

    assert(not resource_system.spend_gold(99999, "test"), "Should fail with insufficient gold")
    print("✅ Insufficient gold check working")

    # Test 2: Inventory operations
    assert(resource_system.add_item("grain", 5), "Failed to add item")
    assert(resource_system.get_item_count("grain") == 5, "Item count incorrect")
    print("✅ Item addition working")

    assert(resource_system.remove_item("grain", 2), "Failed to remove item")
    assert(resource_system.get_item_count("grain") == 3, "Item removal incorrect")
    print("✅ Item removal working")

    # Test 3: Save/Load
    var saved_state: Dictionary = resource_system.save_state()
    resource_system.gold = 0
    resource_system.inventory.clear()

    resource_system.load_state(saved_state)
    assert(resource_system.gold > 0, "Gold not restored")
    assert(resource_system.inventory.size() > 0, "Inventory not restored")
    print("✅ Save/Load working")

    print("✅ Resource Tracker test complete!")
    get_tree().quit(0)
```

## Validation Requirements

### CRITICAL Property Names:
- Use `gold` NOT `money` or `coins`
- Use `inventory` NOT `items` or `bag`
- Use `item_id` NOT `item_name` or `id`

### Method Patterns:
- Transaction methods return `bool` for success/failure
- All amounts must be positive integers
- Check affordability with `can_afford()` before spending
- Use `has_item()` before removing items

### Array Typing:
- `transaction_history: Array[Dictionary]`
- NOT just `Array` or `var transaction_history = []`

### Signal Integration:
- All signals emit through SignalBus
- Validate data before emission
- Include old and new values for state changes

## Performance Targets
- [ ] System initialization: <10ms
- [ ] Gold transactions: <1ms each
- [ ] Inventory operations: <5ms for 100 items
- [ ] Save/Load: <50ms for full state

## AI Agent Checklist

### Before Starting:
1. ✅ Run: `godot --headless --scene tests/preflight_check.tscn`
2. ✅ Verify it shows: "ALL CHECKS PASSED"
3. ✅ Review `docs/development/API_REFERENCE.md` for patterns
4. ✅ Check quiet mode is enabled in test_setup.gd (line 11)

### During Implementation:
1. Create ResourceTracker system first
2. Add to GameCore lazy loading
3. Add signals to SignalBus with validation
4. Create ItemDatabase with static data
5. Write individual test
6. Add integration test to test_setup.gd
7. Run tests frequently to catch errors early

### Before Completion:
1. Run: `godot --headless --scene tests/individual/test_resource.tscn`
2. Run: `godot --headless --scene test_setup.tscn`
3. Verify: "Status: SUCCESS"
4. Check no compilation errors in console

## Common Pitfalls to Avoid
- ❌ Don't allow negative gold balances
- ❌ Don't allow negative quantities
- ❌ Don't forget to validate item IDs
- ❌ Don't use untyped arrays
- ❌ Don't emit signals without validation
- ❌ Don't access resource system without `GameCore.get_system("resource")`

## Success Criteria
- [ ] All currency operations validated (no negative balances)
- [ ] Inventory management with stack limits
- [ ] Item database with food definitions
- [ ] SignalBus integration for all state changes
- [ ] Save/Load preserves complete state
- [ ] Individual test passes
- [ ] Integration test passes
- [ ] No parse errors or warnings
- [ ] Performance targets met

## Example Usage After Implementation
```gdscript
# Get the resource system
var resources = GameCore.get_system("resource")

# Gold operations
if resources.can_afford(100):
    resources.spend_gold(100, "bought_creature")

resources.add_gold(250, "quest_reward")

# Inventory operations
resources.add_item("grain", 10)
if resources.has_item("grain", 5):
    resources.feed_creature(creature.id, "grain")

# Check balance
print("Current gold: %d" % resources.get_balance())
print("Grain count: %d" % resources.get_item_count("grain"))
```

## Notes
- Start with 500 gold as per design document
- Food costs from design: Basic (25-50g), Training (100-200g), Premium (500+g)
- Transaction history limited to last 100 entries for performance
- All operations must be atomic (succeed or fail completely)
- This system will be used by Shop, Quest, and Feeding systems later