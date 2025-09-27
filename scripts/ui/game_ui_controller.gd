@tool
extends Control

@onready var menu_button: Button = $HUD/TopBar/MenuButton
@onready var time_label: Label = $HUD/TopBar/TimeLabel
@onready var resources_label: Label = $HUD/TopBar/ResourcesLabel
@onready var creature_list: ItemList = $HUD/SidePanel/CreatureList
@onready var collect_button: Button = $HUD/BottomBar/ActionButtons/CollectButton
@onready var shop_button: Button = $HUD/BottomBar/ActionButtons/ShopButton
@onready var quest_button: Button = $HUD/BottomBar/ActionButtons/QuestButton
@onready var training_button: Button = $HUD/BottomBar/ActionButtons/TrainingButton
@onready var next_week_button: Button = $HUD/BottomBar/ActionButtons/NextWeekButton
@onready var content_switcher: Control = $HUD/MainContent/ContentSwitcher
@onready var default_view: Control = $HUD/MainContent/ContentSwitcher/DefaultView
@onready var collection_view: Control = $HUD/MainContent/ContentSwitcher/CollectionView
@onready var shop_view: Control = $HUD/MainContent/ContentSwitcher/ShopView
@onready var shop_panel: Control = $HUD/MainContent/ContentSwitcher/ShopView/ShopPanel
@onready var training_view: Control = $HUD/MainContent/ContentSwitcher/TrainingView
@onready var training_panel: Control = $HUD/MainContent/ContentSwitcher/TrainingView/TrainingPanel

var _ui_manager: UIManager
var game_controller
var _current_view: String = "default"

func _ready() -> void:
	if not Engine.is_editor_hint():
		call_deferred("_initialize_ui")

func _initialize_ui() -> void:
	_setup_controllers()
	_connect_signals()
	_update_ui()
	create_creatures()

func create_creatures() -> void:
	var collection = GameCore.get_system("collection")
	var species = GameCore.get_system("species").get_all_species()

	for i in range(8):
		var creature = CreatureGenerator.generate_creature_data(species[i % species.size()])
		creature.creature_name = "Test %s %d" % [creature.species_id.capitalize(), i+1]
		collection.acquire_creature(creature, "test")

	# Add some training food items for testing
	var resource_tracker = GameCore.get_system("resource")
	if resource_tracker:
		resource_tracker.add_item("power_bar", 5)
		resource_tracker.add_item("speed_snack", 5)
		resource_tracker.add_item("brain_food", 5)
		resource_tracker.add_item("focus_tea", 5)
		resource_tracker.add_gold(500, "initial_test_funds")


func _setup_controllers() -> void:
	_ui_manager = GameCore.get_system("ui")

func _connect_signals() -> void:
	if game_controller:
		game_controller.time_updated.connect(_on_time_updated)
		game_controller.creatures_updated.connect(_on_creatures_updated)
		game_controller.training_data_updated.connect(_on_training_data_updated)
		game_controller.food_inventory_updated.connect(_on_food_inventory_updated)

	# Connect to time and aging signals directly
	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.week_advanced.connect(_on_week_advanced_ui)
		signal_bus.aging_batch_completed.connect(_on_aging_completed)
		signal_bus.gold_spent.connect(_on_gold_spent)

func _update_ui() -> void:
	_update_time_display()
	_update_resources_display()
	_update_creature_list()

func _update_time_display() -> void:
	if time_label:
		var time_system = GameCore.get_system("time")
		if time_system:
			time_label.text = "Week %d" % time_system.current_week
		elif game_controller:
			time_label.text = game_controller.get_time_display()
		else:
			time_label.text = "Week 1"

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
	print("🔵 GameUI: Collect button pressed - toggling collection view")
	_toggle_collection_view()

func _on_shop_pressed() -> void:
	print("🟠 GameUI: Shop button pressed - toggling shop view")
	_toggle_shop_view()

func _on_quest_pressed() -> void:
	print("🟢 GameUI: Quest button pressed - opening quests")
	if _ui_manager:
		_ui_manager.show_window("quests")

func _on_training_pressed() -> void:
	print("🟡 GameUI: Training button pressed - toggling training view")
	_toggle_training_view()

func _on_next_week_pressed() -> void:
	print("⏰ GameUI: Next Week button pressed - advancing time")
	var time_system = GameCore.get_system("time")
	if time_system:
		var success = time_system.advance_week()
		if success:
			print("  ✅ Week advanced successfully")
			_update_ui()  # Refresh the UI to show updated creature ages
		else:
			print("  ❌ Failed to advance week")
	else:
		print("  ❌ Time system not available")

func _on_time_updated() -> void:
	_update_time_display()

func _on_creatures_updated() -> void:
	_update_creature_list()

func _toggle_collection_view() -> void:
	if _current_view == "collection":
		_show_default_view()
	else:
		_show_collection_view()

func _toggle_shop_view() -> void:
	if _current_view == "shop":
		_show_default_view()
	else:
		_show_shop_view()

func _toggle_training_view() -> void:
	if _current_view == "training":
		_show_default_view()
	else:
		_show_training_view()

func _show_collection_view() -> void:
	_hide_all_views()
	_current_view = "collection"
	collection_view.show()
	collect_button.text = "Close Collection"
	shop_button.text = "Shop"
	training_button.text = "Training"

func _show_shop_view() -> void:
	_hide_all_views()
	_current_view = "shop"
	shop_view.show()
	collect_button.text = "Collect"
	shop_button.text = "Close Shop"
	training_button.text = "Training"

	# Initialize shop panel if needed
	if shop_panel and shop_panel.has_method("_initialize_shop_panel"):
		shop_panel._initialize_shop_panel()

func _show_training_view() -> void:
	_hide_all_views()
	_current_view = "training"
	training_view.show()
	collect_button.text = "Collect"
	shop_button.text = "Shop"
	training_button.text = "Close Training"

	# Initialize training panel with game controller
	if training_panel and training_panel.has_method("set_game_controller"):
		training_panel.set_game_controller(game_controller)

	# Refresh training panel if needed
	if training_panel and training_panel.has_method("refresh"):
		training_panel.refresh()

func _show_default_view() -> void:
	_hide_all_views()
	_current_view = "default"
	default_view.show()
	collect_button.text = "Collect"
	shop_button.text = "Shop"
	training_button.text = "Training"

func _hide_all_views() -> void:
	default_view.hide()
	collection_view.hide()
	shop_view.hide()
	training_view.hide()

func _on_week_advanced_ui(new_week: int, total_weeks: int) -> void:
	print("GameUI: Week advanced to %d - updating time display" % new_week)
	_update_time_display()

func _on_aging_completed(creatures_aged: int, total_weeks: int) -> void:
	print("GameUI: Aging completed for %d creatures - updating creature list" % creatures_aged)
	_update_creature_list()

func _on_gold_spent(amount: int, reason: String) -> void:
	print("GameUI: Gold spent (%d for %s) - updating resources display" % [amount, reason])
	_update_resources_display()

func _on_training_data_updated() -> void:
	print("GameUI: Training data updated - refreshing training panel")
	if _current_view == "training" and training_panel and training_panel.has_method("refresh"):
		training_panel.refresh()

func _on_food_inventory_updated() -> void:
	print("GameUI: Food inventory updated - refreshing training panel")
	if _current_view == "training" and training_panel and training_panel.has_method("refresh_food_buttons"):
		training_panel.refresh_food_buttons()
