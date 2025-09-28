# Stage 3: Comprehensive Implementation Guide

## Overview
Stage 3 focuses on implementing user-facing features that create engaging gameplay and polish the user experience. This includes quest systems, new game flow, enhanced UI, and various gameplay systems.

## Parallel Execution Strategy

### Batch 1: Core Systems (All can run in parallel)
1. **Quest System Core** - Data structures, resources, and backend logic
2. **Shop System Backend** - Shop inventory, purchase logic, economy balance
3. **Battle System Core** - Combat calculations, damage formulas, turn logic
4. **Breeding System Logic** - Genetics, inheritance, breeding rules

### Batch 2: UI Components (All can run in parallel)
1. **Quest UI** - Quest log, quest cards, turn-in dialogs
2. **Shop UI** - Shop interface, item displays, purchase confirmations
3. **Battle UI** - Combat interface, health bars, action menus
4. **Breeding UI** - Breeding interface, partner selection, offspring preview
5. **New Game Starter Popup** - Welcome screen with starter items
6. **Facility UI Enhancements** - Backgrounds, sprites, food/training selection

### Batch 3: Integration & Polish (Sequential dependencies)
1. **Game Flow Integration** - Wire all systems together
2. **Tutorial System** - Guide new players through features
3. **Save System Updates** - Persist new system states
4. **Testing & Balancing** - Ensure all systems work together

## Feature Categories

### 1. Quest System (Parallel-Ready)
**Files:** `quest_system_parallel_prompts.md`
- Quest data structures and resources
- Quest validation and matching logic
- Quest UI components (log, cards, turn-in)
- Quest rewards and progression
- **Parallel Capacity:** 4 concurrent instances

### 2. New Game Experience (Parallel-Ready)
**Files:** `new_game_start_parallel_prompts.md`
- Starter popup with creature/items
- UI visibility management for tutorial
- Creature sprite movement system
- Next Week button logic
- **Parallel Capacity:** 4 concurrent instances

### 3. Facility UI Enhancements (Parallel-Ready)
**Files:** `facility_ui_parallel_prompts.md`
- Facility backgrounds and themes
- Creature sprite display in facilities
- Food selection interface
- Training type selection
- Weekly progress preview
- **Parallel Capacity:** 4 concurrent instances

### 4. Shop System (Needs Prompts)
**Components to implement:**
- Shop inventory management
- Item generation and restocking
- Purchase validation and transactions
- Shop UI with categories
- Price balancing system
- **Parallel Capacity:** 3-4 concurrent instances

### 5. Battle System (Needs Prompts)
**Components to implement:**
- Turn-based combat engine
- Damage calculation formulas
- Status effects and conditions
- Battle UI with animations
- AI opponent logic
- Victory/defeat handling
- **Parallel Capacity:** 4-5 concurrent instances

### 6. Breeding System (Needs Prompts)
**Components to implement:**
- Genetic inheritance rules
- Breeding compatibility checks
- Offspring generation
- Breeding UI with preview
- Breeding costs and cooldowns
- **Parallel Capacity:** 3-4 concurrent instances

### 7. World Map System (Needs Prompts)
**Components to implement:**
- Map rendering and navigation
- Location discovery system
- Fast travel mechanics
- Random encounters
- Map persistence
- **Parallel Capacity:** 3-4 concurrent instances

### 8. Achievement System (Needs Prompts)
**Components to implement:**
- Achievement definitions
- Progress tracking
- Unlock notifications
- Achievement UI/gallery
- Reward distribution
- **Parallel Capacity:** 2-3 concurrent instances

## Execution Guidelines

### For Parallel Development

1. **Setup Phase (All developers)**
   - Clone/pull latest code
   - Run preflight check
   - Review CLAUDE.md invariants
   - Select a prompt from your assigned batch

2. **Development Phase**
   - Each developer takes one complete prompt
   - Work in isolation on assigned components
   - Create new files as specified
   - Modify existing files carefully
   - Test individual components

3. **Integration Phase**
   - Merge all parallel work
   - Resolve any conflicts
   - Run integration tests
   - Fix cross-component issues

### Prompt Selection Strategy

**For Maximum Parallelization:**
- Assign developers to different feature categories
- Within a category, assign different component types (UI vs Logic)
- Avoid overlapping file modifications
- Coordinate on shared resources (SignalBus, GameCore)

