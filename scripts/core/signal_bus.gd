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

# Age-related signals (Task 6)
signal creature_category_changed(data: CreatureData, old_category: int, new_category: int)
signal creature_expired(data: CreatureData)
signal aging_batch_completed(creatures_aged: int, total_weeks: int)

# Tag-related signals (Task 4)
signal creature_tag_added(data: CreatureData, tag: String)
signal creature_tag_removed(data: CreatureData, tag: String)
signal tag_add_failed(data: CreatureData, tag: String, reason: String)
signal tag_validation_failed(tags: Array[String], errors: Array[String])

# === QUEST SIGNALS ===
# Quest management signals (will be used in later tasks)
# signal quest_started(quest: QuestData)
# signal quest_completed(quest: QuestData)
# signal quest_requirements_met(quest: QuestData, creatures: Array[CreatureData])
# signal quest_failed(quest: QuestData)

# === ECONOMY SIGNALS ===
# Resource management signals (will be used in later tasks)
# signal gold_changed(old_amount: int, new_amount: int)
signal item_purchased(item_id: String, quantity: int, vendor_id: String, cost: int)
# signal item_consumed(item_id: String, quantity: int)

# === SHOP SIGNALS ===
# Shop system signals (Stage 3)
signal shop_refreshed(weeks_passed: int)
signal vendor_unlocked(vendor_id: String)
signal gold_spent(amount: int, reason: String)

# === SPECIES SIGNALS (Task 10) ===
signal species_loaded(species_id: String)
signal species_registered(species_id: String, category: String)
signal species_validation_failed(species_id: String, errors: Array[String])

# === COLLECTION SIGNALS (Task 8) ===
# Creature collection events
signal creature_acquired(creature_data: CreatureData, source: String)
signal creature_released(creature_data: CreatureData, reason: String)
signal creature_cleanup_required(creature_id: String)  # For memory cleanup across systems
signal active_roster_changed(new_roster: Array[CreatureData])
signal stable_collection_updated(operation: String, creature_id: String)

# Collection milestones
signal collection_milestone_reached(milestone: String, count: int)

# === TIME SIGNALS ===
# Time progression signals (Stage 2 Task 1)
signal week_advanced(new_week: int, total_weeks: int)
signal month_completed(month: int, year: int)
signal year_completed(year: int)
signal time_advance_blocked(reasons: Array[String])
signal week_advance_blocked(reason: String)
signal weekly_event_triggered(event: WeeklyEvent)
signal weekly_update_started()
signal weekly_update_completed(duration_ms: int)
signal weekly_update_failed()

# === SAVE/LOAD SIGNALS (Task 7) ===
# Additional save-related signals for Task 7 implementation
signal auto_save_triggered()
signal save_progress(progress: float)
signal data_corrupted(slot_name: String, error: String)
signal backup_created(slot_name: String, backup_name: String)
signal backup_restored(slot_name: String, backup_name: String)

# Task 9: Resource tracking signals
signal gold_changed(old_amount: int, new_amount: int, change: int)
signal item_added(item_id: String, quantity: int, total: int)
signal item_removed(item_id: String, quantity: int, remaining: int)
signal transaction_failed(reason: String, amount: int)
signal creature_fed(creature_id: String, food_id: String, food_data: Dictionary)

# === STAMINA SIGNALS ===
# Stamina management signals (Stage 2 Task 5)
signal stamina_depleted(creature_data: CreatureData, amount: int)
signal stamina_restored(creature_data: CreatureData, amount: int)
signal creature_exhausted(creature_data: CreatureData)
signal creature_recovered(creature_data: CreatureData)
signal stamina_activity_performed(creature_data: CreatureData, activity: int, cost: int)  # activity is StaminaSystem.Activity enum
signal stamina_weekly_processed(active_count: int, stable_count: int)
signal food_consumed(creature_data: CreatureData, food_type: String)
signal activity_assigned(creature_data: CreatureData, activity: int)  # activity is StaminaSystem.Activity enum

