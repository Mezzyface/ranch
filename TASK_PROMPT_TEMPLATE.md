# Task Implementation Prompt Template

## Template Structure

```markdown
# Task [NUMBER]: [TASK_NAME] Implementation

## Prerequisites
- [ ] Previous tasks completed (Tasks 1-[N-1])
- [ ] Run preflight check: `godot --headless --scene tests/preflight_check.tscn`
- [ ] All tests passing: `godot --headless --scene tests/test_all.tscn`

## Task Overview
[Brief description of what this task implements and why it's needed]

## Required Files to Create/Modify

### New Files:
1. `scripts/systems/[system_name].gd` - Main system implementation
2. `tests/individual/test_[system].gd` - Individual test file
3. `tests/individual/test_[system].tscn` - Test scene

### Files to Modify:
1. `scripts/core/game_core.gd` - Add system to lazy loading
2. `scripts/core/signal_bus.gd` - Add new signals if needed
3. `test_setup.gd` - Add comprehensive integration test
4. `tests/test_all.gd` - Add to test suite

## Implementation Requirements

### Core Functionality:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

### Integration Points:
- [ ] GameCore lazy loading integration
- [ ] SignalBus signal definitions and emission methods
- [ ] Save/Load persistence if applicable
- [ ] PlayerCollection integration if applicable

### Data Structure:
```gdscript
# Example data structure
extends Node

var [property_1]: [type] = [default]
var [property_2]: Dictionary = {}

func _init() -> void:
    print("[SystemName] initialized")
```

### Required Methods:
```gdscript
func [method_1]([params]) -> [return_type]:
    # Implementation

func [method_2]([params]) -> void:
    # Implementation
```

## Validation Requirements

### Property Names (CRITICAL):
- Use `id` NOT `creature_id`
- Use `species_id` NOT `species`
- Follow established naming conventions

### Method Patterns:
- Data methods on data classes (CreatureData)
- System methods on system classes
- Use `GameCore.get_system()` for access

### Array Typing:
- ALWAYS use `Array[String]` not `Array`
- ALWAYS use `Array[CreatureData]` not `Array`

### Signal Integration:
- Define signals in SignalBus
- Add emission methods with validation
- Use class-level variables for lambda scope

## Testing Requirements

### Individual Test (`test_[system].gd`):
- [ ] Test all core functionality
- [ ] Test edge cases
- [ ] Test integration points
- [ ] Performance benchmarks if applicable
- [ ] Exit with proper code (0 = pass, 1 = fail)

### Integration Test (in `test_setup.gd`):
- [ ] Add test function `_test_[system]_system()`
- [ ] Use quiet mode logging functions
- [ ] Track results in test_results dictionary

## Performance Targets
- [ ] System initialization: <10ms
- [ ] Core operations: <100ms for 100 items
- [ ] Save/Load: <200ms for full state

## AI Agent Checklist

### Before Starting:
1. Run preflight check - MUST PASS
2. Review API_REFERENCE.md for correct patterns
3. Check SYSTEMS_INTEGRATION_GUIDE.md for integration patterns
4. Enable quiet mode in test_setup.gd

### During Implementation:
1. Use SystemValidator for runtime validation
2. Test frequently with individual tests
3. Check for compilation errors after each file
4. Use explicit typing everywhere

### Before Completion:
1. Run all tests with quiet mode
2. Verify no parse errors
3. Check signal integration works
4. Confirm performance targets met

## Common Pitfalls to Avoid
- ❌ Don't use wrong property names
- ❌ Don't create untyped arrays
- ❌ Don't call methods on wrong systems
- ❌ Don't use .nanosecond for timing
- ❌ Don't access systems directly without get_system()

## Success Criteria
- [ ] All tests pass
- [ ] No compilation errors
- [ ] Performance targets met
- [ ] Signals integrate properly
- [ ] Save/Load works if applicable
- [ ] Documentation updated
```

## How to Use This Template

1. **Copy the template** for each new task
2. **Fill in the placeholders** with task-specific information
3. **Include concrete examples** from existing systems
4. **Add task-specific requirements** not covered in template
5. **Test the prompt** with preflight check before giving to AI

## Key Sections Explained

- **Prerequisites**: Ensures environment is ready
- **Task Overview**: High-level understanding
- **Required Files**: Exact files to create/modify
- **Implementation Requirements**: Detailed specifications
- **Validation Requirements**: Critical patterns to follow
- **Testing Requirements**: How to verify correctness
- **AI Agent Checklist**: Step-by-step for AI agents
- **Common Pitfalls**: Specific errors to avoid
- **Success Criteria**: Definition of done