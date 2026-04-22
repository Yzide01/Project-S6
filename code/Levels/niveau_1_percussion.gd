extends Node2D

@export var intro_position: Vector2
@export var outro_position: Vector2
@export var secret_combination: Array[int] = [2, 0, 1] 

var is_solved: bool = false
@onready var spirit = $PercussionSpirit
@onready var bowls = [$Bowl_1, $Bowl_2, $Bowl_3]

func _ready() -> void:
	for b in bowls:
		b.state_changed.connect(_check_solution)
	_play_sequence("Intro", intro_position, "res://Dialogues/Level3/Intro.dialogue")

func _check_solution():
	if is_solved: return
	var current = [bowls[0].current_mass_state, bowls[1].current_mass_state, bowls[2].current_mass_state]
	if current == secret_combination:
		is_solved = true
		_play_sequence("Outro", outro_position, "res://Dialogues/Level3/Outro.dialogue")

func _play_sequence(type, pos, diag_path):
	var player = get_tree().get_first_node_in_group("player")
	if player: player.can_move = false # BLOQUAGE
	
	if spirit:
		spirit.global_position = pos
		spirit.modulate.a = 0
		spirit.show()
		var t = create_tween()
		t.tween_property(spirit, "modulate:a", 1.0, 1.0)
		await t.finished

	DialogueManager.show_example_dialogue_balloon(load(diag_path), "start")
	await DialogueManager.dialogue_ended
	
	if spirit:
		var t2 = create_tween()
		t2.tween_property(spirit, "modulate:a", 0.0, 1.0)
		await t2.finished
		spirit.hide()
		
	if player: player.can_move = true # LIBÉRATION
