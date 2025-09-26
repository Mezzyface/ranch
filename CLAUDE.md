# CLAUDE.md

Primary machine-actionable guidance for AI coding agents (Claude, GPT, etc.). Keep this file short, stable, enumerated. Narrative/historical details have been archived.

## 0. EXECUTION PROTOCOL (ALWAYS IN THIS ORDER)
1. Preflight: `godot --headless --scene tests/preflight_check.tscn` (abort on fail)
2. Identify minimal affected files (no broad search & replace unless explicit)
3. Verify invariants (Section 1) before editing
4. Apply minimal cohesive patch
5. Re-run preflight + directly related individual test (if exists)
6. Summarize: each user requirement → Done / Skipped (reason) + invariants status
7. Never proceed to new feature if any invariant broken

## 1. NON-NEGOTIABLE INVARIANTS
- Data vs behavior: `CreatureData` Resource (no signals) / `CreatureEntity` Node (behavior + signaling via SignalBus ONLY)
- Property names: `id`, `species_id`, `age_weeks`, `lifespan_weeks`, `creature_name` (NO legacy variants)
- System access: ONLY `GameCore.get_system("<name>")`
- Age category & modifier logic lives on `CreatureData` (do not duplicate)
- Arrays are explicitly typed (e.g. `Array[String]`, `Array[CreatureData]`)
- Signals: use existing SignalBus emission helpers; do not add wrappers unless introducing a new domain event (then document in Section 6)
- Species truth: SpeciesSystem resources (hardcoded generator map = deprecated read‑only)
- Performance: New batch ops must respect baselines (Section 7) or provide timing + justification
- Save orchestration: SaveSystem coordinates; each system owns its own serialization (no duplication)

## 2. ALLOWED / DISALLOWED
ALLOWED: focused feature implementation, adding a precise enum value, introducing small interface (`ISaveable`, `ITickable`) with registration, adding targeted test scene.

DISALLOWED (without explicit instruction): wide renames, new bespoke signal wrappers, extending deprecated species map, duplicating age/stat helpers, untyped public arrays, speculative refactors.

## 3. TASK EXECUTION TEMPLATE (INTERNAL WORKFLOW)
1. Intent → concrete edits list
2. Read target files (only) to confirm assumptions
3. Patch
4. Preflight + individual test(s)
5. Summarize results & invariant checklist

## 4. FILE MAP QUICK REFERENCE
Core Loader: `scripts/core/game_core.gd`
Signals: `scripts/core/signal_bus.gd`
Enums: `scripts/core/global_enums.gd`
Systems: `scripts/systems/*.gd`
Data: `scripts/data/*.gd`
Generation: `scripts/generation/`
Tests (unit/individual): `tests/individual/`
Integration Harness: `tests/test_all.tscn`, `test_setup.tscn`
Preflight: `tests/preflight_check.tscn`

## 5. PATCH POLICY
- Leave unrelated formatting untouched
- Remove dead code only if zero references AND clearly deprecated
- Use `# TODO(stage2): ...` for deferred refactors
- Add `# AI_NOTE:` only when rationale is non-obvious to future reviewers

## 6. CURRENT SYSTEM KEYS
`collection`, `save`, `tag`, `age`, `stat`, `resource`, `species` (extend list when adding new system)

## 7. PERFORMANCE BASELINES
| Operation | Target |
|-----------|--------|
| 1000 creature generation | <100ms |
| Batch aging 1000 creatures | <100ms |
| Save/load 100 creatures | <200ms |
| 100 species lookups | <50ms |
If exceeded, add timing + mitigation note in summary.

## 8. SUBMISSION CHECKLIST
[ ] Preflight passes
[ ] No forbidden property names introduced
[ ] No new signal wrapper unless documented
[ ] All arrays typed explicitly
[ ] Only `GameCore.get_system()` used for system access
[ ] No duplicated age/stat logic
[ ] Species edits via resources only
[ ] Tests updated/added as needed
[ ] Performance within baseline or justified

