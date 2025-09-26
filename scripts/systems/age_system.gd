# AgeSystem - GameCore Subsystem for Creature Age Management
# Handles creature lifecycle progression, age category transitions, and time-based mechanics
extends Node

# Age category constants (matching CreatureData implementation)
const AGE_CATEGORIES := {
	0: "Baby",      # 0-10% of lifespan: 0.6x modifier
	1: "Juvenile",  # 10-25% of lifespan: 0.8x modifier
	2: "Adult",     # 25-75% of lifespan: 1.0x modifier
	3: "Elder",     # 75-90% of lifespan: 0.8x modifier
	4: "Ancient"    # 90%+ of lifespan: 0.6x modifier
}

const AGE_MODIFIERS := {
	0: 0.6,  # Baby
	1: 0.8,  # Juvenile
	2: 1.0,  # Adult
	3: 0.8,  # Elder
	4: 0.6   # Ancient
}

var signal_bus: SignalBus
var stat_system: Node  # Will be loaded as needed

func _ready() -> void:
	signal_bus = GameCore.get_signal_bus()
	print("AgeSystem initialized")

# === BASIC AGE PROGRESSION METHODS ===

func age_creature_by_weeks(creature_data: CreatureData, weeks: int) -> bool:
	"""Age a creature by specified number of weeks with category change detection."""
	if not creature_data:
		push_error("AgeSystem: Cannot age null creature_data")
		return false

	if weeks < 0:
		push_error("AgeSystem: Cannot age by negative weeks: %d" % weeks)
		return false

	if weeks == 0:
		return true  # No aging needed

	var old_age: int = creature_data.age_weeks
	var old_category: int = creature_data.get_age_category()

	# Apply aging
	creature_data.age_weeks += weeks

	var new_age: int = creature_data.age_weeks
	var new_category: int = creature_data.get_age_category()

	# Emit basic aging signal
	if signal_bus:
		signal_bus.emit_creature_aged(creature_data, new_age)

	# Check for category changes and expiration
	_check_age_category_change(creature_data, old_category, new_category)

	return true

func age_creature_to_category(creature_data: CreatureData, target_category: int) -> bool:
	"""Age a creature to a specific age category."""
	if not creature_data:
		push_error("AgeSystem: Cannot age null creature_data")
		return false

	if not GlobalEnums.is_valid_age_category(target_category):
		push_error("AgeSystem: Invalid target category: %d" % target_category)
		return false

	var current_category: GlobalEnums.AgeCategory = creature_data.get_age_category()
	if current_category >= target_category:
		return true  # Already at or past target category

	# Calculate weeks needed to reach target category
	var weeks_needed: int = get_weeks_to_category(creature_data, target_category)
	if weeks_needed <= 0:
		return true  # Already there or past it

	return age_creature_by_weeks(creature_data, weeks_needed)

func age_all_creatures(creature_list: Array[CreatureData], weeks: int) -> int:
	"""Age multiple creatures by specified weeks. Returns number of creatures aged successfully."""
	if weeks < 0:
		push_error("AgeSystem: Cannot age by negative weeks: %d" % weeks)
		return 0

	if weeks == 0:
		return creature_list.size()  # "Successfully" aged by 0

	var aged_count: int = 0
	var start_time: int = Time.get_ticks_msec()

	for creature_data in creature_list:
		if age_creature_by_weeks(creature_data, weeks):
			aged_count += 1

	var duration: int = Time.get_ticks_msec() - start_time
	print("AgeSystem: Aged %d creatures by %d weeks in %d ms" % [aged_count, weeks, duration])

	# Emit batch completion signal
	if signal_bus and signal_bus.has_signal("aging_batch_completed"):
		signal_bus.aging_batch_completed.emit(aged_count, weeks)

	return aged_count

# === LIFECYCLE EVENT DETECTION ===

func check_age_category_change(creature_data: CreatureData, old_age: int, new_age: int) -> Dictionary:
	"""Check if creature changed age categories. Returns change info."""
	if not creature_data:
		return {}

	# Calculate categories based on ages
	var old_life_percentage: float = (old_age / float(creature_data.lifespan_weeks)) * 100
	var new_life_percentage: float = (new_age / float(creature_data.lifespan_weeks)) * 100

	var old_category: int = _get_category_from_percentage(old_life_percentage)
	var new_category: int = _get_category_from_percentage(new_life_percentage)

	return {
		"old_category": old_category,
		"new_category": new_category,
		"changed": old_category != new_category,
		"old_age": old_age,
		"new_age": new_age
	}

func _check_age_category_change(creature_data: CreatureData, old_category: GlobalEnums.AgeCategory, new_category: GlobalEnums.AgeCategory) -> void:
	"""Internal method to handle age category changes and expiration."""
	if old_category != new_category:
		# Emit category change signal
		if signal_bus and signal_bus.has_signal("creature_category_changed"):
			signal_bus.creature_category_changed.emit(creature_data, old_category, new_category)

		# Update StatSystem if available (for age modifier changes)
		_notify_stat_system_age_change(creature_data)

	# Check for expiration
	if is_creature_expired(creature_data):
		if signal_bus and signal_bus.has_signal("creature_expired"):
			signal_bus.creature_expired.emit(creature_data)

func is_creature_expired(creature_data: CreatureData) -> bool:
	"""Check if creature has exceeded its lifespan."""
	if not creature_data:
		return false

	return creature_data.age_weeks >= creature_data.lifespan_weeks

