extends Button




func _on_button_exit_pressed() -> void:
	GameManager.quit_game()

func _on_button_mute_toggled(toggled_on: bool) -> void:
	Audio.bus_toggle_mute("Music")


func _on_button_options_pressed() -> void:
	GameManager.last_scene = "res://Scenes/Main/control.tscn"
	get_tree().change_scene_to_file("res://Scenes/Settings/settings.tscn")


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level Selector/level_selector.tscn")