## 9. COMMON ERROR GUARDS
- Untyped arrays → inference warnings (treated as errors)
- Legacy property names (`creature_id`, `species`) → breaks tests & filters
- Calling age/category on system instead of data → method not found
- Time API misuse (`.nanosecond`) → invalid; use `Time.get_ticks_msec()`

## 10. ADDING A NEW SYSTEM (MINIMAL STEPS)
1. `scripts/systems/<name>_system.gd` (extends Node)
2. Add case in `game_core.gd` loader
3. Add small test in `tests/individual/`
4. Append key to Section 6 list
5. If persistent: implement save hooks or register future `ISaveable`

## 11. STAGE 1 CONSOLIDATED LESSONS (REFERENCE)

## Repository Overview
### Testing Commands
```bash
godot --headless --scene tests/preflight_check.tscn
godot --headless --scene tests/test_all.tscn
# (Run specific individual test scenes if you modified a single system)
```
### M. Minimal Verification Checklist (Superseded by Section 8 Machine Protocol)

---
Legacy verbose per‑task narratives (Tag System through Species Resources) moved to `docs/development/ARCHIVE_STAGE1_TASK_DETAILS.md`.
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
- **Collection Management**: Active roster (6 limit) and stable collection (unlimited) with advanced search
- **Species Templates**: Resource-based species system with category/rarity organization

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

# CRITICAL: Use GlobalEnums for all shared data types (NOT strings or magic numbers!)
# ❌ WRONG: creature.get_age_category() == 2  # Magic number
# ❌ WRONG: creature.category = "starter"      # String constant
# ✅ CORRECT: creature.get_age_category() == GlobalEnums.AgeCategory.ADULT
# ✅ CORRECT: species.category = GlobalEnums.SpeciesCategory.STARTER

# Always use enum-based methods when available:
var stat_value = creature.get_stat_by_type(GlobalEnums.StatType.STRENGTH)  # Preferred
var age_cat = creature.get_age_category()  # Returns GlobalEnums.AgeCategory
species.rarity = GlobalEnums.SpeciesRarity.RARE  # Direct enum usage

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

### Current Stage: Stage 1 - Core Foundation (Near Complete - 10/11 Tasks Done)
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
8. **✅ Player Collection** (`08_player_collection.md`) - Active/stable roster management COMPLETE
9. **✅ Resource Tracking** (`09_resource_tracking.md`) - Gold/item economy COMPLETE
10. **✅ Species Resources** (`10_species_resources.md`) - Species templates COMPLETE
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
## Stage 1 Consolidated Lessons (Tasks 1–10)

This section replaces verbose per‑task blocks with a unified, low‑maintenance summary of durable principles. Historical granular logs can be moved to an archive if needed.

### A. Architecture & Data Separation
- Data (Resource) vs Behavior (Node) line is non‑negotiable: `CreatureData` stays signal‑free; `CreatureEntity` mediates behavior.
- GameCore = lazy loader + registry; avoid direct dictionary poking (`GameCore._systems[...]`). Always use `GameCore.get_system(name)`.
- Species hardcoded map is now DEPRECATED (read‑only until full removal); SpeciesSystem resources are the source of truth.

### B. Signals & Communication
- Centralize through SignalBus; no new bespoke `emit_<event>()` wrappers—prepare for generic emitter migration.
- Validate inputs before emission; red validation errors are protective, not failures.
- Reduce signal surface by batching (e.g., roster changes emit full snapshot once).

### C. Validation & Safety
- Tag/Stat/Age logic lives in their owning systems or data classes—do not duplicate helper math elsewhere.
- Fallback logic (e.g., local tag checks in `CreatureEntity`) is slated for removal; treat as legacy.
- Explicit array typing `Array[String]` prevents subtle Godot 4.5 inference errors.

