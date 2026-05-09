extends CanvasLayer

var current_page : int = 1
var wave_color : Color = Color(0.75, 0.6, 0.3, 1.0) 
var wave_thickness : float = 2.0

var book_content = {
	1: {
		"level_title": "THE AWAKENING",
		"is_intro": true,
		"left_lesson": "INTRODUCTION",
		"left_text": "The world has fallen silent. Silence has devoured the echoes. Use this grimoire to master the laws of music and awaken the Spirits of Music.",
		"img_left": "res://Assets/Book/montagne.png",
		"right_lesson": "THE LAW OF LENGTH",
		"use_strings": true, 
		"txt_long": "[b]Low Frequencies[/b]\nA long string vibrates slowly.",
		"txt_med": "[b]Harmonic Balance[/b]\nMedium length creates harmonic balance.",
		"txt_short": "[b]High Frequencies[/b]\nA small string vibrates rapidly."
	},
	2: {
		"level_title": "HARMONIC RATIOS",
		"is_intro": false,
		"left_lesson": "THE PIANO",
		"left_text": "The piano is a mechanical string instrument. A key strike triggers a hammer to hit a tuned string, converting physical motion into acoustic vibrations.",
		"img_left": "res://Assets/Book/piano_mechanism.png", 
		"right_lesson": "PYTHAGOREAN MONOCHORD",
		"use_strings": false, 
		"right_text": "Pythagoras discovered that music is governed by ratios. Reducing a string to [b]1/2[/b] doubles the frequency ([b]Octave[/b]).\n\nRatios of [b]2/3[/b] ([b]Fifth[/b]) and [b]3/4[/b] ([b]Fourth[/b]) form the basis of the musical scales we use today.",
		"img_right": "res://Assets/Book/monocorde.png"
	},
	3: {
		"level_title": "RESONANT GEOMETRY",
		"is_intro": false,
		"left_lesson": "VIBRATING SURFACES",
		"left_text": "When a surface vibrates, the air pulses to form sound waves. The frequency depends on the object's mass and tension.\n\nOn a Chladni plate, dust dances into geometric patterns dictated by sound.",
		"img_left": "res://Assets/Book/sable.png",
		"right_lesson": "CHLADNI PATTERNS",
		"use_strings": false, 
		"right_text": "Lower frequencies create simple forms. Higher ones create intricate webs. These patterns translate invisible sound into visible geometry.",
		"img_right": "res://Assets/Book/sable2.png",
		"is_large_r": true 
	},
	4: {
		"level_title": "THE HEARTBEAT",
		"is_intro": false,
		"left_lesson": "DRUM RESONANCE",
		"left_text": "Drums produce sound through vibration. Striking the skin makes the air inside the hollow body vibrate. This space acts as a resonator, amplifying the sound.",
		"img_left": "res://Assets/Book/tambour.png",
		"right_lesson": "SIGNAL AND SYNC",
		"use_strings": false, 
		"right_text": "Drums were the first long distance communication tools. By mimicking speech cadence, bards sent messages across valleys.\n\nThey were used to synchronize rowers and armies to a shared, vital frequency.",
		"img_right": "res://Assets/Book/barde tambour.png",
		"is_large_r": true 
	},
	5: {
		"level_title": "THE HYDRAULIC FORCE",
		"is_intro": false,
		"left_lesson": "THE HYDRAULIS",
		"left_text": "The Hydraulis is the ancestor of all organs. Invented in Alexandria, it uses the weight of water to compress air.\n\nWater pressure ensures that notes remain stable, mirroring the eternal movement of the tides.",
		"img_left": "res://Assets/Book/hydraulis_diagram.png", 
		"right_lesson": "THE GREAT ORGAN",
		"use_strings": false, 
		"right_text": "While the Hydraulis uses water, the Great Organ uses bellows to breathe. Each pipe is a voice whose size dictates its song.\n\nAir is channeled through valves to transform raw pressure into harmonic resonance.",
		"img_right": "res://Assets/Book/pressure_gauge.png",
		"is_large_r": true 
	},
	6: {
		"level_title": "THE BREATH OF PROPORTION",
		"is_intro": false,
		"left_lesson": "AIR COLUMNS",
		"left_text": "The pitch of a pipe is determined by the length of the air column inside. A longer pipe contains more air, which vibrates at a lower frequency.\n\nOpening holes changes this length, allowing one tube to produce multiple notes.",
		"img_left": "res://Assets/Book/tube.png", 
		"right_lesson": "THE SYRINX",
		"use_strings": false, 
		"right_text": "The Pan Flute consists of reeds tied together. The player moves between pipes of fixed lengths to change notes.\n\nEach reed follows the same ratios as the Monochord, creating a scale through the geometry of breath.",
		"img_right": "res://Assets/Book/flute.png",
		"is_large_r": true 
	}
}

func _ready():
	for i in range(6, 0, -1):
		if Progression.unlocked_pages.get("page_" + str(i), false):
			current_page = i
			break
			
	if not Progression.page_unlocked_signal.is_connected(update_view):
		Progression.page_unlocked_signal.connect(update_view)
		
	await get_tree().process_frame
	update_view()

