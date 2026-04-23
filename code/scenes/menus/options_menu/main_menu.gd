extends Control

func _ready():
	# On connecte les signaux des boutons
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Optionnel : S'assurer que la souris est visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_pressed():
	# On lance la Cinématique 1 ! 
	# Le SceneManager s'occupe du fondu et de la vidéo.
	# Après la vidéo, le SceneManager ira vers la scène de la Cinématique 2.
	SceneManager.jouer_cinematique("res://Assets/Videos/Scene-1.ogv", "res://scenes/manager/cine2.tscn")

func _on_quit_pressed():
	get_tree().quit() # Ferme le jeu
