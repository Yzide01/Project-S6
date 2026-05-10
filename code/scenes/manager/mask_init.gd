extends ColorRect

func _ready() -> void:
	# Make sure the ColorRect covers the whole screen if you have a moving camera
	# (If your camera is static, you can ignore this line)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var nom_scene = get_tree().current_scene.name.to_lower()
	var mat = material as ShaderMaterial
	if not mat: return
	
	# Auto-set the starting color based on the current level
	if "niveau6" in nom_scene or "niveau5" in nom_scene:
		mat.set_shader_parameter("saturation", 1.0)
	elif "niveau4" in nom_scene or "niveau3" in nom_scene:
		mat.set_shader_parameter("saturation", 0.3)
	else:
		mat.set_shader_parameter("saturation", 0.0)
