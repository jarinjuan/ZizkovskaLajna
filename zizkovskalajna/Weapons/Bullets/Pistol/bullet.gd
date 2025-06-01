extends Area2D

@export var speed = 500
@export var direction := Vector2.RIGHT
var shooter: Node = null  # <- kdo střelil (hráč nebo enemy)

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	print("X")
	# Pokud střelu vystřelil hráč
	if shooter and shooter.is_in_group("player"):
		if body.is_in_group("enemy"):
			if body.has_method("die"):
				body.die()
				
			queue_free()
		elif !body.is_in_group("player"):  # zasáhlo něco jiného
			if body.has_method("break_glass"):
				body.break_glass()
			queue_free()

	# Pokud střelu vystřelil enemy
	elif shooter and shooter.is_in_group("enemy"):
		if body.is_in_group("player"):
			if body.has_method("die"):
				body.die()
			queue_free()
		elif !body.is_in_group("enemy"):
			if body.has_method("break_glass"):
				body.break_glass()
			queue_free()
