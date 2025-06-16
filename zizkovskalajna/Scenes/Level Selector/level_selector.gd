extends Control

const LEVEL_SCENE_PATH = "res://Scenes/Levels/"
const LEVEL_IMAGE_PATH = "res://Assets/Sprites/Levels/"
var BIG_BUTTON_SIZE
var SMALL_BUTTON_SIZE
var darken_material := ShaderMaterial.new()


var level_scene_paths = [
	"res://Scenes/Levels/level_01.tscn",
	"res://Scenes/Levels/level_02.tscn",
	"res://Scenes/Levels/level_03.tscn",
	# Přidej sem další levely, co máš
]
var level_image = []
var current_level = int(GameManager.max_unlocked_level - 1)

func _ready():
	BIG_BUTTON_SIZE = $center.size
	SMALL_BUTTON_SIZE = $left.size
	
	darken_material.shader = preload("res://Scenes/Level Selector/darken_shader.gdshader")
	
	# Vyčistit pole obrázků (pokud třeba reloaduješ)
	level_image.clear()
	
	# Načti obrázky podle pevného seznamu levelů
	for full_scene_path in level_scene_paths:
		var file_name = full_scene_path.get_file() # např. "level1.tscn"
		var image_path = LEVEL_IMAGE_PATH + file_name.get_basename() + ".png"
		print(image_path)
		if not ResourceLoader.exists(image_path):
			image_path = "res://Assets/Sprites/Tilesets/error.png"
		
		level_image.append(load(image_path) as Texture2D)
	
	if current_level + 1 > level_scene_paths.size():
		current_level = level_scene_paths.size() - 1
		
	# Nastav UI podle current_level
	$levelLabel.text = str(current_level + 1)
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	
	if current_level + 1 < level_scene_paths.size():
		$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
		$right.material = null if can_access_level(current_level + 1) else darken_material
	else:
		$right.texture = null
	
	if current_level > 0:
		$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
		$left.material = null if can_access_level(current_level - 1) else darken_material
	else:
		$left.texture = null



func resize_get_texture(old_image, new_size):
	var new_texture
	
	old_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	new_texture = ImageTexture.create_from_image(old_image)
	return new_texture
	



func right_button_pressed():
	if (current_level+1) == level_scene_paths.size():
		return
	
	current_level = current_level + 1
	$levelLabel.text = str(current_level+1)
	
	$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	$left.material = null if can_access_level(current_level - 1) else darken_material
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	$center.material = null if can_access_level(current_level) else darken_material
	
	if current_level+1 == level_scene_paths.size():
		$right.texture = null
		return
	$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	$right.material = null if can_access_level(current_level + 1) else darken_material
	
	return


func left_button_pressed():
	if current_level - 1 < 0:
		return
	
	current_level -= 1
	$levelLabel.text = str(current_level + 1)
	
	$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	$right.material = null if can_access_level(current_level + 1) else darken_material
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	$center.material = null if can_access_level(current_level) else darken_material
	
	if current_level == 0:
		$left.texture = null
		return
	
	$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	$left.material = null if can_access_level(current_level - 1) else darken_material



func play_pressed():
	if !can_access_level(current_level):
		return
	GameManager.last_level_played = current_level
	print(level_scene_paths[current_level])
	get_tree().change_scene_to_file(level_scene_paths[current_level])


func get_back():
	get_tree().change_scene_to_file("res://Scenes/Level Selector/level_selector.tscn")

func can_access_level(current_level) -> bool:
	if current_level > GameManager.max_unlocked_level - 1:
		return false
	return true


func _unhandled_input(event):
	if event.is_action_pressed("move_right"):
		right_button_pressed()
		return
	if event.is_action_pressed("move_left"):
		left_button_pressed()
		return
	if event.is_action_pressed("confirm"):
		play_pressed()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main/control.tscn")
