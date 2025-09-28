# UI Components API Reference

## Overview

UI Components are reusable interface elements that provide consistent functionality and appearance throughout the game. They handle creature display, facility management, user interaction, notifications, and data visualization.

## Core UI Components

### CreatureCard (`scripts/ui/creature_card.gd`)

Displays creature information in a card format with drag-and-drop support.

#### Properties
```gdscript
@export var creature_data: CreatureData  # Creature to display
@export var slot_index: int = -1         # Position in roster
@export var is_active_slot: bool = true  # Active vs stable slot
@export var is_empty_slot: bool = false  # Show as empty

# UI Elements
portrait: TextureRect          # Creature image
name_label: Label             # Creature name
level_label: Label            # Level display
species_label: Label          # Species name
stamina_bar: ProgressBar      # Stamina indicator
empty_slot_label: Label       # Empty slot text
```

#### Signals
```gdscript
signal dragged(creature: CreatureData, card: CreatureCard)
signal dropped(creature: CreatureData, slot: int)
signal clicked(creature: CreatureData)
signal hovered(creature: CreatureData)
signal context_menu_requested(creature: CreatureData, position: Vector2)
```

#### Methods
```gdscript
set_creature(creature: CreatureData) -> void
# Update displayed creature

set_empty(show_text: bool = true) -> void
# Show as empty slot

highlight(enabled: bool) -> void
# Visual highlight effect

set_draggable(enabled: bool) -> void
# Enable/disable drag functionality

update_stamina_display() -> void
# Refresh stamina bar

show_tooltip() -> void
# Display creature details tooltip
```

#### Usage Example
```gdscript
# Create creature card
var card_scene = preload("res://scenes/ui/components/creature_card.tscn")
var card = card_scene.instantiate()

# Configure card
card.creature_data = my_creature
card.slot_index = 0
card.is_active_slot = true

# Connect signals
card.clicked.connect(_on_creature_clicked)
card.dragged.connect(_on_creature_dragged)

# Add to UI
roster_container.add_child(card)
```

### CreatureListItem (`scripts/ui/creature_list_item.gd`)

Compact list view of creature information.

#### Properties
```gdscript
@export var creature_data: CreatureData
@export var show_stats: bool = true
@export var show_tags: bool = false
@export var selectable: bool = true

# Display Elements
icon: TextureRect
name_label: Label
species_label: Label
age_label: Label
stats_container: HBoxContainer
tags_container: HBoxContainer
selection_highlight: Panel
```

#### Signals
```gdscript
signal selected(creature: CreatureData)
signal deselected(creature: CreatureData)
signal double_clicked(creature: CreatureData)
signal action_requested(creature: CreatureData, action: String)
```

#### Methods
```gdscript
set_selected(selected: bool) -> void
# Update selection state

update_display() -> void
# Refresh all displayed info

set_compact_mode(compact: bool) -> void
# Toggle between full and compact display

add_action_button(text: String, action: String) -> void
# Add custom action button
```

### NotificationPopup (`scripts/ui/notification_popup.gd`)

Temporary popup messages with auto-dismiss.

#### Properties
```gdscript
@export var duration: float = 3.0        # Display time
@export var fade_time: float = 0.5       # Fade animation
@export var popup_type: PopupType        # Visual style

enum PopupType {
    INFO,
    SUCCESS,
    WARNING,
    ERROR,
    ACHIEVEMENT
}

# Components
icon: TextureRect
title_label: Label
message_label: RichTextLabel
progress_bar: ProgressBar  # Optional
```

#### Methods
```gdscript
show_message(text: String, type: PopupType = PopupType.INFO) -> void
# Display simple message

show_notification(data: NotificationData) -> void
# Display complex notification

set_progress(value: float) -> void
# Update progress bar (0.0 to 1.0)

dismiss() -> void
# Close immediately

queue_dismiss() -> void
# Start auto-dismiss timer
```

#### Usage Example
```gdscript
# Simple notification
var popup = preload("res://scenes/ui/components/notification_popup.tscn").instantiate()
popup.show_message("Creature acquired!", NotificationPopup.PopupType.SUCCESS)
get_tree().current_scene.add_child(popup)

# Complex notification
var notification = NotificationData.new()
notification.title = "Achievement Unlocked"
notification.message = "Collected 10 creatures!"
notification.icon = preload("res://assets/icons/achievement.png")
notification.type = NotificationPopup.PopupType.ACHIEVEMENT
popup.show_notification(notification)
```

