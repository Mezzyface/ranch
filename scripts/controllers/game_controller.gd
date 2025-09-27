@tool
class_name GameController extends Node

signal game_state_changed()
signal creatures_updated()
signal resources_updated()
signal time_updated()
signal training_data_updated()
signal food_inventory_updated()

var _collection_system
var _time_system
var _save_system
var _training_system
var _food_system
var _resource_tracker
var _signal_bus: SignalBus

func _ready() -> void:
	name = "GameController"
	if not Engine.is_editor_hint():
		_setup_systems()
		_connect_signals()

func _setup_systems() -> void:
	_collection_system = GameCore.get_system("collection")
	_time_system = GameCore.get_system("time")
	_save_system = GameCore.get_system("save")
	_training_system = GameCore.get_system("training")
	_food_system = GameCore.get_system("food")
	_resource_tracker = GameCore.get_system("resource")
	_signal_bus = GameCore.get_signal_bus()

func _connect_signals() -> void:
	if _signal_bus:
		_signal_bus.week_advanced.connect(_on_week_advanced)
		_signal_bus.active_roster_changed.connect(_on_roster_changed)
		_signal_bus.training_scheduled.connect(_on_training_scheduled)
		_signal_bus.training_completed.connect(_on_training_completed)
		_signal_bus.training_food_consumed.connect(_on_food_consumed)
		_signal_bus.item_added.connect(_on_item_changed)
		_signal_bus.item_removed.connect(_on_item_changed)

func get_current_week() -> int:
	if _time_system:
		return _time_system.current_week
	return 1

func get_time_display() -> String:
	return "Week %d" % get_current_week()

func get_resources_display() -> String:
	var resource_tracker = GameCore.get_system("resource")
	if resource_tracker:
		var gold = resource_tracker.get_balance()
		return "Gold: %d" % gold
	return "Gold: 0"

func get_active_creatures() -> Array[String]:
	var creature_names: Array[String] = []
	if _collection_system:
		var creatures = _collection_system.get_active_creatures()
		for creature in creatures:
			if creature and creature.creature_name:
				creature_names.append(creature.creature_name)
	return creature_names

func get_active_creatures_data() -> Array[Dictionary]:
	"""Get active creatures with full data for UI display"""
	var creature_data: Array[Dictionary] = []
	if _collection_system:
		var creatures = _collection_system.get_active_creatures()
		for creature in creatures:
			if creature:
				var training_status = get_creature_training_status(creature.id)
				var food_effect = get_creature_food_effect(creature.id)

				var display_text = "%s (%s)" % [creature.creature_name, creature.species_id]

				# Add training status if applicable
				if training_status.get("status", "none") != "none":
					display_text += " [%s]" % training_status.status.to_upper()

				# Add food effect if applicable
				if food_effect.get("has_effect", false):
					display_text += " (+%d%% %s)" % [int((food_effect.multiplier - 1.0) * 100), food_effect.food_name]

				creature_data.append({
					"id": creature.id,
					"display_text": display_text,
					"creature_name": creature.creature_name,
					"species_id": creature.species_id,
					"stamina": creature.stamina_current,
					"max_stamina": creature.stamina_max
				})
	return creature_data

func get_active_creature_count() -> int:
	if _collection_system:
		return _collection_system.get_active_creatures().size()
	return 0

func advance_time() -> bool:
	if _time_system:
		return _time_system.advance_week()
	return false

func can_advance_time() -> bool:
	if _time_system:
		var result = _time_system.can_advance_time()
		return result.can_advance if result else false
	return false

func save_game(save_name: String = "default") -> bool:
	if _save_system:
		return _save_system.save_game_state(save_name)
	return false

func load_game(save_name: String = "default") -> bool:
	if _save_system:
		return _save_system.load_game_state(save_name)
	return false

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	time_updated.emit()
	game_state_changed.emit()

func _on_roster_changed(new_roster: Array) -> void:
	creatures_updated.emit()
	game_state_changed.emit()

# === TRAINING SYSTEM METHODS ===

func get_training_data() -> Dictionary:
	"""Get comprehensive training data for UI display"""
	if not _training_system:
		return {}

	return {
		"facility_utilization": _training_system.get_facility_utilization(),
		"training_assignments": _training_system.get_training_assignments(),
		"completed_trainings": _training_system.get_completed_trainings()
	}

func get_creature_training_status(creature_id: String) -> Dictionary:
	"""Get training status for a specific creature"""
	if not _training_system:
		return {"status": "system_unavailable"}
	return _training_system.get_training_status(creature_id)

func schedule_creature_training(creature_id: String, activity: int, facility_tier: int = 0, food_type: int = -1) -> Dictionary:
	"""Schedule training for a creature through the controller"""
	if not _training_system or not _collection_system:
		return {"success": false, "reason": "Systems not available"}

	# Find the creature
	var creature = _find_creature_by_id(creature_id)
	if not creature:
		return {"success": false, "reason": "Creature not found"}

	# Schedule the training with optional food
	return _training_system.schedule_training(creature, activity, facility_tier, food_type)

func cancel_creature_training(creature_id: String) -> bool:
	"""Cancel training for a creature"""
	if not _training_system:
		return false
	return _training_system.cancel_training(creature_id)

# === FOOD SYSTEM METHODS ===

func get_food_inventory() -> Dictionary:
	"""Get training food inventory data"""
	if not _resource_tracker:
		return {}

	var food_items = {
		"power_bar": _resource_tracker.get_item_count("power_bar"),
		"speed_snack": _resource_tracker.get_item_count("speed_snack"),
		"brain_food": _resource_tracker.get_item_count("brain_food"),
		"focus_tea": _resource_tracker.get_item_count("focus_tea")
	}

	return food_items

func get_creature_food_effect(creature_id: String) -> Dictionary:
	"""Get active food effect for a creature"""
	if not _food_system:
		return {"has_effect": false}
	return _food_system.get_active_food_effect(creature_id)

func consume_training_food(creature_id: String, food_type: int) -> bool:
	"""Consume training food for a creature"""
	if not _food_system:
		return false
	return _food_system.consume_training_food(creature_id, food_type)

func get_available_training_foods() -> Array:
	"""Get list of available training food types with info"""
	if not _food_system:
		return []
	return _food_system.get_all_training_foods()

# === CREATURE LOOKUP HELPER ===

func _find_creature_by_id(creature_id: String) -> CreatureData:
	"""Find creature by ID in active collection"""
	if not _collection_system:
		return null

	var active_creatures = _collection_system.get_active_creatures()
	for creature in active_creatures:
		if creature.id == creature_id:
			return creature

	var stable_creatures = _collection_system.get_stable_creatures()
	for creature in stable_creatures:
		if creature.id == creature_id:
			return creature

	return null

# === SIGNAL HANDLERS ===

func _on_training_scheduled(_creature_data: CreatureData, _activity: String, _facility: String) -> void:
	training_data_updated.emit()
	creatures_updated.emit()

func _on_training_completed(_creature_data: CreatureData, _activity: String, _stat_gains: Dictionary) -> void:
	training_data_updated.emit()
	creatures_updated.emit()

func _on_food_consumed(_creature_id: String, _food_name: String, _expires_week: int) -> void:
	food_inventory_updated.emit()
	creatures_updated.emit()

func _on_item_changed(_item_id: String, _quantity: int, _total: int) -> void:
	resources_updated.emit()
	food_inventory_updated.emit()
