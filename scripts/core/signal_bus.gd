class_name SignalBus
extends Node

# === CORE SYSTEM SIGNALS ===
# System management signals
signal save_requested()
signal load_requested()
signal save_completed(success: bool)
signal load_completed(success: bool)

# === CREATURE SIGNALS ===
# Core creature lifecycle signals (uncommented for Task 2+)
signal creature_created(data: CreatureData)
signal creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int)
signal creature_modifiers_changed(creature_id: String, stat_name: String)
signal creature_aged(data: CreatureData, new_age: int)
signal creature_activated(data: CreatureData)
signal creature_deactivated(data: CreatureData)

# === QUEST SIGNALS ===
# Quest management signals (will be used in later tasks)
# signal quest_started(quest: QuestData)
# signal quest_completed(quest: QuestData)
# signal quest_requirements_met(quest: QuestData, creatures: Array[CreatureData])
# signal quest_failed(quest: QuestData)

# === ECONOMY SIGNALS ===
# Resource management signals (will be used in later tasks)
# signal gold_changed(old_amount: int, new_amount: int)
# signal item_purchased(item_id: String, quantity: int)
# signal item_consumed(item_id: String, quantity: int)

# === TIME SIGNALS ===
# Time progression signals (will be used in later tasks)
# signal week_advanced(new_week: int)
# signal day_passed(current_week: int, current_day: int)

# === SIGNAL MANAGEMENT ===
# Connection tracking for debugging and cleanup
var _signal_connections: Dictionary = {}
var _debug_mode: bool = true

func _ready() -> void:
	print("SignalBus initialized with enhanced signal management")
	_setup_signal_validation()

# === CONNECTION MANAGEMENT ===
func connect_signal_safe(signal_name: String, target: Callable, flags: int = 0) -> bool:
	"""
	Safely connect a signal with validation and debug logging.
	Returns true if connection successful, false otherwise.
	"""
	if not has_signal(signal_name):
		push_error("SignalBus: Signal '%s' does not exist" % signal_name)
		return false

	var signal_obj: Signal = get(signal_name)
	if signal_obj.is_connected(target):
		if _debug_mode:
			print("SignalBus: Signal '%s' already connected to target" % signal_name)
		return true

	var error: int = signal_obj.connect(target, flags)
	if error != OK:
		push_error("SignalBus: Failed to connect signal '%s' (error: %d)" % [signal_name, error])
		return false

	# Track connection for debugging
	if not _signal_connections.has(signal_name):
		_signal_connections[signal_name] = []
	_signal_connections[signal_name].append(target)

	if _debug_mode:
		print("SignalBus: Connected signal '%s' to %s" % [signal_name, str(target)])

	return true

func disconnect_signal_safe(signal_name: String, target: Callable) -> bool:
	"""
	Safely disconnect a signal with validation and debug logging.
	Returns true if disconnection successful, false otherwise.
	"""
	if not has_signal(signal_name):
		push_error("SignalBus: Signal '%s' does not exist" % signal_name)
		return false

	var signal_obj: Signal = get(signal_name)
	if not signal_obj.is_connected(target):
		if _debug_mode:
			print("SignalBus: Signal '%s' not connected to target" % signal_name)
		return true

	signal_obj.disconnect(target)

	# Remove from tracking
	if _signal_connections.has(signal_name):
		var connections: Array = _signal_connections[signal_name]
		connections.erase(target)
		if connections.is_empty():
			_signal_connections.erase(signal_name)

	if _debug_mode:
		print("SignalBus: Disconnected signal '%s' from %s" % [signal_name, str(target)])

	return true

# === SIGNAL EMISSION PATTERNS ===
func emit_creature_created(data: CreatureData) -> void:
	"""Emit creature_created signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_created with null data")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_created for '%s'" % data.creature_name)

	creature_created.emit(data)

func emit_creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int) -> void:
	"""Emit creature_stats_changed signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_stats_changed with null data")
		return

	if stat.is_empty():
		push_error("SignalBus: Cannot emit creature_stats_changed with empty stat name")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_stats_changed for '%s': %s %d->%d" % [data.creature_name, stat, old_value, new_value])

	creature_stats_changed.emit(data, stat, old_value, new_value)

func emit_creature_modifiers_changed(creature_id: String, stat_name: String) -> void:
	"""Emit creature_modifiers_changed signal with validation."""
	if creature_id.is_empty():
		push_error("SignalBus: Cannot emit creature_modifiers_changed with empty creature_id")
		return
	if stat_name.is_empty():
		push_error("SignalBus: Cannot emit creature_modifiers_changed with empty stat_name")
		return
	if _debug_mode:
		print("SignalBus: Emitting creature_modifiers_changed for creature '%s': %s" % [creature_id, stat_name])
	creature_modifiers_changed.emit(creature_id, stat_name)

func emit_creature_aged(data: CreatureData, new_age: int) -> void:
	"""Emit creature_aged signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_aged with null data")
		return

	if new_age < 0:
		push_error("SignalBus: Cannot emit creature_aged with negative age")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_aged for '%s': age %d" % [data.creature_name, new_age])

	creature_aged.emit(data, new_age)

func emit_creature_activated(data: CreatureData) -> void:
	"""Emit creature_activated signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_activated with null data")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_activated for '%s'" % data.creature_name)

	creature_activated.emit(data)

func emit_creature_deactivated(data: CreatureData) -> void:
	"""Emit creature_deactivated signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_deactivated with null data")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_deactivated for '%s'" % data.creature_name)

	creature_deactivated.emit(data)

# === DEBUG & UTILITY ===
func get_connection_count(signal_name: String) -> int:
	"""Get the number of connections for a signal."""
	if not _signal_connections.has(signal_name):
		return 0
	return _signal_connections[signal_name].size()

func get_all_connections() -> Dictionary:
	"""Get a copy of all tracked connections for debugging."""
	return _signal_connections.duplicate(true)

func set_debug_mode(enabled: bool) -> void:
	"""Enable or disable debug logging for signals."""
	_debug_mode = enabled
	print("SignalBus: Debug mode %s" % ("enabled" if enabled else "disabled"))

func _setup_signal_validation() -> void:
	"""Set up internal signal validation and logging."""
	# Connect to our own signals for validation/logging if needed
	# This allows us to track signal flow for debugging
	pass
