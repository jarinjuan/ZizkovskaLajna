extends Area2D

const SPEED: float = 400  # Rychlost kulky
var direction: Vector2 = Vector2.ZERO  # Směr kulky

func _ready() -> void:
	# Pokud je kulka připravená, začneme pohyb
	set_process(true)

func _process(delta: float) -> void:
	# Pohyb kulky směrem k cíli
	position += direction * SPEED * delta
	
	# Pokud kulka opustí herní oblast, zmizí
	if position.x < 0 or position.x > get_viewport_rect().size.x or position.y < 0 or position.y > get_viewport_rect().size.y:
		queue_free()

func _on_Area2D_body_entered(body) -> void:
	# Pokud kulka zasáhne nějakého nepřítele
	if body.is_in_group("enemies"):
		print("Zasaž
		en nepřítel!")
		body.queue_free()  # Znič nepřítele
		queue_free()  # Znič kulku
