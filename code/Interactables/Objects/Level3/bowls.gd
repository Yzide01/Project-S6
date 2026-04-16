extends Node2D

signal state_changed # Envoie un signal au gestionnaire du niveau

# 0 = Empty (High Pitch), 1 = Half-Full (Medium), 2 = Full (Low Pitch)
var current_mass_state: int = 0 

@onready var interactable = $Interactable
@onready var audio = $Sound # AudioStreamPlayer2D

func _ready() -> void:
	if interactable:
		interactable.is_interactable = true
		interactable.interact = _on_interact
	_update_feedback()

func _on_interact():
	# Cycle : Empty -> Half -> Full -> Empty
	current_mass_state = (current_mass_state + 1) % 3
	_update_feedback()
	
	if audio:
		audio.play()
		
	# On prévient le niveau qu'un bassin a changé
	state_changed.emit() 

func _update_feedback():
	# Modifies the pitch based on the simulated mass
	if audio:
		match current_mass_state:
			0: audio.pitch_scale = 1.5 # Low mass = High pitch
			1: audio.pitch_scale = 1.0 # Medium mass = Medium pitch
			2: audio.pitch_scale = 0.6 # High mass = Low pitch
			
	# Updates the text to clearly explain the cycle
	if interactable:
		match current_mass_state:
			0: interactable.interact_name = "Pour water (Currently: Empty / High Pitch)"
			1: interactable.interact_name = "Pour more water (Currently: Half / Medium)"
			2: interactable.interact_name = "Empty the bowl (Currently: Full / Low Pitch)"
