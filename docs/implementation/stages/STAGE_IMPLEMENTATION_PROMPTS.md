# Stage Implementation Task Prompts

This document provides comprehensive, standalone task prompts for implementing Stages 3-10 of the creature collection game. Each prompt includes all necessary context and can be executed independently.

---

## Stage 3: Shop System & Economy (2 weeks)

### Task 3.1: Core Shop System
```
Implement the core shop system from scratch following docs/design/features/shop.md. Create scripts/systems/shop_system.gd as a GameCore subsystem that manages all vendors and transactions. The system must support:
- 6 specialized vendors (Armored Ace, Sky Sailor, Shadow Market, Savage Supplies, Mystical Menagerie, Starter Stable)
- Dynamic inventory management with stock rotation
- Price calculations with modifiers and discounts
- Transaction validation and gold spending via ResourceTracker
- Signals: item_purchased, shop_refreshed, vendor_unlocked via SignalBus
- Save/load integration for shop states and inventories
Test with: godot --headless --scene tests/systems/test_shop.tscn
Performance target: Handle 100 items across all vendors in <50ms
```

### Task 3.2: Vendor Data Resources
```
Create vendor resource definitions in data/vendors/ folder. Each vendor needs:
- VendorResource class extending Resource with: id, name, description, unlock_requirements, base_inventory
- 6 vendor .tres files: armored_ace.tres, sky_sailor.tres, shadow_market.tres, savage_supplies.tres, mystical_menagerie.tres, starter_stable.tres
- Each vendor specializes in specific creature types and tags (reference quest_design_doc.md for requirements)
- Inventory includes: creature eggs (guaranteed stat ranges), basic foods, training items
- Progressive unlock conditions tied to quest completion (TIM-02 unlocks cave vendors, etc.)
Ensure resources are @tool compatible and include validation methods.
```

### Task 3.3: Shop Item System
```
Create ShopItem resource class in scripts/resources/shop_item_resource.gd for all purchasable items:
- Item types: CREATURE_EGG, FOOD, TRAINING_ITEM, SPECIAL
- Properties: id, name, description, base_price, stock_quantity, restock_rate, requirements
- Creature eggs must define: species_id, guaranteed_stat_ranges, guaranteed_tags
- Foods must define: effect_type, stamina_restoration, stat_bonuses
- Implement price_with_modifiers(reputation, discounts) method
- Create 20+ initial items covering all TIM quest requirements
Test item generation and validation with dedicated test scene.
```

### Task 3.4: Shop UI Interface
```
Create scenes/ui/panels/shop_panel.tscn with full shopping interface:
- Vendor selection sidebar showing 6 vendors (locked/unlocked states)
- Item grid display with filtering by type/price/availability
- Item detail panel showing stats, requirements, and effects
- Purchase confirmation dialog with affordability check
- Transaction feedback animations and notifications
- Connect to ShopSystem for real-time inventory updates
- Integrate with ResourceTracker to display current gold
Maintain 60 FPS with 50+ items displayed.
```

### Task 3.5: Economy Balancing
```
Implement economic balancing system in ShopSystem:
- Base prices from MVP design: Scuttleguard (200g), Glow Grub (400g), Wind Dancer (500g), etc.
- Dynamic pricing based on: player level, reputation, market conditions
- Restock mechanics: weekly refresh with random variance
- Bulk purchase discounts (10% for 3+, 20% for 5+)
- Special deals system for featured items
- Integration with TimeSystem for weekly market updates
Create economy_config.tres with all tunable values for easy balancing.
```

### Task 3.6: Shop Integration Testing
```
Create comprehensive shop system tests in tests/systems/test_shop_integration.tscn:
- Test all 6 vendors load with correct inventories
- Verify purchase transactions deduct gold correctly
- Test stock depletion and restock mechanics
- Validate creature eggs produce correct stat ranges
- Test save/load preserves shop states
- Verify unlock progression works with quest completion
- Performance test: 1000 transactions in <2 seconds
- Economic balance test: Can complete TIM-01 through TIM-03 with shop purchases
```

---

## Stage 4: Training System (2 weeks)

