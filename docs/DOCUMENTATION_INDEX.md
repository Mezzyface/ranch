# 📚 Documentation Index

This index provides a complete overview of all documentation in the repository, organized by purpose and audience.

## 🎯 Essential Documentation

### For AI Agents & Automation
- **[CLAUDE.md](/CLAUDE.md)** - Primary machine-actionable guidance and invariants
- **[INTERFACES.md](/INTERFACES.md)** - Formal interface contracts (append-only)
- **[AI Agent Guide](development/AI_AGENT_GUIDE.md)** - Expanded examples & templates

### For Developers
- **[Comprehensive API Guide](development/COMPREHENSIVE_API_GUIDE.md)** - Complete API reference & usage patterns ⭐
- **[Systems Integration Guide](development/SYSTEMS_INTEGRATION_GUIDE.md)** - How systems work together
- **[Age System Guide](development/age_system_guide.md)** - Detailed age system documentation

### For Testing
- **[Test README](../tests/README.md)** - Test infrastructure overview
- **[Validation Guide](../tests/validation_guide.md)** - CreatureGenerator validation steps
- **[Test Quiet Mode](development/TEST_QUIET_MODE.md)** - Testing documentation

---

## 📂 Documentation Structure

### `/docs/development/` - Developer Resources
- `COMPREHENSIVE_API_GUIDE.md` - Merged API reference, usage patterns, quick solutions
- `SYSTEMS_INTEGRATION_GUIDE.md` - System dependencies and workflows
- `AI_AGENT_GUIDE.md` - AI-specific implementation guidance
- `age_system_guide.md` - Age system deep dive
- `TEST_QUIET_MODE.md` - Testing patterns

### `/docs/design/` - Game Design
- **Systems**: `systems/` - Core system designs (creature, species, stats, tags, time)
- **Features**: `features/` - Feature specifications (breeding, competitions, food, quest, shop, training)
- **Content**: `content/` - Quest and content design
- **Art**: `ART_ASSET_SPECIFICATION.md`, `ASSET_MAPPING_TINY_SWORDS.md`
- **UX**: `UX_DESIGN_SPECIFICATION.md`

### `/docs/implementation/` - Technical Implementation
- `implementation_plan.md` - Multi-stage development plan
- `architecture_verification.md` - Architecture best practices verification
- `IMPROVED_ARCHITECTURE.md` - Improved Godot 4.5 patterns
- `ARCHITECTURE_MIGRATION.md` - Migration from old patterns
- `enum.md` - Global enumeration reference
- **Stage 2**: `stages/stage_2/` - Current development stage docs

### `/docs/project/` - Project Management
- `game.md` - Core gameplay loop
- `mvp_summary.md` - MVP feature set

### `/tasks/` - Development Tasks
- `SYSTEM_ARCHITECTURE.md` - Architecture patterns guide
- `TASK_PROMPT_TEMPLATE.md` - Template for new tasks

---

## 🗺️ Quick Navigation

### By Topic
**Architecture**: [Systems Integration](development/SYSTEMS_INTEGRATION_GUIDE.md) → [Architecture Verification](implementation/architecture_verification.md) → [System Architecture](../tasks/SYSTEM_ARCHITECTURE.md)

**API & Usage**: [Comprehensive API Guide](development/COMPREHENSIVE_API_GUIDE.md) → [INTERFACES.md](/INTERFACES.md)

**Implementation**: [Implementation Plan](implementation/implementation_plan.md) → [Stage 2 Guide](implementation/stages/stage_2/STAGE_2_IMPLEMENTATION_GUIDE.md)

**Testing**: [Test README](../tests/README.md) → [Validation Guide](../tests/validation_guide.md)

---

## 📝 Documentation Principles

1. **CLAUDE.md** - Operational protocol, always authoritative
2. **INTERFACES.md** - Append-only contracts, never break compatibility
3. **Comprehensive API Guide** - Single source for all API patterns
4. **No Duplication** - Each concept documented in exactly one place
5. **Clear Hierarchy** - Essential → Development → Implementation → Design

---

## 🔄 Recent Consolidation (2025-09-26)

### Merged Files
- `USAGE.md`, `QUICK_REFERENCE.md`, `API_REFERENCE.md`, `QUICK_START_GUIDE.md` → **[Comprehensive API Guide](development/COMPREHENSIVE_API_GUIDE.md)**

### Relocated Files
- `AGESYSTEM_USAGE_GUIDE.md` → `docs/development/age_system_guide.md`
- `VALIDATION_GUIDE.md` → `tests/validation_guide.md`
- `ARCHITECTURE_VERIFICATION_REPORT.md` → `docs/implementation/architecture_verification.md`

### Removed (Redundant)
- Root-level `USAGE.md` and `QUICK_REFERENCE.md`
- Old `API_REFERENCE.md` and `QUICK_START_GUIDE.md`
- Deleted `tasks/STAGE_1_COMPLETION_SUMMARY.md`

---

*This index is the authoritative guide to documentation organization. Update when adding new documentation.*