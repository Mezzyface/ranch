class_name CreatureEntityIdleState
extends CreatureEntityState

# Idle state for creature entities

var idle_timer: float = 0.0
var next_idle_action: float = 0.0

func enter() -> void:
	"""Start idle state - play idle animation and set up random movement"""
	if sprite:
		entity_controller._play_safe_animation("idle")

	# Set up next idle action (random movement or animation)
	next_idle_action = randf_range(2.0, 5.0)
	idle_timer = 0.0

func exit() -> void:
	"""Clean up idle state"""
	idle_timer = 0.0
	next_idle_action = 0.0

func update(delta: float) -> void:
	"""Update idle behavior"""
	idle_timer += delta

	# Occasionally do something interesting
	if idle_timer >= next_idle_action:
		_perform_idle_action()
		# Reset timer for next action
		next_idle_action = randf_range(3.0, 8.0)
		idle_timer = 0.0

func _perform_idle_action() -> void:
	"""Perform a random idle action"""
	var action = randi() % 3

	match action:
		0:
			# Move to a random position
			if entity_controller.has_method("_get_random_position_in_bounds"):
				var new_pos = entity_controller._get_random_position_in_bounds()
				entity_controller.target_position = new_pos
				state_machine.transition_to("Walking")
		1:
			# Play idle animation (already playing, but refresh)
			if sprite:
				entity_controller._play_safe_animation("idle")
		2:
			# Just wait longer
			pass

func get_state_name() -> String:
	return "Idle"