### Task 4.1: Core Training System
```
Implement TrainingSystem in scripts/systems/training_system.gd as GameCore subsystem:
- Training activities: Physical (STR/CON), Agility (DEX), Mental (INT/WIS), Discipline (DIS)
- Each training takes 1 week and ages creature +1 week
- Base gains: 5-15 points per stat per week (affected by age modifiers)
- Food bonuses: Training foods provide +50% effectiveness
- Stamina cost: 10 stamina per training session
- Facility tiers: Basic (1.0x), Advanced (1.5x), Elite (2.0x) multipliers
- Signals: training_started, training_completed, facility_upgraded
- Integration: TimeSystem for weekly progression, StaminaSystem for costs
Performance: Process 100 creature trainings in <100ms
```

### Task 4.2: Training Facilities
```
Create training facility management in TrainingSystem:
- Facility types: Training Grounds, Agility Course, Library, Meditation Chamber
- Each facility has 3 tiers with upgrade costs: Basic (free), Advanced (1000g), Elite (5000g)
- Facilities affect specific stats: Grounds (STR/CON), Course (DEX), Library (INT), Chamber (WIS/DIS)
- Capacity limits: Basic (3), Advanced (6), Elite (10) simultaneous trainees
- Maintenance costs: Advanced (50g/week), Elite (200g/week)
- Create FacilityResource class with upgrade paths and requirements
- Save/load facility states and upgrade progress
```

### Task 4.3: Training Schedule Manager
```
Implement training scheduling in scripts/systems/training_scheduler.gd:
- Queue system for multi-week training programs
- Auto-assignment based on stat priorities
- Conflict resolution (can't train and compete same week)
- Batch training for multiple creatures
- Training groups with shared bonuses (+10% for 3+ creatures training together)
- Interrupt handling for emergencies (quest requirements, etc.)
- Schedule optimization algorithm to maximize gains
- Weekly report generation showing progress
```

### Task 4.4: Training UI Panel
```
Create scenes/ui/panels/training_panel.tscn for training management:
- Facility overview showing all 4 facilities and upgrade status
- Creature assignment interface with drag-and-drop
- Training schedule calendar view
- Progress bars for active training sessions
- Stat gain preview calculator
- Food bonus selector integration
- Results summary dialog after training completion
- Quick-train templates for common builds
Connect to TrainingSystem and update in real-time.
```

### Task 4.5: Training Foods Integration
```
Extend FoodSystem to support training enhancement:
- Training food types: Power Bars (+STR/CON), Speed Snacks (+DEX), Brain Food (+INT/WIS), Focus Tea (+DIS)
- Base cost: 25g per training food item
- Effects: +50% training effectiveness for targeted stats
- Bulk recipes: Combine basic foods into training foods
- Spoilage: Training foods last 4 weeks
- Auto-consume option for scheduled training
- Integration with ShopSystem for purchasing
- UI indicators in training panel for food effects
```

### Task 4.6: Training System Testing
```
Create tests/systems/test_training.tscn for comprehensive validation:
- Test stat gains match expected ranges (5-15 base + modifiers)
- Verify age affects training effectiveness correctly
- Test facility upgrades apply proper multipliers
- Validate food bonuses calculate correctly
- Test multi-week training schedules execute properly
- Verify stamina depletion and blocking when exhausted
- Performance test: 52-week training program for 20 creatures
- Balance test: Can reach 200+ stats for TIM-05 requirements via training
```

---

## Stage 5: Quest System - Tutorial Phase (2-3 weeks)

### Task 5.1: Quest System Core
```
Enhance QuestSystem in scripts/systems/quest_system.gd to full functionality:
- Quest states: LOCKED, AVAILABLE, ACTIVE, READY_TO_COMPLETE, COMPLETED
- Requirement types: CreatureStats, CreatureTags, ItemOwnership, QuestCompletion
- Multi-part quest support (like TIM-03 with 3 parts)
- Quest chains with prerequisites
- Validation engine for complex requirements
- Reward distribution system (gold, XP, items, unlocks)
- Quest journal with 10 active quest limit
- Signals: quest_available, quest_accepted, quest_completed, quest_failed
- Save/load quest states and progress
Performance: Validate 100 creatures against requirements in <50ms
```

