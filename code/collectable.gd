extends InteractableObject

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Cette fonction sera appelée par les partitions quand on marche dessus
func ajouter_partition() -> void:
	partitions_actuelles += 1
	print("Le piano a reçu une partition ! Total : ", partitions_actuelles)

# L'interaction quand le joueur appuie sur la touche
func interact(player: Node2D) -> void:
	if partitions_actuelles >= partitions_requises:
		print("Toutes les partitions sont là. Musique !")
		is_interactable = false # On désactive pour ne pas relancer
		audio_player.play()
	else:
		print("Il manque des partitions... J'en ai : ", partitions_actuelles)
