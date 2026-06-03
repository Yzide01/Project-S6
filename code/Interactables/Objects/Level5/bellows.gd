extends Node2D

signal pumped_air

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Pump the bellows"
		interactable_area.is_interactable = true
		interactable_area.interact = _on_interact

func _on_interact() -> void:
	pumped_air.emit()
