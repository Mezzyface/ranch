# Repository Structure Overview

## 📁 Complete Directory Layout

```
ranch/                              # Root directory
│
├── 📄 README.md                    # Main project documentation & navigation
├── 📄 CLAUDE.md                    # AI assistant guidance document
│
└── 📁 docs/                        # All documentation
    │
    ├── 📁 design/                  # Game Design Documents
    │   │
    │   ├── 📁 systems/             # Core System Designs
    │   │   ├── creature.md         # Creature data model
    │   │   ├── species.md          # Species templates
    │   │   ├── stats.md            # Stat system (STR, CON, DEX, INT, WIS, DIS)
    │   │   ├── tags.md             # Tag system for traits
    │   │   └── time.md             # Time & aging mechanics
    │   │
    │   ├── 📁 features/            # Feature Designs
    │   │   ├── quest.md            # Quest system mechanics
    │   │   ├── training.md         # Training system
    │   │   ├── food.md             # Food & feeding system
    │   │   ├── breeding.md         # Breeding mechanics
    │   │   ├── competitions.md     # Competition events
    │   │   └── shop.md             # Shop & vendors
    │   │
    │   └── 📁 content/             # Content & Story
    │       └── quest_design_doc.md # TIM quest line (TIM-01 to TIM-06)
    │
    ├── 📁 implementation/          # Technical Implementation
    │   │
    │   ├── 📄 implementation_plan.md  # 10-stage development roadmap
    │   ├── 📄 enum.md                  # Global enumeration definitions
    │   │
    │   └── 📁 stages/              # Development Stages
    │       │
    │       └── 📁 stage_1/         # Stage 1: Core Foundation (Current)
    │           ├── 00_stage_1_overview.md     # Stage guide & task order
    │           ├── 01_project_setup.md        # Godot project setup
    │           ├── 02_creature_class.md       # Creature data model
    │           ├── 03_stat_system.md          # Stat implementation
    │           ├── 04_tag_system.md           # Tag implementation
    │           ├── 05_creature_generation.md  # Generation system
    │           ├── 06_age_system.md           # Age mechanics
    │           ├── 07_save_load_system.md     # Persistence
    │           ├── 08_player_collection.md    # Collection management
    │           ├── 09_resource_tracking.md    # Resource system
    │           ├── 10_species_resources.md    # Species resources
    │           └── 11_global_enums.md         # Enum setup
    │
    └── 📁 project/                 # Project Management
        ├── game.md                 # Core gameplay overview
        └── mvp_summary.md          # MVP scope & economics

[Future: src/]                      # Godot project files (not yet created)
```

## 📊 Document Categories

### 🎨 Design Documents (16 files)
**Purpose**: Define what the game is and how it works
- **Systems** (5): Core mechanics and data models
- **Features** (6): Gameplay features and mechanics
- **Content** (1): Quest content and progression
- **Project** (2): Overall game vision and scope

### 🔧 Implementation Documents (14 files)
**Purpose**: Define how to build the game
- **Planning** (2): Roadmap and technical specifications
- **Stage 1** (12): Detailed implementation tasks

### 📚 Meta Documents (3 files)
- **README.md**: Project navigation and overview
- **CLAUDE.md**: AI assistant instructions
- **STRUCTURE.md**: This file - directory layout

## 🎯 Navigation Quick Links

### For New Developers
1. Start → [README.md](../README.md)
2. Overview → [game.md](project/game.md)
3. Implementation → [Stage 1 Overview](implementation/stages/stage_1/00_stage_1_overview.md)

### For Designers
1. Systems → [design/systems/](design/systems/)
2. Features → [design/features/](design/features/)
3. Content → [design/content/](design/content/)

### For Project Managers
1. MVP Scope → [mvp_summary.md](project/mvp_summary.md)
2. Timeline → [implementation_plan.md](implementation/implementation_plan.md)
3. Current Stage → [stage_1/](implementation/stages/stage_1/)

## 🔄 Document Flow

```
Project Vision (game.md)
    ↓
Design Documents (design/)
    ↓
Implementation Plan (implementation_plan.md)
    ↓
Stage Tasks (stages/stage_1/)
    ↓
Source Code (future: src/)
```

## 📝 File Naming Conventions

- **Design docs**: `system_name.md` (lowercase, underscore separated)
- **Implementation tasks**: `##_task_name.md` (numbered, descriptive)
- **Overview docs**: Descriptive names (e.g., `mvp_summary.md`)
- **Meta docs**: UPPERCASE.md for visibility

## ✅ Organization Benefits

1. **Clear Separation**: Design vs Implementation
2. **Easy Navigation**: Logical folder hierarchy
3. **Stage-based Development**: Implementation organized by stages
4. **Scalable Structure**: Easy to add new stages/features
5. **Documentation First**: All specs before code
6. **AI-Friendly**: Clear structure for automated tools

## 🚀 Next Steps

1. Agents can now easily find Stage 1 tasks in `docs/implementation/stages/stage_1/`
2. Begin with [01_project_setup.md](implementation/stages/stage_1/01_project_setup.md)
3. Follow task order in [00_stage_1_overview.md](implementation/stages/stage_1/00_stage_1_overview.md)
4. All design references are in `docs/design/`