class_name IdleState
extends CreatureState

# Idle state - creature stands still for a random duration

const IDLE_DURATION_MIN: float = 1.0
const IDLE_DURATION_MAX: float = 3.0

var idle_timer: float = 0.0

func enter() -> void:
	idle_timer = randf_range(IDLE_DURATION_MIN, IDLE_DURATION_MAX)

	# Play idle animation
	if sprite_controller.has_method("_play_safe_animation"):
		sprite_controller._play_safe_animation("idle")

func update(delta: float) -> void:
	idle_timer -= delta

	if idle_timer <= 0.0:
		# Transition to walking state
		state_machine.transition_to("Walking")

func get_state_name() -> String:
	return "Idle"