# Breeding System Design

## Overview

The breeding system allows players to combine two parent creatures to create offspring with inherited traits. Breeding is restricted by egg groups - creatures can only breed with others that share at least one compatible egg group. The resulting offspring inherit a combination of species characteristics, stats, tags, and color variants from their parents.

## Egg Group System

### Egg Group Categories
Creatures belong to one or more egg groups that determine breeding compatibility:

- **Mammalian**: Warm-blooded creatures with fur or skin
- **Avian**: Birds and flying creatures with feathers or wings
- **Reptilian**: Cold-blooded scaled creatures
- **Aquatic**: Water-dwelling creatures with fins or gills
- **Arthropod**: Creatures with exoskeletons and segmented bodies
- **Magical**: Creatures with innate magical properties
- **Elemental**: Beings tied to specific elemental forces
- **Construct**: Artificial or mechanically created beings

### Breeding Compatibility Rules
- **Same Group**: Creatures in identical egg groups can always breed
- **Compatible Groups**: Some groups have natural compatibility (e.g., Mammalian + Magical)
- **Incompatible Groups**: Certain combinations cannot produce offspring (e.g., Construct + Aquatic)
- **Multi-Group Creatures**: Creatures with multiple egg groups have more breeding options

## Inheritance Mechanics

### Species Inheritance
The offspring's species is determined by parent compatibility and dominance:
- **Same Species**: Offspring is always the same species as parents
- **Cross-Species**: Offspring may be either parent species or rarely a hybrid
- **Hybrid Creation**: Requires specific egg group combinations and rare breeding materials
- **Dominant Traits**: Some species have stronger inheritance patterns than others

### Stat Inheritance
Starting stats are derived from parent creatures through genetic algorithms:
- **Base Range**: Each parent contributes a stat range based on their current values
- **Genetic Potential**: Higher parent stats increase offspring's potential ceiling
- **Regression Factor**: Offspring stats tend toward species averages, preventing extreme inheritance
- **Random Variation**: Small random factors ensure genetic diversity

#### Stat Inheritance Formula
- **Base Range**: Calculated from parent stats with species modifiers
- **Compatibility Bonus**: Better egg group compatibility increases inheritance quality
- **Facility Bonus**: Advanced breeding facilities improve stat range potential
- **Item Modifiers**: Special breeding materials can guarantee minimum stat thresholds
- **Final Result**: Breeding conditions determine where in the potential range offspring lands

### Tag Inheritance
Tags follow different inheritance patterns based on their type:

#### Species Tags (Always Inherited)
- Anatomical and size tags always match the offspring's resulting species
- Cannot be modified through breeding

#### Heritable Tags (Genetic Inheritance)
- **Base Inheritance**: Probability determined by genetic dominance patterns
- **Breeding Quality**: Better conditions increase inheritance chances for desirable tags
- **Linked Tags**: Some tags inherit together as genetic packages
- **Enhanced Expression**: Optimal breeding setup can guarantee certain tag inheritance

#### Trainable Tags (Not Inherited)
- Must be developed through training after birth
- Parents' trained abilities do not pass to offspring

#### Equipment Tags (Not Inherited)
- Temporary modifications are not genetic
- Offspring start with no equipment tags

### Color Variant Inheritance
Visual appearance follows specific inheritance patterns:
- **Dominant Colors**: Common variants have higher inheritance probability
- **Recessive Colors**: Rare variants require both parents to carry the gene
- **New Combinations**: Crossbreeding can create previously unseen color patterns
- **Regional Variants**: Some colors are tied to specific environments or breeding locations

## Breeding Requirements

### Basic Requirements
- **Compatible Egg Groups**: Both parents must share at least one egg group
- **Maturity**: Both creatures must be adults (past adolescent age)
- **Health Status**: Both parents must be healthy and well-fed
- **Breeding Resource**: Breeding Creatures passes time, and requires resources

### Advanced Breeding
- **Breeding Facilities**: Specialized buildings improve success rates and inheritance quality
- **Dietary Supplements**: Specific foods during breeding can influence inheritance
- **Environmental Factors**: Breeding location may affect certain inherited traits
- **Breeding Items**: Rare materials can guarantee specific inheritance patterns or enable hybrid creation

## Breeding Outcomes

### Breeding Success
- **Guaranteed Offspring**: Breeding always produces offspring when requirements are met
- **Quality Variation**: Compatibility, facilities, food, and items affect inheritance quality
- **Outcome Modifiers**: Better conditions improve stat inheritance ranges and tag expression
- **Hybrid Enabling**: Special materials and optimal conditions enable cross-species hybrids

### Gestation and Development
- **Gestation Period**: 1-2 in-game weeks depending on species
- **Egg Stage**: Some species produce eggs that require incubation
- **Growth Stages**: Offspring progress through juvenile → adolescent → adult phases
- **Early Influence**: Care during early stages can affect final adult characteristics

## Strategic Breeding Applications

### Genetic Line Planning
- **Pure Lines**: Breeding within species to strengthen specific traits
- **Hybrid Programs**: Long-term crossbreeding to create unique combinations
- **Trait Stacking**: Combining parents with complementary heritable tags
- **Stat Optimization**: Selective breeding to push stat ranges toward species maximums

### Collection Goals
- **Quest Preparation**: Breeding creatures with specific tag combinations for future quests
- **Specialty Roles**: Creating creatures optimized for particular activities
- **Color Collection**: Pursuing rare and beautiful color variants
- **Legacy Projects**: Multi-generation breeding programs with long-term goals

### Resource Management
- **Breeding Costs**: Food, facilities, and time investment considerations
- **Opportunity Cost**: Balancing breeding time against training active creatures
- **Storage Limitations**: Managing growing creature collections
- **Genetic Diversity**: Maintaining healthy breeding populations to prevent trait stagnation

## Integration with Other Systems

### Quest System
- Many high-level quests require creatures with specific inherited traits
- Some quests unlock new breeding materials or techniques
- Breeding achievements may unlock advanced quest lines

### Training System
- Inherited stats provide the foundation for training potential
- Some trainable tags are easier to develop with specific inherited traits
- Training facilities may offer breeding-related services

### Time Management
- Breeding projects require long-term planning and patience
- Active vs. stable creature decisions affect breeding program timing
- Weekly activity allocation must account for breeding facility management

### Equipment System
- Some equipment enhances breeding success or inheritance quality
- Breeding-specific tools and facilities represent major investments
- Certain rare materials are essential for hybrid creation attempts