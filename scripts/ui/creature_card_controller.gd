extends Control

# Unified Creature Card - Combines visual representation with drag-and-drop functionality
# Root node is Control for proper UI interaction

signal drag_started(creature_data: CreatureData)
signal drag_ended(creature_data: CreatureData, dropped_on_facility: bool, facility_id: String)
signal clicked(creature_data: CreatureData)

# UI references
@onready var background: PanelContainer = $Background
@onready var portrait: TextureRect = $Background/MarginContainer/VBox/Portrait
@onready var name_label: Label = $Background/MarginContainer/VBox/NameLabel
@onready var species_label: Label = $Background/MarginContainer/VBox/SpeciesLabel
@onready var level_label: Label = $Background/MarginContainer/VBox/LevelLabel
@onready var stamina_bar: ProgressBar = $Background/MarginContainer/VBox/Stats/StaminaBar
@onready var stamina_label: Label = $Background/MarginContainer/VBox/Stats/StaminaLabel
@onready var empty_slot_label: Label = $Background/MarginContainer/VBox/EmptySlotLabel
@onready var stats_container: VBoxContainer = $Background/MarginContainer/VBox/Stats

# Creature data
var creature_data: CreatureData

# Drag and drop state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var original_parent: Node = null
var _mouse_in: bool = false

# Visual state
var is_empty_slot: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_setup_signals()
	_update_display()

func _setup_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func set_creature_data(data: CreatureData) -> void:
	creature_data = data
	is_empty_slot = (data == null)
	_update_display()

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
	if species_label:
		species_label.hide()
	if level_label:
		level_label.hide()
	if portrait:
		portrait.hide()
	if stats_container:
		stats_container.hide()

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
		var age_category = _get_age_category_name(creature_data.get_age_category())
		level_label.text = "%s (%d weeks)" % [age_category, creature_data.age_weeks]

	if portrait:
		portrait.show()
		_set_creature_portrait()

	if stats_container:
		stats_container.show()
		if stamina_bar:
			var max_stamina = creature_data.stamina_max
			var current_stamina = creature_data.stamina_current
			stamina_bar.max_value = max_stamina
			stamina_bar.value = current_stamina
		if stamina_label:
			stamina_label.text = "%d" % creature_data.stamina_current

func _get_age_category_name(category: int) -> String:
	match category:
		0: return "Baby"
		1: return "Juvenile"
		2: return "Adult"
		3: return "Elder"
		4: return "Ancient"
		_: return "Unknown"

func _set_creature_portrait() -> void:
	if not creature_data or not portrait:
		return

	var species_system = GameCore.get_system("species")
	if not species_system:
		_set_fallback_portrait()
		return

	var species = species_system.get_species(creature_data.species_id)
	if not species:
		_set_fallback_portrait()
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
		_set_fallback_portrait()

func _load_texture_safe(path: String) -> Texture2D:
	if path.is_empty():
		return null

	if ResourceLoader.exists(path):
		var resource = load(path)
		if resource is Texture2D:
			return resource as Texture2D

	return null

func _set_fallback_portrait() -> void:
	if not portrait:
		return

	# Create a placeholder portrait
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.4, 1))  # Brown for creatures
	var texture = ImageTexture.create_from_image(image)
	portrait.texture = texture

func _on_mouse_entered() -> void:
	_mouse_in = true
	if not is_empty_slot and creature_data and not is_dragging:
		_highlight(true)

func _on_mouse_exited() -> void:
	_mouse_in = false
	if not is_dragging:
		_highlight(false)

func _highlight(enable: bool) -> void:
	if enable:
		modulate = Color(1.1, 1.1, 1.1, 1.0)
	else:
		modulate = Color.WHITE

func _on_gui_input(event: InputEvent) -> void:
	if not creature_data or is_empty_slot:
		return

	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = global_position - mouse_event.global_position
				original_position = global_position
				original_parent = get_parent()

				# Move to viewport for dragging
				var viewport = get_viewport()
				get_parent().remove_child(self)
				viewport.add_child(self)

				# Visual feedback
				modulate = Color(1.0, 1.0, 1.0, 0.7)
				z_index = 100

				drag_started.emit(creature_data)
				clicked.emit(creature_data)

			else:
				# End dragging
				if is_dragging:
					is_dragging = false

					# Check what we're dropped on
					var dropped_on_facility = false
					var facility_id = ""

					var facility_card = _get_facility_under_mouse()
					if facility_card:
						dropped_on_facility = true
						facility_id = facility_card.get_facility_id()

					# Return to original parent
					get_parent().remove_child(self)
					original_parent.add_child(self)
					global_position = original_position

					# Reset visual
					modulate = Color.WHITE if not _mouse_in else Color(1.1, 1.1, 1.1, 1.0)
					z_index = 0

					drag_ended.emit(creature_data, dropped_on_facility, facility_id)

	elif event is InputEventMouseMotion:
		if is_dragging:
			# Update position while dragging
			global_position = event.global_position + drag_offset

func _get_facility_under_mouse() -> Control:
	"""Find if mouse is over a facility card"""
	var mouse_pos = get_global_mouse_position()

	# Find the facility view in the scene
	var facility_view = _find_facility_view()
	if not facility_view:
		return null

	# Check each facility card
	if facility_view.has_method("get_facility_cards"):
		var facility_cards = facility_view.get_facility_cards()

		for card in facility_cards:
			if not is_instance_valid(card):
				continue

			var card_rect = card.get_global_rect()
			if card_rect.has_point(mouse_pos):
				return card

	return null

func _find_facility_view() -> Node:
	"""Find the FacilityView node in the scene tree"""
	var root = get_tree().root
	return _find_node_by_script(root, "facility_view_controller.gd")

func _find_node_by_script(node: Node, script_name: String) -> Node:
	"""Recursively find a node with the specified script"""
	if node.get_script():
		var script_path = node.get_script().resource_path
		if script_path.ends_with(script_name):
			return node

	for child in node.get_children():
		var result = _find_node_by_script(child, script_name)
		if result:
			return result

	return null

# Additional methods for compatibility
func set_creature(data: CreatureData) -> void:
	set_creature_data(data)

func clear_slot() -> void:
	creature_data = null
	is_empty_slot = true
	_update_display()

func is_empty() -> bool:
	return is_empty_slot or creature_data == null