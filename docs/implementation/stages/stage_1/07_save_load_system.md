# Task 07: ConfigFile Save/Load System

## Overview
Implement a robust save/load system using ConfigFile (NOT store_var) that provides versioning, human-readable saves, and won't break between Godot versions. This replaces the fragile binary serialization approach.

## Dependencies
- Task 01: GameCore and SignalBus (complete)
- Task 02: CreatureData/CreatureEntity separation (complete)
- All data structures properly separated (Resources for data, Nodes for behavior)

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- Use ConfigFile for saves (human-readable, version-safe)
- Never use store_var (breaks between Godot versions)
- Support save migration between versions
- All saves go through SaveSystem managed by GameCore

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
   - ConfigFile format (.cfg) for reliability
   - Human-readable for debugging
   - Built-in sectioning for organization
   - Version tracking for migration

2. **Save Architecture**
   - SaveSystem as GameCore subsystem (not autoload)
   - Signal-based save triggers via SignalBus
   - Multiple save slots (save_slot_0.cfg, save_slot_1.cfg)
   - Automatic backup before overwriting

3. **Data Integrity**
   - Version checking on load
   - Migration system for old saves
   - Validation of required sections
   - Graceful handling of missing data

## Implementation Steps

1. **Create SaveSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for save/load signals
   - Uses ConfigFile for all operations

2. **Implement Save Function**
   - Gather data from all systems
   - Write to ConfigFile sections
   - Create backup before overwriting

3. **Implement Load Function**
   - Read ConfigFile sections
   - Validate version
   - Distribute data to systems

4. **Add Migration System**
   - Version checking
   - Migration functions for each version
   - Data conversion utilities

5. **Test Save/Load Cycle**
   - Verify all data persists
   - Test migration from old versions
   - Ensure human-readable output

## Test Criteria

### Unit Tests
- [ ] Save creates ConfigFile successfully
- [ ] Load reads ConfigFile correctly
- [ ] All creature data persists
- [ ] Player resources save/load correctly
- [ ] Progression data maintains integrity
- [ ] Settings preserve values

### Data Integrity Tests
- [ ] Save and load 100 creatures without data loss
- [ ] Version migration works
- [ ] Backup system functions
- [ ] ConfigFile remains human-readable
- [ ] Large saves handle efficiently

### Integration Tests
- [ ] SignalBus triggers save/load correctly
- [ ] Multiple save slots work independently
- [ ] GameCore properly manages SaveSystem
- [ ] No memory leaks during save/load

## Code Implementation

