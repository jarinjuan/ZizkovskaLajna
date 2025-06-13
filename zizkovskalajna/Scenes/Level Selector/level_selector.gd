extends Control

const LEVEL_SCENE_PATH = "res://Scenes/Levels/"
const LEVEL_IMAGE_PATH = "res://Assets/Sprites/Levels/"
var BIG_BUTTON_SIZE
var SMALL_BUTTON_SIZE
var darken_material := ShaderMaterial.new()


var level_scene_paths = []
var level_image = []
var current_level = int(GameManager.max_unlocked_level - 1)

func _ready():
	var dir = DirAccess.open(LEVEL_SCENE_PATH)
	BIG_BUTTON_SIZE = $center.size
	SMALL_BUTTON_SIZE = $left.size
	
	if !dir:
		Log.write_log("Level scenes dirrectory cant be accessed", Log.MessageLevel.ERROR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !file_name.ends_with(".tscn") || dir.current_is_dir():
			file_name = dir.get_next()
			continue
			
		var image_path = LEVEL_IMAGE_PATH + file_name.get_basename() + ".png"
		
		if !ResourceLoader.exists(image_path):
			image_path = "res://Assets/Sprites/Tilesets/error.png"
		
		
		level_image.push_back(load(image_path) as Texture2D)
		level_scene_paths.push_back(LEVEL_SCENE_PATH + file_name)
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
	$levelLabel.text = str(current_level+1)
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	if current_level + 1 < level_scene_paths.size():
		$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
		$right.material = null if can_access_level(current_level + 1) else darken_material
	if current_level > 0:
		$left.texture = resize_get_texture(level_image[current_level + -1].get_image(), SMALL_BUTTON_SIZE)
		$left.material = null if can_access_level(current_level - 1) else darken_material
	#for sprite in get_tree().get_nodes_in_group("button_animations"):
		#sprite.play("default")
	darken_material.shader = preload("res://Scenes/Level Selector/darken_shader.gdshader")
	return


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
	
	current_level = current_level - 1
	$levelLabel.text = str(current_level+1)
	
	$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	$right.material = null if can_access_level(current_level + 1) else darken_material
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	$center.material = null if can_access_level(current_level) else darken_material
	
	if current_level == 0:
		$left.texture = null
		return

	$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	$left.material = null if can_access_level(current_level - 1) else darken_material
	
	return


func play_pressed():
	if !can_access_level(current_level):
		return
	GameManager.last_level_played = current_level
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
