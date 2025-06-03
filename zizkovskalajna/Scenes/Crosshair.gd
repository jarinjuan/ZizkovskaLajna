extends Node2D 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	$Crosshair.position = get_global_mouse_position()
