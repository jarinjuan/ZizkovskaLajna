extends Button




func _on_button_exit_pressed() -> void:
	GameManager.quit_game()

func _on_button_mute_toggled(toggled_on: bool) -> void:
	Audio.bus_toggle_mute("Music")


func _on_button_options_pressed() -> void:
	pass # Replace with function body.


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level Selector/level_selector.tscn")
