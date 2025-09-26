# AI Agent Integration Guide

**CRITICAL**: This guide is specifically for AI agents (Claude, GPT, etc.) working on this codebase. Follow these patterns EXACTLY to avoid integration errors.

---

## 🚨 MANDATORY: Run Preflight Check First

Before implementing ANYTHING, run this command:
```bash
godot --headless --scene tests/preflight_check.tscn
```

If it fails, DO NOT PROCEED. Fix the issues first.

---

## ❌ NEVER DO THIS / ✅ ALWAYS DO THIS

### Property Access

```gdscript
# ❌ NEVER - These properties don't exist!
creature.creature_id        # WRONG!
creature.species            # WRONG!
creature.creature_age       # WRONG!

# ✅ ALWAYS - Use these exact property names
creature.id                 # CORRECT
creature.species_id         # CORRECT
creature.age_weeks          # CORRECT
creature.lifespan_weeks     # CORRECT
creature.creature_name      # CORRECT
```

### Method Calls

```gdscript
# ❌ NEVER - These methods don't exist where you think!
age_system.get_creature_age_category(creature)     # WRONG!
age_system.get_creature_age_modifier(creature)     # WRONG!
tag_system.creature_meets_requirements(...)        # WRONG!

# ✅ ALWAYS - Methods are on the data class
creature.get_age_category()                        # CORRECT
creature.get_age_modifier()                        # CORRECT
tag_system.meets_tag_requirements(creature, ...)   # CORRECT
```

### Array Types

```gdscript
# ❌ NEVER - Untyped arrays cause errors
var tags = ["Flying", "Fast"]                      # WRONG!
var creatures = []                                 # WRONG!
collection.get_available_for_quest(["Flying"])     # WRONG!

# ✅ ALWAYS - Use explicit typing
var tags: Array[String] = ["Flying", "Fast"]       # CORRECT
var creatures: Array[CreatureData] = []            # CORRECT
var required: Array[String] = ["Flying"]           # CORRECT
collection.get_available_for_quest(required)       # CORRECT
```

### System Loading

```gdscript
# ❌ NEVER - Direct access doesn't trigger lazy loading
var system = GameCore.systems["collection"]        # WRONG!
var system = GameCore.collection_system           # WRONG!

# ✅ ALWAYS - Use get_system for lazy loading
var system = GameCore.get_system("collection")     # CORRECT
var signal_bus = GameCore.get_signal_bus()        # CORRECT
```

### Time Measurement

```gdscript
# ❌ NEVER - These don't exist in Godot 4.5
Time.get_time_dict_from_system().nanosecond       # WRONG!
Time.nanosecond                                   # WRONG!
OS.get_ticks_usec()                              # WRONG!

# ✅ ALWAYS - Use millisecond ticks
var start: int = Time.get_ticks_msec()            # CORRECT
var end: int = Time.get_ticks_msec()              # CORRECT
var duration: int = end - start                   # CORRECT
```

---

## 📋 Copy-Paste Templates for Common Tasks

### Template 1: Creating a New System (Task 9-11)

```gdscript
# File: scripts/systems/your_new_system.gd
extends Node

# System initialization
func _init() -> void:
    print("YourNewSystem initialized")

# Add to GameCore._load_system():
match system_name:
    "your_system":
        system = preload("res://scripts/systems/your_new_system.gd").new()
```

### Template 2: Working with Creatures

```gdscript
func work_with_creature() -> void:
    # Generate creature - use exact species names
    var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

    # Access properties - use exact names
    var id: String = creature.id                    # NOT creature_id
    var species: String = creature.species_id       # NOT species
    var name: String = creature.creature_name

    # Get age info - methods on creature, not system
    var age_cat: int = creature.get_age_category()  # NOT age_system.get_creature_age_category()
    var modifier: float = creature.get_age_modifier()

    # Add to collection
    var collection = GameCore.get_system("collection")
    if not collection.add_to_active(creature):
        collection.add_to_stable(creature)
```

### Template 3: Quest Eligibility Check

