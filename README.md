# Creature Collection Game - Design & Implementation

A comprehensive creature collection, breeding, and training game built with Godot 4.5.

## 📁 Repository Structure

```
ranch/
├── README.md                   # This file - project navigation
├── USAGE.md                    # 📖 Comprehensive API and usage guide
├── CLAUDE.md                   # AI assistant guidance
├── docs/                       # All documentation
│   ├── design/                 # Game design documents
│   │   ├── systems/           # Core system designs
│   │   ├── features/          # Feature designs
│   │   └── content/           # Content & quests
│   ├── implementation/        # Technical implementation
│   │   ├── stages/            # Development stages
│   │   └── enum.md            # Global enumerations
│   └── project/               # Project management
├── scripts/                    # Game source code (Godot 4.5)
│   ├── core/                  # GameCore, SignalBus
│   ├── systems/               # StatSystem, SaveSystem, etc.
│   ├── entities/              # CreatureEntity, etc.
│   ├── data/                  # CreatureData, QuestData
│   └── controllers/           # MainController, etc.
└── test_setup.gd              # Comprehensive test suite
```

## 🎮 Game Overview

A creature collection game where players:
- **Collect** diverse species of creatures with unique stats and abilities
- **Train** creatures to improve their capabilities
- **Breed** creatures to create powerful offspring
- **Complete** quests using the right creature combinations
- **Compete** in various challenges for rewards
- **Manage** resources and time strategically

## 📚 Documentation Guide

### 🎯 Start Here
- [Usage Guide](USAGE.md) - **📖 Complete API documentation and usage examples**
- [Project Overview](docs/project/game.md) - Core gameplay loop and architecture
- [MVP Summary](docs/project/mvp_summary.md) - Complete MVP design with economic analysis
- [Implementation Plan](docs/implementation/implementation_plan.md) - 10-stage development roadmap

### 🔧 Core Systems Design
- [Creature System](docs/design/systems/creature.md) - Creature data model and behaviors
- [Species System](docs/design/systems/species.md) - Species templates and variations
- [Stats System](docs/design/systems/stats.md) - Six core stats (STR, CON, DEX, INT, WIS, DIS)
- [Tags System](docs/design/systems/tags.md) - Creature traits and capabilities
- [Time System](docs/design/systems/time.md) - Weekly progression and aging

### 🎪 Feature Design
- [Quest System](docs/design/features/quest.md) - Quest mechanics and validation
- [Training System](docs/design/features/training.md) - Stat improvement mechanics
- [Food System](docs/design/features/food.md) - Creature care and bonuses
- [Breeding System](docs/design/features/breeding.md) - Genetic inheritance
- [Competition System](docs/design/features/competitions.md) - Alternative income events
- [Shop System](docs/design/features/shop.md) - Creature and item acquisition

### 📖 Content Design
- [Quest Design: A Gem of a Problem](docs/design/content/quest_design_doc.md) - TIM-01 through TIM-06 tutorial quests

### 💻 Implementation

#### Stage 1: Core Foundation (Current Stage)
- [Stage 1 Overview](docs/implementation/stages/stage_1/00_stage_1_overview.md) - Complete implementation guide
- [Global Enums](docs/implementation/enum.md) - Type-safe enumerations

**Stage 1 Tasks (In Order):**
1. ✅ [Project Setup & SignalBus](docs/implementation/stages/stage_1/01_project_setup.md) - GameCore + enhanced SignalBus
2. ✅ [Creature Class](docs/implementation/stages/stage_1/02_creature_class.md) - CreatureData + CreatureEntity
3. ✅ [Stat System](docs/implementation/stages/stage_1/03_stat_system.md) - Advanced modifiers and age mechanics
4. ✅ [Tag System](docs/implementation/stages/stage_1/04_tag_system.md) - Comprehensive validation and quest integration
5. ✅ [Creature Generation](docs/implementation/stages/stage_1/05_creature_generation.md) - 4 species with performance optimization
6. ✅ [Age System](docs/implementation/stages/stage_1/06_age_system.md) - Lifecycle progression and time-based mechanics
7. ✅ [Save/Load System](docs/implementation/stages/stage_1/07_save_load_system.md) - Hybrid persistence with comprehensive validation
8. [Player Collection](docs/implementation/stages/stage_1/08_player_collection.md) - 🚀 NEXT
9. [Resource Tracking](docs/implementation/stages/stage_1/09_resource_tracking.md)
10. [Species Resources](docs/implementation/stages/stage_1/10_species_resources.md)
11. [Global Enums](docs/implementation/stages/stage_1/11_global_enums.md)

## 🏗️ Current Implementation Status

### ✅ Architecture Foundation Complete (Tasks 1-7)

The core game architecture is fully implemented and tested:

- **GameCore Management**: Single autoload with lazy-loaded subsystems
- **MVC Pattern**: Resources for data, Nodes for behavior
- **SignalBus Communication**: Centralized, validated signal routing
- **Data Persistence**: Hybrid save system (ConfigFile + ResourceSaver)
- **Performance Standards**: All systems meeting <100ms targets

### 🧪 Comprehensive Testing Suite

Run the complete test suite with:
```bash
# Console testing (recommended for CI/CD)
"C:\Program Files\Godot\Godot_console.exe" --headless --scene test_console_scene.tscn

# Full testing (comprehensive validation)
"C:\Program Files\Godot\Godot.exe" --headless --scene test_setup.tscn
```

**Test Coverage**: 100% pass rate across all implemented systems
- System integration testing
- Performance benchmarking
- Signal validation
- Save/load verification
- Error handling validation

### 🔧 Current API Usage

