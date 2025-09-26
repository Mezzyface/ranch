# 📖 Creature Collection Game - Usage Guide

This guide provides comprehensive documentation for using the implemented Stage 1 systems of the Creature Collection Game.

## 🏗️ Architecture Overview

The game uses a proven MVC (Model-View-Controller) architecture with:
- **Resources** for pure data (CreatureData, QuestData, etc.)
- **Nodes** for behavior and game logic (CreatureEntity, Systems, etc.)
- **GameCore** as a single autoload managing all subsystems
- **SignalBus** for centralized, validated communication

## 🎮 GameCore System

### Basic Access Pattern
```gdscript
# Access any subsystem through GameCore (lazy-loaded)
var stat_system: StatSystem = GameCore.get_system("stat")
var tag_system: TagSystem = GameCore.get_system("tag")
var age_system: AgeSystem = GameCore.get_system("age")
var save_system: SaveSystem = GameCore.get_system("save")

# Access SignalBus for communication
var signal_bus: SignalBus = GameCore.get_signal_bus()
```

### Available Systems
- `"stat"` - StatSystem for calculations and modifiers
- `"tag"` - TagSystem for validation and filtering
- `"age"` - AgeSystem for lifecycle management
- `"save"` - SaveSystem for data persistence

### Version Information
```gdscript
print("GameCore Version: %s" % GameCore.get_version())  # "1.0"
print("Config: %s" % GameCore.get_config())  # Development settings
```

## 📡 SignalBus Communication

### Signal Types Available

**Creature Lifecycle Events**:
```gdscript
# Emit creature events (with validation)
signal_bus.creature_created.emit(creature_data)
signal_bus.creature_stats_changed.emit(creature_data, "strength", old_value, new_value)
signal_bus.creature_aged.emit(creature_data, new_age)
signal_bus.creature_category_changed.emit(creature_data, old_category, new_category)
signal_bus.creature_expired.emit(creature_data)

# Connect to events
signal_bus.creature_created.connect(_on_creature_created)
```

**Save/Load Events**:
```gdscript
# Save system signals
signal_bus.save_completed.emit(success: bool)
signal_bus.load_completed.emit(success: bool)
signal_bus.auto_save_triggered.emit()
signal_bus.backup_created.emit(source_slot: String, backup_slot: String)
signal_bus.backup_restored.emit(restored_slot: String, backup_source: String)
```

**Tag System Events**:
```gdscript
# Tag management signals
signal_bus.creature_tags_changed.emit(creature_data, old_tags, new_tags)
signal_bus.tag_added.emit(creature_data, tag_name)
signal_bus.tag_removed.emit(creature_data, tag_name)
signal_bus.tag_validation_failed.emit(creature_data, invalid_tags)
```

### Signal Validation
All signals validate their parameters automatically:
```gdscript
# ✅ Valid emission
signal_bus.creature_created.emit(valid_creature_data)

# ❌ Invalid emission (will show error and not emit)
signal_bus.creature_created.emit(null)  # Error: Cannot emit with null data
```

### Debug Mode
```gdscript
# Enable debug output for signal flow
signal_bus.set_debug_mode(true)

# Disable for production/testing
signal_bus.set_debug_mode(false)
```

## 🦎 Creature System

### CreatureData (Resource)
Pure data storage with automatic validation:

```gdscript
# Create new creature data
var creature: CreatureData = CreatureData.new()
creature.creature_name = "My Creature"
creature.species_id = "scuttleguard"
creature.age_weeks = 10
creature.lifespan_weeks = 520

# Set stats (automatically clamped to 1-1000)
creature.strength = 150
creature.constitution = 200
creature.dexterity = 120

# Manage tags
creature.tags = ["Medium", "Natural Armor", "Territorial"]

# Serialization
var data_dict: Dictionary = creature.to_dict()
var restored: CreatureData = CreatureData.from_dict(data_dict)
```

### CreatureEntity (Node)
Behavior and game logic layer:

