class_name TrekArt
extends RefCounted

# ART-OVERHAUL-001 Stage D: the treks in PixelLab art (art/farm/trek/, made by tools/aoh_trek.py). TrekSystem draws
# through this when TREK_ART_V2 is on; off, its old drawing returns. Art only: the tiles, blocking, routes, events
# and timings are TrekSystem's and untouched here.
# - Three grounds by route (the trail on the dual grid): the misty forest (edge, mill, chapel, post), the
#   overgrown pasture (the orchard's marked way) and the dark hollow (the dark trail and the grove route).
# - Every wood tile gets a tree or, where a tree would hang over open ground, undergrowth. A piece may reach at
#   most PATH_REACH art px over the trail, an exit or an event's tiles, and OPEN_REACH over other open ground.
#   Trees darken the deeper they stand from open ground (VIS-002's depth tint), and the ground under the wood is
#   shaded. Open ground gets flat details and a stepped shadow where it meets the trees.
# - The events and destinations are sprites at the old positions: the fallen log, the flooded hollow (creek water,
#   reeds, and the footbridge once built), the fingerpost, the cairn, the hollow tree, the mill with its turning
#   wheel, the chapel, the drowned orchard, the grove and the stile. Fog billows and two drifting fog layers.

const DIR := "res://art/farm/trek/"
const T := 16                       # art px per tile
const PATH_REACH := 3               # art px an upright piece may reach over the trail, an exit or an event's tiles
const OPEN_REACH := 5               # ... over the open ground around the trail
const DEPTH_TINTS := [Color(0.94, 0.94, 0.94), Color(0.72, 0.74, 0.8), Color(0.54, 0.57, 0.66)]   # edge, one in, deeper
const WOOD_SHADE := Color(0.02, 0.03, 0.02, 0.5)   # the ground under the trees
const NUDGES := [0, -2, 2, -4, 4, -6, 6]
const BIG_EVERY := 3                # one deep wood tile in this many tries for a farm-sized tree (art/farm/concept)
# Tree mixes by ground: [kind, weight at the wood's edge, weight deeper in].
const TREES := {
	"forest": [["fir", 40, 62], ["maple", 44, 26], ["dead", 16, 12]],
	"pasture": [["apple", 34, 8], ["maple", 26, 30], ["fir", 18, 50], ["dead", 22, 12]],
	"hollow": [["fir", 34, 46], ["dead", 30, 22], ["ancient", 36, 32]],
}
const DECAL_ODDS := {"forest": 0.24, "pasture": 0.24, "hollow": 0.2}   # open tiles with a flat detail (a fifth of that on the trail)
const FOG_LAYERS := [
	{"alpha": 0.10, "size": 1.0, "speed": 5.0, "parallax": 0.0, "tint": Color(0.74, 0.78, 0.82)},
	{"alpha": 0.07, "size": 1.5, "speed": 9.0, "parallax": 0.18, "tint": Color(0.66, 0.7, 0.76)},
]
const FOG_BY_GROUND := {"forest": 1.0, "pasture": 0.6, "hollow": 1.35}
# Sprite spots measured on the kept art (art px from the sprite's top-left).
const SIGN_ARMS := [Vector2(3, 5), Vector2(21, 7)]   # the fingerpost's left and right arm tips
const MILL_WINDOW := Rect2(29, 23, 6, 6)        # the upper window, lit as the old mill's was
const CHAPEL_WINDOWS := [Rect2(30, 50, 4, 11)]   # by night, light through the door left ajar
const LIT := Color("e8c070")

var ok := false
var atlas: Texture2D
var grounds := {}                   # forest, pasture, hollow, creek -> Texture2D
var pieces: Array[Rect2] = []        # Rect2 in the atlas, by index
var kinds := {}                     # kind -> [piece index]
var holes := {}                     # hollow tree piece index -> Vector2 (art px)
var ground := "forest"              # this clearing's ground

var _sig := 0
var _decals: Array = []             # [piece, art-px top-left] flat on open ground
var _upright: Array = []            # [piece, art-px top-left, tint] trees and undergrowth, in drawing order
var _shade: Array[Vector2i] = []    # wood tiles (shaded ground)
var _edges: Array = []              # [tile, side] open tiles beside the wood, for the stepped shadow
var unplaced := 0                   # wood tiles nothing would fit (the check reports it)
var _reaches := PackedInt32Array()  # _reach per tile, while rebuilding


