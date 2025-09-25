# Task 06: Age System Implementation

## Overview
Implement the age system that tracks creature aging, manages age categories, applies performance modifiers, and handles lifespan mechanics as a GameCore subsystem that works with the CreatureData/CreatureEntity separation.

## Dependencies
- Task 01: GameCore Setup (complete)
- Task 02: CreatureData/CreatureEntity separation (complete)
- Task 03: Stat System (complete)
- Design documents: `creature.md`, `time.md`

## Context
**CRITICAL ARCHITECTURE CHANGES**:
- AgeSystem as GameCore subsystem (NOT autoload)
- Works with CreatureEntity for aging behavior
- All signals go through SignalBus
- Age data stored in CreatureData, behavior in CreatureEntity
- Lazy-loaded by GameCore when needed

From the design documents:
- Creatures age weekly when active
- Age affects performance (young +10%, adult 0%, elder -10%)
- Five age categories: Baby, Juvenile, Adult, Elder, Ancient
- Creatures have species-specific lifespans
- Aging only occurs for active creatures

## Requirements

### Age Categories (Updated from Design)
1. **Baby** (0-10% of lifespan)
   - Performance modifier: 0.6x (60%)
   - Faster training gains (+50%)
   - Cannot participate in quests
   - Higher stamina recovery

2. **Juvenile** (10-25% of lifespan)
   - Performance modifier: 0.8x (80%)
   - Training gains (+20%)
   - Can do basic quests
   - Good stamina recovery

3. **Adult** (25-75% of lifespan)
   - Performance modifier: 1.0x (100%)
   - Normal training gains
   - Optimal for all activities
   - Standard stamina recovery

4. **Elder** (75-90% of lifespan)
   - Performance modifier: 0.8x (80%)
   - Reduced training gains (-20%)
   - Wisdom-based bonuses
   - Slower stamina recovery

5. **Ancient** (90-100% of lifespan)
   - Performance modifier: 0.6x (60%)
   - Minimal training gains (-50%)
   - High experience bonuses
   - Very slow stamina recovery

### Age Mechanics
1. **Weekly Aging**
   - Only active creatures age (managed by AgeSystem)
   - Stable creatures don't age
   - Age increases by 1 week per time advance

2. **Performance Modifiers**
   - Apply to competition scores
   - Apply to quest validation
   - Don't affect base stats permanently

3. **Death Mechanics**
   - Creatures can exceed lifespan
   - Increased mortality chance past 100%
   - Special handling for story creatures

## Implementation Steps

1. **Create AgeSystem Class**
   - Extends Node, managed by GameCore
   - Connects to SignalBus for all signals
   - Lazy-loaded subsystem

2. **Implement Age Progression**
   - Age management through CreatureEntity
   - Category calculation from CreatureData
   - Modifier application

3. **Integrate with Time System**
   - Hook into weekly progression via SignalBus
   - Update creature ages through entities
   - Apply age effects

4. **Add Age Utilities**
   - Age display formatting
   - Category indicators
   - Lifespan progress calculations

## Test Criteria

### Unit Tests
- [ ] Age categories calculate correctly from CreatureData
- [ ] Baby creatures get 0.6x modifier
- [ ] Adult creatures get 1.0x modifier
- [ ] Ancient creatures get 0.6x modifier
- [ ] Age only increases when active through CreatureEntity
- [ ] Stable creatures don't age

### Age Progression Tests
- [ ] Creatures age 1 week per time advance
- [ ] Age categories transition at correct percentages
- [ ] Lifespan calculations are accurate
- [ ] Mortality chance increases past 100%

### Integration Tests
- [ ] Age modifiers apply to performance scores
- [ ] Training effectiveness varies by age through AgeSystem
- [ ] Stamina recovery varies by age
- [ ] Age persists through save/load
- [ ] SignalBus properly routes aging events

## Code Implementation