# === TRAINING SIGNALS ===
# Training system signals (Stage 4)
signal training_scheduled(creature_data: CreatureData, activity: String, facility: String)
signal training_cancelled(creature_id: String, status: String)
signal training_completed(creature_data: CreatureData, activity: String, stat_gains: Dictionary)
signal training_food_consumed(creature_id: String, food_name: String, expires_week: int)

# === FACILITY SIGNALS ===
# Facility system signals (Task 1.2)
signal facility_unlocked(facility_id: String)
signal creature_assigned_to_facility(creature_id: String, facility_id: String, activity: int, food_type: int)
signal facility_assignment_removed(facility_id: String, creature_id: String)

# === GAME STATE SIGNALS ===
# GameController state signals (migrated from GameController)
signal game_state_changed()
signal creatures_updated()
signal resources_updated()
signal time_updated()
signal training_data_updated()
signal food_inventory_updated()

# === UI SIGNALS ===
# UIManager state signals (migrated from UIManager)
signal scene_changed(new_scene: String)
signal window_opened(window_name: String)
signal window_closed(window_name: String)
signal transition_started()
signal transition_completed()

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

# === AGE SIGNAL EMISSION ===
func emit_creature_category_changed(data: CreatureData, old_category: int, new_category: int) -> void:
	"""Emit creature_category_changed signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_category_changed with null data")
		return

	if old_category < 0 or old_category > 4:
		push_error("SignalBus: Invalid old_category: %d" % old_category)
		return

	if new_category < 0 or new_category > 4:
		push_error("SignalBus: Invalid new_category: %d" % new_category)
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_category_changed for '%s': %d -> %d" % [data.creature_name, old_category, new_category])

	creature_category_changed.emit(data, old_category, new_category)

func emit_creature_expired(data: CreatureData) -> void:
	"""Emit creature_expired signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_expired with null data")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_expired for '%s' (age: %d, lifespan: %d)" % [data.creature_name, data.age_weeks, data.lifespan_weeks])

	creature_expired.emit(data)

func emit_aging_batch_completed(creatures_aged: int, total_weeks: int) -> void:
	"""Emit aging_batch_completed signal with validation."""
	if creatures_aged < 0:
		push_error("SignalBus: Cannot emit aging_batch_completed with negative creatures_aged: %d" % creatures_aged)
		return

	if total_weeks < 0:
		push_error("SignalBus: Cannot emit aging_batch_completed with negative total_weeks: %d" % total_weeks)
		return

	if _debug_mode:
		print("SignalBus: Emitting aging_batch_completed: %d creatures aged by %d weeks" % [creatures_aged, total_weeks])

	aging_batch_completed.emit(creatures_aged, total_weeks)

# === TAG SIGNAL EMISSION ===
func emit_creature_tag_added(data: CreatureData, tag: String) -> void:
	"""Emit creature_tag_added signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_tag_added with null data")
		return

	if tag.is_empty():
		push_error("SignalBus: Cannot emit creature_tag_added with empty tag")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_tag_added for '%s': tag '%s'" % [data.creature_name, tag])

	creature_tag_added.emit(data, tag)

func emit_creature_tag_removed(data: CreatureData, tag: String) -> void:
	"""Emit creature_tag_removed signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit creature_tag_removed with null data")
		return

	if tag.is_empty():
		push_error("SignalBus: Cannot emit creature_tag_removed with empty tag")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_tag_removed for '%s': tag '%s'" % [data.creature_name, tag])

	creature_tag_removed.emit(data, tag)

func emit_tag_add_failed(data: CreatureData, tag: String, reason: String) -> void:
	"""Emit tag_add_failed signal with validation."""
	if data == null:
		push_error("SignalBus: Cannot emit tag_add_failed with null data")
		return

	if tag.is_empty():
		push_error("SignalBus: Cannot emit tag_add_failed with empty tag")
		return

	if reason.is_empty():
		push_error("SignalBus: Cannot emit tag_add_failed with empty reason")
		return

	if _debug_mode:
		print("SignalBus: Emitting tag_add_failed for '%s': tag '%s' - %s" % [data.creature_name, tag, reason])

	tag_add_failed.emit(data, tag, reason)