func _init() -> void:
	if not ResourceLoader.exists(DIR + "atlas.png"):
		return
	atlas = load(DIR + "atlas.png")
	for g in ["forest", "pasture", "hollow", "creek"]:
		grounds[g] = load(DIR + "ground_%s.png" % g)
	var f := FileAccess.open(DIR + "trek.json", FileAccess.READ)
	if f == null:
		return
	var meta: Dictionary = JSON.parse_string(f.get_as_text())
	for p in meta["pieces"]:
		var r: Array = p["r"]
		if p.has("hole"):
			holes[pieces.size()] = Vector2(p["hole"][0], p["hole"][1])
		pieces.append(Rect2(r[0], r[1], r[2], r[3]))
	for k in meta["kinds"]:
		kinds[k] = meta["kinds"][k]
	ok = atlas != null and grounds.size() == 4


static func _hash(x: int, y: int, salt: int) -> int:
	return absi(hash([x, y, salt]))


# --- layout (rebuilt when the clearing's tiles change) ---

static func _open(k: int) -> bool:
	return k in [MainGame.Tile.GRASS, MainGame.Tile.PATH, MainGame.Tile.FALLOW, MainGame.Tile.EXIT, MainGame.Tile.CAVE_EXIT, MainGame.Tile.FENCE]


# How far an art-px rect may reach over tile t: -1 where it may not overlap at all (never used), else the reach.
func _reach(m, t: Vector2i) -> int:
	if t.x < 0 or t.y < 0 or t.x >= m.CAVE_W or t.y >= m.CAVE_H:
		return 999
	var k: int = m.cave[t.y][t.x]
	if k in [MainGame.Tile.PATH, MainGame.Tile.EXIT, MainGame.Tile.CAVE_EXIT, MainGame.Tile.FENCE]:
		return PATH_REACH
	if k in [MainGame.Tile.GRASS, MainGame.Tile.FALLOW]:
		return OPEN_REACH
	if k == MainGame.Tile.ROCK or k == MainGame.Tile.HOUSE:
		return PATH_REACH   # the fingerpost, cairn, hollow tree and destination stay in view
	return 999


# Whether an upright piece's art-px rect stays clear of open ground (within the reach allowed on each tile).
func fits(m, r: Rect2) -> bool:
	var tx0 := floori(r.position.x / T)
	var ty0 := floori(r.position.y / T)
	var tx1 := floori((r.end.x - 1) / T)
	var ty1 := floori((r.end.y - 1) / T)
	var w: int = m.CAVE_W
	var cached: bool = _reaches.size() == w * m.CAVE_H
	for ty in range(ty0, ty1 + 1):
		for tx in range(tx0, tx1 + 1):
			var reach := 999
			if cached:
				if tx >= 0 and ty >= 0 and tx < w and ty < m.CAVE_H:
					reach = _reaches[ty * w + tx]
			else:
				reach = _reach(m, Vector2i(tx, ty))
			if reach >= 999:
				continue
			var o := r.intersection(Rect2(tx * T, ty * T, T, T))
			if o.size.x > reach and o.size.y > reach:
				return false
	return true


# The nearest sideways nudge (NUDGES, then a little further) that keeps a piece off the trail; as given if none does.
func _settle(m, at: Vector2, sz: Vector2, open_reach := 999) -> Vector2:
	for n in NUDGES + [-8, 8, -10, 10, -12, 12]:
		if clear_of(m, Rect2(at + Vector2(n, 0), sz), [], PATH_REACH, open_reach):
			return at + Vector2(n, 0)
	return at


# Whether an art-px rect keeps off the trail (within path_reach) and open ground (within open_reach), apart from
# the tiles in own.
func clear_of(m, r: Rect2, own: Array, path_reach: int, open_reach: int) -> bool:
	var Tl := MainGame.Tile
	for ty in range(floori(r.position.y / T), floori((r.end.y - 1) / T) + 1):
		for tx in range(floori(r.position.x / T), floori((r.end.x - 1) / T) + 1):
			if tx < 0 or ty < 0 or tx >= m.CAVE_W or ty >= m.CAVE_H or own.has(Vector2i(tx, ty)):
				continue
			var k: int = m.cave[ty][tx]
			var reach := 999
			if k in [Tl.PATH, Tl.EXIT, Tl.CAVE_EXIT, Tl.FENCE]:
				reach = path_reach
			elif k in [Tl.GRASS, Tl.FALLOW]:
				reach = open_reach
			var o := r.intersection(Rect2(tx * T, ty * T, T, T))
			if o.size.x > reach and o.size.y > reach:
				return false
	return true


