# Controller System API Reference

## Overview

The Controller System provides the architectural backbone for game flow, scene management, and UI coordination. Controllers act as intermediaries between game systems and UI, maintaining persistent state across scene transitions.

## Core Controllers

### MainController (`scripts/controllers/main_controller.gd`)

The persistent root controller that manages the game's lifecycle and scene transitions.

#### Key Properties
```gdscript
# Scene Management
ui_layer: CanvasLayer           # UI rendering layer
main_ui: Control                # Root UI container
current_ui_scene: Control       # Active UI scene

# Controllers
game_controller: GameController # Game state manager
ui_manager: UIManager           # UI system reference
```

#### Core Methods
```gdscript
change_ui_scene(scene_path: String) -> void
# Load and transition to new UI scene
# Automatically injects game_controller reference

_setup_controllers() -> void
# Initialize child controllers and systems

_load_initial_ui() -> void
# Load starting UI scene (main menu)
```

#### Input Handling
```gdscript
# Global hotkeys handled by MainController
"ui_save_game" (F5)     # Quick save
"ui_load_game" (F9)     # Quick load
"ui_open_shop" (S)      # Shop window
"ui_open_creatures" (C) # Collection window
"ui_open_quests" (Q)    # Quest window
```

#### Usage Example
```gdscript
# MainController is the root of the scene tree
# Access from any node:
var main = get_tree().get_root().get_node("Main")
main.change_ui_scene("res://scenes/ui/game_ui.tscn")

# Or via UIManager
var ui_manager = GameCore.get_system("ui")
ui_manager.change_scene("res://scenes/ui/settings.tscn")
```

### GameController (`scripts/controllers/game_controller.gd`)

Manages game state, progression, and system coordination.

#### Key Properties
```gdscript
# Game State
current_state: GameState        # MENU, PLAYING, PAUSED
game_data: Dictionary           # Runtime game data
is_new_game: bool              # New vs loaded game

# System References
systems: Dictionary             # Cached system references
save_slot: String              # Active save slot
```

#### Core Methods
```gdscript
start_new_game() -> bool
# Initialize new game state
# Returns: success status

continue_game(slot: String) -> bool
# Load and continue saved game
# Returns: success status

save_game(slot: String = "autosave") -> bool
# Save current game state
# Returns: success status

load_game(slot: String) -> bool
# Load game from slot
# Returns: success status

pause_game() -> void
# Pause game and time progression

resume_game() -> void
# Resume from pause

reset_game() -> void
# Clear all game data
```

#### Game State Management
```gdscript
enum GameState {
    MENU,       # Main menu
    PLAYING,    # Active gameplay
    PAUSED,     # Game paused
    LOADING,    # Loading save
    SAVING      # Save in progress
}

get_game_state() -> GameState
# Get current game state

set_game_state(state: GameState) -> void
# Change game state with validation

is_game_active() -> bool
# Check if game is playable (PLAYING state)
```

#### System Coordination
```gdscript
# GameController coordinates between systems
advance_time(weeks: int = 1) -> void
# Progress game time

process_weekly_update() -> void
# Trigger weekly game events

get_player_stats() -> Dictionary
# Aggregate player statistics

update_resources(type: String, amount: int) -> void
# Modify player resources
```

#### Usage Example
```gdscript
# Access from UI scenes
var game_controller = get_node("/root/Main/GameController")
# Or injected via MainController
var game_controller = self.game_controller  # If set by MainController

# Start new game
if game_controller.start_new_game():
    print("New game started!")

# Save/Load
game_controller.save_game("slot1")
game_controller.load_game("slot1")

# Game flow
game_controller.pause_game()
show_pause_menu()
game_controller.resume_game()
```

## UI Controllers

### UI Controller Base Pattern

All UI controllers follow a consistent pattern:

```gdscript
class_name BaseUIController
extends Control

# Injected by MainController
var game_controller: GameController

# UI References
@onready var panel: Panel = $Panel
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
    _setup_ui()
    _connect_signals()
    _load_data()

func set_game_controller(controller: GameController) -> void:
    game_controller = controller
    _on_game_controller_set()

func _setup_ui() -> void:
    # Initialize UI elements
    pass

func _connect_signals() -> void:
    # Connect UI signals
    close_button.pressed.connect(_on_close_pressed)

func _load_data() -> void:
    # Load and display data
    pass

func _on_game_controller_set() -> void:
    # Called when game_controller is injected
    _load_data()
```

