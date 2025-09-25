class_name MainController
extends Node2D

func _ready() -> void:
	print("Main scene loaded successfully")
	print("GameCore available: ", GameCore.instance != null)
	print("SignalBus available: ", GameCore.get_signal_bus() != null)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_save_game"):
		GameCore.get_signal_bus().save_requested.emit()
	elif event.is_action_pressed("ui_load_game"):
		GameCore.get_signal_bus().load_requested.emit()