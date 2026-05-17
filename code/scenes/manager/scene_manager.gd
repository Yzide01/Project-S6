extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var video_player = $VideoStreamPlayer
@onready var black_screen = $ColorRect
@onready var cinematic_audio = $CinematicAudio



#-----------------------------------------
# TUTORIAL:

# To change scene do:
# SceneManager.changer_niveau("res://Levels/Level3/Level3.tscn")
#
# To change scene just after a cinematic do:
# SceneManager.jouer_cinematique("res://Cinematics/intro_niveau2.ogv", "res://Levels/Level2/Level2.tscn")
# it will play the cinematic and change level right after


# Mémoire pour savoir où aller après la vidéo
var scene_apres_video: String = ""
var vial_use_count: int = 0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# On s'assure que le fondu noir ne bloque pas les clics pendant le jeu
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Quand une vidéo se termine, on appelle la fonction automatiquement
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
		
		# 1. On force le volume au minimum (silence total)
		cinematic_audio.volume_db = -60.0 
		cinematic_audio.play()
		
		# 2. On crée le fondu d'entrée (Fade-in)
		var audio_tween_in = create_tween()
		# Fait passer le volume de -60 à 0 dB en 1 seconde
		audio_tween_in.tween_property(cinematic_audio, "volume_db", 0.0, 1.0) 
		
	video_player.play()
	
	animation_player.play("fade_to_normal")

func _on_video_finished() -> void:
	# 1. On crée un fondu audio (baisse le volume jusqu'à -60dB en 0.5 secondes)
	if cinematic_audio.playing:
		var audio_tween = create_tween()
		audio_tween.tween_property(cinematic_audio, "volume_db", -60.0, 0.5)
	
	# 2. Le fondu visuel habituel
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
		
	video_player.visible = false 
	video_player.stop()
	
	#get_tree().change_scene_to_file(scene_apres_video)
	
	if scene_apres_video != "":
		# S'il y a un niveau prévu, on y va
		get_tree().change_scene_to_file(scene_apres_video)
	else:
		# Sinon, on reste dans le niveau et on enlève la pause !
		get_tree().paused = false
	cinematic_audio.stop() # On coupe définitivement le son une fois qu'on est dans le noir complet
	animation_player.play("fade_to_normal")

# Permettre au joueur de passer la vidéo avec Espace
func _input(event: InputEvent) -> void:
	if video_player.visible and video_player.is_playing():
		if event.is_action_pressed("jump") or event.is_action_pressed("ui_cancel"):
			# Cette ligne dit à Godot : "J'ai géré cet appui sur Espace, ne le dis pas aux autres !"
			get_viewport().set_input_as_handled() 
			_on_video_finished()


func jouer_cinematique_sur_place(chemin_video: String) -> void:
	scene_apres_video = "" # Très important : on précise qu'on ne veut pas changer de niveau
	get_tree().paused = true # On met le jeu en pause
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	video_player.stream = load(chemin_video)
	video_player.visible = true
	video_player.size = get_viewport().get_visible_rect().size
	video_player.play()
	
	animation_player.play("fade_to_normal")
