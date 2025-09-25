# Task 01: Project Setup and Architecture

## Overview
Initialize the Godot 4.5 project with proper structure, version control, and foundational architecture for the creature collection game.

## Dependencies
- Godot 4.5 installed
- Git for version control
- No other task dependencies (this is the first task)

## Context
From the game design documentation, we're building a creature collection/breeding game with the following key systems:
- Creature management with stats and tags
- Quest system with validation
- Shop system for acquiring creatures
- Time-based progression system
- Competition and breeding mechanics

This task establishes the foundational project structure that all other systems will build upon.

## Requirements

### Directory Structure
```
res://
├── scenes/
│   ├── main/
│   ├── creatures/
│   ├── ui/
│   └── systems/
├── scripts/
│   ├── creatures/
│   ├── systems/
│   ├── data/
│   ├── ui/
│   └── utils/
├── resources/
│   ├── creatures/
│   ├── items/
│   └── data/
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

### Core Singletons (Autoload)
Create and register these singleton scripts:

1. **GameManager** (`scripts/systems/game_manager.gd`)
   - Manages overall game state
   - Coordinates between systems
   - Handles scene transitions

2. **DataManager** (`scripts/systems/data_manager.gd`)
   - Loads creature definitions
   - Manages item databases
   - Handles configuration data

3. **SaveManager** (`scripts/systems/save_manager.gd`)
   - Save/load game functionality
   - Profile management
   - Settings persistence

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

## Code Examples

### GameManager Singleton Base
```gdscript
class_name GameManager
extends Node

signal game_started()
signal game_loaded()
signal game_saved()
signal week_advanced(new_week: int)

var current_week: int = 1
var game_state: Dictionary = {}

func _ready() -> void:
    print("GameManager initialized")
    set_process_mode(Node.PROCESS_MODE_ALWAYS)

func start_new_game() -> void:
    current_week = 1
    game_state.clear()
    game_started.emit()

func advance_week() -> void:
    current_week += 1
    week_advanced.emit(current_week)
    # Will trigger other system updates in future tasks
```

### DataManager Singleton Base
```gdscript
class_name DataManager
extends Node

var creature_definitions: Dictionary = {}
var item_definitions: Dictionary = {}
var quest_definitions: Dictionary = {}
var species_resources: Dictionary = {}

func _ready() -> void:
    print("DataManager initialized")
    set_process_mode(Node.PROCESS_MODE_ALWAYS)
    # Will load data files in future tasks

func get_creature_definition(id: String) -> Dictionary:
    return creature_definitions.get(id, {})

func get_species_resource(species_id: String) -> Resource:
    return species_resources.get(species_id, null)
```

### SaveManager Singleton Base
```gdscript
class_name SaveManager
extends Node

const SAVE_PATH: String = "user://savegame.dat"
const SAVE_VERSION: int = 1

signal game_saved(success: bool)
signal game_loaded(success: bool)

func _ready() -> void:
    print("SaveManager initialized")
    set_process_mode(Node.PROCESS_MODE_ALWAYS)

func save_game(data: Dictionary) -> bool:
    data["version"] = SAVE_VERSION
    data["timestamp"] = Time.get_unix_time_from_system()

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(data)
        file.close()
        game_saved.emit(true)
        return true
    game_saved.emit(false)
    return false

func load_game() -> Dictionary:
    if FileAccess.file_exists(SAVE_PATH):
        var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file:
            var data: Dictionary = file.get_var()
            file.close()

            # Version check for future compatibility
            if data.get("version", 0) == SAVE_VERSION:
                game_loaded.emit(true)
                return data
            else:
                push_warning("Save file version mismatch")
                game_loaded.emit(false)
    game_loaded.emit(false)
    return {}
```

## Notes
- This task focuses purely on setup - no gameplay implementation yet
- Ensure Godot 4.5 specific features are utilized where appropriate
- Keep scripts minimal but with clear structure for expansion
- Document any deviations from the plan

## Estimated Time
4-6 hours for complete implementation and testing