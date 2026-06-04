extends InteractableObject

signal corde_jouee(note_id: int)

@export var note_id: int = 1 
@onready var audio_player = $AudioStreamPlayer2D 
@onready var sprite_brillant: Sprite2D = $SpriteGlow

func _ready() -> void:
	object_name = "Corde"

func interact(_player: Node2D) -> void:
	if not is_interactable:
		return
		
	if audio_player:
		audio_player.play()
	
	corde_jouee.emit(note_id) 

# --- MAGIC EFFECT FUNCTION ---

func set_progressive_glow(active: bool) -> void:
	var tween = create_tween()
	
	if active:
		tween.tween_property(sprite_brillant, "modulate:a", 1.0, 0.5)
	else:
		tween.tween_property(sprite_brillant, "modulate:a", 0.0, 0.0)
