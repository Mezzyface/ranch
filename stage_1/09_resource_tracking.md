# Task 09: Resource Tracking System

## Overview
Implement the resource tracking system for managing player gold, food inventory, items, and other consumable resources throughout the game.

## Dependencies
- Task 01: Project Setup (complete)
- Task 07: Save/Load System (complete)
- Design documents: `game.md`, `food.md`, `shop.md`

## Context
From the design documents:
- Gold is the primary currency for purchasing creatures and items
- Food items affect training effectiveness and creature performance
- Starting resources: 500 gold + basic food supplies
- Resources must persist through save/load
- Track spending and earning for statistics

## Requirements

### Resource Types
1. **Currency**
   - Gold: Primary currency
   - Premium currency (future expansion)

2. **Food Items**
   - Basic rations (Grain, Hay, Berries)
   - Training foods (stat-specific)
   - Competition foods
   - Premium foods

3. **Special Items**
   - Quest rewards
   - Rare items
   - Breeding items
   - Facility upgrades

4. **Consumables**
   - Temporary boosters
   - Medicine/healing items
   - Stamina restorers

### Tracking Features
1. **Inventory Management**
   - Item quantities
   - Stack limits
   - Item categories
   - Expiration (if applicable)

2. **Transaction History**
   - Purchase records
   - Quest rewards
   - Competition winnings
   - Spending tracking

3. **Resource Validation**
   - Prevent negative values
   - Check affordability
   - Validate transactions
   - Handle edge cases

## Implementation Steps

1. **Create Resource Definitions**
   - Item database
   - Food definitions
   - Currency types

2. **Implement ResourceManager**
   - Resource tracking
   - Transaction methods
   - Validation logic
   - Event signals

3. **Create Inventory System**
   - Item storage
   - Quantity management
   - Category organization
   - Usage tracking

4. **Add Transaction System**
   - Purchase validation
   - Resource spending
   - Reward distribution
   - History tracking

## Test Criteria

### Unit Tests
- [ ] Add and subtract gold correctly
- [ ] Food inventory tracks quantities
- [ ] Cannot spend more than available
- [ ] Negative resources prevented
- [ ] Item stacking works correctly

### Transaction Tests
- [ ] Purchases deduct correct amounts
- [ ] Rewards add to inventory
- [ ] Batch transactions work
- [ ] Transaction history records accurately
- [ ] Rollback on failed transactions

### Integration Tests
- [ ] Resources persist through save/load
- [ ] Shop purchases update inventory
- [ ] Quest rewards distribute correctly
- [ ] Competition prizes add to resources
- [ ] UI reflects resource changes

## Code Implementation

