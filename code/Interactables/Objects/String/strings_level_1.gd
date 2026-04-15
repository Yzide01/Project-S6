extends Node2D

signal played(id: int)

@export var interact_name: String = "Jouer la corde"
@export var is_interactable: bool = true

# Requis par interacting_component.gd
var interact: Callable 

func _ready() -> void:
	interact = _on_interact

func _on_interact():
	if is_interactable:
		# On récupère l'ID depuis le nom du nœud (ex: "String_3" -> 3)
		var id = int(name.get_slice("_", 1))
		played.emit(id) # Utilisation correcte du signal
