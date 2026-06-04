extends Node2D

@export var secret_combination: Array[int] = [1, 3, 2]
var current_sequence: Array[int] = []
var is_playing_hint: bool = false
var is_solved: bool = false

@onready var corde1 = $String_1
@onready var corde2 = $String_2
@onready var corde3 = $String_3
@onready var magic_door = $MagicDoor 
@onready var audio_hint = $HintAudioPlayer 
@onready var book_page = $BookPage

func _ready() -> void:
	if corde1: corde1.played.connect(_on_string_played)
	if corde2: corde2.played.connect(_on_string_played)
	if corde3: corde3.played.connect(_on_string_played)
	
	if magic_door:
		magic_door.hint_requested.connect(_on_door_hint_requested)

	_play_intro_dialogue()

func _play_intro_dialogue() -> void:
	await get_tree().create_timer(0.8).timeout
	if is_solved:
		var generic = load("res://Dialogues/Generic/LevelCompleted.dialogue")
		if generic: DialogueManager.show_example_dialogue_balloon(generic, "start")
		return
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level1/level1.dialogue"), "intro")

# --- HINT FUNCTION ---
func _on_door_hint_requested() -> void:
	if is_playing_hint:
		return
		
	is_playing_hint = true
	current_sequence.clear()
	
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level1/level1.dialogue"), "start")
	
	await DialogueManager.dialogue_ended 
	
	if audio_hint:
		audio_hint.play()
	
	await get_tree().create_timer(3.0).timeout
	
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Level1/level1.dialogue"), "hint")
	
	await DialogueManager.dialogue_ended

	is_playing_hint = false


func _on_string_played(id: int) -> void:
	if is_playing_hint:
		return

	current_sequence.append(id)
	
	if current_sequence.size() > secret_combination.size():
		current_sequence.pop_front()


	if current_sequence == secret_combination:
		_solve_puzzle()


func _solve_puzzle() -> void:
	if is_solved: return
	is_solved = true
	book_page.victory()

	if magic_door:
		magic_door.unlock()
	
	
	if corde1 and corde1.has_node("Interactable"):
		corde1.get_node("Interactable").is_interactable = false
	if corde2 and corde2.has_node("Interactable"):
		corde2.get_node("Interactable").is_interactable = false
	if corde3 and corde3.has_node("Interactable"):
		corde3.get_node("Interactable").is_interactable = false


# --- LEVEL STATE SAVE MANAGEMENT ---
func get_level_state() -> Dictionary:
	return {
		"is_solved": is_solved
	}

func restore_level_state(state: Dictionary) -> void:
	if state.get("is_solved", false):
		_solve_puzzle()
