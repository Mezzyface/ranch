@tool
class_name UIManager extends Node

signal scene_changed(new_scene: String)
signal window_opened(window_name: String)
signal window_closed(window_name: String)
signal transition_started()
signal transition_completed()

var current_scene: Control = null
var scene_stack: Array[String] = []
var windows: Dictionary = {}
var is_transitioning: bool = false

var _scene_cache: Dictionary = {}
var _transition_duration: float = 0.3
var _signal_bus: SignalBus

func _ready() -> void:
	name = "UIManager"
	_signal_bus = GameCore.get_signal_bus()

func change_scene(scene_path: String) -> void:
	if is_transitioning:
		push_error("UIManager: Cannot change scene while transitioning")
		return

	if scene_path.is_empty():
		push_error("UIManager: Scene path cannot be empty")
		return

	_start_transition()

	if current_scene:
		_fade_out_scene(current_scene)

	var new_scene = _load_scene(scene_path)
	if new_scene:
		current_scene = new_scene
		scene_stack.clear()
		scene_stack.push_back(scene_path)
		_fade_in_scene(new_scene)
		scene_changed.emit(scene_path)

	_end_transition()

func push_scene(scene_path: String) -> void:
	if is_transitioning:
		push_error("UIManager: Cannot push scene while transitioning")
		return

	if scene_path.is_empty():
		push_error("UIManager: Scene path cannot be empty")
		return

	scene_stack.push_back(scene_path)
	change_scene(scene_path)

func pop_scene() -> void:
	if scene_stack.size() <= 1:
		push_error("UIManager: Cannot pop from empty scene stack")
		return

	scene_stack.pop_back()
	var previous_scene = scene_stack.back()
	change_scene(previous_scene)

func show_window(window_name: String) -> void:
	if window_name.is_empty():
		push_error("UIManager: Window name cannot be empty")
		return

	if not windows.has(window_name):
		push_error("UIManager: Window '%s' not registered" % window_name)
		return

	var window = windows[window_name] as Window
	if window and not window.visible:
		window.show()
		window_opened.emit(window_name)

func hide_window(window_name: String) -> void:
	if window_name.is_empty():
		push_error("UIManager: Window name cannot be empty")
		return

	if not windows.has(window_name):
		push_error("UIManager: Window '%s' not registered" % window_name)
		return

	var window = windows[window_name] as Window
	if window and window.visible:
		window.hide()
		window_closed.emit(window_name)

func register_window(window_name: String, window: Window) -> void:
	if window_name.is_empty():
		push_error("UIManager: Window name cannot be empty")
		return

	if not window:
		push_error("UIManager: Window instance cannot be null")
		return

	windows[window_name] = window

func unregister_window(window_name: String) -> void:
	if windows.has(window_name):
		windows.erase(window_name)

func show_notification(text: String, duration: float = 3.0) -> void:
	if text.is_empty():
		push_error("UIManager: Notification text cannot be empty")
		return

	print("UI_NOTIFICATION: %s (duration: %.1fs)" % [text, duration])

func show_confirm_dialog(text: String, callback: Callable) -> void:
	if text.is_empty():
		push_error("UIManager: Dialog text cannot be empty")
		return

	if not callback.is_valid():
		push_error("UIManager: Callback must be valid")
		return

	print("UI_CONFIRM_DIALOG: %s" % text)

func get_current_scene_path() -> String:
	if scene_stack.is_empty():
		return ""
	return scene_stack.back()

func is_window_open(window_name: String) -> bool:
	if not windows.has(window_name):
		return false

	var window = windows[window_name] as Window
	return window and window.visible

func _load_scene(scene_path: String) -> Control:
	if _scene_cache.has(scene_path):
		return _scene_cache[scene_path]

	var scene = load(scene_path)
	if not scene:
		push_error("UIManager: Failed to load scene '%s'" % scene_path)
		return null

	var instance = scene.instantiate()
	if not instance is Control:
		push_error("UIManager: Scene '%s' must be a Control node" % scene_path)
		instance.queue_free()
		return null

	_scene_cache[scene_path] = instance
	return instance

func _start_transition() -> void:
	is_transitioning = true
	transition_started.emit()

func _end_transition() -> void:
	is_transitioning = false
	transition_completed.emit()

func _fade_out_scene(scene: Control) -> void:
	if not scene:
		return

	var tween = create_tween()
	tween.tween_property(scene, "modulate:a", 0.0, _transition_duration / 2.0)
	await tween.finished

	if scene.get_parent():
		scene.get_parent().remove_child(scene)

func _fade_in_scene(scene: Control) -> void:
	if not scene:
		return

	scene.modulate.a = 0.0
	get_tree().current_scene.add_child(scene)

	var tween = create_tween()
	tween.tween_property(scene, "modulate:a", 1.0, _transition_duration / 2.0)
	await tween.finished

func clear_scene_cache() -> void:
	for scene in _scene_cache.values():
		if scene and is_instance_valid(scene):
			scene.queue_free()
	_scene_cache.clear()

func set_transition_duration(duration: float) -> void:
	if duration < 0.0:
		push_error("UIManager: Transition duration must be non-negative")
		return
	_transition_duration = duration
