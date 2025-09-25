# Training System Specifications

## Training Overview

The training system allows players to improve their creatures' stats through weekly activities. Training integrates with the **Time Management System** (see [time.md](time.md)) to coordinate weekly progression and aging.

## Creature States and Time

For complete details on creature states, time progression, and weekly cycles, see **[time.md](time.md)**.

### Key Time Integration Points
- **Active Creatures**: Participate in weekly time progression
- **Stable Creatures**: Unaffected by time passage (stasis)
- **Weekly Cycles**: Training activities resolve during global time advancement
- **Aging**: Active creatures age +1 week when time progresses

## Training Mechanics

### Weekly Training System
- **Duration**: Each training activity takes 1 full week
- **Aging**: Creature ages +1 week after training completion
- **Food Requirement**: Must assign food before training begins
- **Stamina Cost**: Training activities consume stamina over the week

### Training Efficiency by Age
- **Young (0-25% lifespan)**: Fast learning, +20% training effectiveness
- **Adult (25-75% lifespan)**: Standard training effectiveness
- **Elder (75-100% lifespan)**: Slower learning, -20% training effectiveness, +10% wisdom gain

### Training Efficiency Factors
- **Activity Type**: Different training activities provide different stat gains and stamina costs
- **Age**: Young creatures learn faster, elder creatures learn slower but gain wisdom bonuses
- **Food Effects**: Assigned food can modify training effectiveness
- **Current Stat Level**: Does not affect training efficiency or costs

## Training Activities (Weekly Duration)

Each training activity takes one full week and ages the creature by +1 week.

### Strength Training
- **Weight Lifting**: Basic strength building, 10 stamina cost, +8-25 STR
- **Combat Practice**: Fighting training, 15 stamina cost, +15-35 STR
- **Heavy Labor**: Construction work, 20 stamina cost, +25-40 STR
- **Boulder Pushing**: Advanced strength training, 25 stamina cost, +35-50 STR

### Constitution Training
- **Endurance Running**: Basic stamina building, 10 stamina cost, +8-25 CON
- **Exposure Training**: Environmental resistance, 15 stamina cost, +15-35 CON
- **Survival Challenges**: Harsh condition training, 20 stamina cost, +25-40 CON
- **Marathon Training**: Extended endurance, 25 stamina cost, +35-50 CON

### Dexterity Training
- **Agility Courses**: Obstacle navigation, 8 stamina cost, +8-25 DEX
- **Precision Tasks**: Fine motor control, 12 stamina cost, +12-30 DEX
- **Reaction Training**: Speed enhancement, 15 stamina cost, +20-35 DEX
- **Acrobatics**: Advanced agility, 20 stamina cost, +30-45 DEX

### Intelligence Training
- **Puzzle Solving**: Basic problem solving, 5 stamina cost, +5-20 INT
- **Learning Exercises**: Knowledge acquisition, 10 stamina cost, +12-30 INT
- **Cognitive Challenges**: Complex thinking, 15 stamina cost, +20-35 INT
- **Strategy Games**: Advanced problem solving, 20 stamina cost, +30-45 INT

### Wisdom Training
- **Observation Exercises**: Perception training, 5 stamina cost, +5-20 WIS
- **Environmental Exposure**: Natural instinct development, 10 stamina cost, +12-30 WIS
- **Alertness Drills**: Awareness enhancement, 15 stamina cost, +20-35 WIS
- **Meditation**: Inner wisdom development, 8 stamina cost, +10-25 WIS

### Discipline Training
- **Obedience Training**: Basic command following, 8 stamina cost, +8-25 DIS
- **Focus Exercises**: Concentration improvement, 12 stamina cost, +12-30 DIS
- **Command Drills**: Advanced obedience, 15 stamina cost, +20-35 DIS
- **Military Training**: Elite discipline, 25 stamina cost, +35-50 DIS

### Resting Activity
- **Rest Week**: Recovery and stamina restoration, restores 30-50 stamina, no stat gains
  - Still requires food assignment and ages creature +1 week
  - Essential for stamina management between intensive training periods

## Training Facilities

### Basic Training Grounds
- **Available Activities**: Weight Lifting, Endurance Running, Agility Courses, Puzzle Solving, Observation Exercises, Obedience Training
- **Unlock**: Available from game start
- **Cost**: Free to use

### Advanced Training Center
- **Available Activities**: Combat Practice, Exposure Training, Precision Tasks, Learning Exercises, Environmental Exposure, Focus Exercises
- **Unlock**: Player level 5 or quest completion
- **Cost**: 50 gold per session

### Elite Training Academy
- **Available Activities**: Heavy Labor, Survival Challenges, Reaction Training, Cognitive Challenges, Alertness Drills, Command Drills
- **Unlock**: Player level 10 or special quest
- **Cost**: 150 gold per session

### Master Training Dojo
- **Available Activities**: Boulder Pushing, Marathon Training, Acrobatics, Strategy Games, Meditation, Military Training
- **Unlock**: Player level 20 or master trainer quest
- **Cost**: 500 gold per session

## Implementation Details

For complete Godot 4.5 implementation including enums, data structures, training systems, and facility management, see **[training_implementation.md](training_implementation.md)**.