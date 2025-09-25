# Task 01: Project Setup with GameCore Architecture

## Overview
Initialize the Godot 4.5 project with improved architecture featuring a single GameCore autoload, SignalBus for communication, and proper MVC separation. This establishes the foundation for all future development.

## Dependencies
- Godot 4.5 installed
- Git for version control
- Review IMPROVED_ARCHITECTURE.md for architecture patterns

## Context
From the game design documentation, we're building a creature collection/breeding game with the following key systems:
- Creature management with stats and tags
- Quest system with validation
- Shop system for acquiring creatures
- Time-based progression system
- Competition and breeding mechanics

This task establishes the foundational project structure that all other systems will build upon.

## Requirements

### Directory Structure (Improved)
```
res://
├── scenes/
│   ├── main/
│   ├── ui/
│   └── entities/
├── scripts/
│   ├── core/          # GameCore and SignalBus
│   ├── systems/       # Subsystems (lazy-loaded)
│   ├── data/          # Resources (pure data)
│   ├── entities/      # Nodes (behavior)
│   ├── controllers/   # Game logic
│   └── utils/         # Helpers
├── resources/
│   ├── creatures/     # CreatureData resources
│   ├── species/       # SpeciesData resources
│   ├── quests/        # QuestData resources
│   └── items/         # ItemData resources
├── assets/
│   ├── sprites/
│   ├── fonts/
│   └── audio/
└── tests/
    ├── unit/
    └── integration/
```

### Project Settings
1. **Display**
   - Window Width: 1280
   - Window Height: 720
   - Stretch Mode: viewport
   - Stretch Aspect: keep

