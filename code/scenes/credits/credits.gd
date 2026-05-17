extends Control

@export var scroll_speed: float = 50.0
@onready var container = $VBoxContainer # Assure-toi que le nom correspond

func _ready() -> void:
	# On place les crédits juste en bas de l'écran au départ
	container.global_position.y = get_viewport_rect().size.y
	
func _process(delta: float) -> void:
	# On fait monter le container
	container.position.y -= scroll_speed * delta
	
	# Si les crédits ont totalement dépassé le haut de l'écran
	if container.global_position.y + container.size.y < 0:
		finir_credits()

func _input(event: InputEvent) -> void:
	# Permettre de quitter les crédits avec Espace ou Echap
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("jump"):
		finir_credits()

func finir_credits() -> void:
	# Retour au menu principal (adapte le chemin)
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
