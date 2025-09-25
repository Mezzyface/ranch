extends Node

static var instance: Node
var signal_bus: SignalBus
var _systems: Dictionary = {}

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	# Create SignalBus first
	signal_bus = SignalBus.new()
	signal_bus.name = "SignalBus"
	add_child(signal_bus)

	print("GameCore initialized")
	# Systems will be lazy-loaded as needed

static func get_signal_bus() -> SignalBus:
	return instance.signal_bus

static func get_system(system_name: String) -> Node:
	if not instance._systems.has(system_name):
		instance._load_system(system_name)
	return instance._systems.get(system_name)

func _load_system(system_name: String) -> void:
	var system: Node

	match system_name:
		"creature":
			system = preload("res://scripts/systems/creature_system.gd").new()
		"save":
			system = preload("res://scripts/systems/save_system.gd").new()
		"quest":
			system = preload("res://scripts/systems/quest_system.gd").new()
		_:
			push_error("Unknown system: " + system_name)
			return

	system.name = system_name.capitalize() + "System"
	add_child(system)
	_systems[system_name] = system
	print("Loaded system: " + system_name)