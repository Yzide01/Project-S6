extends Node2D

signal played(id: int)

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Pluck the string"
		interactable_area.is_interactable = true
		# On lie l'action à ce script
		interactable_area.interact = _on_interact

func _on_interact():
	var id = int(name.get_slice("_", 1))
	played.emit(id)
	print("Corde jouée : ", id)
