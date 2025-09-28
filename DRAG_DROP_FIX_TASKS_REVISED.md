# Drag and Drop Fix Tasks for Animated Creatures (REVISED)

## Context Clarification
The goal is to create a proper creature scene for the **animated sprite creatures** that appear in the bottom panel (CreatureContainer) of the facility view. These creatures need to be draggable onto facility cards. The issue is that the current CreatureSpriteController is an AnimatedSprite2D which doesn't properly handle mouse input for drag and drop.

## Execution Order and Parallelization

### Sequential Tasks (Must be done in order):
1. **Task 1** - Create Creature Entity Scene (FIRST - foundation)
2. **Tasks 2 & 3** - Can run IN PARALLEL after Task 1
3. **Task 4** - Visual Feedback (after Tasks 2 & 3)
4. **Task 5** - Testing (LAST)

---

## Task 1: Create Creature Entity Scene [PRIORITY: CRITICAL]

**Context:**
We need a proper scene for the animated creatures in the facility view's bottom panel. The current `CreatureSpriteController` extends AnimatedSprite2D, which has issues with mouse input detection. We need a Control-based wrapper that contains the animated sprite.

**Requirements:**
1. Create new scene file: `scenes/entities/creature_entity.tscn`
2. Structure:
   ```
   CreatureEntity (Control) - For proper mouse input handling
   └── AnimatedSprite2D - For the creature animation
       └── (Any effects/particles)
   ```
3. Create controller script: `scripts/entities/creature_entity_controller.gd`
4. The controller should:
   - Extend Control (NOT AnimatedSprite2D)
   - Have `creature_data: CreatureData` property
   - Have embedded `AnimatedSprite2D` for animations
   - Implement drag and drop via `_gui_input`
   - Include the state machine functionality from current CreatureSpriteController
   - Properly detect mouse clicks on the sprite area

**Key Implementation:**
```gdscript
extends Control

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var creature_data: CreatureData = null
var is_dragging: bool = false
var drag_offset: Vector2
var state_machine: CreatureStateMachine

func _ready() -> void:
    # Set size to match sprite
    custom_minimum_size = Vector2(64, 64)
    mouse_filter = Control.MOUSE_FILTER_PASS

    # Initialize state machine
    state_machine = CreatureStateMachine.new(self)

func _gui_input(event: InputEvent) -> void:
    if not creature_data:
        return

    if event is InputEventMouseButton:
        var mouse_event = event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT:
            if mouse_event.pressed:
                # Start drag
                is_dragging = true
                drag_offset = global_position - mouse_event.global_position
                get_viewport().set_input_as_handled()
            else:
                # End drag - check for drop target
                if is_dragging:
                    is_dragging = false
                    _handle_drop()

    elif event is InputEventMouseMotion and is_dragging:
        global_position = event.global_position + drag_offset

func set_creature_data(data: CreatureData) -> void:
    creature_data = data
    # Update sprite based on species
```

**File References:**
- Move logic from: `scripts/ui/creature_sprite_controller.gd`
- Reference state machine: `scripts/ui/creature_states/` directory
- Keep animation setup from lines 83-137 of creature_sprite_controller.gd

**Validation:**
- Creature must be clickable and draggable
- State machine must still work (idle, walking, assigned states)
- Must properly receive and store creature_data

---

## Task 2: Update Facility Cards to Accept Drops [CAN PARALLELIZE WITH TASK 3]

**Context:**
Facility cards need to detect when a creature entity is dropped on them and handle the assignment.

**Requirements:**
1. Update `scripts/ui/facility_card.gd` to:
   - Override `_can_drop_data(position, data)` method
   - Override `_drop_data(position, data)` method
   - Check if dropped data contains CreatureData
   - Show visual feedback when creature hovers over
   - Call FacilitySystem to assign the creature

**Implementation:**
```gdscript
# In facility_card.gd

func _can_drop_data(position: Vector2, data: Variant) -> bool:
    if not is_unlocked:
        return false

    # Check if it's creature data
    if data is Dictionary and data.has("creature_data"):
        var creature = data.creature_data
        if creature is CreatureData:
            # Check if facility has room
            return not has_assigned_creature()
    return false

func _drop_data(position: Vector2, data: Variant) -> void:
    if data is Dictionary and data.has("creature_data"):
        var creature = data.creature_data as CreatureData

        # Show assignment dialog or directly assign
        var facility_system = GameCore.get_system("facility")
        # This might open the assignment dialog for food selection
        _show_assignment_dialog_for_creature(creature)

func _notification(what: int) -> void:
    # Visual feedback on drag hover
    if what == NOTIFICATION_DRAG_BEGIN:
        modulate = Color(1.1, 1.1, 1.1)
    elif what == NOTIFICATION_DRAG_END:
        modulate = Color.WHITE
```

