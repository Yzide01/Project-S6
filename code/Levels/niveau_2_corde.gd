extends Node2D

@export var battle_scene_packed: PackedScene

@onready var book_page = $decoration/BookPage
@onready var piano = $decoration/Piano

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
var current_battle_scene: Node = null
var has_spoken_about_zone: bool = false
var page_collected: bool = false

func _ready() -> void:
	if piano:
		piano.victory.connect(_victory)

# --- VICTOIRE AU PIANO ---
func _victory():
	if book_page:
		book_page.victory()
		# On attend que le joueur récupère la page
		await book_page.page_picked
		page_collected = true
		# Message de confirmation (assure-toi d'avoir ~ page_collected dans ton .dialogue)
		_play_dialogue("page_collected")

# --- ZONE DE SORTIE (DÉCLENCHE LE COMBAT) ---
func _on_exit_zone_body_entered(body: Node2D) -> void:
	# On vérifie que c'est le Player et qu'il a la page
	if (body.name == "Player" or body.is_in_group("Player")) and page_collected:
		var ma_horde: Array[BaseEnemy] = [whisper_data]
		start_combat(ma_horde)

func start_combat(horde: Array[BaseEnemy]) -> void:
	if not is_inside_tree(): return
	
	get_tree().paused = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	current_battle_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_layer.add_child(current_battle_scene)
	
	var mes_instruments: Array[String] = ["corde"]
	var intro = "The Whisper is fragile, but its silence is deadly."
	
	current_battle_scene.start_encounter(horde, mes_instruments, intro)
	
	await current_battle_scene.tree_exited
	ui_layer.queue_free()
	
	get_tree().paused = false
	# On change de niveau après la fin du combat
	SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")

# --- ZONE D'EXPLORATION ---
func _on_exploration_zone_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("Player")) and not has_spoken_about_zone:
		has_spoken_about_zone = true
		_play_dialogue("explore_zone")

func _play_dialogue(section_name: String):
	var diag_path = "res://Dialogues/Level2/level2.dialogue"
	if FileAccess.file_exists(diag_path):
		DialogueManager.show_example_dialogue_balloon(load(diag_path), section_name)
