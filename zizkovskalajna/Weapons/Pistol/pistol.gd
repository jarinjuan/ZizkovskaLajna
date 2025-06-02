# pistol.gd
extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle = $Muzzle
@export var ammo: int

func shoot(target_pos: Vector2) -> void:
	if !can_fire or ammo <= 0:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	
	var angle = (target_pos - weapon_owner.global_position).angle()
	var direction = Vector2.RIGHT.rotated(angle)
	bullet.rotation = angle
	bullet.direction = direction

	bullet.shooter = weapon_owner
	get_tree().root.add_child(bullet)

	ammo -= 1
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
