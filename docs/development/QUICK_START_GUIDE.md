# Quick Start Guide for Developers

**Purpose**: Provide copy-paste ready solutions for common development tasks in the creature collection game.

**Created**: 2024-12-26
**For**: Developers implementing Tasks 9-11 and beyond

---

## 🚀 Quick Setup for New Development

### 1. Project Structure
```
your_work/
├── scripts/
│   ├── systems/        # Your new system goes here
│   ├── data/           # New data classes (Resources)
│   └── entities/       # New entity classes (Nodes)
├── tests/
│   └── individual/     # Your test files go here
└── docs/              # Update documentation
```

### 2. Essential Imports for Any Script
```gdscript
extends Node  # or extends Resource for data classes

# Get core systems
func _ready() -> void:
    var signal_bus: SignalBus = GameCore.get_signal_bus()
    var collection = GameCore.get_system("collection")
    var save_system = GameCore.get_system("save")
    var tag_system = GameCore.get_system("tag")
    var age_system = GameCore.get_system("age")
    var stat_system = GameCore.get_system("stat")
```

---

## 📋 Common Development Tasks

### Task: Create a New System
```gdscript
# File: scripts/systems/resource_tracker.gd
extends Node

var gold: int = 500
var items: Dictionary = {}

signal gold_changed(new_amount: int, change: int)
signal item_acquired(item_id: String, quantity: int)

func _init() -> void:
    print("ResourceTracker initialized")

func add_gold(amount: int) -> void:
    var old_gold: int = gold
    gold += amount
    gold = max(0, gold)  # Never negative

    # Emit through SignalBus
    var signal_bus: SignalBus = GameCore.get_signal_bus()
    if signal_bus:
        # Add emission method to SignalBus first!
        signal_bus.emit_resource_changed("gold", gold, amount)

func can_afford(cost: int) -> bool:
    return gold >= cost
```

### Task: Add System to GameCore
```gdscript
# In scripts/core/game_core.gd - _load_system() method
match system_name:
    "resource":  # Add this case
        system = preload("res://scripts/systems/resource_tracker.gd").new()
```

### Task: Add Signals to SignalBus
```gdscript
# In scripts/core/signal_bus.gd

# Add signal declarations
signal resource_changed(resource_type: String, new_value: int, change: int)
signal purchase_completed(item_type: String, cost: int)

# Add emission methods with validation
func emit_resource_changed(resource_type: String, new_value: int, change: int) -> void:
    if _validate_not_null(resource_type, "resource_changed"):
        resource_changed.emit(resource_type, new_value, change)
        if _debug_mode:
            print("Signal: resource_changed(%s, %d, %d)" % [resource_type, new_value, change])

func emit_purchase_completed(item_type: String, cost: int) -> void:
    if _validate_not_null(item_type, "purchase_completed"):
        purchase_completed.emit(item_type, cost)
```

### Task: Create a Test for Your System
```gdscript
# File: tests/individual/test_resource.gd
extends Node

func _ready() -> void:
    print("=== Resource Tracker Test ===")

    # Load system
    var resource_system = GameCore.get_system("resource")
    assert(resource_system != null, "Failed to load ResourceTracker")

    # Test gold operations
    var initial_gold: int = resource_system.gold
    print("Initial gold: %d" % initial_gold)

    resource_system.add_gold(100)
    assert(resource_system.gold == initial_gold + 100, "Gold addition failed")
    print("✅ Gold addition working")

    # Test affordability check
    assert(resource_system.can_afford(50), "Affordability check failed")
    assert(not resource_system.can_afford(99999), "Affordability check failed")
    print("✅ Affordability checks working")

    print("✅ Resource Tracker test complete!")
    get_tree().quit(0)
```

### Task: Create Test Scene
```
# File: tests/individual/test_resource.tscn
[gd_scene load_steps=2 format=3 uid="uid://test_resource"]

[ext_resource type="Script" path="res://tests/individual/test_resource.gd" id="1"]

[node name="TestResource" type="Node"]
script = ExtResource("1")
```

---

## 🎮 Common Gameplay Implementation Patterns

### Pattern: Shop Purchase Flow
```gdscript
func purchase_creature_egg(species: String, egg_quality: String, cost: int) -> bool:
    var resource_system = GameCore.get_system("resource")
    var collection = GameCore.get_system("collection")
    var signal_bus = GameCore.get_signal_bus()

    # Check affordability
    if not resource_system.can_afford(cost):
        print("Cannot afford egg: %d gold required" % cost)
        return false

    # Deduct cost
    resource_system.add_gold(-cost)

    # Generate creature
    var algorithm = CreatureGenerator.GenerationType.HIGH_ROLL if egg_quality == "premium" else CreatureGenerator.GenerationType.UNIFORM
    var creature: CreatureData = CreatureGenerator.generate_creature_data(species, algorithm)

    # Add to collection
    if not collection.add_to_active(creature):
        collection.add_to_stable(creature)

    # Emit purchase signal
    signal_bus.emit_purchase_completed("creature_egg", cost)

    return true
```

### Pattern: Quest Completion Rewards
```gdscript
func complete_quest(quest_id: String, reward_gold: int, reward_items: Dictionary) -> void:
    var resource_system = GameCore.get_system("resource")
    var signal_bus = GameCore.get_signal_bus()

    # Add gold reward
    resource_system.add_gold(reward_gold)

    # Add item rewards
    for item_id in reward_items:
        resource_system.add_item(item_id, reward_items[item_id])

    # Mark quest complete (Task 9-11 will implement)
    # quest_system.mark_complete(quest_id)

    # Emit completion signal
    signal_bus.emit_quest_completed(quest_id, reward_gold)
```

