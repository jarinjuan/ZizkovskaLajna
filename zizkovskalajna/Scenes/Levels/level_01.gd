extends Node2D

var brain_instructions = "Kill them. Kill them all."
var tutorial_message = "Move using WASD. Turn around using your mouse. Shoot using left mouse button."
var enemy_dead_sentence = "Peter, what the fuck are you doing?!"
var x = 0

func _ready():
	await Ui.dialog_setup()
	await Ui.start_dialog(tutorial_message, "transmitter")
	await Ui.start_dialog(brain_instructions, "sprite_brain")
	
func _on_enemy_enemy_died() -> void:
	while (x < 1):
		Ui.start_dialog(enemy_dead_sentence, "transmitter")
		x += 1
