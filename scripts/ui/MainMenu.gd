extends Control

@onready var _new_game_button: Button = $VBoxContainer/NewGameButton
@onready var _continue_button: Button = $VBoxContainer/ContinueButton
@onready var _quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	_new_game_button.pressed.connect(_on_new_game)
	_continue_button.pressed.connect(_on_continue)
	_quit_button.pressed.connect(_on_quit)
	_continue_button.disabled = not SaveManager.has_save()


func _on_new_game() -> void:
	GameState.reset_for_new_game()
	SceneRouter.go_to_greenhouse()


func _on_continue() -> void:
	if SaveManager.load_game():
		SceneRouter.go_to_greenhouse()


func _on_quit() -> void:
	get_tree().quit()