### D. Performance Practices
- Batch operations (aging, filtering, generation) must complete 1k scale < 100ms on baseline hardware.
- Preallocate arrays for mass generation and aging.
- Avoid per‑loop system lookups; cache references locally inside hot loops.

### E. Persistence Principles
- Hybrid model stays: ConfigFile for metadata, ResourceSaver for complex resource objects.
- Future direction: introduce `ISaveable` (draft) so SaveSystem enumerates system states instead of hardcoding.
- Creature collection owns its own serialization; SaveSystem should orchestrate, not duplicate logic.

### F. Collection & Domain Rules
- Active roster cap enforced at system boundary; internal data structures never exceed 6 active.
- Species + Tag assignment validated at creation time; invalid combinations never enter collection state.
- Age modifiers affect performance/competitions, not quest requirement thresholds.

### G. Testing & Tooling
- Individual system test scenes + one integration harness—fast isolated failures preferred over monolithic runs.
- Deterministic generation (seeded path) planned; current statistical tolerance accepted for distribution tests.
- Preflight / validator scripts catch 90% of common AI or contributor mistakes (property name, system loading, array typing).

### H. Logging & Debug (Transitional)
- Verbose console logging is temporary; Stage 2 introduces channelized `DebugConfig` (levels + filters).
- Quiet modes required for bulk operations (collection, generation) to keep CI output manageable.

### I. Anti‑Patterns (Do NOT Reintroduce)
- Direct property name drift: `creature_id`, `species` (should be `id`, `species_id`).
- Manual age category math outside `CreatureData` / `AgeSystem`.
- Recreating species definitions outside SpeciesSystem resources.
- Using system internals: `GameCore._systems[...]` or storing raw references for later without null checks.
- Adding new per‑signal validation wrappers instead of consolidating.

### J. Metrics Snapshot (Pre‑Refactor Baseline)
| Area | Current | Target (Stage 2+) |
|------|---------|-------------------|
| SignalBus LOC | ~600 | <350 (extraction + generic emitter) |
| SaveSystem LOC | ~870 | <400 (modular split) |
| Duplicate age logic copies | 3 | 1 |
| Hardcoded species table | Present | Removed |
| Fallback tag validation points | 2 | 0 |

### K. Task → Durable Principle Matrix
| Task | Key Addition | Lasting Principle |
|------|--------------|-------------------|
| 1 Project Setup | GameCore + SignalBus | Centralized lazy loading & event routing |
| 2 Creature Class | Data/behavior split | Resources stay pure data |
| 3 Stat System | Modifier pipeline | Separate base vs contextual (age) stats |
| 4 Tag System | Declarative metadata | Validate before mutation |
| 5 Generation | Algorithm variants | Deterministic expansion path (seed later) |
| 6 Age System | Lifecycle events | Orchestrate; no stat side effects directly |
| 7 Save System | Hybrid persistence | Systems own their state; orchestrator coordinates |
| 8 Collection | Dual-tier storage | Cap & invariant enforcement at boundary |
| 9 Resource Tracking | Economy baseline | Emit domain deltas, not polled mutations |
| 10 Species Resources | Resource-backed species | Data lives in assets, not code |

### L. Stage 2 Forward Hooks
- Introduce `TimeSystem` (weeks) → drives AgeSystem & modifier decay.
- Replace per‑event emission wrappers with schema‑driven generic emitter.
- Formalize `ISaveable` + `ITickable` contracts and register via GameCore.
- Begin deprecating hardcoded species map (remove after migration test passes).

### M. Minimal Verification Checklist (Supersedes Prior Per‑Task Lists)
- [ ] No forbidden property names (`creature_id`, `species`).
- [ ] All tag/stat/age computations delegated to owning system/data.
- [ ] No new emit wrapper functions added.
- [ ] Batch ops meet performance thresholds (<100ms / 1k items baseline).
- [ ] Save orchestration does not directly serialize system internals ad hoc.
- [ ] Species creation path uses SpeciesSystem (not hardcoded dictionary extension).
- [ ] Fallback tag or species logic not invoked in normal runtime.

