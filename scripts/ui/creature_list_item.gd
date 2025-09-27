@tool
class_name CreatureListItem
extends PanelContainer

signal dragged(creature: CreatureData, item: CreatureListItem)
signal clicked(creature: CreatureData)
signal double_clicked(creature: CreatureData)

@export var creature_data: CreatureData :
	set(value):
		creature_data = value
		if is_inside_tree():
			_update_display()

@onready var name_label: Label = $HBox/NameLabel
@onready var species_label: Label = $HBox/SpeciesLabel
@onready var age_label: Label = $HBox/AgeLabel
@onready var stats_label: Label = $HBox/StatsLabel

var _is_dragging: bool = false
var _mouse_in: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_item()
		_update_display()

func _setup_item() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _update_display() -> void:
	if not is_inside_tree() or not creature_data:
		return

	if name_label:
		name_label.text = creature_data.creature_name

	if species_label:
		var species_system = GameCore.get_system("species")
		if species_system:
			var species = species_system.get_species(creature_data.species_id)
			if species:
				species_label.text = species.display_name
			else:
				species_label.text = "Unknown"
		else:
			species_label.text = creature_data.species_id

	if age_label:
		age_label.text = "%d weeks" % creature_data.age_weeks

	if stats_label:
		var health = creature_data.get_stat("CON") * 2
		var stamina = creature_data.get_stat("DEX") * 2
		stats_label.text = "HP:%d ST:%d" % [health, stamina]

func _on_mouse_entered() -> void:
	_mouse_in = true
	_highlight(true)

func _on_mouse_exited() -> void:
	_mouse_in = false
	if not _is_dragging:
		_highlight(false)

func _highlight(enable: bool) -> void:
	if enable:
		modulate = Color(1.1, 1.1, 1.1, 1.0)
	else:
		modulate = Color.WHITE

func _on_gui_input(event: InputEvent) -> void:
	if not creature_data:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				if mouse_event.double_click:
					double_clicked.emit(creature_data)
				else:
					clicked.emit(creature_data)
			elif _is_dragging:
				_is_dragging = false
				_highlight(_mouse_in)

func _get_drag_data(position: Vector2):
	if not creature_data:
		return null

	_is_dragging = true

	var preview = _create_drag_preview()
	set_drag_preview(preview)

	dragged.emit(creature_data, self)

	return {
		"creature": creature_data,
		"source_item": self,
		"from_stable": true
	}

func _create_drag_preview() -> Control:
	var preview_scene = preload("res://scenes/ui/components/creature_drag_preview.tscn")
	var preview = preview_scene.instantiate() as CreatureDragPreview
	preview.creature_data = creature_data
	return preview

func set_creature(new_creature: CreatureData) -> void:
	creature_data = new_creature
	_update_display()