func emit_tag_validation_failed(tags: Array[String], errors: Array[String]) -> void:
	"""Emit tag_validation_failed signal with validation."""
	if tags.is_empty():
		push_error("SignalBus: Cannot emit tag_validation_failed with empty tags array")
		return

	if errors.is_empty():
		push_error("SignalBus: Cannot emit tag_validation_failed with empty errors array")
		return

	if _debug_mode:
		print("SignalBus: Emitting tag_validation_failed for tags %s: %s" % [str(tags), str(errors)])

	tag_validation_failed.emit(tags, errors)

# === SAVE/LOAD SIGNAL EMISSION (Task 7) ===
func emit_auto_save_triggered() -> void:
	"""Emit auto_save_triggered signal."""
	if _debug_mode:
		print("SignalBus: Emitting auto_save_triggered")

	auto_save_triggered.emit()

func emit_save_progress(progress: float) -> void:
	"""Emit save_progress signal with validation."""
	if progress < 0.0 or progress > 1.0:
		push_error("SignalBus: Invalid save progress: %.2f (must be 0.0-1.0)" % progress)
		return

	if _debug_mode:
		print("SignalBus: Emitting save_progress: %.1f%%" % (progress * 100.0))

	save_progress.emit(progress)

func emit_data_corrupted(slot_name: String, error: String) -> void:
	"""Emit data_corrupted signal with validation."""
	if slot_name.is_empty():
		push_error("SignalBus: Cannot emit data_corrupted with empty slot_name")
		return

	if error.is_empty():
		push_error("SignalBus: Cannot emit data_corrupted with empty error")
		return

	if _debug_mode:
		print("SignalBus: Emitting data_corrupted for slot '%s': %s" % [slot_name, error])

	data_corrupted.emit(slot_name, error)

func emit_backup_created(slot_name: String, backup_name: String) -> void:
	"""Emit backup_created signal with validation."""
	if slot_name.is_empty():
		push_error("SignalBus: Cannot emit backup_created with empty slot_name")
		return

	if backup_name.is_empty():
		push_error("SignalBus: Cannot emit backup_created with empty backup_name")
		return

	if _debug_mode:
		print("SignalBus: Emitting backup_created: '%s' -> '%s'" % [slot_name, backup_name])

	backup_created.emit(slot_name, backup_name)

func emit_backup_restored(slot_name: String, backup_name: String) -> void:
	"""Emit backup_restored signal with validation."""
	if slot_name.is_empty():
		push_error("SignalBus: Cannot emit backup_restored with empty slot_name")
		return

	if backup_name.is_empty():
		push_error("SignalBus: Cannot emit backup_restored with empty backup_name")
		return

	if _debug_mode:
		print("SignalBus: Emitting backup_restored: '%s' from '%s'" % [slot_name, backup_name])

	backup_restored.emit(slot_name, backup_name)

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

# === COLLECTION SIGNAL EMISSION (Task 8) ===
func emit_creature_acquired(creature_data: CreatureData, source: String) -> void:
	"""Emit creature_acquired signal with validation."""
	if creature_data == null:
		push_error("SignalBus: Cannot emit creature_acquired with null creature_data")
		return

	if source.is_empty():
		push_error("SignalBus: Cannot emit creature_acquired with empty source")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_acquired for '%s' from '%s'" % [creature_data.creature_name, source])

	creature_acquired.emit(creature_data, source)

func emit_creature_released(creature_data: CreatureData, reason: String) -> void:
	"""Emit creature_released signal with validation."""
	if creature_data == null:
		push_error("SignalBus: Cannot emit creature_released with null creature_data")
		return

	if reason.is_empty():
		push_error("SignalBus: Cannot emit creature_released with empty reason")
		return

	if _debug_mode:
		print("SignalBus: Emitting creature_released for '%s' reason: '%s'" % [creature_data.creature_name, reason])

	creature_released.emit(creature_data, reason)

