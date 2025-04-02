extends CharacterBody2D

@onready var player = get_node("../Player")  
const SPEED: int = 75 

func _process(delta: float) -> void:
	var direction: Vector2 = (player.position - position).normalized() 
	if direction.length() > 0:  
		position += direction * SPEED * delta  
		
		
