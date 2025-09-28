@tool
class_name ActivityResource
extends Resource

# Basic identity and display
@export var display_name: String = ""
@export var description: String = ""
@export var icon_path: String = ""

func run_activity_on_creatures(creatures: Array[CreatureData]) -> Array[CreatureData]:
	## This is where you will run your activity logic on the creatures
	return creatures
