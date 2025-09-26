# Task 10: Species Resources System Implementation

## Prerequisites
- [ ] Tasks 1-9 completed and all tests passing
- [ ] Run preflight check: `godot --headless --scene tests/preflight_check.tscn` - MUST PASS
- [ ] Run integration test: `godot --headless --scene test_setup.tscn` - Should show 100% pass rate

## Task Overview
Implement the Species Resources System to replace the hardcoded species data in CreatureGenerator with a flexible, data-driven system. This system manages species templates, provides extensibility for future species additions, and supports the breeding system planned for Stage 8.

## Required Files to Create/Modify

### New Files to Create:
1. `scripts/systems/species_system.gd` - Main SpeciesSystem for template management
2. `scripts/resources/species_resource.gd` - Species resource definition
3. `data/species/` - Directory for species data files
4. `tests/individual/test_species.gd` - Individual test file
5. `tests/individual/test_species.tscn` - Test scene

### Files to Modify:
1. `scripts/core/game_core.gd` - Add SpeciesSystem to lazy loading (line ~50)
2. `scripts/core/signal_bus.gd` - Add species signals (after resource signals)
3. `scripts/generation/creature_generator.gd` - Update to use SpeciesSystem
4. `test_setup.gd` - Add `_test_species_system()` function
5. `tests/test_all.gd` - Add species test to TESTS_TO_RUN array

## Implementation Requirements

### Core Functionality:

#### 1. Species Resource Definition
```gdscript
class_name SpeciesResource
extends Resource

@export var species_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var category: String = "common"  # starter, common, uncommon, rare, legendary
@export var rarity: String = "common"
@export var base_price: int = 200

# Lifecycle properties
@export var lifespan_weeks: int = 520
@export var maturity_weeks: int = 104  # When breeding becomes possible
@export var peak_weeks: int = 260      # Peak performance period

# Physical characteristics
@export var size_category: String = "medium"  # small, medium, large, massive
@export var habitat_preference: String = "terrestrial"  # terrestrial, aquatic, aerial, underground

# Stat ranges for generation
@export var stat_ranges: Dictionary = {}

# Tag system integration
@export var guaranteed_tags: Array[String] = []
@export var optional_tags: Array[String] = []
@export var tag_probabilities: Dictionary = {}  # tag -> probability (0.0-1.0)

# Naming system
@export var name_pool: Array[String] = []
@export var name_prefix: String = ""
@export var name_suffix: String = ""

# Breeding compatibility (for Stage 8)
@export var breeding_group: String = "default"
@export var compatible_species: Array[String] = []
@export var hybrid_offspring: Array[String] = []

# Asset references
@export var sprite_path: String = ""
@export var icon_path: String = ""
@export var sound_effects: Dictionary = {}

# Gameplay mechanics
@export var feeding_preferences: Array[String] = []  # Preferred food types
@export var training_modifiers: Dictionary = {}     # Stat training efficiency
@export var special_abilities: Array[String] = []   # Unique abilities

func _init() -> void:
	_setup_default_stat_ranges()

func _setup_default_stat_ranges() -> void:
	"""Set up default stat ranges if not configured."""
	if stat_ranges.is_empty():
		stat_ranges = {
			"strength": {"min": 50, "max": 150},
			"constitution": {"min": 50, "max": 150},
			"dexterity": {"min": 50, "max": 150},
			"intelligence": {"min": 50, "max": 150},
			"wisdom": {"min": 50, "max": 150},
			"discipline": {"min": 50, "max": 150}
		}

func get_stat_range(stat_name: String) -> Dictionary:
	"""Get min/max range for a specific stat."""
	return stat_ranges.get(stat_name.to_lower(), {"min": 1, "max": 100})

func is_compatible_for_breeding(other_species_id: String) -> bool:
	"""Check if this species can breed with another."""
	return other_species_id in compatible_species

func get_random_name() -> String:
	"""Generate a random name for this species."""
	if name_pool.is_empty():
		return "Unnamed %s" % display_name

	var base_name: String = name_pool[randi() % name_pool.size()]
	return name_prefix + base_name + name_suffix

func validate() -> Dictionary:
	"""Validate species resource for completeness and correctness."""
	var errors: Array[String] = []

	if species_id.is_empty():
		errors.append("species_id cannot be empty")
	if display_name.is_empty():
		errors.append("display_name cannot be empty")
	if lifespan_weeks <= 0:
		errors.append("lifespan_weeks must be positive")
	if name_pool.is_empty():
		errors.append("name_pool cannot be empty")

	# Validate stat ranges
	for stat_name in stat_ranges:
		var range_data: Dictionary = stat_ranges[stat_name]
		if not range_data.has("min") or not range_data.has("max"):
			errors.append("Stat %s missing min/max values" % stat_name)
		elif range_data.min >= range_data.max:
			errors.append("Stat %s min >= max" % stat_name)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}
```

