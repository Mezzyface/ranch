class_name WalkingState
extends CreatureState

# Walking state - creature walks to random positions within bounds

const WALK_SPEED: float = 50.0
const DIRECTION_CHANGE_MIN: float = 2.0
const DIRECTION_CHANGE_MAX: float = 5.0

var target_position: Vector2 = Vector2.ZERO
var walk_timer: float = 0.0

func enter() -> void:
	walk_timer = randf_range(DIRECTION_CHANGE_MIN, DIRECTION_CHANGE_MAX)

	# Pick random target position within bounds
	if sprite_controller.has_method("_get_random_position_in_bounds"):
		target_position = sprite_controller._get_random_position_in_bounds()
		# Ensure target is within bounds
		if sprite_controller.has_method("_clamp_to_bounds"):
			target_position = sprite_controller._clamp_to_bounds(target_position)

	# Start walking animation in the right direction
	_update_animation_for_direction()

func physics_update(delta: float) -> void:
	walk_timer -= delta

	# Move towards target
	var direction = (target_position - sprite_controller.position).normalized()
	var new_position = sprite_controller.position + direction * WALK_SPEED * delta

	# Clamp position to stay within bounds
	if sprite_controller.has_method("_clamp_to_bounds"):
		new_position = sprite_controller._clamp_to_bounds(new_position)

	sprite_controller.position = new_position

	# Update animation based on movement direction
	if sprite_controller.has_method("_update_movement_animation"):
		sprite_controller._update_movement_animation(direction)

	# Check if reached target or timer expired
	var distance = sprite_controller.position.distance_to(target_position)
	if distance < 10.0 or walk_timer <= 0.0:
		# Transition back to idle
		state_machine.transition_to("Idle")

func _update_animation_for_direction() -> void:
	"""Update animation based on initial direction to target"""
	var direction = (target_position - sprite_controller.position).normalized()
	if sprite_controller.has_method("_update_movement_animation"):
		sprite_controller._update_movement_animation(direction)

func get_state_name() -> String:
	return "Walking"