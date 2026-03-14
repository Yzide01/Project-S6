extends InteractableObject

signal corde_jouee(id_corde: int) # Signal envoyé au niveau quand on interagit

@export var note_id: int = 1 # 1 = Sol, 2 = Re, 3 = La, 4 = Mi
@export var pitch_value: float = 1.0 # Pour modifier la hauteur du son

@onready var audio_player = $AudioStreamPlayer2D

func _ready() -> void:
	object_name = "Corde"
	audio_player.pitch_scale = pitch_value # Plus la valeur est haute, plus c'est aigu

func interact(_player: Node2D) -> void:
	if not is_interactable:
		return
	
	audio_player.play() # Joue le son
	corde_jouee.emit(note_id) # Prévient le gestionnaire du niveau
	print("Corde ", note_id, " jouée !")
