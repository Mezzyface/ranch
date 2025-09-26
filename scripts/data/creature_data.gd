class_name CreatureData
extends Resource

# Identity
@export var id: String = ""
@export var creature_name: String = ""
@export var species_id: String = ""

# Core Stats (1-1000) - Simple validation, NO signals!
@export_range(1, 1000) var strength: int = 50:
	set(value):
		strength = clampi(value, 1, 1000)

@export_range(1, 1000) var constitution: int = 50:
	set(value):
		constitution = clampi(value, 1, 1000)

@export_range(1, 1000) var dexterity: int = 50:
	set(value):
		dexterity = clampi(value, 1, 1000)

@export_range(1, 1000) var intelligence: int = 50:
	set(value):
		intelligence = clampi(value, 1, 1000)

@export_range(1, 1000) var wisdom: int = 50:
	set(value):
		wisdom = clampi(value, 1, 1000)

@export_range(1, 1000) var discipline: int = 50:
	set(value):
		discipline = clampi(value, 1, 1000)

# Tags
@export var tags: Array[String] = []

# Age System
@export_range(0, 1000) var age_weeks: int = 0
@export_range(100, 1000) var lifespan: int = 520  # 10 years default

# State Management
@export var is_active: bool = false
@export_range(0, 200) var stamina_current: int = 100:
	set(value):
		stamina_current = clampi(value, 0, stamina_max)
@export_range(50, 200) var stamina_max: int = 100

# Breeding Properties
@export var egg_group: String = ""
@export var parent_ids: Array[String] = []
@export_range(1, 10) var generation: int = 1

# Constructor
func _init() -> void:
	if id.is_empty():
		id = "creature_%d_%06d" % [Time.get_unix_time_from_system(), randi() % 999999]

# Utility functions (pure calculations, no state changes)
func get_age_category() -> int:
	var life_percentage: float = (age_weeks / float(lifespan)) * 100
	if life_percentage < 10:
		return 0  # BABY
	elif life_percentage < 25:
		return 1  # JUVENILE
	elif life_percentage < 75:
		return 2  # ADULT
	elif life_percentage < 90:
		return 3  # ELDER
	else:
		return 4  # ANCIENT

func get_age_modifier() -> float:
	match get_age_category():
		0: return 0.6  # BABY
		1: return 0.8  # JUVENILE
		2: return 1.0  # ADULT
		3: return 0.8  # ELDER
		4: return 0.6  # ANCIENT
		_: return 1.0

# Stat Accessors with typed return values
func get_stat(stat_name: String) -> int:
	match stat_name.to_upper():
		"STR", "STRENGTH": return strength
		"CON", "CONSTITUTION": return constitution
		"DEX", "DEXTERITY": return dexterity
		"INT", "INTELLIGENCE": return intelligence
		"WIS", "WISDOM": return wisdom
		"DIS", "DISCIPLINE": return discipline
		_:
			push_warning("Invalid stat name: " + stat_name)
			return 0

func set_stat(stat_name: String, value: int) -> void:
	match stat_name.to_upper():
		"STR", "STRENGTH": strength = value
		"CON", "CONSTITUTION": constitution = value
		"DEX", "DEXTERITY": dexterity = value
		"INT", "INTELLIGENCE": intelligence = value
		"WIS", "WISDOM": wisdom = value
		"DIS", "DISCIPLINE": discipline = value
		_:
			push_warning("Invalid stat name: " + stat_name)

# Simple tag queries (no state changes)
func has_tag(tag: String) -> bool:
	return tag in tags

func has_all_tags(required_tags: Array[String]) -> bool:
	for tag in required_tags:
		if not has_tag(tag):
			return false
	return true

func has_any_tag(required_tags: Array[String]) -> bool:
	for tag in required_tags:
		if has_tag(tag):
			return true
	return false

# Serialization with proper property names
func to_dict() -> Dictionary:
	return {
		"id": id,
		"creature_name": creature_name,
		"species_id": species_id,
		"stats": {
			"strength": strength,
			"constitution": constitution,
			"dexterity": dexterity,
			"intelligence": intelligence,
			"wisdom": wisdom,
			"discipline": discipline
		},
		"tags": tags,
		"age_weeks": age_weeks,
		"lifespan": lifespan,
		"is_active": is_active,
		"stamina_current": stamina_current,
		"stamina_max": stamina_max,
		"egg_group": egg_group,
		"parent_ids": parent_ids,
		"generation": generation
	}

static func from_dict(data: Dictionary) -> CreatureData:
	var creature: CreatureData = CreatureData.new()
	creature.id = data.get("id", "")
	creature.creature_name = data.get("creature_name", "")
	creature.species_id = data.get("species_id", "")

	var stats: Dictionary = data.get("stats", {})
	creature.strength = stats.get("strength", 50)
	creature.constitution = stats.get("constitution", 50)
	creature.dexterity = stats.get("dexterity", 50)
	creature.intelligence = stats.get("intelligence", 50)
	creature.wisdom = stats.get("wisdom", 50)
	creature.discipline = stats.get("discipline", 50)

	creature.tags = Array(data.get("tags", []), TYPE_STRING, "", null)
	creature.age_weeks = data.get("age_weeks", 0)
	creature.lifespan = data.get("lifespan", 520)
	creature.is_active = data.get("is_active", false)
	creature.stamina_current = data.get("stamina_current", 100)
	creature.stamina_max = data.get("stamina_max", 100)
	creature.egg_group = data.get("egg_group", "")
	creature.parent_ids = Array(data.get("parent_ids", []), TYPE_STRING, "", null)
	creature.generation = data.get("generation", 1)

	return creature