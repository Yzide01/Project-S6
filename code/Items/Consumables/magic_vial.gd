extends InventoryItem
class_name MagicVial

@export var video_path: String = "res://Assets/Videos/vial_scene.ogv"

func use(player: Node) -> void:
	print("--- FIOLE UTILISÉE ! ---")
	
	# 1. Cinématique
	SceneManager.jouer_cinematique_sur_place(video_path)
	await SceneManager.video_player.finished
	
	# 2. On incrémente le compteur global
	SceneManager.vial_use_count += 1
	
	# 3. On décide de la couleur STRICTEMENT selon le nombre d'utilisations
	var target_sat = 0.0
	if SceneManager.vial_use_count == 1:
		target_sat = 0.35  # 1ère fiole -> Pastel
	elif SceneManager.vial_use_count == 2:
		target_sat = 0.70  # 2ème fiole -> Chaleureux
	else:
		target_sat = 1.0   # 3ème fiole et plus -> Couleur totale
	
	# 4. Animation du masque
	var filtres = player.get_tree().get_nodes_in_group("world_filter")
	if filtres.size() > 0:
		var color_rect = filtres[0] 
		if color_rect and color_rect.material:
			var mat = color_rect.material as ShaderMaterial
			
			# On récupère la valeur actuelle pour que l'animation parte du bon point
			var current_sat = mat.get_shader_parameter("saturation")
			if typeof(current_sat) != TYPE_FLOAT:
				current_sat = 0.0
				
			var tween = player.get_tree().create_tween()
			
			# On blinde l'animation pour qu'elle ne soit jamais bloquée par une pause
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			
			# LA MÉTHODE 100% INFAILLIBLE : 
			# On utilise "tween_method" avec une lambda pour forcer la mise à jour visuelle du shader
			tween.tween_method(func(val: float): mat.set_shader_parameter("saturation", val), current_sat, target_sat, 2.0)
			
			print("✅ Fiole n°", SceneManager.vial_use_count, " bue ! Saturation = ", target_sat)
