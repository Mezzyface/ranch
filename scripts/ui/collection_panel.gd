@tool
class_name CollectionPanel
extends Control

@onready var active_grid: GridContainer = $VBox/ActiveSection/ActiveGrid
@onready var stable_scroll: ScrollContainer = $VBox/StableSection/ScrollContainer
@onready var stable_list: VBoxContainer = $VBox/StableSection/ScrollContainer/StableList
@onready var search_bar: LineEdit = $VBox/StableSection/Header/SearchBar
@onready var filter_button: OptionButton = $VBox/StableSection/Header/FilterButton

var creature_card_scene = preload("res://scenes/ui/components/creature_card.tscn")
var creature_list_item_scene = preload("res://scenes/ui/components/creature_list_item.tscn")

var collection_system
var _active_cards: Array[CreatureCard] = []
var _stable_items: Array[CreatureListItem] = []
var _current_filter: String = ""
var _current_search: String = ""

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_collection_panel()

func _setup_collection_panel() -> void:
	collection_system = GameCore.get_system("collection")

	if not collection_system:
		push_error("CollectionPanel: Collection system not found")
		return

	_setup_active_grid()
	_setup_layout()
	_setup_signals()
	_setup_filters()
	_refresh_display()

func _setup_active_grid() -> void:
	active_grid.columns = 3

	for i in range(6):
		var card = creature_card_scene.instantiate() as CreatureCard
		card.slot_index = i
		card.is_active_slot = true
		card.is_empty_slot = true
		card.dragged.connect(_on_creature_dragged)
		card.dropped.connect(_on_creature_dropped_to_active)
		card.clicked.connect(_on_creature_clicked)
		active_grid.add_child(card)
		_active_cards.append(card)

func _setup_layout() -> void:
	# Ensure stable section gets adequate space
	var stable_section = $VBox/StableSection
	stable_section.custom_minimum_size.y = 300  # Minimum 300 pixels for stable section

	# Make sure scroll container has proper sizing
	var scroll_container = $VBox/StableSection/ScrollContainer
	scroll_container.custom_minimum_size.y = 200  # Minimum scroll area

func _setup_signals() -> void:
	var signal_bus = GameCore.get_signal_bus()
	signal_bus.active_roster_changed.connect(_on_active_roster_changed)
	signal_bus.stable_collection_updated.connect(_on_stable_collection_updated)
	signal_bus.creature_acquired.connect(_on_creature_acquired)
	signal_bus.creature_released.connect(_on_creature_released)
	signal_bus.creature_stats_changed.connect(_on_creature_stats_changed)
	signal_bus.week_advanced.connect(_on_week_advanced)
	signal_bus.creature_aged.connect(_on_creature_aged)
	signal_bus.aging_batch_completed.connect(_on_aging_batch_completed)
	search_bar.text_changed.connect(_on_search_changed)
	filter_button.item_selected.connect(_on_filter_changed)

func _setup_filters() -> void:
	filter_button.add_item("All Creatures")

	# Get actual species from the system
	var species_system = GameCore.get_system("species")
	if species_system:
		var all_species = species_system.get_all_species()
		for species_id in all_species:
			var species = species_system.get_species(species_id)
			if species:
				filter_button.add_item(species.display_name)
	else:
		# Fallback species if system not available
		filter_button.add_item("Glow Grub")
		filter_button.add_item("Scuttleguard")
		filter_button.add_item("Stone Sentinel")
		filter_button.add_item("Wind Dancer")

func _refresh_display() -> void:
	_update_active_roster()
	_update_stable_list()

func _update_active_roster() -> void:
	if not collection_system:
		return

	var active_creatures = collection_system.get_active_creatures()

	for i in range(6):
		var card = _active_cards[i]
		if i < active_creatures.size():
			card.set_creature(active_creatures[i])
		else:
			card.clear_slot()

func _update_stable_list() -> void:
	if not collection_system:
		return

	_clear_stable_list()

	var stable_creatures = collection_system.get_stable_creatures()
	var filtered_creatures = _filter_creatures(stable_creatures)

	for creature in filtered_creatures:
		var item = creature_list_item_scene.instantiate() as CreatureListItem
		item.creature_data = creature
		item.dragged.connect(_on_creature_dragged_from_stable)
		item.clicked.connect(_on_creature_clicked)
		item.double_clicked.connect(_on_creature_double_clicked)
		stable_list.add_child(item)
		_stable_items.append(item)

func _clear_stable_list() -> void:
	for item in _stable_items:
		if item and is_instance_valid(item):
			stable_list.remove_child(item)
			item.queue_free()
	_stable_items.clear()

func _filter_creatures(creatures: Array[CreatureData]) -> Array[CreatureData]:
	var filtered: Array[CreatureData] = []

	for creature in creatures:
		if not _passes_search_filter(creature):
			continue
		if not _passes_type_filter(creature):
			continue
		filtered.append(creature)

	return filtered

