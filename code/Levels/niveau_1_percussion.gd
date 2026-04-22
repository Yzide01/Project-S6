extends Node2D

# --- CONFIGURATION ---
@export var intro_position: Vector2
@export var outro_position: Vector2
@export var secret_combination: Array[int] = [2, 0, 1] 

# --- RÉFÉRENCES ---
@onready var spirit = $PercussionSpirit
@onready var bowls = [$Bowl_1, $Bowl_2, $Bowl_3]

var is_solved: bool = false

func _ready() -> void:
	# 1. Cacher l'esprit proprement au début
	if spirit:
		spirit.hide()
		spirit.modulate.a = 0.0
	
	# 2. Brancher les bassins
	for b in bowls:
		if b and b.has_signal("state_changed"):
			b.state_changed.connect(_check_solution)
	
	# 3. Lancer l'intro
	await get_tree().create_timer(0.3).timeout
	_play_sequence(intro_position, "res://Dialogues/Level3/Intro.dialogue")

func _check_solution():
	if is_solved: return
	var current = [bowls[0].current_mass_state, bowls[1].current_mass_state, bowls[2].current_mass_state]
	if current == secret_combination:
		is_solved = true
		_play_sequence(outro_position, "res://Dialogues/Level3/Outro.dialogue")

func _play_sequence(pos, diag_path):
	# A. CHERCHER ET BLOQUER LE JOUEUR
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# On coupe tout : Physique + Clavier + Processus
		player.set_physics_process(false)
		player.set_process_input(false)
		player.process_mode = Node.PROCESS_MODE_DISABLED
		print("DEBUG: Mélos est totalement bloqué")

	# B. APPARITION DE L'ESPRIT (Valeurs corrigées 1.0 et 0.8)
	if spirit:
		spirit.global_position = pos
		spirit.show()
		var t = create_tween()
		t.tween_property(spirit, "modulate:a", 1.0, 0.8) # 1.0 = visible
		await t.finished

	# C. DIALOGUE
	if FileAccess.file_exists(diag_path):
		DialogueManager.show_example_dialogue_balloon(load(diag_path), "start")
		await DialogueManager.dialogue_ended
	else:
		print("ERREUR: Dialogue introuvable à ", diag_path)
	
	# D. DISPARITION DE L'ESPRIT
	if spirit:
		var t2 = create_tween()
		t2.tween_property(spirit, "modulate:a", 0.0, 0.8) # 0.0 = invisible
		await t2.finished
		spirit.hide()

	# E. LIBÉRATION DU JOUEUR
	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.set_physics_process(true)
		player.set_process_input(true)
		print("DEBUG: Mélos est libre")
