# CLAUDE.md

Primary machine-actionable guidance for AI coding agents (Claude, GPT, etc.). Keep this file short, stable, enumerated. Narrative/historical details live in `docs/development/ARCHIVE_STAGE1_TASK_DETAILS.md`.

## 0. EXECUTION PROTOCOL (ALWAYS IN THIS ORDER)
1. Preflight: `godot --headless --scene tests/preflight_check.tscn` (abort on fail)
2. Identify minimal affected files (no broad search & replace unless explicit)
3. Verify invariants (Section 1) before editing
4. Apply minimal cohesive patch
5. Re-run preflight + directly related individual test (if exists)
6. Summarize: each user requirement → Done / Skipped (reason) + invariants status
7. Never proceed to new feature if any invariant broken

## 1. NON-NEGOTIABLE INVARIANTS
- Data vs behavior: `CreatureData` Resource (no signals) / `CreatureEntity` Node (behavior + signaling via SignalBus ONLY)
- Property names: `id`, `species_id`, `age_weeks`, `lifespan_weeks`, `creature_name` (NO legacy variants)
- System access: ONLY `GameCore.get_system("<name>")`
- Age category & modifier logic lives on `CreatureData` (do not duplicate)
- Arrays explicitly typed (e.g. `Array[String]`, `Array[CreatureData]`)
- Signals: use existing SignalBus emission helpers; no new bespoke wrapper unless a brand‑new domain event (see Section 12)
- Species truth: SpeciesSystem resources (Deprecated Hardcoded Species Map is read‑only; do not extend)
- Enums are append‑only: NEVER reorder or repurpose existing values (breaks save compatibility & comparisons)
- Performance: New batch ops must respect baselines (Section 7) or include timing comment (Section 13)
- Save orchestration: SaveSystem coordinates; each system owns its serialization (no duplication inside SaveSystem)
- No partial SaveSystem modularization unless an explicit task states "SaveSystem modular refactor"

## 2. ALLOWED / DISALLOWED
ALLOWED: focused feature implementation, adding a precise enum value, introducing small interface (`ISaveable`, `ITickable`) with registration, adding targeted test scene.

DISALLOWED (without explicit instruction): wide renames, new bespoke signal wrappers, extending deprecated species map, duplicating age/stat helpers, untyped public arrays, speculative refactors.

## 3. TASK EXECUTION TEMPLATE (INTERNAL WORKFLOW)
1. Intent → concrete edits list
2. Read target files (only) to confirm assumptions
3. Patch
4. Preflight + individual test(s)
5. Summarize results & invariant checklist

## 4. FILE MAP QUICK REFERENCE
Core Loader: `scripts/core/game_core.gd`
Signals: `scripts/core/signal_bus.gd`
Enums: `scripts/core/global_enums.gd`
Systems: `scripts/systems/*.gd`
Data: `scripts/data/*.gd`
Generation: `scripts/generation/`
Tests (unit/individual): `tests/individual/`
Integration Harness: `tests/test_all.tscn`, `test_setup.tscn`
Preflight: `tests/preflight_check.tscn`

## 5. PATCH POLICY
- Leave unrelated formatting untouched
- Remove dead code only if zero references AND clearly deprecated
- Use `# TODO(stage2): ...` for deferred refactors
- Add `# AI_NOTE:` only when rationale is non-obvious to future reviewers

## 6. CURRENT SYSTEM KEYS
`collection`, `save`, `tag`, `age`, `stat`, `resource` (ResourceTracker), `species`  
(Extend list when adding new system; update tests referencing keys.)

Canonical signal usage (do NOT invent new wrappers):
```gdscript
var bus = GameCore.get_signal_bus()
bus.creature_acquired.emit(creature, "shop")  # existing signal
```
If a new domain event truly required, follow Section 12 before adding.

