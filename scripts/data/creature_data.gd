class_name CreatureData
extends Resource

# Placeholder class for future task
@export var id: String = ""
@export var creature_name: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": creature_name
	}