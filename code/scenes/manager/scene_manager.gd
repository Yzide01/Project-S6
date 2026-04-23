extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var video_player = $VideoStreamPlayer
@onready var black_screen = $ColorRect




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

func _ready() -> void:
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

# --- 2. NOUVELLE FONCTION : Jouer une cinématique entre deux niveaux ---
func jouer_cinematique(chemin_video: String, chemin_scene_suivante: String) -> void:
	scene_apres_video = chemin_scene_suivante
	
	# 1. Fondu au noir pour cacher l'ancien niveau
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	# 2. On charge le fichier .ogv, on l'affiche et on met Play
	video_player.stream = load(chemin_video)
	video_player.visible = true
	video_player.play()
	
	# 3. On enlève l'écran noir pour voir la vidéo
	animation_player.play("fade_to_normal")

# Appelée quand la vidéo arrive à la fin (ou est passée)
func _on_video_finished() -> void:
	video_player.stop() # On coupe tout de suite le son/image
	
	# 1. On lance le fondu noir par dessus la dernière image de la vidéo
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	# 2. L'écran est totalement noir. On peut cacher la vidéo incognito !
	video_player.visible = false 
	
	# 3. On charge la scène suivante "dans le noir"
	get_tree().change_scene_to_file(scene_apres_video)
	
	# 4. On rouvre les rideaux sur le nouveau niveau
	animation_player.play("fade_to_normal")

# Permettre au joueur de passer la vidéo avec Espace
func _input(event: InputEvent) -> void:
	if video_player.visible and video_player.is_playing():
		if event.is_action_pressed("jump") or event.is_action_pressed("ui_cancel"):
			# Cette ligne dit à Godot : "J'ai géré cet appui sur Espace, ne le dis pas aux autres !"
			get_viewport().set_input_as_handled() 
			_on_video_finished()
