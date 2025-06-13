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

	var base_angle = weapon_owner.rotation  # místo cílové pozice použijeme rotaci hráče

	for i in pellets_per_shot:
		var bullet = bullet_scene.instantiate()

		# Muzzle pozice získaná z hráče
		var muzzle_pos = weapon_owner.get_muzzle_position()
		bullet.global_position = muzzle_pos

		# Přidáme náhodný spread ke směru
		var spread_radians = deg_to_rad(randf_range(-spread_angle_deg / 2, spread_angle_deg / 2))
		var final_angle = base_angle + spread_radians
		var direction = Vector2.RIGHT.rotated(final_angle)

		bullet.rotation = final_angle
		bullet.direction = direction
		bullet.shooter = weapon_owner

		get_tree().current_scene.add_child(bullet)

	ammo -= 1
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
