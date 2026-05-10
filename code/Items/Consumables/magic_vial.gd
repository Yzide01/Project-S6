extends InventoryItem
class_name MagicVial

@export var item_name: String = "Magic Vial"
@export var icon: Texture2D
@export var video_path: String = "res://code/Assets/Videos/vial_scene.ogv"

# This is the function the UI will call
func use_item():
	if item_name == "Magic Vial":
		VialScene.utiliser_fiole(video_path)
		print("Vial used!")
