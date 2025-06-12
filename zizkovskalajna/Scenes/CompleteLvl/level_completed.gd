extends CanvasLayer

@onready var time_display_label: Label = $LabelTime

var next_level = GameManager.current_level + 1

func _ready():
		var elapsed_time = GameManager.get_last_level_time()

		display_formatted_time(elapsed_time)





func display_formatted_time(time_in_seconds: float):
	var minutes = int(time_in_seconds / 60)
	var seconds = fmod(time_in_seconds, 60)
	var milliseconds = int(fmod(time_in_seconds * 1000, 1000))
	time_display_label.text = "Time: %02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_next_button_pressed() -> void:
	if GameManager.max_unlocked_level >= next_level:
		var next_level_path = "res://Scenes/Levels/level_%02d.tscn" % next_level
		print(next_level_path)
		var file = FileAccess.open(next_level_path, FileAccess.READ)
		if file:
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("Next level not found: ", next_level_path)
	else:
		print(GameManager.max_unlocked_level)
		print(next_level)


func _on_exit_button_pressed() -> void:
	Ui.close_ammo()
	Audio.play_music() 
	get_tree().change_scene_to_file("res://Scenes/Main/control.tscn")
