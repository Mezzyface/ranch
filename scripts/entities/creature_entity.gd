class_name CreatureEntity
extends Node

var data: CreatureData
var signal_bus: SignalBus
var stat_system: Node # StatSystem reference

func _init(creature_data: CreatureData = null) -> void:
	if creature_data:
		data = creature_data
	else:
		data = CreatureData.new()

func _ready() -> void:
	signal_bus = GameCore.get_signal_bus()
	stat_system = GameCore.get_system("stat")
	if signal_bus and _debug_mode():
		print("CreatureEntity ready for: %s" % data.creature_name)

# Stat modification with validation through StatSystem
func modify_stat(stat_name: String, value: int) -> void:
	var old_value: int = data.get_stat(stat_name)
	var validated_value: int = stat_system.validate_stat_value(stat_name, value) if stat_system else value
	data.set_stat(stat_name, validated_value)
	var new_value: int = data.get_stat(stat_name)

	if old_value != new_value and signal_bus:
		signal_bus.emit_creature_stats_changed(data, stat_name, old_value, new_value)

func increase_stat(stat_name: String, amount: int) -> void:
	var current: int = data.get_stat(stat_name)
	modify_stat(stat_name, current + amount)

func decrease_stat(stat_name: String, amount: int) -> void:
	var current: int = data.get_stat(stat_name)
	modify_stat(stat_name, current - amount)

# Tag management with validation
func add_tag(tag: String) -> bool:
	if not data.has_tag(tag) and _is_valid_tag(tag):
		data.tags.append(tag)
		if signal_bus and _debug_mode():
			print("CreatureEntity: Added tag '%s' to %s" % [tag, data.creature_name])
		return true
	return false

func remove_tag(tag: String) -> bool:
	if data.has_tag(tag):
		data.tags.erase(tag)
		if signal_bus and _debug_mode():
			print("CreatureEntity: Removed tag '%s' from %s" % [tag, data.creature_name])
		return true
	return false

# Age management with signals
func age_one_week() -> void:
	var old_age: int = data.age_weeks
	var old_category: int = data.get_age_category()
	data.age_weeks += 1

	# Apply aging effects
	if data.is_active:
		data.stamina_current = maxi(0, data.stamina_current - 10)

	if signal_bus:
		signal_bus.emit_creature_aged(data, data.age_weeks)

	# Check for age category change
	var new_category: int = data.get_age_category()
	if old_category != new_category and _debug_mode():
		print("CreatureEntity: %s aged from category %d to %d" % [data.creature_name, old_category, new_category])

# Stamina management
func consume_stamina(amount: int) -> bool:
	if data.stamina_current >= amount:
		var old_stamina: int = data.stamina_current
		data.stamina_current -= amount
		if signal_bus and _debug_mode():
			print("CreatureEntity: %s consumed %d stamina (%d -> %d)" % [
				data.creature_name, amount, old_stamina, data.stamina_current
			])
		return true
	return false

func restore_stamina(amount: int) -> void:
	var old_stamina: int = data.stamina_current
	data.stamina_current = mini(data.stamina_current + amount, data.stamina_max)

	if old_stamina != data.stamina_current and _debug_mode():
		print("CreatureEntity: %s restored stamina (%d -> %d)" % [
			data.creature_name, old_stamina, data.stamina_current
		])

func rest_fully() -> void:
	var old_stamina: int = data.stamina_current
	data.stamina_current = data.stamina_max
	if _debug_mode():
		print("CreatureEntity: %s fully rested (%d -> %d)" % [
			data.creature_name, old_stamina, data.stamina_current
		])

# State management
func set_active(active: bool) -> void:
	if data.is_active != active:
		data.is_active = active
		if signal_bus:
			if active:
				signal_bus.emit_creature_activated(data)
			else:
				signal_bus.emit_creature_deactivated(data)

# Validation
func _is_valid_tag(tag: String) -> bool:
	# Define valid tags based on design documents
	const VALID_TAGS = [
		# Size tags
		"Small", "Medium", "Large",
		# Social tags
		"Territorial", "Social", "Solitary",
		# Movement tags
		"Winged", "Aquatic", "Terrestrial",
		# Activity tags
		"Nocturnal", "Diurnal", "Crepuscular",
		# Environment tags
		"Dark Vision", "Natural Armor", "Camouflage",
		# Utility tags
		"Heavy Labor", "Sanitation", "Pest Control", "Security"
	]
	return tag in VALID_TAGS

