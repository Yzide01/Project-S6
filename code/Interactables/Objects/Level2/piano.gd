extends InteractableObject

@export var partitions_requises: int = 3
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func interact(player: Node2D) -> void:
	# 1. On compte combien de partitions le joueur possède dans son inventaire
	var partitions_trouvees = 0
	
	if player.inventory:
		for slot in player.inventory.slots:
			if slot.item and slot.item.name == "Partition":
				partitions_trouvees += slot.amount

	# 2. On vérifie si on a le bon compte
	if partitions_trouvees >= partitions_requises:
		_jouer_musique_finale()
	else:
		_lancer_pensee_manquante()

func _jouer_musique_finale() -> void:
	is_interactable = false # On désactive le piano pour qu'il ne se relance pas
	audio_player.play()
	print("Bravo ! La musique finale se joue.")
	# Optionnel : lancer un dialogue de fin ici

func _lancer_pensee_manquante() -> void:
	# On lance le dialogue qui dit qu'il manque des partitions
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level2/level2.dialogue"), "partitions_manquantes")
