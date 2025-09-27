class_name TrainingSystem extends Node

# Training Activity Types
enum TrainingActivity {
	PHYSICAL = 0,    # Targets Strength & Constitution
	AGILITY = 1,     # Targets Dexterity
	MENTAL = 2,      # Targets Intelligence & Wisdom
	DISCIPLINE = 3   # Targets Discipline
}

# Training Facility Tiers
enum FacilityTier {
	BASIC = 0,       # 1.0x multiplier
	ADVANCED = 1,    # 1.5x multiplier
	ELITE = 2        # 2.0x multiplier
}

# Training duration (in weeks)
const TRAINING_DURATION_WEEKS: int = 1

# Base stat gains per training activity (before facility multipliers)
const BASE_STAT_GAINS: Dictionary = {
	TrainingActivity.PHYSICAL: {
		"strength": {"min": 5, "max": 15},
		"constitution": {"min": 5, "max": 15}
	},
	TrainingActivity.AGILITY: {
		"dexterity": {"min": 5, "max": 15}
	},
	TrainingActivity.MENTAL: {
		"intelligence": {"min": 5, "max": 15},
		"wisdom": {"min": 5, "max": 15}
	},
	TrainingActivity.DISCIPLINE: {
		"discipline": {"min": 5, "max": 15}
	}
}

# Facility tier multipliers
const FACILITY_MULTIPLIERS: Dictionary = {
	FacilityTier.BASIC: 1.0,
	FacilityTier.ADVANCED: 1.5,
	FacilityTier.ELITE: 2.0
}

# Facility names for display
const FACILITY_NAMES: Dictionary = {
	FacilityTier.BASIC: "Basic",
	FacilityTier.ADVANCED: "Advanced",
	FacilityTier.ELITE: "Elite"
}

# Training activity names
const ACTIVITY_NAMES: Dictionary = {
	TrainingActivity.PHYSICAL: "Physical Training",
	TrainingActivity.AGILITY: "Agility Training",
	TrainingActivity.MENTAL: "Mental Training",
	TrainingActivity.DISCIPLINE: "Discipline Training"
}

# Training assignment system (replaces queue-based system)
var creature_training_assignments: Dictionary = {}  # creature_id -> {activity, facility_tier, food_type}
var completed_trainings: Array[Dictionary] = []  # Completed this week

# Facility availability per tier
var available_facilities: Dictionary = {
	FacilityTier.BASIC: 10,     # 10 basic training slots
	FacilityTier.ADVANCED: 5,   # 5 advanced training slots
	FacilityTier.ELITE: 2       # 2 elite training slots
}

var used_facilities: Dictionary = {
	FacilityTier.BASIC: 0,
	FacilityTier.ADVANCED: 0,
	FacilityTier.ELITE: 0
}

# System dependencies
var _signal_bus: SignalBus = null
var _collection_system = null
var _stamina_system = null
var _time_system = null
var _performance_mode: bool = false

# Performance tracking
var _stats: Dictionary = {
	"total_trainings": 0,
	"by_activity": {},
	"by_facility": {}
}

func _ready() -> void:
	print("TrainingSystem initialized")
	_signal_bus = GameCore.get_signal_bus()

	# Initialize stats tracking
	for activity in TrainingActivity.values():
		_stats.by_activity[activity] = 0
	for tier in FacilityTier.values():
		_stats.by_facility[tier] = 0

	# Connect to stamina system for training activity events
	if _signal_bus:
		_signal_bus.stamina_activity_performed.connect(_on_training_activity_performed)

# === CORE TRAINING METHODS ===

