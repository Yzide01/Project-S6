extends Node2D

@export var secret_combination: Array[int] = [1, 3, 2]
var current_sequence: Array[int] = []

# Références aux nœuds Logic (à placer dans votre scène héritée)
@onready var door = $Node2D/MagicDoor # Votre instance de Door.tscn
@onready var strings_container = $Node2D/Strings

func _ready() -> void:
	# Initialisation de la porte
	if door:
		door.is_open = false
		door.label_closed = "Mélodie requise"
		door._update_door_state()
		door.interactable.is_interactable = false # Empêche l'ouverture manuelle

	# Connexion automatique aux signaux des cordes enfants
	for string in strings_container.get_children():
		if string.has_signal("played"):
			string.played.connect(_on_string_played)

func _on_string_played(id: int) -> void:
	current_sequence.append(id)
	print("Séquence actuelle : ", current_sequence)

	if current_sequence.size() == secret_combination.size():
		if current_sequence == secret_combination:
			_solve_puzzle()
		else:
			print("Mauvaise mélodie ! On recommence.")
			current_sequence.clear()

func _solve_puzzle() -> void:
	print("Porte déverrouillée !")
	if door:
		door.is_open = true
		door.label_open = "Entrer"
		door.interactable.is_interactable = true 
		door._update_door_state() # Ouvre physiquement la porte
	
	# Désactive les cordes pour ne plus pouvoir jouer
	for string in strings_container.get_children():
		string.is_interactable = false
