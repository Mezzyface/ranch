# Stage 2 Preflight Checklist

## Before Starting Stage 2 Implementation

### 🔍 Prerequisites Verification

#### Stage 1 Completion Status
- [ ] **Task 1**: Project Setup & SignalBus ✅ COMPLETE
- [ ] **Task 2**: Creature Class ✅ COMPLETE
- [ ] **Task 3**: Stat System ✅ COMPLETE
- [ ] **Task 4**: Tag System ✅ COMPLETE
- [ ] **Task 5**: Creature Generation ✅ COMPLETE
- [ ] **Task 6**: Age System ✅ COMPLETE
- [ ] **Task 7**: Save/Load System ✅ COMPLETE
- [ ] **Task 8**: Player Collection ✅ COMPLETE
- [ ] **Task 9**: Resource Tracking ⚠️ MUST BE COMPLETE
- [ ] **Task 10**: Species Resources (optional for Stage 2)
- [ ] **Task 11**: Global Enums (optional for Stage 2)

#### Test Suite Status
```bash
# Run this command and verify all pass:
godot --headless --scene tests/test_all.tscn

# Expected output:
# ✓ SignalBus tests: X/X passed
# ✓ Creature tests: X/X passed
# ✓ Stats tests: X/X passed
# ✓ Tags tests: X/X passed
# ✓ Generator tests: X/X passed
# ✓ Age tests: X/X passed
# ✓ Save tests: X/X passed
# ✓ Collection tests: X/X passed
```

#### Performance Baseline
```bash
# Run performance check:
godot --headless --scene tests/stage_2_preflight.tscn

# Required benchmarks:
# - 100 creature generation: <100ms ✅
# - 100 creature save: <200ms ✅
# - Collection operations: <100ms ✅
```

### 📁 File Structure Preparation

#### Create Stage 2 Directories
```bash
# Create required directories
mkdir -p scripts/ui
mkdir -p scripts/ui/components
mkdir -p scripts/ui/panels
mkdir -p scenes/ui
mkdir -p scenes/ui/components
mkdir -p scenes/ui/panels
mkdir -p scenes/ui/dialogs
mkdir -p resources/themes
mkdir -p resources/fonts
mkdir -p tests/stage_2
```

#### Verify Documentation
- [ ] Stage 2 overview exists: `docs/implementation/stages/stage_2/00_stage_2_overview.md`
- [ ] Task templates exist for all 10 tasks
- [ ] API contracts documented: `API_CONTRACTS.md`
- [ ] Agent execution guide available: `AGENT_EXECUTION_GUIDE.md`

### 🔧 Development Environment

#### Godot Configuration
- [ ] Godot 4.5 installed and working
- [ ] Project opens without errors
- [ ] No compilation errors in console
- [ ] Debug build configuration active

#### Git Setup
```bash
# Create Stage 2 branch
git checkout -b stage-2-implementation

# Ensure clean working tree
git status  # Should show no uncommitted changes
```

### ⚠️ Critical Warnings to Address

#### Before Starting TimeSystem (Task 1)
- [ ] Confirm SignalBus has capacity for new signals
- [ ] Review GameCore lazy loading pattern
- [ ] Understand save system integration points

#### Before Starting UI Framework (Task 2)
- [ ] Plan scene hierarchy structure
- [ ] Decide on theme color scheme
- [ ] Prepare font resources if custom

#### Before Starting StaminaSystem (Task 5)
- [ ] Ensure CreatureData can store stamina values
- [ ] Plan stamina balance (costs/recovery rates)

#### Before Starting FoodSystem (Task 6)
- [ ] ⚠️ **ResourceTracking MUST be complete**
- [ ] Plan food types and effects
- [ ] Design inventory data structure

### 📋 Task Dependencies Map

```
Independent Start:
├── Task 1: TimeSystem (can start immediately)
└── Task 2: UI Framework (can start immediately)

Dependent on Task 1:
├── Task 5: StaminaSystem
├── Task 7: Time Controls UI
└── Task 9: Weekly Update System

Dependent on Task 2:
├── Task 3: Creature Collection UI
├── Task 4: Creature Detail Panel
└── Task 8: Resource Display UI

Dependent on Stage 1 Task 9:
└── Task 6: FoodSystem

Final Integration:
└── Task 10: Integration Testing (requires all tasks)
```

### 🚀 Quick Start Commands

```bash
# 1. Verify Stage 1 completion
godot --headless --scene tests/test_all.tscn

# 2. Run preflight check
godot --headless --scene tests/stage_2_preflight.tscn

# 3. Create Stage 2 branch
git checkout -b stage-2-implementation

# 4. Start first task (TimeSystem)
# Open docs/implementation/stages/stage_2/01_time_system.md
# Follow implementation guide exactly
```

### ✅ Final Verification Before Starting

Run this checklist one more time:
1. [ ] All Stage 1 tests pass
2. [ ] No critical errors in console
3. [ ] Documentation reviewed and understood
4. [ ] Git branch created for Stage 2
5. [ ] Development environment ready

### 🎯 Success Criteria for Stage 2

By the end of Stage 2, you should have:
- [ ] Weekly time progression working
- [ ] Basic UI showing creatures and stats
- [ ] Stamina system depleting/recovering
- [ ] Food consumption mechanics
- [ ] All UI components responsive
- [ ] 52-week test passing
- [ ] Performance targets met (60 FPS)

### 📝 Notes for AI Agents

**IMPORTANT**:
- Follow Stage 1 patterns EXACTLY
- Test after EVERY file creation
- Use SignalBus for ALL signals
- Keep data and behavior separated
- Document all public methods
- Include debug output during development
- Commit working code frequently

**DO NOT**:
- Skip validation steps
- Create new patterns different from Stage 1
- Let Resources emit signals
- Ignore performance targets
- Proceed if tests are failing

### 🔗 Quick Links

- [Stage 2 Overview](00_stage_2_overview.md)
- [Implementation Guide](STAGE_2_IMPLEMENTATION_GUIDE.md)
- [API Contracts](API_CONTRACTS.md)
- [Agent Execution Guide](AGENT_EXECUTION_GUIDE.md)
- [Stage 1 Lessons Learned](../../../CLAUDE.md)

---

**Ready to Start?** Begin with Task 1 (TimeSystem) or Task 2 (UI Framework) as they have no dependencies!