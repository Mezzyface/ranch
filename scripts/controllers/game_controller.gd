@tool
class_name GameController extends Node

signal game_state_changed()
signal creatures_updated()
signal resources_updated()
signal time_updated()

var _collection_system
var _time_system
var _save_system
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
	_signal_bus = GameCore.get_signal_bus()

func _connect_signals() -> void:
	if _signal_bus:
		_signal_bus.week_advanced.connect(_on_week_advanced)
		_signal_bus.active_roster_changed.connect(_on_roster_changed)

func get_current_week() -> int:
	if _time_system:
		return _time_system.current_week
	return 1

func get_time_display() -> String:
	return "Week %d" % get_current_week()

func get_resources_display() -> String:
	return "Gold: 100"

func get_active_creatures() -> Array[String]:
	var creature_names: Array[String] = []
	if _collection_system:
		var creatures = _collection_system.get_active_creatures()
		for creature in creatures:
			if creature and creature.creature_name:
				creature_names.append(creature.creature_name)
	return creature_names

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
