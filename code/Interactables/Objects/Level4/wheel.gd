extends Node2D

signal pressure_stabilized
signal pressure_destabilized

# 0 = Off, 1 = Manual Bellows (Unstable), 2 = Hydraulis (Stable)
var pressure_state: int = 0 
var count: int = 0 

@onready var wheel_animated_sprite = $AnimatedSprite2D
@onready var interactable = $Interactable
@onready var audio = $Sound

func _ready() -> void:
	if interactable:
		interactable.is_interactable = true
		interactable.interact = _on_interact
	_update_feedback()

func _on_interact():
	# Cycle through the 3 states
	pressure_state = (pressure_state + 1) % 3
	_update_feedback()
	count += 1 
	
	if count == 1:
		if wheel_animated_sprite:
			wheel_animated_sprite.speed_scale = 1.0
			wheel_animated_sprite.play("tourner")
			
	elif count == 2:
		if wheel_animated_sprite:
			wheel_animated_sprite.speed_scale = 2.0
			
		# Optionnel : Si tu veux bloquer l'objet après la deuxième interaction
		# if interactable_area:
		# 	interactable_area.is_interactable = false

func _update_feedback():
	if interactable:
		match pressure_state:
			0:
				interactable.interact_name = "Turn wheel (Air: OFF)"
				if audio: audio.stop()
				pressure_destabilized.emit()
				
			1:
				interactable.interact_name = "Turn wheel (Air: UNSTABLE)"
				if audio:
					# Random pitch simulates human fatigue and chaotic pressure
					audio.pitch_scale = randf_range(0.6, 1.4) 
					audio.play()
				pressure_destabilized.emit()
				
			2:
				interactable.interact_name = "Turn wheel (Air: STABLE)"
				if audio:
					# Perfect 1.0 pitch simulates the constant weight of water
					audio.pitch_scale = 1.0 
					audio.play()
				pressure_stabilized.emit()
				interactable.is_interactable = false
