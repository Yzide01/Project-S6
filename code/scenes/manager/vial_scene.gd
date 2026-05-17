extends Node

# 1. On charge ton inventaire pour pouvoir écouter ses signaux
@onready var inventory: Inventory = preload("res://Core/InventorySystem/playerInventory.tres")

var video_layer: CanvasLayer
var video_player: VideoStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# --- LA PIÈCE MANQUANTE : On écoute le signal de l'inventaire ---
	if inventory and not inventory.use_item.is_connected(_on_item_used):
		inventory.use_item.connect(_on_item_used)
	# ---------------------------------------------------------------
	
	# Création d'une couche UI au-dessus de tout le reste
	video_layer = CanvasLayer.new()
	video_layer.layer = 120 
	add_child(video_layer)
	
	# Création du lecteur vidéo
	video_player = VideoStreamPlayer.new()
	video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	video_player.expand = true
	video_layer.add_child(video_player)
	video_layer.hide()

# --- LA FONCTION DÉCLENCHÉE PAR LE SIGNAL ---
func _on_item_used(item) -> void:
	# Si l'objet utilisé possède une fonction "use_item" (comme ta MagicVial), on l'exécute !
	if item and item.has_method("use_item"):
		item.use_item()
# --------------------------------------------

func utiliser_fiole(chemin_video: String) -> void:
	# 1. On fige le jeu
	get_tree().paused = true
	
	# 2. On charge et on joue la vidéo (.ogv requis dans Godot 4)
	var stream = load(chemin_video)
	if stream:
		video_player.stream = stream
		video_layer.show()
		video_player.play()
		await video_player.finished # On attend la fin du film
	else:
		push_error("Impossible de charger la vidéo : ", chemin_video)
		
	# 3. Fin de la vidéo, on nettoie et on retire la pause
	video_layer.hide()
	get_tree().paused = false
	
	# 4. Le script devine tout seul le niveau actuel en lisant le nom de la scène
	var nom_scene = get_tree().current_scene.name.to_lower()
	var cible_saturation: float = 0.0
	
	if "niveau6" in nom_scene or "niveau5" in nom_scene:
		cible_saturation = 1.0 # Couleurs complètes
	elif "niveau4" in nom_scene or "niveau3" in nom_scene:
		cible_saturation = 0.3 # Couleurs ternes
	else:
		cible_saturation = 0.0 # Noir et blanc
		
	# 5. On cherche notre Filtre (via le groupe) et on anime la couleur sur 2 secondes
	var filtres = get_tree().get_nodes_in_group("world_filter")
	if filtres.size() > 0:
		var mat = filtres[0].material as ShaderMaterial
		if mat:
			var tween = create_tween()
			tween.tween_property(mat, "shader_parameter/saturation", cible_saturation, 2.0)
	else:
		print("Attention: Aucun filtre 'world_filter' n'a été trouvé dans ce niveau.")
