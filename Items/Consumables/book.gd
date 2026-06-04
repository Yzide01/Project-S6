extends InventoryItem
class_name BookItem

func use(player: Node) -> void:
	var book_ui = player.get_tree().get_first_node_in_group("book_ui")
	if book_ui:
		if book_ui.visible == false:
			book_ui.visible = true
		else:
			book_ui.visible = false