## 7. PERFORMANCE BASELINES
| Operation | Target |
|-----------|--------|
| 1000 creature generation | <100ms |
| Batch aging 1000 creatures | <100ms |
| Save/load 100 creatures | <200ms |
| 100 species lookups | <50ms |
If exceeded, add timing + mitigation note in summary.

## 8. SUBMISSION CHECKLIST
- [ ] Preflight passes
- [ ] No forbidden property names introduced
- [ ] No new signal wrapper (or documented & tested if added)
- [ ] All arrays typed explicitly
- [ ] Only `GameCore.get_system()` used for systems
- [ ] No duplicated age/stat logic
- [ ] Species edits via resources only (not Deprecated Hardcoded Species Map)
- [ ] Tests updated/added for changed logic
- [ ] Performance within baseline or timing comment added
- [ ] Enums only appended (if touched)
- [ ] SaveSystem untouched unless task explicitly permits refactor
- [ ] No structural refactor attempted without explicit label (e.g. REFRACTOR_APPROVED:save_system)

## 9. COMMON ERROR GUARDS
- Untyped arrays → inference warnings (treated as errors)
- Legacy property names (`creature_id`, `species`) → breaks tests & filters
- Calling age/category on system instead of data → method not found
- Time API misuse (`.nanosecond`) → invalid; use `Time.get_ticks_msec()`
- Reordered enum values → subtle corruption (never reorder)
- Structural refactor without approval label → likely scope creep (abort & request explicit task)

## 10. ADDING A NEW SYSTEM (MINIMAL STEPS)
1. `scripts/systems/<name>_system.gd` (extends Node)
2. Add case in `game_core.gd` loader
3. Add small test in `tests/individual/`
4. Append key to Section 6 list
5. If persistent: implement save hooks or register future `ISaveable`
6. Place future interfaces in `scripts/core/interfaces/` and list in `INTERFACES.md`

## 11. STAGE 1 CONSOLIDATED LESSONS (REFERENCE)
Concise durable principles from Stage 1 (Tasks 1–10):
- Data/behavior separation enforced (Resources never emit signals)
- Central SignalBus with pending future generic emitter consolidation
- Validation-before-mutation for tags, age transitions, stats
- Batch-first performance mindset (1k operations under stated thresholds)
- Hybrid persistence (ConfigFile + ResourceSaver) orchestrated—not duplicated—by SaveSystem
- Deprecated Hardcoded Species Map slated for removal after full migration verification
- Active roster cap + invariants enforced at system boundary
- Quiet/debug modes required for bulk operations & CI readability
- Anti-patterns: duplicate age math, expanding deprecated species map, bespoke signal wrappers, property drift

## 12. SIGNAL EVENT ADDITION PROTOCOL
1. Define event: name + payload param list (types) in a comment block
2. Add signal to `signal_bus.gd` in alphabetic order within its domain cluster
3. Add or extend validation (null/empty/type checks) in emission path
4. Provide minimal test (emit success + invalid payload rejection) in `tests/individual/`
5. Update Section 6 only if a new system domain introduced
6. Add summary line to PR / task output referencing test name

## 13. PERFORMANCE MEASUREMENT PATTERN
Use this pattern when measuring new or potentially expensive operations:
```gdscript
var _t0: int = Time.get_ticks_msec()
# ... operation ...
var _dt: int = Time.get_ticks_msec() - _t0
print("AI_NOTE: performance(batch_aging_1000) = %d ms (baseline <100ms)" % _dt)
```
Embed one timing line per new batch operation; remove exploratory spam.

Always prefix automated performance logs with `AI_NOTE:` so they are easily greppable and can be stripped from release builds.

