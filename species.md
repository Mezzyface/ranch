# Species System Design

## Overview

The species system defines the various creature types available in the game. Each species represents a unique type of creature with distinct characteristics, stat distributions, visual appearance, and behavioral patterns. Species serve as templates for generating individual creature instances while ensuring consistency within each creature type.

## Core Concepts

### Species Identity
Each species has a unique identity that distinguishes it from others:
- **Species ID**: Internal identifier used by game systems (e.g., "scuttleguard")
- **Display Name**: Player-facing name shown in UI (e.g., "Scuttleguard")
- **Description**: Short flavor text describing the species
- **Lore**: Extended background, ecology, and origin story
- **Classification**: Fantasy taxonomy or creature category

### Species as Templates
Species act as templates that define:
- **Stat Ranges**: Minimum and maximum values for each stat when generating creatures
- **Guaranteed Traits**: Tags that all members of the species possess
- **Possible Traits**: Tags that some members might have
- **Visual Characteristics**: Base appearance and color variations
- **Behavioral Patterns**: How the species typically acts

## Species Characteristics

### Statistical Distribution
Each species defines the range of possible stats for its members:
- **Base Stats**: Typical or average stats for the species
- **Stat Ranges**: Minimum and maximum possible values for each stat
- **Stat Affinities**: Natural talent for certain stats (affects training)
- **Growth Patterns**: How quickly the species develops different stats

### Physical Attributes
- **Size Category**: Physical size classification (Tiny, Small, Medium, Large, Massive)
- **Weight Range**: Typical weight in kilograms
- **Height Range**: Typical height in centimeters
- **Body Type**: Physical structure (bipedal, quadrupedal, serpentine, etc.)
- **Distinctive Features**: Notable physical characteristics

### Life Cycle
- **Lifespan**: Average and maximum age in weeks
- **Maturity Age**: When the creature can breed
- **Growth Stages**: Progression through life stages
- **Aging Effects**: How age affects the creature's capabilities

### Behavioral Traits
- **Temperament**: Base personality (aggressive, docile, curious, etc.)
- **Activity Pattern**: When most active (diurnal, nocturnal, crepuscular)
- **Social Structure**: How they interact (solitary, pack, herd, colony)
- **Intelligence Level**: Cognitive capabilities
- **Trainability**: How well they respond to training

## Species Acquisition and Rarity

### Rarity Tiers
Species are categorized by how difficult they are to obtain:
- **Common**: Easily found, low cost, good for beginners
- **Uncommon**: Moderately available, balanced stats
- **Rare**: Hard to find, specialized abilities
- **Epic**: Very rare, exceptional capabilities
- **Legendary**: Extremely rare, unique powers
- **Unique**: One-of-a-kind species with special significance

### Acquisition Methods
- **Shop Purchase**: Available as eggs from specialized vendors
- **Wild Capture**: Found in specific environments
- **Breeding Result**: Only obtainable through specific breeding combinations
- **Quest Rewards**: Given for completing certain quests
- **Special Events**: Limited-time availability
- **Achievement Unlocks**: Earned through gameplay milestones

### Economic Value
- **Base Price**: Standard cost when purchasing eggs
- **Market Fluctuation**: How price varies with supply/demand
- **Trade Value**: Worth in player-to-player exchanges
- **Prestige Value**: Social status from owning rare species

## Species Examples

### Scuttleguard
- **Identity**: Small, territorial arthropod guardian
- **Stat Focus**: High WIS (110-170), DIS (90-150), moderate DEX (90-150)
- **Guaranteed Tags**: Small, Territorial, Dark Vision
- **Role**: Early game guardian, cave exploration
- **Rarity**: Common
- **Price**: 200 gold

### Stone Sentinel
- **Identity**: Living rock creature with incredible defense
- **Stat Focus**: Very high CON (190-280), high DIS (160-250)
- **Guaranteed Tags**: Medium, Natural Armor, Camouflage, Territorial
- **Role**: Premium defender, vault guardian
- **Rarity**: Uncommon
- **Price**: 800 gold

### Wind Dancer
- **Identity**: Graceful flying creature with exceptional agility
- **Stat Focus**: Very high DEX (190-280), high WIS (150-250)
- **Guaranteed Tags**: Small, Winged, Flies, Enhanced Hearing
- **Role**: Pest control, aerial reconnaissance
- **Rarity**: Common
- **Price**: 500 gold

### Glow Grub
- **Identity**: Bioluminescent utility creature
- **Stat Focus**: Balanced stats with high WIS (130-190)
- **Guaranteed Tags**: Small, Bioluminescent, Cleanser, Nocturnal
- **Role**: Cave sanitation, light source
- **Rarity**: Common
- **Price**: 400 gold

### Shadow Cat
- **Identity**: Stealthy feline predator
- **Stat Focus**: High DEX (150-250), high WIS (140-230)
- **Guaranteed Tags**: Small, Stealthy, Territorial, Nocturnal
- **Role**: Patrol, stealth missions
- **Rarity**: Common
- **Price**: 450 gold

