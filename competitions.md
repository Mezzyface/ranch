# Competition System Design

## Overview

The competition system provides an alternative income source through weekly events where creatures compete for monetary prizes. Competitions replace regular training activities, allowing players to earn gold while their creatures gain experience and minor stat improvements.

## Competition Mechanics

### Weekly Activity Integration
- **Time Slot**: Competitions occupy a creature's weekly activity slot (same as training)
- **Duration**: Each competition lasts 1 full week
- **Aging**: Creatures age +1 week after competition (same as training)
- **Food Requirement**: Must assign food before competition (affects performance)
- **Stamina Cost**: Competitions consume stamina based on intensity

### Competition Types

#### Combat Competitions
Focus on physical prowess and fighting ability

**Strength Contests**
- **Primary Stat**: Strength (STR)
- **Secondary Stats**: Constitution (CON), Discipline (DIS)
- **Entry Fee**: 20 gold
- **Stamina Cost**: 15
- **Duration**: 1 week
- **Stat Gain**: +5-12 STR, +2-5 CON

**Endurance Challenges**
- **Primary Stat**: Constitution (CON)
- **Secondary Stats**: Discipline (DIS), Wisdom (WIS)
- **Entry Fee**: 15 gold
- **Stamina Cost**: 20
- **Duration**: 1 week
- **Stat Gain**: +5-12 CON, +2-5 DIS

#### Agility Competitions
Focus on speed, precision, and dexterity

**Speed Races**
- **Primary Stat**: Dexterity (DEX)
- **Secondary Stats**: Constitution (CON)
- **Entry Fee**: 25 gold
- **Stamina Cost**: 12
- **Duration**: 1 week
- **Stat Gain**: +5-12 DEX, +2-5 CON

**Obstacle Courses**
- **Primary Stat**: Dexterity (DEX)
- **Secondary Stats**: Intelligence (INT), Wisdom (WIS)
- **Entry Fee**: 30 gold
- **Stamina Cost**: 15
- **Duration**: 1 week
- **Stat Gain**: +5-12 DEX, +2-5 INT

#### Intelligence Competitions
Focus on mental abilities and problem-solving

**Logic Tournaments**
- **Primary Stat**: Intelligence (INT)
- **Secondary Stats**: Wisdom (WIS), Discipline (DIS)
- **Entry Fee**: 10 gold
- **Stamina Cost**: 8
- **Duration**: 1 week
- **Stat Gain**: +6-15 INT, +2-5 WIS

**Strategy Games**
- **Primary Stat**: Intelligence (INT)
- **Secondary Stats**: Discipline (DIS)
- **Entry Fee**: 15 gold
- **Stamina Cost**: 10
- **Duration**: 1 week
- **Stat Gain**: +6-15 INT, +3-8 DIS

#### Awareness Competitions
Focus on perception and instinctual abilities

**Tracking Contests**
- **Primary Stat**: Wisdom (WIS)
- **Secondary Stats**: Dexterity (DEX), Intelligence (INT)
- **Entry Fee**: 12 gold
- **Stamina Cost**: 10
- **Duration**: 1 week
- **Stat Gain**: +5-12 WIS, +2-5 DEX

**Guard Trials**
- **Primary Stat**: Wisdom (WIS)
- **Secondary Stats**: Discipline (DIS), Constitution (CON)
- **Entry Fee**: 18 gold
- **Stamina Cost**: 12
- **Duration**: 1 week
- **Stat Gain**: +5-12 WIS, +3-8 DIS

#### Discipline Competitions
Focus on obedience and reliability

**Obedience Trials**
- **Primary Stat**: Discipline (DIS)
- **Secondary Stats**: Intelligence (INT), Wisdom (WIS)
- **Entry Fee**: 8 gold
- **Stamina Cost**: 6
- **Duration**: 1 week
- **Stat Gain**: +6-15 DIS, +2-5 INT

**Service Competitions**
- **Primary Stat**: Discipline (DIS)
- **Secondary Stats**: Strength (STR), Constitution (CON)
- **Entry Fee**: 22 gold
- **Stamina Cost**: 14
- **Duration**: 1 week
- **Stat Gain**: +5-12 DIS, +2-5 STR

## Performance Calculation

### Base Performance Score
- **Primary Stat × 3** + **Secondary Stat 1 × 1.5** + **Secondary Stat 2 × 1.5**
- **Food Bonuses**: Applied to relevant stats before calculation
- **Age Modifiers**: Young (+10%), Adult (0%), Elder (-10%)
- **Random Variance**: ±15% to add unpredictability

### Competition Results

#### Placement System
Based on performance score compared to simulated AI competitors:

**1st Place (Top 10%)**
- **Prize**: 200-400 gold (varies by competition type)
- **Bonus**: +50% stat gains
- **Achievement**: Competition winner status

**2nd-3rd Place (Top 30%)**
- **Prize**: 100-200 gold
- **Bonus**: +25% stat gains
- **Achievement**: Podium finisher status

**Top Half (31st-50th%)**
- **Prize**: 50-100 gold
- **Bonus**: Normal stat gains
- **Achievement**: Solid performer status

**Bottom Half (51st-100th%)**
- **Prize**: 10-30 gold (participation prize)
- **Bonus**: -25% stat gains
- **Achievement**: Needs improvement status

### Competition Difficulty Scaling

#### Beginner Competitions
- **Unlock**: Available from game start
- **AI Competitor Strength**: 10-30 average stats
- **Entry Fees**: 8-20 gold
- **Prize Pools**: 200-400 gold for 1st place

#### Intermediate Competitions
- **Unlock**: After completing TIM-02
- **AI Competitor Strength**: 25-50 average stats
- **Entry Fees**: 15-35 gold
- **Prize Pools**: 300-600 gold for 1st place

