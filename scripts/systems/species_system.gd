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
	var result: Array[String] = []
	var category_species = species_by_category.get(category, [])
	for species_id in category_species:
		result.append(species_id as String)
	return result

func get_species_by_rarity(rarity: String) -> Array[String]:
	"""Get species IDs by rarity."""
	var result: Array[String] = []
	var rarity_species = species_by_rarity.get(rarity, [])
	for species_id in rarity_species:
		result.append(species_id as String)
	return result

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
		},
		{
			"species_id": "stone_sentinel",
			"display_name": "Stone Sentinel",
			"category": "premium",
			"rarity": "uncommon",
			"base_price": 500,
			"lifespan_weeks": 780,
			"guaranteed_tags": ["Large", "Sturdy", "Natural Armor"],
			"optional_tags": ["Intimidating", "Slow", "Hardy"],
			"stat_ranges": {
				"strength": {"min": 150, "max": 250},
				"constitution": {"min": 200, "max": 300},
				"dexterity": {"min": 20, "max": 60},
				"intelligence": {"min": 30, "max": 60},
				"wisdom": {"min": 80, "max": 120},
				"discipline": {"min": 150, "max": 250}
			},
			"name_pool": ["Boulder", "Granite", "Fortress", "Bastion", "Aegis", "Bulwark", "Rampart", "Citadel", "Keep", "Tower", "Wall", "Guardian"]
		},
		{
			"species_id": "wind_dancer",
			"display_name": "Wind Dancer",
			"category": "premium",
			"rarity": "uncommon",
			"base_price": 400,
			"lifespan_weeks": 416,
			"guaranteed_tags": ["Medium", "Winged", "Fast"],
			"optional_tags": ["Graceful", "Aerial", "Keen Eyes"],
			"stat_ranges": {
				"strength": {"min": 60, "max": 120},
				"constitution": {"min": 50, "max": 100},
				"dexterity": {"min": 180, "max": 280},
				"intelligence": {"min": 80, "max": 140},
				"wisdom": {"min": 120, "max": 180},
				"discipline": {"min": 70, "max": 130}
			},
			"name_pool": ["Zephyr", "Gale", "Breeze", "Storm", "Tempest", "Gust", "Whirlwind", "Cyclone", "Hurricane", "Mistral", "Sirocco", "Chinook"]
		},
		{
			"species_id": "glow_grub",
			"display_name": "Glow Grub",
			"category": "utility",
			"rarity": "common",
			"base_price": 150,
			"lifespan_weeks": 312,
			"guaranteed_tags": ["Small", "Bioluminescent", "Docile"],
			"optional_tags": ["Fragile", "Peaceful", "Useful"],
			"stat_ranges": {
				"strength": {"min": 30, "max": 80},
				"constitution": {"min": 40, "max": 90},
				"dexterity": {"min": 50, "max": 100},
				"intelligence": {"min": 60, "max": 120},
				"wisdom": {"min": 100, "max": 160},
				"discipline": {"min": 80, "max": 140}
			},
			"name_pool": ["Glow", "Shine", "Spark", "Beam", "Flicker", "Gleam", "Radiance", "Lumina", "Aurora", "Prism", "Crystal", "Lantern"]
		}
	]

	for species_data in default_species:
		var species: SpeciesResource = SpeciesResource.new()
		_populate_species_from_dict(species, species_data)
		species_registry[species.species_id] = species

	_organize_species_data()

func _populate_species_from_dict(species: SpeciesResource, data: Dictionary) -> void:
	"""Populate a SpeciesResource from dictionary data."""
	species.species_id = data.get("species_id", "")
	species.display_name = data.get("display_name", "")
	species.category = data.get("category", "common")
	species.rarity = data.get("rarity", "common")
	species.base_price = data.get("base_price", 200)
	species.lifespan_weeks = data.get("lifespan_weeks", 520)

	# Handle Array[String] assignments properly
	var guaranteed_tags_array: Array[String] = []
	var optional_tags_array: Array[String] = []
	var name_pool_array: Array[String] = []

	for tag in data.get("guaranteed_tags", []):
		guaranteed_tags_array.append(tag as String)
	species.guaranteed_tags = guaranteed_tags_array

	for tag in data.get("optional_tags", []):
		optional_tags_array.append(tag as String)
	species.optional_tags = optional_tags_array

	for name in data.get("name_pool", []):
		name_pool_array.append(name as String)
	species.name_pool = name_pool_array

	species.stat_ranges = data.get("stat_ranges", {}).duplicate()