@tool
extends Control

@onready var new_game_button: Button = $CenterContainer/MainPanel/ButtonContainer/NewGameButton
@onready var load_game_button: Button = $CenterContainer/MainPanel/ButtonContainer/LoadGameButton
@onready var collection_button: Button = $CenterContainer/MainPanel/ButtonContainer/CollectionButton
@onready var settings_button: Button = $CenterContainer/MainPanel/ButtonContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/MainPanel/ButtonContainer/QuitButton

var _ui_manager: UIManager
var game_controller

func _ready() -> void:
	if not Engine.is_editor_hint():
		_ui_manager = GameCore.get_system("ui")
		call_deferred("_setup_navigation")

func _setup_navigation() -> void:
	if new_game_button:
		new_game_button.grab_focus()

func _on_new_game_pressed() -> void:
	print("MainMenu: Starting new game")
	if _ui_manager:
		_ui_manager.change_scene("res://scenes/ui/game_ui.tscn")

func _on_load_game_pressed() -> void:
	print("MainMenu: Loading game")
	if game_controller:
		var success = game_controller.load_game("default")
		if success and _ui_manager:
			_ui_manager.change_scene("res://scenes/ui/game_ui.tscn")

func _on_collection_pressed() -> void:
	print("MainMenu: Opening collection view")
	if _ui_manager:
		_ui_manager.change_scene("res://scenes/ui/game_ui.tscn")
		# The GameUI will auto-show collection since we're coming from menu

func _on_settings_pressed() -> void:
	print("MainMenu: Opening settings")
	if _ui_manager:
		_ui_manager.show_window("settings")

func _on_quit_pressed() -> void:
	print("MainMenu: Quitting game")
	get_tree().quit()
