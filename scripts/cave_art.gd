class_name CaveArt
extends RefCounted

# The mining cave in PixelLab art (ART-OVERHAUL-001 Stage C, CAVE_ART_V2 in main.gd). Art only: the cave's
# layout, ore, collision, creatures, mining and saves are main.gd's and are untouched.
#
# - The floor: one stone tile repeated, unturned (its grain runs one way, so turned copies show seams).
# - The walls: PixelLab transition (cliff) tilesets on the dual grid, so walls have a dark top and a rock face on
#   their south side. A vertex sits at each tile centre and counts as rock when its tile is rock AND the tile south
#   of it is rock too, so the face falls inside the wall's own bottom row, not on the floor in front of it (the
#   face's foot reaches 5 art px over the floor's top edge). A floor vertex just south of a rock vertex is the
#   face ("transition"). Each cell takes its tile by pattern_4x4 (centre corners exact, then the ring around them),
#   from one of three sets of the same 25 tiles chosen by position, so long faces don't repeat.
# - A wall one tile thick from north to south has no room for a top, so it gets the straight face alone.
# - Dressing, all placed by position, so a day's cave always looks the same: flat decals on the floor (cracks,
#   grit, chips, small puddles; roots, leaves and pebbles near the way out); moss and roots hung from the tops of faces near
#   the way out, stone drips deeper in; rubble and ferns at the foot of faces; and a few stones and spires standing
#   on the north lip of the rock, drawn over the farmer (the front layer) and reaching at most FRONT_REACH art px
#   onto the floor north of them. Nothing is placed on or beside ore, or by the way out, so mining stays clear.
# - Ore: three cuts each of copper and iron, one per ore tile. The way out: rough mossy steps between rock jambs,
#   over both exit tiles as before (not flipped, so their light still falls from the upper left).
# Everything has binary alpha and no light baked in: CAVE_TINT, the lantern and the faint daylight at the way out
# light it as they lit the old art.

const DIR := "res://art/farm/cave_int/"
const T := 16                    # art px per tile
const NEAR := 5                  # tiles (walking distance) from the way in that count as "near the way out"
const FRONT_REACH := 6           # art px a front-layer piece may reach onto the floor north of its wall
const CENTER := [5, 6, 9, 10]    # pattern_4x4 indices of a cell's own four corners

var ok := false
var walls: Texture2D
var floor_tex: Texture2D
var atlas: Texture2D
var tiles: Array = []            # {p: PackedInt32Array (16), r: [Vector2 per set], key: int}
var by_key := {}                 # centre key -> [tile index]
var face_tile := -1              # the straight face's tile (centre 2,2 over 0,0), for walls one tile thick
var sets := 1
var kinds := {}                  # kind -> [Rect2 in the atlas]

var _sig := 0
var _w := 0
var _h := 0
var _cells: Array = []           # [r+1][c+1] -> Rect2 source in walls.png, or an empty Rect2 for floor only
var _back: Array = []            # [Rect2 src, Vector2 art-px top-left] under the farmer, after the walls
var _decals: Array = []          # the same, on the floor, before the walls
var _front: Array = []           # the same, over the farmer
var _thin: Array = []            # Vector2i tiles of walls one tile thick


func _init() -> void:
	if not ResourceLoader.exists(DIR + "cave_int.json"):
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "cave_int.json"))
	walls = load(DIR + "walls.png")
	floor_tex = load(DIR + "floor.png")
	atlas = load(DIR + "atlas.png")
	sets = int(data["sets"])
	for i in data["tiles"].size():
		var t: Dictionary = data["tiles"][i]
		var p := PackedInt32Array(t["p"])
		var rects: Array = []
		for r in t["r"]:
			rects.append(Vector2(r[0], r[1]))
		var key := _key(p[5], p[6], p[9], p[10])
		tiles.append({"p": p, "r": rects})
		if not by_key.has(key):
			by_key[key] = []
		by_key[key].append(i)
		if p[5] == 2 and p[6] == 2 and p[9] == 0 and p[10] == 0:
			face_tile = i
	for pc in data["pieces"]:
		var kind: String = pc["kind"]
		if not kinds.has(kind):
			kinds[kind] = []
		kinds[kind].append(Rect2(pc["x"], pc["y"], pc["w"], pc["h"]))
	ok = face_tile >= 0


static func _key(a: int, b: int, c: int, d: int) -> int:
	return ((a * 3 + b) * 3 + c) * 3 + d


static func _hash(x: int, y: int, salt: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663) ^ (salt * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))


# 0..1 from a tile and a salt, the same every time.
static func _roll(x: int, y: int, salt: int) -> float:
	return float(_hash(x, y, salt) % 10007) / 10007.0


