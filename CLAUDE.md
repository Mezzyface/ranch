# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Primary machine-actionable guidance for AI coding agents (Claude, GPT, etc.). Keep this file short, stable, enumerated. Narrative/historical details live in `docs/development/ARCHIVE_STAGE1_TASK_DETAILS.md`.

## 0. EXECUTION PROTOCOL (ALWAYS IN THIS ORDER)
1. Preflight: `godot --check-only project.godot` (validate project) + `godot --headless --scene tests/preflight_check.tscn` (abort on fail)
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
- **Resource-based data**: Use ItemManager/SpeciesSystem with .tres files; ItemDatabase is DEPRECATED
- Resource validation: All resource classes (SpeciesResource, ItemResource) must implement `is_valid()` and fail-fast on invalid data
- Resource files: Must be proper Godot .tres format with @tool annotation and @export properties
- Enums are append‑only: NEVER reorder or repurpose existing values (breaks save compatibility & comparisons)
- Performance: New batch ops must respect baselines (Section 7) or include timing comment (Section 13)
- Save orchestration: SaveSystem coordinates; each system owns its serialization (no duplication inside SaveSystem)
- No partial SaveSystem modularization unless an explicit task states "SaveSystem modular refactor"
- **Fail-fast principle**: System dependencies must be explicit; NO silent fallbacks that bypass validation (push_error and return failure)

## 2. ALLOWED / DISALLOWED
ALLOWED: focused feature implementation, adding a precise enum value, introducing small interface (`ISaveable`, `ITickable`) with registration, adding targeted test scene.

DISALLOWED (without explicit instruction): wide renames, new bespoke signal wrappers, extending deprecated species map, duplicating age/stat helpers, untyped public arrays, speculative refactors, **silent fallback patterns that bypass system validation**.

## 3. TASK EXECUTION TEMPLATE (INTERNAL WORKFLOW)
1. Intent → concrete edits list
2. Read target files (only) to confirm assumptions
3. Patch
4. Preflight + individual test(s)
5. Summarize results & invariant checklist

## 4. COMMON COMMANDS
```bash
# Project validation (run first)
godot --check-only project.godot

# Test execution (in order of preference)
godot --headless --scene tests/preflight_check.tscn          # Preflight check
godot --headless --scene tests/individual/test_<system>.tscn # Individual tests
godot --headless --scene tests/test_all.tscn                 # All tests
run_tests.bat [timeout_seconds]                              # Automated test runner with timeout
tests/run_tests.bat [timeout_seconds]                        # Direct test runner

# Stage-specific preflights
godot --headless --scene tests/stage_2_preflight.tscn        # Stage 2 readiness check

# Alternative (if godot not in PATH)
"C:\Program Files\Godot\Godot.exe" --check-only project.godot
"C:\Program Files\Godot\Godot.exe" --headless --scene tests/preflight_check.tscn
```

## 5. FILE MAP QUICK REFERENCE
Core Loader: `scripts/core/game_core.gd`
Signals: `scripts/core/signal_bus.gd`
Enums: `scripts/core/global_enums.gd`
Main Controller: `scripts/controllers/main_controller.gd` (persistent scene manager)
Game Controller: `scripts/controllers/game_controller.gd` (game state abstraction)
UI Manager: `scripts/ui/ui_manager.gd` (scene/window management)
UI Controllers: `scripts/ui/*_controller.gd` (UI scene logic)
UI Scenes: `scenes/ui/*.tscn` (main_menu, game_ui)
UI Components: `scenes/ui/components/*.tscn` (reusable UI elements)
UI Theme: `resources/themes/default_theme.tres`
Main Scene: `scenes/main/main.tscn` (application entry point)
ItemManager: `scripts/systems/item_manager.gd` (replaces ItemDatabase)
SpeciesSystem: `scripts/systems/species_system.gd` (loads SpeciesResource files)
TimeSystem: `scripts/systems/time_system.gd` (weekly progression, events)
Weekly Events: `scripts/core/weekly_event.gd` (time-based event system)
Systems: `scripts/systems/*.gd`
Resource Classes: `scripts/resources/*.gd` (ItemResource, SpeciesResource)
Resource Files: `data/items/*.tres`, `data/species/*.tres` (Godot Resource instances)
Data: `scripts/data/*.gd` (Core data structures, TimeData)
Entities: `scripts/entities/*.gd`
Generation: `scripts/generation/`
Tests (individual): `tests/individual/`
Test Infrastructure: `tests/test_all.tscn`, `tests/test_runner.tscn`
Preflights: `tests/preflight_check.tscn`, `tests/stage_2_preflight.tscn`
Test Automation: `tests/run_tests.bat`, `tests/run_tests.ps1`

## 6. PATCH POLICY
- Leave unrelated formatting untouched
- Remove dead code only if zero references AND clearly deprecated
- Use `# TODO(stage2): ...` for deferred refactors
- Add `# AI_NOTE:` only when rationale is non-obvious to future reviewers

## 7. CURRENT SYSTEM KEYS
`collection`, `save`, `tag`, `age`, `stat`, `resource` (ResourceTracker), `species`, `item_manager` (ItemManager), `time` (TimeSystem), `ui` (UIManager), `stamina` (StaminaSystem)
(Extend list when adding new system; update tests referencing keys.)

Canonical signal usage (do NOT invent new wrappers):
```gdscript
var bus = GameCore.get_signal_bus()
bus.creature_acquired.emit(creature, "shop")  # existing signal
bus.week_advanced.emit(new_week, total_weeks)  # time progression
```
TimeSystem access pattern:
```gdscript
var time_system = GameCore.get_system("time")
time_system.advance_week()  # manual progression
time_system.schedule_event(event, target_week)  # event scheduling
```
UIManager access pattern:
```gdscript
var ui_manager = GameCore.get_system("ui")
ui_manager.change_scene("res://scenes/ui/game_ui.tscn")  # scene management
ui_manager.show_window("shop")  # window management
```
Architecture: Main scene (persistent) → GameController → Systems. UI scenes receive GameController reference, never access systems directly.

