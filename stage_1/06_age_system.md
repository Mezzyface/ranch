# Task 06: Age System Implementation

## Overview
Implement the age system that tracks creature aging, manages age categories, applies performance modifiers, and handles lifespan mechanics.

## Dependencies
- Task 02: Creature Class (complete)
- Task 03: Stat System (complete)
- Design documents: `creature.md`, `time.md`

## Context
From the design documents:
- Creatures age weekly when active
- Age affects performance (young +10%, adult 0%, elder -10%)
- Three age categories: Young (0-20%), Adult (20-80%), Elder (80-100%)
- Creatures have species-specific lifespans
- Aging only occurs for active creatures

## Requirements

### Age Categories
1. **Young** (0-20% of lifespan)
   - Performance bonus: +10%
   - Higher stamina recovery
   - Faster training gains
   - Lower breeding success

2. **Adult** (20-80% of lifespan)
   - No performance modifiers
   - Standard stamina recovery
   - Optimal breeding age
   - Peak performance period

3. **Elder** (80-100% of lifespan)
   - Performance penalty: -10%
   - Slower stamina recovery
   - Reduced training effectiveness
   - Lower breeding success

### Age Mechanics
1. **Weekly Aging**
   - Only active creatures age
   - Stable creatures don't age
   - Age increases by 1 week per time advance

2. **Performance Modifiers**
   - Apply to competition scores
   - Apply to quest validation
   - Don't affect base stats

3. **Death Mechanics**
   - Creatures can exceed lifespan
   - Increased mortality chance past 100%
   - Special handling for story creatures

## Implementation Steps

1. **Enhance Age System in Creature**
   - Age progression methods
   - Category calculation
   - Modifier application

2. **Create AgeManager**
   - Age all active creatures
   - Calculate modifiers
   - Handle mortality

3. **Integrate with Time System**
   - Hook into weekly progression
   - Update creature ages
   - Apply age effects

4. **Add UI Indicators**
   - Age display formatting
   - Category indicators
   - Lifespan progress

## Test Criteria

### Unit Tests
- [ ] Age categories calculate correctly
- [ ] Young creatures get +10% modifier
- [ ] Adult creatures get 0% modifier
- [ ] Elder creatures get -10% modifier
- [ ] Age only increases when active
- [ ] Stable creatures don't age

### Age Progression Tests
- [ ] Creatures age 1 week per time advance
- [ ] Age categories transition at correct percentages
- [ ] Lifespan calculations are accurate
- [ ] Mortality chance increases past 100%

### Integration Tests
- [ ] Age modifiers apply to performance scores
- [ ] Training effectiveness reduced for elders
- [ ] Stamina recovery varies by age
- [ ] Age persists through save/load

## Code Implementation

### Enhanced Creature Age Methods (`scripts/creatures/creature_age_extensions.gd`)
```gdscript
# Extension methods for Creature class age functionality
extends RefCounted

static func get_age_percentage(creature: Creature) -> float:
    if creature.lifespan <= 0:
        return 0.0
    return (float(creature.age_weeks) / float(creature.lifespan)) * 100.0

static func get_age_category_detailed(creature: Creature) -> Dictionary:
    var percentage = get_age_percentage(creature)
    var category = creature.get_age_category()

    return {
        "category": category,
        "percentage": percentage,
        "weeks_in_category": _get_weeks_in_current_category(creature),
        "weeks_until_next": _get_weeks_until_next_category(creature),
        "description": _get_age_description(category, percentage)
    }

static func _get_weeks_in_current_category(creature: Creature) -> int:
    var percentage = get_age_percentage(creature)

    if percentage < 20:  # Young
        return creature.age_weeks
    elif percentage < 80:  # Adult
        return creature.age_weeks - int(creature.lifespan * 0.2)
    else:  # Elder
        return creature.age_weeks - int(creature.lifespan * 0.8)

static func _get_weeks_until_next_category(creature: Creature) -> int:
    var percentage = get_age_percentage(creature)

    if percentage < 20:  # Young -> Adult
        return int(creature.lifespan * 0.2) - creature.age_weeks
    elif percentage < 80:  # Adult -> Elder
        return int(creature.lifespan * 0.8) - creature.age_weeks
    else:  # Elder -> End
        return creature.lifespan - creature.age_weeks

static func _get_age_description(category: Creature.AgeCategory, percentage: float) -> String:
    match category:
        Creature.AgeCategory.YOUNG:
            if percentage < 10:
                return "Newborn"
            else:
                return "Young"
        Creature.AgeCategory.ADULT:
            if percentage < 40:
                return "Young Adult"
            elif percentage < 60:
                return "Prime Adult"
            else:
                return "Mature Adult"
        Creature.AgeCategory.ELDER:
            if percentage < 90:
                return "Elder"
            elif percentage < 100:
                return "Ancient"
            else:
                return "Venerable"
        _:
            return "Unknown"

static func get_formatted_age(creature: Creature) -> String:
    var years = creature.age_weeks / 52
    var weeks = creature.age_weeks % 52

    if years == 0:
        return "%d weeks" % weeks
    elif years == 1:
        if weeks == 0:
            return "1 year"
        else:
            return "1 year, %d weeks" % weeks
    else:
        if weeks == 0:
            return "%d years" % years
        else:
            return "%d years, %d weeks" % [years, weeks]

static func get_lifespan_status(creature: Creature) -> String:
    var percentage = get_age_percentage(creature)

    if percentage < 50:
        return "Healthy"
    elif percentage < 75:
        return "Aging"
    elif percentage < 90:
        return "Old"
    elif percentage < 100:
        return "Very Old"
    elif percentage < 110:
        return "Past Prime"
    else:
        return "Living on Borrowed Time"
```

