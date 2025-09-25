# Task 09: Resource Tracking System

## Overview
Implement the resource tracking system as a GameCore subsystem that manages gold currency, food inventory, and consumable items with automatic validation and change notifications using the improved architecture.

## Dependencies
- Task 01: GameCore Setup (complete)
- Task 07: Save/Load System (complete)
- Design documents: `economy.md`, `food.md`

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- ResourceSystem as GameCore subsystem (NOT autoload)
- All signals go through SignalBus
- Integrates with SaveSystem for persistence
- Lazy-loaded by GameCore when needed
- Supports future shop and feeding systems

From the design documents:
- Players start with 500 gold
- Gold spent on creatures, food, training
- Gold earned from quests and competitions
- Food items have different effects and costs
- Weekly food consumption for active creatures

## Requirements

### Resource Categories
1. **Currency**
   - Gold as primary currency
   - Transaction validation
   - Balance tracking
   - Spending history

2. **Food Inventory**
   - Basic foods (grain, hay, berries, water)
   - Training foods (protein mix, endurance blend, etc.)
   - Premium foods (golden nectar, vitality elixir)
   - Specialty foods (breeding supplements, combat rations)

3. **Consumable Items**
   - Health potions
   - Energy boosters
   - Special quest items
   - Equipment (future expansion)

### Resource Operations
1. **Currency Management**
   - Add/subtract gold
   - Transaction validation
   - Insufficient funds handling
   - Transaction logging

2. **Inventory Management**
   - Add/remove items
   - Stack management
   - Item validation
   - Quantity tracking

3. **Consumption System**
   - Item usage validation
   - Effect application
   - Quantity reduction
   - Consumption history

## Implementation Steps

1. **Create ResourceSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for all signals
   - Lazy-loaded subsystem

2. **Implement Currency System**
   - Gold balance tracking
   - Transaction processing
   - Validation and error handling

3. **Add Inventory Management**
   - Item storage system
   - CRUD operations
   - Stack management

4. **Create Item Database**
   - Food item definitions
   - Effect specifications
   - Cost and value data

## Test Criteria

### Unit Tests
- [ ] Add/subtract gold correctly
- [ ] Prevent negative balances
- [ ] Add/remove inventory items
- [ ] Stack items properly
- [ ] Save/load preserves resources

### Transaction Tests
- [ ] Large transactions work
- [ ] Insufficient funds prevented
- [ ] Item consumption reduces quantity
- [ ] Zero quantity items removed
- [ ] Transaction history maintained

### Integration Tests
- [ ] ResourceSystem integrates with SaveSystem
- [ ] SignalBus properly routes resource events
- [ ] GameCore manages ResourceSystem correctly
- [ ] Performance with large inventories
- [ ] Memory management efficient

## Code Implementation

