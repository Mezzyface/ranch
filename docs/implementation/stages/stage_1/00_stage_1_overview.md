# Stage 1: Core Foundation & Architecture - Implementation Guide (v2.0)

## Overview
Stage 1 establishes the proper Godot 4.5 architecture with separated data/behavior layers, a single core manager, robust save systems, and performance-optimized patterns. This foundation ensures scalability and maintainability.

## Goal
Create a properly architected foundation with MVC pattern, separating Resources (data) from Nodes (behavior), implementing a single GameCore manager instead of multiple singletons, and using ConfigFile for robust saves.

## Task Execution Order (Revised for Improved Architecture)

### Phase 1: Core Architecture
**Task 01: Project Setup with GameCore**
- Creates: Single GameCore autoload, SignalBus, proper project structure
- Key Change: Only ONE autoload (GameCore), not multiple singletons
- Test: GameCore initializes, subsystems register lazily

**Task 02: SignalBus Implementation**
- Creates: Centralized signal management system
- Key Change: All signals go through SignalBus, not individual Resources
- Test: Signals properly routed between systems

### Phase 2: Data Layer (Resources)
**Task 03: CreatureData Resource**
- Creates: Pure data resource (NO signals)
- Key Change: Just data storage, no behavior
- Test: Serialization/deserialization works

**Task 04: SpeciesData Resource**
- Creates: Species templates as Resources
- Implements: Resource caching system
- Test: Lazy loading performance

**Task 05: Stat & Tag Systems**
- Creates: Stat calculations, tag validation
- Key Change: Implemented as utility classes, not on Resources
- Test: Calculations accurate, validation works

### Phase 3: Controller Layer
**Task 06: CreatureEntity Implementation**
- Creates: Node-based creature behavior controller
- Key Change: Handles signals and behavior (separate from CreatureData)
- Test: Signals emit properly, behavior works

**Task 07: System Controllers**
- Creates: CreatureSystem, QuestSystem as GameCore subsystems
- Key Change: Lazy-loaded, not autoloaded
- Test: Systems register and communicate via SignalBus

### Phase 4: Persistence & State
**Task 08: ConfigFile Save System**
- Creates: Robust save/load using ConfigFile
- Key Change: NOT using store_var (breaks between versions)
- Test: Save migration, version checking

**Task 09: Collection Management**
- Creates: Active/stable roster with proper MVC
- Implements: Object pooling for UI elements
- Test: Performance with 1000+ creatures

**Task 10: Resource Tracking**
- Creates: Economy system for gold/items
- Implements: Efficient resource caching
- Test: Transaction performance

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

### Enums (Autoload as "Enums")
Location: `scripts/utils/Enums.gd`
- Load from `enum.md` specifications
- Contains all global enumerations
- Available to all scripts

### Core Managers (Autoload)
1. **GameManager** - Overall game state
2. **DataManager** - Static data loading
3. **SaveManager** - Persistence
4. **StatManager** - Stat calculations
5. **TagManager** - Tag validation
6. **SpeciesManager** - Species resources
7. **CollectionManager** - Player creatures
8. **ResourceManager** - Gold/items

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