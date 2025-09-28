extends Control

# Overlay Menu Controller - Main game interface with navigation buttons and game area

@onready var date_label: Label = $VBoxContainer/Panel/MarginContainer/Date
@onready var gold_label: Label = $VBoxContainer/Panel/MarginContainer/Gold
@onready var facilities_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Facilities
@onready var shop_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Shop
@onready var inventory_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Inventory
@onready var stable_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Stable
@onready var menu_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Menu
@onready var game_area: Control = $VBoxContainer/HBoxContainer/GameArea

var game_controller
var resource_tracker
var time_system
var signal_bus
var current_view: Control = null

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_connect_buttons()
	_load_default_view()
	_update_ui()

func _initialize_systems() -> void:
	resource_tracker = GameCore.get_system("resource")
	time_system = GameCore.get_system("time")
	signal_bus = GameCore.get_signal_bus()

func _setup_signals() -> void:
	if signal_bus:
		# Connect to resource and time updates
		if signal_bus.has_signal("gold_changed"):
			signal_bus.gold_changed.connect(_on_gold_changed)
		if signal_bus.has_signal("week_advanced"):
			signal_bus.week_advanced.connect(_on_week_advanced)

func _connect_buttons() -> void:
	if facilities_button:
		facilities_button.pressed.connect(_on_facilities_pressed)
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)
	if inventory_button:
		inventory_button.pressed.connect(_on_inventory_pressed)
	if stable_button:
		stable_button.pressed.connect(_on_stable_pressed)
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _load_default_view() -> void:
	# Load facility_view as the default main view
	_load_view_in_game_area("res://scenes/ui/facility_view.tscn")

func _load_view_in_game_area(scene_path: String) -> void:
	# Clear current view
	if current_view:
		current_view.queue_free()
		current_view = null

	# Load new view
	var scene = load(scene_path)
	if scene and game_area:
		current_view = scene.instantiate()
		if current_view:
			# Pass game controller if the view supports it
			if current_view.has_method("set_game_controller"):
				current_view.set_game_controller(game_controller)
			elif "game_controller" in current_view:
				current_view.game_controller = game_controller

			game_area.add_child(current_view)

func _update_ui() -> void:
	_update_date_display()
	_update_gold_display()

func _update_date_display() -> void:
	if date_label and time_system:
		var current_week = time_system.current_week
		var year = (current_week - 1) / 52
		var week_in_year = ((current_week - 1) % 52) + 1
		date_label.text = "Year %d Week %d" % [year, week_in_year]

func _update_gold_display() -> void:
	if gold_label and resource_tracker:
		var gold_amount = resource_tracker.get_balance()
		gold_label.text = "%d Gold" % gold_amount

func set_game_controller(controller) -> void:
	game_controller = controller

# Button handlers
func _on_facilities_pressed() -> void:
	print("OverlayMenu: Facilities button pressed")
	_load_view_in_game_area("res://scenes/ui/facility_view.tscn")

func _on_shop_pressed() -> void:
	print("OverlayMenu: Shop button pressed")
	_load_view_in_game_area("res://scenes/ui/shop.tscn")

func _on_inventory_pressed() -> void:
	print("OverlayMenu: Inventory button pressed")
	# TODO: Load inventory view when available
	# _load_view_in_game_area("res://scenes/ui/inventory_view.tscn")

func _on_stable_pressed() -> void:
	print("OverlayMenu: Stable button pressed")
	# TODO: Load stable/collection view when available
	# _load_view_in_game_area("res://scenes/ui/collection_view.tscn")

func _on_menu_pressed() -> void:
	print("OverlayMenu: Menu button pressed")
	var ui_manager = GameCore.get_system("ui")
	if ui_manager:
		ui_manager.change_scene("res://scenes/ui/main_menu.tscn")

# Signal handlers
func _on_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
	_update_gold_display()

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	_update_date_display()