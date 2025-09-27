# INTERFACES.md

Authoritative lightweight interface/contract index for AI agents.
Do NOT bloat with narrative or implementation notes—pure structure + invariants.
If a new data Resource or formal interface is added, append a new section (append-only, no edits that break prior contracts).

---
## 1. CreatureData (Resource)
Path: `scripts/data/creature_data.gd`
Class name: `CreatureData`
Signals: NONE (resources must stay signal-free)

### 1.1 Properties (exported unless noted)
| Name | Type | Range / Shape | Mutability | Notes / Invariants |
|------|------|---------------|------------|--------------------|
| id | String | non-empty after _init | R/W | Auto-assigned if empty in `_init()`; unique per creature (not enforced globally) |
| creature_name | String | any | R/W | Display name |
| species_id | String | matches SpeciesSystem key | R/W | Source of truth for species |
| strength | int | 1..1000 | R/W (clamped) | Base stat |
| constitution | int | 1..1000 | R/W (clamped) | Base stat |
| dexterity | int | 1..1000 | R/W (clamped) | Base stat |
| intelligence | int | 1..1000 | R/W (clamped) | Base stat |
| wisdom | int | 1..1000 | R/W (clamped) | Base stat |
| discipline | int | 1..1000 | R/W (clamped) | Base stat |
| tags | Array[String] | list of tag ids | R/W | Must pass TagSystem validation externally |
| age_weeks | int | 0..lifespan_weeks | R/W | Incremented by AgeSystem or gameplay events |
| lifespan_weeks | int | 100..1000 | R/W | Species baseline; affects age category calculation |
| is_active | bool | true/false | R/W | PlayerCollection active roster flag |
| stamina_current | int | 0..stamina_max | R/W (clamped) | Current stamina / energy pool |
| stamina_max | int | 50..200 | R/W | Upper bound for stamina_current |
| egg_group | String | any | R/W | Breeding grouping (future) |
| parent_ids | Array[String] | list of creature ids | R/W | For lineage tracking |
| generation | int | 1..10 | R/W | Offspring generation depth |

### 1.2 Derived / Calculated (no storage)
| Concept | Source Method | Return Type | Notes |
|---------|---------------|-------------|-------|
| Age Category | `get_age_category()` | `GlobalEnums.AgeCategory` | Percentage-of-lifespan thresholds (BABY/JUVENILE/ADULT/ELDER/ANCIENT) |
| Age Modifier | `get_age_modifier()` | float | 0.6 / 0.8 / 1.0 scaling table per age category |
| Stat Value (string) | `get_stat(name)` | int | Accepts aliases: STR/CON/DEX/INT/WIS/DIS and full names |
| Stat Value (enum) | `get_stat_by_type(stat_type)` | int | Preferred accessor (enum safe) |

### 1.3 Methods
| Method | Signature | Side Effects | Notes |
|--------|----------|--------------|-------|
| `_init()` | `func _init() -> void` | May assign `id` | Only auto-populates id if empty |
| `get_age_category()` | `func get_age_category() -> GlobalEnums.AgeCategory` | None (pure) | Uses percentage thresholds: <10,<25,<75,<90, else |
| `get_age_modifier()` | `func get_age_modifier() -> float` | None (pure) | Matches category mapping (0.6/0.8/1.0/0.8/0.6) |
| `get_stat(stat_name)` | `func get_stat(stat_name: String) -> int` | Warning on invalid | Case-insensitive, alias-aware |
| `get_stat_by_type(stat_type)` | `func get_stat_by_type(stat_type: GlobalEnums.StatType) -> int` | None | Preferred enum path |
| `set_stat(stat_name, value)` | `func set_stat(stat_name: String, value: int) -> void` | Mutates one base stat | Performs basic range clamp via property setters |
| `set_stat_by_type(stat_type, value)` | `func set_stat_by_type(stat_type: GlobalEnums.StatType, value: int) -> void` | Mutates one base stat | Enum safe |
| `has_tag(tag)` | `func has_tag(tag: String) -> bool` | None | Simple membership test |
| `has_all_tags(required)` | `func has_all_tags(required_tags: Array[String]) -> bool` | None | Returns false on first miss |
| `has_any_tag(required)` | `func has_any_tag(required_tags: Array[String]) -> bool` | None | Returns true on first match |
| `to_dict()` | `func to_dict() -> Dictionary` | None | Serialization (contract below) |
| `from_dict(data)` | `static func from_dict(data: Dictionary) -> CreatureData` | Returns new instance | Safe defaults + typed array construction |

### 1.4 Serialization Contract (Dictionary Keys)
Top-level keys produced by `to_dict()` (MUST remain stable for backward compatibility):
```
{
  "id": String,
  "creature_name": String,
  "species_id": String,
  "stats": {
    "strength": int,
    "constitution": int,
    "dexterity": int,
    "intelligence": int,
    "wisdom": int,
    "discipline": int
  },
  "tags": Array[String],
  "age_weeks": int,
  "lifespan_weeks": int,
  "is_active": bool,
  "stamina_current": int,
  "stamina_max": int,
  "egg_group": String,
  "parent_ids": Array[String],
  "generation": int
}
```
Rules:
- Do NOT rename keys—add new optional keys only (backward compatible).
- Enum ordinals never serialized directly; only derived or string identifiers.

### 1.5 Invariants Summary
- Resource MUST remain signal-free.
- Stat properties always clamped to 1–1000 via setters.
- `stamina_current <= stamina_max` after any mutation.
- Age category & modifier logic lives ONLY here (not duplicated elsewhere).
- Arrays typed explicitly; `tags` and `parent_ids` always `Array[String]`.
- `from_dict()` must tolerate missing keys safely (default values).

### 1.6 Common Misuse Patterns (Reject / Avoid)
| Misuse | Correct Alternative |
|--------|---------------------|
| `creature.creature_id` | `creature.id` |
| External recomputation of age percentage | Use `get_age_category()` / `get_age_modifier()` |
| Direct stat dictionary access | Use `get_stat_by_type()` |
| Adding signals to CreatureData | Emit via CreatureEntity / SignalBus |

### 1.7 Extension Guidance
When adding new persisted fields:
1. Add exported property with typed declaration & validation.
2. Append optional key in `to_dict()` / parse in `from_dict()` with safe default.
3. DO NOT remove or rename existing keys.
4. Update this section (append only) and `CLAUDE.md` if new invariant introduced.

---
## 2. CreatureEntity (Node)
Path: `scripts/entities/creature_entity.gd`
Class name: `CreatureEntity`
Purpose: Behavioral wrapper for CreatureData, manages system interactions and signals

