extends Node

var video_layer: CanvasLayer
var video_player: VideoStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 1. On crée un CanvasLayer au-dessus de TOUT (HUD, menus, etc.)
	video_layer = CanvasLayer.new()
	video_layer.layer = 120 
	add_child(video_layer)
	
	# 2. On configure le lecteur vidéo
	video_player = VideoStreamPlayer.new()
	video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	video_player.expand = true
	video_layer.add_child(video_player)
	video_layer.hide()

func utiliser_fiole(chemin_video: String, niveau_actuel: int) -> void:
	# 1. On met tout le jeu en pause (ennemis, joueur, etc.)
	get_tree().paused = true
	
	# 2. On charge et lance la cinématique
	var stream = load(chemin_video)
	if stream:
		video_player.stream = stream
		video_layer.show()
		video_player.play()
		
		# On attend patiemment la fin de la vidéo
		await video_player.finished
	else:
		print("ERREUR: Impossible de charger la vidéo : ", chemin_video)
		
	# 3. La vidéo est finie, on la cache et on enlève la pause
	video_layer.hide()
	get_tree().paused = false
	
	# 4. Détermination de la couleur en fonction du niveau
	var cible_saturation: float = 0.0
	if niveau_actuel >= 5:
		cible_saturation = 1.0
	elif niveau_actuel >= 3:
		cible_saturation = 0.3
	else:
		cible_saturation = 0.0
		
	# 5. On applique le fondu sur le filtre (sans se soucier de son chemin exact !)
	var filtres = get_tree().get_nodes_in_group("world_filter")
	if filtres.size() > 0:
		var mat = filtres[0].material as ShaderMaterial
		if mat:
			var tween = create_tween()
			tween.tween_property(mat, "shader_parameter/saturation", cible_saturation, 2.0)
	else:
		print("Attention: Aucun nœud avec le groupe 'world_filter' n'a été trouvé.")
