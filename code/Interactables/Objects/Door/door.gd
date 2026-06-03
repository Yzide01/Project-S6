extends StaticBody2D

signal hint_requested

@export var is_open: bool = false
@export var is_locked: bool = true
@export var is_interactable: bool = true
@export var object_name: String = "Porte"

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
		
	if is_locked:
		hint_requested.emit()
		return

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
