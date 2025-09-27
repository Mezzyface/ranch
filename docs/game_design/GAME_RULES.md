# Creature Ranch Game Rules & Mechanics

## Overview
Creature Ranch is a creature collection and management game where players raise, train, and breed magical creatures while managing resources and completing quests.

## Core Game Loop
1. **Collect** creatures through various means (quests, breeding, trading)
2. **Manage** your active roster and stable
3. **Train** creatures through activities to improve their stats
4. **Complete** quests and competitions for rewards
5. **Breed** creatures to create new generations
6. **Progress** through weekly time advancement

---

## 1. Creatures

### 1.1 Creature Properties
Every creature has the following attributes:

#### Core Stats (Range: 1-1000)
- **Strength**: Physical power and melee damage
- **Constitution**: Health and stamina efficiency
- **Dexterity**: Speed and evasion
- **Intelligence**: Magic power and learning speed
- **Wisdom**: Magic resistance and decision-making
- **Discipline**: Training effectiveness and stamina conservation

#### Vital Stats
- **Stamina**: Energy for activities (0-100)
  - Exhaustion occurs at ≤20 stamina
  - All activities require stamina
- **Age**: Measured in weeks
  - Affects stat modifiers
  - Determines life stage
- **Lifespan**: Total weeks creature can live

### 1.2 Age Categories & Modifiers
Creatures progress through life stages based on their age percentage:

| Stage | Age % of Lifespan | Stat Modifier | Description |
|-------|-------------------|---------------|-------------|
| Baby | 0-10% | 0.6x | Weak but high growth potential |
| Juvenile | 10-25% | 0.8x | Learning and developing |
| Adult | 25-75% | 1.0x | Prime of life |
| Elder | 75-90% | 0.8x | Experienced but declining |
| Ancient | 90-100% | 0.6x | Wise but frail |

### 1.3 Species
Each creature belongs to a species that determines:
- Base stat ranges
- Egg groups for breeding compatibility
- Special traits and abilities
- Rarity tier (Common, Uncommon, Rare, Legendary)
- Evolution potential

---

## 2. Roster Management

### 2.1 Active Roster
- **Size**: Maximum 6 creatures
- **Purpose**: Creatures available for activities and quests
- **State**: Creatures consume stamina when performing activities
- **Benefits**: Can participate in all game activities
- **Restrictions**: Limited slots force strategic choices

### 2.2 Stable
- **Size**: Unlimited
- **Purpose**: Storage for inactive creatures
- **State**: Creatures in complete stasis
  - No stamina changes
  - No aging (time still passes)
  - No stat changes
- **Benefits**: Preserve creatures for later use
- **Restrictions**: Cannot participate in activities

### 2.3 Roster Strategy
- Rotate exhausted creatures to stable
- Keep balanced team for different activity types
- Consider age and stat modifiers when selecting active roster
- Plan for breeding pairs

---

## 3. Activities & Stamina System

### 3.1 Stamina Mechanics
- **Range**: 0-100 points
- **Exhaustion Threshold**: 20 points
- **Recovery**: Only through food items or special abilities
- **No Passive Changes**: Stamina doesn't regenerate or drain over time

### 3.2 Activity Costs

| Activity | Stamina Cost | Benefits | Requirements |
|----------|--------------|----------|--------------|
| Training | 10 | Improve specific stat | Trainer available |
| Quest | 15 | Rewards, experience, items | Quest requirements met |
| Competition | 25 | Prizes, reputation | Entry requirements |
| Breeding | 30 | New creature offspring | Compatible pair |

### 3.3 Food & Recovery

| Item Type | Stamina Restored | Rarity | Additional Effects |
|-----------|------------------|--------|-------------------|
| Basic Food | 10 | Common | None |
| Standard Food | 20 | Common | None |
| Quality Food | 30 | Uncommon | Small stat boost |
| Premium Food | 50 | Rare | Moderate stat boost |
| Energy Drink | 40 | Uncommon | Temporary speed boost |
| Stamina Potion | 100 | Rare | Full restoration |

---

## 4. Time System

### 4.1 Weekly Progression
- **Manual Advancement**: Player chooses when to advance time
- **Weekly Events**: Special occurrences based on schedule
- **Aging**: All creatures age by 1 week
- **No Auto-Save**: Player must save manually

### 4.2 Time-Based Mechanics
- Creature aging and life stages
- Quest availability and deadlines
- Breeding cooldowns
- Seasonal events (every 4 weeks)

### 4.3 Weekly Processing Order
1. Age all creatures (+1 week)
2. Process scheduled events
3. Update quest availability
4. Check for creature milestones
5. Apply any time-based modifiers

---

## 5. Collection System

### 5.1 Acquisition Methods
- **Starter Creatures**: Initial selection
- **Quest Rewards**: Complete quests for creatures
- **Breeding**: Combine compatible creatures
- **Trading**: Exchange with NPCs or other players
- **Wild Encounters**: Random events

### 5.2 Collection Milestones
- 10 creatures: Stable expansion
- 25 creatures: Unlock advanced breeding
- 50 creatures: Access to rare quests
- 100 creatures: Master collector title

