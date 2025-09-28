class_name CreatureEntityDraggingState
extends CreatureEntityState

# Dragging state for creature entities

func enter() -> void:
	"""Start dragging state - play walk animation and provide visual feedback"""
	if sprite:
		entity_controller._play_safe_animation("walk")
		# Make sprite slightly transparent while dragging
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.8)

	# Could add additional visual effects here like a shadow or outline

func exit() -> void:
	"""Clean up dragging state"""
	if sprite:
		# Restore normal appearance
		sprite.modulate = Color.WHITE

func update(delta: float) -> void:
	"""Handle dragging behavior"""
	# The actual movement is handled by _gui_input in the controller
	# This state mainly handles visual feedback
	pass

func get_state_name() -> String:
	return "Dragging"