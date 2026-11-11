class_name SectionWheel
extends CanvasLayer

## The section wheel: the menus that used to have their own keys, arranged around a ring. Shift or a
## click on the left stick opens it. The mouse hovers and clicks a section. On a controller the left
## stick highlights one and A opens it; the D-pad, the arrow keys or WASD step round the ring (right and
## down clockwise), and Enter, Space or A opens it. B or Esc closes the wheel. Choosing a section closes the wheel
## and shows that section alone, with no other sections in sight.
##
## UI-OVERHAUL-001 Phase 6: the wheel is drawn as a farmer's field instrument from pixel art (art/ui/wheel/,
## tools/make_wheel_art.py): walnut wedges in an iron rim, brass strips and rivets, and a brass-ringed hub that
## names the section. The lit wedge, its rim notch and the hub's pointer are pre-drawn frames, one per segment, so
## nothing is rotated or scaled off the pixel grid. Every piece is drawn at ART_SCALE; without the art the older
## code-drawn ring is drawn instead. Presentation only: the sections, the input and the geometry are unchanged.

signal section_chosen(section_name: String)

const SECTIONS := [
	{"name": "Skills", "subtitle": "How far you have come", "icon": "bars", "color": "7fbf5a"},
	{"name": "Gear", "subtitle": "What you wear and hold", "icon": "shield", "color": "7f9fbf"},
	{"name": "Craft", "subtitle": "Make, cook, and build", "icon": "hammer", "color": "c0703a"},
	{"name": "Quests", "subtitle": "What the farm asks of you", "icon": "scroll", "color": "e8d7a0"},
	{"name": "Diary", "subtitle": "What you have learned so far", "icon": "book", "color": "8a5a34"},
	{"name": "House", "subtitle": "Keep it standing", "icon": "house", "color": "d08a5a"},
	{"name": "Buildings", "subtitle": "The workshop, the coop, and the barn", "icon": "barn", "color": "b8443a"},
	{"name": "Achievements", "subtitle": "Things you have done", "icon": "trophy", "color": "e0b43c"},
]
# Icon art: Gear and Craft use the item icons (UiSkin), the rest art/ui/wheel_icons.png, five SpriteCook
# cells 16 wide and 20 tall: journal (Skills), scroll, house, barn, trophy. Drawn at 3x, like the world.
const WHEEL_ICONS_PATH := "res://art/ui/wheel_icons.png"
const WHEEL_CELL := Vector2(16, 20)
const WHEEL_CELLS := {"bars": 0, "scroll": 1, "house": 2, "barn": 3, "trophy": 4}
const ITEM_ICONS := {"shield": "shield", "hammer": "hammer"}
const ICON_SCALE := 3.0
const ICON_HOT := Color(1.25, 1.2, 1.1)   # the highlighted section's icon is a little brighter
const INNER_R := 92.0
const OUTER_R := 222.0
const GAP := 0.035            # the space between two segments, in radians
const STICK_DEADZONE := 0.5
const COL_DIM := Color(0.0, 0.0, 0.0, 0.6)
const COL_SEGMENT := Color("231a12")
const COL_SEGMENT_HOT := Color("65472a")
const COL_BORDER := Color("8a6a3a")
const COL_ACCENT := Color("d8b050")
const COL_TEXT := Color("e8dcc0")
const COL_MUTED := Color("9a8a6a")
const PLAQUE_W := 168.0       # the widest the middle plaque gets, so it stays inside the ring
const PLAQUE_PAD := Vector2(18, 14)
const COL_IRON := Color("5f5b55")
const WOOD_SHADE := Color(0.72, 0.68, 0.64)   # the wood's tint on a segment that isn't highlighted
const WOOD_HOT := Color(1.35, 1.2, 1.0)        # and on the highlighted one

# The Phase 6 art, drawn at 2x like the diary and the HUD.
const ART_DIR := "res://art/ui/wheel/"
const ART_SCALE := 2.0
const DIAL_SIZE := 232.0
const ICON_SIZE := 20.0
const ICON_R := 150.0          # the icon-and-label block's centre, from the wheel's centre (screen px)
const LABEL_SIZE := 12
const COL_LABEL := Color("a89878")
const COL_LABEL_HOT := Color("efe4c8")
const COL_NAME := Color("e8dcc0")
const COL_SUB := Color("b0a080")
const COL_GLYPH_BG := Color("2f1c12")
const COL_GLYPH_EDGE := Color("8a6a3a")
const HUB_TEXT_W := 128.0      # the hub's text column: inside the brass ring (radius 79 px at 2x)
static var fade_seconds := 0.18   # the open and close fade; 0 shows and hides at once (tests set it)

