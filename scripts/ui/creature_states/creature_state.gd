class_name CreatureState
extends RefCounted

# Base class for creature sprite states

var sprite_controller: AnimatedSprite2D
var state_machine

func _init(controller: AnimatedSprite2D, machine) -> void:
	sprite_controller = controller
	state_machine = machine

func enter() -> void:
	"""Called when entering this state"""
	pass

func exit() -> void:
	"""Called when exiting this state"""
	pass

func update(delta: float) -> void:
	"""Called every frame while in this state"""
	pass

func physics_update(delta: float) -> void:
	"""Called every physics frame while in this state"""
	pass

func handle_input(event: InputEvent) -> void:
	"""Handle input events while in this state"""
	pass

func get_state_name() -> String:
	"""Return the name of this state"""
	return "BaseState"