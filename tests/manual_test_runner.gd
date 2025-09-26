extends Node

## Manual Test Runner
## A lightweight scene you can open in the editor to sanity‑check key systems
## without executing the full sequential suite. Add quick ad‑hoc probes here.

func _ready() -> void:
    print("=== Manual Test Runner ===")
    await get_tree().process_frame

    _probe_core_systems()
    _probe_creature_generation()
    _probe_age_progression()

    print("\nManual test probes complete. (Scene left running for further interactive inspection.)")

func _probe_core_systems() -> void:
    var required: Array[String] = ["stat", "tag", "age", "species", "save"]
    var missing: Array[String] = []
    for id in required:
        var sys = GameCore.get_system(id)
        if sys:
            print("  ✓ System '%s' available" % id)
        else:
            print("  ❌ System '%s' MISSING" % id)
            missing.append(id)
    if missing.is_empty():
        print("✅ Core system availability OK")
    else:
        print("⚠️  Missing systems: %s" % ", ".join(missing))

func _probe_creature_generation() -> void:
    var species_ids: Array[String] = ["scuttleguard", "stone_sentinel", "wind_dancer", "glow_grub"]
    var generated: Array[CreatureData] = []
    for s in species_ids:
        var c: CreatureData = CreatureGenerator.generate_creature_data(s)
        if c:
            generated.append(c)
            print("  ✓ Generated %s (%s) L%d STR%d" % [c.creature_name, c.species_id, c.lifespan_weeks, c.strength])
        else:
            print("  ❌ Failed to generate %s" % s)
    if generated.size() == species_ids.size():
        print("✅ Creature generation probe OK")
    else:
        print("⚠️  Some species failed to generate (%d/%d)" % [generated.size(), species_ids.size()])

func _probe_age_progression() -> void:
    var age_system = GameCore.get_system("age")
    if not age_system:
        print("❌ AgeSystem missing; skipping age probe")
        return
    var c: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
    if not c:
        print("❌ Could not generate creature for age probe")
        return
    var before = c.age_weeks
    age_system.age_creature_by_weeks(c, 10)
    var after = c.age_weeks
    if after == before + 10:
        print("✅ Age progression +10 weeks: %d -> %d" % [before, after])
    else:
        print("❌ Age progression failed: %d -> %d" % [before, after])