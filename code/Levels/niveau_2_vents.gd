extends Node2D

var level6_dialogue = load("res://Dialogues/Level6/Intro.dialogue")

@export var battle_scene_packed: PackedScene

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
@onready var dampener_data = preload("res://Entities/Enemies/dampener.tres")
@onready var devourer_data = preload("res://Entities/Enemies/devourer.tres") 
@onready var book_page = $BookPage

@onready var spirit_winds = $WindSpirit
@onready var inca_ghost = $IncaGhost            
@onready var inca_trigger_area = $IncaTriggerArea 
@onready var exit = $Exit
@onready var flute = $flupe_pan
var player: Node2D
var current_battle_scene: Node = null
var stele_read: bool = false
var inca_met: bool = false
var puzzle_completed: bool = false
var is_dialogue_playing: bool = false
var current_target: int = 5 

func _ready() -> void:
	flute.visible = false
	if spirit_winds:
		spirit_winds.hide()
		spirit_winds.modulate.a = 0.0
	
	if inca_ghost:
		inca_ghost.hide()
		inca_ghost.modulate.a = 0.0
		
	if exit:
		exit.start_level_combat.connect(_on_exit_interacted_for_combat)
	start_level_intro()
	


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
		
		if inca_ghost:
			inca_ghost.show()
			var t = create_tween()
			t.tween_property(inca_ghost, "modulate:a", 1.0, 1.5)
			await t.finished
		
		await _play_dialogue("lecon_inca")


func check_tube(size: int, tube_node: Node2D) -> void:
	if puzzle_completed: return
	
	if size == current_target:
		print("Bon tube touché : ", size)
		tube_node.hide()
		var interactable = tube_node.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = false
		
		current_target -= 1
		
		if current_target == 0:
			_on_puzzle_completed()
	else:
		print("Erreur ! Le joueur a touché le tube ", size, " au lieu de ", current_target)
		# dialogue à mettre
		reset_puzzle()

func reset_puzzle() -> void:
	current_target = 5
	print("Réinitialisation du puzzle...")
	for tube in get_tree().get_nodes_in_group("tubes"):
		tube.show()
		var interactable = tube.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = true


func _on_puzzle_completed():
	flute.visible = true
	if puzzle_completed: return
	puzzle_completed = true
	exit.unlock()
	await _play_dialogue("success")

	if inca_ghost:
		var t = create_tween()
		t.tween_property(inca_ghost, "modulate:a", 0.0, 2.0)
	book_page.victory()
	#await get_tree().create_timer(10.0).timeout


	# Création forcée de la horde avec les 3 ennemis !
	#var ma_horde: Array[BaseEnemy] = []
	#ma_horde.append(whisper_data)
	#ma_horde.append(dampener_data)
	#ma_horde.append(devourer_data)
	#
	#await start_combat(ma_horde)
	
	print("Level 6 Complete - Porte ouverte !")

func _on_exit_interacted_for_combat() -> void:
	var ma_horde: Array[BaseEnemy] = [whisper_data, dampener_data,devourer_data]
	start_combat(ma_horde)

func start_combat(horde: Array[BaseEnemy]) -> void:
	player = get_tree().get_root().find_child("Player", true, false)
	if player: 
		player.set_physics_process(false)
	is_dialogue_playing = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 1000 
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	ui_layer.add_child(current_battle_scene)
	
	var intro = "The final trial! You must face all three types of enemies at once. Use your Strings, Percussions, and your newly unlocked Winds to secure victory!"
	
	# Création forcée du tableau d'instruments (Le joueur a tout maintenant !)
	var mes_instruments: Array[String] = []
	mes_instruments.append("corde")
	mes_instruments.append("percussion")
	mes_instruments.append("vent") # Ajuste si ton instrument s'appelle autrement (ex: "wind")
	
	current_battle_scene.start_encounter(horde, mes_instruments, intro)
	
	await current_battle_scene.tree_exited
	
	ui_layer.queue_free()
	current_battle_scene = null
	
	if player: 
		player.set_physics_process(true)
	is_dialogue_playing = false


# --- SYSTÈME DE DIALOGUE ---

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
