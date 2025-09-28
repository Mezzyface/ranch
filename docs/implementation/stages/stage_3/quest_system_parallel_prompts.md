# Quest System Implementation - Parallel Prompts for Sonnet

This document contains self-contained prompts for implementing the quest system from the quest design document. Each prompt can be run in a separate Sonnet instance for parallel development.

## Parallel Execution Strategy

- **Can run simultaneously:** Prompts 1, 2, 3, and 4 can all run in parallel
- **Sequential dependency:** Prompt 5 (testing) should run after Prompts 1 and 2 are complete
- **Integration points:** All prompts reference the same quest IDs (TIM-01 through TIM-06) and stat names (STR, CON, INT, WIS, DEX, DIS)

---

## PROMPT 1: Quest Data Structure & Resources (Can Run Parallel)

```
Create the quest system data structure and resources for a Godot 4 project. Create these files:

1. Create QuestResource at scripts/resources/quest_resource.gd:
- Extends Resource with @tool annotation
- Properties: quest_id (String), title (String), description (String), prerequisites (Array[String]), dialogue_snippet (String), rewards (Dictionary with gold:int, xp:int, items:Array[String], unlocks:Array[String])
- Method: is_valid() -> bool

2. Create QuestObjective at scripts/data/quest_objective.gd:
- Properties: type (enum: PROVIDE_CREATURE, PROVIDE_MULTIPLE), required_tags (Array[String]), required_stats (Dictionary of stat_name:String -> min_value:int), quantity (int), description (String)
- Method: matches_creature(creature_data: CreatureData) -> bool

3. Create the quest .tres files in data/quests/:
- TIM-01.tres through TIM-06.tres following this exact structure from the design doc:
  - TIM-01: Small/Territorial tags, DIS>80, WIS>70
  - TIM-02: Dark Vision tag, CON>120, STR>110
  - TIM-03: Three parts with specific tag/stat combos
  - TIM-04: Two creatures with Sure-Footed, STR>130, INT>90, DIS>110
  - TIM-05: Camouflage tag, CON>200, DIS>180
  - TIM-06: Multiple parts with varying requirements

Ensure all resources use proper Godot format with script_class and @export properties.
```

---

## PROMPT 2: Quest System Core (Can Run Parallel)

```
Create the QuestSystem for a Godot 4 project at scripts/systems/quest_system.gd:

1. System should extend Node and integrate with GameCore
2. Properties: active_quests (Dictionary), completed_quests (Array[String]), quest_resources (Dictionary)
3. Key methods:
   - _ready(): Load all quest resources from data/quests/
   - start_quest(quest_id: String) -> bool
   - complete_objective(quest_id: String, objective_index: int, creatures: Array[CreatureData]) -> bool
   - check_prerequisites(quest_id: String) -> bool
   - get_available_quests() -> Array[String]
   - is_quest_active(quest_id: String) -> bool
   - is_quest_completed(quest_id: String) -> bool

4. Integrate with SignalBus - add these signals to scripts/core/signal_bus.gd:
   - signal quest_started(quest_id: String)
   - signal quest_objective_completed(quest_id: String, objective_index: int)
   - signal quest_completed(quest_id: String)
   - signal quest_reward_granted(quest_id: String, rewards: Dictionary)

5. Add "quest" to GameCore system loader in scripts/core/game_core.gd

6. Implement save/load functionality for quest progress
```

---

## PROMPT 3: Quest UI Components (Can Run Parallel)

```
Create Quest UI components for a Godot 4 project:

1. Create scenes/ui/components/quest_card.tscn:
   - Panel container showing quest title, description, objectives
   - Progress indicators for multi-part quests
   - Reward display section
   - "Track Quest" and "Turn In" buttons

2. Create scripts/ui/quest_card.gd:
   - Properties: quest_data (QuestResource), is_active (bool)
   - Methods: set_quest_data(), update_progress(), _on_track_pressed(), _on_turn_in_pressed()
   - Connect to SignalBus for updates

3. Create scenes/ui/quest_log.tscn:
   - TabContainer with "Active" and "Completed" tabs
   - ScrollContainer for quest list
   - Quest details panel
   - Integration point for overlay_menu.tscn

4. Create scripts/ui/quest_log_controller.gd:
   - Load and display quests from QuestSystem
   - Filter by active/completed status
   - Handle quest selection and details display
   - Integrate with UIManager for scene transitions
```

---

## PROMPT 4: Quest Validation & Matching (Can Run Parallel)

```
Create quest validation and creature matching system for a Godot 4 project:

1. Create scripts/systems/quest_matcher.gd:
   - Static class for matching creatures to quest requirements
   - Method: find_matching_creatures(objective: QuestObjective, collection: Array[CreatureData]) -> Array[CreatureData]
   - Method: validate_creature_for_objective(creature: CreatureData, objective: QuestObjective) -> bool
   - Handle tag matching with AND logic
   - Handle stat minimum requirements
   - Handle quantity requirements for multi-creature objectives

2. Extend CreatureData at scripts/data/creature_data.gd:
   - Add method: meets_quest_requirements(tags: Array[String], min_stats: Dictionary) -> bool
   - Ensure compatibility with existing stat getters

3. Create quest turn-in dialog at scenes/ui/quest_turn_in_dialog.tscn:
   - Show quest requirements
   - Display eligible creatures from player collection
   - Allow selection of creatures to submit
   - Preview rewards before confirmation

4. Integration with PlayerCollection:
   - Add method in scripts/systems/player_collection.gd:
     get_creatures_matching_requirements(tags: Array[String], min_stats: Dictionary) -> Array[CreatureData]
```

---

## PROMPT 5: Quest Testing Scene (Run After Prompts 1 & 2)

```
Create comprehensive quest system tests for a Godot 4 project:

1. Create tests/individual/test_quest.tscn and test_quest.gd:
   - Test quest resource loading
   - Test prerequisite checking
   - Test objective matching with mock creatures
   - Test quest progression (start -> complete objectives -> finish)
   - Test save/load of quest progress
   - Test signal emissions
   - Test reward granting

2. Create test data generator at tests/helpers/quest_test_data.gd:
   - Generate mock creatures meeting specific quest requirements
   - Create test cases for all 6 Tim quests
   - Edge cases: creatures missing one requirement, exact matches, over-qualified

3. Add quest system to preflight check in tests/preflight_check.tscn

Run with: godot --headless --scene tests/individual/test_quest.tscn
```

---

## Implementation Notes

### Quest ID Reference
- TIM-01: Study Guard
- TIM-02: Going Underground
- TIM-03: Cave Ecology 101
- TIM-04: Subterranean Shipping
- TIM-05: The Living Lock
- TIM-06: Dungeon Master's Decree

### Stat Abbreviations
- STR: Strength
- CON: Constitution
- INT: Intelligence
- WIS: Wisdom
- DEX: Dexterity
- DIS: Discipline

### Required Tags (from design doc)
- Small, Territorial, Dark Vision, Bioluminescent, Cleanser, Flies, Stealthy
- Sure-Footed, Camouflage, Constructor, Sentient

### Integration Points
- GameCore system registration
- SignalBus for quest events
- PlayerCollection for creature access
- SaveSystem for persistence
- UIManager for scene management
- ResourceTracker for reward handling (gold/xp)