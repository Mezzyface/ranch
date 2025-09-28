class_name CreatureEntityWalkingState
extends CreatureEntityState

# Walking state for creature entities

const MOVEMENT_SPEED: float = 50.0
const ARRIVAL_THRESHOLD: float = 5.0

func enter() -> void:
	"""Start walking state - play walk animation"""
	if sprite:
		entity_controller._play_safe_animation("walk")

func exit() -> void:
	"""Clean up walking state"""
	pass

func update(delta: float) -> void:
	"""Move towards target position"""
	if not entity_controller.target_position or entity_controller.target_position == Vector2.ZERO:
		# No target, go back to idle
		state_machine.transition_to("Idle")
		return

	var current_pos = entity_controller.global_position
	var target_pos = entity_controller.target_position
	var distance = current_pos.distance_to(target_pos)

	# Check if we've arrived
	if distance <= ARRIVAL_THRESHOLD:
		state_machine.transition_to("Idle")
		return

	# Move towards target
	var direction = (target_pos - current_pos).normalized()
	var movement = direction * MOVEMENT_SPEED * delta

	# Update movement animation based on direction
	if entity_controller.has_method("_update_movement_animation"):
		entity_controller._update_movement_animation(direction)

	# Move the entity controller
	entity_controller.global_position += movement

	# Clamp to bounds if needed
	if entity_controller.has_method("_clamp_to_bounds"):
		entity_controller.global_position = entity_controller._clamp_to_bounds(entity_controller.global_position)

func get_state_name() -> String:
	return "Walking"