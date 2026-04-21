extends CanvasLayer

# Le % permet à Godot de trouver le nœud directement, peu importe où il est rangé !
@onready var left_page = %RichTextLabel
@onready var right_page = %RichTextLabel2

func _ready():
	# On cache le livre au lancement du jeu
	hide()

func open_book(title: String, content_left: String, content_right: String):
	# Cette fonction sera appelée quand on ramasse la page !
	show() # On affiche le livre
	left_page.text = "[center][b]" + title + "[/b][/center]\n\n" + content_left
	right_page.text = content_right

func _input(event):
	# Si le livre est visible et qu'on appuie sur Echap (ui_cancel) ou Entrée (ui_accept)
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept")):
		hide() # On referme le livre
