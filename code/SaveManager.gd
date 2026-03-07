extends Node

const SAVE_PATH = "user://chromesthesia_save.json"

# Variables de progression globale
var current_chapter: String = "Étage des Vents"
var current_level: int = 1

# Sauvegarde l'état du jeu
func save_game() -> void:
	var save_data = {
		"inventory": InventoryManager.items,
		"chapter": current_chapter,
		"level": current_level
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Partie sauvegardée : ", current_chapter, " - Niveau ", current_level)

func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		
		if error == OK:
			var data = json.get_data()
			
			if data.has("inventory"):
				InventoryManager.items = data["inventory"]
				
			if data.has("chapter"):
				current_chapter = data["chapter"]
			if data.has("level"):
				current_level = data["level"]
				
			print("Partie chargée ! Reprise au : ", current_chapter, " - Niveau ", current_level)
	else:
		print("Aucune sauvegarde trouvée.")
