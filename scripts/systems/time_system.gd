class_name TimeSystem extends Node

const WEEKS_PER_MONTH: int = 4
const WEEKS_PER_YEAR: int = 52
const MONTHS_PER_YEAR: int = 13

var current_week: int = 1
var current_month: int = 1
var current_year: int = 1
var total_weeks_elapsed: int = 0

var scheduled_events: Dictionary = {}
var recurring_events: Array[WeeklyEvent] = []

var is_processing_week: bool = false
var week_advance_blocked: bool = false
var block_reasons: Array[String] = []

var last_update_duration_ms: int = 0
var average_update_duration_ms: float = 0.0
var _performance_samples: Array[int] = []

var debug_mode: bool = false
var time_scale: float = 1.0

func _ready() -> void:
	name = "TimeSystem"
	_setup_default_events()
	print("TimeSystem initialized")

func _setup_default_events() -> void:
	var aging_event = WeeklyEvent.new()
	aging_event.event_id = "weekly_aging"
	aging_event.event_type = WeeklyEvent.EventType.CREATURE_AGING
	aging_event.event_name = "Weekly Creature Aging"
	aging_event.is_recurring = true
	aging_event.recurrence_interval = 1
	aging_event.priority = 1
	recurring_events.append(aging_event)

func advance_week() -> bool:
	if is_processing_week:
		push_error("TimeSystem: Already processing week advancement")
		return false

	var can_advance_result = can_advance_time()
	if not can_advance_result.can_advance:
		var signal_bus = GameCore.get_signal_bus()
		if signal_bus:
			signal_bus.time_advance_blocked.emit(can_advance_result.reasons)
		return false

	is_processing_week = true
	var start_time = Time.get_ticks_msec()

	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.weekly_update_started.emit()

	current_week += 1
	total_weeks_elapsed += 1

	if current_week > WEEKS_PER_YEAR:
		current_week = 1
		current_year += 1
		if signal_bus:
			signal_bus.year_completed.emit(current_year - 1)

	current_month = ((current_week - 1) / WEEKS_PER_MONTH) + 1
	if current_week == 1 and total_weeks_elapsed > 0:
		if signal_bus:
			signal_bus.month_completed.emit(MONTHS_PER_YEAR, current_year - 1)

	_process_weekly_events()

	_trigger_system_updates()

	if signal_bus:
		signal_bus.week_advanced.emit(current_week, total_weeks_elapsed)

	var duration = Time.get_ticks_msec() - start_time
	last_update_duration_ms = duration
	_update_average_duration(duration)

	if signal_bus:
		signal_bus.weekly_update_completed.emit(duration)

	if debug_mode:
		print("AI_NOTE: performance(weekly_update) = %d ms (baseline <200ms)" % duration)

	is_processing_week = false
	return true

func advance_weeks(count: int) -> bool:
	if count <= 0:
		push_error("TimeSystem: Cannot advance negative or zero weeks")
		return false

	for i in range(count):
		if not advance_week():
			return false
	return true

func advance_to_week(target_week: int) -> bool:
	if target_week <= total_weeks_elapsed:
		push_error("TimeSystem: Cannot advance to past week %d (current: %d)" % [target_week, total_weeks_elapsed])
		return false

	var weeks_to_advance = target_week - total_weeks_elapsed
	return advance_weeks(weeks_to_advance)

func schedule_event(event: WeeklyEvent, week: int) -> void:
	if event == null:
		push_error("TimeSystem: Cannot schedule null event")
		return

	if not event.is_valid():
		push_error("TimeSystem: Cannot schedule invalid event '%s'" % event.event_name)
		return

	if week <= total_weeks_elapsed:
		push_error("TimeSystem: Cannot schedule event for past week %d" % week)
		return

	if not scheduled_events.has(week):
		scheduled_events[week] = []

	scheduled_events[week].append(event)
	_sort_events_by_priority(scheduled_events[week])

func cancel_event(event_id: String) -> bool:
	for week in scheduled_events.keys():
		var events: Array = scheduled_events[week]
		for i in range(events.size() - 1, -1, -1):
			var event: WeeklyEvent = events[i]
			if event.event_id == event_id:
				events.remove_at(i)
				return true
	return false

func get_current_date_string() -> String:
	return "Year %d, Month %d, Week %d" % [current_year, current_month, current_week]

func get_weeks_until(target_week: int) -> int:
	return target_week - total_weeks_elapsed

func can_advance_time() -> Dictionary:
	block_reasons.clear()

	if is_processing_week:
		block_reasons.append("Already processing week advancement")

	if week_advance_blocked:
		block_reasons.append("Week advancement manually blocked")

	return {
		"can_advance": block_reasons.is_empty(),
		"reasons": block_reasons
	}

func _process_weekly_events() -> void:
	var events_to_process: Array[WeeklyEvent] = []

	if scheduled_events.has(total_weeks_elapsed):
		events_to_process.append_array(scheduled_events[total_weeks_elapsed])
		scheduled_events.erase(total_weeks_elapsed)

	for recurring_event in recurring_events:
		if (total_weeks_elapsed % recurring_event.recurrence_interval) == 0:
			events_to_process.append(recurring_event)

	_sort_events_by_priority(events_to_process)

	for event in events_to_process:
		if event.can_execute():
			event.execute()

