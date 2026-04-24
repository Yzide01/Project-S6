extends CanvasLayer

var pause_menu_scene = preload("res://scenes/menus/options_menu/pause_menu.tscn")
var current_pause_menu = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			close_pause_menu_from_input()
		else:
			open_pause_menu()

func open_pause_menu():
	if current_pause_menu == null:
		current_pause_menu = pause_menu_scene.instantiate()
		add_child(current_pause_menu)
		get_tree().paused = true

func close_pause_menu_from_input():
	if current_pause_menu and current_pause_menu.has_method("close_menu_with_animation"):
		current_pause_menu.close_menu_with_animation()
	else:
		close_pause_menu()

func close_pause_menu():
	if current_pause_menu:
		current_pause_menu.queue_free()
		current_pause_menu = null
	get_tree().paused = false
