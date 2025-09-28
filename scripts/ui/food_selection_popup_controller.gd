@tool
extends Control

# Food Selection Popup - Select food items for facility assignments

signal food_selected(food_type: int)
signal popup_closed()

@onready var background: ColorRect = $Background
@onready var popup_panel: PanelContainer = $PopupPanel
@onready var title_label: Label = $PopupPanel/VBoxContainer/HeaderContainer/TitleLabel
@onready var close_button: Button = $PopupPanel/VBoxContainer/HeaderContainer/CloseButton
@onready var food_grid: GridContainer = $PopupPanel/VBoxContainer/ScrollContainer/FoodGrid
@onready var cancel_button: Button = $PopupPanel/VBoxContainer/ButtonContainer/CancelButton
@onready var confirm_button: Button = $PopupPanel/VBoxContainer/ButtonContainer/ConfirmButton

var facility_id: String
var current_food_type: int = -1
var selected_food_type: int = -1
var food_buttons: Array[Button] = []
var food_button_group: ButtonGroup

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_signals()
		_setup_button_group()
		hide()

func _setup_signals() -> void:
	if background:
		background.gui_input.connect(_on_background_input)

	if close_button:
		close_button.pressed.connect(_close_popup)

	if cancel_button:
		cancel_button.pressed.connect(_close_popup)

	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)

func _setup_button_group() -> void:
	food_button_group = ButtonGroup.new()

func show_popup(target_facility_id: String, current_food: int = -1) -> void:
	"""Show the food selection popup for a specific facility"""
	facility_id = target_facility_id
	current_food_type = current_food
	selected_food_type = current_food

	_populate_food_grid()
	_update_confirm_button()

	show()

	# Animate popup appearance
	if popup_panel:
		popup_panel.scale = Vector2(0.8, 0.8)
		popup_panel.modulate = Color.TRANSPARENT
		var tween = create_tween()
		tween.parallel().tween_property(popup_panel, "scale", Vector2.ONE, 0.2)
		tween.parallel().tween_property(popup_panel, "modulate", Color.WHITE, 0.2)

func _close_popup() -> void:
	"""Close the popup with animation"""
	if popup_panel:
		var tween = create_tween()
		tween.parallel().tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.15)
		tween.parallel().tween_property(popup_panel, "modulate", Color.TRANSPARENT, 0.15)
		tween.tween_callback(hide)
	else:
		hide()

	popup_closed.emit()

func _populate_food_grid() -> void:
	"""Populate the grid with available food items"""
	_clear_food_buttons()

	var item_manager = GameCore.get_system("item_manager")
	var resource_tracker = GameCore.get_system("resource")
	if not item_manager or not resource_tracker:
		return

	var inventory = resource_tracker.get_inventory()

	# Get all consumable food items that are in stock
	var food_items = item_manager.get_items_by_type_enum(GlobalEnums.ItemType.FOOD)
	var available_foods: Array[ItemResource] = []
	for item_resource in food_items:
		if item_resource.is_consumable:
			var quantity = inventory.get(item_resource.item_id, 0)
			if quantity > 0:  # Only include items we have in stock
				available_foods.append(item_resource)

	# Create buttons for each available food item
	for i in range(available_foods.size()):
		var item_resource = available_foods[i]
		var quantity = inventory.get(item_resource.item_id, 0)
		_create_food_button(item_resource, quantity, i)

func _create_food_button(item_resource: ItemResource, quantity: int, food_type: int) -> void:
	"""Create a selectable button for a food item"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(150, 80)
	button.toggle_mode = true
	button.button_group = food_button_group

	# Create a container for the button content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(vbox)

	# Add icon
	var icon_container = CenterContainer.new()
	icon_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(icon_container)

	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(32, 32)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_container.add_child(texture_rect)

	# Load food icon
	var icon_path = item_resource.icon_path
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var texture = load(icon_path)
		if texture is Texture2D:
			texture_rect.texture = texture

	# Add name and quantity labels
	var name_label = Label.new()
	name_label.text = item_resource.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)

	var quantity_label = Label.new()
	quantity_label.text = "(%d available)" % quantity
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quantity_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(quantity_label)

	# Set initial state
	if food_type == current_food_type:
		button.button_pressed = true

	# Disable if no quantity available (shouldn't happen since we filter above)
	if quantity <= 0:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5)

	# Connect signal
	button.toggled.connect(func(pressed: bool): _on_food_button_toggled(food_type, pressed))

	food_grid.add_child(button)
	food_buttons.append(button)

func _clear_food_buttons() -> void:
	"""Clear all food selection buttons"""
	for button in food_buttons:
		if is_instance_valid(button):
			button.queue_free()
	food_buttons.clear()

	# Clear any existing children
	for child in food_grid.get_children():
		child.queue_free()

func _update_confirm_button() -> void:
	"""Update confirm button enabled state"""
	if not confirm_button:
		return

	# Confirm is enabled if a food is selected
	confirm_button.disabled = selected_food_type < 0

func _on_background_input(event: InputEvent) -> void:
	"""Handle clicking on background to close popup"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_popup()

func _on_food_button_toggled(food_type: int, pressed: bool) -> void:
	"""Handle food selection"""
	if pressed:
		selected_food_type = food_type
	else:
		selected_food_type = -1
	_update_confirm_button()

func _on_confirm_pressed() -> void:
	"""Handle confirm button press"""
	if selected_food_type >= 0:
		food_selected.emit(selected_food_type)
		_close_popup()