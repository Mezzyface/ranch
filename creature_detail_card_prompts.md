# Creature Detail Card Implementation Prompts

These prompts can be used in separate Sonnet instances to implement the creature detail card popup functionality. Tasks that can be done in parallel are marked accordingly.

## Prompt 1: Create Creature Detail Card Controller Script
**Can be done in parallel: YES**

```
Create a controller script for the creature detail card popup in a Godot 4 project.

File to create: scripts/ui/creature_detail_card_controller.gd

Requirements:
1. Create a controller that extends Control
2. Add @onready variables for UI elements that need to be populated from CreatureData
3. Add a populate(creature_data: CreatureData) method that fills in all the UI fields
4. Include proper null checks and validation
5. Add a close button handler that hides/queues free the popup
6. The creature container should display the sprite idle animation

The CreatureData resource has these properties to display:
- creature_name: String
- species_id: String
- age_weeks: int
- lifespan_weeks: int
- stats: Dictionary (with strength, agility, intelligence, etc.)
- tags: Array[String]
- happiness: float
- loyalty: float
- id: String

Make sure to follow Godot 4 best practices and use @onready for node references.
```

## Prompt 2: Wire Up Click Handler in Creature Entity
**Can be done in parallel: YES**

```
Modify the creature entity controller to show a detail popup when clicked in a Godot 4 project.

Files to modify:
- scripts/entities/creature_entity_controller.gd
- scenes/entities/creature_entity.tscn (if needed for input handling)

Requirements:
1. Add click/input detection to the creature entity
2. When clicked, instantiate the creature detail card: "res://scenes/ui/components/creature_detail_card.tscn"
3. Pass the CreatureData to the popup's populate() method
4. Position the popup appropriately (center of screen or near click)
5. Add the popup to the scene tree (get_tree().current_scene or appropriate parent)
6. Ensure only one detail card can be open at a time
7. Use proper z-index/layer to ensure popup appears above other UI

The creature entity already has access to its CreatureData through the existing controller.

Signal through SignalBus if needed: GameCore.get_signal_bus()
```

## Prompt 3: Update Detail Card Scene with Proper Node Structure
**Can be done in parallel: NO - Do this FIRST if the scene is empty**

```
Set up the creature detail card scene structure in a Godot 4 project.

File to modify: scenes/ui/components/creature_detail_card.tscn

Create this node structure:
- CreatureDetailCard (Control) - Main container
  - Panel - Background panel
    - MarginContainer - Padding
      - VBoxContainer - Main layout
        - HeaderContainer (HBoxContainer)
          - CreatureNameLabel (Label)
          - CloseButton (Button) - "X" to close
        - HSeparator
        - CreatureContainer (TextureRect or AnimatedSprite2D) - For creature sprite
        - StatsContainer (GridContainer) - 2 columns for stat labels/values
          - SpeciesLabel (Label) - "Species:"
          - SpeciesValue (Label)
          - AgeLabel (Label) - "Age:"
          - AgeValue (Label)
          - LifespanLabel (Label) - "Lifespan:"
          - LifespanValue (Label)
          - StrengthLabel (Label) - "Strength:"
          - StrengthValue (Label)
          - AgilityLabel (Label) - "Agility:"
          - AgilityValue (Label)
          - IntelligenceLabel (Label) - "Intelligence:"
          - IntelligenceValue (Label)
        - HSeparator
        - TraitsContainer (VBoxContainer)
          - TraitsLabel (Label) - "Traits:"
          - TagsList (RichTextLabel or ItemList)
        - HSeparator
        - MoodContainer (HBoxContainer)
          - HappinessLabel (Label) - "Happiness:"
          - HappinessBar (ProgressBar)
          - LoyaltyLabel (Label) - "Loyalty:"
          - LoyaltyBar (ProgressBar)

Set appropriate minimum sizes and anchors for responsive layout.
Attach the controller script: "res://scripts/ui/creature_detail_card_controller.gd"
```

## Prompt 4: Add Creature Sprite Animation to Detail Card
**Can be done in parallel: YES (after Prompt 3)**

```
Implement creature sprite display in the detail card in a Godot 4 project.

Files to modify:
- scripts/ui/creature_detail_card_controller.gd
- scenes/ui/components/creature_detail_card.tscn (if needed)

Requirements:
1. In the CreatureContainer node, display the creature's idle animation
2. Load the appropriate sprite based on species_id from CreatureData
3. Sprite paths are in: "res://assets/sprites/creatures/[species_id]/idle.tres" or similar structure
4. If using AnimatedSprite2D, play the "idle" animation on loop
5. Scale the sprite appropriately to fit the container (e.g., 2x or 3x scale)
6. Center the sprite in the container
7. Handle missing sprites gracefully with a placeholder or error message

The creature sprites should already exist in the project. Use the species_id from CreatureData to determine which sprite to load.
```

## Prompt 5: Add Popup Overlay and Input Blocking
**Can be done in parallel: YES**

```
Ensure the creature detail card properly blocks input and appears as a modal popup in a Godot 4 project.

Files to modify:
- scenes/ui/components/creature_detail_card.tscn
- scripts/ui/creature_detail_card_controller.gd

Requirements:
1. Add a semi-transparent background (ColorRect) that covers the whole screen
2. Set mouse_filter = STOP on the background to block clicks
3. Center the actual detail card panel on screen
4. Add escape key handling to close the popup
5. Ensure clicking outside the card (on the background) closes it
6. Set proper z_index or add to CanvasLayer for rendering above everything
7. Add fade in/out animation if desired (optional)

The popup should prevent interaction with anything behind it while open.
```

## Execution Notes

- **Prompt 3 should be done FIRST** if the scene file is empty or needs the basic structure
- **Prompts 1, 2, and 5** can be run in parallel immediately
- **Prompt 4** can be run after Prompt 3 is complete
- Each prompt contains all necessary context and can be run independently in a new Sonnet window
- All prompts follow Godot 4 best practices and conventions