extends Area2D

@onready var player = get_node("../Player") 
const PICKUP_DISTANCE: float = 20.0  

var weapon_name: String = "pistol"  

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player: Vector2 = player.position - position
	var distance_to_player: float = to_player.length()

	if distance_to_player <= PICKUP_DISTANCE and Input.is_action_just_pressed("mouse_right"):
		if player.has_method("pick_up_weapon"):
			player.pick_up_weapon(self)
			queue_free()
