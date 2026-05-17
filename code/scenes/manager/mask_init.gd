extends ColorRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat = material as ShaderMaterial
	if not mat: return
	
	# On applique la couleur de départ UNIQUEMENT basée sur le compteur global
	var current_sat = 0.0
	if SceneManager.vial_use_count == 1:
		current_sat = 0.35
	elif SceneManager.vial_use_count == 2:
		current_sat = 0.80
	elif SceneManager.vial_use_count >= 3:
		current_sat = 1.0
		
	mat.set_shader_parameter("saturation", current_sat)

func _process(_delta: float) -> void:
	# Garde le filtre ajusté à l'écran
	var cam_transform = get_canvas_transform()
	if cam_transform.get_scale().x != 0 and cam_transform.get_scale().y != 0:
		size = get_viewport_rect().size / cam_transform.get_scale()
		global_position = -cam_transform.get_origin() / cam_transform.get_scale()
