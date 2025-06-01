extends CharacterBody2D

@export var weapon_scene: PackedScene

@onready var player = get_node("../Player")
@onready var alive_sprite = $AliveSprite 
@onready var dead_sprite = $DeadSprite
@onready var ray_cast = $RayCast2D
@onready var nav_agent = $NavAgent
@onready var weapon_socket = $WeaponSocket


var current_weapon: Weapon = null
var player_visible: bool = false
var last_seen_position: Vector2 = Vector2.ZERO
var can_fire = true
var has_weapon: bool = false

const SPEED: int = 100
const RUN_AWAY_DISTANCE: float = 50.0  
const DISTANCE_MARGIN: float = 5.0 
var home_position: Vector2
var lost_sight_timer := 0.0
const RETURN_HOME_TIME: float = 5.0
var returning_home := false

# --- ADDED ---
var reaction_timer := 0.0
const REACTION_TIME := 0.5
var player_spotted := false

func _ready():
	dead_sprite.visible = false
	home_position = global_position
	add_to_group("enemies")
	add_to_group("characters")
	add_to_group("enemy")

	if weapon_scene:
		equip_weapon(weapon_scene)


func equip_weapon(weapon_packed: PackedScene):
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = weapon_packed.instantiate() as Weapon
	current_weapon.weapon_owner = self
	weapon_socket.add_child(current_weapon)
	has_weapon = true


func _aim():
	if player:
		ray_cast.target_position = to_local(player.global_position)
		ray_cast.force_raycast_update()


func shoot_at_player():
	if has_weapon and can_fire and current_weapon:
		current_weapon.shoot(player.global_position)


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

	# --- ROTATION UPDATE ---
	if player_visible:
		look_at(player.global_position)
	elif not returning_home and last_seen_position != Vector2.ZERO:
		look_at(last_seen_position)
	elif returning_home:
		look_at(home_position)
	# ------------------------

	if player_visible:
		if not player_spotted:
			player_spotted = true
			reaction_timer = 0.0
		else:
			reaction_timer += delta

		last_seen_position = player.global_position
		lost_sight_timer = 0.0
		returning_home = false

		if has_weapon:
			direction = to_player.normalized()
			if reaction_timer >= REACTION_TIME:
				shoot_at_player()
		else:
			if distance_to_player < RUN_AWAY_DISTANCE - DISTANCE_MARGIN:
				direction = (-to_player).normalized()
			elif distance_to_player > RUN_AWAY_DISTANCE + DISTANCE_MARGIN:
				direction = to_player.normalized()
	else:
		player_spotted = false
		reaction_timer = 0.0
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
	remove_from_group("enemies")
