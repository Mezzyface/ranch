# CreatureGenerator - Utility class for generating creatures with varied stats and tags
# Static utility class (RefCounted) - NOT a GameCore subsystem
# Generates CreatureData by default (lightweight), CreatureEntity only when behavior needed
class_name CreatureGenerator
extends RefCounted

# Generation algorithms
enum GenerationType {
	UNIFORM,     # Equal probability across stat range
	GAUSSIAN,    # Bell curve distribution (Box-Muller transform)
	HIGH_ROLL,   # Max of two rolls (premium eggs)
	LOW_ROLL     # Min of two rolls (discount eggs)
}

# Species data structure for Stage 1 (hardcoded, will migrate to SpeciesSystem in Task 10)
const SPECIES_DATA := {
	"scuttleguard": {
		"display_name": "Scuttleguard",
		"category": "starter",
		"rarity": "common",
		"price": 200,
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
		"name_pool": [
			"Skitter", "Dash", "Scout", "Guard", "Patrol", "Sentry",
			"Swift", "Alert", "Watch", "Ward", "Shield", "Defender"
		]
	},

	"stone_sentinel": {
		"display_name": "Stone Sentinel",
		"category": "premium",
		"rarity": "uncommon",
		"price": 800,
		"lifespan_weeks": 780,
		"guaranteed_tags": ["Medium", "Camouflage", "Natural Armor", "Territorial"],
		"optional_tags": ["Problem Solver", "Constructor", "Enhanced Hearing"],
		"stat_ranges": {
			"strength": {"min": 130, "max": 190},
			"constitution": {"min": 190, "max": 280},
			"dexterity": {"min": 50, "max": 110},
			"intelligence": {"min": 50, "max": 90},
			"wisdom": {"min": 130, "max": 220},
			"discipline": {"min": 160, "max": 250}
		},
		"name_pool": [
			"Boulder", "Granite", "Basalt", "Flint", "Slate", "Marble",
			"Fortress", "Bastion", "Bulwark", "Aegis", "Rampart", "Citadel"
		]
	},

	"wind_dancer": {
		"display_name": "Wind Dancer",
		"category": "flying",
		"rarity": "common",
		"price": 500,
		"lifespan_weeks": 390,
		"guaranteed_tags": ["Small", "Winged", "Flies", "Enhanced Hearing"],
		"optional_tags": ["Messenger", "Stealthy", "Diurnal"],
		"stat_ranges": {
			"strength": {"min": 70, "max": 110},
			"constitution": {"min": 80, "max": 130},
			"dexterity": {"min": 190, "max": 280},
			"intelligence": {"min": 90, "max": 140},
			"wisdom": {"min": 150, "max": 250},
			"discipline": {"min": 90, "max": 150}
		},
		"name_pool": [
			"Zephyr", "Gale", "Breeze", "Whirl", "Drift", "Soar",
			"Glide", "Flutter", "Swift", "Aerial", "Nimble", "Grace"
		]
	},

	"glow_grub": {
		"display_name": "Glow Grub",
		"category": "utility",
		"rarity": "common",
		"price": 400,
		"lifespan_weeks": 260,
		"guaranteed_tags": ["Small", "Bioluminescent", "Cleanser", "Nocturnal"],
		"optional_tags": ["Problem Solver", "Stealthy", "Enhanced Hearing"],
		"stat_ranges": {
			"strength": {"min": 50, "max": 90},
			"constitution": {"min": 90, "max": 150},
			"dexterity": {"min": 70, "max": 130},
			"intelligence": {"min": 70, "max": 110},
			"wisdom": {"min": 130, "max": 190},
			"discipline": {"min": 110, "max": 170}
		},
		"name_pool": [
			"Glow", "Shine", "Gleam", "Radiance", "Beacon", "Luminous",
			"Spark", "Flicker", "Pulse", "Bright", "Shimmer", "Light"
		]
	}
}

# Optional tag assignment probability
const OPTIONAL_TAG_CHANCE: float = 0.25

# Performance optimization: Cache species keys
static var _cached_species_keys: Array[String] = []

# === GENERATION STATISTICS ===
static var _generation_stats: Dictionary = {}