### Task 5.2: Tim NPC Implementation
```
Create scripts/npcs/tim_npc.gd for the main quest giver:
- Dialogue system with branching conversations
- Quest offering based on completion state
- Personality: Gem-obsessed, paranoid, escalating demands
- Location progression: Study → Cave → Deep Cave
- Special dialogue for over-qualified creatures
- Hint system for struggling players
- Voice bark system ("My gems!", "Perfect!", "Not quite right...")
- Animation states: idle, excited, disappointed, thinking
Create scenes/npcs/tim.tscn with full NPC setup.
```

### Task 5.3: Quest Data Resources (TIM-01 to TIM-06)
```
Create comprehensive quest resources in data/quests/tim/:
- TIM-01 Study Guard: [Small]+[Territorial], DIS>80, WIS>70 → 300g
- TIM-02 Going Underground: [Dark Vision], CON>120, STR>110 → 400g
- TIM-03 Cave Ecology: 3 parts with specific creature requirements → 1500g
- TIM-04 Subterranean Shipping: 2x [Sure-Footed] creatures → 1800g
- TIM-05 Living Lock: [Camouflage], CON>200, DIS>180 → 2500g + Sapphire
- TIM-06 Dungeon Master: 5 creatures with varied requirements → 7500g + unlocks
Include dialogue snippets, requirement validation rules, and reward distributions.
Each quest must reference quest_design_doc.md for exact requirements.
```

### Task 5.4: Quest UI System
```
Create scenes/ui/panels/quest_panel.tscn for quest management:
- Quest journal with categorized tabs (Active, Available, Completed)
- Detailed quest view with requirements checklist
- Progress indicators for multi-part quests
- Creature eligibility checker highlighting valid creatures
- Submit creature interface with preview
- Reward preview panel
- Quest tracking HUD overlay (optional toggle)
- Tim dialogue window with typewriter effect
- Quest completion celebration animation
Maintain 60 FPS with complex requirement checking.
```

### Task 5.5: Creature Submission System
```
Implement creature submission in scripts/systems/quest_submission.gd:
- Analyze player collection for eligible creatures
- Requirement matching algorithm with partial credit
- Multi-criteria scoring for best-fit suggestions
- Submission preview with success probability
- Permanent creature transfer on quest completion
- Rollback system for failed submissions
- Batch submission for multi-creature quests
- Integration with PlayerCollection for roster updates
Test with all TIM quest combinations and edge cases.
```

### Task 5.6: Quest Tutorial Flow
```
Implement tutorial progression in scripts/systems/tutorial_manager.gd:
- Guided introduction to quest mechanics via TIM-01
- Tooltips and hints for first-time actions
- Progressive complexity from single to multi-creature quests
- Shop tutorial when player lacks required creatures
- Training hints when stats are too low
- Competition suggestion for gold shortage
- Skip option for experienced players
- Achievement tracking for tutorial completion
Ensure new players can complete TIM-01 to TIM-03 without confusion.
```

---

## Stage 6: Competition System (2 weeks)

### Task 6.1: Competition System Core
```
Create CompetitionSystem in scripts/systems/competition_system.gd:
- 10 competition types: Strength Contest, Endurance Run, Agility Trial, Intelligence Quiz, Wisdom Challenge, Discipline Test, All-Around, Specialized, Team, Elite
- Auto-resolution based on creature stats vs AI opponents
- Difficulty tiers: Beginner (50-150 stats), Intermediate (150-300), Advanced (300-500), Elite (500+)
- Entry fees: 10g (Beginner) to 100g (Elite)
- Prize pools: 50-400g based on placement (1st/2nd/3rd)
- Weekly scheduling with 3-5 available competitions
- Stamina cost: 25 per competition
- Signals: competition_entered, competition_completed, tier_unlocked
Performance: Simulate 100 competitions in <200ms
```

