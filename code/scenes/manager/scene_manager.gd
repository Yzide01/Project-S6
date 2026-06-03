extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var video_player = $VideoStreamPlayer
@onready var black_screen = $ColorRect
@onready var cinematic_audio = $CinematicAudio




# To change scene do:
# To change scene just after a cinematic do:
# it will play the cinematic and change level right after


var scene_apres_video: String = ""
var vial_use_count: int = 0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ensures the visual fade canvas does not block mouse inputs during active gameplay.
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	video_player.finished.connect(_on_video_finished)

# --- 1. FONCTION CLASSIQUE : Changer de niveau directement ---
func changer_niveau(chemin_scene: String) -> void:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(chemin_scene)
	
	animation_player.play("fade_to_normal")

func jouer_cinematique(chemin_video: String, chemin_scene_suivante: String, chemin_audio: String = "") -> void:
	scene_apres_video = chemin_scene_suivante
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	video_player.stream = load(chemin_video)
	video_player.visible = true
	var taille_ecran = get_viewport().get_visible_rect().size
	video_player.size = taille_ecran
		
	if chemin_audio != "":
		cinematic_audio.stream = load(chemin_audio)
		
		cinematic_audio.volume_db = -60.0 
		cinematic_audio.play()
		
		var audio_tween_in = create_tween()
		audio_tween_in.tween_property(cinematic_audio, "volume_db", 0.0, 1.0) 
		
	video_player.play()
	
	animation_player.play("fade_to_normal")

func _on_video_finished() -> void:
	if cinematic_audio.playing:
		var audio_tween = create_tween()
		audio_tween.tween_property(cinematic_audio, "volume_db", -60.0, 0.5)
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
		
	video_player.visible = false 
	video_player.stop()
	
	
	if scene_apres_video != "":
		get_tree().change_scene_to_file(scene_apres_video)
	else:
		get_tree().paused = false
	cinematic_audio.stop()
	animation_player.play("fade_to_normal")

func _input(event: InputEvent) -> void:
	if video_player.visible and video_player.is_playing():
		if event.is_action_pressed("jump") or event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled() 
			_on_video_finished()


func jouer_cinematique_sur_place(chemin_video: String) -> void:
	scene_apres_video = ""
	get_tree().paused = true
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	video_player.stream = load(chemin_video)
	video_player.visible = true
	video_player.size = get_viewport().get_visible_rect().size
	video_player.play()
	
	animation_player.play("fade_to_normal")
