# 🎯 Stage 1 Task 6: Age System Implementation

You are implementing Stage 1 Task 6 of a creature collection game in Godot 4.5. Build upon the proven architecture patterns established in the previous 5 completed tasks.

## 📋 Current Project Status

- ✅ **Task 1 COMPLETE**: GameCore autoload with enhanced SignalBus
- ✅ **Task 2 COMPLETE**: CreatureData/CreatureEntity separation with robust MVC architecture
- ✅ **Task 3 COMPLETE**: Advanced StatSystem with modifiers, age mechanics, and quest validation (0ms performance)
- ✅ **Task 4 COMPLETE**: Comprehensive TagSystem with validation, dependencies, and quest integration (25 tags, 0ms filtering)
- ✅ **Task 5 COMPLETE**: CreatureGenerator with 4 species, 4 algorithms, and performance optimization (<100ms for 1000 creatures)
- 🚀 **Task 6 NEXT**: Age System for creature lifecycle progression and time-based mechanics

**Architecture**: Proven MVC pattern, centralized SignalBus, lazy-loaded subsystems, 45% Stage 1 complete

## 🎯 Implementation Task

Implement Task 6: Age System for creature lifecycle progression, building upon existing age foundations in CreatureData.

## 🔧 Key Requirements

### 1. AgeSystem GameCore Subsystem

**Location**: `scripts/systems/age_system.gd`
- **GameCore subsystem** (loaded via lazy loading like StatSystem, TagSystem)
- **Manages creature aging progression** and lifecycle events
- **Integrates with existing age mechanics** in CreatureData
- **Weekly progression cycles** for time-based advancement
- **Age category transitions** with performance modifier updates

### 2. Age Categories & Mechanics (Already Defined in CreatureData)

**5 Age Categories** with performance modifiers:
- **Baby** (0-10% of lifespan): 0.6x modifier
- **Juvenile** (10-25% of lifespan): 0.8x modifier
- **Adult** (25-75% of lifespan): 1.0x modifier
- **Elder** (75-90% of lifespan): 0.8x modifier
- **Ancient** (90%+ of lifespan): 0.6x modifier

**Existing CreatureData Properties** (DO NOT CHANGE):
- `age_weeks: int = 0` - Current age in weeks
- `lifespan_weeks: int = 520` - Total lifespan (species-dependent)
- `get_age_category() -> int` - Returns 0-4 for age category
- `get_age_modifier() -> float` - Returns performance modifier

### 3. Age Progression Features

#### **Manual Aging Methods**:
- `age_creature_by_weeks(creature_data: CreatureData, weeks: int)` - Manual aging
- `age_creature_to_category(creature_data: CreatureData, target_category: int)` - Age to specific category
- `age_all_creatures(creature_list: Array[CreatureData], weeks: int)` - Batch aging

#### **Lifecycle Event Detection**:
- `check_age_category_change(creature_data: CreatureData, old_age: int, new_age: int)` - Detect transitions
- `is_creature_expired(creature_data: CreatureData)` - Check if past lifespan
- `get_weeks_until_next_category(creature_data: CreatureData)` - Time to next category

#### **Age Statistics & Analysis**:
- `get_age_distribution(creature_list: Array[CreatureData])` - Population age analysis
- `get_lifespan_remaining(creature_data: CreatureData)` - Weeks left to live
- `calculate_age_performance_impact(creature_data: CreatureData)` - Modifier effects

### 4. SignalBus Integration

**Age-Related Signals** (already defined in SignalBus):
- `creature_aged(data: CreatureData, new_age: int)` - Basic aging signal
- **NEW signals to add**:
  - `creature_category_changed(data: CreatureData, old_category: int, new_category: int)`
  - `creature_expired(data: CreatureData)` - Death from old age
  - `aging_batch_completed(creatures_aged: int, total_weeks: int)`

### 5. StatSystem Integration

**Age Modifier Application**:
- **Quest requirements**: Use base stats (NO age modifiers) - ALREADY IMPLEMENTED
- **Competition stats**: Apply age modifiers for performance - ALREADY IMPLEMENTED
- **Age transitions**: Update StatSystem when age category changes
- **Performance calculations**: Age affects effective stats for competitions

### 6. Time Integration Preparation

**Weekly Progression Support**:
- `advance_week()` - Advance all active creatures by 1 week
- `process_aging_events()` - Handle age category changes and expiration
- **Time System hooks** (placeholder for Stage 2 Time System)
- **Batch processing** for efficiency with large creature collections

## 📚 Apply Established Architecture Patterns

### From Task 1-5 Success:
- **GameCore integration** through lazy loading subsystem pattern
- **SignalBus validation** for error handling and debugging
- **Data/Behavior separation** - AgeSystem modifies CreatureData, emits through SignalBus
- **Explicit typing** to avoid Godot 4.5 warnings
- **Comprehensive test coverage** with performance validation
- **StatSystem integration** for modifier updates