### AgeSystem - GameCore Subsystem
```gdscript
# scripts/systems/age_system.gd
class_name AgeSystem
extends Node

var signal_bus: SignalBus

func _ready() -> void:
    signal_bus = GameCore.get_signal_bus()

    # Connect to time system events
    signal_bus.week_advanced.connect(_on_week_advanced)

    print("AgeSystem initialized")

# Called when time advances by one week
func _on_week_advanced() -> void:
    # Get all active creatures from collection system
    var collection_system = GameCore.get_system("collection")
    if collection_system:
        var active_creatures = collection_system.get_active_creature_entities()
        age_creatures_batch(active_creatures)

# Age multiple creatures at once
func age_creatures_batch(creature_entities: Array[CreatureEntity]) -> void:
    for creature_entity in creature_entities:
        if creature_entity.data.is_active:
            age_creature_entity(creature_entity)

# Age a single CreatureEntity
func age_creature_entity(creature_entity: CreatureEntity) -> void:
    var old_category = get_age_category(creature_entity.data)
    var old_age = creature_entity.data.age_weeks

    # Increment age in the data
    creature_entity.data.age_weeks += 1

    # Check for category change
    var new_category = get_age_category(creature_entity.data)

    # Emit aging signal
    if signal_bus:
        signal_bus.creature_aged.emit(creature_entity.data, creature_entity.data.age_weeks)

    # Handle category transitions
    if old_category != new_category:
        _handle_age_category_transition(creature_entity, old_category, new_category)

    # Apply weekly aging effects
    _apply_weekly_aging_effects(creature_entity)

    # Check mortality if past lifespan
    if should_check_mortality(creature_entity.data):
        check_mortality(creature_entity)

# Handle age category transitions
func _handle_age_category_transition(
    creature_entity: CreatureEntity,
    old_category: int,
    new_category: int
) -> void:
    # Adjust stamina max based on new age category
    var base_stamina = 50 + (creature_entity.data.constitution / 10)
    match new_category:
        0, 1:  # Baby, Juvenile
            creature_entity.data.stamina_max = int(base_stamina * 1.2)
        2:     # Adult
            creature_entity.data.stamina_max = base_stamina
        3, 4:  # Elder, Ancient
            creature_entity.data.stamina_max = int(base_stamina * 0.8)

    # Ensure current stamina doesn't exceed new max
    creature_entity.data.stamina_current = mini(
        creature_entity.data.stamina_current,
        creature_entity.data.stamina_max
    )

    # Emit category change signal
    if signal_bus:
        signal_bus.creature_age_category_changed.emit(
            creature_entity.data,
            old_category,
            new_category
        )

    print("Creature %s transitioned from %s to %s" % [
        creature_entity.data.creature_name,
        _category_to_string(old_category),
        _category_to_string(new_category)
    ])

# Apply weekly effects of aging
func _apply_weekly_aging_effects(creature_entity: CreatureEntity) -> void:
    # Gradual stamina loss for older creatures
    var age_category = get_age_category(creature_entity.data)
    var stamina_loss = 0

    match age_category:
        0, 1:  # Baby, Juvenile - no loss
            stamina_loss = 0
        2:     # Adult - minimal loss
            stamina_loss = 2
        3:     # Elder - moderate loss
            stamina_loss = 5
        4:     # Ancient - significant loss
            stamina_loss = 10

    if stamina_loss > 0:
        creature_entity.data.stamina_current = maxi(
            0,
            creature_entity.data.stamina_current - stamina_loss
        )

# Age calculation methods
func get_age_category(creature_data: CreatureData) -> int:
    var life_percentage = get_age_percentage(creature_data)

    if life_percentage < 10:
        return 0  # BABY
    elif life_percentage < 25:
        return 1  # JUVENILE
    elif life_percentage < 75:
        return 2  # ADULT
    elif life_percentage < 90:
        return 3  # ELDER
    else:
        return 4  # ANCIENT

func get_age_percentage(creature_data: CreatureData) -> float:
    if creature_data.lifespan <= 0:
        return 0.0
    return (float(creature_data.age_weeks) / float(creature_data.lifespan)) * 100.0

func get_age_modifier(creature_data: CreatureData) -> float:
    match get_age_category(creature_data):
        0: return 0.6  # BABY
        1: return 0.8  # JUVENILE
        2: return 1.0  # ADULT
        3: return 0.8  # ELDER
        4: return 0.6  # ANCIENT
        _: return 1.0

# Performance and training modifiers
func get_training_effectiveness_modifier(creature_data: CreatureData) -> float:
    match get_age_category(creature_data):
        0: return 1.5  # BABY - learns fast
        1: return 1.2  # JUVENILE - good learning
        2: return 1.0  # ADULT - normal
        3: return 0.8  # ELDER - slower learning
        4: return 0.5  # ANCIENT - very slow learning
        _: return 1.0

func get_stamina_recovery_modifier(creature_data: CreatureData) -> float:
    match get_age_category(creature_data):
        0: return 1.8  # BABY - fast recovery
        1: return 1.4  # JUVENILE - good recovery
        2: return 1.0  # ADULT - normal
        3: return 0.7  # ELDER - slow recovery
        4: return 0.4  # ANCIENT - very slow recovery
        _: return 1.0

func get_quest_eligibility_modifier(creature_data: CreatureData) -> float:
    var age_category = get_age_category(creature_data)
    match age_category:
        0: return 0.0  # BABY - cannot do quests
        1: return 0.7  # JUVENILE - limited quests
        2: return 1.0  # ADULT - all quests
        3: return 1.1  # ELDER - wisdom bonus
        4: return 1.2  # ANCIENT - experience bonus
        _: return 1.0

# Mortality system
func should_check_mortality(creature_data: CreatureData) -> bool:
    return get_age_percentage(creature_data) >= 100.0

func check_mortality(creature_entity: CreatureEntity) -> void:
    var age_percentage = get_age_percentage(creature_entity.data)

    if age_percentage < 100:
        return  # No mortality risk yet

    # Calculate mortality chance
    var over_percentage = age_percentage - 100
    var mortality_chance = calculate_mortality_chance(over_percentage)

    if randf() < mortality_chance:
        if signal_bus:
            signal_bus.creature_died_of_age.emit(creature_entity.data)

func calculate_mortality_chance(percentage_over: float) -> float:
    # Progressive mortality risk
    if percentage_over <= 10:
        return 0.05      # 5% per week for first 10%
    elif percentage_over <= 25:
        return 0.15      # 15% per week for next 15%
    elif percentage_over <= 50:
        return 0.30      # 30% per week for next 25%
    else:
        return 0.50      # 50% per week beyond 50% over

# Age formatting and display utilities
func get_formatted_age(creature_data: CreatureData) -> String:
    var years = creature_data.age_weeks / 52
    var weeks = creature_data.age_weeks % 52

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

func get_age_description(creature_data: CreatureData) -> String:
    var age_category = get_age_category(creature_data)
    var age_percentage = get_age_percentage(creature_data)

    match age_category:
        0:  # BABY
            return "Newborn"
        1:  # JUVENILE
            if age_percentage < 20:
                return "Young"
            else:
                return "Juvenile"
        2:  # ADULT
            if age_percentage < 40:
                return "Young Adult"
            elif age_percentage < 60:
                return "Prime Adult"
            else:
                return "Mature Adult"
        3:  # ELDER
            return "Elder"
        4:  # ANCIENT
            if age_percentage < 100:
                return "Ancient"
            else:
                return "Venerable"
        _:
            return "Unknown"

func get_lifespan_status(creature_data: CreatureData) -> String:
    var percentage = get_age_percentage(creature_data)

    if percentage < 25:
        return "Young"
    elif percentage < 50:
        return "Healthy"
    elif percentage < 75:
        return "Mature"
    elif percentage < 90:
        return "Aging"
    elif percentage < 100:
        return "Old"
    elif percentage < 110:
        return "Very Old"
    else:
        return "Ancient"

# Age-based stat calculations (for UI display)
func get_effective_stats(creature_data: CreatureData) -> Dictionary:
    var modifier = get_age_modifier(creature_data)

    return {
        "strength": int(creature_data.strength * modifier),
        "constitution": int(creature_data.constitution * modifier),
        "dexterity": int(creature_data.dexterity * modifier),
        "intelligence": int(creature_data.intelligence * modifier),
        "wisdom": int(creature_data.wisdom * modifier),
        "discipline": int(creature_data.discipline * modifier)
    }

# Population age analysis
func analyze_age_distribution(creature_data_array: Array[CreatureData]) -> Dictionary:
    var distribution = {
        "baby": 0,
        "juvenile": 0,
        "adult": 0,
        "elder": 0,
        "ancient": 0,
        "average_age_weeks": 0,
        "oldest": null,
        "youngest": null
    }

    if creature_data_array.is_empty():
        return distribution

    var total_age = 0
    var oldest_age = -1
    var youngest_age = 999999

    for creature_data in creature_data_array:
        # Count categories
        match get_age_category(creature_data):
            0: distribution.baby += 1
            1: distribution.juvenile += 1
            2: distribution.adult += 1
            3: distribution.elder += 1
            4: distribution.ancient += 1

        # Track ages
        total_age += creature_data.age_weeks

        if creature_data.age_weeks > oldest_age:
            oldest_age = creature_data.age_weeks
            distribution.oldest = creature_data

        if creature_data.age_weeks < youngest_age:
            youngest_age = creature_data.age_weeks
            distribution.youngest = creature_data

    distribution.average_age_weeks = total_age / creature_data_array.size()
    return distribution

# Retirement recommendations
func should_retire(creature_data: CreatureData) -> bool:
    var age_percentage = get_age_percentage(creature_data)
    return age_percentage >= 85  # Recommend retirement at 85% lifespan

# Utility methods
func _category_to_string(category: int) -> String:
    match category:
        0: return "Baby"
        1: return "Juvenile"
        2: return "Adult"
        3: return "Elder"
        4: return "Ancient"
        _: return "Unknown"

# Special handling for story-important creatures
func has_plot_armor(creature_data: CreatureData) -> bool:
    # Certain creatures might be protected from age death
    # This is for future story implementation
    return false
```

