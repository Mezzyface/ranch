@tool
class_name SceneTransition extends CanvasLayer

enum TransitionType {
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	ZOOM_IN,
	ZOOM_OUT
}

signal transition_started()
signal transition_halfway()
signal transition_completed()

@export var transition_type: TransitionType = TransitionType.FADE
@export var transition_duration: float = 0.3
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_CUBIC

var _overlay: ColorRect
var _is_transitioning: bool = false
var _current_tween: Tween

func _ready() -> void:
	layer = 100
	_create_overlay()

func _create_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	add_child(_overlay)

func transition_to_scene(target_scene_path: String, callback: Callable = Callable()) -> void:
	if _is_transitioning:
		push_error("SceneTransition: Already transitioning")
		return

	if target_scene_path.is_empty():
		push_error("SceneTransition: Target scene path cannot be empty")
		return

	_is_transitioning = true
	transition_started.emit()

	match transition_type:
		TransitionType.FADE:
			await _fade_transition(target_scene_path, callback)
		TransitionType.SLIDE_LEFT:
			await _slide_transition(target_scene_path, Vector2(-get_viewport().size.x, 0), callback)
		TransitionType.SLIDE_RIGHT:
			await _slide_transition(target_scene_path, Vector2(get_viewport().size.x, 0), callback)
		TransitionType.SLIDE_UP:
			await _slide_transition(target_scene_path, Vector2(0, -get_viewport().size.y), callback)
		TransitionType.SLIDE_DOWN:
			await _slide_transition(target_scene_path, Vector2(0, get_viewport().size.y), callback)
		TransitionType.ZOOM_IN:
			await _zoom_transition(target_scene_path, 0.0, 1.0, callback)
		TransitionType.ZOOM_OUT:
			await _zoom_transition(target_scene_path, 2.0, 1.0, callback)

	_is_transitioning = false
	transition_completed.emit()

func _fade_transition(target_scene_path: String, callback: Callable) -> void:
	_current_tween = create_tween()
	_current_tween.set_ease(ease_type)
	_current_tween.set_trans(trans_type)
	_current_tween.tween_property(_overlay, "modulate:a", 1.0, transition_duration / 2.0)
	await _current_tween.finished

	transition_halfway.emit()

	if callback.is_valid():
		callback.call()
	elif not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)

	_current_tween = create_tween()
	_current_tween.set_ease(ease_type)
	_current_tween.set_trans(trans_type)
	_current_tween.tween_property(_overlay, "modulate:a", 0.0, transition_duration / 2.0)
	await _current_tween.finished

func _slide_transition(target_scene_path: String, offset: Vector2, callback: Callable) -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	var initial_position = current_scene.position

	_current_tween = create_tween()
	_current_tween.set_ease(ease_type)
	_current_tween.set_trans(trans_type)
	_current_tween.tween_property(current_scene, "position", initial_position + offset, transition_duration / 2.0)
	await _current_tween.finished

	transition_halfway.emit()

	if callback.is_valid():
		callback.call()
	elif not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)

	await get_tree().process_frame

	var new_scene = get_tree().current_scene
	if new_scene:
		new_scene.position = initial_position - offset
		_current_tween = create_tween()
		_current_tween.set_ease(ease_type)
		_current_tween.set_trans(trans_type)
		_current_tween.tween_property(new_scene, "position", initial_position, transition_duration / 2.0)
		await _current_tween.finished

func _zoom_transition(target_scene_path: String, start_scale: float, end_scale: float, callback: Callable) -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	_current_tween = create_tween()
	_current_tween.set_ease(ease_type)
	_current_tween.set_trans(trans_type)
	_current_tween.tween_property(current_scene, "scale", Vector2(start_scale, start_scale), transition_duration / 2.0)
	await _current_tween.finished

	transition_halfway.emit()

	if callback.is_valid():
		callback.call()
	elif not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)

	await get_tree().process_frame

	var new_scene = get_tree().current_scene
	if new_scene:
		new_scene.scale = Vector2(start_scale, start_scale)
		_current_tween = create_tween()
		_current_tween.set_ease(ease_type)
		_current_tween.set_trans(trans_type)
		_current_tween.tween_property(new_scene, "scale", Vector2(end_scale, end_scale), transition_duration / 2.0)
		await _current_tween.finished


func instant_transition_to_scene(target_scene_path: String) -> void:
	if target_scene_path.is_empty():
		push_error("SceneTransition: Target scene path cannot be empty")
		return

	get_tree().change_scene_to_file(target_scene_path)

func set_overlay_color(color: Color) -> void:
	if _overlay:
		_overlay.color = color

func get_overlay_color() -> Color:
	if _overlay:
		return _overlay.color
	return Color.BLACK

func is_transitioning() -> bool:
	return _is_transitioning

func stop_transition() -> void:
	if _current_tween:
		_current_tween.kill()
		_current_tween = null

	_is_transitioning = false
	_overlay.modulate.a = 0.0