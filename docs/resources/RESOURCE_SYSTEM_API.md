# Resource System API Reference

## Overview

The Resource System provides data-driven configuration for game entities using Godot's Resource system. All resources are stored as `.tres` files for easy modification and version control.

## Core Resource Classes

### ItemResource (`scripts/resources/item_resource.gd`)

Defines items that can be collected, traded, and used in the game.

#### Key Properties
```gdscript
# Core Identity
item_id: String           # Unique identifier
display_name: String      # UI display name
item_type: ItemType       # CONSUMABLE, EQUIPMENT, MATERIAL, etc.
rarity: ItemRarity        # COMMON, UNCOMMON, RARE, EPIC, LEGENDARY

# Economy
base_price: int           # Purchase price in shop
sell_value: int           # Sell price (default: 60% of base)
stack_size: int           # Max items per inventory slot

# Properties
is_consumable: bool       # Can be used/consumed
is_tradeable: bool        # Can be traded between players
is_quest_item: bool       # Protected from deletion

# Effects (Consumables)
stamina_restore: int      # Stamina points restored
stat_boosts: Dictionary   # {stat_name: boost_amount}
stat_boost_duration_hours: int  # 0 = permanent
healing_amount: int       # Health restored

# Requirements
required_level: int       # Min level to use
required_tags: Array[String]  # Required creature tags
```

#### Methods
```gdscript
is_valid() -> bool
# Validate resource configuration

can_use(creature: CreatureData) -> bool
# Check if creature can use this item

apply_effects(creature: CreatureData) -> void
# Apply item effects to creature

get_tooltip_text() -> String
# Generate formatted tooltip
```

#### Usage Example
```gdscript
# Loading an item resource
var item_manager = GameCore.get_system("item_manager")
var potion = item_manager.get_item("health_potion")

# Check if creature can use
if potion.can_use(creature_data):
    potion.apply_effects(creature_data)
    print("Used %s" % potion.display_name)

# Creating new item via code
var new_item = ItemResource.new()
new_item.item_id = "super_berry"
new_item.display_name = "Super Berry"
new_item.item_type = GlobalEnums.ItemType.CONSUMABLE
new_item.stamina_restore = 50
new_item.base_price = 100
```

### SpeciesResource (`scripts/resources/species_resource.gd`)

Defines creature species with their base stats and characteristics.

#### Key Properties
```gdscript
# Core Identity
species_id: String         # Unique identifier
species_name: String       # Display name
species_type: SpeciesType  # BIRD, BEAST, DRAGON, etc.
rarity: CreatureRarity     # COMMON, RARE, LEGENDARY

# Base Stats
base_stats: Dictionary     # {stat_name: base_value}
stat_growth_rates: Dictionary  # {stat_name: growth_per_level}
max_level: int            # Maximum achievable level

# Lifecycle
base_lifespan_weeks: int  # Base lifespan
lifespan_variance: int    # +/- random variance
maturity_age_weeks: int   # Adult age threshold
evolution_species_id: String  # Next evolution form

# Abilities
innate_abilities: Array[String]  # Natural abilities
learnable_abilities: Array[Dictionary]  # [{ability_id, required_level}]

# Appearance
sprite_path: String       # Visual asset path
portrait_path: String     # UI portrait path
size_category: String     # TINY, SMALL, MEDIUM, LARGE
color_variations: Array[Color]  # Available colors

# Behavior
temperament: String       # DOCILE, FRIENDLY, AGGRESSIVE
preferred_habitat: String # FOREST, MOUNTAIN, OCEAN
diet_type: String        # HERBIVORE, CARNIVORE, OMNIVORE

# Breeding
can_breed: bool          # Breeding enabled
breeding_cooldown_weeks: int  # Time between breeding
compatible_species: Array[String]  # Cross-breeding partners
```

#### Methods
```gdscript
is_valid() -> bool
# Validate species configuration

get_stat_at_level(stat: String, level: int) -> int
# Calculate stat value at given level

get_random_lifespan() -> int
# Generate random lifespan within variance

can_evolve_at_level(level: int) -> bool
# Check evolution eligibility

generate_random_appearance() -> Dictionary
# Generate random visual properties
```

#### Usage Example
```gdscript
# Loading species
var species_system = GameCore.get_system("species")
var dragon = species_system.get_species("fire_dragon")

# Check species properties
print("Species: %s" % dragon.species_name)
print("Base HP: %d" % dragon.base_stats.get("health", 0))
print("Lifespan: %d-%d weeks" % [
    dragon.base_lifespan_weeks - dragon.lifespan_variance,
    dragon.base_lifespan_weeks + dragon.lifespan_variance
])

# Generate creature from species
var creature = CreatureData.new()
creature.species_id = dragon.species_id
creature.lifespan_weeks = dragon.get_random_lifespan()
```

## Resource File Format

### Item Resource File (`data/items/health_potion.tres`)
```
[gd_resource type="Resource" script_class="ItemResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/item_resource.gd" id="1"]

[resource]
script = ExtResource("1")
item_id = "health_potion"
display_name = "Health Potion"
item_type = 0  # CONSUMABLE
rarity = 1     # COMMON
base_price = 50
sell_value = 30
stack_size = 10
is_consumable = true
is_tradeable = true
healing_amount = 25
description = "Restores 25 health points"
icon_path = "res://assets/icons/items/health_potion.png"
```

### Species Resource File (`data/species/fire_dragon.tres`)
```
[gd_resource type="Resource" script_class="SpeciesResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/species_resource.gd" id="1"]

[resource]
script = ExtResource("1")
species_id = "fire_dragon"
species_name = "Fire Dragon"
species_type = 3  # DRAGON
rarity = 4       # LEGENDARY
base_stats = {
    "health": 100,
    "strength": 25,
    "speed": 15,
    "intelligence": 20
}
base_lifespan_weeks = 260
lifespan_variance = 52
sprite_path = "res://assets/sprites/creatures/fire_dragon.png"
```

