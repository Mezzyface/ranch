@tool
extends Control

@onready var menu_button: Button = $HUD/TopBar/MenuButton
@onready var time_label: Label = $HUD/TopBar/TimeLabel
@onready var resources_label: Label = $HUD/TopBar/ResourcesLabel
@onready var creature_list: ItemList = $HUD/SidePanel/CreatureList
@onready var collect_button: Button = $HUD/BottomBar/ActionButtons/CollectButton
@onready var shop_button: Button = $HUD/BottomBar/ActionButtons/ShopButton
@onready var quest_button: Button = $HUD/BottomBar/ActionButtons/QuestButton

var _ui_manager: UIManager
var game_controller

func _ready() -> void:
	if not Engine.is_editor_hint():
		call_deferred("_initialize_ui")

func _initialize_ui() -> void:
	_setup_controllers()
	_connect_signals()
	_update_ui()

func _setup_controllers() -> void:
	_ui_manager = GameCore.get_system("ui")

func _connect_signals() -> void:
	if game_controller:
		game_controller.time_updated.connect(_on_time_updated)
		game_controller.creatures_updated.connect(_on_creatures_updated)

func _update_ui() -> void:
	_update_time_display()
	_update_resources_display()
	_update_creature_list()

func _update_time_display() -> void:
	if game_controller and time_label:
		time_label.text = game_controller.get_time_display()

func _update_resources_display() -> void:
	if game_controller and resources_label:
		resources_label.text = game_controller.get_resources_display()

func _update_creature_list() -> void:
	if not game_controller or not creature_list:
		return

	creature_list.clear()
	var creature_names = game_controller.get_active_creatures()

	for name in creature_names:
		creature_list.add_item(name)

func _on_menu_pressed() -> void:
	print("GameUI: Opening menu")
	if _ui_manager:
		_ui_manager.change_scene("res://scenes/ui/main_menu.tscn")

func _on_creature_selected(index: int) -> void:
	print("GameUI: Selected creature at index %d" % index)

func _on_collect_pressed() -> void:
	print("GameUI: Collect button pressed")

func _on_shop_pressed() -> void:
	print("GameUI: Shop button pressed")
	if _ui_manager:
		_ui_manager.show_window("shop")

func _on_quest_pressed() -> void:
	print("GameUI: Quest button pressed")
	if _ui_manager:
		_ui_manager.show_window("quests")

func _on_time_updated() -> void:
	_update_time_display()

func _on_creatures_updated() -> void:
	_update_creature_list()
