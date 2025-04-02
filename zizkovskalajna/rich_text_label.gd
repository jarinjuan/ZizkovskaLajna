extends RichTextLabel

var shake_amount = 0.3
var colors = [Color.RED, Color.YELLOW, Color.PINK, Color.CYAN]

func _process(delta):
	# Random třes
	position.x += randf_range(-shake_amount, shake_amount)
	position.y += randf_range(-shake_amount, shake_amount)
	
	# Změna barvy každou chvíli
	if randi() % 10 == 0: 
		text = "[color=" + colors.pick_random().to_html() + "]Zizkovska Lajna[/color]"
