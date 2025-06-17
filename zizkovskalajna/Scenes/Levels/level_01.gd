extends Node2D

var brain_instructions = "Kill them. Kill them all."
var tutorial_message = "Move using WASD. Turn around using your mouse. Shoot using left mouse button."
var enemy_dead_sentence = "Peter, what the fuck are you doing?!"
var player_sentence = "What have I done?"
var x = 0

func _ready():
	await Ui.dialog_setup()
	await Ui.start_dialog(tutorial_message, "transmitter")
	await Ui.start_dialog(brain_instructions, "sprite_brain")
	
func _on_enemy_enemy_died() -> void:
	if (x == 0):
		Ui.start_dialog(enemy_dead_sentence, "sprite_enemy_dialogue")
	x += 1
	print(x)
	if (x == 9):
		Ui.start_dialog(player_sentence, "sprite_player_dialogue")
