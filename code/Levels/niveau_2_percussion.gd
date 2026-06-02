extends Node2D

@export var battle_scene_packed: PackedScene
@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
@onready var dampener_data = preload("res://Entities/Enemies/dampener.tres")

# --- VARIABLES D'ÉTAT ---
var is_solved: bool = false
var is_dialogue_playing: bool = false
var has_talked_at_edge: bool = false
var has_seen_wheel: bool = false
var spirit_has_appeared: bool = false
var won = false
var current_battle_scene: Node = null
# --- RÉFÉRENCES NOEUDS ---
@onready var wheel = $wheel
@onready var altar_door = $altar
@onready var spirit_sprite = $PercussionSpirit 
@onready var spirit_sprite2 = $PercussionSpirit2

@onready var spawn_point = $SpawnPoint 
@onready var tilemap = $tambours_ok
@onready var book_page = $BookPage
@onready var finished = false

var intro_dialogue = load("res://Dialogues/Level4/Intro.dialogue")

func _ready() -> void:
	# 1. État initial du visuel
	if spirit_sprite:
		spirit_sprite.modulate.a = 0.0
		spirit_sprite.hide()
	
	# 2. Désactiver l'autel au début
	if altar_door and altar_door.has_node("Interactable"):
		altar_door.get_node("Interactable").is_interactable = false
	
	# 3. Connexion du puzzle de la roue
	if wheel and not wheel.pressure_stabilized.is_connected(_on_pressure_stable):
		wheel.pressure_stabilized.connect(_on_pressure_stable)

	# 4. Branchement automatique des zones de détection
	_force_connect("EdgeTrigger", _on_edge_trigger_body_entered)
	_force_connect("wheel_trigger_simple", _on_wheel_trigger_simple_body_entered)
	_force_connect("DrumTrigger", _on_drum_trigger_body_entered)
	_force_connect("FinishTrigger", _on_finish_trigger_body_entered)

func _force_connect(node_name: String, callback: Callable):
	var target = find_child(node_name, true, false)
	if target:
		if not target.body_entered.is_connected(callback):
			target.body_entered.connect(callback)
			print("SYSTÈME : ", node_name, " prêt.")
	else:
		push_warning("Nœud " + node_name + " introuvable dans la scène.")

# --- GESTION DES ZONES DE DIALOGUE ---

# Dialogue de la roue (déclenche find_wheel)
func _on_wheel_trigger_simple_body_entered(body: Node2D) -> void:
	if _is_player(body) and not has_seen_wheel and not is_dialogue_playing and not is_solved:
		has_seen_wheel = true
		_play_safe_text("find_wheel", body)

# Dialogue du bord (déclenche start)
func _on_edge_trigger_body_entered(body: Node2D) -> void:
	if _is_player(body) and not has_talked_at_edge and not is_dialogue_playing:
		has_talked_at_edge = true
		_play_safe_text("start", body)

# Dialogue de chute + Apparition de l'Esprit
func _on_drum_trigger_body_entered(body: Node2D) -> void:
	if _is_player(body) and not is_dialogue_playing and not is_solved:
		is_dialogue_playing = true
		
		# 1. Dialogue "Ouch"
		await _play_safe_text("impact_fail", body)
		
		# 2. L'esprit arrive
		if not spirit_has_appeared and spirit_sprite:
			spirit_has_appeared = true
			spirit_sprite.show()
			var tw = create_tween()
			tw.tween_property(spirit_sprite, "modulate:a", 1.0, 0.5)
			
			await _play_safe_text("spirit_appears", body)
			
			var tw2 = create_tween()
			tw2.tween_property(spirit_sprite, "modulate:a", 0.0, 0.8)
			await tw2.finished
			spirit_sprite.hide()
		
		# 3. On ramène le joueur au début
		if spawn_point: 
			body.global_position = spawn_point.global_position
		
		is_dialogue_playing = false

# Dialogue après avoir traversé
func _on_finish_trigger_body_entered(body: Node2D) -> void:
	if _is_player(body) and not is_dialogue_playing and not finished:
		finished = true
		_play_safe_text("across_the_gap", body)

# --- LOGIQUE PUZZLE ET VICTOIRE ---

