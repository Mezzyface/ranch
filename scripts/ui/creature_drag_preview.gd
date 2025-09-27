@tool
class_name CreatureDragPreview
extends Control

@export var creature_data: CreatureData :
	set(value):
		creature_data = value
		if is_inside_tree():
			_update_display()

@onready var background: ColorRect = $Background
@onready var name_label: Label = $VBox/NameLabel
@onready var species_label: Label = $VBox/SpeciesLabel
@onready var portrait: TextureRect = $VBox/Portrait

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_preview()
		_update_display()

func _setup_preview() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.8)
	z_index = 100

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

func set_creature(new_creature: CreatureData) -> void:
	creature_data = new_creature
	_update_display()