@tool
extends Control

# Activity Selection Popup - Select training activities for facility assignments

signal activity_selected(activity: int)
signal popup_closed()

@onready var background: ColorRect = $Background
@onready var popup_panel: PanelContainer = $PopupPanel
@onready var title_label: Label = $PopupPanel/VBoxContainer/HeaderContainer/TitleLabel
@onready var close_button: Button = $PopupPanel/VBoxContainer/HeaderContainer/CloseButton
@onready var activity_grid: GridContainer = $PopupPanel/VBoxContainer/ScrollContainer/ActivityGrid
@onready var cancel_button: Button = $PopupPanel/VBoxContainer/ButtonContainer/CancelButton
@onready var confirm_button: Button = $PopupPanel/VBoxContainer/ButtonContainer/ConfirmButton

var facility_id: String
var facility_resource: FacilityResource
var current_activity: int = -1
var selected_activity: int = -1
var activity_buttons: Array[Button] = []
var activity_button_group: ButtonGroup

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
	activity_button_group = ButtonGroup.new()

func show_popup(target_facility_id: String, target_facility_resource: FacilityResource, current_selected_activity: int = -1) -> void:
	"""Show the activity selection popup for a specific facility"""
	facility_id = target_facility_id
	facility_resource = target_facility_resource
	current_activity = current_selected_activity
	selected_activity = current_selected_activity

	_populate_activity_grid()
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

func _populate_activity_grid() -> void:
	"""Populate the grid with available activities for this facility"""
	_clear_activity_buttons()

	if not facility_resource:
		return

	# Get supported activities from the facility
	var supported_activities = facility_resource.supported_activities
	if supported_activities.is_empty():
		return

	# Create buttons for each supported activity
	for activity in supported_activities:
		_create_activity_button(activity)

func _create_activity_button(activity: int) -> void:
	"""Create a selectable button for an activity"""
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 120)
	button.toggle_mode = true
	button.button_group = activity_button_group

	# Create a container for the button content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.set("theme_override_constants/separation", 8)  # Will use theme if available
	button.add_child(vbox)

	# Add icon
	var icon_container = CenterContainer.new()
	icon_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(icon_container)

	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(48, 48)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_container.add_child(texture_rect)

	# Create activity icon based on type
	var activity_color = _get_activity_color(activity)
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(activity_color)
	var texture = ImageTexture.new()
	texture.set_image(image)
	texture_rect.texture = texture

	# Add activity name label
	var name_label = Label.new()
	name_label.text = _get_activity_name(activity)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)

	# Add description label
	var desc_label = Label.new()
	desc_label.text = _get_activity_description(activity)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Using default theme font size
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(desc_label)

	# Set initial state
	if activity == current_activity:
		button.button_pressed = true

	# Connect signal
	button.toggled.connect(func(pressed: bool): _on_activity_button_toggled(activity, pressed))

	activity_grid.add_child(button)
	activity_buttons.append(button)

func _clear_activity_buttons() -> void:
	"""Clear all activity selection buttons"""
	for button in activity_buttons:
		if is_instance_valid(button):
			button.queue_free()
	activity_buttons.clear()

	# Clear any existing children
	for child in activity_grid.get_children():
		child.queue_free()

func _update_confirm_button() -> void:
	"""Update confirm button enabled state"""
	if not confirm_button:
		return

	# Confirm is enabled if an activity is selected
	confirm_button.disabled = selected_activity < 0

func _get_activity_color(activity: int) -> Color:
	"""Get color for activity type (matching facility_card.gd)"""
	match activity:
		0: return Color(0.8, 0.4, 0.4, 1)  # Red for Physical
		1: return Color(0.4, 0.8, 0.4, 1)  # Green for Agility
		2: return Color(0.4, 0.4, 0.8, 1)  # Blue for Mental
		3: return Color(0.8, 0.8, 0.4, 1)  # Yellow for Discipline
		_: return Color(0.5, 0.5, 0.5, 1)  # Gray for unknown

func _get_activity_name(activity: int) -> String:
	"""Get display name for activity type"""
	match activity:
		0: return "Physical Training"    # TrainingActivity.PHYSICAL
		1: return "Agility Training"     # TrainingActivity.AGILITY
		2: return "Mental Training"      # TrainingActivity.MENTAL
		3: return "Discipline Training"  # TrainingActivity.DISCIPLINE
		_: return "Unknown Activity"

func _get_activity_description(activity: int) -> String:
	"""Get description for activity type"""
	match activity:
		0: return "Strength & Constitution"
		1: return "Dexterity"
		2: return "Intelligence & Wisdom"
		3: return "Discipline"
		_: return "Unknown"

func _on_background_input(event: InputEvent) -> void:
	"""Handle clicking on background to close popup"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_popup()

func _on_activity_button_toggled(activity: int, pressed: bool) -> void:
	"""Handle activity selection"""
	if pressed:
		selected_activity = activity
	else:
		selected_activity = -1
	_update_confirm_button()

func _on_confirm_pressed() -> void:
	"""Handle confirm button press"""
	if selected_activity >= 0:
		activity_selected.emit(selected_activity)
		_close_popup()