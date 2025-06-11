extends Node2D

var tutorial_message = "Dog."

#func _process(delta: float) -> void:
	#Ui.start_dialog(tutorial_message, "transmitter")
	

func _ready():
	await Ui.dialog_setup()
	Ui.start_dialog(tutorial_message, "demo")

func _on_enemy_enemy_died() -> void:
	Ui.start_dialog(tutorial_message, "demo")
