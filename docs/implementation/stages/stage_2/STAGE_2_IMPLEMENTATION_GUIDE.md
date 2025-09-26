# Stage 2 Implementation Guide: Time Management & Basic UI

## Executive Summary
Stage 2 transforms the core systems from Stage 1 into a playable game by adding time progression, user interface, and weekly management mechanics. This stage establishes the gameplay loop of managing creatures week by week.

## Prerequisites Checklist
Before starting Stage 2, ensure:
- [ ] Stage 1 Tasks 1-8 fully complete and tested
- [ ] Stage 1 Task 9 (ResourceTracking) complete or near-complete
- [ ] All Stage 1 tests passing
- [ ] GameCore architecture stable and documented
- [ ] SignalBus handling all existing signals properly

## Implementation Order & Dependencies

### Phase 1: Core Systems (Days 1-3)
1. **Task 1: TimeSystem** - No dependencies, start immediately
2. **Task 5: StaminaSystem** - Depends on TimeSystem
3. **Task 6: FoodSystem** - Depends on ResourceTracking (Stage 1 Task 9)

### Phase 2: UI Foundation (Days 4-6)
4. **Task 2: UI Framework** - Can start in parallel with Phase 1
5. **Task 7: Time Controls UI** - Depends on TimeSystem + UI Framework
6. **Task 8: Resource Display UI** - Depends on UI Framework + ResourceTracking

### Phase 3: Creature UI (Days 7-8)
7. **Task 3: Creature Collection UI** - Depends on UI Framework + PlayerCollection
8. **Task 4: Creature Detail Panel** - Depends on Collection UI

### Phase 4: Integration (Days 9-10)
9. **Task 9: Weekly Update System** - Depends on ALL previous systems
10. **Task 10: Integration Testing** - Final validation

## Key Architecture Decisions

### 1. Time Management Philosophy
- **Manual advancement only** - Player controls pacing
- **Weekly granularity** - All updates happen per week
- **Synchronous updates** - All systems update in sequence
- **Rollback capability** - Failed updates can be reverted

### 2. UI Architecture
- **Scene-based navigation** - Each major screen is a scene
- **Component reusability** - Creature cards used everywhere
- **MVC pattern** - UI observes data, doesn't own it
- **Performance first** - Object pooling for dynamic elements

### 3. System Integration Pattern
```gdscript
# Standard weekly update flow
TimeSystem.advance_week()
    -> WeeklyUpdateOrchestrator.execute()
        -> AgeSystem.process_weekly()
        -> StaminaSystem.process_weekly()
        -> FoodSystem.process_weekly()
        -> SaveSystem.auto_save()
    -> SignalBus.week_advanced.emit()
    -> UI.refresh_all_displays()
```

## Critical Implementation Notes

### TimeSystem Gotchas
- Always validate before advancing time
- Block advancement during other operations
- Handle year transitions (week 52 → week 1)
- Maintain performance under 200ms per update

### UI Performance Tips
- Use object pooling for creature cards
- Defer updates outside viewport
- Batch UI updates per frame
- Cache computed display values

### Stamina System Balance
- Active creatures: -20 stamina/week
- Stable creatures: +30 stamina/week
- Exhaustion threshold: 20 stamina
- Activities blocked when exhausted

### Signal Flow for Stage 2
```gdscript
# New critical signals
week_advanced(week: int) -> Updates all UI displays
stamina_depleted(creature: CreatureData) -> Shows warning
food_shortage_warning() -> Blocks time advancement
weekly_update_completed(duration: int) -> Shows summary
```

## Testing Strategy

### Unit Test Coverage Required
- [ ] TimeSystem: Week/month/year calculations
- [ ] StaminaSystem: Depletion and recovery math
- [ ] FoodSystem: Consumption calculations
- [ ] UI: Component isolation tests

### Integration Test Scenarios
1. **52-Week Marathon**: Advance full year without errors
2. **100 Creature Stress**: Performance with large collection
3. **Save/Load Cycle**: Preserve all UI and time state
4. **Rollback Test**: Recover from failed update

### Performance Benchmarks
- Week advancement: <200ms with 100 creatures
- UI refresh: 60 FPS maintained
- Scene transition: <100ms
- Save operation: <300ms with full state

## Common Pitfalls & Solutions

### Problem 1: UI Not Updating
**Symptom**: Data changes but UI doesn't reflect
**Solution**: Ensure SignalBus connections in UI components
```gdscript
func _ready():
    SignalBus.week_advanced.connect(_on_week_advanced)
    SignalBus.collection_changed.connect(_on_collection_changed)
```

### Problem 2: Stamina Going Negative
**Symptom**: Stamina values below 0
**Solution**: Clamp in setter, validate in system
```gdscript
func set_stamina(creature: CreatureData, value: int):
    creature_stamina[creature.id] = clamp(value, MIN_STAMINA, MAX_STAMINA)
```

### Problem 3: Time Advancing During Load
**Symptom**: Week advances while loading save
**Solution**: Block time during system operations
```gdscript
var week_advance_blocked: bool = false
func advance_week() -> bool:
    if week_advance_blocked:
        return false
```

## Success Metrics
- [ ] All 10 tasks implemented and documented
- [ ] 52-week progression test passes
- [ ] UI responsive at 60 FPS with 100 creatures
- [ ] Save/load preserves complete state
- [ ] All Stage 2 signals integrated
- [ ] Performance targets met across all systems
- [ ] Integration tests pass without errors

## Handoff to Stage 3
Stage 2 completion enables:
- **Shop UI Integration** - UI framework ready for shops
- **Training Activities** - Stamina system enables training costs
- **Quest Time Limits** - Time system enables deadlines
- **Food Economy** - Food consumption creates demand

## Quick Reference: File Locations
```
Stage 2 Implementation Files:
├── docs/implementation/stages/stage_2/
│   ├── 00_stage_2_overview.md (this stage plan)
│   ├── 01_time_system.md
│   ├── 02_ui_framework.md
│   ├── 03_creature_collection_ui.md
│   ├── 04_creature_detail_panel.md
│   ├── 05_stamina_system.md
│   ├── 06_food_system.md
│   ├── 07_time_controls_ui.md
│   ├── 08_resource_display_ui.md
│   ├── 09_weekly_update_system.md
│   └── 10_integration_testing.md

Code Files (to be created):
├── scripts/systems/
│   ├── time_system.gd
│   ├── stamina_system.gd
│   └── food_system.gd
├── scripts/ui/
│   ├── ui_manager.gd
│   ├── collection_panel.gd
│   └── creature_card.gd
└── scenes/ui/
    ├── game_ui.tscn
    ├── panels/
    └── components/
```

## Development Workflow
1. **Start with TimeSystem** - Foundation for everything
2. **Build UI Framework early** - Needed for visualization
3. **Implement systems before their UI** - Logic first, display second
4. **Test continuously** - Each system should have tests before moving on
5. **Document signals** - Every new signal needs clear documentation
6. **Profile performance** - Check benchmarks after each system

## Notes for AI Agents
- Follow Stage 1 patterns exactly - consistency is critical
- Use SignalBus for ALL cross-system communication
- Never let Resources emit signals (data/behavior separation)
- Test both success and failure cases
- Include debug modes in all systems
- Document every public method
- Use explicit typing throughout