## 14. REQUIREMENT SUMMARY FORMAT (END OF AI TASK)
Provide a concise, standardized summary after changes:
```
Requirements:
- Add age modifier caching: Done
- Preserve existing signals: Done
- Avoid new wrappers: Done
Performance: batch_aging_1000 = 62ms (<100ms) PASS
Invariants: All pass
Enums touched: None
Follow-ups: TODO(stage2): unify species random selection weighting
```
Rules:
- List every explicit user requirement (even if skipped → mark Skipped + reason)
- Include at most one performance line per operation type
- Omit unchanged systems from summary
- If any invariant fails → STOP (do not submit patch)
## 15. DOC AUTHORITY MATRIX
| Doc | Purpose | Modify When |
|-----|---------|-------------|
| CLAUDE.md | Operational AI protocol & invariants | New invariant / process change |
| AI_AGENT_GUIDE.md | Expanded examples & templates | New common pattern emerges |
| README.md | Human overview & milestones | Milestone / scope shift |
| ARCHIVE_STAGE1_TASK_DETAILS.md | Historical narrative | New stage archive only |
| INTERFACES.md | Interface contracts index | Append-only when adding or extending contracts |

## 16. DEPRECATED ARTIFACTS
- Deprecated Hardcoded Species Map: constant `SPECIES_DATA` in `scripts/generation/creature_generator.gd` (read‑only; do NOT extend; removal scheduled post-migration validation)
- Legacy per-signal wrapper pattern (replaced by central validation + future generic emitter)

## 17. COMMIT MESSAGE GUIDELINE (FOR AI-GENERATED PATCHES)
Format: `type(scope): summary | invariants OK`
Types: feat, fix, chore, docs, test, perf, refactor (refactor only with approval label)
Example: `feat(age): add weeks_to_category util (62ms/1k) | invariants OK`

---
Provide a concise block like:
```
Requirements:
- Add age modifier caching: Done
- Preserve existing signals: Done
- Avoid new wrappers: Done
Performance: batch_aging_1000 = 62ms (<100ms) PASS
Invariants: All pass
Enums touched: None
Follow-ups: TODO(stage2): unify species random selection weighting
```

---
Legacy detailed task narratives moved to: `docs/development/ARCHIVE_STAGE1_TASK_DETAILS.md`
1. **Comprehensive Tag Architecture**
   - **Success**: 25 tags across 5 categories with complete metadata
   - **Success**: Complex validation with mutual exclusions, dependencies, incompatibilities
   - **Validation**: All 12 test scenarios passed with 0ms performance

2. **Advanced Validation System**
   - **Success**: Mutual exclusions prevent conflicts (Size, Activity patterns, Social/Solitary)
   - **Success**: Dependencies enforce requirements (Flies→Winged, Sentient→Problem Solver)
   - **Success**: Incompatibilities prevent invalid combinations (Aquatic↔Flies)
   - **Pattern**: Validate before modification to prevent invalid states

3. **Quest Integration Ready**
   - **Success**: Tag requirement matching for quest eligibility
   - **Success**: Collection filtering by required/excluded tags
   - **Success**: Tag match scoring for optimal creature selection
   - **Pattern**: Perfect (1.0) and partial (0.33) scoring system works

4. **Performance Excellence**
   - **Success**: 100 creatures filtered in 0ms demonstrates optimization
   - **Success**: Efficient filtering handles 1000+ creature collections
   - **Pattern**: Cache validation results and use efficient data structures

5. **CreatureEntity Integration**
   - **Success**: Safe tag management through TagSystem validation
   - **Success**: Proper fallback behavior when TagSystem not loaded
   - **Success**: Signal integration with comprehensive error reporting
   - **Pattern**: Use system validation before direct data modification

6. **Signal Architecture Enhancement**
   - **Success**: 4 new tag signals with proper validation
   - **Success**: Debug logging shows signal flow clearly
   - **Pattern**: Validated emission methods prevent invalid data propagation

### New Best Practices from Task 4:
- **Validation before modification is crucial** - Prevent invalid states from occurring
- **Performance testing validates optimization** - 0ms filtering proves efficient algorithms
- **Complex validation systems need comprehensive test coverage** - 12 scenarios ensure reliability
- **Signal validation provides excellent debugging** - Red errors prove protection works
- **String-based tags work well for Stage 1** - Enum migration planned for later stages
- **CreatureEntity fallback patterns improve robustness** - System works even with missing dependencies
- **Dictionary-based tag metadata scales well** - Easy to add new tags and properties

