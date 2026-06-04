extends Control

@export var scroll_speed: float = 50.0
@onready var container = $VBoxContainer

func _ready() -> void:
	container.global_position.y = get_viewport_rect().size.y
	
func _process(delta: float) -> void:
	container.position.y -= scroll_speed * delta
	
	if container.global_position.y + container.size.y < 0:
		finir_credits()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("jump"):
		finir_credits()

func finir_credits() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
