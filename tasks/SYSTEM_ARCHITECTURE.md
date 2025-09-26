# 🏗️ System Architecture Guide

## Overview

This document explains how the core systems work together in our creature collection game built with Godot 4.5. Understanding these patterns is essential for extending the game and adding new features.

## 🎯 Core Architecture Pattern: MVC + Subsystems

Our architecture follows a **Model-View-Controller + Subsystem** pattern:

```
GameCore (Controller)
├── SignalBus (Communication Hub)
├── StatSystem (Utility Subsystem)
├── SaveSystem (Utility Subsystem)
├── CreatureSystem (Utility Subsystem)
└── QuestSystem (Utility Subsystem) [Future]

CreatureData (Model) ←→ CreatureEntity (Controller) ←→ UI (View)
```

## 🔧 Core Components

### **1. GameCore - The Central Controller**

**Location**: `scripts/core/game_core.gd`
**Type**: Autoload singleton
**Purpose**: Central system manager and dependency injection container

```gdscript
# Access pattern
var stat_system = GameCore.get_system("stat")  # Lazy loading
var signal_bus = GameCore.get_signal_bus()     # Direct access
```

**Key Features**:
- **Lazy Loading**: Systems created only when first requested
- **Dependency Management**: All subsystems access other systems through GameCore
- **Single Source of Truth**: One place to manage system lifecycle

**When to Use**:
- ✅ Getting system references in any script
- ✅ Adding new subsystems to the game
- ❌ Storing game state (use dedicated systems instead)

---

### **2. SignalBus - Communication Hub**

**Location**: `scripts/core/signal_bus.gd`
**Type**: Centralized signal manager
**Purpose**: Decoupled communication between all systems

```gdscript
# Signal emission pattern
var signal_bus = GameCore.get_signal_bus()
signal_bus.emit_creature_stats_changed(creature_data, "strength", old_val, new_val)

# Signal listening pattern
signal_bus.creature_stats_changed.connect(_on_stats_changed)
```

**Key Features**:
- **Validation**: All signals validated before emission
- **Connection Management**: Safe connection/disconnection helpers
- **Debug Support**: Toggle debug mode for signal flow visibility
- **Type Safety**: Prevents null/invalid data propagation

**When to Use**:
- ✅ Any cross-system communication
- ✅ UI updates from game logic changes
- ✅ Event-driven architecture patterns
- ❌ Direct method calls within same system

---

### **3. Data/Behavior Separation Pattern**

This is our **most important architectural principle**:

#### **CreatureData (Pure Data Model)**
```gdscript
# Pure data - NO signals, NO behavior
class_name CreatureData extends Resource

@export var creature_name: String = ""
@export var strength: int = 50
@export var tags: Array[String] = []

# Only data access methods
func get_stat(stat_name: String) -> int:
    # Returns raw data only
```

#### **CreatureEntity (Behavior Controller)**
```gdscript
# Behavior and signal emission
class_name CreatureEntity extends Node

var data: CreatureData  # References the data
var stat_system: Node   # System dependencies

# Behavior methods that modify data
func modify_stat(stat_name: String, value: int) -> void:
    data.set_stat(stat_name, value)  # Modify data
    signal_bus.emit_creature_stats_changed(data, stat_name, old, new)  # Signal change
```

**Why This Separation?**:
- ✅ **Serialization Safety**: Resources save/load cleanly
- ✅ **Performance**: Data can be cached, copied, transmitted
- ✅ **Testing**: Data logic separate from game logic
- ✅ **Flexibility**: Same data can have different behaviors in different contexts

---

### **4. StatSystem - Stat Management Subsystem**

**Location**: `scripts/systems/stat_system.gd`
**Type**: GameCore subsystem
**Purpose**: All stat calculations, validations, and modifications

