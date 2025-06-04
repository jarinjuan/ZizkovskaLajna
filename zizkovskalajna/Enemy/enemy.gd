extends CharacterBody2D

@export var weapon_scene: PackedScene

@onready var player = get_node("../Player")
@onready var alive_sprite = $AliveSprite 
@onready var dead_sprite = $DeadSprite
@onready var knocked_sprite = $KnockedSprite
@onready var ray_cast = $RayCast2D
@onready var nav_agent = $NavAgent
@onready var weapon_socket = $WeaponSocket
var target_pickup: Node2D = null
var is_dead := false
var current_weapon: Weapon = null
var player_visible: bool = false
var last_seen_position: Vector2 = Vector2.ZERO
var can_fire = true
var has_weapon: bool = false
var current_weapon_scale: Vector2
const SPEED: int = 100
const RUN_AWAY_DISTANCE: float = 50.0  
const DISTANCE_MARGIN: float = 5.0 
var home_position: Vector2
var lost_sight_timer := 0.0
const RETURN_HOME_TIME: float = 5.0
var returning_home := false

var reaction_timer := 0.0
const REACTION_TIME := 0.5
var player_spotted := false

func _ready():
	dead_sprite.visible = false
	knocked_sprite.visible = false
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

func drop_weapon():
	if has_weapon:
		var dropped = preload("res://Weapons/Pickup/WeaponPickup.tscn").instantiate()
		dropped.global_position = weapon_socket.global_position
		dropped.weapon_scene = load(current_weapon.scene_file_path)
		
		var sprite_node = current_weapon.get_node_or_null("Sprite2D")
		if sprite_node:
			dropped.weapon_texture = sprite_node.texture
			dropped.texture_scale = sprite_node.scale 
		
		dropped.ammo_count = current_weapon.ammo
		
		get_tree().current_scene.add_child(dropped)
		current_weapon.queue_free()
		current_weapon = null
		has_weapon = false

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
	if is_dead:
		return
	_aim()
	update_visibility()

	# Vyhledání nejbližší zbraně, pokud ji nemáme
	if not has_weapon and target_pickup == null:
		var closest_pickup = null
		var closest_dist = INF
		for pickup in get_tree().get_nodes_in_group("weapon_pickup"):			
			var dist = pickup.global_position.distance_to(global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_pickup = pickup
		if closest_pickup:
			target_pickup = closest_pickup
			nav_agent.set_target_position(target_pickup.global_position)

	# PRIORITA: Pickup režim → nic jiného neřešíme
	if not has_weapon and target_pickup:
		if nav_agent.get_target_position() != target_pickup.global_position:
			nav_agent.set_target_position(target_pickup.global_position)

		if not nav_agent.is_navigation_finished():
			var to_pickup = nav_agent.get_next_path_position() - global_position
			velocity = to_pickup.normalized() * SPEED
			move_and_slide()
			return
		else:
			if global_position.distance_to(target_pickup.global_position) <= 20.0:
				equip_weapon(target_pickup.weapon_scene)
				target_pickup.queue_free()
				target_pickup = null
				has_weapon = true
			return

	# --- Normální AI logika ---
	var to_player: Vector2 = player.global_position - global_position
	var distance_to_player: float = to_player.length()
	var direction: Vector2 = Vector2.ZERO

	if player_visible:
		look_at(player.global_position)
	elif not returning_home and last_seen_position != Vector2.ZERO:
		look_at(last_seen_position)
	elif returning_home:
		look_at(home_position)

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

func knock_down():
	if is_dead:
		return
	alive_sprite.visible = false
	knocked_sprite.visible = true
	drop_weapon()	
	set_process(false)
	set_physics_process(false)
	velocity = Vector2.ZERO
	move_and_slide()
	if has_node("AIController"):
		$AIController.set_active(false)
	await get_tree().create_timer(2).timeout
	if is_dead:
		return
	set_process(true)
	set_physics_process(true)
	if has_node("AIController"):
		$AIController.set_active(true)
	alive_sprite.visible = true
	knocked_sprite.visible = false

func die():
	if is_dead:
		return
	alive_sprite.visible = false
	knocked_sprite.visible = false
	dead_sprite.visible = true
	dead_sprite.z_index = -1
	is_dead = true
	if has_weapon:
		drop_weapon()
	set_process(false)
	set_physics_process(false)
	$CollisionShape2D.queue_free()
	remove_from_group("enemy")
