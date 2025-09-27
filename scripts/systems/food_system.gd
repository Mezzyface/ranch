extends Node
class_name FoodSystem

# Training food effectiveness multiplier
const TRAINING_FOOD_MULTIPLIER: float = 1.5  # +50% effectiveness

# Training food types and their stat targets
enum TrainingFoodType {
	POWER_BAR = 0,     # +STR/CON training
	SPEED_SNACK = 1,   # +DEX training
	BRAIN_FOOD = 2,    # +INT/WIS training
	FOCUS_TEA = 3      # +DIS training
}

# Mapping of training foods to affected stats
const TRAINING_FOOD_STATS: Dictionary = {
	TrainingFoodType.POWER_BAR: ["strength", "constitution"],
	TrainingFoodType.SPEED_SNACK: ["dexterity"],
	TrainingFoodType.BRAIN_FOOD: ["intelligence", "wisdom"],
	TrainingFoodType.FOCUS_TEA: ["discipline"]
}

# Training food display names
const TRAINING_FOOD_NAMES: Dictionary = {
	TrainingFoodType.POWER_BAR: "Power Bar",
	TrainingFoodType.SPEED_SNACK: "Speed Snack",
	TrainingFoodType.BRAIN_FOOD: "Brain Food",
	TrainingFoodType.FOCUS_TEA: "Focus Tea"
}

# Training food item IDs
const TRAINING_FOOD_IDS: Dictionary = {
	TrainingFoodType.POWER_BAR: "power_bar",
	TrainingFoodType.SPEED_SNACK: "speed_snack",
	TrainingFoodType.BRAIN_FOOD: "brain_food",
	TrainingFoodType.FOCUS_TEA: "focus_tea"
}

# Active training food effects per creature
var active_effects: Dictionary = {}  # creature_id -> {food_type: TrainingFoodType, expires_week: int}

# System dependencies
var _signal_bus: SignalBus = null
var _resource_tracker = null
var _time_system = null

func _ready() -> void:
	print("FoodSystem initialized")
	_signal_bus = GameCore.get_signal_bus()

	# Connect to feeding signals
	if _signal_bus:
		_signal_bus.creature_fed.connect(_on_creature_fed)
		_signal_bus.week_advanced.connect(_on_week_advanced)

# === TRAINING FOOD MANAGEMENT ===

func consume_training_food(creature_id: String, food_type: TrainingFoodType) -> bool:
	"""Consume a training food and apply its effect to a creature"""
	if not _resource_tracker:
		_resource_tracker = GameCore.get_system("resource")

	var food_id = TRAINING_FOOD_IDS.get(food_type)
	if not food_id:
		push_error("FoodSystem: Invalid training food type %d" % food_type)
		return false

	# Check if player has the food item
	if not _resource_tracker or not _resource_tracker.has_item(food_id, 1):
		push_error("FoodSystem: No %s in inventory" % get_training_food_name(food_type))
		return false

	# Remove food from inventory
	if not _resource_tracker.remove_item(food_id, 1):
		return false

	# Apply training food effect
	var current_week = _get_current_week()
	var expires_week = current_week + 4  # Training foods last 4 weeks

	active_effects[creature_id] = {
		"food_type": food_type,
		"expires_week": expires_week
	}

	# Emit signal
	if _signal_bus:
		_signal_bus.training_food_consumed.emit(creature_id, get_training_food_name(food_type), expires_week)

	return true

func get_training_multiplier_for_stat(creature_id: String, stat_name: String) -> float:
	"""Get the training multiplier for a specific stat on a creature"""
	if not active_effects.has(creature_id):
		return 1.0

	var effect = active_effects[creature_id]
	var current_week = _get_current_week()

	# Check if effect has expired
	if current_week >= effect.expires_week:
		active_effects.erase(creature_id)
		return 1.0

	# Check if the food affects this stat
	var food_type = effect.food_type
	var affected_stats = TRAINING_FOOD_STATS.get(food_type, [])

	if stat_name in affected_stats:
		return TRAINING_FOOD_MULTIPLIER

	return 1.0

func get_active_food_effect(creature_id: String) -> Dictionary:
	"""Get the active training food effect for a creature"""
	if not active_effects.has(creature_id):
		return {"has_effect": false}

	var effect = active_effects[creature_id]
	var current_week = _get_current_week()

	# Check if effect has expired
	if current_week >= effect.expires_week:
		active_effects.erase(creature_id)
		return {"has_effect": false}

	var food_type = effect.food_type
	return {
		"has_effect": true,
		"food_name": get_training_food_name(food_type),
		"affected_stats": TRAINING_FOOD_STATS.get(food_type, []),
		"expires_week": effect.expires_week,
		"weeks_remaining": effect.expires_week - current_week,
		"multiplier": TRAINING_FOOD_MULTIPLIER
	}

func clear_expired_effects() -> int:
	"""Remove expired training food effects"""
	var current_week = _get_current_week()
	var removed_count = 0

	var to_remove: Array[String] = []
	for creature_id in active_effects.keys():
		var effect = active_effects[creature_id]
		if current_week >= effect.expires_week:
			to_remove.append(creature_id)
			removed_count += 1

	for creature_id in to_remove:
		active_effects.erase(creature_id)

	return removed_count

# === UTILITY METHODS ===

func get_training_food_name(food_type: TrainingFoodType) -> String:
	"""Get display name for training food type"""
	return TRAINING_FOOD_NAMES.get(food_type, "Unknown Food")

func get_training_food_id(food_type: TrainingFoodType) -> String:
	"""Get item ID for training food type"""
	return TRAINING_FOOD_IDS.get(food_type, "")

func get_all_training_foods() -> Array[Dictionary]:
	"""Get information about all training food types"""
	var foods: Array[Dictionary] = []

	for food_type in TrainingFoodType.values():
		foods.append({
			"type": food_type,
			"name": get_training_food_name(food_type),
			"item_id": get_training_food_id(food_type),
			"affected_stats": TRAINING_FOOD_STATS.get(food_type, []),
			"multiplier": TRAINING_FOOD_MULTIPLIER
		})

	return foods

func _get_current_week() -> int:
	"""Get current week from time system"""
	if not _time_system:
		_time_system = GameCore.get_system("time")

	if _time_system and _time_system.has_method("get_current_week"):
		return _time_system.get_current_week()

	return 1  # Fallback

# === SIGNAL HANDLERS ===

func _on_creature_fed(creature_id: String, food_id: String, _food_data: Dictionary) -> void:
	"""Handle creature feeding to detect training food consumption"""
	# Find matching training food type
	for food_type in TrainingFoodType.values():
		if TRAINING_FOOD_IDS.get(food_type) == food_id:
			# This was handled by direct consumption, not through feeding
			# But we can use this for validation or logging
			break

func _on_week_advanced(_new_week: int, _total_weeks: int) -> void:
	"""Handle weekly time advancement to clean up expired effects"""
	var removed = clear_expired_effects()
	if removed > 0:
		print("FoodSystem: Cleared %d expired training food effects" % removed)

# === SAVE/LOAD SUPPORT ===

func save_state() -> Dictionary:
	"""Save food system state"""
	return {
		"active_effects": active_effects.duplicate()
	}

func load_state(data: Dictionary) -> void:
	"""Load food system state"""
	active_effects = data.get("active_effects", {})
	print("FoodSystem loaded: %d active effects" % active_effects.size())