```gdscript
# System access
var stat_system = GameCore.get_system("stat")

# Quest requirements (NO age modifier)
var quest_eligible = stat_system.meets_requirements(creature_data, {"strength": 400})
var effective_stat = stat_system.get_effective_stat(creature_data, "strength")

# Competition performance (WITH age modifier)
var performance = stat_system.calculate_performance(creature_data)
var comp_stat = stat_system.get_competition_stat(creature_data, "strength")

# Modifier management
stat_system.apply_modifier(creature_id, "strength", 100, ModifierType.EQUIPMENT)
stat_system.remove_modifier(creature_id, "strength", "sword_of_power")
```

**Key Features**:
- **Dual Stat Modes**: Quest stats (fair) vs Competition stats (age-affected)
- **Advanced Modifiers**: Temporary, permanent, equipment, trait modifiers
- **Stacking Logic**: Additive first, then multiplicative
- **Tier System**: 6-level classification (WEAK → EXCEPTIONAL)
- **Validation**: All values clamped to 1-1000 range

**When to Use**:
- ✅ Any stat calculation or validation
- ✅ Quest requirement checking
- ✅ Competition performance scoring
- ✅ Equipment/buff/debuff effects
- ❌ Direct stat modification (use CreatureEntity instead)

---

## 🔄 System Interaction Patterns

### **Pattern 1: Quest Eligibility Check**

```gdscript
# In quest system or UI
func check_creature_eligibility(creature_entity: CreatureEntity, quest_requirements: Dictionary) -> bool:
    var stat_system = GameCore.get_system("stat")

    # Check stats (uses base + modifiers, NO age penalty)
    if not stat_system.meets_requirements(creature_entity.data, quest_requirements.stats):
        return false

    # Check tags (future Tag System)
    var tag_system = GameCore.get_system("tag")
    if not tag_system.meets_tag_requirements(creature_entity.data, quest_requirements.tags):
        return false

    return true
```

### **Pattern 2: Stat Modification with Validation**

```gdscript
# In equipment system or training
func equip_item(creature_entity: CreatureEntity, item: ItemData) -> bool:
    var stat_system = GameCore.get_system("stat")

    # Apply equipment modifier through StatSystem
    var modifier_id = "equipment_" + item.id
    stat_system.apply_modifier(
        creature_entity.data.id,
        "strength",
        item.strength_bonus,
        StatSystem.ModifierType.EQUIPMENT,
        StatSystem.StackingMode.ADDITIVE,
        -1,  # Permanent duration
        modifier_id
    )

    # Signal automatically emitted by StatSystem
    return true
```

### **Pattern 3: UI Updates via Signals**

```gdscript
# In UI controller
func _ready():
    var signal_bus = GameCore.get_signal_bus()
    signal_bus.creature_stats_changed.connect(_on_creature_stats_changed)
    signal_bus.creature_modifiers_changed.connect(_on_creature_modifiers_changed)

func _on_creature_stats_changed(creature_data: CreatureData, stat: String, old: int, new: int):
    # Update UI displays for base stat changes
    update_stat_display(creature_data, stat, new)

func _on_creature_modifiers_changed(creature_id: String, stat_name: String):
    # Update UI for modifier changes (equipment, buffs, etc)
    var creature_data = find_creature_by_id(creature_id)
    var stat_system = GameCore.get_system("stat")
    var breakdown = stat_system.get_stat_breakdown(creature_data, stat_name)
    update_modifier_display(creature_data, stat_name, breakdown)
```

### **Pattern 4: System Initialization**

```gdscript
# In any system that needs dependencies
class_name MyNewSystem
extends Node

var signal_bus: SignalBus
var stat_system: Node
var save_system: Node

func _ready() -> void:
    # Get dependencies through GameCore
    signal_bus = GameCore.get_signal_bus()
    stat_system = GameCore.get_system("stat")
    save_system = GameCore.get_system("save")

    # Connect to relevant signals
    signal_bus.creature_created.connect(_on_creature_created)

    print("MyNewSystem initialized")
```

---

## 🎮 Development Workflow

### **Adding a New Feature**

1. **Determine the Pattern**:
   - **Pure data change**: Modify CreatureData Resource
   - **Behavior/logic**: Add to appropriate system or CreatureEntity
   - **Cross-system communication**: Use SignalBus
   - **New functionality**: Create new GameCore subsystem

