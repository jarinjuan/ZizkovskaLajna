extends CanvasLayer

class_name BulletUIClass

func  update_bullet_ui():
	$%bullet_count.text = str(GameManager.ammo)
