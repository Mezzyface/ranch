# Stage 1: Core Data Models & Foundation - Implementation Guide

## Overview
Stage 1 establishes the fundamental data structures and systems for the creature collection game. This stage focuses on core functionality without UI, creating a solid foundation for future development.

## Goal
Create basic creature management system with stats, tags, aging, and persistence. No gameplay or UI implementation yet - purely foundational data models and systems.

## Task Execution Order

### Phase 1: Project Foundation
**Task 01: Project Setup and Architecture**
- File: `01_project_setup.md`
- Dependencies: None (first task)
- Creates: Project structure, core singletons, basic configuration
- Test: Verify project loads, directories exist, singletons initialize

### Phase 2: Core Data Models
**Task 02: Creature Class Implementation**
- File: `02_creature_class.md`
- Dependencies: Task 01 complete
- Creates: Creature resource class with properties
- Test: Create/modify creatures, validate data integrity

**Task 03: Stat System Implementation**
- File: `03_stat_system.md`
- Dependencies: Tasks 01, 02 complete
- Creates: Stat system with 6 core stats, growth mechanics
- Test: Stat calculations, modifiers, boundaries

**Task 04: Tag System Implementation**
- File: `04_tag_system.md`
- Dependencies: Tasks 01, 02 complete
- Creates: Tag validation, management, and rules
- Test: Tag assignment, validation, exclusions

### Phase 3: Creature Management
**Task 05: Creature Generation System**
- File: `05_creature_generation.md`
- Dependencies: Tasks 02, 03, 04 complete
- Creates: Species-based creature generation
- Test: Generate valid creatures with correct stats/tags

**Task 06: Age System Implementation**
- File: `06_age_system.md`
- Dependencies: Tasks 02, 03 complete
- Creates: Age categories, modifiers, progression
- Test: Age calculations, performance modifiers

**Task 10: Species Resources**
- File: `10_species_resources.md`
- Dependencies: Tasks 02, 03, 04, 05 complete
- Creates: Species resource system for data-driven creatures
- Test: Load species, generate from templates

### Phase 4: Data Persistence
**Task 07: Save/Load System**
- File: `07_save_load_system.md`
- Dependencies: Tasks 02, 05 complete
- Creates: Game state persistence
- Test: Save/load creatures and game state

**Task 08: Player Collection Management**
- File: `08_player_collection.md`
- Dependencies: Tasks 02, 05, 07 complete
- Creates: Active/stable roster management
- Test: Collection operations, limits, queries

**Task 09: Resource Tracking System**
- File: `09_resource_tracking.md`
- Dependencies: Tasks 01, 07 complete
- Creates: Gold, food, and item tracking
- Test: Resource transactions, inventory management

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