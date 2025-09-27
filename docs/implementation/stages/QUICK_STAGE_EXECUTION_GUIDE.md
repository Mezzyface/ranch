# Quick Stage Execution Guide

This guide provides rapid, copy-paste ready prompts for implementing each stage. Each prompt is self-contained and can be given to an AI agent or developer.

---

## 🎯 Stage 3: Shop System & Economy - Quick Prompts

### Parallel Execution (2 Agents)
**Agent 1 - Backend:**
```
Implement ShopSystem and VendorResource classes from Stage 3 Tasks 3.1-3.3 in STAGE_IMPLEMENTATION_PROMPTS.md. Create the shop system as a GameCore subsystem with 6 vendors, dynamic inventory, and transaction validation. Create vendor resources for Armored Ace, Sky Sailor, Shadow Market, Savage Supplies, Mystical Menagerie, and Starter Stable. Each vendor specializes in specific creature types. Reference quest_design_doc.md for creature requirements. Test with: godot --headless --scene tests/systems/test_shop.tscn
```

**Agent 2 - Frontend:**
```
Create the shop UI from Stage 3 Tasks 3.4-3.5 in STAGE_IMPLEMENTATION_PROMPTS.md. Build scenes/ui/panels/shop_panel.tscn with vendor selection, item grid, purchase dialogs, and transaction feedback. Implement dynamic pricing and restock mechanics. Connect to ShopSystem for real-time updates. Maintain 60 FPS with 50+ items. Include economy_config.tres for balance tuning.
```

### Sequential Execution (1 Agent)
```
Complete Stage 3: Shop System & Economy following tasks 3.1-3.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Start with ShopSystem core, then create vendor resources, implement shop items, build the UI, add economy balancing, and finish with integration testing. Ensure players can purchase creatures for TIM quests with prices: Scuttleguard 200g, Glow Grub 400g, Wind Dancer 500g. Performance target: 100 items <50ms, 1000 transactions <2s.
```

---

## 🎯 Stage 4: Training System - Quick Prompts

### Parallel Execution (2 Agents)
**Agent 1 - Training Core:**
```
Implement TrainingSystem from Stage 4 Tasks 4.1-4.3 in STAGE_IMPLEMENTATION_PROMPTS.md. Create training activities (Physical, Agility, Mental, Discipline) that take 1 week and provide 5-15 stat gains. Add facilities with 3 tiers (Basic 1.0x, Advanced 1.5x, Elite 2.0x multipliers). Implement training scheduler with queue system and batch training. Integrate with TimeSystem and StaminaSystem. Process 100 trainings <100ms.
```

**Agent 2 - Training UI & Food:**
```
Build training UI from Stage 4 Tasks 4.4-4.5 in STAGE_IMPLEMENTATION_PROMPTS.md. Create scenes/ui/panels/training_panel.tscn with facility overview, creature assignment, schedule calendar, and progress tracking. Extend FoodSystem with training foods (Power Bars, Speed Snacks, Brain Food, Focus Tea) providing +50% effectiveness. Cost: 25g per item. Test reaching 200+ stats for TIM-05 requirements.
```

### MVP Minimal Version
```
Implement basic training: Create TrainingSystem with 4 activities providing 5-15 stat gains per week. Training ages creatures +1 week and costs 10 stamina. Add simple UI for creature assignment. Skip facilities and advanced features. Focus on making stats reach 200+ for late-game quests. Test with 52-week progression.
```

---

## 🎯 Stage 5: Quest System (Tim's Quests) - Quick Prompts

### Full Implementation (Critical for MVP)
```
Implement complete Quest System from Stage 5 Tasks 5.1-5.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Priority focus on TIM-01 through TIM-06 quests. Create QuestSystem with validation engine, Tim NPC with dialogue, all 6 quest resources with exact requirements from quest_design_doc.md, quest UI panel, and creature submission system. This is THE core gameplay loop. Ensure: TIM-01 ([Small]+[Territorial], DIS>80, WIS>70), TIM-02 ([Dark Vision], CON>120, STR>110), TIM-03 (3-part multi-creature). Must support multi-part quests and creature validation <50ms.
```

### Rapid MVP Version
```
Quick quest implementation: Create basic QuestSystem that loads TIM-01 to TIM-03 from resources. Implement requirement validation for tags and stats. Add simple submission dialog. Skip fancy UI and Tim animations. Focus on functional quest completion with correct rewards (300g, 400g, 1500g). Test complete quest chain progression.
```

---

## 🎯 Stage 6: Competition System - Quick Prompts

### Complete System
```
Build Competition System from Stage 6 Tasks 6.1-6.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Create 10 competition types with auto-resolution based on stats. Add difficulty tiers (Beginner to Elite), entry fees (10-100g), and prizes (50-400g). Generate AI opponents with appropriate challenge. Build competition UI with weekly board and results. This provides alternative income for mid-game gap. Simulate 100 competitions <200ms. Ensure 60-70% win rate with appropriate creatures.
```

### Economic Bridge Version
```
Minimal competitions for income: Create 3 basic competitions (Strength, Intelligence, All-Around) with simple stat checks. Entry: 10g, Prizes: 50-150g. Add to weekly update cycle. Purpose: Bridge funding gap for TIM-03 (need 300-600g income). Skip complex UI, just add results to weekly summary.
```

---

## 🎯 Stage 7: Advanced Quests - Quick Prompts

### Extended Content
```
Implement Stage 7 Advanced Quests from Tasks 7.1-7.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Add 5 new NPCs (Marina, Brutus, Whisper, Sage Elm, Groundskeeper) with unique quest types. Create procedural quest generator for weekly variety. Implement quest chains with branching paths. Add special events and time-limited quests. This extends gameplay beyond TIM questline. Support 50+ active quests.
```

