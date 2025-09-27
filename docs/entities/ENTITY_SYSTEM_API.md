# Entity System API Reference

## Overview

Entities are behavioral wrappers around data classes that provide interaction capabilities, signal emission, and system integration. They follow the data/behavior separation principle where data (Resources) hold state and entities provide actions.

## Core Entity Classes

### CreatureEntity (`scripts/entities/creature_entity.gd`)

The behavioral layer for creature interactions and state changes.

#### Properties
```gdscript
data: CreatureData           # Underlying creature data
signal_bus: SignalBus       # Signal emission reference
stat_system: Node           # StatSystem reference
tag_system: Node            # TagSystem reference
age_system: Node            # AgeSystem reference

# State flags
_is_processing: bool        # Entity active flag
_event_queue: Array         # Pending events
```

#### Initialization
```gdscript
func _init(creature_data: CreatureData = null) -> void
# Create entity with optional data

func setup(creature_data: CreatureData) -> void
# Initialize with creature data

func connect_systems() -> void
# Connect to required game systems
```

#### Stat Management
```gdscript
modify_stat(stat_name: String, value: int) -> void
# Set stat with validation and signals

increase_stat(stat_name: String, amount: int) -> void
# Increase stat by amount

decrease_stat(stat_name: String, amount: int) -> void
# Decrease stat by amount

apply_stat_modifier(stat_name: String, modifier: float) -> void
# Apply multiplicative modifier

reset_stat(stat_name: String) -> void
# Reset to base value
```

#### Tag Operations
```gdscript
add_tag(tag: String) -> bool
# Add tag through TagSystem

remove_tag(tag: String) -> bool
# Remove tag through TagSystem

can_add_tag(tag: String) -> Dictionary
# Check tag eligibility
# Returns: {can_add: bool, reason: String}

get_tags_by_category(category: int) -> Array[String]
# Get filtered tags by category

has_tag(tag: String) -> bool
# Quick tag check
```

#### Age Management
```gdscript
age_one_week() -> void
# Progress age by one week with effects

age_by_weeks(weeks: int) -> void
# Age by multiple weeks

get_age_effects() -> Dictionary
# Get current age-based effects

apply_age_transition() -> void
# Handle age category changes
```

#### Stamina System
```gdscript
consume_stamina(amount: int) -> bool
# Use stamina if available
# Returns: success status

restore_stamina(amount: int) -> void
# Restore stamina up to max

get_stamina_percentage() -> float
# Get stamina as percentage

is_exhausted() -> bool
# Check if stamina depleted

rest() -> void
# Full stamina restoration
```

#### Activity Management
```gdscript
perform_activity(activity: String, duration: int = 1) -> bool
# Execute activity with stamina cost
# Returns: success status

can_perform_activity(activity: String) -> Dictionary
# Check activity eligibility
# Returns: {can_perform: bool, reason: String}

get_available_activities() -> Array[String]
# List performable activities
```

#### Combat Interface
```gdscript
take_damage(amount: int, source: String = "") -> void
# Apply damage with death check

heal(amount: int) -> void
# Restore health

attack(target: CreatureEntity, skill: String = "basic") -> Dictionary
# Perform attack
# Returns: {damage: int, critical: bool, effects: Array}

defend() -> void
# Enter defensive stance

get_combat_stats() -> Dictionary
# Get battle-relevant stats
```

### Usage Example
```gdscript
# Create entity
var creature_data = CreatureData.new()
creature_data.creature_name = "Spark"
creature_data.species_id = "electric_mouse"

var entity = CreatureEntity.new(creature_data)
add_child(entity)

# Modify stats
entity.increase_stat("strength", 10)
entity.apply_stat_modifier("speed", 1.2)

# Tag management
entity.add_tag("trained")
entity.add_tag("competitive")

# Activity
if entity.can_perform_activity("training").can_perform:
    entity.perform_activity("training", 2)  # 2 hour training

# Combat
var enemy = get_enemy_entity()
var result = entity.attack(enemy, "thunderbolt")
print("Dealt %d damage!" % result.damage)

# Age progression
entity.age_one_week()
if entity.data.get_age_category() == GlobalEnums.AgeCategory.ADULT:
    entity.add_tag("mature")
```

## Entity Lifecycle

### Entity States
```gdscript
enum EntityState {
    IDLE,        # No current action
    ACTIVE,      # Performing action
    RESTING,     # Recovering stamina
    TRAINING,    # Stat improvement
    BATTLING,    # In combat
    BREEDING,    # Breeding process
    INCUBATING,  # Egg state
    EXPIRED      # Lifespan ended
}
```