**File References:**
- Update: `scripts/ui/facility_card.gd`
- Reference: `scripts/ui/facility_assignment_dialog_controller.gd` for assignment logic
- Use: `scripts/systems/facility_system.gd` for actual assignment

**Validation:**
- Facility cards must detect creature hovering
- Drops must trigger assignment process
- Visual feedback must show valid/invalid drop targets

---

## Task 3: Update Facility View Controller [CAN PARALLELIZE WITH TASK 2]

**Context:**
The facility view controller needs to spawn the new creature entities instead of the old sprite controller, and handle their lifecycle.

**Requirements:**
1. Update `scripts/ui/facility_view_controller.gd`:
   - Replace creature sprite spawning with new entity instantiation
   - Ensure creatures are added to CreatureContainer
   - Connect to assignment/unassignment signals
   - Handle creature removal when assigned
   - Handle creature addition when unassigned

**Code Changes:**
```gdscript
# In facility_view_controller.gd (around line 150-180)

# OLD:
func _spawn_creature_sprites() -> void:
    # Clear existing sprites...
    for creature in unassigned_creatures:
        _spawn_creature_sprite(creature)

func _spawn_creature_sprite(creature: CreatureData) -> void:
    var sprite = AnimatedSprite2D.new()
    # ...

# NEW:
func _spawn_creature_entities() -> void:
    _clear_creature_entities()

    for creature in unassigned_creatures:
        _spawn_creature_entity(creature)

func _spawn_creature_entity(creature: CreatureData) -> void:
    var entity_scene = preload("res://scenes/entities/creature_entity.tscn")
    var entity = entity_scene.instantiate()

    entity.set_creature_data(creature)
    entity.drag_started.connect(_on_creature_drag_started)
    entity.drag_ended.connect(_on_creature_drag_ended)

    creature_container.add_child(entity)
    creature_entities.append(entity)

    # Position randomly in container if needed
    var container_size = creature_container.size
    entity.position = Vector2(
        randf() * container_size.x,
        randf() * container_size.y
    )
```

2. Handle drag data:
```gdscript
func _on_creature_drag_started(creature: CreatureData) -> void:
    # Set drag preview
    Input.set_default_cursor_shape(Input.CURSOR_MOVE)

func _on_creature_drag_ended(creature: CreatureData, dropped: bool) -> void:
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)

    if dropped:
        # Creature was assigned, remove from unassigned list
        _update_creature_display()
```

**File References:**
- Update: `scripts/ui/facility_view_controller.gd:150-200`
- Ensure CreatureContainer in: `scenes/ui/facility_view.tscn`

**Validation:**
- All unassigned creatures appear as draggable entities
- Creatures are removed when assigned
- Creatures reappear when unassigned

---

## Task 4: Implement Proper Drag and Drop System [AFTER TASKS 2 & 3]

**Context:**
The creature entities need to properly communicate with facility cards during drag and drop operations.

**Requirements:**
1. In `scripts/entities/creature_entity_controller.gd`, implement:
   - Proper drag preview creation
   - Detection of drop targets
   - Drag data formatting for Godot's drag/drop system

**Implementation:**
```gdscript
# In creature_entity_controller.gd

func _gui_input(event: InputEvent) -> void:
    if not creature_data:
        return

    if event is InputEventMouseButton:
        var mouse_event = event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT:
            if mouse_event.pressed and not is_dragging:
                _start_drag()
            elif not mouse_event.pressed and is_dragging:
                _end_drag()

func _start_drag() -> void:
    is_dragging = true

    # Create drag preview
    var preview = Control.new()
    var preview_sprite = sprite.duplicate()
    preview.add_child(preview_sprite)
    set_drag_preview(preview)

    # Set drag data
    var drag_data = {
        "creature_data": creature_data,
        "source": self
    }

    # Start Godot's built-in drag
    force_drag(drag_data, preview)

    # Visual feedback
    modulate.a = 0.5

func _end_drag() -> void:
    is_dragging = false
    modulate.a = 1.0

    # Check if dropped on valid target
    var viewport = get_viewport()
    var mouse_pos = viewport.get_mouse_position()

    # Find what's under the mouse
    var space = viewport.world_2d.direct_space_state
    var query = PhysicsPointQueryParameters2D.new()
    query.position = mouse_pos
    var results = space.intersect_point(query)

    # Process drop if on facility
    for result in results:
        if result.collider.has_method("accept_creature"):
            result.collider.accept_creature(creature_data)
            queue_free()  # Remove this entity
            return
```

