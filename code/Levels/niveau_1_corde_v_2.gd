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

func _on_door_hint_requested() -> void:
	if is_playing_hint:
		return
		
	is_playing_hint = true
	current_sequence.clear() # On remet à zéro quand on redemande l'indice
	print("Lecture de l'indice sonore...")
	
	if audio_hint:
		audio_hint.play()
		await audio_hint.finished 
	else:
		await get_tree().create_timer(3.0).timeout 
		
	is_playing_hint = false
	print("Fin de l'indice, à vous de jouer.")

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
	
	# Mise à jour avec le bon nom "Interactable"
	if corde1 and corde1.has_node("Interactable"):
		corde1.get_node("Interactable").is_interactable = false
	if corde2 and corde2.has_node("Interactable"):
		corde2.get_node("Interactable").is_interactable = false
	if corde3 and corde3.has_node("Interactable"):
		corde3.get_node("Interactable").is_interactable = false