var open := false
var highlight := 0
var ring: Control
var pad_prompts := false       # the prompts name the controller's buttons (the last device used was a pad)
var _fade := 1.0               # 0 to 1: how far the wheel has faded in
var _fading_out := false
var dial_tex: Texture2D = _art("dial")
var hot_tex: Texture2D = _art("hot")
var icon_tex: Texture2D = _art("icons")
var wheel_icons: Texture2D = load(WHEEL_ICONS_PATH) if ResourceLoader.exists(WHEEL_ICONS_PATH) else null


func _ready() -> void:
	layer = 25
	ring = Control.new()
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.draw.connect(_draw_ring)
	ring.gui_input.connect(_on_ring_input)
	add_child(ring)
	visible = false


static func _art(art_name: String) -> Texture2D:
	var path := ART_DIR + art_name + ".png"
	return load(path) if ResourceLoader.exists(path) else null


# The wheel takes input from its first frame; the fade is only how it looks.
func show_wheel() -> void:
	open = true
	visible = true
	_fading_out = false
	ring.mouse_filter = Control.MOUSE_FILTER_STOP
	# The prompts follow the device the rest of the UI last saw.
	var host := get_parent()
	var bar: Object = host.get("action_bar") if host != null else null
	if bar != null and bar.get("_pad_glyphs") != null:
		pad_prompts = bool(bar.get("_pad_glyphs"))
	_fade = 0.0 if fade_seconds > 0.0 else 1.0
	ring.modulate.a = _fade
	ring.queue_redraw()


# Closing (Esc, B, Shift, a click off the ring) fades out; choosing a section hides it at once, as the
# section's panel takes the screen. Either way the wheel stops taking input now.
func hide_wheel(fade_out := true) -> void:
	open = false
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fade_out and fade_seconds > 0.0 and visible and _fade > 0.0:
		_fading_out = true
	else:
		_fading_out = false
		visible = false


# Notes which device was used last, for the prompts. Never handles the event.
func _input(event: InputEvent) -> void:
	if not open:
		return
	var pad := pad_prompts
	if event is InputEventJoypadButton:
		pad = true
	elif event is InputEventJoypadMotion:
		pad = pad or absf((event as InputEventJoypadMotion).axis_value) > STICK_DEADZONE
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false
	if pad != pad_prompts:
		pad_prompts = pad
		ring.queue_redraw()


func _process(delta: float) -> void:
	if _fading_out:
		_fade = maxf(0.0, _fade - delta / fade_seconds)
		ring.modulate.a = _fade
		if _fade <= 0.0:
			_fading_out = false
			visible = false
		return
	if not open:
		return
	if _fade < 1.0:
		_fade = minf(1.0, _fade + delta / maxf(fade_seconds, 0.001))
		ring.modulate.a = _fade
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


# The D-pad, arrows and WASD step the highlight round the ring. The stick's own motion is left to
# _process, which points at a segment instead.
func _unhandled_input(event: InputEvent) -> void:
	if not open or event is InputEventJoypadMotion:
		return
	var step := 0
	if event.is_action_pressed("ui_right", true) or event.is_action_pressed("ui_down", true):
		step = 1
	elif event.is_action_pressed("ui_left", true) or event.is_action_pressed("ui_up", true):
		step = -1
	if step == 0:
		return
	highlight = posmod(highlight + step, SECTIONS.size())
	ring.queue_redraw()
	get_viewport().set_input_as_handled()


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
	hide_wheel(false)
	section_chosen.emit(section_name)


