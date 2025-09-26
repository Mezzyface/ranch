# Stage 2 Execution Prompts

## How to Use These Prompts
1. Copy the prompt exactly as written
2. Run preflight check first to ensure readiness
3. Execute tasks in the recommended order
4. Use validation prompts after each task completion

---

## 🔍 PREFLIGHT CHECK (Run First!)

```
Please run the Stage 2 preflight check to verify all prerequisites are met:

1. Run: godot --headless --scene tests/stage_2_preflight.gd
2. Review the output and address any failures or warnings
3. Ensure all Stage 1 tests pass: godot --headless --scene tests/test_all.tscn
4. Report the preflight results summary

Only proceed with Stage 2 implementation if the preflight check shows "READY FOR STAGE 2 IMPLEMENTATION".
```

---

## 📋 TASK EXECUTION PROMPTS

### Task 1: TimeSystem Implementation

```
Please implement Stage 2 Task 1: TimeSystem by following docs/implementation/stages/stage_2/01_time_system.md

Requirements:
1. Create TimeSystem as a GameCore subsystem using lazy loading pattern
2. Implement weekly time progression with manual advancement only
3. Add event scheduling system for weekly events
4. Integrate with SignalBus for week_advanced, month_completed, year_completed signals
5. Create weekly update trigger that will call other systems
6. Add save/load integration to persist time state
7. Include debug commands for time manipulation
8. Create tests/individual/test_time.gd with comprehensive tests

Success Criteria:
- TimeSystem loads via GameCore.get_system("time")
- advance_week() processes in <200ms with 100 creatures
- 52-week progression completes without errors
- All time-related signals emit properly
- Save/load preserves time state correctly

Follow the patterns from Stage 1 exactly. Test compilation after each file creation.
```

### Task 2: UI Framework Foundation (Can run parallel with Task 1)

```
Please implement Stage 2 Task 2: UI Framework Foundation by following docs/implementation/stages/stage_2/02_ui_framework.md

Requirements:
1. Create scenes/ui/game_ui.tscn with proper scene structure
2. Implement UIManager for scene transitions and window management
3. Create default theme resource with consistent styling
4. Set up responsive layout system with anchors and containers
5. Add keyboard navigation support and input mappings
6. Implement notification and dialog systems
7. Ensure 60 FPS performance with full UI

File Structure:
- scenes/ui/main_menu.tscn
- scenes/ui/game_ui.tscn
- scripts/ui/ui_manager.gd
- scripts/ui/scene_transition.gd
- resources/themes/default_theme.tres

Success Criteria:
- Scene transitions complete in <100ms
- UI maintains 60 FPS with all panels open
- Responsive layout adapts to window resize
- Theme applies consistently across all elements

Test the UI visually by running: godot scenes/ui/game_ui.tscn
```

### Task 3: Creature Collection UI (Requires Task 2)

```
Please implement Stage 2 Task 3: Creature Collection UI by following docs/implementation/stages/stage_2/03_creature_collection_ui.md

Requirements:
1. Create collection panel with active roster (6 slots) and stable list
2. Implement creature cards showing name, stats, stamina bars
3. Add drag-and-drop functionality between active and stable
4. Connect to PlayerCollection system for data
5. Update display when SignalBus.collection_changed emits
6. Add search and filter functionality for stable creatures
7. Ensure smooth scrolling with 100+ creatures

Components to Create:
- scenes/ui/panels/collection_panel.tscn
- scenes/ui/components/creature_card.tscn
- scripts/ui/collection_panel.gd
- scripts/ui/creature_card.gd

Success Criteria:
- Displays all creatures from PlayerCollection correctly
- Drag-and-drop swaps creatures between rosters
- Updates immediately when collection changes
- Smooth performance with large collections

Test by generating 100 creatures and viewing in the UI.
```

### Task 4: Creature Detail Panel (Requires Task 3)

```
Please implement Stage 2 Task 4: Creature Detail Panel by following docs/implementation/stages/stage_2/04_creature_detail_panel.md

Requirements:
1. Create detailed view showing all creature information
2. Display all stats with base and modified values
3. Show age category and weeks until next transition
4. List all tags with category grouping
5. Show stamina bar and exhaustion status
6. Add action buttons (move to active/stable, feed, etc.)
7. Update dynamically when creature data changes

Create a panel that opens when double-clicking a creature card.
Include close button and escape key handling.
```

### Task 5: StaminaSystem Implementation (Requires Task 1)

```
Please implement Stage 2 Task 5: StaminaSystem by following docs/implementation/stages/stage_2/05_stamina_system.md

Requirements:
1. Create StaminaSystem as GameCore subsystem
2. Track stamina (0-100) for each creature
3. Implement weekly depletion for active creatures (-20/week)
4. Implement recovery for stable creatures (+30/week)
5. Add exhaustion threshold at 20 stamina
6. Block activities when creatures are exhausted
7. Integrate with TimeSystem for weekly updates
8. Add food-based stamina restoration methods

Success Criteria:
- Weekly stamina updates process automatically
- Exhausted creatures cannot perform activities
- Food items restore stamina correctly
- Performance: Update 100 creatures in <50ms

Test with: godot --headless --scene tests/individual/test_stamina.gd
```

### Task 6: FoodSystem Implementation (Requires Task 9 from Stage 1)

