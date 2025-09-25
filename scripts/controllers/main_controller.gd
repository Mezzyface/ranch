class_name MainController
extends Node2D

func _ready() -> void:
	print("Main scene loaded successfully")
	print("GameCore available: ", GameCore != null)
	print("SignalBus available: ", GameCore.get_signal_bus() != null)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_save_game"):
		print("Save game input detected!")
		# Ensure SaveSystem is loaded before emitting signal
		GameCore.get_system("save")
		GameCore.get_signal_bus().save_requested.emit()
	elif event.is_action_pressed("ui_load_game"):
		print("Load game input detected!")
		# Ensure SaveSystem is loaded before emitting signal
		GameCore.get_system("save")
		GameCore.get_signal_bus().load_requested.emit()
	elif event.is_action_pressed("ui_open_shop"):
		print("Shop input detected (S key)!")
	elif event.is_action_pressed("ui_open_creatures"):
		print("Creatures input detected (C key)!")
	elif event.is_action_pressed("ui_open_quests"):
		print("Quests input detected (Q key)!")
	elif event.is_action_pressed("ui_advance_time"):
		print("Advance time input detected (Space key)!")