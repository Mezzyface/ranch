class_name WeeklyUpdateOrchestrator extends Node

enum UpdatePhase {
	PRE_UPDATE,
	AGING,
	STAMINA,
	FOOD,
	QUESTS,
	COMPETITIONS,
	ECONOMY,
	POST_UPDATE,
	SAVE
}

var update_pipeline: Array[UpdatePhase] = []
var phase_handlers: Dictionary = {}
var update_results: Dictionary = {}
var rollback_data: Dictionary = {}
var is_updating: bool = false

func _ready() -> void:
	_initialize_pipeline()

func _initialize_pipeline() -> void:
	update_pipeline = [
		UpdatePhase.PRE_UPDATE,
		UpdatePhase.AGING,
		UpdatePhase.STAMINA,
		UpdatePhase.FOOD,
		UpdatePhase.QUESTS,
		UpdatePhase.COMPETITIONS,
		UpdatePhase.ECONOMY,
		UpdatePhase.POST_UPDATE,
		UpdatePhase.SAVE
	]

	phase_handlers = {
		UpdatePhase.PRE_UPDATE: _handle_pre_update,
		UpdatePhase.AGING: _handle_aging,
		UpdatePhase.STAMINA: _handle_stamina,
		UpdatePhase.FOOD: _handle_food,
		UpdatePhase.QUESTS: _handle_quests,
		UpdatePhase.COMPETITIONS: _handle_competitions,
		UpdatePhase.ECONOMY: _handle_economy,
		UpdatePhase.POST_UPDATE: _handle_post_update,
		UpdatePhase.SAVE: _handle_save
	}

func execute_weekly_update() -> Dictionary:
	if is_updating:
		push_error("Weekly update already in progress")
		return {"success": false, "error": "Update already in progress"}

	is_updating = true
	update_results.clear()

	var _t0: int = Time.get_ticks_msec()

	_prepare_update()

	for phase in update_pipeline:
		if not _execute_phase(phase):
			_rollback_update()
			is_updating = false
			return {"success": false, "failed_phase": UpdatePhase.keys()[phase]}

	var summary = _generate_summary()
	_finalize_update()

	var _dt: int = Time.get_ticks_msec() - _t0
	print("AI_NOTE: performance(weekly_update) = %d ms (baseline <200ms)" % _dt)

	is_updating = false
	return {"success": true, "summary": summary, "time_ms": _dt}

func _execute_phase(phase: UpdatePhase) -> bool:
	if not phase_handlers.has(phase):
		push_error("No handler for phase: %s" % UpdatePhase.keys()[phase])
		return false

	var handler: Callable = phase_handlers[phase]
	return handler.call()

func _prepare_update() -> void:
	rollback_data = {
		"creatures": _snapshot_creatures(),
		"resources": _snapshot_resources(),
		"time": _snapshot_time()
	}

func _handle_pre_update() -> bool:
	var collection = GameCore.get_system("collection")
	if not collection:
		push_error("Collection system not available")
		return false

	var active_creatures = collection.get_active_creatures()
	var stable_creatures = collection.get_stable_creatures()
	var all_creatures = active_creatures + stable_creatures

	update_results["pre_update"] = {
		"creature_count": all_creatures.size(),
		"active_count": active_creatures.size(),
		"stable_count": stable_creatures.size()
	}

	return true

func _handle_aging() -> bool:
	if not GameCore.has_system("age"):
		return true

	var age_system = GameCore.get_system("age")
	var collection = GameCore.get_system("collection")

	var aged_count = 0
	var category_changes: Array[Dictionary] = []
	var expired: Array[String] = []

	# Only age active creatures - stable creatures remain in stasis
	var active_creatures = collection.get_active_creatures()
	for creature in active_creatures:
		var old_category = creature.get_age_category()
		creature.age_weeks += 1

		if creature.age_weeks >= creature.lifespan_weeks:
			expired.append(creature.creature_name)
			continue

		aged_count += 1
		var new_category = creature.get_age_category()
		if old_category != new_category:
			category_changes.append({
				"creature": creature.creature_name,
				"from": GlobalEnums.AgeCategory.keys()[old_category],
				"to": GlobalEnums.AgeCategory.keys()[new_category]
			})

	update_results["aging"] = {
		"aged_creatures": aged_count,
		"category_changes": category_changes,
		"expired_creatures": expired
	}

	return true

