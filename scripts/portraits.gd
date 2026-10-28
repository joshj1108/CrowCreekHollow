class_name Portraits
extends RefCounted

# The walkers' portraits for the dialogue box, drawn in code until SpriteCook art replaces them (see DESIGN.md,
# Folk: the portrait sheet). Each is a framed bust on a 48 by 48 grid, drawn in whole cells so it reads as
# pixel art at any size, in the UI kit's colours: dark outlines, muted cloth, the frame's dark wood and iron.
# Expressions: neutral, smile, worry, grim and far (looking away). Who is a walker id: mill (Old Maren; the
# edge route is her too), orchard (Davy), chapel (the vicar), post (the postman) or grove (the woman in grey).

const GRID := 48
const EXPRESSIONS := ["neutral", "smile", "worry", "grim", "far"]
const NAMES := {"mill": "Old Maren", "edge": "Old Maren", "orchard": "Davy Tull", "chapel": "The vicar",
	"post": "The postman", "grove": "The woman in grey"}
const INK := Color("1d1611")
const WOOD := Color("4a3424")
const WOOD_LIGHT := Color("6a4c34")
const IRON := Color("8a8a90")
const BACKS := {"mill": Color("3a3a44"), "orchard": Color("34402e"), "chapel": Color("2e2a34"),
	"post": Color("2c3444"), "grove": Color("201e26")}


static func id_for(who: String) -> String:
	return "mill" if who == "edge" else who


# The portrait of who, with an expression, filling rect (best square).
static func draw(ci: CanvasItem, who: String, expr: String, rect: Rect2) -> void:
	who = id_for(who)
	var side := floorf(minf(rect.size.x, rect.size.y) / GRID) * GRID
	if side <= 0.0:
		side = minf(rect.size.x, rect.size.y)
	var s := side / GRID
	var o := (rect.position + (rect.size - Vector2(side, side)) * 0.5).floor()
	var p := func(x: float, y: float, w: float, h: float, col: Color) -> void:
		ci.draw_rect(Rect2(o + Vector2(x, y) * s, Vector2(w, h) * s), col)
	# The frame: ink, dark wood with a lighter inner edge, iron brackets at the corners.
	p.call(0, 0, 48, 48, INK)
	p.call(1, 1, 46, 46, WOOD)
	p.call(3, 3, 42, 42, WOOD_LIGHT)
	p.call(4, 4, 40, 40, BACKS.get(who, BACKS["mill"]))
	# A little light behind the head, so the bust stands off the dark.
	p.call(12, 8, 24, 28, (BACKS.get(who, BACKS["mill"]) as Color).lightened(0.08))
	match who:
		"orchard":
			_davy(p, expr)
		"chapel":
			_vicar(p, expr)
		"post":
			_postman(p, expr)
		"grove":
			_woman(p, expr)
		_:
			_maren(p, expr)
	for c in [Vector2(1, 1), Vector2(42, 1), Vector2(1, 42), Vector2(42, 42)]:
		p.call(c.x, c.y, 5, 5, INK)
		p.call(c.x + 1, c.y + 1, 3, 3, IRON)


# Shoulders and a body colour, cut off by the frame's bottom.
static func _body(p: Callable, x: float, w: float, top: float, col: Color) -> void:
	p.call(x - 1, top - 1, w + 2, 45 - top, INK)
	p.call(x, top, w, 44 - top, col)


# A face: outline, skin, and the expression's eyes, brows and mouth. cx is the face's centre column.
static func _face(p: Callable, cx: float, top: float, w: float, h: float, skin: Color, expr: String, ink := INK) -> void:
	var x := cx - w / 2.0
	p.call(x - 1, top - 1, w + 2, h + 2, ink)
	p.call(x, top, w, h, skin)
	var shade := skin.darkened(0.18)
	p.call(x, top + h - 2, w, 2, shade)
	var ey := top + h * 0.42
	var lx := cx - 4
	var rx := cx + 2
	match expr:
		"smile":
			p.call(lx, ey + 1, 2, 1, ink)
			p.call(rx, ey + 1, 2, 1, ink)
			p.call(cx - 2, top + h - 4, 4, 1, ink)
			p.call(cx - 3, top + h - 5, 1, 1, ink)
			p.call(cx + 2, top + h - 5, 1, 1, ink)
		"worry":
			p.call(lx, ey, 2, 2, ink)
			p.call(rx, ey, 2, 2, ink)
			p.call(lx + 1, ey - 2, 2, 1, ink)
			p.call(lx, ey - 1, 1, 1, ink)
			p.call(rx - 1, ey - 2, 2, 1, ink)
			p.call(rx + 1, ey - 1, 1, 1, ink)
			p.call(cx - 1, top + h - 5, 2, 2, ink)
		"grim":
			p.call(lx - 1, ey - 1, 4, 1, ink)
			p.call(rx - 1, ey - 1, 4, 1, ink)
			p.call(lx, ey, 2, 1, ink)
			p.call(rx, ey, 2, 1, ink)
			p.call(cx - 3, top + h - 5, 6, 1, ink)
			p.call(cx - 3, top + h - 4, 1, 1, ink)
			p.call(cx + 2, top + h - 4, 1, 1, ink)
		"far":
			p.call(lx - 1, ey, 2, 2, ink)
			p.call(rx - 1, ey, 2, 2, ink)
			p.call(lx, ey - 1, 3, 1, shade)
			p.call(rx, ey - 1, 3, 1, shade)
			p.call(cx - 2, top + h - 5, 3, 1, ink)
		_:
			p.call(lx, ey, 2, 2, ink)
			p.call(rx, ey, 2, 2, ink)
			p.call(cx - 2, top + h - 5, 4, 1, ink)


