# API Reference Guide

**Purpose**: Prevent common integration errors by providing correct method names, property references, and usage patterns for all Stage 1 systems.

**Created**: Task 8 implementation - Based on actual working code
**Updated**: 2024-12-26 - Enhanced with complete usage examples and integration patterns

---

## 🎯 Quick Error Prevention Checklist

### ❌ Common Mistakes to Avoid
1. **Wrong Property Names**: `creature_id` vs `id`, `species` vs `species_id`
2. **Wrong Method Names**: `get_creature_age_category()` vs `get_age_category()`
3. **Array Type Issues**: `["Flying"]` vs `var tags: Array[String] = ["Flying"]`
4. **Missing System Loading**: Call `GameCore.get_system()` before use
5. **Signal Method Names**: `creature_meets_requirements()` vs `meets_tag_requirements()`

---

## 📦 Core Data Classes

### CreatureData (Resource)
**File**: `scripts/data/creature_data.gd`

#### ✅ Correct Property Names
```gdscript
creature_data.id                    # NOT creature_id
creature_data.creature_name         # Display name
creature_data.species_id            # NOT species
creature_data.age_weeks             # Current age
creature_data.lifespan_weeks        # Maximum age
creature_data.tags                  # Array[String]
creature_data.is_active             # Boolean status
```

#### ✅ Correct Methods
```gdscript
# Age methods (built into CreatureData)
creature_data.get_age_category()              # Returns int (0-4)
creature_data.get_age_modifier()              # Returns float

# Stat methods
creature_data.get_stat("STR")                 # Returns int (1-1000)
creature_data.set_stat("STR", 150)            # Sets stat value

# Tag methods
creature_data.has_tag("Flying")               # Returns bool
creature_data.has_all_tags(["Small", "Fast"]) # Returns bool
creature_data.has_any_tag(["Large", "Medium"]) # Returns bool
creature_data.meets_tag_requirements(required, excluded) # Quest eligibility

# Serialization
creature_data.to_dict()                       # Returns Dictionary
CreatureData.from_dict(data)                  # Static factory method

# Serialization
var dict: Dictionary = creature_data.to_dict()
var creature: CreatureData = CreatureData.from_dict(dict)
```

### CreatureEntity (Node)
**File**: `scripts/entities/creature_entity.gd`

#### ✅ Correct Usage
```gdscript
# CreatureEntity wraps CreatureData for behavior
var entity: CreatureEntity = CreatureEntity.new()
entity.data = creature_data  # Assign data

# All actual data access goes through .data
var name: String = entity.data.creature_name
var age: int = entity.data.age_weeks
```

---

## 🎮 GameCore System Loading

### ✅ Correct System Access Pattern
```gdscript
# ALWAYS use GameCore.get_system() - enables lazy loading
var collection_system = GameCore.get_system("collection")
var save_system = GameCore.get_system("save")
var tag_system = GameCore.get_system("tag")
var age_system = GameCore.get_system("age")
var stat_system = GameCore.get_system("stat")

# Available system names:
# "collection" -> PlayerCollection
# "save"       -> SaveSystem
# "tag"        -> TagSystem
# "age"        -> AgeSystem
# "stat"       -> StatSystem
# "creature"   -> CreatureSystem
# "quest"      -> QuestSystem
```

### ✅ SignalBus Access
```gdscript
var signal_bus: SignalBus = GameCore.get_signal_bus()
```

---

## 🏷️ TagSystem Integration

### ✅ Correct Method Names
```gdscript
# Tag validation
tag_system.meets_tag_requirements(creature_data, required_tags)  # NOT creature_meets_requirements
tag_system.validate_tag_combination(tags_array)
tag_system.is_valid_tag(tag_name)

# Tag management
tag_system.add_tag_to_creature(creature_entity, tag)  # Takes CreatureEntity, not CreatureData
tag_system.remove_tag_from_creature(creature_entity, tag)

# Collection filtering
tag_system.filter_creatures_by_tags(creatures, required_tags, excluded_tags)
```

### ✅ Correct Array Typing
```gdscript
# WRONG - Type inference issues
var available = collection_system.get_available_for_quest(["Flying"])

# RIGHT - Explicit typing
var required_tags: Array[String] = ["Flying"]
var available = collection_system.get_available_for_quest(required_tags)
```

---

## ⏰ AgeSystem Integration

### ✅ Correct Method Usage
```gdscript
# Use CreatureData's built-in methods, NOT AgeSystem methods
var age_category: int = creature_data.get_age_category()  # NOT age_system.get_creature_age_category()
var modifier: float = creature_data.get_age_modifier()

# AgeSystem methods for aging operations
age_system.age_creature_by_weeks(creature_data, weeks)
age_system.age_creature_to_category(creature_data, target_category)
age_system.age_all_creatures(creature_list, weeks)
```

---

## 🗃️ PlayerCollection System

