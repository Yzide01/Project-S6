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
		
	# Joue le son !
	if audio_player:
		audio_player.play()
	
	print("La corde ", note_id, " vibre !")
	corde_jouee.emit(note_id) 

# --- NOUVELLE FONCTION POUR L'EFFET MAGIQUE ---

# Cette fonction active ou désactive la brillance de manière progressive
func set_progressive_glow(active: bool) -> void:
	# On crée un "Tween", un outil génial pour faire des animations fluides par code
	var tween = create_tween()
	
	if active:
		# On fait apparaître le sprite brillant (alpha = 1.0) en 0.5 secondes
		tween.tween_property(sprite_brillant, "modulate:a", 1.0, 0.5)
	else:
		# On le fait disparaître (alpha = 0.0) instantanément (0.0 secondes)
		tween.tween_property(sprite_brillant, "modulate:a", 0.0, 0.0)