### 2.1 Properties
| Name | Type | Notes |
|------|------|-------|
| data | CreatureData | Core data resource (required) |
| tag_system | Node | Reference to TagSystem (auto-loaded) |
| stat_system | Node | Reference to StatSystem (auto-loaded) |
| signal_bus | SignalBus | Reference to SignalBus (auto-loaded) |

### 2.2 System Dependency Requirements
**CRITICAL**: All methods that depend on systems now fail fast without fallbacks (as of 2025-09-26).

| Method | Required System | Failure Behavior |
|--------|----------------|------------------|
| add_tag() | TagSystem | push_error() and return false |
| remove_tag() | TagSystem | push_error() and return false |
| can_add_tag() | TagSystem | push_error() and return {can_add: false, reason: "TagSystem not loaded"} |
| get_performance_score() | StatSystem | push_error() and return 0.0 |
| get_competition_stat() | StatSystem | push_error() and return 0 |
| matches_requirements() | StatSystem/TagSystem | push_error() and return false if required |

### 2.3 Public Methods
| Method | Signature | Notes |
|--------|----------|-------|
| assign_data | `func assign_data(creature: CreatureData) -> void` | Sets data and loads systems |
| add_tag | `func add_tag(tag: String) -> bool` | Requires TagSystem |
| remove_tag | `func remove_tag(tag: String) -> bool` | Requires TagSystem |
| can_add_tag | `func can_add_tag(tag: String) -> Dictionary` | Requires TagSystem |
| get_tags_by_category | `func get_tags_by_category(category: int) -> Array[String]` | Delegates to data |
| age_by_weeks | `func age_by_weeks(weeks: int) -> void` | Emits signals |
| consume_stamina | `func consume_stamina(amount: int) -> bool` | Returns false if insufficient |
| restore_stamina | `func restore_stamina(amount: int) -> void` | Clamps to max |
| rest_fully | `func rest_fully() -> void` | Sets to max stamina |
| set_active | `func set_active(active: bool) -> void` | Emits activation signals |
| matches_requirements | `func matches_requirements(req_stats: Dictionary, req_tags: Array[String]) -> bool` | Requires systems |
| get_performance_score | `func get_performance_score() -> float` | Requires StatSystem |
| get_effective_stat | `func get_effective_stat(stat_name: String) -> int` | Falls back to base stat |
| get_competition_stat | `func get_competition_stat(stat_name: String) -> int` | Requires StatSystem |

### 2.4 Invariants
- MUST have systems loaded for tag/stat operations (no dangerous fallbacks)
- All system-dependent operations fail fast with clear errors
- Signal emission only through SignalBus validated helpers
- Never modifies CreatureData tags directly (always through TagSystem)
- _is_valid_tag() is deprecated - use TagSystem.is_valid_tag()

### 2.5 Common Misuse Patterns (Reject)
| Misuse | Correct Alternative |
|--------|---------------------|
| Direct tag array manipulation | Use add_tag()/remove_tag() methods |
| Fallback tag validation | Require TagSystem to be loaded |
| Hardcoded tag lists | Use TagSystem as single source of truth |
| Silent system failures | push_error() and fail fast |

---
## 3. Planned Formal Interfaces
(Scaffolds—implement when first consumer exists.)

### 3.1 ISaveable (planned)
Proposed location: `scripts/core/interfaces/i_saveable.gd`
Minimum contract (draft):
```
interface ISaveable:
  func get_save_namespace() -> String
  func save_state() -> Dictionary
  func load_state(data: Dictionary) -> void
```
Notes:
- Systems implement to allow SaveSystem modular enumeration instead of hardcoded switch.
- Must be idempotent: calling `load_state(save_state())` should not drift state.

### 3.2 ITickable (planned)
```
interface ITickable:
  func tick(delta_weeks: int) -> void
```
Notes:
- Registered in future TimeSystem for unified progression loops.
- Must not emit signals directly for batch operations until after loop (aggregate if needed).

---
## 4. Change Log (Append Only)
| Date | Change | Notes |
|------|--------|-------|
| 2025-09-26 | Initial creation with CreatureData contract | Baseline |
| 2025-09-26 | Added implemented system/data interface summaries (TagSystem, AgeSystem, PlayerCollection, StatSystem, SpeciesSystem, ResourceTracker, SaveSystem, ItemDatabase, QuestData) | Expansion |
| 2025-09-26 | Added CreatureGenerator & SpeciesResource contracts | Generation layer coverage |
| 2025-09-26 | Added CreatureEntity contract with fail-fast dependency enforcement | Removed dangerous fallbacks |
| 2025-09-26 | Updated GlobalEnums with fail-fast validation patterns | Replaced silent fallbacks with explicit error logging |
| 2025-09-27 | Updated aging behavior documentation | Only active creatures age during weekly updates; stable creatures remain in stasis |
| 2025-09-27 | Fixed double aging issue in TimeSystem | Removed redundant aging events; WeeklyUpdateOrchestrator now handles all aging |
| 2025-09-27 | Added Shop & Economy Systems (Stage 3) | ShopSystem, ResourceTracker shop integration, EconomyConfig, VendorResource, Shop UI architecture with signal-based purchase flow |

---
## 5. Maintenance Rules
- Append-only except to correct factual inaccuracies.
- Keep table formats stable for machine parsing.
- If a contract becomes deprecated, mark with `(DEPRECATED)` but do not delete.

---
## 6. Implemented Data Models & Utilities

### 5.1 QuestData (Resource)
Path: `scripts/data/quest_data.gd`
Status: Placeholder (expand when quest progression implemented)

Properties:
| Name | Type | Notes |
|------|------|-------|
| id | String | Unique quest id |
| title | String | Display title |
| description | String | Narrative/goal text |
| is_completed | bool | Completion flag |

Methods:
| Method | Signature | Side Effects | Notes |
|--------|----------|--------------|-------|
| to_dict | `func to_dict() -> Dictionary` | None | Serializes all fields |

Serialization Keys: `{ id, title, description, is_completed }` (stable; append only)

### 5.2 ItemDatabase (Autoload Node)
Path: `scripts/data/item_database.gd`
Nature: Static in-memory item definitions (non-persistent)

Item Entry Shape: `{ name: String, type: String, food_type?: int, cost: int, sell: int, effect?: String }`

Static Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| is_valid_item | `static func is_valid_item(item_id: String) -> bool` | Existence check |
| get_item_data | `static func get_item_data(item_id: String) -> Dictionary` | Returns {} if missing |
| get_item_cost | `static func get_item_cost(item_id: String) -> int` | 0 default |
| get_item_type | `static func get_item_type(item_id: String) -> String` | "unknown" default |
| get_all_items | `static func get_all_items() -> Dictionary` | Duplicate copy |
| get_items_by_type | `static func get_items_by_type(item_type: String) -> Array[String]` | Filter by `type` |

