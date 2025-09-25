# Architecture Migration Quick Reference

## ⚠️ CRITICAL CHANGES FROM v1.0 TO v2.0

### 🔴 STOP DOING THESE (Old Architecture)
```gdscript
# ❌ DON'T: Resources with signals
class_name Creature extends Resource
signal stats_changed()  # BROKEN - signals lost on save/load!

# ❌ DON'T: Multiple autoloaded singletons
# Project Settings > Autoload:
GameManager
DataManager
SaveManager
StatManager
TagManager  # Too many!

# ❌ DON'T: Using store_var for saves
file.store_var(save_data)  # Breaks between Godot versions!

# ❌ DON'T: Tight coupling
creature.stats_changed.connect(ui._on_stats_changed)
```

### ✅ START DOING THESE (New Architecture)

```gdscript
# ✅ DO: Separate data from behavior
class_name CreatureData extends Resource  # Pure data
@export var stats: Dictionary = {}

class_name CreatureEntity extends Node  # Behavior
signal stats_changed(creature: CreatureData)
var data: CreatureData

# ✅ DO: Single GameCore autoload
# Project Settings > Autoload:
GameCore  # ONLY autoload!

# ✅ DO: ConfigFile for saves
var config := ConfigFile.new()
config.set_value("creatures", id, creature_data.to_dict())
config.save("user://save.cfg")

# ✅ DO: SignalBus for decoupling
SignalBus.creature_stats_changed.connect(_on_any_stats_changed)
```

## Quick Conversion Guide

### 1. Creature Class → Split into Two
```gdscript
# OLD: scripts/creatures/creature.gd
class_name Creature extends Resource
signal stats_changed()
@export var strength: int

# NEW: scripts/data/creature_data.gd
class_name CreatureData extends Resource
@export var strength: int  # Just data!

# NEW: scripts/entities/creature_entity.gd
class_name CreatureEntity extends Node
signal stats_changed(creature: CreatureData)
var data: CreatureData
```

### 2. Singleton Access → GameCore Subsystems
```gdscript
# OLD
CreatureManager.add_creature(creature)
SaveManager.save_game()

# NEW
GameCore.get_system("creature").add_creature(data)
GameCore.get_system("save").save_game()
```

### 3. Direct Signals → SignalBus
```gdscript
# OLD
creature.stats_changed.connect(_on_stats_changed)

# NEW
SignalBus.creature_stats_changed.connect(_on_creature_stats_changed)
```

### 4. Save System → ConfigFile
```gdscript
# OLD
func save_game():
    var file = FileAccess.open(path, FileAccess.WRITE)
    file.store_var(game_data)  # Binary format

# NEW
func save_game():
    var config = ConfigFile.new()
    config.set_value("meta", "version", SAVE_VERSION)
    config.set_value("creatures", id, creature.to_dict())
    config.save("user://save.cfg")  # Human-readable
```

## File Structure Changes

### Old Structure
```
scripts/
├── singletons/      # 8+ autoloads
│   ├── game_manager.gd
│   ├── data_manager.gd
│   └── save_manager.gd
├── creatures/
│   └── creature.gd  # Mixed data + behavior
```

### New Structure
```
scripts/
├── core/
│   └── game_core.gd     # ONLY autoload
├── systems/
│   ├── creature_system.gd  # Lazy-loaded
│   └── save_system.gd       # Lazy-loaded
├── data/
│   └── creature_data.gd    # Pure data
├── entities/
│   └── creature_entity.gd  # Behavior
└── utils/
    └── signal_bus.gd       # Signal routing
```

## Performance Improvements

### Resource Caching
```gdscript
# Lazy load and cache
var _species_cache: Dictionary = {}

func get_species(id: String) -> SpeciesData:
    if not _species_cache.has(id):
        _species_cache[id] = load("res://data/species/%s.tres" % id)
    return _species_cache[id]
```

### Object Pooling
```gdscript
var _ui_pool: Array[Control] = []

func get_ui_element() -> Control:
    if _ui_pool.is_empty():
        return UI_SCENE.instantiate()
    return _ui_pool.pop_back()

func return_ui_element(element: Control) -> void:
    element.visible = false
    _ui_pool.append(element)
```

## Testing the Migration

### 1. Verify No Signals on Resources
```gdscript
func test_creature_data_has_no_signals():
    var data = CreatureData.new()
    assert(data.get_signal_list().is_empty())
```

### 2. Verify Single Autoload
```gdscript
func test_single_autoload():
    assert(GameCore != null)
    assert(GameManager == null)  # Should not exist!
```

### 3. Verify Save Format
```gdscript
func test_save_format():
    var path = "user://test_save.cfg"
    save_game(path)
    var file_text = FileAccess.get_file_as_string(path)
    assert("[creatures]" in file_text)  # Human-readable!
```

## Common Pitfalls to Avoid

1. **Don't add signals to Resources** - They won't persist
2. **Don't create multiple autoloads** - Use GameCore subsystems
3. **Don't use store_var** - Use ConfigFile or JSON
4. **Don't connect directly to data objects** - Use SignalBus
5. **Don't load all resources at startup** - Use lazy loading
6. **Don't create new UI elements repeatedly** - Use object pooling

## Benefits of New Architecture

- ✅ **Saves won't break** between Godot versions
- ✅ **Better performance** with lazy loading
- ✅ **Easier testing** with separated concerns
- ✅ **Cleaner code** with MVC pattern
- ✅ **Less memory usage** with single autoload
- ✅ **Better debugging** with centralized signals
- ✅ **Scalable** architecture for future features

## Need Help?

1. Review `IMPROVED_ARCHITECTURE.md` for detailed explanations
2. Check `stage_1/00_stage_1_overview.md` for implementation order
3. Follow the revised Stage 1 tasks in order