### Task 6.2: Competition Types & Rules
```
Define competition rules in data/competitions/:
- Each competition has primary stat (60% weight) and secondary stats (40%)
- Weather/environment modifiers affect certain competitions
- Tag bonuses: [Athletic] +10% in physical, [Intelligent] +10% in mental
- Team competitions require 3 creatures, use average stats
- Special competitions with unique rules (e.g., "Tiny Titan" for [Small] only)
- Seasonal championships with grand prizes
- Create CompetitionResource class with all parameters
- Generate 30+ competition variations for variety
Balance to ensure 60-70% win rate with appropriate creatures.
```

### Task 6.3: AI Opponent System
```
Implement AI opponents in scripts/systems/competition_opponents.gd:
- Generate themed opponents based on competition type
- Stat ranges appropriate to tier with ±20% variance
- Named opponents with basic personalities
- Recurring rivals that grow stronger over time
- Special legendary opponents with unique rewards
- Team synergies for group competitions
- Adaptive difficulty based on player win rate
- Pool of 100+ opponent templates
Ensure AI provides appropriate challenge without being unfair.
```

### Task 6.4: Competition UI Interface
```
Create scenes/ui/panels/competition_panel.tscn:
- Weekly competition board showing available events
- Entry form with creature selection
- Stat comparison vs estimated opponents
- Competition simulation viewer with results
- Leaderboard showing top performers
- Prize collection interface
- Competition history and statistics
- Creature performance analytics
- Quick-enter for favorite competitions
Update weekly with TimeSystem integration.
```

### Task 6.5: Competition Rewards System
```
Implement reward distribution in CompetitionSystem:
- Gold prizes: 50g (3rd), 150g (2nd), 300g (1st)
- Bonus rewards: Items, food, training vouchers
- Reputation system affecting future competitions
- Championship trophies for display
- Unlock tokens for special shops/items
- Experience points for creature development
- Special titles for consistent winners
- Integration with ResourceTracker and inventory
Track lifetime earnings and competition statistics.
```

### Task 6.6: Competition Integration Testing
```
Create tests/systems/test_competitions.tscn:
- Test all 10 competition types with various creatures
- Verify stat calculations and modifiers apply correctly
- Test AI opponent generation and difficulty scaling
- Validate prize distribution and economic balance
- Test stamina consumption and blocking
- Verify weekly rotation and scheduling
- Performance test: 52 weeks of competitions
- Economic test: Can fund TIM quests via competition income
- Win rate analysis: 60-70% with appropriate creatures
```

---

## Stage 7: Advanced Quests (2-3 weeks)

### Task 7.1: Advanced Quest Mechanics
```
Extend QuestSystem with advanced features:
- Branching quest paths with player choices
- Time-limited quests (complete within X weeks)
- Repeatable daily/weekly quests for steady income
- Hidden quests with discovery mechanics
- Faction reputation affecting quest availability
- Quest modifiers (bonus objectives, hard mode)
- Failed quest consequences and retry mechanics
- Quest items and special resources
- Dynamic quest generation based on player progress
Support 50+ active quests without performance impact.
```

### Task 7.2: Additional NPCs
```
Create 5 additional quest givers in scripts/npcs/:
- Marina (Sky Sailor vendor): Aerial creature quests
- Brutus (Savage Supplies): Combat and strength challenges
- Whisper (Shadow Market): Stealth and intelligence missions
- Sage Elm (Mystical Menagerie): Magic and wisdom quests
- Groundskeeper (Starter Stable): Tutorial and basic quests
Each NPC has unique personality, dialogue style, and quest types.
Create scenes/npcs/ with scene files for each NPC.
Include relationship system affecting quest rewards.
```

### Task 7.3: Procedural Quest Generation
```
Implement quest generator in scripts/systems/quest_generator.gd:
- Template-based generation with variable parameters
- Difficulty scaling based on player collection
- Contextual quests based on recent events
- Fetch quests: Acquire X creatures with Y properties
- Challenge quests: Win X competitions with restrictions
- Breeding quests: Produce creatures with specific traits
- Collection quests: Own X creatures of Y type simultaneously
- Reward scaling algorithm based on difficulty
Generate 10 meaningful quests weekly with no repetition.
```

