# Time Management System

## Time Overview

The time system manages the passage of weeks and coordinates aging across all active creatures. Time progresses through weekly cycles where active creatures perform activities, age, and consume resources.

## Time Mechanics

### Time Units
- **Base Unit**: 1 Week
- **Progression**: Time advances when the player choose to move to the next week
- **Global**: All active creatures experience time simultaneously
- **Selective**: Only active creatures are affected by time passage

### Time Progression Triggers
- **Manual Advance**: Player initiates "End Week" when ready
- **Batch Processing**: All weekly activities process simultaneously

## Creature State Management

### Active Creatures
- **Weekly Activities**: Must be assigned an activity each week
- **Food Assignment**: Must be assigned food before week progression
- **Age Progression**: Gain +1 week age when time advances
- **Activity Resolution**: Activities resolve during time progression

### Stable Creatures (Stasis)
- **Time Immunity**: Unaffected by time progression
- **No Aging**: Remain at current age
- **No Activities**: Cannot be assigned weekly activities
- **Preserved State**: All stats and conditions remain unchanged

### State Transitions
- **Activation**: Move creature from Stable to Active roster
- **Stabilization**: Move creature from Active to Stable storage
- **Capacity Limits**: Stable and Active rosters have maximum capacity
- **Strategic Timing**: Players control when creatures are active

## Weekly Cycle Structure

### Phase 1: Planning
- **Activity Assignment**: Assign weekly activities to all active creatures
- **Food Assignment**: Assign food to all active creatures
- **Resource Check**: Verify sufficient resources (food, gold, etc.)
- **Validation**: Ensure all active creatures have valid assignments

### Phase 2: Processing
- **Time Advance**: Global week counter increases
- **Age Progression**: All active creatures age +1 week
- **Activity Resolution**: All activities process with food effects
- **Resource Consumption**: Food and other resources consumed

### Phase 3: Results
- **Outcome Display**: Show results of all activities
- **Stat Changes**: Apply training gains, breeding results, etc.
- **Status Updates**: Update creature conditions and states
- **Lifespan Check**: Handle creatures reaching maximum age

## Time-Related Events

### Weekly Events
- **Random Events**: Chance for special events each week
- **Seasonal Changes**: Environmental effects based on time
- **Market Fluctuations**: Food prices and availability changes
- **Quest Deadlines**: Time-sensitive mission updates

### Long-term Tracking
- **Game Week Counter**: Total weeks elapsed since game start
- **Creature Age Tracking**: Individual creature age progression
- **Historical Records**: Log of past activities and outcomes
- **Milestone Rewards**: Benefits for reaching time-based goals

## Lifespan and Death

### Age Categories
- **Young**: 0-25% of max lifespan
- **Adult**: 25-75% of max lifespan
- **Elder**: 75-100% of max lifespan
- **Critical**: 95%+ of max lifespan (death warning)

### Death Mechanics
- **Natural Death**: Creatures die when reaching maximum lifespan
- **Death Prevention**: Phoenix Ash food prevents aging for one week
- **Memorial**: Records of deceased creatures preserved

## Strategic Implications

### Resource Management
- **Active Roster Limits**: Limited active creature capacity
- **Food Costs**: Weekly food consumption for active creatures
- **Opportunity Costs**: Time spent on activities vs. other options
- **Long-term Planning**: Balance immediate needs with future goals

### Timing Decisions
- **Activation Timing**: When to move creatures from stable to active
- **Activity Sequencing**: Order of training and development
- **Breeding Windows**: Optimal ages for reproduction
- **Quest Scheduling**: Coordinating creature availability with missions

## Implementation Details

For complete Godot 4.5 implementation including TimeManager, ActivityAssignment, WeeklyEvents, and MemorialSystem, see **[time_implementation.md](time_implementation.md)**.