func _pick(kind: String, x: int, y: int, salt: int) -> Rect2:
	var list: Array = kinds.get(kind, [])
	if list.is_empty():
		return Rect2()
	return list[_hash(x, y, salt) % list.size()]


# --- building the picture for a layout (once per change: a new day's cave, or ore mined) ---

func _rebuild(m) -> void:
	var cave: Array = m.cave
	_h = cave.size()
	_w = cave[0].size()
	var rock := func(x: int, y: int) -> bool:
		if x < 0 or y < 0 or x >= _w or y >= _h:
			return true
		var k: int = cave[y][x]
		return k == m.Tile.WALL or k == m.Tile.ORE_COPPER or k == m.Tile.ORE_IRON
	# Vertices at tile centres: 1 rock (with rock south of it), 2 face, 0 floor. Outside the cave is rock.
	var v: Array = []
	for y in _h:
		var row := PackedInt32Array()
		row.resize(_w)
		for x in _w:
			row[x] = 1 if (rock.call(x, y) and rock.call(x, y + 1)) else 0
		v.append(row)
	for y in range(_h - 1, -1, -1):
		for x in _w:
			if v[y][x] == 0 and (y == 0 or v[y - 1][x] == 1):
				v[y][x] = 2
	var vat := func(r: int, c: int) -> int:
		if r < 0 or c < 0 or r >= _h or c >= _w:
			return 1
		return v[r][c]
	_cells = []
	for r in range(-1, _h):
		var row: Array = []
		for c in range(-1, _w):
			var a: int = vat.call(r, c)
			var b: int = vat.call(r, c + 1)
			var cc: int = vat.call(r + 1, c)
			var d: int = vat.call(r + 1, c + 1)
			if a == 0 and b == 0 and cc == 0 and d == 0:
				row.append(Rect2())
				continue
			var best := _choose(_key(a, b, cc, d), r, c, vat)
			var s := _hash(c, r, 7) % sets
			row.append(Rect2(tiles[best]["r"][s], Vector2(T, T)))
		_cells.append(row)
	_place(m, cave, rock)


func _choose(key: int, r: int, c: int, vat: Callable) -> int:
	var cand: Array = by_key.get(key, [])
	if cand.size() == 1:
		return cand[0]
	if cand.is_empty():
		cand = range(tiles.size())
	var best := 0
	var best_score := -999999
	for i in cand:
		var p: PackedInt32Array = tiles[i]["p"]
		var score := 0
		for k in 16:
			if p[k] == 255:
				continue
			var have: int = vat.call(r - 1 + k / 4, c - 1 + k % 4)
			var centre := CENTER.has(k)
			if have == p[k]:
				score += 10 if centre else 1
			else:
				score -= 30 if centre else 1
		if score > best_score:
			best_score = score
			best = i
	return best


func _place(m, cave: Array, rock: Callable) -> void:
	_decals = []
	_back = []
	_front = []
	_thin = []
	var start: Vector2i = m.CAVE_START
	var exit: Vector2i = m.CAVE_EXIT_TILE
	var ore := func(x: int, y: int) -> bool:
		if x < 0 or y < 0 or x >= _w or y >= _h:
			return false
		var k: int = cave[y][x]
		return k == m.Tile.ORE_COPPER or k == m.Tile.ORE_IRON
	var by_ore := func(x: int, y: int) -> bool:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if ore.call(x + dx, y + dy):
					return true
		return false
	for y in _h:
		for x in _w:
			var near := absi(x - start.x) + absi(y - start.y) <= NEAR
			var by_exit := absi(x - exit.x) <= 2 and y >= exit.y - 1
			var o := Vector2(x * T, y * T)
			if not rock.call(x, y):
				if cave[y][x] != m.Tile.FLOOR:
					continue
				# Floor decals: centred on the tile, nudged a little; big ones only where the floor is open.
				var roll := _roll(x, y, 1)
				var kind := ""
				if near:
					if roll < 0.22:
						kind = "leaves"
					elif roll < 0.34:
						kind = "roots"
					elif roll < 0.42:
						kind = "pebbles"
				elif roll < 0.24:
					kind = "small"
				elif roll < 0.29:
					kind = "gravel"
				elif roll < 0.315:
					kind = "crack"
				elif roll < 0.33:
					kind = "puddle"
				if kind != "":
					var src := _pick(kind, x, y, 2)
					if src.size.x > T or src.size.y > T:
						var open := true
						for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
							if rock.call(x + d.x, y + d.y):
								open = false
						if not open:
							src = _pick("small", x, y, 2)
					if src.size != Vector2.ZERO:
						var jitter := Vector2(_hash(x, y, 3) % 5 - 2, _hash(x, y, 4) % 5 - 2)
						_decals.append([src, o + (Vector2(T, T) - src.size) * 0.5 + jitter])
				continue
			if ore.call(x, y):
				var src := _pick("copper" if cave[y][x] == m.Tile.ORE_COPPER else "iron", x, y, 5)
				_back.append([src, o + (Vector2(T, T) - src.size) * 0.5 + Vector2(0, 1)])
			var floor_n: bool = not rock.call(x, y - 1)
			var floor_s: bool = not rock.call(x, y + 1)
			if floor_n and floor_s:
				_thin.append(Vector2i(x, y))
			if by_ore.call(x, y) or by_exit:
				continue
			if floor_s:
				# A face: something hung from its top, or rubble or a fern at its foot.
				var roll := _roll(x, y, 6)
				if near and roll < 0.45:
					_hang(_pick("moss", x, y, 8), o)
				elif not near and roll < 0.22:
					_hang(_pick("drip", x, y, 8), o)
				var roll2 := _roll(x, y, 9)
				if near and roll2 < 0.3:
					_foot(_pick("fern", x, y, 10), o)
				elif roll2 < 0.1:
					_foot(_pick("foot", x, y, 10), o)
			elif floor_n and not floor_s and _roll(x, y, 11) < 0.12:
				# A stone or spire standing on the rock's north lip, over the farmer.
				var src := _pick("mossrock" if near else ("spire" if _roll(x, y, 12) < 0.5 else "boulder"), x, y, 13)
				if src.size != Vector2.ZERO:
					var lip := src.size.y - FRONT_REACH        # its base sits this far down the wall tile
					if lip <= T - 2:
						_front.append([src, o + Vector2((T - src.size.x) * 0.5, lip - src.size.y)])


