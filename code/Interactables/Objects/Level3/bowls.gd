extends Node2D

signal state_changed
var current_mass_state: int = 0 

@onready var interactable = $Interactable 
@onready var interactable2 = $Interactable2
@onready var audio = $Sound
@onready var vide = $bassin_vide

func _ready() -> void:
	if interactable:
		interactable.is_interactable = true
		interactable.interact = _on_interact
	_update_feedback()
	if interactable2:
		interactable2.is_interactable = true
		interactable2.interact = _on_interact2
	_update_feedback()
	
func _on_interact():
	_update_feedback()
	if audio: audio.play()

func _update_feedback():
	if audio:
		match current_mass_state:
			0: audio.pitch_scale = 1.7 # Vide = Aigu
			1: audio.pitch_scale = 0.7 # Plein = Grave
			
func _on_interact2():
	current_mass_state = (current_mass_state + 1) % 2
	
	var target_alpha = 0.0 if vide.visible else 1.0
	vide.visible = true  # important sinon on ne verra pas le fade
	
	var tween = create_tween()
	tween.tween_property(vide, "modulate:a", target_alpha, 0.5)
	
	if target_alpha == 0.0:
		tween.tween_callback(func(): vide.visible = false)
	
	state_changed.emit()
