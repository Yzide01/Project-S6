extends Control

var save_menu_scene = preload("res://scenes/menus/save_menu/save_menu.tscn")
var current_save_menu = null

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
	var tween = create_tween()
	# Slow, elegant fade-in
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2.0).set_trans(Tween.TRANS_SINE)
	
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_pressed():
	if has_node("ColorRect"):
		$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Fade out beautifully before playing the cinematic
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	hide()
	# Play the cinematics
	SceneManager.jouer_cinematique("res://Assets/Videos/Scène-1.ogv", "res://scenes/manager/relais_cine2.tscn", "res://Assets/Sound/Ambiant sound/cinematics.ogg")

func _on_quit_pressed():
	# Disable UI clicks while closing
	if has_node("ColorRect"):
		$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	# Fade out beautifully before quitting
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5).set_trans(Tween.TRANS_SINE)
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
