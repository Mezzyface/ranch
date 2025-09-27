# 📚 Comprehensive API & Usage Guide

**Purpose**: Single source of truth for all API references, usage patterns, and quick-start solutions for the Creature Collection Game.

**Last Updated**: 2025-09-26
**Stage**: Stage 1 Complete, Stage 2 In Progress

---

## 🚀 Quick Start

### System Access Pattern
```gdscript
# Get any system (lazy loaded)
var stat_system = GameCore.get_system("stat")
var save_system = GameCore.get_system("save")
var tag_system = GameCore.get_system("tag")
var age_system = GameCore.get_system("age")
var collection_system = GameCore.get_system("collection")
var resource_tracker = GameCore.get_system("resource")
var species_system = GameCore.get_system("species")
var item_manager = GameCore.get_system("item_manager")

# Get SignalBus (always available)
var signal_bus = GameCore.get_signal_bus()
```

### Available System Keys
- `"stat"` - StatSystem for calculations and modifiers
- `"tag"` - TagSystem for validation and filtering
- `"age"` - AgeSystem for lifecycle management
- `"save"` - SaveSystem for persistence
- `"collection"` - PlayerCollection for roster management
- `"resource"` or `"resources"` - ResourceTracker for resource management
- `"species"` - SpeciesSystem for species data
- `"item_manager"` or `"items"` - ItemManager for item operations
- `"creature"` - CreatureSystem (when implemented)
- `"quest"` - QuestSystem (when implemented)

---

## 📦 Core Data Classes

### CreatureData (Resource)
**File**: `scripts/data/creature_data.gd`

#### ✅ Correct Property Names
```gdscript
creature_data.id                    # NOT creature_id
creature_data.creature_name         # Display name
creature_data.species_id            # NOT species
creature_data.strength              # Base stats (1-1000)
creature_data.constitution
creature_data.dexterity
creature_data.intelligence
creature_data.wisdom
creature_data.discipline
creature_data.age_weeks             # Current age in weeks
creature_data.lifespan_weeks       # Maximum lifespan
creature_data.tags                 # Array[String] of tag IDs
creature_data.is_active            # Active roster flag
creature_data.stamina_current     # Current stamina
creature_data.stamina_max         # Maximum stamina
```

#### Methods on CreatureData
```gdscript
# Age calculations (on data, not system!)
creature.get_age_category() -> int          # Returns GlobalEnums.AgeCategory (0-4)
creature.get_age_modifier() -> float        # 0.6-1.0 multiplier based on age category
```

---

## 🎮 CreatureEntity Usage

```gdscript
# Create creature entity
var entity = CreatureEntity.new(creature_data)
add_child(entity)  # Must add to scene tree!

# Stat operations (for quest eligibility)
var quest_strength = entity.get_effective_stat("strength")     # No age modifier
var meets_quest = entity.matches_requirements(stat_reqs, tag_reqs)

# Performance operations (for competitions)
var comp_strength = entity.get_competition_stat("strength")    # With age modifier
var performance = entity.get_performance_score()              # Age-affected

# Training operations
entity.train_stat("strength", amount, max_boost)  # Emit signals
```

---

## 🕒 AgeSystem

### Basic Usage
```gdscript
var age_system = GameCore.get_system("age")

# Age single creature
age_system.age_creature_by_weeks(creature, 26)  # Age by half year

# Age to specific category
age_system.age_creature_to_category(creature, 2)  # Adult category

# Batch operations
var creatures: Array[CreatureData] = [...]
age_system.batch_age_by_weeks(creatures, 52, true)  # Quiet mode
```

### Age Categories
- **Baby** (0-10% lifespan): 0.6x modifier
- **Juvenile** (10-25%): 0.8x modifier
- **Adult** (25-75%): 1.0x modifier
- **Elder** (75-90%): 0.8x modifier
- **Ancient** (90-100%): 0.6x modifier

---

## 📊 StatSystem

### Core Methods
```gdscript
var stat_system = GameCore.get_system("stat")

# Get base stat value
var strength = stat_system.get_stat(creature, "strength")

# Apply modifiers
var modified = stat_system.apply_modifiers(100, modifiers)

# Calculate with age modifier
var final = stat_system.calculate_with_age_modifier(creature, "strength")

# Batch operations
var totals = stat_system.batch_calculate_stats(creatures)
```

### Valid Stat Names
- `strength`, `constitution`, `dexterity`
- `intelligence`, `wisdom`, `discipline`

---

## 🏷️ TagSystem

### Tag Operations
```gdscript
var tag_system = GameCore.get_system("tag")

# Single tag operations
tag_system.add_tag(creature, "Flying")
tag_system.remove_tag(creature, "Swimming")
var has_tag = tag_system.has_tag(creature, "Flying")

# Multiple tag operations
tag_system.add_tags(creature, ["Flying", "Magic"])
var has_all = tag_system.has_all_tags(creature, ["Flying", "Magic"])
var has_any = tag_system.has_any_tags(creature, ["Flying", "Swimming"])

# Filtering
var flyers = tag_system.filter_by_tags(all_creatures, ["Flying"], false)
var magic_flyers = tag_system.filter_by_all_tags(all_creatures, ["Flying", "Magic"])
```