# How far each wood tile stands from open ground (0 beside it, 1 one tile in, 2 deeper), by rings of neighbours.
func _depths(m) -> Dictionary:
	var out := {}
	for y in m.CAVE_H:
		for x in m.CAVE_W:
			if m.cave[y][x] != MainGame.Tile.TREE:
				continue
			var d := 2
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					var tx: int = x + dx
					var ty: int = y + dy
					if tx >= 0 and ty >= 0 and tx < m.CAVE_W and ty < m.CAVE_H and m.cave[ty][tx] != MainGame.Tile.TREE:
						d = mini(d, maxi(absi(dx), absi(dy)) - 1)
			out[Vector2i(x, y)] = d
	return out


func _pick_kind(x: int, y: int, depth: int) -> String:
	var mix: Array = TREES[ground]
	var total := 0
	for e in mix:
		total += int(e[1] if depth == 0 else e[2])
	var roll := _hash(x, y, 31) % maxi(1, total)
	for e in mix:
		roll -= int(e[1] if depth == 0 else e[2])
		if roll < 0:
			return e[0]
	return mix[0][0]


# Tries the pieces of a kind (from a hashed start) at the nudges, its foot on the tile's foot (or the tile below's,
# when that is wood too, for undergrowth). Returns [piece, top-left] or [].
func _try(m, kind: String, x: int, y: int, low: bool) -> Array:
	var list: Array = kinds.get(kind, [])
	if list.is_empty():
		return []
	var start := _hash(x, y, 7) % list.size()
	var feet := [0]
	if low and y + 1 < m.CAVE_H and m.cave[y + 1][x] == MainGame.Tile.TREE:
		feet.append(T)
	for foot in feet:
		for k in mini(list.size(), 5):
			var i: int = list[(start + k) % list.size()]
			var s: Vector2 = pieces[i].size
			for n in NUDGES:
				var at := Vector2(x * T + (T - s.x) * 0.5 + n, (y + 1) * T + foot - s.y + 1)
				at = at.round()
				if fits(m, Rect2(at, s)):
					return [i, at]
	return []


func _rebuild(m, trek) -> void:
	_decals = []
	_upright = []
	_shade = []
	_edges = []
	unplaced = 0
	var Tl := MainGame.Tile
	var depths := _depths(m)
	_reaches = PackedInt32Array()
	for y in m.CAVE_H:
		for x in m.CAVE_W:
			_reaches.append(_reach(m, Vector2i(x, y)))
	for y in m.CAVE_H:
		for x in m.CAVE_W:
			var k: int = m.cave[y][x]
			if k == Tl.TREE:
				_shade.append(Vector2i(x, y))
				var depth: int = depths[Vector2i(x, y)]
				var got: Array = []
				# The farm's own tall firs and maples, now and then deep in the wood where they clear the open ground.
				if depth == 2 and _hash(x, y, 23) % BIG_EVERY == 0:
					got = _try(m, "big", x, y, false)
				if got.is_empty():
					got = _try(m, _pick_kind(x, y, depth), x, y, false)
				if got.is_empty():
					got = _try(m, "u_" + ground, x, y, true)
				if got.is_empty():
					got = _try(m, "u_small", x, y, true)
				if got.is_empty():
					unplaced += 1
					continue
				_upright.append([got[0], got[1], DEPTH_TINTS[depth]])
			elif _open(k) and k != Tl.FENCE:
				for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
					var t: Vector2i = Vector2i(x, y) + d
					if t.x >= 0 and t.y >= 0 and t.x < m.CAVE_W and t.y < m.CAVE_H and m.cave[t.y][t.x] == Tl.TREE:
						_edges.append([Vector2i(x, y), d])
				var on_trail := k != Tl.GRASS and k != Tl.FALLOW
				var odds: float = DECAL_ODDS[ground] * (0.2 if on_trail else 1.0)
				if float(_hash(x, y, 11) % 1000) / 1000.0 < odds:
					var list: Array = kinds["d_" + ground]
					var i: int = list[_hash(x, y, 13) % list.size()]
					var s: Vector2 = pieces[i].size
					var off := Vector2(_hash(x, y, 17) % 7 - 3, _hash(x, y, 19) % 7 - 3)
					_decals.append([i, (Vector2(x * T, y * T) + (Vector2(T, T) - s) * 0.5 + off).round()])
	_reaches = PackedInt32Array()
	# Drawing order: by the foot (bottom edge), then left to right, so nearer pieces cover farther ones.
	_upright.sort_custom(func(a, b) -> bool:
		var fa: float = a[1].y + pieces[a[0]].size.y
		var fb: float = b[1].y + pieces[b[0]].size.y
		return fa < fb if fa != fb else a[1].x < b[1].x)


