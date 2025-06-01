extends StaticBody2D

@export var intact_texture: Texture2D
@export var broken_texture: Texture2D

var is_broken = false


func _ready():
	intact_texture = load("res://Assets/Sprites/Tilesets/sprite_window.png") 
	broken_texture = load("res://Assets/Sprites/Tilesets/sprite_windowbroken.png")
	$Sprite2D.texture = intact_texture
	

func break_glass():
	if is_broken:
		return
	is_broken = true
	$Sprite2D.texture = broken_texture
	$CollisionShape2D.set_deferred("disabled", true)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_root().get_node("res://PLayer/player.gd")
		if player and not player.weapon_equipped:
			break_glass()