### CreatureDragPreview (`scripts/ui/creature_drag_preview.gd`)

Visual feedback during drag-and-drop operations.

#### Properties
```gdscript
@export var creature_data: CreatureData
@export var opacity: float = 0.7
@export var scale_factor: float = 0.8

# Visual Elements
preview_container: Control
creature_icon: TextureRect
name_label: Label
invalid_overlay: ColorRect  # Red overlay for invalid drops
```

#### Methods
```gdscript
setup_preview(creature: CreatureData) -> void
# Initialize preview with creature data

set_valid_drop(valid: bool) -> void
# Update visual state for drop validity

follow_mouse() -> void
# Update position to follow cursor

show_at_position(pos: Vector2) -> void
# Display at specific position
```

## Collection UI Components

### CollectionPanel (`scripts/ui/collection_panel.gd`)

Main panel for creature collection management.

#### Properties
```gdscript
# Display Settings
@export var display_mode: DisplayMode = DisplayMode.GRID
@export var items_per_row: int = 4
@export var show_filters: bool = true

enum DisplayMode {
    GRID,
    LIST,
    DETAILS
}

# Components
filter_bar: Control
sort_dropdown: OptionButton
search_field: LineEdit
creature_container: Container
pagination_bar: HBoxContainer
```

#### Methods
```gdscript
refresh_display() -> void
# Reload and display creatures

apply_filter(filter: Dictionary) -> void
# Apply display filter

set_display_mode(mode: DisplayMode) -> void
# Change view mode

get_selected_creatures() -> Array[CreatureData]
# Get currently selected creatures

perform_batch_action(action: String, creature_ids: Array) -> void
# Execute action on multiple creatures
```

### FilterBar (`scripts/ui/components/filter_bar.gd`)

Filtering controls for creature lists.

#### Properties
```gdscript
# Filter Options
species_filter: OptionButton
age_range: RangeSlider
tag_filter: ItemList
rarity_checkboxes: Array[CheckBox]
stat_filters: Dictionary  # stat_name -> RangeSlider

# Current Filter
active_filters: Dictionary = {
    "species": [],
    "age_min": 0,
    "age_max": 999,
    "tags": [],
    "rarities": [],
    "stats": {}
}
```

#### Signals
```gdscript
signal filter_changed(filters: Dictionary)
signal filter_cleared()
signal preset_selected(preset_name: String)
```

#### Methods
```gdscript
get_active_filters() -> Dictionary
# Get current filter configuration

clear_filters() -> void
# Reset all filters

save_preset(name: String) -> void
# Save current filter as preset

load_preset(name: String) -> void
# Load saved filter preset

apply_quick_filter(type: String) -> void
# Apply common filter (e.g., "young", "strong")
```

## Window Components

### ShopWindow (`scripts/ui/windows/shop_window.gd`)

In-game shop interface.

#### Components
```gdscript
# Layout
item_grid: GridContainer      # Shop inventory
details_panel: Panel          # Selected item details
purchase_button: Button       # Buy button
player_gold_label: Label      # Player currency
cart: ItemList               # Shopping cart

# Item Display
item_cards: Array[ShopItemCard]
selected_item: ItemResource
```

#### Methods
```gdscript
refresh_shop_inventory() -> void
# Update displayed items

set_shop_data(inventory: Array[ItemResource]) -> void
# Load shop inventory

purchase_item(item: ItemResource, quantity: int = 1) -> bool
# Process purchase

add_to_cart(item: ItemResource) -> void
# Add item to cart

checkout() -> bool
# Purchase all cart items
```

### QuestWindow (`scripts/ui/windows/quest_window.gd`)

Quest management interface.

#### Components
```gdscript
# Quest Lists
active_quests: ItemList
available_quests: ItemList
completed_quests: ItemList

# Quest Details
quest_name: Label
quest_description: RichTextLabel
objectives_list: ItemList
rewards_panel: GridContainer
accept_button: Button
abandon_button: Button
```