```
Please implement Stage 2 Task 6: FoodSystem by following docs/implementation/stages/stage_2/06_food_system.md

Requirements:
1. Create FoodSystem managing food inventory
2. Implement weekly consumption for active creatures
3. Add different food types with varying effects
4. Integrate with StaminaSystem for restoration
5. Block time advancement if insufficient food
6. Add food spoilage mechanics (optional)
7. Connect to ResourceTracking for inventory

IMPORTANT: This requires Stage 1 Task 9 (ResourceTracking) to be complete!

Success Criteria:
- Tracks multiple food types and quantities
- Calculates weekly consumption correctly
- Prevents starvation with warnings
- Integrates with creature feeding
```

### Task 7: Time Controls UI (Requires Tasks 1 & 2)

```
Please implement Stage 2 Task 7: Time Controls UI by following docs/implementation/stages/stage_2/07_time_controls_ui.md

Requirements:
1. Create time display showing current week/month/year
2. Add "Advance Week" button with confirmation dialog
3. Show upcoming events preview
4. Display weekly summary after advancement
5. Add keyboard shortcut (Space) for time advance
6. Block advancement when conditions aren't met
7. Show time advancement animation/transition

Connect to TimeSystem and show blocking reasons if advancement fails.
```

### Task 8: Resource Display UI (Requires Tasks 2 & Stage 1 Task 9)

```
Please implement Stage 2 Task 8: Resource Display UI by following docs/implementation/stages/stage_2/08_resource_display_ui.md

Requirements:
1. Create resource bar showing gold amount
2. Display food inventory summary
3. Show creature count (active/stable/total)
4. Preview weekly costs (food, gold)
5. Animate value changes smoothly
6. Flash warnings for low resources
7. Update in real-time as resources change

Place in top or bottom bar of main UI for constant visibility.
```

### Task 9: Weekly Update System (Requires Tasks 1, 5, 6)

```
Please implement Stage 2 Task 9: Weekly Update Orchestrator by following docs/implementation/stages/stage_2/09_weekly_update_system.md

Requirements:
1. Create orchestrator to coordinate all weekly updates
2. Define update phases in correct order:
   - Pre-update validation
   - Age progression
   - Stamina updates
   - Food consumption
   - Save state
3. Implement rollback on failure
4. Generate weekly summary report
5. Emit signals for each phase
6. Handle missing systems gracefully

Success Criteria:
- All systems update in correct sequence
- Failed updates roll back cleanly
- Summary shows all changes
- Complete update in <200ms for 100 creatures

This is the integration point for all Stage 2 systems!
```

### Task 10: Integration Testing (Final Task)

```
Please implement Stage 2 Task 10: Integration Testing by following docs/implementation/stages/stage_2/10_integration_testing.md

Requirements:
1. Create comprehensive integration tests
2. Test 52-week progression without errors
3. Verify save/load with all Stage 2 systems
4. Test UI responsiveness with 100+ creatures
5. Validate all signals connect properly
6. Check performance benchmarks
7. Create stage_2_complete.gd validation script

Run all tests and ensure Stage 2 is fully functional before proceeding to Stage 3.
```

---

## ✅ VALIDATION PROMPTS

### After Each Task:

```
Please validate the completed [TASK NAME] implementation:

1. Run compilation check: godot --check-only project.godot
2. Run specific test: godot --headless --scene tests/individual/test_[system].gd
3. Check for warnings in console
4. Verify performance meets targets
5. Ensure save/load integration works
6. Confirm SignalBus signals emit correctly
7. Document any issues encountered

Report: "Task [NUMBER] validation [PASSED/FAILED]" with details.
```

### Final Stage 2 Validation:

```
Please run complete Stage 2 validation:

1. Run all Stage 2 tests: godot --headless --scene tests/stage_2/test_all_stage_2.tscn
2. Execute 52-week progression test
3. Test save/load with full game state
4. Verify UI maintains 60 FPS
5. Check all performance benchmarks:
   - Week advancement: <200ms
   - UI refresh: <16ms per frame
   - Scene transition: <100ms
6. Generate Stage 2 completion report

Stage 2 is complete when all validations pass.
```

---

## 🚀 PARALLEL EXECUTION STRATEGY

### For Multiple Agents:

```
Agent 1: Please implement Stage 2 Task 1 (TimeSystem) following the documentation exactly.
Agent 2: Please implement Stage 2 Task 2 (UI Framework) following the documentation exactly.

Both agents should:
- Follow Stage 1 patterns
- Test after each file creation
- Use SignalBus for all signals
- Report completion status

After both complete, proceed with dependent tasks.
```

---

## 🔧 TROUBLESHOOTING PROMPTS

### If Build Fails:

```
The build is failing. Please:
1. Show the exact error message
2. Check for missing files or typos
3. Verify all class_name declarations are correct
4. Ensure proper node paths in scenes
5. Fix the issue and test again
```

### If Tests Fail:

```
Tests are failing for [SYSTEM NAME]. Please:
1. Run the test with verbose output
2. Identify the specific assertion that fails
3. Add debug prints to trace the issue
4. Fix the bug and verify all tests pass
5. Ensure no regression in other tests
```

### If Performance Issues:

```
Performance target not met for [SYSTEM NAME]. Please:
1. Profile the slow operation
2. Identify bottlenecks with timers
3. Implement optimization (caching, batching, etc.)
4. Re-test performance
5. Document the optimization made
```

---

## 📝 NOTES FOR BEST RESULTS

1. **Always run preflight first** - Don't skip this step
2. **Execute in order** - Respect task dependencies
3. **Test continuously** - Validate after each task
4. **Follow patterns exactly** - Consistency with Stage 1 is critical
5. **Document issues** - Help future implementations
6. **Commit frequently** - Save progress after each working task

These prompts are designed to be clear, specific, and actionable for AI agents to execute Stage 2 successfully.