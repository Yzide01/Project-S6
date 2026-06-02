extends Node2D

var intro_dialogue = load("res://Dialogues/Level5/Intro.dialogue")
var bellows_dialogue = load("res://Dialogues/Level5/Bellows.dialogue")
var hydraulis_dialogue = load("res://Dialogues/Level5/Hydraulis.dialogue")
var winfail_dialogue = load("res://Dialogues/Level5/Outro.dialogue")
@onready var spirit = $WindSpirit
@onready var marker_intro = $MarkerIntro
@onready var marker_bellows = $MarkerIntro # Ajuste le nom si tu crées un MarkerBellows dédié
@onready var exit_door = $ExitDoor
@onready var door_closed = $door_closed
@onready var book_page = $BookPage

# --- NOUVEAU : Référence à l'interface du chrono ---
@onready var timer_label = $TimerCanvas/TimerLabel
@onready var bellows_sound = $BellowsSound

var player: Node2D
var bellows_seen: bool = false
var hydraulis_seen: bool = false
var is_pressurized: bool = false
var pressure_timer: Timer

func _ready() -> void:
	if spirit:
		spirit.hide()
		spirit.modulate.a = 0.0
		spirit.z_index = 100 
		
	if timer_label:
		timer_label.hide() # On s'assure que le chrono est caché au début
	
	pressure_timer = Timer.new()
	pressure_timer.one_shot = true
	pressure_timer.timeout.connect(_on_pressure_lost)
	add_child(pressure_timer)

	if intro_dialogue:
		await get_tree().create_timer(1.0).timeout
		await _play_sequence(intro_dialogue, "start", null)
		await _play_sequence(intro_dialogue, "partie_2", marker_intro)

# --- NOUVEAU : Mise à jour de l'affichage du temps en temps réel ---
func _process(_delta: float) -> void:
	# Si le chrono n'est pas arrêté et que le label existe
	if not pressure_timer.is_stopped() and timer_label:
		# On formate le texte pour garder 1 seule décimale (ex: 14.5s)
		timer_label.text = "Air pressurized : %.1f s" % pressure_timer.time_left

func _on_medieval_organ_interacted() -> void:
	is_pressurized = true
	pressure_timer.start(15.0) 
	if bellows_sound: bellows_sound.play()
	# On affiche le chrono à l'écran !
	if timer_label:
		timer_label.show()
	
	print("Mélos: The massive bellows pumped air into the underground pipes! But the pressure is too chaotic.")
	print("Mélos: Quick! You have 15 seconds to reach the Hydraulis and stabilize the air with water pressure before it leaks!")

func _on_hydraulis_interacted() -> void:
	if not is_pressurized:
		print("Mélos: The water mechanism is ready, but there is no air in the pipes.")
	else:
		pressure_timer.stop()
		if bellows_sound: bellows_sound.stop()
		# On cache le chrono car l'énigme est réussie
		if timer_label:
			timer_label.hide()
			
		print("Mélos: The water caught the chaotic air! The pressure is now perfectly stable. The mechanism is activating!")
		await DialogueManager.show_example_dialogue_balloon(winfail_dialogue, "start")
		await get_tree().create_timer(3).timeout

		book_page.victory()
		open_door()
		
func _on_pressure_lost() -> void:
	is_pressurized = false
	hydraulis_seen = false
	bellows_seen = false
	if bellows_sound: bellows_sound.stop()
	# On cache le chrono car le temps est écoulé
	if timer_label:
		timer_label.hide()
	await DialogueManager.show_example_dialogue_balloon(winfail_dialogue, "fail")

	print("Mélos: The air leaked out... The system is empty again. We need to pump the bellows at the Organ once more.")

func _on_hydraulis_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not hydraulis_seen:
		if not is_pressurized:
			hydraulis_seen = true 
			await _play_sequence(hydraulis_dialogue, "start", null)

func _on_bellows_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not bellows_seen:
		bellows_seen = true
		
		player = get_tree().get_root().find_child("Player", true, false)
		if player: player.process_mode = Node.PROCESS_MODE_DISABLED
		
		if bellows_dialogue:
			DialogueManager.show_example_dialogue_balloon(bellows_dialogue, "start")
			await DialogueManager.dialogue_ended
			
		if marker_bellows and spirit:
			spirit.global_position = marker_bellows.global_position
			spirit.show()
			if spirit.has_node("SpiritSound"):
				spirit.get_node("SpiritSound").play()
			var t = create_tween()
			t.tween_property(spirit, "modulate:a", 1.0, 0.5)
			await t.finished
			
		if bellows_dialogue:
			DialogueManager.show_example_dialogue_balloon(bellows_dialogue, "partie_esprit")
			await DialogueManager.dialogue_ended
			
		if marker_bellows and spirit:
			var t2 = create_tween()
			t2.tween_property(spirit, "modulate:a", 0.0, 0.5)
			await t2.finished
			spirit.hide()
			
		if player: player.process_mode = Node.PROCESS_MODE_INHERIT

func _play_sequence(dialogue_resource, title: String, target_marker: Marker2D):
	player = get_tree().get_root().find_child("Player", true, false)
	if player: player.process_mode = Node.PROCESS_MODE_DISABLED

	if target_marker and spirit:
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

# --- GESTION DE LA SAUVEGARDE DE L'ÉTAT DU NIVEAU ---
func get_level_state() -> Dictionary:
	return {
		"bellows_seen": bellows_seen,
		"hydraulis_seen": hydraulis_seen,
		"is_pressurized": is_pressurized,
		"door_opened": not door_closed.visible if door_closed else false
	}

func restore_level_state(state: Dictionary) -> void:
	bellows_seen = state.get("bellows_seen", false)
	hydraulis_seen = state.get("hydraulis_seen", false)
	is_pressurized = state.get("is_pressurized", false)
	
	if state.get("door_opened", false):
		open_door()
