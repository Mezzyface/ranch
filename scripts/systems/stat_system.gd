# StatSystem - GameCore Subsystem for Stat Management
# Handles all stat calculations, modifications, and validations for creatures
extends Node

# Stat name constants
const STAT_NAMES := {
	"STR": "strength",
	"CON": "constitution",
	"DEX": "dexterity",
	"INT": "intelligence",
	"WIS": "wisdom",
	"DIS": "discipline"
}

# Stat aliases for flexible access
const STAT_ALIASES := {
	"STRENGTH": "strength",
	"CONSTITUTION": "constitution",
	"DEXTERITY": "dexterity",
	"INTELLIGENCE": "intelligence",
	"WISDOM": "wisdom",
	"DISCIPLINE": "discipline",
	"STR": "strength",
	"CON": "constitution",
	"DEX": "dexterity",
	"INT": "intelligence",
	"WIS": "wisdom",
	"DIS": "discipline"
}

const STAT_MIN := 1
const STAT_MAX := 1000

# Stat tier thresholds
const STAT_TIERS := {
	"WEAK": 0,
	"BELOW_AVERAGE": 200,
	"AVERAGE": 400,
	"ABOVE_AVERAGE": 600,
	"STRONG": 750,
	"EXCEPTIONAL": 900
}

var signal_bus: SignalBus
var active_modifiers: Dictionary = {} # creature_id -> modifiers

# Modifier types
enum ModifierType {
	TEMPORARY,
	PERMANENT,
	EQUIPMENT,
	TRAIT
}

# Stacking modes
enum StackingMode {
	ADDITIVE,
	MULTIPLICATIVE,
	REPLACE
}

func _ready() -> void:
	signal_bus = GameCore.get_signal_bus()
	print("StatSystem initialized")

# Get normalized stat name
func _normalize_stat_name(stat_name: String) -> String:
	var upper_name := stat_name.to_upper()
	if upper_name in STAT_ALIASES:
		return STAT_ALIASES[upper_name]
	return stat_name.to_lower()

# Calculate effective stat value with all modifiers (NO AGE MODIFIER)
# Age modifiers only affect training gains and competition performance, NOT quest requirements
func get_effective_stat(creature_data: CreatureData, stat_name: String) -> int:
	var normalized_name := _normalize_stat_name(stat_name)
	var base_value := creature_data.get_stat(normalized_name)
	if base_value == 0:
		return 0

	# Start with base value (NO age modifier for quest requirements)
	var final_value := base_value

	# Apply modifiers if any
	if creature_data.id in active_modifiers:
		final_value = _apply_all_modifiers(creature_data.id, normalized_name, base_value)

	return clampi(final_value, STAT_MIN, STAT_MAX)

# Calculate competition performance stat (includes age modifier)
# This is used for competitions and performance scoring, NOT quest requirements
func get_competition_stat(creature_data: CreatureData, stat_name: String) -> int:
	var normalized_name := _normalize_stat_name(stat_name)
	var base_value := creature_data.get_stat(normalized_name)
	if base_value == 0:
		return 0

	# Apply age modifier for competitions
	var age_modifier := creature_data.get_age_modifier()
	var age_adjusted := int(base_value * age_modifier)

	# Apply modifiers if any
	var final_value := age_adjusted
	if creature_data.id in active_modifiers:
		final_value = _apply_all_modifiers(creature_data.id, normalized_name, age_adjusted)

	return clampi(final_value, STAT_MIN, STAT_MAX)

# Apply all modifiers to a stat value
func _apply_all_modifiers(creature_id: String, stat_name: String, base_value: int) -> int:
	if not creature_id in active_modifiers:
		return base_value

	var creature_mods = active_modifiers[creature_id]
	if not stat_name in creature_mods:
		return base_value

	var stat_mods = creature_mods[stat_name]
	var final_value := base_value

	# Apply additive modifiers first
	var additive_total := 0
	for modifier in stat_mods:
		if modifier.get("stacking_mode", StackingMode.ADDITIVE) == StackingMode.ADDITIVE:
			additive_total += modifier.value

	final_value += additive_total

	# Apply multiplicative modifiers
	var multiplicative_factor := 1.0
	for modifier in stat_mods:
		if modifier.get("stacking_mode", StackingMode.ADDITIVE) == StackingMode.MULTIPLICATIVE:
			# Convert percentage to factor (e.g., +20% = 1.2, -10% = 0.9)
			var factor: float = 1.0 + (modifier.value / 100.0)
			multiplicative_factor *= factor

	final_value = int(final_value * multiplicative_factor)

	return final_value

