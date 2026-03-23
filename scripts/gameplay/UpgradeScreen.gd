extends Control

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _money_label: Label = $VBoxContainer/MoneyLabel
@onready var _upgrades_list: VBoxContainer = $VBoxContainer/ScrollContainer/UpgradesList
@onready var _back_button: Button = $VBoxContainer/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back)
	_refresh()


func _refresh() -> void:
	_title_label.text = "Upgrades"
	_money_label.text = "Coins: %d | Reputation: %d" % [GameState.money, GameState.reputation]

	for child in _upgrades_list.get_children():
		child.queue_free()

	var categories := ["greenhouse", "shop", "travel"]
	for cat in categories:
		var cat_label := Label.new()
		cat_label.text = "-- %s --" % cat.capitalize()
		cat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_upgrades_list.add_child(cat_label)

		for u in ContentDB.upgrades.values():
			if u.category != cat:
				continue
			var hbox := HBoxContainer.new()

			var info := Label.new()
			if u.id in GameState.purchased_upgrades:
				info.text = "%s [OWNED]" % u.display_name
			else:
				info.text = "%s - %d coins, %d rep" % [u.display_name, u.cost_money, u.cost_reputation]
				if u.description != "":
					info.text += "\n  %s" % u.description
			info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info.autowrap_mode = TextServer.AUTOWRAP_WORD
			hbox.add_child(info)

			if u.id not in GameState.purchased_upgrades:
				var buy_btn := Button.new()
				buy_btn.text = "Buy"
				buy_btn.custom_minimum_size = Vector2(80, 35)
				buy_btn.disabled = not UpgradeSystem.can_purchase(u.id)
				var uid = u.id
				buy_btn.pressed.connect(func():
					UpgradeSystem.purchase(uid)
					_refresh()
				)
				hbox.add_child(buy_btn)

			_upgrades_list.add_child(hbox)


func _on_back() -> void:
	SceneRouter.go_to_bed_hub()
