@tool
extends Control

@onready var label: Label = $Label
@onready var background: NinePatchRect = $Background

var _fade_tween: Tween

func show_notification(text: String, duration: float = 3.0) -> void:
	if label:
		label.text = text

	modulate.a = 0.0
	visible = true

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	await _fade_tween.finished

	await get_tree().create_timer(duration).timeout

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await _fade_tween.finished

	visible = false
	queue_free()

func _ready() -> void:
	visible = false