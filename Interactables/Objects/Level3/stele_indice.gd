extends Node2D



@onready var interactable = $Interactable 


func _ready() -> void:
	if interactable:
		interactable.is_interactable = true
		interactable.interact = _on_interact

	
func _on_interact():	
	var diag_path = "res://Dialogues/Level3/Intro.dialogue"
	var dialogue_res = load(diag_path)
	
	if dialogue_res:
		DialogueManager.show_example_dialogue_balloon(dialogue_res, "hint")
	else:
		print("ERREUR : Le fichier dialogue n'a pas été trouvé.")