func emit_active_roster_changed(new_roster: Array[CreatureData]) -> void:
	"""Emit active_roster_changed signal with validation."""
	if new_roster == null:
		push_error("SignalBus: Cannot emit active_roster_changed with null roster")
		return

	# Validate roster size doesn't exceed 6
	if new_roster.size() > 6:
		push_error("SignalBus: Active roster size exceeds limit: %d" % new_roster.size())
		return

	if _debug_mode:
		var creature_names: Array[String] = []
		for creature in new_roster:
			if creature != null:
				creature_names.append(creature.creature_name)
		print("SignalBus: Emitting active_roster_changed: [%s]" % ", ".join(creature_names))

	active_roster_changed.emit(new_roster)

func emit_stable_collection_updated(operation: String, creature_id: String) -> void:
	"""Emit stable_collection_updated signal with validation."""
	if operation.is_empty():
		push_error("SignalBus: Cannot emit stable_collection_updated with empty operation")
		return

	if creature_id.is_empty():
		push_error("SignalBus: Cannot emit stable_collection_updated with empty creature_id")
		return

	if _debug_mode:
		print("SignalBus: Emitting stable_collection_updated: %s for creature '%s'" % [operation, creature_id])

	stable_collection_updated.emit(operation, creature_id)

func emit_collection_milestone_reached(milestone: String, count: int) -> void:
	"""Emit collection_milestone_reached signal with validation."""
	if milestone.is_empty():
		push_error("SignalBus: Cannot emit collection_milestone_reached with empty milestone")
		return

	if count < 0:
		push_error("SignalBus: Cannot emit collection_milestone_reached with negative count: %d" % count)
		return

	if _debug_mode:
		print("SignalBus: Emitting collection_milestone_reached: '%s' at count %d" % [milestone, count])

	collection_milestone_reached.emit(milestone, count)

# Task 10: Species signal emission helpers
func emit_species_loaded(species_id: String) -> void:
	"""Emit species_loaded signal with validation."""
	if species_id.is_empty():
		push_error("SignalBus: Cannot emit species_loaded with empty species_id")
		return

	species_loaded.emit(species_id)
	if _debug_mode:
		print("SignalBus: Species loaded: %s" % species_id)

func emit_species_registered(species_id: String, category: String) -> void:
	"""Emit species_registered signal with validation."""
	if species_id.is_empty():
		push_error("SignalBus: Cannot emit species_registered with empty species_id")
		return

	if category.is_empty():
		push_error("SignalBus: Cannot emit species_registered with empty category")
		return

	species_registered.emit(species_id, category)
	if _debug_mode:
		print("SignalBus: Species registered: %s (category: %s)" % [species_id, category])

func emit_species_validation_failed(species_id: String, errors: Array[String]) -> void:
	"""Emit species_validation_failed signal with validation."""
	if species_id.is_empty():
		push_error("SignalBus: Cannot emit species_validation_failed with empty species_id")
		return

	species_validation_failed.emit(species_id, errors)
	if _debug_mode:
		print("SignalBus: Species validation failed: %s - %s" % [species_id, str(errors)])

# Task 9: Resource signal emission helpers
func emit_gold_changed(old_amount: int, new_amount: int, change: int) -> void:
	"""Emit gold_changed signal with validation."""
	if old_amount < 0 or new_amount < 0:
		push_error("SignalBus: Cannot emit gold_changed with negative amounts")
		return

	if _debug_mode:
		print("SignalBus: Gold changed from %d to %d (change: %d)" % [old_amount, new_amount, change])

	gold_changed.emit(old_amount, new_amount, change)

func emit_item_added(item_id: String, quantity: int, total: int) -> void:
	"""Emit item_added signal with validation."""
	if item_id.is_empty():
		push_error("SignalBus: Cannot emit item_added with empty item_id")
		return

	if quantity <= 0 or total <= 0:
		push_error("SignalBus: Cannot emit item_added with non-positive quantities")
		return

	if _debug_mode:
		print("SignalBus: Item added: %s x%d (total: %d)" % [item_id, quantity, total])

	item_added.emit(item_id, quantity, total)