### Task 7.4: Quest Chain System
```
Implement quest chains in scripts/systems/quest_chains.gd:
- Multi-stage narratives with persistent state
- Branching storylines based on choices
- Cumulative rewards for chain completion
- Special unlocks for finishing entire chains
- 5 major chains: Tim's Dungeon, Marina's Delivery Service, Brutus's Arena, Whisper's Network, Sage's Research
- Each chain has 6-10 quests with escalating difficulty
- Chain-specific creatures and items as rewards
- Save/load chain progress and decisions
Support parallel chain progression.
```

### Task 7.5: Quest Events System
```
Create special events in scripts/systems/quest_events.gd:
- Seasonal events with themed quests
- Limited-time challenges with exclusive rewards
- Community goals with collective progress
- Boss quests requiring multiple creatures
- Rescue missions with permanent consequences
- Discovery quests unlocking new areas
- Tournament arcs with elimination rounds
- Story events advancing world narrative
Schedule 2-3 special events per in-game year.
```

### Task 7.6: Advanced Quest Testing
```
Create tests/systems/test_advanced_quests.tscn:
- Test branching paths and choice consequences
- Verify procedural generation creates valid quests
- Test quest chain progression and state management
- Validate time-limited quest mechanics
- Test NPC relationship effects on rewards
- Verify special events trigger correctly
- Performance test: 50 active quests with updates
- Narrative test: All quest chains completable
- Economic test: Advanced quests provide viable income
```

---

## Stage 8: Breeding System (2 weeks)

### Task 8.1: Core Breeding System
```
Implement BreedingSystem in scripts/systems/breeding_system.gd:
- Genetic inheritance: Stats = parent average ± 20% variance
- Tag inheritance: 70% chance for each parent tag, 5% mutation
- Egg groups: 8 categories determining compatibility
- Breeding cooldown: 4 weeks per creature
- Gender system: Male/Female/Hermaphrodite based on species
- Fertility rates: Affected by age (Adult/Elder optimal)
- Multiple offspring: 1-3 eggs based on species
- Stamina cost: 30 per breeding
- Signals: breeding_started, egg_produced, egg_hatched
Performance: Calculate 1000 breeding combinations in <100ms
```

### Task 8.2: Genetics Engine
```
Create genetics system in scripts/systems/genetics.gd:
- Dominant/recessive traits for tags
- Stat inheritance with weighted distribution
- Mutation system: 5% chance for new tags
- Hybrid vigor: Crossbreeding bonuses
- Inbreeding penalties for close relatives
- Pedigree tracking (3 generations)
- Hidden genes affecting rare traits
- Shiny system: 1/500 chance for special variant
- Create GeneticProfile resource for creature data
Support complex multi-generation breeding programs.
```

### Task 8.3: Egg Management System
```
Implement egg handling in scripts/systems/egg_manager.gd:
- Egg states: Unhatched, Incubating, Ready, Hatched
- Incubation time: 2-4 weeks based on species
- Temperature requirements for optimal development
- Egg care activities affecting outcome
- Early hatching with reduced stats
- Egg storage system with capacity limits
- Egg trading/selling mechanics
- Special incubators with bonuses
- Integration with TimeSystem for progression
Handle 100+ eggs simultaneously.
```

### Task 8.4: Breeding UI Interface
```
Create scenes/ui/panels/breeding_panel.tscn:
- Compatibility checker for breeding pairs
- Genetic preview showing possible outcomes
- Pedigree viewer with family trees
- Breeding schedule manager
- Egg nursery with incubation status
- Hatching ceremony animation
- Breeding statistics and records
- Eugenics planner for optimal pairings
- Quick-breed for proven combinations
Real-time genetic calculations at 60 FPS.
```

### Task 8.5: Breeding Facilities
```
Add breeding facilities to the game:
- Basic Nursery: 5 egg capacity, normal rates
- Advanced Hatchery: 20 eggs, -25% incubation time
- Elite Breeding Center: 50 eggs, mutation rate +2%
- Facility upgrades: 500g, 2000g, 10000g
- Special equipment: Incubators, genetic analyzers
- Staff hiring for automation
- Research unlocks for advanced techniques
- Integration with existing facility system
Create BreedingFacilityResource for configurations.
```

