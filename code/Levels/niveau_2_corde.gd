extends Node2D
@onready var book_page = $decoration/BookPage
@onready var piano = $decoration/Piano
func _ready() -> void:
	piano.victory.connect(_victory)

func _victory():
	book_page.victory()
	await book_page.page_picked
	await get_tree().create_timer(3.0).timeout
	SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")