---
## 7. Implemented Systems (Public Surfaces)
Only externally safe, non-underscore methods documented. Underscore-prefixed helpers are internal.

### 6.1 TagSystem
Path: `scripts/systems/tag_system.gd`
Key Data: `TAGS` dictionary; enum `TagCategory` (append-only).

Public Methods:
| Method | Signature | Purity | Notes |
|--------|----------|--------|-------|
| get_tag_data | `func get_tag_data(tag_name: String) -> Dictionary` | Pure | {} fallback |
| is_valid_tag | `func is_valid_tag(tag_name: String) -> bool` | Pure | Membership |
| get_tags_by_category | `func get_tags_by_category(category: TagSystem.TagCategory) -> Array[String]` | Pure | Category filter |
| get_all_tags | `func get_all_tags() -> Array[String]` | Pure | Flat list |
| validate_tag_combination | `func validate_tag_combination(tags: Array[String]) -> Dictionary` | Pure | {valid, errors[]} |
| can_add_tag_to_creature | `func can_add_tag_to_creature(creature_data: CreatureData, new_tag: String) -> Dictionary` | Pure | Pre-check |
| add_tag_to_creature | `func add_tag_to_creature(creature_entity: CreatureEntity, tag: String) -> bool` | Mutates | Emits via SignalBus |
| remove_tag_from_creature | `func remove_tag_from_creature(creature_entity: CreatureEntity, tag: String) -> bool` | Mutates | Emits removal |
| get_tags_to_remove_for | `func get_tags_to_remove_for(current_tags: Array[String], new_tag: String) -> Array[String]` | Pure | Conflict resolution |
| meets_tag_requirements | `func meets_tag_requirements(creature_data: CreatureData, required_tags: Array[String]) -> bool` | Pure | All present |
| filter_creatures_by_tags | `func filter_creatures_by_tags(creatures: Array[CreatureData], required: Array[String], excluded: Array[String]=[]) -> Array[CreatureData]` | Pure | Filtering |
| calculate_inherited_tags | `func calculate_inherited_tags(parent1_tags: Array[String], parent2_tags: Array[String]) -> Array[String]` | Random | Ensures validity |
| has_size_tag | `func has_size_tag(tags: Array[String]) -> bool` | Pure | Group check |
| get_tag_description | `func get_tag_description(tag_name: String) -> String` | Pure | Description fallback |
| get_tag_category | `func get_tag_category(tag_name: String) -> TagSystem.TagCategory` | Pure | Enum or -1 |
| calculate_tag_match_score | `func calculate_tag_match_score(creature_tags: Array[String], required_tags: Array[String]) -> float` | Pure | Fraction match |

Invariant: Tag mutations must go through TagSystem (no raw array mutation in higher-level business logic for validated flows).

### 6.2 AgeSystem
Path: `scripts/systems/age_system.gd`
Public Methods:
| Method | Signature | Side Effects | Notes |
|--------|----------|--------------|-------|
| age_creature_by_weeks | `func age_creature_by_weeks(creature_data: CreatureData, weeks: int) -> bool` | Mutates + emits | Core aging |
| age_creature_to_category | `func age_creature_to_category(creature_data: CreatureData, target_category: int) -> bool` | Mutates + emits | Category jump |
| age_all_creatures | `func age_all_creatures(creature_list: Array[CreatureData], weeks: int) -> int` | Mutates batch | Returns count |
| check_age_category_change | `func check_age_category_change(creature_data: CreatureData, old_age: int, new_age: int) -> Dictionary` | None | Analysis only |
| is_creature_expired | `func is_creature_expired(creature_data: CreatureData) -> bool` | None | Expiration |
| get_weeks_until_next_category | `func get_weeks_until_next_category(creature_data: CreatureData) -> int` | None | Remaining weeks |
| get_weeks_to_category | `func get_weeks_to_category(creature_data: CreatureData, target_category: int) -> int` | None | Weeks needed |
| get_age_distribution | `func get_age_distribution(creature_list: Array[CreatureData]) -> Dictionary` | None | Aggregation |
| get_lifespan_remaining | `func get_lifespan_remaining(creature_data: CreatureData) -> int` | None | Non-negative |
| calculate_age_performance_impact | `func calculate_age_performance_impact(creature_data: CreatureData) -> Dictionary` | None | Stats snapshot |
| advance_week | `func advance_week() -> Dictionary` | None | Placeholder |
| process_aging_events | `func process_aging_events() -> Dictionary` | None | Placeholder |
| get_category_name | `func get_category_name(category_id: int) -> String` | None | Lookup |
| get_category_modifier | `func get_category_modifier(category_id: int) -> float` | None | Lookup |
| validate_creature_age | `func validate_creature_age(creature_data: CreatureData) -> Dictionary` | None | Debug validator |

### 6.3 PlayerCollection
Path: `scripts/systems/player_collection.gd`
Public Methods:
| Method | Signature | Category | Notes |
|--------|----------|----------|-------|
| set_quiet_mode | `func set_quiet_mode(enabled: bool) -> void` | Config | Reduce logs |
| add_to_active | `func add_to_active(creature_data: CreatureData) -> bool` | Active | Cap enforced |
| remove_from_active | `func remove_from_active(creature_id: String) -> bool` | Active | Reindex |
| move_to_stable | `func move_to_stable(creature_id: String) -> bool` | Transfer | Active→Stable |
| get_active_creatures | `func get_active_creatures() -> Array[CreatureData]` | Query | Copy |
| get_available_for_quest | `func get_available_for_quest(required_tags: Array[String]) -> Array[CreatureData]` | Query | Tag filter |
| add_to_stable | `func add_to_stable(creature_data: CreatureData) -> bool` | Stable | Unlimited |
| remove_from_stable | `func remove_from_stable(creature_id: String) -> bool` | Stable | Remove |
| promote_to_active | `func promote_to_active(creature_id: String) -> bool` | Transfer | Stable→Active |
| get_stable_creatures | `func get_stable_creatures() -> Array[CreatureData]` | Query | Enumerate |
| search_creatures | `func search_creatures(criteria: Dictionary) -> Array[CreatureData]` | Query | Multi filter |
| acquire_creature | `func acquire_creature(creature_data: CreatureData, source: String) -> bool` | Lifecycle | Adds & signals |
| release_creature | `func release_creature(creature_id: String, reason: String) -> bool` | Lifecycle | Removes |
| get_collection_stats | `func get_collection_stats() -> Dictionary` | Metrics | Cached |
| get_species_breakdown | `func get_species_breakdown() -> Dictionary` | Metrics | Species counts |
| get_performance_metrics | `func get_performance_metrics() -> Dictionary` | Metrics | Active + stable summary |
| get_acquisition_history | `func get_acquisition_history() -> Array[Dictionary]` | Metrics | Chronological |
| save_collection_state | `func save_collection_state(slot_name: String="default") -> bool` | Persistence | Writes config |
| load_collection_state | `func load_collection_state(slot_name: String="default") -> bool` | Persistence | Rebuilds caches |

