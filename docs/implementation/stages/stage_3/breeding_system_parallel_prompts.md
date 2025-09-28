# Breeding System Implementation - Parallel Prompts for Sonnet

## Overview
Genetic breeding system where creatures can produce offspring with inherited traits. Each prompt can run in parallel.

## Parallel Execution Strategy
- **Can run simultaneously:** Prompts 1, 2, 3, and 4
- **Sequential dependency:** Prompt 5 (integration) after others complete

---

## PROMPT 1: Genetics & Breeding Core (Can Run Parallel)

```
Create the breeding system core for a Godot 4 project at scripts/systems/breeding_system.gd:

CONTEXT:
- GameCore at scripts/core/game_core.gd for system registration
- SignalBus at scripts/core/signal_bus.gd for events
- CreatureData at scripts/data/creature_data.gd has stats and properties
- PlayerCollection at scripts/systems/player_collection.gd for creature management
- SpeciesSystem at scripts/systems/species_system.gd for species data

REQUIREMENTS:
1. Breeding system extends Node, registers with GameCore as "breeding"
2. Core properties:
   - breeding_pairs: Dictionary (pair_id -> BreedingPair)
   - breeding_cooldowns: Dictionary (creature_id -> weeks_remaining)
   - genetics_seed: int (for reproducible breeding)

3. Breeding mechanics:
   - can_breed(parent1: CreatureData, parent2: CreatureData) -> bool
   - calculate_compatibility(parent1: CreatureData, parent2: CreatureData) -> float
   - start_breeding(parent1: CreatureData, parent2: CreatureData) -> String (pair_id)
   - generate_offspring(pair_id: String) -> CreatureData
   - calculate_breeding_time(parent1: CreatureData, parent2: CreatureData) -> int

4. Genetic inheritance:
   - inherit_stats(parent1: CreatureData, parent2: CreatureData) -> Dictionary
   - inherit_traits(parent1: CreatureData, parent2: CreatureData) -> Array[String]
   - calculate_mutations(offspring: CreatureData, mutation_chance: float) -> void
   - determine_species(parent1: CreatureData, parent2: CreatureData) -> String

5. Add to SignalBus:
   - signal breeding_started(parent1: CreatureData, parent2: CreatureData, pair_id: String)
   - signal breeding_completed(offspring: CreatureData, pair_id: String)
   - signal breeding_failed(reason: String)
   - signal mutation_occurred(creature: CreatureData, mutation: String)

6. Genetics formulas:
   - Stat inheritance: 40% parent1, 40% parent2, 20% random variance
   - Trait inheritance: 50% chance from each parent
   - Mutation chance: 5% base + compatibility bonus
   - Breeding time: 1-3 weeks based on species

7. Breeding restrictions:
   - Minimum age: 4 weeks
   - Cooldown: 2 weeks after breeding
   - Same species or compatible species only
   - Cannot breed with siblings (track lineage)

Test with: godot --headless --scene tests/individual/test_breeding.tscn
```

---

## PROMPT 2: Breeding Compatibility & Traits (Can Run Parallel)

