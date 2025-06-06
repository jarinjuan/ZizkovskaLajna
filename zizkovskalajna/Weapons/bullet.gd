extends Area2D
class_name Bullet

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO
var shooter: Node = null  # např. hráč nebo enemy

# Blood textures
var blood_textures := [
	preload("res://Assets/Sprites/Objects/Blood/blood1.png"),
	preload("res://Assets/Sprites/Objects/Blood/blood2.png"),
	preload("res://Assets/Sprites/Objects/Blood/blood3.png")
]

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if not shooter:
		return

	var is_player = shooter.is_in_group("player")
	var is_enemy = shooter.is_in_group("enemy")

	if is_player and body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		spawn_blood_splatter(global_position)
		queue_free()

	elif is_enemy and body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		spawn_blood_splatter(global_position)
		queue_free()

	elif not body.is_in_group("player") and not body.is_in_group("enemy"):
		if body.has_method("break_glass"):
			body.break_glass()
		queue_free()

func spawn_blood_splatter(pos: Vector2) -> void:
	var count = randi_range(6, 12)
	for i in count:
		var stain = Sprite2D.new()
		stain.texture = blood_textures[randi() % blood_textures.size()]
		
		var offset_radius = randf_range(20.0, 70.0)  # větší rozptyl
		var offset_angle = randf() * TAU
		var offset = Vector2.RIGHT.rotated(offset_angle) * offset_radius

		stain.position = pos + offset
		stain.rotation = randf() * TAU
		stain.scale = Vector2.ONE * 2 # větší velikost
		stain.z_index = -1
		get_tree().current_scene.add_child(stain)