### Updated Verification Checklist from Task 4:
- [ ] TagSystem loads via GameCore lazy loading
- [ ] All 25 tags defined with proper categories
- [ ] Validation prevents size conflicts (Small+Large)
- [ ] Dependencies enforced (Flies requires Winged)
- [ ] Incompatibilities blocked (Aquatic vs Flies)
- [ ] Quest requirement matching works
- [ ] Collection filtering efficient (0ms for 100 creatures)
- [ ] CreatureEntity integration safe with validation
- [ ] Signal flow shows proper emission and validation
- [ ] Performance handles large datasets gracefully

## Stage 1 Task 5 Lessons Learned

### ✅ Task 5 (Creature Generation) - COMPLETED & VERIFIED
**Key Achievements:**

1. **CreatureGenerator Utility Class Architecture**
   - **Success**: Static utility class (RefCounted, not GameCore subsystem)
   - **Success**: Generates CreatureData by default (lightweight for save/serialization)
   - **Success**: CreatureEntity generation only when behavior needed
   - **Pattern**: Follows established MVC separation patterns from Tasks 1-4

2. **Complete Species Implementation**
   - **Success**: 4 species with distinct stat ranges, tags, and lifespans
   - **Success**: Scuttleguard (starter), Stone Sentinel (premium), Wind Dancer (flying), Glow Grub (utility)
   - **Success**: All species integrate with TagSystem validation
   - **Pattern**: Hardcoded for Stage 1, ready for SpeciesSystem migration in Task 10

3. **Generation Algorithm Variety**
   - **Success**: UNIFORM, GAUSSIAN (Box-Muller), HIGH_ROLL, LOW_ROLL algorithms
   - **Success**: Each algorithm produces expected statistical distributions
   - **Success**: Premium eggs (HIGH_ROLL) vs discount eggs (LOW_ROLL) differentiation
   - **Pattern**: Algorithm selection affects creature quality as designed

4. **Performance Excellence**
   - **Success**: 1000 creatures generated in <100ms (target met)
   - **Success**: Pre-allocation and caching optimizations effective
   - **Success**: Population generation scales linearly
   - **Pattern**: Performance-first approach with batch operations

5. **Property Consistency Achieved**
   - **Success**: Unified `lifespan_weeks` property across CreatureData and species data
   - **Success**: Type safety fixes for all Array[String] assignments
   - **Success**: Godot 4.5 compilation without critical errors
   - **Pattern**: Explicit typing and consistent naming prevents confusion

6. **TagSystem Integration**
   - **Success**: Guaranteed tags always assigned, optional tags 25% probability
   - **Success**: Full TagSystem validation during generation
   - **Success**: Graceful fallback when TagSystem unavailable
   - **Pattern**: Validation-first approach with fallback behavior

### New Best Practices from Task 5:
- **Static utility classes work well** for generation without lifecycle management
- **CreatureData-first generation** improves serialization and performance
- **Unified property naming** (lifespan_weeks) prevents assignment errors
- **Performance targets drive architecture** - pre-allocation and caching essential
- **Validation during generation** prevents invalid creature creation
- **Factory method patterns** provide flexibility for different use cases
- **Statistical validation** ensures generation algorithms work as intended

