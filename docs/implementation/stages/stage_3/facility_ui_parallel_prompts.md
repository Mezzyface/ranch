# Facility UI Enhancement - Parallel Implementation Prompts

## Overview
These prompts can be executed in parallel by different AI agents. Each includes necessary context.

---

## PROMPT 1: Facility Background & Creature Sprite Display
**Can run in parallel with: Prompts 2, 3, 4**

```
I need to update the facility card UI in a Godot project to display:
1. A background image for each facility type
2. An animated creature sprite overlapping the facility when a creature is assigned

Context:
- Facility card scene: scenes/ui/components/facility_card.tscn
- Facility card controller: scripts/ui/facility_card.gd
- Facility types are in scripts/core/global_enums.gd (FacilityType enum)
- Creatures have portrait_path property pointing to animated sprites
- SignalBus at scripts/core/signal_bus.gd has facility_assignment_changed signal
- FacilitySystem at scripts/systems/facility_system.gd manages assignments

Requirements:
1. Add TextureRect node for facility background image
2. Add AnimatedSprite2D node for creature display
3. Load appropriate facility background based on facility.facility_type
4. When creature assigned, load and display creature's animated sprite
5. Position creature sprite to overlay nicely on facility background
6. Hide creature sprite when no creature assigned

Facility background images should be loaded from:
- TRAINING_FIELD: res://assets/facilities/training_field.png
- RANCH: res://assets/facilities/ranch.png
- LIBRARY: res://assets/facilities/library.png
- MEDITATION_CIRCLE: res://assets/facilities/meditation_circle.png

Test with: godot --headless --scene test_facility_visuals.tscn
```

---

## PROMPT 2: Food Selection UI Component
**Can run in parallel with: Prompts 1, 3, 4**

```
I need to add a food selection UI to the facility card in a Godot project.

Context:
- Facility card scene: scenes/ui/components/facility_card.tscn
- Facility card controller: scripts/ui/facility_card.gd
- FoodSystem at scripts/systems/food_system.gd manages food items
- Food items have ItemResource with food_type property
- SignalBus at scripts/core/signal_bus.gd for signals

Requirements:
1. Add a food icon button (TextureButton) to the facility card
2. Create a popup menu (PopupMenu or custom Control) that shows available food items
3. When food icon clicked, show popup with:
   - List of available food items from FoodSystem
   - Food name, icon, and effects
   - Current food assignment highlighted
4. On food selection, update the assigned creature's food preference
5. Update food icon to show currently selected food
6. Only show food UI when a creature is assigned to the facility

Food icon position: Bottom-left corner of facility card
Use icon: res://assets/icons/food_icon.png (create placeholder if missing)

The food assignment should:
- Call FoodSystem.assign_food_to_creature(creature_data, food_item)
- Emit appropriate signal via SignalBus
- Update visual immediately

Test with: godot --headless --scene test_facility_food_ui.tscn
```

---

## PROMPT 3: Training Selection UI Component
**Can run in parallel with: Prompts 1, 2, 4**

```
I need to add a training type selection UI to the facility card in a Godot project.

Context:
- Facility card scene: scenes/ui/components/facility_card.tscn
- Facility card controller: scripts/ui/facility_card.gd
- TrainingSystem at scripts/systems/training_system.gd manages training
- Training types in global_enums.gd (TrainingType enum)
- Each facility supports specific training types
- SignalBus at scripts/core/signal_bus.gd for signals

Requirements:
1. Add a training icon button (TextureButton) to the facility card
2. Create a popup menu showing available training types for this facility
3. When training icon clicked, show popup with:
   - List of training types valid for this facility type
   - Training name, icon, stat gains preview
   - Current training highlighted
4. On training selection, update the facility's training type
5. Update training icon to show currently selected training
6. Only show training UI when facility supports training

Training icon position: Bottom-right corner of facility card
Use icon: res://assets/icons/training_icon.png (create placeholder if missing)

Training types per facility:
- TRAINING_FIELD: STRENGTH, AGILITY, ENDURANCE
- LIBRARY: INTELLIGENCE, FOCUS
- MEDITATION_CIRCLE: WILLPOWER, CHARISMA
- RANCH: (no training, used for resource generation)

The training assignment should:
- Call TrainingSystem.set_facility_training(facility, training_type)
- Emit appropriate signal via SignalBus
- Update visual immediately

Test with: godot --headless --scene test_facility_training_ui.tscn
```

---

## PROMPT 4: Weekly Progress Preview Display
**Can run in parallel with: Prompts 1, 2, 3**

```
I need to add a weekly progress preview to the top of facility cards in a Godot project.

Context:
- Facility card scene: scenes/ui/components/facility_card.tscn
- Facility card controller: scripts/ui/facility_card.gd
- TrainingSystem at scripts/systems/training_system.gd calculates stat gains
- FoodSystem affects stamina and mood
- WeeklyUpdateOrchestrator at scripts/systems/weekly_update_orchestrator.gd
- TimeSystem at scripts/systems/time_system.gd for week progression

Requirements:
1. Add a preview panel (PanelContainer) at the top of facility card
2. Display predicted changes for next week:
   - Stat gains from training (if assigned)
   - Stamina changes from activity
   - Mood changes from food/training combination
   - Experience gains
3. Use color coding: green for gains, red for losses, yellow for warnings
4. Format: "STR +2 | END +1 | Stamina -10 | Mood +5"
5. Update preview when:
   - Creature assignment changes
   - Training type changes
   - Food selection changes
6. Only show when creature is assigned

The preview should calculate by:
- Getting training gains from TrainingSystem.calculate_stat_gains()
- Getting stamina cost from training type
- Getting mood effects from food/training combo
- Displaying in a RichTextLabel with BBCode colors

Preview panel position: Top edge of facility card, full width
Height: 30-40 pixels
Background: Semi-transparent dark panel

Test with: godot --headless --scene test_facility_preview.tscn
```

---

## PROMPT 5: Integration Testing (Run AFTER all parallel tasks complete)
**Dependencies: Prompts 1-4 must be complete**

```
I need to create integration tests for the enhanced facility UI system in a Godot project.

Context:
- All facility UI enhancements have been added
- Facility card at scenes/ui/components/facility_card.tscn
- Tests go in tests/individual/test_facility_ui.tscn

Requirements:
1. Create comprehensive test scene that validates:
   - Facility background images load correctly
   - Creature sprites display when assigned
   - Food selection UI opens and assigns food
   - Training selection UI opens and sets training
   - Weekly preview updates with correct calculations
   - All UI elements hide when no creature assigned

2. Test edge cases:
   - Switching between different creatures
   - Removing creature assignment
   - Invalid food/training combinations
   - Multiple facilities with different assignments

3. Performance test:
   - Load 10+ facility cards simultaneously
   - Verify UI updates stay under 16ms

Run with: godot --headless --scene tests/individual/test_facility_ui.tscn
```

---

## Notes on Parallelization

**Can run simultaneously:**
- Prompts 1, 2, 3, and 4 can all run in parallel as they modify different aspects of the facility card

**Must run sequentially:**
- Prompt 5 (Integration Testing) must wait until all other prompts are complete

**Potential conflicts to watch:**
- Multiple agents editing facility_card.tscn may cause merge conflicts
- Coordinate node naming to avoid collisions
- Use clear node paths in scripts

**Recommended execution:**
1. Start Prompts 1-4 in separate windows simultaneously
2. Once all complete, run Prompt 5 for integration testing