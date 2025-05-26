extends Area2D

@export var weapon_scene: PackedScene  # sem v editoru přidáš pistol, m4, co chceš
@export var weapon_texture: Texture2D
@onready var player = get_node("../Player")  # nebo jak máš strukturu, přizpůsob
@onready var sprite = $Sprite2D

const PICKUP_DISTANCE: float = 20.0

func _ready():
	if weapon_texture:
		sprite.texture = weapon_texture

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if (player.global_position - global_position).length() <= PICKUP_DISTANCE and Input.is_action_just_pressed("mouse_right"):
		if player.has_method("pick_up_weapon"):
			player.pick_up_weapon(weapon_scene)
			queue_free()
