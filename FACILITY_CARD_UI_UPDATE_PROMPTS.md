# Facility Card UI Update Prompts

This document contains self-contained prompts for updating the facility card UI system to remove the assignment dialog and improve the food/activity selection interface.

## Execution Order

**Parallel execution:**
- Prompt 1 & 2 can run simultaneously in separate windows

**Sequential execution:**
- Prompt 3 should run AFTER prompts 1 & 2 are complete
- Prompt 4 should run AFTER prompt 3 is complete

---

## Prompt 1: Food Button UI Update (Can run in parallel)

```
Task: Update the facility card food button to show current food icon and open a food selection grid when clicked.

Context:
- Facility card is at scripts/ui/facility_card.gd and scenes/ui/components/facility_card.tscn
- Food button node path: Background/VBoxContainer/HBoxContainer/Food
- ItemManager system provides food items via GameCore.get_system("item_manager")
- Current implementation loads food icons in _load_food_icon() method
- Food items have icon_path property for their textures

Requirements:
1. Make food button always display the current selected food icon (not just when assigned)
2. Add a food selection popup window that opens when food button is clicked
3. The popup should show a grid of available food items from inventory
4. Each food item in grid should show icon and name
5. Clicking a food item should select it and close the popup
6. Update the facility assignment data with the new food selection
7. The food icon on the button should immediately update to show the new selection

Files to modify:
- scripts/ui/facility_card.gd
- scenes/ui/components/facility_card.tscn (if needed for popup)
- May need to create a new food_selection_popup.tscn

Use existing patterns from ItemManager for getting food items:
item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)

Follow project conventions in CLAUDE.md:
- Use GameCore.get_system() for system access
- Typed arrays like Array[ItemResource]
- Use SignalBus for events
- No silent fallbacks - use push_error and return on failures
```

---

## Prompt 2: Activity Button UI Update (Can run in parallel)

```
Task: Update the facility card activity button to show current activity icon and open an activity selection panel when clicked.

Context:
- Facility card is at scripts/ui/facility_card.gd and scenes/ui/components/facility_card.tscn
- Activity button node path: Background/VBoxContainer/HBoxContainer/Activity
- Activities are defined by facility type in FacilityResource
- Current implementation uses _get_activity_color() for activity visualization
- GlobalEnums.TrainingActivity defines activity types

Requirements:
1. Make activity button always display an icon representing the current selected activity
2. Add an activity selection popup that opens when activity button is clicked
3. The popup should show available activities for the specific facility type
4. Each activity option should show an icon/color and activity name
5. Clicking an activity should select it and close the popup
6. Update the facility assignment data with the new activity selection
7. The activity icon on the button should immediately update to show the new selection

Files to modify:
- scripts/ui/facility_card.gd
- scenes/ui/components/facility_card.tscn (if needed for popup)
- May need to create a new activity_selection_popup.tscn

Activity types from GlobalEnums.TrainingActivity:
- PHYSICAL (0), AGILITY (1), MENTAL (2), DISCIPLINE (3)

Follow project conventions in CLAUDE.md:
- Use GameCore.get_system() for system access
- Typed arrays
- Use SignalBus for events
- No silent fallbacks - use push_error and return on failures
```

---

## Prompt 3: Remove Assignment Dialog Dependency (Run AFTER prompts 1 & 2 complete)

```
Task: Remove the facility assignment dialog since creature assignment is now done via drag-drop only.

Context:
- Assignment dialog at scripts/ui/facility_assignment_dialog_controller.gd
- Dialog scene at scenes/ui/facility_assignment_dialog.tscn
- Facility card currently emits assign_pressed signal that triggers dialog
- Drag-drop now handles creature assignment directly to facility cards
- Food and activity selection now handled by buttons on facility card (from Prompts 1 & 2)

Requirements:
1. Remove the "Assign" button from facility cards (keep "Remove" button)
2. Update facility_card.gd to NOT emit assign_pressed signal
3. Remove references to assignment dialog from facility_view_controller.gd
4. Clean up any dialog-related methods in facility_card.gd
5. Ensure drag-drop creates assignment directly without dialog
6. When creature is dropped on facility, it should:
   - Create assignment with default food/activity if not set
   - Or use currently selected food/activity from the buttons

Files to modify:
- scripts/ui/facility_card.gd (remove assign button, dialog references)
- scripts/ui/facility_view_controller.gd (remove dialog handling)
- scenes/ui/components/facility_card.tscn (remove assign button)

Files that can potentially be deleted (verify no other dependencies first):
- scripts/ui/facility_assignment_dialog_controller.gd
- scenes/ui/facility_assignment_dialog.tscn

Follow project conventions in CLAUDE.md:
- Use GameCore.get_system() for system access
- Use SignalBus for events
- Fail-fast principle with push_error
```

---

## Prompt 4: Finalize Drag-Drop Integration (Run AFTER prompt 3 complete)

```
Task: Finalize drag-drop integration to work with the new food/activity selection system.

Context:
- Creature entities can be dragged from anywhere
- Facility cards accept dropped creatures via _drop_data()
- Food and activity are now selected via buttons on the facility card (from Prompts 1 & 2)
- No assignment dialog anymore (removed in Prompt 3)
- FacilitySystem manages assignments via GameCore.get_system("facility")

Requirements:
1. Update _drop_data() in facility_card.gd to:
   - Create assignment immediately when creature is dropped
   - Use currently selected food/activity from the buttons
   - Use sensible defaults if food/activity not yet selected
   - Call FacilitySystem.assign_creature_to_facility() directly
2. Add visual feedback during drag:
   - Highlight valid drop targets (unlocked, unoccupied facilities)
   - Show different highlight for invalid targets
   - Use modulate or scale animations for feedback
3. Update facility assignment creation to use FacilitySystem directly
4. Ensure proper signals are emitted for assignment creation via SignalBus
5. Handle edge cases:
   - Dropping on occupied facility (should reject)
   - Dropping on locked facility (should reject)
   - No food/activity selected (use first available defaults)
6. Verify creature entity returns to idle state after successful drop

Files to modify:
- scripts/ui/facility_card.gd (update _drop_data, add feedback)
- May need to update facility_view_controller.gd for coordination

Ensure compatibility with creature entity drag state machine at:
- scripts/entities/creature_entity_controller.gd
- scripts/entities/creature_entity_dragging_state.gd

Follow project conventions in CLAUDE.md:
- Use GameCore.get_system() for system access
- Use SignalBus for all events
- Fail-fast with push_error on failures
- Typed arrays for all collections
```

---

## Testing After Implementation

After all prompts are complete, test the following flow:

1. Run: `godot --check-only project.godot`
2. Run: `godot --headless --scene tests/preflight_check.tscn`
3. Manual test in editor:
   - Drag creature to facility card
   - Click food button and select different food
   - Click activity button and select different activity
   - Verify assignment is created with correct settings
   - Verify "Remove" button still works
   - Verify locked facilities reject drops
   - Verify occupied facilities reject drops