```gdscript
func check_quest_eligibility() -> void:
    # MUST use typed array
    var required_tags: Array[String] = ["Dark Vision", "Small"]
    var excluded_tags: Array[String] = ["Flies"]

    var collection = GameCore.get_system("collection")
    var tag_system = GameCore.get_system("tag")

    # Get available creatures
    var available: Array[CreatureData] = collection.get_available_for_quest(required_tags)

    # Further filter if needed
    for creature in available:
        if tag_system.meets_tag_requirements(creature, required_tags, excluded_tags):
            print("Eligible: %s" % creature.creature_name)
```

### Template 4: Signal Integration

```gdscript
func setup_signals() -> void:
    var signal_bus: SignalBus = GameCore.get_signal_bus()

    # Connect to signals
    signal_bus.creature_acquired.connect(_on_creature_acquired)
    signal_bus.save_completed.connect(_on_save_completed)

    # Emit signals - validation happens automatically
    var creature: CreatureData = get_some_creature()
    signal_bus.emit_creature_acquired(creature, "shop")

func _on_creature_acquired(creature: CreatureData, source: String) -> void:
    print("Creature acquired from %s" % source)
```

---

## 🔍 Validation Checklist Before Submitting Code

Run through this checklist EVERY TIME before submitting code:

- [ ] Ran preflight check: `godot --headless --scene tests/preflight_check.tscn`
- [ ] All property access uses `id` not `creature_id`
- [ ] All property access uses `species_id` not `species`
- [ ] Age methods called on creature, not age_system
- [ ] All arrays have explicit typing: `Array[String]` or `Array[CreatureData]`
- [ ] Systems loaded with `GameCore.get_system()`
- [ ] Time measured with `Time.get_ticks_msec()`
- [ ] No references to `.nanosecond` anywhere
- [ ] Tag system method is `meets_tag_requirements` not `creature_meets_requirements`

---

## 🎯 System Names for GameCore.get_system()

These are the ONLY valid system names:

```gdscript
GameCore.get_system("collection")  # PlayerCollection
GameCore.get_system("save")        # SaveSystem
GameCore.get_system("tag")         # TagSystem
GameCore.get_system("age")         # AgeSystem
GameCore.get_system("stat")        # StatSystem
# Future systems (Tasks 9-11):
GameCore.get_system("resource")    # ResourceTracker
GameCore.get_system("species")     # SpeciesSystem
```

---

## 🚫 Common AI Agent Mistakes to Avoid

1. **Assuming methods exist on systems that don't**
   - Age methods are on CreatureData, not AgeSystem
   - Many utility methods are on the data classes themselves

2. **Using wrong property names from memory**
   - It's `id` not `creature_id`
   - It's `species_id` not `species`
   - Check the actual class definition!

3. **Creating untyped arrays**
   - Godot 4.5 REQUIRES typed arrays for many methods
   - Always use `Array[String]` or `Array[CreatureData]`

4. **Using time APIs that don't exist**
   - There is NO `.nanosecond` property
   - Use `Time.get_ticks_msec()` for everything

5. **Direct system access instead of lazy loading**
   - NEVER access `GameCore.systems` directly
   - ALWAYS use `GameCore.get_system()`

---

## 🧪 Test Your Integration

After implementing, test with:

```bash
# Run preflight check
godot --headless --scene tests/preflight_check.tscn

# Run individual system test
godot --headless --scene tests/individual/test_collection.tscn

# Run all tests
godot --headless --scene tests/test_all.tscn
```

---

## 📚 Reference Files to Check

When in doubt, check these actual implementation files:

- `scripts/data/creature_data.gd` - See actual property names
- `scripts/systems/player_collection.gd` - See actual method signatures
- `scripts/core/game_core.gd` - See system loading pattern
- `scripts/core/signal_bus.gd` - See signal names and emission methods
- `tests/preflight_check.gd` - See validation patterns

---

**REMEMBER**: When in doubt, run the preflight check! It will catch 90% of integration errors before they happen.