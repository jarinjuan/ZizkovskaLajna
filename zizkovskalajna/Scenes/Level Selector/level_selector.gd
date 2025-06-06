extends Control

const LEVEL_SCENE_PATH = "res://discard/levels/"
const LEVEL_IMAGE_PATH = "res://discard/levels/Sprites/"
const LEVEL_IMAGE_LOCKED_PATH = "res://discard/levels/Sprites/locked/"
var BIG_BUTTON_SIZE
var SMALL_BUTTON_SIZE

var level_scene_paths = []
var level_image = []
var level_image_locked = []
var current_level = 0

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
		var image_locked_path = LEVEL_IMAGE_LOCKED_PATH + file_name.get_basename() + ".png"
		
		if !ResourceLoader.exists(image_path):
			image_path = "res://Assets/Sprites/Objects/error.png"
			
		if !ResourceLoader.exists(image_locked_path):
			image_locked_path = "res://Assets/Sprites/Objects/error.png" 
		
		level_image.push_back(load(image_path) as Texture2D)
		level_image_locked.push_back(load(image_locked_path) as Texture2D)
		level_scene_paths.push_back(LEVEL_SCENE_PATH + file_name)
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

	$center.texture = resize_get_texture(level_image[0].get_image(), BIG_BUTTON_SIZE)
	$right.texture = resize_get_texture(level_image[1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level + 1):
		$right.texture = resize_get_texture(level_image_locked[current_level + 1].get_image(), SMALL_BUTTON_SIZE)

	return


func resize_get_texture(old_image, new_size):
	var new_texture
	
	old_image.resize(new_size.x, new_size.y)
	new_texture = ImageTexture.create_from_image(old_image)
	return new_texture


func right_button_pressed():
	if (current_level+1) == level_scene_paths.size():
		return
	
	current_level = current_level + 1
	
	$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level-1):
		$left.texture = resize_get_texture(level_image_locked[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	if !can_access_level(current_level):
		$center.texture = resize_get_texture(level_image_locked[current_level].get_image(), BIG_BUTTON_SIZE)
	
	if current_level+1 == level_scene_paths.size():
		$right.texture = null
		return
	$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level + 1):
		$right.texture = resize_get_texture(level_image_locked[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	
	return


func left_button_pressed():
	if current_level - 1 < 0:
		return
	
	current_level = current_level - 1
	
	$right.texture = resize_get_texture(level_image[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level + 1):
		$right.texture = resize_get_texture(level_image_locked[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	$center.texture = resize_get_texture(level_image[current_level].get_image(), BIG_BUTTON_SIZE)
	if !can_access_level(current_level):
		$center.texture = resize_get_texture(level_image_locked[current_level].get_image(), BIG_BUTTON_SIZE)
	
	if current_level == 0:
		$left.texture = null
		return
	
	
	$left.texture = resize_get_texture(level_image[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level-1):
		$left.texture = resize_get_texture(level_image_locked[current_level - 1].get_image(), SMALL_BUTTON_SIZE)
	
	return


func play_pressed():
	if !can_access_level(current_level):
		return
	get_tree().change_scene_to_file(level_scene_paths[current_level])


func get_back():
	get_tree().change_scene_to_file("res://discard/level_selector.tscn")

func can_access_level(current_level) -> bool:
	if current_level > GameManager.max_unlocked_level:
		return false
	return true