func emit_item_removed(item_id: String, quantity: int, remaining: int) -> void:
	"""Emit item_removed signal with validation."""
	if item_id.is_empty():
		push_error("SignalBus: Cannot emit item_removed with empty item_id")
		return

	if quantity <= 0:
		push_error("SignalBus: Cannot emit item_removed with non-positive quantity")
		return

	if remaining < 0:
		push_error("SignalBus: Cannot emit item_removed with negative remaining")
		return

	if _debug_mode:
		print("SignalBus: Item removed: %s x%d (remaining: %d)" % [item_id, quantity, remaining])

	item_removed.emit(item_id, quantity, remaining)

func emit_transaction_failed(reason: String, amount: int) -> void:
	"""Emit transaction_failed signal with validation."""
	if reason.is_empty():
		push_error("SignalBus: Cannot emit transaction_failed with empty reason")
		return

	if _debug_mode:
		print("SignalBus: Transaction failed: %s (amount: %d)" % [reason, amount])

	transaction_failed.emit(reason, amount)

func emit_creature_fed(creature_id: String, food_id: String, food_data: Dictionary) -> void:
	"""Emit creature_fed signal with validation."""
	if creature_id.is_empty():
		push_error("SignalBus: Cannot emit creature_fed with empty creature_id")
		return

	if food_id.is_empty():
		push_error("SignalBus: Cannot emit creature_fed with empty food_id")
		return

	if food_data.is_empty():
		push_error("SignalBus: Cannot emit creature_fed with empty food_data")
		return

	if _debug_mode:
		print("SignalBus: Creature fed: %s consumed %s" % [creature_id, food_id])

	creature_fed.emit(creature_id, food_id, food_data)

# === TIME SIGNAL EMISSION ===
func emit_week_advanced(new_week: int, total_weeks: int) -> void:
	"""Emit week_advanced signal with validation."""
	if new_week <= 0:
		push_error("SignalBus: Cannot emit week_advanced with non-positive week: %d" % new_week)
		return

	if total_weeks < 0:
		push_error("SignalBus: Cannot emit week_advanced with negative total_weeks: %d" % total_weeks)
		return

	if _debug_mode:
		print("SignalBus: Emitting week_advanced: week %d (total: %d)" % [new_week, total_weeks])

	week_advanced.emit(new_week, total_weeks)

func emit_week_advance_blocked(reason: String) -> void:
	"""Emit week_advance_blocked signal with validation."""
	if reason.is_empty():
		push_error("SignalBus: Cannot emit week_advance_blocked with empty reason")
		return

	if _debug_mode:
		print("SignalBus: Emitting week_advance_blocked: %s" % reason)

	week_advance_blocked.emit(reason)

func emit_month_completed(month: int, year: int) -> void:
	"""Emit month_completed signal with validation."""
	if month <= 0 or month > 13:
		push_error("SignalBus: Invalid month: %d (must be 1-13)" % month)
		return

	if year <= 0:
		push_error("SignalBus: Invalid year: %d" % year)
		return

	if _debug_mode:
		print("SignalBus: Emitting month_completed: month %d of year %d" % [month, year])

	month_completed.emit(month, year)

func emit_year_completed(year: int) -> void:
	"""Emit year_completed signal with validation."""
	if year <= 0:
		push_error("SignalBus: Invalid year: %d" % year)
		return

	if _debug_mode:
		print("SignalBus: Emitting year_completed: year %d" % year)

	year_completed.emit(year)

func emit_time_advance_blocked(reasons: Array[String]) -> void:
	"""Emit time_advance_blocked signal with validation."""
	if reasons.is_empty():
		push_error("SignalBus: Cannot emit time_advance_blocked with empty reasons")
		return

	if _debug_mode:
		print("SignalBus: Emitting time_advance_blocked: %s" % str(reasons))

	time_advance_blocked.emit(reasons)

