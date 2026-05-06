extends Node2D

# --- CONFIGURATION DES CHEMINS ---
var level6_dialogue = load("res://Dialogues/Level6/Intro.dialogue")

@onready var spirit_winds = $WindSpirit
@onready var inca_ghost = $IncaGhost           
@onready var inca_trigger_area = $IncaTriggerArea 

var player: Node2D
var stele_read: bool = false
var inca_met: bool = false
var puzzle_completed: bool = false

var current_target: int = 5 

func _ready() -> void:
	# 1. Initialisation visuelle
	if spirit_winds:
		spirit_winds.hide()
		spirit_winds.modulate.a = 0.0
	
	if inca_ghost:
		inca_ghost.hide()
		inca_ghost.modulate.a = 0.0
	
	# 2. Lancement de l'introduction automatique
	start_level_intro()

# --- SÉQUENCES AUTOMATIQUES ---

func start_level_intro():
	await get_tree().create_timer(1.0).timeout
	await _play_dialogue("start")

func _on_stele_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not stele_read:
		stele_read = true 
		await _play_dialogue("indice_stele")

func _on_inca_trigger_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not inca_met:
		inca_met = true
		
		# Apparition visuelle de l'Inca en fondu
		if inca_ghost:
			inca_ghost.show()
			var t = create_tween()
			t.tween_property(inca_ghost, "modulate:a", 1.0, 1.5)
			await t.finished
		
		# Dialogue de leçon sur les longueurs
		await _play_dialogue("lecon_inca")


func check_tube(size: int, tube_node: Node2D) -> void:
	if puzzle_completed: return
	
	if size == current_target:
		# Bonne séquence
		print("Bon tube touché : ", size)
		# On cache le tube et on bloque son interaction
		tube_node.hide()
		var interactable = tube_node.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = false
		
		current_target -= 1
		
		# Si on a cliqué sur les 5 dans le bon ordre
		if current_target == 0:
			_on_puzzle_completed()
	else:
		# Mauvaise séquence !
		print("Erreur ! Le joueur a touché le tube ", size, " au lieu de ", current_target)
		
		# dialogue à mettre

		
		reset_puzzle()

func reset_puzzle() -> void:
	current_target = 5
	print("Réinitialisation du puzzle...")
	# On réaffiche tous les tubes (assure-toi qu'ils sont dans le groupe "tubes")
	for tube in get_tree().get_nodes_in_group("tubes"):
		tube.show()
		var interactable = tube.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = true

func _on_puzzle_completed():
	if puzzle_completed: return
	puzzle_completed = true
	
	# Dialogue final de réussite
	await _play_dialogue("success")
	
	# L'esprit disparaît doucement
	if inca_ghost:
		var t = create_tween()
		t.tween_property(inca_ghost, "modulate:a", 0.0, 2.0)
	
	# Logique d'ouverture de porte ou passage au niveau suivant ici
	print("Level 6 Complete - Porte ouverte !")
	
	var exit_door = $Door # Si tu as une porte, mets son nom ici
	if exit_door and exit_door.has_method("unlock"):
		exit_door.unlock()



func _play_dialogue(title: String):
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player: 
		player.process_mode = Node.PROCESS_MODE_DISABLED
	
	if level6_dialogue:
		DialogueManager.show_example_dialogue_balloon(level6_dialogue, title)
		await DialogueManager.dialogue_ended
	else:
		print("ERREUR : res://Dialogues/Level6/Intro.dialogue introuvable")
	
	if player: 
		player.process_mode = Node.PROCESS_MODE_INHERIT
