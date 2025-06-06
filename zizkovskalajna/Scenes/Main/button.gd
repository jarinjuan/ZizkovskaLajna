extends Button

@onready var music_player = $"../AudioStreamPlayer2D"
var playbackPosition = 0


func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
			playbackPosition = music_player.get_playback_position()
			music_player.stop()			
	else:
			music_player.play(playbackPosition)
