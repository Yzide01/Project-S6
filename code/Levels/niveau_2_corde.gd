extends Node2D

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
var is_locked: bool = true

# On charge le fichier de dialogue
var level2_dialogue = load("res://Dialogues/Level2/Strings.dialogue")

@onready var interactable_area = $Interactable

func _ready() -> void:
	add_to_group("Piano")
	if interactable_area:
		interactable_area.interact_name = "Inspect piano"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if is_locked:
		# On ne lance QUE le dialogue d'inactivité si le piano est bloqué
		_play_dialogue("piano_inactive")
	else:
		# On ne lance QUE le dialogue actif si on a les 3 partitions
		await _play_dialogue("piano_active")
		# Ici tu lances ta musique ou ton mini-jeu
		interactable_area.is_interactable = false 

# Cette fonction est appelée UNIQUEMENT par la partition quand elle est ramassée
func ajouter_partition() -> void:
	partitions_actuelles += 1
	
	# Sécurité : On vérifie que le titre du dialogue existe bien (ex: find_fragment_1)
	var dialogue_title = "find_fragment_" + str(partitions_actuelles)
	_play_dialogue(dialogue_title)
	
	if partitions_actuelles >= partitions_requises:
		unlock()

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Play melody"

func _play_dialogue(title: String):
	var player = get_tree().get_root().find_child("Player", true, false)
	
	# Empêcher de lancer un dialogue vide ou invalide
	if not level2_dialogue: return

	if player: player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# DialogueManager ne lancera que la section demandée (~ title)
	DialogueManager.show_example_dialogue_balloon(level2_dialogue, title)
	await DialogueManager.dialogue_ended
	
	if player: player.process_mode = Node.PROCESS_MODE_INHERIT
