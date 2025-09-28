# New Game Start Implementation - Parallel Prompts

These prompts can be run in parallel using different Sonnet instances. Each prompt is self-contained with all necessary context.

## Prompt 1: Starter Popup Implementation (Can run in parallel)

```
You are working on a Godot 4 project. Create a starter popup that shows when a new game begins.

CONTEXT:
- Main scene: scenes/main/main.tscn
- Overlay menu: scenes/ui/overlay_menu.tscn (main game UI)
- Game controller: scripts/controllers/game_controller.gd
- Signal bus: scripts/core/signal_bus.gd
- Resource tracker: scripts/systems/resource_tracker.gd
- Collection system: scripts/systems/player_collection.gd

REQUIREMENTS:
1. Create a new popup scene: scenes/ui/starter_popup.tscn
2. Create controller: scripts/ui/starter_popup_controller.gd
3. Popup should display:
   - "Welcome to [Game Name]!" header
   - Starter creature with animated sprite (use placeholder AnimatedSprite2D)
   - Creature name below sprite
   - Food item with icon (x5 quantity)
   - Gold amount (500g)
   - "Start Adventure" button to close
4. Add to SignalBus: signal new_game_started()
5. Trigger popup when new_game_started signal fires
6. When closed, emit signal: starter_popup_closed

GODOT SCENE STRUCTURE:
StarterPopup (Control)
├── Panel
│   ├── MarginContainer
│   │   ├── VBoxContainer
│   │   │   ├── Title (Label: "Welcome!")
│   │   │   ├── HSeparator
│   │   │   ├── CreatureContainer (HBoxContainer)
│   │   │   │   ├── CreatureSprite (AnimatedSprite2D)
│   │   │   │   └── CreatureName (Label)
│   │   │   ├── ItemsContainer (HBoxContainer)
│   │   │   │   ├── FoodIcon (TextureRect)
│   │   │   │   ├── FoodLabel (Label: "x5")
│   │   │   │   ├── VSeparator
│   │   │   │   ├── GoldIcon (TextureRect)
│   │   │   │   └── GoldLabel (Label: "500g")
│   │   │   └── StartButton (Button: "Start Adventure")

Files to create:
- scenes/ui/starter_popup.tscn
- scripts/ui/starter_popup_controller.gd

Files to modify:
- scripts/core/signal_bus.gd (add signals)
- scripts/ui/overlay_menu_controller.gd (connect to show popup)
```

## Prompt 2: UI Visibility Changes (Can run in parallel)

```
You are working on a Godot 4 project. Modify the overlay menu to initially show only the top bar (gold and time) with other UI elements hidden until the player completes the tutorial.

CONTEXT:
- Overlay menu scene: scenes/ui/overlay_menu.tscn
- Controller: scripts/ui/overlay_menu_controller.gd
- Signal bus: scripts/core/signal_bus.gd
- Main game area shows facility_view.tscn by default

REQUIREMENTS:
1. In overlay_menu.tscn, hide navigation buttons initially:
   - Facilities, Shop, Inventory, Stable, Menu buttons
2. Add tutorial state tracking to overlay_menu_controller.gd:
   - var tutorial_completed: bool = false
   - Function to show/hide navigation based on state
3. Keep visible initially:
   - Top panel with Date and Gold labels
   - GameArea (for facility view)
4. Add to SignalBus: signal tutorial_completed()
5. When tutorial_completed signal fires, show all navigation buttons
6. Save tutorial state so it persists between sessions

Files to modify:
- scenes/ui/overlay_menu.tscn (set buttons visible = false)
- scripts/ui/overlay_menu_controller.gd (add tutorial logic)
- scripts/core/signal_bus.gd (add signal)

IMPLEMENTATION NOTES:
- Use button.visible = false/true for hiding/showing
- Connect to starter_popup_closed signal to begin tutorial
- Store tutorial state in SaveSystem for persistence
```

## Prompt 3: Creature Sprite Movement System (Can run in parallel)

```
You are working on a Godot 4 project. Create a creature sprite movement system for the facility view.

CONTEXT:
- Facility view: scenes/ui/facility_view.tscn
- Controller: scripts/ui/facility_view_controller.gd
- Facility system: scripts/systems/facility_system.gd
- Collection system: scripts/systems/player_collection.gd

REQUIREMENTS:
1. Add creature sprite area to facility_view.tscn:
   - Create CreatureArea (Control) in bottom half of screen
   - Add CreatureSprite2D (AnimatedSprite2D) as child
2. Implement creature movement:
   - Random walk pattern when not in facility
   - Move to facility position when assigned
   - Smooth movement with lerp
   - Face movement direction (flip sprite)
3. Create scripts/ui/creature_sprite_controller.gd:
   - Handle movement logic
   - Connect to facility assignment signals
   - Animate idle/walk states
4. Visual feedback when creature enters facility:
   - Sprite moves to facility card position
   - Show training animation/particles
5. Support multiple creatures (future-proofing)

MOVEMENT LOGIC:
```gdscript
# Random walk when idle
var wander_target: Vector2
var wander_timer: float = 0.0

