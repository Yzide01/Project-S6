extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_pressed():
	hide()
	# Play the cinematics
	SceneManager.jouer_cinematique("res://Assets/Videos/Scène-1.ogv", "res://scenes/manager/relais_cine2.tscn", "res://Assets/Sound/Ambiant sound/cinematics.ogg")

	
func _on_quit_pressed():
	get_tree().quit()
