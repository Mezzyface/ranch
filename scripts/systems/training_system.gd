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

# Training queue system
var training_queue: Array[Dictionary] = []  # Array of training entries
var active_trainings: Array[Dictionary] = []  # Currently in-progress trainings
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

	# Connect to time system for weekly updates
	if _signal_bus:
		_signal_bus.week_advanced.connect(_on_week_advanced)

# === CORE TRAINING METHODS ===

func schedule_training(creature: CreatureData, activity: TrainingActivity, facility_tier: FacilityTier = FacilityTier.BASIC, food_type: int = -1) -> Dictionary:
	"""Schedule a training session for a creature"""
	if not creature:
		return {"success": false, "reason": "Invalid creature data"}

	# Check if creature is already in training
	if _is_creature_in_training(creature.id):
		return {"success": false, "reason": "Creature already in training"}

	# Check facility availability
	if not _is_facility_available(facility_tier):
		return {"success": false, "reason": "No available facilities of tier %s" % get_facility_name(facility_tier)}

	# Get stamina system for validation
	if not _stamina_system:
		_stamina_system = GameCore.get_system("stamina")

	# Check stamina requirements (training costs 10 stamina)
	if _stamina_system and not _stamina_system.can_perform_activity(creature, 10):
		return {"success": false, "reason": "Insufficient stamina for training"}

	# Create training entry
	var training_entry: Dictionary = {
		"creature_id": creature.id,
		"creature_name": creature.creature_name,
		"activity": activity,
		"facility_tier": facility_tier,
		"start_week": _get_current_week(),
		"end_week": _get_current_week() + TRAINING_DURATION_WEEKS,
		"status": "scheduled",
		"food_type": food_type  # Store food type to consume when training starts
	}

	# Add to queue
	training_queue.append(training_entry)
	used_facilities[facility_tier] += 1

	# Emit signal
	if _signal_bus:
		_signal_bus.training_scheduled.emit(creature, get_activity_name(activity), get_facility_name(facility_tier))

	return {"success": true, "training_id": training_queue.size() - 1}

func cancel_training(creature_id: String) -> bool:
	"""Cancel a scheduled or active training"""
	# Check queue first
	for i in range(training_queue.size()):
		var entry = training_queue[i]
		if entry.creature_id == creature_id:
			used_facilities[entry.facility_tier] -= 1
			training_queue.remove_at(i)
			if _signal_bus:
				_signal_bus.training_cancelled.emit(creature_id, "scheduled")
			return true

	# Check active trainings
	for i in range(active_trainings.size()):
		var entry = active_trainings[i]
		if entry.creature_id == creature_id:
			used_facilities[entry.facility_tier] -= 1
			active_trainings.remove_at(i)
			if _signal_bus:
				_signal_bus.training_cancelled.emit(creature_id, "active")
			return true

	return false

