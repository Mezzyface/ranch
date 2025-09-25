# Game Design Document

## Core Gameplay Loop

1. **Receive Request**: Player receives quest with specific stat and tag requirements
2. **Analyze Collection**: Player examines their creature collection to find suitable matches
3. **Acquire/Improve**: If no match exists, player must breed, tame, or train creatures
4. **Time Management**: Plan weekly activities for active creatures (see [time.md](../design/systems/time.md))
5. **Deliver**: Submit qualifying creatures to quest giver
6. **Receive Rewards**: Gain gold, XP, items, and unlock new content

## Acquisition Systems

### Breeding
- Combine two parent creatures to create offspring
- Offspring inherit traits and potential stat ranges from parents
- Can produce creatures with new tag combinations

### Taming
- Capture wild creatures from various environments
- Wild creatures come with base stats and inherent tags
- Taming difficulty varies by creature type and environment

### Training
- Improve creature stats through weekly training activities
- Training integrates with time management system (see [time.md](../design/systems/time.md))
- Training consumes creature stamina and requires food assignment
- Only active creatures can train; stable creatures remain in stasis

## Quest System

The quest system drives gameplay through NPC requests for creatures meeting specific criteria. For complete quest mechanics, progression systems, and quest generation, see **[quest.md](../design/features/quest.md)**.

### Core Quest Mechanics
- **Requirement Matching**: Stats and tags determine creature suitability
- **Progressive Difficulty**: Requirements scale with player advancement
- **Multi-Part Quests**: Complex requests with specialized roles
- **Reward Scaling**: Better rewards for more challenging requirements

## Reward Systems

### Currency & Experience
- **Gold**: Primary currency for purchasing items, services
- **XP**: Player experience for progression and unlocks

### Items & Materials
- **Breeding Components**: Rare materials like Flawless Sapphire
- **Training Equipment**: Items to enhance training effectiveness
- **Construction Materials**: For building facilities

### Unlocks
- **New Locations**: Access to different environments and creatures
- **Shop Upgrades**: Enhanced vendor inventories and services
- **Radiant Quests**: Repeatable content for ongoing gameplay

## Game Balance Framework

### Stat Progression Curves
- **Tutorial/Early**: Stats 70-150 out of 1000 (easily achievable with starter creatures)
- **Intermediate**: Stats 150-300 out of 1000 (requires training/breeding focus)
- **Advanced**: Stats 300-600+ out of 1000 (demands specialization and rare creatures)

### Tag Distribution
- **Common Tags**: Easily found on multiple creature types
- **Environmental Tags**: Specific to certain biomes/locations
- **Utility Tags**: Rarer, often requiring breeding combinations
- **Behavioral Tags**: Influenced by training and creature personality

### Multi-Creature Scaling
- Single creature → Two creatures → Three+ creatures
- Simple requirements → Complex multi-part objectives
- Individual specialists → Coordinated teams

## Godot 4.5 Architecture (v2.0 - Improved)

### Core Architecture Pattern
- **MVC Separation**: Resources (Model), Nodes (Controller), Scenes (View)
- **Single GameCore**: One autoload managing all subsystems (NOT multiple singletons)
- **SignalBus**: Centralized signal routing for decoupled communication
- **Lazy Loading**: Subsystems loaded on demand for performance

### System Architecture
```
GameCore (Only Autoload)
├── CreatureSystem (lazy-loaded)
├── QuestSystem (lazy-loaded)
├── SaveSystem (ConfigFile-based)
├── TrainingSystem (lazy-loaded)
└── SignalBus (signal routing)
```

### Data Layer (Resources - NO Signals)
- **CreatureData**: Pure creature data storage
- **SpeciesData**: Species templates and generation rules
- **QuestData**: Quest requirements and rewards
- **TrainingData**: Training activities and modifiers

### Controller Layer (Nodes - Behavior & Signals)
- **CreatureEntity**: Handles creature behavior, emits signals
- **QuestController**: Manages quest state and validation
- **TrainingController**: Processes training logic
- **SystemControllers**: Coordinate between data and UI

### Save System (ConfigFile - NOT store_var)
- **Versioned Saves**: Support for save migration
- **Human-Readable**: ConfigFile format for debugging
- **Robust**: Won't break between Godot versions