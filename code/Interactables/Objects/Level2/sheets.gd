extends Node2D

@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.interact_name = "Ramasser la partition"
		interactable_area.is_interactable = true 
		interactable_area.interact = _on_interact

func _on_interact():
	# 1. On cherche le piano dans la scène (grâce à son groupe)
	var piano = get_tree().get_first_node_in_group("Piano")
	
	# 2. On lui donne la partition
	if piano:
		piano.ajouter_partition()
	
	# 3. La partition disparaît de la carte
	queue_free()
