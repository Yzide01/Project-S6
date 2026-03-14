extends InteractableObject

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_wall_collision: CollisionShape2D = $SolidWall/CollisionShape2D
@onready var animations = $AnimationPlayer

@export var itemRes: InventoryItem

func _ready() -> void:
	object_name = "Collectable"
	
func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()

func interact(_player: Node2D) -> void:
	if not is_interactable:
		return
	animations.play("spin")
	await animations.animation_finished
	collect(_player.inventory)