func _ground_of(trek) -> String:
	if trek.route_id == "grove" or trek._trail() == "dark":
		return "hollow"
	if trek.route_id == "orchard":
		return "pasture"
	return "forest"


func refresh(m, trek) -> void:
	var g := _ground_of(trek)
	var sig: int = hash([m.cave.hash(), g])
	if sig != _sig:
		_sig = sig
		ground = g
		_rebuild(m, trek)


# --- drawing ---

func _blit(ci: CanvasItem, i: int, at: Vector2, s: float, tint := Color.WHITE, flip_h := false) -> void:
	var src: Rect2 = pieces[i]
	var dst := Rect2(at * s, src.size * s)
	if flip_h:
		dst = Rect2(dst.position + Vector2(dst.size.x, 0), Vector2(-dst.size.x, dst.size.y))
	ci.draw_texture_rect_region(atlas, dst, src, tint)


func _first(kind: String, n := 0) -> int:
	var list: Array = kinds.get(kind, [])
	return -1 if list.is_empty() else int(list[n % list.size()])


# The dual grid: a tile per vertex, chosen by which of the four cells round it are "on" (the trail, or water).
func _dual(m, tex: Texture2D, on: Callable, x0: int, y0: int, x1: int, y1: int, fill: bool) -> void:
	var px: float = m.PX
	for y in range(y0, y1 + 2):
		for x in range(x0, x1 + 2):
			var mask := 0
			if on.call(x - 1, y - 1):
				mask |= 1
			if on.call(x, y - 1):
				mask |= 2
			if on.call(x - 1, y):
				mask |= 4
			if on.call(x, y):
				mask |= 8
			if mask == 0 and not fill:
				continue
			var src := Rect2((mask % 4) * T, (mask / 4) * T, T, T)
			if mask == 0 or mask == 15:
				src = Rect2(64 + (_hash(x, y, 3) % 4) * T, (0 if mask == 0 else T), T, T)
			m.draw_texture_rect_region(tex, Rect2((x - 0.5) * px, (y - 0.5) * px, px, px), src)


