extends Control

# Creature Mini Card - Draggable card for unassigned creatures

signal drag_started(creature_data: CreatureData)
signal drag_ended(creature_data: CreatureData, dropped_on_facility: bool, facility_id: String)

@onready var background: PanelContainer = $Background
@onready var creature_name_label: Label = $Background/VBoxContainer/NameLabel
@onready var age_label: Label = $Background/VBoxContainer/AgeLabel
@onready var portrait: TextureRect = $Background/VBoxContainer/Portrait

var creature_data: CreatureData
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var original_parent: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)

func set_creature_data(data: CreatureData) -> void:
	creature_data = data
	_update_display()

func _update_display() -> void:
	if not creature_data:
		return

	if creature_name_label:
		creature_name_label.text = creature_data.creature_name

	if age_label:
		var age_category = _get_age_category_name(creature_data.get_age_category())
		age_label.text = "%s (%d weeks)" % [age_category, creature_data.age_weeks]

	# Set portrait (placeholder for now)
	if portrait:
		_set_creature_portrait()

func _get_age_category_name(category: int) -> String:
	match category:
		0: return "Baby"
		1: return "Juvenile"
		2: return "Adult"
		3: return "Elder"
		4: return "Ancient"
		_: return "Unknown"

func _set_creature_portrait() -> void:
	# Create a placeholder portrait
	var image = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.4, 1))  # Brown for creatures
	var texture = ImageTexture.create_from_image(image)
	portrait.texture = texture

func _on_gui_input(event: InputEvent) -> void:
	if not creature_data:
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
					modulate = Color.WHITE
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