# Task 07: Save/Load System Implementation

## Overview
Implement a robust save/load system that persists game state, creature collections, player progress, and all game data between sessions.

## Dependencies
- Task 01: Project Setup (complete)
- Task 02: Creature Class (complete)
- All data structures that need persistence

## Context
The save system must handle:
- Complete creature collections with all properties
- Player resources (gold, items, food)
- Game progression (completed quests, unlocks)
- Current week and time state
- Settings and preferences

## Requirements

### Save Data Structure
1. **Player Data**
   - Player name/profile
   - Total gold
   - Current week
   - Playtime statistics

2. **Creature Collection**
   - All creatures with full properties
   - Active/stable states
   - Current stamina/status

3. **Progression Data**
   - Completed quests
   - Unlocked vendors
   - Unlocked features
   - Achievements

4. **Inventory**
   - Food items and quantities
   - Special items
   - Unused eggs

5. **Settings**
   - Game preferences
   - UI settings
   - Audio levels

### Technical Requirements
1. **File Format**
   - JSON for readability and debugging
   - Compression optional for size
   - Version tracking for compatibility

2. **Save Locations**
   - User data directory
   - Multiple save slots
   - Autosave support
   - Cloud save preparation

3. **Data Integrity**
   - Validation on load
   - Corruption detection
   - Backup system
   - Recovery options

## Implementation Steps

1. **Create Save Data Classes**
   - SaveGame resource
   - Data serialization methods
   - Version management

2. **Implement Save System**
   - Save to file
   - Multiple slots
   - Autosave functionality
   - Quick save/load

3. **Implement Load System**
   - Load from file
   - Data validation
   - Version migration
   - Error handling

4. **Add UI Integration**
   - Save/load menu
   - Slot selection
   - Confirmation dialogs
   - Progress indicators

## Test Criteria

### Unit Tests
- [ ] Save game creates file successfully
- [ ] Load game reads file correctly
- [ ] All creature data persists
- [ ] Player resources save/load correctly
- [ ] Progression data maintains integrity
- [ ] Settings preserve values

### Data Integrity Tests
- [ ] Save and load 100 creatures without data loss
- [ ] Corrupted saves are detected
- [ ] Version migration works
- [ ] Backup system functions
- [ ] Large saves handle efficiently

### Integration Tests
- [ ] Autosave triggers correctly
- [ ] Multiple save slots work independently
- [ ] Quick save/load maintains game state
- [ ] UI updates after load
- [ ] No memory leaks during save/load

## Code Implementation

### SaveGame Resource (`scripts/data/save_game.gd`)
```gdscript
class_name SaveGame
extends Resource

const SAVE_VERSION = 1
const SAVE_MAGIC = "CREATURE_SAVE"

@export var version: int = SAVE_VERSION
@export var magic: String = SAVE_MAGIC
@export var timestamp: int = 0
@export var playtime: float = 0.0

# Player Data
@export var player_name: String = "Player"
@export var gold: int = 500
@export var current_week: int = 1

# Creatures (stored as dictionaries)
@export var creatures: Array[Dictionary] = []
@export var active_creature_ids: Array[String] = []

# Progression
@export var completed_quests: Array[String] = []
@export var unlocked_vendors: Array[String] = []
@export var unlocked_features: Array[String] = []

# Inventory
@export var food_inventory: Dictionary = {}  # item_id: quantity
@export var special_items: Array[String] = []
@export var egg_inventory: Array[Dictionary] = []

# Settings
@export var settings: Dictionary = {}

# Statistics
@export var statistics: Dictionary = {
    "creatures_bred": 0,
    "quests_completed": 0,
    "competitions_won": 0,
    "gold_earned": 0,
    "gold_spent": 0
}

func _init():
    timestamp = Time.get_unix_time_from_system()

# Convert creatures to saveable format
func set_creatures_from_array(creature_array: Array[Creature]):
    creatures.clear()
    for creature in creature_array:
        creatures.append(creature.to_dict())

# Restore creatures from save data
func get_creatures_array() -> Array[Creature]:
    var result: Array[Creature] = []
    for creature_data in creatures:
        result.append(Creature.from_dict(creature_data))
    return result

# Validate save data
func is_valid() -> bool:
    if magic != SAVE_MAGIC:
        return false
    if version < 0 or version > SAVE_VERSION:
        return false
    if timestamp <= 0:
        return false
    return true

# Create from current game state
static func create_from_game_state() -> SaveGame:
    var save = SaveGame.new()

    # Get data from singletons
    if GameManager:
        save.current_week = GameManager.current_week
        save.player_name = GameManager.get("player_name", "Player")

    # Additional data gathering would happen here
    # This is a placeholder for the actual implementation

    return save

# Apply to current game state
func apply_to_game_state():
    if GameManager:
        GameManager.current_week = current_week
        if GameManager.has_method("set_player_name"):
            GameManager.set_player_name(player_name)

    # Additional state restoration would happen here
```