Invariants:
- Active roster size ≤ 6; metadata species counts non-negative; stats cache invalidated on structural change
- **Weekly aging behavior**: Only active creatures age during weekly updates; stable creatures remain in stasis

### 6.4 StatSystem
Path: `scripts/systems/stat_system.gd`
Public Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| get_effective_stat | `func get_effective_stat(creature_data: CreatureData, stat_name: String) -> int` | Base + modifiers |
| get_effective_stat_by_type | `func get_effective_stat_by_type(creature_data: CreatureData, stat_type: GlobalEnums.StatType) -> int` | Enum path |
| get_competition_stat | `func get_competition_stat(creature_data: CreatureData, stat_name: String) -> int` | Includes age modifier |
| apply_modifier | `func apply_modifier(creature_id: String, stat_name: String, value: int, modifier_type: ModifierType, stacking_mode: StackingMode, duration_weeks: int, modifier_id: String="") -> void` | Add modifier |
| remove_modifier | `func remove_modifier(creature_id: String, stat_name: String, modifier_id: String="") -> bool` | Remove specific/all |
| clear_creature_modifiers | `func clear_creature_modifiers(creature_id: String) -> void` | Purge creature modifiers |
| validate_stat_value | `func validate_stat_value(_stat_name: String, value: int) -> int` | Clamp 1..1000 |
| get_stat_cap | `func get_stat_cap(_stat_name: String) -> int` | Returns max |
| calculate_stat_difference | `func calculate_stat_difference(creature_a: CreatureData, creature_b: CreatureData, stat_name: String) -> int` | A-B |
| get_stat_tier | `func get_stat_tier(value: int) -> String` | Tier label |
| calculate_total_stats | `func calculate_total_stats(creature_data: CreatureData) -> int` | Sum effective |
| meets_requirements | `func meets_requirements(creature_data: CreatureData, requirements: Dictionary) -> bool` | Threshold check |
| compare_stats | `func compare_stats(creature_a: CreatureData, creature_b: CreatureData, stat_name: String) -> int` | Difference |
| calculate_performance | `func calculate_performance(creature_data: CreatureData, weights: Dictionary={}) -> float` | Weighted score |
| calculate_growth_rate | `func calculate_growth_rate(current_value: int, trainer_skill: int=50) -> int` | Diminishing returns |
| validate_stat_distribution | `func validate_stat_distribution(stats: Dictionary) -> bool` | Range & total |
| get_stat_display_name | `func get_stat_display_name(stat_key: String) -> String` | Human name |
| get_stat_breakdown | `func get_stat_breakdown(creature_data: CreatureData, stat_name: String) -> Dictionary` | Detailed structure |
| get_creature_modifiers | `func get_creature_modifiers(creature_id: String) -> Dictionary` | Deep copy |
| has_modifiers | `func has_modifiers(creature_id: String, stat_name: String="") -> bool` | Presence |

Invariant: Age modifier applied only in competition path, not base effective stat.

### 6.5 StaminaSystem
Path: `scripts/systems/stamina_system.gd`
Activity-based stamina management with no passive changes.

Activity Enum:
| Value | Name | Stamina Effect | Description |
|-------|------|---------------|-------------|
| 0 | IDLE | 0 | No activity, no stamina change |
| -20 | REST | +20 | Restores stamina through rest |
| 10 | TRAINING | -10 | Improves stats through practice |
| 15 | QUEST | -15 | Participates in quest activities |
| 25 | COMPETITION | -25 | Competes in events |
| 30 | BREEDING | -30 | Breeding activities |

Public Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| get_stamina | `func get_stamina(creature: CreatureData) -> int` | Current stamina 0-100 |
| set_stamina | `func set_stamina(creature: CreatureData, value: int) -> void` | Clamped to valid range |
| deplete_stamina | `func deplete_stamina(creature: CreatureData, amount: int) -> bool` | Applies modifiers |
| restore_stamina | `func restore_stamina(creature: CreatureData, amount: int) -> void` | Applies modifiers |
| is_exhausted | `func is_exhausted(creature: CreatureData) -> bool` | True if stamina ≤ 20 |
| can_perform_activity | `func can_perform_activity(creature: CreatureData, cost: int) -> bool` | Stamina check |
| assign_activity | `func assign_activity(creature: CreatureData, activity: Activity) -> bool` | Assign weekly activity |
| get_assigned_activity | `func get_assigned_activity(creature: CreatureData) -> Activity` | Get current activity |
| perform_activity | `func perform_activity(creature: CreatureData, activity: Activity, activity_name: String = "") -> bool` | Execute activity |
| get_activity_name | `func get_activity_name(activity: Activity) -> String` | Display name |
| process_weekly_activities | `func process_weekly_activities() -> Dictionary` | Process all assigned activities |
| auto_assign_activities | `func auto_assign_activities() -> void` | Auto-assign based on stamina |
| apply_food_effect | `func apply_food_effect(creature: CreatureData, food_type: String) -> void` | Food restoration |
| set_depletion_modifier | `func set_depletion_modifier(creature: CreatureData, modifier: float) -> void` | Stamina loss rate |
| set_recovery_modifier | `func set_recovery_modifier(creature: CreatureData, modifier: float) -> void` | Recovery rate |
| clear_modifiers | `func clear_modifiers(creature: CreatureData) -> void` | Remove modifiers |

Invariants:
- No passive stamina changes (deplete_weekly/restore_weekly are no-ops)
- Stamina only changes through assigned activities
- Activities must be explicitly assigned - IDLE maintains current stamina
- Exhaustion threshold is 20 stamina
- **Weekly aging behavior**: Only active creatures age during weekly updates; stable creatures remain in stasis

