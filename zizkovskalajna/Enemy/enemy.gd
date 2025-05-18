extends CharacterBody2D

@onready var player = get_node("../Player")
@onready var alive_sprite = $AliveSprite 
@onready var dead_sprite = $DeadSprite
const SPEED: int = 100
const RUN_AWAY_DISTANCE: float = 50.0  
const DISTANCE_MARGIN: float = 5.0 

var has_weapon: bool = false #pokud ma zbran tak bezi k hraci, pokud ne tak si udrzuje vzdalenost 70px od hrace a utika od/k nemu

func _ready():
	dead_sprite.visible = false

func _physics_process(delta: float) -> void:
	var to_player: Vector2 = player.position - position
	var distance_to_player: float = to_player.length()
	var direction: Vector2 = Vector2.ZERO

	if has_weapon:
		direction = to_player.normalized()
	else:
		if distance_to_player < RUN_AWAY_DISTANCE - DISTANCE_MARGIN:
			direction = (-to_player).normalized()
		elif distance_to_player > RUN_AWAY_DISTANCE + DISTANCE_MARGIN:
			direction = to_player.normalized()
		else:
			direction = Vector2.ZERO

	if direction.length() < 0.01:
		direction = Vector2.ZERO

	var velocity = direction * SPEED

	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider() == player:
		velocity = Vector2.ZERO
		
		
func die():

	alive_sprite.visible = false
	dead_sprite.visible = true
	dead_sprite.z_index = -1
	set_process(false)
	set_physics_process(false)
	$CollisionShape2D.queue_free()