### ResourceSystem - GameCore Subsystem
```gdscript
# scripts/systems/resource_system.gd
class_name ResourceSystem
extends Node

var signal_bus: SignalBus

# Currency
var gold: int = 500

# Inventory - item_id -> quantity
var inventory: Dictionary = {}

# Transaction history for debugging/statistics
var transaction_history: Array[Dictionary] = []
const MAX_HISTORY_SIZE = 100

# Item database - will be expanded in future stages
const ITEM_DATABASE = {
    # Basic Foods
    "grain_rations": {
        "name": "Grain Rations",
        "category": "basic_food",
        "description": "Standard food rations for creatures",
        "cost": 5,
        "effects": {"stamina": 10},
        "max_stack": 999
    },
    "fresh_hay": {
        "name": "Fresh Hay",
        "category": "basic_food",
        "description": "Nutritious hay for herbivorous creatures",
        "cost": 3,
        "effects": {"stamina": 8},
        "max_stack": 999
    },
    "wild_berries": {
        "name": "Wild Berries",
        "category": "basic_food",
        "description": "Sweet berries that creatures love",
        "cost": 4,
        "effects": {"stamina": 12},
        "max_stack": 999
    },
    "spring_water": {
        "name": "Spring Water",
        "category": "basic_food",
        "description": "Pure water from mountain springs",
        "cost": 2,
        "effects": {"stamina": 5},
        "max_stack": 999
    },

    # Training Foods
    "protein_mix": {
        "name": "Protein Mix",
        "category": "training_food",
        "description": "High-protein blend for strength training",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"strength": 0.1}},
        "max_stack": 99
    },
    "endurance_blend": {
        "name": "Endurance Blend",
        "category": "training_food",
        "description": "Special mix to improve constitution",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"constitution": 0.1}},
        "max_stack": 99
    },
    "agility_feed": {
        "name": "Agility Feed",
        "category": "training_food",
        "description": "Lightweight food for dexterity training",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"dexterity": 0.1}},
        "max_stack": 99
    },
    "brain_food": {
        "name": "Brain Food",
        "category": "training_food",
        "description": "Nutrients to enhance intelligence",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"intelligence": 0.1}},
        "max_stack": 99
    },
    "focus_formula": {
        "name": "Focus Formula",
        "category": "training_food",
        "description": "Helps creatures concentrate and gain wisdom",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"wisdom": 0.1}},
        "max_stack": 99
    },
    "discipline_diet": {
        "name": "Discipline Diet",
        "category": "training_food",
        "description": "Structured nutrition for better discipline",
        "cost": 15,
        "effects": {"stamina": 20, "training_bonus": {"discipline": 0.1}},
        "max_stack": 99
    },

    # Premium Foods
    "golden_nectar": {
        "name": "Golden Nectar",
        "category": "premium_food",
        "description": "Rare nectar with powerful restorative properties",
        "cost": 100,
        "effects": {"stamina": 50, "age_slow": 0.1},
        "max_stack": 10
    },
    "vitality_elixir": {
        "name": "Vitality Elixir",
        "category": "premium_food",
        "description": "Magical elixir that boosts vitality",
        "cost": 80,
        "effects": {"stamina": 100, "health_boost": 50},
        "max_stack": 20
    },

    # Specialty Items
    "combat_rations": {
        "name": "Combat Rations",
        "category": "specialty",
        "description": "Emergency food for dangerous quests",
        "cost": 25,
        "effects": {"stamina": 30, "quest_bonus": 0.2},
        "max_stack": 50
    }
}

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    print("ResourceSystem initialized with %d gold" % gold)

# Currency Management
func add_gold(amount: int, source: String = "unknown") -> void:
    if amount <= 0:
        push_warning("Cannot add negative or zero gold")
        return

    var old_gold = gold
    gold += amount

    _record_transaction({
        "type": "gold_add",
        "amount": amount,
        "source": source,
        "old_balance": old_gold,
        "new_balance": gold,
        "timestamp": Time.get_unix_time_from_system()
    })

    if signal_bus:
        signal_bus.gold_changed.emit(gold, old_gold)
        signal_bus.gold_added.emit(amount, source)

func subtract_gold(amount: int, reason: String = "unknown") -> bool:
    if amount <= 0:
        push_warning("Cannot subtract negative or zero gold")
        return false

    if gold < amount:
        if signal_bus:
            signal_bus.insufficient_gold.emit(amount, gold)
        return false

    var old_gold = gold
    gold -= amount

    _record_transaction({
        "type": "gold_subtract",
        "amount": amount,
        "reason": reason,
        "old_balance": old_gold,
        "new_balance": gold,
        "timestamp": Time.get_unix_time_from_system()
    })

    if signal_bus:
        signal_bus.gold_changed.emit(gold, old_gold)
        signal_bus.gold_spent.emit(amount, reason)

    return true

func can_afford(amount: int) -> bool:
    return gold >= amount

func get_gold() -> int:
    return gold

func set_gold(amount: int) -> void:
    # Used by SaveSystem
    var old_gold = gold
    gold = maxi(0, amount)

    if signal_bus and gold != old_gold:
        signal_bus.gold_changed.emit(gold, old_gold)

# Inventory Management
func add_item(item_id: String, quantity: int = 1, source: String = "unknown") -> bool:
    if not is_valid_item(item_id):
        push_error("Invalid item ID: " + item_id)
        return false

    if quantity <= 0:
        push_warning("Cannot add negative or zero quantity")
        return false

    var item_data = ITEM_DATABASE[item_id]
    var current_quantity = inventory.get(item_id, 0)
    var max_stack = item_data.get("max_stack", 999)

    # Check if we can add without exceeding max stack
    if current_quantity + quantity > max_stack:
        push_warning("Would exceed max stack size for " + item_id)
        return false

    inventory[item_id] = current_quantity + quantity

    _record_transaction({
        "type": "item_add",
        "item_id": item_id,
        "quantity": quantity,
        "source": source,
        "new_quantity": inventory[item_id],
        "timestamp": Time.get_unix_time_from_system()
    })

    if signal_bus:
        signal_bus.item_added.emit(item_id, quantity, source)
        signal_bus.inventory_changed.emit()

    return true

func remove_item(item_id: String, quantity: int = 1, reason: String = "unknown") -> bool:
    if not is_valid_item(item_id):
        push_error("Invalid item ID: " + item_id)
        return false

    if quantity <= 0:
        push_warning("Cannot remove negative or zero quantity")
        return false

    var current_quantity = inventory.get(item_id, 0)
    if current_quantity < quantity:
        if signal_bus:
            signal_bus.insufficient_items.emit(item_id, quantity, current_quantity)
        return false

    var new_quantity = current_quantity - quantity

    if new_quantity == 0:
        inventory.erase(item_id)
    else:
        inventory[item_id] = new_quantity

    _record_transaction({
        "type": "item_remove",
        "item_id": item_id,
        "quantity": quantity,
        "reason": reason,
        "new_quantity": new_quantity,
        "timestamp": Time.get_unix_time_from_system()
    })

    if signal_bus:
        signal_bus.item_removed.emit(item_id, quantity, reason)
        signal_bus.inventory_changed.emit()

    return true

func consume_item(item_id: String, creature_entity: CreatureEntity = null) -> Dictionary:
    if not remove_item(item_id, 1, "consumption"):
        return {"success": false, "reason": "Could not remove item"}

    var item_data = get_item_data(item_id)
    var effects = item_data.get("effects", {})

    if creature_entity and creature_entity.data:
        # Apply effects to creature
        if effects.has("stamina"):
            var old_stamina = creature_entity.data.stamina_current
            creature_entity.data.stamina_current = mini(
                creature_entity.data.stamina_max,
                creature_entity.data.stamina_current + effects.stamina
            )

            if signal_bus:
                signal_bus.creature_stamina_restored.emit(
                    creature_entity.data,
                    effects.stamina,
                    old_stamina,
                    creature_entity.data.stamina_current
                )

    if signal_bus:
        signal_bus.item_consumed.emit(item_id, creature_entity.data if creature_entity else null)

    return {"success": true, "effects": effects}

func has_item(item_id: String, quantity: int = 1) -> bool:
    return inventory.get(item_id, 0) >= quantity

func get_item_quantity(item_id: String) -> int:
    return inventory.get(item_id, 0)

func get_inventory() -> Dictionary:
    return inventory.duplicate()

func set_inventory(new_inventory: Dictionary) -> void:
    # Used by SaveSystem
    inventory = new_inventory.duplicate()

    if signal_bus:
        signal_bus.inventory_changed.emit()

# Item Database Access
func is_valid_item(item_id: String) -> bool:
    return ITEM_DATABASE.has(item_id)

func get_item_data(item_id: String) -> Dictionary:
    return ITEM_DATABASE.get(item_id, {})

func get_item_name(item_id: String) -> String:
    var item_data = get_item_data(item_id)
    return item_data.get("name", item_id)

func get_item_description(item_id: String) -> String:
    var item_data = get_item_data(item_id)
    return item_data.get("description", "No description available")

func get_item_cost(item_id: String) -> int:
    var item_data = get_item_data(item_id)
    return item_data.get("cost", 0)

func get_items_by_category(category: String) -> Array[String]:
    var items: Array[String] = []

    for item_id in ITEM_DATABASE:
        if ITEM_DATABASE[item_id].get("category", "") == category:
            items.append(item_id)

    return items

func get_all_item_ids() -> Array[String]:
    var items: Array[String] = []
    for item_id in ITEM_DATABASE:
        items.append(item_id)
    return items

# Inventory Analysis
func get_inventory_value() -> int:
    var total_value = 0

    for item_id in inventory:
        var quantity = inventory[item_id]
        var cost = get_item_cost(item_id)
        total_value += quantity * cost

    return total_value

func get_inventory_stats() -> Dictionary:
    var stats = {
        "total_items": 0,
        "unique_items": inventory.keys().size(),
        "categories": {},
        "most_common_item": "",
        "total_value": get_inventory_value()
    }

    var max_quantity = 0

    for item_id in inventory:
        var quantity = inventory[item_id]
        stats.total_items += quantity

        if quantity > max_quantity:
            max_quantity = quantity
            stats.most_common_item = item_id

        var item_data = get_item_data(item_id)
        var category = item_data.get("category", "unknown")

        if not stats.categories.has(category):
            stats.categories[category] = 0
        stats.categories[category] += quantity

    return stats

# Weekly food consumption
func calculate_weekly_food_cost(active_creature_count: int) -> int:
    # Basic calculation - will be enhanced in future stages
    return active_creature_count * 25  # 25 gold per creature per week

func has_sufficient_food_for_week(active_creature_count: int) -> bool:
    var required_cost = calculate_weekly_food_cost(active_creature_count)
    return can_afford(required_cost)

# Transaction history management
func _record_transaction(transaction: Dictionary) -> void:
    transaction_history.append(transaction)

    # Keep history size manageable
    if transaction_history.size() > MAX_HISTORY_SIZE:
        transaction_history.pop_front()

func get_transaction_history(count: int = 10) -> Array[Dictionary]:
    var start = maxi(0, transaction_history.size() - count)
    return transaction_history.slice(start)

func get_recent_gold_transactions(count: int = 5) -> Array[Dictionary]:
    var gold_transactions: Array[Dictionary] = []

    for i in range(transaction_history.size() - 1, -1, -1):
        var transaction = transaction_history[i]
        if transaction.type.begins_with("gold_"):
            gold_transactions.append(transaction)
            if gold_transactions.size() >= count:
                break

    return gold_transactions

# Shop integration helpers (for future use)
func can_purchase(item_id: String, quantity: int = 1) -> Dictionary:
    if not is_valid_item(item_id):
        return {"can_purchase": false, "reason": "Invalid item"}

    var cost = get_item_cost(item_id) * quantity
    if not can_afford(cost):
        return {"can_purchase": false, "reason": "Insufficient gold", "required": cost, "available": gold}

    var item_data = get_item_data(item_id)
    var current_quantity = get_item_quantity(item_id)
    var max_stack = item_data.get("max_stack", 999)

    if current_quantity + quantity > max_stack:
        return {"can_purchase": false, "reason": "Would exceed max stack"}

    return {"can_purchase": true, "cost": cost}

func purchase_item(item_id: String, quantity: int = 1) -> bool:
    var check = can_purchase(item_id, quantity)
    if not check.can_purchase:
        return false

    if subtract_gold(check.cost, "item_purchase"):
        return add_item(item_id, quantity, "shop_purchase")

    return false

# Inventory maintenance
func clean_empty_stacks() -> void:
    var empty_items: Array[String] = []

    for item_id in inventory:
        if inventory[item_id] <= 0:
            empty_items.append(item_id)

    for item_id in empty_items:
        inventory.erase(item_id)

    if not empty_items.is_empty() and signal_bus:
        signal_bus.inventory_cleaned.emit(empty_items)

# Debug/cheat functions (remove in production)
func add_starting_resources() -> void:
    add_item("grain_rations", 10, "starting_kit")
    add_item("spring_water", 5, "starting_kit")
    add_item("wild_berries", 3, "starting_kit")

func debug_add_gold(amount: int) -> void:
    if OS.is_debug_build():
        add_gold(amount, "debug_cheat")

func debug_add_item(item_id: String, quantity: int) -> void:
    if OS.is_debug_build():
        add_item(item_id, quantity, "debug_cheat")
```