### Item Definitions (`scripts/data/item_definitions.gd`)
```gdscript
class_name ItemDefinitions
extends Resource

enum ItemType {
    FOOD,
    TRAINING_FOOD,
    COMPETITION_FOOD,
    MEDICINE,
    SPECIAL,
    UPGRADE
}

enum FoodEffect {
    NONE,
    STAMINA_RESTORE,
    STAT_BOOST,
    TRAINING_BOOST,
    COMPETITION_BOOST,
    BREEDING_BOOST
}

const ITEMS = {
    # Basic Foods
    "grain_rations": {
        "name": "Grain Rations",
        "type": ItemType.FOOD,
        "price": 5,
        "stack_size": 99,
        "description": "Standard creature food",
        "effects": {
            "type": FoodEffect.NONE
        }
    },
    "fresh_hay": {
        "name": "Fresh Hay",
        "type": ItemType.FOOD,
        "price": 8,
        "stack_size": 99,
        "description": "+5 stamina recovery",
        "effects": {
            "type": FoodEffect.STAMINA_RESTORE,
            "value": 5
        }
    },
    "wild_berries": {
        "name": "Wild Berries",
        "type": ItemType.FOOD,
        "price": 10,
        "stack_size": 99,
        "description": "+2 to all training gains",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "value": 2
        }
    },
    "spring_water": {
        "name": "Spring Water",
        "type": ItemType.FOOD,
        "price": 3,
        "stack_size": 99,
        "description": "Removes negative effects",
        "effects": {
            "type": FoodEffect.NONE,
            "special": "cleanse"
        }
    },

    # Training Foods
    "protein_mix": {
        "name": "Protein Mix",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Strength training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "strength",
            "multiplier": 1.5
        }
    },
    "endurance_blend": {
        "name": "Endurance Blend",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Constitution training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "constitution",
            "multiplier": 1.5
        }
    },
    "agility_feed": {
        "name": "Agility Feed",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Dexterity training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "dexterity",
            "multiplier": 1.5
        }
    },
    "brain_food": {
        "name": "Brain Food",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Intelligence training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "intelligence",
            "multiplier": 1.5
        }
    },
    "focus_formula": {
        "name": "Focus Formula",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Wisdom training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "wisdom",
            "multiplier": 1.5
        }
    },
    "discipline_diet": {
        "name": "Discipline Diet",
        "type": ItemType.TRAINING_FOOD,
        "price": 25,
        "stack_size": 20,
        "description": "+50% Discipline training",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "stat": "discipline",
            "multiplier": 1.5
        }
    },

    # Competition Foods
    "combat_rations": {
        "name": "Combat Rations",
        "type": ItemType.COMPETITION_FOOD,
        "price": 40,
        "stack_size": 10,
        "description": "+25% competition performance",
        "effects": {
            "type": FoodEffect.COMPETITION_BOOST,
            "multiplier": 1.25
        }
    },
    "task_fuel": {
        "name": "Task Fuel",
        "type": ItemType.COMPETITION_FOOD,
        "price": 35,
        "stack_size": 10,
        "description": "+30% on mental competitions",
        "effects": {
            "type": FoodEffect.COMPETITION_BOOST,
            "multiplier": 1.3,
            "competition_types": ["logic", "strategy", "tracking"]
        }
    },

    # Premium Foods
    "golden_nectar": {
        "name": "Golden Nectar",
        "type": ItemType.FOOD,
        "price": 100,
        "stack_size": 5,
        "description": "+100% training effectiveness",
        "effects": {
            "type": FoodEffect.TRAINING_BOOST,
            "multiplier": 2.0
        }
    }
}

static func get_item_data(item_id: String) -> Dictionary:
    return ITEMS.get(item_id, {})

static func item_exists(item_id: String) -> bool:
    return ITEMS.has(item_id)

static func get_items_by_type(type: ItemType) -> Array[String]:
    var result: Array[String] = []
    for item_id in ITEMS:
        if ITEMS[item_id].type == type:
            result.append(item_id)
    return result

static func get_item_price(item_id: String) -> int:
    var data = get_item_data(item_id)
    return data.get("price", 0)

static func get_stack_size(item_id: String) -> int:
    var data = get_item_data(item_id)
    return data.get("stack_size", 99)
```