# Apply modifier to creature
func apply_modifier(creature_id: String, stat_name: String, value: int,
				   modifier_type: ModifierType = ModifierType.TEMPORARY,
				   stacking_mode: StackingMode = StackingMode.ADDITIVE,
				   duration_weeks: int = 1, modifier_id: String = "") -> void:

	var normalized_name := _normalize_stat_name(stat_name)

	# Initialize modifier structure
	if not creature_id in active_modifiers:
		active_modifiers[creature_id] = {}
	if not normalized_name in active_modifiers[creature_id]:
		active_modifiers[creature_id][normalized_name] = []

	# Create modifier data
	var modifier_data := {
		"id": modifier_id if modifier_id != "" else _generate_modifier_id(),
		"value": value,
		"type": modifier_type,
		"stacking_mode": stacking_mode,
		"duration_weeks": duration_weeks,
		"created_week": 0 # Will connect to time system later
	}

	# Handle stacking
	if stacking_mode == StackingMode.REPLACE:
		# Replace all modifiers of same type
		active_modifiers[creature_id][normalized_name] = [modifier_data]
	else:
		# Add to existing modifiers
		active_modifiers[creature_id][normalized_name].append(modifier_data)

	# Schedule removal for temporary modifiers
	if modifier_type == ModifierType.TEMPORARY and duration_weeks > 0:
		_schedule_modifier_removal(creature_id, normalized_name, modifier_data.id, duration_weeks)

	# Emit signal
	if signal_bus:
		signal_bus.emit_creature_modifiers_changed(creature_id, normalized_name)

# Remove specific modifier
func remove_modifier(creature_id: String, stat_name: String, modifier_id: String = "") -> bool:
	var normalized_name := _normalize_stat_name(stat_name)

	if not creature_id in active_modifiers:
		return false
	if not normalized_name in active_modifiers[creature_id]:
		return false

	var stat_mods = active_modifiers[creature_id][normalized_name]

	if modifier_id == "":
		# Remove all modifiers for this stat
		active_modifiers[creature_id].erase(normalized_name)
		if active_modifiers[creature_id].is_empty():
			active_modifiers.erase(creature_id)
		return true
	else:
		# Remove specific modifier
		for i in range(stat_mods.size() - 1, -1, -1):
			if stat_mods[i].id == modifier_id:
				stat_mods.remove_at(i)
				if stat_mods.is_empty():
					active_modifiers[creature_id].erase(normalized_name)
					if active_modifiers[creature_id].is_empty():
						active_modifiers.erase(creature_id)

				# Emit signal
				if signal_bus:
					signal_bus.emit_creature_modifiers_changed(creature_id, normalized_name)
				return true

	return false

# Remove all modifiers for a creature
func clear_creature_modifiers(creature_id: String) -> void:
	if creature_id in active_modifiers:
		active_modifiers.erase(creature_id)
		if signal_bus:
			signal_bus.emit_creature_modifiers_changed(creature_id, "all")

# Validate stat value
func validate_stat_value(_stat_name: String, value: int) -> int:
	return clampi(value, STAT_MIN, STAT_MAX)

# Get stat cap
func get_stat_cap(_stat_name: String) -> int:
	return STAT_MAX

# Calculate stat difference between two creatures
func calculate_stat_difference(creature_a: CreatureData, creature_b: CreatureData, stat_name: String) -> int:
	var a_value := get_effective_stat(creature_a, stat_name)
	var b_value := get_effective_stat(creature_b, stat_name)
	return a_value - b_value

# Get stat tier
func get_stat_tier(value: int) -> String:
	if value >= STAT_TIERS.EXCEPTIONAL:
		return "EXCEPTIONAL"
	elif value >= STAT_TIERS.STRONG:
		return "STRONG"
	elif value >= STAT_TIERS.ABOVE_AVERAGE:
		return "ABOVE_AVERAGE"
	elif value >= STAT_TIERS.AVERAGE:
		return "AVERAGE"
	elif value >= STAT_TIERS.BELOW_AVERAGE:
		return "BELOW_AVERAGE"
	else:
		return "WEAK"

# Calculate total stats for performance
func calculate_total_stats(creature_data: CreatureData) -> int:
	var total := 0
	for stat_key in STAT_NAMES:
		total += get_effective_stat(creature_data, STAT_NAMES[stat_key])
	return total

# Check if creature meets stat requirements
func meets_requirements(creature_data: CreatureData, requirements: Dictionary) -> bool:
	for stat_name in requirements:
		var required_value = requirements[stat_name]
		var creature_value = get_effective_stat(creature_data, stat_name)
		if creature_value < required_value:
			return false
	return true

