class_name CreatureEntity
extends Node

var data: CreatureData
var signal_bus: SignalBus
var stat_system: Node # StatSystem reference
var tag_system: Node # TagSystem reference

func _init(creature_data: CreatureData = null) -> void:
	if creature_data:
		data = creature_data
	else:
		data = CreatureData.new()

func _ready() -> void:
	signal_bus = GameCore.get_signal_bus()
	stat_system = GameCore.get_system("stat")
	tag_system = GameCore.get_system("tag")
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

# Tag management through TagSystem
func add_tag(tag: String) -> bool:
	"""Add a tag to this creature, validated through TagSystem."""
	if not tag_system:
		push_error("CreatureEntity.add_tag: TagSystem required but not loaded. Cannot add tag '%s' to %s" % [tag, data.creature_name])
		return false
	return tag_system.add_tag_to_creature(self, tag)

func remove_tag(tag: String) -> bool:
	"""Remove a tag from this creature, through TagSystem."""
	if not tag_system:
		push_error("CreatureEntity.remove_tag: TagSystem required but not loaded. Cannot remove tag '%s' from %s" % [tag, data.creature_name])
		return false
	return tag_system.remove_tag_from_creature(self, tag)

func can_add_tag(tag: String) -> Dictionary:
	"""Check if a tag can be added to this creature."""
	if not tag_system:
		push_error("CreatureEntity.can_add_tag: TagSystem required but not loaded.")
		return {"can_add": false, "reason": "TagSystem not loaded"}
	return tag_system.can_add_tag_to_creature(data, tag)

func get_tags_by_category(category: int) -> Array[String]:
	"""Get all tags this creature has in a specific category."""
	if tag_system:
		var creature_tags: Array[String] = data.tags
		var category_tags: Array[String] = tag_system.get_tags_by_category(category)
		var result: Array[String] = []
		for tag in creature_tags:
			if tag in category_tags:
				result.append(tag)
		return result
	return []

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

# Validation - DEPRECATED: Use TagSystem for all validation
func _is_valid_tag(tag: String) -> bool:
	# This function should not be used - TagSystem is the source of truth
	push_warning("CreatureEntity._is_valid_tag is deprecated. Use TagSystem.is_valid_tag()")
	if tag_system:
		return tag_system.is_valid_tag(tag)
	return false  # Fail closed without TagSystem

# Quest requirement matching using StatSystem and TagSystem
func matches_requirements(req_stats: Dictionary, req_tags: Array[String]) -> bool:
	# Require StatSystem for stat validation if stats specified
	if not req_stats.is_empty():
		if not stat_system:
			push_error("CreatureEntity.matches_requirements: StatSystem required for stat requirements")
			return false
		if not stat_system.meets_requirements(data, req_stats):
			return false

	# Require TagSystem for tag validation if tags specified
	if not req_tags.is_empty():
		if not tag_system:
			push_error("CreatureEntity.matches_requirements: TagSystem required for tag requirements")
			return false
		if not tag_system.meets_tag_requirements(data, req_tags):
			return false

	return true

# Performance calculations using StatSystem (includes age modifier)
func get_performance_score() -> float:
	if not stat_system:
		push_error("CreatureEntity.get_performance_score: StatSystem required for performance calculation")
		return 0.0  # Return worst score without proper calculation
	return stat_system.calculate_performance(data)

func get_effective_stat(stat_name: String) -> int:
	"""Get stat value for quest requirements (NO age modifier, modifiers only)."""
	if not stat_system:
		push_error("CreatureEntity.get_effective_stat: StatSystem required for modifier calculations")
		return data.get_stat(stat_name)  # Return base only as emergency fallback
	return stat_system.get_effective_stat(data, stat_name)

func get_competition_stat(stat_name: String) -> int:
	"""Get stat value for competitions (includes age modifier)."""
	if not stat_system:
		push_error("CreatureEntity.get_competition_stat: StatSystem required for competition calculations")
		return 0  # Return worst value without proper calculation
	return stat_system.get_competition_stat(data, stat_name)

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
static func create_random(creature_name: String = "", species: String = "") -> CreatureEntity:
	var entity: CreatureEntity = CreatureEntity.new()

	if not creature_name.is_empty():
		entity.data.creature_name = creature_name
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
