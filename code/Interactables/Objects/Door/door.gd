extends StaticBody2D

signal hint_requested # Signal envoyé au niveau pour demander l'indice musical

@export var is_open: bool = false
@export var is_locked: bool = true # Le verrou de l'énigme
@export var is_interactable: bool = true
@export var object_name: String = "Porte"

# Variables pour glisser tes deux images de porte dans l'inspecteur Godot
@export var texture_fermee: Texture2D 
@export var texture_ouverte: Texture2D 

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	interactable.interact = _on_interact
	object_name = "Porte"
	_update_door_state()

func _on_interact(_player: Node2D = null) -> void:
	if not is_interactable:
		return
		
	# Si la porte est verrouillée, on ne l'ouvre pas, on demande l'indice !
	if is_locked:
		print("La porte est verrouillée. Elle émet une mélodie...")
		hint_requested.emit()
		return

	# Si elle n'est plus verrouillée, on l'ouvre
	is_open = !is_open
	_update_door_state()

func _update_door_state() -> void:
	if is_open:
		solid_wall_collision.set_deferred("disabled", true)
		sprite_2d.modulate = Color(1, 1, 1, 0.3) 
		if texture_ouverte:
			sprite_2d.texture = texture_ouverte
	else:
		solid_wall_collision.set_deferred("disabled", false)
		sprite_2d.modulate = Color(1, 1, 1, 1.0)
		if texture_fermee:
			sprite_2d.texture = texture_fermee