# === CORE GENERATION METHODS ===

static func generate_creature_data(species_id: String, generation_type: GenerationType = GenerationType.UNIFORM, creature_name: String = "") -> CreatureData:
	"""
	Generate lightweight CreatureData (default approach for save/serialization efficiency).
	Use this for most generation needs unless behavior is immediately required.
	"""
	if not SPECIES_DATA.has(species_id):
		push_error("CreatureGenerator: Unknown species_id '%s'" % species_id)
		return null

	var species: Dictionary = SPECIES_DATA[species_id]
	var data: CreatureData = CreatureData.new()

	# Basic creature info
	data.species_id = species_id
	data.creature_name = creature_name if creature_name != "" else _generate_random_name(species_id)
	data.id = _generate_unique_id()

	# Generate stats using specified algorithm
	_generate_stats(data, species, generation_type)

	# Set lifespan and default age (baby)
	data.lifespan_weeks = species.lifespan_weeks
	data.age_weeks = 0  # Start as baby

	# Initialize stamina to max (based on constitution)
	data.stamina_max = _calculate_max_stamina(data.constitution)
	data.stamina_current = data.stamina_max

	# Assign tags
	_assign_tags(data, species)

	# Track generation statistics
	_track_generation_stats(species_id, generation_type)

	return data

static func generate_creature_entity(species_id: String, generation_type: GenerationType = GenerationType.UNIFORM, creature_name: String = "") -> CreatureEntity:
	"""
	Generate full CreatureEntity with behavior (heavier, use when behavior needed immediately).
	This creates both CreatureData and CreatureEntity wrapper.
	"""
	var data: CreatureData = generate_creature_data(species_id, generation_type, creature_name)
	if data == null:
		return null

	var entity: CreatureEntity = CreatureEntity.new(data)
	return entity

static func generate_starter_creature(species_id: String = "scuttleguard") -> CreatureEntity:
	"""
	Generate a starter creature for new players with slight stat boost.
	Always returns CreatureEntity since new players need immediate interaction.
	"""
	var entity: CreatureEntity = generate_creature_entity(species_id, GenerationType.HIGH_ROLL)
	if entity == null:
		return null

	# Apply starter boost (+10% to all stats, minimum +5)
	var data: CreatureData = entity.data
	data.strength = mini(data.strength + maxi(int(data.strength * 0.1), 5), 1000)
	data.constitution = mini(data.constitution + maxi(int(data.constitution * 0.1), 5), 1000)
	data.dexterity = mini(data.dexterity + maxi(int(data.dexterity * 0.1), 5), 1000)
	data.intelligence = mini(data.intelligence + maxi(int(data.intelligence * 0.1), 5), 1000)
	data.wisdom = mini(data.wisdom + maxi(int(data.wisdom * 0.1), 5), 1000)
	data.discipline = mini(data.discipline + maxi(int(data.discipline * 0.1), 5), 1000)

	# Recalculate stamina after constitution boost
	data.stamina_max = _calculate_max_stamina(data.constitution)
	data.stamina_current = data.stamina_max

	return entity

static func generate_from_egg(species_id: String, egg_quality: String = "standard") -> CreatureData:
	"""
	Generate creature from shop egg with quality modifiers.
	Returns CreatureData for shop/inventory efficiency.
	"""
	var generation_type: GenerationType

	match egg_quality:
		"premium":
			generation_type = GenerationType.HIGH_ROLL
		"discount":
			generation_type = GenerationType.LOW_ROLL
		"standard":
			generation_type = GenerationType.UNIFORM
		_:
			generation_type = GenerationType.GAUSSIAN

	return generate_creature_data(species_id, generation_type)

