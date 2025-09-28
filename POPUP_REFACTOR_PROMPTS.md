# Popup Panel Refactoring Prompts

These prompts are designed for parallel execution in multiple Sonnet windows. Each prompt contains all necessary context.

## Execution Order
1. **FIRST:** Run Prompt 1 to clean up the base popup_panel.tscn
2. **IN PARALLEL:** After Prompt 1 is complete, run Prompts 2-5 simultaneously in different windows

---

## Prompt 1: Clean up popup_panel.tscn to be a generic base (DO THIS FIRST)

```
I need to clean up res://scenes/ui/components/popup_panel.tscn to be a proper generic base scene for all popup panels with grids. Currently it has food-specific elements that need to be removed.

The file should:
1. Remove the script assignment (line 20: script = ExtResource("1_iey3k"))
2. Remove the example GridItem nodes (lines 97-152) - keep only the empty GridContainer
3. Change the root node name from "FoodSelectionPopup" to "PopupPanel"
4. Change the GridContainer node name from "FoodGrid" to "ItemGrid" (line 91)
5. Remove the food-specific icon imports (lines 3, 5)
6. Set a generic title like "Select Item" for the TitleLabel (line 58)
7. Keep all the structure: Background, PopupPanel container, VBoxContainer with HeaderContainer, ScrollContainer with GridContainer, and ButtonContainer

The resulting scene should be a clean, reusable base with no specific implementation details.
```

---

## Prompt 2: Refactor FoodSelectionPopup to inherit from popup_panel.tscn (PARALLEL)

```
I need to refactor res://scenes/ui/components/food_selection_popup.tscn to inherit from the base res://scenes/ui/components/popup_panel.tscn scene.

Current food_selection_popup.tscn is at lines 1-110. It needs to:
1. Use [gd_scene load_steps=3 format=3 uid="uid://db7k3xy1m8pqv"] with base scene as inherited
2. Inherit from res://scenes/ui/components/popup_panel.tscn
3. Override the script to use res://scripts/ui/food_selection_popup_controller.gd
4. Override the TitleLabel text to "Select Food"
5. Override the ItemGrid columns property to 2
6. Keep the same uid and format

The controller script at res://scripts/ui/food_selection_popup_controller.gd should already handle the food-specific logic for populating the grid dynamically.
```

---

## Prompt 3: Refactor ActivitySelectionPopup to inherit from popup_panel.tscn (PARALLEL)

```
I need to refactor res://scenes/ui/components/activity_selection_popup.tscn to inherit from the base res://scenes/ui/components/popup_panel.tscn scene.

Current activity_selection_popup.tscn needs to:
1. Use inherited scene structure from res://scenes/ui/components/popup_panel.tscn
2. Override the script to use res://scripts/ui/activity_selection_popup_controller.gd
3. Override the TitleLabel text to "Select Activity"
4. Override the PopupPanel size offsets to be larger: offset_left = -250.0, offset_top = -200.0, offset_right = 250.0, offset_bottom = 200.0
5. Override the ItemGrid (was ActivityGrid) columns property to 2
6. Keep the same uid="uid://cxa8b7n2napqr"

The controller script should already handle the activity-specific logic.
```

---

## Prompt 4: Create VendorSelectionPopup using popup_panel base (PARALLEL)

```
Create a new popup scene res://scenes/ui/components/vendor_selection_popup.tscn that inherits from res://scenes/ui/components/popup_panel.tscn.

Requirements:
1. Inherit from res://scenes/ui/components/popup_panel.tscn
2. Override TitleLabel text to "Select Vendor"
3. Override ItemGrid columns to 3
4. Set the PopupPanel size to: offset_left = -300.0, offset_top = -200.0, offset_right = 300.0, offset_bottom = 200.0

No controller script needed for now - just create the scene structure.
```

---

## Prompt 5: Create CreatureSelectionPopup using popup_panel base (PARALLEL)

```
Create a new popup scene res://scenes/ui/components/creature_selection_popup.tscn that inherits from res://scenes/ui/components/popup_panel.tscn.

Requirements:
1. Inherit from res://scenes/ui/components/popup_panel.tscn
2. Override TitleLabel text to "Select Creature"
3. Override ItemGrid columns to 3
4. Set the PopupPanel size to: offset_left = -350.0, offset_top = -250.0, offset_right = 350.0, offset_bottom = 250.0

No controller script needed for now - just create the scene structure.
```

---

## Notes
- Each prompt is self-contained with all necessary context
- The parallel tasks don't depend on each other, only on the base scene being cleaned up first
- All prompts preserve existing UIDs where applicable
- The base popup_panel.tscn provides the common structure: Background overlay, centered panel, header with title and close button, scrollable grid, and bottom buttons