```gdscript
# Create entity from data
var entity: CreatureEntity = CreatureEntity.new()
entity.setup_from_data(creature_data)
add_child(entity)

# Access data
var data: CreatureData = entity.data
print("Creature: %s" % data.creature_name)

# Entity automatically emits signals for stat changes
entity.data.strength = 200  # Triggers signals through SignalBus
```

### CreatureGenerator Utility
Static utility for creature creation:

```gdscript
# Available species: "scuttleguard", "stone_sentinel", "wind_dancer", "glow_grub"
var species: Array[String] = CreatureGenerator.get_available_species()

# Basic generation
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Generation with algorithm control
var premium: CreatureData = CreatureGenerator.generate_creature_data(
    "stone_sentinel",
    CreatureGenerator.GenerationType.HIGH_ROLL
)

# Available generation types:
# - UNIFORM: Even distribution across stat ranges
# - GAUSSIAN: Bell curve distribution (Box-Muller algorithm)
# - HIGH_ROLL: Biased toward higher stats (premium eggs)
# - LOW_ROLL: Biased toward lower stats (discount eggs)

# Generate with behavior (CreatureEntity)
var entity: CreatureEntity = CreatureGenerator.generate_creature_entity("wind_dancer")

# Batch generation for testing/populations
var population: Array[CreatureData] = CreatureGenerator.generate_population_data(100)
```

### Species Information
```gdscript
# Get species data
var species_info: Dictionary = CreatureGenerator.get_species_info("scuttleguard")
print("Lifespan: %d weeks" % species_info.lifespan_weeks)
print("Guaranteed tags: %s" % species_info.guaranteed_tags)
print("Optional tags: %s" % species_info.optional_tags)

# Validate species
if CreatureGenerator.is_valid_species("my_species"):
    print("Species exists")
```

## 📊 StatSystem

### Basic Stat Operations
```gdscript
var stat_system: StatSystem = GameCore.get_system("stat")

# Get effective stats (includes age modifiers for competition)
var competition_str: int = stat_system.get_competition_stat(creature_data, "strength")
var competition_con: int = stat_system.get_competition_stat(creature_data, "constitution")

# Get base stats (no age modifiers, used for quest validation)
var base_str: int = stat_system.get_base_stat(creature_data, "strength")

# Stat breakdown for debugging
var breakdown: Dictionary = stat_system.get_stat_breakdown(creature_data, "strength")
print("Base: %d, Modifiers: %s, Effective: %d" % [
    breakdown.base_value,
    breakdown.modifiers,
    breakdown.effective_value
])
```

### Stat Name Aliases
The system accepts multiple names for each stat:
```gdscript
# These all access the same stat
stat_system.get_base_stat(creature, "strength")    # Primary name
stat_system.get_base_stat(creature, "str")         # Short form
stat_system.get_base_stat(creature, "STRENGTH")    # Case insensitive

# Full mapping:
# STR/STRENGTH -> strength
# CON/CONSTITUTION -> constitution
# DEX/DEXTERITY -> dexterity
# INT/INTELLIGENCE -> intelligence
# WIS/WISDOM -> wisdom
# DIS/DISCIPLINE -> discipline
```

### Stat Validation
```gdscript
# Validate stat value (1-1000 range)
if stat_system.is_valid_stat_value(1500):  # false
    print("Valid stat")

# Validate stat name
if stat_system.is_valid_stat_name("strength"):  # true
    print("Valid stat name")
```

### Age Modifiers
Different contexts apply age modifiers differently:
- **Quest Requirements**: Use base stats (fair for all ages)
- **Competition Performance**: Use age-modified stats (realistic)

```gdscript
# Quest validation (no age penalty)
var quest_str: int = stat_system.get_base_stat(creature, "strength")

# Competition performance (age affects performance)
var competition_str: int = stat_system.get_competition_stat(creature, "strength")
```

## 🏷️ TagSystem

