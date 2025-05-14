extends CharacterBody2D
@export var fire_rate = 0.2;
var bullet_speed = 1000
const SPEED: int = 200
var current_weapon = null 
var weapon_equipped = false
var bullet = preload("res://bullet.tscn")
var can_fire = true



func _physics_process(delta: float) -> void:
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

func pick_up_weapon(weapon):
	current_weapon = weapon.weapon_name
	weapon_equipped = true
	print("zvednuto: " + current_weapon) #kontrola jak to de
	print(weapon_equipped)

func _process(delta):
	rotate(get_angle_to(get_global_mouse_position()))

	if weapon_equipped and Input.is_action_pressed("fire") and can_fire:
		var bullet_instance = bullet.instantiate()
		bullet_instance.position = $BulletPoint.get_global_position()
		var direction_to_mouse = (get_global_mouse_position() - bullet_instance.position).normalized()
		bullet_instance.rotation = direction_to_mouse.angle()
		get_tree().get_root().add_child(bullet_instance)
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true
