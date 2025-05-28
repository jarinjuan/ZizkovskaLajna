var debug_dialog: Control  # or Popup, Window, etc.
var debug_scene = preload("res://UI/DebugDialog.tscn")

func _ready():
	debug_dialog = debug_scene.instantiate()
	add_child(debug_dialog)
	debug_dialog.visible = false  # Start hidden
