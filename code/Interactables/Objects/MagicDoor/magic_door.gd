extends Node2D

signal hint_requested # Signal envoyé au niveau pour jouer le son

@onready var interactable_area = $Interactable
var is_locked: bool = true

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Magic door"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if is_locked:
		print("Indice demandé à la porte !")
		hint_requested.emit()
	else:
		print("Le joueur traverse la porte !")
		SceneManager.changer_niveau("res://Levels/niveau2_corde.tscn")

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Go through the door"
