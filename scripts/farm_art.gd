extends RefCounted

## Picture drawing for the farm: the farmhouse and its porch, outbuildings, trees, rocks,
## brush piles, stumps, and the pond. Every function draws onto a CanvasItem (the farm
## node) during its own _draw call, so the farm reads as one set of buildings and ground.
## Shapes are built from polygons, so each piece can carry light, shade, and wear.

const T := 48.0   # one tile in world units. Matches PX in main.gd.

# Trees are drawn once into small pictures and reused, since a border of them is costly to draw every frame.
const TREE_SEEDS := 6                 # how many distinct trees of each kind
const TREE_BAKE_SCALE := 2.0          # the pictures are drawn at twice the size for sharpness
const TREE_SPRITE_W := 2.8 * T        # the tree picture's footprint on the map, in world units
const TREE_SPRITE_H := 3.3 * T
const TREE_CELL := Rect2(0.9 * T, 2.2 * T, T, T)  # where a tree sits inside its picture when baked


# A stable pseudo-random number for a tile or an object, so it looks the same every time it is drawn.
static func hash_int(x: int, y: int, salt: int) -> int:
	var h: int = (x * 73856093) ^ (y * 19349663) ^ (salt * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h)


# A number from 0 to 1 taken from one part of a hash.
static func frac(h: int, shift: int) -> float:
	return float((h >> shift) % 1000) / 1000.0


static func ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(16):
		var a: float = TAU * float(i) / 16.0
		out.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return out


# A lumpy outline, for stones and tree canopies.
static func blob(c: Vector2, rx: float, ry: float, h: int, points: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in points:
		var a: float = TAU * float(i) / float(points) + frac(h, i * 5) * 0.35
		var k: float = 0.82 + 0.3 * frac(h, 11 + i * 7)
		out.append(c + Vector2(cos(a) * rx * k, sin(a) * ry * k))
	return out


# Shrinks an outline toward its centre, then moves it. Used to stack light and shade on one shape.
static func scaled(pts: PackedVector2Array, c: Vector2, k: float, offset: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + offset + (p - c) * k)
	return out


# --- Stones, brush, and stumps -------------------------------------------------

# A rock with a shaded side, a lit top, a crack, and sometimes a patch of moss.
static func draw_rock(ci: CanvasItem, c: Vector2, r: float, h: int) -> void:
	ci.draw_colored_polygon(ellipse(c + Vector2(r * 0.22, r * 0.5), r * 1.0, r * 0.42), Color(0, 0, 0, 0.28))
	var outline := blob(c, r, r * 0.8, h, 9)
	ci.draw_colored_polygon(outline, Color("4a4a54"))
	ci.draw_colored_polygon(scaled(outline, c, 0.84, Vector2(-r * 0.1, -r * 0.14)), Color("6c6c78"))
	ci.draw_colored_polygon(scaled(outline, c, 0.45, Vector2(-r * 0.24, -r * 0.3)), Color("9d9daa"))
	ci.draw_line(c + Vector2(-r * 0.1, r * 0.1), c + Vector2(r * 0.3, r * 0.45), Color(0.18, 0.18, 0.22, 0.8), 1.2)
	if frac(h, 3) > 0.45:
		ci.draw_colored_polygon(ellipse(c + Vector2(-r * 0.4, -r * 0.2), r * 0.3, r * 0.16), Color(0.32, 0.52, 0.26, 0.92))


# A brush pile: a mound of leaves with dead sticks crossing over it.
static func draw_brush(ci: CanvasItem, c: Vector2, h: int) -> void:
	ci.draw_colored_polygon(ellipse(c + Vector2(T * 0.1, T * 0.2), T * 0.36, T * 0.14), Color(0, 0, 0, 0.26))
	for i in 7:
		var a: float = frac(h, i * 4) * TAU
		var d: float = T * 0.16 * frac(h, 20 + i * 3)
		var lc: Vector2 = c + Vector2(cos(a), sin(a)) * d
		var g := Color("2f5a24") if i % 2 == 0 else Color("4f7f36")
		ci.draw_colored_polygon(ellipse(lc, T * 0.14, T * 0.085), g)
	for i in 5:
		var ang: float = (frac(h, 40 + i * 5) - 0.5) * 1.6 + (0.7 if i % 2 == 0 else -0.7)
		var dir := Vector2(cos(ang), sin(ang))
		var len: float = T * (0.26 + 0.1 * frac(h, 60 + i * 3))
		var mid: Vector2 = c + Vector2(frac(h, 70 + i * 4) - 0.5, frac(h, 80 + i * 4) - 0.5) * T * 0.2
		ci.draw_line(mid - dir * len * 0.5, mid + dir * len * 0.5, Color("5e3f22"), 2.4)
		ci.draw_line(mid - dir * len * 0.5 + Vector2(0, -1), mid + dir * len * 0.5 + Vector2(0, -1), Color("9a7046"), 0.9)


# A felled tree's stump: a pale cut face with rings, and bark at the rim.
static func draw_stump(ci: CanvasItem, cell: Rect2) -> void:
	var c := cell.get_center() + Vector2(0, T * 0.12)
	ci.draw_colored_polygon(ellipse(c + Vector2(4, 6), T * 0.3, T * 0.14), Color(0, 0, 0, 0.26))
	ci.draw_colored_polygon(ellipse(c, T * 0.26, T * 0.2), Color("4a3424"))
	ci.draw_colored_polygon(ellipse(c, T * 0.2, T * 0.14), Color("c9a574"))
	ci.draw_arc(c, T * 0.12, 0.0, TAU, 14, Color("9a7450"), 1.2)
	ci.draw_arc(c, T * 0.06, 0.0, TAU, 10, Color("9a7450"), 1.0)


# --- Trees ----------------------------------------------------------------------

# The ground under a tree: leaf litter and shade, so the trunk never stands over bare background.
static func draw_tree_floor(ci: CanvasItem, cell: Rect2, h: int) -> void:
	ci.draw_rect(cell, Color("24402a"))
	for i in 4:
		var p := cell.position + Vector2(frac(h, 5 + i * 6) * cell.size.x, frac(h, 25 + i * 6) * cell.size.y)
		ci.draw_colored_polygon(ellipse(p, 3.0, 1.8), Color("6a4a2a") if i % 2 == 0 else Color("8a6a36"))


# variant: 0 is an oak, 1 a weeping willow, 2 a bare, dead-looking tree. Each one has a
# cool, slightly uneasy palette with warm light in the leaves, so it reads as cosy and eerie at once.
static func draw_tree(ci: CanvasItem, cell: Rect2, h: int, variant: int) -> void:
	var base := Vector2(cell.get_center().x, cell.end.y - T * 0.1)
	var trunk := Color("2a2019")
	if variant == 2:
		_dead_tree(ci, base, h)
		return
	# Roots flare into the ground, then the trunk rises.
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-T * 0.3, T * 0.1), base + Vector2(-T * 0.14, 0), base + Vector2(T * 0.14, 0), base + Vector2(T * 0.3, T * 0.1)]), trunk)
	var top := Vector2(base.x, base.y - T * 1.25)
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-T * 0.14, 0), top + Vector2(-T * 0.08, 0), top + Vector2(T * 0.08, 0), base + Vector2(T * 0.14, 0)]), trunk)
	ci.draw_line(base + Vector2(-T * 0.06, -2), top + Vector2(-T * 0.03, 0), Color(0.08, 0.05, 0.03, 0.7), 1.2)
	ci.draw_line(base + Vector2(T * 0.09, -2), top + Vector2(T * 0.05, 0), Color(0.5, 0.4, 0.3, 0.35), 1.0)
	var c := Vector2(base.x, base.y - T * 1.6)
	if variant == 1:
		_willow(ci, c, h)
	else:
		_oak(ci, c, h)


