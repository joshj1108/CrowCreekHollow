class_name DialogueBox
extends PanelContainer

# The dialogue box: a framed portrait (Portraits), the speaker's name in gold and what they say in cream. It
# shows walker talk two ways. say() is a passing line (a word on a trek, a visitor's greeting) that fades on a
# timer like a message and never stops play. play() is a scene: pages turned with Space (or A), which pauses
# the day while it is open (main checks in_scene()); its callback runs when the last page is turned.

const PORTRAIT := 96.0

var portrait: Control
var name_label: Label
var text_label: Label
var hint_label: Label
var who := ""
var expr := "neutral"
var pages: Array = []
var page := 0
var timer := 0.0
var _done: Callable
var _hint := ""


class PortraitView:
	extends Control
	var box: DialogueBox

	func _draw() -> void:
		if box != null and box.who != "":
			Portraits.draw(self, box.who, box.expr, Rect2(Vector2.ZERO, size))


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: StyleBox = UiSkin.panel(14)
	if sb == null:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(0.1, 0.08, 0.07, 0.94)
		flat.border_color = Color("1d1611")
		flat.set_border_width_all(3)
		flat.set_content_margin_all(14)
		sb = flat
	add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	portrait = PortraitView.new()
	(portrait as PortraitView).box = self
	portrait.custom_minimum_size = Vector2(PORTRAIT, PORTRAIT)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(portrait)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	row.add_child(col)
	name_label = _label(col, 17, Color("d8b050"))
	text_label = _label(col, 15, Color("e8dcc0"))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	hint_label = _label(col, 12, Color("9a8a6a"))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	visible = false


func _label(parent: Node, font_size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.92))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


# A passing line from who, shown for seconds. A scene that is open keeps the box.
func say(speaker: String, face: String, text: String, seconds: float) -> void:
	if in_scene():
		return
	_show(speaker, face, text)
	hint_label.text = ""
	timer = seconds


# A scene: each page is {who, expr, text}; who "" is the narration, with no portrait.
func play(scene_pages: Array, done: Callable, hint: String) -> void:
	pages = scene_pages
	page = 0
	_done = done
	timer = 0.0
	_hint = hint
	_turn()


func in_scene() -> bool:
	return not pages.is_empty()


# The next page, or the end of the scene.
func advance() -> void:
	if not in_scene():
		return
	page += 1
	if page >= pages.size():
		pages = []
		visible = false
		if _done.is_valid():
			_done.call()
		return
	_turn()


func close() -> void:
	pages = []
	timer = 0.0
	visible = false


func _turn() -> void:
	var pg: Dictionary = pages[page]
	_show(str(pg.get("who", "")), str(pg.get("expr", "neutral")), str(pg["text"]))
	hint_label.text = "%d / %d   %s" % [page + 1, pages.size(), _hint]


func _show(speaker: String, face: String, text: String) -> void:
	who = speaker
	expr = face
	portrait.visible = speaker != ""
	name_label.visible = speaker != ""
	name_label.text = str(Portraits.NAMES.get(speaker, ""))
	text_label.text = text
	text_label.add_theme_color_override("font_color", Color("e8dcc0") if speaker != "" else Color("c8bca0"))
	visible = true
	portrait.queue_redraw()


func _process(delta: float) -> void:
	if timer > 0.0 and not in_scene():
		timer -= delta
		if timer <= 0.0:
			visible = false
