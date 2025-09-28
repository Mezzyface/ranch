# Save System API Reference

## Overview

The SaveSystem provides comprehensive game state persistence, coordinating with all game systems to save and load data. It uses a hybrid approach combining ConfigFile for metadata and ResourceSaver for complex data.

## Core Components

### SaveSystem (`scripts/systems/save_system.gd`)

Central orchestrator for all save/load operations.

#### Key Properties
```gdscript
# Configuration
SAVE_DIR: String = "user://saves/"       # Save directory path
AUTOSAVE_INTERVAL: float = 300.0         # 5 minutes
MAX_SAVE_SLOTS: int = 10                 # Maximum save files
SAVE_VERSION: int = 1                    # Save format version

# State
current_save_slot: String                # Active save slot
is_saving: bool                          # Save in progress flag
last_save_time: float                    # Timestamp of last save
autosave_enabled: bool = true            # Autosave toggle
```

#### Core Methods

##### Save Operations
```gdscript
save_game_state(slot_name: String = "default") -> bool
# Save complete game state to specified slot
# Returns: true if successful

quick_save() -> bool
# Quick save to dedicated slot
# Returns: true if successful

autosave() -> bool
# Automatic save to autosave slot
# Returns: true if successful

save_to_file(filepath: String, data: Dictionary) -> bool
# Save data to specific file
# Returns: true if successful
```

##### Load Operations
```gdscript
load_game_state(slot_name: String = "default") -> bool
# Load complete game state from slot
# Returns: true if successful

quick_load() -> bool
# Load from quick save slot
# Returns: true if successful

load_from_file(filepath: String) -> Dictionary
# Load data from specific file
# Returns: save data or empty dict
```

##### Save Management
```gdscript
get_save_slots() -> Array[Dictionary]
# Get all available save slots with metadata
# Returns: [{slot_name, timestamp, playtime, version}]

delete_save(slot_name: String) -> bool
# Delete a save file
# Returns: true if successful

copy_save(source_slot: String, dest_slot: String) -> bool
# Copy save to new slot
# Returns: true if successful

has_save(slot_name: String) -> bool
# Check if save exists
# Returns: true if exists

get_save_info(slot_name: String) -> Dictionary
# Get save file metadata
# Returns: {timestamp, playtime, version, creatures_count, etc.}
```

##### System Integration
```gdscript
register_saveable_system(system_key: String, system: Node) -> void
# Register a system for save/load operations

unregister_saveable_system(system_key: String) -> void
# Remove system from save operations

set_autosave_enabled(enabled: bool) -> void
# Toggle autosave functionality

trigger_manual_save() -> void
# Force immediate save (UI callback)
```

## Save Data Structure

### Save File Format
```gdscript
{
    # Metadata
    "version": 1,
    "timestamp": 1234567890,
    "playtime_seconds": 3600,
    "game_version": "1.0.0",

    # Core Systems
    "collection": {
        "active_roster": [...],
        "stable_collection": {...},
        "metadata": {...}
    },

    "time": {
        "current_week": 15,
        "current_month": 4,
        "current_year": 1,
        "total_weeks": 15
    },

    "resources": {
        "gold": 1000,
        "items": {...},
        "materials": {...}
    },

    "stats": {
        "player_level": 10,
        "experience": 5000,
        "achievements": [...]
    },

    "facility": {
        "version": 1,
        "unlocked_facilities": ["gym", "library"],
        "facility_assignments": {
            "gym": {
                "facility_id": "gym",
                "creature_id": "creature_123",
                "selected_activity": 0,
                "food_type": 0
            }
        },
        "facility_unlock_status": {
            "gym": true,
            "library": true
        }
    },

    # Game State
    "quests": {
        "active": [...],
        "completed": [...]
    },

    "settings": {
        "difficulty": "normal",
        "sound_volume": 0.8
    }
}
```

### System Serialization

Each system implements its own serialization:

```gdscript
# In each system
func serialize() -> Dictionary:
    return {
        "data": _internal_data,
        "cache": _cache_data,
        "version": SYSTEM_VERSION
    }

func deserialize(data: Dictionary) -> bool:
    if data.get("version", 0) != SYSTEM_VERSION:
        return migrate_save_data(data)

    _internal_data = data.get("data", {})
    _cache_data = data.get("cache", {})
    return true
```

## Integrated Systems

The SaveSystem automatically handles save/load operations for the following systems:

### Core Systems

#### PlayerCollection (`collection`)
- **Data**: Active roster, stable collection, metadata
- **Integration**: Hybrid approach using ConfigFile + ResourceSaver
- **Validation**: Creature data integrity checks
- **Features**: Individual creature files, collection statistics

#### TimeSystem (`time`)
- **Data**: Current week/month/year, total progression
- **Integration**: ConfigFile-based state persistence
- **Validation**: Time progression consistency
- **Features**: Event scheduling, temporal state

