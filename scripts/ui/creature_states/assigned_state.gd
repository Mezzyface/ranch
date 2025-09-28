class_name AssignedState
extends CreatureState

# Assigned state - creature moves to and stays at facility position

const LERP_WEIGHT: float = 5.0
const ARRIVAL_DISTANCE: float = 5.0

var target_position: Vector2 = Vector2.ZERO
var facility_id: String = ""
var has_arrived: bool = false

func enter() -> void:
	has_arrived = false

	# Get the target position and facility ID from the sprite controller
	if sprite_controller.get("assigned_facility_id"):
		facility_id = sprite_controller.assigned_facility_id

	if sprite_controller.get("target_position"):
		target_position = sprite_controller.target_position

	# Start with appropriate directional animation
	var direction = (target_position - sprite_controller.position).normalized()
	if sprite_controller.has_method("_update_movement_animation"):
		sprite_controller._update_movement_animation(direction)

func physics_update(delta: float) -> void:
	if target_position == Vector2.ZERO:
		return

	if not has_arrived:
		# Smoothly move to facility position
		var new_pos = sprite_controller.position.lerp(target_position, LERP_WEIGHT * delta)
		sprite_controller.position = new_pos

		# Check if close enough to facility
		var distance = sprite_controller.position.distance_to(target_position)
		if distance < ARRIVAL_DISTANCE:
			# Stay at facility position
			sprite_controller.position = target_position
			has_arrived = true

			# Switch to idle animation
			if sprite_controller.has_method("_play_safe_animation"):
				sprite_controller._play_safe_animation("idle")

			# Play entrance effect
			if sprite_controller.has_method("play_entrance_effect"):
				sprite_controller.play_entrance_effect()
		else:
			# Update animation based on movement direction
			var direction = (target_position - sprite_controller.position).normalized()
			if sprite_controller.has_method("_update_movement_animation"):
				sprite_controller._update_movement_animation(direction)

func exit() -> void:
	# Play exit effect when leaving assigned state
	if sprite_controller.has_method("play_exit_effect"):
		sprite_controller.play_exit_effect()

func get_state_name() -> String:
	return "Assigned"