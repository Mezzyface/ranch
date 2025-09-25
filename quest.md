# Quest System Specifications

## Quest Overview

The quest system manages requests from NPCs that require players to provide creatures meeting specific stat and tag criteria. Quests serve as tutorials for creature selection and drive the core gameplay loop of breeding, training, and optimizing creatures.

## Quest Mechanics

### Quest Structure
- **Quest Giver**: NPC who provides the quest
- **Requirements**: Stat minimums and required tags
- **Quantity**: Number of creatures needed (default: 1)
- **Rewards**: Gold, XP, items, and unlocks
- **Prerequisites**: Conditions to unlock the quest

### Requirement Types
- **Stat Requirements**: Minimum values for specific stats
- **Tag Requirements**: Creatures must possess all specified tags
- **Quantity Requirements**: Multiple creatures needed for some quests
- **Multi-Part Quests**: Complex quests with separate requirements for each part

## Quest Categories

### Tutorial Quests
- **Purpose**: Teach core mechanics and creature selection
- **Structure**: Progressive difficulty with escalating requirements
- **Rewards**: Basic resources and system unlocks

### Story Quests
- **Purpose**: Advance main narrative and unlock new areas
- **Structure**: Linear progression with major story beats
- **Rewards**: Significant story progression and facility access

### Side Quests
- **Purpose**: Optional content for additional rewards
- **Structure**: Independent quests available alongside main story
- **Rewards**: Bonus resources, rare items, cosmetic unlocks

### Radiant Quests
- **Purpose**: Repeatable endgame content
- **Structure**: Procedurally generated requirements
- **Rewards**: Ongoing income and rare materials

## Quest Validation System

### Creature Matching
- **Stat Validation**: Check if creature meets minimum stat requirements
- **Tag Validation**: Verify creature possesses all required tags
- **Multi-Creature**: For quests requiring multiple creatures, validate each individually
- **Substitution**: Allow player to swap creatures before final submission

### Progress Tracking
- **Partial Completion**: Track progress on multi-part quests
- **Requirement Display**: Show which requirements are met/unmet
- **Recommendation System**: Suggest suitable creatures from player's collection

## Quest Progression

### Linear Progression
- **Prerequisite System**: Quests unlock based on completion of previous quests
- **Difficulty Scaling**: Requirements increase with player progression
- **Gated Content**: Advanced areas and features unlock through quest completion

### Branch Progression
- **Choice Points**: Some quests offer multiple paths forward
- **Specialization**: Different branches focus on different creature types
- **Convergence**: Branches may reconverge at major story points

## Reward Systems

### Base Rewards
- **Gold**: Currency for purchasing food, facilities, and services
- **Experience**: Player progression points for unlocking features
- **Items**: Consumables, breeding materials, and equipment

### Progression Rewards
- **Facility Unlocks**: Access to new training facilities or areas
- **Capacity Increases**: Expand active roster or stable storage
- **Feature Unlocks**: New game mechanics or quality-of-life features

### Rare Rewards
- **Unique Creatures**: Special creatures not available through normal means
- **Legendary Items**: Powerful consumables or permanent upgrades
- **Cosmetic Unlocks**: Visual customizations for creatures or facilities

## Example Quest Line: "A Gem of a Problem"

### Quest 1: Study Guard (TIM-01)
- **Requirements**:
  - Tags: SMALL, TERRITORIAL
  - Stats: Discipline > 5, Wisdom > 4
- **Rewards**: 150 Gold, 50 XP
- **Purpose**: Introduction to basic stat and tag matching

### Quest 2: Going Underground (TIM-02)
- **Requirements**:
  - Tags: DARK_VISION
  - Stats: Constitution > 8, Strength > 7
- **Rewards**: 400 Gold, 150 XP, Tim's Cave location unlock
- **Purpose**: Introduce environmental tags and higher stat requirements

### Quest 3: Cave Ecology 101 (TIM-03)
- **Multi-Part Requirements**:
  - Part 1: Tags: BIOLUMINESCENT, CLEANSER (1 creature)
  - Part 2: Tags: FLIES, Stats: Dexterity > 6 (1+ creatures)
  - Part 3: Tags: STEALTHY, Stats: Wisdom > 6 (2 creatures)
