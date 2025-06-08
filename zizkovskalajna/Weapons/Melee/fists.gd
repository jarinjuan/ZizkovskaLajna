extends Node2D
class_name MeleeWeapon 

@export var cooldown_time: float = 0.5
@export var range: float = 25
var weapon_owner: Node = null
var can_punch: bool = true

func _ready():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = cooldown_time
	timer.name = "CooldownTimer"
	add_child(timer)
	timer.timeout.connect(_on_cooldown_timeout)

func punch():
	if not can_punch:
		return

	can_punch = false
	$CooldownTimer.start()

	var target_pos = weapon_owner.global_position

	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if target_pos.distance_to(enemy.global_position) <= range:
			if enemy.has_method("get_punched"):				
				enemy.get_punched()
				break

	var things_to_smash = get_tree().get_nodes_in_group("glass")
	for thing in things_to_smash:
		if target_pos.distance_to(thing.global_position) <= range:
			if thing.has_method("break_glass"):
				thing.break_glass()

func _on_cooldown_timeout():
	can_punch = true