func get_training_status(creature_id: String) -> Dictionary:
	"""Get the current training status for a creature"""
	# Check scheduled trainings
	for entry in training_queue:
		if entry.creature_id == creature_id:
			return {
				"status": "scheduled",
				"activity": get_activity_name(entry.activity),
				"facility": get_facility_name(entry.facility_tier),
				"weeks_remaining": entry.end_week - _get_current_week()
			}

	# Check active trainings
	for entry in active_trainings:
		if entry.creature_id == creature_id:
			return {
				"status": "active",
				"activity": get_activity_name(entry.activity),
				"facility": get_facility_name(entry.facility_tier),
				"weeks_remaining": entry.end_week - _get_current_week()
			}

	# Check completed this week
	for entry in completed_trainings:
		if entry.creature_id == creature_id:
			return {
				"status": "completed",
				"activity": get_activity_name(entry.activity),
				"facility": get_facility_name(entry.facility_tier),
				"stat_gains": entry.get("stat_gains", {})
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

func process_weekly_training() -> Dictionary:
	"""Process all training activities for the week"""
	var t0: int = Time.get_ticks_msec()
	var results: Dictionary = {
		"trainings_started": 0,
		"trainings_completed": 0,
		"stat_gains": [],
		"errors": []
	}

	# Get collection system for creature lookup
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")
		if not _collection_system:
			push_error("TrainingSystem.process_weekly_training: Collection system not available")
			return results

	# Move scheduled trainings to active
	var new_active: Array[Dictionary] = []
	for entry in training_queue:
		if entry.start_week <= _get_current_week():
			# Consume training food if specified
			if entry.has("food_type") and entry.food_type >= 0:
				_consume_training_food(entry.creature_id, entry.food_type)

			entry.status = "active"
			new_active.append(entry)
			results.trainings_started += 1

	# Remove started trainings from queue
	for entry in new_active:
		var index = training_queue.find(entry)
		if index >= 0:
			training_queue.remove_at(index)

	# Add to active trainings
	active_trainings.append_array(new_active)

	# Process completed trainings
	var completed_this_week: Array[Dictionary] = []
	for entry in active_trainings:
		if entry.end_week <= _get_current_week():
			var creature = _get_creature_by_id(entry.creature_id)
			if creature:
				var gains = _apply_training_gains(creature, entry.activity, entry.facility_tier)
				entry.stat_gains = gains
				entry.status = "completed"
				completed_this_week.append(entry)
				results.trainings_completed += 1
				results.stat_gains.append({
					"creature_name": creature.creature_name,
					"activity": get_activity_name(entry.activity),
					"gains": gains
				})

				# Update stats
				_stats.total_trainings += 1
				_stats.by_activity[entry.activity] += 1
				_stats.by_facility[entry.facility_tier] += 1
			else:
				results.errors.append("Creature %s not found for training completion" % entry.creature_id)

	# Remove completed trainings from active and free up facilities
	for entry in completed_this_week:
		var index = active_trainings.find(entry)
		if index >= 0:
			active_trainings.remove_at(index)
			used_facilities[entry.facility_tier] -= 1

	# Store completed trainings for this week
	completed_trainings = completed_this_week

	var dt: int = Time.get_ticks_msec() - t0
	if not _performance_mode:
		print("AI_NOTE: performance(process_weekly_training) = %d ms (baseline <100ms)" % dt)

	return results

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
	"""Check if a creature is already scheduled or in training"""
	for entry in training_queue:
		if entry.creature_id == creature_id:
			return true
	for entry in active_trainings:
		if entry.creature_id == creature_id:
			return true
	return false

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

func _on_week_advanced(_new_week: int, _total_weeks: int) -> void:
	"""Handle weekly time advancement"""
	process_weekly_training()

# === UTILITY METHODS ===

func get_activity_name(activity: TrainingActivity) -> String:
	"""Get display name for training activity"""
	return ACTIVITY_NAMES.get(activity, "Unknown Activity")

func get_facility_name(facility_tier: FacilityTier) -> String:
	"""Get display name for facility tier"""
	return FACILITY_NAMES.get(facility_tier, "Unknown Facility")

func get_training_queue() -> Array[Dictionary]:
	"""Get copy of current training queue"""
	return training_queue.duplicate()

func get_active_trainings() -> Array[Dictionary]:
	"""Get copy of current active trainings"""
	return active_trainings.duplicate()

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
		"training_queue": training_queue.duplicate(),
		"active_trainings": active_trainings.duplicate(),
		"completed_trainings": completed_trainings.duplicate(),
		"used_facilities": used_facilities.duplicate(),
		"statistics": _stats.duplicate()
	}

func load_state(data: Dictionary) -> void:
	"""Load training system state"""
	var queue_data = data.get("training_queue", [])
	var active_data = data.get("active_trainings", [])
	var completed_data = data.get("completed_trainings", [])

	training_queue.clear()
	active_trainings.clear()
	completed_trainings.clear()

	# Safely assign arrays
	for entry in queue_data:
		training_queue.append(entry)
	for entry in active_data:
		active_trainings.append(entry)
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