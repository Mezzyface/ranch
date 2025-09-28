# Parallel Prompt Generation Template

## Process for Creating Parallel Implementation Prompts

### Step 1: Feature Analysis
1. Identify the main feature requirements
2. Break down into independent components
3. Identify shared dependencies
4. Determine execution order (parallel vs sequential)

### Step 2: Component Separation
Divide the feature into parallel-safe components:
- **UI Components**: Separate scenes/controls that don't conflict
- **System Logic**: Independent backend systems
- **Data Structures**: Non-overlapping data models
- **Visual Elements**: Sprites, animations, effects
- **Integration Layer**: Final wiring (runs after parallel tasks)

### Step 3: Prompt Structure Template

```markdown
# [Feature Name] Implementation - Parallel Prompts

## Overview
[Brief description of the feature and its goals]

## Prompt [N]: [Component Name] (Can run in parallel)

You are working on a Godot 4 project. [Component description]

CONTEXT:
- [List relevant existing files/systems]
- [Key integration points]
- [Dependencies]

REQUIREMENTS:
1. [Specific requirement]
2. [Specific requirement]
3. [Expected behavior]
4. [Integration points]

IMPLEMENTATION STRUCTURE:
[Scene tree or code structure example]

Files to create:
- [New file paths]

Files to modify:
- [Existing files that need updates]

IMPLEMENTATION NOTES:
- [Key technical details]
- [Gotchas to avoid]
- [Testing considerations]
```

### Step 4: Dependency Mapping

Create a dependency chart:
```
Parallel Group 1:
├── Component A (no dependencies)
├── Component B (no dependencies)
└── Component C (no dependencies)

Sequential:
└── Integration Component (depends on A, B, C)
```

### Step 5: Testing Sequence

Include testing steps:
1. Individual component tests
2. Integration test after parallel completion
3. Full feature test
4. Edge case validation

---

## Example Features for Parallel Implementation

### Shop System
**Parallel Components:**
1. Shop UI layout and display
2. Shop inventory management system
3. Purchase validation logic
4. Shop keeper NPC sprites/animations

**Sequential:**
5. Integration with game economy

### Battle System
**Parallel Components:**
1. Battle UI and animations
2. Combat calculation engine
3. Enemy AI system
4. Battle effects and particles

**Sequential:**
5. Battle flow controller

### Quest System
**Parallel Components:**
1. Quest UI and journal
2. Quest data structures and storage
3. Quest tracking system
4. Quest reward system

**Sequential:**
5. Quest progression integration

### Breeding System
**Parallel Components:**
1. Breeding UI interface
2. Genetics calculation system
3. Breeding animation/effects
4. Offspring generation logic

**Sequential:**
5. Integration with collection system

### World Map
**Parallel Components:**
1. Map rendering and navigation
2. Location data system
3. Fast travel UI
4. Map markers and icons

**Sequential:**
5. Map state persistence

---

## Prompt Generation Checklist

Before creating parallel prompts, verify:

- [ ] Components are truly independent
- [ ] No shared file modifications between parallel tasks
- [ ] Context includes all necessary information
- [ ] Each prompt is self-contained
- [ ] Integration prompt clearly depends on parallel completion
- [ ] Testing sequence is defined
- [ ] File paths are absolute and correct
- [ ] Godot scene structure is provided where relevant
- [ ] Signal/event flow is documented
- [ ] Performance considerations noted

## Common Patterns

### UI Component Pattern
```
- Create scene file (.tscn)
- Create controller script (.gd)
- Add to SignalBus if needed
- Connect to existing systems via GameCore
- Test in isolation
```

### System Component Pattern
```
- Create system script in scripts/systems/
- Add to GameCore loader
- Implement ISaveable if persistent
- Add unit test in tests/individual/
- Document public API
```

### Integration Pattern
```
- Wire signals between components
- Add to main game flow
- Update save/load if needed
- Verify performance
- Add integration test
```

## Notes for AI Agents

When given a feature request:

1. **Analyze first** - Don't immediately start coding
2. **Identify parallelizable work** - Look for independent components
3. **Create focused prompts** - Each should be 1-2 hours of work max
4. **Include all context** - Prompts must be self-contained
5. **Test independently** - Each component should work standalone
6. **Document integration** - Clear instructions for combining components

This approach enables:
- Faster development through parallelization
- Reduced merge conflicts
- Better testing isolation
- Clearer component boundaries
- Easier debugging
```