func draw(m, trek, x0: int, y0: int, x1: int, y1: int) -> void:
	refresh(m, trek)
	var px: float = m.PX
	var s := px / T
	var view := Rect2((x0 - 3) * T, (y0 - 1) * T, (x1 - x0 + 7) * T, (y1 - y0 + 6) * T)
	_dual(m, grounds[ground], func(x: int, y: int) -> bool: return trek._is_trail(x, y), x0, y0, x1, y1, true)
	var ev: String = trek._event()
	var water: Dictionary = {}
	if ev == "flood":
		for t in trek.blocked:
			water[t] = true
	var spec: Dictionary = trek._spec()
	if spec.has("dest") and trek.route_id == "orchard":
		var r: Rect2i = spec["dest"]
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				water[Vector2i(x, y)] = true
	if not water.is_empty():
		_dual(m, grounds["creek"], func(x: int, y: int) -> bool: return water.has(Vector2i(x, y)), x0, y0, x1, y1, false)
	if spec.has("dest") and trek.route_id == "grove":
		_draw_grove_ring(m, spec["dest"])
	for t in _shade:
		if t.x >= x0 and t.x <= x1 and t.y >= y0 and t.y <= y1:
			m.draw_rect(Rect2(t.x * px, t.y * px, px, px), WOOD_SHADE)
	for e in _edges:
		var t: Vector2i = e[0]
		if t.x < x0 or t.x > x1 or t.y < y0 or t.y > y1:
			continue
		var d: Vector2i = e[1]
		var cell := Rect2(t.x * px, t.y * px, px, px)
		for band in [[1.0 / 3.0, 0.12], [1.0 / 6.0, 0.14]]:
			var deep := px * float(band[0])
			var r := Rect2(cell.position, Vector2(px, deep))
			if d == Vector2i(0, 1):
				r.position.y = cell.end.y - deep
			elif d.x != 0:
				r = Rect2(cell.position + Vector2(0.0 if d.x < 0 else px - deep, 0), Vector2(deep, px))
			m.draw_rect(r, Color(0.02, 0.03, 0.02, float(band[1])))
	for d in _decals:
		if view.has_point(d[1]):
			_blit(m, d[0], d[1], s, Color.WHITE, _hash(int(d[1].x), int(d[1].y), 5) % 2 == 0)
	if not water.is_empty():
		_draw_banks(m, water, s, view)
	if ev == "flood":
		_draw_crossing(m, trek, s)
	# Uprights and the event and destination pieces, in foot order, so they overlap as they stand.
	var items: Array = []
	for u in _upright:
		if view.has_point(u[1]):
			items.append([u[1].y + pieces[u[0]].size.y, 0, u])
	var ev_items := _event_items(m, trek, spec, ev)
	for e in ev_items:
		items.append([e[0], 1, e])
	items.sort_custom(func(a, b) -> bool: return a[0] < b[0] if a[0] != b[0] else a[1] < b[1])
	for it in items:
		if it[1] == 0:
			var u: Array = it[2]
			_blit(m, u[0], u[1], s, u[2], _hash(int(u[1].x), int(u[1].y), 9) % 3 == 0)
		else:
			(it[2][1] as Callable).call()
	if ev == "fog":
		_draw_fog(m, trek)


# Reeds and wet stones round the water, on its open edge tiles (flat, so they never block the view of the way).
func _draw_banks(m, water: Dictionary, s: float, view: Rect2) -> void:
	for t in water:
		for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var n: Vector2i = t + d
			if water.has(n) or _hash(n.x, n.y, 41) % 3 != 0:
				continue
			var kind := "reeds" if _hash(n.x, n.y, 43) % 3 != 0 else "stepstones"
			var list: Array = kinds[kind]
			var i: int = list[_hash(n.x, n.y, 47) % list.size()]
			var sz: Vector2 = pieces[i].size
			var at := (Vector2(t * T) + Vector2(T, T) * 0.5 + Vector2(d) * T * 0.55 - sz * 0.5).round()
			if view.has_point(at):
				_blit(m, i, at, s, Color.WHITE, _hash(n.x, n.y, 49) % 2 == 0)


# The rope tied across (as before), or the footbridge once the trail work keeps the hollow dry.
func _draw_crossing(m, trek, s: float) -> void:
	if trek.blocked.is_empty():
		return
	if trek._hollows_dry():
		var i := _first("bridge")
		if i < 0:
			return
		var spec: Dictionary = trek._spec()
		var pts: Array = spec["points"]
		var e := int(spec["event"])
		var a: Array = pts[maxi(0, e - 1)]
		var b: Array = pts[mini(pts.size() - 1, e + 1)]
		var across := absf(float(b[0]) - float(a[0])) >= absf(float(b[1]) - float(a[1]))
		var c := Vector2(trek.event_point * T) + Vector2(T, T * 0.5)
		var sz: Vector2 = pieces[i].size
		if across:
			for k in [-1, 0, 1]:
				_blit(m, i, (c + Vector2(k * (sz.x - 4) - sz.x * 0.5, -sz.y * 0.5)).round(), s)
		else:
			# Turned a quarter: the planks run up the trail (an exact 90 degree turn keeps the pixels square).
			for k in [-1, 0, 1]:
				var at := (c + Vector2(-sz.y * 0.5, k * (sz.x - 4) - sz.x * 0.5)).round() * s
				m.draw_set_transform(at + Vector2(sz.y * s, 0), PI * 0.5, Vector2.ONE)
				m.draw_texture_rect_region(atlas, Rect2(Vector2.ZERO, sz * s), pieces[i])
				m.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if trek.roped:
		var a: Vector2 = m._tile_center(trek.blocked[0].x, trek.blocked[0].y)
		var b: Vector2 = m._tile_center(trek.blocked[-1].x, trek.blocked[-1].y)
		var px: float = m.PX
		m.draw_line(a + Vector2(-px * 0.6, -px * 0.6), b + Vector2(px * 0.6, px * 0.3), Color("1d1611"), 4.0)
		m.draw_line(a + Vector2(-px * 0.6, -px * 0.6), b + Vector2(px * 0.6, px * 0.3), Color("b89a68"), 2.0)


