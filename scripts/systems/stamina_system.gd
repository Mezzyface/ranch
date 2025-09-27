class_name StaminaSystem extends Node

# Constants
const MAX_STAMINA: int = 100
const MIN_STAMINA: int = 0
const EXHAUSTION_THRESHOLD: int = 20

# Activity costs
enum Activity {
	IDLE = 0,        # No stamina change
	REST = -20,      # Negative value = restoration
	TRAINING = 10,
	QUEST = 15,
	COMPETITION = 25,
	BREEDING = 30
}

# Food stamina restoration values
const FOOD_STAMINA_VALUES: Dictionary = {
	"basic_food": 10,
	"standard_food": 20,
	"quality_food": 30,
	"premium_food": 50,
	"energy_drink": 40,
	"stamina_potion": 100
}

# Stamina tracking
var creature_stamina: Dictionary = {}  # creature_id -> int
var creature_activities: Dictionary = {}  # creature_id -> Activity
var depletion_modifiers: Dictionary = {}  # creature_id -> float
var recovery_modifiers: Dictionary = {}  # creature_id -> float
var exhausted_creatures: Dictionary = {}  # creature_id -> bool

# System state
var _signal_bus: SignalBus = null
var _collection_system = null
var _time_system = null
var _performance_mode: bool = false

func _ready() -> void:
	print("StaminaSystem initialized")
	_signal_bus = GameCore.get_signal_bus()

	# Initialize required dependencies (fail-fast)
	_collection_system = GameCore.get_system("collection")
	if not _collection_system:
		push_error("StaminaSystem: CRITICAL - Collection system not available. Cannot initialize.")
		# Don't set_process(false) as system might load later, but log the error

	# Connect to signals for system coordination
	if _signal_bus:
		_signal_bus.week_advanced.connect(_on_week_advanced)
		_signal_bus.creature_cleanup_required.connect(_on_creature_cleanup_required)

func get_stamina(creature: CreatureData) -> int:
	if not creature:
		push_error("StaminaSystem.get_stamina: Invalid creature data")
		return 0

	# Use creature's built-in stamina if not tracked separately
	if not creature_stamina.has(creature.id):
		creature_stamina[creature.id] = creature.stamina_current

	return creature_stamina.get(creature.id, MAX_STAMINA)

func set_stamina(creature: CreatureData, value: int) -> void:
	if not creature:
		push_error("StaminaSystem.set_stamina: Invalid creature data")
		return

	var old_stamina: int = get_stamina(creature)
	var new_stamina: int = clampi(value, MIN_STAMINA, creature.stamina_max)

	creature_stamina[creature.id] = new_stamina
	creature.stamina_current = new_stamina

	# Check exhaustion state changes
	var was_exhausted: bool = exhausted_creatures.get(creature.id, false)
	var is_exhausted_now: bool = new_stamina <= EXHAUSTION_THRESHOLD

	if is_exhausted_now and not was_exhausted:
		exhausted_creatures[creature.id] = true
		if _signal_bus:
			_signal_bus.creature_exhausted.emit(creature)
	elif not is_exhausted_now and was_exhausted:
		exhausted_creatures[creature.id] = false
		if _signal_bus:
			_signal_bus.creature_recovered.emit(creature)

func deplete_stamina(creature: CreatureData, amount: int) -> bool:
	if not creature or amount <= 0:
		return false

	var current: int = get_stamina(creature)
	if current <= 0:
		return false

	var modifier: float = depletion_modifiers.get(creature.id, 1.0)
	var actual_depletion: int = int(amount * modifier)
	var new_stamina: int = max(MIN_STAMINA, current - actual_depletion)

	set_stamina(creature, new_stamina)

	if _signal_bus:
		_signal_bus.stamina_depleted.emit(creature, actual_depletion)

	return true

