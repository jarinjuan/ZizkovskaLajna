extends Area2D

@export var weapon_scene: PackedScene
@export var weapon_texture: Texture2D
@export var texture_scale: Vector2 = Vector2.ONE
@export var ammo_count: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


var has_hit := false
var velocity = Vector2.ZERO
var start_position = Vector2.ZERO
var max_distance = 100  # vzdálenost, kterou zbraň max doletí

func _ready():
	sprite.texture = weapon_texture
	sprite.scale = texture_scale
	start_position = global_position


	await get_tree().create_timer(0.5).timeout
	spawn_pickup_and_die()
	
func _process(delta):
	if velocity != Vector2.ZERO:
		global_position += velocity * delta
		if global_position.distance_to(start_position) >= max_distance:
			velocity = Vector2.ZERO
			spawn_pickup_and_die()
			

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body: Node):
	if has_hit:
		return
	has_hit = true

	if body.is_in_group("enemy") and body.has_method("knock_down"):
		body.knock_down()
	elif !body.is_in_group("enemy"):
			if body.has_method("break_glass"):
				body.break_glass()
	spawn_pickup_and_die()

func spawn_pickup_and_die():
	if not is_inside_tree():
		return
	var pickup = preload("res://Weapons/Pickup/WeaponPickup.tscn").instantiate()
	pickup.global_position = global_position
	pickup.weapon_scene = weapon_scene
	pickup.weapon_texture = weapon_texture
	pickup.texture_scale = texture_scale
	pickup.ammo_count = ammo_count
	get_tree().current_scene.add_child(pickup)
	queue_free()
