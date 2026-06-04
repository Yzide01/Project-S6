extends Node2D

var level6_dialogue = load("res://Dialogues/Level6/Intro.dialogue")

@export var battle_scene_packed: PackedScene
@onready var audio = $AudioStreamPlayer2D

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
@onready var dampener_data = preload("res://Entities/Enemies/dampener.tres")
@onready var devourer_data = preload("res://Entities/Enemies/devourer.tres") 
@onready var book_page = $BookPage

@onready var spirit_winds = $WindSpirit
@onready var inca_ghost = $IncaGhost            
@onready var inca_trigger_area = $IncaTriggerArea 
@onready var exit = $Exit
@onready var flute = $flute_pan
@onready var flute_inca = $flute_pan2
@export var endgame_video_path: String = "res://Assets/Videos/final_vial_scene.ogv"

var player: Node2D
var current_battle_scene: Node = null
var stele_read: bool = false
var inca_met: bool = false
var puzzle_completed: bool = false
var is_dialogue_playing: bool = false
var current_target: int = 5 

func _ready() -> void:
	if flute:
		flute.hide()
		flute.visible = false
		flute.modulate.a = 0.0
		
	if flute_inca:
		flute_inca.hide()
		flute_inca.visible = false
		flute_inca.modulate.a = 0.0
		
	if spirit_winds:
		spirit_winds.hide()
		spirit_winds.visible = false
		spirit_winds.modulate.a = 0.0
	
	if inca_ghost:
		inca_ghost.hide()
		inca_ghost.visible = false
		inca_ghost.modulate.a = 0.0
		
	if exit:
		exit.start_level_combat.connect(_on_exit_interacted_for_combat)
	start_level_intro()

func start_level_intro():
	await get_tree().create_timer(1.0).timeout
	if puzzle_completed:
		var generic = load("res://Dialogues/Generic/LevelCompleted.dialogue")
		if generic: DialogueManager.show_example_dialogue_balloon(generic, "start")
		return
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
			inca_ghost.visible = true
			var t = create_tween()
			t.tween_property(inca_ghost, "modulate:a", 1.0, 1.5)
			await t.finished
		
		await _play_dialogue("lecon_inca")
		
		if inca_ghost:
			var t_fade = create_tween()
			t_fade.tween_property(inca_ghost, "modulate:a", 0.0, 1.0)
			await t_fade.finished
			inca_ghost.hide()

func check_tube(size: int, tube_node: Node2D) -> void:
	if puzzle_completed: return
	
	if size == current_target:
		tube_node.hide()
		var interactable = tube_node.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = false
		
		current_target -= 1
		
		if current_target == 0:
			_on_puzzle_completed()
	else:
		reset_puzzle()

func reset_puzzle() -> void:
	current_target = 5
	for tube in get_tree().get_nodes_in_group("tubes"):
		tube.show()
		var interactable = tube.get_node_or_null("Interactable")
		if interactable:
			interactable.is_interactable = true
func _on_puzzle_completed():
	if puzzle_completed: return
	puzzle_completed = true
	exit.unlock()
	await get_tree().create_timer(0.5).timeout
	
	# --- FINAL VISUAL SEQUENCE ---
	var fade_tween = create_tween().set_parallel(true)
	
	if flute_inca:
		flute_inca.show()
		fade_tween.tween_property(flute_inca, "modulate:a", 1.0, 1.0)
		
	if flute:
		flute.show()
		fade_tween.tween_property(flute, "modulate:a", 1.0, 1.0)
		
	await fade_tween.finished
	
	if audio:
		audio.volume_db = 0.0
		audio.play()
		
	await _play_dialogue("success")

	if spirit_winds:
		spirit_winds.show()
		var t_wind = create_tween()
		t_wind.tween_property(spirit_winds, "modulate:a", 1.0, 0.6)
		await t_wind.finished

	await _play_dialogue("suite_success")

	# --- SPIRITS FINAL DISAPPEARANCE ---
	var final_fade = create_tween().set_parallel(true)
	
	if flute_inca: 
		final_fade.tween_property(flute_inca, "modulate:a", 0.0, 1.5)
	if spirit_winds: 
		final_fade.tween_property(spirit_winds, "modulate:a", 0.0, 1.5)
		
	if audio and audio.playing:
		final_fade.tween_property(audio, "volume_db", -60.0, 1.5)
		
	await final_fade.finished
	
	if audio:
		audio.stop()
	
	if flute_inca: flute_inca.hide()
	if spirit_winds: spirit_winds.hide()
	if inca_ghost: inca_ghost.hide()
	
	book_page.victory()

func _on_exit_interacted_for_combat() -> void:
	if audio: audio.stop() 
	
	await start_combat(3)
	
	if not is_inside_tree() or is_queued_for_deletion():
		return
	SceneManager.jouer_cinematique(endgame_video_path, "res://scenes/credits/credits.tscn")


func start_combat(niveau_id: int) -> void:
	if not is_inside_tree(): return
	
	get_tree().paused = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	current_battle_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_layer.add_child(current_battle_scene)
	
	current_battle_scene._check_test_mode(niveau_id)
	
	# Wait for battle to finish ONLY ONCE (Removed the duplicate lines)
	await current_battle_scene.tree_exited
	
	if is_instance_valid(ui_layer):
		ui_layer.queue_free()
	
	current_battle_scene = null
	
	# --- ANTI-CRASH FIX ---
	if not is_inside_tree() or is_queued_for_deletion():
		return
		
	get_tree().paused = false
	
	if player: 
		player.set_physics_process(true)
	is_dialogue_playing = false

func _play_dialogue(title: String):
	player = get_tree().get_root().find_child("Player", true, false)
	if player: 
		player.process_mode = Node.PROCESS_MODE_DISABLED
	
	if level6_dialogue:
		DialogueManager.show_example_dialogue_balloon(level6_dialogue, title)
		await DialogueManager.dialogue_ended
	else:
		pass
	
	if player: 
		player.process_mode = Node.PROCESS_MODE_INHERIT

# --- LEVEL STATE SAVE MANAGEMENT ---
func get_level_state() -> Dictionary:
	return {
		"puzzle_completed": puzzle_completed,
		"inca_met": inca_met
	}

func restore_level_state(state: Dictionary) -> void:
	puzzle_completed = state.get("puzzle_completed", false)
	inca_met = state.get("inca_met", false)
	
	if puzzle_completed:
		if exit: exit.unlock()
		for tube in get_tree().get_nodes_in_group("tubes"):
			tube.hide()
			var interactable = tube.get_node_or_null("Interactable")
			if interactable:
				interactable.is_interactable = false
		
		if book_page: book_page.queue_free()
