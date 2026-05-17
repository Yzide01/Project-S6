extends InventoryItem
class_name MagicVial

@export var video_path: String = "res://Assets/Videos/vial_scene.ogv"

# Ton système d'inventaire cherche TOUJOURS la fonction "use" avec l'argument "player"
func use(player: Node) -> void:
	print("--- FIOLE UTILISÉE ! ---")
	
	# 1. On lance la vidéo via TON SceneManager (sans changer de niveau)
	SceneManager.jouer_cinematique_sur_place(video_path)
	
	# 2. On attend patiemment que la vidéo se termine
	await SceneManager.video_player.finished
	
	# 3. La vidéo est finie, on calcule la couleur du masque
	var scene_path = player.get_tree().current_scene.scene_file_path.to_lower()
	var target_sat = 0.0
	
	if "5" in scene_path or "6" in scene_path: target_sat = 1.0
	elif "3" in scene_path or "4" in scene_path: target_sat = 0.3
	
	# 4. On trouve ton masque et on change sa couleur
	var filtres = player.get_tree().get_nodes_in_group("world_filter")
	if filtres.size() > 0:
		# On cherche le ColorRect qui est l'enfant du MaskRoot
		var color_rect = filtres[0].get_node_or_null("ColorRect") 
		if color_rect and color_rect.material:
			var mat = color_rect.material as ShaderMaterial
			
			# On crée une animation fluide de 2 secondes
			var tween = player.get_tree().create_tween()
			tween.tween_property(mat, "shader_parameter/saturation", target_sat, 2.0)
			print("✅ Masque mis à jour ! Saturation = ", target_sat)
