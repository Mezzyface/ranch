  Claude Prompt for Stage 1 Implementation

  You are implementing Stage 1 of a creature collection game in Godot 4.5. Follow the improved architecture strictly.

  ## Critical Architecture Rules (MUST FOLLOW):
  1. **ONLY ONE AUTOLOAD**: GameCore manages everything (except GlobalEnums which is also autoloaded for constants)
  2. **Data/Behavior Separation**:
     - CreatureData (Resource) = Pure data, NO signals, NO behavior
     - CreatureEntity (Node) = Behavior and signals only
  3. **All signals through SignalBus**: Resources NEVER emit signals
  4. **Subsystems are lazy-loaded**: Created by GameCore on first access, NOT autoloaded
  5. **ConfigFile for saves**: NEVER use store_var()

  ## Project Context:
  - Building a creature collection/breeding game similar to Pokemon/Monster Rancher
  - 6 core stats: STR, CON, DEX, INT, WIS, DIS (range 0-1000)
  - Creatures have tags for abilities and quest requirements
  - Weekly time cycles for aging and training
  - Currently in Stage 1: Core Foundation (no UI yet)

  ## File Locations:
  res://
  ├── scripts/
  │   ├── core/          # GameCore and SignalBus ONLY
  │   ├── systems/       # All subsystems (lazy-loaded)
  │   ├── data/          # Resources (CreatureData, etc)
  │   ├── entities/      # Nodes (CreatureEntity, etc)
  │   └── utils/         # Helpers and GlobalEnums
  ├── resources/
  │   ├── creatures/     # .tres files for creatures
  │   └── species/       # .tres files for species

  ## Implementation Task: [SPECIFY TASK NUMBER]
  Implement Task [X] from docs/implementation/stages/stage_1/[task_file].md

  ## Key Implementation Points:
  - Follow the code templates in the task file exactly
  - Update GameCore._load_system() when adding new subsystems
  - Test each component before moving to next task
  - Use typed GDScript (var creature: CreatureData not var creature)
  - All permanent data goes in Resources, temporary state in Nodes

  ## Common Patterns:
  ```gdscript
  # Getting a subsystem (lazy-loaded)
  var stat_system = GameCore.get_system("stat") as StatSystem

  # Using SignalBus
  var signal_bus = GameCore.get_signal_bus()
  signal_bus.creature_created.emit(creature_data)

  # NEVER do this in Resources:
  signal my_signal()  # WRONG - Resources can't have signals

  Testing Requirements:

  - Verify no errors in Godot console
  - Check that subsystems load on demand (not at startup)
  - Ensure saves work with ConfigFile format
  - Validate all signals route through SignalBus

  Please implement the specified task following these guidelines exactly. If you see old architecture patterns (multiple autoloads, Creature class instead of
  CreatureData/Entity, store_var, etc.), DO NOT use them - use the improved architecture instead.

  ## Additional Context for Specific Tasks:

  When executing specific tasks, add:

  ### For Tasks 1-2 (Foundation):
  Focus on setting up the core architecture correctly. This is the foundation everything else builds on.

  ### For Tasks 3-6 (Systems):
  These are GameCore subsystems. Remember to update GameCore._load_system() to include your new system.

  ### For Task 7 (Save System):
  Use ConfigFile exclusively. The save system should only save CreatureData resources, not CreatureEntity nodes.

  ### For Tasks 8-10 (Collections/Resources):
  Implement caching where appropriate for performance. Collections store data, create entities on demand.

  ### For Task 11 (GlobalEnums):
  This is the ONLY other autoload besides GameCore. It provides type-safe constants for the entire project.

  This prompt ensures the AI agents understand the critical architecture decisions and won't revert to the old patterns found in outdated documentation.