### ✅ Correct Method Calls
```gdscript
# Active roster (6 creature limit)
collection_system.add_to_active(creature_data)
collection_system.remove_from_active(creature_id)  # Takes ID string
collection_system.move_to_stable(creature_id)

# Stable collection (unlimited)
collection_system.add_to_stable(creature_data)
collection_system.remove_from_stable(creature_id)
collection_system.promote_to_active(creature_id)

# Retrieval methods
var active: Array[CreatureData] = collection_system.get_active_creatures()
var stable: Array[CreatureData] = collection_system.get_stable_creatures()

# Quest integration
var available: Array[CreatureData] = collection_system.get_available_for_quest(required_tags)

# Statistics
var stats: Dictionary = collection_system.get_collection_stats()
var metrics: Dictionary = collection_system.get_performance_metrics()
```

### ✅ Search Criteria Format
```gdscript
var criteria: Dictionary = {
    "species_id": "scuttleguard",           # NOT "species"
    "required_tags": ["Small", "Fast"],     # Array[String]
    "age_category": 2,                      # Int (0-4)
    "min_stats": {"STR": 100, "DEX": 80}   # Dictionary
}
var results: Array[CreatureData] = collection_system.search_creatures(criteria)
```

---

## 🎯 CreatureGenerator Usage

### ✅ Correct Species Names
```gdscript
# Available species (hardcoded in Stage 1)
"scuttleguard"    # Starter species
"stone_sentinel"  # Premium species
"wind_dancer"     # Flying species
"glow_grub"       # Utility species
```

### ✅ Correct Generation Methods
```gdscript
# Basic generation
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# With specific algorithm
var premium: CreatureData = CreatureGenerator.generate_creature_data(
    "stone_sentinel",
    CreatureGenerator.GenerationType.HIGH_ROLL
)

# Batch generation
var population: Array[CreatureData] = CreatureGenerator.generate_population_data(100)
```

---

## 🧬 SpeciesSystem Usage (Task 10)

### ✅ Correct Method Calls
```gdscript
# Get the species system
var species_system = GameCore.get_system("species")

# Basic species queries
var all_species: Array[String] = species_system.get_all_species()
var starters: Array[String] = species_system.get_species_by_category("starter")
var rare_species: Array[String] = species_system.get_species_by_rarity("rare")

# Species validation
if species_system.is_valid_species("scuttleguard"):
    var info: Dictionary = species_system.get_species_info("scuttleguard")

# Random selection
var random_species: String = species_system.get_random_species()
var random_starter: String = species_system.get_random_species("starter", "")
```

### ✅ Species Information Format
```gdscript
# get_species_info() returns Dictionary with:
{
    "display_name": "Scuttleguard",
    "category": "starter",
    "rarity": "common",
    "price": 200,
    "lifespan_weeks": 520,
    "guaranteed_tags": ["Small", "Territorial", "Dark Vision"],
    "optional_tags": ["Stealthy", "Enhanced Hearing", "Nocturnal"],
    "stat_ranges": {
        "strength": {"min": 70, "max": 130},
        "constitution": {"min": 80, "max": 140},
        # ... other stats
    },
    "name_pool": ["Skitter", "Dash", "Scout", "Guard", ...]
}
```

### ✅ CreatureGenerator Integration (Automatic)
```gdscript
# CreatureGenerator automatically uses SpeciesSystem with fallback
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
# This now uses SpeciesSystem.get_species_info() internally

# Still works the same way, but now backed by SpeciesSystem
var valid: bool = CreatureGenerator.is_valid_species("wind_dancer")
var species_list: Array[String] = CreatureGenerator.get_available_species()
```

### ✅ Available Species (Default Fallback)
```gdscript
# Current species (when no .tres files exist):
"scuttleguard"    # Starter species - Small, territorial guardian
"stone_sentinel"  # Premium species - Large, armored defender
"wind_dancer"     # Premium species - Medium, flying, fast
"glow_grub"       # Utility species - Small, bioluminescent, docile
```

---

## 📡 SignalBus Integration

### ✅ Signal Names and Emission Methods
```gdscript
# Collection signals (Task 8)
signal_bus.emit_creature_acquired(creature_data, source)
signal_bus.emit_creature_released(creature_data, reason)
signal_bus.emit_active_roster_changed(roster_array)
signal_bus.emit_stable_collection_updated(operation, creature_id)
signal_bus.emit_collection_milestone_reached(milestone, count)

# Age signals (Task 6)
signal_bus.emit_creature_category_changed(creature_data, old_cat, new_cat)
signal_bus.emit_creature_expired(creature_data)
signal_bus.emit_aging_batch_completed(aged_count, total_weeks)

# Tag signals (Task 4)
signal_bus.emit_creature_tag_added(creature_data, tag)
signal_bus.emit_creature_tag_removed(creature_data, tag)

# Species signals (Task 10)
signal_bus.emit_species_loaded(species_id)
signal_bus.emit_species_registered(species_id, category)
signal_bus.emit_species_validation_failed(species_id, errors)
```

### ✅ Signal Connection Pattern
```gdscript
func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()
    if signal_bus:
        signal_bus.creature_acquired.connect(_on_creature_acquired)
        signal_bus.active_roster_changed.connect(_on_roster_changed)
```