func _hang(src: Rect2, o: Vector2) -> void:
	if src.size != Vector2.ZERO:
		_back.append([src, o + Vector2((T - src.size.x) * 0.5, 0)])


func _foot(src: Rect2, o: Vector2) -> void:
	# Its base on the face's foot, inside the wall tile (the face's own foot reaches 5 px over the floor).
	if src.size != Vector2.ZERO:
		_back.append([src, o + Vector2((T - src.size.x) * 0.5, T + 3 - src.size.y)])


# --- drawing ---

func _refresh(m) -> void:
	var sig: int = m.cave.hash()
	if sig != _sig:
		_sig = sig
		_rebuild(m)


func draw(m, x0: int, y0: int, x1: int, y1: int) -> void:
	_refresh(m)
	var px: float = m.PX
	var s := px / T
	# The floor tile as PixelLab made it: it tiles seamlessly only unturned (its grain runs one way), so the
	# variety comes from the decals.
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			m.draw_texture_rect(floor_tex, Rect2(x * px, y * px, px, px), false)
	var view := Rect2(x0 * T - T * 2, y0 * T - T * 2, (x1 - x0 + 5) * T, (y1 - y0 + 5) * T)
	_draw_list(m, _decals, s, view)
	for r in range(y0 - 1, y1 + 1):
		for c in range(x0 - 1, x1 + 1):
			if r < -1 or c < -1 or r >= _h or c >= _w:
				continue
			var cell: Rect2 = _cells[r + 1][c + 1]
			if cell.size != Vector2.ZERO:
				m.draw_texture_rect_region(walls, Rect2((c + 0.5) * px, (r + 0.5) * px, px, px), cell)
	var face: Array = tiles[face_tile]["r"]
	for t in _thin:
		if t.x >= x0 - 1 and t.x <= x1 + 1 and t.y >= y0 - 1 and t.y <= y1 + 1:
			var src := Rect2(face[_hash(t.x, t.y, 7) % sets], Vector2(T, T))
			m.draw_texture_rect_region(walls, Rect2(t.x * px, t.y * px, px, px), src)
	_draw_list(m, _back, s, view)
	# The way out: steps over both exit tiles, centred on them, reaching down into the outer wall south of them.
	var steps := _pick("steps", 0, 0, 0)
	if steps.size != Vector2.ZERO:
		var e: Vector2i = m.CAVE_EXIT_TILE
		var at := Vector2(e.x * T + T - steps.size.x * 0.5, e.y * T)
		m.draw_texture_rect_region(atlas, Rect2(at * s, steps.size * s), steps)


func draw_front(ci: CanvasItem, m, x0: int, y0: int, x1: int, y1: int) -> void:
	if not ok or m.cave.is_empty():
		return
	_refresh(m)
	var view := Rect2(x0 * T - T * 2, y0 * T - T * 2, (x1 - x0 + 5) * T, (y1 - y0 + 5) * T)
	_draw_list(ci, _front, m.PX / T, view)


func _draw_list(ci: CanvasItem, list: Array, s: float, view: Rect2) -> void:
	for it in list:
		var src: Rect2 = it[0]
		var at: Vector2 = it[1]
		if view.has_point(at):
			ci.draw_texture_rect_region(atlas, Rect2(at * s, src.size * s), src)
