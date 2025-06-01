# m4.gd
extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle = $Muzzle

func shoot(target_pos: Vector2) -> void:
	if !can_fire or ammo <= 0:
		return

	var bullet = bullet_scene.instantiate()
	bullet.position = muzzle.global_position
	bullet.rotation = (target_pos - bullet.position).angle()
	bullet.shooter = weapon_owner
	get_tree().root.add_child(bullet)

	ammo -= 1
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
