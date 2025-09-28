class_name CreatureStateMachine
extends RefCounted

# State machine for managing creature sprite states

var sprite_controller: AnimatedSprite2D
var states: Dictionary = {}
var current_state: CreatureState = null
var previous_state: CreatureState = null

func _init(controller: AnimatedSprite2D) -> void:
	sprite_controller = controller

	# Initialize all states
	states["Idle"] = IdleState.new(sprite_controller, self)
	states["Walking"] = WalkingState.new(sprite_controller, self)
	states["Assigned"] = AssignedState.new(sprite_controller, self)
	states["Dragging"] = DraggingState.new(sprite_controller, self)

func start(initial_state_name: String = "Idle") -> void:
	"""Start the state machine with the given initial state"""
	if states.has(initial_state_name):
		current_state = states[initial_state_name]
		current_state.enter()
	else:
		push_error("CreatureStateMachine: Invalid initial state: " + initial_state_name)

func transition_to(state_name: String) -> void:
	"""Transition to a new state"""
	if not states.has(state_name):
		push_error("CreatureStateMachine: State not found: " + state_name)
		return

	if current_state:
		previous_state = current_state
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()

func update(delta: float) -> void:
	"""Update the current state"""
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	"""Physics update for the current state"""
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent) -> void:
	"""Pass input events to the current state"""
	if current_state:
		current_state.handle_input(event)

func get_current_state_name() -> String:
	"""Get the name of the current state"""
	if current_state:
		return current_state.get_state_name()
	return "None"

func is_in_state(state_name: String) -> bool:
	"""Check if currently in the specified state"""
	return get_current_state_name() == state_name

func force_state(state_name: String) -> void:
	"""Force transition to a state without calling exit on current state"""
	if states.has(state_name):
		previous_state = current_state
		current_state = states[state_name]
		current_state.enter()

func assign_to_facility(facility_id: String, facility_position: Vector2) -> void:
	"""Helper method to handle facility assignment"""
	# Update sprite controller properties that the assigned state will use
	if sprite_controller.has_method("set"):
		sprite_controller.set("assigned_facility_id", facility_id)
		sprite_controller.set("target_position", facility_position)

	# Transition to assigned state
	transition_to("Assigned")

func unassign_from_facility() -> void:
	"""Helper method to handle facility unassignment"""
	# Clear sprite controller properties
	if sprite_controller.has_method("set"):
		sprite_controller.set("assigned_facility_id", "")
		sprite_controller.set("target_position", Vector2.ZERO)

	# Transition back to idle state
	transition_to("Idle")