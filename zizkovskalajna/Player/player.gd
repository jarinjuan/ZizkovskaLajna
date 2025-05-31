extends CharacterBody2D

@export var fire_rate = 0.1;

@export var melee_range: float = 50.0
@export var bullets = 30
var bullet_speed = 1000
const SPEED: int = 200
@onready var weapon_socket = $WeaponSocket
var current_weapon: Weapon = null
var weapon_equipped := false

var can_fire = true
var is_waiting_for_restart := false
@onready var death_screen := $DeathScreen


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


func pick_up_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()        # drop old gun
	current_weapon = weapon_scene.instantiate() as Weapon
	weapon_socket.add_child(current_weapon)
	weapon_equipped = true


func _process(delta):
	rotate(get_angle_to(get_global_mouse_position()))

	if weapon_equipped and Input.is_action_pressed("fire") and current_weapon:
		current_weapon.shoot(get_global_mouse_position())


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