static func generate_population_data(count: int, species_distribution: Dictionary = {}) -> Array[CreatureData]:
	"""
	Generate a population of creatures for testing or batch operations.
	Returns array of CreatureData for efficiency.

	species_distribution example: {"scuttleguard": 0.4, "wind_dancer": 0.3, "glow_grub": 0.3}
	If empty, uses equal distribution across all species.
	"""
	var population: Array[CreatureData] = []
	var species_list: Array[String] = []
	var weights: Array[float] = []

	# Set up species distribution
	if species_distribution.is_empty():
		# Equal distribution
		var keys = SPECIES_DATA.keys()
		for key in keys:
			species_list.append(key as String)
		for i in species_list.size():
			weights.append(1.0 / species_list.size())
	else:
		# Custom distribution
		for species in species_distribution:
			species_list.append(species as String)
			weights.append(species_distribution[species] as float)

	# Generate population (optimized for batch operations)
	population.resize(count)  # Pre-allocate for performance
	for i in range(count):
		var selected_species: String = _weighted_random_species(species_list, weights)
		var generation_type: GenerationType = GenerationType.values()[randi() % GenerationType.size()]
		var creature: CreatureData = generate_creature_data(selected_species, generation_type)
		if creature:
			population[i] = creature
		else:
			# Fallback to scuttleguard if generation fails
			population[i] = generate_creature_data("scuttleguard", GenerationType.UNIFORM)

	return population

# === GENERATION ALGORITHMS ===

static func _generate_stats(data: CreatureData, species: Dictionary, generation_type: GenerationType) -> void:
	"""Generate stats using the specified algorithm."""
	var ranges: Dictionary = species.stat_ranges

	match generation_type:
		GenerationType.UNIFORM:
			_generate_uniform_stats(data, ranges)
		GenerationType.GAUSSIAN:
			_generate_gaussian_stats(data, ranges)
		GenerationType.HIGH_ROLL:
			_generate_high_roll_stats(data, ranges)
		GenerationType.LOW_ROLL:
			_generate_low_roll_stats(data, ranges)

static func _generate_uniform_stats(data: CreatureData, ranges: Dictionary) -> void:
	"""Equal probability across stat range."""
	data.strength = randi_range(ranges.strength.min, ranges.strength.max)
	data.constitution = randi_range(ranges.constitution.min, ranges.constitution.max)
	data.dexterity = randi_range(ranges.dexterity.min, ranges.dexterity.max)
	data.intelligence = randi_range(ranges.intelligence.min, ranges.intelligence.max)
	data.wisdom = randi_range(ranges.wisdom.min, ranges.wisdom.max)
	data.discipline = randi_range(ranges.discipline.min, ranges.discipline.max)

static func _generate_gaussian_stats(data: CreatureData, ranges: Dictionary) -> void:
	"""Bell curve distribution using Box-Muller transform."""
	data.strength = _gaussian_stat(ranges.strength.min, ranges.strength.max)
	data.constitution = _gaussian_stat(ranges.constitution.min, ranges.constitution.max)
	data.dexterity = _gaussian_stat(ranges.dexterity.min, ranges.dexterity.max)
	data.intelligence = _gaussian_stat(ranges.intelligence.min, ranges.intelligence.max)
	data.wisdom = _gaussian_stat(ranges.wisdom.min, ranges.wisdom.max)
	data.discipline = _gaussian_stat(ranges.discipline.min, ranges.discipline.max)

static func _generate_high_roll_stats(data: CreatureData, ranges: Dictionary) -> void:
	"""Max of two rolls (premium eggs)."""
	data.strength = maxi(_uniform_stat(ranges.strength.min, ranges.strength.max), _uniform_stat(ranges.strength.min, ranges.strength.max))
	data.constitution = maxi(_uniform_stat(ranges.constitution.min, ranges.constitution.max), _uniform_stat(ranges.constitution.min, ranges.constitution.max))
	data.dexterity = maxi(_uniform_stat(ranges.dexterity.min, ranges.dexterity.max), _uniform_stat(ranges.dexterity.min, ranges.dexterity.max))
	data.intelligence = maxi(_uniform_stat(ranges.intelligence.min, ranges.intelligence.max), _uniform_stat(ranges.intelligence.min, ranges.intelligence.max))
	data.wisdom = maxi(_uniform_stat(ranges.wisdom.min, ranges.wisdom.max), _uniform_stat(ranges.wisdom.min, ranges.wisdom.max))
	data.discipline = maxi(_uniform_stat(ranges.discipline.min, ranges.discipline.max), _uniform_stat(ranges.discipline.min, ranges.discipline.max))

