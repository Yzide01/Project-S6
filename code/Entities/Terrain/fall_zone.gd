extends Area2D

func _process(_delta):
	for body in get_overlapping_bodies():
		if body is Player:
			# Si le joueur atterrit et qu'il est coincé dans la zone
			if body.z_height <= body.current_floor_z:
				body.respawn()
