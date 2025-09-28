class_name DraggingState
extends CreatureState

# Dragging state - creature follows mouse while being dragged

var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var is_over_facility: bool = false
var target_facility_card = null

func enter() -> void:
	# Store the original position in case we need to snap back
	original_position = sprite_controller.position

	# Calculate offset between mouse and sprite position
	drag_offset = sprite_controller.get_global_mouse_position() - sprite_controller.global_position

	# Change visual appearance to indicate dragging
	sprite_controller.modulate = Color(1.2, 1.2, 1.2, 0.8)
	sprite_controller.scale = Vector2(2.5, 2.5)

	# Play idle animation while dragging
	if sprite_controller.has_method("_play_safe_animation"):
		sprite_controller._play_safe_animation("idle")

func physics_update(delta: float) -> void:
	# Follow mouse position
	var mouse_pos = sprite_controller.get_global_mouse_position()
	var parent = sprite_controller.get_parent()
	if parent:
		# Convert global to local position based on parent type
		if parent is Node2D:
			sprite_controller.position = parent.to_local(mouse_pos)
		elif parent is Control:
			# For Control nodes, we need to convert differently
			sprite_controller.position = mouse_pos - parent.global_position
		else:
			# Fallback to direct mouse position
			sprite_controller.position = mouse_pos

	# Check if we're over a facility card
	_check_facility_hover()

func exit() -> void:
	# Reset visual appearance
	sprite_controller.modulate = Color.WHITE
	sprite_controller.scale = Vector2(2, 2)

	# If we're over a valid facility, trigger assignment
	if is_over_facility and target_facility_card:
		_handle_facility_drop()
	else:
		# Return to original position if not dropped on a facility
		sprite_controller.position = original_position

func _check_facility_hover() -> void:
	"""Check if the sprite is hovering over a facility card"""
	is_over_facility = false
	target_facility_card = null

	# Navigate up to find the facility view controller
	# sprite_controller -> CreatureArea -> VBoxContainer -> MarginContainer -> FacilityView
	var current_node = sprite_controller.get_parent()
	while current_node:
		if current_node.has_method("get_facility_cards"):
			break
		current_node = current_node.get_parent()

	if current_node and current_node.has_method("get_facility_cards"):
		var facility_cards = current_node.get_facility_cards()

		for card in facility_cards:
			if not is_instance_valid(card):
				continue

			# Check if mouse is over this card
			var card_rect = card.get_global_rect()
			var mouse_pos = sprite_controller.get_global_mouse_position()

			if card_rect.has_point(mouse_pos):
				is_over_facility = true
				target_facility_card = card

				# Visual feedback for valid drop target
				sprite_controller.modulate = Color(0.8, 1.2, 0.8, 0.9)
				break

	# Reset color if not over a facility
	if not is_over_facility:
		sprite_controller.modulate = Color(1.2, 1.2, 1.2, 0.8)

func _handle_facility_drop() -> void:
	"""Handle dropping the creature on a facility"""
	if not target_facility_card or not sprite_controller.creature_data:
		return

	var facility_id = target_facility_card.get_facility_id()

	# Check if facility is unlocked
	var facility_system = sprite_controller.facility_system
	if facility_system and facility_system.is_facility_unlocked(facility_id):
		# Navigate up to find the facility view controller
		var current_node = sprite_controller.get_parent()
		while current_node:
			if current_node.has_method("_show_assignment_dialog"):
				break
			current_node = current_node.get_parent()

		if current_node and current_node.has_method("_show_assignment_dialog"):
			# Show the assignment dialog for this facility
			current_node._show_assignment_dialog(facility_id)

		# Move sprite to facility position after a delay
		sprite_controller.get_tree().create_timer(0.5).timeout.connect(
			func():
				var facility_pos = target_facility_card.global_position + target_facility_card.size / 2
				var parent = sprite_controller.get_parent()
				var local_pos: Vector2

				# Convert global to local position based on parent type
				if parent is Node2D:
					local_pos = parent.to_local(facility_pos)
				elif parent is Control:
					local_pos = facility_pos - parent.global_position
				else:
					local_pos = facility_pos

				state_machine.assign_to_facility(facility_id, local_pos)
		)
	else:
		# Return to original position if facility is locked
		sprite_controller.position = original_position
		state_machine.transition_to("Idle")

func get_state_name() -> String:
	return "Dragging"
