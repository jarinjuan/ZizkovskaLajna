extends Node

var ammo = preload("res://Scenes/UI/ammo.tscn")
var menu = preload("res://Scenes/UI/menu.tscn")
var ammo_ui
var menu_ui

func _ready():
	ammo_ui = ammo.instantiate()
	menu_ui = menu.instantiate()
	add_child(ammo_ui)
	add_child(menu_ui)
	menu_ui.visible = false
	ammo_ui.visible = false
	

func pick_up_bullet_ui():
	ammo_ui.get_node("bullet").get_node("current").text = str(GameManager.ammo)
	ammo_ui.get_node("bullet").get_node("original").text = str(GameManager.original_ammo_count)

func  update_bullet_ui():
	ammo_ui.get_node("bullet").get_node("current").text = str(GameManager.ammo)
	
func show_ammo():
	ammo_ui.visible = true

func close_ammo():
	ammo_ui.visible = false
