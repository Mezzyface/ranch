# Shop System Design

## Overview

The shop system provides players with access to specialized creature eggs and food through multiple vendor companies. Each company specializes in specific creature lineages or food types, creating strategic purchasing decisions and unlocking creature diversity needed for quest completion.

## Shop Categories

### Creature Egg Vendors
Companies that sell creature eggs with guaranteed stat ranges and tag combinations. Eggs hatch into young creatures (0-5% lifespan) with predetermined genetics.

### Food Suppliers
Companies that provide different food types for training enhancement, creature care, and specialized activities.

### Equipment & Service Vendors
Companies offering creature equipment, breeding services, and facility upgrades.

## Creature Egg Vendors

### Armored Specialists Co.
**Specialization**: Defensive and guard creatures
**Company Philosophy**: "Unbreakable protection, unwavering loyalty"

**Available Eggs:**
- **Scuttleguard Egg**: 200 gold
  - Guaranteed Tags: `[Small]`, `[Territorial]`, `[Dark Vision]`
  - Stat Ranges: STR: 70-130, CON: 80-140, DEX: 90-150, INT: 40-70, WIS: 110-170, DIS: 90-150
  - Perfect for early guard quests (TIM-01, TIM-02)

- **Stone Sentinel Egg**: 800 gold
  - Guaranteed Tags: `[Medium]`, `[Camouflage]`, `[Natural Armor]`, `[Territorial]`
  - Stat Ranges: STR: 130-190, CON: 190-280, DEX: 50-110, INT: 50-90, WIS: 130-220, DIS: 160-250
  - Ideal for vault guardian roles (TIM-05)

- **Cave Stalker Egg**: 600 gold
  - Guaranteed Tags: `[Small]`, `[Dark Vision]`, `[Stealthy]`, `[Sure-Footed]`
  - Stat Ranges: STR: 90-150, CON: 110-170, DEX: 150-250, INT: 80-130, WIS: 140-230, DIS: 130-190
  - Multi-role creature for cave operations (TIM-03, TIM-04)

### Aerial Dynamics Inc.
**Specialization**: Flying and aerial creatures
**Company Philosophy**: "Masters of sky and wind"

**Available Eggs:**
- **Wind Dancer Egg**: 500 gold
  - Guaranteed Tags: `[Small]`, `[Winged]`, `[Flies]`, `[Enhanced Hearing]`
  - Stat Ranges: STR: 70-110, CON: 80-130, DEX: 190-280, INT: 90-140, WIS: 150-250, DIS: 90-150
  - Perfect for pest control (TIM-03 Part 2)

- **Sky Courier Egg**: 700 gold
  - Guaranteed Tags: `[Medium]`, `[Winged]`, `[Flies]`, `[Messenger]`, `[Sure-Footed]`
  - Stat Ranges: STR: 130-190, CON: 140-200, DEX: 150-220, INT: 130-190, WIS: 150-220, DIS: 190-280
  - Excellent logistics creature (TIM-04)

### BioLum Creatures Ltd.
**Specialization**: Bioluminescent and utility creatures
**Company Philosophy**: "Nature's living lights and tools"

**Available Eggs:**
- **Glow Grub Egg**: 400 gold
  - Guaranteed Tags: `[Small]`, `[Bioluminescent]`, `[Cleanser]`, `[Nocturnal]`
  - Stat Ranges: STR: 50-90, CON: 90-150, DEX: 70-130, INT: 70-110, WIS: 130-190, DIS: 110-170
  - Essential for sanitation tasks (TIM-03 Part 1)

- **Lantern Beetle Egg**: 650 gold
  - Guaranteed Tags: `[Small]`, `[Bioluminescent]`, `[Cleanser]`, `[Flies]`, `[Sure-Footed]`
  - Stat Ranges: STR: 80-130, CON: 110-170, DEX: 130-220, INT: 90-150, WIS: 140-200, DIS: 130-190
  - Multi-utility creature for cave operations

