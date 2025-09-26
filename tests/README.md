# Test Suite Documentation

This directory contains individual test scripts for each Stage 1 system, allowing targeted testing and debugging.

## 🎯 Quick Start

### Run All Tests
```bash
# Sequential execution with summary
godot --headless --scene res://tests/test_all.tscn

# Show available tests
godot --headless --scene res://tests/test_runner.tscn

# Original comprehensive test (may timeout)
godot --headless --scene res://tests/test_setup.tscn
```

### Run Individual Tests
```bash
# Core systems
godot --headless --scene res://tests/individual/test_signalbus.tscn
godot --headless --scene res://tests/individual/test_creature.tscn
godot --headless --scene res://tests/individual/test_stats.tscn

# Feature systems
godot --headless --scene res://tests/individual/test_tags.tscn
godot --headless --scene res://tests/individual/test_generator.tscn
godot --headless --scene res://tests/individual/test_age.tscn

# Integration systems
godot --headless --scene res://tests/individual/test_save.tscn
godot --headless --scene res://tests/individual/test_collection.tscn
```

## 📋 Test Coverage

| Test | System | Coverage | Duration |
|------|--------|----------|----------|
| `test_signalbus` | SignalBus | Signal existence, connection safety, debug mode | ~1s |
| `test_creature` | CreatureData/Entity | Properties, serialization, age calculation | ~1s |
| `test_stats` | StatSystem | Validation, clamping, breakdown, caps | ~1s |
| `test_tags` | TagSystem | Validation, combinations, filtering, requirements | ~1s |
| `test_generator` | CreatureGenerator | All species, algorithms, performance, population | ~2s |
| `test_age` | AgeSystem | Aging, categories, transitions, batch operations | ~1s |
| `test_save` | SaveSystem | Game state, collections, auto-save, validation | ~3s |
| `test_collection` | PlayerCollection | Active/stable management, search, signals | ~2s |

**Total:** ~12s for all individual tests

## 🧪 Test Details

### Core Systems Tests

**SignalBus Test** (`test_signalbus`)
- ✅ Signal accessibility through GameCore
- ✅ All expected signals exist (17 signals)
- ✅ Safe signal connection/disconnection
- ✅ Signal emission and handling
- ✅ Debug mode toggling

**Creature Test** (`test_creature`)
- ✅ CreatureData creation and properties
- ✅ Stat clamping (1-1000 range)
- ✅ Stat accessors (`get_stat()`, `set_stat()`)
- ✅ Age category calculation
- ✅ Serialization (`to_dict()`, `from_dict()`)
- ✅ CreatureEntity data assignment

**StatSystem Test** (`test_stats`)
- ✅ Stat validation for valid/invalid values
- ✅ Stat clamping for out-of-range values
- ✅ Stat breakdown (tier classification)
- ✅ Stat caps (min=1, max=1000)

### Feature Systems Tests

**TagSystem Test** (`test_tags`)
- ✅ Valid/invalid tag recognition
- ✅ Tag combination validation
- ✅ Mutual exclusion enforcement
- ✅ Tag requirements checking
- ✅ Creature filtering by tags

**CreatureGenerator Test** (`test_generator`)
- ✅ All 4 species generation (scuttleguard, stone_sentinel, wind_dancer, glow_grub)
- ✅ Generation algorithms (UNIFORM, GAUSSIAN, HIGH_ROLL, LOW_ROLL)
- ✅ Performance target (<100ms for 100 creatures)
- ✅ Population generation with species distribution

**AgeSystem Test** (`test_age`)
- ✅ Age category calculation (Baby, Juvenile, Adult, Elder, Ancient)
- ✅ Age modifier calculation (0.6, 0.8, 1.0, 0.8, 0.6)
- ✅ Individual creature aging
- ✅ Category transitions
- ✅ Batch aging operations
- ✅ Age distribution analysis
- ✅ Expiration detection

### Integration Systems Tests

**SaveSystem Test** (`test_save`)
- ✅ Game state save/load
- ✅ Creature collection persistence
- ✅ Individual creature save/load
- ✅ Performance targets (<200ms)
- ✅ Auto-save functionality
- ✅ Save validation and backup
- ✅ Data integrity verification

**PlayerCollection Test** (`test_collection`)
- ✅ Active roster (6 creature limit)
- ✅ Stable collection (unlimited)
- ✅ Movement operations (active ↔ stable)
- ✅ Search and filtering
- ✅ Quest availability checking
- ✅ Statistics and analytics
- ✅ Signal integration (5 signals)
- ✅ Quiet mode for performance

## 🐛 Debugging Workflow

### When a System Fails
1. **Run individual test** to isolate the issue
2. **Check console output** for specific error messages
3. **Reference API_REFERENCE.md** for correct method calls
4. **Fix the issue** in the system code
5. **Re-run the individual test** to verify the fix
6. **Run full test suite** to ensure no regression

### Common Issues
- **Method name errors**: Check API_REFERENCE.md for correct names
- **Property name errors**: Use `id` not `creature_id`, `species_id` not `species`
- **Array type errors**: Use explicit `Array[String]` typing
- **System loading errors**: Ensure `GameCore.get_system()` is called

## 🎯 Performance Targets

| Operation | Target | Measured |
|-----------|--------|----------|
| 100 creatures generation | <100ms | ~30-50ms |
| 100 creatures save/load | <200ms | ~140-200ms |
| Tag filtering (100 creatures) | <10ms | ~0-5ms |
| Collection stats calculation | <5ms | ~1-3ms |

## 📁 File Structure

```
tests/
├── README.md                    # This file
├── test_runner.gd/.tscn        # Shows available tests
├── test_all.gd/.tscn           # Runs all tests sequentially
└── individual/                 # Individual test files
    ├── test_signalbus.gd/.tscn
    ├── test_creature.gd/.tscn
    ├── test_stats.gd/.tscn
    ├── test_tags.gd/.tscn
    ├── test_generator.gd/.tscn
    ├── test_age.gd/.tscn
    ├── test_save.gd/.tscn
    └── test_collection.gd/.tscn
```

## 🚀 Benefits of Individual Tests

1. **Faster Debugging**: Test only the system you're working on
2. **Clearer Output**: No mixed output from multiple systems
3. **Targeted Development**: Focus on specific functionality
4. **Regression Testing**: Quickly verify fixes don't break anything
5. **CI/CD Ready**: Each test can be run independently in pipelines
6. **Documentation**: Each test serves as usage examples

## 🔧 Adding New Tests

When adding new systems (Tasks 9-11), create new individual tests:

1. **Create test script**: `tests/individual/test_newsystem.gd`
2. **Create test scene**: `tests/individual/test_newsystem.tscn`
3. **Add to test runner**: Update `INDIVIDUAL_TESTS` in `test_runner.gd`
4. **Add to sequential runner**: Update `TESTS_TO_RUN` in `test_all.gd`
5. **Update this README**: Add test coverage documentation

**Individual tests make development much more efficient!** 🎯