### 5.3 Release Mechanics
- Released creatures cannot be recovered
- Provides small resource bonus based on creature level
- Required for population management

---

## 6. Quest System

### 6.1 Quest Types
- **Story Quests**: Main progression
- **Daily Quests**: Repeatable tasks
- **Special Events**: Time-limited challenges
- **Collection Quests**: Require specific creatures

### 6.2 Quest Requirements
Can include any combination of:
- Specific creature species
- Minimum stat thresholds
- Age requirements
- Tag requirements (traits/abilities)
- Number of creatures

### 6.3 Quest Rewards
- Gold and items
- New creatures
- Unlock new areas/features
- Reputation/experience

---

## 7. Breeding System

### 7.1 Breeding Requirements
- Both creatures must have ≥30 stamina
- Must be in compatible egg groups
- Must be adults (25-75% lifespan)
- Cannot breed parent with offspring

### 7.2 Inheritance Mechanics
Offspring inherit:
- **Stats**: Average of parents ±20% random variance
- **Traits**: Chance to inherit from either parent
- **Lifespan**: Based on species with parent influence
- **Generation**: Parent's highest generation + 1

### 7.3 Breeding Strategy
- Higher generation creatures have better stat potential
- Rare species combinations may produce unique offspring
- Trait stacking through selective breeding
- Balance immediate needs vs long-term breeding goals

---

## 8. Resource Management

### 8.1 Primary Resources
- **Gold**: Primary currency
  - Earned from quests and competitions
  - Used for items, upgrades, fees
- **Food**: Stamina restoration
  - Purchased or quest rewards
  - Different tiers for different needs
- **Items**: Various consumables and equipment
  - Stat boosters
  - Breeding items
  - Quest items

### 8.2 Resource Strategy
- Balance food supply with active roster size
- Save rare items for crucial moments
- Invest in long-term upgrades vs immediate needs

---

## 9. Tags & Traits System

### 9.1 Tag Categories
- **Personality**: Affects behavior and compatibility
- **Physical**: Affects stats and abilities
- **Elemental**: Determines strengths/weaknesses
- **Skills**: Special abilities and bonuses
- **Status**: Temporary conditions

### 9.2 Tag Effects
- Modify stat calculations
- Enable special abilities
- Affect breeding compatibility
- Unlock unique quests
- Provide passive bonuses

---

## 10. Save System

### 10.1 Save Slots
- Multiple save slots available
- Each slot maintains complete game state
- No auto-save (player must save manually)

### 10.2 Save Data Includes
- All creatures and their states
- Resources and inventory
- Quest progress
- Current week and time data
- System settings and preferences

---

## 11. Difficulty & Progression

### 11.1 Difficulty Factors
- Creature aging (permanent)
- Limited active roster
- Stamina management
- Resource scarcity
- Quest time limits

### 11.2 Progression Goals
1. **Early Game**: Build basic collection, learn mechanics
2. **Mid Game**: Optimize roster, start breeding program
3. **Late Game**: Rare creature collection, perfect breeds
4. **End Game**: Complete collection, achievements

---

## 12. Victory Conditions

### 12.1 Main Objectives
- Complete main story quest line
- Achieve master collector status (all species)
- Breed a perfect creature (all stats 1000)

### 12.2 Optional Objectives
- Complete all achievements
- Unlock all areas
- Maximize reputation with all factions
- Create unique breed combinations

---

## Strategy Tips

### Beginner
1. Focus on a balanced active roster
2. Always keep some food in reserve
3. Don't neglect creature age - plan succession
4. Complete daily quests for steady resources

### Intermediate
1. Start selective breeding programs
2. Optimize stat distributions for specific activities
3. Build specialized teams for different quest types
4. Manage multiple generation breeding lines

### Advanced
1. Min-max breeding for perfect stats
2. Exploit tag synergies
3. Plan multi-generation breeding strategies
4. Optimize resource efficiency

---

## Implementation Status

### Completed Systems
- ✅ Creature data structure
- ✅ Stats and age system
- ✅ Collection management (active/stable)
- ✅ Stamina system
- ✅ Time progression
- ✅ Save/Load system
- ✅ Tags system
- ✅ Species system
- ✅ UI framework

### Pending Systems
- ⏳ Quest system (core structure exists)
- ⏳ Breeding mechanics
- ⏳ Trading system
- ⏳ Combat/Competition mechanics
- ⏳ Achievement system
- ⏳ Full UI implementation

---

## Balancing Notes

### Stamina Economy
- Average creature can perform 5-10 activities before exhaustion
- Food should be valuable but not impossibly scarce
- Emergency food should always be obtainable through basic quests

### Age Progression
- Average creature lives 10 years (520 weeks)
- Breeding window is 50% of lifespan
- Players need ~2-3 generations for significant stat improvement

### Collection Rate
- Players should acquire 1-2 new creatures per play session
- Rare creatures should appear every 10-20 acquisitions
- Complete collection should take 50-100 hours

### Difficulty Curve
- Tutorial: Weeks 1-4
- Easy: Weeks 5-20
- Normal: Weeks 21-100
- Hard: Weeks 100+
- Scaling based on player collection size and creature stats