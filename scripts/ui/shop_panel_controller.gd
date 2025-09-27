@tool
extends Control

# Shop Panel Controller - Manages the complete shopping interface
# Provides vendor selection, item grid, purchase dialogs, and real-time updates

# === UI REFERENCES ===
@onready var vendor_list: ItemList = $HSplitContainer/VendorSidebar/VBoxContainer/VScrollContainer/VendorList
@onready var vendor_name_label: Label = $HSplitContainer/MainContent/VBoxContainer/VendorHeader/VBoxContainer/VendorName
@onready var vendor_description_label: Label = $HSplitContainer/MainContent/VBoxContainer/VendorHeader/VBoxContainer/VendorDescription
@onready var item_grid: GridContainer = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemArea/ScrollContainer/ItemGrid
@onready var item_detail_panel: Panel = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel
@onready var item_detail_name: Label = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/ItemName
@onready var item_detail_icon: TextureRect = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/ItemIcon
@onready var item_detail_description: Label = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/ItemDescription
@onready var item_detail_price: Label = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/ItemPrice
@onready var item_detail_stock: Label = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/ItemStock
@onready var purchase_button: Button = $HSplitContainer/MainContent/VBoxContainer/HSplitContainer2/ItemDetailPanel/VBoxContainer/PurchaseButton
@onready var gold_label: Label = $HSplitContainer/MainContent/VBoxContainer/VendorHeader/GoldLabel
@onready var filter_options: OptionButton = $HSplitContainer/MainContent/VBoxContainer/FilterBar/FilterType
@onready var sort_options: OptionButton = $HSplitContainer/MainContent/VBoxContainer/FilterBar/SortBy
@onready var search_line_edit: LineEdit = $HSplitContainer/MainContent/VBoxContainer/FilterBar/SearchBox

# === SYSTEM REFERENCES ===
var shop_system: Node
var resource_tracker: Node
var signal_bus: SignalBus

# === STATE ===
var current_vendor_id: String = ""
var current_item: Dictionary = {}
var vendor_data: Dictionary = {}
var filtered_items: Array[Dictionary] = []
var item_cards: Array[Control] = []
var _vendor_items_cache: Dictionary = {}  # Cache items by vendor_id

# === PERFORMANCE ===
var _update_timer: Timer
var _last_update_time: int = 0
var _is_initialized: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		call_deferred("_initialize_shop_panel")

func _initialize_shop_panel() -> void:
	if _is_initialized:
		_update_display()  # Just refresh display if already initialized
		return

	_setup_systems()
	_setup_ui()
	_connect_signals()
	_load_vendors()
	_update_display()
	_is_initialized = true

func _setup_systems() -> void:
	shop_system = GameCore.get_system("shop")
	resource_tracker = GameCore.get_system("resource")
	signal_bus = GameCore.get_signal_bus()

func _setup_ui() -> void:
	# Setup filter options
	filter_options.add_item("All Items")
	filter_options.add_item("Creature Eggs")
	filter_options.add_item("Food")
	filter_options.add_item("Training Items")
	filter_options.add_item("Special Items")
	filter_options.add_item("In Stock Only")

	# Setup sort options
	sort_options.add_item("Name")
	sort_options.add_item("Price (Low to High)")
	sort_options.add_item("Price (High to Low)")
	sort_options.add_item("Stock Available")

	# Setup item grid
	item_grid.columns = 4

	# Hide item detail panel initially
	item_detail_panel.hide()

	# Setup update timer for real-time updates
	_update_timer = Timer.new()
	_update_timer.wait_time = 1.0  # Update every second
	_update_timer.timeout.connect(_update_real_time)
	add_child(_update_timer)
	_update_timer.start()

func _connect_signals() -> void:
	# UI signals
	vendor_list.item_selected.connect(_on_vendor_selected)
	purchase_button.pressed.connect(_on_purchase_pressed)
	filter_options.item_selected.connect(_on_filter_changed)
	sort_options.item_selected.connect(_on_sort_changed)
	search_line_edit.text_changed.connect(_on_search_changed)

	# System signals
	if signal_bus:
		signal_bus.item_purchased.connect(_on_item_purchased)
		signal_bus.shop_refreshed.connect(_on_shop_refreshed)
		signal_bus.vendor_unlocked.connect(_on_vendor_unlocked)

func _load_vendors() -> void:
	if not shop_system:
		return

	vendor_list.clear()
	var unlocked_vendors = shop_system.get_unlocked_vendors()

	for vendor in unlocked_vendors:
		vendor_list.add_item(vendor.display_name)
		vendor_data[vendor_list.get_item_count() - 1] = vendor.vendor_id

	# Add locked vendors (grayed out)
	var all_vendors = shop_system.get_all_vendors()
	for vendor in all_vendors:
		if not shop_system.is_vendor_unlocked(vendor.vendor_id):
			var index = vendor_list.get_item_count()
			vendor_list.add_item("[LOCKED] " + vendor.display_name)
			vendor_list.set_item_disabled(index, true)
			vendor_data[index] = vendor.vendor_id

	# Select first unlocked vendor
	if vendor_list.get_item_count() > 0:
		vendor_list.select(0)
		_on_vendor_selected(0)

