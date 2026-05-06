extends Node2D

@export var tube_size: int = 1 
@onready var interactable_area = $Interactable

func _ready() -> void:
	if interactable_area:
		interactable_area.is_interactable = true
		interactable_area.interact = _on_interact

func _on_interact() -> void:
	var level = get_tree().get_first_node_in_group("level6")
	if level and level.has_method("check_tube"):
		level.check_tube(tube_size, self)
