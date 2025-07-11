extends CanvasLayer

@onready var time_display_label: Label = $LabelTime

var next_level = GameManager.current_level + 1

func _ready():
	var elapsed_time = GameManager.get_last_level_time()
	if next_level == 4:
		$nextButton.disabled = true
		$tempText.visible = true
	else: $tempText.visible = false
		
	display_formatted_time(elapsed_time)
	Audio.stop_audio_stream(Audio.background_music)
	Audio.play_audio_stream(Audio.lvlc_music)


func display_formatted_time(time_in_seconds: float):
	var minutes = int(time_in_seconds / 60)
	var seconds = fmod(time_in_seconds, 60)
	var milliseconds = int(fmod(time_in_seconds * 1000, 1000))
	time_display_label.text = "Time: %02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_next_button_pressed() -> void:
	if GameManager.max_unlocked_level >= next_level:
		var next_level_path = "res://Scenes/Levels/level_%02d.tscn" % next_level
		if next_level_path:
			Audio.stop_audio_stream(Audio.lvlc_music)
			Audio.play_audio_stream(Audio.background_music)
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("Next level not found: ", next_level_path)
	else:
		print(GameManager.max_unlocked_level)
		print(next_level)


func _on_exit_button_pressed() -> void:
	GameManager.skip_dialog = false
	Ui.close_ammo()
	Audio.play_audio_stream(Audio.background_music)
	Audio.stop_audio_stream(Audio.lvlc_music)
	get_tree().change_scene_to_file("res://Scenes/Main/control.tscn")
