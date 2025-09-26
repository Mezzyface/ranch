Legacy Test Artifacts
======================

This folder contains large or superseded test harnesses retained temporarily
for reference while the lean per-system suite under `tests/individual/` is
the authoritative source of validation.

Will be removed after confirmation of coverage stability.

Contents to prune soon:
- test_godot_console.gd / test_console_scene.tscn (monolithic runner)
- test_setup.gd / test_setup.tscn (stage 1 mega integration)
- standalone editor scripts (verify_creature_generator, generator standalone)
- deprecated lifespan test (logic migrated)

Do not add new tests here—extend individual or integration suites instead.