func _process(delta):
    if not in_facility:
        wander_timer -= delta
        if wander_timer <= 0:
            set_random_wander_target()
            wander_timer = randf_range(2.0, 4.0)

        position = position.lerp(wander_target, delta * 2.0)
        sprite.flip_h = (wander_target.x < position.x)
```

Files to create:
- scripts/ui/creature_sprite_controller.gd

Files to modify:
- scenes/ui/facility_view.tscn (add CreatureArea)
- scripts/ui/facility_view_controller.gd (integrate sprites)
```

## Prompt 4: Next Week Button Logic (Can run in parallel)

```
You are working on a Godot 4 project. Implement the "Next Week" button that appears in facility view and is disabled until tutorial conditions are met.

CONTEXT:
- Facility view: scenes/ui/facility_view.tscn
- Time system: scripts/systems/time_system.gd
- Training system: scripts/systems/training_system.gd
- Food system: scripts/systems/food_system.gd
- Signal bus: scripts/core/signal_bus.gd

REQUIREMENTS:
1. Add "Next Week" button to facility_view.tscn:
   - Position: bottom right corner
   - Initially disabled (greyed out)
   - Shows tooltip explaining requirements
2. Enable button when ALL conditions met:
   - At least one creature assigned to training facility
   - Food type selected for training
   - Player has interacted with facility system
3. Button tooltip should dynamically update:
   - "Assign a creature to training" (if no assignment)
   - "Select food for training" (if no food selected)
   - "Click to advance time" (when ready)
4. When clicked:
   - Advance week via time_system
   - Show week progression feedback
   - Update all UI elements
5. After first week advance:
   - Emit tutorial_completed signal
   - Keep button always visible

BUTTON STATES:
```gdscript
func update_next_week_button():
    var can_advance = check_tutorial_conditions()
    next_week_button.disabled = not can_advance

    if not has_creature_assigned:
        next_week_button.tooltip_text = "Assign a creature to training first"
    elif not has_food_selected:
        next_week_button.tooltip_text = "Select training food"
    else:
        next_week_button.tooltip_text = "Click to advance to next week"
```

Files to modify:
- scenes/ui/facility_view.tscn (add NextWeekButton)
- scripts/ui/facility_view_controller.gd (add button logic)
- scripts/core/signal_bus.gd (if needed)
```

## Prompt 5: Game Initialization Flow (Run AFTER others complete)

```
You are working on a Godot 4 project. Wire together the new game initialization flow using the components created by other prompts.

CONTEXT:
- Game controller: scripts/controllers/game_controller.gd
- Main controller: scripts/controllers/main_controller.gd
- Save system: scripts/systems/save_system.gd
- Collection system: scripts/systems/player_collection.gd
- Resource tracker: scripts/systems/resource_tracker.gd

REQUIREMENTS:
1. Modify game initialization to detect new game:
   - Check if save exists
   - If new game, trigger special flow
2. New game flow sequence:
   - Create starter creature (use existing generator)
   - Add 5 training food items
   - Set gold to 500
   - Emit new_game_started signal
   - Show starter popup
   - Initialize tutorial state
3. Add starter creature generation:
   - Species: "Wolf" or similar basic creature
   - Level 1 with base stats
   - Add to player collection
4. Initialize resources:
   - 500 gold via resource_tracker
   - 5 power_bar food items
5. Ensure systems initialize in correct order

INITIALIZATION SEQUENCE:
```gdscript
func start_new_game():
    # 1. Generate starter creature
    var starter = generate_starter_creature()
    collection_system.add_creature(starter)

    # 2. Add starter resources
    resource_tracker.set_balance(500)
    resource_tracker.add_item("power_bar", 5)

    # 3. Initialize tutorial
    signal_bus.new_game_started.emit()

    # 4. Save initial state
    save_system.save_game_state("autosave")
```

Files to modify:
- scripts/controllers/game_controller.gd
- scripts/controllers/main_controller.gd
- Potentially others based on discoveries
```

## Execution Notes

**Can run in parallel (Prompts 1-4):**
- Each handles a separate UI component
- No file conflicts between them
- All can be developed simultaneously

**Must run after others (Prompt 5):**
- Integrates components from prompts 1-4
- Requires their signals and systems to exist

**Testing sequence after all complete:**
1. Delete any existing save files
2. Run: `godot --scene scenes/main/main.tscn`
3. Verify starter popup appears
4. Check only top bar visible initially
5. Confirm creature sprite animates in facility view
6. Test facility assignment enables Next Week button
7. Advance week and verify tutorial completion
```