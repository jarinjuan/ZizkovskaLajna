extends Node2D
class_name Weapon

@export var fire_rate: float = 0.3
@export var can_fire = true
var weapon_owner: Node = null

func shoot(target_pos: Vector2) -> void:
	pass
