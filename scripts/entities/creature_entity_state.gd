class_name CreatureEntityState
extends RefCounted

# Base class for creature entity states (Control-based)

var entity_controller: Control
var state_machine
var sprite: AnimatedSprite2D

func _init(controller: Control, machine) -> void:
	entity_controller = controller
	state_machine = machine
	# Get the sprite from the controller
	if controller.has_method("get") and controller.get("sprite"):
		sprite = controller.get("sprite")
	elif controller.has_node("AnimatedSprite2D"):
		sprite = controller.get_node("AnimatedSprite2D")

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
	return "BaseEntityState"