### State Transitions
```gdscript
func change_state(new_state: EntityState) -> void:
    var old_state = current_state
    current_state = new_state

    # Exit old state
    _exit_state(old_state)

    # Enter new state
    _enter_state(new_state)

    # Emit signal
    if signal_bus:
        signal_bus.entity_state_changed.emit(self, old_state, new_state)
```

## Signal Integration

### Entity Signals

All entity signals emit through SignalBus:

```gdscript
# Stat changes
signal creature_stats_changed(creature: CreatureData, stat: String, old: int, new: int)
signal stat_modifier_applied(creature: CreatureData, stat: String, modifier: float)

# Tag changes
signal creature_tag_added(creature: CreatureData, tag: String)
signal creature_tag_removed(creature: CreatureData, tag: String)

# Age events
signal creature_aged(creature: CreatureData, new_age: int)
signal creature_matured(creature: CreatureData, category: int)
signal creature_expired(creature: CreatureData)

# Activity events
signal activity_started(creature: CreatureData, activity: String)
signal activity_completed(creature: CreatureData, activity: String, result: Dictionary)
signal stamina_depleted(creature: CreatureData)

# Combat events
signal damage_dealt(attacker: CreatureData, target: CreatureData, amount: int)
signal creature_defeated(creature: CreatureData, defeater: CreatureData)
```

### Signal Usage
```gdscript
var bus = GameCore.get_signal_bus()

# Listen for stat changes
bus.creature_stats_changed.connect(_on_stat_changed)

# Listen for activities
bus.activity_completed.connect(_on_activity_done)

func _on_stat_changed(creature: CreatureData, stat: String, old: int, new: int):
    print("%s's %s changed: %d -> %d" % [creature.creature_name, stat, old, new])

func _on_activity_done(creature: CreatureData, activity: String, result: Dictionary):
    if result.success:
        print("%s completed %s!" % [creature.creature_name, activity])
```

## Entity Patterns

### Entity Factory
```gdscript
class_name EntityFactory
extends Node

static func create_creature_entity(species_id: String) -> CreatureEntity:
    # Get species data
    var species_system = GameCore.get_system("species")
    var species = species_system.get_species(species_id)

    # Create data
    var data = CreatureData.new()
    data.species_id = species_id
    data.creature_name = generate_name(species)
    apply_species_base_stats(data, species)

    # Create entity
    var entity = CreatureEntity.new(data)
    entity.connect_systems()

    return entity

static func create_from_save(save_data: Dictionary) -> CreatureEntity:
    var data = CreatureData.new()
    data.from_dict(save_data)

    var entity = CreatureEntity.new(data)
    entity.connect_systems()
    entity.restore_state(save_data.get("entity_state", {}))

    return entity
```

### Entity Pool
```gdscript
class_name EntityPool
extends Node

var available_entities: Array[CreatureEntity] = []
var active_entities: Dictionary = {}  # id -> entity

func get_entity(creature_data: CreatureData) -> CreatureEntity:
    var entity: CreatureEntity

    if available_entities.is_empty():
        entity = CreatureEntity.new()
    else:
        entity = available_entities.pop_back()

    entity.setup(creature_data)
    active_entities[creature_data.id] = entity
    return entity

func return_entity(entity: CreatureEntity) -> void:
    active_entities.erase(entity.data.id)
    entity.reset()
    available_entities.append(entity)
```

### Entity Component System
```gdscript
# Component interface
class_name EntityComponent
extends Node

var entity: CreatureEntity

func _ready() -> void:
    entity = get_parent() as CreatureEntity

func process_component(delta: float) -> void:
    pass

# Movement component
class_name MovementComponent
extends EntityComponent

var speed: float = 100.0
var position: Vector2

func process_component(delta: float) -> void:
    if entity.data.stamina_current > 0:
        # Movement logic
        position += Vector2.RIGHT * speed * delta
```

## Performance Optimization

### Entity Updates
```gdscript
# Batch entity updates
class_name EntityManager
extends Node

var entities: Array[CreatureEntity] = []
var update_interval: float = 0.1
var _update_timer: float = 0.0

func _process(delta: float) -> void:
    _update_timer += delta
    if _update_timer >= update_interval:
        _update_timer = 0.0
        _batch_update_entities()

func _batch_update_entities() -> void:
    for entity in entities:
        if entity._is_processing:
            entity.update(update_interval)
```

