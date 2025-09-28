# Battle System Implementation - Parallel Prompts for Sonnet

## Overview
Turn-based battle system where creatures fight using stats and abilities. Each prompt can run in parallel.

## Parallel Execution Strategy
- **Can run simultaneously:** Prompts 1, 2, 3, and 4
- **Sequential dependency:** Prompt 5 (integration) after others complete

---

## PROMPT 1: Battle System Core Engine (Can Run Parallel)

```
Create the battle system core for a Godot 4 project at scripts/systems/battle_system.gd:

CONTEXT:
- GameCore at scripts/core/game_core.gd for system registration
- SignalBus at scripts/core/signal_bus.gd for events
- CreatureData at scripts/data/creature_data.gd has stats (STR, CON, INT, WIS, DEX, DIS)
- GlobalEnums at scripts/core/global_enums.gd for battle enums

REQUIREMENTS:
1. Battle system extends Node, registers with GameCore as "battle"
2. Core properties:
   - current_battle: BattleInstance
   - battle_queue: Array[BattleAction]
   - turn_order: Array[CreatureData]
   - battle_state: enum (SETUP, PLAYER_TURN, ENEMY_TURN, RESOLVING, ENDED)

3. Combat mechanics:
   - calculate_damage(attacker: CreatureData, defender: CreatureData, action: String) -> int
   - calculate_hit_chance(attacker: CreatureData, defender: CreatureData) -> float
   - calculate_critical_chance(attacker: CreatureData) -> float
   - apply_damage(target: CreatureData, damage: int) -> void
   - check_battle_end() -> bool

4. Turn management:
   - start_battle(player_creature: CreatureData, enemy_creature: CreatureData) -> void
   - process_turn(action: BattleAction) -> void
   - advance_turn() -> void
   - get_next_actor() -> CreatureData

5. Add to SignalBus:
   - signal battle_started(player: CreatureData, enemy: CreatureData)
   - signal turn_started(creature: CreatureData)
   - signal damage_dealt(target: CreatureData, damage: int, is_critical: bool)
   - signal battle_ended(winner: CreatureData, rewards: Dictionary)
   - signal status_applied(target: CreatureData, status: String)

6. Damage formulas:
   - Physical: (ATK * 2 - DEF) * random(0.9, 1.1)
   - Magic: (INT * 1.5 - WIS/2) * random(0.9, 1.1)
   - Critical: damage * 1.5
   - Miss chance: 5% base + (defender.DEX - attacker.DEX) * 0.5%

7. Battle rewards:
   - Experience: enemy_level * 10
   - Gold: enemy_level * random(5, 15)
   - Item drops: based on enemy type

Test with: godot --headless --scene tests/individual/test_battle.tscn
```

---

## PROMPT 2: Battle Actions & Abilities (Can Run Parallel)

```
Create battle actions and abilities system for a Godot 4 project:

1. Create BattleAction class at scripts/data/battle_action.gd:
   - Properties:
     - action_name: String
     - action_type: enum (ATTACK, DEFEND, SKILL, ITEM, FLEE)
     - target_type: enum (SELF, ENEMY, ALL_ENEMIES, ALL_ALLIES)
     - power: int
     - accuracy: float
     - stamina_cost: int
     - cooldown: int
     - description: String

2. Create base actions:
   - Attack: Basic physical damage (power: 100, accuracy: 95%)
   - Defend: Reduce damage next turn (50% reduction)
   - Focus: Increase next attack damage (1.5x multiplier)
   - Flee: Attempt to escape battle (60% base chance)

3. Create CreatureAbility at scripts/data/creature_ability.gd:
   - Properties:
     - ability_id: String
     - display_name: String
     - element_type: String (fire, water, earth, air, neutral)
     - base_power: int
     - effect: String (damage, heal, buff, debuff)
     - learn_level: int

4. Status effects system at scripts/systems/status_effect_system.gd:
   - Poison: 5% max HP damage per turn
   - Burn: 3% max HP damage, reduces defense
   - Freeze: Skip next turn
   - Sleep: Skip turns until damaged
   - Buff/Debuff: Modify stats temporarily

5. Create ability resources in data/abilities/:
   - fireball.tres (Fire damage, burn chance)
   - heal.tres (Restore HP)
   - shield.tres (Increase defense)
   - haste.tres (Extra turn)
   - bite.tres (Physical damage, bleed chance)

6. Ability learning:
   - Creatures learn abilities at specific levels
   - Some abilities tied to species
   - Rare abilities from items/events

Each ability should follow type effectiveness (rock-paper-scissors style).
```