- **Rewards**: 1200 Gold, 300 XP
- **Purpose**: Complex multi-part quest with specialized roles

### Quest 4: Subterranean Shipping (TIM-04)
- **Requirements**:
  - Tags: SURE_FOOTED
  - Stats: Strength > 8, Intelligence > 5, Discipline > 7
  - Quantity: 2 creatures
- **Rewards**: 1000 Gold, 250 XP
- **Purpose**: Multi-creature quest with balanced stat requirements

### Quest 5: The Living Lock (TIM-05)
- **Requirements**:
  - Tags: CAMOUFLAGE
  - Stats: Constitution > 12, Discipline > 10
- **Rewards**: 2500 Gold, 500 XP, Flawless Sapphire
- **Purpose**: High-tier specialized request with rare item reward

### Quest 6: Dungeon Master's Decree (TIM-06)
- **Multi-Part Requirements**:
  - Part 1: Tags: DARK_VISION, Stats: Constitution > 8, Strength > 7 (3 creatures)
  - Part 2: Tags: CONSTRUCTOR, Stats: Strength > 15 (1 creature)
  - Part 3: Tags: SENTIENT, Stats: Intelligence > 14 (1 creature)
- **Rewards**: 7500 Gold, 1200 XP, Tim's Geological Marvel shop, Preferred Contractor status
- **Purpose**: Capstone quest demonstrating mastery across multiple disciplines

## Quest Generation System

### Template-Based Generation
- **Quest Templates**: Define structure and requirement patterns
- **Variable Substitution**: Randomize specific stats, tags, and quantities
- **Difficulty Scaling**: Adjust requirements based on player progression

### Procedural Generation
- **Requirement Algorithms**: Generate balanced stat and tag combinations
- **Reward Scaling**: Match rewards to quest difficulty
- **Variety Mechanisms**: Ensure diverse quest types and themes

### Dynamic Quests
- **Player Collection Analysis**: Generate quests based on creatures player owns
- **Challenge Adjustment**: Create quests that push player to improve their collection
- **Market Integration**: Quests that encourage specific food purchases or training activities

## Quest Integration Points

### Training System
- **Goal-Oriented Training**: Players train creatures to meet specific quest requirements
- **Progress Tracking**: Show training progress toward quest goals
- **Recommendation Engine**: Suggest optimal training activities for quest preparation

### Breeding System
- **Strategic Breeding**: Design breeding programs to produce quest-suitable offspring
- **Legacy Planning**: Long-term breeding strategies for future quest requirements
- **Genetic Tracking**: Monitor bloodlines capable of producing specific stat/tag combinations

### Time Management
- **Deadline Pressure**: Some quests may have time limits
- **Optimal Timing**: Strategic timing of creature activation for quest completion
- **Resource Planning**: Balance quest completion with creature development

## NPC Quest Givers

### Specialist NPCs
- **Tim (Gem Collector)**: Tutorial quest line focusing on guards and utility creatures
- **Commander Silva (Military)**: Combat-focused quests requiring strong, disciplined creatures
- **Dr. Fauna (Researcher)**: Intelligence-based quests for study and experimentation
- **Master Builder (Construction)**: Strength and construction-oriented quests

### Rotating NPCs
- **Traveling Merchants**: Temporary quests with unique rewards
- **Seasonal Characters**: Holiday or event-specific quest givers
- **Emergency Contacts**: Crisis situations requiring immediate creature deployment

## Quest Management Features

### Quest Journal
- **Active Quests**: Track current quest progress and requirements
- **Completed Quests**: History of finished quests and received rewards
- **Available Quests**: List of unlocked but not yet started quests

### Progress Indicators
- **Requirement Checklist**: Visual indicators for met/unmet requirements
- **Creature Suggestions**: Highlight suitable creatures in player's collection
- **Training Recommendations**: Calculate optimal training paths for quest completion

### Collection Integration
- **Creature Filtering**: Filter collection by quest suitability
- **Batch Validation**: Check multiple creatures against quest requirements simultaneously
- **Auto-Assignment**: Automatically assign suitable creatures to quest slots

## Implementation Details

For complete Godot 4.5 implementation including quest validation, generation systems, and NPC management, see **[quest_implementation.md](quest_implementation.md)**.