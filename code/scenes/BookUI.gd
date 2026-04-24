extends CanvasLayer

var current_page : int = 1
var max_pages : int = 6

var book_content = {
	1: {
		"title": "SOUND DIMENSION",
		"left_page": "[center][b]INTRODUCTION[/b][/center]\n\nThe world has stopped vibrating. Silence has devoured the echoes. This book is the key to awakening the Spirits of Music.",
		"right_page": "[center][b]LENGTH DETERMINES PITCH[/b][/center]\n\n• [b]Long String[/b] = Low Frequency.\n• [b]Short String[/b] = High Frequency."
	},
	2: {
		"title": "RESONANCE",
		"left_page": "[center][b]PYTHAGORAS[/b][/center]\n\nIn the 6th century BC, Pythagoras proved that music is mathematical. By dividing a string in two, he obtained a perfect octave.",
		"right_page": "[center][b]ECHO AND SPACE[/b][/center]\n\n• [b]High Pitch[/b] is an arrow: precise but short.\n• [b]Low Pitch[/b] is a wave: powerful and far."
	},
	3: {
		"title": "MASS AND VIBRATION",
		"left_page": "[center][b]LITHOPHONES[/b][/center]\n\nCarved stones were humanity's first massive instruments. The weight defines the voice.",
		"right_page": "[center][b]THE INFLUENCE OF MASS[/b][/center]\n\n• [b]More water[/b] = Lower Sound.\n• [b]Empty basin[/b] = Higher Sound."
	},
	4: {
		"title": "MEMBRANE TENSION",
		"left_page": "[center][b]WAR TIMPANI[/b][/center]\n\nIn the 17th century, tuning screws allowed drums to be tuned precisely for the orchestra.",
		"right_page": "[center][b]ELASTICITY AND BOUNCE[/b][/center]\n\n• [b]Loose Surface[/b]: Absorbs energy.\n• [b]Tense Surface[/b]: Clear sound and bounce."
	},
	5: {
		"title": "PRESSURE REGULATION",
		"left_page": "[center][b]ALEXANDRIA'S ORGAN[/b][/center]\n\nInvented in the 3rd century BC, this mechanism used water to stabilize the air pressure.",
		"right_page": "[center][b]BREATH STABILITY[/b][/center]\n\n• [b]Bellows[/b]: Saccadic air.\n• [b]Hydraulis[/b]: Constant weight and pressure."
	},
	6: {
		"title": "TUBE PHYSICS",
		"left_page": "[center][b]MASTERS OF THE WIND[/b][/center]\n\nFrom prehistoric bone flutes to Inca panpipes, length defines the spirit of the wind.",
		"right_page": "[center][b]THE AIR COLUMN[/b][/center]\n\n• [b]Long Tube[/b] = Low sound.\n• [b]Short Tube[/b] = High sound."
	}
}

func _ready():
	await get_tree().process_frame
	update_view()

func _input(event):
	if self.visible:
		if event.is_action_pressed("ui_right"):
			_next_page()
		elif event.is_action_pressed("ui_left"):
			_prev_page()

func _next_page():
	if current_page < max_pages:
		current_page += 1
		update_view()

func _prev_page():
	if current_page > 1:
		current_page -= 1
		update_view()

func update_view():
	# On récupère les labels
	var title = find_child("TitleLabel", true, false)
	var text_l = find_child("RichTextLabelLecon", true, false) # Page Gauche
	var text_r = find_child("RichTextLabelArchive", true, false) # Page Droite
	
	if book_content.has(current_page):
		var data = book_content[current_page]
		
		# MISE À JOUR DU TITRE AVEC LE NUMÉRO
		if title: 
			title.text = "LEVEL " + str(current_page) + " - " + data["title"]
			
		# MISE À JOUR DES TEXTES INVERSÉS
		if text_l: text_l.text = data["left_page"]
		if text_r: text_r.text = data["right_page"]
