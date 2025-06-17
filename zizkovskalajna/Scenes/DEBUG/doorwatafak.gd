extends RigidBody2D

@export var force_amount := 800.0
var is_open := false
var has_hit := false
var contacts_reported

func _ready():
	set_contact_monitor(true) # Aktivuje sledování kolizí
	contacts_reported = 10    # Kolik kolizí můžeš najednou trackovat
	add_to_group("doors")


func _on_body_entered(body):
	if is_open or has_hit:
		return
	
	if body.is_in_group("enemies") or body.name == "Player":
		open_door(body)

func open_door(body):
	is_open = true
	has_hit = true
	var direction = (global_position - body.global_position).normalized()
	apply_impulse(Vector2.ZERO, direction * force_amount)
	await get_tree().create_timer(0.2).timeout
	$CollisionShape2D.set_deferred("disabled", true)
	
	
func _integrate_forces(state):
	if has_hit:
		return

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider and collider.is_in_group("enemies") and not collider.dead:
			collider.die()
			has_hit = true
