# Drag and Drop Fix Tasks for Claude Sonnet

## Execution Order and Parallelization

### Sequential Tasks (Must be done in order):
1. **Task 1** - Create Unified Creature Scene (FIRST - foundation for everything else)
2. **Tasks 2 & 3** - Can run IN PARALLEL after Task 1
3. **Task 4** - Visual Feedback (after Tasks 2 & 3 complete)
4. **Task 5** - Testing (LAST - after all others complete)

---

## Task 1: Create a Unified Creature Scene [PRIORITY: CRITICAL]

**Context:**
We need to create a proper creature scene that combines visual representation with drag-and-drop functionality. The current system has `CreatureSpriteController` (AnimatedSprite2D) and `CreatureMiniCard` (Control) working separately, causing issues with drag and drop. The error `[CreatureSprite] No creature data - ignoring input` shows that creature_data is not being properly assigned.

**Requirements:**
1. Create a new scene file: `scenes/ui/components/creature_card.tscn`
2. Root node should be a Control node for proper UI interaction
3. Include these child nodes:
   - PanelContainer (background)
   - TextureRect or AnimatedSprite2D (for creature sprite)
   - Labels for name and age
   - Any visual effects nodes
4. Create corresponding controller script: `scripts/ui/creature_card_controller.gd`
5. The controller should:
   - Extend Control
   - Have a `creature_data: CreatureData` property
   - Implement drag and drop using `_gui_input` and mouse events
   - Have `set_creature_data(data: CreatureData)` method
   - Emit signals: `drag_started`, `drag_ended`, `clicked`
   - Handle visual feedback during drag (opacity, z-index)

**File References:**
- Reference existing mini card: `scripts/ui/creature_mini_card.gd`
- Reference sprite controller for animation: `scripts/ui/creature_sprite_controller.gd`
- Follow patterns in: `scripts/ui/facility_card.gd`

**Validation:**
- Card must properly receive and display creature data
- Mouse events must be properly handled
- Visual feedback during drag must work

**Success Criteria:**
```gdscript
# Test that creature data is properly set
var card = preload("res://scenes/ui/components/creature_card.tscn").instantiate()
var creature = CreatureData.new()
creature.creature_name = "Test"
card.set_creature_data(creature)
assert(card.creature_data == creature)
```

---

## Task 2: Create Drag and Drop Handler Component [CAN PARALLELIZE WITH TASK 3]

**Context:**
The facility view needs to properly handle drag and drop of creatures onto facility cards. Currently, the system isn't detecting drops correctly because the drag/drop logic is split between multiple components.

**Requirements:**
1. Create `scripts/ui/components/drag_drop_handler.gd`
2. This should be a reusable component that can be added to any Control node
3. Implement:
   ```gdscript
   func can_drop_data(position: Vector2, data: Variant) -> bool:
       # Check if data is valid CreatureData
       return data is Dictionary and data.has("creature_data")

   func drop_data(position: Vector2, data: Variant) -> void:
       # Handle the actual drop
       if data is Dictionary and data.has("creature_data"):
           drop_received.emit(data.creature_data)
   ```
4. Update `scripts/ui/facility_card.gd` to:
   - Include the drag/drop handler
   - Accept dropped creatures
   - Show visual feedback when hovering with dragged creature
   - Call facility system to assign creature when dropped

**File References:**
- Update: `scripts/ui/facility_card.gd`
- Reference assignment logic: `scripts/ui/facility_assignment_dialog_controller.gd:150-200`
- Use FacilitySystem: `scripts/systems/facility_system.gd`

**Validation:**
- Facility cards must highlight when creature is dragged over them
- Drops must trigger proper facility assignment
- Invalid drops (wrong creature type, facility full) must be rejected with feedback

**Success Criteria:**
```gdscript
# Facility card accepts valid drops
var facility_card = preload("res://scenes/ui/components/facility_card.tscn").instantiate()
var drag_data = {"creature_data": CreatureData.new()}
assert(facility_card.can_drop_data(Vector2.ZERO, drag_data) == true)
```

---

## Task 3: Update Facility View to Use New Creature Cards [CAN PARALLELIZE WITH TASK 2]

**Context:**
The facility view needs to display unassigned creatures using the new unified creature cards and properly handle their drag/drop interactions. Currently it's trying to use AnimatedSprite2D which doesn't work well with Control-based UI.

**Requirements:**
1. Update `scripts/ui/facility_view_controller.gd` to:
   - Replace creature sprite spawning (lines 150-200) with new creature card instantiation
   - Create creature cards for all unassigned creatures
   - Position them in the CreatureContainer properly
   - Connect drag/drop signals
2. Update `scenes/ui/facility_view.tscn` to:
   - Ensure CreatureContainer has proper layout (HBoxContainer or GridContainer)
   - Set proper mouse filter settings (MOUSE_FILTER_PASS for interaction)
3. Handle creature assignment/unassignment:
   - When dropped on facility, remove from unassigned area
   - When removed from facility, add back to unassigned area
   - Update display immediately on changes

**Code to Replace in facility_view_controller.gd:**
```gdscript
# OLD CODE (around line 150-180):
func _spawn_creature_sprite(creature: CreatureData) -> void:
    var sprite = preload("res://scripts/ui/creature_sprite_controller.gd").new()
    # ...

# NEW CODE:
func _spawn_creature_card(creature: CreatureData) -> void:
    var card = preload("res://scenes/ui/components/creature_card.tscn").instantiate()
    card.set_creature_data(creature)
    card.drag_started.connect(_on_creature_drag_started)
    card.drag_ended.connect(_on_creature_drag_ended)
    creature_container.add_child(card)
```