func emit_weekly_event_triggered(event: WeeklyEvent) -> void:
	"""Emit weekly_event_triggered signal with validation."""
	if event == null:
		push_error("SignalBus: Cannot emit weekly_event_triggered with null event")
		return

	if not event.is_valid():
		push_error("SignalBus: Cannot emit weekly_event_triggered with invalid event")
		return

	if _debug_mode:
		print("SignalBus: Emitting weekly_event_triggered: %s" % event.event_name)

	weekly_event_triggered.emit(event)

func emit_weekly_update_started() -> void:
	"""Emit weekly_update_started signal."""
	if _debug_mode:
		print("SignalBus: Emitting weekly_update_started")

	weekly_update_started.emit()

func emit_weekly_update_completed(duration_ms: int) -> void:
	"""Emit weekly_update_completed signal with validation."""
	if duration_ms < 0:
		push_error("SignalBus: Cannot emit weekly_update_completed with negative duration: %d" % duration_ms)
		return

	if _debug_mode:
		print("SignalBus: Emitting weekly_update_completed: %d ms" % duration_ms)

	weekly_update_completed.emit(duration_ms)

func _setup_signal_validation() -> void:
	"""Set up internal signal validation and logging."""
	# Connect to our own signals for validation/logging if needed
	# This allows us to track signal flow for debugging
	pass

# === GAME STATE SIGNAL EMISSION ===
func emit_game_state_changed() -> void:
	"""Emit game_state_changed signal."""
	if _debug_mode:
		print("SignalBus: Emitting game_state_changed")
	game_state_changed.emit()

func emit_creatures_updated() -> void:
	"""Emit creatures_updated signal."""
	if _debug_mode:
		print("SignalBus: Emitting creatures_updated")
	creatures_updated.emit()

func emit_resources_updated() -> void:
	"""Emit resources_updated signal."""
	if _debug_mode:
		print("SignalBus: Emitting resources_updated")
	resources_updated.emit()

func emit_time_updated() -> void:
	"""Emit time_updated signal."""
	if _debug_mode:
		print("SignalBus: Emitting time_updated")
	time_updated.emit()

func emit_training_data_updated() -> void:
	"""Emit training_data_updated signal."""
	if _debug_mode:
		print("SignalBus: Emitting training_data_updated")
	training_data_updated.emit()

func emit_food_inventory_updated() -> void:
	"""Emit food_inventory_updated signal."""
	if _debug_mode:
		print("SignalBus: Emitting food_inventory_updated")
	food_inventory_updated.emit()

# === UI SIGNAL EMISSION ===
func emit_scene_changed(new_scene: String) -> void:
	"""Emit scene_changed signal with validation."""
	if new_scene.is_empty():
		push_error("SignalBus: Cannot emit scene_changed with empty scene path")
		return
	if _debug_mode:
		print("SignalBus: Emitting scene_changed: %s" % new_scene)
	scene_changed.emit(new_scene)

func emit_window_opened(window_name: String) -> void:
	"""Emit window_opened signal with validation."""
	if window_name.is_empty():
		push_error("SignalBus: Cannot emit window_opened with empty window name")
		return
	if _debug_mode:
		print("SignalBus: Emitting window_opened: %s" % window_name)
	window_opened.emit(window_name)

func emit_window_closed(window_name: String) -> void:
	"""Emit window_closed signal with validation."""
	if window_name.is_empty():
		push_error("SignalBus: Cannot emit window_closed with empty window name")
		return
	if _debug_mode:
		print("SignalBus: Emitting window_closed: %s" % window_name)
	window_closed.emit(window_name)

func emit_transition_started() -> void:
	"""Emit transition_started signal."""
	if _debug_mode:
		print("SignalBus: Emitting transition_started")
	transition_started.emit()

func emit_transition_completed() -> void:
	"""Emit transition_completed signal."""
	if _debug_mode:
		print("SignalBus: Emitting transition_completed")
	transition_completed.emit()