```
Create breeding compatibility and trait system for a Godot 4 project:

1. Create BreedingPair class at scripts/data/breeding_pair.gd:
   - Properties:
     - pair_id: String
     - parent1: CreatureData
     - parent2: CreatureData
     - compatibility: float (0.0 to 1.0)
     - breeding_start_week: int
     - breeding_duration: int
     - offspring_count: int (1-3 based on compatibility)

2. Create GeneticTrait at scripts/data/genetic_trait.gd:
   - Properties:
     - trait_id: String
     - display_name: String
     - trait_type: enum (DOMINANT, RECESSIVE, CO_DOMINANT)
     - stat_modifiers: Dictionary
     - inheritance_chance: float
     - mutation_group: String

3. Species compatibility matrix:
   ```gdscript
   const SPECIES_COMPATIBILITY = {
       "wolf": ["dog", "fox"],
       "cat": ["lion", "tiger"],
       "dragon": ["wyvern", "drake"],
       # Cross-species produce hybrids
   }
   ```

4. Create trait definitions in data/traits/:
   - strong_genes.tres (STR +10%, dominant)
   - quick_reflexes.tres (DEX +15%, recessive)
   - thick_hide.tres (CON +20%, co-dominant)
   - brilliant_mind.tres (INT +25%, rare)
   - albino.tres (All stats -5%, visual change)

5. Mutation system:
   - Random stat boosts (5-10%)
   - New traits not in parents
   - Color variations
   - Size variations
   - Rare "legendary" mutations

6. Lineage tracking:
   - Store parent IDs in offspring
   - Track generation number
   - Prevent inbreeding (siblings, parent-child)
   - Family tree visualization data

7. Hybrid species rules:
   - 70% chance of parent1 species
   - 20% chance of parent2 species
   - 10% chance of hybrid (if compatible)
   - Hybrids have unique stat distributions

Ensure genetic diversity and interesting combinations.
```

---

## PROMPT 3: Breeding UI Interface (Can Run Parallel)

```
Create breeding UI for a Godot 4 project:

1. Create scenes/ui/breeding.tscn:
   Breeding (Control)
   ├── Background (Panel)
   ├── BreedingHeader
   │   ├── Title (Label: "Breeding Center")
   │   └── CloseButton (Button)
   ├── ParentSelection (HBoxContainer)
   │   ├── Parent1Panel
   │   │   ├── Parent1Sprite (AnimatedSprite2D)
   │   │   ├── Parent1Name (Label)
   │   │   ├── Parent1Stats (VBoxContainer)
   │   │   └── SelectParent1Btn (Button)
   │   ├── HeartIcon (TextureRect - centered)
   │   └── Parent2Panel
   │       ├── Parent2Sprite (AnimatedSprite2D)
   │       ├── Parent2Name (Label)
   │       ├── Parent2Stats (VBoxContainer)
   │       └── SelectParent2Btn (Button)
   ├── CompatibilityPanel
   │   ├── CompatibilityBar (ProgressBar)
   │   ├── CompatibilityLabel (Label: "85% Compatible")
   │   └── TraitPreview (ItemList)
   └── BreedingActions
       ├── TimeEstimate (Label: "Breeding time: 2 weeks")
       ├── StartBreedingBtn (Button)
       └── CostLabel (Label: "Cost: 500 gold")

2. Create scripts/ui/breeding_controller.gd:
   - Load creatures from PlayerCollection
   - Filter breedable creatures
   - Calculate and display compatibility
   - Show potential trait inheritance
   - Preview possible offspring stats
   - Handle breeding initiation
   - Display breeding progress

3. Create scenes/ui/components/creature_selector.tscn:
   - Grid of creature cards
   - Filter by species, age, availability
   - Show breeding cooldowns
   - Highlight compatible pairs
   - Search functionality

4. Breeding preview features:
   - Stat range preview (min-max possible)
   - Trait inheritance chances
   - Possible mutations indicator
   - Offspring count estimate
   - Success rate display

5. Visual feedback:
   - Heart animation when breeding starts
   - Compatibility glow effect
   - Parent sprites face each other
   - Egg/nest animation during breeding
   - Sparkles for high compatibility

6. Create offspring reveal:
   - Egg hatching animation
   - Show offspring with fanfare
   - Compare to parents
   - Highlight inherited traits
   - Show any mutations

Connect to UIManager for scene management.
```

---

## PROMPT 4: Breeding Progression & Unlocks (Can Run Parallel)

