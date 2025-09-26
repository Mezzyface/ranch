# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A creature collection/breeding game built with Godot 4.5. Currently implementing Stage 1 (Core Foundation) with basic GameCore autoload and SignalBus architecture completed. The game features creature collection, training, breeding, and quest completion through strategic creature management.

## Core Architecture (v2.0 - Improved)

### Game Systems
- **6 Core Stats**: STR, CON, DEX, INT, WIS, DIS (scale 1-1000)
- **Tag System**: Environmental, behavioral, physical, and utility tags for creature traits
- **Age System**: 5 age categories (Baby, Juvenile, Adult, Elder, Ancient) with performance modifiers
- **Time Management**: Weekly cycles for training, competitions, and aging
- **Resource Economy**: Gold currency, food requirements, creature acquisition through shops

### Data Architecture (Godot 4.5) - UPDATED
- **MVC Pattern**: Resources for data, Nodes for behavior, clear separation
- **Single GameCore**: One autoload managing subsystems (NOT multiple singletons)
- **SignalBus**: Centralized signal routing (Resources don't emit signals)
- **Flexible Save System**: ConfigFile for settings, ResourceSaver for complex data (NOT store_var)
- **Lazy Loading**: Subsystems and resources loaded on demand
- **Object Pooling**: UI elements reused for performance
- **Cache Management**: Handle Godot 4 resource cache bugs with workarounds

## Godot 4.5 Implementation Guidelines

### Key Godot 4.x Features to Use
- **Strong Typing**: Use typed GDScript (`var creature: Creature`, `func get_stats() -> Dictionary`)
- **@export Variables**: For inspector-configurable creature attributes and species templates
- **Custom Resources**: Extend Resource class for Creature, Species, Quest data models
- **Signal Bus Pattern**: Central signal manager for decoupled communication
- **Node Groups**: For managing creature collections and batch operations

### GDScript Best Practices - CRITICAL UPDATES
```gdscript
# CORRECT: Separate data from behavior
class_name CreatureData extends Resource  # Pure data, NO signals
@export var creature_name: String = ""
@export var stats: Dictionary = {}

class_name CreatureEntity extends Node  # Behavior and signals here
signal stats_changed(creature: CreatureData)
var data: CreatureData

# CORRECT: Use SignalBus for communication
SignalBus.creature_created.emit(creature_data)

# Save System Options (choose based on needs):
# Option 1: ConfigFile for simple data/settings
var config := ConfigFile.new()
config.set_value("creatures", id, creature.to_dict())
config.save("user://save.cfg")

# Option 2: ResourceSaver for complex Resources (Godot's native approach)
ResourceSaver.save(creature_data, "user://creature_%s.tres" % id)
# WARNING: Resources can contain scripts - validate loaded data!

# Resource Cache Workaround (Godot 4 bug):
# After saving:
resource.take_over_path(resource.resource_path)
# When loading:
ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
```

### Performance Considerations
- **Object Pooling**: Reuse creature instances for UI elements
- **Resource Preloading**: Cache frequently used species templates
- **Lazy Loading**: Load creature sprites only when visible
- **Dictionary Caching**: Store calculated stats to avoid recomputation
- **Signal Connections**: Prefer loaded Resources over .new() for reliable signals
- **Cache Invalidation**: Use take_over_path() after saving Resources to update cache

## Implementation Plan

### Current Stage: Stage 1 - Core Foundation (In Progress - Task 1 Complete)
10-stage implementation roadmap totaling 19-24 weeks:

1. **Stage 1**: Core Data Models & Foundation (2-3 weeks) - Creature class, stats, tags, species resources
2. **Stage 2**: Time Management & Basic UI (2 weeks)
3. **Stage 3**: Shop System & Economy (2 weeks)
4. **Stage 4**: Training System (2 weeks)
5. **Stage 5**: Quest System - Tutorial Phase (2-3 weeks)
6. **Stage 6**: Competition System (2 weeks)
7. **Stage 7**: Advanced Quests (2-3 weeks)
8. **Stage 8**: Breeding System (2 weeks)
9. **Stage 9**: Polish & Additional Vendors (2 weeks)
10. **Stage 10**: Balancing & MVP Completion (1-2 weeks)

### Stage 1 Tasks - Implementation Order (Aligned with Actual Files)
Full task list with correct file references:
1. **✅ Project Setup & SignalBus** (`01_project_setup.md`) - GameCore autoload + SignalBus COMPLETE
2. **✅ Creature Class** (`02_creature_class.md`) - CreatureData + CreatureEntity COMPLETE
3. **✅ Stat System** (`03_stat_system.md`) - Stat calculations and utilities COMPLETE
4. **✅ Tag System** (`04_tag_system.md`) - Tag management and validation COMPLETE
5. **✅ Creature Generation** (`05_creature_generation.md`) - Random creature creation COMPLETE
6. **✅ Age System** (`06_age_system.md`) - Age progression and effects COMPLETE
7. **✅ Save/Load System** (`07_save_load_system.md`) - ConfigFile persistence COMPLETE
8. **Player Collection** (`08_player_collection.md`) - Active/stable roster management
9. **Resource Tracking** (`09_resource_tracking.md`) - Gold/item economy
10. **Species Resources** (`10_species_resources.md`) - Species templates
11. **Global Enums** (`11_global_enums.md`) - Type-safe enumerations

⚠️ **CRITICAL**: See `docs/implementation/IMPROVED_ARCHITECTURE.md` for architecture details

## Commands

### Development Commands
```bash
# Open Godot project
godot project.godot

# Check project compilation
godot --check-only project.godot

# Export build (after export templates configured)
godot --export "Windows Desktop" builds/game.exe
```

### Testing Commands
```bash
# Show available individual tests
godot --headless --scene tests/test_runner.tscn

# Run all tests sequentially
godot --headless --scene tests/test_all.tscn

# Run individual system tests
godot --headless --scene tests/individual/test_signalbus.tscn
godot --headless --scene tests/individual/test_creature.tscn
godot --headless --scene tests/individual/test_stats.tscn
godot --headless --scene tests/individual/test_tags.tscn
godot --headless --scene tests/individual/test_generator.tscn
godot --headless --scene tests/individual/test_age.tscn
godot --headless --scene tests/individual/test_save.tscn
godot --headless --scene tests/individual/test_collection.tscn

# Run comprehensive test (may timeout with verbose output)
godot --headless --scene test_setup.tscn
```

### Current Status
- **✅ Godot project created** - Complete with GameCore architecture
- **✅ Task 1 COMPLETE** - Project setup with GameCore and enhanced SignalBus
- **✅ Task 2 COMPLETE** - Creature Class with CreatureData/CreatureEntity separation
- **✅ Task 3 COMPLETE** - Stat System with advanced modifiers and age mechanics
- **✅ Task 4 COMPLETE** - Tag System with comprehensive validation and quest integration
- **✅ Task 5 COMPLETE** - Creature Generation with 4 species, 4 algorithms, and performance optimization
- **✅ Task 6 COMPLETE** - Age System for creature lifecycle progression and time-based mechanics
- **✅ Task 7 COMPLETE** - Save/Load System with hybrid persistence, auto-save, and comprehensive validation
- **🚀 Ready for Task 8** - Player Collection system for active/stable creature roster management
- **All tests passing** - AgeSystem and SaveSystem fully functional with robust signal handling
- **Test fixes complete** - Category transitions, weeks calculation, and SignalBus integration working perfectly
- **Progress**: 7/11 Stage 1 tasks complete (~64%)

## Key Implementation Notes

### Documentation Structure
- **docs/design/**: Game mechanics and systems (16 files)
- **docs/implementation/**: Technical specs and stage tasks (14 files)
- **docs/project/**: Project management documents
- Full documentation map in `README.md` and `docs/STRUCTURE.md`

### Art Assets
- **Using Tiny Swords asset pack** for creature sprites
- 11 mapped species using available sprites (spiders, turtles, monks, etc.)
- See `docs/design/ASSET_MAPPING_TINY_SWORDS.md` for sprite-to-species mappings

### Quest Line: "A Gem of a Problem" (TIM-01 to TIM-06)
Tutorial progression teaching creature selection:
- **TIM-01**: Basic warehouse guard (single creature with Dark Vision)
- **TIM-02**: Cave exploration (Natural Armor + Camouflage)
- **TIM-03**: Complex facility (pest control + sanitation + security)
- **TIM-04**: Construction site (heavy labor + logistics)
- **TIM-05**: High-security vault (elite guardian)
- **TIM-06**: Exhibition setup (multiple specialized roles)

### Economic Flow
- Starting: 500 gold + 2-3 creatures
- Quest line net profit: +4,690 gold
- Creature costs: 50-800 gold depending on rarity
- Weekly food cost: ~25 gold per active creature

### Critical Godot 4.5 Gotchas
- Resources with signals can cause issues - keep data and behavior separate
- Use `take_over_path()` after saving Resources to handle cache bugs
- Prefer ConfigFile for settings, ResourceSaver for complex game data
- Always use typed GDScript for better performance and error checking

## Stage 1 Lessons Learned

### ✅ Task 1 (Project Setup) - COMPLETED & VERIFIED
**Key Issues Discovered & Solutions:**

1. **Autoload Class Naming Conflict**
   - **Issue**: `class_name GameCore` conflicts with autoload singleton name
   - **Solution**: Remove `class_name` from autoload scripts, use `extends Node` only
   - **Why**: Godot 4.5 autoloads should not have class_name declarations

2. **Type Inference Warnings**
   - **Issue**: `var version := config.get_value()` causes Variant typing warnings
   - **Solution**: Use explicit typing: `var version: int = config.get_value()`
   - **Why**: Godot 4.5 treats warnings as errors in strict mode

3. **Input Map Configuration**
   - **Issue**: Input actions need proper modifier key settings in project.godot
   - **Solution**: Set `"ctrl_pressed":true` for Ctrl+key combinations manually
   - **Why**: Godot editor may not export modifier keys correctly to project file

4. **Lazy Loading Verification**
   - **Issue**: Systems won't load until first accessed, signals may not connect
   - **Solution**: Force system loading before emitting relevant signals
   - **Pattern**: `GameCore.get_system("save")` before `save_requested.emit()`

5. **Missing Placeholder Classes**
   - **Issue**: SignalBus references QuestData before it exists, causing parse errors
   - **Solution**: Create minimal placeholder Resource classes early
   - **Why**: GDScript requires all referenced types to exist for compilation

6. **Input Action Conflicts**
   - **Issue**: Multiple actions can map to same key (S for both shop and save)
   - **Solution**: Use modifiers properly - S for shop, Ctrl+S for save
   - **Testing**: Add debug prints to verify correct action triggering

7. **Unused Signal Warnings**
   - **Issue**: SignalBus declares all signals upfront, causing "never used" warnings
   - **Solution**: Comment out unused signals during early development, uncomment as needed
   - **Why**: Godot warns about declared but unused signals to prevent code bloat

8. **Tool Mode vs Runtime Testing**
   - **Issue**: `@tool` EditorScript can't access autoload methods (placeholder instance error)
   - **Solution**: Use regular Node with `_ready()` and scene for testing instead of EditorScript
   - **Pattern**: Create test.tscn scene with test script, run scene for integration testing

### Best Practices Established:
- **Always test compilation** after each script creation
- **Add debug output** for input and signal verification during development
- **Load systems explicitly** before emitting signals they need to handle
- **Use explicit typing** for all variables to avoid inference warnings
- **Create placeholder classes** for forward references immediately
- **Prefix unused parameters** with underscore (`_config`) to avoid warnings

### Verification Checklist for Future Tasks:
- [ ] No compilation errors in Godot console
- [ ] All referenced classes exist (even as placeholders)
- [ ] Input actions work as expected with debug output
- [ ] Systems load correctly when accessed
- [ ] Signals flow from source to destination with debug confirmation

## Stage 1 Task 2 Lessons Learned

### ✅ Task 2 (SignalBus Enhancement) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Enhanced Signal Architecture**
   - **Success**: Uncommented creature lifecycle signals while keeping unused signals commented
   - **Pattern**: Declare signals as needed, not all upfront to avoid unused warnings
   - **Result**: Clean console with expected "unused signal" warnings for future features

2. **Robust Connection Management**
   - **Success**: `connect_signal_safe()` and `disconnect_signal_safe()` with full validation
   - **Pattern**: Return boolean success values, track connections for debugging
   - **Result**: Bulletproof signal connections with comprehensive error handling

3. **Validated Signal Emission**
   - **Success**: Emission wrapper methods prevent invalid data from propagating
   - **Pattern**: Validate inputs before emission, use debug logging for verification
   - **Result**: Red error messages in console confirm validation works (this is good!)

4. **Debug System Architecture**
   - **Success**: Toggle debug mode, connection tracking, comprehensive logging
   - **Pattern**: Debug information helps during development, can be disabled in production
   - **Result**: Excellent visibility into signal flow for troubleshooting

### New Best Practices Established:
- **Signal validation is critical** - Never emit with null/invalid data
- **Connection tracking aids debugging** - Know what's connected where
- **Expected warnings are acceptable** - Yellow unused signal warnings are normal during development
- **Red validation errors are good** - They prove the system is protecting against bad data
- **Comprehensive test coverage** - Test both success and failure cases
- **Debug logging during development** - Essential for verifying signal flow

### Updated Verification Checklist:
- [ ] Expected unused signal warnings (yellow) are acceptable
- [ ] Validation error messages (red) prove protection works
- [ ] Signal emissions work with valid data
- [ ] Connection management tracks properly
- [ ] Debug mode toggle functions correctly

## Stage 1 Task 2 Lessons Learned

### ✅ Task 2 (Creature Classes) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Perfect Data/Behavior Separation**
   - **Success**: CreatureData (Resource) contains only data, NO signals
   - **Success**: CreatureEntity (Node) handles all behavior and signal emission
   - **Validation**: Test confirms "CreatureData has NO signals (correct!)"

2. **Stat System Foundation**
   - **Success**: Stats clamp properly to 1-1000 range
   - **Success**: Stat accessors work with multiple names (STR/STRENGTH)
   - **Success**: Age modifiers calculate correctly

3. **Serialization Ready**
   - **Success**: to_dict() and from_dict() implemented
   - **Pattern**: Clean serialization without signals ensures save stability

4. **Signal Integration**
   - **Success**: All creature signals emit through centralized SignalBus
   - **Success**: Validation prevents null/invalid data emission
   - **Pattern**: Use SignalBus emit helpers for consistency

### New Best Practices from Task 2:
- **Array.erase() returns void in Godot 4** - Check existence first with has() methods
- **Resource setters work for clamping** - Use set(value) for automatic validation
- **Age categories use percentages** - More flexible than fixed age ranges
- **Performance scores need modifiers** - Age affects effective stats
- **Tag validation is critical** - Prevent invalid tags early

## Stage 1 Task 4 Lessons Learned

### ✅ Task 4 (Tag System) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Comprehensive Tag Architecture**
   - **Success**: 25 tags across 5 categories with complete metadata
   - **Success**: Complex validation with mutual exclusions, dependencies, incompatibilities
   - **Validation**: All 12 test scenarios passed with 0ms performance

2. **Advanced Validation System**
   - **Success**: Mutual exclusions prevent conflicts (Size, Activity patterns, Social/Solitary)
   - **Success**: Dependencies enforce requirements (Flies→Winged, Sentient→Problem Solver)
   - **Success**: Incompatibilities prevent invalid combinations (Aquatic↔Flies)
   - **Pattern**: Validate before modification to prevent invalid states

3. **Quest Integration Ready**
   - **Success**: Tag requirement matching for quest eligibility
   - **Success**: Collection filtering by required/excluded tags
   - **Success**: Tag match scoring for optimal creature selection
   - **Pattern**: Perfect (1.0) and partial (0.33) scoring system works

4. **Performance Excellence**
   - **Success**: 100 creatures filtered in 0ms demonstrates optimization
   - **Success**: Efficient filtering handles 1000+ creature collections
   - **Pattern**: Cache validation results and use efficient data structures

5. **CreatureEntity Integration**
   - **Success**: Safe tag management through TagSystem validation
   - **Success**: Proper fallback behavior when TagSystem not loaded
   - **Success**: Signal integration with comprehensive error reporting
   - **Pattern**: Use system validation before direct data modification

6. **Signal Architecture Enhancement**
   - **Success**: 4 new tag signals with proper validation
   - **Success**: Debug logging shows signal flow clearly
   - **Pattern**: Validated emission methods prevent invalid data propagation

### New Best Practices from Task 4:
- **Validation before modification is crucial** - Prevent invalid states from occurring
- **Performance testing validates optimization** - 0ms filtering proves efficient algorithms
- **Complex validation systems need comprehensive test coverage** - 12 scenarios ensure reliability
- **Signal validation provides excellent debugging** - Red errors prove protection works
- **String-based tags work well for Stage 1** - Enum migration planned for later stages
- **CreatureEntity fallback patterns improve robustness** - System works even with missing dependencies
- **Dictionary-based tag metadata scales well** - Easy to add new tags and properties

### Updated Verification Checklist from Task 4:
- [ ] TagSystem loads via GameCore lazy loading
- [ ] All 25 tags defined with proper categories
- [ ] Validation prevents size conflicts (Small+Large)
- [ ] Dependencies enforced (Flies requires Winged)
- [ ] Incompatibilities blocked (Aquatic vs Flies)
- [ ] Quest requirement matching works
- [ ] Collection filtering efficient (0ms for 100 creatures)
- [ ] CreatureEntity integration safe with validation
- [ ] Signal flow shows proper emission and validation
- [ ] Performance handles large datasets gracefully

## Stage 1 Task 5 Lessons Learned

### ✅ Task 5 (Creature Generation) - COMPLETED & VERIFIED
**Key Achievements:**

1. **CreatureGenerator Utility Class Architecture**
   - **Success**: Static utility class (RefCounted, not GameCore subsystem)
   - **Success**: Generates CreatureData by default (lightweight for save/serialization)
   - **Success**: CreatureEntity generation only when behavior needed
   - **Pattern**: Follows established MVC separation patterns from Tasks 1-4

2. **Complete Species Implementation**
   - **Success**: 4 species with distinct stat ranges, tags, and lifespans
   - **Success**: Scuttleguard (starter), Stone Sentinel (premium), Wind Dancer (flying), Glow Grub (utility)
   - **Success**: All species integrate with TagSystem validation
   - **Pattern**: Hardcoded for Stage 1, ready for SpeciesSystem migration in Task 10

3. **Generation Algorithm Variety**
   - **Success**: UNIFORM, GAUSSIAN (Box-Muller), HIGH_ROLL, LOW_ROLL algorithms
   - **Success**: Each algorithm produces expected statistical distributions
   - **Success**: Premium eggs (HIGH_ROLL) vs discount eggs (LOW_ROLL) differentiation
   - **Pattern**: Algorithm selection affects creature quality as designed

4. **Performance Excellence**
   - **Success**: 1000 creatures generated in <100ms (target met)
   - **Success**: Pre-allocation and caching optimizations effective
   - **Success**: Population generation scales linearly
   - **Pattern**: Performance-first approach with batch operations

5. **Property Consistency Achieved**
   - **Success**: Unified `lifespan_weeks` property across CreatureData and species data
   - **Success**: Type safety fixes for all Array[String] assignments
   - **Success**: Godot 4.5 compilation without critical errors
   - **Pattern**: Explicit typing and consistent naming prevents confusion

6. **TagSystem Integration**
   - **Success**: Guaranteed tags always assigned, optional tags 25% probability
   - **Success**: Full TagSystem validation during generation
   - **Success**: Graceful fallback when TagSystem unavailable
   - **Pattern**: Validation-first approach with fallback behavior

### New Best Practices from Task 5:
- **Static utility classes work well** for generation without lifecycle management
- **CreatureData-first generation** improves serialization and performance
- **Unified property naming** (lifespan_weeks) prevents assignment errors
- **Performance targets drive architecture** - pre-allocation and caching essential
- **Validation during generation** prevents invalid creature creation
- **Factory method patterns** provide flexibility for different use cases
- **Statistical validation** ensures generation algorithms work as intended

### CreatureGenerator Usage Patterns:
```gdscript
# Basic generation (most common)
var creature_data: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Generation with specific algorithm
var premium_creature: CreatureData = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.HIGH_ROLL)

# Full entity when behavior needed immediately
var creature_entity: CreatureEntity = CreatureGenerator.generate_creature_entity("wind_dancer")

# Starter creature for new players (boosted stats)
var starter: CreatureEntity = CreatureGenerator.generate_starter_creature()

# Shop integration
var egg_creature: CreatureData = CreatureGenerator.generate_from_egg("glow_grub", "premium")

# Batch generation for testing/population
var population: Array[CreatureData] = CreatureGenerator.generate_population_data(100)

# Species validation
if CreatureGenerator.is_valid_species("scuttleguard"):
    var info: Dictionary = CreatureGenerator.get_species_info("scuttleguard")
```

### Updated Verification Checklist from Task 5:
- [ ] CreatureGenerator loads as static utility class (not GameCore subsystem)
- [ ] All 4 species generate with proper stat ranges and tags
- [ ] Generation algorithms produce expected distributions
- [ ] Performance target met: 1000 creatures in <100ms
- [ ] Property consistency: lifespan_weeks unified across codebase
- [ ] TagSystem integration validates guaranteed/optional tags
- [ ] StatSystem integration works with generated creatures
- [ ] CreatureEntity creation from generated data succeeds
- [ ] Factory methods provide appropriate creature variants
- [ ] Population generation handles species distribution correctly

## Stage 1 Task 6 Lessons Learned

### ✅ Task 6 (Age System) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Complete AgeSystem GameCore Subsystem Architecture**
   - **Success**: AgeSystem follows lazy loading pattern with full SignalBus integration
   - **Success**: 5 age categories (Baby→Juvenile→Adult→Elder→Ancient) with performance modifiers
   - **Success**: Manual aging, category transitions, and batch processing implemented
   - **Pattern**: Consistent with established GameCore subsystem patterns

2. **Advanced Age Progression & Lifecycle Management**
   - **Success**: age_creature_by_weeks(), age_creature_to_category(), age_all_creatures() methods
   - **Success**: Lifecycle event detection (expiration handling, category changes)
   - **Success**: Age statistics and population analysis with get_age_distribution()
   - **Pattern**: Comprehensive age management for creature lifecycle progression

3. **Perfect StatSystem Integration**
   - **Success**: Quest requirements use base stats (NO age modifiers) for fairness
   - **Success**: Competition stats apply age modifiers for realistic performance
   - **Success**: Age transitions update StatSystem when categories change
   - **Pattern**: Dual-stat approach maintains quest balance while adding realism

4. **Enhanced SignalBus with Age Events**
   - **Success**: 3 new age-related signals with comprehensive validation
   - **Success**: creature_category_changed, creature_expired, aging_batch_completed
   - **Success**: Validated emission helpers prevent invalid data propagation
   - **Pattern**: Signal validation provides excellent debugging with clear error messages

5. **Performance Excellence Maintained**
   - **Success**: Batch aging 1000 creatures in <100ms (target met)
   - **Success**: Age analysis and statistics calculations highly optimized
   - **Success**: Pre-allocation and efficient data structures for large populations
   - **Pattern**: Performance-first approach scales linearly with creature count

### New Best Practices from Task 6:
- **Explicit typing mandatory** - Godot 4.5 treats type inference warnings as errors
- **Parameter naming matters** - Avoid shadowing built-in Node properties like "name"
- **Signal validation is critical** - Comprehensive error messages aid debugging significantly
- **Batch operations essential** - Large-scale creature management requires optimized processing
- **Lifecycle events need careful handling** - Age transitions affect multiple systems
- **Performance testing validates optimization** - Always measure against concrete targets

### Updated Verification Checklist from Task 6:
- [ ] AgeSystem loads via GameCore lazy loading pattern
- [ ] All age progression methods work (manual aging, category transitions, batch processing)
- [ ] Age category transitions emit proper signals with validation
- [ ] StatSystem integration maintains dual-stat approach (quest vs competition)
- [ ] SignalBus validation prevents invalid age operations with clear errors
- [ ] Batch aging handles large creature collections efficiently (<100ms for 1000)
- [ ] Lifecycle events (expiration, category changes) detected correctly
- [ ] CreatureGenerator integration allows aging of generated creatures
- [ ] Species lifespan variety respected (different lifespans per species)
- [ ] Performance standards maintained with comprehensive testing

## Stage 1 Task 7 Lessons Learned

### ✅ Task 7 (Save/Load System) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Comprehensive Hybrid Save Architecture**
   - **Success**: ConfigFile for settings/metadata, ResourceSaver for complex creature data
   - **Success**: Slot-based save system with validation, backup/restore functionality
   - **Success**: Auto-save with configurable intervals and manual triggers
   - **Pattern**: Hybrid approach balances performance with data integrity

2. **Advanced Data Persistence & Validation**
   - **Success**: Individual creature save/load with .tres format and cache workarounds
   - **Success**: Batch creature collection operations with performance optimization
   - **Success**: Comprehensive save data validation with repair capabilities
   - **Pattern**: Validation-first approach with graceful error recovery

3. **Perfect System Integration**
   - **Success**: System states persistence for all GameCore subsystems
   - **Success**: SignalBus integration with save/load completion events
   - **Success**: Performance targets met: <200ms for 100 creatures
   - **Pattern**: Seamless integration with existing GameCore architecture

4. **Robust Error Handling & Recovery**
   - **Success**: Slot validation, corruption detection, and automatic backup creation
   - **Success**: Graceful fallbacks for missing data or system references
   - **Success**: Comprehensive logging and debug information for troubleshooting
   - **Pattern**: Defensive programming with multiple layers of validation

5. **Test Quality & Signal Handling Fixes**
   - **Success**: Fixed lambda scope issues with class-level variables for signal testing
   - **Success**: Resolved age category transition detection with proper timing
   - **Success**: Corrected weeks calculation test logic with accurate expectations
   - **Pattern**: Robust test patterns ensure reliable system validation

### New Best Practices from Task 7:
- **Hybrid save approaches** work best - ConfigFile for simple data, ResourceSaver for complex objects
- **Signal scope handling** requires class-level variables for lambda functions in tests
- **Directory creation** must be explicit before saving files to avoid path errors
- **Method visibility** should match usage - make methods public when tests need access
- **Test expectations** must match actual system behavior, not idealized assumptions
- **Performance validation** should include both save and load operations
- **Cache workarounds** are essential with Godot 4.5 Resource system bugs

### SaveSystem Usage Patterns:
```gdscript
# Basic save/load operations
var save_system: SaveSystem = GameCore.get_system("save")
save_system.save_game_state("my_save_slot")
save_system.load_game_state("my_save_slot")

# Creature persistence
var creatures: Array[CreatureData] = get_player_creatures()
save_system.save_creature_collection(creatures, "my_slot")
var loaded: Array[CreatureData] = save_system.load_creature_collection("my_slot")

# Auto-save functionality
save_system.enable_auto_save(5)  # Every 5 minutes
save_system.trigger_auto_save()  # Manual trigger

# Backup and validation
save_system.create_backup("main_save", "backup_slot")
var validation: Dictionary = save_system.validate_save_data("main_save")
if not validation.valid:
    save_system.repair_corrupted_save("main_save")
```

### Updated Verification Checklist from Task 7:
- [ ] SaveSystem loads via GameCore lazy loading pattern
- [ ] Basic save/load operations work with slot management
- [ ] Creature collection persistence handles large datasets efficiently
- [ ] Individual creature save/load works with proper cache handling
- [ ] Auto-save functionality triggers correctly with configurable intervals
- [ ] Data validation detects corruption and enables repair workflows
- [ ] Backup/restore operations preserve data integrity
- [ ] SignalBus integration emits save/load completion events properly
- [ ] Performance targets met: <200ms for 100 creature operations
- [ ] Error handling provides graceful fallbacks and comprehensive logging
- [ ] System integration saves/loads state for all GameCore subsystems
- [ ] Test patterns handle signal scope and timing correctly