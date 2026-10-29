class_name EndingScreen
extends CanvasLayer

# The ending sequence (StoryAct): the farm darkens, the ending's title, then its lines one at a time, each
# faded in over the farm; then the credits roll up the screen, and it fades back to the farm and play goes
# on. Space (or A) shows the next line, or hurries the credits. The day is held while it plays (main checks
# StoryAct.playing()).

const DIM := 0.78
const FADE := 1.2             # seconds for the dark to come up, and to go
const LINE_FADE := 0.9
const CREDITS_SECONDS := 26.0
const HURRY := 5.0            # the credits run this many times faster while hurried

var active := false
var stage := ""               # dim, lines, credits, out
var lines: Array = []
var line := -1                # -1: the title
var t := 0.0
var hurry := false
var _done: Callable
var shade: ColorRect
var title_label: Label
var text_label: Label
var hint_label: Label
var roll: VBoxContainer
var credit_lines: Array = []


func _init() -> void:
	layer = 60
	visible = false
	shade = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.03, 0.0)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	title_label = _label(34, Color("d8b050"))
	text_label = _label(22, Color("e8dcc0"))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label = _label(13, Color("9a8a6a"))
	hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.offset_top = -48
	hint_label.offset_bottom = -20
	hint_label.text = "Space: next"
	roll = VBoxContainer.new()
	roll.alignment = BoxContainer.ALIGNMENT_BEGIN
	roll.add_theme_constant_override("separation", 10)
	roll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(roll)


func _label(font_size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.02, 0.95))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.offset_left = 120
	l.offset_right = -120
	add_child(l)
	return l


func play(title: String, ending_lines: Array, credits: Array, done: Callable) -> void:
	active = true
	visible = true
	lines = ending_lines
	line = -1
	_done = done
	hurry = false
	title_label.text = title
	text_label.text = ""
	title_label.modulate.a = 0.0
	text_label.modulate.a = 0.0
	hint_label.modulate.a = 0.0
	for c in roll.get_children():
		c.queue_free()
	credit_lines = credits
	for c in credits:
		var l := Label.new()
		l.text = str(c)
		l.add_theme_font_size_override("font_size", 26 if c == credits[0] else 18)
		l.add_theme_color_override("font_color", Color("d8b050") if c == credits[0] else Color("e8dcc0"))
		l.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.02, 0.95))
		l.add_theme_constant_override("outline_size", 5)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(0, 22)
		roll.add_child(l)
	roll.visible = false
	_stage("dim")


func _stage(s: String) -> void:
	stage = s
	t = 0.0


# Space: the next line; in the credits, hurry them.
func advance() -> void:
	match stage:
		"dim":
			_stage("lines")
		"lines":
			if t < LINE_FADE * 0.5:
				t = LINE_FADE   # a press mid-fade finishes the fade first
				return
			line += 1
			if line >= lines.size():
				title_label.modulate.a = 0.0
				text_label.modulate.a = 0.0
				_start_credits()
				return
			text_label.text = str(lines[line])
			t = 0.0
		"credits":
			hurry = true


# Shows line n (-1 the title) at once, faded in, for screenshots.
func jump(n: int) -> void:
	shade.color.a = DIM
	_stage("lines")
	line = n
	if n >= lines.size():
		_start_credits()
		t = CREDITS_SECONDS * 0.35
		_process(0.0)
		return
	text_label.text = str(lines[n]) if n >= 0 else ""
	t = LINE_FADE
	_process(0.0)


func _start_credits() -> void:
	_stage("credits")
	roll.visible = true
	hint_label.text = "Space: faster"


func _process(delta: float) -> void:
	if not active:
		return
	t += delta
	var vp := get_viewport().get_visible_rect().size
	match stage:
		"dim":
			shade.color.a = DIM * clampf(t / FADE, 0.0, 1.0)
			if t >= FADE:
				_stage("lines")
				t = 0.0
		"lines":
			var a := clampf(t / LINE_FADE, 0.0, 1.0)
			hint_label.modulate.a = a * 0.8
			if line < 0:
				title_label.modulate.a = a
				text_label.modulate.a = 0.0
			else:
				title_label.modulate.a = 0.0
				text_label.modulate.a = a
		"credits":
			if hurry:
				t += delta * (HURRY - 1.0)
			roll.size = Vector2(vp.x, 0)
			roll.position = Vector2(0, lerpf(vp.y, -roll.get_combined_minimum_size().y - 40.0, t / CREDITS_SECONDS))
			if t >= CREDITS_SECONDS:
				roll.visible = false
				hint_label.modulate.a = 0.0
				_stage("out")
		"out":
			shade.color.a = DIM * (1.0 - clampf(t / FADE, 0.0, 1.0))
			if t >= FADE:
				active = false
				visible = false
				hint_label.text = "Space: next"
				if _done.is_valid():
					_done.call()