# Old Maren: small and old, white hair in a bun, a grey shawl over a dark dress, lines at her eyes.
static func _maren(p: Callable, expr: String) -> void:
	_body(p, 9, 30, 33, Color("8a8a90"))
	p.call(12, 36, 24, 8, Color("3a3040"))
	p.call(14, 33, 20, 2, Color("9a9aa2"))
	p.call(21, 29, 6, 4, INK)
	p.call(22, 29, 4, 4, Color("d0b8a0"))
	_face(p, 24, 14, 14, 15, Color("e0c8b0"), expr)
	p.call(16, 11, 16, 5, INK)
	p.call(17, 12, 14, 4, Color("c8c8c8"))
	p.call(16, 14, 2, 6, Color("c8c8c8"))
	p.call(30, 14, 2, 6, Color("c8c8c8"))
	p.call(21, 8, 6, 4, INK)
	p.call(22, 9, 4, 3, Color("b8b8b8"))
	if expr != "smile":
		p.call(17, 21, 1, 1, Color("b89c84"))
		p.call(30, 21, 1, 1, Color("b89c84"))


# Davy Tull: a boy of eleven or so, a flat cap, freckles, a red scarf at his throat, a brown jacket.
static func _davy(p: Callable, expr: String) -> void:
	_body(p, 10, 28, 34, Color("6a4a32"))
	p.call(18, 34, 12, 10, Color("4a3424"))
	p.call(14, 31, 20, 4, INK)
	p.call(15, 32, 18, 3, Color("9a3028"))
	_face(p, 24, 15, 14, 15, Color("e8d0b8"), expr)
	p.call(19, 23, 1, 1, Color("c09070"))
	p.call(21, 24, 1, 1, Color("c09070"))
	p.call(27, 24, 1, 1, Color("c09070"))
	p.call(29, 23, 1, 1, Color("c09070"))
	p.call(15, 11, 18, 6, INK)
	p.call(16, 12, 16, 4, Color("4a4038"))
	p.call(14, 15, 14, 2, INK)
	p.call(15, 15, 12, 1, Color("5a5046"))
	p.call(31, 16, 2, 4, Color("8a5a34"))


# The vicar: long and thin in the face, a wide black hat, a black coat and a white collar.
static func _vicar(p: Callable, expr: String) -> void:
	_body(p, 9, 30, 33, Color("201c22"))
	p.call(21, 31, 6, 3, INK)
	p.call(22, 32, 4, 2, Color("e8e4dc"))
	_face(p, 24, 13, 12, 18, Color("dcc4ac"), expr)
	p.call(18, 13, 1, 18, Color("c4ac94"))
	p.call(10, 10, 28, 4, INK)
	p.call(11, 11, 26, 2, Color("201c22"))
	p.call(16, 4, 16, 7, INK)
	p.call(17, 5, 14, 6, Color("201c22"))
	p.call(17, 9, 14, 1, Color("3a343e"))


# The postman: a navy coat and peaked cap, a grey moustache, the satchel's strap across his chest.
static func _postman(p: Callable, expr: String) -> void:
	_body(p, 8, 32, 33, Color("2c3a56"))
	for i in 10:
		p.call(11 + i * 2, 34 + i, 3, 2, Color("6a4a2e"))
	p.call(23, 36, 2, 2, Color("c8a040"))
	_face(p, 24, 14, 14, 16, Color("e0c8b0"), expr)
	if expr != "worry":
		p.call(20, 25, 8, 2, Color("a0a0a0"))
		p.call(19, 26, 1, 1, Color("a0a0a0"))
		p.call(28, 26, 1, 1, Color("a0a0a0"))
	p.call(16, 8, 16, 7, INK)
	p.call(17, 9, 14, 5, Color("2c3a56"))
	p.call(17, 12, 14, 1, Color("c8a040"))
	p.call(15, 14, 18, 2, INK)
	p.call(16, 14, 16, 1, Color("1a1a22"))


# The woman in grey: the shawl drawn over her head, her face in its shadow. Only her eyes show, and a strand of
# hair the colour of crow feathers. Her expressions are only in the eyes.
static func _woman(p: Callable, expr: String) -> void:
	_body(p, 8, 32, 32, Color("7a7a80"))
	p.call(13, 9, 22, 26, INK)
	p.call(14, 10, 20, 24, Color("7a7a80"))
	p.call(17, 14, 14, 18, Color("141018"))
	p.call(17, 14, 2, 10, Color("08060a"))
	var eye := Color("b8b0a8")
	match expr:
		"far":
			p.call(19, 21, 3, 1, eye)
			p.call(26, 21, 3, 1, eye)
		"grim":
			p.call(20, 21, 2, 1, eye)
			p.call(26, 21, 2, 1, eye)
		_:
			p.call(20, 21, 2, 2, eye)
			p.call(26, 21, 2, 2, eye)
	p.call(18, 31, 12, 1, Color("5a5a62"))
