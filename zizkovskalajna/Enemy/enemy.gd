extends CharacterBody2D

@export var weapon_scene: PackedScene
signal enemy_died
@onready var player = get_node("../Player")

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
var is_onehit = false
var reaction_timer := 0.0
const REACTION_TIME := 0.5
var player_spotted := false
@export var walking_enemy := false
@export var patrol_points: Array[Node2D] = []
var patrol_index := 0
var is_patrolling := true

const SPEED_PATROL := 60
const SPEED_RETURN := 70
const SPEED_COMBAT := 120
const PATROL_PAUSE_TIME := 1.0
var patrol_pause_timer := 0.0
var waiting_at_patrol := false

var blood_textures := [
	preload("res://Assets/Sprites/Objects/Blood/blood1.png"),
	preload("res://Assets/Sprites/Objects/Blood/blood2.png"),
	preload("res://Assets/Sprites/Objects/Blood/blood3.png")
]

func _ready():
	home_position = global_position
	add_to_group("characters")
	add_to_group("enemy")
	$Enemy_M4.visible = false
	$Enemy_Pistol.visible = false
	$Enemy_Uzi.visible = false
	$Enemy_Shotgun.visible = false
	$Enemy_Unarmed.visible = true
	$Enemy_Knocked.visible = false
	$Enemy_Dead.visible = false
	$Enemy_Bbat.visible = false
	$AliveShape.disabled = false
	$KnockedShape.disabled = true
	if walking_enemy and patrol_points.is_empty():
		patrol_points = []
		for node in get_tree().get_nodes_in_group("enemy_patrol_point"):
			if node is Node2D:
				patrol_points.append(node)
	

	if weapon_scene:
		equip_weapon(weapon_scene)

func removeSprites():
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			child.visible = false

func update_weapon_sprite(weapon_name: String) -> void:
	removeSprites()
	
	var sprite_name = "Enemy_" + capitalize_first(weapon_name)
	var sprite = get_node_or_null(sprite_name)
	if sprite:
		sprite.visible = true
	else:
		print("Sprite ", sprite_name, " nebyl nalezen!")
		
func capitalize_first(text: String) -> String:
	if text.length() == 0:
		return text
	return text[0].to_upper() + text.substr(1)

func spawn_blood_splatter(pos: Vector2, min: int, max: int) -> void:
	var count = randi_range(min, max)

	for i in count:
		var stain = Sprite2D.new()
		stain.texture = blood_textures[randi() % blood_textures.size()]
		
		var offset_radius = randf_range(20.0, 70.0)  
		var offset_angle = randf() * TAU
		var offset = Vector2.RIGHT.rotated(offset_angle) * offset_radius

		stain.position = pos + offset
		stain.rotation = randf() * TAU
		stain.scale = Vector2.ONE * 2 
		stain.z_index = -1
		get_tree().current_scene.add_child(stain)



func equip_weapon(weapon_packed: PackedScene):
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = weapon_packed.instantiate() as Weapon
	current_weapon.weapon_owner = self
	weapon_socket.add_child(current_weapon)
	var weapon_name = weapon_packed.resource_path.get_file().get_basename().to_lower()
	update_weapon_sprite(weapon_name)
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
		