### AgeManager Singleton (`scripts/systems/age_manager.gd`)
```gdscript
extends Node

signal creature_aged(creature: Creature)
signal creature_category_changed(creature: Creature, old_category: Creature.AgeCategory)
signal creature_died_of_age(creature: Creature)

# Age all active creatures by one week
func age_active_creatures(creatures: Array[Creature]):
    for creature in creatures:
        if creature.is_active:
            age_creature(creature)

# Age a single creature
func age_creature(creature: Creature):
    var old_category = creature.get_age_category()
    creature.age_one_week()

    emit_signal("creature_aged", creature)

    # Check for category change
    var new_category = creature.get_age_category()
    if old_category != new_category:
        emit_signal("creature_category_changed", creature, old_category)
        _apply_category_change_effects(creature, old_category, new_category)

    # Check mortality
    if should_check_mortality(creature):
        check_mortality(creature)

# Apply effects when creature changes age category
func _apply_category_change_effects(
    creature: Creature,
    old_category: Creature.AgeCategory,
    new_category: Creature.AgeCategory
):
    # Adjust stamina max based on age
    match new_category:
        Creature.AgeCategory.YOUNG:
            creature.stamina_max = 50 + (creature.constitution / 8)
        Creature.AgeCategory.ADULT:
            creature.stamina_max = 50 + (creature.constitution / 10)
        Creature.AgeCategory.ELDER:
            creature.stamina_max = 40 + (creature.constitution / 12)

    # Ensure current stamina doesn't exceed new max
    creature.stamina_current = mini(creature.stamina_current, creature.stamina_max)

    print("Creature %s aged from %s to %s" % [
        creature.name,
        _category_to_string(old_category),
        _category_to_string(new_category)
    ])

func _category_to_string(category: Creature.AgeCategory) -> String:
    match category:
        Creature.AgeCategory.YOUNG: return "Young"
        Creature.AgeCategory.ADULT: return "Adult"
        Creature.AgeCategory.ELDER: return "Elder"
        _: return "Unknown"

# Check if creature should have mortality check
func should_check_mortality(creature: Creature) -> bool:
    var age_percentage = CreatureAgeExtensions.get_age_percentage(creature)
    return age_percentage >= 100

# Check if creature dies of old age
func check_mortality(creature: Creature):
    var age_percentage = CreatureAgeExtensions.get_age_percentage(creature)

    if age_percentage < 100:
        return  # No mortality risk yet

    # Calculate mortality chance
    var over_percentage = age_percentage - 100
    var mortality_chance = calculate_mortality_chance(over_percentage)

    if randf() < mortality_chance:
        emit_signal("creature_died_of_age", creature)

# Calculate chance of death based on how far past lifespan
func calculate_mortality_chance(percentage_over: float) -> float:
    # 0-10% over: 5% chance per week
    # 10-20% over: 10% chance per week
    # 20-30% over: 20% chance per week
    # 30%+ over: 35% chance per week

    if percentage_over <= 10:
        return 0.05
    elif percentage_over <= 20:
        return 0.10
    elif percentage_over <= 30:
        return 0.20
    else:
        return 0.35

# Get performance modifier based on age
func get_age_performance_modifier(creature: Creature) -> float:
    return creature.get_age_modifier()

# Get training effectiveness based on age
func get_training_effectiveness_modifier(creature: Creature) -> float:
    match creature.get_age_category():
        Creature.AgeCategory.YOUNG:
            return 1.2  # +20% training gains
        Creature.AgeCategory.ADULT:
            return 1.0  # Normal training
        Creature.AgeCategory.ELDER:
            return 0.7  # -30% training gains
        _:
            return 1.0

# Get stamina recovery rate based on age
func get_stamina_recovery_modifier(creature: Creature) -> float:
    match creature.get_age_category():
        Creature.AgeCategory.YOUNG:
            return 1.5  # +50% recovery
        Creature.AgeCategory.ADULT:
            return 1.0  # Normal recovery
        Creature.AgeCategory.ELDER:
            return 0.6  # -40% recovery
        _:
            return 1.0

# Get breeding success modifier based on age
func get_breeding_success_modifier(creature: Creature) -> float:
    var age_percentage = CreatureAgeExtensions.get_age_percentage(creature)

    if age_percentage < 15:
        return 0.3  # Very young, poor breeding
    elif age_percentage < 20:
        return 0.7  # Young, reduced success
    elif age_percentage < 70:
        return 1.0  # Prime breeding age
    elif age_percentage < 80:
        return 0.8  # Older, slightly reduced
    elif age_percentage < 90:
        return 0.5  # Elder, significantly reduced
    else:
        return 0.2  # Very old, poor breeding

# Calculate retirement recommendation
func should_retire(creature: Creature) -> bool:
    var age_percentage = CreatureAgeExtensions.get_age_percentage(creature)

    # Recommend retirement at 85% lifespan
    return age_percentage >= 85

# Get age-based stat preview (for UI)
func get_modified_stats_preview(creature: Creature) -> Dictionary:
    var modifier = get_age_performance_modifier(creature)

    return {
        "strength": int(creature.strength * (1.0 + modifier)),
        "constitution": int(creature.constitution * (1.0 + modifier)),
        "dexterity": int(creature.dexterity * (1.0 + modifier)),
        "intelligence": int(creature.intelligence * (1.0 + modifier)),
        "wisdom": int(creature.wisdom * (1.0 + modifier)),
        "discipline": int(creature.discipline * (1.0 + modifier))
    }

# Batch age analysis for population
func analyze_age_distribution(creatures: Array[Creature]) -> Dictionary:
    var distribution = {
        "young": 0,
        "adult": 0,
        "elder": 0,
        "average_age": 0,
        "oldest": null,
        "youngest": null
    }

    var total_age = 0
    var oldest_age = -1
    var youngest_age = 999999

    for creature in creatures:
        # Count categories
        match creature.get_age_category():
            Creature.AgeCategory.YOUNG:
                distribution.young += 1
            Creature.AgeCategory.ADULT:
                distribution.adult += 1
            Creature.AgeCategory.ELDER:
                distribution.elder += 1

        # Track ages
        total_age += creature.age_weeks

        if creature.age_weeks > oldest_age:
            oldest_age = creature.age_weeks
            distribution.oldest = creature

        if creature.age_weeks < youngest_age:
            youngest_age = creature.age_weeks
            distribution.youngest = creature

    if creatures.size() > 0:
        distribution.average_age = total_age / creatures.size()

    return distribution

# Special handling for story-important creatures
func apply_plot_armor(creature: Creature) -> bool:
    # Certain creatures might be protected from age death
    # This is for future story implementation
    return false
```

