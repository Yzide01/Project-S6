extends Node2D

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Pick up sheet music" 
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	var piano = get_tree().get_first_node_in_group("Piano")
	
	if piano:
		piano.ajouter_partition()
		# Le dialogue spécifique au fragment (1, 2 ou 3) 
		# sera géré par le piano pour être plus centralisé.
	
	queue_free()
