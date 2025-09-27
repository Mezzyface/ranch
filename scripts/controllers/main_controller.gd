class_name MainController
extends Node2D

const GameController = preload("res://scripts/controllers/game_controller.gd")

@onready var ui_layer: CanvasLayer = $UI
@onready var main_ui: Control = $UI/MainUI

var game_controller: GameController
var ui_manager: UIManager
var current_ui_scene: Control = null

func _ready() -> void:
	print("Main scene loaded successfully")
	print("GameCore available: ", GameCore != null)
	print("SignalBus available: ", GameCore.get_signal_bus() != null)

	_setup_controllers()
	_load_initial_ui()

func _setup_controllers() -> void:
	game_controller = GameController.new()
	game_controller.name = "GameController"
	add_child(game_controller)

	ui_manager = GameCore.get_system("ui")
	if ui_manager:
		ui_manager.scene_changed.connect(_on_ui_scene_changed)

func _load_initial_ui() -> void:
	change_ui_scene("res://scenes/ui/main_menu.tscn")

func change_ui_scene(scene_path: String) -> void:
	if current_ui_scene:
		current_ui_scene.queue_free()
		current_ui_scene = null

	var scene = load(scene_path)
	if scene:
		current_ui_scene = scene.instantiate()
		if current_ui_scene:
			if current_ui_scene.has_method("set_game_controller"):
				current_ui_scene.set_game_controller(game_controller)
			elif "game_controller" in current_ui_scene:
				current_ui_scene.game_controller = game_controller
			main_ui.add_child(current_ui_scene)

func _on_ui_scene_changed(scene_path: String) -> void:
	change_ui_scene(scene_path)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_save_game"):
		print("Save game input detected!")
		if game_controller:
			var success = game_controller.save_game("default")
			print("Save result: ", success)
	elif event.is_action_pressed("ui_load_game"):
		print("Load game input detected!")
		if game_controller:
			var success = game_controller.load_game("default")
			print("Load result: ", success)
	elif event.is_action_pressed("ui_open_shop"):
		print("Shop input detected (S key)!")
		# Use the same method as the shop button
		if current_ui_scene and current_ui_scene.has_method("_on_shop_pressed"):
			current_ui_scene._on_shop_pressed()
		elif ui_manager:
			ui_manager.show_window("shop")
	elif event.is_action_pressed("ui_open_creatures"):
		print("Creatures input detected (C key)!")
		# Use the same method as the collect button
		if current_ui_scene and current_ui_scene.has_method("_on_collect_pressed"):
			current_ui_scene._on_collect_pressed()
		else:
			# If not on game UI, switch to it first
			change_ui_scene("res://scenes/ui/game_ui.tscn")
	elif event.is_action_pressed("ui_open_quests"):
		print("Quests input detected (Q key)!")
		if current_ui_scene and current_ui_scene.has_method("_on_quest_pressed"):
			current_ui_scene._on_quest_pressed()
		elif ui_manager:
			ui_manager.show_window("quests")
	elif event.is_action_pressed("ui_advance_time"):
		print("Advance time input detected (Space key)!")
		if game_controller:
			var success = game_controller.advance_time()
			print("Time advance result: ", success)
	elif event.is_action_pressed("ui_menu"):
		print("Menu input detected (Escape key)!")
		change_ui_scene("res://scenes/ui/main_menu.tscn")
	elif event.is_action_pressed("toggle_fullscreen"):
		print("Fullscreen toggle detected (F11)!")
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