#### 2. Species System Manager
```gdscript
extends Node
class_name SpeciesSystem

# === CONSTANTS ===
const SPECIES_DATA_PATH: String = "res://data/species/"
const SPECIES_FILE_EXTENSION: String = ".tres"

# === SPECIES DATA ===
var species_registry: Dictionary = {}  # species_id -> SpeciesResource
var species_by_category: Dictionary = {}  # category -> Array[String]
var species_by_rarity: Dictionary = {}    # rarity -> Array[String]

# === CACHING ===
var _loading_cache: Dictionary = {}
var _validation_cache: Dictionary = {}

func _init() -> void:
	print("SpeciesSystem initialized")
	_load_all_species()

func _load_all_species() -> void:
	"""Load all species from the species data directory."""
	var dir: DirAccess = DirAccess.open(SPECIES_DATA_PATH)
	if not dir:
		push_warning("SpeciesSystem: Species data directory not found: %s" % SPECIES_DATA_PATH)
		_create_default_species()
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(SPECIES_FILE_EXTENSION):
			var species_path: String = SPECIES_DATA_PATH + file_name
			_load_species_from_file(species_path)
		file_name = dir.get_next()

	_organize_species_data()
	print("SpeciesSystem: Loaded %d species" % species_registry.size())

func _load_species_from_file(file_path: String) -> bool:
	"""Load a single species from file."""
	var species: SpeciesResource = load(file_path) as SpeciesResource
	if not species:
		push_error("SpeciesSystem: Failed to load species from %s" % file_path)
		return false

	# Validate species data
	var validation: Dictionary = species.validate()
	if not validation.valid:
		push_error("SpeciesSystem: Invalid species %s: %s" % [species.species_id, str(validation.errors)])
		return false

	# Register species
	species_registry[species.species_id] = species
	return true

func _organize_species_data() -> void:
	"""Organize species by categories and rarities for efficient lookup."""
	species_by_category.clear()
	species_by_rarity.clear()

	for species_id in species_registry:
		var species: SpeciesResource = species_registry[species_id]

		# Organize by category
		if not species_by_category.has(species.category):
			species_by_category[species.category] = []
		species_by_category[species.category].append(species_id)

		# Organize by rarity
		if not species_by_rarity.has(species.rarity):
			species_by_rarity[species.rarity] = []
		species_by_rarity[species.rarity].append(species_id)

func get_species(species_id: String) -> SpeciesResource:
	"""Get species resource by ID."""
	return species_registry.get(species_id, null)

func get_all_species() -> Array[String]:
	"""Get array of all species IDs."""
	var ids: Array[String] = []
	for id in species_registry.keys():
		ids.append(id)
	return ids

func get_species_by_category(category: String) -> Array[String]:
	"""Get species IDs by category."""
	return species_by_category.get(category, []).duplicate()

func get_species_by_rarity(rarity: String) -> Array[String]:
	"""Get species IDs by rarity."""
	return species_by_rarity.get(rarity, []).duplicate()

func is_valid_species(species_id: String) -> bool:
	"""Check if species ID exists."""
	return species_id in species_registry

func get_random_species(category: String = "", rarity: String = "") -> String:
	"""Get a random species ID, optionally filtered by category/rarity."""
	var candidates: Array[String] = []

	if not category.is_empty() and category in species_by_category:
		candidates = species_by_category[category]
	elif not rarity.is_empty() and rarity in species_by_rarity:
		candidates = species_by_rarity[rarity]
	else:
		candidates = get_all_species()

	if candidates.is_empty():
		return ""

	return candidates[randi() % candidates.size()]

# Integration with existing systems
func get_species_info(species_id: String) -> Dictionary:
	"""Get species information in the format expected by CreatureGenerator."""
	var species: SpeciesResource = get_species(species_id)
	if not species:
		return {}

	return {
		"display_name": species.display_name,
		"category": species.category,
		"rarity": species.rarity,
		"price": species.base_price,
		"lifespan_weeks": species.lifespan_weeks,
		"guaranteed_tags": species.guaranteed_tags.duplicate(),
		"optional_tags": species.optional_tags.duplicate(),
		"stat_ranges": species.stat_ranges.duplicate(),
		"name_pool": species.name_pool.duplicate()
	}

func _create_default_species() -> void:
	"""Create default species if no species files found."""
	push_warning("SpeciesSystem: No species files found, creating defaults")

	# This will migrate the existing hardcoded species from CreatureGenerator
	var default_species: Array[Dictionary] = [
		{
			"species_id": "scuttleguard",
			"display_name": "Scuttleguard",
			"category": "starter",
			"rarity": "common",
			"base_price": 200,
			"lifespan_weeks": 520,
			"guaranteed_tags": ["Small", "Territorial", "Dark Vision"],
			"optional_tags": ["Stealthy", "Enhanced Hearing", "Nocturnal"],
			"stat_ranges": {
				"strength": {"min": 70, "max": 130},
				"constitution": {"min": 80, "max": 140},
				"dexterity": {"min": 90, "max": 150},
				"intelligence": {"min": 40, "max": 70},
				"wisdom": {"min": 110, "max": 170},
				"discipline": {"min": 90, "max": 150}
			},
			"name_pool": ["Skitter", "Dash", "Scout", "Guard", "Patrol", "Sentry", "Swift", "Alert", "Watch", "Ward", "Shield", "Defender"]
		}
		# Add other default species...
	]

	for species_data in default_species:
		var species: SpeciesResource = SpeciesResource.new()
		_populate_species_from_dict(species, species_data)
		species_registry[species.species_id] = species
```