#### ResourceTracker (`resource`)
- **Data**: Gold, items, materials inventory
- **Integration**: ConfigFile with item validation
- **Validation**: Resource quantity constraints
- **Features**: Transaction history, resource caps

#### FacilitySystem (`facility`) *NEW*
- **Data**: Facility unlock status, creature assignments
- **Integration**: ConfigFile with comprehensive validation
- **Validation**: Creature existence, facility registry checks
- **Features**: Orphaned assignment cleanup, version migration

### Support Systems

#### StatSystem (`stat`)
- **Data**: System state markers (minimal persistence)
- **Integration**: ConfigFile-based initialization flags
- **Validation**: System availability checks
- **Features**: Calculation cache invalidation

#### AgeSystem (`age`)
- **Data**: System state markers (computed data)
- **Integration**: ConfigFile-based initialization flags
- **Validation**: System dependency checks
- **Features**: Age category consistency

### System Loading Order

Systems are loaded in dependency order to ensure proper initialization:

1. **Core Data**: TimeSystem, ResourceTracker
2. **Collections**: PlayerCollection, FacilitySystem
3. **Computed**: StatSystem, AgeSystem
4. **UI**: UIManager (state restoration)

### System Requirements

For a system to integrate with SaveSystem:

1. **Methods**: Implement `save_state()` and `load_state(data)`
2. **Validation**: Handle missing/invalid data gracefully
3. **Cleanup**: Remove orphaned references during load
4. **Versioning**: Support save format migration
5. **Logging**: Report validation issues and cleanup actions

## Signal Integration

### Save System Signals

```gdscript
# Save operations
signal save_started(slot_name: String)
signal save_completed(slot_name: String, success: bool)
signal save_failed(slot_name: String, error: String)

# Load operations
signal load_started(slot_name: String)
signal load_completed(slot_name: String, success: bool)
signal load_failed(slot_name: String, error: String)

# Autosave
signal autosave_triggered()
signal autosave_completed(success: bool)
```

### Signal Usage
```gdscript
var save_system = GameCore.get_system("save")
var bus = GameCore.get_signal_bus()

# Monitor save operations
bus.save_started.connect(_on_save_started)
bus.save_completed.connect(_on_save_completed)

func _on_save_started(slot: String):
    show_saving_indicator()

func _on_save_completed(slot: String, success: bool):
    hide_saving_indicator()
    if success:
        show_message("Game saved to %s" % slot)
```

## Usage Patterns

### Basic Save/Load
```gdscript
var save_system = GameCore.get_system("save")

# Manual save
if save_system.save_game_state("slot1"):
    print("Game saved successfully")

# Load game
if save_system.load_game_state("slot1"):
    print("Game loaded successfully")

# Quick save/load
save_system.quick_save()  # F5
save_system.quick_load()  # F9
```

### Save Slot Management
```gdscript
var save_system = GameCore.get_system("save")

# List saves
var saves = save_system.get_save_slots()
for save in saves:
    print("%s - %s (%.1f hours)" % [
        save.slot_name,
        Time.get_datetime_string_from_unix_time(save.timestamp),
        save.playtime / 3600.0
    ])

# Check before overwriting
if save_system.has_save("slot1"):
    if confirm_dialog("Overwrite existing save?"):
        save_system.save_game_state("slot1")

# Copy save for backup
save_system.copy_save("slot1", "slot1_backup")
```

### Autosave Configuration
```gdscript
var save_system = GameCore.get_system("save")

# Configure autosave
save_system.set_autosave_enabled(true)
save_system.AUTOSAVE_INTERVAL = 600.0  # 10 minutes

# Manual autosave trigger
save_system.autosave()

# Disable during critical operations
save_system.set_autosave_enabled(false)
perform_critical_operation()
save_system.set_autosave_enabled(true)
```

### Custom System Integration
```gdscript
# Register custom saveable system
class_name CustomSystem
extends Node

func _ready():
    var save_system = GameCore.get_system("save")
    save_system.register_saveable_system("custom", self)

func serialize() -> Dictionary:
    return {
        "custom_data": _data,
        "version": 1
    }

func deserialize(data: Dictionary) -> bool:
    _data = data.get("custom_data", {})
    return true
```

## Performance Optimization

### Async Saving
```gdscript
# SaveSystem handles async operations internally
func _save_async(slot: String):
    is_saving = true
    var thread = Thread.new()
    thread.start(_save_worker.bind(slot))

func _save_worker(slot: String):
    var data = _collect_save_data()
    _write_to_disk(slot, data)
    call_deferred("_on_save_complete", slot)
```

### Incremental Saves
```gdscript
# Save only changed data
var save_system = GameCore.get_system("save")

# Mark systems as dirty
save_system.mark_dirty("collection")
save_system.mark_dirty("resources")

# Only dirty systems are saved
save_system.incremental_save()  # Faster than full save
```

