extends Node2D


@onready var interactable_area = $Interactable
var is_locked: bool = true

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Door"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if not is_locked:
		SceneManager.changer_niveau("res://Levels/niveau2_vents.tscn")

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Go through the door"