func get_weeks_until_next_category(creature_data: CreatureData) -> int:
	"""Get weeks until creature reaches next age category."""
	if not creature_data:
		return 0

	var current_category: GlobalEnums.AgeCategory = creature_data.get_age_category()
	if current_category >= 4:  # Ancient is max category
		return 0

	var next_category: int = current_category + 1
	return get_weeks_to_category(creature_data, next_category)

func get_weeks_to_category(creature_data: CreatureData, target_category: int) -> int:
	"""Calculate weeks needed to reach target age category."""
	if not creature_data:
		return 0

	if not GlobalEnums.is_valid_age_category(target_category):
		return 0

	# Calculate target age based on category thresholds
	var target_percentage: float
	match target_category:
		0: target_percentage = 0.0   # Baby (start)
		1: target_percentage = 10.0  # Juvenile
		2: target_percentage = 25.0  # Adult
		3: target_percentage = 75.0  # Elder
		4: target_percentage = 90.0  # Ancient
		_: return 0

	var target_weeks: int = int((target_percentage / 100.0) * creature_data.lifespan_weeks)
	var weeks_needed: int = target_weeks - creature_data.age_weeks

	return max(0, weeks_needed)

# === AGE STATISTICS & ANALYSIS ===

func get_age_distribution(creature_list: Array[CreatureData]) -> Dictionary:
	"""Analyze age distribution of creature population."""
	var distribution: Dictionary = {
		"total_creatures": creature_list.size(),
		"categories": {
			0: 0,  # Baby
			1: 0,  # Juvenile
			2: 0,  # Adult
			3: 0,  # Elder
			4: 0   # Ancient
		},
		"average_age": 0.0,
		"expired_count": 0,
		"category_names": AGE_CATEGORIES
	}

	if creature_list.is_empty():
		return distribution

	var total_age: int = 0
	for creature_data in creature_list:
		if not creature_data:
			continue

		total_age += creature_data.age_weeks
		var category: GlobalEnums.AgeCategory = creature_data.get_age_category()
		if category in distribution.categories:
			distribution.categories[category] += 1

		if is_creature_expired(creature_data):
			distribution.expired_count += 1

	distribution.average_age = total_age / float(creature_list.size())

	return distribution

func get_lifespan_remaining(creature_data: CreatureData) -> int:
	"""Get weeks remaining in creature's lifespan."""
	if not creature_data:
		return 0

	var remaining: int = creature_data.lifespan_weeks - creature_data.age_weeks
	return max(0, remaining)

func calculate_age_performance_impact(creature_data: CreatureData) -> Dictionary:
	"""Calculate how age affects creature's performance."""
	if not creature_data:
		return {}

	var age_modifier: float = creature_data.get_age_modifier()
	var category: int = creature_data.get_age_category()
	var category_name: String = AGE_CATEGORIES.get(category, "Unknown")

	return {
		"age_weeks": creature_data.age_weeks,
		"lifespan_weeks": creature_data.lifespan_weeks,
		"life_percentage": (creature_data.age_weeks / float(creature_data.lifespan_weeks)) * 100,
		"category": category,
		"category_name": category_name,
		"age_modifier": age_modifier,
		"performance_impact": (age_modifier - 1.0) * 100,  # Percentage impact
		"weeks_remaining": get_lifespan_remaining(creature_data),
		"is_expired": is_creature_expired(creature_data)
	}

# === TIME INTEGRATION PREPARATION ===

func advance_week() -> Dictionary:
	"""Advance all active creatures by 1 week. Returns aging summary."""
	# This will be implemented when we have creature collections
	# For now, return empty summary
	return {
		"creatures_aged": 0,
		"category_changes": 0,
		"expirations": 0
	}

func process_aging_events() -> Dictionary:
	"""Process all pending aging events. Returns event summary."""
	# This will be implemented when we have event queuing
	# For now, return empty summary
	return {
		"events_processed": 0,
		"category_changes": 0,
		"expirations": 0
	}

# === UTILITY METHODS ===

func get_category_name(category_id: int) -> String:
	"""Get display name for age category."""
	return AGE_CATEGORIES.get(category_id, "Unknown")

func get_category_modifier(category_id: int) -> float:
	"""Get performance modifier for age category."""
	return AGE_MODIFIERS.get(category_id, 1.0)

func _get_category_from_percentage(life_percentage: float) -> int:
	"""Calculate age category from life percentage."""
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

func _notify_stat_system_age_change(creature_data: CreatureData) -> void:
	"""Notify StatSystem of age-related changes for modifier updates."""
	if not stat_system:
		stat_system = GameCore.get_system("stat")

	# StatSystem already handles age modifiers through get_competition_stat()
	# Just emit signal to notify of potential stat changes due to age
	if signal_bus:
		signal_bus.emit_creature_modifiers_changed(creature_data.id, "age_category")

# === DEBUG & VALIDATION ===

func validate_creature_age(creature_data: CreatureData) -> Dictionary:
	"""Validate creature age data for debugging."""
	if not creature_data:
		return {
			"valid": false,
			"errors": ["Null creature data"]
		}

	var errors: Array[String] = []

	if creature_data.age_weeks < 0:
		errors.append("Negative age: %d" % creature_data.age_weeks)

	if creature_data.lifespan_weeks <= 0:
		errors.append("Invalid lifespan: %d" % creature_data.lifespan_weeks)

	if creature_data.age_weeks > creature_data.lifespan_weeks:
		errors.append("Age exceeds lifespan: %d > %d" % [creature_data.age_weeks, creature_data.lifespan_weeks])

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"age_weeks": creature_data.age_weeks,
		"lifespan_weeks": creature_data.lifespan_weeks,
		"category": creature_data.get_age_category(),
		"modifier": creature_data.get_age_modifier()
	}