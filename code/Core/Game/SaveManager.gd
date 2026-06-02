extends Node

const DB_PATH = "user://chromesthesia_save.db"

# Variables de progression globale
var current_chapter: String = "Wind Floor"
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
		"combat_state": {"data_type": "text"},
		"level_state": {"data_type": "text"},
		"vial_use_count": {"data_type": "int"},
		"unlocked_pages": {"data_type": "text"},
		"last_saved": {"data_type": "text"}
	}
	
	db.create_table("saves", table_dict)
	
	# Ajout sécurisé des colonnes si elles n'existent pas dans les anciennes sauvegardes
	db.query("ALTER TABLE saves ADD COLUMN combat_state TEXT;")
	db.query("ALTER TABLE saves ADD COLUMN level_state TEXT;")
	db.query("ALTER TABLE saves ADD COLUMN vial_use_count INTEGER DEFAULT 0;")
	db.query("ALTER TABLE saves ADD COLUMN unlocked_pages TEXT;")

# Variables de restauration
var restore_player_position: bool = false
var loaded_player_x: float = 0.0
var loaded_player_y: float = 0.0

var restore_combat: bool = false
var loaded_combat_level: int = 1
var loaded_level_state: Dictionary = {}

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
			
		# Déduire automatiquement le chapitre et le niveau depuis le nom du fichier
		var sp_lower = scene_path.to_lower()
		if "vents" in sp_lower:
			current_chapter = "Wind Floor"
		elif "corde" in sp_lower:
			current_chapter = "Strings Floor"
		elif "percussion" in sp_lower:
			current_chapter = "Percussion Floor"
			
		if "niveau_1" in sp_lower or "niveau1" in sp_lower:
			current_level = 1
		elif "niveau_2" in sp_lower or "niveau2" in sp_lower:
			current_level = 2
		elif "niveau_3" in sp_lower or "niveau3" in sp_lower:
			current_level = 3
	
	# Check for combat state
	var combat_managers = get_tree().get_nodes_in_group("combat_manager")
	var in_combat = false
	var combat_lvl = 1
	if combat_managers.size() > 0:
		in_combat = true
		combat_lvl = combat_managers[0].current_level_id
		
	var combat_state = {
		"in_combat": in_combat,
		"level": combat_lvl
	}
	var combat_state_json = JSON.stringify(combat_state)
	
	var level_state = {}
	if current_scene and current_scene.has_method("get_level_state"):
		level_state = current_scene.get_level_state()
	var level_state_json = JSON.stringify(level_state)

	var vial_use_count = 0
	if SceneManager and "vial_use_count" in SceneManager:
		vial_use_count = SceneManager.vial_use_count
		
	var unlocked_pages_json = ""
	var progression_node = get_tree().root.get_node_or_null("Progression")
	if progression_node and "unlocked_pages" in progression_node:
		unlocked_pages_json = JSON.stringify(progression_node.unlocked_pages)

	var data = {
		"id": slot_id,
		"chapter": current_chapter,
		"level": current_level,
		"scene_path": scene_path,
		"player_x": p_x,
		"player_y": p_y,
		"inventory_data": inventory_json,
		"combat_state": combat_state_json,
		"level_state": level_state_json,
		"vial_use_count": vial_use_count,
		"unlocked_pages": unlocked_pages_json,
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
				
		if result.has("combat_state") and result["combat_state"] != null:
			var json = JSON.new()
			var err = json.parse(result["combat_state"])
			if err == OK:
				var c_data = json.get_data()
				if typeof(c_data) == TYPE_DICTIONARY and c_data.has("in_combat") and c_data["in_combat"]:
					restore_combat = true
					loaded_combat_level = c_data["level"]
					
		loaded_level_state = {}
		if result.has("level_state") and result["level_state"] != null:
			var json = JSON.new()
			var err = json.parse(result["level_state"])
			if err == OK:
				var l_data = json.get_data()
				if typeof(l_data) == TYPE_DICTIONARY:
					loaded_level_state = l_data
					
		if result.has("vial_use_count") and result["vial_use_count"] != null:
			if SceneManager and "vial_use_count" in SceneManager:
				SceneManager.vial_use_count = result["vial_use_count"]
				
		if result.has("unlocked_pages") and result["unlocked_pages"] != null:
			var json = JSON.new()
			var err = json.parse(result["unlocked_pages"])
			if err == OK:
				var pages_data = json.get_data()
				var progression_node = get_tree().root.get_node_or_null("Progression")
				if typeof(pages_data) == TYPE_DICTIONARY and progression_node:
					progression_node.unlocked_pages = pages_data
					if progression_node.has_signal("page_unlocked_signal"):
						progression_node.page_unlocked_signal.emit()
				
		print("Partie chargée (Slot ", slot_id, ") ! Reprise au : ", current_chapter, " - Niveau ", current_level)
		
		var target_path = ""
		if result.has("scene_path") and result["scene_path"] != "":
			target_path = result["scene_path"]
		else:
			# Fallback pour les anciennes sauvegardes (sans scene_path)
			if current_chapter == "Étage des Vents" or current_chapter == "Wind Floor":
				if current_level == 1:
					target_path = "res://Levels/niveau1_vents.tscn"
			elif current_chapter == "Étage des Percussions" or current_chapter == "Percussion Floor":
				if current_level == 1:
					target_path = "res://Levels/niveau1_percussion.tscn"
			elif current_chapter == "Étage des Cordes" or current_chapter == "Strings Floor":
				if current_level == 1:
					target_path = "res://Levels/niveau1_cordeV2.tscn"
				
		if target_path != "":
			if SceneManager.has_method("changer_niveau"):
				await SceneManager.changer_niveau(target_path)
			else:
				get_tree().change_scene_to_file(target_path)
				await get_tree().process_frame
				await get_tree().process_frame
				
			# On attend un tout petit peu pour s'assurer que la nouvelle scène a fini son _ready
			await get_tree().create_timer(0.5).timeout
			
			var new_scene = get_tree().current_scene
			if new_scene:
				if loaded_level_state and not loaded_level_state.is_empty():
					if new_scene.has_method("restore_level_state"):
						new_scene.restore_level_state(loaded_level_state)
					loaded_level_state = {}
					
				if restore_combat:
					if new_scene.has_method("start_combat"):
						new_scene.start_combat(loaded_combat_level)
					restore_combat = false
				
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

func delete_save(slot_id: int = 1) -> void:
	if not db:
		return
	db.query("DELETE FROM saves WHERE id = " + str(slot_id) + ";")
	print("Sauvegarde supprimée (Slot ", slot_id, ")")