---

## PROMPT 3: Battle UI Interface (Can Run Parallel)

```
Create battle UI for a Godot 4 project:

1. Create scenes/ui/battle.tscn:
   Battle (Control)
   ├── Background (TextureRect - battle arena)
   ├── CreatureDisplay
   │   ├── PlayerSide
   │   │   ├── PlayerSprite (AnimatedSprite2D)
   │   │   ├── PlayerHP (ProgressBar)
   │   │   ├── PlayerStamina (ProgressBar)
   │   │   └── PlayerStatus (HBoxContainer for icons)
   │   └── EnemySide
   │       ├── EnemySprite (AnimatedSprite2D)
   │       ├── EnemyHP (ProgressBar)
   │       └── EnemyStatus (HBoxContainer)
   ├── BattleMenu (Panel)
   │   ├── ActionButtons (GridContainer)
   │   │   ├── AttackBtn (Button)
   │   │   ├── SkillBtn (Button)
   │   │   ├── DefendBtn (Button)
   │   │   └── FleeBtn (Button)
   │   └── SkillSubMenu (ItemList - hidden initially)
   └── BattleLog (RichTextLabel)

2. Create scripts/ui/battle_controller.gd:
   - Initialize battle display
   - Show action menu on player turn
   - Animate attacks and abilities
   - Update HP/stamina bars
   - Display damage numbers
   - Show status effect icons
   - Handle input during player turn
   - Display battle results

3. Battle animations:
   - Attack: Sprite moves toward target
   - Damage: Flash red, shake
   - Heal: Green particles
   - Critical: Screen flash, bigger damage text
   - Status: Icon appears above sprite
   - Victory: Celebration animation
   - Defeat: Fade to black

4. Create scenes/ui/components/damage_number.tscn:
   - Floating text that rises and fades
   - Color-coded (red: damage, green: heal, yellow: critical)
   - Size based on damage amount

5. Battle flow visualization:
   - Turn indicator showing whose turn
   - Action preview before confirming
   - Target selection highlighting
   - Queue display for multi-turn actions

6. Audio/Visual feedback:
   - Hit sounds based on action type
   - Screen shake for big hits
   - Particle effects for abilities
   - Victory fanfare
   - Defeat sound

Connect to UIManager for scene transitions.
```

---

## PROMPT 4: Enemy AI & Battle Scenarios (Can Run Parallel)