**File References:**
- Update: `scripts/ui/facility_view_controller.gd:150-200`
- Update scene: `scenes/ui/facility_view.tscn`
- Reference collection system: `scripts/systems/player_collection.gd`

**Validation:**
- All unassigned creatures must appear as draggable cards
- Dragging and dropping must work smoothly
- UI must update immediately when creatures are assigned/unassigned

---

## Task 4: Add Visual Feedback and Polish [AFTER TASKS 2 & 3]

**Context:**
The drag and drop system needs clear visual feedback to be user-friendly. Users need to know what's draggable, where they can drop, and whether actions are valid.

**Requirements:**
1. Add hover effects:
   - Creature cards should highlight on hover (modulate = Color(1.1, 1.1, 1.1))
   - Facility cards should glow/highlight when valid drop target
   - Show "invalid" feedback (red tint) for incompatible drops
2. Add drag ghost/preview:
   - Semi-transparent copy follows mouse during drag
   - Original stays in place but dims (modulate alpha = 0.5)
3. Add drop animations:
   - Smooth transition when creature is assigned (use Tween)
   - Bounce/scale effect on successful drop
   - Return animation if drop is cancelled
4. Add tooltips:
   - Show creature stats on hover
   - Show facility requirements
   - Show why assignment might fail (e.g., "No food available")

**Implementation Example:**
```gdscript
# In creature_card_controller.gd
func _on_mouse_entered() -> void:
    modulate = Color(1.1, 1.1, 1.1)  # Slight highlight

func _on_mouse_exited() -> void:
    if not is_dragging:
        modulate = Color.WHITE

# During drag
func start_drag() -> void:
    var preview = duplicate()
    preview.modulate.a = 0.5
    set_drag_preview(preview)
```

**File References:**
- Add to: `scripts/ui/creature_card_controller.gd`
- Add to: `scripts/ui/facility_card.gd`
- Reference theme: `resources/themes/default_theme.tres`

**Validation:**
- All visual feedback must be smooth and responsive
- Feedback must clearly indicate valid/invalid actions
- Animations must not interfere with functionality

---

## Task 5: Testing and Integration [FINAL - AFTER ALL OTHERS]

**Context:**
Ensure the new drag and drop system works correctly with all existing systems and follows CLAUDE.md invariants.

**Requirements:**
1. Create test scene: `tests/test_drag_and_drop.tscn`
2. Create test script: `tests/test_drag_and_drop.gd`
3. Test script should verify:
   ```gdscript
   extends Node

   func _ready() -> void:
       print("Testing drag and drop system...")

       # Test 1: Creature cards receive data correctly
       var card = preload("res://scenes/ui/components/creature_card.tscn").instantiate()
       var creature = CreatureData.new()
       creature.id = "test_creature_1"
       creature.creature_name = "Test Dragon"
       card.set_creature_data(creature)
       assert(card.creature_data.id == "test_creature_1", "Creature data not set")

       # Test 2: Drag events are properly emitted
       var drag_started = false
       card.drag_started.connect(func(c): drag_started = true)
       card._start_drag()
       assert(drag_started, "Drag started signal not emitted")

       # Test 3: Drop detection works on facility cards
       var facility_card = preload("res://scenes/ui/components/facility_card.tscn").instantiate()
       var drag_data = {"creature_data": creature}
       assert(facility_card.can_drop_data(Vector2.ZERO, drag_data), "Drop not accepted")

       # Test 4: Facility system is called with correct parameters
       var facility_system = GameCore.get_system("facility")
       var assignment_count_before = facility_system.get_all_assignments().size()
       facility_system.assign_creature("facility_1", creature.id, 0, 0)
       var assignment_count_after = facility_system.get_all_assignments().size()
       assert(assignment_count_after > assignment_count_before, "Assignment not created")

       print("All drag and drop tests passed!")
       get_tree().quit(0)
   ```

**Integration checks:**
- Works with save/load system
- Works with weekly updates
- Works with food consumption
- Signals are properly emitted via SignalBus
- Follows CLAUDE.md invariants (no new signal wrappers, proper system access)

**File References:**
- Create: `tests/test_drag_and_drop.gd`
- Create: `tests/test_drag_and_drop.tscn`
- Reference test patterns: `tests/individual/test_facility.tscn`
- Check SignalBus: `scripts/core/signal_bus.gd`

**Validation:**
Run: `godot --headless --scene tests/test_drag_and_drop.tscn`
All tests must pass without errors

---

## Important Notes for Implementation:

1. **CLAUDE.md Compliance:**
   - Use `GameCore.get_system()` for all system access
   - Don't create new signal wrappers - use existing SignalBus
   - Keep property names consistent: `creature_name`, `age_weeks`, etc.
   - All arrays must be typed (e.g., `Array[CreatureData]`)

2. **Performance Considerations:**
   - Drag/drop operations should be < 50ms
   - Use object pooling for frequently created/destroyed cards if needed

3. **Error Handling:**
   - Always check if creature_data exists before using it
   - Use `push_error()` for failures, never silent fallbacks
   - Validate all drops before processing

4. **Debugging:**
   - Keep debug prints minimal but informative
   - Use `print("AI_NOTE: ...")` for important debug messages
   - Remove excessive debug output before completion

## Parallel Execution Summary:

**Phase 1:** Task 1 alone (foundation)
**Phase 2:** Tasks 2 & 3 in parallel (independent systems)
**Phase 3:** Task 4 alone (depends on 2 & 3)
**Phase 4:** Task 5 alone (final validation)

This parallelization can reduce total implementation time by ~30% if two developers work simultaneously on Phase 2.