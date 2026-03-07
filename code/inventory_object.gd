extends Control


var is_grabbing = false
var grabbed_offset = Vector2()

var current_slot = null
var is_in_slot = false

var item_data: UsableObject

func _ready():
	_init_sprite()
	
func _process(_delta):
	if is_grabbing:
		position = get_global_mouse_position() + grabbed_offset

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#detecte le clique sur l'objet
		is_grabbing = event.pressed
		grabbed_offset = position - get_global_mouse_position()
		
		#detecte le ralachement de l'objet
		if(!event.pressed and current_slot != null):
			if(is_in_slot and !current_slot.is_used):
				_remove_previous_slot()
				_confirm_new_slot()
			else:
				_return_to_slot()

func _return_to_slot():
	position = current_slot.get_child(1).position
	
func _confirm_new_slot():
	current_slot.add_child(self)
	position = current_slot.get_child(1).position
	current_slot._use_slot()
	
func _remove_previous_slot():
	get_parent()._free_slot()
	get_parent().remove_child(self)
	
#detecte si l'objet touche un slot
func _on_object_area_area_entered(area):
	current_slot = area.get_parent()
	is_in_slot = true
	
func _on_object_area_area_exited(area):
	is_in_slot = false
	
func _init_sprite():
	if item_data and item_data.texture:
		$object_back.texture = item_data.texture

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
