extends CanvasLayer



func _on_skip_button_pressed() -> void:
	GameManager.skip_dialog = true
	Ui.close_dialog()
