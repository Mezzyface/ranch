# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a planning directory containing comprehensive game design documentation for a creature collection/breeding game. The primary focus is on a tutorial quest line called "A Gem of a Problem" that teaches players creature selection based on stats and tags.

## Document Architecture

### Core System Documents
- `game.md` - Core gameplay loop, acquisition systems, and Godot 4.5 architecture overview
- `creature.md` - Creature system design including stats, tags, and behaviors
- `stats.md` - Stat system design with 6 core stats (STR, CON, INT, WIS, DEX, DIS)
- `tags.md` - Tag system for creature traits and environmental requirements
- `time.md` - Time management system for creature activities and stamina

### Gameplay Feature Documents
- `quest.md` - Quest system mechanics, progression, and quest generation algorithms
- `quest_design_doc.md` - Specific "A Gem of a Problem" quest line (TIM-01 through TIM-06)
- `training.md` - Training system mechanics and weekly activity management
- `food.md` - Food system for creature care and training enhancement
- `breeding.md` - Breeding system with egg group compatibility and inheritance mechanics
- `shop.md` - Multi-vendor shop system with specialized creature eggs and foods
- `competitions.md` - Weekly competition system for alternative income and creature development

### Project Overview Documents
- `mvp_summary.md` - Complete MVP design summary with economic analysis and implementation priorities
- No implementation documents (`*_implementation.md` files) exist yet

## Game Design Architecture

### Core Systems Integration
- **Creature Management**: Stats, tags, and validation systems work together
- **Quest System**: Dynamic requirement matching against creature collections (see quest.md for full mechanics)
- **Training System**: Weekly time management with food and stamina mechanics
- **Breeding System**: Egg group compatibility and genetic inheritance of stats and tags
- **Time Management**: Active vs. stable creature states with weekly planning
- **Food System**: Creature care and training enhancement through feeding
- **Shop System**: Multi-vendor ecosystem with progressive unlocks tied to quest completion
- **Competition System**: Alternative income source with performance-based rewards

### Quest Design Philosophy
Tutorial progression from simple to complex:
1. **TIM-01**: Basic tag/stat matching
2. **TIM-02**: Environmental requirements
3. **TIM-03**: Multi-part specialized roles
4. **TIM-04**: Utility creature logistics
5. **TIM-05**: High-tier specialized guardian
6. **TIM-06**: Capstone multi-discipline challenge

### Stat & Tag Framework
- **6 Core Stats**: STR, CON, INT, WIS, DEX, DIS (scale 1-1000)
- **Tag Categories**: Environmental, behavioral, physical, utility
- **Progressive Complexity**: From individual creatures to coordinated teams
- **Validation Systems**: Automatic requirement checking and creature matching

## Repository Structure

This is a **pure design documentation repository** - no actual code exists yet. All files are comprehensive design specifications for a creature collection game intended for implementation in Godot 4.5.

### Key Document Relationships
- **Quest System**: `quest.md` defines mechanics, `quest_design_doc.md` provides specific tutorial quest line
- **Creature System**: `creature.md` for basic design, `stats.md` and `tags.md` for detailed specifications
- **Breeding System**: `breeding.md` covers egg group compatibility and inheritance algorithms
- **Economic Systems**: `shop.md` and `competitions.md` provide creature acquisition and income sources
- **Time Management**: `time.md` integrates with `training.md`, `food.md`, and `competitions.md` for weekly creature care
- **MVP Overview**: `mvp_summary.md` synthesizes all systems into implementation roadmap with economic flow analysis

## Development Notes

When working with this documentation:
- All design documents define game mechanics and intended player experience
- No implementation code exists - these are specifications for future development
- Systems are designed to integrate through component-based Godot 4.5 architecture
- Quest progression (TIM-01 through TIM-06) demonstrates escalating complexity patterns
- Complete economic flow analysis available in `mvp_summary.md` with implementation priorities
- Shop system provides strategic creature acquisition with 6+ specialized vendors
- Competition system solves mid-game economic gaps while adding gameplay variety

## Key Design Principles

### Economic Balance
- **Starting Resources**: 500 gold + 2-3 starter creatures
- **Quest Profitability**: Net positive across TIM quest line (+4,690 gold total)
- **Income Sources**: Quest rewards (primary) + competitions (supplemental) + breeding (optional)
- **Resource Scarcity**: Mid-game funding gaps create strategic planning requirements

### Progressive Complexity
- **TIM-01/02**: Tutorial phase with simple single-creature challenges
- **TIM-03/04**: Multi-creature coordination requiring diverse specialists
- **TIM-05/06**: High-end challenges demanding premium creatures and intensive training
- **Vendor Unlocks**: New shop access tied to quest completion progress

### System Integration
- **Weekly Time Cycles**: All activities (training, competitions, breeding) consume time
- **Food Requirements**: Active creatures need weekly food affecting performance
- **Age Mechanics**: Creatures age through activities with performance modifiers
- **Validation Systems**: Automatic checking of creature qualifications against quest requirements