2. **Rendering**
   - Renderer: Forward+ (for 2D optimization)
   - Default Clear Color: Dark gray (#2a2a2a)

3. **Input Map** (Initial bindings)
   - `ui_advance_time` - Space key (advance week)
   - `ui_open_shop` - S key
   - `ui_open_creatures` - C key
   - `ui_open_quests` - Q key
   - `ui_save_game` - Ctrl+S
   - `ui_load_game` - Ctrl+L

### Core Architecture (ONLY ONE Autoload!)
Create the single GameCore autoload and SignalBus:

1. **GameCore** (`scripts/core/game_core.gd`)
   - ONLY autoload in the project
   - Manages all subsystems via lazy loading
   - Provides centralized access point

2. **SignalBus** (`scripts/core/signal_bus.gd`)
   - Created by GameCore (not autoloaded)
   - Routes all signals between systems
   - Prevents direct coupling

3. **Subsystems** (NOT autoloaded, managed by GameCore)
   - CreatureSystem
   - SaveSystem (ConfigFile-based)
   - QuestSystem
   - All lazy-loaded on demand

### Version Control Setup
1. Initialize git repository
2. Create `.gitignore` with Godot-specific exclusions:
```
.godot/
.import/
export.cfg
export_presets.cfg
*.tmp
.DS_Store
```

3. Initial commit structure with meaningful commit message

## Implementation Steps

1. **Create New Project**
   - Open Godot 4.5
   - Create new project named "CreatureCollection"
   - Set up project settings as specified above

2. **Create Directory Structure**
   - Create all folders as outlined
   - Add .gitkeep files to empty directories

3. **Create Core Singleton Scripts**
   - Implement basic singleton structure
   - Register in Project Settings → Autoload

4. **Set Up Main Scene**
   - Create main.tscn in scenes/main/
   - Add basic UI container structure
   - Set as main scene in project settings

5. **Configure Project Settings**
   - Set display resolution
   - Configure input mappings
   - Set rendering options

### Main Scene Structure
Create `main.tscn` with basic node hierarchy:
```
Main (Node2D)
├── Systems (Node)
│   ├── TimeManager (Node)
│   ├── QuestManager (Node)
│   └── EconomyManager (Node)
├── UI (CanvasLayer)
│   └── MainUI (Control)
└── World (Node2D)
```

## Implementation Steps

1. **Create New Godot Project**
   - Name: "CreatureCollection"
   - Path: As specified by user
   - Renderer: Forward+

2. **Set Up Directory Structure**
   - Create all folders as specified above
   - Add `.gdignore` files in appropriate directories

3. **Configure Project Settings**
   - Set display settings
   - Configure rendering options
   - Set up input map

4. **Create Core Scripts**
   - Create singleton scripts with basic structure
   - Add to autoload in project settings
   - Include basic logging for system initialization

5. **Build Main Scene**
   - Create scene hierarchy
   - Save as `scenes/main/main.tscn`
   - Set as main scene in project settings

6. **Initialize Version Control**
   - Git init
   - Add .gitignore
   - Make initial commit

## Test Criteria

### Automated Tests
- [ ] Project opens successfully in Godot 4.5
- [ ] All singleton scripts load without errors
- [ ] Main scene loads and runs

### Manual Verification
- [ ] Directory structure matches specification
- [ ] Project settings are correctly configured
- [ ] Input map contains all required actions
- [ ] Git repository is initialized with proper .gitignore
- [ ] Main scene hierarchy is correct
- [ ] Window displays at correct resolution

### System Integration Tests
- [ ] GameManager singleton is accessible from any script
- [ ] DataManager singleton is accessible from any script
- [ ] SaveManager singleton is accessible from any script
- [ ] All systems can log to console
- [ ] Scene can receive input events

## Success Metrics
- Project loads in < 2 seconds
- No errors or warnings in console on startup
- All folders and files are properly organized
- Version control is tracking appropriate files
- Base architecture supports future system additions

## Code Examples (Improved Architecture)

### GameCore - The ONLY Autoload
```gdscript
# scripts/core/game_core.gd
class_name GameCore
extends Node

static var instance: GameCore
var signal_bus: SignalBus
var _systems: Dictionary = {}

func _enter_tree() -> void:
    instance = self

func _ready() -> void:
    # Create SignalBus first
    signal_bus = SignalBus.new()
    signal_bus.name = "SignalBus"
    add_child(signal_bus)

    print("GameCore initialized")
    # Systems will be lazy-loaded as needed

static func get_signal_bus() -> SignalBus:
    return instance.signal_bus

static func get_system(system_name: String) -> Node:
    if not instance._systems.has(system_name):
        instance._load_system(system_name)
    return instance._systems.get(system_name)

func _load_system(system_name: String) -> void:
    var system: Node

    match system_name:
        "creature":
            system = preload("res://scripts/systems/creature_system.gd").new()
        "save":
            system = preload("res://scripts/systems/save_system.gd").new()
        "quest":
            system = preload("res://scripts/systems/quest_system.gd").new()
        _:
            push_error("Unknown system: " + system_name)
            return

    system.name = system_name.capitalize() + "System"
    add_child(system)
    _systems[system_name] = system
    print("Loaded system: " + system_name)
```

### SignalBus - Centralized Communication
```gdscript
# scripts/core/signal_bus.gd
class_name SignalBus
extends Node

# Creature signals
signal creature_created(data: CreatureData)
signal creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int)
signal creature_aged(data: CreatureData, new_age: int)
signal creature_activated(data: CreatureData)
signal creature_deactivated(data: CreatureData)

# Quest signals
signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_requirements_met(quest: QuestData, creatures: Array[CreatureData])
signal quest_failed(quest: QuestData)

# Economy signals
signal gold_changed(old_amount: int, new_amount: int)
signal item_purchased(item_id: String, quantity: int)
signal item_consumed(item_id: String, quantity: int)

# Time signals
signal week_advanced(new_week: int)
signal day_passed(current_week: int, current_day: int)

# System signals
signal save_requested()
signal load_requested()
signal save_completed(success: bool)
signal load_completed(success: bool)

func _ready() -> void:
    print("SignalBus initialized")
```

### SaveSystem - Using ConfigFile (NOT store_var!)
```gdscript
# scripts/systems/save_system.gd
class_name SaveSystem
extends Node

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://save_slot_%d.cfg"

func _ready() -> void:
    var signal_bus := GameCore.get_signal_bus()
    signal_bus.save_requested.connect(_on_save_requested)
    signal_bus.load_requested.connect(_on_load_requested)
    print("SaveSystem initialized")

func save_game(slot: int = 0) -> bool:
    var config := ConfigFile.new()

    # Metadata
    config.set_value("meta", "version", SAVE_VERSION)
    config.set_value("meta", "timestamp", Time.get_unix_time_from_system())
    config.set_value("meta", "play_time", 0) # Will track later

    # Game state
    var creature_system := GameCore.get_system("creature") as CreatureSystem
    if creature_system:
        for creature in creature_system.get_all_creatures():
            config.set_value("creatures", creature.id, creature.to_dict())

    # Save to file
    var error := config.save(SAVE_PATH % slot)
    var success := error == OK

    GameCore.get_signal_bus().save_completed.emit(success)
    return success

func load_game(slot: int = 0) -> bool:
    var config := ConfigFile.new()
    var path := SAVE_PATH % slot

    if not FileAccess.file_exists(path):
        push_warning("Save file doesn't exist: " + path)
        GameCore.get_signal_bus().load_completed.emit(false)
        return false

    var error := config.load(path)
    if error != OK:
        push_error("Failed to load save file: " + path)
        GameCore.get_signal_bus().load_completed.emit(false)
        return false

    # Check version
    var version := config.get_value("meta", "version", 0)
    if version != SAVE_VERSION:
        print("Migrating save from version %d to %d" % [version, SAVE_VERSION])
        _migrate_save(config, version)

    # Load creatures
    var creature_system := GameCore.get_system("creature") as CreatureSystem
    if creature_system:
        creature_system.clear_all_creatures()

        if config.has_section("creatures"):
            for creature_id in config.get_section_keys("creatures"):
                var creature_dict := config.get_value("creatures", creature_id, {})
                creature_system.add_creature_from_dict(creature_dict)

    GameCore.get_signal_bus().load_completed.emit(true)
    return true

func _migrate_save(config: ConfigFile, from_version: int) -> void:
    # Handle save migration between versions
    pass
```

## Notes
- This task focuses purely on setup - no gameplay implementation yet
- Ensure Godot 4.5 specific features are utilized where appropriate
- Keep scripts minimal but with clear structure for expansion
- Document any deviations from the plan

## Estimated Time
4-6 hours for complete implementation and testing