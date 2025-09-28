extends Node

var signal_bus: SignalBus
var _systems: Dictionary = {}

func _ready() -> void:
	# Create SignalBus first
	signal_bus = SignalBus.new()
	signal_bus.name = "SignalBus"
	add_child(signal_bus)

	print("GameCore initialized")
	# Systems will be lazy-loaded as needed

func get_signal_bus() -> SignalBus:
	return signal_bus

func get_system(system_key) -> Node:
	var system_name: String = _resolve_system_key(system_key)
	if system_name.is_empty():
		return null

	if not _systems.has(system_name):
		_load_system(system_name)
	return _systems.get(system_name)

func has_system(system_key) -> bool:
	var system_name: String = _resolve_system_key(system_key)
	if system_name.is_empty():
		return false
	return _systems.has(system_name) or _is_valid_system_name(system_name)

func _resolve_system_key(system_key) -> String:
	# Support both string and enum
	if system_key is String:
		# Legacy string access - will be deprecated
		return system_key
	elif system_key is GlobalEnums.SystemKey:
		# New enum access - preferred
		return GlobalEnums.system_key_to_string(system_key)
	else:
		push_error("GameCore.get_system: Invalid system key type: %s" % type_string(typeof(system_key)))
		return ""

func _is_valid_system_name(system_name: String) -> bool:
	var valid_systems = ["creature", "save", "quest", "stat", "tag", "age", "collection", "resource", "resources", "species", "item_manager", "items", "time", "ui", "stamina", "shop", "training", "food", "weekly_update", "weekly_orchestrator", "facility"]
	return system_name in valid_systems

func _load_system(system_name: String) -> void:
	var system: Node

	match system_name:
		"creature":
			system = preload("res://scripts/systems/creature_system.gd").new()
		"save":
			system = preload("res://scripts/systems/save_system.gd").new()
		"quest":
			system = preload("res://scripts/systems/quest_system.gd").new()
		"stat":
			system = preload("res://scripts/systems/stat_system.gd").new()
		"tag":
			system = preload("res://scripts/systems/tag_system.gd").new()
		"age":
			system = preload("res://scripts/systems/age_system.gd").new()
		"collection":
			system = preload("res://scripts/systems/player_collection.gd").new()
		"resource", "resources":
			system = preload("res://scripts/systems/resource_tracker.gd").new()
		"species":
			system = preload("res://scripts/systems/species_system.gd").new()
		"item_manager", "items":
			system = preload("res://scripts/systems/item_manager.gd").new()
		"time":
			system = preload("res://scripts/systems/time_system.gd").new()
		"ui":
			system = preload("res://scripts/ui/ui_manager.gd").new()
		"stamina":
			system = preload("res://scripts/systems/stamina_system.gd").new()
		"shop":
			system = preload("res://scripts/systems/shop_system.gd").new()
		"training":
			system = preload("res://scripts/systems/training_system.gd").new()
		"food":
			system = preload("res://scripts/systems/food_system.gd").new()
		"weekly_update", "weekly_orchestrator":
			system = preload("res://scripts/systems/weekly_update_orchestrator.gd").new()
		"facility":
			system = preload("res://scripts/systems/facility_system.gd").new()
		_:
			push_error("Unknown system: " + system_name)
			return

	system.name = system_name.capitalize() + "System"
	add_child(system)
	_systems[system_name] = system
	print("Loaded system: " + system_name)