# [foot y in art px, Callable that draws it, art-px Rect2, kind] for the event's and destination's pieces.
func _event_items(m, trek, spec: Dictionary, ev: String) -> Array:
	var out: Array = []
	var s: float = m.PX / float(T)
	if ev == "tree" and not trek.blocked.is_empty() and not trek.event_done:
		var lo := Vector2(1e9, 1e9)
		var hi := Vector2(-1e9, -1e9)
		for t in trek.blocked:
			lo = lo.min(Vector2(t * T))
			hi = hi.max(Vector2(t * T + Vector2i(T, T)))
		# The longest trunk that lies over the blocked stretch without covering the trail beyond it.
		var i := -1
		var at := Vector2.ZERO
		var long: Array = kinds.get("log", [])
		var logs: Array = []
		var turn := _hash(trek.event_point.x, trek.event_point.y, 1)
		for k in long.size():
			logs.append(long[(k + turn) % long.size()])
		logs.append_array(kinds.get("log_short", []))
		for j in logs:
			var p := ((lo + hi) * 0.5 - pieces[j].size * 0.5).round()
			i = j
			at = p
			if clear_of(m, Rect2(p, pieces[j].size), trek.blocked, PATH_REACH, OPEN_REACH):
				break
		var sz: Vector2 = pieces[i].size
		out.append([at.y + sz.y, func() -> void: _blit(m, i, at, s), Rect2(at, sz), "log"])
	if trek.sign_tile.x >= 0:
		var i := _first("sign")
		var t: Vector2i = trek.sign_tile
		var sz: Vector2 = pieces[i].size
		var at := Vector2(t.x * T + (T - sz.x) * 0.5, (t.y + 1) * T - sz.y + 1).round()
		out.append([at.y + sz.y, func() -> void:
			_blit(m, i, at, s)
			if trek._can_read_sign() and not trek.plan.is_empty():
				for side in 2:
					var marked: bool = (side == 1) == bool(trek.plan["marked_right"])
					var tip: Vector2 = (at + SIGN_ARMS[side]) * s
					if marked:
						m.draw_rect(Rect2(tip - Vector2(s, s), Vector2(s, s) * 2.0), LIT)
					else:
						m.draw_rect(Rect2(tip - Vector2(s, s * 0.5), Vector2(s * 2.0, s)), Color("1d1611")), Rect2(at, sz), "sign"])
	if (ev == "cairn" or ev == "hollow") and trek.side_tile.x >= 0:
		var t: Vector2i = trek.side_tile
		var kind := "cairn" if ev == "cairn" else "hollowtree"
		var i := _first(kind, _hash(t.x, t.y, 2))
		var sz: Vector2 = pieces[i].size
		var at := _settle(m, Vector2(t.x * T + (T - sz.x) * 0.5, (t.y + 1) * T - sz.y + 1).round(), sz)
		out.append([at.y + sz.y, func() -> void:
			_blit(m, i, at, s)
			if ev == "cairn" and trek.event_done:
				m.draw_rect(Rect2((at + Vector2(sz.x * 0.5 - 1, sz.y - 4)) * s, Vector2(2, 2) * s), LIT)
			elif ev == "hollow" and not trek.event_done:
				var h: Vector2 = holes.get(i, sz * Vector2(0.5, 0.7))
				m.draw_rect(Rect2((at + h - Vector2(1, 0)) * s, Vector2(2, 1) * s), Color("b8b0a0")), Rect2(at, sz), kind])
	if spec.has("dest"):
		var r: Rect2i = spec["dest"]
		match trek.route_id:
			"orchard":
				out.append_array(_orchard_items(m, r, s))
			"chapel", "post":
				out.append(_building_item(m, trek, r, "chapel", s))
			"grove":
				out.append_array(_grove_items(m, r, s))
			"edge":
				out.append(_building_item(m, trek, r, "stile", s))
			_:
				out.append(_building_item(m, trek, r, "mill", s))
	return out


