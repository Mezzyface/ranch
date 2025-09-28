# Stage 3: Master Parallel Implementation Guide

## Executive Summary
Stage 3 implements user-facing features through parallel development. This guide contains **20+ self-contained prompts** that can be executed simultaneously across multiple Sonnet instances.

## Quick Start for Parallel Execution

### Maximum Parallelization (20 Developers)
Assign one prompt per developer from different systems:
- 4 devs on Quest System (Prompts Q1-Q4)
- 4 devs on New Game Flow (Prompts N1-N4)
- 4 devs on Shop System (Prompts S1-S4)
- 4 devs on Battle System (Prompts B1-B4)
- 4 devs on Breeding System (Prompts BR1-BR4)

### Moderate Parallelization (5-10 Developers)
Focus on complete features:
- 2 devs per major system
- One on backend, one on UI
- Rotate through systems

### Minimal Parallelization (2-4 Developers)
Pick non-overlapping systems:
- Dev 1: Quest backend + UI
- Dev 2: Shop backend + UI
- Dev 3: Battle system
- Dev 4: New game flow

---

## Complete Prompt Catalog

### Quest System (Files: quest_system_parallel_prompts.md)

**Q1: Quest Data Structure & Resources**
- Create QuestResource and QuestObjective classes
- Set up quest .tres files for Tim's quests
- Implement validation logic
- **Dependencies:** None
- **Can run parallel:** Yes

**Q2: Quest System Core**
- Build QuestSystem with progress tracking
- Add SignalBus integration
- Implement save/load
- **Dependencies:** None
- **Can run parallel:** Yes

**Q3: Quest UI Components**
- Create quest log and quest cards
- Build turn-in dialog
- Add progress visualization
- **Dependencies:** None
- **Can run parallel:** Yes

**Q4: Quest Validation & Matching**
- Create creature matching logic
- Build requirement validators
- Integrate with PlayerCollection
- **Dependencies:** None
- **Can run parallel:** Yes

**Q5: Quest Testing (Sequential)**
- Comprehensive quest tests
- **Dependencies:** Q1, Q2
- **Can run parallel:** No

---

### New Game Experience (Files: new_game_start_parallel_prompts.md)

**N1: Starter Popup Implementation**
- Welcome screen with starter items
- Creature display and animations
- **Dependencies:** None
- **Can run parallel:** Yes

**N2: UI Visibility Changes**
- Hide UI elements for tutorial
- Progressive unlock system
- **Dependencies:** None
- **Can run parallel:** Yes

**N3: Creature Sprite Movement**
- Random walk patterns
- Facility assignment animations
- **Dependencies:** None
- **Can run parallel:** Yes

**N4: Next Week Button Logic**
- Tutorial condition checking
- Time progression gating
- **Dependencies:** None
- **Can run parallel:** Yes

**N5: Game Initialization Flow (Sequential)**
- Wire all components together
- **Dependencies:** N1-N4
- **Can run parallel:** No

---

### Shop System (Files: shop_system_parallel_prompts.md)

**S1: Shop System Core Backend**
- Shop inventory management
- Purchase logic and validation
- Economy integration
- **Dependencies:** None
- **Can run parallel:** Yes

**S2: Shop Item Data Structure**
- ShopItemResource class
- Price calculations
- Inventory generation
- **Dependencies:** None
- **Can run parallel:** Yes

**S3: Shop UI Interface**
- Shop scene and layout
- Category navigation
- Purchase interface
- **Dependencies:** None
- **Can run parallel:** Yes

**S4: Shop Keeper NPC & Flavor**
- Keeper personality and dialogue
- Visual polish and animations
- **Dependencies:** None
- **Can run parallel:** Yes

**S5: Shop Integration & Testing (Sequential)**
- Complete shop integration
- **Dependencies:** S1-S4
- **Can run parallel:** No

---

### Battle System (Files: battle_system_parallel_prompts.md)

**B1: Battle System Core Engine**
- Combat calculations
- Turn management
- Damage formulas
- **Dependencies:** None
- **Can run parallel:** Yes

**B2: Battle Actions & Abilities**
- Ability system
- Status effects
- Element types
- **Dependencies:** None
- **Can run parallel:** Yes

**B3: Battle UI Interface**
- Combat interface
- Animations and effects
- Health/stamina displays
- **Dependencies:** None
- **Can run parallel:** Yes

**B4: Enemy AI & Scenarios**
- AI behaviors
- Enemy definitions
- Battle encounters
- **Dependencies:** None
- **Can run parallel:** Yes

**B5: Battle Integration & Testing (Sequential)**
- Complete battle integration
- **Dependencies:** B1-B4
- **Can run parallel:** No

---

### Breeding System (Files: breeding_system_parallel_prompts.md)

**BR1: Genetics & Breeding Core**
- Genetic inheritance logic
- Breeding mechanics
- Mutation system
- **Dependencies:** None
- **Can run parallel:** Yes

**BR2: Breeding Compatibility & Traits**
- Trait system
- Species compatibility
- Lineage tracking
- **Dependencies:** None
- **Can run parallel:** Yes

**BR3: Breeding UI Interface**
- Breeding interface
- Parent selection
- Offspring preview
- **Dependencies:** None
- **Can run parallel:** Yes

