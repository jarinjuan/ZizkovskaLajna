extends Node2D

var brain_instructions = "We are not human anymore. We are simply a democracy tool."
var player_response = "There has to be other option than to just kill everybody. I haven't slept for three days straight. I can't stop seeing their faces, even though I know they were bad people. We have to stop."
var brain_instructions2 = "Stop? You *hesitate* now? After all the blood, after all the justice we've delivered? You knew the price. You knodddddddw what they did. Their screams mean nothing — they're echoes of a dying regime. And now you want mercy? Pathetic. Pick up the gun. Do what's necessary."
var x = 0

func _ready():
	await Ui.dialog_setup()
	await Ui.start_dialog(brain_instructions, "sprite_brain")
	await Ui.start_dialog(player_response, "sprite_player_dialogue")
	await Ui.start_dialog(brain_instructions2, "sprite_brain")
