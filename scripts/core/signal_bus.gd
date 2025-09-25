class_name SignalBus
extends Node

# Creature signals
signal creature_created(data: CreatureData)
signal creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int)
signal creature_aged(data: CreatureData, new_age: int)
signal creature_activated(data: CreatureData)
signal creature_deactivated(data: CreatureData)

# Quest signals
signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_requirements_met(quest: QuestData, creatures: Array[CreatureData])
signal quest_failed(quest: QuestData)

# Economy signals
signal gold_changed(old_amount: int, new_amount: int)
signal item_purchased(item_id: String, quantity: int)
signal item_consumed(item_id: String, quantity: int)

# Time signals
signal week_advanced(new_week: int)
signal day_passed(current_week: int, current_day: int)

# System signals
signal save_requested()
signal load_requested()
signal save_completed(success: bool)
signal load_completed(success: bool)

func _ready() -> void:
	print("SignalBus initialized")