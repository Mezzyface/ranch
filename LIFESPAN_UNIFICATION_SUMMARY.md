# Lifespan Property Unification - Summary

## ✅ **Unified Property Naming**

Changed both CreatureData and species data to consistently use `lifespan_weeks` for clarity and consistency.

### **Files Modified**:

#### 1. **CreatureData** (`scripts/data/creature_data.gd`)
```gdscript
# ❌ Before:
@export_range(100, 1000) var lifespan: int = 520

# ✅ After:
@export_range(100, 1000) var lifespan_weeks: int = 520
```

**Updated Methods**:
- `get_age_category()` - Now uses `lifespan_weeks` for calculations
- `to_dict()` - Serializes as `"lifespan_weeks"`
- `from_dict()` - Deserializes from `"lifespan_weeks"`

#### 2. **CreatureGenerator** (`scripts/generation/creature_generator.gd`)
```gdscript
# ✅ Consistent assignment:
data.lifespan_weeks = species.lifespan_weeks
```

#### 3. **Test Files Updated**:
- `test_lifespan_fix.gd` - Updated property references
- `VALIDATION_GUIDE.md` - Updated test examples

### **Benefits of Unification**:

1. **Clarity**: `lifespan_weeks` is explicit about the unit of measurement
2. **Consistency**: Both species data and creature data use identical property names
3. **Maintainability**: No confusion between `lifespan` vs `lifespan_weeks`
4. **Future-proofing**: When SpeciesSystem is implemented, naming will be consistent

### **Species Lifespan Values**:
- **Scuttleguard**: 520 weeks (~10 years)
- **Stone Sentinel**: 780 weeks (~15 years)
- **Wind Dancer**: 390 weeks (~7.5 years)
- **Glow Grub**: 260 weeks (~5 years)

### **Age Category Calculation**:
All age calculations now consistently use `lifespan_weeks`:
```gdscript
func get_age_category() -> int:
    var life_percentage: float = (age_weeks / float(lifespan_weeks)) * 100
    # Categories: BABY (0-10%), JUVENILE (10-25%), ADULT (25-75%), ELDER (75-90%), ANCIENT (90%+)
```

### **Serialization Compatibility**:
Save files now use consistent property naming:
```json
{
    "creature_name": "Scout 42",
    "age_weeks": 0,
    "lifespan_weeks": 520,
    ...
}
```

## 🧪 **Testing the Unification**:

Run this test to verify the changes work correctly:

```gdscript
extends Node

func _ready():
    var creature = CreatureGenerator.generate_creature_data("scuttleguard")
    print("Creature: %s" % creature.creature_name)
    print("Lifespan: %d weeks" % creature.lifespan_weeks)  # Should be 520
    print("Age: %d weeks" % creature.age_weeks)           # Should be 0

    # Test age category (should be BABY = 0)
    print("Age category: %d" % creature.get_age_category())  # Should be 0
    print("Age modifier: %.1f" % creature.get_age_modifier()) # Should be 0.6
```

## ✅ **Migration Complete**

The lifespan property is now unified across the entire codebase using `lifespan_weeks` for maximum clarity and consistency. This change improves code maintainability and reduces potential confusion for future development.