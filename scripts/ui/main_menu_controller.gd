@tool
extends Control

@onready var new_game_button: Button = $CenterContainer/MainButtons/NewGameButton
@onready var load_game_button: Button = $CenterContainer/MainButtons/LoadGameButton
@onready var collection_button: Button = $CenterContainer/MainButtons/CollectionButton
@onready var settings_button: Button = $CenterContainer/MainButtons/SettingsButton
@onready var quit_button: Button = $CenterContainer/MainButtons/QuitButton

var _ui_manager
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
		_ui_manager.change_scene("res://scenes/ui/facility_view.tscn")

func _on_load_game_pressed() -> void:
	print("MainMenu: Loading game")
	if game_controller:
		var success = game_controller.load_game("default")
		if success and _ui_manager:
			_ui_manager.change_scene("res://scenes/ui/facility_view.tscn")

func _on_collection_pressed() -> void:
	print("MainMenu: Opening collection view")
	if _ui_manager:
		_ui_manager.change_scene("res://scenes/ui/facility_view.tscn")
		# The FacilityView will be the main game view
func _on_settings_pressed() -> void:
	$CenterContainer/SettingsMenu.visible = true
	$CenterContainer/MainButtons.visible = false
	
func _on_quit_pressed() -> void:
	print("MainMenu: Quitting game")
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$CenterContainer/SettingsMenu.visible = false
	$CenterContainer/MainButtons.visible = true


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