func _update_display() -> void:
	_update_gold_display()
	_update_vendor_display()
	_update_item_grid()

func _update_gold_display() -> void:
	if resource_tracker and gold_label:
		var gold = resource_tracker.get_balance()
		gold_label.text = "Gold: %d" % gold

func _update_vendor_display() -> void:
	if current_vendor_id.is_empty() or not shop_system:
		return

	var vendor = shop_system.get_vendor(current_vendor_id)
	if not vendor:
		return

	vendor_name_label.text = vendor.display_name
	vendor_description_label.text = vendor.description

func _update_item_grid() -> void:
	var t0 = Time.get_ticks_msec()

	if current_vendor_id.is_empty() or not shop_system:
		_clear_item_grid()
		return

	# Get inventory - use cache if available and not stale
	var inventory: Array[Dictionary]
	if _vendor_items_cache.has(current_vendor_id):
		inventory = _vendor_items_cache[current_vendor_id]
	else:
		inventory = shop_system.get_vendor_inventory(current_vendor_id)
		_vendor_items_cache[current_vendor_id] = inventory

	# Filter and sort
	var new_filtered = _filter_and_sort_items(inventory)

	# Only recreate if items actually changed
	if not _items_equal(filtered_items, new_filtered):
		_clear_item_grid()
		filtered_items = new_filtered

		# Create item cards
		for item in filtered_items:
			var card = _create_item_card(item)
			item_grid.add_child(card)
			item_cards.append(card)

	var dt = Time.get_ticks_msec() - t0
	if dt > 16:  # Log if takes more than 16ms (targeting 60 FPS)
		print("AI_NOTE: performance(shop_item_grid_update) = %d ms (targeting <16ms for 60 FPS)" % dt)

func _filter_and_sort_items(inventory: Array[Dictionary]) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []

	for item in inventory:
		if _passes_filter(item):
			filtered.append(item)

	# Sort items
	var sort_type = sort_options.selected
	match sort_type:
		0:  # Name
			filtered.sort_custom(func(a, b): return a.display_name < b.display_name)
		1:  # Price (Low to High)
			filtered.sort_custom(func(a, b): return a.final_price < b.final_price)
		2:  # Price (High to Low)
			filtered.sort_custom(func(a, b): return a.final_price > b.final_price)
		3:  # Stock Available
			filtered.sort_custom(func(a, b): return a.stock_quantity > b.stock_quantity)

	return filtered

func _passes_filter(item: Dictionary) -> bool:
	# Search filter
	var search_text = search_line_edit.text.to_lower()
	if not search_text.is_empty():
		var display_name = item.get("display_name", "")
		var description = item.get("description", "")
		if not display_name.to_lower().contains(search_text) and not description.to_lower().contains(search_text):
			return false

	# Type filter
	var filter_type = filter_options.selected
	match filter_type:
		0:  # All Items
			return true
		5:  # In Stock Only
			return item.get("stock_quantity", 0) > 0
		_:  # Other filters would need item type info from ItemManager
			return true

	return true

func _create_item_card(item: Dictionary) -> Control:
	# Load the ShopItemCard component
	var card_scene = preload("res://scenes/ui/components/shop_item_card.tscn")
	var card = card_scene.instantiate()

	# Setup the card with item data
	if card.has_method("setup_item"):
		card.setup_item(item, current_vendor_id, shop_system)

	# Connect the item selection signal
	if card.has_signal("item_selected"):
		card.item_selected.connect(_on_item_card_selected)

	return card

func _clear_item_grid() -> void:
	for card in item_cards:
		card.queue_free()
	item_cards.clear()

func _items_equal(list1: Array[Dictionary], list2: Array[Dictionary]) -> bool:
	if list1.size() != list2.size():
		return false

	for i in range(list1.size()):
		var item1 = list1[i]
		var item2 = list2[i]
		if item1.get("item_id", "") != item2.get("item_id", "") or \
		   item1.get("stock_quantity", 0) != item2.get("stock_quantity", 0):
			return false

	return true

func _load_detail_item_icon(item: Dictionary) -> void:
	if not item_detail_icon or item.is_empty():
		return

	var item_id = item.get("item_id", "")
	if item_id.is_empty():
		_set_detail_fallback_icon(item)
		return

	# Get the actual ItemResource from ItemManager
	var item_manager = GameCore.get_system("item_manager")
	if not item_manager:
		_set_detail_fallback_icon(item)
		return

	var item_resource = item_manager.get_item_resource(item_id)
	if not item_resource:
		_set_detail_fallback_icon(item)
		return

	# Load the icon texture
	var icon_path = item_resource.icon_path
	if icon_path.is_empty():
		_set_detail_fallback_icon(item)
		return

	# Load the texture
	if ResourceLoader.exists(icon_path):
		var texture = load(icon_path)
		if texture is Texture2D:
			item_detail_icon.texture = texture
		else:
			_set_detail_fallback_icon(item)
	else:
		_set_detail_fallback_icon(item)