2. **Example: Adding Equipment System**

```gdscript
# 1. Create EquipmentSystem as GameCore subsystem
class_name EquipmentSystem
extends Node

var signal_bus: SignalBus
var stat_system: Node

func _ready():
    signal_bus = GameCore.get_signal_bus()
    stat_system = GameCore.get_system("stat")

# 2. Add equipment data to CreatureData
# In creature_data.gd:
@export var equipped_items: Array[String] = []

# 3. Add equipment behavior to CreatureEntity
# In creature_entity.gd:
func equip_item(item_id: String) -> bool:
    var equipment_system = GameCore.get_system("equipment")
    return equipment_system.equip_item_to_creature(self, item_id)

# 4. Register system in GameCore
# In game_core.gd _load_system():
"equipment":
    system = preload("res://scripts/systems/equipment_system.gd").new()
```

### **Testing New Systems**

```gdscript
# Add to test_setup.gd
func _test_new_system():
    var new_system = GameCore.get_system("my_new_system")
    if new_system:
        print("✅ MyNewSystem lazy loading works")
        # Test functionality
        _test_new_system_features(new_system)
    else:
        print("❌ MyNewSystem lazy loading failed")
```

---

## 📋 Best Practices

### **✅ Do's**

1. **Always use GameCore.get_system()** to access subsystems
2. **Route all cross-system communication through SignalBus**
3. **Keep data (Resources) separate from behavior (Nodes)**
4. **Validate all inputs at system boundaries**
5. **Use explicit typing** for Godot 4.5 compatibility
6. **Test all new functionality** in test_setup.gd
7. **Follow the lazy loading pattern** for new subsystems

### **❌ Don'ts**

1. **Never store game state in GameCore** (it's just a manager)
2. **Never emit signals from Resource classes** (CreatureData, etc.)
3. **Never directly access other systems** (always go through GameCore)
4. **Never bypass StatSystem** for stat calculations
5. **Never modify CreatureData directly** from UI (use CreatureEntity)
6. **Never create autoload systems** (use GameCore subsystems instead)

---

## 🔮 Future System Integration

### **Ready for Stage 1 Task 4: Tag System**

The Tag System will integrate seamlessly:

```gdscript
# Tag System will follow the same patterns
var tag_system = GameCore.get_system("tag")

# Quest eligibility with tags
var eligible = tag_system.meets_tag_requirements(creature_data, required_tags)

# Tag modification through CreatureEntity
creature_entity.add_tag("Dark Vision")  # Will use TagSystem validation

# Breeding inheritance
var inherited_tags = tag_system.calculate_inherited_tags(parent1_tags, parent2_tags)
```

### **Planned Systems Using These Patterns**

- **Tag System**: Creature trait management
- **Age System**: Creature aging and lifecycle
- **Training System**: Stat improvement mechanics
- **Quest System**: Mission management and requirements
- **Breeding System**: Creature genetics and inheritance
- **Competition System**: Performance-based challenges

---

## 🚀 Getting Started

### **For New Developers**

1. **Explore the test suite**: Run `test_setup.tscn` to see all systems in action
2. **Study the patterns**: Look at StatSystem → CreatureEntity → SignalBus flow
3. **Start small**: Add a simple method to an existing system
4. **Follow the architecture**: Always use the established patterns

### **For Adding New Features**

1. **Check if it fits existing systems**: Can StatSystem handle this?
2. **Identify the data/behavior split**: What goes in Resources vs Nodes?
3. **Plan the signal flow**: How will other systems know about changes?
4. **Write tests first**: Add tests to validate your feature works

---

## 📚 Additional Resources

- **CLAUDE.md**: Project overview and current status
- **docs/design/**: Game mechanics and requirements
- **docs/implementation/**: Technical specifications for each task
- **test_setup.gd**: Comprehensive examples of system usage

This architecture provides a solid foundation for building a complex creature collection game while maintaining clean, testable, and extensible code! 🎮✨