### MainMenuController (`scripts/ui/main_menu_controller.gd`)

Manages the main menu interface.

#### Key Methods
```gdscript
_on_new_game_pressed() -> void
# Start new game flow

_on_continue_pressed() -> void
# Load most recent save

_on_load_pressed() -> void
# Show load game dialog

_on_settings_pressed() -> void
# Open settings menu

_on_quit_pressed() -> void
# Exit application
```

### GameUIController (`scripts/ui/game_ui_controller.gd`)

Manages the main gameplay interface.

#### Key Components
```gdscript
# UI Panels
@onready var top_bar: Control = $TopBar
@onready var creature_panel: Control = $CreaturePanel
@onready var action_buttons: Control = $ActionButtons

# Windows (hidden by default)
@onready var shop_window: Control = $ShopWindow
@onready var collection_window: Control = $CollectionWindow
@onready var quest_window: Control = $QuestWindow
```

#### Window Management
```gdscript
show_window(window_name: String) -> void
# Display specific window

hide_window(window_name: String) -> void
# Hide specific window

toggle_window(window_name: String) -> void
# Toggle window visibility

hide_all_windows() -> void
# Close all open windows

is_window_open(window_name: String) -> bool
# Check window visibility
```

### CollectionUIController (`scripts/ui/collection_ui_controller.gd`)

Manages the creature collection interface.

#### Key Features
```gdscript
# Display modes
enum DisplayMode {
    GRID,      # Grid view
    LIST,      # List view
    DETAILS    # Detailed view
}

# Filtering
filter_settings: Dictionary = {
    "species": "",
    "tags": [],
    "min_age": 0,
    "max_age": 999,
    "show_active": true,
    "show_stable": true
}

# Sorting
sort_by: String = "name"  # name, age, species, strength
sort_ascending: bool = true
```

#### Methods
```gdscript
refresh_collection() -> void
# Reload and display creatures

apply_filter(filter: Dictionary) -> void
# Apply filtering to display

sort_creatures(property: String) -> void
# Sort displayed creatures

select_creature(creature_id: String) -> void
# Select and show creature details

move_to_active(creature_id: String) -> void
# Move creature to active roster

move_to_stable(creature_id: String) -> void
# Move creature to stable
```

## UI Manager Integration

### UIManager (`scripts/ui/ui_manager.gd`)

System-level UI coordination.

#### Core Functions
```gdscript
change_scene(scene_path: String) -> void
# Change main UI scene

show_window(window_name: String) -> void
# Show named window in current scene

show_popup(message: String, type: PopupType) -> void
# Display popup message

show_dialog(dialog: DialogData) -> void
# Show modal dialog

get_current_scene() -> Control
# Get active UI scene

register_window(name: String, window: Control) -> void
# Register window for management
```

#### Popup System
```gdscript
enum PopupType {
    INFO,
    WARNING,
    ERROR,
    SUCCESS,
    CONFIRM
}

show_popup(message: String, type: PopupType) -> void
# Show temporary popup

show_confirm_dialog(
    message: String,
    on_confirm: Callable,
    on_cancel: Callable = Callable()
) -> void
# Show confirmation dialog
```

## Signal Flow

### Controller Signal Patterns

```gdscript
# MainController -> GameController
signal game_state_requested(state: String)

# GameController -> UI
signal game_started()
signal game_loaded(slot: String)
signal game_saved(slot: String)
signal game_paused()
signal game_resumed()

# UI -> GameController
signal action_requested(action: String, params: Dictionary)
signal window_opened(window: String)
signal window_closed(window: String)
```

### Signal Usage Example
```gdscript
# In UI Controller
func _ready():
    var bus = GameCore.get_signal_bus()
    bus.game_saved.connect(_on_game_saved)
    bus.creature_acquired.connect(_on_creature_acquired)

func _on_game_saved(slot: String):
    show_save_indicator()

func _on_creature_acquired(creature: CreatureData, source: String):
    refresh_creature_display()
    show_acquisition_popup(creature)
```

## Scene Architecture

