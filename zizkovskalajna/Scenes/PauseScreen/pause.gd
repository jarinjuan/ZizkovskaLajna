# pause_menu.gd
extends CanvasLayer

@onready var resume_button: Button = $ButtonContainer/ButtonsVBox/ResumeButton 
@onready var restart_button: Button = $ButtonContainer/ButtonsVBox/RestartButton
@onready var quit_button: Button = $ButtonContainer/ButtonsVBox/QuitButton


signal resume_game
signal restart_game
signal quit_game

func _ready():
	# Connect button signals
	# Make sure these paths match your scene tree for pause_menu.tscn!
	resume_button.pressed.connect(_on_ResumeButton_pressed)
	restart_button.pressed.connect(_on_RestartButton_pressed)
	quit_button.pressed.connect(_on_QuitButton_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_ResumeButton_pressed():
	emit_signal("resume_game") # Tell the parent to resume

func _on_RestartButton_pressed():
	emit_signal("restart_game") # Tell the parent to go to main menu

func _on_QuitButton_pressed():
	emit_signal("quit_game") # Tell the parent to quit the game
