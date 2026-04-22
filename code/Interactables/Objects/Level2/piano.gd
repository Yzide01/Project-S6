extends Node2D

@export var partitions_requises: int = 3
var partitions_actuelles: int = 0
var is_locked: bool = true

@onready var interactable_area = $Interactable
@onready var audio_player = $AudioStreamPlayer2D

# On charge ton fichier de dialogue (le chemin exact vient de ton fichier .import !)
const DIALOGUE_FILE = preload("res://Dialogues/Level2/level2.dialogue")

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Inspecter le piano"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	if is_locked:
		# Le piano n'a pas encore toutes les partitions
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "piano_inactive")
	else:
		# Le joueur a tout trouvé et interagit pour jouer
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "piano_active")
		
		interactable_area.is_interactable = false # On désactive l'interaction
		if audio_player:
			audio_player.play() # La musique se lance !

# Cette fonction est appelée automatiquement par les partitions quand on les ramasse
func ajouter_partition() -> void:
	partitions_actuelles += 1
	
	# On lance la bonne pensée selon le nombre de partitions trouvées
	if partitions_actuelles == 1:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_1")
	elif partitions_actuelles == 2:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_2")
	elif partitions_actuelles >= partitions_requises:
		DialogueManager.show_example_dialogue_balloon(DIALOGUE_FILE, "find_fragment_3")
		unlock() # On déverrouille le piano !

func unlock() -> void:
	is_locked = false
	if interactable_area:
		interactable_area.interact_name = "Jouer la mélodie"
