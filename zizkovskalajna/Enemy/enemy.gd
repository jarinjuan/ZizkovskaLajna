extends CharacterBody2D

@export var fire_rate = 0.2;
@onready var player = get_node("../Player")
@onready var alive_sprite = $AliveSprite 
@onready var dead_sprite = $DeadSprite
@onready var ray_cast = $RayCast2D
@onready var nav_agent = $NavAgent
var bullet = preload("res://Enemy/enemy_bullet.tscn")
var player_visible: bool = false
var last_seen_position: Vector2 = Vector2.ZERO
var can_fire = true
const SPEED: int = 100
const RUN_AWAY_DISTANCE: float = 50.0  
const DISTANCE_MARGIN: float = 5.0 
var home_position: Vector2
var lost_sight_timer := 0.0
const RETURN_HOME_TIME: float = 5.0
var returning_home := false


var has_weapon: bool = true #pokud ma zbran tak bezi k hraci, pokud ne tak si udrzuje vzdalenost 70px od hrace a utika od/k nemu

func _ready():
	dead_sprite.visible = false
	home_position = global_position
	
	
func _aim():
	if player:
		ray_cast.target_position = to_local(player.global_position)
		ray_cast.force_raycast_update()
	
func shoot_at_player():
	
	if has_weapon and can_fire and player_visible:
		var bullet_instance = bullet.instantiate()
		bullet_instance.position = $BulletPoint.get_global_position()
		bullet_instance.rotation = (player.global_position - bullet_instance.position).angle()
		get_tree().get_root().add_child(bullet_instance)
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true

	

	
func update_visibility():
	if not ray_cast:
		player_visible = false
		return

	ray_cast.target_position = to_local(player.global_position)
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		var hit = ray_cast.get_collider()
		player_visible = (hit == player)
	else:
		player_visible = false

func _physics_process(delta: float) -> void:
	_aim()
	update_visibility()

	var to_player: Vector2 = player.global_position - global_position
	var distance_to_player: float = to_player.length()
	var direction: Vector2 = Vector2.ZERO

	if player_visible:
		last_seen_position = player.global_position
		lost_sight_timer = 0.0
		returning_home = false
		if has_weapon:
			direction = to_player.normalized()
			shoot_at_player()
		else:
			if distance_to_player < RUN_AWAY_DISTANCE - DISTANCE_MARGIN:
				direction = (-to_player).normalized()
			elif distance_to_player > RUN_AWAY_DISTANCE + DISTANCE_MARGIN:
				direction = to_player.normalized()
	else:
		lost_sight_timer += delta
	if lost_sight_timer >= RETURN_HOME_TIME:
		returning_home = true

	if returning_home:
		if nav_agent.get_target_position() != home_position:
			nav_agent.set_target_position(home_position)

		if not nav_agent.is_navigation_finished():
			var to_home = nav_agent.get_next_path_position() - global_position
			direction = to_home.normalized()
		else:
			direction = Vector2.ZERO
	else:
		if last_seen_position != Vector2.ZERO:
			if nav_agent.get_target_position() != last_seen_position:
				nav_agent.set_target_position(last_seen_position)

			if not nav_agent.is_navigation_finished():
				var next_path_pos = nav_agent.get_next_path_position()
				direction = (next_path_pos - global_position).normalized()
			else:
				direction = Vector2.ZERO
				returning_home = false
				last_seen_position = Vector2.ZERO

	velocity = direction * SPEED
	move_and_slide()
	
		
func die():
	alive_sprite.visible = false
	dead_sprite.visible = true
	dead_sprite.z_index = -1
	set_process(false)
	set_physics_process(false)
	$CollisionShape2D.queue_free()