### Tag Categories (25 tags across 5 categories)
- **Size**: Small, Medium, Large (mutually exclusive)
- **Activity**: Diurnal, Nocturnal (mutually exclusive)
- **Social**: Social, Solitary (mutually exclusive)
- **Ability**: Dark Vision, Flies, Problem Solver, Constructor, etc.
- **Physical**: Natural Armor, Camouflage, Aquatic, etc.

### Tag Validation
```gdscript
var tag_system: TagSystem = GameCore.get_system("tag")

# Validate individual tag
if tag_system.is_valid_tag("Dark Vision"):
    print("Tag exists")

# Validate tag combination
var validation: Dictionary = tag_system.validate_tags(["Small", "Large"])  # Invalid - mutually exclusive
if not validation.valid:
    print("Invalid combination: %s" % validation.error)

# Get tag information
var description: String = tag_system.get_tag_description("Dark Vision")
var category: TagSystem.TagCategory = tag_system.get_tag_category("Dark Vision")
```

### Creature Tag Management
```gdscript
# Safe tag management (validates before applying)
if tag_system.can_add_tag_to_creature(creature_data, "Flies"):
    tag_system.add_tag_to_creature(creature_data, "Flies")

# Remove tag safely
tag_system.remove_tag_from_creature(creature_data, "Flies")

# Batch validation
var result: Dictionary = tag_system.validate_creature_tags(creature_data)
if not result.valid:
    print("Issues: %s" % result.issues)
```

### Collection Filtering
```gdscript
# Filter creatures by required tags (efficient: 0ms for 100 creatures)
var stealth_creatures: Array[CreatureData] = tag_system.filter_creatures_by_tags(
    all_creatures,
    ["Dark Vision", "Stealthy"]
)

# Advanced filtering with exclusions
var filtered: Array[CreatureData] = tag_system.filter_creatures_by_tags(
    all_creatures,
    ["Natural Armor"],      # Required tags
    ["Aquatic"]             # Excluded tags (optional parameter)
)

# Quest requirement matching
var requirements: Array[String] = ["Dark Vision", "Small"]
var suitable: Array[CreatureData] = tag_system.get_creatures_for_quest(all_creatures, requirements)
```

### Tag Dependencies & Incompatibilities
The system automatically enforces:
- **Dependencies**: "Flies" requires "Winged"
- **Mutual Exclusions**: Can't have both "Small" and "Large"
- **Incompatibilities**: "Aquatic" and "Flies" are incompatible

```gdscript
# Check dependencies
var deps: Array[String] = tag_system.get_tag_dependencies("Flies")  # ["Winged"]

# Check incompatibilities
var incompatible: Array[String] = tag_system.get_tag_incompatibilities("Aquatic")  # ["Flies"]
```

## ⏰ AgeSystem

### Age Categories (5 categories with performance modifiers)
- **Baby** (0-10% of lifespan): 0.6x stats
- **Juvenile** (10-25%): 0.8x stats
- **Adult** (25-80%): 1.0x stats
- **Elder** (80-95%): 0.9x stats
- **Ancient** (95%+): 0.8x stats

### Age Progression
```gdscript
var age_system: AgeSystem = GameCore.get_system("age")

# Age by weeks
if age_system.age_creature_by_weeks(creature_data, 26):  # Age by half year
    print("Creature aged successfully")

# Age to specific category
if age_system.age_creature_to_category(creature_data, 2):  # Age to Adult
    print("Creature is now Adult")

# Batch aging (efficient: <100ms for 1000 creatures)
var aged_count: int = age_system.age_all_creatures([creature1, creature2, creature3], 5)
```

### Age Information
```gdscript
# Get current age category
var category: int = creature_data.get_age_category()
print("Category: %s" % AgeSystem.AGE_CATEGORIES[category])

# Calculate weeks until next category
var weeks_needed: int = age_system.get_weeks_until_next_category(creature_data)

# Check lifespan remaining
var remaining: int = age_system.get_lifespan_remaining(creature_data)

# Check if expired
if age_system.is_creature_expired(creature_data):
    print("Creature has exceeded lifespan")
```

