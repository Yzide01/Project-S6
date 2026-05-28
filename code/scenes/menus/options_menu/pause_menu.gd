extends Control

var current_options = null
var options_scene = preload("res://scenes/menus/options_menu/master_options_menu_with_tabs.tscn")
var level_selection_scene = preload("res://scenes/menus/level_selection/level_selection_menu.tscn")
var save_menu_scene = preload("res://scenes/menus/save_menu/save_menu.tscn")
var current_level_selection = null
var current_save_menu = null

func _ready():
	if $VBoxContainer.has_node("ResumeButton"):
		$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	if $VBoxContainer.has_node("SettingButton"):
		$VBoxContainer/SettingButton.pressed.connect(_on_setting_pressed)
	if $VBoxContainer.has_node("LevelSelectionButton"):
		$VBoxContainer/LevelSelectionButton.pressed.connect(_on_level_selection_pressed)
	if $VBoxContainer.has_node("SaveButton"):
		$VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	if $VBoxContainer.has_node("LoadButton"):
		$VBoxContainer/LoadButton.pressed.connect(_on_load_pressed)
	if $VBoxContainer.has_node("ExitButton"):
		$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

	$VBoxContainer/ResumeButton.grab_focus()

	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if current_options:
			current_options.queue_free()
			current_options = null
			$VBoxContainer.show()
			$VBoxContainer/ResumeButton.grab_focus()
			get_viewport().set_input_as_handled()
		elif current_level_selection:
			current_level_selection.queue_free()
			current_level_selection = null
			$VBoxContainer.show()
			$VBoxContainer/ResumeButton.grab_focus()
			get_viewport().set_input_as_handled()
		elif current_save_menu:
			current_save_menu.queue_free()
			current_save_menu = null
			$VBoxContainer.show()
			$VBoxContainer/ResumeButton.grab_focus()
			get_viewport().set_input_as_handled()
		else:
			get_viewport().set_input_as_handled()
			close_menu_with_animation()

func _on_options_closed():
	$VBoxContainer.show()
	$VBoxContainer/SettingButton.grab_focus()
	current_options = null

var is_closing = false

func close_menu_with_animation():
	if is_closing:
		return
	is_closing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	if PauseMenuManager.has_method("close_pause_menu"):
		PauseMenuManager.close_pause_menu()
	else:
		get_tree().paused = false
		queue_free()

func _on_resume_pressed():
	close_menu_with_animation()

func _on_setting_pressed():
	current_options = options_scene.instantiate()
	add_child(current_options)
	$VBoxContainer.hide()
	current_options.tree_exited.connect(_on_options_closed)

func _on_level_selection_pressed():
	current_level_selection = level_selection_scene.instantiate()
	add_child(current_level_selection)
	$VBoxContainer.hide()
	current_level_selection.tree_exited.connect(_on_level_selection_closed)

func _on_level_selection_closed():
	$VBoxContainer.show()
	if $VBoxContainer.has_node("LevelSelectionButton"):
		$VBoxContainer/LevelSelectionButton.grab_focus()
	current_level_selection = null

func _on_save_pressed():
	current_save_menu = save_menu_scene.instantiate()
	current_save_menu.mode = "save"
	add_child(current_save_menu)
	$VBoxContainer.hide()
	current_save_menu.tree_exited.connect(_on_save_menu_closed)

func _on_load_pressed():
	current_save_menu = save_menu_scene.instantiate()
	current_save_menu.mode = "load"
	add_child(current_save_menu)
	$VBoxContainer.hide()
	current_save_menu.tree_exited.connect(_on_save_menu_closed)

func _on_save_menu_closed():
	$VBoxContainer.show()
	if $VBoxContainer.has_node("SaveButton"):
		$VBoxContainer/SaveButton.grab_focus()
	current_save_menu = null

func _on_exit_pressed():
	get_tree().quit()