If a new domain event truly required, follow Section 13 before adding.

## 8. PERFORMANCE BASELINES
| Operation | Target |
|-----------|--------|
| 1000 creature generation | <100ms |
| Batch aging 1000 creatures | <100ms |
| Save/load 100 creatures | <200ms |
| 100 species lookups | <50ms |
| Weekly time progression | <200ms |
| Event processing (100 events) | <50ms |
If exceeded, add timing + mitigation note in summary.

## 9. SUBMISSION CHECKLIST
- [ ] Preflight passes
- [ ] No forbidden property names introduced
- [ ] No new signal wrapper (or documented & tested if added)
- [ ] All arrays typed explicitly
- [ ] Only `GameCore.get_system()` used for systems
- [ ] No duplicated age/stat logic
- [ ] Species edits via resources only (SpeciesSystem fully operational)
- [ ] **Resource validation**: All .tres files loadable with proper script_class and @tool annotation
- [ ] **ItemManager integration**: Use GameCore.get_system("item_manager") for item operations
- [ ] Tests updated/added for changed logic
- [ ] Performance within baseline or timing comment added
- [ ] Enums only appended (if touched)
- [ ] SaveSystem untouched unless task explicitly permits refactor
- [ ] No structural refactor attempted without explicit label (e.g. REFRACTOR_APPROVED:save_system)

## 10. COMMON ERROR GUARDS
- Untyped arrays → inference warnings (treated as errors)
- Legacy property names (`creature_id`, `species`) → breaks tests & filters
- Calling age/category on system instead of data → method not found
- Time API misuse (`.nanosecond`) → invalid; use `Time.get_ticks_msec()`
- Reordered enum values → subtle corruption (never reorder)
- Structural refactor without approval label → likely scope creep (abort & request explicit task)
- Silent fallback patterns → data corruption; use push_error() and fail fast
- Direct tag array manipulation → bypasses validation; use TagSystem methods only
- **Invalid .tres format** → Resource files must have proper Godot format with script_class and load_steps
- **Missing @tool annotation** → Resource classes must use @tool for editor loading
- **Missing ItemManager** → Use GameCore.get_system("item_manager") for item operations

## 11. ADDING A NEW SYSTEM (MINIMAL STEPS)
1. `scripts/systems/<name>_system.gd` (extends Node)
2. Add case in `game_core.gd` loader
3. Add small test in `tests/individual/`
4. Append key to Section 7 list
5. If persistent: implement save hooks or register future `ISaveable`
6. Place future interfaces in `scripts/core/interfaces/` and list in `INTERFACES.md`

## 12. STAGE 1 CONSOLIDATED LESSONS (REFERENCE)
Concise durable principles from Stage 1 (Tasks 1–10):
- Data/behavior separation enforced (Resources never emit signals)
- Central SignalBus with pending future generic emitter consolidation
- Validation-before-mutation for tags, age transitions, stats
- Batch-first performance mindset (1k operations under stated thresholds)
- Hybrid persistence (ConfigFile + ResourceSaver) orchestrated—not duplicated—by SaveSystem
- Resource-based species management fully operational (hardcoded data removed)
- Active roster cap + invariants enforced at system boundary
- Quiet/debug modes required for bulk operations & CI readability
- Anti-patterns: duplicate age math, bespoke signal wrappers, property drift, hardcoded data patterns

## 13. SIGNAL EVENT ADDITION PROTOCOL
1. Define event: name + payload param list (types) in a comment block
2. Add signal to `signal_bus.gd` in alphabetic order within its domain cluster
3. Add or extend validation (null/empty/type checks) in emission path
4. Provide minimal test (emit success + invalid payload rejection) in `tests/individual/`
5. Update Section 7 only if a new system domain introduced
6. Add summary line to PR / task output referencing test name

## 14. PERFORMANCE MEASUREMENT PATTERN
Use this pattern when measuring new or potentially expensive operations:
```gdscript
var _t0: int = Time.get_ticks_msec()
# ... operation ...
var _dt: int = Time.get_ticks_msec() - _t0
print("AI_NOTE: performance(batch_aging_1000) = %d ms (baseline <100ms)" % _dt)
```
Embed one timing line per new batch operation; remove exploratory spam.

Always prefix automated performance logs with `AI_NOTE:` so they are easily greppable and can be stripped from release builds.

## 15. REQUIREMENT SUMMARY FORMAT (END OF AI TASK)
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
## 16. DOC AUTHORITY MATRIX
| Doc | Purpose | Modify When |
|-----|---------|-------------|
| CLAUDE.md | Operational AI protocol & invariants | New invariant / process change |
| AI_AGENT_GUIDE.md | Expanded examples & templates | New common pattern emerges |
| README.md | Human overview & milestones | Milestone / scope shift |
| ARCHIVE_STAGE1_TASK_DETAILS.md | Historical narrative | New stage archive only |
| INTERFACES.md | Interface contracts index | Append-only when adding or extending contracts |

## 17. DEPRECATED ARTIFACTS
- Legacy per-signal wrapper pattern (replaced by central validation + future generic emitter)
- ~~Hardcoded Species Map~~ (REMOVED: was `SPECIES_DATA` constant - now fully replaced by SpeciesSystem resources)

## 18. COMMIT MESSAGE GUIDELINE (FOR AI-GENERATED PATCHES)
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