func _on_pressure_stable():
	if not is_solved:
		is_solved = true
		if tilemap: tilemap.visible = true 
		
		var p = get_tree().get_first_node_in_group("Player") 
		await _play_safe_text("victory", p)
		
		_setup_altar()
		if book_page: book_page.victory()

func _setup_altar():
	if altar_door and altar_door.has_node("Interactable"):
		var interact_comp = altar_door.get_node("Interactable")
		interact_comp.is_interactable = true
		interact_comp.interact = _on_altar_interacted

# --- COMBAT ET CHANGEMENT DE NIVEAU ---


func _on_altar_interacted():
	if won == false:
		await start_combat(2)
		
		# SÉCURITÉ : Si le joueur meurt et que le niveau redémarre, on bloque la suite
		if not is_inside_tree() or is_queued_for_deletion():
			return
			
		# On lance la séquence de récompense avec l'esprit
		await _give_vial_sequence()
		
		won = true
	else:
		SceneManager.changer_niveau("res://Levels/niveau1_vents.tscn")

	
func _give_vial_sequence():
	var p = get_tree().get_first_node_in_group("Player")
	if p: p.set_physics_process(false)
	is_dialogue_playing = true
	
	# 1. L'esprit apparaît devant l'autel
	if spirit_sprite2:
		spirit_sprite2.show()
		var tw = create_tween()
		tw.tween_property(spirit_sprite2, "modulate:a", 1.0, 0.5)
		await tw.finished
		
	# 2. Lancement du dialogue (Assure-toi d'avoir une balise "outro" ou "give_vial" dans ton fichier Dialogue)
	DialogueManager.show_example_dialogue_balloon(intro_dialogue, "outro")
	await DialogueManager.dialogue_ended
	
	# 3. Ajout direct de la Fiole Magique dans l'inventaire du joueur !
	var vial_item = load("res://Core/InventorySystem/items/Vial.tres")
	var player_inv = load("res://Core/InventorySystem/playerInventory.tres")
	
	if player_inv and vial_item:
		player_inv.insert(vial_item)
		print("🧪 Fiole magique reçue et ajoutée à l'inventaire !")
	else:
		push_error("Erreur : Impossible de charger l'inventaire ou la fiole.")
		
	# 4. L'esprit disparaît
	if spirit_sprite:
		var tw2 = create_tween()
		tw2.tween_property(spirit_sprite, "modulate:a", 0.0, 0.5)
		await tw2.finished
		spirit_sprite.hide()
		
	is_dialogue_playing = false
	if p: p.set_physics_process(true)



	
func start_combat(niveau_id: int) -> void:
	if not is_inside_tree(): return
	
	get_tree().paused = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	current_battle_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# ⚠️ IMPORTANT : On l'ajoute à la scène AVANT d'appeler la fonction
	ui_layer.add_child(current_battle_scene)
	
	# On lance ta nouvelle fonction avec le numéro du combat !
	current_battle_scene._check_test_mode(niveau_id)
	
	await current_battle_scene.tree_exited
	ui_layer.queue_free()
	if not is_inside_tree() or is_queued_for_deletion():
		return
	get_tree().paused = false
	
	# --- RAPPEL --- 
	# N'oublie pas de laisser ici ton code pour changer de scène 
	# ou lancer la cinématique de fin selon le niveau !
# --- FONCTIONS UTILITAIRES ---

func _play_safe_text(section: String, player: Node2D):
	is_dialogue_playing = true
	if player: player.set_physics_process(false)
	
	DialogueManager.show_example_dialogue_balloon(intro_dialogue, section)
	await DialogueManager.dialogue_ended
	
	if player: player.set_physics_process(true)
	is_dialogue_playing = false

func _is_player(body: Node2D) -> bool:
	return body.is_in_group("Player") or body.name.to_lower().contains("player")

# --- GESTION DE LA SAUVEGARDE DE L'ÉTAT DU NIVEAU ---
func get_level_state() -> Dictionary:
	return {
		"is_solved": is_solved,
		"won": won,
		"finished": finished
	}

func restore_level_state(state: Dictionary) -> void:
	is_solved = state.get("is_solved", false)
	won = state.get("won", false)
	finished = state.get("finished", false)
	
	if is_solved:
		if tilemap: tilemap.visible = true
		_setup_altar()
		if book_page: book_page.queue_free()
