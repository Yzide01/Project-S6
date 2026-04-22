extends Node2D

var intro_dialogue = load("res://Dialogues/Level5/Intro.dialogue")
var bellows_dialogue = load("res://Dialogues/Level5/Bellows.dialogue")
var hydraulis_dialogue = load("res://Dialogues/Level5/Hydraulis.dialogue")

@onready var spirit = $WindSpirit
@onready var marker_intro = $MarkerIntro
@onready var marker_hydraulis = $MarkerHydraulis

var player: Node2D
var bellows_seen: bool = false
var hydraulis_seen: bool = false

func _ready() -> void:
	if spirit:
		spirit.hide()
		spirit.modulate.a = 0.0
		spirit.z_index = 999 # Priorité maximale

	if intro_dialogue:
		await get_tree().create_timer(1.0).timeout
		await _play_sequence(intro_dialogue, "start", null)
		await _play_sequence(intro_dialogue, "partie_2", marker_intro)

func _on_bellows_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not bellows_seen:
		bellows_seen = true
		_play_sequence(bellows_dialogue, "start", null)

func _on_hydraulis_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not hydraulis_seen:
		hydraulis_seen = true
		_play_sequence(hydraulis_dialogue, "start", marker_hydraulis)

func _play_sequence(dialogue_resource, title: String, target_marker: Marker2D):
	player = get_tree().get_root().find_child("Player", true, false)
	if player: player.process_mode = Node.PROCESS_MODE_DISABLED

	if target_marker and spirit:
		# ON FORCE LA POSITION ET LA VISIBILITÉ
		spirit.global_position = target_marker.global_position
		spirit.show()
		spirit.modulate = Color(1, 1, 1, 0) # On part de transparent
		
		if spirit.has_node("SpiritSound"):
			spirit.get_node("SpiritSound").play()
		
		var t = create_tween()
		t.tween_property(spirit, "modulate:a", 1.0, 0.5)
		await t.finished

	if dialogue_resource:
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, title)
		await DialogueManager.dialogue_ended
	
	if target_marker and spirit:
		var t2 = create_tween()
		t2.tween_property(spirit, "modulate:a", 0.0, 0.5)
		await t2.finished
		spirit.hide()

	if player: player.process_mode = Node.PROCESS_MODE_INHERIT
