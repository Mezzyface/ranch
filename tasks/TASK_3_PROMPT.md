# 🎯 Stage 1 Task 3: Stat System Implementation

You are implementing Stage 1 Task 3 of a creature collection game in Godot 4.5. Follow the improved architecture strictly.

## 📋 Current Project Status:
- ✅ Task 1 COMPLETE: GameCore autoload with enhanced SignalBus
- ✅ Task 2 COMPLETE: CreatureData/CreatureEntity separation with stat foundation (1-1000 clamping)
- 🚀 Task 3 NEXT: Advanced Stat System with modifiers, calculations, and utilities
- Architecture: MVC pattern, centralized SignalBus, pure data Resources

## 🎯 Implementation Task:
Implement Task 3 from `docs/implementation/stages/stage_1/03_stat_system.md`

## 🔧 Key Requirements:

### 1. **StatSystem Utility Class**
Location: `scripts/systems/stat_system.gd`
- Singleton pattern loaded by GameCore (lazy-loaded)
- Stat calculation utilities
- Modifier system (buffs/debuffs)
- Stat validation and boundaries
- Performance calculations

### 2. **Stat Modifiers**
- Temporary modifiers (buffs/debuffs)
- Permanent modifiers (equipment, traits)
- Stacking rules (additive vs multiplicative)
- Duration tracking for temporary effects

### 3. **Calculation Methods**
- `calculate_modified_stat(base_value, modifiers)` - Apply all modifiers
- `get_stat_cap(stat_name)` - Return max value for stat
- `validate_stat_value(stat_name, value)` - Ensure within bounds
- `calculate_stat_difference(stat1, stat2)` - Compare stats
- `get_stat_tier(value)` - Return tier (weak/average/strong/exceptional)

### 4. **Integration with CreatureEntity**
- Extend CreatureEntity to use StatSystem
- Track active modifiers per creature
- Emit signals when modifiers change
- Calculate effective stats with all modifiers

## 📚 Apply Lessons Learned:
- Use lazy loading pattern (loaded by GameCore when needed)
- Maintain separation - StatSystem is utility, not data storage
- Use explicit typing to avoid Variant warnings
- Stats always respect 1-1000 boundaries
- Test calculations with edge cases

## 🧪 Testing Requirements:
- Update test_setup.gd to test StatSystem
- Test modifier stacking (additive and multiplicative)
- Verify stat caps are enforced
- Test tier calculations
- Ensure CreatureEntity integration works
- Test edge cases (0, 1, 1000, negative modifiers)

## 📁 Expected File Locations:
- `scripts/systems/stat_system.gd` - Main StatSystem utility (update existing placeholder)
- Update `scripts/entities/creature_entity.gd` - Add modifier tracking
- Update `scripts/core/game_core.gd` - Add StatSystem to lazy loading if needed
- Update `test_setup.gd` - Add StatSystem tests

## 🎯 Success Criteria:
- StatSystem provides consistent calculations
- Modifiers stack correctly (additive first, then multiplicative)
- All stats respect 1-1000 boundaries after modifiers
- Temporary effects can expire
- Stat tiers provide meaningful categories
- Integration with CreatureEntity is seamless
- Tests demonstrate all functionality

## ⚠️ Critical Architecture Rules:
1. StatSystem is a utility class, NOT a data store
2. CreatureData still holds base stats
3. CreatureEntity manages active modifiers
4. All calculations go through StatSystem
5. Maintain 1-1000 boundaries AFTER modifiers

## 📋 Implementation Checklist:
- [ ] Read Task 3 documentation
- [ ] Create/Update StatSystem utility class
- [ ] Implement modifier types (temporary/permanent)
- [ ] Add calculation methods
- [ ] Implement tier system
- [ ] Integrate with CreatureEntity
- [ ] Add modifier tracking to creatures
- [ ] Update tests with StatSystem validation
- [ ] Verify all stats stay within bounds
- [ ] Test modifier stacking rules

## 💡 Example Stat Calculation:
```
Base STR: 500
Equipment Bonus: +50 (additive)
Buff: +20% (multiplicative)
Debuff: -10% (multiplicative)

Calculation:
1. Apply additive: 500 + 50 = 550
2. Apply multiplicative: 550 * 1.20 * 0.90 = 594
3. Clamp to bounds: min(594, 1000) = 594
Final: 594
```

## 🏗️ Suggested Implementation Order:
1. Create basic StatSystem class structure
2. Implement core calculation methods
3. Add modifier types and tracking
4. Implement stacking rules
5. Add tier system
6. Integrate with CreatureEntity
7. Update tests
8. Validate edge cases

Follow `docs/implementation/stages/stage_1/03_stat_system.md` for detailed specifications. Build upon the solid CreatureData/CreatureEntity foundation from Task 2! 🚀