func restore_stamina(creature: CreatureData, amount: int) -> void:
	if not creature or amount <= 0:
		return

	var current: int = get_stamina(creature)
	if current >= creature.stamina_max:
		return

	var modifier: float = recovery_modifiers.get(creature.id, 1.0)
	var actual_recovery: int = int(amount * modifier)
	var new_stamina: int = min(creature.stamina_max, current + actual_recovery)

	set_stamina(creature, new_stamina)

	if _signal_bus:
		_signal_bus.stamina_restored.emit(creature, actual_recovery)

func is_exhausted(creature: CreatureData) -> bool:
	if not creature:
		return true
	return get_stamina(creature) <= EXHAUSTION_THRESHOLD

func can_perform_activity(creature: CreatureData, cost: int) -> bool:
	if not creature:
		return false
	return get_stamina(creature) >= cost

func assign_activity(creature: CreatureData, activity: Activity) -> bool:
	if not creature:
		return false

	# Check if creature has enough stamina for the activity
	if activity > 0 and not can_perform_activity(creature, activity):
		return false

	creature_activities[creature.id] = activity

	if _signal_bus:
		_signal_bus.activity_assigned.emit(creature, activity)

	return true

func get_assigned_activity(creature: CreatureData) -> Activity:
	if not creature:
		return Activity.IDLE
	return creature_activities.get(creature.id, Activity.IDLE)

func get_activity_name(activity: Activity) -> String:
	match activity:
		Activity.IDLE: return "IDLE"
		Activity.REST: return "REST"
		Activity.TRAINING: return "TRAINING"
		Activity.QUEST: return "QUEST"
		Activity.COMPETITION: return "COMPETITION"
		Activity.BREEDING: return "BREEDING"
		_: return "UNKNOWN"

func perform_activity(creature: CreatureData, activity: Activity, activity_name: String = "") -> bool:
	if not creature:
		return false

	# Handle restoration activities (negative values)
	if activity < 0:
		restore_stamina(creature, abs(int(activity)))
		if _signal_bus:
			_signal_bus.stamina_activity_performed.emit(creature, activity, abs(int(activity)))
		return true

	# Handle depletion activities (positive values)
	if activity > 0:
		if not can_perform_activity(creature, activity):
			return false
		deplete_stamina(creature, activity)
		if _signal_bus:
			_signal_bus.stamina_activity_performed.emit(creature, activity, abs(int(activity)))
		return true

	# IDLE activity (no change)
	return true

func apply_food_effect(creature: CreatureData, food_type: String) -> void:
	if not creature:
		push_error("StaminaSystem.apply_food_effect: Invalid creature data")
		return

	var restoration: int = FOOD_STAMINA_VALUES.get(food_type, 10)
	restore_stamina(creature, restoration)

	if _signal_bus:
		_signal_bus.food_consumed.emit(creature, food_type)

func set_depletion_modifier(creature: CreatureData, modifier: float) -> void:
	if not creature:
		return
	depletion_modifiers[creature.id] = max(0.1, modifier)

func set_recovery_modifier(creature: CreatureData, modifier: float) -> void:
	if not creature:
		return
	recovery_modifiers[creature.id] = max(0.1, modifier)

func clear_modifiers(creature: CreatureData) -> void:
	if not creature:
		return
	depletion_modifiers.erase(creature.id)
	recovery_modifiers.erase(creature.id)

func deplete_weekly(creature: CreatureData) -> void:
	# Stamina is only depleted through assigned activities
	# No passive weekly drain
	pass

func restore_weekly(creature: CreatureData) -> void:
	# Stamina is only restored through assigned activities (like rest)
	# No passive weekly recovery
	pass