func _set_detail_fallback_icon(item: Dictionary) -> void:
	# Create a simple colored texture as fallback for detail panel
	if not item_detail_icon:
		return

	# Try to determine item type for fallback color
	var item_id = item.get("item_id", "")
	var fallback_color = Color(0.5, 0.5, 0.5, 1)  # Default gray

	# Set colors based on item type
	if "egg" in item_id:
		fallback_color = Color(0.9, 0.8, 0.6, 1)  # Cream for eggs
	elif "food" in item_id or "grain" in item_id or "hay" in item_id:
		fallback_color = Color(0.6, 0.8, 0.4, 1)  # Green for food
	elif "potion" in item_id or "elixir" in item_id:
		fallback_color = Color(0.6, 0.4, 0.8, 1)  # Purple for potions

	# Create a simple texture (larger for detail panel)
	var image = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	image.fill(fallback_color)
	var texture = ImageTexture.new()
	texture.set_image(image)
	item_detail_icon.texture = texture

func _update_real_time() -> void:
	_update_gold_display()

	# Update stock displays for visible items every few seconds
	var current_time = Time.get_ticks_msec()
	if current_time - _last_update_time > 3000:  # Every 3 seconds
		_refresh_item_stock_displays()
		_last_update_time = current_time

func _refresh_item_stock_displays() -> void:
	# Update stock numbers on visible cards without full refresh
	if filtered_items.size() != item_cards.size():
		_update_item_grid()  # Full refresh if counts don't match
		return

	for i in range(min(item_cards.size(), filtered_items.size())):
		var card = item_cards[i]
		var item = filtered_items[i]

		# Find stock label in card and update it
		_update_card_stock_display(card, item)

func _update_card_stock_display(card: Control, item: Dictionary) -> void:
	# Update stock display on ShopItemCard component
	if card.has_method("update_stock"):
		var new_stock = item.get("stock_quantity", 0)
		card.update_stock(new_stock)
	elif card.has_method("refresh_display"):
		card.refresh_display()

# === EVENT HANDLERS ===

func _on_vendor_selected(index: int) -> void:
	if index < 0 or not vendor_data.has(index):
		return

	current_vendor_id = vendor_data[index]
	current_item = {}
	item_detail_panel.hide()

	_update_vendor_display()
	_update_item_grid()

func _on_item_card_selected(item: Dictionary) -> void:
	_on_item_card_clicked(item)

func _on_item_card_clicked(item: Dictionary) -> void:
	current_item = item
	_show_item_detail(item)

func _show_item_detail(item: Dictionary) -> void:
	item_detail_name.text = item.get("display_name", "Unknown Item")
	item_detail_description.text = item.get("description", "No description available")

	# Load item icon
	_load_detail_item_icon(item)

	var price = item.get("final_price", 0)
	item_detail_price.text = "Price: %d gold" % price
	item_detail_stock.text = "Stock: %d" % item.get("stock_quantity", 0)

	# Check if purchasable
	var player_gold = resource_tracker.get_balance() if resource_tracker else 0
	var item_id = item.get("item_id", "")
	var can_purchase = shop_system.can_purchase_item(current_vendor_id, item_id, player_gold)

	purchase_button.disabled = not can_purchase.can_purchase
	purchase_button.text = "Purchase" if can_purchase.can_purchase else can_purchase.reason

	item_detail_panel.show()

func _on_purchase_pressed() -> void:
	if not current_item or not shop_system or not resource_tracker:
		return

	var player_gold = resource_tracker.get_balance()
	var item_id = current_item.get("item_id", "")
	var result = shop_system.purchase_item(current_vendor_id, item_id, player_gold)

	if result.success:
		# Show success feedback (gold deduction and inventory addition handled by signals)
		_show_purchase_feedback(true, "Purchase successful!", result.gold_spent)

		# Update displays
		_update_display()
		_show_item_detail(current_item)  # Refresh item detail

	else:
		_show_purchase_feedback(false, result.message, 0)

func _show_purchase_feedback(success: bool, message: String, cost: int) -> void:
	# Create feedback notification
	var notification = preload("res://scenes/ui/components/notification_popup.tscn").instantiate()
	if notification:
		get_parent().add_child(notification)
		if notification.has_method("show_notification"):
			var full_message = message
			if success and cost > 0:
				full_message += " (-%d gold)" % cost
			notification.show_notification(full_message, 3.0)

func _on_filter_changed(index: int) -> void:
	_update_item_grid()

func _on_sort_changed(index: int) -> void:
	_update_item_grid()

func _on_search_changed(new_text: String) -> void:
	_update_item_grid()

# === SYSTEM EVENT HANDLERS ===

func _on_item_purchased(item_id: String, quantity: int, vendor_id: String) -> void:
	if vendor_id == current_vendor_id:
		# Invalidate cache for this vendor since stock changed
		_vendor_items_cache.erase(vendor_id)
		_update_item_grid()

func _on_shop_refreshed(weeks_passed: int) -> void:
	# Clear all vendor caches since items may have restocked
	_vendor_items_cache.clear()
	_update_item_grid()

func _on_vendor_unlocked(vendor_id: String) -> void:
	_load_vendors()  # Refresh vendor list
