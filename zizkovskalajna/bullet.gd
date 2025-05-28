extends Area2D

@export var speed = 600
@export var direction := Vector2.RIGHT

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if !body.is_in_group("player"):
		if body.has_method("break_glass"):
			body.break_glass()

	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()

	queue_free()