### ResourceManager Singleton (`scripts/systems/resource_manager.gd`)
```gdscript
extends Node

signal gold_changed(new_amount: int)
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal transaction_completed(type: String, amount: int)
signal transaction_failed(reason: String)

var gold: int = 500
var inventory: Dictionary = {}  # item_id: quantity
var transaction_history: Array[Dictionary] = []

# Currency Management
func add_gold(amount: int, source: String = "unknown") -> bool:
    if amount < 0:
        push_error("Cannot add negative gold")
        return false

    var old_gold = gold
    gold += amount
    emit_signal("gold_changed", gold)
    emit_signal("transaction_completed", "gold_earned", amount)

    _record_transaction({
        "type": "earn",
        "resource": "gold",
        "amount": amount,
        "source": source,
        "timestamp": Time.get_unix_time_from_system()
    })

    print("Gold increased from %d to %d (%s)" % [old_gold, gold, source])
    return true

func spend_gold(amount: int, reason: String = "purchase") -> bool:
    if amount < 0:
        push_error("Cannot spend negative gold")
        return false

    if amount > gold:
        emit_signal("transaction_failed", "Insufficient gold")
        return false

    var old_gold = gold
    gold -= amount
    emit_signal("gold_changed", gold)
    emit_signal("transaction_completed", "gold_spent", amount)

    _record_transaction({
        "type": "spend",
        "resource": "gold",
        "amount": amount,
        "reason": reason,
        "timestamp": Time.get_unix_time_from_system()
    })

    print("Gold decreased from %d to %d (%s)" % [old_gold, gold, reason])
    return true

func can_afford(amount: int) -> bool:
    return gold >= amount

func get_gold() -> int:
    return gold

func set_gold(amount: int):
    gold = maxi(0, amount)
    emit_signal("gold_changed", gold)

# Inventory Management
func add_item(item_id: String, quantity: int = 1) -> bool:
    if not ItemDefinitions.item_exists(item_id):
        push_error("Unknown item: " + item_id)
        return false

    if quantity <= 0:
        push_error("Invalid quantity: %d" % quantity)
        return false

    var max_stack = ItemDefinitions.get_stack_size(item_id)
    var current = inventory.get(item_id, 0)

    if current + quantity > max_stack:
        emit_signal("transaction_failed", "Would exceed stack limit")
        return false

    inventory[item_id] = current + quantity
    emit_signal("item_added", item_id, quantity)
    emit_signal("transaction_completed", "item_added", quantity)

    _record_transaction({
        "type": "add_item",
        "resource": item_id,
        "amount": quantity,
        "timestamp": Time.get_unix_time_from_system()
    })

    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    if not has_item(item_id, quantity):
        emit_signal("transaction_failed", "Insufficient items")
        return false

    inventory[item_id] -= quantity

    if inventory[item_id] <= 0:
        inventory.erase(item_id)

    emit_signal("item_removed", item_id, quantity)
    emit_signal("transaction_completed", "item_removed", quantity)

    _record_transaction({
        "type": "remove_item",
        "resource": item_id,
        "amount": quantity,
        "timestamp": Time.get_unix_time_from_system()
    })

    return true

func has_item(item_id: String, quantity: int = 1) -> bool:
    return inventory.get(item_id, 0) >= quantity

func get_item_count(item_id: String) -> int:
    return inventory.get(item_id, 0)

func get_inventory() -> Dictionary:
    return inventory.duplicate()

func get_inventory_value() -> int:
    var total_value = 0

    for item_id in inventory:
        var quantity = inventory[item_id]
        var price = ItemDefinitions.get_item_price(item_id)
        total_value += price * quantity

    return total_value

# Purchase Helpers
func purchase_item(item_id: String, quantity: int = 1) -> bool:
    var item_data = ItemDefinitions.get_item_data(item_id)
    if item_data.is_empty():
        emit_signal("transaction_failed", "Invalid item")
        return false

    var total_cost = item_data.price * quantity

    if not can_afford(total_cost):
        emit_signal("transaction_failed", "Cannot afford item")
        return false

    # Try to add item first
    if not add_item(item_id, quantity):
        return false

    # Then deduct gold
    if not spend_gold(total_cost, "purchase_" + item_id):
        # Rollback item addition if gold spending fails
        remove_item(item_id, quantity)
        return false

    return true

func purchase_creature_egg(species: String, price: int) -> bool:
    if not can_afford(price):
        emit_signal("transaction_failed", "Cannot afford creature")
        return false

    if not spend_gold(price, "creature_" + species):
        return false

    # Egg creation would happen in shop system
    return true

# Batch Operations
func add_items_batch(items: Dictionary) -> bool:
    # items = {item_id: quantity}
    for item_id in items:
        if not add_item(item_id, items[item_id]):
            return false
    return true

func remove_items_batch(items: Dictionary) -> bool:
    # First check if all items are available
    for item_id in items:
        if not has_item(item_id, items[item_id]):
            emit_signal("transaction_failed", "Missing required items")
            return false

    # Then remove them
    for item_id in items:
        remove_item(item_id, items[item_id])

    return true

# Transaction History
func _record_transaction(transaction: Dictionary):
    transaction_history.append(transaction)

    # Keep only last 1000 transactions
    if transaction_history.size() > 1000:
        transaction_history.pop_front()

func get_transaction_history(limit: int = 100) -> Array[Dictionary]:
    var start = maxi(0, transaction_history.size() - limit)
    return transaction_history.slice(start)

func get_spending_summary() -> Dictionary:
    var summary = {
        "total_earned": 0,
        "total_spent": 0,
        "purchases": 0,
        "quest_rewards": 0,
        "competition_winnings": 0
    }

    for transaction in transaction_history:
        if transaction.type == "earn":
            summary.total_earned += transaction.amount

            match transaction.get("source", ""):
                "quest":
                    summary.quest_rewards += transaction.amount
                "competition":
                    summary.competition_winnings += transaction.amount

        elif transaction.type == "spend":
            summary.total_spent += transaction.amount

            if transaction.get("reason", "").begins_with("purchase"):
                summary.purchases += transaction.amount

    return summary

# Food Usage
func use_food_on_creature(creature: Creature, food_id: String) -> bool:
    if not has_item(food_id):
        return false

    var food_data = ItemDefinitions.get_item_data(food_id)
    if food_data.is_empty():
        return false

    # Apply food effects (handled by training/competition systems)
    # This is just removing from inventory
    return remove_item(food_id)

# Statistics
func get_resource_statistics() -> Dictionary:
    return {
        "current_gold": gold,
        "inventory_value": get_inventory_value(),
        "total_value": gold + get_inventory_value(),
        "unique_items": inventory.size(),
        "total_items": _count_all_items(),
        "spending_summary": get_spending_summary()
    }

func _count_all_items() -> int:
    var total = 0
    for item_id in inventory:
        total += inventory[item_id]
    return total

# Save/Load Integration
func save_resources() -> Dictionary:
    return {
        "gold": gold,
        "inventory": inventory.duplicate(),
        "transaction_history": transaction_history.duplicate()
    }

func load_resources(data: Dictionary):
    gold = data.get("gold", 500)
    inventory = data.get("inventory", {})
    transaction_history = data.get("transaction_history", [])

    emit_signal("gold_changed", gold)

# Debug/Cheat Functions
func debug_add_all_foods():
    for item_id in ItemDefinitions.ITEMS:
        var item_data = ItemDefinitions.ITEMS[item_id]
        if item_data.type in [ItemDefinitions.ItemType.FOOD, ItemDefinitions.ItemType.TRAINING_FOOD]:
            add_item(item_id, 10)

func debug_set_gold(amount: int):
    set_gold(amount)
    print("Debug: Gold set to %d" % amount)
```