static func _generate_low_roll_stats(data: CreatureData, ranges: Dictionary) -> void:
	"""Min of two rolls (discount eggs)."""
	data.strength = mini(_uniform_stat(ranges.strength.min, ranges.strength.max), _uniform_stat(ranges.strength.min, ranges.strength.max))
	data.constitution = mini(_uniform_stat(ranges.constitution.min, ranges.constitution.max), _uniform_stat(ranges.constitution.min, ranges.constitution.max))
	data.dexterity = mini(_uniform_stat(ranges.dexterity.min, ranges.dexterity.max), _uniform_stat(ranges.dexterity.min, ranges.dexterity.max))
	data.intelligence = mini(_uniform_stat(ranges.intelligence.min, ranges.intelligence.max), _uniform_stat(ranges.intelligence.min, ranges.intelligence.max))
	data.wisdom = mini(_uniform_stat(ranges.wisdom.min, ranges.wisdom.max), _uniform_stat(ranges.wisdom.min, ranges.wisdom.max))
	data.discipline = mini(_uniform_stat(ranges.discipline.min, ranges.discipline.max), _uniform_stat(ranges.discipline.min, ranges.discipline.max))

# === STAT GENERATION UTILITIES ===

static func _uniform_stat(min_val: int, max_val: int) -> int:
	"""Generate a uniform random stat."""
	return randi_range(min_val, max_val)

static func _gaussian_stat(min_val: int, max_val: int) -> int:
	"""Generate a Gaussian-distributed stat using Box-Muller transform."""
	var mean: float = (min_val + max_val) / 2.0
	var std_dev: float = (max_val - min_val) / 6.0  # 99.7% within range

	# Box-Muller transform
	var u1: float = randf()
	var u2: float = randf()
	var z0: float = sqrt(-2.0 * log(u1)) * cos(2.0 * PI * u2)

	var value: int = int(mean + z0 * std_dev)
	return clampi(value, min_val, max_val)

# === TAG ASSIGNMENT ===

static func _assign_tags(data: CreatureData, species: Dictionary) -> void:
	"""Assign guaranteed and optional tags with TagSystem validation."""
	var tags: Array[String] = []

	# Add guaranteed tags
	for tag in species.guaranteed_tags:
		tags.append(tag as String)

	# Add optional tags with probability
	for tag in species.optional_tags:
		if randf() < OPTIONAL_TAG_CHANCE:
			tags.append(tag as String)

	# Validate tag combination with TagSystem if available
	var tag_system = _get_tag_system()
	if tag_system:
		var validation: Dictionary = tag_system.validate_tag_combination(tags)
		if validation.valid:
			data.tags = tags
		else:
			# Fallback: use only guaranteed tags if validation fails
			var guaranteed_tags: Array[String] = []
			for tag in species.guaranteed_tags:
				guaranteed_tags.append(tag as String)
			data.tags = guaranteed_tags
			print("CreatureGenerator: Tag validation failed for %s, using guaranteed tags only" % data.creature_name)
	else:
		# Fallback behavior when TagSystem not available
		data.tags = tags
		print("CreatureGenerator: TagSystem not available, using tags without validation")

static func _get_tag_system():
	"""Get TagSystem through GameCore if available."""
	# GameCore is an autoload, not a singleton
	if not GameCore:
		return null

	# Try to get TagSystem (will lazy load if needed)
	return GameCore.get_system("tag")

# === UTILITY METHODS ===

static func _generate_unique_id() -> String:
	"""Generate a unique creature ID."""
	var timestamp: int = Time.get_unix_time_from_system()
	var random_suffix: int = randi_range(1000, 9999)
	return "creature_%d_%d" % [timestamp, random_suffix]

static func _generate_random_name(species_id: String) -> String:
	"""Generate a random name for the species."""
	if not SPECIES_DATA.has(species_id):
		return "Unknown"

	var name_pool: Array = SPECIES_DATA[species_id].name_pool
	var base_name: String = name_pool[randi() % name_pool.size()] as String
	var number: int = randi_range(1, 999)
	return "%s %d" % [base_name, number]

static func _calculate_max_stamina(constitution: int) -> int:
	"""Calculate maximum stamina based on constitution."""
	# Stamina = constitution + random(0, 50) for variety
	return constitution + randi_range(0, 50)

