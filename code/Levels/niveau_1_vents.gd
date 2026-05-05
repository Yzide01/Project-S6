extends Node2D

var intro_dialogue = load("res://Dialogues/Level5/Intro.dialogue")
var bellows_dialogue = load("res://Dialogues/Level5/Bellows.dialogue")
var hydraulis_dialogue = load("res://Dialogues/Level5/Hydraulis.dialogue")

@onready var spirit = $WindSpirit
@onready var marker_intro = $MarkerIntro
@onready var marker_hydraulis = $MarkerHydraulis
@onready var exit_door = $ExitDoor
@onready var door_closed = $door_closed

var player: Node2D
var bellows_seen: bool = false
var hydraulis_seen: bool = false
var is_pressurized: bool = false
var pressure_timer: Timer

func _ready() -> void:
	if spirit:
		spirit.hide()
		spirit.modulate.a = 0.0
		# On le force à être devant tout le monde
		spirit.z_index = 100 
	pressure_timer = Timer.new()
	pressure_timer.one_shot = true
	pressure_timer.timeout.connect(_on_pressure_lost)
	add_child(pressure_timer)

	if intro_dialogue:
		await get_tree().create_timer(1.0).timeout
		# 1. Mélos parle seul
		await _play_sequence(intro_dialogue, "start", null)
		# 2. L'esprit apparaît sur le MarkerIntro
		await _play_sequence(intro_dialogue, "partie_2", marker_intro)

func _on_medieval_organ_interacted() -> void:
	is_pressurized = true
	pressure_timer.start(15.0) # Le joueur a 15 secondes pour aller à l'Hydraulis
	
	print("Mélos: The massive bellows pumped air into the underground pipes! But the pressure is too chaotic, the door only shakes...")
	print("Mélos: Quick! Find a way to stabilize the air before it leaks out!")

func _on_hydraulis_interacted() -> void:
	if not is_pressurized:
		# Si le joueur n'a pas pompé l'air d'abord
		print("Mélos: The water mechanism is ready, but there is no air in the pipes. We need a massive pump to fill the system first.")
	else:
		# Succès ! L'air a été pompé ET stabilisé
		pressure_timer.stop()
		print("Mélos: The water caught the chaotic air! The pressure is now perfectly stable. The mechanism is activating!")
		open_door()
		
func _on_pressure_lost() -> void:
	is_pressurized = false
	print("Mélos: The air leaked out... The system is empty again. We need to use the bellows.")
	# Ajouter un son de dégonflement / pneu qui se vide
	
func _on_hydraulis_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not hydraulis_seen:
		hydraulis_seen = true
		_play_sequence(hydraulis_dialogue, "start", marker_hydraulis)



func _on_bellows_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not bellows_seen:
		bellows_seen = true
		DialogueManager.show_example_dialogue_balloon(bellows_dialogue, "start")	
func _play_sequence(dialogue_resource, title: String, target_marker: Marker2D):
	player = get_tree().get_root().find_child("Player", true, false)
	if player: player.process_mode = Node.PROCESS_MODE_DISABLED

	if target_marker and spirit:
		# ON FORCE LA POSITION ET LE RENDU
		spirit.global_position = target_marker.global_position
		spirit.show()
		
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
	
func open_door() -> void:
	if exit_door:
		door_closed.visible = false
		exit_door.unlock()
