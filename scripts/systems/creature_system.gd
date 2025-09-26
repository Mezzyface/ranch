class_name CreatureSystem
extends Node

var _creatures: Array[CreatureData] = []

func _ready() -> void:
	print("CreatureSystem initialized (placeholder)")

func get_all_creatures() -> Array[CreatureData]:
	return _creatures

func add_creature_from_dict(creature_dict: Dictionary) -> void:
	# Placeholder - will implement in later tasks
	print("Adding creature from dict (placeholder): ", creature_dict)

func clear_all_creatures() -> void:
	_creatures.clear()