# Compare two creatures' stats
func compare_stats(creature_a: CreatureData, creature_b: CreatureData, stat_name: String) -> int:
	var a_value := get_effective_stat(creature_a, stat_name)
	var b_value := get_effective_stat(creature_b, stat_name)
	return a_value - b_value

# Calculate stat-based performance score (uses competition stats with age modifier)
func calculate_performance(creature_data: CreatureData, weights: Dictionary = {}) -> float:
	var default_weights := {
		"strength": 0.15,
		"constitution": 0.15,
		"dexterity": 0.15,
		"intelligence": 0.15,
		"wisdom": 0.15,
		"discipline": 0.25
	}

	var final_weights := default_weights if weights.is_empty() else weights

	var score := 0.0
	for stat_name in final_weights:
		var stat_value := get_competition_stat(creature_data, stat_name)
		score += stat_value * final_weights[stat_name]

	return score

# Get stat growth rate based on training
func calculate_growth_rate(current_value: int, trainer_skill: int = 50) -> int:
	# Higher current values grow slower (diminishing returns)
	var difficulty_modifier := 1.0 - (current_value / float(STAT_MAX))
	var trainer_modifier := trainer_skill / 100.0
	var base_growth := randi_range(1, 5)

	return int(base_growth * difficulty_modifier * trainer_modifier)

# Validate stat distribution for new creatures
func validate_stat_distribution(stats: Dictionary) -> bool:
	var total := 0
	for stat_name in stats:
		var value = stats[stat_name]
		if value < STAT_MIN or value > STAT_MAX:
			return false
		total += value

	# Check if total is reasonable for starting creature
	var max_starting_total := 300  # 50 average per stat
	return total <= max_starting_total

# Get readable stat name
func get_stat_display_name(stat_key: String) -> String:
	match stat_key.to_upper():
		"STR", "STRENGTH": return "Strength"
		"CON", "CONSTITUTION": return "Constitution"
		"DEX", "DEXTERITY": return "Dexterity"
		"INT", "INTELLIGENCE": return "Intelligence"
		"WIS", "WISDOM": return "Wisdom"
		"DIS", "DISCIPLINE": return "Discipline"
		_: return stat_key.capitalize()

# Get stat breakdown for UI display
func get_stat_breakdown(creature_data: CreatureData, stat_name: String) -> Dictionary:
	var normalized_name := _normalize_stat_name(stat_name)
	var base := creature_data.get_stat(normalized_name)
	var age_mod := creature_data.get_age_modifier()
	var age_adjusted := int(base * age_mod)
	var temp_mod := 0
	var modifier_details := []

	if creature_data.id in active_modifiers and normalized_name in active_modifiers[creature_data.id]:
		var stat_mods = active_modifiers[creature_data.id][normalized_name]
		for modifier in stat_mods:
			modifier_details.append({
				"id": modifier.id,
				"value": modifier.value,
				"type": modifier.type,
				"stacking_mode": modifier.stacking_mode
			})
			if modifier.stacking_mode == StackingMode.ADDITIVE:
				temp_mod += modifier.value

	return {
		"base": base,
		"age_modifier": age_mod,
		"age_adjusted": age_adjusted,
		"temporary_modifier": temp_mod,
		"final": get_effective_stat(creature_data, normalized_name),
		"tier": get_stat_tier(get_effective_stat(creature_data, normalized_name)),
		"modifier_details": modifier_details
	}

# Generate unique modifier ID
func _generate_modifier_id() -> String:
	return "mod_" + str(Time.get_unix_time_from_system()) + "_" + str(randi_range(1000, 9999))

# Schedule modifier removal (placeholder for time system integration)
func _schedule_modifier_removal(_creature_id: String, _stat_name: String, _modifier_id: String, _duration_weeks: int) -> void:
	# Will connect to time system in later task
	pass

# Get all active modifiers for a creature
func get_creature_modifiers(creature_id: String) -> Dictionary:
	if creature_id in active_modifiers:
		return active_modifiers[creature_id].duplicate(true)
	return {}

# Check if creature has any modifiers
func has_modifiers(creature_id: String, stat_name: String = "") -> bool:
	if not creature_id in active_modifiers:
		return false

	if stat_name == "":
		return not active_modifiers[creature_id].is_empty()
	else:
		var normalized_name := _normalize_stat_name(stat_name)
		return normalized_name in active_modifiers[creature_id]
