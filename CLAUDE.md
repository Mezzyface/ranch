# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A creature collection/breeding game built with Godot 4.5. Currently in planning/documentation phase with no code implementation yet. The game features creature collection, training, breeding, and quest completion through strategic creature management.

## Core Architecture

### Game Systems
- **6 Core Stats**: STR, CON, DEX, INT, WIS, DIS (scale 1-1000)
- **Tag System**: Environmental, behavioral, physical, and utility tags for creature traits
- **Age System**: 5 age categories (Baby, Juvenile, Adult, Elder, Ancient) with performance modifiers
- **Time Management**: Weekly cycles for training, competitions, and aging
- **Resource Economy**: Gold currency, food requirements, creature acquisition through shops

### Data Architecture (Godot 4.5)
- **Resources**: All creatures, species, and items use Godot Resource system for serialization
- **Singleton Managers**: GameManager, DataManager, SaveManager, StatManager, TagManager, SpeciesManager, CollectionManager, ResourceManager
- **Component-based Design**: Modular systems that communicate through signals
- **Save System**: JSON-based persistence with versioning support

## Godot 4.5 Implementation Guidelines

### Key Godot 4.x Features to Use
- **Strong Typing**: Use typed GDScript (`var creature: Creature`, `func get_stats() -> Dictionary`)
- **@export Variables**: For inspector-configurable creature attributes and species templates
- **Custom Resources**: Extend Resource class for Creature, Species, Quest data models
- **Signal Bus Pattern**: Central signal manager for decoupled communication
- **Node Groups**: For managing creature collections and batch operations

### GDScript Best Practices
```gdscript
# Use class_name for custom resources
class_name Creature extends Resource

# Use typed exports
@export var species_id: String = ""
@export var stats: Dictionary = {}
@export var tags: Array[String] = []

# Use signals for state changes
signal stats_changed(old_stats: Dictionary, new_stats: Dictionary)
signal creature_aged(new_age_category: Enums.AgeCategory)
```

### Performance Considerations
- **Object Pooling**: Reuse creature instances for UI elements
- **Resource Preloading**: Cache frequently used species templates
- **Lazy Loading**: Load creature sprites only when visible
- **Dictionary Caching**: Store calculated stats to avoid recomputation

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

### Stage 1 Task Order
Located in `docs/implementation/stages/stage_1/`:
1. `01_project_setup.md` - Godot project initialization
2. `11_global_enums.md` - Global enumeration setup
3. `02_creature_class.md` - Core creature resource
4. `03_stat_system.md` - Stat calculations and modifiers
5. `04_tag_system.md` - Tag validation and rules
6. `05_creature_generation.md` - Procedural generation
7. `06_age_system.md` - Age categories and progression
8. `10_species_resources.md` - Species templates
9. `07_save_load_system.md` - Game persistence
10. `08_player_collection.md` - Active/stable management
11. `09_resource_tracking.md` - Gold/food economy

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