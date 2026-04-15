extends Node2D

@export var is_open: bool = false
@export var label_open: String = "E pour Fermer"
@export var label_closed: String = "E pour Ouvrir"

@onready var interactable: Area2D = $Interactable
@onready var solid_wall_collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# On lie le Callable pour le système d'interaction
	interactable.interact = _on_interact
	_update_door_state()
	
func _on_interact():
	is_open = !is_open
	_update_door_state()

func _update_door_state() -> void:
	# On vérifie si le nœud de collision est bien chargé
	if not is_node_ready() or solid_wall_collision == null:
		return
		
	if is_open:
		interactable.interact_name = label_open
		solid_wall_collision.set_deferred("disabled", true)
	else:
		interactable.interact_name = label_closed
		solid_wall_collision.set_deferred("disabled", false)