---
*Legacy detailed task narratives were removed to reduce churn. Retrieve from version control history if deep forensic context is required.*
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

## Stage 1 Task 8 Lessons Learned

### ✅ Task 8 (Player Collection) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Complete Player Collection System Architecture**
   - **Success**: Active roster (6 creature limit) with swap mechanics
   - **Success**: Stable collection (unlimited) with promotion/demotion
   - **Success**: Advanced search with multiple criteria types
   - **Success**: Collection statistics and performance metrics
   - **Pattern**: Dual collection system balances gameplay and flexibility

2. **Property Name Consistency Critical**
   - **Issue**: Mixed use of `creature_id` vs `id`, `species` vs `species_id`
   - **Solution**: Standardized on `id` and `species_id` throughout codebase
   - **Impact**: Fixed over 20 property reference errors across systems
   - **Pattern**: Always use consistent property names across all systems

3. **Method Location Matters**
   - **Issue**: `age_system.get_creature_age_category()` doesn't exist
   - **Solution**: Use `creature_data.get_age_category()` - methods on data classes
   - **Impact**: Simplified API by keeping methods close to data
   - **Pattern**: Data classes should contain their own utility methods

4. **Array Type Safety in Godot 4.5**
   - **Issue**: `["Flying"]` causes type mismatch with `Array[String]` parameters
   - **Solution**: Explicit typing: `var tags: Array[String] = ["Flying"]`
   - **Impact**: Eliminated all array type errors in system integration
   - **Pattern**: Always use explicit array typing for method parameters

5. **Time Measurement API Changes**
   - **Issue**: `Time.get_time_dict_from_system().nanosecond` doesn't exist
   - **Solution**: Use `Time.get_ticks_msec()` for all timing measurements
   - **Impact**: Fixed all performance measurement code
   - **Pattern**: Millisecond precision sufficient for game timing

6. **Output Overflow Management**
   - **Issue**: Verbose signal logging causes terminal overflow in tests
   - **Solution**: Implemented comprehensive quiet mode system
   - **Success**: Class-level control variables for runtime management
   - **Pattern**: Always provide quiet/debug modes for bulk operations

### New Best Practices from Task 8:
- **Documentation prevents errors** - API_REFERENCE.md eliminated 90% of integration issues
- **Individual test infrastructure** - Isolated tests improve debugging efficiency
- **Signal validation essential** - Comprehensive validation prevents invalid state propagation
- **Property naming conventions** - Establish and enforce early to prevent confusion
- **Performance testing mandatory** - Always measure against concrete targets
- **Quiet modes necessary** - Bulk operations need output control

### Critical Integration Patterns:
```gdscript
# Pattern 1: Explicit Array Typing
var required_tags: Array[String] = ["Flying", "Fast"]
var available = collection.get_available_for_quest(required_tags)

# Pattern 2: Correct Property Access
if creature_data.id == target_id:  # NOT creature_id
    process_creature(creature_data)

# Pattern 3: Method Location
var category = creature_data.get_age_category()  # NOT age_system.get_creature_age_category()

# Pattern 4: Quiet Mode for Bulk Operations
collection_system.set_quiet_mode(true)
# ... bulk operations ...
collection_system.set_quiet_mode(false)
```

### Updated Verification Checklist from Task 8:
- [ ] PlayerCollection loads via GameCore lazy loading pattern
- [ ] Active roster enforces 6-creature limit with proper swapping
- [ ] Stable collection handles unlimited creatures efficiently
- [ ] Search functionality works with all criteria types
- [ ] Quest availability checking integrates with TagSystem
- [ ] Collection statistics calculate correctly
- [ ] All 5 collection signals emit with proper validation
- [ ] Property names consistent: `id`, `species_id` everywhere
- [ ] Array parameters use explicit `Array[String]` typing
- [ ] Performance targets met: <100ms for 100 creature operations
- [ ] Quiet mode prevents output overflow in tests
- [ ] Individual test infrastructure enables focused debugging