### Performance Baselines
- Full save (100 creatures): < 200ms
- Quick save: < 100ms
- Load game: < 300ms
- Autosave: < 150ms
- Save slot enumeration: < 50ms

## Error Handling

### Common Errors
1. **Disk Full**: Insufficient storage space
2. **Permission Denied**: Cannot write to save directory
3. **Corrupted Save**: Invalid or damaged save file
4. **Version Mismatch**: Save from incompatible version
5. **Missing Systems**: Required systems not loaded

### Error Recovery
```gdscript
var save_system = GameCore.get_system("save")

# Safe save with error handling
func safe_save(slot: String) -> bool:
    # Check disk space
    if not save_system.has_sufficient_space():
        show_error("Insufficient disk space")
        return false

    # Backup existing save
    if save_system.has_save(slot):
        save_system.copy_save(slot, slot + "_backup")

    # Attempt save
    if not save_system.save_game(slot):
        # Restore backup on failure
        save_system.copy_save(slot + "_backup", slot)
        show_error("Save failed - backup restored")
        return false

    # Clean up backup on success
    save_system.delete_save(slot + "_backup")
    return true
```

### Save Validation
```gdscript
# Validate save before loading
func validate_save(slot: String) -> bool:
    var data = save_system.load_from_file(save_system.get_save_path(slot))

    if data.is_empty():
        return false

    # Check version
    if data.get("version", 0) > SAVE_VERSION:
        push_error("Save version too new")
        return false

    # Check required fields
    var required = ["collection", "time", "resources"]
    for field in required:
        if not data.has(field):
            push_error("Save missing required field: %s" % field)
            return false

    return true
```

## Save Migration

### Version Migration
```gdscript
func migrate_save_data(data: Dictionary) -> Dictionary:
    var version = data.get("version", 0)

    # Migrate from version 0 to 1
    if version == 0:
        data = _migrate_v0_to_v1(data)
        version = 1

    # Future migrations
    # if version == 1:
    #     data = _migrate_v1_to_v2(data)
    #     version = 2

    data["version"] = SAVE_VERSION
    return data

func _migrate_v0_to_v1(data: Dictionary) -> Dictionary:
    # Add new fields
    if not data.has("time"):
        data["time"] = {
            "current_week": 1,
            "current_month": 1,
            "current_year": 1
        }

    # Convert old formats
    if data.has("creatures"):
        data["collection"] = {
            "active_roster": data["creatures"],
            "stable_collection": {}
        }
        data.erase("creatures")

    return data
```

## Testing

### Save System Tests
- Save/load cycle integrity
- Multi-slot management
- Autosave functionality
- Error recovery
- Migration testing
- Performance benchmarks
- Concurrent save handling

### Test File
`tests/individual/test_save.tscn` - Comprehensive save system tests

### Test Patterns
```gdscript
func test_save_load_cycle():
    var save_system = GameCore.get_system("save")

    # Create test data
    var collection = GameCore.get_system("collection")
    var creature = create_test_creature()
    collection.add_creature(creature)

    # Save
    assert(save_system.save_game("test_slot"))

    # Clear data
    collection.clear_collection()

    # Load
    assert(save_system.load_game("test_slot"))

    # Verify
    assert(collection.has_creature(creature.id))

    # Cleanup
    save_system.delete_save("test_slot")
```

## Cloud Save Integration

### Cloud Save Support (Future)
```gdscript
# Planned cloud save interface
class_name CloudSaveManager

func sync_with_cloud() -> void:
    # Upload local saves to cloud
    # Download cloud saves
    # Resolve conflicts

func upload_save(slot: String) -> bool:
    # Upload specific save to cloud
    pass

func download_save(slot: String) -> bool:
    # Download save from cloud
    pass
```

## Settings Integration

### Save Settings
```gdscript
# User preferences for saves
var save_settings = {
    "autosave_enabled": true,
    "autosave_interval": 300,
    "compression_enabled": true,
    "backup_count": 3,
    "cloud_sync": false
}

# Apply settings
save_system.apply_settings(save_settings)
```

## Common Patterns

### Save State Observer
```gdscript
class_name SaveStateObserver
extends Node

func _ready():
    var bus = GameCore.get_signal_bus()
    bus.save_completed.connect(_on_save)
    bus.load_completed.connect(_on_load)

func _on_save(slot: String, success: bool):
    if success:
        update_save_indicator()
        log_save_event(slot)

func _on_load(slot: String, success: bool):
    if success:
        refresh_all_ui()
        resume_game_timers()
```

### Save Metadata Enrichment
```gdscript
# Add custom metadata to saves
func enrich_save_metadata(data: Dictionary) -> Dictionary:
    data["custom_metadata"] = {
        "screenshot": take_screenshot_base64(),
        "current_quest": get_active_quest_name(),
        "play_style": analyze_play_style(),
        "difficulty": current_difficulty
    }
    return data
```