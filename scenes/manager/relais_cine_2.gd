extends Node

func _ready():
	SceneManager.jouer_cinematique(
		"res://Assets/Videos/Scene-2.ogv", 
		"res://Levels/niveau1_cordeV2.tscn" ,
		"res://Assets/Sound/Ambiant sound/cinematics.ogg"
	)
