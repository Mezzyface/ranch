@tool
class_name WeeklyEvent extends Resource

enum EventType {
	CREATURE_AGING,
	STAMINA_DEPLETION,
	FOOD_CONSUMPTION,
	QUEST_DEADLINE,
	COMPETITION_START,
	SHOP_REFRESH,
	CUSTOM
}

@export var event_id: String = ""
@export var event_type: EventType = EventType.CUSTOM
@export var event_name: String = ""
@export var trigger_week: int = -1
@export var is_recurring: bool = false
@export var recurrence_interval: int = 1
@export var event_data: Dictionary = {}
@export var priority: int = 0

func is_valid() -> bool:
	if event_id.is_empty() or event_name.is_empty():
		return false
	if trigger_week < 0 and not is_recurring:
		return false
	if is_recurring and recurrence_interval <= 0:
		return false
	return true

func execute() -> void:
	if not can_execute():
		push_error("WeeklyEvent.execute: Cannot execute event '%s' - validation failed" % event_name)
		return

	var signal_bus = GameCore.get_signal_bus()
	if signal_bus:
		signal_bus.weekly_event_triggered.emit(self)

	match event_type:
		EventType.CREATURE_AGING:
			_execute_aging_event()
		EventType.STAMINA_DEPLETION:
			_execute_stamina_event()
		EventType.FOOD_CONSUMPTION:
			_execute_food_event()
		EventType.QUEST_DEADLINE:
			_execute_quest_event()
		EventType.COMPETITION_START:
			_execute_competition_event()
		EventType.SHOP_REFRESH:
			_execute_shop_event()
		EventType.CUSTOM:
			_execute_custom_event()

func can_execute() -> bool:
	if not is_valid():
		return false

	if GameCore == null:
		return false

	var signal_bus = GameCore.get_signal_bus()
	return signal_bus != null

func _execute_aging_event() -> void:
	if GameCore.has_system("age") and GameCore.has_system("collection"):
		var age_system = GameCore.get_system("age")
		var collection_system = GameCore.get_system("collection")

		var active_creatures = collection_system.get_active_creatures()
		if not active_creatures.is_empty():
			age_system.age_all_creatures(active_creatures, 1)

func _execute_stamina_event() -> void:
	if GameCore.has_system("stamina"):
		var stamina_system = GameCore.get_system("stamina")
		stamina_system.process_weekly_stamina()

func _execute_food_event() -> void:
	if GameCore.has_system("food"):
		var food_system = GameCore.get_system("food")
		food_system.process_weekly_consumption()

func _execute_quest_event() -> void:
	if GameCore.has_system("quest"):
		var quest_system = GameCore.get_system("quest")
		quest_system.process_weekly_updates()

func _execute_competition_event() -> void:
	pass

func _execute_shop_event() -> void:
	pass

func _execute_custom_event() -> void:
	pass