### CreatureGenerator Usage Patterns:
```gdscript
# Basic generation (most common)
var creature_data: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Generation with specific algorithm
var premium_creature: CreatureData = CreatureGenerator.generate_creature_data("stone_sentinel", CreatureGenerator.GenerationType.HIGH_ROLL)

# Full entity when behavior needed immediately
var creature_entity: CreatureEntity = CreatureGenerator.generate_creature_entity("wind_dancer")

Example: `feat(age): add weeks_to_category util (62ms/1k) | invariants OK`

---
(Full historical task narratives have been removed from this file; see `docs/development/ARCHIVE_STAGE1_TASK_DETAILS.md` for legacy detail.)
1. **Complete Player Collection System Architecture**
   - **Success**: Active roster (6 creature limit) with swap mechanics
   - **Success**: Stable collection (unlimited) with promotion/demotion
   - **Success**: Advanced search with multiple criteria types
   - **Success**: Collection statistics and performance metrics
   - **Pattern**: Dual collection system balances gameplay and flexibility

2. **Property Name Consistency Critical**
   - **Issue**: Mixed use of `creature_id` vs `id`, `species` vs `species_id`
   - **Solution**: Standardized on `id` and `species_id` throughout codebase
   - **Impact**: Fixed over 20 property reference errors across systems
   - **Pattern**: Always use consistent property names across all systems

3. **Method Location Matters**
   - **Issue**: `age_system.get_creature_age_category()` doesn't exist
   - **Solution**: Use `creature_data.get_age_category()` - methods on data classes
   - **Impact**: Simplified API by keeping methods close to data
   - **Pattern**: Data classes should contain their own utility methods

4. **Array Type Safety in Godot 4.5**
   - **Issue**: `["Flying"]` causes type mismatch with `Array[String]` parameters
   - **Solution**: Explicit typing: `var tags: Array[String] = ["Flying"]`
   - **Impact**: Eliminated all array type errors in system integration
   - **Pattern**: Always use explicit array typing for method parameters

5. **Time Measurement API Changes**
   - **Issue**: `Time.get_time_dict_from_system().nanosecond` doesn't exist
   - **Solution**: Use `Time.get_ticks_msec()` for all timing measurements
   - **Impact**: Fixed all performance measurement code
   - **Pattern**: Millisecond precision sufficient for game timing

6. **Output Overflow Management**
   - **Issue**: Verbose signal logging causes terminal overflow in tests
   - **Solution**: Implemented comprehensive quiet mode system
   - **Success**: Class-level control variables for runtime management
   - **Pattern**: Always provide quiet/debug modes for bulk operations

### New Best Practices from Task 8:
- **Documentation prevents errors** - API_REFERENCE.md eliminated 90% of integration issues
- **Individual test infrastructure** - Isolated tests improve debugging efficiency
- **Signal validation essential** - Comprehensive validation prevents invalid state propagation
- **Property naming conventions** - Establish and enforce early to prevent confusion
- **Performance testing mandatory** - Always measure against concrete targets
- **Quiet modes necessary** - Bulk operations need output control

### Critical Integration Patterns:
```gdscript
# Pattern 1: Explicit Array Typing
var required_tags: Array[String] = ["Flying", "Fast"]
var available = collection.get_available_for_quest(required_tags)

# Pattern 2: Correct Property Access
if creature_data.id == target_id:  # NOT creature_id
    process_creature(creature_data)

# Pattern 3: Method Location
var category = creature_data.get_age_category()  # NOT age_system.get_creature_age_category()

