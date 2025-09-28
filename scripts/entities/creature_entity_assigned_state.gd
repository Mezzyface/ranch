class_name CreatureEntityAssignedState
extends CreatureEntityState

# Assigned state for creature entities - when assigned to a facility

const MOVEMENT_SPEED: float = 75.0
const ARRIVAL_THRESHOLD: float = 8.0
const FACILITY_HOVER_DISTANCE: float = 15.0

var moving_to_facility: bool = true
var hover_timer: float = 0.0
var hover_angle: float = 0.0

func enter() -> void:
	"""Start assigned state - move to facility"""
	if sprite:
		entity_controller._play_safe_animation("walk")

	moving_to_facility = true
	hover_timer = 0.0
	hover_angle = 0.0

	# Play entrance effect
	if entity_controller.has_method("play_entrance_effect"):
		entity_controller.play_entrance_effect()

func exit() -> void:
	"""Clean up assigned state"""
	moving_to_facility = false

	# Play exit effect
	if entity_controller.has_method("play_exit_effect"):
		entity_controller.play_exit_effect()

func update(delta: float) -> void:
	"""Handle assigned state behavior"""
	if not entity_controller.target_position or entity_controller.target_position == Vector2.ZERO:
		# No target, something went wrong
		state_machine.transition_to("Idle")
		return

	var current_pos = entity_controller.global_position
	var facility_pos = entity_controller.target_position

	if moving_to_facility:
		# Move towards facility
		var distance = current_pos.distance_to(facility_pos)

		if distance <= ARRIVAL_THRESHOLD:
			# Arrived at facility, start hovering
			moving_to_facility = false
			if sprite:
				entity_controller._play_safe_animation("idle")
		else:
			# Keep moving towards facility
			var direction = (facility_pos - current_pos).normalized()
			var movement = direction * MOVEMENT_SPEED * delta

			# Update movement animation
			if entity_controller.has_method("_update_movement_animation"):
				entity_controller._update_movement_animation(direction)

			entity_controller.global_position += movement
	else:
		# Hover around the facility
		hover_timer += delta
		hover_angle += delta * 1.5  # Rotation speed

		# Create a small circular hover pattern
		var hover_offset = Vector2(
			cos(hover_angle) * FACILITY_HOVER_DISTANCE,
			sin(hover_angle) * FACILITY_HOVER_DISTANCE * 0.5  # Elliptical pattern
		)

		entity_controller.global_position = facility_pos + hover_offset

		# Play idle animation while hovering
		if sprite:
			entity_controller._play_safe_animation("idle")

func get_state_name() -> String:
	return "Assigned"