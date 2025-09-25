# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A creature collection/breeding game built with Godot 4.5. Currently in planning/documentation phase with no code implementation yet. The game features creature collection, training, breeding, and quest completion through strategic creature management.

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

### Current Stage: Stage 1 - Core Foundation (Not Started)
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

### Stage 1 Tasks - Detailed Implementation Order
Full task list with file references:
1. **Project Setup** (`docs/implementation/stages/stage_1/01_project_setup.md`) - GameCore autoload
2. **SignalBus** (`docs/implementation/stages/stage_1/02_signal_bus.md`) - Centralized signals
3. **CreatureData** (`docs/implementation/stages/stage_1/03_creature_resource.md`) - Pure data resource
4. **SpeciesData** (`docs/implementation/stages/stage_1/04_species_resource.md`) - Template system
5. **Stat System** (`docs/implementation/stages/stage_1/05_stat_system.md`) - Calculation utilities
6. **Tag System** (`docs/implementation/stages/stage_1/06_tag_system.md`) - Tag management
7. **CreatureEntity** (`docs/implementation/stages/stage_1/07_creature_entity.md`) - Behavior node
8. **Controllers** (`docs/implementation/stages/stage_1/08_system_controllers.md`) - Subsystems
9. **Save System** (`docs/implementation/stages/stage_1/09_save_system.md`) - ConfigFile persistence
10. **Collection Manager** (`docs/implementation/stages/stage_1/10_collection_manager.md`) - Pooling
11. **Resource Tracker** (`docs/implementation/stages/stage_1/11_resource_tracking.md`) - Economy
12. **Stage 1 Testing** (`docs/implementation/stages/stage_1/12_stage_1_testing.md`) - Integration tests

⚠️ **CRITICAL**: See `docs/implementation/IMPROVED_ARCHITECTURE.md` for architecture details

## Commands

### Development Commands (After Godot Project Creation)
```bash
# Open Godot project
godot project.godot

# Run tests (after test framework setup)
godot --script res://tests/run_tests.gd

# Export build (after export templates configured)
godot --export "Windows Desktop" builds/game.exe
```

### Current Status
- **No Godot project exists yet** - Start with Stage 1 Task 01 (project setup)
- **No code implemented** - Pure documentation phase
- **No build/test commands** - Will be established during implementation

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

### Task 1 (Project Setup) - COMPLETED
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