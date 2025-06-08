extends Area2D
class_name Bullet

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO
var shooter: Node = null  # např. hráč nebo enemy



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
		queue_free()

	elif is_enemy and body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
		queue_free()

	elif not body.is_in_group("player") and not body.is_in_group("enemy"):
		if body.has_method("break_glass"):
			body.break_glass()
		queue_free()
