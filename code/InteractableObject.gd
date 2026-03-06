class_name InteractableObject
extends Area2D

@export var object_name: String = "Objet Inconnu"
@export var is_interactable: bool = true

func interact(player: Node2D) -> void:
	if not is_interactable:
		return
	
	print("Interaction basique avec : ", object_name)