## Stage 1 Task 10 Lessons Learned

### ✅ Task 10 (Species Resources System) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Complete Resource-Based Architecture**
   - **Success**: SpeciesResource class with full template properties and validation
   - **Success**: SpeciesSystem GameCore subsystem with lazy loading
   - **Success**: Directory structure ready for .tres files with fallback to defaults
   - **Pattern**: Resource-based data management enables future modding support

2. **Seamless CreatureGenerator Integration**
   - **Success**: Backward compatibility maintained with fallback patterns
   - **Success**: SpeciesSystem integration with existing get_species_info() API
   - **Success**: No breaking changes to existing creature generation workflows
   - **Pattern**: Gradual migration strategy allows incremental system upgrades

3. **Array Type Safety Resolution**
   - **Issue**: `Array[String]` assignments failed with "Invalid assignment" errors
   - **Solution**: Explicit array construction with typed loops for guaranteed_tags, optional_tags, name_pool
   - **Impact**: Fixed all compilation errors and enabled proper type safety
   - **Pattern**: Godot 4.5 requires explicit Array[Type] handling for Resource properties

4. **SignalBus Integration Excellence**
   - **Success**: 3 new species signals with proper validation patterns
   - **Success**: Consistent validation using existing pattern (if variable.is_empty())
   - **Success**: Debug logging integration maintains development visibility
   - **Pattern**: Follow established SignalBus patterns for consistency

5. **Test Infrastructure Enhancement**
   - **Success**: Individual test_species.tscn with comprehensive coverage
   - **Success**: Integration test function in test_setup.gd with performance metrics
   - **Success**: Added to test_all.gd for complete test suite coverage
   - **Pattern**: Each system needs individual and integration test coverage

6. **Performance Excellence Achieved**
   - **Success**: <50ms for 100 species lookups (target met)
   - **Success**: Efficient category/rarity organization with proper indexing
   - **Success**: Lazy loading minimizes startup time
   - **Pattern**: Performance-first design with caching and efficient data structures

### New Best Practices from Task 10:
- **Resource property assignments need explicit typing** - Use typed loops for Array[String] properties
- **Fallback patterns enable gradual migration** - Maintain backward compatibility during system upgrades
- **Directory structure planning is critical** - Create paths early even if files don't exist yet
- **SignalBus validation consistency** - Follow established patterns for error handling
- **Migration strategies work incrementally** - Implement phases to avoid breaking changes
- **Performance testing validates architecture** - Always measure against concrete targets

### SpeciesSystem Usage Patterns:
```gdscript
# Basic species management
var species_system = GameCore.get_system("species")
var all_species: Array[String] = species_system.get_all_species()
var starters: Array[String] = species_system.get_species_by_category("starter")

# CreatureGenerator integration (automatic)
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Detailed species information
var species_resource: SpeciesResource = species_system.get_species("wind_dancer")
var species_info: Dictionary = species_system.get_species_info("wind_dancer")

# Random selection with filtering
var random_starter: String = species_system.get_random_species("starter", "")
var random_rare: String = species_system.get_random_species("", "rare")
```

### Updated Verification Checklist from Task 10:
- [ ] SpeciesSystem loads via GameCore lazy loading pattern
- [ ] Species data fallback creates 4 default species when no .tres files exist
- [ ] All species validation passes with proper error reporting
- [ ] Category and rarity organization works efficiently
- [ ] CreatureGenerator integration maintains backward compatibility
- [ ] Individual SpeciesSystem test passes all 6 test scenarios
- [ ] Integration test includes SpeciesSystem validation
- [ ] Performance targets met: <50ms for 100 species lookups
- [ ] Array[String] property assignments work correctly
- [ ] SignalBus species signals emit with proper validation
- [ ] Test infrastructure covers both individual and integration scenarios