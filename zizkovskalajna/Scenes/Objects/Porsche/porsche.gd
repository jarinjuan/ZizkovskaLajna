extends Area2D

@export var level_controller_path: NodePath

var level_controller: Node
signal level_finished

var door_opened := false

func _ready():
	level_controller = get_node(level_controller_path)
	$PorscheDoor.stop()
	$PorscheDoor.frame = 0  
	

func _on_body_entered(body):
	if body.is_in_group("player"):
		if level_controller.all_enemies_dead:
			$PorscheDoor.play("openDoor")
			await get_tree().create_timer(1.0).timeout
			emit_signal("level_finished")
		else:
			print("Dodelej praci")