# A round canopy: dark underside, mid leaves, lit crown, and a few warm light spots.
static func _oak(ci: CanvasItem, c: Vector2, h: int) -> void:
	var r: float = T * 1.0
	# A thinner, greyer crown with gaps where the light gets through, and grey moss hanging from it.
	var clumps: Array = _clumps(c, r, h, 7, 0.8)
	_canopy_layers(ci, clumps, [Color("111c1d"), Color("1d2e2e"), Color("2f4544"), Color("485c57")])
	_strands(ci, c, r, h, 9, T * 0.8, Color(0.5, 0.56, 0.5, 0.5))
	for i in 2:
		var sp := c + Vector2((frac(h, 130 + i * 6) - 0.5) * r * 1.2, (frac(h, 140 + i * 6) - 0.5) * r * 0.8)
		ci.draw_circle(sp, T * 0.04, Color(0.8, 0.66, 0.4, 0.22))
	# A dead limb or two break out of the crown.
	for i in 2:
		var side := -1.0 if i == 0 else 1.0
		var from := c + Vector2(side * r * 0.5, -r * 0.2 + frac(h, 150 + i * 4) * r * 0.3)
		var to := from + Vector2(side * T * (0.5 + 0.3 * frac(h, 160 + i * 3)), -T * 0.5)
		ci.draw_line(from, to, Color("2a211a"), 2.2)
		ci.draw_line(to, to + Vector2(side * T * 0.2, -T * 0.15), Color("2a211a"), 1.2)


# A weeping willow: a low, wide canopy with long strands hanging almost to the ground.
static func _willow(ci: CanvasItem, c: Vector2, h: int) -> void:
	var r: float = T * 1.12
	var clumps: Array = _clumps(c + Vector2(0, T * 0.12), r, h, 7, 0.55)
	_canopy_layers(ci, clumps, [Color("141f1b"), Color("1f3029"), Color("34463d"), Color("4d5f52")])
	_strands(ci, c + Vector2(0, T * 0.2), r * 0.9, h, 14, T * 1.6, Color(0.55, 0.6, 0.5, 0.5))


# The great tree at the edge of the field. It is hollow and gnarled, with crooked limbs and a crown
# that never thins. It is drawn once per frame on the map, and the crows roost in its top.
static func draw_big_tree(ci: CanvasItem, base: Vector2, h: int) -> void:
	var bark := Color("221915")
	var r: float = T * 1.75
	var crown := base + Vector2(0, -T * 2.4)
	# Roots spread over the ground, one on each side.
	for i in 6:
		var side := -1.0 if i % 2 == 0 else 1.0
		var reach := T * (0.5 + 0.3 * frac(h, 200 + i * 3))
		var end := base + Vector2(side * reach, T * (0.08 + 0.1 * frac(h, 210 + i * 2)))
		ci.draw_line(base + Vector2(side * T * 0.2, -T * 0.08), end, bark, 4.0 - 0.3 * float(i % 3))
	# The trunk tapers up from a wide base, leaning a little, and the hollow sits near the bottom.
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-T * 0.5, T * 0.06), base + Vector2(-T * 0.36, -T * 1.6), base + Vector2(-T * 0.24, -T * 2.3),
		base + Vector2(T * 0.22, -T * 2.3), base + Vector2(T * 0.36, -T * 1.6), base + Vector2(T * 0.48, T * 0.06)]), bark)
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(T * 0.08, -T * 0.1), base + Vector2(T * 0.36, -T * 1.6), base + Vector2(T * 0.22, -T * 2.3), base + Vector2(T * 0.02, -T * 2.3)]), Color("33261e"))
	ci.draw_colored_polygon(ellipse(base + Vector2(-T * 0.06, -T * 0.85), T * 0.2, T * 0.26), Color("0b0705"))
	ci.draw_arc(base + Vector2(-T * 0.06, -T * 0.85), T * 0.2, 0.0, TAU, 14, Color("4a3a2c"), 1.2)
	# Crooked limbs reach out from the top of the trunk, and each one ends in a bare twig.
	for i in 6:
		var side := -1.0 if i % 2 == 0 else 1.0
		var s := base + Vector2(side * T * 0.14, -T * (1.9 + 0.12 * float(i % 3)))
		var m := s + Vector2(side * T * (0.7 + 0.3 * frac(h, 210 + i * 4)), -T * (0.55 + 0.2 * frac(h, 220 + i * 3)))
		var tip := m + Vector2(side * T * (0.5 + 0.3 * frac(h, 230 + i * 5)), -T * (0.35 + 0.3 * frac(h, 240 + i * 3)))
		ci.draw_line(s, m, bark, 5.0)
		ci.draw_line(m, tip, bark, 2.4)
		ci.draw_line(tip, tip + Vector2(side * T * 0.18, -T * 0.12), bark, 1.2)
	# A dark, dense crown with grey moss hanging from it.
	var clumps: Array = _clumps(crown, r, h, 11, 0.75)
	_canopy_layers(ci, clumps, [Color("0a1212"), Color("15211f"), Color("213330"), Color("344541")])
	_strands(ci, crown + Vector2(0, T * 0.2), r * 1.1, h, 18, T * 1.5, Color(0.5, 0.56, 0.5, 0.55))
	# Pale leaves that never fell, scattered on the ground under the crown.
	for i in 6:
		var lp := base + Vector2((frac(h, 250 + i * 4) - 0.5) * T * 3.2, T * (0.02 + 0.2 * frac(h, 260 + i * 3)))
		ci.draw_colored_polygon(ellipse(lp, T * 0.1, T * 0.05), Color(0.62, 0.52, 0.3, 0.6))