### Age Display Helper (`scripts/ui/age_display_helper.gd`)
```gdscript
class_name AgeDisplayHelper
extends RefCounted

# Get color for age display based on category
static func get_age_color(creature: Creature) -> Color:
    match creature.get_age_category():
        Creature.AgeCategory.YOUNG:
            return Color.GREEN
        Creature.AgeCategory.ADULT:
            return Color.WHITE
        Creature.AgeCategory.ELDER:
            return Color.YELLOW
        _:
            return Color.GRAY

# Get icon for age category
static func get_age_icon_path(creature: Creature) -> String:
    match creature.get_age_category():
        Creature.AgeCategory.YOUNG:
            return "res://assets/icons/age_young.png"
        Creature.AgeCategory.ADULT:
            return "res://assets/icons/age_adult.png"
        Creature.AgeCategory.ELDER:
            return "res://assets/icons/age_elder.png"
        _:
            return ""

# Create rich text for age display
static func get_age_rich_text(creature: Creature) -> String:
    var color = get_age_color(creature)
    var age_text = CreatureAgeExtensions.get_formatted_age(creature)
    var category = creature.get_age_category()
    var category_text = AgeManager._category_to_string(category)

    return "[color=#%s]%s (%s)[/color]" % [
        color.to_html(false),
        age_text,
        category_text
    ]

# Get lifespan bar progress (0.0 to 1.0)
static func get_lifespan_progress(creature: Creature) -> float:
    return clamp(CreatureAgeExtensions.get_age_percentage(creature) / 100.0, 0.0, 1.0)

# Get lifespan bar color
static func get_lifespan_bar_color(creature: Creature) -> Color:
    var percentage = CreatureAgeExtensions.get_age_percentage(creature)

    if percentage < 50:
        return Color.GREEN
    elif percentage < 75:
        return Color.YELLOW
    elif percentage < 90:
        return Color.ORANGE
    elif percentage < 100:
        return Color.RED
    else:
        return Color.DARK_RED
```

## Success Metrics
- Age calculations complete in < 1ms
- Category transitions trigger correctly
- Modifiers apply accurately
- Mortality system works as designed
- UI displays age information clearly

## Notes
- Consider caching age calculations
- Ensure age effects are clearly communicated
- Balance age modifiers for gameplay
- Consider special cases for unique creatures

## Estimated Time
3-4 hours for implementation and testing