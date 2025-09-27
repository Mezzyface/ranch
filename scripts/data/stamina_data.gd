class_name StaminaData extends Resource

# Stamina data for serialization and tracking
@export var current_stamina: int = 100
@export var max_stamina: int = 100
@export var depletion_modifier: float = 1.0
@export var recovery_modifier: float = 1.0
@export var last_activity_week: int = -1
@export var exhaustion_count: int = 0

func _init(initial_stamina: int = 100) -> void:
	current_stamina = initial_stamina
	max_stamina = 100

func is_exhausted() -> bool:
	return current_stamina <= 20

func get_stamina_percentage() -> float:
	if max_stamina <= 0:
		return 0.0
	return float(current_stamina) / float(max_stamina)

func clamp_stamina() -> void:
	current_stamina = clampi(current_stamina, 0, max_stamina)