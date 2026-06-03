extends Node2D

@export var intro_position: Vector2
@export var outro_position: Vector2
@export var secret_combination: Array[int] = [1, 0, 1]
@export var target_tune: Array[int] = [0, 1, 2]

@onready var spirit = $PercussionSpirit
@onready var bowls = [$Bowl_1, $Bowl_2, $Bowl_3]
@onready var book_page = $BookPage

var is_solved: bool = false
var current_tune: Array[int] = []

func _ready() -> void:
	if spirit:
		spirit.hide()
		spirit.modulate.a = 0.0

	for i in range(bowls.size()):
		var b = bowls[i]
		if b:
			if b.has_signal("state_changed"):
				b.state_changed.connect(_on_water_changed)
			if b.has_signal("played"):
				b.played.connect(_on_bowl_played.bind(i))

	await get_tree().create_timer(0.3).timeout
	_play_sequence(intro_position, "res://Dialogues/Level3/Intro.dialogue")

var water_ready: bool = false

func _on_water_changed():
	current_tune.clear()
	
	var current_water = [bowls[0].current_mass_state, bowls[1].current_mass_state, bowls[2].current_mass_state]
	
	if current_water == secret_combination and not water_ready:
		water_ready = true
		
		# --- DIALOGUE TRIGGER ---
		# Loads the specific .dialogue file for this level sequence.
		var dialogue_resource = load("res://Dialogues/Level3/WaterReady.dialogue")
		if dialogue_resource:
			DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
		else:
			push_error("Fichier de dialogue introuvable !")
			
	elif current_water != secret_combination:
		water_ready = false
		
func _on_bowl_played(bowl_index: int):
	if is_solved:
		return

	var current_water = [bowls[0].current_mass_state, bowls[1].current_mass_state, bowls[2].current_mass_state]
	
	if current_water != secret_combination:
		current_tune.clear()
		return

	current_tune.append(bowl_index)

	if current_tune.size() > target_tune.size():
		current_tune.pop_front()

	var alternate_tune = target_tune.duplicate()
	alternate_tune.reverse()

	if current_tune == target_tune or current_tune == alternate_tune:
		_trigger_victory()

func _trigger_victory():
	is_solved = true
	await _play_sequence(outro_position, "res://Dialogues/Level3/Outro.dialogue")
	await get_tree().create_timer(2.0).timeout
	
	if book_page:
		book_page.victory()
		await book_page.page_picked
		
	await get_tree().create_timer(3.0).timeout
	SceneManager.changer_niveau("res://Levels/niveau2_percussion.tscn")


func _play_sequence(pos, diag_path):
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.set_physics_process(false)
		player.set_process_input(false)
		player.process_mode = Node.PROCESS_MODE_DISABLED

	if spirit:
		spirit.global_position = pos
		spirit.show()
		var t = create_tween()
		t.tween_property(spirit, "modulate:a", 1.0, 0.8)
		await t.finished

	var dialogue_res = load(diag_path)
	if dialogue_res:
		DialogueManager.show_example_dialogue_balloon(dialogue_res, "start")
		await DialogueManager.dialogue_ended
	else:
		push_error("Dialogue introuvable à l'export: ", diag_path)

	if spirit:
		var t2 = create_tween()
		t2.tween_property(spirit, "modulate:a", 0.0, 0.8)
		await t2.finished
		spirit.hide()

	if player:
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.set_physics_process(true)
		player.set_process_input(true)

func _on_terrain_entered(area: Area2D) -> void:
	pass

# --- LEVEL STATE SAVE MANAGEMENT ---
func get_level_state() -> Dictionary:
	return {
		"is_solved": is_solved
	}

func restore_level_state(state: Dictionary) -> void:
	if state.get("is_solved", false):
		is_solved = true
		SceneManager.changer_niveau("res://Levels/niveau2_percussion.tscn")
