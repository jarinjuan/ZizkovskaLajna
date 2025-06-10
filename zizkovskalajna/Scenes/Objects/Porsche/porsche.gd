extends Area2D

@export var level_controller_path: NodePath
var level_controller: Node
signal level_finished

func _ready():
	level_controller = get_node(level_controller_path)

func _on_body_entered(body):
	if body.is_in_group("player"):
		
		if level_controller.all_enemies_dead:
			emit_signal("level_finished")
		else:
			print("Dodelej praci")