### Stealth Ops Breeding
**Specialization**: Stealth and reconnaissance creatures
**Company Philosophy**: "Unseen, unheard, unmatched"

**Available Eggs:**
- **Shadow Cat Egg**: 450 gold
  - Guaranteed Tags: `[Small]`, `[Stealthy]`, `[Territorial]`, `[Nocturnal]`
  - Stat Ranges: STR: 70-130, CON: 80-140, DEX: 150-250, INT: 90-150, WIS: 140-230, DIS: 80-140
  - Good for patrol duties (TIM-03 Part 3)

- **Mist Walker Egg**: 750 gold
  - Guaranteed Tags: `[Medium]`, `[Stealthy]`, `[Camouflage]`, `[Sure-Footed]`
  - Stat Ranges: STR: 110-170, CON: 130-190, DEX: 190-280, INT: 130-190, WIS: 190-280, DIS: 150-220
  - Premium stealth creature

### Construction Crews Inc.
**Specialization**: Building and construction creatures
**Company Philosophy**: "Built to build, made to last"

**Available Eggs:**
- **Boulder Mover Egg**: 1200 gold
  - Guaranteed Tags: `[Large]`, `[Constructor]`, `[Sure-Footed]`, `[Natural Armor]`
  - Stat Ranges: STR: 250-330, CON: 190-280, DEX: 70-130, INT: 90-150, WIS: 110-170, DIS: 190-280
  - Required for construction projects (TIM-06 Part 2)

- **Architect Ant Egg**: 900 gold
  - Guaranteed Tags: `[Small]`, `[Constructor]`, `[Problem Solver]`, `[Social]`
  - Stat Ranges: STR: 130-190, CON: 130-190, DEX: 150-220, INT: 190-280, WIS: 150-220, DIS: 220-310
  - Intelligent construction alternative

### Mindful Creatures Academy
**Specialization**: High-intelligence and sentient creatures
**Company Philosophy**: "Awakening minds, expanding possibilities"

**Available Eggs:**
- **Sage Owl Egg**: 1500 gold
  - Guaranteed Tags: `[Small]`, `[Sentient]`, `[Winged]`, `[Enhanced Hearing]`, `[Nocturnal]`
  - Stat Ranges: STR: 70-130, CON: 90-150, DEX: 130-190, INT: 220-330, WIS: 250-370, DIS: 150-220
  - Perfect puzzle master (TIM-06 Part 3)

- **Crystal Thinker Egg**: 2000 gold
  - Guaranteed Tags: `[Medium]`, `[Sentient]`, `[Problem Solver]`, `[Bioluminescent]`
  - Stat Ranges: STR: 90-150, CON: 130-220, DEX: 90-150, INT: 250-370, WIS: 220-310, DIS: 190-280
  - Premium intelligent creature

## Food Suppliers

### Grain & More General Store
**Basic food supplier for everyday needs**

**Available Foods:**
- **Grain Rations**: 5 gold - Standard food, no bonuses
- **Fresh Hay**: 8 gold - +5 stamina recovery
- **Wild Berries**: 10 gold - +2 to all training gains
- **Spring Water**: 3 gold - Removes negative effects

### Peak Performance Nutrition
**Training-focused food supplier**

**Available Foods:**
- **Protein Mix**: 25 gold - +50% Strength training effectiveness
- **Endurance Blend**: 25 gold - +50% Constitution training effectiveness
- **Agility Feed**: 25 gold - +50% Dexterity training effectiveness
- **Brain Food**: 25 gold - +50% Intelligence training effectiveness
- **Focus Formula**: 25 gold - +50% Wisdom training effectiveness
- **Discipline Diet**: 25 gold - +50% Discipline training effectiveness

### Premium Provisions Co.
**High-end food supplier**
**Unlock**: After completing TIM-03

