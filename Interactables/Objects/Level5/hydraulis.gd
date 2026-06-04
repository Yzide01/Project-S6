extends Node2D

signal played_hydraulis

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Play the Hydraulis"
		interactable_area.is_interactable = true
		interactable_area.interact = _on_interact

func _on_interact() -> void:
	played_hydraulis.emit()