### GameCore Integration:
In `scripts/core/game_core.gd`, add to `_load_system()`:
```gdscript
"species":
	system = preload("res://scripts/systems/species_system.gd").new()
```

### SignalBus Integration:
Add to `scripts/core/signal_bus.gd`:
```gdscript
# Species system signals
signal species_loaded(species_id: String)
signal species_registered(species_id: String, category: String)
signal species_validation_failed(species_id: String, errors: Array[String])

func emit_species_loaded(species_id: String) -> void:
	if _validate_not_null(species_id, "species_loaded"):
		species_loaded.emit(species_id)
		if _debug_mode:
			print("SignalBus: Species loaded: %s" % species_id)

func emit_species_registered(species_id: String, category: String) -> void:
	if _validate_not_null(species_id, "species_registered") and _validate_not_null(category, "species_registered"):
		species_registered.emit(species_id, category)

func emit_species_validation_failed(species_id: String, errors: Array[String]) -> void:
	if _validate_not_null(species_id, "species_validation_failed"):
		species_validation_failed.emit(species_id, errors)
		if _debug_mode:
			print("SignalBus: Species validation failed: %s - %s" % [species_id, str(errors)])
```

### CreatureGenerator Integration:
Update `scripts/generation/creature_generator.gd`:
```gdscript
# Replace SPECIES_DATA constant usage with SpeciesSystem calls
static func get_species_info(species_id: String) -> Dictionary:
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.get_species_info(species_id)

	# Fallback to hardcoded data if SpeciesSystem not available
	return SPECIES_DATA.get(species_id, {})

static func is_valid_species(species_id: String) -> bool:
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.is_valid_species(species_id)

	return species_id in SPECIES_DATA

static func get_all_species() -> Array[String]:
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.get_all_species()

	var ids: Array[String] = []
	for id in SPECIES_DATA.keys():
		ids.append(id)
	return ids
```