### Pattern: Weekly Maintenance Costs
```gdscript
func process_weekly_costs() -> void:
    var collection = GameCore.get_system("collection")
    var resource_system = GameCore.get_system("resource")

    # Calculate food costs
    var active_creatures: Array[CreatureData] = collection.get_active_creatures()
    var food_cost: int = active_creatures.size() * 25  # 25 gold per creature

    # Check if player can afford
    if not resource_system.can_afford(food_cost):
        print("WARNING: Cannot afford food costs!")
        # Handle starvation mechanics
        return

    # Deduct costs
    resource_system.add_gold(-food_cost)
    print("Weekly food cost: %d gold for %d creatures" % [food_cost, active_creatures.size()])
```

### Pattern: Competition Rewards
```gdscript
func award_competition_prize(placement: int) -> void:
    var resource_system = GameCore.get_system("resource")
    var signal_bus = GameCore.get_signal_bus()

    var prize_gold: int = 0
    match placement:
        1: prize_gold = 500
        2: prize_gold = 300
        3: prize_gold = 100
        _: prize_gold = 50  # Participation prize

    resource_system.add_gold(prize_gold)
    signal_bus.emit_competition_completed(placement, prize_gold)
```

---

## 🔧 Debugging Common Issues

### Issue: "Invalid call. Nonexistent function"
```gdscript
# WRONG - Method doesn't exist
age_system.get_creature_age_category(creature)

# RIGHT - Use creature's method
creature.get_age_category()
```

### Issue: "Array type mismatch"
```gdscript
# WRONG - Type inference problem
var tags = ["Flying", "Fast"]
collection.get_available_for_quest(tags)

# RIGHT - Explicit typing
var tags: Array[String] = ["Flying", "Fast"]
collection.get_available_for_quest(tags)
```

### Issue: "Invalid property 'creature_id'"
```gdscript
# WRONG - Wrong property name
if creature.creature_id == target_id:

# RIGHT - Correct property name
if creature.id == target_id:
```

### Issue: "System not found"
```gdscript
# WRONG - Direct access
var system = GameCore.systems["new_system"]

# RIGHT - Use getter (triggers lazy load)
var system = GameCore.get_system("new_system")
```

---

## 🧪 Testing Your Code

### Run Individual Test
```bash
godot --headless --scene tests/individual/test_resource.tscn
```

### Run All Tests
```bash
godot --headless --scene tests/test_all.tscn
```

### Add Test to Sequential Runner
```gdscript
# In tests/test_all.gd - Add to TESTS_TO_RUN array
{"name": "ResourceTracker", "scene": "res://tests/individual/test_resource.tscn"}
```

---

## 📝 Documentation to Update

When adding new systems or features, update:

1. **CLAUDE.md** - Add lessons learned and patterns discovered
2. **API_REFERENCE.md** - Add new methods and correct usage
3. **SYSTEMS_INTEGRATION_GUIDE.md** - Document system dependencies
4. **This guide** - Add common patterns you discover
5. **tests/README.md** - Document your test coverage

---

## 🎯 Performance Guidelines

### Batch Operations
```gdscript
# INEFFICIENT - Multiple signals
for creature in creatures:
    signal_bus.emit_creature_updated(creature)

# EFFICIENT - Single signal with array
signal_bus.emit_batch_update_completed(creatures)
```

### System Reference Caching
```gdscript
# Cache system references at class level
var collection_system = null
var resource_system = null

func _ready():
    collection_system = GameCore.get_system("collection")
    resource_system = GameCore.get_system("resource")

func do_work():
    # Use cached references
    collection_system.do_something()
    resource_system.do_something()
```

### Quiet Mode for Bulk Operations
```gdscript
func import_creatures(creatures: Array[CreatureData]):
    var collection = GameCore.get_system("collection")
    var signal_bus = GameCore.get_signal_bus()

    # Disable verbose logging
    var original_debug = signal_bus._debug_mode
    signal_bus.set_debug_mode(false)
    collection.set_quiet_mode(true)

    # Bulk import
    for creature in creatures:
        collection.add_to_stable(creature)

    # Restore logging
    signal_bus.set_debug_mode(original_debug)
    collection.set_quiet_mode(false)

    # Emit single summary signal
    signal_bus.emit_import_completed(creatures.size())
```

---

## 💡 Pro Tips

1. **Always validate data before operations** - Prevents cascading errors
2. **Use signals for UI updates** - Keeps systems decoupled
3. **Cache system references** - Avoids repeated lookups
4. **Test with edge cases** - Empty collections, max values, etc.
5. **Document your patterns** - Help future developers (including yourself)
6. **Use explicit types** - Godot 4.5 is strict about typing
7. **Follow existing patterns** - Consistency is key
8. **Write tests first** - Ensures your API is usable

---

## 🚨 Critical Reminders

- `creature.id` NOT `creature.creature_id`
- `species_id` NOT `species`
- `Array[String]` NOT just `Array` for typed arrays
- `GameCore.get_system()` NOT direct access
- `Time.get_ticks_msec()` NOT `.nanosecond`
- Test your code with `godot --headless --scene your_test.tscn`

---

**Use this guide to quickly implement new features. Copy-paste the patterns and adapt them to your needs!**