extends Node

const DB_PATH = "user://chromesthesia_save.db"

# Variables de progression globale
var current_chapter: String = "Étage des Vents"
var current_level: int = 1

var db: SQLite = null

func _ready() -> void:
	# Initialise la base de données
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	
	# Crée la table de sauvegarde si elle n'existe pas
	var table_dict = {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true},
		"chapter": {"data_type": "text"},
		"level": {"data_type": "int"},
		"scene_path": {"data_type": "text"},
		"player_x": {"data_type": "real"},
		"player_y": {"data_type": "real"},
		"inventory_data": {"data_type": "text"},
		"last_saved": {"data_type": "text"}
	}
	
	db.create_table("saves", table_dict)

# Variables de restauration
var restore_player_position: bool = false
var loaded_player_x: float = 0.0
var loaded_player_y: float = 0.0

# Sauvegarde l'état du jeu (supporte plusieurs slots)
func save_game(slot_id: int = 1) -> void:
	if not db:
		print("Erreur: base de données non initialisée.")
		return
		
	var inventory = preload("res://Core/InventorySystem/playerInventory.tres")
	
	# Serialize inventory to primitives
	var inv_array = []
	for slot in inventory.slots:
		if slot and slot.item:
			inv_array.append({"item_path": slot.item.resource_path, "amount": slot.amount})
		else:
			inv_array.append(null)
			
	var inventory_json = JSON.stringify(inv_array)
	var time_now = Time.get_datetime_string_from_system()
	
	# Extract scene path and player position
	var scene_path = ""
	var p_x = 0.0
	var p_y = 0.0
	var current_scene = get_tree().current_scene
	if current_scene:
		scene_path = current_scene.scene_file_path
		var player = current_scene.get_node_or_null("Player")
		if player:
			p_x = player.global_position.x
			p_y = player.global_position.y
	
	var data = {
		"id": slot_id,
		"chapter": current_chapter,
		"level": current_level,
		"scene_path": scene_path,
		"player_x": p_x,
		"player_y": p_y,
		"inventory_data": inventory_json,
		"last_saved": time_now
	}
	
	# On vérifie si la sauvegarde existe déjà pour ce slot
	db.query("SELECT id FROM saves WHERE id = " + str(slot_id) + ";")
	if db.query_result.size() > 0:
		# Mise à jour
		db.update_rows("saves", "id = " + str(slot_id), data)
	else:
		# Insertion
		db.insert_row("saves", data)
		
	print("Partie sauvegardée (Slot ", slot_id, ") : ", current_chapter, " - Niveau ", current_level)

# Charge l'état du jeu
func load_game(slot_id: int = 1) -> void:
	if not db:
		print("Erreur: base de données non initialisée.")
		return
		
	db.query("SELECT * FROM saves WHERE id = " + str(slot_id) + ";")
	if db.query_result.size() > 0:
		var result = db.query_result[0]
		
		if result.has("chapter"):
			current_chapter = result["chapter"]
		if result.has("level"):
			current_level = result["level"]
			
		if result.has("player_x") and result.has("player_y"):
			restore_player_position = true
			loaded_player_x = result["player_x"]
			loaded_player_y = result["player_y"]
			
		if result.has("inventory_data") and result["inventory_data"] != null:
			var json = JSON.new()
			var error = json.parse(result["inventory_data"])
			if error == OK:
				var inv_array = json.get_data()
				var inventory = preload("res://Core/InventorySystem/playerInventory.tres")
				# Deserialize inventory
				for i in range(min(inv_array.size(), inventory.slots.size())):
					if inv_array[i] != null:
						inventory.slots[i].item = load(inv_array[i]["item_path"])
						inventory.slots[i].amount = inv_array[i]["amount"]
					else:
						inventory.slots[i].item = null
						inventory.slots[i].amount = 0
				inventory.updated.emit()
				
		print("Partie chargée (Slot ", slot_id, ") ! Reprise au : ", current_chapter, " - Niveau ", current_level)
		
		if result.has("scene_path") and result["scene_path"] != "":
			if SceneManager.has_method("changer_niveau"):
				SceneManager.changer_niveau(result["scene_path"])
			else:
				get_tree().change_scene_to_file(result["scene_path"])
		else:
			# Fallback pour les anciennes sauvegardes (sans scene_path)
			var fallback_path = ""
			if current_chapter == "Étage des Vents" and current_level == 1:
				fallback_path = "res://Levels/niveau1_vents.tscn"
			elif current_chapter == "Étage des Percussions" and current_level == 1:
				fallback_path = "res://Levels/niveau1_percussion.tscn"
			elif current_chapter == "Étage des Cordes" and current_level == 1:
				fallback_path = "res://Levels/niveau1_cordeV2.tscn"
			
			if fallback_path != "":
				if SceneManager.has_method("changer_niveau"):
					SceneManager.changer_niveau(fallback_path)
				else:
					get_tree().change_scene_to_file(fallback_path)
				
		# Unpause the game if loaded from pause menu
		get_tree().paused = false
		if PauseMenuManager.has_method("close_pause_menu"):
			PauseMenuManager.close_pause_menu()
	else:
		print("Aucune sauvegarde trouvée pour le slot ", slot_id)

func get_slot_info(slot_id: int) -> Dictionary:
	if not db:
		return {}
	db.query("SELECT chapter, level, last_saved FROM saves WHERE id = " + str(slot_id) + ";")
	if db.query_result.size() > 0:
		return db.query_result[0]
	return {}
