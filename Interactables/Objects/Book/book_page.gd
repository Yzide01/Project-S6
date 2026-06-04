extends Node2D

signal page_picked

@export var page_id: String = "page_1"

@onready var interactable = $Interactable
@onready var sprite = $Sprite2D

func _ready() -> void:
	sprite.visible = false
	if interactable:
		interactable.is_interactable = false
		interactable.interact = _on_interact
		
func victory():
	interactable.is_interactable = true
	sprite.visible = true
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Book_Pages/page.dialogue"), "page_appear")

func _on_interact():
	if interactable.is_interactable == true:
		Progression.unlock_page(page_id)
		interactable.is_interactable = false
		sprite.visible = false
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/Book_Pages/page.dialogue"), "page_taken")
		page_picked.emit()
	else:
		return
