extends Node

signal page_unlocked_signal

var unlocked_pages = {
	"page_1": false,
	"page_2": false,
	"page_3": false,
	"page_4": false,
	"page_5": false,
	"page_6": false
}

func unlock_page(page_id: String) -> void:
	if unlocked_pages.has(page_id):
		unlocked_pages[page_id] = true
		page_unlocked_signal.emit()
		
		# Auto-saves the global progression state.
		if SaveManager and SaveManager.has_method("save_game"):
			SaveManager.save_game()
