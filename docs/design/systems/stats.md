# Stats System Specifications

## Stat Enums (Godot 4.5)

```gdscript
enum StatType {
    STRENGTH,
    CONSTITUTION,
    DEXTERITY,
    INTELLIGENCE,
    WISDOM,
    DISCIPLINE
}
```

## Primary Stats (Range: 0-1000)

### Strength (STR)
- **Purpose**: Physical power, combat effectiveness, construction ability
- **Quest Usage**: Required for guards (STR > 110), logistics helpers (STR > 130), construction workers (STR > 250)
- **Training Focus**: Physical activities, combat practice, heavy labor

### Constitution (CON)
- **Purpose**: Health, durability, endurance, resistance to damage
- **Quest Usage**: Cave guards (CON > 120), vault guardians (CON > 200)
- **Training Focus**: Endurance exercises, survival challenges, stamina building

### Dexterity (DEX)
- **Purpose**: Speed, agility, precision, fine motor control
- **Quest Usage**: Pest control specialists (DEX > 100)
- **Training Focus**: Agility courses, precision tasks, reaction training

### Intelligence (INT)
- **Purpose**: Problem solving, learning ability, complex task execution
- **Quest Usage**: Logistics helpers (INT > 90), puzzle masters (INT > 230)
- **Training Focus**: Puzzle solving, learning exercises, cognitive challenges

### Wisdom (WIS)
- **Purpose**: Awareness, perception, instinct, environmental knowledge
- **Quest Usage**: Study guards (WIS > 70), patrol creatures (WIS > 100)
- **Training Focus**: Observation exercises, alertness drills, meditation

### Discipline (DIS)
- **Purpose**: Obedience, focus, reliability, following commands
- **Quest Usage**: Study guards (DIS > 80), logistics helpers (DIS > 110), vault guardians (DIS > 180)
- **Training Focus**: Obedience training, focus exercises, command drills

## Age Modifiers (IMPORTANT CLARIFICATION)

**Age modifiers DO NOT affect base stats used for quest requirements.**

Age modifiers affect:
- **Training gains only** (different rates by age category)
- **Competition performance scores** (multiplied by age modifier)
- **Stamina recovery rates** (age-dependent)

Age modifiers DO NOT affect:
- **Quest requirement validation** (uses base stats)
- **Base stat values** (permanently unchanged)
- **Effective stats for requirement checking**

## Training Stat (Range: 0-100)

### Stamina (STA)
- **Purpose**: Energy available for training activities
- **Mechanics**:
  - Depletes during training sessions
  - Regenerates over time when resting
  - Higher stamina allows longer/more intensive training
  - Different training activities consume different amounts
- **Management**: Players must balance training intensity with stamina recovery


## Quest Integration

Stats are used throughout the quest system to determine creature suitability for various tasks. For complete quest requirements, validation systems, and quest progression, see **[quest.md](quest.md)**.

## Stat Balance Considerations
- **Physical Stats** (STR, CON, DEX): Combat and physical task effectiveness
- **Mental Stats** (INT, WIS, DIS): Complex task and behavioral reliability
- **Balanced Creatures**: Equal development across all stats for versatility
- **Specialized Creatures**: Focus on specific stat clusters for role optimization

## Breeding and Stat Inheritance

### Inheritance Rules
- Offspring base stats = Average of parents ± random variance (10-20%)
- Each stat inherits independently
- Exceptional parents (800+ in a stat) have higher chance of producing exceptional offspring
- Minimum inherited stat = 10% of parent average
- Maximum inherited stat = 150% of parent average (capped at 1000)

### Breeding Strategies
- **Power Breeding**: High STR + High STR = Strong combat creature
- **Smart Breeding**: High INT + High INT = Puzzle-solving creature
- **Balanced Breeding**: Well-rounded parent + Well-rounded parent = Versatile creature
- **Complementary Breeding**: Specialist + Generalist = Moderate improvements across multiple stats

## Implementation Details

For complete Godot 4.5 implementation including StatsComponent, StatHelper, quest validation, and breeding systems, see **[stats_implementation.md](stats_implementation.md)**.