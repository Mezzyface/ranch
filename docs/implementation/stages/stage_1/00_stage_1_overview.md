# Stage 1: Core Foundation & Architecture - Implementation Guide (v2.0)

## Overview
Stage 1 establishes the proper Godot 4.5 architecture with separated data/behavior layers, a single core manager, robust save systems, and performance-optimized patterns. This foundation ensures scalability and maintainability.

## Goal
Create a properly architected foundation with MVC pattern, separating Resources (data) from Nodes (behavior), implementing a single GameCore manager instead of multiple singletons, and using ConfigFile for robust saves.

## Task Execution Order (Aligned with Actual Files)

### ✅ Task 01: Project Setup & SignalBus (01_project_setup.md) - COMPLETE
- Created: Single GameCore autoload with enhanced SignalBus
- Implemented: Signal validation, connection management, debug logging
- Test: GameCore initializes, SignalBus routes signals with validation

### ✅ Task 02: Creature Class (02_creature_class.md) - COMPLETE
- Created: CreatureData (Resource) + CreatureEntity (Node) separation
- Implemented: Pure data in Resource, behavior in Node, signals via SignalBus
- Verified: Data serialization, stat clamping (1-1000), tag validation
- Test: Architecture validated - CreatureData has NO signals

### 🚀 Task 03: Stat System (03_stat_system.md) - NEXT
- Creates: Stat calculations and modifiers
- Implements: Utility functions for stat operations
- Test: Calculations accurate, boundaries enforced

### Task 04: Tag System (04_tag_system.md)
- Creates: Tag validation and management
- Implements: Tag compatibility checking
- Test: Tag operations, conflict detection

### Task 05: Creature Generation (05_creature_generation.md)
- Creates: Random creature generation logic
- Implements: Species-based generation patterns
- Test: Valid creature creation, stat distribution

### Task 06: Age System (06_age_system.md)
- Creates: Age progression and effects
- Implements: Weekly aging, performance modifiers
- Test: Age transitions, stat impacts

### Task 07: Save/Load System (07_save_load_system.md)
- Creates: ConfigFile-based persistence
- Key Change: NOT using store_var (breaks between versions)
- Test: Save/load cycles, data integrity

### Task 08: Player Collection (08_player_collection.md)
- Creates: Active/stable roster management
- Implements: Collection operations, roster limits
- Test: Collection management, performance

### Task 09: Resource Tracking (09_resource_tracking.md)
- Creates: Economy system for gold/items
- Implements: Transaction system, resource validation
- Test: Economic operations, balance tracking

### Task 10: Species Resources (10_species_resources.md)
- Creates: Species templates as Resources
- Implements: Species data loading, caching
- Test: Template loading, inheritance

### Task 11: Global Enums (11_global_enums.md)
- Creates: Type-safe enumerations
- Implements: Shared constants across systems
- Test: Enum usage, type safety

## Testing Strategy

### Unit Testing Approach
Each task includes specific unit tests that should be run immediately after implementation:
1. Create test scripts in `tests/unit/` directory
2. Test individual functions and methods
3. Verify edge cases and boundaries
4. Document any failures for fixing

### Integration Testing
After completing each phase, run integration tests:
- Phase 1: Verify project structure and singleton communication
- Phase 2: Test creature creation with stats and tags
- Phase 3: Test creature generation and aging together
- Phase 4: Test full save/load cycle with collections

### Manual Testing Checklist
For each completed task:
- [ ] Code runs without errors
- [ ] All test criteria pass
- [ ] No memory leaks detected
- [ ] Performance meets requirements
- [ ] Code follows Godot best practices

## Implementation Guidelines

### Code Standards
- Use GDScript static typing where possible
- Follow Godot naming conventions (snake_case for variables, PascalCase for classes)
- Add comments for complex logic
- Keep functions under 50 lines
- Use signals for loose coupling

### Resource Management
- Use Godot Resources for data that needs serialization
- Preload frequently used resources
- Free resources when no longer needed
- Use resource UIDs for stable references

### Performance Considerations
- Target 60 FPS even with 1000+ creatures
- Use object pooling for frequently created/destroyed objects
- Minimize dictionary lookups in hot paths
- Cache calculated values when appropriate

## Global Systems to Initialize

### Single Autoload: GameCore
Location: `scripts/core/game_core.gd`
- ONLY autoload in the entire project
- Manages all subsystems via lazy loading
- Creates and manages SignalBus

### Subsystems (Lazy-loaded by GameCore, NOT autoloaded)
1. **CreatureSystem** - Manages all creatures
2. **SaveSystem** - ConfigFile-based persistence
3. **StatSystem** - Stat calculations utility
4. **TagSystem** - Tag validation utility
5. **SpeciesSystem** - Species resource caching
6. **CollectionSystem** - Player creature roster
7. **ResourceSystem** - Gold/item economy
8. **QuestSystem** - Quest management

### SignalBus (Created by GameCore)
Location: `scripts/core/signal_bus.gd`
- Centralized signal routing
- Prevents Resources from having signals
- Decouples system communication

## Success Criteria

### Minimum Viable Stage 1
- [ ] Project structure established
- [ ] Creature data model complete
- [ ] Stats and tags functional
- [ ] Creatures can be generated
- [ ] Age system works
- [ ] Data persists through save/load
- [ ] Collections can be managed
- [ ] Resources are tracked

### Quality Metrics
- No critical errors in console
- All unit tests pass (minimum 80% coverage)
- Performance: < 100ms to generate 100 creatures
- Memory: < 100MB RAM with 1000 creatures
- Save/Load: < 1 second for full game state

## Common Issues and Solutions

### Issue: Circular Dependencies
**Solution**: Use dependency injection or signals instead of direct references

### Issue: Save Data Corruption
**Solution**: Implement versioning and validation in save system

### Issue: Performance with Large Collections
**Solution**: Implement pagination and lazy loading

### Issue: Tag Conflicts
**Solution**: Validate tag combinations before assignment

### Issue: Stat Overflow
**Solution**: Clamp all stat modifications to valid ranges

## Next Steps After Stage 1

Once all Stage 1 tasks are complete:
1. Run full integration test suite
2. Profile performance bottlenecks
3. Document any technical debt
4. Create Stage 2 task list
5. Begin UI implementation (Stage 2)

## Notes for Implementers

- Start with Task 01 and proceed in order
- Don't skip dependencies - they build on each other
- Test each task thoroughly before moving on
- If blocked, check design documents for clarification
- Use placeholder data where needed (can refine later)
- Focus on functionality over optimization initially
- Keep implementation simple - complexity comes later

## Time Estimate
Total Stage 1: 25-35 hours
- Phase 1: 4-6 hours
- Phase 2: 8-10 hours
- Phase 3: 8-10 hours
- Phase 4: 6-8 hours
- Testing & Integration: 3-5 hours

## Ready Checklist
Before starting implementation:
- [ ] Godot 4.5 installed and working
- [ ] Git configured for version control
- [ ] All design documents reviewed
- [ ] Stage 1 task files read
- [ ] Test environment prepared
- [ ] Time allocated for implementation