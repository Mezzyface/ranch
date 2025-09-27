extends Node

var test_name: String = "TimeSystem Tests"
var tests_passed: int = 0
var tests_total: int = 0

func _ready() -> void:
	print("=== %s ===" % test_name)
	run_all_tests()
	print("=== %s Complete: %d/%d tests passed ===" % [test_name, tests_passed, tests_total])
	get_tree().quit()

func run_all_tests() -> void:
	test_time_system_initialization()
	test_week_advancement()
	test_month_year_transitions()
	test_event_scheduling()
	test_save_load_integration()
	test_performance_tracking()
	test_weekly_event_execution()
	test_debug_commands()

func test_time_system_initialization() -> void:
	print("\n--- Testing TimeSystem Initialization ---")
	var time_system = GameCore.get_system("time")

	run_test("TimeSystem loads", time_system != null)
	run_test("Initial week is 1", time_system.current_week == 1)
	run_test("Initial month is 1", time_system.current_month == 1)
	run_test("Initial year is 1", time_system.current_year == 1)
	run_test("Total weeks elapsed is 0", time_system.total_weeks_elapsed == 0)
	run_test("Not processing week", not time_system.is_processing_week)
	run_test("Has default recurring events", time_system.recurring_events.size() > 0)

func test_week_advancement() -> void:
	print("\n--- Testing Week Advancement ---")
	var time_system = GameCore.get_system("time")

	var initial_week = time_system.current_week
	var result = time_system.advance_week()

	run_test("Week advancement succeeds", result == true)
	run_test("Week incremented", time_system.current_week == initial_week + 1)
	run_test("Total weeks incremented", time_system.total_weeks_elapsed == 1)
	run_test("Performance measured", time_system.last_update_duration_ms >= 0)

func test_month_year_transitions() -> void:
	print("\n--- Testing Month/Year Transitions ---")
	var time_system = GameCore.get_system("time")

	time_system.current_week = 1
	time_system.current_month = 1
	time_system.current_year = 1
	time_system.total_weeks_elapsed = 0

	time_system.advance_weeks(4)
	run_test("Month transition (week 5)", time_system.current_month == 2)

	time_system.current_week = 1
	time_system.current_year = 1
	time_system.total_weeks_elapsed = 0
	time_system.advance_weeks(52)
	run_test("Year transition (week 52+1->1)", time_system.current_week == 1)
	run_test("Year incremented", time_system.current_year == 2)

func test_event_scheduling() -> void:
	print("\n--- Testing Event Scheduling ---")
	var time_system = GameCore.get_system("time")

	var event = WeeklyEvent.new()
	event.event_id = "test_event"
	event.event_name = "Test Event"
	event.event_type = WeeklyEvent.EventType.CUSTOM
	event.trigger_week = time_system.total_weeks_elapsed + 5

	var initial_events = time_system.scheduled_events.size()
	time_system.schedule_event(event, event.trigger_week)

	run_test("Event scheduled", time_system.scheduled_events.size() >= initial_events)
	run_test("Event at correct week", time_system.scheduled_events.has(event.trigger_week))

	var cancelled = time_system.cancel_event("test_event")
	run_test("Event cancelled", cancelled == true)

func test_save_load_integration() -> void:
	print("\n--- Testing Save/Load Integration ---")
	var time_system = GameCore.get_system("time")

	time_system.advance_weeks(10)
	var original_week = time_system.current_week
	var original_total = time_system.total_weeks_elapsed

	var save_data = time_system.save_time_state()
	run_test("Save state created", save_data.has("current_week"))
	run_test("Save contains total weeks", save_data.has("total_weeks"))

	time_system.current_week = 1
	time_system.total_weeks_elapsed = 0

	time_system.load_time_state(save_data)
	run_test("Week restored", time_system.current_week == original_week)
	run_test("Total weeks restored", time_system.total_weeks_elapsed == original_total)

func test_performance_tracking() -> void:
	print("\n--- Testing Performance Tracking ---")
	var time_system = GameCore.get_system("time")

	var start_time = Time.get_ticks_msec()
	time_system.advance_week()
	var duration = time_system.last_update_duration_ms

	run_test("Performance tracked", duration >= 0)
	run_test("Performance within baseline", duration < 200)
	run_test("Average calculated", time_system.average_update_duration_ms >= 0.0)

func test_weekly_event_execution() -> void:
	print("\n--- Testing Weekly Event Execution ---")
	var time_system = GameCore.get_system("time")

	var aging_event = null
	for event in time_system.recurring_events:
		if event.event_type == WeeklyEvent.EventType.CREATURE_AGING:
			aging_event = event
			break

	run_test("Aging event exists", aging_event != null)
	if aging_event:
		run_test("Aging event is valid", aging_event.is_valid())
		run_test("Aging event can execute", aging_event.can_execute())

func test_debug_commands() -> void:
	print("\n--- Testing Debug Commands ---")
	var time_system = GameCore.get_system("time")

	time_system.set_debug_mode(true)
	run_test("Debug mode enabled", time_system.debug_mode == true)

	var original_week = time_system.current_week
	time_system.debug_set_week(10)
	run_test("Debug set week works", time_system.current_week == 10)

	time_system.debug_advance_weeks(5)
	run_test("Debug advance weeks works", time_system.current_week == 15)

	time_system.set_debug_mode(false)
	run_test("Debug mode disabled", time_system.debug_mode == false)

func run_test(description: String, condition: bool) -> void:
	tests_total += 1
	if condition:
		tests_passed += 1
		print("  ✅ %s" % description)
	else:
		print("  ❌ %s" % description)