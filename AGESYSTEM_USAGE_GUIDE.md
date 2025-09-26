# 🕒 AgeSystem Usage Guide

## Overview

The AgeSystem is a GameCore subsystem that manages creature lifecycle progression, age category transitions, and time-based mechanics. It provides comprehensive age management for creature collections with performance optimization for large-scale operations.

## Quick Start

```gdscript
# Get AgeSystem instance
var age_system = GameCore.get_system("age")

# Basic creature aging
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
age_system.age_creature_by_weeks(creature, 26)  # Age by half year
print("Creature is now %s" % age_system.get_category_name(creature.get_age_category()))

# Age to specific category
age_system.age_creature_to_category(creature, 2)  # Adult category
```

## Core Features

### 1. Age Categories & Performance Modifiers

```gdscript
# Age Categories (automatically calculated from lifespan percentage)
# Baby (0-10%): 0.6x performance modifier
# Juvenile (10-25%): 0.8x performance modifier
# Adult (25-75%): 1.0x performance modifier
# Elder (75-90%): 0.8x performance modifier
# Ancient (90%+): 0.6x performance modifier

# Get age information
var category: int = creature.get_age_category()
var modifier: float = creature.get_age_modifier()
var category_name: String = age_system.get_category_name(category)
```

### 2. Age Progression Methods

```gdscript
# Manual aging by weeks
var success: bool = age_system.age_creature_by_weeks(creature, 52)  # 1 year

# Age to specific category
var success: bool = age_system.age_creature_to_category(creature, 2)  # Adult

# Batch aging (optimized for large populations)
var creature_list: Array[CreatureData] = [creature1, creature2, creature3]
var aged_count: int = age_system.age_all_creatures(creature_list, 10)
```

### 3. Lifecycle Event Detection

```gdscript
# Check creature lifecycle status
var is_expired: bool = age_system.is_creature_expired(creature)
var weeks_remaining: int = age_system.get_lifespan_remaining(creature)
var weeks_to_next: int = age_system.get_weeks_until_next_category(creature)

# Age category change detection
var change_info: Dictionary = age_system.check_age_category_change(creature, old_age, new_age)
if change_info.changed:
    print("Category changed from %d to %d" % [change_info.old_category, change_info.new_category])
```

### 4. Population Analysis

```gdscript
# Analyze creature population age distribution
var population: Array[CreatureData] = get_all_creatures()
var distribution: Dictionary = age_system.get_age_distribution(population)

print("Population Analysis:")
print("  Total creatures: %d" % distribution.total_creatures)
print("  Average age: %.1f weeks" % distribution.average_age)
print("  By category: %s" % str(distribution.categories))
print("  Expired count: %d" % distribution.expired_count)
```

### 5. Performance Impact Analysis

```gdscript
# Analyze how age affects creature performance
var impact: Dictionary = age_system.calculate_age_performance_impact(creature)

print("Age Performance Impact:")
print("  Category: %s" % impact.category_name)
print("  Age modifier: %.1fx" % impact.age_modifier)
print("  Life percentage: %.1f%%" % impact.life_percentage)
print("  Performance impact: %.1f%%" % impact.performance_impact)
print("  Weeks remaining: %d" % impact.weeks_remaining)
```

## Integration Patterns

### StatSystem Integration

```gdscript
var stat_system = GameCore.get_system("stat")

# Quest requirements use BASE stats (NO age modifier for fairness)
var quest_strength: int = stat_system.get_effective_stat(creature, "strength")

# Competition stats use age modifiers for realism
var competition_strength: int = stat_system.get_competition_stat(creature, "strength")

print("Base strength: %d, Competition strength: %d (age modifier: %.1fx)" %
      [quest_strength, competition_strength, creature.get_age_modifier()])
```

### SignalBus Integration

```gdscript
var signal_bus = GameCore.get_signal_bus()

# Connect to age-related signals
signal_bus.creature_category_changed.connect(_on_creature_category_changed)
signal_bus.creature_expired.connect(_on_creature_expired)
signal_bus.aging_batch_completed.connect(_on_aging_batch_completed)

func _on_creature_category_changed(creature_data: CreatureData, old_category: int, new_category: int):
    print("%s aged from %s to %s" % [
        creature_data.creature_name,
        age_system.get_category_name(old_category),
        age_system.get_category_name(new_category)
    ])

func _on_creature_expired(creature_data: CreatureData):
    print("%s has died of old age" % creature_data.creature_name)
    # Handle creature removal/memorial logic

func _on_aging_batch_completed(creatures_aged: int, total_weeks: int):
    print("Aged %d creatures by %d weeks" % [creatures_aged, total_weeks])
```

### CreatureGenerator Integration

```gdscript
# Generate creatures and immediately age them
var young_creature: CreatureData = CreatureGenerator.generate_creature_data("wind_dancer")
var old_creature: CreatureData = CreatureGenerator.generate_creature_data("stone_sentinel")

# Age to different life stages
age_system.age_creature_to_category(young_creature, 1)  # Juvenile
age_system.age_creature_to_category(old_creature, 3)   # Elder

# Verify different lifespans are respected
print("Wind Dancer lifespan: %d weeks" % young_creature.lifespan_weeks)
print("Stone Sentinel lifespan: %d weeks" % old_creature.lifespan_weeks)
```

