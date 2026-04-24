extends Node2D

signal state_changed
var current_mass_state: int = 0 

@onready var interactable = $Interactable # Vérifie bien le nom (Interacta ou Interactable)
@onready var audio = $Sound

func _ready() -> void:
	if interactable:
		interactable.is_interactable = true
		interactable.interact = _on_interact
	_update_feedback()

func _on_interact():
	current_mass_state = (current_mass_state + 1) % 3
	_update_feedback()
	if audio: audio.play()
	state_changed.emit() 

func _update_feedback():
	if audio:
		match current_mass_state:
			0: audio.pitch_scale = 1.7 # Vide = Aigu
			1: audio.pitch_scale = 1.0
			2: audio.pitch_scale = 0.6 # Plein = Grave
