extends InventoryItem
class_name MagicVial

@export var video_path: String = "res://Assets/Videos/vial_scene_sr.ogv"
@export var endgame_video_path: String = "res://Assets/Videos/final_vial_scene.ogv"
var diag_path = "Dialogues/Vial/vial.dialogue"
func use(player: Node) -> void:
	var current_scene_name = player.get_tree().current_scene.name.to_lower()
	
	if "level6" in current_scene_name:
		lancer_fin_du_jeu()
		return
	
	await proceder_changement_couleur(player)
	DialogueManager.show_example_dialogue_balloon(load(diag_path), "start")

func lancer_fin_du_jeu() -> void:
	print("Lancement de la cinématique finale")
	# On utilise la fonction qui change de scène automatiquement après la vidéo
	SceneManager.jouer_cinematique(endgame_video_path, "res://scenes/credits.tscn")

func proceder_changement_couleur(player: Node) -> void:
	SceneManager.jouer_cinematique_sur_place(video_path)
	await SceneManager.video_player.finished
	
	SceneManager.vial_use_count += 1
	var target_sat = 0.0
	if SceneManager.vial_use_count == 1: target_sat = 0.35
	elif SceneManager.vial_use_count == 2: target_sat = 1.0
	else: target_sat = 1.0
	
	var filtres = player.get_tree().get_nodes_in_group("world_filter")
	if filtres.size() > 0:
		var mat = filtres[0].material as ShaderMaterial
		var current_sat = mat.get_shader_parameter("saturation")
		var tween = player.get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_method(func(val: float): mat.set_shader_parameter("saturation", val), current_sat, target_sat, 2.0)
