extends Node

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	add_child(_music_player)


func play_music(_scene_name: String) -> void:
	pass


func stop_music() -> void:
	_music_player.stop()


func play_sfx(_sfx_name: String) -> void:
	pass
