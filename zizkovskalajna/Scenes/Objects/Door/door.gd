extends Node2D

@onready var animation = $AnimatedSprite2D

var can_action = true
var is_open = false

func _ready():
	#animation.stop()
	animation.frame = 0

func _process(delta: float) -> void:
	if is_open:
		$CollisionPolygon2D.disabled = true
	else :
		$CollisionPolygon2D.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return
	
	print("Vstoupil:", body.name, " | Groupy:", body.get_groups())
	if can_action and not is_open:
		can_action = false
		
		animation.play("open")
		is_open = true
		await get_tree().create_timer(1).timeout
		can_action = true
	


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == self:
		return
	if can_action and is_open:
		can_action = false
		animation.play("close")
		is_open = false
		await get_tree().create_timer(1).timeout
		can_action = true
