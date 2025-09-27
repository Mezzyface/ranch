@tool
class_name CreatureCard
extends PanelContainer

signal dragged(creature: CreatureData, card: CreatureCard)
signal dropped(creature: CreatureData, slot: int)
signal clicked(creature: CreatureData)

@export var creature_data: CreatureData :
	set(value):
		creature_data = value
		if is_inside_tree():
			_update_display()

@export var slot_index: int = -1
@export var is_active_slot: bool = true
@export var is_empty_slot: bool = false

@onready var portrait: TextureRect = $VBox/Portrait
@onready var name_label: Label = $VBox/NameLabel
@onready var level_label: Label = $VBox/LevelLabel
@onready var species_label: Label = $VBox/SpeciesLabel
@onready var stamina_bar: ProgressBar = $VBox/Stats/StaminaBar
@onready var empty_slot_label: Label = $VBox/EmptySlotLabel

var _is_dragging: bool = false
var _mouse_in: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_card()
		_update_display()

func _setup_card() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _update_display() -> void:
	if not is_inside_tree():
		return

	if is_empty_slot or not creature_data:
		_show_empty_slot()
		return

	_show_creature_data()

func _show_empty_slot() -> void:
	if empty_slot_label:
		empty_slot_label.show()
		empty_slot_label.text = "Empty Slot"

	if name_label:
		name_label.hide()
	if level_label:
		level_label.hide()
	if species_label:
		species_label.hide()
	if portrait:
		portrait.hide()
	if stamina_bar and stamina_bar.get_parent():
		stamina_bar.get_parent().hide()

func _show_creature_data() -> void:
	if empty_slot_label:
		empty_slot_label.hide()

	if name_label:
		name_label.show()
		name_label.text = creature_data.creature_name

	if species_label:
		species_label.show()
		var species_system = GameCore.get_system("species")
		if species_system:
			var species = species_system.get_species(creature_data.species_id)
			if species:
				species_label.text = species.display_name
			else:
				species_label.text = "Unknown Species"
		else:
			species_label.text = creature_data.species_id

	if level_label:
		level_label.show()
		level_label.text = "Age: %d weeks" % creature_data.age_weeks

	if portrait:
		portrait.show()
		_set_portrait_image()

	if stamina_bar and stamina_bar.get_parent():
		stamina_bar.get_parent().show()
		# Use constitution for health and dexterity for stamina as rough approximations
		var stamina =creature_data.stamina_current  # Scale dexterity for staminastamina_bar.max_value = stamina
		stamina_bar.value = stamina

func _on_mouse_entered() -> void:
	_mouse_in = true
	if not is_empty_slot and creature_data:
		_highlight(true)

func _on_mouse_exited() -> void:
	_mouse_in = false
	if not _is_dragging:
		_highlight(false)

func _highlight(enable: bool) -> void:
	if enable:
		modulate = Color(1.2, 1.2, 1.2, 1.0)
	else:
		modulate = Color.WHITE

func _on_gui_input(event: InputEvent) -> void:
	if not creature_data or is_empty_slot:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				clicked.emit(creature_data)
			elif _is_dragging:
				_is_dragging = false
				_highlight(_mouse_in)

func _can_drop_data(position: Vector2, data) -> bool:
	if not data.has("creature"):
		return false

	var source_creature = data.creature as CreatureData
	if not source_creature:
		return false

	if is_active_slot:
		return true
	else:
		return true

func _drop_data(position: Vector2, data) -> void:
	if data.has("creature"):
		var source_creature = data.creature as CreatureData
		dropped.emit(source_creature, slot_index)

func _get_drag_data(position: Vector2):
	if not creature_data or is_empty_slot:
		return null

	_is_dragging = true

	var preview = _create_drag_preview()
	set_drag_preview(preview)

	dragged.emit(creature_data, self)

	return {
		"creature": creature_data,
		"source_slot": slot_index,
		"source_card": self
	}

func _create_drag_preview() -> Control:
	var preview = CreatureCard.new()
	preview.creature_data = creature_data
	preview.custom_minimum_size = size
	preview.modulate = Color(1.0, 1.0, 1.0, 0.7)
	return preview

func set_creature(new_creature: CreatureData) -> void:
	creature_data = new_creature
	is_empty_slot = (new_creature == null)
	_update_display()

func clear_slot() -> void:
	creature_data = null
	is_empty_slot = true
	_update_display()

func _set_portrait_image() -> void:
	if not creature_data or not portrait:
		return

	var species_system = GameCore.get_system("species")
	if not species_system:
		_set_default_portrait()
		return

	var species = species_system.get_species(creature_data.species_id)
	if not species:
		_set_default_portrait()
		return

	# Try species-defined paths
	var texture: Texture2D = null
	if not species.icon_path.is_empty():
		texture = _load_texture_safe(species.icon_path)

	if not texture and not species.sprite_path.is_empty():
		texture = _load_texture_safe(species.sprite_path)

	# Set the texture or fallback to default
	if texture:
		portrait.texture = texture
	else:
		_set_default_portrait()

func _load_texture_safe(path: String) -> Texture2D:
	if path.is_empty():
		return null

	if ResourceLoader.exists(path):
		var resource = load(path)
		if resource is Texture2D:
			return resource as Texture2D

	return null

func _set_default_portrait() -> void:
	# Keep the existing texture if one is already set (from scene file)
	# This preserves the default image you set in the creature card scene
	pass