## Testing Requirements

### Individual Test (`tests/individual/test_species.gd`):
```gdscript
extends Node

func _ready() -> void:
	print("=== Species System Test ===")

	var species_system = GameCore.get_system("species")
	assert(species_system != null, "Failed to load SpeciesSystem")

	# Test 1: Basic species loading
	var all_species: Array[String] = species_system.get_all_species()
	assert(all_species.size() >= 4, "Should have at least 4 species")
	print("✅ Species loading working (%d species)" % all_species.size())

	# Test 2: Species validation
	for species_id in all_species:
		assert(species_system.is_valid_species(species_id), "Species %s should be valid" % species_id)
	print("✅ Species validation working")

	# Test 3: Species data retrieval
	var scuttleguard_info: Dictionary = species_system.get_species_info("scuttleguard")
	assert(not scuttleguard_info.is_empty(), "Scuttleguard info should not be empty")
	assert(scuttleguard_info.has("stat_ranges"), "Should have stat_ranges")
	print("✅ Species data retrieval working")

	# Test 4: Category organization
	var starter_species: Array[String] = species_system.get_species_by_category("starter")
	assert(starter_species.size() > 0, "Should have starter species")
	print("✅ Category organization working")

	# Test 5: Random species selection
	var random_species: String = species_system.get_random_species()
	assert(not random_species.is_empty(), "Random species should not be empty")
	assert(species_system.is_valid_species(random_species), "Random species should be valid")
	print("✅ Random species selection working")

	# Test 6: CreatureGenerator integration
	var creature_data: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")
	assert(creature_data != null, "Should generate creature data")
	assert(creature_data.species_id == "scuttleguard", "Should have correct species ID")
	print("✅ CreatureGenerator integration working")

	print("✅ Species System test complete!")
	get_tree().quit(0)
```

## Performance Targets
- [ ] System initialization: <50ms with 10+ species
- [ ] Species lookup: <1ms per query
- [ ] Category filtering: <5ms for 50+ species
- [ ] Integration with CreatureGenerator: No performance regression

## Migration Strategy
1. **Phase 1**: Create SpeciesSystem alongside existing hardcoded data
2. **Phase 2**: Update CreatureGenerator to use SpeciesSystem with fallback
3. **Phase 3**: Create .tres files for existing species
4. **Phase 4**: Remove hardcoded SPECIES_DATA from CreatureGenerator
5. **Phase 5**: Add new species through resource files only

## Success Criteria
- [ ] SpeciesSystem loads and manages species templates
- [ ] CreatureGenerator integrates seamlessly with SpeciesSystem
- [ ] Individual species test passes
- [ ] Integration test passes with no regressions
- [ ] No parse errors or warnings
- [ ] Performance targets met
- [ ] Resource-based species data structure ready for modding

## Future Extensibility
This system prepares for:
- **Stage 8 Breeding**: Compatible species lists and hybrid offspring
- **Modding Support**: Easy addition of new species via .tres files
- **Balance Updates**: Stat range adjustments without code changes
- **Asset Pipeline**: Sprite and sound effect management
- **Advanced Features**: Special abilities, training modifiers, feeding preferences

## Example Usage After Implementation
```gdscript
# Get the species system
var species = GameCore.get_system("species")

# Query species data
var all_species: Array[String] = species.get_all_species()
var starters: Array[String] = species.get_species_by_category("starter")
var rare_species: Array[String] = species.get_species_by_rarity("rare")

# Generate creatures using the new system
var creature: CreatureData = CreatureGenerator.generate_creature_data("scuttleguard")

# Get detailed species information
var species_info: Dictionary = species.get_species_info("wind_dancer")
print("Species: %s, Price: %d, Lifespan: %d weeks" % [
	species_info.display_name,
	species_info.price,
	species_info.lifespan_weeks
])
```

## Notes
- SpeciesSystem provides backward compatibility with existing CreatureGenerator
- Resource-based approach allows for easy content updates and modding
- Breeding compatibility data is included for future Stage 8 implementation
- Asset pipeline foundation supports future art and audio integration
- Category and rarity systems enable sophisticated creature collection mechanics