---

## 💾 SaveSystem

### Save/Load Operations
```gdscript
var save_system = GameCore.get_system("save")

# Save game
save_system.save_game("save_slot_1")

# Load game
if save_system.has_save("save_slot_1"):
    save_system.load_game("save_slot_1")

# List saves
var saves = save_system.list_saves()

# Delete save
save_system.delete_save("save_slot_1")
```

---

## 📢 SignalBus

### Connecting to Signals
```gdscript
func _ready():
    var bus = GameCore.get_signal_bus()

    # Connect to signals
    bus.creature_acquired.connect(_on_creature_acquired)
    bus.creature_released.connect(_on_creature_released)
    bus.stat_changed.connect(_on_stat_changed)
    bus.tag_added.connect(_on_tag_added)

func _on_creature_acquired(creature: CreatureData, source: String):
    print("Got creature: %s from %s" % [creature.creature_name, source])
```

### Available Signals
- **Creature Events**: `creature_acquired`, `creature_released`, `creature_expired`, `creature_created`
- **Stat Events**: `creature_stats_changed`, `creature_modifiers_changed`
- **Tag Events**: `creature_tag_added`, `creature_tag_removed`, `tag_add_failed`, `tag_validation_failed`
- **Age Events**: `creature_aged`, `creature_category_changed`, `aging_batch_completed`
- **Collection Events**: `active_roster_changed`, `stable_collection_updated`, `collection_milestone_reached`
- **Save Events**: `save_completed`, `load_completed`, `auto_save_triggered`, `save_progress`, `data_corrupted`
- **Resource Events**: `gold_changed`, `item_added`, `item_removed`, `transaction_failed`, `creature_fed`

---

## 🧪 Testing

### Run Tests
```bash
# Project validation
godot --check-only project.godot

# Preflight check (run first!)
godot --headless --scene tests/preflight_check.tscn

# Individual system tests
godot --headless --scene tests/individual/test_creature.tscn
godot --headless --scene tests/individual/test_stats.tscn

# All tests
godot --headless --scene tests/test_all.tscn

# With timeout (Windows)
run_tests.bat 30
```

---

## ❌ Common Mistakes to Avoid

1. **Wrong Property Names**:
   - ❌ `creature_id` → ✅ `id`
   - ❌ `species` → ✅ `species_id`

2. **Wrong Method Locations**:
   - ❌ `age_system.get_age_category(creature)`
   - ✅ `creature.get_age_category()`

3. **Untyped Arrays**:
   - ❌ `var tags = ["Flying"]`
   - ✅ `var tags: Array[String] = ["Flying"]`

4. **Direct System Access**:
   - ❌ `StatSystem.new()`
   - ✅ `GameCore.get_system("stat")`

5. **Signals in Resources**:
   - ❌ Adding signals to CreatureData
   - ✅ Using CreatureEntity for behavior/signals

---

## 🚀 Copy-Paste Solutions

### Generate a Creature
```gdscript
var creature = CreatureGenerator.generate_creature_data("dragon")
GameCore.get_system("collection").add_creature(creature)
```

### Age and Train Creature
```gdscript
var age_system = GameCore.get_system("age")
var entity = CreatureEntity.new(creature)
add_child(entity)

# Age to adult
age_system.age_creature_to_category(creature, 2)

# Train strength
entity.train_stat("strength", 10, 50)
```

### Save Current Game
```gdscript
var save_system = GameCore.get_system("save")
save_system.save_game("autosave")
print("Game saved!")
```

### Filter Creatures by Requirements
```gdscript
var tag_system = GameCore.get_system("tag")
var collection = GameCore.get_system("collection")

var all_creatures = collection.get_all_creatures()
var flyers = tag_system.filter_by_tags(all_creatures, ["Flying"], false)
print("Found %d flying creatures" % flyers.size())
```

---

## 📈 Performance Targets

| Operation | Target | Notes |
|-----------|--------|-------|
| 1000 creature generation | <100ms | Use batch operations |
| Batch aging 1000 creatures | <100ms | Use quiet mode |
| Save/load 100 creatures | <200ms | ConfigFile-based |
| 100 species lookups | <50ms | Cached resources |

---

## 🔧 Adding New Systems

1. Create system in `scripts/systems/`
2. Add to GameCore loader
3. Add test in `tests/individual/`
4. Update this guide with new APIs
5. Add signals to SignalBus if needed

---

*This guide consolidates information from USAGE.md, QUICK_REFERENCE.md, API_REFERENCE.md, and QUICK_START_GUIDE.md into a single comprehensive resource.*