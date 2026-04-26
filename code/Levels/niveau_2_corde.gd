extends Node2D

@export var battle_scene_packed: PackedScene

@onready var book_page = $decoration/BookPage
@onready var piano = $decoration/Piano

@onready var whisper_data = preload("res://Entities/Enemies/whisper.tres")
@onready var dampener_data = preload("res://Entities/Enemies/dampener.tres")
var current_battle_scene: Node = null

func _ready() -> void:
	piano.victory.connect(_victory)

func _victory():
	book_page.victory()
	await book_page.page_picked
	
	await start_combat([whisper_data])
	
	await get_tree().create_timer(3.0).timeout
	SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")

func start_combat(horde: Array[BaseEnemy]) -> void:
	current_battle_scene = battle_scene_packed.instantiate()
	
	add_child(current_battle_scene)
	current_battle_scene.start_encounter(horde)
	
	await current_battle_scene.tree_exited
	current_battle_scene = null
