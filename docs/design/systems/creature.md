# Creature System Specifications

## Stat System

Creatures have six primary stats (0-1000) and a training stamina stat (0-100). For complete stat definitions, training mechanics, and component implementation, see **[stats.md](stats.md)**.

### Stat Overview
- **Strength (STR)**: Physical power, combat, construction
- **Constitution (CON)**: Health, durability, endurance
- **Dexterity (DEX)**: Speed, agility, precision
- **Intelligence (INT)**: Problem solving, learning, complex tasks
- **Wisdom (WIS)**: Awareness, perception, instinct
- **Discipline (DIS)**: Obedience, focus, reliability
- **Stamina (STA)**: Training energy (0-100)
  
## Tag System

Creatures possess various tags that define their capabilities and characteristics. For complete tag definitions, categories, and implementation details, see **[tags.md](tags.md)**.

### Tag Overview
- **Size Tags**: Physical characteristics (Small)
- **Behavioral Tags**: Personality and behavior traits (Territorial, Stealthy, Sentient)
- **Environmental Tags**: Adaptation to specific environments (Dark Vision, Sure-Footed, Flies)
- **Utility Tags**: Specialized abilities (Bioluminescent, Cleanser, Camouflage, Constructor)

## Scene Structure (Godot 4.5 Composition)

### Main Creature Scene
```
Creature (Node2D)
├── AnimatedSprite2D
├── StatsComponent (Node)
├── TagsComponent (Node)
├── CreatureAI (Node)
└── CollisionShape2D (for interactions)
```

## Component Data Structures (Godot 4.5)

### Creature Main Script
```gdscript
class_name Creature extends Node2D

@export var creature_name: String
@export var creature_id: String
@export var species: String
@export var color_variant: String
@export var current_age: int = 0
@export var max_lifespan: int = 100
@export var is_active: bool = false
@export var current_activity: WeeklyActivity = WeeklyActivity.RESTING
@export var assigned_food: FoodType = FoodType.GRAIN_RATIONS

@onready var stats_component: StatsComponent = $StatsComponent
@onready var tags_component: TagsComponent = $TagsComponent
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
    # Initialize creature
    pass
```

### Component References
- **StatsComponent**: See [stats.md](stats.md) for complete implementation
- **TagsComponent**: See [tags.md](tags.md) for complete implementation

## Example Creatures

### Scuttleguard
- **Species**: Armored Arthropod
- **Color Variant**: Bronze
- **Age**: 15 / 80 years
- **Status**: Active
- **Current Activity**: Combat Practice (Strength Training)
- **Assigned Food**: Protein Mix
- **Stats**: STR: 100, CON: 110, DEX: 130, INT: 50, WIS: 140, DIS: 130
- **Tags**: SMALL, TERRITORIAL, DARK_VISION
- **Role**: Early game guard, suitable for study and cave entrance

### Quill-Cat
- **Species**: Feline Predator
- **Color Variant**: Tawny
- **Age**: 8 / 60 years
- **Status**: Stable (Stasis)
- **Stats**: STR: 80, CON: 90, DEX: 190, INT: 110, WIS: 170, DIS: 90
- **Tags**: SMALL, TERRITORIAL, STEALTHY
- **Role**: Study guard with stealth capabilities

## Implementation Details

For complete implementation including convenience methods, quest validation, and breeding system, see **[creature_implementation.md](creature_implementation.md)**.