**GameCore System Access**:
```gdscript
# Lazy-loaded subsystems
var stat_system: StatSystem = GameCore.get_system("stat")
var age_system: AgeSystem = GameCore.get_system("age")
var save_system: SaveSystem = GameCore.get_system("save")

# SignalBus communication
var signal_bus: SignalBus = GameCore.get_signal_bus()
signal_bus.creature_created.emit(creature_data)
```

**Creature Management**:
```gdscript
# Generate creatures with 4 species and 4 algorithms
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
var premium: CreatureData = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.HIGH_ROLL)

# Age progression (5 categories: Baby→Juvenile→Adult→Elder→Ancient)
age_system.age_creature_by_weeks(creature, 26)  # Age by half year
age_system.age_creature_to_category(creature, 2)  # Age to Adult

# Save/load with comprehensive validation
save_system.save_game_state("my_save")
save_system.load_game_state("my_save")
```

**Tag System (25 tags across 5 categories)**:
```gdscript
var tag_system: TagSystem = GameCore.get_system("tag")

# Validate creature for quest requirements
if tag_system.creature_meets_requirements(creature, ["Dark Vision", "Stealthy"]):
    print("Creature qualified for stealth mission")

# Filter creature collections efficiently
var qualified: Array[CreatureData] = tag_system.filter_creatures_by_tags(all_creatures, ["Natural Armor"])
```

## 🚀 Getting Started

### For Developers

1. **Review Documentation**
   - Start with [Usage Guide](USAGE.md) for API documentation
   - Review [Project Overview](docs/project/game.md) for game design
   - Read [Stage 1 Overview](docs/implementation/stages/stage_1/00_stage_1_overview.md) for implementation details

2. **Set Up Development Environment**
   - Install Godot 4.5
   - Clone this repository
   - Follow [Project Setup](docs/implementation/stages/stage_1/01_project_setup.md)

3. **Run Tests & Explore**
   - Test current systems: `"C:\Program Files\Godot\Godot_console.exe" --headless --scene test_console_scene.tscn`
   - Explore API usage patterns in [Usage Guide](USAGE.md)
   - All Stage 1 systems are fully functional and documented

4. **Begin Implementation (Task 8+)**
   - Continue with remaining Stage 1 tasks
   - Each task has clear requirements and comprehensive testing
   - 64% of Stage 1 foundation complete

### For Designers

1. **Understanding the Game**
   - Review [MVP Summary](docs/project/mvp_summary.md) for complete game overview
   - Explore system designs in `docs/design/systems/`
   - Check feature designs in `docs/design/features/`

2. **Quest Content**
   - See [Quest Design Doc](docs/design/content/quest_design_doc.md) for tutorial progression
   - Review [Quest System](docs/design/features/quest.md) for mechanics

## 📊 Development Progress

### Current Status: Stage 1 - Core Foundation
- [x] Documentation complete
- [x] Design specifications finalized
- [x] Implementation tasks defined
- [x] Godot project created
- [x] Task 1: Project Setup & SignalBus (GameCore + enhanced SignalBus)
- [x] Task 2: Creature Class (CreatureData/CreatureEntity separation)
- [x] Task 3: Stat System (Advanced modifiers and age mechanics)
- [x] Task 4: Tag System (Comprehensive validation and quest integration)
- [x] Task 5: Creature Generation (4 species, 4 algorithms, performance optimization)
- [x] Task 6: Age System (Lifecycle progression and time-based mechanics)
- [x] Task 7: Save/Load System (Hybrid persistence, auto-save, comprehensive validation)
- [ ] Task 8: Player Collection (Active/stable creature roster management)
- [ ] Task 9-11: Resource Tracking, Species Resources, Global Enums
- [ ] Stage 1 testing complete

**Progress: 7/11 Stage 1 tasks complete (~64%)**

### Upcoming Stages
- **Stage 2**: Time Management & Basic UI (2 weeks)
- **Stage 3**: Shop System & Economy (2 weeks)
- **Stage 4**: Training System (2 weeks)
- **Stage 5**: Quest System - Tutorial Phase (2-3 weeks)
- **Stage 6**: Competition System (2 weeks)
- **Stage 7**: Advanced Quests (2-3 weeks)
- **Stage 8**: Breeding System (2 weeks)
- **Stage 9**: Polish & Additional Vendors (2 weeks)
- **Stage 10**: Balancing & MVP Completion (1-2 weeks)

**Total Timeline**: 19-24 weeks (4.5-6 months)

## 🎯 Key Design Principles

### Economic Balance
- **Starting Resources**: 500 gold + 2-3 starter creatures
- **Quest Profitability**: Net positive across tutorial (+4,690 gold total)
- **Income Sources**: Quests (primary) + Competitions (supplemental)

### Progressive Complexity
- **TIM-01/02**: Simple single-creature challenges
- **TIM-03/04**: Multi-creature coordination
- **TIM-05/06**: High-end challenges requiring premium creatures

### System Integration
- **Weekly Time Cycles**: All activities consume time
- **Food Requirements**: Active creatures need weekly food
- **Age Mechanics**: Creatures age affecting performance
- **Validation Systems**: Automatic requirement checking

## 🛠️ Technology Stack

- **Engine**: Godot 4.5
- **Language**: GDScript
- **Architecture**: Component-based, Resource-driven
- **Version Control**: Git

## 📝 Contributing

This project follows a staged development approach. When contributing:

1. Follow the implementation plan stages
2. Ensure all tests pass
3. Document any deviations from design
4. Use the global enum system for type safety
5. Keep code modular and testable

## 📄 License

[License details to be added]

## 🤝 Contact

[Contact information to be added]

---

*For AI assistants working on this project, see [CLAUDE.md](CLAUDE.md) for specific guidance.*