extends Node2D

@export var battle_scene_packed: PackedScene

@onready var book_page = $decoration/BookPage
@onready var piano = $decoration/Piano
@onready var exit = $Exit

# --- AJOUT DE L'ESPRIT ICI (Vérifie le nom du nœud !) ---
@onready var spirit_sprite = $Spirit 

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
var current_battle_scene: Node = null
var has_spoken_about_zone: bool = false
var page_collected: bool = false
@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")
@onready var vial: InventoryItem = preload("res://Core/InventorySystem/items/Vial.tres")

func _ready() -> void:
	if piano:
		piano.victory.connect(_victory)
		
	if exit:
		exit.start_level_combat.connect(_on_exit_interacted_for_combat)
		
	# On s'assure que l'esprit est invisible au début du niveau
	if spirit_sprite:
		spirit_sprite.hide()
		spirit_sprite.modulate.a = 0.0

# --- VICTOIRE AU PIANO ---
func _victory():
	if book_page:
		book_page.victory()
		
		# 1. On attend que le joueur récupère la page
		await book_page.page_picked
		page_collected = true
		
			
		await get_tree().create_timer(0.5).timeout
		
		# 6. Dialogue du joueur
		await _play_dialogue_async("page_collected")
		
		exit.unlock()

var won = false

# --- QUAND LE JOUEUR CLIQUE SUR LA SORTIE ---
func _on_exit_interacted_for_combat() -> void:
	if won == true:
		SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")
		return
	if page_collected:
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
	var intro = "You only have your Strings, this attack doesn't deal much damage, but it lets you thin out the crowd—and who knows, maybe it'll scare them off\nThe Whisper is a fragile minion, but its silence is deadly."
	
	current_battle_scene.start_encounter(horde, mes_instruments, intro)
	
	await current_battle_scene.tree_exited
	ui_layer.queue_free()
	
	get_tree().paused = false
	
	# On bloque les mouvements du joueur pendant la séquence
	var p = get_tree().get_first_node_in_group("Player")
	if p: p.set_physics_process(false)
	
	# 2. Apparition de l'esprit
	if spirit_sprite:
		spirit_sprite.show()
		var tw = create_tween()
		tw.tween_property(spirit_sprite, "modulate:a", 1.0, 0.5)
		await tw.finished
	
	# 3. Dialogue de reconnaissance
	await _play_dialogue_async("reconnaissance")
	
	# 4. L'esprit donne 1 fiole magique
	if inventory and vial:
		inventory.insert(vial)
		print("🧪 Fiole magique reçue !")
		
	# 5. Disparition de l'esprit
	if spirit_sprite:
		var tw2 = create_tween()
		tw2.tween_property(spirit_sprite, "modulate:a", 0.0, 0.5)
		await tw2.finished
		spirit_sprite.hide()
	# On rend les contrôles au joueur
	if p: p.set_physics_process(true)
	won = true
	

# --- ZONE D'EXPLORATION ---
func _on_exploration_zone_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("Player")) and not has_spoken_about_zone:
		has_spoken_about_zone = true
		_play_dialogue("explore_zone")


# --- FONCTIONS DE DIALOGUES ---

# Dialogue qui ne bloque pas le jeu (quand on marche dans une zone)
func _play_dialogue(section_name: String):
	var diag_path = "res://Dialogues/Level2/level2.dialogue"
	if FileAccess.file_exists(diag_path):
		DialogueManager.show_example_dialogue_balloon(load(diag_path), section_name)

# NOUVEAU : Dialogue qui met le script en pause le temps que le joueur lise
func _play_dialogue_async(section_name: String):
	var diag_path = "res://Dialogues/Level2/level2.dialogue"
	if FileAccess.file_exists(diag_path):
		DialogueManager.show_example_dialogue_balloon(load(diag_path), section_name)
		await DialogueManager.dialogue_ended