# A destination piece centred on its rect, its foot on the rect's foot. The mill gets its wheel and lit window,
# the chapel its windows lit by night.
func _building_item(m, trek, r: Rect2i, kind: String, s: float) -> Array:
	var i := _first(kind)
	var sz: Vector2 = pieces[i].size
	var w := Vector2(r.size * T)
	var base := Vector2(r.position * T)
	var at := (base + Vector2((w.x - sz.x) * 0.5, w.y - sz.y)).round()
	if kind == "mill":
		at.x = base.x + 2
	return [at.y + sz.y, func() -> void:
		_blit(m, i, at, s)
		if kind == "mill":
			m.draw_rect(Rect2((at + MILL_WINDOW.position) * s, MILL_WINDOW.size * s), LIT)
			var wi := _first("wheel")
			var ws: Vector2 = pieces[wi].size
			var wat := (at + Vector2(sz.x - 6, sz.y - ws.y - 2)).round()
			# The wheel turns by stepping through its four mirrorings, so its paddles move without resampling.
			var f := int(Time.get_ticks_msec() / 260) % 4
			var src: Rect2 = pieces[wi]
			var dst := Rect2(wat * s, ws * s)
			if f == 1 or f == 2:
				dst = Rect2(dst.position + Vector2(dst.size.x, 0), Vector2(-dst.size.x, dst.size.y))
			if f >= 2:
				dst = Rect2(dst.position + Vector2(0, dst.size.y), Vector2(dst.size.x, -dst.size.y))
			m.draw_texture_rect_region(atlas, dst, src)
		elif kind == "chapel" and trek.night:
			for wr in CHAPEL_WINDOWS:
				m.draw_rect(Rect2((at + wr.position) * s, wr.size * s), LIT), Rect2(at, sz), kind]


# The drowned orchard: gone-wild apple trees and a dead one standing in black water, broken fencing either side.
func _orchard_items(m, r: Rect2i, s: float) -> Array:
	var out: Array = []
	var base := Vector2(r.position * T)
	var w := float(r.size.x * T)
	var spots := [[0.2, "apple", 0], [0.52, "dead", 3], [0.82, "apple", 2]]
	for k in spots.size():
		var i := _first(spots[k][1], spots[k][2])
		var sz: Vector2 = pieces[i].size
		var foot := base.y + r.size.y * T - (4 if k % 2 == 0 else 12)
		var at := Vector2(base.x + w * float(spots[k][0]) - sz.x * 0.5, foot - sz.y).round()
		out.append([foot, func() -> void: _blit(m, i, at, s, Color(0.92, 0.94, 0.96)), Rect2(at, sz), "orchard"])
	for side in [-1, 1]:
		var list: Array = kinds["u_pasture"]
		var i: int = list[10 if side < 0 else 12]
		var sz: Vector2 = pieces[i].size
		var at := Vector2((base.x - sz.x + 6) if side < 0 else (base.x + w - 6), base.y + r.size.y * T - sz.y).round()
		if not clear_of(m, Rect2(at, sz), [], PATH_REACH, OPEN_REACH):
			continue
		out.append([at.y + sz.y, func() -> void: _blit(m, i, at, s, Color.WHITE, side > 0), Rect2(at, sz), "orchard"])
	return out


# The Hollow's grove: a path worn round and round in the middle of the rect, great old trees behind and standing
# stones in front.
func _draw_grove_ring(m, r: Rect2i) -> void:
	var inner := Rect2i(r.position + Vector2i(1, 0), r.size - Vector2i(2, 0))
	var ring := func(x: int, y: int) -> bool:
		return inner.has_point(Vector2i(x, y)) and not (y == r.position.y + 1 and x > inner.position.x and x < inner.end.x - 1)
	_dual(m, grounds["hollow"], ring, inner.position.x - 1, inner.position.y - 1, inner.end.x, inner.end.y, false)