## Performance Optimization

### Batch Operations
```gdscript
# For large creature collections, always use batch methods
var large_population: Array[CreatureData] = []
for i in range(1000):
    large_population.append(generate_random_creature())

# Batch aging (optimized for performance)
var start_time: int = Time.get_ticks_msec()
var aged_count: int = age_system.age_all_creatures(large_population, 5)
var duration: int = Time.get_ticks_msec() - start_time

print("Aged %d creatures in %dms" % [aged_count, duration])  # Should be <100ms
```

### Efficient Analysis
```gdscript
# Population analysis is optimized for large datasets
var start_time: int = Time.get_ticks_msec()
var distribution: Dictionary = age_system.get_age_distribution(large_population)
var duration: int = Time.get_ticks_msec() - start_time

print("Analyzed %d creatures in %dms" % [distribution.total_creatures, duration])
```

## Error Handling & Validation

```gdscript
# AgeSystem provides comprehensive validation
if not age_system.age_creature_by_weeks(creature, -5):  # Invalid
    print("Aging failed: negative weeks not allowed")

if not age_system.age_creature_to_category(creature, -1):  # Invalid
    print("Aging failed: invalid category")

# Validate creature age data
var validation: Dictionary = age_system.validate_creature_age(creature)
if not validation.valid:
    print("Invalid creature age data: %s" % str(validation.errors))
```

## Time System Integration (Ready for Stage 2)

```gdscript
# Placeholder methods ready for Stage 2 Time System
func advance_game_week():
    var age_system = GameCore.get_system("age")

    # This will be implemented when Time System is added
    var aging_summary: Dictionary = age_system.advance_week()
    var events_summary: Dictionary = age_system.process_aging_events()

    print("Weekly aging: %s" % str(aging_summary))
    print("Age events: %s" % str(events_summary))
```

## Best Practices

### 1. Use Batch Operations for Large Collections
```gdscript
# ✅ Good: Batch aging
age_system.age_all_creatures(creature_list, weeks)

# ❌ Avoid: Individual aging in loops
for creature in creature_list:
    age_system.age_creature_by_weeks(creature, weeks)  # Slower
```

### 2. Monitor Performance Impact
```gdscript
# Always consider age modifiers for gameplay balance
func can_creature_handle_quest(creature: CreatureData, quest_requirements: Dictionary) -> bool:
    var stat_system = GameCore.get_system("stat")

    # Use base stats for quest requirements (fair, no age penalty)
    for stat_name in quest_requirements:
        var required: int = quest_requirements[stat_name]
        var actual: int = stat_system.get_effective_stat(creature, stat_name)
        if actual < required:
            return false

    return true

func get_creature_competition_performance(creature: CreatureData) -> float:
    var stat_system = GameCore.get_system("stat")

    # Use age-modified stats for competitions (realistic)
    return stat_system.calculate_performance(creature)
```

### 3. Handle Lifecycle Events Gracefully
```gdscript
func update_creature_roster():
    var expired_creatures: Array[CreatureData] = []

    for creature in active_roster:
        if age_system.is_creature_expired(creature):
            expired_creatures.append(creature)

    # Handle expired creatures appropriately
    for expired in expired_creatures:
        handle_creature_death(expired)
        active_roster.erase(expired)
```

### 4. Validate Before Operations
```gdscript
func safe_age_creature(creature: CreatureData, weeks: int) -> bool:
    # Always validate data before operations
    var validation: Dictionary = age_system.validate_creature_age(creature)
    if not validation.valid:
        print("Cannot age invalid creature: %s" % str(validation.errors))
        return false

    return age_system.age_creature_by_weeks(creature, weeks)
```

## Testing & Debugging

```gdscript
# Enable debug logging for signal validation
var signal_bus = GameCore.get_signal_bus()
signal_bus.set_debug_mode(true)

# Test signal validation (will show red error messages - this is correct!)
signal_bus.emit_creature_aged(null, 10)  # Should error
signal_bus.emit_creature_category_changed(creature, -1, 2)  # Should error

# The red error messages prove validation is working correctly
```

## Migration Notes for Future Stages

- **Stage 2 (Time System)**: `advance_week()` and `process_aging_events()` will be fully implemented
- **Stage 6 (Competition System)**: Age modifiers will affect competition performance calculations
- **Stage 8 (Breeding System)**: Age categories will affect fertility and breeding eligibility
- **UI Integration**: Age display and progression visualization will use AgeSystem data

## Performance Targets

- ✅ **Batch aging**: 1000 creatures in <100ms
- ✅ **Age analysis**: Population distribution in <50ms
- ✅ **Signal validation**: Comprehensive error reporting with minimal overhead
- ✅ **Memory efficiency**: Linear scaling with creature count

The AgeSystem is production-ready and provides a robust foundation for time-based creature management! 🎯