#### Methods
```gdscript
refresh_quests() -> void
# Update all quest lists

show_quest_details(quest_id: String) -> void
# Display quest information

accept_quest(quest_id: String) -> bool
# Accept available quest

abandon_quest(quest_id: String) -> bool
# Abandon active quest

claim_rewards(quest_id: String) -> void
# Claim quest completion rewards
```

## Utility Components

### StatBar (`scripts/ui/components/stat_bar.gd`)

Visual representation of creature statistics.

#### Properties
```gdscript
@export var stat_name: String = "health"
@export var max_value: float = 100.0
@export var current_value: float = 100.0
@export var show_text: bool = true
@export var bar_color: Color = Color.GREEN

# Components
progress_bar: ProgressBar
label: Label
icon: TextureRect
```

#### Methods
```gdscript
set_values(current: float, maximum: float) -> void
# Update displayed values

animate_change(new_value: float, duration: float = 0.5) -> void
# Animate value change

set_color_by_percentage() -> void
# Auto-color based on percentage (green->yellow->red)
```

### FacilityCard (`scripts/ui/facility_card.gd`)

Displays facility information and assignment status in a card format for training facility management.

#### Properties
```gdscript
var facility_resource: FacilityResource      # Facility configuration
var current_assignment: FacilityAssignmentData  # Current assignment (null if empty)

# UI Elements
@onready var background: PanelContainer      # Card background
@onready var facility_icon: TextureRect      # Facility icon (64x64)
@onready var facility_name: Label           # Facility display name
@onready var creature_portrait: TextureRect  # Assigned creature portrait
@onready var empty_portrait_label: Label    # "Empty" text when unassigned
@onready var activity_icon: TextureRect     # Training activity icon
@onready var activity_label: Label          # Activity name
@onready var food_icon: TextureRect         # Required food icon
@onready var food_label: Label              # Food type name
@onready var action_button: Button          # "Assign"/"Remove" button
@onready var lock_overlay: ColorRect        # Lock state overlay
@onready var cost_label: Label              # Unlock cost display
@onready var unlock_button: Button          # Unlock facility button
@onready var no_food_warning: ColorRect     # Food shortage warning
```

#### Signals
```gdscript
signal assign_pressed(facility_id: String)   # Request creature assignment
signal remove_pressed(facility_id: String)   # Request creature removal
signal unlock_pressed(facility_id: String)   # Request facility unlock
```

#### Methods
```gdscript
set_facility(facility: FacilityResource) -> void
# Update displayed facility and reset assignment

set_assignment(assignment: FacilityAssignmentData) -> void
# Update assignment information and creature display

update_display() -> void
# Refresh all UI elements based on current state

set_food_warning(has_warning: bool) -> void
# Enable/disable food shortage warning animation

get_facility_id() -> String
# Get the facility ID for this card

is_locked() -> bool
# Check if facility is currently locked

is_assigned() -> bool
# Check if facility has a creature assigned
```

#### Visual States
- **Locked**: Grayed out with lock overlay showing unlock cost
- **Empty**: Normal colors, shows "Assign" button and "Empty" placeholder
- **Occupied**: Shows creature portrait, activity, and food information with "Remove" button
- **No Food Warning**: Animated red border when required food is missing

#### Usage Example
```gdscript
# Create facility card
var card_scene = preload("res://scenes/ui/components/facility_card.tscn")
var card = card_scene.instantiate()

# Configure facility
var facility = facility_system.get_facility("training_ground_01")
card.set_facility(facility)

# Set assignment if creature is assigned
var assignment = facility_system.get_assignment("training_ground_01")
if assignment:
    card.set_assignment(assignment)

# Connect signals
card.assign_pressed.connect(_on_assign_facility)
card.remove_pressed.connect(_on_remove_from_facility)
card.unlock_pressed.connect(_on_unlock_facility)

# Add to facility grid
facility_grid.add_child(card)
```

## Facility Management Components

### FacilityView (`scripts/ui/facility_view_controller.gd`)

Main facility management interface that displays all training facilities in a grid layout and handles facility interactions.

#### Properties
```gdscript
var facility_system: Node                    # FacilitySystem reference
var resource_tracker: Node                  # ResourceTracker reference
var signal_bus: Node                        # SignalBus reference
var facility_cards: Array[Control] = []     # Array of facility card instances

# UI Elements
@onready var facility_grid: GridContainer   # Grid for facility cards
@onready var warning_container: HBoxContainer  # Week advance warnings
@onready var warning_label: Label           # Warning message text
@onready var processing_label: Label        # Week processing indicator
@onready var notification_panel: PanelContainer  # User feedback popup
@onready var notification_label: Label      # Notification message
```

