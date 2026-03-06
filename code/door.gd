extends InteractableObject

@export var is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $SolidWall/CollisionShape2D

func _ready() -> void:
	object_name = "Porte"
	_update_door_state()

func interact(_player: Node2D) -> void:
	if not is_interactable:
		return
		
	is_open = !is_open
	_update_door_state()

func _update_door_state() -> void:
	if is_open:
		print("La porte s'ouvre !")
		solid_wall_collision.set_deferred("disabled", true)
		sprite.modulate = Color(1, 1, 1, 0.3) 
	else:
		print("La porte se ferme !")
		solid_wall_collision.set_deferred("disabled", false)
		sprite.modulate = Color(1, 1, 1, 1.0)
