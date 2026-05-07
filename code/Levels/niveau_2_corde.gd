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
	
	var ma_horde: Array[BaseEnemy] = []
	ma_horde.append(whisper_data)
	
	await start_combat(ma_horde)
	
	await get_tree().create_timer(3.0).timeout
	SceneManager.changer_niveau("res://Levels/niveau1_percussion.tscn")

func start_combat(horde: Array[BaseEnemy]) -> void:
	get_tree().paused = true
	
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 1000
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)
	
	current_battle_scene = battle_scene_packed.instantiate()
	current_battle_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_layer.add_child(current_battle_scene)
	
	var intro = "You only have your Strings, this attack doesn't deal much damage, but it lets you thin out the crowd—and who knows, maybe it'll scare them off\nThe Whisper is a fragile minion, but its silence is deadly."
	
	var mes_instruments: Array[String] = []
	mes_instruments.append("corde")
	
	current_battle_scene.start_encounter(horde, mes_instruments, intro)
	
	await current_battle_scene.tree_exited
	
	ui_layer.queue_free()
	current_battle_scene = null
	get_tree().paused = false
