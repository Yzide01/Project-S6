extends Control

func _ready():
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)
	
	# Connect buttons to their assigned levels
	if $VBoxContainer.has_node("Level1CordeButton"):
		$VBoxContainer/Level1CordeButton.pressed.connect(func(): _load_level("res://Levels/niveau1_cordeV2.tscn"))
		$VBoxContainer/Level1CordeButton.grab_focus()
	if $VBoxContainer.has_node("Level1PercuButton"):
		$VBoxContainer/Level1PercuButton.pressed.connect(func(): _load_level("res://Levels/niveau1_percussion.tscn"))
	if $VBoxContainer.has_node("Level1VentsButton"):
		$VBoxContainer/Level1VentsButton.pressed.connect(func(): _load_level("res://Levels/niveau1_vents.tscn"))
	if $VBoxContainer.has_node("Level2CordeButton"):
		$VBoxContainer/Level2CordeButton.pressed.connect(func(): _load_level("res://Levels/niveau2_corde.tscn"))
	if $VBoxContainer.has_node("Level2PercuButton"):
		$VBoxContainer/Level2PercuButton.pressed.connect(func(): _load_level("res://Levels/niveau2_percussion.tscn"))
	if $VBoxContainer.has_node("Level2VentsButton"):
		$VBoxContainer/Level2VentsButton.pressed.connect(func(): _load_level("res://Levels/niveau2_vents.tscn"))
	if $VBoxContainer.has_node("LevelTestButton"):
		$VBoxContainer/LevelTestButton.pressed.connect(func(): _load_level("res://Levels/niveau_test.tscn"))
	if $VBoxContainer.has_node("BattleButton"):
		$VBoxContainer/BattleButton.pressed.connect(func(): _load_level("res://Core/CombatSystem/battle_scene.tscn"))
	
	if $VBoxContainer.has_node("BackButton"):
		$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

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
	if PauseMenuManager.has_method("close_pause_menu"):
		PauseMenuManager.close_pause_menu()
	SceneManager.changer_niveau(level_path)