### Event Queuing
```gdscript
# Queue events for batch processing
func queue_event(event_type: String, data: Dictionary) -> void:
    _event_queue.append({
        "type": event_type,
        "data": data,
        "timestamp": Time.get_ticks_msec()
    })

func process_event_queue() -> void:
    while not _event_queue.is_empty():
        var event = _event_queue.pop_front()
        _handle_event(event)
```

## Entity Behaviors

### AI Behavior
```gdscript
class_name CreatureAI
extends Node

var entity: CreatureEntity
var behavior_tree: BehaviorTree

func _ready() -> void:
    entity = get_parent() as CreatureEntity
    setup_behavior_tree()

func think() -> void:
    if entity.current_state == EntityState.IDLE:
        var action = behavior_tree.evaluate(entity)
        if action:
            entity.perform_activity(action)
```

### Autonomous Actions
```gdscript
# Entity performs actions based on state
func update_autonomous(delta: float) -> void:
    match current_state:
        EntityState.IDLE:
            if randf() < 0.1:  # 10% chance
                perform_random_activity()

        EntityState.RESTING:
            restore_stamina(10 * delta)
            if data.stamina_current >= data.stamina_max:
                change_state(EntityState.IDLE)

        EntityState.TRAINING:
            if consume_stamina(5):
                increase_stat(current_training_stat, 1)
            else:
                change_state(EntityState.RESTING)
```

## Testing Entities

### Entity Test Patterns
```gdscript
func test_entity_creation():
    var data = CreatureData.new()
    data.creature_name = "Test"

    var entity = CreatureEntity.new(data)
    assert(entity.data == data)
    assert(entity.signal_bus != null)

func test_stat_modification():
    var entity = create_test_entity()
    var initial = entity.data.strength

    entity.increase_stat("strength", 10)
    assert(entity.data.strength == initial + 10)

    # Test signals
    var signal_received = false
    var bus = GameCore.get_signal_bus()
    bus.creature_stats_changed.connect(
        func(c, s, o, n): signal_received = true
    )

    entity.modify_stat("strength", 100)
    assert(signal_received)

func test_activity_system():
    var entity = create_test_entity()
    entity.data.stamina_current = 50

    # Test activity
    var can_train = entity.can_perform_activity("training")
    assert(can_train.can_perform)

    var success = entity.perform_activity("training", 1)
    assert(success)
    assert(entity.data.stamina_current < 50)
```

## Entity Extensions

### Custom Entity Types
```gdscript
# Specialized entity for NPCs
class_name NPCEntity
extends CreatureEntity

@export var dialogue_tree: Resource
@export var shop_inventory: Array[ItemResource]
@export var quest_giver: bool = false

func interact(player: CreatureEntity) -> void:
    if quest_giver:
        show_quest_dialog()
    elif shop_inventory.size() > 0:
        open_shop()
    else:
        show_dialogue()

# Boss entity with special mechanics
class_name BossEntity
extends CreatureEntity

@export var phase_count: int = 3
@export var phase_thresholds: Array[float] = [0.75, 0.5, 0.25]
var current_phase: int = 0

func take_damage(amount: int, source: String = "") -> void:
    super.take_damage(amount, source)

    var health_percent = get_health_percentage()
    for i in range(phase_count):
        if health_percent <= phase_thresholds[i] and current_phase == i:
            advance_phase()
            break

func advance_phase() -> void:
    current_phase += 1
    apply_phase_buffs()
    signal_bus.boss_phase_changed.emit(self, current_phase)
```

## Common Patterns

### Entity Observer
```gdscript
class_name EntityObserver
extends Node

var observed_entity: CreatureEntity

func observe(entity: CreatureEntity) -> void:
    observed_entity = entity

    var bus = GameCore.get_signal_bus()
    bus.creature_stats_changed.connect(_on_stats_changed)
    bus.activity_completed.connect(_on_activity)

func _on_stats_changed(creature: CreatureData, stat: String, old: int, new: int):
    if creature == observed_entity.data:
        update_stat_display(stat, new)

func _on_activity(creature: CreatureData, activity: String, result: Dictionary):
    if creature == observed_entity.data:
        log_activity(activity, result)
```

### Entity Command Queue
```gdscript
class_name EntityCommandQueue
extends Node

var command_queue: Array[Callable] = []
var entity: CreatureEntity

func queue_command(command: Callable) -> void:
    command_queue.append(command)

func execute_next() -> void:
    if not command_queue.is_empty() and entity.current_state == EntityState.IDLE:
        var command = command_queue.pop_front()
        command.call()
```