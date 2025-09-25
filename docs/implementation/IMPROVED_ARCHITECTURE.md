# Improved Architecture for Godot 4.5 Creature Collection Game

## Overview
This document outlines architectural improvements based on Godot 4.5 best practices, addressing issues in the current design and providing a more robust, performant foundation.

## Key Architecture Problems & Solutions

### 1. Resource vs Node Separation

#### ❌ Current Problem
```gdscript
class_name Creature extends Resource
signal stats_changed()  # Resources shouldn't have signals!
```
Resources with signals don't work properly in Godot - signals are lost when Resources are saved/loaded.

#### ✅ Solution: Separate Data from Behavior
```gdscript
# Pure data storage (can be saved/loaded)
class_name CreatureData extends Resource
@export var id: String = ""
@export var creature_name: String = ""
@export var stats: Dictionary = {}
# No signals, no behavior, just data

# Behavior and state management
class_name CreatureEntity extends Node
signal stats_changed(creature: CreatureData)
var data: CreatureData

func modify_stat(stat_name: String, value: int) -> void:
    data.stats[stat_name] = value
    stats_changed.emit(data)
```

### 2. Singleton Architecture

#### ❌ Current Problem
8+ autoloaded singletons cause:
- Memory overhead (all loaded at startup)
- Initialization order dependencies
- Global state management issues
- Tight coupling between systems

#### ✅ Solution: Single Core Manager with Subsystems
```gdscript
# Single autoload
class_name GameCore extends Node

# Subsystems created on demand
var systems: Dictionary = {}

func _ready() -> void:
    # Initialize only essential systems
    register_system("save", SaveSystem.new())
    register_system("data", DataSystem.new())

func register_system(name: String, system: Node) -> void:
    systems[name] = system
    add_child(system)

func get_system(name: String) -> Node:
    return systems.get(name)

# Usage: GameCore.get_system("creature").add_creature(data)
```

### 3. Save System

#### ❌ Current Problem
```gdscript
func save_game(data: Dictionary) -> bool:
    file.store_var(data)  # Binary format, breaks between Godot versions
```

#### ✅ Solution: ConfigFile or JSON
```gdscript
class_name SaveSystem extends Node

const SAVE_VERSION := 1

func save_game(slot: int) -> Error:
    var config := ConfigFile.new()

    # Metadata
    config.set_value("meta", "version", SAVE_VERSION)
    config.set_value("meta", "timestamp", Time.get_unix_time_from_system())

    # Game state
    var creature_system := GameCore.get_system("creature") as CreatureSystem
    for creature in creature_system.get_all_creatures():
        config.set_value("creatures", creature.id, creature.to_dict())

    # Save with error handling
    return config.save("user://save_slot_%d.cfg" % slot)

func load_game(slot: int) -> Dictionary:
    var config := ConfigFile.new()
    var path := "user://save_slot_%d.cfg" % slot

    if config.load(path) != OK:
        return {}

    # Version check
    var version := config.get_value("meta", "version", 0)
    if version != SAVE_VERSION:
        return migrate_save(config, version)

    return parse_config(config)
```

## Recommended Architecture

### Layer Structure

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (UI Scenes, Visual Effects)      │
├─────────────────────────────────────┤
│         Controller Layer            │
│    (Game Logic, State Management)   │
├─────────────────────────────────────┤
│           Data Layer                │
│    (Resources, Save/Load, Config)   │
└─────────────────────────────────────┘
```

### Core Systems Design

```gdscript
# 1. Data Models (Resources)
class_name CreatureData extends Resource
class_name SpeciesData extends Resource
class_name QuestData extends Resource

# 2. Controllers (Nodes)
class_name CreatureController extends Node
class_name QuestController extends Node
class_name ShopController extends Node

# 3. Views (Scenes)
# scenes/ui/creature_card.tscn
# scenes/ui/shop_panel.tscn
# scenes/ui/quest_tracker.tscn

# 4. System Management
class_name GameCore extends Node  # Single autoload
class_name CreatureSystem extends Node
class_name QuestSystem extends Node
```

### Signal Architecture

#### Use Signal Bus Pattern
```gdscript
# SignalBus.gd (autoload)
class_name SignalBus extends Node

# Creature signals
signal creature_created(creature: CreatureData)
signal creature_stats_changed(creature: CreatureData, stat: String, value: int)
signal creature_aged(creature: CreatureData)

# Quest signals
signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_requirements_met(quest: QuestData, creature: CreatureData)

