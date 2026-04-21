extends Node2D

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
var is_locked: bool = true

@onready var interactable_area = $Interactable
@onready var audio_player = $AudioStreamPlayer2D

func _ready() -> void:
	# On configure l'interaction exactement comme la porte
	if interactable_area:
		interactable_area.interact_name = "Inspecter le piano"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if is_locked:
		print("Il manque des partitions... J'en ai : ", partitions_actuelles)
		# Ici tu pourras mettre la pensée du joueur
	else:
		print("Le joueur joue la mélodie !")
		interactable_area.is_interactable = false # On désactive après avoir joué
		if audio_player:
			audio_player.play()

# Cette fonction sera appelée par les partitions
func ajouter_partition() -> void:
	partitions_actuelles += 1
	print("Partition reçue par le piano ! Total : ", partitions_actuelles)
	
	# Si on a le compte, on déverrouille le piano !
	if partitions_actuelles >= partitions_requises:
		unlock()

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Jouer la mélodie"