**Available Foods:**
- **Golden Nectar**: 100 gold - +100% training effectiveness any stat
- **Ancient Grains**: 80 gold - +3 to all training gains, +10 stamina
- **Vitality Elixir**: 75 gold - +20 stamina recovery, stamina immunity

### Breeding Specialists Supply
**Breeding-focused food supplier**
**Unlock**: After completing TIM-04

**Available Foods:**
- **Breeding Supplement**: 50 gold - +50% breeding success, healthier offspring
- **Youth Serum**: 150 gold - Temporarily treats creature as younger age category

## Shop Progression & Unlocks

### Starting Shops (Available from game start)
- **Grain & More General Store**
- **Armored Specialists Co.**
- **Aerial Dynamics Inc.**

### Early Game Unlocks (After TIM-01)
- **BioLum Creatures Ltd.**
- **Stealth Ops Breeding**
- **Peak Performance Nutrition**

### Mid Game Unlocks (After TIM-03)
- **Construction Crews Inc.**
- **Premium Provisions Co.**

### Late Game Unlocks (After TIM-05)
- **Mindful Creatures Academy**
- **Breeding Specialists Supply**

## Economic Balance

### Early Game Economics (TIM-01, TIM-02)
- **Quest Rewards**: 150-400 gold
- **Essential Purchases**: Grain Rations (5g), Basic eggs (200-500g)
- **Strategy**: Focus on basic creatures and minimal training food

### Mid Game Economics (TIM-03, TIM-04)
- **Quest Rewards**: 1000-1200 gold
- **Essential Purchases**: Specialized eggs (400-800g), Training foods (25g)
- **Strategy**: Investment in diverse creature types and training efficiency

### Late Game Economics (TIM-05, TIM-06)
- **Quest Rewards**: 2500-7500 gold
- **Essential Purchases**: Premium eggs (1200-2000g), Advanced foods (75-150g)
- **Strategy**: High-end creatures and premium training resources

## Strategic Shopping for TIM Quests

### TIM-01 Shopping List
- **Scuttleguard Egg** (200g) - Perfect match for requirements
- **Grain Rations** (5g) for basic feeding

### TIM-02 Shopping List
- Use trained Scuttleguard from TIM-01, or
- **Stone Sentinel Egg** (800g) if stats insufficient
- **Protein Mix** (25g) for STR training if needed

### TIM-03 Shopping List
- **Glow Grub Egg** (400g) - Part 1 (Bioluminescent + Cleanser)
- **Wind Dancer Egg** (500g) - Part 2 (Flies + DEX)
- **Shadow Cat Egg** (450g) - Part 3 (Stealthy), need 2 total
- **Training foods** as needed for stat requirements

### TIM-04 Shopping List
- **Sky Courier Egg** (700g) - Sure-Footed + good stats, need 2
- **Training foods** for STR/INT/DIS enhancement

### TIM-05 Shopping List
- **Stone Sentinel Egg** (800g) or **Mist Walker Egg** (750g)
- **Premium foods** for intensive CON/DIS training

### TIM-06 Shopping List
- **Boulder Mover Egg** (1200g) - Constructor + high STR
- **Sage Owl Egg** (1500g) - Sentient + high INT
- Additional **Cave Stalker Eggs** for multiple guards
- **Premium foods** for final training push

## Implementation Notes

### Shop Interface Requirements
- **Company-based organization**: Group by vendor
- **Filter by tags**: Find creatures with specific capabilities
- **Filter by stats**: Find creatures with stat ranges
- **Unlock progression**: Show locked vendors with unlock conditions
- **Inventory management**: Track purchased eggs and food

### Economic Gameplay
- **Resource management**: Balance gold spending across quests
- **Investment timing**: When to buy vs. breed vs. train
- **Efficiency optimization**: Minimize costs while meeting quest requirements
- **Long-term planning**: Consider creature utility across multiple quests

This shop system provides the missing acquisition method while creating strategic economic decisions that enhance the core breeding/training gameplay loop.