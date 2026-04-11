extends StaticBody2D

@export var is_open: bool = false

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	is_open = !is_open
	_update_door_state()

func _update_door_state() -> void:
	if is_open:
		print("La porte s'ouvre !")
		solid_wall_collision.set_deferred("disabled", true)
		sprite_2d.modulate = Color(1, 1, 1, 0.3) 
	else:
		print("La porte se ferme !")
		solid_wall_collision.set_deferred("disabled", false)
		sprite_2d.modulate = Color(1, 1, 1, 1.0)
