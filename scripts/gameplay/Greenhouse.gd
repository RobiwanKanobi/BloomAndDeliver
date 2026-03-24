extends Node2D

@onready var _inventory_label: Label = $CanvasLayer/UI/InventoryLabel
@onready var _money_label: Label = $CanvasLayer/UI/MoneyLabel
@onready var _go_to_shop_button: Button = $CanvasLayer/UI/GoToShopButton
@onready var _title_label: Label = $CanvasLayer/UI/TitleLabel
@onready var _seed_shop_button: Button = $CanvasLayer/UI/SeedShopButton
@onready var _slots_container: VBoxContainer = $CanvasLayer/UI/SlotsContainer
@onready var _go_to_bed_button: Button = $CanvasLayer/UI/GoToBedButton

var _seed_shop_open: bool = false
var _seed_shop_panel: Control


func _ready() -> void:
	_go_to_shop_button.pressed.connect(_on_go_to_shop)
	_go_to_bed_button.pressed.connect(_on_go_to_bed)
	_seed_shop_button.pressed.connect(_toggle_seed_shop)
	GameState.inventory_changed.connect(_refresh_ui)
	_title_label.text = "Greenhouse - Day %d (Phase %d)" % [GameState.current_day, GameState.get_game_phase()]
	GreenhouseSystem.init_slots()
	_refresh_ui()
	_refresh_slots()


func _toggle_seed_shop() -> void:
	_seed_shop_open = not _seed_shop_open
	if _seed_shop_open:
		_show_seed_shop()
	else:
		_hide_seed_shop()


func _show_seed_shop() -> void:
	if _seed_shop_panel:
		_seed_shop_panel.queue_free()
	_seed_shop_panel = VBoxContainer.new()
	_seed_shop_panel.name = "SeedShopPanel"
	var title_lbl := Label.new()
	title_lbl.text = "-- Seed Shop --"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_seed_shop_panel.add_child(title_lbl)

	var offerings = ProgressionSystem.get_seed_shop_offerings()
	for item in offerings:
		var btn := Button.new()
		var seed_count = GameState.seed_inventory.get(item.flower_id, 0)
		btn.text = "%s - %d coins (have: %d)" % [item.display_name, item.cost, seed_count]
		btn.custom_minimum_size = Vector2(300, 35)
		var fid = item.flower_id
		btn.pressed.connect(func():
			if ProgressionSystem.buy_seed(fid):
				_refresh_ui()
				_show_seed_shop()
		)
		btn.disabled = GameState.money < item.cost
		_seed_shop_panel.add_child(btn)

	var close_btn := Button.new()
	close_btn.text = "Close Shop"
	close_btn.custom_minimum_size = Vector2(300, 35)
	close_btn.pressed.connect(func():
		_seed_shop_open = false
		_hide_seed_shop()
	)
	_seed_shop_panel.add_child(close_btn)
	$CanvasLayer/UI.add_child(_seed_shop_panel)


func _hide_seed_shop() -> void:
	if _seed_shop_panel:
		_seed_shop_panel.queue_free()
		_seed_shop_panel = null


func _refresh_slots() -> void:
	for child in _slots_container.get_children():
		child.queue_free()

	var total = GreenhouseSystem.get_total_slots()
	for i in range(total):
		var slot = GameState.greenhouse_slots.get(i, {"flower_id": "", "state": "empty", "days_remaining": 0})
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(320, 35)

		var lbl := Label.new()
		match slot.state:
			"empty":
				lbl.text = "Slot %d: [Empty]" % (i + 1)
			"planted":
				var fname = _flower_name(slot.flower_id)
				lbl.text = "Slot %d: %s (planted, %d days)" % [i + 1, fname, slot.days_remaining]
			"budding":
				var fname = _flower_name(slot.flower_id)
				lbl.text = "Slot %d: %s (budding, %d days)" % [i + 1, fname, slot.days_remaining]
			"ready":
				var fname = _flower_name(slot.flower_id)
				lbl.text = "Slot %d: %s [READY]" % [i + 1, fname]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		if slot.state == "empty":
			var plant_btn := Button.new()
			plant_btn.text = "Plant"
			plant_btn.custom_minimum_size = Vector2(70, 30)
			var idx = i
			plant_btn.pressed.connect(func(): _show_plant_menu(idx))
			plant_btn.disabled = GameState.seed_inventory.is_empty()
			hbox.add_child(plant_btn)
		elif slot.state == "ready":
			var harvest_btn := Button.new()
			harvest_btn.text = "Harvest"
			harvest_btn.custom_minimum_size = Vector2(70, 30)
			var idx = i
			harvest_btn.pressed.connect(func():
				GreenhouseSystem.harvest_slot(idx)
				_refresh_ui()
				_refresh_slots()
			)
			hbox.add_child(harvest_btn)

		_slots_container.add_child(hbox)


func _show_plant_menu(slot_index: int) -> void:
	for child in _slots_container.get_children():
		child.queue_free()

	var title_row := Label.new()
	title_row.text = "Choose a seed for slot %d:" % (slot_index + 1)
	_slots_container.add_child(title_row)

	for fid in GameState.seed_inventory:
		if GameState.seed_inventory[fid] <= 0:
			continue
		var btn := Button.new()
		btn.text = "%s (seeds: %d)" % [_flower_name(fid), GameState.seed_inventory[fid]]
		btn.custom_minimum_size = Vector2(300, 35)
		var flower_id = fid
		var idx = slot_index
		btn.pressed.connect(func():
			GreenhouseSystem.plant_seed(idx, flower_id)
			_refresh_slots()
			_refresh_ui()
		)
		_slots_container.add_child(btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(300, 35)
	cancel_btn.pressed.connect(func(): _refresh_slots())
	_slots_container.add_child(cancel_btn)


func _flower_name(fid: String) -> String:
	var flower = ContentDB.get_flower(fid)
	return flower.display_name if flower else fid


func _refresh_ui() -> void:
	var inv := GameState.get_inventory_array()
	if inv.size() == 0:
		_inventory_label.text = "Inventory: (empty)"
	else:
		var text := "Inventory:\n"
		for item in inv:
			var flower = ContentDB.get_flower(item.id)
			var name_str = flower.display_name if flower else item.id
			text += "  %s x%d\n" % [name_str, item.quantity]
		_inventory_label.text = text
	_go_to_shop_button.disabled = false
	_money_label.text = "Coins: %d" % GameState.money
	_refresh_slots()


func _on_go_to_shop() -> void:
	SceneRouter.go_to_shop_counter()


func _on_go_to_bed() -> void:
	SceneRouter.go_to_bed_hub()
