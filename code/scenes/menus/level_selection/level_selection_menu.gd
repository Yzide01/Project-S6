extends Control

func _ready():
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)
	
	# Connect buttons to their assigned levels
	$VBoxContainer/Level1CordeButton.pressed.connect(func(): _load_level("res://Levels/niveau1_cordeV2.tscn"))
	$VBoxContainer/Level1PercuButton.pressed.connect(func(): _load_level("res://Levels/niveau1_percussion.tscn"))
	$VBoxContainer/Level1VentsButton.pressed.connect(func(): _load_level("res://Levels/niveau1_vents.tscn"))
	$VBoxContainer/Level2CordeButton.pressed.connect(func(): _load_level("res://Levels/niveau2_corde.tscn"))
	$VBoxContainer/Level2PercuButton.pressed.connect(func(): _load_level("res://Levels/niveau2_percussion.tscn"))
	$VBoxContainer/Level2VentsButton.pressed.connect(func(): _load_level("res://Levels/niveau2_vents.tscn"))
	$VBoxContainer/LevelTestButton.pressed.connect(func(): _load_level("res://Levels/niveau_test.tscn"))
	
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	$VBoxContainer/Level1CordeButton.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu_with_animation()

var is_closing = false

func close_menu_with_animation():
	if is_closing:
		return
	is_closing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15).set_trans(Tween.TRANS_SINE)
	await tween.finished
	queue_free()

func _on_back_pressed():
	close_menu_with_animation()

func _load_level(level_path):
	get_tree().paused = false
	SceneManager.changer_niveau(level_path)
