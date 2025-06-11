extends Node2D

var tutorial_message = "Dog."

func _process(delta: float) -> void:
	Ui.start_dialog(tutorial_message, "transmitter")