func _handle_stamina() -> bool:
	if not GameCore.has_system("stamina"):
		return true

	var stamina_system = GameCore.get_system("stamina")

	# Process assigned activities for the week
	var activity_results = stamina_system.process_weekly_activities()

	# Organize results for summary
	var depleted = []
	var recovered = []

	for activity_record in activity_results.get("activities_performed", []):
		if activity_record.has("failed"):
			continue

		var stamina_change = activity_record.get("stamina_change", 0)
		if stamina_change < 0:
			depleted.append({
				"creature": activity_record.creature,
				"amount": abs(stamina_change),
				"activity": activity_record.activity
			})
		elif stamina_change > 0:
			recovered.append({
				"creature": activity_record.creature,
				"amount": stamina_change,
				"activity": activity_record.activity
			})

	update_results["stamina"] = {
		"depleted": depleted,
		"recovered": recovered,
		"activities": activity_results.get("activities_performed", [])
	}

	return true

func _handle_food() -> bool:
	if not GameCore.has_system("resource") or not GameCore.has_system("stamina"):
		return true

	var resource_system = GameCore.get_system("resource")
	var stamina_system = GameCore.get_system("stamina")
	var collection = GameCore.get_system("collection")

	# Food consumption is now handled by activity system
	# Only active creatures performing activities consume food
	# Food is consumed from inventory based on assigned activities
	var active_creatures = collection.get_active_creatures()
	var food_items_consumed = []
	var total_food_value = 0

	for creature in active_creatures:
		var activity = stamina_system.get_assigned_activity(creature)
		# Only creatures performing activities need food
		if activity != stamina_system.Activity.IDLE:
			# Food consumption will be handled by activity system
			# This is just tracking for the summary
			total_food_value += 1  # 1 food item per active creature doing activities

	update_results["food"] = {
		"items_consumed": food_items_consumed,
		"active_creatures_fed": active_creatures.size(),
		"total_food_value": total_food_value
	}

	return true

func _handle_quests() -> bool:
	update_results["quests"] = {
		"completions": [],
		"progress": []
	}
	return true

func _handle_competitions() -> bool:
	update_results["competitions"] = {
		"results": [],
		"rewards": []
	}
	return true

func _handle_economy() -> bool:
	if not GameCore.has_system("resource"):
		return true

	var resource_system = GameCore.get_system("resource")

	# No automatic costs - player manages resources directly
	# Economy phase reserved for future features (market fluctuations, etc.)
	update_results["economy"] = {
		"spent": 0,
		"earned": 0,
		"balance": resource_system.get_balance()
	}

	return true

func _handle_post_update() -> bool:
	for creature_name in update_results.get("aging", {}).get("expired_creatures", []):
		var collection = GameCore.get_system("collection")
		var all_creatures = collection.get_active_creatures() + collection.get_stable_creatures()
		for creature in all_creatures:
			if creature.creature_name == creature_name:
				if collection.has_method("remove_from_active"):
					collection.remove_from_active(creature.id)
				elif collection.has_method("remove_from_stable"):
					collection.remove_from_stable(creature.id)
				break

	return true

func _handle_save() -> bool:
	if not GameCore.has_system("save"):
		return true

	var save_system = GameCore.get_system("save")
	save_system.save_game_state("autosave_week")
	return true