### SaveManager Enhanced (`scripts/systems/save_manager_enhanced.gd`)
```gdscript
extends Node

const SAVE_DIR = "user://saves/"
const AUTOSAVE_SLOT = 0
const MAX_SAVE_SLOTS = 10
const BACKUP_COUNT = 3

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(error: String)
signal load_failed(error: String)

var current_save_slot: int = 1
var autosave_timer: Timer
var is_saving: bool = false

func _ready():
    # Ensure save directory exists
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")

    # Setup autosave timer
    autosave_timer = Timer.new()
    autosave_timer.wait_time = 300.0  # 5 minutes
    autosave_timer.timeout.connect(_on_autosave)
    add_child(autosave_timer)

# Save game to specific slot
func save_game(slot: int = -1) -> bool:
    if is_saving:
        push_warning("Save already in progress")
        return false

    is_saving = true

    if slot == -1:
        slot = current_save_slot

    var save_game = SaveGame.create_from_game_state()

    # Add creature data
    if GameManager.has("creature_collection"):
        save_game.set_creatures_from_array(GameManager.creature_collection)

    # Add resource data
    if GameManager.has("player_gold"):
        save_game.gold = GameManager.player_gold

    # Add progression data
    if GameManager.has("completed_quests"):
        save_game.completed_quests = GameManager.completed_quests

    # Save to file
    var success = _write_save_file(save_game, slot)

    is_saving = false

    if success:
        emit_signal("save_completed", slot)
        print("Game saved to slot %d" % slot)
    else:
        emit_signal("save_failed", "Failed to write save file")

    return success

# Load game from specific slot
func load_game(slot: int = -1) -> bool:
    if slot == -1:
        slot = current_save_slot

    var save_game = _read_save_file(slot)
    if not save_game:
        emit_signal("load_failed", "Failed to read save file")
        return false

    if not save_game.is_valid():
        emit_signal("load_failed", "Save file is corrupted")
        return false

    # Check version compatibility
    if save_game.version > SaveGame.SAVE_VERSION:
        emit_signal("load_failed", "Save file is from a newer version")
        return false

    # Migrate old saves if needed
    if save_game.version < SaveGame.SAVE_VERSION:
        save_game = _migrate_save(save_game)

    # Apply to game state
    save_game.apply_to_game_state()

    # Restore creatures
    if GameManager.has_method("set_creature_collection"):
        GameManager.set_creature_collection(save_game.get_creatures_array())

    # Restore resources
    if GameManager.has_method("set_player_gold"):
        GameManager.set_player_gold(save_game.gold)

    # Restore progression
    if GameManager.has_method("set_completed_quests"):
        GameManager.set_completed_quests(save_game.completed_quests)

    current_save_slot = slot
    emit_signal("load_completed", slot)
    print("Game loaded from slot %d" % slot)

    return true

# Write save file to disk
func _write_save_file(save_game: SaveGame, slot: int) -> bool:
    var file_path = _get_save_path(slot)

    # Backup existing save
    if FileAccess.file_exists(file_path):
        _create_backup(file_path, slot)

    # Convert to JSON
    var json_data = {
        "version": save_game.version,
        "magic": save_game.magic,
        "timestamp": save_game.timestamp,
        "playtime": save_game.playtime,
        "player_data": {
            "name": save_game.player_name,
            "gold": save_game.gold,
            "current_week": save_game.current_week
        },
        "creatures": save_game.creatures,
        "active_creature_ids": save_game.active_creature_ids,
        "progression": {
            "completed_quests": save_game.completed_quests,
            "unlocked_vendors": save_game.unlocked_vendors,
            "unlocked_features": save_game.unlocked_features
        },
        "inventory": {
            "food": save_game.food_inventory,
            "special_items": save_game.special_items,
            "eggs": save_game.egg_inventory
        },
        "settings": save_game.settings,
        "statistics": save_game.statistics
    }

    var json = JSON.new()
    var json_string = JSON.stringify(json_data, "\t")

    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        push_error("Cannot create save file: " + file_path)
        return false

    file.store_string(json_string)
    file.close()

    return true

# Read save file from disk
func _read_save_file(slot: int) -> SaveGame:
    var file_path = _get_save_path(slot)

    if not FileAccess.file_exists(file_path):
        push_error("Save file does not exist: " + file_path)
        return null

    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("Cannot open save file: " + file_path)
        return null

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        push_error("Failed to parse save file: " + json.get_error_message())
        return null

    var json_data = json.data

    # Create SaveGame from JSON
    var save_game = SaveGame.new()
    save_game.version = json_data.get("version", 0)
    save_game.magic = json_data.get("magic", "")
    save_game.timestamp = json_data.get("timestamp", 0)
    save_game.playtime = json_data.get("playtime", 0.0)

    # Player data
    var player_data = json_data.get("player_data", {})
    save_game.player_name = player_data.get("name", "Player")
    save_game.gold = player_data.get("gold", 500)
    save_game.current_week = player_data.get("current_week", 1)

    # Creatures
    save_game.creatures = json_data.get("creatures", [])
    save_game.active_creature_ids = json_data.get("active_creature_ids", [])

    # Progression
    var progression = json_data.get("progression", {})
    save_game.completed_quests = progression.get("completed_quests", [])
    save_game.unlocked_vendors = progression.get("unlocked_vendors", [])
    save_game.unlocked_features = progression.get("unlocked_features", [])

    # Inventory
    var inventory = json_data.get("inventory", {})
    save_game.food_inventory = inventory.get("food", {})
    save_game.special_items = inventory.get("special_items", [])
    save_game.egg_inventory = inventory.get("eggs", [])

    # Settings and statistics
    save_game.settings = json_data.get("settings", {})
    save_game.statistics = json_data.get("statistics", {})

    return save_game

# Get save file path
func _get_save_path(slot: int) -> String:
    if slot == AUTOSAVE_SLOT:
        return SAVE_DIR + "autosave.sav"
    else:
        return SAVE_DIR + "save_%02d.sav" % slot

# Create backup of save file
func _create_backup(file_path: String, slot: int):
    for i in range(BACKUP_COUNT - 1, 0, -1):
        var old_backup = file_path + ".bak%d" % i
        var new_backup = file_path + ".bak%d" % (i + 1)
        if FileAccess.file_exists(old_backup):
            DirAccess.rename_absolute(old_backup, new_backup)

    DirAccess.copy_absolute(file_path, file_path + ".bak1")

# Migrate old save format
func _migrate_save(save_game: SaveGame) -> SaveGame:
    print("Migrating save from version %d to %d" % [save_game.version, SaveGame.SAVE_VERSION])

    # Handle version-specific migrations here
    match save_game.version:
        0:
            # Version 0 -> 1 migration
            pass

    save_game.version = SaveGame.SAVE_VERSION
    return save_game

# Get save slot information
func get_save_info(slot: int) -> Dictionary:
    var file_path = _get_save_path(slot)

    if not FileAccess.file_exists(file_path):
        return {"exists": false}

    var save_game = _read_save_file(slot)
    if not save_game:
        return {"exists": true, "corrupted": true}

    return {
        "exists": true,
        "corrupted": false,
        "player_name": save_game.player_name,
        "week": save_game.current_week,
        "gold": save_game.gold,
        "creature_count": save_game.creatures.size(),
        "playtime": save_game.playtime,
        "timestamp": save_game.timestamp
    }

# Get all save slots info
func get_all_save_info() -> Array[Dictionary]:
    var info_list: Array[Dictionary] = []

    for slot in range(MAX_SAVE_SLOTS):
        info_list.append(get_save_info(slot))

    return info_list

# Delete save slot
func delete_save(slot: int) -> bool:
    var file_path = _get_save_path(slot)

    if not FileAccess.file_exists(file_path):
        return false

    DirAccess.remove_absolute(file_path)

    # Also remove backups
    for i in range(1, BACKUP_COUNT + 1):
        var backup_path = file_path + ".bak%d" % i
        if FileAccess.file_exists(backup_path):
            DirAccess.remove_absolute(backup_path)

    return true

# Quick save (to current slot)
func quick_save() -> bool:
    return save_game(current_save_slot)

# Quick load (from current slot)
func quick_load() -> bool:
    return load_game(current_save_slot)

# Autosave
func _on_autosave():
    if not is_saving and GameManager.get("allow_autosave", true):
        save_game(AUTOSAVE_SLOT)

# Enable/disable autosave
func set_autosave_enabled(enabled: bool):
    if enabled:
        autosave_timer.start()
    else:
        autosave_timer.stop()

# Export save for sharing
func export_save(slot: int, export_path: String) -> bool:
    var file_path = _get_save_path(slot)
    if not FileAccess.file_exists(file_path):
        return false

    DirAccess.copy_absolute(file_path, export_path)
    return true

# Import save from external file
func import_save(import_path: String, slot: int) -> bool:
    if not FileAccess.file_exists(import_path):
        return false

    # Validate the save before importing
    var temp_save = _read_save_file_direct(import_path)
    if not temp_save or not temp_save.is_valid():
        return false

    var file_path = _get_save_path(slot)
    DirAccess.copy_absolute(import_path, file_path)
    return true

# Read save file directly from path
func _read_save_file_direct(file_path: String) -> SaveGame:
    # Similar to _read_save_file but with custom path
    # Implementation would be similar
    return null
```

## Success Metrics
- Save/load completes in < 500ms for typical game
- No data loss across save/load cycles
- Corrupted saves detected 100% of time
- Backup system prevents data loss
- Migration handles version changes

## Notes
- Consider compression for large saves
- Implement cloud save hooks for future
- Add save file encryption option
- Monitor save file sizes

## Estimated Time
4-5 hours for implementation and testing