### 6.6 SpeciesSystem
Path: `scripts/systems/species_system.gd`
Public Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| get_species | `func get_species(species_id: String) -> SpeciesResource` | Null if missing |
| get_all_species | `func get_all_species() -> Array[String]` | All IDs |
| get_species_by_category | `func get_species_by_category(category: String) -> Array[String]` | Backward compatible |
| get_species_by_category_enum | `func get_species_by_category_enum(category: GlobalEnums.SpeciesCategory) -> Array[String]` | Preferred |
| get_species_by_rarity | `func get_species_by_rarity(rarity: String) -> Array[String]` | Backward compatible |
| get_species_by_rarity_enum | `func get_species_by_rarity_enum(rarity: GlobalEnums.SpeciesRarity) -> Array[String]` | Preferred |
| is_valid_species | `func is_valid_species(species_id: String) -> bool` | Membership |
| get_random_species | `func get_random_species(category: String="", rarity: String="") -> String` | Filtered random |
| get_species_info | `func get_species_info(species_id: String) -> Dictionary` | Generator-format dict |

Invariant: Defaults created if resource directory missing; arrays returned are copies.

### 6.6 ResourceTracker
Path: `scripts/systems/resource_tracker.gd`
Public Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| add_gold | `func add_gold(amount: int, source: String="unknown") -> bool` | Emits delta |
| spend_gold | `func spend_gold(amount: int, purpose: String="unknown") -> bool` | Validates funds |
| can_afford | `func can_afford(cost: int) -> bool` | Balance check |
| get_balance | `func get_balance() -> int` | Current gold |
| add_item | `func add_item(item_id: String, quantity: int=1) -> bool` | Validates + clamp |
| remove_item | `func remove_item(item_id: String, quantity: int=1) -> bool` | Quantity enforcement |
| get_item_count | `func get_item_count(item_id: String) -> int` | Count or 0 |
| has_item | `func has_item(item_id: String, quantity: int=1) -> bool` | Availability |
| get_inventory | `func get_inventory() -> Dictionary` | Duplicate |
| feed_creature | `func feed_creature(creature_id: String, food_id: String) -> bool` | Consumes + emits |
| get_transaction_history | `func get_transaction_history() -> Array[Dictionary]` | Copy |
| get_economic_stats | `func get_economic_stats() -> Dictionary` | Aggregated |
| save_state | `func save_state() -> Dictionary` | Persistence blob |
| load_state | `func load_state(data: Dictionary) -> void` | Idempotent load |

Invariant: No negative gold; max stack size enforced.

### 6.7 SaveSystem
Path: `scripts/systems/save_system.gd`
Key Public API (subset of very large file):
| Method | Signature | Notes |
|--------|----------|-------|
| save_game_state | `func save_game_state(slot_name: String="default") -> bool` | Full save pipeline |
| load_game_state | `func load_game_state(slot_name: String="default") -> bool` | Full load pipeline |
| delete_save_slot | `func delete_save_slot(slot_name: String) -> bool` | Deletes slot |
| get_save_slots | `func get_save_slots() -> Array[String]` | Enumerate slots |
| get_save_info | `func get_save_info(slot_name: String) -> Dictionary` | Metadata snapshot |
| save_creature_collection | `func save_creature_collection(creatures: Array[CreatureData], slot_name: String) -> bool` | Bulk creatures |
| load_creature_collection | `func load_creature_collection(slot_name: String) -> Array[CreatureData]` | Bulk load |
| save_individual_creature | `func save_individual_creature(creature: CreatureData, slot_name: String) -> bool` | Single save |
| load_individual_creature | `func load_individual_creature(creature_id: String, slot_name: String) -> CreatureData` | Single load |
| enable_auto_save | `func enable_auto_save(interval_minutes: int=5) -> void` | Timer start |
| disable_auto_save | `func disable_auto_save() -> void` | Timer stop |
| trigger_auto_save | `func trigger_auto_save() -> bool` | Manual trigger |
| validate_save_data | `func validate_save_data(slot_name: String) -> Dictionary` | Integrity check |

Invariants: Slot name validated; creature resource validation on load; hybrid resource + config model stable; enums append-only assumption.

---
## 8. Core Layer Interfaces
Central foundational APIs used by all higher-level systems. Changes here are high risk; treat as stable contracts unless explicitly versioned.

### 7.1 GameCore (Autoload Root)
Path: `scripts/core/game_core.gd`
Responsibilities: Lazy loading of systems, ownership of `SignalBus`.

Public Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| get_signal_bus | `func get_signal_bus() -> SignalBus` | Returns singleton instance |
| get_system | `func get_system(system_name: String) -> Node` | Lazy-loads + caches; names: `creature`, `save`, `quest`, `stat`, `tag`, `age`, `collection`, `resource` (`resources` alias), `species` |

Invariants:
- All system access must go through `get_system()` (no direct scene tree lookups in client code).
- New systems require match-case addition + Section 6 update in `CLAUDE.md`.

### 7.2 SignalBus (Central Event Hub)
Path: `scripts/core/signal_bus.gd`
Structure: Declares signals + provides validated emission helpers (pattern: `emit_<signal_name>()`).

Signal Domains (grouped):
- Core Save/Load: `save_requested`, `load_requested`, `save_completed(success)`, `load_completed(success)`
- Creature Lifecycle: `creature_created`, `creature_stats_changed`, `creature_modifiers_changed`, `creature_aged`, `creature_activated`, `creature_deactivated`
- Aging: `creature_category_changed`, `creature_expired`, `aging_batch_completed`
- Tag: `creature_tag_added`, `creature_tag_removed`, `tag_add_failed`, `tag_validation_failed`
- Species: `species_loaded`, `species_registered`, `species_validation_failed`
- Collection: `creature_acquired`, `creature_released`, `active_roster_changed`, `stable_collection_updated`, `collection_milestone_reached`
- Save Extended: `auto_save_triggered`, `save_progress`, `data_corrupted`, `backup_created`, `backup_restored`
- Economy / Inventory: `gold_changed`, `item_added`, `item_removed`, `transaction_failed`, `creature_fed`
- (Commented / Future) Quest, Time progression signals

Emission Helper Pattern (subset):
| Helper | Signature | Validation Focus |
|--------|----------|------------------|
| emit_creature_created | `func emit_creature_created(data: CreatureData) -> void` | Non-null data |
| emit_creature_stats_changed | `func emit_creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int) -> void` | Non-empty stat |
| emit_creature_aged | `func emit_creature_aged(data: CreatureData, new_age: int) -> void` | new_age >= 0 |
| emit_creature_category_changed | `func emit_creature_category_changed(data: CreatureData, old_category: int, new_category: int) -> void` | category bounds 0..4 |
| emit_creature_tag_added | `func emit_creature_tag_added(data: CreatureData, tag: String) -> void` | Non-empty tag |
| emit_gold_changed | `func emit_gold_changed(old_amount: int, new_amount: int, change: int) -> void` | Non-negative amounts |
| emit_item_added | `func emit_item_added(item_id: String, quantity: int, total: int) -> void` | quantity > 0, total > 0 |
| emit_active_roster_changed | `func emit_active_roster_changed(new_roster: Array[CreatureData]) -> void` | roster size <= 6 |
| emit_backup_created | `func emit_backup_created(slot_name: String, backup_name: String) -> void` | Non-empty strings |

