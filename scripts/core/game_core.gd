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

func get_system(system_name: String) -> Node:
	if not _systems.has(system_name):
		_load_system(system_name)
	return _systems.get(system_name)

func has_system(system_name: String) -> bool:
	return _systems.has(system_name) or _is_valid_system_name(system_name)

func _is_valid_system_name(system_name: String) -> bool:
	var valid_systems = ["creature", "save", "quest", "stat", "tag", "age", "collection", "resource", "resources", "species", "item_manager", "items", "time", "ui", "stamina", "shop"]
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
		_:
			push_error("Unknown system: " + system_name)
			return

	system.name = system_name.capitalize() + "System"
	add_child(system)
	_systems[system_name] = system
	print("Loaded system: " + system_name)
