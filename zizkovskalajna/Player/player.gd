extends CharacterBody2D

@export var fire_rate = 0.1;
@export var weapon_pickup_scene: PackedScene 
@export var melee_range: float = 50.0
const SPEED: int = 200
@onready var weapon_socket = $WeaponSocket
var current_weapon: Weapon = null
var weapon_equipped := false

var can_fire = true
var is_waiting_for_restart := false
@onready var death_screen := $DeathScreen
var current_weapon_scale: Vector2
var current_weapon_bullets: int


func _ready():
	Engine.time_scale = 1

func _physics_process(delta: float) -> void: #movement

	var movement := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		movement.x += 2
	if Input.is_action_pressed("move_left"):
		movement.x -= 2
	if Input.is_action_pressed("move_down"):
		movement.y += 2
	if Input.is_action_pressed("move_up"):
		movement.y -= 2
	if movement.length() > 0:
		movement = movement.normalized()
	velocity = movement * SPEED
	move_and_slide()
	
func drop_weapon():
	if current_weapon and weapon_pickup_scene:
		
		var dropped = weapon_pickup_scene.instantiate()
		dropped.texture_scale = current_weapon_scale
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
		weapon_equipped = false



func throw_weapon():#not working
	if current_weapon:
		var thrown_weapon = current_weapon.duplicate() as Weapon
		thrown_weapon.weapon_owner = null
		thrown_weapon.global_position = weapon_socket.global_position

		var direction = (get_global_mouse_position() - global_position).normalized()
		thrown_weapon.rotation = direction.angle()

		var body = RigidBody2D.new()
		body.global_position = global_position
		body.linear_velocity = direction * 800 
		body.gravity_scale = 0
		body.add_child(thrown_weapon)

		get_tree().current_scene.add_child(body)

		current_weapon.queue_free()
		current_weapon = null
		weapon_equipped = false


func pick_up_weapon(new_weapon_scene: PackedScene, new_weapon_scale: Vector2, new_weapon_ammo: int) -> void:
	if current_weapon:
		if weapon_pickup_scene:
			var dropped = weapon_pickup_scene.instantiate()
			dropped.texture_scale = current_weapon_scale
			dropped.global_position = weapon_socket.global_position
			dropped.weapon_scene = load(current_weapon.scene_file_path)
		
			var sprite_node = current_weapon.get_node_or_null("Sprite2D")
			if sprite_node:
				dropped.weapon_texture = sprite_node.texture
				dropped.texture_scale = sprite_node.scale 
		
			dropped.ammo_count = current_weapon_bullets

			get_tree().root.add_child(dropped)

		current_weapon.queue_free()

	
	current_weapon = new_weapon_scene.instantiate() as Weapon
	current_weapon.weapon_owner = self
	var sprite_node = current_weapon.get_node_or_null("Sprite2D")
	current_weapon_scale = new_weapon_scale
	current_weapon.ammo = new_weapon_ammo
	weapon_socket.add_child(current_weapon)
	print(current_weapon.ammo)
	weapon_equipped = true


func _process(delta):
	rotate(get_angle_to(get_global_mouse_position()))

	if weapon_equipped and Input.is_action_pressed("fire") and current_weapon:
		current_weapon.shoot(get_global_mouse_position())

	elif weapon_equipped and Input.is_action_just_pressed("mouse_right"):
		drop_weapon()


	elif not weapon_equipped and Input.is_action_just_pressed("fire"):
		var things_to_smash = get_tree().get_nodes_in_group("glass")
		for thing in things_to_smash:
			if global_position.distance_to(thing.global_position) <= melee_range:
				if thing.has_method("break_glass"):
					thing.break_glass()
					

		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if global_position.distance_to(enemy.global_position) <= melee_range:
				if enemy.has_method("die"):
					enemy.die()


func die():
	death_screen.show_wasted()
