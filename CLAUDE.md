# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a planning directory containing comprehensive game design documentation for a creature collection/breeding game. The primary focus is on a tutorial quest line called "A Gem of a Problem" that teaches players creature selection based on stats and tags.

## Document Architecture

### Project Overview (`docs/project/`)
- `game.md` - Core gameplay loop, acquisition systems, and Godot 4.5 architecture overview
- `mvp_summary.md` - Complete MVP design summary with economic analysis and implementation priorities

### Core System Documents (`docs/design/systems/`)
- `creature.md` - Creature system design including stats, tags, and behaviors
- `species.md` - Species resource system for creature types, stat ranges, and visual assets
- `stats.md` - Stat system design with 6 core stats (STR, CON, INT, WIS, DEX, DIS)
- `tags.md` - Tag system for creature traits and environmental requirements
- `time.md` - Time management system for creature activities and stamina

### Gameplay Feature Documents (`docs/design/features/`)
- `quest.md` - Quest system mechanics, progression, and quest generation algorithms
- `training.md` - Training system mechanics and weekly activity management
- `food.md` - Food system for creature care and training enhancement
- `breeding.md` - Breeding system with egg group compatibility and inheritance mechanics
- `shop.md` - Multi-vendor shop system with specialized creature eggs and foods
- `competitions.md` - Weekly competition system for alternative income and creature development

### Content Design (`docs/design/content/`)
- `quest_design_doc.md` - Specific "A Gem of a Problem" quest line (TIM-01 through TIM-06)

### Implementation Documents (`docs/implementation/`)
- `implementation_plan.md` - Multi-stage implementation roadmap with 10 development stages
- `enum.md` - Global enumeration definitions for type safety
- `stages/stage_1/` - Stage 1 implementation tasks (11 tasks total)

## Game Design Architecture

### Core Systems Integration
- **Creature Management**: Stats, tags, and validation systems work together
- **Quest System**: Dynamic requirement matching against creature collections (see docs/design/features/quest.md for full mechanics)
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

This repository contains comprehensive game design documentation with staged implementation plans. The project is in early development with Stage 1 tasks defined in the `stage_1/` directory.

### Key Document Relationships
- **Quest System**: `quest.md` defines mechanics, `quest_design_doc.md` provides specific tutorial quest line
- **Creature System**: `creature.md` for basic design, `stats.md` and `tags.md` for detailed specifications
- **Breeding System**: `breeding.md` covers egg group compatibility and inheritance algorithms
- **Economic Systems**: `shop.md` and `competitions.md` provide creature acquisition and income sources
- **Time Management**: `time.md` integrates with `training.md`, `food.md`, and `competitions.md` for weekly creature care
- **MVP Overview**: `mvp_summary.md` synthesizes all systems into implementation roadmap with economic flow analysis

## Implementation Status

### Current Stage: Stage 1 - Core Data Models & Foundation
The project is in early implementation following a 10-stage development plan:

1. **Stage 1**: Core Data Models & Foundation (2-3 weeks)
2. **Stage 2**: Time Management & Basic UI (2 weeks)
3. **Stage 3**: Shop System & Economy (2 weeks)
4. **Stage 4**: Training System (2 weeks)
5. **Stage 5**: Quest System - Tutorial Phase (2-3 weeks)
6. **Stage 6**: Competition System (2 weeks)
7. **Stage 7**: Advanced Quests (2-3 weeks)
8. **Stage 8**: Breeding System (2 weeks)
9. **Stage 9**: Polish & Additional Vendors (2 weeks)
10. **Stage 10**: Balancing & MVP Completion (1-2 weeks)

### Stage 1 Implementation Tasks
Implementation files in `stage_1/` directory:
- `01_project_setup.md` - Godot 4.5 project initialization and architecture
- `02_creature_class.md` - Core creature data model implementation
- `03_stat_system.md` - Six stat system (STR, CON, DEX, INT, WIS, DIS)
- `04_tag_system.md` - Tag system for creature traits
- `05_creature_generation.md` - Procedural creature instance creation
- `06_age_system.md` - Age categories with performance modifiers
- `07_save_load_system.md` - Game state persistence
- `08_player_collection.md` - Active/stable creature management
- `09_resource_tracking.md` - Gold and food inventory systems

## Development Notes

When working with this project:
- Follow the staged implementation plan in `implementation_plan.md`
- Each stage builds upon previous stages with clear dependencies
- Stage 1 tasks are defined in detail in the `stage_1/` directory
- No Godot project files exist yet - begin with `01_project_setup.md`
- Systems are designed for component-based Godot 4.5 architecture
- Complete economic flow analysis available in `mvp_summary.md`

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