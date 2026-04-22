extends Node2D

@onready var spirit = $WindSpirit
var player: Node2D

func _ready() -> void:
	print("--- SCRIPT INITIALISÉ : OK ---")
	player = get_tree().get_first_node_in_group("Player")
	if spirit: spirit.hide()

# TEST ZONE SOUFFLETS
func _on_bellows_area_body_entered(body: Node2D) -> void:
	# Ce message DOIT apparaître peu importe qui entre dans la zone
	print("DEBUT DETECTION : Un corps est entré dans la zone : ", body.name)
	
	if body.is_in_group("Player"):
		print("CONFIRMATION : C'est bien Mélos (Player) !")
		_play_sequence("res://Dialogues/Level5/Bellows.dialogue")
	else:
		print("REFUS : Le corps n'est pas dans le groupe 'Player'. Groupes actuels : ", body.get_groups())

func _play_sequence(diag_path: String):
	print("LANCEMENT SEQUENCE : ", diag_path)
	if player: player.process_mode = Node.PROCESS_MODE_DISABLED
	
	if FileAccess.file_exists(diag_path):
		DialogueManager.show_example_dialogue_balloon(load(diag_path), "start")
		await DialogueManager.dialogue_ended
	else:
		print("ERREUR : Fichier manquant -> ", diag_path)

	if player: player.process_mode = Node.PROCESS_MODE_INHERIT
