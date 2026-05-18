extends Control

var save_menu_scene = preload("res://scenes/menus/save_menu/save_menu.tscn")
var current_save_menu = null

@onready var audio = $AudioStreamPlayer 

func _ready():
	if $VBoxContainer.has_node("PlayButton"):
		$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	if $VBoxContainer.has_node("LoadButton"):
		$VBoxContainer/LoadButton.pressed.connect(_on_load_pressed)
	if $VBoxContainer.has_node("QuitButton"):
		$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Initial fade out state for smooth entry
	modulate = Color(1, 1, 1, 0)
	
	if audio:
		audio.volume_db = -60.0 # On commence dans le silence total
		audio.play()            # On lance la lecture
	
	# Le set_parallel(true) permet d'animer l'image ET le son en même temps !
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2.0).set_trans(Tween.TRANS_SINE)
	
	if audio:
		# On monte le volume jusqu'à 0.0 (volume normal)
		tween.tween_property(audio, "volume_db", -20, 2.0).set_trans(Tween.TRANS_SINE)
	
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_pressed():
	if has_node("ColorRect"):
		$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Fade out beautifully before playing the cinematic
	var tween = create_tween().set_parallel(true) # Parallel ici aussi !
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0).set_trans(Tween.TRANS_SINE)
	
	if audio:
		# On baisse le volume vers le silence total
		tween.tween_property(audio, "volume_db", -60.0, 1.0).set_trans(Tween.TRANS_SINE)
		
	await tween.finished
	
	# Une fois le fondu terminé, on STOPPE complètement l'audio pour éviter qu'il déborde
	if audio:
		audio.stop() 
		
	hide()
	
	# Play the cinematics
	SceneManager.jouer_cinematique("res://Assets/Videos/Scène-1.ogv", "res://scenes/manager/relais_cine2.tscn", "res://Assets/Sound/Ambiant sound/cinematics.ogg")

func _on_quit_pressed():
	# Disable UI clicks while closing
	if has_node("ColorRect"):
		$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	# Fade out beautifully before quitting
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5).set_trans(Tween.TRANS_SINE)
	
	if audio:
		tween.tween_property(audio, "volume_db", -60.0, 0.5).set_trans(Tween.TRANS_SINE)
		
	await tween.finished
	get_tree().quit()

func _on_load_pressed():
	current_save_menu = save_menu_scene.instantiate()
	add_child(current_save_menu)
	$VBoxContainer.hide()
	current_save_menu.tree_exited.connect(_on_save_menu_closed)

func _on_save_menu_closed():
	$VBoxContainer.show()
	if $VBoxContainer.has_node("LoadButton"):
		$VBoxContainer/LoadButton.grab_focus()
	current_save_menu = null