Invariants:
- All external emission should prefer helpers (enforces validation + debug gating).
- Debug mode toggle: `set_debug_mode(bool)` controls console verbosity for emissions.
- Adding a new signal requires: declaration (alphabetical within domain), emission helper, minimal test, update to `CLAUDE.md` Section 12 if new domain.

### 7.3 GlobalEnums (Autoload)
Path: `scripts/core/global_enums.gd`
Purpose: Central enumeration & conversion utilities with fail-fast validation.

Enum Groups (append-only): AgeCategory, StatType, StatTier, SizeCategory, SpeciesCategory, SpeciesRarity, GenerationType, QuestDifficulty, QuestStatus, QuestType, CurrencyType, ItemType, ItemRarity, TagCategory, CollectionType, CollectionOperation.

**CRITICAL (as of 2025-09-26)**: All conversion functions now use fail-fast validation with push_error() logging.

Utility Methods (subset):
| Method | Signature | Notes |
|--------|----------|-------|
| age_category_to_string | `static func age_category_to_string(category: AgeCategory) -> String` | Mapping |
| string_to_age_category | `static func string_to_age_category(category_str: String) -> AgeCategory` | Logs error on invalid input |
| stat_type_to_string | `static func stat_type_to_string(stat: StatType) -> String` | Lowercase names |
| string_to_stat_type | `static func string_to_stat_type(stat_str: String) -> StatType` | Accepts abbreviations; logs error on invalid |
| get_all_stat_types | `static func get_all_stat_types() -> Array[StatType]` | Ordered list |
| get_stat_tier | `static func get_stat_tier(value: int) -> StatTier` | Range classification |
| stat_tier_to_string | `static func stat_tier_to_string(tier: StatTier) -> String` | Tier label |
| species_category_to_string | `static func species_category_to_string(category: SpeciesCategory) -> String` | Returns "unknown" on invalid enum |
| string_to_species_category | `static func string_to_species_category(category_str: String) -> SpeciesCategory` | Logs error on invalid input |
| species_rarity_to_string | `static func species_rarity_to_string(rarity: SpeciesRarity) -> String` | Returns "unknown" on invalid enum |
| string_to_species_rarity | `static func string_to_species_rarity(rarity_str: String) -> SpeciesRarity` | Logs error on invalid input |
| string_to_tag_category | `static func string_to_tag_category(category_str: String) -> TagCategory` | Logs error on invalid input |
| is_valid_age_category | `static func is_valid_age_category(category: int) -> bool` | Bounds check |
| is_valid_stat_type | `static func is_valid_stat_type(stat: int) -> bool` | Bounds check |
| is_valid_stat_value | `static func is_valid_stat_value(value: int) -> bool` | 1..1000 |
| is_valid_species_category | `static func is_valid_species_category(category: int) -> bool` | 0..6 bounds check |
| is_valid_species_rarity | `static func is_valid_species_rarity(rarity: int) -> bool` | 0..3 bounds check |
| is_valid_tag_category | `static func is_valid_tag_category(category: int) -> bool` | 0..5 bounds check |
| validate_age_category | `static func validate_age_category(category: int, context: String = "") -> bool` | Enhanced validation with context |
| validate_stat_type | `static func validate_stat_type(stat: int, context: String = "") -> bool` | Enhanced validation with context |
| validate_species_category | `static func validate_species_category(category: int, context: String = "") -> bool` | Enhanced validation with context |

Invariants:
- Never reorder enum entries; only append to preserve ordinal compatibility (save data, comparisons, switch statements).
- All conversion functions log errors on invalid input instead of silent fallbacks.
- Invalid enum-to-string conversions return "unknown" instead of arbitrary defaults.
- All new conversion helpers MUST have both directions (enum↔string) when user input or persistence is involved.

### 7.4 SystemValidator (Utility)
Path: `scripts/core/system_validator.gd`
Purpose: Centralized runtime & pattern validation for AI agents and tests.

Surface Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| validate_creature_property_access | `static func validate_creature_property_access(creature_data: CreatureData, property_name: String) -> bool` | Enforces canonical names |
| validate_system_method_call | `static func validate_system_method_call(system_name: String, method_name: String) -> bool` | Flags deprecated calls |
| validate_array_type | `static func validate_array_type(array_value: Variant, expected_type: String="String") -> bool` | Ensures typed arrays |
| validate_time_api_usage | `static func validate_time_api_usage(code_string: String) -> bool` | Guards invalid API usage |
| validate_system_loading | `static func validate_system_loading(system_name: String, loaded_via_get_system: bool) -> bool` | Enforces GameCore accessor |
| validate_integration_pattern | `static func validate_integration_pattern(pattern_code: String) -> Dictionary` | Multi-error scan |
| run_comprehensive_validation | `static func run_comprehensive_validation() -> bool` | Aggregated checks |
| preflight_check | `static func preflight_check() -> bool` | Lightweight environment sanity |

Invariants:
- Error messaging must prefer corrective guidance (WRONG vs CORRECT usage pairs).
- Preflight must remain side-effect minimal (no stateful mutations beyond ephemeral allocations).

---

## 9. Generation & Species Resources

### 8.1 CreatureGenerator (Static Utility)
Path: `scripts/generation/creature_generator.gd`
Nature: Pure static methods on a `RefCounted` (NOT a GameCore-managed system). ~~Hardcoded species dictionary (SPECIES_DATA) removed~~ - now fully integrated with `SpeciesSystem` resources.

