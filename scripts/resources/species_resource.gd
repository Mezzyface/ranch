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