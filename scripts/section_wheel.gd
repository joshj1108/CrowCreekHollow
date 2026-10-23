class_name SectionWheel
extends CanvasLayer

## The section wheel: the menus that used to have their own keys, arranged around a ring. Shift or a
## click on the left stick opens it. The mouse hovers and clicks a section. On a controller the right
## stick highlights one and A opens it. B or Esc closes the wheel. Choosing a section closes the wheel
## and shows that section alone, with no other sections in sight.

signal section_chosen(section_name: String)

const SECTIONS := [
	{"name": "Skills", "subtitle": "How far you have come", "icon": "bars", "color": "7fbf5a"},
	{"name": "Gear", "subtitle": "What you wear and hold", "icon": "shield", "color": "7f9fbf"},
	{"name": "Craft", "subtitle": "Make, cook, and build", "icon": "hammer", "color": "c0703a"},
	{"name": "Quests", "subtitle": "What the farm asks of you", "icon": "scroll", "color": "e8d7a0"},
	{"name": "House", "subtitle": "Keep it standing", "icon": "house", "color": "d08a5a"},
	{"name": "Buildings", "subtitle": "The workshop, the coop, and the barn", "icon": "barn", "color": "b8443a"},
	{"name": "Achievements", "subtitle": "Things you have done", "icon": "trophy", "color": "e0b43c"},
]
const INNER_R := 92.0
const OUTER_R := 222.0
const GAP := 0.035            # the space between two segments, in radians
const STICK_DEADZONE := 0.5
const COL_DIM := Color(0.0, 0.0, 0.0, 0.6)
const COL_SEGMENT := Color("231a12")
const COL_SEGMENT_HOT := Color("65472a")
const COL_BORDER := Color("8a6a3a")
const COL_ACCENT := Color("d9a94e")
const COL_TEXT := Color("f1e4c8")
const COL_MUTED := Color("b3a27c")

var open := false
var highlight := 0
var ring: Control


func _ready() -> void:
	layer = 25
	ring = Control.new()
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.draw.connect(_draw_ring)
	ring.gui_input.connect(_on_ring_input)
	add_child(ring)
	visible = false


func show_wheel() -> void:
	open = true
	visible = true
	ring.mouse_filter = Control.MOUSE_FILTER_STOP
	ring.queue_redraw()


func hide_wheel() -> void:
	open = false
	visible = false
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if not open:
		return
	# The left stick moves the highlight; the mouse does the same when it moves.
	var pads := Input.get_connected_joypads()
	var device: int = pads[0] if not pads.is_empty() else 0
	var stick := Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
	if stick.length() > STICK_DEADZONE:
		var i := _segment_at(stick)
		if i != highlight:
			highlight = i
			ring.queue_redraw()
	if Input.is_action_just_pressed("ui_accept"):
		_choose(highlight)


func _segment_at(v: Vector2) -> int:
	var seg := TAU / float(SECTIONS.size())
	var angle := atan2(v.x, -v.y)   # zero is straight up, and the angle grows clockwise
	return posmod(roundi(angle / seg), SECTIONS.size())


func _centre() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func _on_ring_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var offset: Vector2 = (event as InputEventMouseMotion).position - _centre()
		if offset.length() >= INNER_R and offset.length() <= OUTER_R:
			var i := _segment_at(offset)
			if i != highlight:
				highlight = i
				ring.queue_redraw()
	elif event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var offset: Vector2 = (event as InputEventMouseButton).position - _centre()
		if offset.length() >= INNER_R and offset.length() <= OUTER_R:
			_choose(_segment_at(offset))
		else:
			# A click off the ring closes the wheel without choosing.
			hide_wheel()


func _choose(i: int) -> void:
	var section_name := str(SECTIONS[i]["name"])
	hide_wheel()
	section_chosen.emit(section_name)