# A bare tree with a few branches and a handful of pale leaves that have not fallen.
static func _dead_tree(ci: CanvasItem, base: Vector2, h: int) -> void:
	var trunk := Color("2e241c")
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-T * 0.22, T * 0.08), base + Vector2(-T * 0.12, 0), base + Vector2(T * 0.12, 0), base + Vector2(T * 0.22, T * 0.08)]), trunk)
	var top := Vector2(base.x, base.y - T * 2.0)
	ci.draw_line(base, top, trunk, T * 0.2)
	var limbs := [Vector2(-0.8, -0.9), Vector2(0.9, -0.7), Vector2(-0.5, -0.35), Vector2(0.55, -0.4)]
	for i in limbs.size():
		var lim: Vector2 = limbs[i]
		var p0 := base + Vector2(0, -T * (0.9 + 0.3 * float(i)))
		var p1 := p0 + lim * T * 0.9
		ci.draw_line(p0, p1, trunk, 3.0)
		ci.draw_line(p1, p1 + Vector2(lim.x * 0.4, -0.3) * T * 0.4, trunk, 1.6)
	for i in 6:
		var lp := base + Vector2((frac(h, 150 + i * 4) - 0.5) * T * 2.0, -T * (1.9 + frac(h, 170 + i * 3) * 0.6))
		ci.draw_colored_polygon(ellipse(lp, T * 0.08, T * 0.05), Color(0.7, 0.62, 0.38, 0.5))


static func _clumps(c: Vector2, r: float, h: int, count: int, squash: float) -> Array:
	var out: Array = []
	for i in count:
		var a: float = TAU * float(i) / float(count) + frac(h, i * 3) * 0.6
		var d: float = r * (0.3 + 0.36 * frac(h, 30 + i * 5))
		var cc: Vector2 = c + Vector2(cos(a), sin(a) * squash) * d
		var rr: float = r * (0.4 + 0.14 * frac(h, 50 + i * 4))
		out.append(Vector3(cc.x, cc.y, rr))
	return out


# Paints the canopy in four passes: shadow underneath, then mid tones, then lit tops, then highlights.
static func _canopy_layers(ci: CanvasItem, clumps: Array, palette: Array) -> void:
	for pass_index in 4:
		var col: Color = palette[pass_index]
		for v in clumps:
			var cl: Vector3 = v
			var cc := Vector2(cl.x, cl.y)
			var rr: float = cl.z
			match pass_index:
				0:
					ci.draw_colored_polygon(blob(cc + Vector2(0, rr * 0.2), rr, rr * 0.9, int(cl.x * 7.0), 10), col)
				1:
					ci.draw_colored_polygon(blob(cc - Vector2(0, rr * 0.12), rr * 0.86, rr * 0.8, int(cl.y * 5.0), 10), col)
				2:
					ci.draw_colored_polygon(blob(cc - Vector2(rr * 0.3, rr * 0.34), rr * 0.5, rr * 0.42, int(cl.x * 3.0), 8), col)
				_:
					ci.draw_circle(cc - Vector2(rr * 0.4, rr * 0.45), rr * 0.16, col)


# Strands of moss or willow hanging from the canopy. Each one sways a little.
static func _strands(ci: CanvasItem, c: Vector2, r: float, h: int, count: int, length: float, col: Color) -> void:
	for i in count:
		var x: float = c.x + (frac(h, 90 + i * 4) - 0.5) * r * 1.7
		var y0: float = c.y + r * 0.2 + frac(h, 100 + i * 3) * r * 0.35
		var l: float = length * (0.6 + 0.5 * frac(h, 110 + i * 5))
		var sway: float = (frac(h, 120 + i * 7) - 0.5) * 6.0
		var prev := Vector2(x, y0)
		for s in 4:
			var t: float = float(s + 1) / 4.0
			var p := Vector2(x + sway * t, y0 + l * t)
			ci.draw_line(prev, p, col, 1.2)
			prev = p


# --- Buildings ------------------------------------------------------------------

# The farmhouse. A sloped roof sits over the top of the house with a ridge, a back slope,
# and hips at each end, and the walls, windows, and door are drawn below it. The stage sets how worn it is.
static func draw_house(ci: CanvasItem, rect: Rect2, stage: int, walls: Color, roof: Color) -> void:
	var l: float = rect.position.x
	var r: float = rect.end.x
	var top: float = rect.position.y
	var bot: float = rect.end.y
	var roof_bot: float = top + T * 2.3
	var ridge: float = top - T * 0.2
	# The chimney stands behind the roof, so the roof overlaps its foot.
	_chimney(ci, rect, stage)
	# Walls.
	ci.draw_rect(Rect2(l, roof_bot - 4, rect.size.x, bot - roof_bot + 4), walls)
	var y: float = roof_bot + 8.0
	while y < bot - 6.0:
		ci.draw_line(Vector2(l, y), Vector2(r, y), Color(0, 0, 0, 0.16 if stage < 3 else 0.09), 1.0)
		y += 9.0
	# Shadow the eave casts on the wall.
	ci.draw_rect(Rect2(l, roof_bot - 2, rect.size.x, 9.0), Color(0, 0, 0, 0.3))
	if stage >= 2:
		var trim := Color("e8dcc0") if stage == 3 else Color("c9b48c")
		ci.draw_rect(Rect2(l, roof_bot, 7, bot - roof_bot), trim)
		ci.draw_rect(Rect2(r - 7, roof_bot, 7, bot - roof_bot), trim)
	ci.draw_rect(Rect2(l, bot - 7, rect.size.x, 7), Color("3a2e26"))
	# Windows and door.
	for w in window_rects(rect):
		_window(ci, w, stage)
	_door(ci, Rect2(l + 2.0 * T, bot - 1.5 * T, T, 1.5 * T), stage)
	# Roof: back slope above the ridge, the front slope, and hips at each end.
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(l + T * 0.45, ridge - T * 0.32), Vector2(r - T * 0.45, ridge - T * 0.32),
		Vector2(r - T * 0.45, ridge), Vector2(l + T * 0.45, ridge)]), roof.darkened(0.35))
	var front := PackedVector2Array([
		Vector2(l - T * 0.22, roof_bot), Vector2(l + T * 0.45, ridge),
		Vector2(r - T * 0.45, ridge), Vector2(r + T * 0.22, roof_bot)])
	ci.draw_colored_polygon(front, roof)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(l - T * 0.22, roof_bot), Vector2(l + T * 0.45, ridge), Vector2(l + T * 0.45, roof_bot)]), roof.darkened(0.25))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(r + T * 0.22, roof_bot), Vector2(r - T * 0.45, ridge), Vector2(r - T * 0.45, roof_bot)]), roof.darkened(0.4))
	# Shingle courses across the front, staggered so the joints don't line up.
	var course := 0
	var sy: float = ridge + 7.0
	while sy < roof_bot - 3.0:
		ci.draw_line(Vector2(l - 2, sy), Vector2(r + 2, sy), roof.darkened(0.3), 1.6)
		var sx: float = l + (0.0 if course % 2 == 0 else 14.0)
		while sx < r:
			ci.draw_line(Vector2(sx, sy), Vector2(sx, sy + 7.0), roof.darkened(0.3), 1.0)
			sx += 28.0
		sy += 9.0
		course += 1
	# Ridge cap, and a dark eave line where the roof meets the wall.
	ci.draw_line(Vector2(l + T * 0.45, ridge), Vector2(r - T * 0.45, ridge), Color("1a120c"), 2.5)
	ci.draw_line(Vector2(l - T * 0.22, roof_bot), Vector2(r + T * 0.22, roof_bot), Color("1a120c", 0.85), 2.5)
	if stage == 0:
		# A missing patch of roof and a sagging edge show how far the house has fallen.
		ci.draw_rect(Rect2(r - T * 2.1, ridge + T * 0.25, T * 1.3, T * 0.9), Color("0d0a08"))
		ci.draw_line(Vector2(l, roof_bot), Vector2(l + rect.size.x * 0.5, roof_bot + 5.0), Color("1a140f"), 3.0)
		ci.draw_line(Vector2(l + rect.size.x * 0.5, roof_bot + 5.0), Vector2(r, roof_bot), Color("1a140f"), 3.0)
	if stage == 3:
		# A ridge ornament and warm light along the eave.
		ci.draw_circle(Vector2(l + rect.size.x * 0.5, ridge - T * 0.3), 3.0, Color("d9b040"))


