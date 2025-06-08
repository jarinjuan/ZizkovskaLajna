extends CharacterBody2D

@export var fire_rate = 0.1
@export var weapon_pickup_scene: PackedScene 
const SPEED: int = 200

@onready var weapon_socket = $WeaponSocket
@onready var death_screen := $DeathScreen
@onready var fists_scene: PackedScene = preload("res://Weapons/Melee/fists.tscn")

var current_weapon: Node = null  # může být Weapon nebo MeleeWeapon
var current_weapon_scale: Vector2
var current_weapon_bullets: int
var weapon_equipped := false
var fists: MeleeWeapon = null
var is_waiting_for_restart := false


func _ready():
	Engine.time_scale = 1
	fists = fists_scene.instantiate()
	fists.weapon_owner = self
	weapon_socket.add_child(fists)
	current_weapon = fists
	weapon_equipped = false


func _physics_process(delta: float) -> void:
	var movement := Vector2.ZERO
	if Input.is_action_pressed("move_right"): movement.x += 2
	if Input.is_action_pressed("move_left"): movement.x -= 2
	if Input.is_action_pressed("move_down"): movement.y += 2
	if Input.is_action_pressed("move_up"): movement.y -= 2

	if movement.length() > 0:
		movement = movement.normalized()
		velocity = movement * SPEED
		move_and_slide()

		# animace
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.position = $AnimatedSprite2D.position.round()
		
	else:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0  # idle frame

	
func _process(delta: float) -> void:
	rotate(get_angle_to(get_global_mouse_position()))

	if not current_weapon == fists:
		if weapon_equipped:			
			if Input.is_action_pressed("fire"):
				if current_weapon.has_method("shoot"):
					current_weapon.shoot(get_global_mouse_position())
					GameManager.ammo = current_weapon.ammo
					Ui.update_bullet_ui()
				elif current_weapon.has_method("swing"):
					current_weapon.swing()
			elif Input.is_action_just_pressed("mouse_right"): 
				throw_weapon()
	elif Input.is_action_pressed("fire") and current_weapon == fists:
		current_weapon.punch()
		
		


func drop_weapon():
	if current_weapon and current_weapon != fists and weapon_pickup_scene:
		var dropped = weapon_pickup_scene.instantiate()
		dropped.texture_scale = current_weapon_scale
		dropped.global_position = weapon_socket.global_position
		dropped.weapon_scene = load(current_weapon.scene_file_path)

		var sprite_node = current_weapon.get_node_or_null("Sprite2D")
		if sprite_node:
			dropped.weapon_texture = sprite_node.texture
			dropped.texture_scale = sprite_node.scale 
			if current_weapon.has_method("shoot"):
				dropped.ammo_count = current_weapon.ammo

		get_tree().current_scene.add_child(dropped)
		current_weapon.queue_free()

		current_weapon = null
		weapon_equipped = false
		
		Ui.close_ammo()



		current_weapon = fists
		fists.show()
		weapon_equipped = false


func throw_weapon():
	if current_weapon == null or current_weapon == fists:
		return
	
	var thrown_scene = preload("res://Weapons/Throw/throw.tscn").instantiate()
	thrown_scene.global_position = weapon_socket.global_position

	var direction = (get_global_mouse_position() - global_position).normalized()
	thrown_scene.velocity = direction * 600
	thrown_scene.rotation = direction.angle()

	var sprite_node = current_weapon.get_node_or_null("Sprite2D")
	if sprite_node:
		thrown_scene.weapon_texture = sprite_node.texture
		thrown_scene.texture_scale = sprite_node.scale

	thrown_scene.weapon_scene = load(current_weapon.scene_file_path)
	if current_weapon.has_method("shoot"):
		thrown_scene.ammo_count = current_weapon.ammo
	else:
		thrown_scene.ammo_count = 0
	
	get_tree().current_scene.add_child(thrown_scene)

	Ui.close_ammo()
	current_weapon.queue_free()
	current_weapon = fists
	fists.show()
	weapon_equipped = false



func pick_up_weapon(new_weapon_scene: PackedScene, new_weapon_scale: Vector2, new_weapon_ammo: int) -> void:
	if current_weapon and current_weapon != fists:
		drop_weapon()
	Ui.close_ammo()

	fists.hide()

	current_weapon = new_weapon_scene.instantiate()
	current_weapon.weapon_owner = self
	current_weapon_scale = new_weapon_scale


	if current_weapon.has_method("shoot"):
		current_weapon.ammo = new_weapon_ammo
		Ui.show_ammo()
		GameManager.ammo = current_weapon.ammo
		GameManager.original_ammo_count = current_weapon.original_ammo
		Ui.pick_up_bullet_ui()

	
	weapon_socket.add_child(current_weapon)
	weapon_equipped = true
	
	






func die():
	death_screen.show_wasted()
	Ui.close_ammo()
