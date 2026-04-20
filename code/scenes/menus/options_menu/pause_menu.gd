extends Control

var current_options = null
var options_scene = preload("res://scenes/menus/options_menu/master_options_menu_with_tabs.tscn")

func _ready():
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/SettingButton.pressed.connect(_on_setting_pressed)
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

func _on_exit_pressed():
	get_tree().quit()
