extends Node

var ammo = preload("res://Scenes/UI/ammo.tscn").instantiate() as Node
var menu = preload("res://Scenes/UI/menu.tscn").instantiate() as Node
var dialog = preload("res://Scenes/UI/dialog.tscn").instantiate() as Node
var random := RandomNumberGenerator.new()


func _ready():
	#------------BULLET--------------------------
	add_child(ammo)
	ammo.visible = false
	ammo.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bullet_current = ammo.get_node("bullet/current") as Label
	bullet_original = ammo.get_node("bullet/original") as Label
	#------------DIALOG--------------------------
	add_child(dialog)
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	
	scroll_bar = dialog.get_node("cont/text").get_v_scroll_bar() as VScrollBar
	dialog_text = dialog.get_node("cont/text") as RichTextLabel
	blop_player = dialog.get_node("blop") as AudioStreamPlayer
	character_texture = dialog.get_node("cont/character") as TextureRect
	
	await dialog_setup()
	
	#------------OTHER--------------------------
	random.randomize()
	get_node("/root/Ui").process_mode = Node.PROCESS_MODE_ALWAYS
	

	
#------------BULLET--------------------------
var bullet_original
var bullet_current

func pick_up_bullet_ui():
	bullet_current.text = str(GameManager.ammo)
	bullet_original.text = str(GameManager.original_ammo_count)

func  update_bullet_ui():
	bullet_current.text = str(GameManager.ammo)
	
func show_ammo():
	ammo.visible = true

func close_ammo():
	ammo.visible = false
	
func is_active_ammo():
	if ammo.visible == true:
		return true
	else: return false

#------------DIALOG--------------------------
const dialog_image_path = "res://Assets/Sprites/Dialog/"
var dialog_playing: bool = false
var scroll_bar
var dialog_text
var blop_player
var character_texture

func show_dialog():
	scroll_bar.visible = false
	dialog.visible = true

func close_dialog():
	dialog.visible = false
	
	
func start_dialog(message, character_name):
	
	var size = character_texture.size
	character_texture.texture = resize_get_texture(load(dialog_image_path + character_name + ".png") as Texture2D, size)
	dialog.visible = true
	dialog_playing = true
	dialog_text.text = message
	dialog_text.visible_characters = 0
	
	get_tree().paused = true
	while true:
		if dialog_text.visible_characters == dialog_text.text.length():
			break
			
		if dialog_text.text[dialog_text.visible_characters] == '.':
			dialog_text.visible_characters += 1
			await wait_for_any_input()
			continue
			
		dialog_text.visible_characters += 1
		blop_player.pitch_scale = random.randf_range(0.90, 1.05)
		blop_player.play(0)
		scroll_bar.visible = false
		await blop_player.finished
		
	await wait_for_any_input()
	dialog_playing = false
	get_tree().paused = false
	close_dialog()


func dialog_setup():
	dialog.visible = false
	show_dialog()
	scroll_bar.visible = false
	await wait(0.01)
	close_dialog()
	
#------------OTHER--------------------------
func wait(time):
	await get_tree().create_timer(time).timeout

func wait_for_any_input() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_anything_pressed():
			return
	
var lorem = "Noc byla chladná a mlha se valila údolím jako přízrak. Každý krok na vlhké trávě zněl hlasitěji, než by měl. Ve vzduchu bylo něco těžkého – neklid, který se nedal vysvětlit. A pak, najednou, ticho prořízl výkřik. Krátký. Ostrý. A pak zase nic"

func resize_get_texture(texture: Texture2D, new_size: Vector2) -> Texture2D:
	if not texture:
		return null

	var image: Image = texture.get_image()
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	var new_texture := ImageTexture.create_from_image(image)
	return new_texture
