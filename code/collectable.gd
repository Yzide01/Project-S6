extends InteractableObject

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $SolidWall/CollisionShape2D
@onready var animations = $AnimationPlayer

func _ready() -> void:
	object_name = "Collectable"

func interact(_player: Node2D) -> void:
	if not is_interactable:
		return
	animations.play("spin")
	await animations.animation_finished
	queue_free()