static func _weighted_random_species(species_list: Array[String], weights: Array[float]) -> String:
	"""Select a random species based on weights."""
	var total_weight: float = 0.0
	for weight in weights:
		total_weight += weight

	var random_value: float = randf() * total_weight
	var cumulative_weight: float = 0.0

	for i in range(species_list.size()):
		cumulative_weight += weights[i]
		if random_value <= cumulative_weight:
			return species_list[i]

	# Fallback to last species
	return species_list[-1]

# === VALIDATION & STATISTICS ===

static func validate_creature_against_species(data: CreatureData) -> Dictionary:
	"""
	Validate that a creature meets its species specifications.
	Returns: {"valid": bool, "errors": Array[String]}
	"""
	var errors: Array[String] = []
	var result: Dictionary = {"valid": true, "errors": errors}

	if not SPECIES_DATA.has(data.species_id):
		result.valid = false
		errors.append("Unknown species: %s" % data.species_id)
		return result

	var species: Dictionary = SPECIES_DATA[data.species_id]
	var ranges: Dictionary = species.stat_ranges

	# Validate stat ranges
	var stats_to_check := {
		"strength": data.strength,
		"constitution": data.constitution,
		"dexterity": data.dexterity,
		"intelligence": data.intelligence,
		"wisdom": data.wisdom,
		"discipline": data.discipline
	}

	for stat_name in stats_to_check:
		var value: int = stats_to_check[stat_name]
		var min_val: int = ranges[stat_name].min
		var max_val: int = ranges[stat_name].max

		if value < min_val or value > max_val:
			result.valid = false
			errors.append("%s out of range: %d (expected %d-%d)" % [stat_name, value, min_val, max_val])

	# Validate guaranteed tags
	for tag in species.guaranteed_tags:
		if not data.has_tag(tag):
			result.valid = false
			errors.append("Missing guaranteed tag: %s" % tag)

	return result

static func get_generation_statistics() -> Dictionary:
	"""Get generation statistics for analysis."""
	return _generation_stats.duplicate(true)

static func reset_generation_statistics() -> void:
	"""Reset generation statistics."""
	_generation_stats.clear()

static func _track_generation_stats(species_id: String, generation_type: GenerationType) -> void:
	"""Track generation statistics."""
	if not _generation_stats.has("total_generated"):
		_generation_stats.total_generated = 0

	if not _generation_stats.has("by_species"):
		_generation_stats.by_species = {}

	if not _generation_stats.has("by_type"):
		_generation_stats.by_type = {}

	_generation_stats.total_generated += 1

	# Track by species
	if not _generation_stats.by_species.has(species_id):
		_generation_stats.by_species[species_id] = 0
	_generation_stats.by_species[species_id] += 1

	# Track by generation type
	var type_name: String = GenerationType.keys()[generation_type]
	if not _generation_stats.by_type.has(type_name):
		_generation_stats.by_type[type_name] = 0
	_generation_stats.by_type[type_name] += 1

# === INFORMATION METHODS ===

static func get_available_species() -> Array[String]:
	"""Get list of available species IDs."""
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.get_all_species()

	# Fallback to hardcoded data if SpeciesSystem not available
	if _cached_species_keys.is_empty():
		var keys = SPECIES_DATA.keys()
		_cached_species_keys.clear()
		for key in keys:
			_cached_species_keys.append(key as String)
	return _cached_species_keys

static func get_species_info(species_id: String) -> Dictionary:
	"""Get complete species information."""
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.get_species_info(species_id)

	# Fallback to hardcoded data if SpeciesSystem not available
	return SPECIES_DATA.get(species_id, {})

static func is_valid_species(species_id: String) -> bool:
	"""Check if species ID is valid."""
	var species_system = GameCore.get_system("species")
	if species_system:
		return species_system.is_valid_species(species_id)

	# Fallback to hardcoded data if SpeciesSystem not available
	return SPECIES_DATA.has(species_id)

# TODO: Task 10 - Migrate to SpeciesSystem
# This hardcoded species data will be moved to external resources
# when implementing the SpeciesSystem in Stage 1 Task 10