func _process(_delta):
	var page_key = "page_" + str(current_page)
	var is_unlocked = Progression.unlocked_pages.get(page_key, false)
	
	if self.visible and is_unlocked and book_content[current_page].get("use_strings", false):
		_redraw_all_waves()

func _unhandled_input(event):
	if not self.visible: return
	if event.is_action_pressed("ui_right") and current_page < book_content.size():
		current_page += 1
		update_view()
	if event.is_action_pressed("ui_left") and current_page > 1:
		current_page -= 1
		update_view()

func update_view():
	# On utilise get_node_or_null sur les chemins probables ou des noms uniques
	var title_l = _find_node_by_name("TitleLabel")
	var text_l = _find_node_by_name("RichTextLabelLecon")
	var img_l = _find_node_by_name("IllustrationLeft")
	var text_r = _find_node_by_name("RichTextLabelArchive") 
	var img_r = _find_node_by_name("IllustrationRight")
	var container_cordes = _find_node_by_name("ContainerCordes")

	var page_key = "page_" + str(current_page)
	var is_unlocked = Progression.unlocked_pages.get(page_key, false)

	if text_l: text_l.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	if text_r: text_r.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_LEFT)

	if not is_unlocked:
		if title_l: title_l.text = "LEVEL " + str(current_page) + " - ???"
		if text_l:
			text_l.fit_content = true
			text_l.text = "[center][b]MISSING PAGE[/b][/center]\n\n[left]This page has been torn from the grimoire. You must find it to reveal its secrets.[/left]"
		if img_l: img_l.hide()
		if img_r: img_r.hide()
		if text_r: text_r.hide()
		if container_cordes: container_cordes.hide()
		return

	if book_content.has(current_page):
		var data = book_content[current_page]
		if title_l: title_l.text = "LEVEL " + str(current_page) + " - " + data["level_title"]

		if text_l: 
			text_l.show()
			text_l.fit_content = true
			var title_str = "[center][b]" + (data["left_lesson"] if data.get("is_intro", false) else "LESSON " + str(current_page) + ": " + data["left_lesson"]) + "[/b][/center]\n\n"
			text_l.text = title_str + "[left]" + data["left_text"] + "[/left]"
			
		if img_l:
			img_l.show()
			img_l.texture = load(data["img_left"])
			_apply_img_settings(img_l, false)

		if data["use_strings"]:
			if img_r: img_r.hide()
			if text_r: text_r.hide()
			if container_cordes: container_cordes.show()
			_setup_strings_ui(data)
			_setup_waves()
		else:
			if container_cordes: container_cordes.hide()
			if text_r:
				text_r.show()
				text_r.fit_content = true
				var title_r = "[center][b]" + data["right_lesson"] + "[/b][/center]\n\n"
				text_r.text = title_r + "[left]" + data["right_text"] + "[/left]"
			if img_r:
				img_r.show()
				img_r.texture = load(data["img_right"])
				_apply_img_settings(img_r, data.get("is_large_r", false))

# Fonction utilitaire pour remplacer find_child qui semble poser problème
func _find_node_by_name(node_name: String) -> Node:
	# On cherche dans les enfants de manière récursive
	return find_child(node_name, true, false)

func _apply_img_settings(img_node: TextureRect, is_large: bool):
	if img_node:
		var target_height = 280 if is_large else 180 
		img_node.custom_minimum_size = Vector2(0, target_height)
		img_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _setup_strings_ui(data):
	var l_long = _find_node_by_name("LabelLong")
	var l_med = _find_node_by_name("LabelMed")
	var l_short = _find_node_by_name("LabelShort")
	if l_long: l_long.text = "[center][b]LESSON 1: " + data["right_lesson"] + "[/b][/center]\n\n[left]" + data["txt_long"] + "[/left]"
	if l_med: l_med.text = "[left]" + data["txt_med"] + "[/left]"
	if l_short: l_short.text = "[left]" + data["txt_short"] + "[/left]"

func _setup_waves():
	_connect_wave("TextureLongue", 6.0, 0.05)
	_connect_wave("TextureMoyenne", 4.0, 0.12)
	_connect_wave("TexturePetite", 2.0, 0.3)

func _connect_wave(node_name, amp, freq):
	var node = _find_node_by_name(node_name)
	if node:
		if node.is_connected("draw", _on_draw_wave): node.draw.disconnect(_on_draw_wave)
		node.draw.connect(_on_draw_wave.bind(node, amp, freq))

func _on_draw_wave(node, amp, freq):
	var time = Time.get_ticks_msec() * 0.01
	var points = PackedVector2Array()
	var y_off = node.size.y / 2.0
	for x in range(0, int(node.size.x), 2):
		var y = amp * sin((x + time) * freq)
		points.append(Vector2(x, y_off + y))
	node.draw_polyline(points, wave_color, wave_thickness)

func _redraw_all_waves():
	for n in ["TextureLongue", "TextureMoyenne", "TexturePetite"]:
		var node = _find_node_by_name(n)
		if node: node.queue_redraw()
