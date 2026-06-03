extends ColorRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	visible = false
	
	var mat = material as ShaderMaterial
	if not mat: return
	
	var current_sat = 0.0
	if SceneManager.vial_use_count == 1:
		current_sat = 0.35
	elif SceneManager.vial_use_count == 2:
		current_sat = 0.80
	elif SceneManager.vial_use_count >= 3:
		current_sat = 1.0
		
	mat.set_shader_parameter("saturation", current_sat)
	
	call_deferred("_apply_material_to_world")

func _apply_material_to_world():
	if get_parent():
		_apply_recursive(get_parent())

func _apply_recursive(node: Node):
	if node is CanvasLayer:
		return
		
	if node.name == "Player" or node.name == "player" or node.is_in_group("player"):
		return
		
	if node is CanvasItem and node != self:
		if node.material == null:
			node.material = self.material
			
	for child in node.get_children():
		_apply_recursive(child)