```
Create breeding progression system for a Godot 4 project:

1. Create BreedingMastery at scripts/systems/breeding_mastery.gd:
   - Track breeding experience
   - Unlock new features with levels
   - Improve breeding outcomes
   - Reduce breeding times
   - Increase mutation chances

2. Mastery levels and unlocks:
   ```gdscript
   const MASTERY_UNLOCKS = {
       1: "Basic breeding",
       5: "Trait preview",
       10: "Reduced cooldown",
       15: "Twin chance +10%",
       20: "Cross-species breeding",
       25: "Mutation rate +5%",
       30: "Triplet chance",
       40: "Legendary mutations",
       50: "Perfect breeding"
   }
   ```

3. Breeding achievements:
   - First breeding
   - Breed 10/50/100 creatures
   - Create a hybrid
   - Get a mutation
   - Perfect compatibility breeding
   - Breed rare species
   - Complete breeding chain

4. Special breeding events:
   - Full moon: +10% mutation chance
   - Spring season: -1 week breeding time
   - Rare alignment: Legendary traits possible
   - Festival: Free breeding costs

5. Breeding items/consumables:
   - Fertility potion: +1 offspring
   - Mutation serum: +20% mutation chance
   - Compatibility charm: +15% compatibility
   - Time crystal: Instant breeding
   - Trait lock: Guarantee trait inheritance

6. Breeding facility upgrades:
   - Nursery: Hold more breeding pairs
   - Incubator: Reduce breeding time
   - Genetics lab: Preview exact offspring
   - Trait manipulator: Choose traits

7. Breeding chains/quests:
   - Breed specific combinations
   - Create creatures with rare traits
   - Achieve perfect stats
   - Discover hidden species

Track all progression in save system.
```

---

## PROMPT 5: Breeding Integration & Testing (Run After Others)

```
Integrate and test the complete breeding system in a Godot 4 project:

CONTEXT:
- Breeding system components have been created
- Need to wire everything together with game systems

REQUIREMENTS:
1. Integration tasks:
   - Add breeding system to GameCore loader
   - Connect to TimeSystem for breeding duration
   - Link with ResourceTracker for costs
   - Add breeding button to overlay_menu.tscn
   - Connect to achievement system
   - Update tutorial for breeding

2. Create tests/individual/test_breeding.tscn:
   - Test compatibility calculations
   - Verify stat inheritance
   - Test trait inheritance
   - Check mutation rates
   - Validate cooldowns
   - Test lineage tracking
   - Verify hybrid creation
   - Test save/load breeding pairs

3. Balance testing:
   - Breeding costs vs economy
   - Time requirements
   - Stat inheritance ranges
   - Mutation frequencies
   - Compatibility effects
   - Population growth rate

4. Edge cases:
   - Breeding at exactly min age
   - Max stat inheritance
   - All recessive traits
   - Circular lineage detection
   - Breeding during cooldown
   - Invalid species combinations

5. Performance:
   - Generate 100 offspring quickly
   - Large lineage trees
   - Multiple concurrent breedings
   - Complex trait calculations

6. Integration features:
   - Weekly breeding progress updates
   - Notification when complete
   - Auto-collect offspring option
   - Breeding statistics tracking
   - Family tree viewer

Run comprehensive tests:
godot --headless --scene tests/individual/test_breeding.tscn
```

---

## Implementation Notes

### Genetics Model
```
Offspring Stats = (Parent1 * 0.4) + (Parent2 * 0.4) + (Random * 0.2)
With mutations: ±5-10% additional variance
```

### Compatibility Factors
- Same species: 0.8 base
- Compatible species: 0.5 base
- Age difference: -0.1 per 10 weeks
- Trait overlap: +0.05 per shared trait
- Previous breeding: +0.1 bonus

### Breeding Costs
- Base cost: 500 gold
- Rare species: +200 gold
- Cross-species: +300 gold
- Reduced by mastery: -10% per 10 levels

### Offspring Quality
- 0-30% compatibility: 1 offspring, basic stats
- 31-70% compatibility: 1-2 offspring, good stats
- 71-90% compatibility: 2 offspring, great stats
- 91-100% compatibility: 2-3 offspring, excellent stats

### Integration Points
- GameCore: System registration
- SignalBus: Breeding events
- TimeSystem: Breeding duration
- ResourceTracker: Gold costs
- PlayerCollection: Offspring storage
- SaveSystem: Breeding pair persistence