### Age Statistics
```gdscript
# Population analysis
var creatures: Array[CreatureData] = [creature1, creature2, creature3]
var distribution: Dictionary = age_system.get_age_distribution(creatures)
print("Juveniles: %d, Adults: %d, Elders: %d" % [
    distribution.get(1, 0),  # Juvenile
    distribution.get(2, 0),  # Adult
    distribution.get(3, 0)   # Elder
])

# Species lifespan information
var lifespans: Dictionary = age_system.get_species_lifespan_variety()
for species in lifespans:
    print("%s lives %d weeks" % [species, lifespans[species]])
```

### Age Modifiers for Stats
Age affects competition performance but not quest eligibility:

```gdscript
# Quest requirements use base stats (no age penalty)
var quest_eligible: bool = creature_data.strength >= 100

# Competition uses age-modified stats
var stat_system: StatSystem = GameCore.get_system("stat")
var competition_str: int = stat_system.get_competition_stat(creature_data, "strength")
# Automatically applies age modifier based on category
```

## 💾 SaveSystem

### Basic Save/Load Operations
```gdscript
var save_system: SaveSystem = GameCore.get_system("save")

# Save current game state
if save_system.save_game_state("my_save_slot"):
    print("Game saved successfully")

# Load game state
if save_system.load_game_state("my_save_slot"):
    print("Game loaded successfully")

# Check if save exists
if save_system.slot_exists("my_save_slot"):
    print("Save slot exists")

# Get save information
var info: Dictionary = save_system.get_save_info("my_save_slot")
print("Created: %s" % Time.get_datetime_string_from_unix_time(info.created_timestamp))
print("Size: %.2f MB" % info.size_mb)
```

### Creature Collection Persistence
```gdscript
# Save creature collection
var creatures: Array[CreatureData] = get_my_creatures()
if save_system.save_creature_collection(creatures, "main_save"):
    print("Creatures saved")

# Load creatures
var loaded_creatures: Array[CreatureData] = save_system.load_creature_collection("main_save")
print("Loaded %d creatures" % loaded_creatures.size())

# Individual creature operations
if save_system.save_individual_creature(special_creature, "main_save"):
    print("Individual creature saved")

var loaded_creature: CreatureData = save_system.load_individual_creature("creature_id", "main_save")
```

### Auto-Save System
```gdscript
# Enable auto-save every 5 minutes
save_system.enable_auto_save(5)

# Manual auto-save trigger
save_system.trigger_auto_save()

# Disable auto-save
save_system.disable_auto_save()

# Check auto-save status
if save_system.is_auto_save_enabled():
    print("Auto-save interval: %d minutes" % save_system.get_auto_save_interval())
```

### Backup & Recovery
```gdscript
# Create backup
if save_system.create_backup("main_save", "backup_2025_09_25"):
    print("Backup created")

# Restore from backup
if save_system.restore_from_backup("main_save", "backup_2025_09_25"):
    print("Backup restored")

# Validate save integrity
var validation: Dictionary = save_system.validate_save_data("main_save")
if not validation.valid:
    print("Save corrupted: %s" % validation.error)

    # Attempt automatic repair
    if save_system.repair_corrupted_save("main_save"):
        print("Save repaired successfully")
```

### Save Slot Management
```gdscript
# Get all save slots
var slots: Array[String] = save_system.get_all_save_slots()
print("Available saves: %s" % slots)

# Delete save slot
if save_system.delete_save_slot("old_save"):
    print("Save deleted")

# Get save size information
var size: float = save_system.get_save_size("main_save")  # Size in MB
```

### Performance Optimization
The SaveSystem uses a hybrid approach:
- **ConfigFile**: For settings, metadata, simple game data
- **ResourceSaver**: For complex creature data (.tres format)