### Task 8.6: Breeding System Testing
```
Create tests/systems/test_breeding.tscn:
- Test genetic inheritance calculations
- Verify tag inheritance and mutations
- Test egg group compatibility rules
- Validate incubation timing and progression
- Test facility bonuses and upgrades
- Verify pedigree tracking accuracy
- Performance test: 1000 breeding operations
- Genetic diversity test over 10 generations
- Economic test: Breeding as income source
- Edge cases: Inbreeding, rare mutations, shinies
```

---

## Stage 9: Polish & Additional Vendors (2 weeks)

### Task 9.1: Audio System
```
Implement AudioManager in scripts/systems/audio_manager.gd:
- Background music system with smooth transitions
- Sound effect pooling for efficiency
- Volume controls: Master, Music, SFX, UI
- Spatial audio for creature sounds
- Dynamic music based on game state
- Audio zones for different areas
- Creature voice system with species-specific sounds
- UI feedback sounds for all interactions
- Ambient soundscapes for shops/areas
- Audio settings persistence
Target: 64 simultaneous sounds without crackling
```

### Task 9.2: Visual Effects System
```
Create VFXManager in scripts/systems/vfx_manager.gd:
- Particle system pooling for performance
- Status effect visualizers
- Stat change indicators (+10 STR, etc.)
- Weather effects for atmosphere
- UI particle effects for feedback
- Creature aura/glow effects
- Transition effects between scenes
- Celebration effects for achievements
- Combat/competition visualization
- Optimized for 60 FPS with 50+ effects
Create reusable effect templates in scenes/vfx/
```

### Task 9.3: Achievement System
```
Implement AchievementSystem in scripts/systems/achievement_system.gd:
- 50+ achievements across all categories
- Progressive achievements with tiers
- Hidden achievements for discovery
- Statistics tracking for everything
- Reward unlocks: Titles, items, creatures
- Achievement notification queue
- Progress bars for long-term goals
- Steam/platform integration ready
- Export statistics to file
- Create achievement_definitions.tres
Display in scenes/ui/panels/achievement_panel.tscn
```

### Task 9.4: Tutorial Enhancement
```
Improve tutorial system in scripts/systems/tutorial_enhancement.gd:
- Interactive tutorials for each system
- Context-sensitive help system
- Video tutorials for complex features
- Practice mode for competitions
- Sandbox mode for experimentation
- Tip system with 100+ hints
- New player onboarding flow
- Glossary of game terms
- Interactive creature encyclopedia
- Tutorial skip for experienced players
Ensure 90% of players complete tutorial successfully.
```

### Task 9.5: Exotic Vendors
```
Add 4 exotic vendors with unique mechanics:
- Traveling Merchant: Random rare items, appears weekly
- Black Market: Illegal/powerful items, reputation risk
- Collector's Exchange: Trade creatures for special currency
- Seasonal Vendor: Holiday/event specific items
Each vendor needs:
- Unique inventory system
- Special currency or trade mechanics
- Unlock conditions
- Risk/reward mechanics
- Integration with reputation system
Create vendor resources in data/vendors/exotic/
```

### Task 9.6: Polish Testing Suite
```
Create comprehensive polish tests in tests/polish/:
- Audio system stress test
- VFX performance benchmarks
- Achievement unlock verification
- Tutorial completion metrics
- Exotic vendor economics
- UI responsiveness at scale
- Memory leak detection
- Save file size optimization
- Loading time benchmarks
- Full game loop test (startup to 52 weeks)
Target: Stable 60 FPS, <3s load times, <10MB saves
```

---

## Stage 10: Balancing & MVP Completion (1-2 weeks)

### Task 10.1: Economic Balancing
```
Implement economic balancer in scripts/systems/economy_balancer.gd:
- Dynamic price adjustment based on player wealth
- Inflation system for long-term play
- Money sinks to prevent hoarding
- Income/expense tracking and analysis
- Automated testing of economic viability
- Difficulty modes: Easy (+25% income), Normal, Hard (-25% income)
- Economic report generation
- Rebalancing tools for designers
- Export/import balance configurations
Test: Players can complete all content without grinding or exploits
```

