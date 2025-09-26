# Stage 2 Task 2: UI Framework Foundation

## Overview
Establish the core UI architecture with scene management, navigation, theming, and responsive layout system that will serve as the foundation for all game UI components.

## Success Criteria
- [ ] Main scene structure with proper node hierarchy
- [ ] Scene transition system with loading states
- [ ] Consistent theming across all UI elements
- [ ] Responsive layout adapting to window resize
- [ ] Keyboard and gamepad navigation support
- [ ] Performance: 60 FPS with full UI rendered
- [ ] Memory: UI resources < 50MB

## Files to Create/Modify

### New Files
- `scenes/ui/main_menu.tscn` - Main menu scene
- `scenes/ui/game_ui.tscn` - Main game UI container
- `scenes/ui/components/` - Reusable UI components folder
- `scripts/ui/ui_manager.gd` - UI management singleton
- `scripts/ui/scene_transition.gd` - Scene transition controller
- `resources/themes/default_theme.tres` - Game UI theme
- `resources/fonts/` - Font resources

### Modified Files
- `project.godot` - UI settings and input mappings
- `scripts/core/game_core.gd` - Register UIManager

## Implementation Details

### 1. Scene Architecture
```
Main (Node2D/Control)
├── UIManager (Node)
├── GameUI (CanvasLayer)
│   ├── HUD (Control)
│   │   ├── TopBar (HBoxContainer)
│   │   ├── SidePanel (VBoxContainer)
│   │   └── BottomBar (HBoxContainer)
│   ├── Windows (Control)
│   │   ├── CreatureDetails (Window)
│   │   ├── ShopWindow (Window)
│   │   └── SettingsWindow (Window)
│   └── Dialogs (Control)
│       ├── ConfirmDialog
│       └── NotificationPopup
└── DebugUI (CanvasLayer)
```

### 2. UIManager Class
```gdscript
class_name UIManager extends Node

var current_scene: Control = null
var scene_stack: Array[String] = []
var windows: Dictionary = {}  # String -> Window
var is_transitioning: bool = false

func change_scene(scene_path: String) -> void
func push_scene(scene_path: String) -> void
func pop_scene() -> void
func show_window(window_name: String) -> void
func hide_window(window_name: String) -> void
func show_notification(text: String, duration: float = 3.0) -> void
func show_confirm_dialog(text: String, callback: Callable) -> void
```

### 3. Theme System
- Base theme with consistent colors, fonts, margins
- Style variations for different UI states
- Custom styles for specific components
- Support for theme switching (future dark mode)

### 4. Responsive Layout
```gdscript
# Anchor presets for common layouts
# Margin containers for consistent spacing
# Grid containers for creature displays
# Scroll containers for lists
# Size flags for flexible layouts
```

### 5. Input Handling
```gdscript
# Keyboard navigation
ui_focus_next: Tab
ui_focus_prev: Shift+Tab
ui_accept: Space/Enter
ui_cancel: Escape

# Quick actions
quick_save: Ctrl+S
quick_load: Ctrl+L
toggle_fullscreen: F11
```

## Performance Requirements
- Scene transitions < 100ms
- UI updates < 16ms per frame
- Smooth animations at 60 FPS
- Efficient texture atlasing
- Object pooling for dynamic elements