Public Generation Methods:
| Method | Signature | Returns | Notes |
|--------|----------|---------|-------|
| generate_creature_data | `static func generate_creature_data(species_id: String, generation_type: GlobalEnums.GenerationType=GlobalEnums.GenerationType.UNIFORM, creature_name: String="") -> CreatureData` | CreatureData or null | Lightweight generation (preferred for inventory/save) |
| generate_creature_entity | `static func generate_creature_entity(species_id: String, generation_type: GlobalEnums.GenerationType=GlobalEnums.GenerationType.UNIFORM, creature_name: String="") -> CreatureEntity` | CreatureEntity or null | Wraps `generate_creature_data` into entity |
| generate_starter_creature | `static func generate_starter_creature(species_id: String="scuttleguard") -> CreatureEntity` | CreatureEntity or null | Applies +10% (min +5) stat boost before stamina recalculation |
| generate_from_egg | `static func generate_from_egg(species_id: String, egg_quality: String="standard") -> CreatureData` | CreatureData | Maps quality→GenerationType (premium/high, discount/low, standard/uniform, else gaussian) |
| generate_population_data | `static func generate_population_data(count: int, species_distribution: Dictionary={}) -> Array[CreatureData]` | Array[CreatureData] | Weighted species selection; pre-alloc optimization |
| validate_creature_against_species | `static func validate_creature_against_species(data: CreatureData) -> Dictionary` | `{valid: bool, errors: Array[String]}` | Verifies stats within species ranges + guaranteed tags present |
| get_generation_statistics | `static func get_generation_statistics() -> Dictionary` | Snapshot copy | Aggregated counters (total, by_species, by_type) |
| reset_generation_statistics | `static func reset_generation_statistics() -> void` | None | Clears counters |
| get_available_species | `static func get_available_species() -> Array[String]` | Species IDs | Delegates to SpeciesSystem (required) |
| get_species_info | `static func get_species_info(species_id: String) -> Dictionary` | Species info dict | Delegates to SpeciesSystem (required) |
| is_valid_species | `static func is_valid_species(species_id: String) -> bool` | Bool | Delegates to SpeciesSystem (required) |

Generation Algorithms (internal helpers — names stable for test hooks, not external API): `_generate_uniform_stats`, `_generate_gaussian_stats`, `_generate_high_roll_stats`, `_generate_low_roll_stats`.

Statistic Tracking Structure (from `get_generation_statistics()`):
```
{
  "total_generated": int,
  "by_species": { species_id: int, ... },
  "by_type": { generation_type_name: int, ... }
}
```

~~Hardcoded Species Data (SPECIES_DATA) Contract~~ (REMOVED):
- ✅ **MIGRATED**: All species data now in SpeciesSystem .tres resource files
- Species: `scuttleguard`, `stone_sentinel`, `wind_dancer`, `glow_grub` available through SpeciesSystem
- Schema maintained in SpeciesResource class with proper validation

Invariants:
- All creature stat generation passes through `_generate_stats()` dispatch using `GenerationType`.
- Starter creature boost applied AFTER base generation and BEFORE external systems interaction.
- Tag assignment always validated through TagSystem when available; fallback only when TagSystem missing.
- Population generation must not allocate inside loop beyond per-creature object creation (pre-sized array maintained).
- Gaussian generation clamps within provided min/max.

Misuse Patterns:
| Misuse | Correct |
|--------|---------|
| Direct mutation of `_generation_stats` | Use `reset_generation_statistics()` + regenerate |
| Bypassing TagSystem by manual `data.tags = [...]` | Let generator assign or run TagSystem validation externally |
| Assuming species data hardcoded | Always use SpeciesSystem through CreatureGenerator |

Extension Guidance:
1. Add new generation algorithm: extend `GlobalEnums.GenerationType`, implement `_generate_<name>_stats`, add case to `_generate_stats`, update tests & this section (append entry only).
2. When migrating species out: ensure `SpeciesSystem.get_species_info()` returns identical shape consumed here.
3. Preserve existing species IDs; only append new ones.

### 8.2 SpeciesResource (Resource)
Path: `scripts/resources/species_resource.gd`
Purpose: Data-driven species specification replacing hardcoded generator entries.

Properties:
| Name | Type | Notes / Invariants |
|------|------|--------------------|
| species_id | String | Primary key (non-empty) |
| display_name | String | UI label (non-empty) |
| description | String | Optional longer text |
| category | GlobalEnums.SpeciesCategory | Enum; stored as ordinal internally; append-only list |
| rarity | GlobalEnums.SpeciesRarity | Enum; append-only list |
| base_price | int | ≥0 economic baseline |
| lifespan_weeks | int | >0 total natural lifespan |
| maturity_weeks | int | ≥0; ≤ peak_weeks ≤ lifespan_weeks (implied relationship) |
| peak_weeks | int | Performance midpoint marker |
| size_category | GlobalEnums.SizeCategory | Physical scale enum |
| habitat_preference | String | e.g. terrestrial/aquatic/aerial/underground |
| stat_ranges | Dictionary | Keys: strength, constitution, dexterity, intelligence, wisdom, discipline → each {min:int, max:int, min < max} |
| guaranteed_tags | Array[String] | Always applied; validated externally |
| optional_tags | Array[String] | Candidate optional tags |
| tag_probabilities | Dictionary | tag:String -> float 0..1 (optional override of uniform OPTIONAL_TAG_CHANCE) |
| name_pool | Array[String] | Non-empty for validation success |
| name_prefix | String | Optional decorative prefix |
| name_suffix | String | Optional decorative suffix |
| breeding_group | String | Group label for compatibility |
| compatible_species | Array[String] | Species IDs for breeding (Stage 8) |
| hybrid_offspring | Array[String] | Potential hybrid species IDs |
| sprite_path | String | Asset path (may be empty placeholder) |
| icon_path | String | Asset path (may be empty placeholder) |
| sound_effects | Dictionary | Keyed by event (e.g., spawn, feed) |
| feeding_preferences | Array[String] | Food type identifiers |
| training_modifiers | Dictionary | Stat -> modifier value (scaling factors) |
| special_abilities | Array[String] | Unique ability identifiers |

Methods:
| Method | Signature | Notes |
|--------|----------|-------|
| get_stat_range | `func get_stat_range(stat_name: String) -> Dictionary` | Returns {min,max} or default {1,100} |
| is_compatible_for_breeding | `func is_compatible_for_breeding(other_species_id: String) -> bool` | Membership check |
| get_random_name | `func get_random_name() -> String` | Uses name_pool; applies prefix/suffix |
| validate | `func validate() -> Dictionary` | `{valid: bool, errors: Array[String]}`; enforces non-empty critical fields & stat range sanity |

Initialization Behavior:
- `_init()` calls `_setup_default_stat_ranges()` if `stat_ranges` empty (default 50..150 across all stats).

Validation Rules (summarized from `validate()`):
- `species_id`, `display_name`, `name_pool` non-empty; `lifespan_weeks` > 0.
- Each stat range includes `min`, `max`, and `min < max`.

Invariants:
- External systems must treat arrays as immutable copies (duplicate before mutation).
- Enum groups in `GlobalEnums` append-only; ordinal persistence stability required.
- `get_stat_range()` never returns null; always a dictionary with numeric min/max.