func _trigger_system_updates() -> void:
	if GameCore.has_system("age"):
		var age_system = GameCore.get_system("age")
		if age_system.has_method("process_weekly_aging"):
			age_system.process_weekly_aging()

	if GameCore.has_system("stamina"):
		var stamina_system = GameCore.get_system("stamina")
		if stamina_system.has_method("process_weekly_stamina"):
			stamina_system.process_weekly_stamina()

	if GameCore.has_system("food"):
		var food_system = GameCore.get_system("food")
		if food_system.has_method("process_weekly_consumption"):
			food_system.process_weekly_consumption()

	if GameCore.has_system("quest"):
		var quest_system = GameCore.get_system("quest")
		if quest_system.has_method("process_weekly_updates"):
			quest_system.process_weekly_updates()

	if GameCore.has_system("save"):
		var save_system = GameCore.get_system("save")
		if save_system.has_method("trigger_auto_save"):
			save_system.trigger_auto_save()

func _sort_events_by_priority(events: Array) -> void:
	events.sort_custom(func(a: WeeklyEvent, b: WeeklyEvent): return a.priority < b.priority)

func _update_average_duration(duration: int) -> void:
	_performance_samples.append(duration)
	if _performance_samples.size() > 10:
		_performance_samples.remove_at(0)

	var total = 0
	for sample in _performance_samples:
		total += sample
	average_update_duration_ms = float(total) / float(_performance_samples.size())

func save_time_state() -> Dictionary:
	return {
		"current_week": current_week,
		"current_month": current_month,
		"current_year": current_year,
		"total_weeks": total_weeks_elapsed,
		"scheduled_events": _serialize_events(scheduled_events),
		"settings": {
			"debug_mode": debug_mode,
			"time_scale": time_scale
		}
	}

func load_time_state(data: Dictionary) -> void:
	if not data.has("current_week") or not data.has("total_weeks"):
		push_error("TimeSystem: Missing required time state data")
		return

	current_week = data.get("current_week", 1)
	current_month = data.get("current_month", 1)
	current_year = data.get("current_year", 1)
	total_weeks_elapsed = data.get("total_weeks", 0)

	if data.has("scheduled_events"):
		scheduled_events = _deserialize_events(data.scheduled_events)

	if data.has("settings"):
		var settings = data.settings
		debug_mode = settings.get("debug_mode", false)
		time_scale = settings.get("time_scale", 1.0)

func _serialize_events(events_dict: Dictionary) -> Dictionary:
	var result = {}
	for week in events_dict.keys():
		var events: Array = events_dict[week]
		var serialized_events = []
		for event in events:
			if event is WeeklyEvent:
				serialized_events.append({
					"event_id": event.event_id,
					"event_type": event.event_type,
					"event_name": event.event_name,
					"trigger_week": event.trigger_week,
					"is_recurring": event.is_recurring,
					"recurrence_interval": event.recurrence_interval,
					"event_data": event.event_data,
					"priority": event.priority
				})
		result[week] = serialized_events
	return result

func _deserialize_events(events_data: Dictionary) -> Dictionary:
	var result = {}
	for week in events_data.keys():
		var events_array = []
		var serialized_events = events_data[week]
		for event_data in serialized_events:
			var event = WeeklyEvent.new()
			event.event_id = event_data.get("event_id", "")
			event.event_type = event_data.get("event_type", WeeklyEvent.EventType.CUSTOM)
			event.event_name = event_data.get("event_name", "")
			event.trigger_week = event_data.get("trigger_week", -1)
			event.is_recurring = event_data.get("is_recurring", false)
			event.recurrence_interval = event_data.get("recurrence_interval", 1)
			event.event_data = event_data.get("event_data", {})
			event.priority = event_data.get("priority", 0)
			events_array.append(event)
		result[int(week)] = events_array
	return result

func debug_advance_weeks(count: int) -> void:
	if not debug_mode:
		push_error("TimeSystem: Debug commands only available in debug mode")
		return
	advance_weeks(count)

func debug_set_week(week: int) -> void:
	if not debug_mode:
		push_error("TimeSystem: Debug commands only available in debug mode")
		return
	if week < 1:
		push_error("TimeSystem: Invalid week number")
		return

	current_week = week
	total_weeks_elapsed = week - 1
	current_month = ((current_week - 1) / WEEKS_PER_MONTH) + 1
	current_year = 1 + (total_weeks_elapsed / WEEKS_PER_YEAR)

func debug_trigger_event(event_type: WeeklyEvent.EventType) -> void:
	if not debug_mode:
		push_error("TimeSystem: Debug commands only available in debug mode")
		return

	var event = WeeklyEvent.new()
	event.event_id = "debug_event_%d" % Time.get_ticks_msec()
	event.event_type = event_type
	event.event_name = "Debug Event"
	event.trigger_week = total_weeks_elapsed

	if event.can_execute():
		event.execute()

func debug_print_schedule() -> void:
	if not debug_mode:
		push_error("TimeSystem: Debug commands only available in debug mode")
		return

	print("TimeSystem Schedule:")
	print("Current: %s (Total weeks: %d)" % [get_current_date_string(), total_weeks_elapsed])
	print("Scheduled Events:")
	for week in scheduled_events.keys():
		var events: Array = scheduled_events[week]
		print("  Week %d: %d events" % [week, events.size()])
		for event in events:
			print("    - %s (Priority: %d)" % [event.event_name, event.priority])

func debug_measure_performance() -> void:
	if not debug_mode:
		push_error("TimeSystem: Debug commands only available in debug mode")
		return

	print("TimeSystem Performance:")
	print("  Last update: %d ms" % last_update_duration_ms)
	print("  Average: %.1f ms" % average_update_duration_ms)
	print("  Samples: %d" % _performance_samples.size())

func set_debug_mode(enabled: bool) -> void:
	debug_mode = enabled
	if enabled:
		print("TimeSystem: Debug mode enabled")
	else:
		print("TimeSystem: Debug mode disabled")