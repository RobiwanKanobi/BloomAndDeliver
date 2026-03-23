extends Control

@onready var _title_label: Label = $VBoxContainer/TitleLabel
@onready var _summary_label: Label = $VBoxContainer/SummaryPanel/SummaryLabel
@onready var _end_day_button: Button = $VBoxContainer/ButtonRow/EndDayButton
@onready var _continue_button: Button = $VBoxContainer/ButtonRow/ContinueButton
@onready var _upgrades_button: Button = $VBoxContainer/ButtonRow/UpgradesButton


func _ready() -> void:
	_end_day_button.pressed.connect(_on_end_day)
	_continue_button.pressed.connect(_on_continue)
	_upgrades_button.pressed.connect(_on_upgrades)
	_continue_button.visible = false
	_display_summary()

	if GameState.is_game_complete():
		_title_label.text = "Congratulations!"


func _display_summary() -> void:
	var summary := GameState.get_daily_summary()
	_title_label.text = "End of Day %d" % summary.day
	var text := ""
	text += "Flowers collected: %d\n" % summary.flowers_collected
	text += "Deliveries completed: %d\n" % summary.deliveries_completed
	text += "Money earned today: %d coins\n" % summary.money_earned
	text += "Reputation gained: %d\n" % summary.reputation_gained
	text += "\n"
	text += "Total money: %d coins\n" % summary.total_money
	text += "Total reputation: %d\n" % summary.total_reputation
	text += "Total deliveries: %d\n" % summary.total_deliveries
	text += "\nPhase: %d/3" % summary.phase

	if GameState.is_game_complete():
		text += "\n\nYou have completed the story!"
		text += "\nThe village celebration was a success."
		text += "\nThank you for playing Bloom & Deliver!"

	_summary_label.text = text


func _on_end_day() -> void:
	SaveManager.save_game()
	_end_day_button.visible = false
	_continue_button.visible = true
	_summary_label.text += "\nProgress saved!"


func _on_continue() -> void:
	GameState.reset_for_new_day()
	SceneRouter.go_to_greenhouse()


func _on_upgrades() -> void:
	SceneRouter.go_to_upgrades()