# Economy signals
signal gold_changed(amount: int)
signal item_purchased(item_id: String)

# Usage
SignalBus.creature_created.connect(_on_creature_created)
SignalBus.creature_created.emit(creature_data)
```

### Performance Optimizations

#### 1. Resource Loading Strategy
```gdscript
class_name ResourceCache extends Node

var _species_cache: Dictionary = {}
var _quest_cache: Dictionary = {}

func get_species(id: String) -> SpeciesData:
    if not _species_cache.has(id):
        var path := "res://resources/species/%s.tres" % id
        _species_cache[id] = load(path) as SpeciesData
    return _species_cache[id]

func preload_common_species() -> void:
    var common := ["scuttleguard", "stone_sentinel", "wind_dancer"]
    for id in common:
        get_species(id)
```

#### 2. Object Pooling
```gdscript
class_name UIObjectPool extends Node

var _creature_cards: Array[Control] = []
var _quest_items: Array[Control] = []

const CREATURE_CARD := preload("res://scenes/ui/creature_card.tscn")

func get_creature_card() -> Control:
    if _creature_cards.is_empty():
        return CREATURE_CARD.instantiate()
    return _creature_cards.pop_back()

func return_creature_card(card: Control) -> void:
    card.visible = false
    _creature_cards.append(card)
```

#### 3. Batch Operations
```gdscript
class_name CreatureSystem extends Node

func age_all_creatures() -> void:
    var aged_creatures: Array[CreatureData] = []

    # Batch processing
    for creature in active_creatures:
        creature.age_weeks += 1
        aged_creatures.append(creature)

    # Single signal emission
    SignalBus.creatures_aged.emit(aged_creatures)
```

## Implementation Phases

### Phase 1: Core Foundation (Week 1)
1. GameCore singleton
2. Basic system registration
3. ConfigFile save system
4. SignalBus setup

### Phase 2: Data Layer (Week 1-2)
1. CreatureData resource
2. SpeciesData resource
3. Resource caching system
4. Data validation

### Phase 3: Controllers (Week 2)
1. CreatureController
2. QuestController
3. State management
4. System integration

### Phase 4: UI Layer (Week 3)
1. Object pooling
2. Scene preloading
3. UI components
4. Performance profiling

## Migration Guide

### From Current to Improved Architecture

1. **Separate Creature class**
```gdscript
# Old: Creature.gd
class_name Creature extends Resource

# New: Split into two files
# CreatureData.gd
class_name CreatureData extends Resource

# CreatureEntity.gd
class_name CreatureEntity extends Node
var data: CreatureData
```

2. **Update Singleton References**
```gdscript
# Old
GameManager.add_creature(creature)

# New
GameCore.get_system("creature").add_creature(creature_data)
```

3. **Convert Signals**
```gdscript
# Old (on Resource)
creature.stats_changed.connect(_on_stats_changed)

# New (via SignalBus)
SignalBus.creature_stats_changed.connect(_on_creature_stats_changed)
```

## Testing Strategy

### Unit Tests
```gdscript
func test_creature_data_serialization():
    var creature := CreatureData.new()
    creature.creature_name = "Test"
    var dict := creature.to_dict()
    var loaded := CreatureData.from_dict(dict)
    assert(loaded.creature_name == "Test")
```

### Integration Tests
```gdscript
func test_save_load_cycle():
    var save_system := SaveSystem.new()
    save_system.save_game(0)
    var loaded := save_system.load_game(0)
    assert(loaded.has("creatures"))
```

### Performance Benchmarks
```gdscript
func benchmark_creature_creation():
    var start := Time.get_ticks_msec()
    for i in 1000:
        var creature := CreatureData.new()
    var elapsed := Time.get_ticks_msec() - start
    print("Created 1000 creatures in %d ms" % elapsed)
    assert(elapsed < 100)  # Should be under 100ms
```

## Best Practices

1. **Always separate data from behavior**
2. **Use Resources for data, Nodes for logic**
3. **Prefer composition over inheritance**
4. **Cache expensive operations**
5. **Batch signal emissions**
6. **Use object pooling for UI**
7. **Lazy load resources**
8. **Profile performance regularly**

## Conclusion

This improved architecture provides:
- Better separation of concerns
- Improved performance
- Easier testing
- More maintainable code
- Better save system reliability
- Reduced memory footprint
- Clearer signal flow

The migration can be done incrementally, starting with the core systems and gradually updating each component.