static func _chimney(ci: CanvasItem, rect: Rect2, stage: int) -> void:
	var cx: float = rect.end.x - T * 1.3
	var top: float = rect.position.y - T * (0.95 if stage >= 2 else 0.7)
	var brick := Color("5a3f33") if stage < 2 else Color("7a4a38")
	ci.draw_rect(Rect2(cx, top, T * 0.5, rect.position.y + T * 0.2 - top), brick)
	for row in range(1, 4):
		var by: float = top + float(row) * (T * 0.2)
		ci.draw_line(Vector2(cx, by), Vector2(cx + T * 0.5, by), Color(0, 0, 0, 0.3), 1.0)
	ci.draw_rect(Rect2(cx - 3, top, T * 0.5 + 6, 5), Color("2a221c"))
	if stage == 3:
		for i in 3:
			ci.draw_circle(Vector2(cx + T * 0.25 + float(i) * 4.0, top - 10.0 - float(i) * 9.0), 4.0 + float(i), Color(0.8, 0.8, 0.8, 0.12))


# The two windows, one each side of the door, in the wall below the roof.
static func window_rects(rect: Rect2) -> Array:
	var out: Array = []
	var wy: float = rect.position.y + T * 2.65
	for wx in [0.14, 0.72]:
		out.append(Rect2(rect.position.x + rect.size.x * float(wx), wy, T * 1.1, T * 1.05))
	return out


static func _window(ci: CanvasItem, w: Rect2, stage: int) -> void:
	var trim := Color("e8dcc0") if stage >= 2 else Color("3a2a1c")
	ci.draw_rect(w.grow(3), trim)
	if stage >= 2:
		ci.draw_rect(w, Color("9bb7c4"))
		if stage == 3:
			ci.draw_rect(w, Color(1.0, 0.8, 0.4, 0.22))
		# Curtains at each side, then the mullions and a sill.
		ci.draw_rect(Rect2(w.position.x, w.position.y, w.size.x * 0.2, w.size.y), Color("a0445a"))
		ci.draw_rect(Rect2(w.end.x - w.size.x * 0.2, w.position.y, w.size.x * 0.2, w.size.y), Color("a0445a"))
		var mid := w.position + w.size * 0.5
		ci.draw_line(Vector2(mid.x, w.position.y), Vector2(mid.x, w.end.y), trim, 2.5)
		ci.draw_line(Vector2(w.position.x, mid.y), Vector2(w.end.x, mid.y), trim, 2.5)
		ci.draw_rect(Rect2(w.position.x - 4, w.end.y + 3, w.size.x + 8, 5), trim)
		if stage == 3:
			var shutter := Color("3f6b4a")
			ci.draw_rect(Rect2(w.position.x - 9, w.position.y, 6, w.size.y), shutter)
			ci.draw_rect(Rect2(w.end.x + 3, w.position.y, 6, w.size.y), shutter)
			var box := Rect2(w.position.x, w.end.y + 9, w.size.x, 6)
			ci.draw_rect(box, Color("5a3a24"))
			for i in 4:
				var fc := Color("d96b8a") if i % 2 == 0 else Color("e8c24a")
				ci.draw_circle(Vector2(box.position.x + 6 + float(i) * 11.0, box.position.y - 1.0), 2.5, fc)
	else:
		ci.draw_rect(w, Color("1d1712"))
		var boards := 2 if stage == 0 else 1
		for i in boards:
			var by: float = w.position.y + w.size.y * (0.4 + 0.3 * float(i))
			ci.draw_rect(Rect2(w.position.x, by, w.size.x, 4), Color("3a2a1c"))
			ci.draw_line(Vector2(w.position.x, by + 1.5), Vector2(w.end.x, by + 1.5), Color(0.5, 0.4, 0.3, 0.3), 1.0)


static func _door(ci: CanvasItem, d: Rect2, stage: int) -> void:
	ci.draw_rect(d.grow(3), Color("e8dcc0") if stage >= 2 else Color("2a1f16"))
	ci.draw_rect(d, Color("24180f") if stage < 2 else Color("5c3a24"))
	if stage < 2:
		for i in [1, 2]:
			var x: float = d.position.x + d.size.x * float(i) / 3.0
			ci.draw_line(Vector2(x, d.position.y), Vector2(x, d.end.y), Color("150e09"), 2.0)
	else:
		# Four raised panels.
		var pw: float = d.size.x * 0.36
		var ph: float = d.size.y * 0.28
		for py in [0.12, 0.56]:
			for px in [0.14, 0.5]:
				var pr := Rect2(d.position.x + d.size.x * px, d.position.y + d.size.y * py, pw, ph)
				ci.draw_rect(pr, Color("6e4a2e"), false, 1.6)
		ci.draw_circle(d.position + Vector2(d.size.x * 0.8, d.size.y * 0.55), 2.5, Color("d9b040"))
	if stage == 3:
		var lamp := Vector2(d.end.x + 8, d.position.y + 6)
		ci.draw_circle(lamp, 9, Color(1.0, 0.8, 0.4, 0.18))
		ci.draw_circle(lamp, 3.5, Color("ffd27a"))
	# The doorstep sits just below the door.
	ci.draw_rect(Rect2(d.position.x - 4, d.end.y, d.size.x + 8, 4), Color("5a4a3a"))


