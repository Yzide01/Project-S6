extends Node2D

signal played(id: int)

@onready var interactable = $Interactable

func _ready() -> void:
	if interactable:
		interactable.interact_name = "Jouer la corde"
		interactable.is_interactable = true
		# On lie l'action à ce script
		interactable.interact = _on_interact

func _on_interact():
	var id_str = name.get_slice("_", 1)
	var id = int(id_str)
	
	var sound_node_name = "Pluck_" + id_str
	
	if has_node(sound_node_name):
		get_node(sound_node_name).play()

	played.emit(id)
	print("Corde jouée : ", id)