```gdscript
# Performance is optimized for:
# - Save operations: <200ms for 100+ creatures
# - Load operations: <200ms for 100+ creatures
# - Batch operations: Pre-allocated arrays for efficiency
# - Memory usage: Godot 4.5 cache workarounds implemented
```

## 🧪 Testing

### Running Tests
```bash
# Console testing (recommended for CI/CD)
"C:\Program Files\Godot\Godot_console.exe" --headless --scene test_console_scene.tscn

# Full testing (comprehensive validation)
"C:\Program Files\Godot\Godot.exe" --headless --scene test_setup.tscn
```

### Test Coverage
All implemented systems have comprehensive test coverage:

**System Integration Tests**:
- GameCore system loading and lazy initialization
- SignalBus communication and validation
- Cross-system compatibility verification

**Performance Tests**:
- CreatureGenerator: 1000 creatures in <100ms
- AgeSystem batch operations: 1000 creatures in <100ms
- SaveSystem operations: 100 creatures in <200ms
- TagSystem filtering: 100 creatures in 0ms

**Data Integrity Tests**:
- Save/load cycle verification
- Creature serialization/deserialization
- Tag validation and conflict detection
- Age progression and category transitions

**Error Handling Tests**:
- Invalid input validation
- Edge case handling
- Recovery from corrupted data
- Signal emission with invalid data

### Test Results
Current test status: **100% pass rate** across all implemented systems
- 8/8 console tests passing
- All Stage 1 systems fully validated
- Performance targets met across all benchmarks

## 🔧 Development Patterns

### Recommended Usage Patterns

**System Access**:
```gdscript
# Always use GameCore for system access (lazy-loaded)
var system: MySystem = GameCore.get_system("my_system")

# Cache system references in your classes
class_name MyController extends Node
var stat_system: StatSystem

func _ready():
    stat_system = GameCore.get_system("stat")  # Load once, use everywhere
```

**Signal Communication**:
```gdscript
# Always validate data before emitting
func emit_creature_event(creature: CreatureData):
    if creature == null:
        push_error("Cannot emit event with null creature")
        return

    var signal_bus: SignalBus = GameCore.get_signal_bus()
    signal_bus.creature_created.emit(creature)
```

**Error Handling**:
```gdscript
# Systems provide comprehensive error handling
var result: bool = age_system.age_creature_by_weeks(creature, -5)
if not result:
    print("Age operation failed - check console for details")
    # Error details automatically logged by system
```

**Performance Considerations**:
```gdscript
# Use batch operations for large datasets
var all_creatures: Array[CreatureData] = get_large_creature_collection()

# ✅ Efficient batch filtering
var filtered: Array[CreatureData] = tag_system.filter_creatures_by_tags(all_creatures, ["Natural Armor"])

# ❌ Avoid individual filtering in loops
# for creature in all_creatures:
#     if tag_system.creature_meets_requirements(creature, ["Natural Armor"]):
#         filtered.append(creature)
```

## 📚 Additional Resources

### Documentation Links
- [Implementation Plan](docs/implementation/implementation_plan.md) - Complete development roadmap
- [Stage 1 Overview](docs/implementation/stages/stage_1/00_stage_1_overview.md) - Technical implementation guide
- [Architecture Guide](CLAUDE.md) - AI assistant development guidance

### Performance Benchmarks
All systems meet or exceed performance targets:
- **GameCore**: System loading <2ms per system
- **CreatureGenerator**: 1000 creatures in 36ms (target: <100ms)
- **AgeSystem**: Batch aging 1000 creatures in 1ms (target: <100ms)
- **TagSystem**: Filtering 100 creatures in 0ms (instantaneous)
- **SaveSystem**: Save/load 100 creatures in 177ms average (target: <200ms)

### Known Limitations
Stage 1 focuses on core architecture. Future stages will add:
- User interface and visual feedback
- Quest system and progression
- Economic systems (shop, resources)
- Advanced creature interactions (breeding, training)
- Multiplayer features and creature sharing

The current implementation provides a solid foundation for all future features while maintaining excellent performance and reliability.