# A porch tile. The top row is under the porch roof; the bottom row is open decking with posts at the corners.
static func draw_porch_tile(ci: CanvasItem, cell: Rect2, local: Vector2i, size: Vector2i, stage: int) -> void:
	var board := Color("8a6a46") if local.x % 2 == 0 else Color("7d5f3e")
	ci.draw_rect(cell, board)
	for i in range(1, 4):
		var by: float = cell.position.y + cell.size.y * float(i) / 4.0
		ci.draw_line(Vector2(cell.position.x, by), Vector2(cell.end.x, by), Color(0.12, 0.08, 0.05, 0.5), 1.0)
	var jx: float = cell.position.x + (cell.size.x * 0.5 if (local.x + local.y) % 2 == 0 else cell.size.x * 0.25)
	ci.draw_line(Vector2(jx, cell.position.y), Vector2(jx, cell.position.y + cell.size.y * 0.25), Color(0.12, 0.08, 0.05, 0.5), 1.0)
	if local.y == 0:
		# The porch roof: a band pitched down from the house, with shingle ticks and a dark eave.
		var band := Rect2(cell.position, Vector2(cell.size.x, cell.size.y * 0.5))
		ci.draw_rect(band, Color("4a3a2c") if stage < 3 else Color("5c4632"))
		var sx: float = cell.position.x + (0.0 if local.x % 2 == 0 else 12.0)
		while sx < cell.end.x:
			ci.draw_line(Vector2(sx, band.position.y), Vector2(sx, band.end.y), Color(0, 0, 0, 0.25), 1.0)
			sx += 24.0
		ci.draw_line(Vector2(cell.position.x, band.end.y), Vector2(cell.end.x, band.end.y), Color(0, 0, 0, 0.45), 2.5)
	if local.x == 0 or local.x == size.x - 1:
		# Posts at the outer corners, and a rail along each outer column.
		var px: float = cell.position.x + (3.0 if local.x == 0 else cell.size.x - 7.0)
		ci.draw_rect(Rect2(px, cell.position.y + 2.0, 5.0, cell.size.y - 2.0), Color("5a3f28"))
		if local.y == size.y - 1:
			ci.draw_rect(Rect2(cell.position.x, cell.end.y - 6.0, cell.size.x, 3.0), Color("6a4c31"))


# A market stall on the road: a striped awning, a counter, and crates of produce.
static func draw_stall(ci: CanvasItem, cell: Rect2) -> void:
	ci.draw_rect(cell, Color("6b4a2e"))
	ci.draw_rect(Rect2(cell.position.x + 4, cell.position.y + cell.size.y * 0.55, cell.size.x - 8, cell.size.y * 0.35), Color("8a6038"))
	var awn_top: float = cell.position.y - 10.0
	var awn_bot: float = cell.position.y + cell.size.y * 0.5
	for i in 6:
		var x0: float = cell.position.x - 4.0 + float(i) * (cell.size.x + 8.0) / 6.0
		var x1: float = x0 + (cell.size.x + 8.0) / 6.0
		var col := Color("b84a3a") if i % 2 == 0 else Color("e8dcc0")
		ci.draw_colored_polygon(PackedVector2Array([Vector2(x0, awn_top), Vector2(x1, awn_top), Vector2(x1, awn_bot), Vector2(x0, awn_bot)]), col)
	for i in 6:
		var x0: float = cell.position.x - 4.0 + float(i) * (cell.size.x + 8.0) / 6.0
		var x1: float = x0 + (cell.size.x + 8.0) / 6.0
		var col := Color("b84a3a") if i % 2 == 0 else Color("e8dcc0")
		ci.draw_colored_polygon(PackedVector2Array([Vector2(x0, awn_bot), Vector2((x0 + x1) * 0.5, awn_bot + 6.0), Vector2(x1, awn_bot)]), col)
	ci.draw_line(Vector2(cell.position.x - 4, awn_top), Vector2(cell.end.x + 4, awn_top), Color("3a2a1c"), 2.0)
	for i in 3:
		var pc := Vector2(cell.position.x + cell.size.x * (0.25 + 0.25 * float(i)), cell.position.y + cell.size.y * 0.72)
		ci.draw_circle(pc, 4.0, Color("e0822a") if i != 1 else Color("9fd27a"))


# A cellar: an earth mound with a planked hatch and a stone rim.
static func draw_cellar(ci: CanvasItem, cell: Rect2) -> void:
	ci.draw_rect(cell, Color("3f3a33"))
	var c := cell.get_center()
	ci.draw_colored_polygon(ellipse(c + Vector2(0, 3), T * 0.44, T * 0.34), Color("5a4b3c"))
	ci.draw_colored_polygon(ellipse(c + Vector2(-4, -2), T * 0.3, T * 0.22), Color("6e5d4a"))
	var hatch := Rect2(cell.position + Vector2(T * 0.22, T * 0.3), Vector2(T * 0.56, T * 0.4))
	ci.draw_rect(hatch.grow(2), Color("2a2118"))
	ci.draw_rect(hatch, Color("6b5a48"))
	for i in range(1, 4):
		var x: float = hatch.position.x + hatch.size.x * float(i) / 4.0
		ci.draw_line(Vector2(x, hatch.position.y), Vector2(x, hatch.end.y), Color("4a3524"), 2.0)
	ci.draw_arc(c + Vector2(0, 2), 4.0, 0.0, TAU, 12, Color("c9c2b0"), 2.0)


# A smokehouse: a small brick hut with a vented roof, and hams hung up to smoke.
static func draw_smokehouse(ci: CanvasItem, cell: Rect2) -> void:
	ci.draw_rect(cell, Color("7a4530"))
	for row in range(1, 4):
		var by: float = cell.position.y + cell.size.y * float(row) / 4.0
		ci.draw_line(Vector2(cell.position.x, by), Vector2(cell.end.x, by), Color(0.2, 0.1, 0.06, 0.6), 1.0)
	ci.draw_colored_polygon(PackedVector2Array([
		cell.position + Vector2(-2, cell.size.y * 0.4), cell.position + Vector2(cell.size.x * 0.5, 0.0),
		cell.position + Vector2(cell.size.x + 2, cell.size.y * 0.4)]), Color("3a2a22"))
	ci.draw_rect(Rect2(cell.position.x + cell.size.x * 0.62, cell.position.y + 4, cell.size.x * 0.18, cell.size.y * 0.2), Color("2a1a14"))
	for i in 3:
		var hx: float = cell.position.x + cell.size.x * (0.22 + 0.28 * float(i))
		ci.draw_line(Vector2(hx, cell.position.y + cell.size.y * 0.44), Vector2(hx, cell.position.y + cell.size.y * 0.52), Color("2a1a14"), 1.0)
		ci.draw_colored_polygon(ellipse(Vector2(hx, cell.position.y + cell.size.y * 0.6), 4.0, 6.0), Color("b5604a"))
	ci.draw_rect(Rect2(cell.position.x + cell.size.x * 0.4, cell.end.y - cell.size.y * 0.3, cell.size.x * 0.2, cell.size.y * 0.3), Color("2a1a14"))


