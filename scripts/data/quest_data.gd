class_name QuestData
extends Resource

# Placeholder class for future quest implementation
@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var is_completed: bool = false

func to_dict() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"description": description,
		"is_completed": is_completed
	}