func _draw_ring() -> void:
	var size_now := ring.get_rect().size
	ring.draw_rect(Rect2(Vector2.ZERO, size_now), COL_DIM)
	var c := size_now * 0.5
	var n := SECTIONS.size()
	var seg := TAU / float(n)
	var font := ThemeDB.fallback_font
	for i in n:
		var mid := float(i) * seg
		var a0 := mid - seg * 0.5 + GAP
		var a1 := mid + seg * 0.5 - GAP
		var points := PackedVector2Array()
		var steps := 20
		for k in range(steps + 1):
			points.append(c + _dir(lerpf(a0, a1, float(k) / steps)) * OUTER_R)
		for k in range(steps, -1, -1):
			points.append(c + _dir(lerpf(a0, a1, float(k) / steps)) * INNER_R)
		var hot := i == highlight
		ring.draw_colored_polygon(points, COL_SEGMENT_HOT if hot else COL_SEGMENT)
		var edge := PackedVector2Array(points)
		edge.append(points[0])
		ring.draw_polyline(edge, COL_ACCENT if hot else COL_BORDER, 3.0 if hot else 1.5)
		var at := c + _dir(mid) * ((INNER_R + OUTER_R) * 0.5)
		_icon(str(SECTIONS[i]["icon"]), at, 17.0, Color(str(SECTIONS[i]["color"])), hot)
	# The middle names the highlighted section.
	var name_text := str(SECTIONS[highlight]["name"])
	var name_width := font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	ring.draw_string(font, c + Vector2(-name_width * 0.5, -4.0), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, COL_ACCENT)
	var sub := str(SECTIONS[highlight]["subtitle"])
	var sub_width := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	ring.draw_string(font, c + Vector2(-sub_width * 0.5, 16.0), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, COL_MUTED)
	var hint := "Mouse or left stick to choose   ·   A or click to open   ·   B or Esc to close"
	var hint_width := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	ring.draw_string(font, Vector2(c.x - hint_width * 0.5, c.y + OUTER_R + 30.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COL_MUTED)


# A direction on the screen for an angle, zero straight up and growing clockwise.
func _dir(angle: float) -> Vector2:
	return Vector2(sin(angle), -cos(angle))


# Draws a section's icon in its own colour, centred on at and about 2 * size across. A highlighted
# icon is a shade lighter. Shapes are simple polygons, so the icons need no image files.
func _icon(kind: String, at: Vector2, size: float, base: Color, hot: bool) -> void:
	var col := base.lightened(0.18) if hot else base
	var dark := COL_SEGMENT
	var ink := Color("3b2a18")
	match kind:
		"bars":
			# Three rising bars, each a shade lighter than the last, like a chart of levels.
			var shades := [base.darkened(0.35), base, base.lightened(0.25)]
			if hot:
				for k in shades.size():
					shades[k] = shades[k].lightened(0.18)
			var heights := [0.45, 0.8, 1.15]
			for k in 3:
				var x0 := -0.95 + float(k) * 0.66
				_poly(at, size, [[x0, 0.9], [x0, 0.9 - heights[k]], [x0 + 0.52, 0.9 - heights[k]], [x0 + 0.52, 0.9]], shades[k])
		"shield":
			_poly(at, size, [[-0.8, -1.0], [0.8, -1.0], [0.8, 0.1], [0.0, 1.0], [-0.8, 0.1]], col)
			_poly(at, size, [[-0.8, -1.0], [0.0, -1.0], [0.0, 1.0], [-0.8, 0.1]], col.darkened(0.25))
		"hammer":
			ring.draw_line(at + Vector2(0.2, -0.2) * size, at + Vector2(-0.6, 0.9) * size, Color("e0cfae"), maxf(3.0, size * 0.22))
			_poly(at, size, [[0.0, -0.75], [0.8, -0.75], [0.8, -0.2], [0.0, -0.2]], col)
		"scroll":
			_poly(at, size, [[-0.6, -0.8], [0.6, -0.8], [0.6, 0.8], [-0.6, 0.8]], col)
			for y in [-0.4, 0.0, 0.4]:
				ring.draw_line(at + Vector2(-0.35, y) * size, at + Vector2(0.35, y) * size, ink, maxf(1.5, size * 0.1))
		"house":
			_poly(at, size, [[-1.0, 0.0], [0.0, -1.0], [1.0, 0.0]], col.darkened(0.3))
			_poly(at, size, [[-0.7, 0.0], [0.7, 0.0], [0.7, 0.9], [-0.7, 0.9]], col)
			_poly(at, size, [[-0.2, 0.9], [-0.2, 0.35], [0.2, 0.35], [0.2, 0.9]], dark)
		"barn":
			# A red barn with a grey silo beside it, so it doesn't read as a house.
			_poly(at, size, [[-1.0, -0.1], [-0.2, -0.7], [-0.2, 0.9], [-1.0, 0.9]], col)
			_poly(at, size, [[-0.6, 0.9], [-0.6, 0.3], [-0.4, 0.3], [-0.4, 0.9]], dark)
			_poly(at, size, [[0.2, -0.7], [0.2, 0.9], [0.9, 0.9], [0.9, -0.7], [0.55, -1.0]], Color("b8b8b8") if not hot else Color("d8d8d8"))
			for y in [-0.35, 0.1]:
				ring.draw_line(at + Vector2(0.2, y) * size, at + Vector2(0.9, y) * size, Color("7a7a7a"), maxf(1.5, size * 0.1))
		"trophy":
			_poly(at, size, [[-0.8, -0.9], [0.8, -0.9], [0.6, 0.0], [0.0, 0.4], [-0.6, 0.0]], col)
			_poly(at, size, [[-0.12, 0.4], [0.12, 0.4], [0.12, 0.7], [-0.12, 0.7]], col.darkened(0.2))
			_poly(at, size, [[-0.5, 0.7], [0.5, 0.7], [0.5, 0.9], [-0.5, 0.9]], col.darkened(0.2))


func _poly(at: Vector2, size: float, pairs: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for pair in pairs:
		pts.append(at + Vector2(pair[0], pair[1]) * size)
	ring.draw_colored_polygon(pts, col)
