extends Node2D

@onready var interactable_area = $InteractableArea

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Mélodie requise"
		interactable_area.is_interactable = false # Bloqué au début
		interactable_area.interact = _on_interact

func _on_interact():
	# Ce qui se passe quand le joueur appuie sur E après avoir résolu l'énigme
	print("Le joueur traverse la porte !")
	# ex: get_tree().change_scene_to_file("res://Levels/niveau2.tscn")

# Fonction appelée par le gestionnaire du niveau
func unlock() -> void:
	if interactable_area:
		interactable_area.is_interactable = true
		interactable_area.interact_name = "Passer la porte"
