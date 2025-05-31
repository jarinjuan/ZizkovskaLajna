extends CanvasLayer

var is_active := false

func _ready():
	visible = false



func show_wasted():
	visible = true
	is_active = true
	get_tree().paused = true

func _input(event):
	if is_active:
		if event is InputEventMouseButton:
			if event.pressed:
				get_tree().paused = false
				is_active = false
				visible = false
				get_tree().reload_current_scene()

		if event is InputEventKey:
			if event.pressed:
				get_tree().paused = false
				is_active = false
				visible = false
				get_tree().reload_current_scene()