### Resource Display Helper - Utility Class
```gdscript
# scripts/utils/resource_display_helper.gd
class_name ResourceDisplayHelper
extends RefCounted

# Format gold amount for display
static func format_gold(amount: int) -> String:
    if amount >= 10000:
        return "%.1fK gold" % (amount / 1000.0)
    elif amount >= 1000:
        return "%.2fK gold" % (amount / 1000.0)
    else:
        return "%d gold" % amount

# Format item quantity for display
static func format_item_quantity(item_id: String, quantity: int) -> String:
    var resource_system = GameCore.get_system("resource") as ResourceSystem
    if not resource_system:
        return "%d x %s" % [quantity, item_id]

    var name = resource_system.get_item_name(item_id)
    return "%d x %s" % [quantity, name]

# Get color for resource display
static func get_resource_color(resource_type: String, amount: int = 0) -> Color:
    match resource_type:
        "gold":
            if amount >= 1000:
                return Color.GOLD
            elif amount >= 100:
                return Color.YELLOW
            else:
                return Color.ORANGE
        "food":
            return Color.GREEN
        "item":
            return Color.CYAN
        _:
            return Color.WHITE

# Create rich text for resource display
static func format_resource_rich_text(resource_type: String, amount: int, label: String = "") -> String:
    var color = get_resource_color(resource_type, amount)
    var text = label if label else format_gold(amount)

    return "[color=#%s]%s[/color]" % [color.to_html(false), text]

# Get inventory summary for UI
static func get_inventory_summary() -> Dictionary:
    var resource_system = GameCore.get_system("resource") as ResourceSystem
    if not resource_system:
        return {}

    var inventory = resource_system.get_inventory()
    var summary = {
        "total_items": 0,
        "categories": {},
        "valuable_items": []
    }

    for item_id in inventory:
        var quantity = inventory[item_id]
        summary.total_items += quantity

        var item_data = resource_system.get_item_data(item_id)
        var category = item_data.get("category", "unknown")

        if not summary.categories.has(category):
            summary.categories[category] = 0
        summary.categories[category] += quantity

        # Track valuable items (cost > 50)
        var cost = resource_system.get_item_cost(item_id)
        if cost > 50:
            summary.valuable_items.append({
                "id": item_id,
                "name": resource_system.get_item_name(item_id),
                "quantity": quantity,
                "total_value": cost * quantity
            })

    # Sort valuable items by total value
    summary.valuable_items.sort_custom(func(a, b): return a.total_value > b.total_value)

    return summary
```

## Success Metrics
- ResourceSystem loads as GameCore subsystem in < 5ms
- Gold transactions complete in < 1ms
- Inventory operations handle 1000+ items efficiently
- Save/load preserves all resources correctly
- Transaction history maintained accurately
- All signals properly routed through SignalBus
- Memory usage stays reasonable with large inventories

## Notes
- ResourceSystem is a GameCore subsystem, not an autoload
- Item database will be expanded in future stages
- Consider item effects system for complex interactions
- Transaction history useful for debugging and analytics
- Future shop system will integrate with purchase helpers
- Add item tooltips and detailed descriptions later

## Estimated Time
3-4 hours for implementation and testing