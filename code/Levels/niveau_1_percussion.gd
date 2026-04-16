extends Node2D

# Solution : [2, 0, 1] (Full, Empty, Half)
@export var secret_combination: Array[int] = [2, 0, 1] 
var is_solved: bool = false

@onready var bowl1 = $Bowl_1
@onready var bowl2 = $Bowl_2
@onready var bowl3 = $Bowl_3

func _ready() -> void:
	# On écoute les changements sur les bassins
	if bowl1: bowl1.state_changed.connect(_check_solution)
	if bowl2: bowl2.state_changed.connect(_check_solution)
	if bowl3: bowl3.state_changed.connect(_check_solution)
	
	# Lancement de la séquence d'introduction
	_play_intro_dialogue()

func _play_intro_dialogue():
	print("--- INTRO SEQUENCE ---")
	print("Percussion Spirit: 'An intruder... So light, so fragile. You think you can restore Harmony? True power lies not in the wind that blows, but in the weight that strikes! My bowls are empty, their voices weak and piercing. Flee, before I crush you with my tempo!'")
	print("Wind Spirit (Guide): 'Do not listen to him, Guardian. Listen to this empty bowl: it sounds hollow and high-pitched. If you can fill them with water, you will increase their mass...'")

func _check_solution():
	if is_solved: return # Ne rien faire si c'est déjà gagné
	
	var state1 = bowl1.current_mass_state if bowl1 else 0
	var state2 = bowl2.current_mass_state if bowl2 else 0
	var state3 = bowl3.current_mass_state if bowl3 else 0
	
	var current_state = [state1, state2, state3]
	
	if current_state == secret_combination:
		is_solved = true
		_play_victory_sequence()
	else:
		# Optionnel : Petit indice si le joueur galère
		# print("Wind Spirit: 'Focus on the mass! More water = more mass = lower frequency.'")
		pass

func _play_victory_sequence():
	print("--- VICTORY SEQUENCE ---")
	
	# Désactive les bassins pour que le joueur ne les dérègle plus
	if bowl1 and bowl1.has_node("Interactable"): bowl1.get_node("Interactable").is_interactable = false
	if bowl2 and bowl2.has_node("Interactable"): bowl2.get_node("Interactable").is_interactable = false
	if bowl3 and bowl3.has_node("Interactable"): bowl3.get_node("Interactable").is_interactable = false
	
	print("Percussion Spirit: 'I... I hear it. The depth. The gravity. You understand the secret of matter, little Guardian. You played with mass to tame the frequency.'")
	
	print("--- SERIOUS GAME PANEL UI ---")
	print("Concept Validated: The Influence of Mass on Frequency")
	print("By adding water to the bronze bowls, you increased their overall mass. In acoustic physics, the more massive and heavy a resonating body is, the more it resists movement. It therefore vibrates more slowly, producing a low-frequency wave (a deep sound). Conversely, a light object vibrates quickly, creating a high-pitched sound.")
	
	print("Percussion Spirit: 'Take this. Let its weight remind you that even the heaviest stone can sing if properly tuned.'")
	print("*Item Received: Ancient Stone Pestle*")
