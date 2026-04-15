extends Node2D

signal played(id: int)

# On va chercher l'enfant Area2D (la scène de ton coéquipier)
@onready var interactable_area = $InteractableArea

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Jouer la corde"
		interactable_area.is_interactable = true
		# On lie l'action à ce script
		interactable_area.interact = _on_interact

func _on_interact():
	# Extrait le chiffre du Node2D (ex: "String_1" -> 1)
	var id = int(name.get_slice("_", 1))
	played.emit(id)
	print("Corde jouée : ", id)
