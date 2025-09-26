extends Node

# Individual test scenes
const INDIVIDUAL_TESTS: Array[Dictionary] = [
	{
		"name": "SignalBus",
		"scene": "res://tests/individual/test_signalbus.tscn",
		"description": "Core SignalBus functionality and signal management"
	},
	{
		"name": "Creature",
		"scene": "res://tests/individual/test_creature.tscn",
		"description": "CreatureData and CreatureEntity classes"
	},
	{
		"name": "StatSystem",
		"scene": "res://tests/individual/test_stats.tscn",
		"description": "Stat validation, clamping, and breakdown"
	},
	{
		"name": "TagSystem",
		"scene": "res://tests/individual/test_tags.tscn",
		"description": "Tag validation, combinations, and filtering"
	},
	{
		"name": "CreatureGenerator",
		"scene": "res://tests/individual/test_generator.tscn",
		"description": "Creature generation algorithms and performance"
	},
	{
		"name": "AgeSystem",
		"scene": "res://tests/individual/test_age.tscn",
		"description": "Age progression, categories, and lifecycle"
	},
	{
		"name": "SaveSystem",
		"scene": "res://tests/individual/test_save.tscn",
		"description": "Game state and creature persistence"
	},
	{
		"name": "PlayerCollection",
		"scene": "res://tests/individual/test_collection.tscn",
		"description": "Active/stable roster management and search"
	}
]

func _ready() -> void:
	print("=== Individual Test Runner ===")
	print("Available individual tests:")
	print()

	for i in range(INDIVIDUAL_TESTS.size()):
		var test: Dictionary = INDIVIDUAL_TESTS[i]
		print("%d. %s - %s" % [i + 1, test.name, test.description])
		print("   Run: godot --headless --scene %s" % test.scene)
		print()

	print("To run all tests sequentially:")
	print("godot --headless --scene res://tests/test_all.tscn")
	print()

	print("To run the comprehensive original test:")
	print("godot --headless --scene res://test_setup.tscn")
	print()

	print("For debugging specific systems, run individual tests first!")

	get_tree().quit()