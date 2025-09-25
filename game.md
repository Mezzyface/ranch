# Game Design Document

## Core Gameplay Loop

1. **Receive Request**: Player receives quest with specific stat and tag requirements
2. **Analyze Collection**: Player examines their creature collection to find suitable matches
3. **Acquire/Improve**: If no match exists, player must breed, tame, or train creatures
4. **Time Management**: Plan weekly activities for active creatures (see [time.md](time.md))
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
- Training integrates with time management system (see [time.md](time.md))
- Training consumes creature stamina and requires food assignment
- Only active creatures can train; stable creatures remain in stasis

## Quest System

The quest system drives gameplay through NPC requests for creatures meeting specific criteria. For complete quest mechanics, progression systems, and quest generation, see **[quest.md](quest.md)**.

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

## Godot 4.5 Architecture

### Core Systems
- **CreatureManager**: Handle creature collection, stats, validation
- **QuestSystem**: Manage quest progression, requirement checking
- **TrainingSystem**: Process training activities, stamina management
- **BreedingSystem**: Handle genetics, trait inheritance
- **LocationSystem**: Manage different environments and taming opportunities

### Scene Structure
- **Main Game Scene**: Central hub with creature management
- **Quest Interface**: Display requirements, progress tracking
- **Training Facilities**: Interactive training mini-games/activities
- **Breeding Center**: Genetics interface and offspring preview
- **Exploration Areas**: Taming locations with environmental challenges

### Data Management
- **Creature Database**: Store all creature definitions, stats, tags
- **Quest Database**: All quest definitions and requirements
- **Player Save Data**: Creature collection, progress, unlocks
- **Game Balance Config**: Stat curves, training costs, reward tables