---

## 💾 SaveSystem Integration

### ✅ Correct Save/Load Methods
```gdscript
# Game state operations
save_system.save_game_state(slot_name)
save_system.load_game_state(slot_name)

# Creature collection operations
save_system.save_creature_collection(creatures_array, slot_name)
var creatures: Array[CreatureData] = save_system.load_creature_collection(slot_name)

# Individual creatures
save_system.save_individual_creature(creature_data, filename)
var creature: CreatureData = save_system.load_individual_creature(filename)
```

---

## ⏱️ Performance and Timing

### ✅ Correct Time Measurement
```gdscript
# WRONG - nanosecond property doesn't exist
var time = Time.get_time_dict_from_system().nanosecond

# RIGHT - Use millisecond ticks
var start_time: int = Time.get_ticks_msec()
# ... do work ...
var end_time: int = Time.get_ticks_msec()
var duration: int = end_time - start_time
```

### ✅ Quiet Mode for Performance Tests
```gdscript
# Disable verbose output during bulk operations
var original_debug: bool = signal_bus._debug_mode
signal_bus.set_debug_mode(false)
collection_system.set_quiet_mode(true)

# ... perform bulk operations ...

# Restore original state
signal_bus.set_debug_mode(original_debug)
collection_system.set_quiet_mode(false)
```

---

## 🧪 Testing Patterns

### ✅ Signal Handler Pattern for Tests
```gdscript
# Use class-level variables for runtime control
var test_quiet_mode_global: bool = false

# Signal handlers reference class variable
var handler = func(data):
    if not test_quiet_mode_global:
        print("Signal received: %s" % data)

# Runtime control works correctly
test_quiet_mode_global = true  # Silences handlers
```

### ✅ Array Type Safety in Tests
```gdscript
# WRONG - Type inference issues
collection_system.search_creatures({"required_tags": ["Flying"]})

# RIGHT - Explicit typing
var search_criteria: Dictionary = {
    "required_tags": Array(["Flying"], TYPE_STRING, "", null)
}
# OR
var required_tags: Array[String] = ["Flying"]
var search_criteria: Dictionary = {"required_tags": required_tags}
```

---

## 📋 System Integration Checklist

### Before Calling Any System Method:
1. ✅ Load system via `GameCore.get_system()`
2. ✅ Check method name spelling
3. ✅ Use correct property names (`id` not `creature_id`)
4. ✅ Use explicit array typing for parameters
5. ✅ Handle null/error cases appropriately

### Before Implementing New Features:
1. ✅ Check existing signal names in SignalBus
2. ✅ Follow established naming conventions
3. ✅ Use validation patterns from existing systems
4. ✅ Add debug logging with quiet mode support
5. ✅ Include performance measurement code

---

## 🎯 Copy-Paste Ready Code Snippets

### Basic System Setup
```gdscript
func _ready() -> void:
    # Load systems
    var signal_bus: SignalBus = GameCore.get_signal_bus()
    var collection_system = GameCore.get_system("collection")
    var tag_system = GameCore.get_system("tag")

    # Connect signals
    if signal_bus:
        signal_bus.creature_acquired.connect(_on_creature_acquired)
```

### Creature Creation and Collection
```gdscript
# Generate creature
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
creature.creature_name = "My Creature"

# Add to collection
if collection_system.add_to_active(creature):
    print("Added to active roster")
else:
    collection_system.add_to_stable(creature)
    print("Added to stable collection")
```

### Quest Availability Check
```gdscript
var required_tags: Array[String] = ["Flying", "Fast"]
var available: Array[CreatureData] = collection_system.get_available_for_quest(required_tags)

for creature in available:
    print("Available: %s (age: %d)" % [creature.creature_name, creature.age_weeks])
```

### Performance Testing Template
```gdscript
func test_performance():
    # Setup quiet mode
    var signal_bus: SignalBus = GameCore.get_signal_bus()
    var original_debug: bool = signal_bus._debug_mode
    signal_bus.set_debug_mode(false)

    var start_time: int = Time.get_ticks_msec()

    # ... performance test code ...

    var end_time: int = Time.get_ticks_msec()
    var duration: int = end_time - start_time

    # Restore state
    signal_bus.set_debug_mode(original_debug)

    print("Test completed in %dms" % duration)
```

---

## 🚨 Critical Reminders

1. **Always use `creature_data.id`, never `creature_data.creature_id`**
2. **Use `species_id`, never `species`**
3. **Age methods are on CreatureData, not AgeSystem**
4. **TagSystem method is `meets_tag_requirements()`, not `creature_meets_requirements()`**
5. **Use explicit array typing: `Array[String]` for all tag arrays**
6. **Load systems before use: `GameCore.get_system()`**
7. **Use millisecond ticks for timing: `Time.get_ticks_msec()`**
8. **Enable quiet modes for performance tests to avoid output overflow**

---

**This document should eliminate 90%+ of integration errors encountered in Task 8. Reference it before implementing any system interactions!**