#### Key Methods
```gdscript
refresh_facilities() -> void
# Update all facility cards with current state and assignments

_on_assign_pressed(facility_id: String) -> void
# Handle creature assignment requests (emits facility_assignment_requested signal)

_on_remove_pressed(facility_id: String) -> void
# Remove creature from facility via FacilitySystem.unassign_creature()

_on_unlock_pressed(facility_id: String) -> void
# Check costs and unlock facility via FacilitySystem.unlock_facility()

has_food_warnings() -> bool
# Check if any assigned facilities are missing required food

_check_food_warnings() -> void
# Update warning display based on food availability
```

#### Signal Handling
```gdscript
# Facility Events
_on_facility_unlocked(facility_id: String) -> void
_on_facility_assigned(facility_id: String, creature_id: String) -> void
_on_facility_unassigned(facility_id: String, creature_id: String) -> void

# Resource Events
_on_gold_changed(new_amount: int) -> void

# Week Advance Events
_on_week_advance_started() -> void
_on_week_advance_completed() -> void
_on_week_advance_blocked(reason: String, missing_food_facilities: Array[String]) -> void
```

#### Visual Features
- **Dynamic Grid Layout**: Automatically adjusts column count based on facility count
- **Week Advance Warnings**: Shows warning when facilities lack required food
- **Processing Indicator**: Displays "Processing week advance..." during operations
- **Notification System**: Shows feedback for unlock results and errors
- **Food Warning Highlighting**: Highlights facilities missing food with animated borders

#### Usage Example
```gdscript
# Create facility view (typically done in main UI)
var facility_view = preload("res://scenes/ui/facility_view.tscn").instantiate()

# Connect to assignment requests (handled by UI manager or game controller)
var signal_bus = GameCore.get_signal_bus()
if signal_bus.has_signal("facility_assignment_requested"):
    signal_bus.facility_assignment_requested.connect(_on_assignment_requested)

# Add to main game area
main_content_area.add_child(facility_view)

func _on_assignment_requested(facility_id: String):
    # Open creature selection dialog
    open_creature_selection_for_facility(facility_id)
```

### TooltipPanel (`scripts/ui/components/tooltip_panel.gd`)

Rich tooltip display system.

#### Properties
```gdscript
@export var follow_mouse: bool = true
@export var offset: Vector2 = Vector2(10, 10)
@export var max_width: float = 300.0

# Content
title: Label
description: RichTextLabel
stats_grid: GridContainer
tags_container: HFlowContainer
```

#### Methods
```gdscript
show_creature_tooltip(creature: CreatureData) -> void
# Display creature information

show_item_tooltip(item: ItemResource) -> void
# Display item information

show_custom_tooltip(data: Dictionary) -> void
# Display custom content

position_near_mouse() -> void
# Update position relative to cursor
```

## Theme and Styling

### UI Theme Configuration

```gdscript
# Theme Resource: resources/themes/default_theme.tres

# Color Palette
const PRIMARY_COLOR = Color("#2E86AB")
const SECONDARY_COLOR = Color("#A23B72")
const SUCCESS_COLOR = Color("#73AB84")
const WARNING_COLOR = Color("#F18F01")
const ERROR_COLOR = Color("#C73E1D")

# Font Sizes
const FONT_SIZE_SMALL = 12
const FONT_SIZE_NORMAL = 14
const FONT_SIZE_LARGE = 18
const FONT_SIZE_TITLE = 24

# Spacing
const MARGIN_SMALL = 4
const MARGIN_NORMAL = 8
const MARGIN_LARGE = 16
```

### Custom Styling
```gdscript
# Apply custom style to component
func apply_custom_style(component: Control):
    var style = StyleBoxFlat.new()
    style.bg_color = PRIMARY_COLOR
    style.corner_radius_all = 4
    style.content_margin_all = MARGIN_NORMAL
    component.add_theme_stylebox_override("panel", style)
```

## Animation Helpers

