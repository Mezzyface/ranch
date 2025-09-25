# MVP Game Design Summary

## Overview

This document summarizes the complete Minimum Viable Product (MVP) design for a creature collection/breeding game. The MVP centers around the "A Gem of a Problem" quest line (TIM-01 through TIM-06) which serves as both tutorial and comprehensive test of all core game systems.

## Core Game Loop

1. **Acquire Creatures** → Shop purchases, breeding, or starter creatures
2. **Analyze Requirements** → Quest needs specific stats and tags
3. **Develop Creatures** → Training, competitions, or breeding to meet requirements
4. **Complete Quests** → Submit qualifying creatures for rewards
5. **Reinvest Resources** → Use gold and materials for next objectives

## Essential Systems for MVP

### 1. Creature System
- **6 Core Stats**: STR, CON, DEX, INT, WIS, DIS (0-1000 scale)
- **Essential Tags**: 12 tags covering size, behavior, environment, and utility
- **Creature Collection**: Player roster with active/stable states
- **Age System**: Weekly aging with performance modifiers (young/adult/elder)

### 2. Quest System (TIM Quest Line)
- **TIM-01**: Basic guard (Small + Territorial, DIS>80, WIS>70) → 300 gold
- **TIM-02**: Cave guard (Dark Vision, CON>120, STR>110) → 400 gold
- **TIM-03**: Multi-part cleanup (3 specialized creatures) → 1500 gold
- **TIM-04**: Logistics team (2 Sure-Footed creatures, multiple stats) → 1800 gold
- **TIM-05**: Vault guardian (Camouflage, CON>200, DIS>180) → 2500 gold + rare item
- **TIM-06**: Capstone challenge (5 creatures, diverse requirements) → 7500 gold + endgame unlocks

### 3. Shop System
- **6 Specialized Vendors**: Each focusing on creature types (armored, aerial, stealth, etc.)
- **Progressive Unlocks**: New shops unlock as quests complete
- **Creature Eggs**: Guaranteed stat ranges and tag combinations
- **Food Supply**: Training enhancement and basic sustenance

### 4. Training System
- **Weekly Activities**: Training takes 1 week, ages creature +1 week
- **Stat Progression**: Basic training provides +5-15 gains per week
- **Food Enhancement**: Training foods provide +50% effectiveness
- **Stamina Management**: Activities cost stamina, rest weeks restore it
- **Facility Tiers**: Basic Training Grounds sufficient for MVP

### 5. Competition System
- **Alternative Income**: Weekly competitions provide 50-400 gold prizes
- **10 Competition Types**: Covering all 6 stats with different focuses
- **Auto-Resolution**: Simulated events based on creature performance
- **Progressive Difficulty**: Beginner → Elite tiers unlock with quest progress
- **Economic Bridge**: Solves mid-game funding gaps

### 6. Time Management
- **Weekly Cycles**: Player advances time manually when ready
- **Active vs Stable**: Only active creatures age and participate in activities
- **Food Requirement**: All active creatures need weekly food assignment
- **Batch Processing**: All weekly activities resolve simultaneously

### 7. Breeding System (Basic)
- **Genetic Inheritance**: Offspring stats = parent average ± variance
- **Tag Inheritance**: Combination of parent tag sets
- **Egg Groups**: Breeding compatibility system (8 categories)
- **Economic Value**: Sell offspring for alternative income

## Starting Resources

- **500 Gold**: Sufficient for initial creature purchases and food
- **2-3 Starter Creatures**: Including basic Scuttleguard for early quests
- **10x Grain Rations**: Basic food supply for first weeks

## Economic Flow Analysis

### Investment Requirements by Quest
- **TIM-01**: 205 gold investment → +95 gold net (tutorial profit)
- **TIM-02**: 50 gold investment → +350 gold net (first profit)
- **TIM-03**: 1,820 gold investment → -320 gold net (investment gap)
- **TIM-04**: 1,260 gold investment → +540 gold net (profitable)
- **TIM-05**: 950 gold investment → +1,550 gold net (profitable)
- **TIM-06**: 4,325 gold investment → +3,175 gold net (capstone profit)

### Total Economic Balance
- **Total Investment**: 8,610 gold across all quests
- **Total Returns**: 13,300 gold in rewards
- **Net Profit**: +4,690 gold plus valuable unlocks and items
- **Competition Income**: Additional 200-800+ gold per week available

## Critical Success Path