func schedule_training(creature: CreatureData, activity: TrainingActivity, facility_tier: FacilityTier = FacilityTier.BASIC, food_type: int = -1) -> Dictionary:
	"""Schedule a training assignment for a creature (assigns training activity to StaminaSystem)"""
	if not creature:
		return {"success": false, "reason": "Invalid creature data"}

	# Check if creature already has a training assignment
	if creature_training_assignments.has(creature.id):
		return {"success": false, "reason": "Creature already has training assignment"}

	# Check facility availability
	if not _is_facility_available(facility_tier):
		return {"success": false, "reason": "No available facilities of tier %s" % get_facility_name(facility_tier)}

	# Get stamina system to assign training activity
	if not _stamina_system:
		_stamina_system = GameCore.get_system("stamina")

	if not _stamina_system:
		return {"success": false, "reason": "StaminaSystem not available"}

	# Check stamina requirements (training costs 10 stamina according to StaminaSystem)
	if not _stamina_system.can_perform_activity(creature, 10):
		return {"success": false, "reason": "Insufficient stamina for training"}

	# Store training assignment details
	creature_training_assignments[creature.id] = {
		"activity": activity,
		"facility_tier": facility_tier,
		"food_type": food_type
	}

	# Assign TRAINING activity to StaminaSystem
	var assigned = _stamina_system.assign_activity(creature, _stamina_system.Activity.TRAINING)
	if not assigned:
		creature_training_assignments.erase(creature.id)
		return {"success": false, "reason": "Failed to assign training activity"}

	# Consume training food immediately when training is assigned
	if food_type >= 0:
		_consume_training_food(creature.id, food_type)

	used_facilities[facility_tier] += 1

	# Emit signal
	if _signal_bus:
		_signal_bus.training_scheduled.emit(creature, get_activity_name(activity), get_facility_name(facility_tier))

	return {"success": true}

func cancel_training(creature_id: String) -> bool:
	"""Cancel a training assignment"""
	if not creature_training_assignments.has(creature_id):
		return false

	var assignment = creature_training_assignments[creature_id]
	used_facilities[assignment.facility_tier] -= 1
	creature_training_assignments.erase(creature_id)

	# Remove training activity from StaminaSystem
	var creature = _get_creature_by_id(creature_id)
	if _stamina_system and creature:
		_stamina_system.assign_activity(creature, _stamina_system.Activity.IDLE)

	if _signal_bus:
		_signal_bus.training_cancelled.emit(creature_id, "assigned")

	return true

func get_training_status(creature_id: String) -> Dictionary:
	"""Get the current training status for a creature"""
	# Check training assignments
	if creature_training_assignments.has(creature_id):
		var assignment = creature_training_assignments[creature_id]
		return {
			"status": "assigned",
			"activity": get_activity_name(assignment.activity),
			"facility": get_facility_name(assignment.facility_tier),
			"food_type": assignment.food_type
		}

	return {"status": "none"}

func get_available_slots(facility_tier: FacilityTier) -> int:
	"""Get number of available training slots for a facility tier"""
	return available_facilities.get(facility_tier, 0) - used_facilities.get(facility_tier, 0)

func get_facility_utilization() -> Dictionary:
	"""Get current facility utilization stats"""
	var utilization: Dictionary = {}
	for tier in FacilityTier.values():
		var available = available_facilities.get(tier, 0)
		var used = used_facilities.get(tier, 0)
		utilization[tier] = {
			"tier_name": get_facility_name(tier),
			"available": available,
			"used": used,
			"utilization_percent": float(used) / float(available) * 100.0 if available > 0 else 0.0
		}
	return utilization

# === BATCH PROCESSING ===


func batch_schedule_training(training_requests: Array[Dictionary]) -> Dictionary:
	"""Batch schedule multiple training sessions with performance optimization"""
	var t0: int = Time.get_ticks_msec()
	var results: Dictionary = {
		"successful": 0,
		"failed": 0,
		"errors": []
	}

	# Pre-validate all requests to avoid partial failures
	for request in training_requests:
		if not request.has("creature_id") or not request.has("activity"):
			results.errors.append("Invalid training request format")
			results.failed += 1
			continue

		var creature = _get_creature_by_id(request.creature_id)
		if not creature:
			results.errors.append("Creature %s not found" % request.creature_id)
			results.failed += 1
			continue

		var facility_tier = request.get("facility_tier", FacilityTier.BASIC)
		var schedule_result = schedule_training(creature, request.activity, facility_tier)

		if schedule_result.success:
			results.successful += 1
		else:
			results.failed += 1
			results.errors.append("Failed to schedule training for %s: %s" % [creature.creature_name, schedule_result.reason])

	var dt: int = Time.get_ticks_msec() - t0
	if not _performance_mode:
		print("AI_NOTE: performance(batch_schedule_training_%d) = %d ms (baseline <100ms)" % [training_requests.size(), dt])

	return results

