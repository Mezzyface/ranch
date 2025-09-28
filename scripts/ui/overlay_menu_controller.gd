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
var starter_popup_scene = preload("res://scenes/ui/starter_popup.tscn")
var tutorial_completed: bool = false

func _ready() -> void:
	_initialize_systems()
	_setup_signals()
	_connect_buttons()
	_set_navigation_visibility(tutorial_completed)
	_load_default_view()
	_update_ui()

func _initialize_systems() -> void:
	resource_tracker = GameCore.get_system("resource")
	time_system = GameCore.get_system("time")
	signal_bus = GameCore.get_signal_bus()

	print("OverlayMenu: Systems initialized - ResourceTracker: %s, TimeSystem: %s, SignalBus: %s" % [resource_tracker != null, time_system != null, signal_bus != null])

func _setup_signals() -> void:
	if signal_bus:
		# Connect to resource and time updates
		if signal_bus.has_signal("gold_changed"):
			if not signal_bus.gold_changed.is_connected(_on_gold_changed):
				signal_bus.gold_changed.connect(_on_gold_changed)
				print("OverlayMenu: Connected to gold_changed signal")
		if signal_bus.has_signal("week_advanced"):
			if not signal_bus.week_advanced.is_connected(_on_week_advanced):
				signal_bus.week_advanced.connect(_on_week_advanced)
				print("OverlayMenu: Connected to week_advanced signal")
		if signal_bus.has_signal("new_game_started"):
			if not signal_bus.new_game_started.is_connected(_on_new_game_started):
				signal_bus.new_game_started.connect(_on_new_game_started)
				print("OverlayMenu: Connected to new_game_started signal")
		if signal_bus.has_signal("tutorial_completed"):
			if not signal_bus.tutorial_completed.is_connected(_on_tutorial_completed):
				signal_bus.tutorial_completed.connect(_on_tutorial_completed)
				print("OverlayMenu: Connected to tutorial_completed signal")
	else:
		print("OverlayMenu: SignalBus not available, retrying in next frame")
		# Retry signal setup in the next frame
		call_deferred("_setup_signals")

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
		print("OverlayMenu: Updated gold display to '%s'" % gold_label.text)
	else:
		print("OverlayMenu: Cannot update gold display - gold_label: %s, resource_tracker: %s" % [gold_label != null, resource_tracker != null])

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
	print("OverlayMenu: Gold changed %d -> %d (change: %d)" % [old_amount, new_amount, change])
	_update_gold_display()

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	_update_date_display()

func _on_new_game_started() -> void:
	print("OverlayMenu: New game started, showing starter popup")
	_show_starter_popup()

func _show_starter_popup() -> void:
	"""Create and display the starter popup."""
	if starter_popup_scene:
		var popup_instance = starter_popup_scene.instantiate()
		if popup_instance:
			# Add popup as a child of this control (overlays the game area)
			add_child(popup_instance)

			# Ensure the popup appears above all other UI elements including Next Week button
			popup_instance.z_index = 1000

			popup_instance.show_popup()
			print("OverlayMenu: Starter popup displayed")

func _set_navigation_visibility(visible: bool) -> void:
	"""Show or hide navigation buttons based on tutorial state."""
	if facilities_button:
		facilities_button.visible = visible
	if shop_button:
		shop_button.visible = visible
	if inventory_button:
		inventory_button.visible = visible
	if stable_button:
		stable_button.visible = visible
	if menu_button:
		menu_button.visible = visible

	print("OverlayMenu: Navigation buttons visibility set to %s" % visible)

func _on_tutorial_completed() -> void:
	"""Handle tutorial completion signal to show navigation buttons."""
	print("OverlayMenu: Tutorial completed, showing navigation buttons")
	tutorial_completed = true
	_set_navigation_visibility(true)