### Task 10.2: Stat Balancing System
```
Create stat balancer in scripts/systems/stat_balancer.gd:
- Automated stat curve validation
- Power creep detection and prevention
- Creature tier analysis
- Training rate optimization
- Competition difficulty tuning
- Quest requirement validation
- Statistical analysis tools
- Monte Carlo simulations for outcomes
- Balance preset system
- A/B testing framework
Ensure no dominant strategies emerge.
```

### Task 10.3: Playtesting Framework
```
Build playtesting tools in scripts/debug/playtest_tools.gd:
- Automated playthrough bots
- Telemetry data collection
- Heatmap generation for UI usage
- Funnel analysis for quest progression
- Session recording and playback
- Bug reporting integration
- Feedback collection system
- Analytics dashboard export
- Performance profiling tools
- Cheat console for testing
Generate actionable reports for improvements.
```

### Task 10.4: Save System Enhancement
```
Enhance save system for release in scripts/systems/save_enhancement.gd:
- Save file compression (target <5MB)
- Cloud save support preparation
- Multiple save slots (3+)
- Auto-save configuration options
- Save file validation and repair
- Import/export functionality
- Save file versioning for updates
- Backup system with rotation
- Quick save/load hotkeys
- Save statistics and metadata
Ensure 100% save compatibility across versions.
```

### Task 10.5: Accessibility Features
```
Implement accessibility in scripts/systems/accessibility.gd:
- Colorblind modes (3 types)
- Font size scaling (50%-200%)
- High contrast mode
- Screen reader support
- Reduced motion options
- Subtitle system for audio
- Control remapping
- One-handed play mode
- Difficulty accessibility options
- Tutorial speed adjustment
Meet WCAG 2.1 AA standards where applicable.
```

### Task 10.6: MVP Validation
```
Create MVP validation suite in tests/mvp/:
- Complete TIM quest line test (01-06)
- Economic progression validation
- All systems integration test
- 52-week full playthrough
- Memory and performance benchmarks
- Save/load cycle testing
- New player experience test
- Veteran player optimization test
- Edge case collection
- Completion requirements checklist
Confirm: 100% of MVP features functional and polished
```

---

## Implementation Notes

### Execution Order
1. Stages should be completed sequentially as they build on each other
2. Within each stage, tasks can often be parallelized
3. Testing tasks should run continuously, not just at the end

### Resource Requirements
- Each stage assumes previous stages are complete
- Reference CLAUDE.md for coding standards and patterns
- Use existing systems via GameCore.get_system() pattern
- All new systems must integrate with SignalBus
- Performance targets are mandatory, not optional

### Context Files to Include
When working on any task, include these files for context:
- CLAUDE.md (coding standards)
- scripts/core/game_core.gd (system management)
- scripts/core/signal_bus.gd (event system)
- scripts/core/global_enums.gd (type definitions)
- Relevant design docs from docs/design/
- Previous stage test results

### Success Criteria
Each task is complete when:
1. All listed features are implemented
2. Tests pass with >95% coverage
3. Performance targets are met
4. Integration with existing systems verified
5. Save/load functionality confirmed
6. No memory leaks detected
7. Documentation updated

### Common Patterns
```gdscript
# System access
var system = GameCore.get_system("system_name")

# Signal emission
var bus = GameCore.get_signal_bus()
bus.signal_name.emit(parameters)

# Resource validation
if not resource.is_valid():
    push_error("Invalid resource")
    return

# Performance measurement
var t0 = Time.get_ticks_msec()
# ... operation ...
var dt = Time.get_ticks_msec() - t0
print("AI_NOTE: performance(operation) = %d ms (baseline <Xms)" % dt)
```

### Testing Commands
```bash
# Project validation
godot --check-only project.godot

# Preflight check
godot --headless --scene tests/preflight_check.tscn

# Stage-specific tests
godot --headless --scene tests/stage_N/test_all.tscn

# Individual system tests
godot --headless --scene tests/systems/test_system_name.tscn
```