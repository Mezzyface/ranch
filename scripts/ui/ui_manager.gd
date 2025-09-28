@tool
class_name UIManager extends Node

# Signals moved to SignalBus for centralized management
# Use _signal_bus.emit_*() methods instead

var scene_stack: Array[String] = []
var windows: Dictionary = {}
var _signal_bus: SignalBus

func _ready() -> void:
	name = "UIManager"
	_signal_bus = GameCore.get_signal_bus()

func change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("UIManager: Scene path cannot be empty")
		return

	# Handle game scene mapping - use overlay_menu as the main game interface
	var target_scene = scene_path
	if scene_path == "res://scenes/ui/game_ui.tscn" or scene_path == "res://scenes/ui/facility_view.tscn":
		target_scene = "res://scenes/ui/overlay_menu.tscn"

	# Just emit the signal and let MainController handle the actual scene change
	scene_stack.clear()
	scene_stack.push_back(target_scene)
	_signal_bus.emit_scene_changed(target_scene)

func push_scene(scene_path: String) -> void:
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
		#window.show()
		_signal_bus.emit_window_opened(window_name)

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
		_signal_bus.emit_window_closed(window_name)

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
