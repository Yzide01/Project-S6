extends Node2D

@export var battle_scene_packed: PackedScene
@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
@onready var dampener_data = preload("res://Entities/Enemies/dampener.tres")
var current_battle_scene: Node = null

# --- VARIABLES ---
var is_solved: bool = false
var is_dialogue_playing: bool = false

var has_talked_at_edge: bool = false
var has_seen_wheel: bool = false
var spirit_has_appeared: bool = false
var has_finished_level: bool = false
@onready var wheel = $wheel
@onready var altar_door = $altar
@onready var spirit_sprite = $PercussionSpirit 
@onready var spawn_point = $SpawnPoint 
@onready var tilemap = $tambours_ok
@onready var book_page = $BookPage

var intro_dialogue = load("res://Dialogues/Level4/Intro.dialogue")

func _ready() -> void:
	if spirit_sprite:
		spirit_sprite.modulate.a = 0.0
		spirit_sprite.hide()
	if altar_door and altar_door.has_node("Interactable"):
		altar_door.get_node("Interactable").is_interactable = false
	if wheel:
		wheel.pressure_stabilized.connect(_on_pressure_stable)
		wheel.pressure_destabilized.connect(_on_pressure_unstable)

func _on_edge_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dialogue_playing and not has_talked_at_edge:
		is_dialogue_playing = true
		has_talked_at_edge = true
		
		body.set_physics_process(false) 
		
		DialogueManager.show_example_dialogue_balloon(intro_dialogue, "start")
		await DialogueManager.dialogue_ended
		
		body.set_physics_process(true)
		is_dialogue_playing = false

func _on_drum_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dialogue_playing and not is_solved:
		is_dialogue_playing = true
		
		body.set_physics_process(false)
		
		DialogueManager.show_example_dialogue_balloon(intro_dialogue, "impact_fail")
		await DialogueManager.dialogue_ended
		
		if not spirit_has_appeared:
			spirit_has_appeared = true
			if spirit_sprite:
				spirit_sprite.modulate.a = 1.0
				spirit_sprite.show()
				DialogueManager.show_example_dialogue_balloon(intro_dialogue, "spirit_appears")
				await DialogueManager.dialogue_ended
				
				var tween = create_tween()
				tween.tween_property(spirit_sprite, "modulate:a", 0.0, 1.5)
				await tween.finished
				spirit_sprite.hide()
		
		if spawn_point:
			body.global_position = spawn_point.global_position
		
		body.set_physics_process(true)
		is_dialogue_playing = false

func _on_wheel_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not has_seen_wheel and not is_dialogue_playing and not is_solved:
		has_seen_wheel = true
		is_dialogue_playing = true
		
		body.set_physics_process(false) 
		
		DialogueManager.show_example_dialogue_balloon(intro_dialogue, "find_wheel")
		await DialogueManager.dialogue_ended
		
		body.set_physics_process(true) 
		is_dialogue_playing = false


			
func _on_pressure_stable():
	if not is_solved:
		is_solved = true
		is_dialogue_playing = true
		if tilemap:
			tilemap.visible = true				
		var player = get_tree().get_first_node_in_group("player") 
		if player: player.set_physics_process(false)
		
		DialogueManager.show_example_dialogue_balloon(intro_dialogue, "victory")
		await DialogueManager.dialogue_ended
		
		if player: player.set_physics_process(true)
		is_dialogue_playing = false
		
		if altar_door and altar_door.has_node("Interactable"):
			var int_comp = altar_door.get_node("Interactable")
			int_comp.is_interactable = true
			int_comp.interact_name = "Enter the Altar"
			int_comp.interact = _on_altar_interacted
		await get_tree().create_timer(1.0).timeout
		book_page.victory()
			
func _on_altar_interacted() -> void:
	await start_combat([whisper_data, dampener_data])
	
	await get_tree().create_timer(2.0).timeout        
	SceneManager.changer_niveau("res://Levels/niveau1_vents.tscn")

func _on_pressure_unstable():
	is_solved = false

func _on_finish_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not has_finished_level and not is_dialogue_playing:
		has_finished_level = true
		is_dialogue_playing = true
		
		body.set_physics_process(false)
		
		DialogueManager.show_example_dialogue_balloon(intro_dialogue, "across_the_gap")
		await DialogueManager.dialogue_ended
		
		body.set_physics_process(true) 
		is_dialogue_playing = false

func start_combat(horde: Array[BaseEnemy]) -> void:
	current_battle_scene = battle_scene_packed.instantiate()
	add_child(current_battle_scene)
	current_battle_scene.start_encounter(horde)
	
	await current_battle_scene.tree_exited
	current_battle_scene = null