func process_weekly_activities(skip_creature_ids: Array[String] = []) -> Dictionary:
	var t0: int = Time.get_ticks_msec()
	var results: Dictionary = {
		"activities_performed": [],
		"stamina_changes": []
	}

	# Ensure collection system is available (fail-fast)
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")
		if not _collection_system:
			push_error("StaminaSystem.process_weekly_activities: CRITICAL - Collection system not available. Cannot process activities.")
			results["error"] = "Collection system not available"
			results["failed"] = true
			return results

	# Process assigned activities for active creatures
	var active_creatures: Array[CreatureData] = _collection_system.get_active_creatures()
	for creature in active_creatures:
		# Skip expired creatures
		if creature.id in skip_creature_ids:
			continue
		var activity = get_assigned_activity(creature)
		if activity != Activity.IDLE:
			var before_stamina = get_stamina(creature)
			if perform_activity(creature, activity):
				var after_stamina = get_stamina(creature)
				results.activities_performed.append({
					"creature": creature.creature_name,
					"activity": get_activity_name(activity),
					"stamina_change": after_stamina - before_stamina
				})
			else:
				# Activity failed (insufficient stamina)
				results.activities_performed.append({
					"creature": creature.creature_name,
					"activity": get_activity_name(activity),
					"failed": true,
					"reason": "insufficient_stamina"
				})

	# Stable creatures remain idle (no activities)
	var stable_creatures: Array[CreatureData] = _collection_system.get_stable_creatures()
	# Stable creatures don't perform activities

	if _signal_bus:
		_signal_bus.stamina_weekly_processed.emit(active_creatures.size(), stable_creatures.size())

	var dt: int = Time.get_ticks_msec() - t0
	if not _performance_mode:
		print("AI_NOTE: performance(process_weekly_activities) = %d ms (baseline <50ms)" % dt)

	return results

func process_weekly_stamina() -> void:
	# Redirect to new activity-based system
	process_weekly_activities()

func _on_week_advanced(_new_week: int, _total_weeks: int) -> void:
	process_weekly_stamina()

func cleanup_creature(creature: CreatureData) -> void:
	if not creature:
		return

	creature_stamina.erase(creature.id)
	creature_activities.erase(creature.id)
	depletion_modifiers.erase(creature.id)
	recovery_modifiers.erase(creature.id)
	exhausted_creatures.erase(creature.id)

func _on_creature_cleanup_required(creature_id: String) -> void:
	"""Handle creature cleanup signal from collection system"""
	if creature_id.is_empty():
		return

	# Clean up all references to this creature ID
	creature_stamina.erase(creature_id)
	creature_activities.erase(creature_id)
	depletion_modifiers.erase(creature_id)
	recovery_modifiers.erase(creature_id)
	exhausted_creatures.erase(creature_id)

# Helper function to auto-assign activities based on stamina levels
func auto_assign_activities() -> void:
	if not _collection_system:
		_collection_system = GameCore.get_system("collection")
		if not _collection_system:
			return

	var active_creatures = _collection_system.get_active_creatures()
	for creature in active_creatures:
		var stamina = get_stamina(creature)
		var current_activity = get_assigned_activity(creature)

		# Only reassign if creature is idle
		if current_activity == Activity.IDLE:
			if stamina < 30:
				# Low stamina - assign rest
				assign_activity(creature, Activity.REST)
			elif stamina >= 80:
				# High stamina - can do intensive activities
				# For now, randomly assign between training and idle
				if randf() > 0.5:
					assign_activity(creature, Activity.TRAINING)
			# Otherwise remain idle

# Save/Load support
func save_state() -> Dictionary:
	return {
		"creature_stamina": creature_stamina.duplicate(),
		"creature_activities": creature_activities.duplicate(),
		"depletion_modifiers": depletion_modifiers.duplicate(),
		"recovery_modifiers": recovery_modifiers.duplicate(),
		"exhausted_creatures": exhausted_creatures.duplicate()
	}

func load_state(data: Dictionary) -> void:
	creature_stamina = data.get("creature_stamina", {})
	creature_activities = data.get("creature_activities", {})
	depletion_modifiers = data.get("depletion_modifiers", {})
	recovery_modifiers = data.get("recovery_modifiers", {})
	exhausted_creatures = data.get("exhausted_creatures", {})

func set_performance_mode(enabled: bool) -> void:
	_performance_mode = enabled