#### Advanced Competitions
- **Unlock**: After completing TIM-04
- **AI Competitor Strength**: 40-70 average stats
- **Entry Fees**: 25-50 gold
- **Prize Pools**: 500-800 gold for 1st place

#### Elite Competitions
- **Unlock**: After completing TIM-06
- **AI Competitor Strength**: 60-100 average stats
- **Entry Fees**: 40-75 gold
- **Prize Pools**: 800-1200 gold for 1st place

## Strategic Integration with TIM Quests

### Early Game Income (TIM-01, TIM-02)
**Best Competitions for Early Creatures:**
- **Obedience Trials**: Scuttleguard's DIS: 6-10 can place well
- **Guard Trials**: Scuttleguard's WIS: 7-11 competitive in beginner tier
- **Expected Income**: 50-200 gold per week depending on placement

**Strategic Use:**
- Enter competitions during weeks when training isn't urgently needed
- Build gold reserves for TIM-03's expensive creature purchases
- Low risk, steady income to supplement quest rewards

### Mid Game Funding (TIM-03 Gap)
**Competition Strategy:**
- Use newly purchased specialized creatures in appropriate competitions
- **Wind Dancer** (DEX: 12-18) dominates Speed Races and Obstacle Courses
- **Shadow Cats** (WIS: 9-15) excel in Tracking Contests and Guard Trials
- **Expected Income**: 100-400 gold per competition with specialized creatures

**Bridging the Gap:**
- **TIM-03 Cost**: 1,820 gold
- **TIM-03 Reward**: 1,200 gold
- **Gap**: 620 gold
- **Solution**: 2-3 competitions with specialized creatures = 200-800+ gold

### Late Game Optimization (TIM-05, TIM-06)
**High-Stakes Competitions:**
- **Stone Sentinel** (STR: 8-12, CON: 12-18) dominates Strength Contests
- **Sage Owl** (INT: 14-22) crushes Logic Tournaments
- **Expected Income**: 300-800+ gold per competition

## Food Integration and Strategy

### Competition-Optimized Foods

**Combat Rations** (from food.md)
- **Cost**: 40 gold
- **Effect**: +25% performance in competitions, reduced injury chance
- **Best For**: All physical competitions (Strength, Endurance, Speed)

**Task Fuel** (from food.md)
- **Cost**: 35 gold
- **Effect**: +30% effectiveness on active tasks
- **Best For**: Mental competitions (Logic, Strategy, Tracking)

**Golden Nectar** (from food.md)
- **Cost**: 100 gold
- **Effect**: +100% training effectiveness (applies to competition performance)
- **Best For**: High-stakes Elite competitions where winning is crucial

### Food Cost vs Prize Analysis

**Example: Beginner Strength Contest**
- **Entry Fee**: 20 gold
- **Food Cost**: 40 gold (Combat Rations)
- **Total Investment**: 60 gold
- **1st Place Prize**: 300 gold
- **Net Profit**: 240 gold (if winning)
- **Break-Even**: Need to place 4th or higher (60+ gold prize)

## Weekly Competition Schedule

### Rotation System
Different competition types rotate weekly to provide variety:

**Week 1**: Strength Contests + Logic Tournaments
**Week 2**: Speed Races + Guard Trials
**Week 3**: Endurance Challenges + Strategy Games
**Week 4**: Obstacle Courses + Tracking Contests
**Week 5**: Obedience Trials + Service Competitions
*Cycle repeats*

### Multiple Entries
- **Limit**: One creature per competition type per week
- **Strategy**: Enter multiple creatures in different competition types
- **Resource Management**: Balance entry fees against expected returns

## Economic Balance Analysis

### Competition vs Training Comparison

**Training Week:**
- **Cost**: 25 gold (training food) + facility fees
- **Benefit**: +7-22 stat gains (with food bonus)
- **Income**: 0 gold

**Competition Week:**
- **Cost**: 20-50 gold (entry + food)
- **Benefit**: +3-8 primary stat + minor secondary stats + 10-400 gold prize
- **Income**: 10-400 gold (placement dependent)

**Strategic Trade-offs:**
- **Training**: Higher stat gains, no income
- **Competition**: Lower stat gains, income potential
- **Optimal**: Mix both based on economic needs and creature development goals

### Income Potential by Game Phase

**Early Game (Beginner Competitions)**
- **Conservative Strategy**: 50-100 gold per week per creature
- **Aggressive Strategy**: 100-300 gold per week (higher risk/reward)

**Mid Game (Intermediate Competitions)**
- **With Specialized Creatures**: 150-400 gold per week
- **Multi-Creature Strategy**: 300-800 gold per week across multiple competitions

**Late Game (Advanced/Elite Competitions)**
- **High-Stat Creatures**: 300-800+ gold per week
- **Portfolio Approach**: 600-1500+ gold per week across creature stable

## Implementation Notes

### Competition Interface Requirements
- **Entry System**: Select creature, competition type, food assignment
- **Performance Tracking**: Show creature stats vs competition requirements
- **Results Display**: Placement, prize money, stat gains, achievement unlocks
- **Schedule View**: Weekly competition rotation and creature availability

### AI Competitor System
- **Stat Generation**: Random stats within difficulty tier ranges
- **Performance Simulation**: Same calculation as player creatures
- **Realistic Results**: Player creatures should win/lose based on actual stats
- **Scaling**: AI competitor strength increases with player progression

### Balancing Mechanisms
- **Entry Fees**: Prevent risk-free income farming
- **Stamina Costs**: Limit consecutive competitions
- **Performance Variance**: Ensure outcomes aren't completely predictable
- **Progressive Difficulty**: Higher rewards require stronger creatures

This competition system solves the TIM-03 funding gap while adding engaging gameplay variety that complements the core breeding/training loop.