# Quest requirement matching using StatSystem
func matches_requirements(req_stats: Dictionary, req_tags: Array[String]) -> bool:
	# Use StatSystem for accurate stat calculations
	if stat_system and not stat_system.meets_requirements(data, req_stats):
		return false

	# Check tags
	return data.has_all_tags(req_tags)

# Performance calculations using StatSystem (includes age modifier)
func get_performance_score() -> float:
	if stat_system:
		return stat_system.calculate_performance(data)
	else:
		# Fallback calculation with age modifier
		var base_score: float = 0.0
		base_score += data.strength * 0.15
		base_score += data.constitution * 0.15
		base_score += data.dexterity * 0.15
		base_score += data.intelligence * 0.15
		base_score += data.wisdom * 0.15
		base_score += data.discipline * 0.25
		return base_score * data.get_age_modifier()

func get_effective_stat(stat_name: String) -> int:
	"""Get stat value for quest requirements (NO age modifier, modifiers only)."""
	if stat_system:
		return stat_system.get_effective_stat(data, stat_name)
	else:
		# Fallback: base stat only (no age modifier for quest requirements)
		return data.get_stat(stat_name)

func get_competition_stat(stat_name: String) -> int:
	"""Get stat value for competitions (includes age modifier)."""
	if stat_system:
		return stat_system.get_competition_stat(data, stat_name)
	else:
		# Fallback: apply age modifier for competitions
		var base_stat: int = data.get_stat(stat_name)
		var age_mod: float = data.get_age_modifier()
		return int(base_stat * age_mod)

# Modifier management through StatSystem
func apply_stat_modifier(stat_name: String, value: int, modifier_type: int = 0,
						stacking_mode: int = 0, duration_weeks: int = 1, modifier_id: String = "") -> void:
	"""Apply a temporary or permanent modifier to a stat."""
	if stat_system:
		stat_system.apply_modifier(data.id, stat_name, value, modifier_type, stacking_mode, duration_weeks, modifier_id)

func remove_stat_modifier(stat_name: String, modifier_id: String = "") -> bool:
	"""Remove a specific modifier from a stat."""
	if stat_system:
		return stat_system.remove_modifier(data.id, stat_name, modifier_id)
	return false

func clear_all_modifiers() -> void:
	"""Remove all modifiers from this creature."""
	if stat_system:
		stat_system.clear_creature_modifiers(data.id)

func has_modifiers(stat_name: String = "") -> bool:
	"""Check if creature has any modifiers."""
	if stat_system:
		return stat_system.has_modifiers(data.id, stat_name)
	return false

func get_stat_breakdown(stat_name: String) -> Dictionary:
	"""Get detailed breakdown of stat calculation."""
	if stat_system:
		return stat_system.get_stat_breakdown(data, stat_name)
	return {}

func get_stat_tier(stat_name: String) -> String:
	"""Get tier classification for a stat."""
	if stat_system:
		var effective_value := get_effective_stat(stat_name)
		return stat_system.get_stat_tier(effective_value)
	return "UNKNOWN"

# Utility functions
func _debug_mode() -> bool:
	# Check if SignalBus debug mode is enabled
	if signal_bus and signal_bus.has_method("get_debug_mode"):
		return signal_bus.get("_debug_mode")
	return false

func get_summary() -> String:
	"""Get a summary string for debugging."""
	return "%s (ID: %s, Age: %d weeks, Active: %s, Stamina: %d/%d)" % [
		data.creature_name,
		data.id,
		data.age_weeks,
		"Yes" if data.is_active else "No",
		data.stamina_current,
		data.stamina_max
	]

# Create a new creature with random stats
static func create_random(name: String = "", species: String = "") -> CreatureEntity:
	var entity: CreatureEntity = CreatureEntity.new()

	if not name.is_empty():
		entity.data.creature_name = name
	else:
		entity.data.creature_name = "Creature_%d" % (randi() % 9999)

	if not species.is_empty():
		entity.data.species_id = species

	# Randomize stats between 20 and 80
	entity.data.strength = randi_range(20, 80)
	entity.data.constitution = randi_range(20, 80)
	entity.data.dexterity = randi_range(20, 80)
	entity.data.intelligence = randi_range(20, 80)
	entity.data.wisdom = randi_range(20, 80)
	entity.data.discipline = randi_range(20, 80)

	# Random age between 0 and 52 weeks (1 year)
	entity.data.age_weeks = randi_range(0, 52)

	return entity
