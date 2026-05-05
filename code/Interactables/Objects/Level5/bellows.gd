extends Node2D

# On crée un signal pour prévenir le niveau que le joueur a pompé
signal pumped_air

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Pump the bellows"
		interactable_area.is_interactable = true
		interactable_area.interact = _on_interact

func _on_interact() -> void:
	# Quand le joueur interagit, on prévient la scène principale
	pumped_air.emit()
