# Tag System Design

## Overview

The tag system categorizes creature capabilities, traits, and behaviors through a flexible labeling system. Tags determine quest eligibility, breeding compatibility, and environmental adaptability. Unlike stats which are numeric values, tags represent binary qualities that define what a creature can do, where it can thrive, and how it behaves.

## Tag Types by Acquisition

### Species Tags (Immutable)
Fixed traits inherent to a creature's species that cannot be changed:
- **Anatomical Features**: `[Winged]`, `[Aquatic]`, `[Bipedal]`, `[Quadruped]`
- **Physical Size Categories**: `[Tiny]`, `[Small]`, `[Medium]`, `[Large]`, `[Massive]`
- **Natural Abilities**: `[Echolocation]`, `[Venom]`, `[Natural Armor]`, `[Bioluminescent]`
- **Sensory Capabilities**: `[Dark Vision]`, `[Enhanced Hearing]`, `[Magnetic Sense]`

### Heritable Tags (Genetic)
Traits that can be passed from parents to offspring through breeding:
- **Temperament**: `[Territorial]`, `[Docile]`, `[Aggressive]`, `[Social]`
- **Intelligence Traits**: `[Sentient]`, `[Problem Solver]`, `[Pack Coordination]`
- **Environmental Adaptations**: `[Cold Resistant]`, `[Heat Resistant]`, `[Pressure Adapted]`
- **Specialized Behaviors**: `[Hoarder]`, `[Migratory]`, `[Nocturnal]`, `[Diurnal]`

### Trainable Tags (Acquired)
Skills and behaviors that can be developed through training and experience:
- **Combat Skills**: `[Guardian]`, `[Stealth]`, `[Intimidating]`
- **Utility Skills**: `[Tracker]`, `[Constructor]`, `[Cleanser]`, `[Messenger]`
- **Social Training**: `[Diplomatic]`, `[Performance]`, `[Service Animal]`
- **Environmental Training**: `[Sure-Footed]`, `[Deep Diver]`, `[High Altitude]`

### Equipment Tags (Temporary)
Capabilities granted by items, enhancements, or magical modifications:
- **Mobility Enhancements**: `[Flight Harness]`, `[Speed Boost]`, `[Water Walking]`
- **Sensory Augmentation**: `[Night Vision Goggles]`, `[Scent Amplifier]`
- **Protection Gear**: `[Armored]`, `[Environmental Suit]`, `[Magic Ward]`
- **Tool Integration**: `[Weapon Mount]`, `[Utility Belt]`, `[Communication Device]`

## Breeding and Genetics

### Tag Inheritance Patterns
- **Dominant Species Tags**: Always inherited from the dominant parent species
- **Recessive Traits**: May skip generations, requiring specific breeding combinations
- **Hybrid Vigor**: Rare cases where offspring gain unique tag combinations
- **Environmental Influence**: Some heritable tags can be influenced by breeding environment

### Breeding Strategy Applications
- **Pure Breeding**: Focus on strengthening specific heritable tags within a species
- **Crossbreeding**: Combine different species to create new tag combinations
- **Line Breeding**: Selective breeding over generations to establish stable trait lines
- **Outcrossing**: Introduce new genetic material to prevent trait stagnation

## Training and Development

### Skill Progression
- **Basic Training**: Foundation skills that most creatures can learn
- **Advanced Training**: Specialized skills requiring high base stats or specific temperament
- **Master Training**: Elite abilities requiring both natural talent and extensive practice

### Training Prerequisites
- **Stat Requirements**: Minimum stat thresholds for certain trainable tags
- **Species Compatibility**: Some training only works with specific anatomical features
- **Temperament Matching**: Training success influenced by creature's heritable behavioral tags
- **Environmental Factors**: Some skills can only be trained in specific environments

## Equipment Integration

### Equipment Slots and Compatibility
- **Anatomical Limitations**: Equipment tags limited by creature's physical structure
- **Size Scaling**: Equipment effectiveness varies with creature size categories
- **Multiple Equipment**: Stacking rules and conflicts between different equipment tags
- **Maintenance Requirements**: Equipment tags may degrade without proper care

### Temporary vs Permanent Modifications
- **Removable Equipment**: Standard gear that can be equipped/unequipped
- **Surgical Modifications**: Semi-permanent changes requiring specialized procedures
- **Magical Enhancements**: Temporary or permanent depending on spell type and duration
- **Biological Augmentation**: Permanent modifications that alter the creature's biology

## Gameplay Integration

### Quest System Requirements
Tags serve as core requirements for quest completion:
- **Single Tag Requirements**: Basic quests requiring one specific capability
- **Multi-Tag Combinations**: Complex quests needing creatures with multiple complementary tags
- **Tag Exclusions**: Some quests specifically exclude certain tags (e.g., no `[Aggressive]` creatures for diplomatic missions)
- **Progressive Complexity**: Advanced quests may require rare or difficult-to-obtain tag combinations

### Strategic Depth
- **Collection Planning**: Players must strategically build diverse creature collections
- **Breeding Projects**: Long-term breeding goals to create creatures with desired tag combinations
- **Training Investment**: Time and resource management for developing trainable tags
- **Equipment Optimization**: Balancing temporary equipment bonuses with permanent creature development

### Player Progression
- **Discovery Phase**: Learning which creatures naturally possess which species tags
- **Development Phase**: Training existing creatures and breeding for new combinations
- **Specialization Phase**: Creating highly specialized creatures for specific quest types
- **Mastery Phase**: Managing complex collections with creatures fulfilling multiple roles

## Environmental and Social Factors

### Habitat Influence
- **Natural Environment**: Some tags only develop in specific biomes or conditions
- **Facility Requirements**: Advanced training may require specialized buildings or equipment
- **Social Dynamics**: Pack animals may develop different tags when housed together vs. separately
- **Seasonal Variations**: Certain environmental adaptations may be seasonal or cyclical

### Rarity and Value
- **Common Tags**: Easily found or trained, suitable for basic quests
- **Uncommon Tags**: Require specific breeding or training, valuable for specialized tasks
- **Rare Tags**: Difficult to obtain, essential for high-level content
- **Unique Tags**: Extremely rare combinations, potentially game-changing capabilities