## Resource Loading

### Via ItemManager
```gdscript
var item_manager = GameCore.get_system("item_manager")

# Get single item
var item = item_manager.get_item("health_potion")

# Get all items of type
var consumables = item_manager.get_items_by_type(GlobalEnums.ItemType.CONSUMABLE)

# Get items by rarity
var rare_items = item_manager.get_items_by_rarity(GlobalEnums.ItemRarity.RARE)
```

### Via SpeciesSystem
```gdscript
var species_system = GameCore.get_system("species")

# Get single species
var species = species_system.get_species("fire_dragon")

# Get all species
var all_species = species_system.get_all_species()

# Get species by type
var dragons = species_system.get_species_by_type(GlobalEnums.SpeciesType.DRAGON)

# Get random species
var random = species_system.get_random_species()
```

## Resource Validation

### Validation Requirements

All resources must implement `is_valid()` method that checks:
1. Required fields are populated
2. References to other resources exist
3. Numerical values are within valid ranges
4. Arrays contain valid data

### Validation Example
```gdscript
func is_valid() -> bool:
    if item_id.is_empty():
        push_error("ItemResource: Missing item_id")
        return false

    if display_name.is_empty():
        push_error("ItemResource: Missing display_name for %s" % item_id)
        return false

    if base_price < 0:
        push_error("ItemResource: Invalid base_price for %s" % item_id)
        return false

    return true
```

## Resource Creation Guidelines

### Best Practices

1. **Unique IDs**: Use snake_case for IDs (e.g., `fire_dragon`, `health_potion`)
2. **Display Names**: Use proper capitalization for display
3. **Validation**: Always implement `is_valid()` method
4. **Defaults**: Provide sensible defaults in `_init()`
5. **Documentation**: Add comments for complex properties
6. **File Organization**: Group resources by type in subdirectories

### Directory Structure
```
data/
├── items/
│   ├── consumables/
│   │   ├── health_potion.tres
│   │   └── stamina_elixir.tres
│   ├── equipment/
│   │   └── iron_sword.tres
│   └── materials/
│       └── dragon_scale.tres
├── species/
│   ├── common/
│   │   └── forest_sprite.tres
│   ├── rare/
│   │   └── crystal_wolf.tres
│   └── legendary/
│       └── fire_dragon.tres
└── abilities/
    └── fireball.tres
```

## Performance Considerations

### Resource Loading
- Resources are loaded once and cached by systems
- Use preload() for critical resources
- Lazy-load optional resources

### Memory Management
```gdscript
# Preload critical resources
const HEALTH_POTION = preload("res://data/items/health_potion.tres")

# Lazy load optional resources
func get_item_lazy(path: String) -> ItemResource:
    if not _cache.has(path):
        _cache[path] = load(path)
    return _cache[path]
```

## Testing Resources

### Test Coverage
- Validation tests for each resource type
- Loading/parsing tests
- Effect application tests
- Cross-reference validation

### Test Example
```gdscript
func test_item_resource_validation():
    var item = ItemResource.new()
    assert(not item.is_valid(), "Empty item should be invalid")

    item.item_id = "test_item"
    item.display_name = "Test Item"
    assert(item.is_valid(), "Item with required fields should be valid")
```

## Migration Guide

### From Hardcoded Data
```gdscript
# Old: Hardcoded dictionary
const ITEMS = {
    "health_potion": {
        "name": "Health Potion",
        "healing": 25,
        "price": 50
    }
}

# New: Resource-based
var item_manager = GameCore.get_system("item_manager")
var potion = item_manager.get_item("health_potion")
```

### Creating Resources from Code
```gdscript
# Generate resource programmatically
var item = ItemResource.new()
item.item_id = "generated_item_%d" % randi()
item.display_name = "Generated Item"
item.item_type = GlobalEnums.ItemType.MATERIAL

# Save to file
ResourceSaver.save(item, "res://data/items/generated/%s.tres" % item.item_id)
```

## Common Patterns

### Resource Factory
```gdscript
class_name ItemFactory

static func create_potion(healing: int, name: String) -> ItemResource:
    var potion = ItemResource.new()
    potion.item_id = name.to_snake_case()
    potion.display_name = name
    potion.item_type = GlobalEnums.ItemType.CONSUMABLE
    potion.healing_amount = healing
    potion.base_price = healing * 2
    return potion
```

### Resource Inheritance
```gdscript
# Base equipment resource
class_name EquipmentResource
extends ItemResource

@export var equipment_slot: GlobalEnums.EquipmentSlot
@export var stat_modifiers: Dictionary = {}
@export var set_bonus_id: String = ""

# Specific weapon resource
class_name WeaponResource
extends EquipmentResource

@export var damage: int = 0
@export var attack_speed: float = 1.0
@export var damage_type: GlobalEnums.DamageType
```

## Error Handling

### Common Errors
1. **Missing Resource File**: File not found at path
2. **Invalid Script Class**: Resource missing @tool annotation
3. **Circular Dependencies**: Resources referencing each other
4. **Type Mismatches**: Wrong enum values or types

### Error Recovery
```gdscript
func load_item_safe(item_id: String) -> ItemResource:
    var path = "res://data/items/%s.tres" % item_id

    if not FileAccess.file_exists(path):
        push_error("Item file not found: %s" % path)
        return null

    var resource = load(path) as ItemResource
    if not resource:
        push_error("Failed to load item: %s" % item_id)
        return null

    if not resource.is_valid():
        push_error("Invalid item resource: %s" % item_id)
        return null

    return resource
```