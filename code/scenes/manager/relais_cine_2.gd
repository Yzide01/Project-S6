extends Node

func _ready():
	# Dès que cette scène invisible se charge (donc à la fin de la Cine 1),
	# elle lance immédiatement la Cinématique 2, puis envoie vers le Niveau 1
	SceneManager.jouer_cinematique(
		"res://Assets/Videos/Scene-2.ogv", 
		"res://Levels/niveau1_cordeV2.tscn" 
	)