# A furnace: stone blocks, a glowing firebox mouth, and a sooty stack.
static func draw_furnace(ci: CanvasItem, cell: Rect2) -> void:
	ci.draw_rect(cell, Color("5c5c66"))
	for row in range(1, 4):
		var by: float = cell.position.y + cell.size.y * float(row) / 4.0
		ci.draw_line(Vector2(cell.position.x, by), Vector2(cell.end.x, by), Color(0.1, 0.1, 0.12, 0.6), 1.0)
	ci.draw_rect(Rect2(cell.position.x + cell.size.x * 0.4, cell.position.y + 2, cell.size.x * 0.2, cell.size.y * 0.2), Color("2a2a30"))
	var mouth := Rect2(cell.position.x + cell.size.x * 0.22, cell.position.y + cell.size.y * 0.45, cell.size.x * 0.56, cell.size.y * 0.35)
	ci.draw_rect(mouth, Color("2a0f05"))
	ci.draw_rect(mouth.grow(-3), Color("e0601e"))
	ci.draw_rect(mouth.grow(-7), Color("ffd060"))
	ci.draw_rect(Rect2(cell.position.x, cell.position.y, cell.size.x, 3), Color("7a7a86"))


# The well: a ring of stones round dark water, with two posts, a little roof, and the crank.
static func draw_well(ci: CanvasItem, cell: Rect2, repaired: bool) -> void:
	var c := cell.get_center() + Vector2(0, 4)
	var r: float = cell.size.x * 0.36
	ci.draw_colored_polygon(ellipse(c + Vector2(4, 6), r * 1.1, r * 0.6), Color(0, 0, 0, 0.26))
	for i in 12:
		var a: float = TAU * float(i) / 12.0
		var sc := c + Vector2(cos(a), sin(a) * 0.85) * r
		ci.draw_colored_polygon(ellipse(sc, r * 0.22, r * 0.17), Color("6e6a64") if i % 2 == 0 else Color("5a5650"))
	ci.draw_colored_polygon(ellipse(c, r * 0.8, r * 0.68), Color("2a3440") if repaired else Color("3d3a36"))
	if repaired:
		ci.draw_colored_polygon(ellipse(c + Vector2(-r * 0.2, -r * 0.16), r * 0.4, r * 0.22), Color("5a7d9a"))
	var post_l := Vector2(c.x - r * 0.95, c.y - r * 1.3)
	var post_r := Vector2(c.x + r * 0.95, c.y - r * 1.3)
	ci.draw_rect(Rect2(post_l.x - 2, post_l.y, 5, r * 1.3), Color("5e4128"))
	ci.draw_rect(Rect2(post_r.x - 2, post_r.y, 5, r * 1.3), Color("5e4128"))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - r * 1.3, c.y - r * 1.3), Vector2(c.x, c.y - r * 2.1), Vector2(c.x + r * 1.3, c.y - r * 1.3)]), Color("5a3a24"))
	ci.draw_line(Vector2(c.x - r * 1.3, c.y - r * 1.3), Vector2(c.x + r * 1.3, c.y - r * 1.3), Color("2a1a10"), 2.0)
	ci.draw_line(Vector2(c.x - r * 0.8, c.y - r * 1.1), Vector2(c.x + r * 0.8, c.y - r * 1.1), Color("7a5a36"), 3.0)
	ci.draw_circle(Vector2(c.x, c.y - r * 1.1), 3.0, Color("3a2a1c"))


# A barn or coop tile. The footprint's north half is roof; its south half shows the roof over a front wall.
static func draw_gable_tile(ci: CanvasItem, cell: Rect2, local: Vector2i, size: Vector2i, roof: Color, walls: Color, kind: String) -> void:
	var north: bool = local.y < size.y / 2
	var roof_h: float = cell.size.y if north else cell.size.y * 0.55
	var roof_rect := Rect2(cell.position, Vector2(cell.size.x, roof_h))
	var col := roof.lightened(0.07) if north else roof
	ci.draw_rect(roof_rect, col)
	# Shingles line up on the world grid, so the courses carry across the tile edges.
	var course_y: float = floor(cell.position.y / 8.0) * 8.0
	var idx: int = 0
	while course_y < roof_rect.end.y:
		if course_y >= roof_rect.position.y:
			ci.draw_line(Vector2(cell.position.x, course_y), Vector2(cell.end.x, course_y), col.darkened(0.32), 1.2)
			var sx: float = floor(cell.position.x / 12.0) * 12.0 + (6.0 if idx % 2 == 0 else 0.0)
			while sx < cell.end.x:
				if sx >= cell.position.x:
					ci.draw_line(Vector2(sx, course_y), Vector2(sx, course_y + 6.0), col.darkened(0.32), 1.0)
				sx += 12.0
		course_y += 8.0
		idx += 1
	if local.y == size.y / 2 - 1 or (north and size.y == 1):
		# The ridge runs along the bottom of the north half, with a dark cap.
		ci.draw_line(Vector2(cell.position.x, roof_rect.end.y - 1), Vector2(cell.end.x, roof_rect.end.y - 1), Color("1a120c"), 2.5)
	if local.y == 0:
		ci.draw_line(Vector2(cell.position.x, cell.position.y + 1), Vector2(cell.end.x, cell.position.y + 1), Color(0, 0, 0, 0.4), 2.0)
	if not north:
		var wall := Rect2(cell.position.x, cell.position.y + cell.size.y * 0.55, cell.size.x, cell.size.y * 0.45)
		ci.draw_rect(wall, walls)
		for i in range(1, 3):
			var wy: float = wall.position.y + wall.size.y * float(i) / 3.0
			ci.draw_line(Vector2(wall.position.x, wy), Vector2(wall.end.x, wy), Color(0, 0, 0, 0.25), 1.0)
		ci.draw_line(Vector2(cell.position.x, wall.position.y), Vector2(cell.end.x, wall.position.y), Color("1a120c"), 2.0)
		var front_row: int = size.y - 1
		if kind == "coop":
			if local == Vector2i(0, front_row):
				_coop_door(ci, wall)
			elif local == Vector2i(1, front_row):
				_coop_nest(ci, wall)
		elif kind == "barn":
			if local == Vector2i(1, front_row):
				_barn_door(ci, wall)
			elif local == Vector2i(0, front_row):
				_barn_window(ci, wall)
			elif local == Vector2i(2, front_row):
				_hay_bales(ci, wall)


static func _coop_door(ci: CanvasItem, wall: Rect2) -> void:
	var d := Rect2(wall.position.x + wall.size.x * 0.25, wall.position.y + wall.size.y * 0.1, wall.size.x * 0.5, wall.size.y * 0.9)
	ci.draw_rect(d, Color("3a2214"))
	ci.draw_line(Vector2(d.position.x, d.position.y + d.size.y * 0.5), Vector2(d.end.x, d.position.y + d.size.y * 0.5), Color("5a3a24"), 1.5)
	ci.draw_circle(Vector2(d.end.x - 3.0, d.position.y + d.size.y * 0.6), 1.2, Color("d9b040"))


