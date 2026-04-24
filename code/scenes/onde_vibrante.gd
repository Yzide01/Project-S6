extends Line2D

func _process(_delta):
	clear_points()
	# On dessine une ligne droite de force qui traverse le rectangle
	add_point(Vector2(0, 50))   # Point de départ (gauche)
	add_point(Vector2(500, 50)) # Point d'arrivée (droite)
	
	# Force la visibilité
	visible = true
	modulate = Color(1, 1, 1, 1) # Force le Blanc pur