**Example Team Assignment (4 developers):**
- Dev 1: Quest System Core (Prompt 1)
- Dev 2: Quest UI Components (Prompt 3)
- Dev 3: Shop System Backend
- Dev 4: New Game Starter Popup

### Integration Checkpoints

After each batch completes:
1. Run full test suite
2. Verify all signals connected
3. Check save/load functionality
4. Test UI navigation flow
5. Validate performance metrics

## Common Integration Points

### SignalBus Additions
All new systems will need signals in `scripts/core/signal_bus.gd`:
```gdscript
# Quest System
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_objective_completed(quest_id: String, objective_index: int)

# Shop System
signal shop_item_purchased(item_id: String, quantity: int)
signal shop_inventory_updated()

# Battle System
signal battle_started(enemy_data: Resource)
signal battle_ended(victory: bool)
signal damage_dealt(target: Node, amount: int)

# Breeding System
signal breeding_started(parent1: CreatureData, parent2: CreatureData)
signal offspring_generated(offspring: CreatureData)
```

### GameCore System Registration
New systems need registration in `scripts/core/game_core.gd`:
```gdscript
"quest": preload("res://scripts/systems/quest_system.gd"),
"shop": preload("res://scripts/systems/shop_system.gd"),
"battle": preload("res://scripts/systems/battle_system.gd"),
"breeding": preload("res://scripts/systems/breeding_system.gd"),
"world_map": preload("res://scripts/systems/world_map_system.gd"),
"achievement": preload("res://scripts/systems/achievement_system.gd"),
```

### Save System Integration
Each new system needs save/load methods:
```gdscript
func get_save_data() -> Dictionary
func load_save_data(data: Dictionary) -> void
```

## Testing Requirements

### Individual Component Tests
Each parallel prompt should include:
- Unit test for core logic
- UI test for visual components
- Integration test for system connections
- Performance test for expensive operations

### Full Integration Tests
After all components merged:
- New game flow start to finish
- All UI navigation paths
- Save/load with new systems
- Performance under load
- Edge cases and error handling

## Performance Targets

| Operation | Target Time |
|-----------|------------|
| Quest validation (100 quests) | <50ms |
| Shop inventory load | <100ms |
| Battle turn calculation | <16ms |
| Breeding calculation | <200ms |
| Map rendering | <100ms |
| Achievement check (100 achievements) | <30ms |

## File Structure Reference

```
scripts/
├── systems/
│   ├── quest_system.gd
│   ├── shop_system.gd
│   ├── battle_system.gd
│   ├── breeding_system.gd
│   ├── world_map_system.gd
│   └── achievement_system.gd
├── ui/
│   ├── quest_log_controller.gd
│   ├── shop_controller.gd
│   ├── battle_controller.gd
│   ├── breeding_controller.gd
│   └── world_map_controller.gd
├── data/
│   ├── quest_objective.gd
│   ├── shop_item_data.gd
│   ├── battle_action.gd
│   └── breeding_result.gd
└── resources/
    ├── quest_resource.gd
    ├── enemy_resource.gd
    └── achievement_resource.gd

scenes/
├── ui/
│   ├── quest_log.tscn
│   ├── shop.tscn
│   ├── battle.tscn
│   ├── breeding.tscn
│   └── world_map.tscn
└── components/
    ├── quest_card.tscn
    ├── shop_item_card.tscn
    ├── battle_hud.tscn
    └── breeding_preview.tscn

data/
├── quests/
│   └── *.tres
├── enemies/
│   └── *.tres
├── achievements/
│   └── *.tres
└── shop_items/
    └── *.tres
```

## Success Criteria

Stage 3 is complete when:
1. All core systems implemented and tested
2. UI components functional and polished
3. Systems integrated with main game flow
4. Tutorial guides new players
5. Save/load handles all new data
6. Performance meets targets
7. No critical bugs in integration tests

## Notes for AI Agents

When creating new parallel prompts:
1. Include ALL necessary context in the prompt
2. Specify exact file paths
3. List integration points clearly
4. Include test requirements
5. Note any dependencies
6. Keep prompts focused on 1-2 hours of work
7. Avoid overlapping file modifications