func _generate_summary() -> WeeklySummary:
	var summary = WeeklySummary.new()

	if GameCore.has_system("time"):
		summary.week = GameCore.get_system("time").current_week

	if update_results.has("aging"):
		summary.creatures_aged = update_results.aging.get("aged_creatures", 0)
		var changes: Array[Dictionary] = []
		changes.assign(update_results.aging.get("category_changes", []))
		summary.category_changes = changes
		var expired_list: Array[String] = []
		expired_list.assign(update_results.aging.get("expired_creatures", []))
		summary.creatures_expired = expired_list

	if update_results.has("stamina"):
		summary.stamina_changes = update_results.stamina

	if update_results.has("food"):
		summary.food_consumed = update_results.food.get("consumed", 0)
		summary.food_remaining = update_results.food.get("remaining", 0)

	if update_results.has("economy"):
		summary.gold_spent = update_results.economy.get("spent", 0)
		summary.gold_earned = update_results.economy.get("earned", 0)

	if update_results.has("quests"):
		var completions: Array[String] = []
		completions.assign(update_results.quests.get("completions", []))
		summary.quest_completions = completions

	if update_results.has("competitions"):
		var results: Array[Dictionary] = []
		results.assign(update_results.competitions.get("results", []))
		summary.competition_results = results

	return summary

func _finalize_update() -> void:
	var bus = GameCore.get_signal_bus()
	if bus:
		var summary = _generate_summary()
		bus.week_advanced.emit(summary.week, summary.week)

	rollback_data.clear()

func _rollback_update() -> void:
	push_warning("Rolling back weekly update due to error")

	if rollback_data.has("creatures"):
		_restore_creatures(rollback_data.creatures)

	if rollback_data.has("resources"):
		_restore_resources(rollback_data.resources)

	if rollback_data.has("time"):
		_restore_time(rollback_data.time)

	var bus = GameCore.get_signal_bus()
	if bus and bus.has_signal("weekly_update_failed"):
		bus.weekly_update_failed.emit()

func _snapshot_creatures() -> Dictionary:
	var snapshot = {}
	var collection = GameCore.get_system("collection")
	if collection:
		var all_creatures = collection.get_active_creatures() + collection.get_stable_creatures()
		for creature in all_creatures:
			snapshot[creature.id] = creature.to_dict()
	return snapshot

func _snapshot_resources() -> Dictionary:
	var snapshot = {}
	var resource_system = GameCore.get_system("resource")
	if resource_system:
		snapshot["gold"] = resource_system.get_balance()
		snapshot["inventory"] = resource_system.get_inventory().duplicate()
	return snapshot

func _snapshot_time() -> Dictionary:
	var snapshot = {}
	var time_system = GameCore.get_system("time")
	if time_system:
		snapshot["week"] = time_system.current_week
		snapshot["total_weeks"] = time_system.total_weeks_elapsed
	return snapshot

func _restore_creatures(snapshot: Dictionary) -> void:
	var collection = GameCore.get_system("collection")
	if not collection:
		return

	for creature_id in snapshot:
		var all_creatures = collection.get_active_creatures() + collection.get_stable_creatures()
		for creature in all_creatures:
			if creature.id == creature_id:
				creature.from_dict(snapshot[creature_id])
				break

func _restore_resources(snapshot: Dictionary) -> void:
	var resource_system = GameCore.get_system("resource")
	if not resource_system:
		return

	if snapshot.has("gold"):
		var current_gold = resource_system.get_balance()
		var diff = snapshot.gold - current_gold
		if diff > 0:
			resource_system.add_gold(diff, "rollback")
		elif diff < 0:
			resource_system.spend_gold(abs(diff), "rollback")

func _restore_time(snapshot: Dictionary) -> void:
	var time_system = GameCore.get_system("time")
	if time_system and snapshot.has("week"):
		time_system.current_week = snapshot.week
		if snapshot.has("total_weeks"):
			time_system.total_weeks_elapsed = snapshot.total_weeks