# Pattern 4: Quiet Mode for Bulk Operations
collection_system.set_quiet_mode(true)
# ... bulk operations ...
collection_system.set_quiet_mode(false)
```

### Updated Verification Checklist from Task 8:
- [ ] PlayerCollection loads via GameCore lazy loading pattern
- [ ] Active roster enforces 6-creature limit with proper swapping
- [ ] Stable collection handles unlimited creatures efficiently
- [ ] Search functionality works with all criteria types
- [ ] Quest availability checking integrates with TagSystem
- [ ] Collection statistics calculate correctly
- [ ] All 5 collection signals emit with proper validation
- [ ] Property names consistent: `id`, `species_id` everywhere
- [ ] Array parameters use explicit `Array[String]` typing
- [ ] Performance targets met: <100ms for 100 creature operations
- [ ] Quiet mode prevents output overflow in tests
- [ ] Individual test infrastructure enables focused debugging

## Stage 1 Task 10 Lessons Learned

### ✅ Task 10 (Species Resources System) - COMPLETED & VERIFIED
**Key Achievements:**

1. **Complete Resource-Based Architecture**
   - **Success**: SpeciesResource class with full template properties and validation
   - **Success**: SpeciesSystem GameCore subsystem with lazy loading
   - **Success**: Directory structure ready for .tres files with fallback to defaults
   - **Pattern**: Resource-based data management enables future modding support

2. **Seamless CreatureGenerator Integration**
   - **Success**: Backward compatibility maintained with fallback patterns
   - **Success**: SpeciesSystem integration with existing get_species_info() API
   - **Success**: No breaking changes to existing creature generation workflows
   - **Pattern**: Gradual migration strategy allows incremental system upgrades

3. **Array Type Safety Resolution**
   - **Issue**: `Array[String]` assignments failed with "Invalid assignment" errors
   - **Solution**: Explicit array construction with typed loops for guaranteed_tags, optional_tags, name_pool
   - **Impact**: Fixed all compilation errors and enabled proper type safety
   - **Pattern**: Godot 4.5 requires explicit Array[Type] handling for Resource properties

4. **SignalBus Integration Excellence**
   - **Success**: 3 new species signals with proper validation patterns
   - **Success**: Consistent validation using existing pattern (if variable.is_empty())
   - **Success**: Debug logging integration maintains development visibility
   - **Pattern**: Follow established SignalBus patterns for consistency

5. **Test Infrastructure Enhancement**
   - **Success**: Individual test_species.tscn with comprehensive coverage
   - **Success**: Integration test function in test_setup.gd with performance metrics
   - **Success**: Added to test_all.gd for complete test suite coverage
   - **Pattern**: Each system needs individual and integration test coverage

6. **Performance Excellence Achieved**
   - **Success**: <50ms for 100 species lookups (target met)
   - **Success**: Efficient category/rarity organization with proper indexing
   - **Success**: Lazy loading minimizes startup time
   - **Pattern**: Performance-first design with caching and efficient data structures

### New Best Practices from Task 10:
- **Resource property assignments need explicit typing** - Use typed loops for Array[String] properties
- **Fallback patterns enable gradual migration** - Maintain backward compatibility during system upgrades
- **Directory structure planning is critical** - Create paths early even if files don't exist yet
- **SignalBus validation consistency** - Follow established patterns for error handling
- **Migration strategies work incrementally** - Implement phases to avoid breaking changes
- **Performance testing validates architecture** - Always measure against concrete targets

### SpeciesSystem Usage Patterns:
```gdscript
# Basic species management
var species_system = GameCore.get_system("species")
var all_species: Array[String] = species_system.get_all_species()
var starters: Array[String] = species_system.get_species_by_category("starter")

# CreatureGenerator integration (automatic)
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Detailed species information
var species_resource: SpeciesResource = species_system.get_species("wind_dancer")
var species_info: Dictionary = species_system.get_species_info("wind_dancer")

# Random selection with filtering
var random_starter: String = species_system.get_random_species("starter", "")
var random_rare: String = species_system.get_random_species("", "rare")
```

### Updated Verification Checklist from Task 10:
- [ ] SpeciesSystem loads via GameCore lazy loading pattern
- [ ] Species data fallback creates 4 default species when no .tres files exist
- [ ] All species validation passes with proper error reporting
- [ ] Category and rarity organization works efficiently
- [ ] CreatureGenerator integration maintains backward compatibility
- [ ] Individual SpeciesSystem test passes all 6 test scenarios
- [ ] Integration test includes SpeciesSystem validation
- [ ] Performance targets met: <50ms for 100 species lookups
- [ ] Array[String] property assignments work correctly
- [ ] SignalBus species signals emit with proper validation
- [ ] Test infrastructure covers both individual and integration scenarios