func get_muzzle_position() -> Vector2:
	for child in get_children():
		if child is Sprite2D and child.visible:
			var muzzle := child.get_node_or_null("Muzzle")
			
			if muzzle:
				return muzzle.global_position
	return global_position  # fallback pro jistotu

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
		
		if distance_to_player < 20:
			velocity = Vector2.ZERO
			move_and_slide()

		if has_weapon:
			direction = to_player.normalized()
			if reaction_timer >= REACTION_TIME:
				shoot_at_player()

		else:
			if distance_to_player < RUN_AWAY_DISTANCE - DISTANCE_MARGIN:
				var run_away_vector = (global_position - player.global_position).normalized()
				var flee_target = global_position + run_away_vector * 300
				if nav_agent.get_target_position() != flee_target:
					nav_agent.set_target_position(flee_target)

				if not nav_agent.is_navigation_finished():
					var flee_direction = (nav_agent.get_next_path_position() - global_position).normalized()
					direction = flee_direction
			else:
				direction = (-to_player).normalized()

	else:
		player_spotted = false
		reaction_timer = 0.0

		if last_seen_position != Vector2.ZERO:
			lost_sight_timer += delta
			if lost_sight_timer >= RETURN_HOME_TIME:
				returning_home = true
		else:
			lost_sight_timer = 0.0  # reset když nikdy neviděl hráčee

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
				
	if not player_visible and walking_enemy and is_patrolling and not returning_home and last_seen_position == Vector2.ZERO and has_weapon:
		if patrol_points.size() > 0:
			var patrol_target = patrol_points[patrol_index].global_position

			if global_position.distance_to(patrol_target) < 10.0 or nav_agent.is_navigation_finished():
				if not waiting_at_patrol:
					waiting_at_patrol = true
					patrol_pause_timer = PATROL_PAUSE_TIME
				else:
					patrol_pause_timer -= delta
					if patrol_pause_timer <= 0:
						patrol_index = (patrol_index + 1) % patrol_points.size()
						patrol_target = patrol_points[patrol_index].global_position
						nav_agent.set_target_position(patrol_target)
						waiting_at_patrol = false
						
			if not waiting_at_patrol:			
				if nav_agent.get_target_position() != patrol_target:
					nav_agent.set_target_position(patrol_target)
				look_at(patrol_target)
			# Ujisti se, že nav_agent má správný cíl
				
				

	var current_speed = SPEED

	if not has_weapon and target_pickup:
		current_speed = SPEED_COMBAT
	elif player_visible or last_seen_position != Vector2.ZERO:
		current_speed = SPEED_COMBAT
	elif returning_home:
		current_speed = SPEED_RETURN
	elif walking_enemy and is_patrolling:
		current_speed = SPEED_PATROL
				
	if not nav_agent.is_navigation_finished():
		var next_path_pos = nav_agent.get_next_path_position()
		if not has_weapon and target_pickup == null and player_visible:
			var run_away_vector = (global_position - player.global_position).normalized()
			var random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(50, 150) 
			var flee_target = global_position + run_away_vector * 300 + random_offset
			if nav_agent.get_target_position() != flee_target:
				nav_agent.set_target_position(flee_target)


		if not nav_agent.is_navigation_finished():
			if global_position.distance_to(player.global_position) <= 50.0:
				velocity = Vector2.ZERO
			else:
				var to_flee = nav_agent.get_next_path_position() - global_position
				direction = to_flee.normalized()
				velocity = direction * current_speed
			
			move_and_slide()
			return


	velocity = direction * current_speed
	move_and_slide()
	


func knock_down():
	if is_dead:
		return
	removeSprites()
	$Enemy_Knocked.visible = true
	$AliveShape.disabled = true
	$KnockedShape.disabled = false
	is_onehit = true
	spawn_blood_splatter(global_position, 2, 5)
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
	removeSprites()
	$Enemy_Unarmed.visible = true
	$AliveShape.disabled = false
	$KnockedShape.disabled = true
	
func get_punched():
	if is_dead:
		return
	if is_onehit == true:
		die()
	else:
		removeSprites()
		$Enemy_Knocked.visible = true
		$AliveShape.disabled = true
		$KnockedShape.disabled = false
		is_onehit = true
		spawn_blood_splatter(global_position, 2, 5)
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
		removeSprites()
		$Enemy_Unarmed.visible = true
		$AliveShape.disabled = false
		$KnockedShape.disabled = true

func die():
	if is_dead:
		return
	removeSprites()
	$Enemy_Dead.visible = true
	$Enemy_Dead.z_index = -1
	spawn_blood_splatter(global_position, 3, 8)
	is_dead = true
	if has_weapon:
		drop_weapon()
	set_process(false)
	set_physics_process(false)
	$AliveShape.disabled = true
	$KnockedShape.disabled = true
	$AliveShape.queue_free()
	$KnockedShape.queue_free()
	enemy_died.emit()
	remove_from_group("enemy")
