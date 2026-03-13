extends Node2D


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_inventory_gui_closed() -> void:
	get_tree().paused = false


func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
