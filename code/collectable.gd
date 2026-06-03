extends InteractableObject

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func ajouter_partition() -> void:
	partitions_actuelles += 1

func interact(player: Node2D) -> void:
	if partitions_actuelles >= partitions_requises:
		is_interactable = false
		audio_player.play()