### SaveSystem - Complete ConfigFile Implementation
```gdscript
# scripts/systems/save_system.gd
class_name SaveSystem
extends Node

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://save_slot_%d.cfg"
const BACKUP_PATH: String = "user://save_slot_%d.backup.cfg"
const AUTOSAVE_SLOT: int = 99

var signal_bus: SignalBus
var current_slot: int = 0

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()

    # Connect to save/load signals
    signal_bus.save_requested.connect(_on_save_requested)
    signal_bus.load_requested.connect(_on_load_requested)
    signal_bus.autosave_requested.connect(_on_autosave_requested)

    print("SaveSystem initialized")

# Main save function
func save_game(slot: int = 0) -> bool:
    # Create backup of existing save
    _create_backup(slot)

    var config := ConfigFile.new()

    # === METADATA SECTION ===
    config.set_value("meta", "version", SAVE_VERSION)
    config.set_value("meta", "timestamp", Time.get_unix_time_from_system())
    config.set_value("meta", "slot", slot)

    # === PLAYER SECTION ===
    var economy_system = GameCore.get_system("economy")
    if economy_system:
        config.set_value("player", "gold", economy_system.get_gold())
        config.set_value("player", "week", economy_system.get_current_week())

    # === CREATURES SECTION ===
    var creature_system = GameCore.get_system("creature") as CreatureSystem
    if creature_system:
        var creatures := creature_system.get_all_creatures()
        for creature_data in creatures:
            config.set_value("creatures", creature_data.id, creature_data.to_dict())

        # Save active creature IDs
        var active_ids := creature_system.get_active_creature_ids()
        config.set_value("creatures_meta", "active_ids", active_ids)

    # === PROGRESSION SECTION ===
    var quest_system = GameCore.get_system("quest")
    if quest_system:
        config.set_value("progression", "completed_quests",
                        quest_system.get_completed_quest_ids())
        config.set_value("progression", "active_quests",
                        quest_system.get_active_quest_ids())

    # === INVENTORY SECTION ===
    var inventory_system = GameCore.get_system("inventory")
    if inventory_system:
        config.set_value("inventory", "food", inventory_system.get_food_dict())
        config.set_value("inventory", "items", inventory_system.get_items_dict())

    # === SETTINGS SECTION ===
    config.set_value("settings", "master_volume", AudioServer.get_bus_volume_db(0))
    config.set_value("settings", "sfx_volume", AudioServer.get_bus_volume_db(1))
    config.set_value("settings", "music_volume", AudioServer.get_bus_volume_db(2))

    # Save to file
    var error := config.save(SAVE_PATH % slot)
    var success := error == OK

    # Emit completion signal
    signal_bus.save_completed.emit(success)

    if success:
        print("Game saved to slot %d" % slot)
        current_slot = slot
    else:
        push_error("Failed to save game: " + error_string(error))

    return success

# Main load function
func load_game(slot: int = 0) -> bool:
    var path := SAVE_PATH % slot

    if not FileAccess.file_exists(path):
        push_warning("Save file doesn't exist: " + path)
        signal_bus.load_completed.emit(false)
        return false

    var config := ConfigFile.new()
    var error := config.load(path)

    if error != OK:
        push_error("Failed to load save: " + error_string(error))
        signal_bus.load_completed.emit(false)
        return false

    # Check version and migrate if needed
    var version := config.get_value("meta", "version", 0)
    if version != SAVE_VERSION:
        print("Migrating save from version %d to %d" % [version, SAVE_VERSION])
        _migrate_save(config, version)

    # === LOAD PLAYER DATA ===
    var economy_system = GameCore.get_system("economy")
    if economy_system:
        economy_system.set_gold(config.get_value("player", "gold", 500))
        economy_system.set_current_week(config.get_value("player", "week", 1))

    # === LOAD CREATURES ===
    var creature_system = GameCore.get_system("creature") as CreatureSystem
    if creature_system:
        creature_system.clear_all_creatures()

        # Load all creatures
        if config.has_section("creatures"):
            for creature_id in config.get_section_keys("creatures"):
                var creature_dict := config.get_value("creatures", creature_id, {})
                var creature_data := CreatureData.from_dict(creature_dict)
                creature_system.add_creature(creature_data)

        # Set active creatures
        var active_ids = config.get_value("creatures_meta", "active_ids", [])
        creature_system.set_active_creatures(active_ids)

    # === LOAD PROGRESSION ===
    var quest_system = GameCore.get_system("quest")
    if quest_system:
        var completed = config.get_value("progression", "completed_quests", [])
        quest_system.set_completed_quests(completed)

        var active = config.get_value("progression", "active_quests", [])
        quest_system.set_active_quests(active)

    # === LOAD INVENTORY ===
    var inventory_system = GameCore.get_system("inventory")
    if inventory_system:
        var food = config.get_value("inventory", "food", {})
        inventory_system.set_food_inventory(food)

        var items = config.get_value("inventory", "items", {})
        inventory_system.set_items_inventory(items)

    # === LOAD SETTINGS ===
    AudioServer.set_bus_volume_db(0, config.get_value("settings", "master_volume", 0))
    AudioServer.set_bus_volume_db(1, config.get_value("settings", "sfx_volume", 0))
    AudioServer.set_bus_volume_db(2, config.get_value("settings", "music_volume", 0))

    # Emit completion signal
    signal_bus.load_completed.emit(true)
    print("Game loaded from slot %d" % slot)
    current_slot = slot

    return true

# Create backup before saving
func _create_backup(slot: int) -> void:
    var save_path := SAVE_PATH % slot
    var backup_path := BACKUP_PATH % slot

    if FileAccess.file_exists(save_path):
        DirAccess.copy_absolute(save_path, backup_path)
        print("Backup created for slot %d" % slot)

# Restore from backup
func restore_backup(slot: int) -> bool:
    var save_path := SAVE_PATH % slot
    var backup_path := BACKUP_PATH % slot

    if not FileAccess.file_exists(backup_path):
        push_warning("No backup exists for slot %d" % slot)
        return false

    DirAccess.copy_absolute(backup_path, save_path)
    print("Backup restored for slot %d" % slot)
    return true

# Save migration between versions
func _migrate_save(config: ConfigFile, from_version: int) -> void:
    match from_version:
        0:
            # Version 0 -> 1 migration
            # Add any missing fields with defaults
            if not config.has_section_key("meta", "slot"):
                config.set_value("meta", "slot", 0)

            # Convert old creature format to new
            if config.has_section("creatures"):
                for creature_id in config.get_section_keys("creatures"):
                    var old_data = config.get_value("creatures", creature_id)
                    # Perform any necessary conversions
                    # ...
        _:
            push_warning("Unknown save version: %d" % from_version)

# Quick save to current slot
func quick_save() -> bool:
    return save_game(current_slot)

# Quick load from current slot
func quick_load() -> bool:
    return load_game(current_slot)

# Autosave to special slot
func autosave() -> bool:
    return save_game(AUTOSAVE_SLOT)

# Signal handlers
func _on_save_requested(slot: int) -> void:
    save_game(slot)

func _on_load_requested(slot: int) -> void:
    load_game(slot)

func _on_autosave_requested() -> void:
    autosave()

# Get save information for UI
func get_save_info(slot: int) -> Dictionary:
    var path := SAVE_PATH % slot

    if not FileAccess.file_exists(path):
        return {"exists": false}

    var config := ConfigFile.new()
    if config.load(path) != OK:
        return {"exists": true, "corrupted": true}

    return {
        "exists": true,
        "corrupted": false,
        "timestamp": config.get_value("meta", "timestamp", 0),
        "week": config.get_value("player", "week", 1),
        "gold": config.get_value("player", "gold", 0),
        "creature_count": config.get_section_keys("creatures").size() if config.has_section("creatures") else 0
    }

# Delete save slot
func delete_save(slot: int) -> bool:
    var save_path := SAVE_PATH % slot
    var backup_path := BACKUP_PATH % slot

    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)

    if FileAccess.file_exists(backup_path):
        DirAccess.remove_absolute(backup_path)

    print("Deleted save slot %d" % slot)
    return true
```

### Example Save File Output
```ini
; This is what a save file looks like with ConfigFile
[meta]
version=1
timestamp=1699123456
slot=0

[player]
gold=1250
week=15

[creatures]
creature_1699123456_123456={"id": "creature_1699123456_123456", "creature_name": "Fluffy", "species_id": "scuttleguard", ...}
creature_1699123457_234567={"id": "creature_1699123457_234567", "creature_name": "Spike", "species_id": "stone_sentinel", ...}

[creatures_meta]
active_ids=["creature_1699123456_123456"]

[progression]
completed_quests=["TIM-01", "TIM-02"]
active_quests=["TIM-03"]

[inventory]
food={"grain_ration": 10, "protein_bar": 5}
items={"healing_potion": 3}

[settings]
master_volume=0.0
sfx_volume=-6.0
music_volume=-12.0
```

## Success Metrics
- Save/load completes in < 200ms for typical game
- ConfigFile remains human-readable
- No data corruption between Godot versions
- Save migration handles version changes gracefully
- Backup system prevents data loss

## Notes
- ConfigFile is more reliable than store_var
- Human-readable format aids debugging
- Supports comments in save files
- Easy to edit for testing
- Version migration ensures compatibility

## Estimated Time
3-4 hours for implementation and testing