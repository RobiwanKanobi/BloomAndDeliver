extends Control

@onready var _customer_portrait: TextureRect = $MainLayout/LeftColumn/CustomerPortrait
@onready var _customer_name_label: Label = $MainLayout/LeftColumn/CustomerNameLabel
@onready var _order_text_label: Label = $MainLayout/LeftColumn/OrderTextLabel
@onready var _reward_label: Label = $MainLayout/LeftColumn/RewardLabel
@onready var _bouquet_container: HBoxContainer = $MainLayout/CenterColumn/BouquetSlots
@onready var _inventory_container: VBoxContainer = $MainLayout/RightColumn/ScrollContainer/InventoryList
@onready var _feedback_label: Label = $BottomRow/FeedbackLabel
@onready var _confirm_button: Button = $BottomRow/ConfirmButton
@onready var _clear_button: Button = $BottomRow/ClearButton
@onready var _town_map_button: Button = $BottomRow/TownMapButton
@onready var _back_button: Button = $BottomRow/BackButton
@onready var _money_label: Label = $MoneyLabel

var _current_order: OrderData
var _bouquet_slots: Array[String] = []
var _delivery_ready: bool = false


func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm)
	_clear_button.pressed.connect(_on_clear_bouquet)
	_town_map_button.pressed.connect(_on_go_to_town_map)
	_back_button.pressed.connect(_on_back_to_greenhouse)
	_town_map_button.visible = false
	_load_order()
	_refresh_inventory_list()
	_refresh_bouquet_display()
	_validate_bouquet()
	_update_money_display()
	GameState.inventory_changed.connect(_refresh_inventory_list)
	GameState.money_changed.connect(_update_money_display)


func _load_order() -> void:
	if GameState.current_order_id != "" and GameState.orders_db.has(GameState.current_order_id):
		_current_order = GameState.orders_db[GameState.current_order_id]
	else:
		var next_order = GameState.get_next_order()
		if next_order:
			GameState.set_current_order(next_order.id)
			_current_order = next_order
		else:
			_current_order = null

	if _current_order:
		var customer = ContentDB.get_customer(_current_order.customer_id)
		_customer_name_label.text = customer.display_name if customer else _current_order.customer_id
		_order_text_label.text = _current_order.request_text
		_reward_label.text = "Reward: %d coins" % _current_order.reward_money
		var portrait_path := "res://assets/art/characters/%s_portrait.png" % _current_order.customer_id
		if ResourceLoader.exists(portrait_path):
			_customer_portrait.texture = load(portrait_path)
		else:
			_customer_portrait.texture = null
	else:
		_customer_name_label.text = "No customer"
		_order_text_label.text = "No more orders today."
		_reward_label.text = ""
		_customer_portrait.texture = null


func _refresh_inventory_list() -> void:
	for child in _inventory_container.get_children():
		child.queue_free()

	var inv := GameState.get_inventory_array()
	for item in inv:
		var available = item.quantity - _count_in_bouquet(item.id)
		if available <= 0:
			continue
		var btn := Button.new()
		var flower = ContentDB.get_flower(item.id)
		var name_str = flower.display_name if flower else item.id
		btn.text = "%s (x%d)" % [name_str, available]
		btn.custom_minimum_size = Vector2(200, 40)
		var fid = item.id
		btn.pressed.connect(func(): _add_to_bouquet(fid))
		_inventory_container.add_child(btn)


func _count_in_bouquet(flower_id: String) -> int:
	var count := 0
	for slot in _bouquet_slots:
		if slot == flower_id:
			count += 1
	return count


func _add_to_bouquet(flower_id: String) -> void:
	if _delivery_ready:
		return
	var max_slots := GameState.get_max_bouquet_slots()
	if _bouquet_slots.size() >= max_slots:
		_feedback_label.text = "Bouquet is full!"
		return
	var available = GameState.get_flower_quantity(flower_id) - _count_in_bouquet(flower_id)
	if available <= 0:
		_feedback_label.text = "No more of that flower available."
		return
	_bouquet_slots.append(flower_id)
	_refresh_bouquet_display()
	_refresh_inventory_list()
	_validate_bouquet()


func _remove_from_bouquet(index: int) -> void:
	if _delivery_ready:
		return
	if index >= 0 and index < _bouquet_slots.size():
		_bouquet_slots.remove_at(index)
		_refresh_bouquet_display()
		_refresh_inventory_list()
		_validate_bouquet()


func _refresh_bouquet_display() -> void:
	for child in _bouquet_container.get_children():
		child.queue_free()

	var max_slots := GameState.get_max_bouquet_slots()
	for i in range(max_slots):
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(100, 100)
		if i < _bouquet_slots.size():
			var flower = ContentDB.get_flower(_bouquet_slots[i])
			slot.text = flower.display_name if flower else _bouquet_slots[i]
			var idx = i
			slot.pressed.connect(func(): _remove_from_bouquet(idx))
		else:
			slot.text = "(empty)"
			slot.disabled = true
		_bouquet_container.add_child(slot)


func _validate_bouquet() -> bool:
	if not _current_order:
		_feedback_label.text = "No order loaded."
		_confirm_button.disabled = true
		return false

	if _bouquet_slots.size() == 0:
		_feedback_label.text = "Add flowers to your bouquet."
		_confirm_button.disabled = true
		return false

	var missing_messages: Array[String] = []
	for req in _current_order.requirements:
		var count := 0
		for flower_id in _bouquet_slots:
			var flower = ContentDB.get_flower(flower_id)
			if not flower:
				continue
			if req.requirement_type == "ColorTag" and flower.color_tag == req.target_value:
				count += 1
			elif req.requirement_type == "FlowerType" and flower.flower_type == req.target_value:
				count += 1
		if count < req.amount:
			missing_messages.append("Need %d more %s: %s" % [req.amount - count, req.requirement_type, req.target_value])

	if missing_messages.size() > 0:
		_feedback_label.text = "Missing: " + ", ".join(missing_messages)
		_confirm_button.disabled = true
		return false
	else:
		_feedback_label.text = "Bouquet looks great! Ready to confirm."
		_confirm_button.disabled = false
		return true


func _on_confirm() -> void:
	if not _current_order:
		return
	for flower_id in _bouquet_slots:
		GameState.remove_flower(flower_id, 1)
	GameState.current_bouquet_flower_ids = _bouquet_slots.duplicate()
	GameState.set_delivery_target(_current_order.destination_location_id)
	_delivery_ready = true
	_confirm_button.disabled = true
	_clear_button.disabled = true
	_back_button.disabled = true
	_town_map_button.visible = true
	var loc = ContentDB.get_location(_current_order.destination_location_id)
	var dest_name = loc.display_name if loc else _current_order.destination_location_id
	_feedback_label.text = "Bouquet confirmed! Deliver to: %s" % dest_name


func _on_clear_bouquet() -> void:
	_bouquet_slots.clear()
	_refresh_bouquet_display()
	_refresh_inventory_list()
	_validate_bouquet()


func _update_money_display() -> void:
	_money_label.text = "Coins: %d" % GameState.money


func _on_go_to_town_map() -> void:
	SceneRouter.go_to_town_map()


func _on_back_to_greenhouse() -> void:
	SceneRouter.go_to_greenhouse()
