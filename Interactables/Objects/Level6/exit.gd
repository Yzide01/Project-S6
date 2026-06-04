extends Node2D

signal start_level_combat 

@onready var interactable_area = $Interactable
var is_locked: bool = true

func _ready() -> void:
	visible = false
	if interactable_area:
		interactable_area.interact_name = "Exit level 6"
		interactable_area.is_interactable = false
		interactable_area.interact = _on_interact

func _on_interact():
	if not is_locked:
		start_level_combat.emit()

func unlock() -> void:
	is_locked = false
	interactable_area.is_interactable = true
	visible = true
	if interactable_area:
		interactable_area.interact_name = "Exit level 6"
