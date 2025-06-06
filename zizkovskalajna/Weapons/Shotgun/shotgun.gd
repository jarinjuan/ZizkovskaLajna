extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle = $Muzzle
@export var ammo: int
@export var pellets_per_shot: int = 6
@export var spread_angle_deg: float = 10.0 # degrees
@export var original_ammo = 6

func shoot(target_pos: Vector2) -> void:
	if !can_fire or ammo <= 0:
		return

	var base_angle = (target_pos - weapon_owner.global_position).angle()

	for i in pellets_per_shot:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position

		# Add random spread
		var spread_radians = deg_to_rad(randf_range(-spread_angle_deg / 2, spread_angle_deg / 2))
		var final_angle = base_angle + spread_radians
		var direction = Vector2.RIGHT.rotated(final_angle)

		bullet.rotation = final_angle
		bullet.direction = direction
		bullet.shooter = weapon_owner

		get_tree().root.add_child(bullet)

	ammo -= 1
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
