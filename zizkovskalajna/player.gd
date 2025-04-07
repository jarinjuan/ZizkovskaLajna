extends CharacterBody2D

const SPEED: int = 200
var current_weapon = null 

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
	print("zvednuto: " + current_weapon) #kontrola jak to de