### Post-MVP Addition
```
Skip for MVP. Stage 7 is post-launch content. Focus on perfecting TIM questline first.
```

---

## 🎯 Stage 8: Breeding System - Quick Prompts

### Complete Genetics System
```
Build Breeding System from Stage 8 Tasks 8.1-8.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Implement genetic inheritance (stats = parent average ±20%), tag inheritance with mutations (5% chance), egg groups for compatibility, and incubation system (2-4 weeks). Create breeding UI with genetic preview and pedigree tracking. Add nursery facilities. Calculate 1000 combinations <100ms. Include shiny system (1/500 chance).
```

### Basic Breeding for MVP
```
Simple breeding: Two creatures produce offspring with averaged stats ±20%. Tags inherited randomly from parents. 4-week cooldown. Creates alternative income source by selling offspring. Skip complex genetics, mutations, and facilities. Just functional breeding for basic quest creature production.
```

---

## 🎯 Stage 9: Polish - Quick Prompts

### Full Polish Pass
```
Implement Stage 9 Polish from Tasks 9.1-9.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Add audio system with music and SFX. Create visual effects for feedback. Implement 50+ achievements. Enhance tutorials for 90% completion rate. Add 4 exotic vendors with unique mechanics. Target: 60 FPS, <3s load times, <10MB saves.
```

### MVP Polish Only
```
Minimal polish for release: Add basic sound effects for UI feedback. Create simple tutorial for TIM-01. Add achievement for quest completion. Skip exotic vendors and complex VFX. Focus on stability and performance.
```

---

## 🎯 Stage 10: Balancing & MVP Completion - Quick Prompts

### Complete Validation
```
Execute Stage 10 MVP Completion from Tasks 10.1-10.6 in STAGE_IMPLEMENTATION_PROMPTS.md. Balance economy ensuring all quests completable. Tune stat curves for progression. Create automated playtesting framework. Enhance save system with compression. Add accessibility features. Run complete validation: TIM questline 01-06, 52-week playthrough, performance benchmarks. Confirm 100% MVP features functional.
```

### Critical MVP Testing
```
MVP validation essentials: Test complete TIM questline (01-06) is playable start to finish. Verify economic progression (starting 500g can reach endgame). Check save/load preserves all data. Run 52-week simulation. Confirm performance targets met. Document any issues for post-launch fixes.
```

---

## 📊 Stage Priority Matrix

| Stage | MVP Critical | Time | Can Parallelize | Dependencies |
|-------|-------------|------|-----------------|--------------|
| 3. Shop | ✅ Essential | 2 weeks | Yes (UI + Backend) | Stage 2 |
| 4. Training | ✅ Essential | 2 weeks | Yes (Systems + UI) | Stage 2 |
| 5. Quests | ✅ CRITICAL | 2-3 weeks | Partially | Stages 3,4 |
| 6. Competition | ⚠️ Important | 2 weeks | Yes | Stage 2 |
| 7. Adv Quests | ❌ Post-MVP | 2-3 weeks | Yes | Stage 5 |
| 8. Breeding | ⚠️ Important | 2 weeks | Yes | Stage 2 |
| 9. Polish | ⚠️ Partial | 2 weeks | Yes | All |
| 10. Validation | ✅ Essential | 1-2 weeks | No | All |

---

## 🚀 Fastest Path to MVP

### Week 1-2: Core Economy (Parallel)
```
Agent 1: Implement complete Shop System (Stage 3)
Agent 2: Implement Training System (Stage 4)
Both: Follow tasks in STAGE_IMPLEMENTATION_PROMPTS.md
```

### Week 3-4: Quest System (Critical Path)
```
All agents: Focus on Stage 5 Quest System - this is the core game
Implement TIM-01 through TIM-06 with full validation
This IS the game - don't skip or rush
```

### Week 5: Income Systems
```
Agent 1: Add Competition System (Stage 6) for alternative income
Agent 2: Add basic Breeding (Stage 8) for creature production
```

### Week 6: Integration & Polish
```
All agents: MVP validation (Stage 10)
Test complete playthrough
Fix critical bugs only
Skip non-essential polish
```

---

## 🎯 Single Developer Path (6-8 weeks)

1. **Shop System** (3 days) - Basic vendors and purchasing
2. **Training System** (3 days) - Stat improvement mechanics
3. **Quest System** (1 week) - TIM complete questline
4. **Competition** (2 days) - Alternative income
5. **Basic Breeding** (2 days) - Creature production
6. **Testing** (3 days) - Full playthrough validation
7. **Polish** (3 days) - Critical fixes only

---

## 📝 Copy-Paste Validation Command

After each stage, run:
```bash
# Validate project compiles
godot --check-only project.godot

# Run preflight check
godot --headless --scene tests/preflight_check.tscn

# Run stage-specific tests
godot --headless --scene tests/stage_3/test_shop.tscn
godot --headless --scene tests/stage_4/test_training.tscn
godot --headless --scene tests/stage_5/test_quests.tscn
godot --headless --scene tests/stage_6/test_competition.tscn

# Run complete MVP validation
godot --headless --scene tests/mvp/test_complete_game.tscn
```

---

## ⚡ Emergency MVP (3 days)

If extremely time constrained, implement ONLY:
1. Basic Shop (buy 3 creatures for TIM quests)
2. Simple Training (reach required stats)
3. TIM-01 to TIM-03 quests (core loop)
4. Save/Load functionality
5. Skip everything else

This gives a playable vertical slice demonstrating core mechanics.