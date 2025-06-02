extends Area2D

@export var weapon_scene: PackedScene
@export var weapon_texture: Texture2D
@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player") 
@export var texture_scale: Vector2
@export var ammo_count: int


const PICKUP_DISTANCE: float = 20.0

func _ready():
	
	if weapon_texture:
		sprite.texture = weapon_texture
		sprite.scale = texture_scale

func _process(_delta: float) -> void:
	if !is_instance_valid(player):
		return

	if global_position.distance_to(player.global_position) <= PICKUP_DISTANCE and Input.is_action_just_pressed("mouse_right"):
		if player.has_method("pick_up_weapon"):
			player.pick_up_weapon(weapon_scene, texture_scale, ammo_count)
			queue_free()