### Phase 1: Tutorial (TIM-01, TIM-02)
- **Weeks 1-3**: Complete both quests with Scuttleguard + minimal training
- **Gold Status**: Start 500 → End ~795 gold
- **Systems Learned**: Basic quest validation, training, food assignment

### Phase 2: Investment Gap Bridge (Pre-TIM-03)
- **Weeks 4-6**: Run competitions to build gold reserves
- **Income Target**: +300-600 gold from competitions
- **Gold Status**: 795 → 1,100-1,400 gold
- **Systems Learned**: Competition mechanics, advanced creature evaluation

### Phase 3: Specialization (TIM-03, TIM-04)
- **Weeks 7-10**: Purchase specialized creatures, complete complex quests
- **Investment**: 3,080 gold total for both quests
- **Returns**: 2,200 gold in rewards
- **Systems Learned**: Multi-creature management, diverse tag requirements

### Phase 4: Mastery (TIM-05, TIM-06)
- **Weeks 11-15**: High-end creature acquisition and complex challenge completion
- **Investment**: 5,275 gold for premium creatures and training
- **Returns**: 10,000 gold plus endgame unlocks
- **Systems Learned**: Advanced breeding, high-stakes resource management

## Minimum Creature Roster for Completion

### Essential Creatures (Shop Purchase)
1. **Scuttleguard** (200g) - TIM-01, TIM-02 foundation
2. **Glow Grub** (400g) - TIM-03 Part 1 (Bioluminescent + Cleanser)
3. **Wind Dancer** (500g) - TIM-03 Part 2 (Flies + DEX)
4. **Shadow Cat x2** (450g each) - TIM-03 Part 3 (Stealthy)
5. **Cave Stalker x2** (600g each) - TIM-04 logistics, TIM-06 guards
6. **Stone Sentinel** (800g) - TIM-05 vault guardian
7. **Boulder Mover** (1200g) - TIM-06 Part 2 (Constructor)
8. **Sage Owl** (1500g) - TIM-06 Part 3 (Sentient)

**Total Creature Investment**: 6,650 gold across 9+ creatures

### Food Requirements
- **Basic Foods**: Grain Rations (5g), Wild Berries (10g)
- **Training Foods**: Stat-specific enhancement foods (25g each)
- **Competition Foods**: Combat Rations (40g), Task Fuel (35g)

## Implementation Priority

### Core MVP Features (Must Have)
1. **Creature Management**: Creation, stats, tags, collection interface
2. **Quest System**: TIM-01 through TIM-06 with validation
3. **Shop System**: 6 vendors with creature eggs and basic foods
4. **Training System**: Basic training activities and weekly progression
5. **Competition System**: 10 competition types with auto-resolution
6. **Time System**: Weekly advancement and creature aging

### Secondary Features (Nice to Have)
- Advanced training facilities beyond Basic Training Grounds
- Complex breeding genetics and rare inheritance patterns
- Extended food system with exotic items
- Additional quest lines beyond TIM series
- Visual polish and advanced UI elements

## Success Metrics

### Gameplay Completability
- ✅ All 6 TIM quests completable with documented systems
- ✅ Economic viability confirmed with competition income
- ✅ Progressive difficulty teaches all core mechanics
- ✅ Resource management creates meaningful decisions

### System Integration
- ✅ All major systems interact cohesively
- ✅ Time management drives weekly planning decisions
- ✅ Economic pressures create strategic trade-offs
- ✅ Creature diversity enables multiple solution paths

### Player Progression
- ✅ Early success with immediate quest completion
- ✅ Mid-game challenge requiring resource management
- ✅ Late-game mastery with complex multi-creature coordination
- ✅ Endgame unlocks providing continued progression potential

## Technical Architecture Notes

### Data Management
- **Creature Database**: All creature definitions, stats, tags, prices
- **Quest Database**: Requirements, rewards, progression chains
- **Shop Database**: Vendor inventories, prices, unlock conditions
- **Player Save**: Creature collection, progress, resources, time state

### Core Components (Godot 4.5)
- **CreatureManager**: Handle collection, validation, statistics
- **QuestSystem**: Track progress, validate requirements
- **ShopSystem**: Manage purchases, inventory, unlocks
- **TimeManager**: Weekly progression, aging, activity resolution
- **TrainingSystem**: Activity selection, stat gains, stamina management
- **CompetitionSystem**: Entry, simulation, rewards, rankings

This MVP design provides a complete, testable game experience that demonstrates all core systems while remaining feasible for initial implementation.