### UI Animation Utils
```gdscript
# Fade in/out
func fade_in(control: Control, duration: float = 0.3):
    var tween = create_tween()
    control.modulate.a = 0.0
    control.show()
    tween.tween_property(control, "modulate:a", 1.0, duration)

# Scale bounce
func bounce_scale(control: Control, scale: float = 1.2):
    var tween = create_tween()
    tween.tween_property(control, "scale", Vector2(scale, scale), 0.1)
    tween.tween_property(control, "scale", Vector2.ONE, 0.2)

# Slide in
func slide_in(control: Control, direction: Vector2, distance: float = 100):
    var tween = create_tween()
    var start_pos = control.position
    control.position = start_pos + direction * distance
    tween.tween_property(control, "position", start_pos, 0.3)
```

## Responsive Design

### Screen Size Adaptation
```gdscript
# Component scaling
func adapt_to_screen_size():
    var viewport_size = get_viewport().size

    if viewport_size.x < 1280:
        # Small screen adjustments
        items_per_row = 3
        font_size = FONT_SIZE_SMALL
    elif viewport_size.x > 1920:
        # Large screen adjustments
        items_per_row = 6
        font_size = FONT_SIZE_LARGE

# Responsive containers
func setup_responsive_grid(container: GridContainer):
    var screen_width = get_viewport().size.x
    var item_width = 200
    var columns = max(1, int(screen_width / item_width))
    container.columns = columns
```

## Performance Optimization

### UI Update Batching
```gdscript
# Batch multiple UI updates
class_name UIUpdateBatcher

var pending_updates: Array = []
var update_timer: Timer

func queue_update(callable: Callable):
    pending_updates.append(callable)
    if not update_timer.is_stopped():
        update_timer.start(0.016)  # Next frame

func _on_timer_timeout():
    for update in pending_updates:
        update.call()
    pending_updates.clear()
```

### Object Pooling
```gdscript
# Pool frequently created UI elements
class_name UIObjectPool

var card_pool: Array[CreatureCard] = []
var max_pool_size: int = 50

func get_card() -> CreatureCard:
    if card_pool.is_empty():
        return preload("res://scenes/ui/components/creature_card.tscn").instantiate()
    return card_pool.pop_back()

func return_card(card: CreatureCard):
    if card_pool.size() < max_pool_size:
        card.set_creature(null)
        card.hide()
        card_pool.append(card)
    else:
        card.queue_free()
```

## Accessibility

### Accessibility Features
```gdscript
# Screen reader support
func add_screen_reader_text(control: Control, text: String):
    control.set_meta("screen_reader_text", text)

# Keyboard navigation
func setup_keyboard_navigation(container: Container):
    container.focus_mode = Control.FOCUS_ALL
    container.focus_neighbor_top = NodePath("../previous_element")
    container.focus_neighbor_bottom = NodePath("../next_element")

# High contrast mode
func apply_high_contrast(control: Control):
    var theme = load("res://resources/themes/high_contrast_theme.tres")
    control.theme = theme
```

## Testing UI Components

### UI Testing Patterns
```gdscript
func test_creature_card():
    var card = preload("res://scenes/ui/components/creature_card.tscn").instantiate()
    add_child(card)

    # Test data display
    var creature = create_test_creature()
    card.set_creature(creature)
    assert(card.name_label.text == creature.creature_name)

    # Test signals
    var signal_received = false
    card.clicked.connect(func(c): signal_received = true)
    card._on_gui_input(create_click_event())
    assert(signal_received)

    card.queue_free()
```

## Common Patterns

### Component Factory
```gdscript
class_name UIComponentFactory

static func create_creature_card(creature: CreatureData) -> CreatureCard:
    var card = preload("res://scenes/ui/components/creature_card.tscn").instantiate()
    card.creature_data = creature
    return card

static func create_notification(message: String, type: int) -> NotificationPopup:
    var popup = preload("res://scenes/ui/components/notification_popup.tscn").instantiate()
    popup.show_message(message, type)
    return popup
```

### Event Bus Integration
```gdscript
class_name UIEventBus
extends Node

# UI-specific events
signal ui_refresh_requested()
signal theme_changed(theme_name: String)
signal language_changed(locale: String)

var _instance: UIEventBus

func emit_refresh():
    ui_refresh_requested.emit()

func connect_component(component: Control):
    ui_refresh_requested.connect(component.refresh_display)
    theme_changed.connect(component.apply_theme)
```