static func _coop_nest(ci: CanvasItem, wall: Rect2) -> void:
	ci.draw_rect(Rect2(wall.position.x + wall.size.x * 0.15, wall.position.y + wall.size.y * 0.35, wall.size.x * 0.7, wall.size.y * 0.55), Color("3a2a1a"))
	for i in 5:
		var sx: float = wall.position.x + wall.size.x * (0.22 + 0.14 * float(i))
		ci.draw_line(Vector2(sx, wall.position.y + wall.size.y * 0.7), Vector2(sx + 3.0, wall.position.y + wall.size.y * 0.85), Color("e0b850"), 1.6)


static func _barn_door(ci: CanvasItem, wall: Rect2) -> void:
	var d := Rect2(wall.position.x + wall.size.x * 0.12, wall.position.y + wall.size.y * 0.08, wall.size.x * 0.76, wall.size.y * 0.92)
	ci.draw_rect(d, Color("5c2219"))
	ci.draw_rect(d, Color("e8dcc0"), false, 1.5)
	ci.draw_line(d.position, d.end, Color("e8dcc0"), 1.5)
	ci.draw_line(Vector2(d.end.x, d.position.y), Vector2(d.position.x, d.end.y), Color("e8dcc0"), 1.5)


static func _barn_window(ci: CanvasItem, wall: Rect2) -> void:
	var w := Rect2(wall.position.x + wall.size.x * 0.3, wall.position.y + wall.size.y * 0.25, wall.size.x * 0.4, wall.size.y * 0.45)
	ci.draw_rect(w.grow(1.5), Color("e8dcc0"))
	ci.draw_rect(w, Color("1d1712"))


static func _hay_bales(ci: CanvasItem, wall: Rect2) -> void:
	for i in 2:
		var b := Rect2(wall.position.x + 2.0 + float(i) * (wall.size.x * 0.46), wall.position.y + wall.size.y * 0.2, wall.size.x * 0.42, wall.size.y * 0.7)
		ci.draw_rect(b, Color("d8b050"))
		ci.draw_line(Vector2(b.position.x, b.position.y + b.size.y * 0.5), Vector2(b.end.x, b.position.y + b.size.y * 0.5), Color("9a7a30"), 1.2)


# A workshop wall tile. The top row of the workshop is its roof; the rest are planked timber walls.
static func draw_wall_tile(ci: CanvasItem, cell: Rect2, roof: bool) -> void:
	if roof:
		ci.draw_rect(cell, Color("4f3622"))
		for i in 4:
			var sx: float = cell.position.x + float(i) * cell.size.x / 4.0
			ci.draw_line(Vector2(sx, cell.position.y), Vector2(sx + 6, cell.end.y), Color(0, 0, 0, 0.2), 1.0)
		ci.draw_line(Vector2(cell.position.x, cell.end.y - 2), Vector2(cell.end.x, cell.end.y - 2), Color(0.1, 0.07, 0.05, 0.7), 2.0)
		return
	ci.draw_rect(cell, Color("6b4c33"))
	for i in range(1, 4):
		var y: float = cell.position.y + cell.size.y * float(i) / 4.0
		ci.draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0.16, 0.11, 0.07, 0.55), 1.0)
	ci.draw_line(Vector2(cell.position.x + cell.size.x * 0.5, cell.position.y), Vector2(cell.position.x + cell.size.x * 0.5, cell.end.y), Color(0.16, 0.11, 0.07, 0.3), 1.0)


# --- Water ----------------------------------------------------------------------

# A pond tile: deep water, a light and dark band, a ripple, and a pale shoreline on each side that touches land.
# land is a bit mask: 1 north, 2 east, 4 south, 8 west.
static func draw_water_tile(ci: CanvasItem, cell: Rect2, t: Vector2i, land: int) -> void:
	var h: int = hash_int(t.x, t.y, 5)
	ci.draw_rect(cell, Color("2c5a85").lightened(0.03 * (frac(h, 0) - 0.5)))
	ci.draw_rect(Rect2(cell.position.x, cell.position.y + cell.size.y * 0.5, cell.size.x, cell.size.y * 0.5), Color(0.08, 0.22, 0.38, 0.28))
	var rp := Vector2(cell.position.x + cell.size.x * (0.2 + 0.5 * frac(h, 4)), cell.position.y + cell.size.y * (0.2 + 0.5 * frac(h, 9)))
	ci.draw_line(rp, rp + Vector2(8, 0), Color(0.7, 0.85, 1.0, 0.22), 1.2)
	var shore := Color(0.8, 0.84, 0.72, 0.6)
	if land & 1:
		ci.draw_line(Vector2(cell.position.x, cell.position.y + 1.5), Vector2(cell.end.x, cell.position.y + 1.5), shore, 3.0)
	if land & 2:
		ci.draw_line(Vector2(cell.end.x - 1.5, cell.position.y), Vector2(cell.end.x - 1.5, cell.end.y), shore, 3.0)
	if land & 4:
		ci.draw_line(Vector2(cell.position.x, cell.end.y - 1.5), Vector2(cell.end.x, cell.end.y - 1.5), shore, 3.0)
	if land & 8:
		ci.draw_line(Vector2(cell.position.x + 1.5, cell.position.y), Vector2(cell.position.x + 1.5, cell.end.y), shore, 3.0)
	# A few reeds on the shore.
	if land != 0 and frac(h, 13) > 0.6:
		var base := cell.position + Vector2(cell.size.x * (0.2 + 0.6 * frac(h, 17)), cell.size.y * 0.5)
		ci.draw_line(base, base + Vector2(-2, -12), Color("5a7a3a"), 1.4)
		ci.draw_line(base + Vector2(2, 0), base + Vector2(3, -10), Color("6a8a46"), 1.2)


