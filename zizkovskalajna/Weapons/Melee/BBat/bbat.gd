extends MeleeWeapon



var can_swing: bool = true

func _ready() -> void:
	range = 50


func swing(): 
	if not can_swing:
		return

	can_swing = false

	$AttackSound.play()
	var target_pos = weapon_owner.global_position
	var hit_something = false

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if target_pos.distance_to(enemy.global_position) <= range:
			if enemy.has_method("die"):
				enemy.die()
				hit_something = true

	for thing in get_tree().get_nodes_in_group("glass"):
		if target_pos.distance_to(thing.global_position) <= range:
			if thing.has_method("break_glass"):
				thing.break_glass()
				hit_something = true

	await get_tree().create_timer(cooldown_time).timeout
	can_swing = true
