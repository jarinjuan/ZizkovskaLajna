extends RigidBody2D
@export var speed = 600


func _ready():
	gravity_scale = 0
	linear_velocity = Vector2(speed, 0).rotated(rotation)


func _on_body_entered(body: Node) -> void:
	if !body.is_in_group("player"):
		queue_free()
