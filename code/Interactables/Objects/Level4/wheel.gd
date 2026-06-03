extends Node2D

signal pressure_stabilized
signal pressure_destabilized

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
					audio.pitch_scale = randf_range(0.6, 1.4) 
					audio.play()
				pressure_destabilized.emit()
				
			2:
				interactable.interact_name = "Turn wheel (Air: STABLE)"
				if audio:
					audio.pitch_scale = 1.0 
					audio.play()
				pressure_stabilized.emit()
				interactable.is_interactable = false