func _grove_items(m, r: Rect2i, s: float) -> Array:
	var out: Array = []
	var base := Vector2(r.position * T)
	var w := float(r.size.x * T)
	var h := float(r.size.y * T)
	for k in 3:
		var i := _first("ancient", k)
		var sz: Vector2 = pieces[i].size
		var foot := base.y + h * (0.55 if k == 1 else 0.75)
		var at := _settle(m, Vector2(base.x + w * (0.12 + 0.38 * k) - sz.x * 0.5 + 6, foot - sz.y).round(), sz, OPEN_REACH)
		out.append([foot, func() -> void: _blit(m, i, at, s, Color(0.8, 0.82, 0.88), k == 2), Rect2(at, sz), "grove"])
	for k in 2:
		var i := _first("stone", k * 2)
		var sz: Vector2 = pieces[i].size
		var foot := base.y + h - 1
		var at := Vector2(base.x + w * (0.3 + 0.4 * k) - sz.x * 0.5, foot - sz.y).round()
		out.append([foot, func() -> void: _blit(m, i, at, s), Rect2(at, sz), "grove"])
	return out


# The fog bank: billows of the weather fog over the event, thick while it blocks the trail, thin once it lifts.
func _draw_fog(m, trek) -> void:
	var px: float = m.PX
	var a := 0.85 if not trek.event_done else (0.3 if m.lantern_tier >= trek.FOG_LANTERN and trek.fog_lift_at < 0.0 else 0.0)
	if trek.fog_lift_at >= 0.0 and trek.event_done:
		a = clampf(0.85 - (trek.clearing_time - trek.fog_lift_at) * 0.3, 0.0, 0.85)
	if a <= 0.0:
		return
	var tex := FarmSprites.tex("weather_fog")
	var c: Vector2 = m._tile_center(trek.event_point.x, trek.event_point.y) + Vector2(px * 0.5, 0)
	var t := Time.get_ticks_msec() / 1000.0
	for k in 12:
		var ang := TAU * k / 12.0
		var p := c + Vector2(cos(ang + t * 0.1) * px * (1.2 + (k % 3)), sin(ang) * px * (0.6 + (k % 2) * 0.8))
		if tex != null:
			var sz: Vector2 = tex.get_size() * m.SCALE * (1.0 + 0.15 * (k % 3))
			m.draw_texture_rect(tex, Rect2((p - sz * 0.5).snapped(Vector2(m.SCALE, m.SCALE)), sz), false, Color(0.8, 0.82, 0.82, a * 0.7))
		else:
			m.draw_circle(p, px * 1.1, Color(0.78, 0.8, 0.8, a * 0.45))
	m.draw_circle(c, px * 1.4, Color(0.82, 0.84, 0.84, a * 0.5))


# Two thin layers of fog drifting across the wood (on TrekSystem's layer, above the walker), thicker in the hollow.
func draw_fog_layers(m, layer: CanvasItem) -> void:
	var tex := FarmSprites.tex("weather_fog")
	if tex == null:
		return
	var view: Vector2 = m.get_viewport_rect().size / m.camera.zoom
	var centre: Vector2 = m.camera.get_screen_center_position()
	var top_left := centre - view * 0.5
	var t := Time.get_ticks_msec() / 1000.0
	var thick: float = FOG_BY_GROUND.get(ground, 1.0)
	for f in FOG_LAYERS:
		var size: Vector2 = tex.get_size() * m.SCALE * float(f["size"])
		var step := Vector2(size.x * 1.35, size.y * 2.4)
		var shift := Vector2(t * float(f["speed"]) - centre.x * float(f["parallax"]), -centre.y * float(f["parallax"]))
		var col: Color = f["tint"]
		col.a = float(f["alpha"]) * thick
		var gx0 := floori((top_left.x - shift.x) / step.x) - 1
		var gy0 := floori((top_left.y - shift.y) / step.y) - 1
		for gy in range(gy0, gy0 + ceili(view.y / step.y) + 3):
			for gx in range(gx0, gx0 + ceili(view.x / step.x) + 3):
				var stagger := step.x * 0.5 if gy % 2 != 0 else 0.0
				var at := Vector2(gx * step.x + stagger, gy * step.y) + shift
				layer.draw_texture_rect(tex, Rect2(at.snapped(Vector2(m.SCALE, m.SCALE)), size), false, col)
