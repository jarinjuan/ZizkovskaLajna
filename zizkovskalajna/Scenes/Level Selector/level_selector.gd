extends Control

const LEVEL_SCENE_PATH = "res://Scenes/Levels/"
const LEVEL_IMAGE_PATH = "res://Assets/Sprites/Levels/"
const LEVEL_IMAGE_LOCKED_PATH = "res://Assets/Sprites/Levels/Locked/"
var BIG_BUTTON_SIZE
var SMALL_BUTTON_SIZE

var level_scene_paths = []
var level_image = []
var level_image_locked = []
var current_level = GameManager.max_unlocked_level

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
			image_path = "res://Assets/Sprites/Tilesets/error.png"
			
		if !ResourceLoader.exists(image_locked_path):
			image_locked_path = "res://Assets/Sprites/Tilesets/error.png" 
		
		level_image.push_back(load(image_path) as Texture2D)
		level_image_locked.push_back(load(image_locked_path) as Texture2D)
		level_scene_paths.push_back(LEVEL_SCENE_PATH + file_name)
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	$center.texture = resize_get_texture(level_image[0].get_image(), BIG_BUTTON_SIZE)
	$right.texture = resize_get_texture(level_image[1].get_image(), SMALL_BUTTON_SIZE)
	if !can_access_level(current_level + 1):
		$right.texture = resize_get_texture(level_image_locked[current_level + 1].get_image(), SMALL_BUTTON_SIZE)
	if current_level > 0:
		$left.texture = resize_get_texture(level_image_locked[current_level - 1].get_image(), SMALL_BUTTON_SIZE)


	#for sprite in get_tree().get_nodes_in_group("button_animations"):
		#sprite.play("default")
		
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
	GameManager.last_level_played = current_level
	get_tree().change_scene_to_file(level_scene_paths[current_level])


func get_back():
	get_tree().change_scene_to_file("res://Scenes/Level Selector/level_selector.tscn")

func can_access_level(current_level) -> bool:
	if current_level > GameManager.max_unlocked_level:
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