# === HELPER METHODS ===

func _consume_training_food(creature_id: String, food_type: int) -> bool:
	"""Consume training food for a creature when training starts"""
	# Get food system to consume the item
	var food_system = GameCore.get_system("food")
	if not food_system:
		print("Warning: FoodSystem not available for food consumption")
		return false

	# Define food item IDs
	var food_items = ["power_bar", "speed_snack", "brain_food", "focus_tea"]
	if food_type < 0 or food_type >= food_items.size():
		print("Warning: Invalid food type %d" % food_type)
		return false

	var item_id = food_items[food_type]

	# Check if we have the food item using ResourceTracker
	var resource_tracker = GameCore.get_system("resource")
	if not resource_tracker:
		print("Warning: ResourceTracker not available for food consumption")
		return false

	var inventory = resource_tracker.get_inventory()
	if not inventory.has(item_id) or inventory[item_id] <= 0:
		print("Warning: No %s available for training" % item_id)
		return false

	# Consume the food item through ResourceTracker
	if resource_tracker.remove_item(item_id, 1):
		print("Consumed %s for creature %s training" % [item_id, creature_id])
		return true
	else:
		print("Failed to consume %s for training" % item_id)
		return false

func _apply_training_gains(creature: CreatureData, activity: TrainingActivity, facility_tier: FacilityTier) -> Dictionary:
	"""Apply stat gains from training to a creature"""
	var gains: Dictionary = {}
	var multiplier: float = FACILITY_MULTIPLIERS.get(facility_tier, 1.0)
	var base_gains = BASE_STAT_GAINS.get(activity, {})

	# Get food system for training food bonuses
	var food_system = GameCore.get_system("food")

	for stat_name in base_gains.keys():
		var stat_range = base_gains[stat_name]
		var base_gain = randi_range(stat_range.min, stat_range.max)

		# Apply facility multiplier
		var gain_with_facility = base_gain * multiplier

		# Apply training food multiplier if applicable
		var food_multiplier = food_system.get_training_multiplier_for_stat(creature.id, stat_name) if food_system else 1.0
		var actual_gain = int(gain_with_facility * food_multiplier)

		# Apply the gain
		var old_value = creature.get_stat(stat_name)
		creature.set_stat(stat_name, old_value + actual_gain)
		gains[stat_name] = actual_gain

		# Emit signal for stat change
		if _signal_bus:
			_signal_bus.emit_creature_stats_changed(creature, stat_name, old_value, creature.get_stat(stat_name))

	# Deduct stamina cost
	if _stamina_system:
		_stamina_system.deplete_stamina(creature, 10)

	# Emit training completed signal
	if _signal_bus:
		_signal_bus.training_completed.emit(creature, get_activity_name(activity), gains)

	return gains

func _is_creature_in_training(creature_id: String) -> bool:
	"""Check if a creature has a training assignment"""
	return creature_training_assignments.has(creature_id)

func _is_facility_available(facility_tier: FacilityTier) -> bool:
	"""Check if a facility tier has available slots"""
	return get_available_slots(facility_tier) > 0

func _get_creature_by_id(creature_id: String) -> CreatureData:
	"""Get creature data by ID from collection system"""
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")

	if not _collection_system:
		return null

	# Search active creatures first
	var active_creatures = _collection_system.get_active_creatures()
	for creature in active_creatures:
		if creature.id == creature_id:
			return creature

	# Search stable creatures
	var stable_creatures = _collection_system.get_stable_creatures()
	for creature in stable_creatures:
		if creature.id == creature_id:
			return creature

	return null

func _get_current_week() -> int:
	"""Get current week from time system"""
	if not _time_system:
		_time_system = GameCore.get_system("time")

	if _time_system and _time_system.has_method("get_current_week"):
		return _time_system.get_current_week()

	# Fallback - assume week 1 if time system not available
	return 1

