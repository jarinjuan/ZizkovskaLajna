# pistol.gd
extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle = $Muzzle
@export var ammo: int
@export var original_ammo = 15

func shoot(target_pos: Vector2) -> void:
	if !can_fire or ammo <= 0:
		return

	var bullet = bullet_scene.instantiate()

	# Muzzle získaný z hráče
	var muzzle_pos = weapon_owner.get_muzzle_position()
	bullet.global_position = muzzle_pos

	# Směr podle rotace hráče (čili celé zbraně)
	var direction = Vector2.RIGHT.rotated(weapon_owner.rotation)
	bullet.direction = direction
	bullet.rotation = direction.angle()

	bullet.shooter = weapon_owner
	get_tree().current_scene.add_child(bullet)


	ammo -= 1
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