func _draw_ring() -> void:
	if dial_tex == null or hot_tex == null or icon_tex == null:
		_draw_ring_flat()
		return
	var size_now := ring.get_rect().size
	ring.draw_rect(Rect2(Vector2.ZERO, size_now), COL_DIM)
	var c := (size_now * 0.5).round()
	var n := SECTIONS.size()
	var seg := TAU / float(n)
	var font := ThemeDB.fallback_font
	var dial := Vector2(DIAL_SIZE, DIAL_SIZE) * ART_SCALE
	var at := c - dial * 0.5
	ring.draw_texture_rect(dial_tex, Rect2(at, dial), false)
	ring.draw_texture_rect_region(hot_tex, Rect2(at, dial), Rect2(highlight * DIAL_SIZE, 0, DIAL_SIZE, DIAL_SIZE))
	# Each wedge: its icon with its name under it, the pair centred ICON_R out. The lit wedge's icon is a
	# shade brighter and its name ivory; the rest are muted, so the lit one is the one the eye finds.
	for i in n:
		var hot := i == highlight
		var mid := float(i) * seg
		var label := str(SECTIONS[i]["name"])
		var label_dim := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE)
		var icon := Vector2(ICON_SIZE, ICON_SIZE) * ART_SCALE
		var block_h := icon.y + 4.0 + label_dim.y
		var centre := c + _dir(mid) * ICON_R
		var icon_at := (centre - Vector2(icon.x * 0.5, block_h * 0.5)).round()
		ring.draw_texture_rect_region(icon_tex, Rect2(icon_at, icon), Rect2(i * ICON_SIZE, 0, ICON_SIZE, ICON_SIZE),
			ICON_HOT if hot else Color(0.86, 0.84, 0.8))
		var base := Vector2(centre.x - label_dim.x * 0.5, icon_at.y + icon.y + 4.0 + font.get_ascent(LABEL_SIZE)).round()
		ring.draw_string(font, base + Vector2(0, 2), label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, Color(0, 0, 0, 0.7))
		ring.draw_string(font, base, label, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, COL_LABEL_HOT if hot else COL_LABEL)
	# The hub names the lit section and says what it is for. The name shrinks to fit; the subtitle wraps.
	var name_text := str(SECTIONS[highlight]["name"])
	var name_size := 20
	while name_size > 14 and font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size).x > HUB_TEXT_W:
		name_size -= 1
	var name_dim := font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size)
	var sub := str(SECTIONS[highlight]["subtitle"])
	var sub_dim := font.get_multiline_string_size(sub, HORIZONTAL_ALIGNMENT_CENTER, HUB_TEXT_W, 12)
	var top := c.y - (name_dim.y + 4.0 + sub_dim.y) * 0.5
	var left := c.x - HUB_TEXT_W * 0.5
	ring.draw_string(font, Vector2(left, top + font.get_ascent(name_size) + 2), name_text, HORIZONTAL_ALIGNMENT_CENTER, HUB_TEXT_W, name_size, Color(0, 0, 0, 0.7))
	ring.draw_string(font, Vector2(left, top + font.get_ascent(name_size)), name_text, HORIZONTAL_ALIGNMENT_CENTER, HUB_TEXT_W, name_size, COL_NAME)
	ring.draw_multiline_string(font, Vector2(left, top + name_dim.y + 4.0 + font.get_ascent(12)), sub, HORIZONTAL_ALIGNMENT_CENTER, HUB_TEXT_W, 12, -1, COL_SUB)
	# Above the dial: below it they would sit on the hotbar at 1280 x 720.
	_draw_prompts(font, Vector2(c.x, c.y - dial.y * 0.5 - 34.0))