### Resource Display Helper (`scripts/ui/resource_display_helper.gd`)
```gdscript
class_name ResourceDisplayHelper
extends RefCounted

# Format gold display with commas
static func format_gold(amount: int) -> String:
    var formatted = "%d" % amount
    var result = ""
    var count = 0

    for i in range(formatted.length() - 1, -1, -1):
        result = formatted[i] + result
        count += 1
        if count == 3 and i > 0:
            result = "," + result
            count = 0

    return result + " gold"

# Get icon path for item
static func get_item_icon_path(item_id: String) -> String:
    var item_data = ItemDefinitions.get_item_data(item_id)

    match item_data.get("type", -1):
        ItemDefinitions.ItemType.FOOD:
            return "res://assets/icons/food.png"
        ItemDefinitions.ItemType.TRAINING_FOOD:
            return "res://assets/icons/training_food.png"
        ItemDefinitions.ItemType.COMPETITION_FOOD:
            return "res://assets/icons/competition_food.png"
        _:
            return "res://assets/icons/item.png"

# Create rich text for item display
static func get_item_rich_text(item_id: String, quantity: int = -1) -> String:
    var item_data = ItemDefinitions.get_item_data(item_id)
    var name = item_data.get("name", "Unknown Item")

    if quantity > 0:
        return "[b]%s[/b] x%d" % [name, quantity]
    else:
        return "[b]%s[/b]" % name

# Get affordability color
static func get_affordability_color(cost: int, available: int) -> Color:
    if available >= cost:
        return Color.GREEN
    elif available >= cost * 0.5:
        return Color.YELLOW
    else:
        return Color.RED

# Format transaction for display
static func format_transaction(transaction: Dictionary) -> String:
    var timestamp = Time.get_datetime_dict_from_unix_time(transaction.timestamp)
    var time_str = "%02d:%02d" % [timestamp.hour, timestamp.minute]

    match transaction.type:
        "earn":
            return "[color=green]+%d gold[/color] from %s at %s" % [
                transaction.amount,
                transaction.get("source", "unknown"),
                time_str
            ]
        "spend":
            return "[color=red]-%d gold[/color] on %s at %s" % [
                transaction.amount,
                transaction.get("reason", "purchase"),
                time_str
            ]
        "add_item":
            return "[color=green]+%d %s[/color] at %s" % [
                transaction.amount,
                transaction.resource,
                time_str
            ]
        "remove_item":
            return "[color=yellow]-%d %s[/color] at %s" % [
                transaction.amount,
                transaction.resource,
                time_str
            ]
        _:
            return "Unknown transaction at %s" % time_str
```

## Success Metrics
- Resource operations complete instantly
- Transaction validation prevents exploits
- Inventory handles 100+ unique items
- Save/load preserves all resources
- No floating point errors with currency

## Notes
- Consider adding resource caps/limits
- Plan for multiple currency types
- Add trading system hooks
- Consider item durability/expiration

## Estimated Time
3-4 hours for implementation and testing