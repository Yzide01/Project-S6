extends Node2D

@export var secret_combination: Array[int] = [1, 3, 2]
var current_sequence: Array[int] = []
var is_playing_hint: bool = false # Empêche le spam pendant le son

@onready var corde1 = $String_1
@onready var corde2 = $String_2
@onready var corde3 = $String_3
@onready var magic_door = $MagicDoor 
@onready var audio_hint = $HintAudioPlayer 

func _ready() -> void:
	if corde1: corde1.played.connect(_on_string_played)
	if corde2: corde2.played.connect(_on_string_played)
	if corde3: corde3.played.connect(_on_string_played)
	
	if magic_door:
		magic_door.hint_requested.connect(_on_door_hint_requested)

# --- LA FONCTION DE L'INDICE ---
func _on_door_hint_requested() -> void:
	if is_playing_hint:
		return
		
	is_playing_hint = true
	current_sequence.clear() # On vide la séquence en cours
	
	# 1. On lance la première réflexion de Mélos
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level1/level1.dialogue"), "start")
	
	# On met le code en pause jusqu'à ce que le joueur ferme la bulle de dialogue
	await DialogueManager.dialogue_ended 
	
	# 2. La porte tremble et joue son son (L'indice Grave-Aigu-Medium)
	if audio_hint:
		audio_hint.play()
	
	# On attend que le son se termine (environ 3 secondes, à ajuster selon ton son)
	await get_tree().create_timer(3.0).timeout
	
	# 3. On lance la suite du dialogue (La déduction de Mélos + L'aide du livre)
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level1/level1.dialogue"), "hint")
	
	# On attend à nouveau que le joueur ferme la dernière bulle
	await DialogueManager.dialogue_ended

	# Fin de la cinématique, le joueur peut jouer sur les cordes !
	is_playing_hint = false


func _on_string_played(id: int) -> void:
	if is_playing_hint:
		return

	# On ajoute la note jouée
	current_sequence.append(id)
	
	if current_sequence.size() > secret_combination.size():
		current_sequence.pop_front()

	print("Séquence en cours : ", current_sequence)

	# On vérifie simplement si les 3 dernières notes sont les bonnes
	if current_sequence == secret_combination:
		_solve_puzzle()


func _solve_puzzle() -> void:
	print("Énigme résolue ! La porte est déverrouillée.")
	if magic_door:
		magic_door.unlock()
	
	## --- ON OUVRE LE LIVRE ICI ---
	#if has_node("BookUI"):
		#$BookUI.open_book(
			#"LESSON I: THE DIMENSION OF SOUND", 
			#"Length dictates the note.\n\nLong String = Low Frequency.\nLarger objects vibrate slower, creating a Deep sound.", 
			#"\n\nShort String = High Frequency.\nSmaller objects vibrate faster, creating a High sound."
		#)
	## -----------------------------
	
	# Mise à jour avec le bon nom "Interactable" pour désactiver les cordes
	if corde1 and corde1.has_node("Interactable"):
		corde1.get_node("Interactable").is_interactable = false
	if corde2 and corde2.has_node("Interactable"):
		corde2.get_node("Interactable").is_interactable = false
	if corde3 and corde3.has_node("Interactable"):
		corde3.get_node("Interactable").is_interactable = false