### Age Display Helper - Utility Class
```gdscript
# scripts/utils/age_display_helper.gd
class_name AgeDisplayHelper
extends RefCounted

# Get color for age display based on category
static func get_age_color(creature_data: CreatureData) -> Color:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return Color.WHITE

    match age_system.get_age_category(creature_data):
        0: return Color.LIGHT_BLUE    # BABY
        1: return Color.GREEN         # JUVENILE
        2: return Color.WHITE         # ADULT
        3: return Color.YELLOW        # ELDER
        4: return Color.ORANGE        # ANCIENT
        _: return Color.GRAY

# Get icon path for age category
static func get_age_icon_path(creature_data: CreatureData) -> String:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return ""

    match age_system.get_age_category(creature_data):
        0: return "res://assets/icons/age_baby.png"
        1: return "res://assets/icons/age_juvenile.png"
        2: return "res://assets/icons/age_adult.png"
        3: return "res://assets/icons/age_elder.png"
        4: return "res://assets/icons/age_ancient.png"
        _: return ""

# Create rich text for age display
static func get_age_rich_text(creature_data: CreatureData) -> String:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return "Age: Unknown"

    var color = get_age_color(creature_data)
    var age_text = age_system.get_formatted_age(creature_data)
    var description = age_system.get_age_description(creature_data)

    return "[color=#%s]%s (%s)[/color]" % [
        color.to_html(false),
        age_text,
        description
    ]

# Get lifespan progress bar value (0.0 to 1.0)
static func get_lifespan_progress(creature_data: CreatureData) -> float:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return 0.0

    return clamp(age_system.get_age_percentage(creature_data) / 100.0, 0.0, 1.0)

# Get lifespan bar color
static func get_lifespan_bar_color(creature_data: CreatureData) -> Color:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return Color.GRAY

    var percentage = age_system.get_age_percentage(creature_data)

    if percentage < 25:
        return Color.GREEN
    elif percentage < 50:
        return Color.YELLOW_GREEN
    elif percentage < 75:
        return Color.YELLOW
    elif percentage < 90:
        return Color.ORANGE
    elif percentage < 100:
        return Color.RED
    else:
        return Color.DARK_RED

# Get age-based performance indicator
static func get_performance_indicator(creature_data: CreatureData) -> String:
    var age_system = GameCore.get_system("age") as AgeSystem
    if not age_system:
        return "Normal"

    var modifier = age_system.get_age_modifier(creature_data)

    if modifier > 1.0:
        return "Enhanced"
    elif modifier >= 0.9:
        return "Normal"
    elif modifier >= 0.7:
        return "Reduced"
    else:
        return "Limited"
```

## Success Metrics
- AgeSystem loads as GameCore subsystem in < 1ms
- Age calculations complete in < 1ms per creature
- Category transitions trigger correctly
- Modifiers apply accurately to all systems
- Mortality system works as designed
- UI displays age information clearly
- All signals properly routed through SignalBus
- CreatureData/CreatureEntity separation maintained

## Notes
- AgeSystem is a GameCore subsystem, not an autoload
- Age data stored in CreatureData, behavior managed by AgeSystem
- Consider caching age calculations for large populations
- Ensure age effects are clearly communicated to player
- Balance age modifiers for engaging gameplay
- Special cases for unique/story creatures planned

## Estimated Time
3-4 hours for implementation and testing