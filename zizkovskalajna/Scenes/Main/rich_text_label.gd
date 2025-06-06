extends RichTextLabel

var shake_amount = 0.3
var colors = [Color.RED, Color.YELLOW, Color.PINK, Color.CYAN]

var tilt_amount = 0.03	  #max uhel
var tilt_speed = 2.0  #rychlost náklonu
var tilt_time = 0.0 

func _ready():
	set_pivot_offset(size / 2)

func _process(delta):
	# todle meni barvicku toho textu, idk jestli to pouzijem
	#if randi() % 10 == 0: 
		#text = "[color=" + colors.pick_random().to_html() + "]Zizkovska Lajna[/color]"

	tilt_time += delta * tilt_speed
	rotation = sin(tilt_time) * tilt_amount