# The pond's shine. Drawn every frame on its own layer: a sun glint on clear days, a moon's
# silver column at night, and rain rings when it rains. focus is the pond's centre, in tiles.
static func draw_water_shimmer(ci: CanvasItem, tiles: Array, time: float, sky: int, rain: bool, focus: Vector2) -> void:
	var sun_pos := Vector2((focus.x + sin(time * 0.2) * 0.5 - 1.3) * T, (focus.y - 0.9 + cos(time * 0.3) * 0.2) * T)
	var moon_x: float = (focus.x + sin(time * 0.15) * 0.25) * T
	for v in tiles:
		var t: Vector2i = v
		var p := Vector2((t.x + 0.5) * T, (t.y + 0.5) * T)
		var h: int = hash_int(t.x, t.y, 7)
		var phase: float = frac(h, 0) * TAU
		# Tiny sparkles that come and go.
		var pulse: float = pow(maxf(0.0, sin(time * 1.6 + phase)), 8.0)
		if pulse > 0.1:
			var sp := p + Vector2(frac(h, 8) - 0.5, frac(h, 16) - 0.5) * T * 0.6
			ci.draw_line(sp + Vector2(-4, 0), sp + Vector2(4, 0), Color(1, 1, 1, 0.55 * pulse), 1.2)
		if sky == 1:
			# The sun's glint spreads across the water near where it touches it.
			var d: float = p.distance_to(sun_pos)
			var k: float = exp(-d * d / (2.0 * (T * 1.3) * (T * 1.3)))
			if k > 0.03:
				var a: float = 0.5 * k * (0.7 + 0.3 * sin(time * 3.0 + phase))
				ci.draw_colored_polygon(ellipse(p, T * 0.22, T * 0.07), Color(1.0, 0.97, 0.82, a))
		elif sky == 2:
			# The moon leaves a silver column of light, wavering across the water.
			var dx: float = absf(p.x - moon_x)
			var mk: float = exp(-dx * dx / (2.0 * (T * 0.6) * (T * 0.6)))
			if mk > 0.03:
				var ma: float = 0.6 * mk * (0.6 + 0.4 * sin(time * 2.0 + phase))
				ci.draw_colored_polygon(ellipse(p, T * 0.36, T * 0.1), Color(0.85, 0.9, 1.0, ma))
		if rain and h % 4 == 0:
			# Rain rings spread out on the surface and fade.
			var age: float = fposmod(time * 0.9 + phase, 1.0)
			var rr: float = T * (0.08 + 0.3 * age)
			ci.draw_arc(p + Vector2(frac(h, 3) - 0.5, frac(h, 21) - 0.5) * T * 0.5, rr, 0.0, TAU, 12, Color(0.85, 0.92, 1.0, 0.35 * (1.0 - age)), 1.0)


static func _leaf(ci: CanvasItem, base: Vector2, tip: Vector2, width: float, col: Color) -> void:
	var dir := tip - base
	var side := Vector2(-dir.y, dir.x).normalized() * width
	var mid := base + dir * 0.5
	ci.draw_colored_polygon(PackedVector2Array([base, mid + side, tip, mid - side]), col)
	ci.draw_line(base, tip, col.darkened(0.35), 1.0)


# A crop at one of its four stages. Turnips show leaves that grow into a purple-shouldered bulb.
# Pumpkins show a sprout, then a vine, then a round fruit with ribs and a stem. Watered soil is darker.
static func draw_crop(ci: CanvasItem, c: Vector2, u: float, kind: String, stage: int, watered: bool) -> void:
	var soil := Color("3d2a1c") if watered else Color("5a3d28")
	var base := c + Vector2(0, u * 0.32)
	ci.draw_colored_polygon(ellipse(base, u * 0.38, u * 0.11), soil)
	if kind == "pumpkin":
		_pumpkin(ci, base, u, stage)
	else:
		_turnip(ci, base, u, stage)


static func _turnip(ci: CanvasItem, base: Vector2, u: float, stage: int) -> void:
	var leaf := Color("6fae4a") if stage < 3 else Color("4f9a3a")
	if stage == 0:
		_leaf(ci, base, base + Vector2(-0.13, -0.2) * u, 0.05 * u, leaf)
		_leaf(ci, base, base + Vector2(0.13, -0.2) * u, 0.05 * u, leaf)
		return
	if stage >= 2:
		var bulb := 0.13 if stage == 2 else 0.19
		ci.draw_colored_polygon(ellipse(base + Vector2(0, -0.03) * u, bulb * u, bulb * 0.75 * u), Color("ece6f2"))
		ci.draw_colored_polygon(ellipse(base + Vector2(0, -0.09) * u, bulb * u * 0.9, bulb * 0.35 * u), Color("9a5aa8"))
	var reach := 0.42 if stage == 1 else (0.55 if stage == 2 else 0.68)
	var width := (0.08 + 0.02 * float(stage)) * u
	for a in [-0.45, -0.15, 0.15, 0.45]:
		_leaf(ci, base, base + Vector2(a, -1.0).normalized() * reach * u, width, leaf)


static func _pumpkin(ci: CanvasItem, base: Vector2, u: float, stage: int) -> void:
	var leaf := Color("4f8a34")
	if stage == 0:
		_leaf(ci, base, base + Vector2(-0.14, -0.18) * u, 0.06 * u, Color("7ab850"))
		_leaf(ci, base, base + Vector2(0.14, -0.18) * u, 0.06 * u, Color("7ab850"))
		return
	if stage == 1:
		ci.draw_line(base, base + Vector2(0.2, -0.22) * u, leaf, 1.5)
		ci.draw_colored_polygon(ellipse(base + Vector2(-0.2, -0.2) * u, 0.14 * u, 0.09 * u), leaf)
		ci.draw_colored_polygon(ellipse(base + Vector2(0.28, -0.3) * u, 0.13 * u, 0.08 * u), leaf)
		return
	var r := 0.2 if stage == 2 else 0.28
	var fruit := base + Vector2(0, -r * 0.8) * u
	ci.draw_colored_polygon(ellipse(base + Vector2(-0.26, -0.12) * u, 0.14 * u, 0.09 * u), leaf)
	ci.draw_colored_polygon(ellipse(base + Vector2(0.28, -0.1) * u, 0.14 * u, 0.09 * u), leaf)
	ci.draw_colored_polygon(ellipse(fruit, r * u, r * 0.8 * u), Color("d98a35") if stage == 2 else Color("e0822a"))
	ci.draw_polyline(ellipse(fruit, r * 0.5 * u, r * 0.8 * u), Color("b8601e"), 1.0)
	ci.draw_rect(Rect2(fruit + Vector2(-0.03, -r * 0.8 - 0.1) * u, Vector2(0.06, 0.1) * u), Color("4f6e2a"))
	if stage == 3:
		ci.draw_colored_polygon(ellipse(fruit + Vector2(-r * 0.4, -r * 0.3) * u, 0.05 * u, 0.03 * u), Color("f2a13a"))


# Sparkles and a faint sheen over the watered crops, drawn on the animated overlay.
static func draw_crop_shimmer(ci: CanvasItem, centres: Array, u: float, time: float) -> void:
	for c in centres:
		var p: Vector2 = c
		var ph := fposmod(p.x * 0.37 + p.y * 0.91, TAU)
		var pulse := 0.5 + 0.5 * sin(time * 2.0 + ph)
		ci.draw_colored_polygon(ellipse(p + Vector2(0, u * 0.1), u * 0.46, u * 0.3), Color(0.85, 0.95, 1.0, 0.08 + 0.08 * pulse))
		for k in 3:
			var a := time * 1.4 + ph + float(k) * 2.1
			var sp := p + Vector2(cos(a) * u * 0.32, -u * 0.2 + sin(a * 1.7) * u * 0.18)
			var tw := 0.5 + 0.5 * sin(time * 5.0 + ph + float(k) * 1.3)
			var arm := u * (0.03 + 0.04 * tw)
			var col := Color(1.0, 1.0, 0.9, 0.3 + 0.6 * tw)
			ci.draw_line(sp + Vector2(-arm, 0), sp + Vector2(arm, 0), col, 1.0)
			ci.draw_line(sp + Vector2(0, -arm), sp + Vector2(0, arm), col, 1.0)
