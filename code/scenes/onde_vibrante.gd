extends Line2D

func _process(_delta):
	clear_points()
	add_point(Vector2(0, 50))
	add_point(Vector2(500, 50))
	
	visible = true
	modulate = Color(1, 1, 1, 1)
