# Stage 2 Task 3: Creature Collection UI

## Overview
Create the visual interface for displaying and managing the player's creature collection, including active roster and stable views with drag-and-drop functionality.

## Success Criteria
- [ ] Grid display for 6 active creatures
- [ ] Scrollable list for stable creatures
- [ ] Creature cards showing key information
- [ ] Drag-and-drop between active and stable
- [ ] Visual feedback for creature states
- [ ] Search and filter functionality
- [ ] Performance: Smooth scrolling with 100+ creatures

## Files to Create

### New Files
- `scenes/ui/panels/collection_panel.tscn`
- `scenes/ui/components/creature_card.tscn`
- `scenes/ui/components/creature_list_item.tscn`
- `scripts/ui/collection_panel.gd`
- `scripts/ui/creature_card.gd`
- `scripts/ui/creature_drag_preview.gd`

## Implementation Details

### 1. Collection Panel Layout
```
CollectionPanel (Control)
├── ActiveRoster (Panel)
│   ├── Label ("Active Team - 6 Slots")
│   └── GridContainer (2x3)
│       └── CreatureCard (x6)
├── StableSection (Panel)
│   ├── Header (HBox)
│   │   ├── Label ("Stable")
│   │   ├── SearchBar
│   │   └── FilterButton
│   └── ScrollContainer
│       └── VBoxContainer
│           └── CreatureListItem (xN)
└── TransferButtons (VBox)
    ├── MoveToActive
    └── MoveToStable
```

### 2. Creature Card Component
```gdscript
class_name CreatureCard extends PanelContainer

@export var creature_data: CreatureData
@export var slot_index: int = -1
@export var is_active_slot: bool = true

# Visual elements
@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $NameLabel
@onready var level_label: Label = $LevelLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var type_icon: TextureRect = $TypeIcon

# Drag and drop
signal dragged(creature: CreatureData)
signal dropped(creature: CreatureData, slot: int)
```

### 3. Drag and Drop System
```gdscript
func _can_drop_data(position: Vector2, data) -> bool:
    return data.has("creature") and can_accept_creature(data.creature)

func _drop_data(position: Vector2, data) -> void:
    if data.has("creature"):
        swap_or_move_creature(data.creature)

func _get_drag_preview() -> Control:
    var preview = preload("res://scenes/ui/creature_drag_preview.tscn").instantiate()
    preview.set_creature(creature_data)
    return preview
```

### 4. Collection Updates
```gdscript
func _ready():
    var collection = GameCore.get_system("collection")
    SignalBus.collection_changed.connect(_on_collection_changed)
    refresh_display()

func refresh_display():
    _update_active_roster()
    _update_stable_list()
    _update_statistics()
```

## Visual Design
- Card backgrounds color-coded by creature type
- Health/stamina bars with animated updates
- Hover effects and selection highlighting
- Drag ghost with transparency
- Empty slot indicators