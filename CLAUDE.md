# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a planning directory containing comprehensive game design documentation for a creature collection/breeding game. The primary focus is on a tutorial quest line called "A Gem of a Problem" that teaches players creature selection based on stats and tags.

## Document Architecture

### Design Documents (`.md` files)
- `game.md` - Core gameplay loop, acquisition systems, and Godot 4.5 architecture overview
- `quest.md` - Quest system mechanics, progression, and quest generation algorithms
- `quest_design_doc.md` - Specific quest line with 6 progressive quests (TIM-01 through TIM-06)
- `creature.md` - Creature system design including stats, tags, and behaviors
- `stats.md` - Stat system design with 6 core stats (STR, CON, INT, WIS, DEX, DIS)
- `tags.md` - Tag system for creature traits and environmental requirements
- `training.md` - Training system mechanics and weekly activity management
- `food.md` - Food system for creature care and training enhancement
- `time.md` - Time management system for creature activities and stamina

### Additional Design Documents
- `breeding.md` - Breeding system with egg group compatibility and inheritance mechanics
- No implementation documents (`*_implementation.md` files) exist yet

## Game Design Architecture

### Core Systems Integration
- **Creature Management**: Stats, tags, and validation systems work together
- **Quest System**: Dynamic requirement matching against creature collections (see quest.md for full mechanics)
- **Training System**: Weekly time management with food and stamina mechanics
- **Breeding System**: Egg group compatibility and genetic inheritance of stats and tags
- **Time Management**: Active vs. stable creature states with weekly planning
- **Food System**: Creature care and training enhancement through feeding

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
- **Time Management**: `time.md` integrates with `training.md` and `food.md` for weekly creature care

## Development Notes

When working with this documentation:
- All design documents define game mechanics and intended player experience
- No implementation code exists - these are specifications for future development
- Systems are designed to integrate through component-based Godot 4.5 architecture
- Quest progression (TIM-01 through TIM-06) demonstrates escalating complexity patterns
- Breeding system uses egg groups to control creature compatibility and genetic inheritance