func _on_training_activity_performed(creature_data: CreatureData, activity: String, cost: int) -> void:
	"""Handle when a creature performs training activity (called by StaminaSystem)"""
	if activity != "TRAINING":
		return  # Not a training activity

	if not creature_training_assignments.has(creature_data.id):
		print("Warning: Creature %s performed training but has no training assignment" % creature_data.creature_name)
		return

	var assignment = creature_training_assignments[creature_data.id]
	var training_activity = assignment.activity
	var facility_tier = assignment.facility_tier

	# Apply training gains immediately
	var gains = _apply_training_gains(creature_data, training_activity, facility_tier)

	# Record completed training
	var completion_record = {
		"creature_id": creature_data.id,
		"creature_name": creature_data.creature_name,
		"activity": training_activity,
		"facility_tier": facility_tier,
		"stat_gains": gains,
		"week": _get_current_week()
	}
	completed_trainings.append(completion_record)

	# Clear assignment (training is one-time)
	creature_training_assignments.erase(creature_data.id)
	used_facilities[facility_tier] -= 1

	# Clear training activity assignment from StaminaSystem
	if _stamina_system:
		_stamina_system.assign_activity(creature_data, _stamina_system.Activity.IDLE)

	# Update stats
	_stats.total_trainings += 1
	_stats.by_activity[training_activity] += 1
	_stats.by_facility[facility_tier] += 1

	# Emit completion signal
	if _signal_bus:
		_signal_bus.training_completed.emit(creature_data, get_activity_name(training_activity), gains)

	print("Training completed: %s gained %s from %s" % [creature_data.creature_name, gains, get_activity_name(training_activity)])

# === UTILITY METHODS ===

func get_activity_name(activity: TrainingActivity) -> String:
	"""Get display name for training activity"""
	return ACTIVITY_NAMES.get(activity, "Unknown Activity")

func get_facility_name(facility_tier: FacilityTier) -> String:
	"""Get display name for facility tier"""
	return FACILITY_NAMES.get(facility_tier, "Unknown Facility")

func get_training_assignments() -> Dictionary:
	"""Get copy of current training assignments"""
	return creature_training_assignments.duplicate()

func get_completed_trainings() -> Array[Dictionary]:
	"""Get copy of completed trainings from this week"""
	return completed_trainings.duplicate()

func get_training_statistics() -> Dictionary:
	"""Get training system statistics"""
	return _stats.duplicate()

func reset_statistics() -> void:
	"""Reset training statistics"""
	_stats.total_trainings = 0
	for activity in TrainingActivity.values():
		_stats.by_activity[activity] = 0
	for tier in FacilityTier.values():
		_stats.by_facility[tier] = 0

func set_performance_mode(enabled: bool) -> void:
	"""Enable/disable performance logging"""
	_performance_mode = enabled

# === SAVE/LOAD SUPPORT ===

func save_state() -> Dictionary:
	"""Save training system state"""
	return {
		"creature_training_assignments": creature_training_assignments.duplicate(),
		"completed_trainings": completed_trainings.duplicate(),
		"used_facilities": used_facilities.duplicate(),
		"statistics": _stats.duplicate()
	}

func load_state(data: Dictionary) -> void:
	"""Load training system state"""
	var assignments_data = data.get("creature_training_assignments", {})
	var completed_data = data.get("completed_trainings", [])

	creature_training_assignments.clear()
	completed_trainings.clear()

	# Load assignments
	for creature_id in assignments_data:
		creature_training_assignments[creature_id] = assignments_data[creature_id]

	# Load completed trainings
	for entry in completed_data:
		completed_trainings.append(entry)
	used_facilities = data.get("used_facilities", {
		FacilityTier.BASIC: 0,
		FacilityTier.ADVANCED: 0,
		FacilityTier.ELITE: 0
	})
	_stats = data.get("statistics", {
		"total_trainings": 0,
		"by_activity": {},
		"by_facility": {}
	})

	# Ensure stats dictionaries are properly initialized
	for activity in TrainingActivity.values():
		if not _stats.by_activity.has(activity):
			_stats.by_activity[activity] = 0
	for tier in FacilityTier.values():
		if not _stats.by_facility.has(tier):
			_stats.by_facility[tier] = 0