2. Add proper mouse detection:
```gdscript
func _ready() -> void:
    # Make sure the Control node covers the sprite area
    var sprite_size = Vector2(64, 64) * sprite.scale
    custom_minimum_size = sprite_size
    size = sprite_size

    # Center the sprite within the Control
    sprite.position = sprite_size / 2
```

**File References:**
- Update: `scripts/entities/creature_entity_controller.gd`
- Coordinate with: `scripts/ui/facility_card.gd`

**Validation:**
- Dragging creates visual preview
- Original creature becomes semi-transparent
- Drop detection works accurately
- Successful drops trigger assignment

---

## Task 5: Testing and Integration [FINAL]

**Context:**
Ensure the new creature entity system works with all existing systems.

**Requirements:**
1. Create test: `tests/test_creature_entity.gd`

```gdscript
extends Node

func _ready() -> void:
    print("Testing creature entity system...")

    # Test 1: Entity creation and data assignment
    var entity_scene = preload("res://scenes/entities/creature_entity.tscn")
    var entity = entity_scene.instantiate()

    var creature = CreatureData.new()
    creature.id = "test_1"
    creature.creature_name = "Test Dragon"
    entity.set_creature_data(creature)

    assert(entity.creature_data == creature, "Creature data not set")
    print("✓ Entity accepts creature data")

    # Test 2: Mouse input detection
    var test_event = InputEventMouseButton.new()
    test_event.button_index = MOUSE_BUTTON_LEFT
    test_event.pressed = true
    test_event.position = Vector2(32, 32)  # Center of 64x64 sprite

    entity._gui_input(test_event)
    assert(entity.is_dragging == true, "Drag not started")
    print("✓ Mouse input detected")

    # Test 3: Facility card drop acceptance
    var facility_card = preload("res://scenes/ui/components/facility_card.tscn").instantiate()
    var drag_data = {"creature_data": creature}

    assert(facility_card._can_drop_data(Vector2.ZERO, drag_data), "Drop not accepted")
    print("✓ Facility accepts creature drops")

    # Test 4: Integration with facility system
    var facility_system = GameCore.get_system("facility")
    var collection = GameCore.get_system("collection")

    # Add creature to collection
    collection.add_creature(creature)

    # Assign via facility system
    facility_system.assign_creature("facility_1", creature.id, 0, 0)

    var assignments = facility_system.get_all_assignments()
    var found = false
    for assignment in assignments:
        if assignment.creature_id == creature.id:
            found = true
            break

    assert(found, "Assignment not created")
    print("✓ Facility system integration works")

    print("All creature entity tests passed!")
    get_tree().quit(0)
```

**File References:**
- Create: `tests/test_creature_entity.gd`
- Create scene: `tests/test_creature_entity.tscn`

**Validation:**
Run: `godot --headless --scene tests/test_creature_entity.tscn`

---

## Important Corrections from Original:

1. **Entity vs Card:** We're creating draggable animated creature entities, NOT UI cards
2. **Control Wrapper:** The entity needs a Control node as root to handle mouse input properly
3. **State Machine:** Must preserve the existing state machine functionality for creature behavior
4. **Visual Representation:** Keep the AnimatedSprite2D for visual display, just wrap it in a Control

## Parallel Execution Summary:

**Phase 1:** Task 1 alone (create creature entity scene)
**Phase 2:** Tasks 2 & 3 in parallel (update facility cards & view controller)
**Phase 3:** Task 4 alone (polish drag/drop system)
**Phase 4:** Task 5 alone (testing)

This approach fixes the core issue: AnimatedSprite2D doesn't handle mouse input well, so we wrap it in a Control node that can properly detect clicks and drags while preserving all the animation and state machine functionality.