func _passes_search_filter(creature: CreatureData) -> bool:
	if _current_search.is_empty():
		return true

	var search_lower = _current_search.to_lower()
	return creature.creature_name.to_lower().contains(search_lower)

func _passes_type_filter(creature: CreatureData) -> bool:
	if _current_filter.is_empty() or _current_filter == "All Creatures":
		return true

	var species_system = GameCore.get_system("species")
	if not species_system:
		return true

	var species = species_system.get_species(creature.species_id)
	if not species:
		return true

	# Check if species display name matches the filter exactly
	return species.display_name == _current_filter

func _on_creature_dragged(creature: CreatureData, card: CreatureCard) -> void:
	print("CollectionPanel: Creature dragged from active slot: ", creature.creature_name)

func _on_creature_dragged_from_stable(creature: CreatureData, item: CreatureListItem) -> void:
	print("CollectionPanel: Creature dragged from stable: ", creature.creature_name)

func _on_creature_dropped_to_active(creature: CreatureData, slot_index: int) -> void:
	print("CollectionPanel: Creature dropped to active slot %d: %s" % [slot_index, creature.creature_name])

	if not collection_system:
		return

	var current_active = collection_system.get_active_creatures()

	# Check if this is a creature from stable
	var is_from_stable = creature.id in collection_system.stable_collection

	# Check if this is swapping within active roster
	var is_from_active = creature.id in collection_system._active_lookup

	if slot_index >= 0 and slot_index < 6:
		# If there's already a creature in this slot
		if slot_index < current_active.size():
			var displaced_creature = current_active[slot_index]

			if is_from_stable:
				# Moving from stable to active slot - displace current to stable
				collection_system.move_to_stable(displaced_creature.id)
				collection_system.promote_to_active(creature.id)
			elif is_from_active and displaced_creature.id != creature.id:
				# Swapping two active creatures
				var source_index = collection_system._active_lookup[creature.id]
				_swap_active_creatures(source_index, slot_index)
		else:
			# Empty slot - just add creature
			if is_from_stable:
				collection_system.promote_to_active(creature.id)
			elif is_from_active:
				# Reorganizing within active roster - no action needed
				pass

func _swap_active_creatures(index_a: int, index_b: int) -> void:
	"""Swap two creatures in active roster."""
	if not collection_system:
		return

	var active = collection_system.get_active_creatures()
	if index_a >= 0 and index_a < active.size() and index_b >= 0 and index_b < active.size():
		# Swap in the array
		var temp = active[index_a]
		active[index_a] = active[index_b]
		active[index_b] = temp

		# Update the system's roster
		collection_system.active_roster = active
		collection_system._rebuild_active_lookup()

		# Emit signal for UI update
		var signal_bus = GameCore.get_signal_bus()
		signal_bus.emit_active_roster_changed(active)

func _on_creature_clicked(creature: CreatureData) -> void:
	print("CollectionPanel: Creature clicked: ", creature.creature_name)

func _on_creature_double_clicked(creature: CreatureData) -> void:
	print("CollectionPanel: Creature double-clicked (moving to active): ", creature.creature_name)

	if collection_system:
		collection_system.promote_to_active(creature.id)

func _on_active_roster_changed(new_roster: Array[CreatureData]) -> void:
	_update_active_roster()

func _on_stable_collection_updated(action: String, creature_id: String) -> void:
	_update_stable_list()

func _on_creature_acquired(creature_data: CreatureData, source: String) -> void:
	_refresh_display()

func _on_creature_released(creature_data: CreatureData, reason: String) -> void:
	_refresh_display()

func _on_creature_stats_changed(creature_data: CreatureData, stat: String, old_value: int, new_value: int) -> void:
	# Only refresh if this might affect display (for now, refresh all to be safe)
	_refresh_display()

func _on_search_changed(new_text: String) -> void:
	_current_search = new_text
	_update_stable_list()

func _on_filter_changed(index: int) -> void:
	_current_filter = filter_button.get_item_text(index)
	_update_stable_list()

func _on_week_advanced(new_week: int, total_weeks: int) -> void:
	print("CollectionPanel: Week advanced to %d (total: %d) - refreshing display" % [new_week, total_weeks])
	_refresh_display()

func _on_creature_aged(creature_data: CreatureData, new_age: int) -> void:
	print("CollectionPanel: Creature '%s' aged to %d weeks - updating display" % [creature_data.creature_name, new_age])
	# Individual creature aged - just refresh display to update all UI elements
	_refresh_display()

func _on_aging_batch_completed(creatures_aged: int, total_weeks: int) -> void:
	print("CollectionPanel: Aging batch completed (%d creatures aged) - refreshing display" % creatures_aged)
	_refresh_display()
