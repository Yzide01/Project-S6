extends Node2D

@export var secret_combination: Array[int] = [1, 3, 2]
var current_sequence: Array[int] = []

@onready var corde1 = $String_1
@onready var corde2 = $String_2
@onready var corde3 = $String_3
@onready var magic_door = $MagicDoor 

func _ready() -> void:
	# On connecte les signaux émis par tes Node2D
	if corde1: corde1.played.connect(_on_string_played)
	if corde2: corde2.played.connect(_on_string_played)
	if corde3: corde3.played.connect(_on_string_played)

func _on_string_played(id: int) -> void:
	current_sequence.append(id)
	print("Séquence en cours : ", current_sequence)

	if current_sequence.size() == secret_combination.size():
		if current_sequence == secret_combination:
			_solve_puzzle()
		else:
			print("Mauvaise mélodie ! On efface tout.")
			current_sequence.clear()

func _solve_puzzle() -> void:
	print("Énigme résolue ! La porte s'ouvre.")
	
	if magic_door:
		magic_door.unlock()
	
	# On désactive l'interaction des cordes pour bloquer le jeu
	if corde1 and corde1.has_node("InteractableArea"):
		corde1.get_node("InteractableArea").is_interactable = false
	if corde2 and corde2.has_node("InteractableArea"):
		corde2.get_node("InteractableArea").is_interactable = false
	if corde3 and corde3.has_node("InteractableArea"):
		corde3.get_node("InteractableArea").is_interactable = false