### Scene Hierarchy
```
Main (Node2D) [Persistent]
├── GameController
├── UI (CanvasLayer)
│   └── MainUI (Control)
│       └── [Current UI Scene]
│           ├── MainMenu
│           ├── GameUI
│           ├── Settings
│           └── ...
└── World (Node2D)
    └── [Game World Content]
```

### Scene Transitions
```gdscript
# Scene transition flow
MainMenu -> GameUI (Start Game)
GameUI -> MainMenu (Return to Menu)
Any -> Settings (Open Settings)
Settings -> Previous (Back)

# Transition with data
func transition_to_game():
    var ui_manager = GameCore.get_system("ui")
    ui_manager.change_scene_with_data(
        "res://scenes/ui/game_ui.tscn",
        {"continue": true, "slot": "autosave"}
    )
```

## Input Management

### Input Mapping
```gdscript
# Project Settings Input Map
"ui_cancel" -> Escape
"ui_accept" -> Enter, Space
"ui_save_game" -> F5
"ui_load_game" -> F9
"ui_open_shop" -> S
"ui_open_creatures" -> C
"ui_open_quests" -> Q
"ui_open_inventory" -> I
"ui_toggle_menu" -> Tab
```

### Input Handling Priority
```gdscript
1. Modal dialogs (highest)
2. Open windows
3. UI controls
4. GameController hotkeys
5. MainController global hotkeys (lowest)
```

## State Persistence

### Controller State Save
```gdscript
# Controllers maintain state across scenes
class_name PersistentController
extends Node

var persistent_data: Dictionary = {}

func save_state() -> Dictionary:
    return {
        "data": persistent_data,
        "timestamp": Time.get_ticks_msec()
    }

func load_state(state: Dictionary) -> void:
    persistent_data = state.get("data", {})
```

## Performance Considerations

### UI Update Optimization
```gdscript
# Batch UI updates
var _update_pending: bool = false

func request_update() -> void:
    if not _update_pending:
        _update_pending = true
        call_deferred("_perform_update")

func _perform_update() -> void:
    _update_pending = false
    # Perform actual update
    refresh_all_displays()
```

### Scene Loading
```gdscript
# Preload frequently used scenes
const GAME_UI = preload("res://scenes/ui/game_ui.tscn")
const SHOP_WINDOW = preload("res://scenes/ui/windows/shop.tscn")

# Lazy load rarely used scenes
func load_settings_lazy():
    if not _settings_scene:
        _settings_scene = load("res://scenes/ui/settings.tscn")
    return _settings_scene
```

## Testing Controllers

### Controller Test Patterns
```gdscript
func test_game_controller():
    var controller = GameController.new()

    # Test state transitions
    assert(controller.get_game_state() == GameController.GameState.MENU)
    controller.start_new_game()
    assert(controller.get_game_state() == GameController.GameState.PLAYING)

    # Test save/load
    assert(controller.save_game("test"))
    controller.reset_game()
    assert(controller.load_game("test"))
```

## Common Patterns

### Window Manager Pattern
```gdscript
class_name WindowManager
extends Node

var windows: Dictionary = {}
var active_window: Control = null

func register_window(name: String, window: Control) -> void:
    windows[name] = window
    window.visibility_changed.connect(_on_window_visibility_changed.bind(window))

func show_window(name: String) -> void:
    if active_window:
        active_window.hide()

    if name in windows:
        active_window = windows[name]
        active_window.show()
```

### State Machine Pattern
```gdscript
class_name GameStateMachine
extends Node

var states: Dictionary = {}
var current_state: State = null

func change_state(state_name: String) -> void:
    if current_state:
        current_state.exit()

    current_state = states.get(state_name)
    if current_state:
        current_state.enter()
```

## Migration Guide

### From Direct Scene Loading
```gdscript
# Old: Direct scene change
get_tree().change_scene_to_file("res://scenes/game.tscn")

# New: Controller-managed
var ui_manager = GameCore.get_system("ui")
ui_manager.change_scene("res://scenes/ui/game_ui.tscn")
```

### From Global Singletons
```gdscript
# Old: Autoload singletons
GameManager.start_game()

# New: Controller architecture
var game_controller = get_node("/root/Main/GameController")
game_controller.start_new_game()
```