### Boulder Mover
- **Identity**: Massive construction specialist
- **Stat Focus**: Very high STR (250-330), high DIS (190-280)
- **Guaranteed Tags**: Large, Constructor, Sure-Footed, Natural Armor
- **Role**: Heavy construction, obstacle clearing
- **Rarity**: Rare
- **Price**: 1200 gold

### Sage Owl
- **Identity**: Highly intelligent sentient bird
- **Stat Focus**: Very high INT (220-330), very high WIS (250-370)
- **Guaranteed Tags**: Small, Sentient, Winged, Enhanced Hearing, Nocturnal
- **Role**: Puzzle solving, complex tasks
- **Rarity**: Epic
- **Price**: 1500 gold

## Breeding and Genetics

### Species Compatibility
- **Same Species**: Always compatible, offspring is same species
- **Egg Group Overlap**: Different species can breed if they share egg groups
- **Hybrid Potential**: Some combinations may produce hybrid species
- **Inheritance Patterns**: How traits pass from parents to offspring

### Genetic Variation
- **Stat Inheritance**: Offspring stats influenced by parent values within species ranges
- **Tag Inheritance**: Some tags pass to offspring, others don't
- **Color Inheritance**: Visual traits follow genetic patterns
- **Mutation Chance**: Small possibility of unusual traits

## Species Progression

### Unlocking New Species
- **Quest Completion**: Story progress unlocks new species
- **Achievement Milestones**: Gameplay accomplishments grant access
- **Breeding Discoveries**: Creating specific combinations reveals new species
- **Shop Progression**: Vendor relationships unlock premium species
- **Seasonal Events**: Time-limited species during special periods

### Species Mastery
- **Collection Goals**: Rewards for obtaining all species in a category
- **Breeding Lines**: Achievements for perfecting genetic lines
- **Species Expert**: Bonuses for specializing in specific species
- **Completionist Rewards**: Benefits for full species collection

## Environmental Adaptation

### Habitat Preferences
Each species has preferred environments:
- **Native Habitat**: Where the species naturally thrives
- **Tolerated Environments**: Can survive but not optimal
- **Hostile Environments**: Suffers penalties or cannot survive

### Environmental Effects
- **Performance Modifiers**: Stats affected by environment match
- **Breeding Success**: Higher in preferred habitats
- **Health and Longevity**: Environment affects lifespan
- **Special Abilities**: Some abilities only work in certain environments

## Species Balance Considerations

### Statistical Balance
- **No Dominant Species**: Each has strengths and weaknesses
- **Role Specialization**: Different species excel at different tasks
- **Cost vs. Power**: Higher rarity/price provides advantages but not dominance
- **Training Potential**: All species can be viable with proper development

### Gameplay Balance
- **Early Access**: Common species sufficient for initial content
- **Progressive Difficulty**: Harder content may favor certain species
- **Multiple Solutions**: Various species combinations can solve challenges
- **Collection Incentive**: Benefits to diversifying rather than specializing

## Integration with Game Systems

### Quest System
- **Species Requirements**: Some quests require specific species
- **Tag Matching**: Quests check for species with certain tags
- **Stat Thresholds**: Species must meet minimum stat requirements
- **Collection Quests**: Objectives to obtain certain species

### Shop System
- **Vendor Specialization**: Different shops sell different species
- **Unlock Progression**: Higher tier species become available over time
- **Price Scaling**: Costs increase with rarity and power
- **Limited Stock**: Some species have purchase limits

### Competition System
- **Species Advantages**: Certain species excel in specific competitions
- **Balanced Categories**: Different competition types favor different species
- **Prestige Events**: Rare species required for elite competitions

### Training System
- **Stat Affinities**: Species have different training effectiveness
- **Ability Development**: Some abilities easier to train on certain species
- **Growth Rates**: Species develop at different speeds

## Future Expansion Possibilities

### New Species Categories
- **Elemental Variants**: Fire, water, earth, air specialized creatures
- **Mechanical Constructs**: Artificial or enhanced species
- **Ethereal Beings**: Ghost or spirit-type creatures
- **Legendary Uniques**: One-of-a-kind story creatures

### Species Evolution
- **Transformation Paths**: Species that can evolve into others
- **Conditional Evolution**: Requirements to trigger transformation
- **Branching Evolution**: Multiple possible evolution paths
- **Temporary Forms**: Situational transformations

### Regional Variants
- **Geographic Differences**: Same species with regional adaptations
- **Cultural Variants**: Species modified by different civilizations
- **Seasonal Forms**: Species that change with seasons
- **Environmental Mutations**: Adaptations to extreme conditions

## Implementation Notes

For implementation details including resource structure, database management, and technical specifications, see:
- **[species_implementation.md](species_implementation.md)** - Technical implementation guide
- **[stage_1/10_species_resources.md](stage_1/10_species_resources.md)** - Stage 1 implementation task

The species system should be data-driven using Godot's resource system, allowing easy addition and modification of species without code changes. Visual editing in the Godot inspector enables rapid balancing and iteration.