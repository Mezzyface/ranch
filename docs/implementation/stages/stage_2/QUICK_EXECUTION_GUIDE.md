# Stage 2 Quick Execution Guide

## 🚀 Copy-Paste Ready Prompts

### Start Here - Preflight Check
```
Run godot --headless --scene tests/stage_2_preflight.gd and verify all prerequisites pass. Only proceed if you see "READY FOR STAGE 2 IMPLEMENTATION".
```

---

## Phase 1: Core Systems (Can Run in Parallel)

### Prompt 1A - TimeSystem
```
Implement TimeSystem from docs/implementation/stages/stage_2/01_time_system.md. Create a GameCore subsystem with weekly advancement, event scheduling, and signals: week_advanced, month_completed, year_completed. Must process weekly updates in <200ms for 100 creatures. Test with: godot --headless --scene tests/individual/test_time.gd
```

### Prompt 1B - UI Framework (Parallel)
```
Implement UI Framework from docs/implementation/stages/stage_2/02_ui_framework.md. Create scenes/ui/game_ui.tscn with UIManager singleton, theme system, and responsive layouts. Maintain 60 FPS. Test visually with: godot scenes/ui/game_ui.tscn
```

---

## Phase 2: Dependent Systems

### Prompt 2A - StaminaSystem (After TimeSystem)
```
Implement StaminaSystem from docs/implementation/stages/stage_2/05_stamina_system.md. Track stamina 0-100, deplete -20/week for active, restore +30/week for stable. Integrate with TimeSystem weekly updates. Test with: godot --headless --scene tests/individual/test_stamina.gd
```

### Prompt 2B - Collection UI (After UI Framework)
```
Implement Creature Collection UI from docs/implementation/stages/stage_2/03_creature_collection_ui.md. Create 6-slot active roster and scrollable stable list with drag-and-drop. Connect to PlayerCollection data. Must handle 100+ creatures smoothly.
```

---

## Phase 3: Integration Systems

### Prompt 3A - FoodSystem
```
Implement FoodSystem from docs/implementation/stages/stage_2/06_food_system.md. Requires ResourceTracking from Stage 1 Task 9. Manage food inventory, weekly consumption, and stamina restoration. Block time advancement if insufficient food.
```

### Prompt 3B - Time Controls UI
```
Implement Time Controls UI from docs/implementation/stages/stage_2/07_time_controls_ui.md. Show week/month/year, add "Advance Week" button with confirmation, display blocking reasons if cannot advance. Connect to TimeSystem.
```

---

## Phase 4: Final Integration

### Prompt 4A - Weekly Update Orchestrator
```
Implement Weekly Update System from docs/implementation/stages/stage_2/09_weekly_update_system.md. Coordinate all systems in order: validate, age, stamina, food, save. Include rollback on failure. Generate summary reports. Complete in <200ms.
```

### Prompt 4B - Final Validation
```
Run complete Stage 2 validation: Test 52-week progression, verify save/load preserves all state, confirm 60 FPS maintained, check all performance targets met. Run: godot --headless --scene tests/stage_2/test_all_stage_2.tscn
```

---

## 🎯 Minimal Viable Stage 2 (If Time Constrained)

### Essential Only (3 Tasks):
```
1. Implement TimeSystem with manual week advancement
2. Implement basic UI framework with creature display
3. Implement Weekly Update Orchestrator to connect systems
Test with 52-week progression. This gives you time management without full features.
```

---

## ⚡ Rapid Parallel Execution (2 Agents)

### Agent 1:
```
Implement TimeSystem (Task 1), then StaminaSystem (Task 5), then FoodSystem (Task 6), then Weekly Update Orchestrator (Task 9). Follow docs in stages/stage_2/. Test each system before proceeding.
```

### Agent 2:
```
Implement UI Framework (Task 2), then Collection UI (Task 3), then Time Controls UI (Task 7), then Resource Display UI (Task 8). Follow docs in stages/stage_2/. Ensure 60 FPS maintained.
```

---

## 🔍 Quick Validation Commands

```bash
# After each task
godot --check-only project.godot

# Test specific system
godot --headless --scene tests/individual/test_[system].gd

# Test all Stage 2
godot --headless --scene tests/stage_2/test_all.tscn

# Visual UI test
godot scenes/ui/game_ui.tscn

# Performance test
godot --headless --scene tests/stage_2/benchmark.tscn
```

---

## 🚨 If Something Breaks

```
Fix compilation error: Check class_name conflicts, ensure no Resources emit signals, verify node paths
Fix test failure: Add debug prints, check signal connections, verify data initialization
Fix performance: Profile with timers, batch operations, use object pooling
Fix UI issues: Check anchors, verify theme application, test different resolutions
```

---

## ✅ Definition of Done

Stage 2 is complete when:
- [ ] TimeSystem advances weeks without errors
- [ ] UI displays creatures and stats at 60 FPS
- [ ] Stamina depletes/recovers weekly
- [ ] Food consumption works
- [ ] 52-week test passes
- [ ] Save/load preserves everything
- [ ] All performance targets met