**BR4: Breeding Progression & Unlocks**
- Mastery system
- Achievements
- Special events
- **Dependencies:** None
- **Can run parallel:** Yes

**BR5: Breeding Integration & Testing (Sequential)**
- Complete breeding integration
- **Dependencies:** BR1-BR4
- **Can run parallel:** No

---

### Facility UI Enhancements (Files: facility_ui_parallel_prompts.md)

**F1: Facility Background & Sprites**
- Visual backgrounds
- Creature sprite display
- **Dependencies:** None
- **Can run parallel:** Yes

**F2: Food Selection UI**
- Food assignment interface
- Visual feedback
- **Dependencies:** None
- **Can run parallel:** Yes

**F3: Training Selection UI**
- Training type selection
- Stat preview
- **Dependencies:** None
- **Can run parallel:** Yes

**F4: Weekly Progress Preview**
- Progress calculations
- Visual indicators
- **Dependencies:** None
- **Can run parallel:** Yes

**F5: Integration Testing (Sequential)**
- Facility UI validation
- **Dependencies:** F1-F4
- **Can run parallel:** No

---

## Execution Strategies

### Strategy 1: Maximum Speed (20+ Developers)
```
Day 1 Morning:
- Assign all parallel prompts (Q1-4, N1-4, S1-4, B1-4, BR1-4, F1-4)
- Each developer takes one prompt
- 4-6 hour development window

Day 1 Afternoon:
- Complete parallel work
- Begin merging branches
- Resolve conflicts

Day 2:
- Run sequential integration prompts (Q5, N5, S5, B5, BR5, F5)
- Full system testing
- Bug fixes
```

### Strategy 2: Balanced Approach (5-10 Developers)
```
Week 1:
- Days 1-2: Quest + Shop systems (parallel)
- Days 3-4: Battle + Breeding systems (parallel)
- Day 5: Integration and testing

Week 2:
- Days 1-2: New game flow + Facility UI
- Days 3-4: Polish and bug fixes
- Day 5: Full integration testing
```

### Strategy 3: Small Team (2-4 Developers)
```
Sprint 1 (Week 1-2):
- Quest system complete
- Shop system complete
- Initial integration

Sprint 2 (Week 3-4):
- Battle system complete
- Breeding system complete
- Second integration

Sprint 3 (Week 5-6):
- New game flow
- Facility enhancements
- Final integration and polish
```

---

## Critical Integration Points

### Shared File Modifications
These files will be modified by multiple systems - coordinate carefully:

**scripts/core/signal_bus.gd**
- Quest signals (Q2)
- Shop signals (S1)
- Battle signals (B1)
- Breeding signals (BR1)
- New game signals (N1)

**scripts/core/game_core.gd**
- System registration for all new systems
- One line per system, unlikely to conflict

**scenes/ui/overlay_menu.tscn**
- Shop button addition
- Tutorial visibility changes
- Multiple UI updates

### Merge Strategy
1. Create feature branches for each prompt
2. Merge SignalBus changes first
3. Merge GameCore changes second
4. Merge UI changes with careful testing
5. Run integration tests after each merge

---

## Testing Checklist

### Per-Component Testing (After each prompt)
- [ ] Individual component works in isolation
- [ ] No errors in console
- [ ] Saves/loads correctly
- [ ] Performance within targets

### Integration Testing (After parallel batch)
- [ ] All signals connected properly
- [ ] Systems communicate correctly
- [ ] UI navigation works
- [ ] No conflicts between systems

### Full System Testing (After all integration)
- [ ] New game flow works end-to-end
- [ ] All features accessible from UI
- [ ] Save/load preserves all data
- [ ] Performance acceptable with all systems
- [ ] No memory leaks
- [ ] Tutorial guides properly

---

## Common Issues & Solutions

### Issue: SignalBus Merge Conflicts
**Solution:** Add signals in alphabetical order within sections, leave blank lines between sections

### Issue: Scene File Conflicts
**Solution:** Coordinate UI modifications, use separate panels/containers when possible

### Issue: Save System Conflicts
**Solution:** Each system uses unique keys in save data dictionary

### Issue: Performance Degradation
**Solution:** Profile after each integration, optimize heavy operations

---

## Prompt Copy Instructions

To use a prompt:
1. Copy the entire prompt text from the specific `.md` file
2. Paste into a new Sonnet window
3. Add this context header:
```
I'm working on a Godot 4 project. The project root is: C:\Users\purem\Documents\planning
Please implement the following:

[PASTE PROMPT HERE]
```

---

## Success Metrics

Stage 3 is complete when:
- ✅ All 6 major systems implemented
- ✅ All UI components functional
- ✅ Systems integrated with main game flow
- ✅ Tutorial system guides new players
- ✅ Save/load handles all new data
- ✅ Performance meets all targets
- ✅ Full test suite passes
- ✅ No critical bugs

---

## Quick Reference: Parallel Groups

**Group A (Backend Systems):** Q1, Q2, S1, S2, B1, B2, BR1, BR2
**Group B (UI Components):** Q3, N1, S3, B3, BR3, F1-F4
**Group C (Logic/AI):** Q4, N4, S4, B4, BR4
**Group D (Flow):** N2, N3, BR2
**Sequential Only:** Q5, N5, S5, B5, BR5, F5

Choose any combination from different groups to maximize parallelization!