# The button prompts over the wheel, in boxed glyphs for whichever device was used last.
func _draw_prompts(font: Font, centre_top: Vector2) -> void:
	var prompts: Array = [["L stick", "Choose"], ["A", "Open"], ["B", "Close"]]
	if not pad_prompts:
		prompts = [["Mouse", "Point"], ["Arrows", "Choose"], ["Enter", "Open"], ["Esc", "Close"]]
	var fs := 13
	var pieces: Array = []
	var total := 0.0
	for p in prompts:
		var gw := font.get_string_size(str(p[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 14.0
		var tw := font.get_string_size(str(p[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		pieces.append([gw, tw])
		total += gw + 6.0 + tw
	total += 18.0 * (prompts.size() - 1)
	var x := roundf(centre_top.x - total * 0.5)
	var h := 22.0
	for k in prompts.size():
		var gw: float = pieces[k][0]
		var box := Rect2(x, centre_top.y, gw, h)
		ring.draw_rect(box, COL_GLYPH_BG)
		ring.draw_rect(box, COL_GLYPH_EDGE, false, 2.0)
		var base_y := roundf(centre_top.y + (h - font.get_height(fs)) * 0.5 + font.get_ascent(fs))
		ring.draw_string(font, Vector2(x, base_y), str(prompts[k][0]), HORIZONTAL_ALIGNMENT_CENTER, gw, fs, COL_TEXT)
		x += gw + 6.0
		ring.draw_string(font, Vector2(x, base_y + 1), str(prompts[k][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.7))
		ring.draw_string(font, Vector2(x, base_y), str(prompts[k][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, COL_MUTED.lightened(0.2))
		x += float(pieces[k][1]) + 18.0


# The ring as drawn before Phase 6, kept for when the art is missing.
func _draw_ring_flat() -> void:
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
		var wood := UiSkin.wood()
		if wood != null:
			# The UI's wood, mapped across the whole ring so the grain runs on from one segment to the next;
			# the highlighted segment is lit, the rest shaded. Edges are iron, gold on the highlight.
			var uvs := PackedVector2Array()
			for p in points:
				uvs.append((p - c) / (OUTER_R * 2.0) + Vector2(0.5, 0.5))
			ring.draw_colored_polygon(points, WOOD_HOT if hot else WOOD_SHADE, uvs, wood)
		else:
			ring.draw_colored_polygon(points, COL_SEGMENT_HOT if hot else COL_SEGMENT)
		var edge := PackedVector2Array(points)
		edge.append(points[0])
		var border := COL_IRON if wood != null else COL_BORDER
		ring.draw_polyline(edge, COL_ACCENT if hot else border, 3.0 if hot else 2.0)
		var at := c + _dir(mid) * ((INNER_R + OUTER_R) * 0.5)
		if not _icon_sprite(str(SECTIONS[i]["icon"]), at, hot):
			_icon(str(SECTIONS[i]["icon"]), at, 17.0, Color(str(SECTIONS[i]["color"])), hot)
	# The middle names the highlighted section, on a wooden plaque when the UI art is there. The name
	# shrinks to fit the plaque and the subtitle wraps, and both sit centred in it.
	var text_w := PLAQUE_W - PLAQUE_PAD.x * 2.0
	var name_text := str(SECTIONS[highlight]["name"])
	var name_size := 24
	while name_size > 16 and font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size).x > text_w:
		name_size -= 1
	var name_dim := font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, name_size)
	var sub := str(SECTIONS[highlight]["subtitle"])
	var sub_dim := font.get_multiline_string_size(sub, HORIZONTAL_ALIGNMENT_CENTER, text_w, 13)
	var block := Vector2(maxf(name_dim.x, sub_dim.x), name_dim.y + 2.0 + sub_dim.y)
	var top := c.y - block.y * 0.5
	var plaque := UiSkin.slot(false)
	if plaque != null:
		var box := Vector2(block.x, block.y) + PLAQUE_PAD * 2.0
		ring.draw_style_box(plaque, Rect2(c - box * 0.5, box).abs())
	ring.draw_string(font, Vector2(c.x - text_w * 0.5, top + font.get_ascent(name_size)), name_text, HORIZONTAL_ALIGNMENT_CENTER, text_w, name_size, COL_ACCENT)
	ring.draw_multiline_string(font, Vector2(c.x - text_w * 0.5, top + name_dim.y + 2.0 + font.get_ascent(13)), sub, HORIZONTAL_ALIGNMENT_CENTER, text_w, 13, -1, COL_MUTED)
	var hint := "Mouse, left stick or arrows to choose   ·   A, Enter or click to open   ·   B or Esc to close"
	var hint_width := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	ring.draw_string(font, Vector2(c.x - hint_width * 0.5, c.y + OUTER_R + 30.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COL_MUTED)


# A direction on the screen for an angle, zero straight up and growing clockwise.
func _dir(angle: float) -> Vector2:
	return Vector2(sin(angle), -cos(angle))


# Draws a section's icon from its SpriteCook art, centred on at and snapped to whole pixels.
# Returns false when there is no art for it, so the shapes below are drawn instead.
func _icon_sprite(kind: String, at: Vector2, hot: bool) -> bool:
	var tex: Texture2D = null
	var region := Rect2()
	if WHEEL_CELLS.has(kind) and wheel_icons != null:
		tex = wheel_icons
		region = Rect2(Vector2(WHEEL_CELLS[kind] * WHEEL_CELL.x, 0.0), WHEEL_CELL)
	elif ITEM_ICONS.has(kind):
		region = UiSkin.icon_rect(ITEM_ICONS[kind], Color.WHITE)
		tex = UiSkin.icons() if region.has_area() else null
	if tex == null:
		return false
	var sz := region.size * ICON_SCALE
	ring.draw_texture_rect_region(tex, Rect2((at - sz * 0.5).round(), sz), region, ICON_HOT if hot else Color.WHITE)
	return true


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
		"book":
			# A leather diary with page edges down its right side and a red ribbon.
			_poly(at, size, [[-0.75, -0.95], [0.75, -0.95], [0.75, 0.95], [-0.75, 0.95]], col)
			_poly(at, size, [[0.5, -0.85], [0.68, -0.85], [0.68, 0.85], [0.5, 0.85]], Color("e8dcc0"))
			_poly(at, size, [[-0.75, -0.95], [-0.5, -0.95], [-0.5, 0.95], [-0.75, 0.95]], col.darkened(0.35))
			_poly(at, size, [[0.05, -0.95], [0.22, -0.95], [0.22, 1.15], [0.05, 1.15]], Color("b8443a"))
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
