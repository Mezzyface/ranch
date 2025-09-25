# Food System Specifications

## Food Overview

The food system provides temporary bonuses and effects to active creatures during their weekly activities. Food integrates with the **Time Management System** (see [time.md](time.md)) where food is consumed during weekly progression.

## Food Mechanics

### Food Assignment and Time Integration
- **Required**: Every active creature must be assigned food before time advancement
- **Duration**: Food effects last only during the assigned week
- **Consumption**: Food is consumed when time progresses (see [time.md](time.md))
- **No Stacking**: Only one food type can be assigned per week
- **Strategic Choice**: Different foods benefit different activities

### Food Categories

#### Basic Foods (Low Cost, Mild Effects)
- **Grain Rations**: Standard food, no bonuses/penalties, 5 gold
- **Fresh Hay**: +5 stamina recovery, good for rest weeks, 8 gold
- **Wild Berries**: +2 to all training gains, 10 gold
- **Spring Water**: Removes negative food effects from previous week, 3 gold

#### Training Foods (Stat-Focused Bonuses)
- **Protein Mix**: +50% Strength training effectiveness, 25 gold
- **Endurance Blend**: +50% Constitution training effectiveness, 25 gold
- **Agility Feed**: +50% Dexterity training effectiveness, 25 gold
- **Brain Food**: +50% Intelligence training effectiveness, 25 gold
- **Focus Formula**: +50% Wisdom training effectiveness, 25 gold
- **Discipline Diet**: +50% Discipline training effectiveness, 25 gold

#### Premium Foods (High Cost, Strong Effects)
- **Golden Nectar**: +100% training effectiveness for any stat, 100 gold
- **Vitality Elixir**: +20 stamina recovery, immunity to stamina loss, 75 gold
- **Youth Serum**: Temporarily treats creature as one age category younger, 150 gold
- **Ancient Grains**: +3 to all stat training gains, +10 stamina recovery, 80 gold

#### Specialty Foods (Activity-Specific)
- **Breeding Supplement**: +50% breeding success chance, healthier offspring, 50 gold
- **Combat Rations**: +25% performance in competitions, reduced injury chance, 40 gold
- **Task Fuel**: +30% effectiveness on active tasks, faster completion, 35 gold
- **Recovery Meal**: Doubles stamina recovery during rest weeks, 30 gold

#### Exotic Foods (Rare, Unique Effects)
- **Dragon Fruit**: Chance to gain rare tags during breeding, 200 gold
- **Phoenix Ash**: Prevents aging for one week (creature doesn't age +1), 300 gold
- **Lunar Moss**: Doubles all food effects but causes -10 stamina penalty, 120 gold
- **Mystic Herbs**: Random powerful effect (positive or negative), 60 gold

## Food Acquisition

### Purchase Sources
- **General Store**: Basic foods and some training foods
- **Specialty Shops**: Premium and specialty foods
- **Black Market**: Exotic foods and rare items
- **Quest Rewards**: Unique foods as mission completion bonuses

## Food Effects by Activity

### Training Activities
- **Training Foods**: Boost specific stat gains
- **Basic Foods**: Provide sustenance without penalties
- **Premium Foods**: Maximize training efficiency
- **Specialty Foods**: Minimal effect on training

### Resting
- **Recovery Meal**: Optimal for rest weeks
- **Vitality Elixir**: Maximum stamina restoration
- **Fresh Hay**: Good stamina bonus
- **Training Foods**: Wasted on rest weeks

### Breeding
- **Breeding Supplement**: Essential for optimal breeding
- **Youth Serum**: Improves breeding success for older creatures
- **Dragon Fruit**: Chance for unique offspring traits
- **Training Foods**: No breeding benefits

### Competition
- **Combat Rations**: Ideal for competitive events
- **Golden Nectar**: Enhances performance significantly
- **Agility Feed**: Good for speed-based competitions
- **Recovery Foods**: Wasted on competition weeks

### Active Tasks
- **Task Fuel**: Optimal for quest assignments
- **Brain Food**: Good for intelligence-based tasks
- **Combat Rations**: Useful for dangerous missions
- **Basic Foods**: Adequate for simple tasks

## Food Storage and Management

### Inventory System
- **Storage Limit**: Players have limited food storage capacity
- **Organization**: Foods sorted by type and quality
- **Bulk Purchase**: Discounts for buying in quantity

### Strategic Planning
- **Weekly Planning**: Assign foods based on planned activities
- **Resource Management**: Balance food costs with creature needs
- **Efficiency**: Match food types to activity types for maximum benefit
- **Emergency Supply**: Keep basic foods for unexpected needs

## Food Usage Examples

### Optimal Food Combinations

#### High-Level Strength Training
- **Creature**: Adult creature training Boulder Pushing (advanced strength)
- **Food Choice**: Protein Mix (+50% strength training)
- **Expected Result**: 30-45 STR gain (base 20-30 × 1.5 multiplier)

#### Rest Week Recovery
- **Creature**: Exhausted creature with low stamina
- **Food Choice**: Recovery Meal (doubles rest recovery)
- **Expected Result**: 60-100 stamina recovery (base 30-50 × 2.0 multiplier)

#### Premium Training Session
- **Creature**: Young creature (age bonus) training any stat
- **Food Choice**: Golden Nectar (+100% training effectiveness)
- **Expected Result**: Combined multipliers (1.2 age × 2.0 food = 2.4× total)

#### Strategic Breeding
- **Creature**: Two high-stat parents
- **Food Choice**: Dragon Fruit (rare tag chance)
- **Expected Result**: Normal breeding + 15% chance for rare offspring tags

## Implementation Details

For complete Godot 4.5 implementation including enums, data structures, food effects, and shop systems, see **[food_implementation.md](food_implementation.md)**.