```
Create enemy AI and battle scenarios for a Godot 4 project:

1. Create EnemyAI at scripts/systems/enemy_ai.gd:
   - AI behavior types:
     - Aggressive: Prioritize damage
     - Defensive: Use defense when low HP
     - Balanced: Mix of offense/defense
     - Chaotic: Random actions
     - Smart: Exploit weaknesses

2. AI decision making:
   ```gdscript
   func choose_action(enemy: CreatureData, player: CreatureData) -> BattleAction:
       match ai_type:
           AIType.AGGRESSIVE:
               return choose_highest_damage_action()
           AIType.DEFENSIVE:
               if enemy.current_hp < enemy.max_hp * 0.3:
                   return defend_action
               return basic_attack
           AIType.SMART:
               return analyze_and_choose()
   ```

3. Create EnemyResource at scripts/resources/enemy_resource.gd:
   - Properties:
     - enemy_id: String
     - display_name: String
     - species_id: String
     - level: int
     - ai_type: String
     - stat_modifiers: Dictionary
     - ability_pool: Array[String]
     - reward_table: Dictionary

4. Create enemy definitions in data/enemies/:
   - wild_wolf.tres (Level 1-5, aggressive)
   - cave_bat.tres (Level 3-7, defensive)
   - forest_sprite.tres (Level 5-10, smart)
   - training_dummy.tres (Tutorial, passive)
   - boss_dragon.tres (Level 20, smart + special patterns)

5. Battle encounter system:
   - Random encounters in different areas
   - Level scaling based on player progress
   - Rare enemy variants (shiny, elite)
   - Boss battles with special mechanics

6. Enemy special behaviors:
   - Enrage at low HP (damage boost)
   - Call for help (summon allies)
   - Flee when losing badly
   - Use items (healing potions)
   - Learn from player patterns

7. Battle scenarios in data/battle_scenarios/:
   - tutorial_battle.tres (scripted for teaching)
   - random_encounter.tres (standard wild battles)
   - boss_battle.tres (multi-phase fights)
   - arena_battle.tres (tournament style)

Test enemy behaviors thoroughly for balance.
```

---

## PROMPT 5: Battle Integration & Testing (Run After Others)

```
Integrate and test the complete battle system in a Godot 4 project:

CONTEXT:
- Battle system components have been created
- Need to wire everything together with game flow

REQUIREMENTS:
1. Integration tasks:
   - Add battle system to GameCore loader
   - Create battle trigger points in game
   - Connect to creature collection for team selection
   - Link rewards to ResourceTracker
   - Add battle stats to save system
   - Create victory/defeat flow

2. Create tests/individual/test_battle.tscn:
   - Test damage calculations
   - Verify turn order
   - Test all status effects
   - Validate AI behaviors
   - Test ability effects
   - Check reward distribution
   - Test flee mechanics
   - Verify save/load mid-battle

3. Balance testing:
   - Damage vs HP scaling
   - Battle duration (target: 2-5 minutes)
   - Ability cooldowns and costs
   - Status effect durations
   - Experience gain rates
   - Item drop rates

4. Edge cases:
   - Both creatures KO same turn
   - Zero damage attacks
   - Healing beyond max HP
   - Negative stats from debuffs
   - Multiple status effects
   - Battle with level 1 vs level 99

5. Performance requirements:
   - 60 FPS during animations
   - <16ms turn processing
   - Smooth HP bar updates
   - No lag on ability selection

6. Battle flow integration:
   - Pre-battle team selection
   - Post-battle rewards screen
   - Experience gain animation
   - Return to previous scene
   - Auto-save after battle

Run comprehensive tests:
godot --headless --scene tests/individual/test_battle.tscn
```

---

## Implementation Notes

### Stat Abbreviations in Combat
- STR (Strength): Physical attack power
- CON (Constitution): HP and defense
- INT (Intelligence): Magic attack power
- WIS (Wisdom): Magic defense
- DEX (Dexterity): Hit/dodge chance
- DIS (Discipline): Critical chance and stamina

### Damage Types
- Physical: Uses STR vs CON
- Magical: Uses INT vs WIS
- True: Ignores defense
- Percentage: Based on max/current HP

### Battle Phases
1. **Initiative**: Determine turn order by DEX
2. **Player Turn**: Choose action from menu
3. **Execution**: Animate and apply effects
4. **Enemy Turn**: AI chooses action
5. **End Check**: Check for victory/defeat
6. **Repeat**: Continue until battle ends

### Rewards Table
- Experience: enemy_level * 10-20
- Gold: enemy_level * 5-15
- Items: 10-30% drop chance
- Rare drops: 1-5% for special items

### Integration Points
- GameCore: System registration
- SignalBus: Battle events
- CreatureData: Stats and HP
- ResourceTracker: Gold/item rewards
- PlayerCollection: Experience gains
- SaveSystem: Battle statistics