Extension Guidance:
1. Adding a new property: export var with sensible default, update `validate()` if required, append row to property table (do not reorder existing rows).
2. Adding new stat: must extend `GlobalEnums.StatType`, update default stat range construction, ensure generator algorithms include new stat.
3. When introducing hybrid logic, keep `compatible_species` symmetrical unless explicit asymmetry intended (document here if so).

---

## 10. Shop & Economy Systems (Stage 3)

### 9.1 ShopSystem
Path: `scripts/systems/shop_system.gd`
Purpose: Vendor management, inventory tracking, and transaction processing
Dependencies: ItemManager, SignalBus

Public Methods:
| Method | Signature | Side Effects | Notes |
|--------|----------|--------------|-------|
| get_all_vendors | `func get_all_vendors() -> Array[VendorResource]` | None | Returns all vendors (locked + unlocked) |
| get_unlocked_vendors | `func get_unlocked_vendors() -> Array[VendorResource]` | None | Only accessible vendors |
| get_vendor | `func get_vendor(vendor_id: String) -> VendorResource` | None | Single vendor lookup |
| is_vendor_unlocked | `func is_vendor_unlocked(vendor_id: String) -> bool` | None | Unlock status check |
| get_vendor_inventory | `func get_vendor_inventory(vendor_id: String) -> Array[Dictionary]` | None | Item list for vendor |
| can_purchase_item | `func can_purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary` | None | Purchase validation |
| purchase_item | `func purchase_item(vendor_id: String, item_id: String, player_gold: int) -> Dictionary` | Mutates stock + emits signals | Core transaction |
| calculate_item_price | `func calculate_item_price(vendor_id: String, item_id: String) -> int` | None | Final price with discounts |
| restock_vendor | `func restock_vendor(vendor_id: String) -> void` | Mutates inventory | Single vendor restock |
| restock_all_vendors | `func restock_all_vendors() -> void` | Mutates all inventories | Weekly restock |

Purchase Flow Return Types:
```gdscript
# can_purchase_item() returns:
{
    "can_purchase": bool,
    "reason": String  # If can_purchase is false
}

# purchase_item() returns:
{
    "success": bool,
    "gold_spent": int,
    "item_received": {"item_id": String, "quantity": int},
    "message": String
}
```

Signals Emitted:
- `item_purchased(item_id: String, quantity: int, vendor_id: String, cost: int)` - When purchase succeeds

Invariants:
- ShopSystem ONLY handles vendor-side logic (stock, pricing, validation)
- Does NOT directly modify player resources (gold/inventory)
- All resource changes handled by ResourceTracker via signals
- Vendor inventory cached for performance; invalidated on purchases/restocks

### 9.2 ResourceTracker (Extended for Shop Integration)
Path: `scripts/systems/resource_tracker.gd`
Purpose: Player gold and inventory management
Signal Integration: Listens for shop purchases, handles resource changes

Additional Shop-Related Methods:
| Method | Signature | Side Effects | Notes |
|--------|----------|--------------|-------|
| _on_item_purchased | `func _on_item_purchased(item_id: String, quantity: int, vendor_id: String, cost: int) -> void` | Deducts gold + adds item | Signal handler |

Signal Flow for Purchases:
```
1. ShopSystem.purchase_item() validates & updates vendor stock
2. ShopSystem emits item_purchased(item_id, quantity, vendor_id, cost)
3. ResourceTracker._on_item_purchased() receives signal
4. ResourceTracker.spend_gold() deducts cost
5. ResourceTracker.add_item() adds to player inventory
6. ResourceTracker emits gold_spent signal for UI updates
```

### 9.3 EconomyConfig (Resource)
Path: `scripts/resources/economy_config.gd`
Purpose: Configurable economic parameters

Properties:
| Name | Type | Default | Notes |
|------|------|---------|-------|
| creature_egg_base_price | int | 200 | Base price for creature eggs |
| food_base_price_per_week | int | 5 | Weekly food cost baseline |
| training_item_base_price | int | 50 | Training item cost |
| reputation_discount_per_10_points | float | 0.01 | 1% discount per 10 reputation |
| vendor_markup_range | Vector2 | (0.8, 1.2) | Price variation 80%-120% |
| weekly_restock_percentage | float | 0.3 | 30% of max stock restored |
| max_stock_per_item | int | 20 | Maximum vendor stock |
| min_stock_per_item | int | 5 | Minimum vendor stock |

### 9.4 VendorResource (Resource)
Path: Auto-loaded from `data/vendors/*.tres`
Purpose: Vendor configuration and properties

Properties:
| Name | Type | Notes |
|------|------|-------|
| vendor_id | String | Unique identifier |
| display_name | String | UI display name |
| description | String | Vendor description |
| unlock_requirements | Dictionary | Conditions for unlocking |
| base_reputation | int | Starting reputation |
| items_sold | Array[String] | Item IDs this vendor sells |
| markup_modifier | float | Price adjustment factor |

Invariants:
- All vendors loaded from .tres files in data/vendors/
- vendor_id must be unique across all vendors
- items_sold references valid ItemManager items

### 9.5 Shop UI Architecture

#### ShopPanelController
Path: `scripts/ui/shop_panel_controller.gd`
Purpose: Main shop interface controller
Dependencies: ShopSystem (read-only), ResourceTracker (read-only for display)

Signal-Based Updates:
| Signal Listened | Handler | Purpose |
|----------------|---------|---------|
| gold_spent | _on_gold_spent | Update gold display |
| item_purchased | _on_item_purchased | Update vendor inventory cache |

UI Access Pattern:
```gdscript
# ✅ CORRECT: Read-only queries for display
var gold = resource_tracker.get_balance()
var vendors = shop_system.get_unlocked_vendors()
var inventory = shop_system.get_vendor_inventory(vendor_id)

# ✅ CORRECT: Purchase through shop system
var result = shop_system.purchase_item(vendor_id, item_id, player_gold)

# ❌ WRONG: Direct resource manipulation
resource_tracker.spend_gold(amount)  # Should use signals
resource_tracker.add_item(item_id)   # Should use signals
```

#### ShopItemCard
Path: `scripts/ui/shop_item_card.gd` + `scenes/ui/components/shop_item_card.tscn`
Purpose: Individual item display component

Features:
- Icon loading from ItemResource via ItemManager
- Fallback colored textures by item type
- Stock display with visual feedback
- Purchase button state management
- Hover effects and selection signals

Performance Optimizations:
- Item grid updates: <16ms target (60 FPS)
- Vendor inventory caching with smart invalidation
- Icon texture caching to prevent repeated loads
- Component pooling for large inventories

---
