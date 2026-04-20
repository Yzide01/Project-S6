extends Area2D

@export var object_name: String = "Collectable"

@onready var interactable: Area2D = $Interactable
@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $SolidWall/CollisionShape2D
@onready var animations = $AnimationPlayer

func _ready() -> void:
	interactable.interact = _on_interact
	object_name = "Collectable"
	
func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()

func _on_interact(_player: Node2D) -> void:

	animations.play("spin")
	await animations.animation_finished
	queue_free()