### Critical Architecture Rules:
1. **AgeSystem is GameCore subsystem** (like StatSystem, TagSystem)
2. **Use existing CreatureData age properties** - do NOT add new properties
3. **Integrate with StatSystem** for performance modifier updates
4. **Signal validation** through SignalBus emission helpers
5. **Maintain performance standards** from previous tasks

## 🧪 Testing Requirements

### Update `test_setup.gd` with comprehensive tests:

1. **Basic Age Progression** - Manual aging and category transitions
2. **Age Category Detection** - Transitions between Baby→Adult→Elder
3. **Lifecycle Events** - Category changes and expiration detection
4. **SignalBus Integration** - Age-related signal emission and validation
5. **StatSystem Integration** - Age modifier effects on performance
6. **Batch Processing** - Multiple creature aging efficiency
7. **Edge Case Handling** - Aging beyond lifespan, negative values
8. **Performance Validation** - Large-scale aging operations
9. **CreatureGenerator Integration** - Aging generated creatures
10. **Species Lifespan Variety** - Different lifespans (260-780 weeks)

## 🎯 Success Criteria

✅ **AgeSystem loads via GameCore lazy loading**
✅ **All age progression methods work correctly**
✅ **Age category transitions emit proper signals**
✅ **StatSystem integration updates performance modifiers**
✅ **SignalBus validation prevents invalid age operations**
✅ **Batch aging handles large creature collections efficiently**
✅ **Lifecycle events (expiration) detected correctly**
✅ **CreatureGenerator integration - aging generated creatures**
✅ **Species lifespan variety respected (4 different lifespans)**
✅ **Performance standards maintained (efficient batch operations)**

## 🏗️ Implementation Order

1. **Create AgeSystem class structure** with GameCore subsystem pattern
2. **Implement basic age progression methods** (manual aging)
3. **Add age category transition detection** and signaling
4. **Integrate with StatSystem** for performance modifier updates
5. **Create lifecycle event detection** (expiration handling)
6. **Add batch processing methods** for multiple creatures
7. **Implement age analysis and statistics** methods
8. **Create comprehensive test suite** in test_setup.gd
9. **Performance testing and optimization** for batch operations
10. **Integration validation** with existing systems

## ⚠️ Critical Implementation Notes

### Existing Infrastructure to Use:
- **CreatureData age properties**: `age_weeks`, `lifespan_weeks`, `get_age_category()`, `get_age_modifier()`
- **StatSystem age integration**: `get_competition_stat()` already applies age modifiers
- **SignalBus patterns**: Use emission helpers for validation
- **GameCore loading**: Follow lazy loading pattern from StatSystem/TagSystem

### Performance Considerations:
- **Batch operations** for aging multiple creatures
- **Efficient category change detection** without redundant calculations
- **Signal emission optimization** for mass aging events
- **Memory management** for large creature collections

### Future Integration Points:
- **Time System integration** (Stage 2) - weekly advancement hooks
- **UI integration** (Stage 2) - age display and progression visualization
- **Competition System** (Stage 6) - age-modified performance
- **Breeding System** (Stage 8) - age requirements and fertility

## 🚀 Building on Proven Foundation

The previous 5 tasks provide excellent patterns to follow:

- ✅ **Task 1**: GameCore subsystem loading and SignalBus integration
- ✅ **Task 2**: Data/Behavior separation and signal architecture
- ✅ **Task 3**: StatSystem performance optimization and modifier management
- ✅ **Task 4**: TagSystem validation patterns and comprehensive testing
- ✅ **Task 5**: CreatureGenerator integration and performance standards

Use these established patterns to implement a robust AgeSystem that extends the creature lifecycle mechanics while maintaining architectural consistency!

## 📖 Reference Documents

- **Full specification**: `docs/implementation/stages/stage_1/06_age_system.md`
- **Architecture guide**: `CLAUDE.md` (see Task 1-5 lessons learned)
- **CreatureData class**: `scripts/data/creature_data.gd` (existing age properties)
- **StatSystem integration**: `scripts/systems/stat_system.gd` (age modifier patterns)

Follow the detailed specifications and build upon the solid foundation established in Tasks 1-5! The architecture patterns are proven to work - apply them consistently for another successful implementation! 🎯

## 🎉 Expected Outcome

Upon completion of Task 6, you will have:
- **Complete creature lifecycle management** with age progression
- **Seamless integration** with StatSystem for age-modified performance
- **Robust signal architecture** for age-related events
- **Efficient batch processing** for large creature populations
- **Comprehensive testing** ensuring reliability and performance
- **Ready for Stage 2** Time System integration

**Stage 1 Progress: 6/11 tasks complete (~55%) - Over halfway to completion!**