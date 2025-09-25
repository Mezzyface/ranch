class_name SignalBus
extends Node

# Creature signals (Stage 1 - will be used in later tasks)
# signal creature_created(data: CreatureData)
# signal creature_stats_changed(data: CreatureData, stat: String, old_value: int, new_value: int)
# signal creature_aged(data: CreatureData, new_age: int)
# signal creature_activated(data: CreatureData)
# signal creature_deactivated(data: CreatureData)

# Quest signals (Stage 1 - will be used in later tasks)
# signal quest_started(quest: QuestData)
# signal quest_completed(quest: QuestData)
# signal quest_requirements_met(quest: QuestData, creatures: Array[CreatureData])
# signal quest_failed(quest: QuestData)

# Economy signals (Stage 1 - will be used in later tasks)
# signal gold_changed(old_amount: int, new_amount: int)
# signal item_purchased(item_id: String, quantity: int)
# signal item_consumed(item_id: String, quantity: int)

# Time signals (Stage 1 - will be used in later tasks)
# signal week_advanced(new_week: int)
# signal day_passed(current_week: int, current_day: int)

# System signals (currently used)
signal save_requested()
signal load_requested()
# signal save_completed(success: bool)  # Will use in later tasks
# signal load_completed(success: bool)  # Will use in later tasks

func _ready() -> void:
	print("SignalBus initialized")