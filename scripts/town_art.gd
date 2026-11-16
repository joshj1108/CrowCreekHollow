class_name TownArt
extends RefCounted

# Wicker Cove's drawing (CCH-WICKER-COVE-ALPHA-001). The ground is two PixelLab Wang tilesets on the dual grid
# (muddy grass to cobbles, sea to quay stone); buildings, boats, the two residents and the harbour props are
# PixelLab sprites in art/farm/town/ (built by tools/wicker_art.py); the trees, lamp posts, barrels, bench and the
# inn's room reuse the farm's art. Missing art falls back to flat colours, so the village still works without it.
#
# Everything that stands is drawn in row order: what stands on or above the farmer's row goes on the main canvas
# behind them, the rest on TownSystem's front layer over them.

const FarmArt := preload("res://scripts/farm_art.gd")
const DIR := "res://art/farm/town/"
const S := 3.0                               # world px per art px (MainGame.SCALE)
const T := 48.0                              # world px per tile (MainGame.PX)

# Corner mask (NW 8, NE 4, SW 2, SE 1; set = upper terrain) -> tile index in the 4x4 sheet, from the tilesets'
# metadata (both sheets share the layout).
const WANG := {13: 0, 10: 1, 4: 2, 12: 3, 6: 4, 8: 5, 0: 6, 1: 7, 11: 8, 3: 9, 2: 10, 5: 11, 15: 12, 14: 13, 9: 14, 7: 15}
const FLAT := {"g": Color("3c4a2c"), "c": Color("5d5a52"), "s": Color("6f7270"), "w": Color("2f4a48")}
const MUD := Color(0.24, 0.17, 0.1, 0.45)

# Lit windows, as fractions of each building's art (x from its left, y from its top).
const WINDOWS := {
	"store": [Vector2(0.30, 0.70)],
	"inn": [Vector2(0.32, 0.76), Vector2(0.74, 0.76), Vector2(0.58, 0.74)],
	"house_a": [Vector2(0.68, 0.74)],
	"house_b": [Vector2(0.66, 0.72)],
	"house_d": [Vector2(0.80, 0.74)],
}
# Where Thomas's half-door is in the store's art: redrawn over his legs, so he stands behind it.
const STORE_HALF_DOOR := Rect2(71, 70, 21, 29)
# Props drawn in place of the plain barrels on particular tiles.
const PROP_AT := {Vector2i(14, 21): "lobster_pot", Vector2i(24, 21): "rope_coil", Vector2i(6, 20): "crate_pile"}

var town: TownSystem
var m: MainGame
var _tex := {}
var terrain: Array = []                      # [y][x] "g", "c", "s" or "w" for the ground under each tile


func _init(t: TownSystem) -> void:
	town = t
	m = t.m


func tex(name: String) -> Texture2D:
	if not _tex.has(name):
		var path := name if name.begins_with("res://") else DIR + name + ".png"
		_tex[name] = load(path) if ResourceLoader.exists(path) else null
	return _tex[name]


# --- Ground ---------------------------------------------------------------------------------------------

func build_terrain() -> void:
	terrain = []
	for y in TownLayout.H:
		var row: Array = []
		for x in TownLayout.W:
			row.append(_base(str(TownLayout.TERRAIN[y][x])))
		terrain.append(row)
	# Props and buildings sit on whatever most of their neighbours are.
	for y in TownLayout.H:
		for x in TownLayout.W:
			if terrain[y][x] != "":
				continue
			var count := {}
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var p: Vector2i = Vector2i(x, y) + d
				if p.x >= 0 and p.y >= 0 and p.x < TownLayout.W and p.y < TownLayout.H:
					var b := _base(str(TownLayout.TERRAIN[p.y][p.x]))
					if b != "":
						count[b] = int(count.get(b, 0)) + 1
			var best := "g"
			for k in count:
				if int(count[k]) > int(count.get(best, 0)):
					best = k
			terrain[y][x] = best


func _base(c: String) -> String:
	match c:
		",", "m", "T":
			return "g"
		"=", "E", "D":
			return "c"
		"q", "r":
			return "s"
		"~", "k", "b":
			return "w"
	return ""


func _ter(x: int, y: int) -> String:
	x = clampi(x, 0, TownLayout.W - 1)
	y = clampi(y, 0, TownLayout.H - 1)
	return str(terrain[y][x])


func draw_ground(ci: CanvasItem, r: Rect2i) -> void:
	var street := tex("tiles_street")
	var sea := tex("tiles_sea")
	for y in range(r.position.y, r.end.y + 1):
		for x in range(r.position.x, r.end.x + 1):
			# The dual grid: this cell straddles four map tiles, its corners.
			var cs := [_ter(x - 1, y - 1), _ter(x, y - 1), _ter(x - 1, y), _ter(x, y)]
			var at := Rect2((x - 0.5) * T, (y - 0.5) * T, T, T)
			if street == null or sea == null:
				ci.draw_rect(at, FLAT[cs[3]])
				continue
			var sheet: Texture2D
			var mask := 0
			if cs.has("w"):
				# Swapped in this sheet too: its "upper" corners are the water.
				sheet = sea
				mask = _mask(cs, func(c: String) -> bool: return c == "w")
			elif cs.has("s") and not cs.has("g"):
				sheet = sea
				mask = 0
			else:
				# PixelLab swapped this sheet's terrains: its "upper" corners are the grass.
				sheet = street
				mask = _mask(cs, func(c: String) -> bool: return c == "g")
			var i: int = WANG[mask]
			ci.draw_texture_rect_region(sheet, at, Rect2((i % 4) * 16, (i / 4) * 16, 16, 16))
	# Mud by the market, over the grass.
	for y in range(r.position.y, r.end.y + 1):
		for x in range(r.position.x, r.end.x + 1):
			if _char(x, y) == "m":
				var h := FarmArt.hash_int(x, y, 5)
				ci.draw_rect(Rect2(x * T + (h % 3) * S, y * T + (h % 2) * S, T - S * 2, T - S * 3), MUD)


func _mask(cs: Array, upper: Callable) -> int:
	return (8 if upper.call(cs[0]) else 0) | (4 if upper.call(cs[1]) else 0) | (2 if upper.call(cs[2]) else 0) | (1 if upper.call(cs[3]) else 0)


func _char(x: int, y: int) -> String:
	if y < 0 and x >= 0 and x < TownLayout.W:
		return str(TownLayout.TERRAIN[0][x])   # above the map: the forest, and the road going on up the hill
	if x < 0 or y < 0 or x >= TownLayout.W or y >= TownLayout.H:
		return "T"
	return str(TownLayout.TERRAIN[y][x])


# The pier: weathered boards over the water, posts down each side, a dark edge where it stands over the sea.
func draw_pier(ci: CanvasItem) -> void:
	var board := Color("5e4a36")
	var gap := Color("2e241b")
	var light := Color("7a6248")
	for y in TownLayout.H:
		for x in TownLayout.W:
			if _char(x, y) != "k":
				continue
			var cell := Rect2(x * T, y * T, T, T)
			ci.draw_rect(cell, board)
			for k in 4:
				ci.draw_rect(Rect2(cell.position.x, cell.position.y + k * 4 * S, T, S), light if k == 0 else gap)
			if (FarmArt.hash_int(x, y, 7) % 3) == 0:
				ci.draw_rect(Rect2(cell.position.x + 5 * S, cell.position.y + 6 * S, 4 * S, S), Color("3a2c20"))
			var west := _char(x - 1, y) != "k"
			var east := _char(x + 1, y) != "k"
			if west:
				ci.draw_rect(Rect2(cell.position.x - S, cell.position.y, S * 2, T), Color("241b14"))
			if east:
				ci.draw_rect(Rect2(cell.end.x - S, cell.position.y, S * 2, T), Color("241b14"))
			if _char(x, y + 1) != "k":
				ci.draw_rect(Rect2(cell.position.x, cell.end.y, T, S * 3), Color("1c1612"))
				if west:
					ci.draw_rect(Rect2(cell.position.x - S, cell.end.y, S * 2, S * 6), Color("241b14"))
				if east:
					ci.draw_rect(Rect2(cell.end.x - S, cell.end.y, S * 2, S * 6), Color("241b14"))


# --- What stands ------------------------------------------------------------------------------------

# Every standing thing in view: [base y in world px, kind, data]. Sorted by base so rows overlap correctly.
func standing(r: Rect2i) -> Array:
	var out: Array = []
	for id in TownLayout.BUILDINGS:
		var b: Rect2i = TownLayout.BUILDINGS[id]
		if b.end.y >= r.position.y - 1 and b.position.y <= r.end.y + 4:
			out.append([b.end.y * T, "building", id])
	for y in range(maxi(-TownSystem.TOP_MARGIN - 1, r.position.y - 1), mini(TownLayout.H, r.end.y + 4)):
		for x in range(maxi(0, r.position.x - 2), mini(TownLayout.W, r.end.x + 3)):
			var c := _char(x, y)
			if c in ["T", "L", "x", "o", "B", "S", "r"]:
				out.append([(y + 1) * T, c, Vector2i(x, y)])
			elif c == "n" and _char(x - 1, y) != "n":
				out.append([(y + 1) * T, "n", Vector2i(x, y)])
			elif c == "b" and _char(x, y - 1) != "b":
				out.append([(y + 4) * T - 0.1, "b", Vector2i(x, y)])
	out.append([TownLayout.BUILDINGS["store"].end.y * T + 0.1, "thomas", null])   # just after the store, in its doorway
	out.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	return out


func draw_standing(ci: CanvasItem, r: Rect2i, front: bool, feet: float) -> void:
	for it in standing(r):
		if (float(it[0]) > feet) != front:
			continue
		match str(it[1]):
			"building":
				_draw_building(ci, str(it[2]))
			"thomas":
				_draw_thomas(ci)
			"T":
				_draw_tree(ci, it[2])
			"L":
				_sprite(ci, tex("res://art/farm/concept/src_lantern_post.png"), it[2], 0.0)
			"x":
				_draw_crate(ci, it[2])
			"o":
				_sprite(ci, tex("bollard"), it[2], 0.0)
			"B":
				_sprite(ci, tex("res://art/farm/e3/bench.png"), it[2], 0.0)
			"S":
				_draw_sign(ci, it[2])
			"r":
				_draw_rock(ci, it[2])
			"n":
				_draw_wide(ci, tex("net_rack"), it[2], 3)
			"b":
				_draw_boat(ci, it[2])


# A sprite standing on a tile: centred, its foot on the tile's bottom edge (lifted lift art px).
func _sprite(ci: CanvasItem, t: Texture2D, tile: Vector2i, lift: float) -> void:
	if t == null:
		ci.draw_rect(Rect2(tile.x * T + 6 * S, tile.y * T + 2 * S, T - 12 * S, T - 3 * S), Color("4a3a2c"))
		return
	var sz := t.get_size() * S
	ci.draw_texture_rect(t, Rect2(Vector2((tile.x + 0.5) * T - sz.x * 0.5, (tile.y + 1) * T - sz.y - lift * S).floor(), sz), false)


func _draw_wide(ci: CanvasItem, t: Texture2D, tile: Vector2i, tiles: int) -> void:
	if t == null:
		ci.draw_rect(Rect2(tile.x * T, tile.y * T, tiles * T, T), Color("4a3a2c"))
		return
	var sz := t.get_size() * S
	ci.draw_texture_rect(t, Rect2(Vector2((tile.x + tiles * 0.5) * T - sz.x * 0.5, (tile.y + 1) * T - sz.y).floor(), sz), false)


func building_rect(id: String) -> Rect2:
	var b: Rect2i = TownLayout.BUILDINGS[id]
	var t := tex(id)
	var sz := (t.get_size() if t != null else Vector2(b.size * 16)) * S
	return Rect2(Vector2(floorf(b.position.x * 16 + (b.size.x * 16 - sz.x / S) * 0.5) * S, b.end.y * T - sz.y), sz)


func _draw_building(ci: CanvasItem, id: String) -> void:
	var t := tex(id)
	var r := building_rect(id)
	if t == null:
		ci.draw_rect(r, Color("4b4038"))
		ci.draw_rect(Rect2(r.position, Vector2(r.size.x, r.size.y * 0.45)), Color("33363c"))
		return
	ci.draw_texture_rect(t, r, false)


# Thomas in his doorway, behind the half-door (the store's own art redrawn over his legs).
func _draw_thomas(ci: CanvasItem) -> void:
	var t := tex("thomas")
	var feet := TownLayout.THOMAS * T
	if t != null:
		var sz := t.get_size() * S
		ci.draw_texture_rect(t, Rect2(Vector2(feet.x - sz.x * 0.5, feet.y - sz.y).floor(), sz), false)
	else:
		ci.draw_rect(Rect2(feet.x - 8 * S, feet.y - 28 * S, 16 * S, 28 * S), Color("6a5a48"))
	var store := tex("store")
	if store != null:
		var r := building_rect("store")
		var src := STORE_HALF_DOOR
		ci.draw_texture_rect_region(store, Rect2(r.position + src.position * S, src.size * S), src)


func _draw_tree(ci: CanvasItem, tile: Vector2i) -> void:
	var v := FarmArt.hash_int(tile.x, tile.y, 19) % 3
	var t := tex("res://art/farm/tree_fir_%d.png" % v)
	var jx := float(FarmArt.hash_int(tile.x, tile.y, 23) % 5) - 2.0
	if t == null:
		ci.draw_rect(Rect2(tile.x * T, tile.y * T - T, T, T * 2), Color("23301f"))
		return
	var sz := t.get_size() * S
	ci.draw_texture_rect(t, Rect2(Vector2((tile.x + 0.5) * T - sz.x * 0.5 + jx * S, (tile.y + 1) * T - sz.y + S).floor(), sz), false)


func _draw_crate(ci: CanvasItem, tile: Vector2i) -> void:
	if PROP_AT.has(tile):
		_sprite(ci, tex(str(PROP_AT[tile])), tile, 0.0)
		return
	var v := FarmArt.hash_int(tile.x, tile.y, 29) % 3
	var name: String = ["res://art/farm/fi/barrel.png", "res://art/farm/fi/crates.png", "res://art/farm/concept/w3c_props_apple_barrel.png"][v]
	_sprite(ci, tex(name), tile, 0.0)


func _draw_rock(ci: CanvasItem, tile: Vector2i) -> void:
	# Only the rocks at the sea's edge show; the ones behind are hidden by the fog anyway.
	var v := FarmArt.hash_int(tile.x, tile.y, 31) % 3
	var t := tex("res://art/farm/boulder_%d.png" % v)
	if t == null:
		ci.draw_rect(Rect2(tile.x * T + S * 2, tile.y * T + S * 4, T - S * 4, T - S * 5), Color("4e4e50"))
		return
	_sprite(ci, t, tile, 0.0)


func _draw_boat(ci: CanvasItem, tile: Vector2i) -> void:
	var t := tex("boat_a" if tile.x < 20 else "boat_b")
	var bob := roundf(sin(Time.get_ticks_msec() / 900.0 + tile.x) * 0.6) * S
	var cell := Rect2(tile.x * T, tile.y * T, T * 2, T * 4)
	if t == null:
		ci.draw_rect(cell.grow(-S * 2), Color("5a4632"))
		return
	var sz := t.get_size() * S
	# A dark ripple round the hull, then the boat.
	ci.draw_rect(Rect2(cell.get_center().x - sz.x * 0.5 - S, cell.get_center().y - sz.y * 0.5 + S * 2 + bob, sz.x + S * 2, sz.y), Color(0.05, 0.09, 0.09, 0.35))
	ci.draw_texture_rect(t, Rect2(Vector2(cell.get_center().x - sz.x * 0.5, cell.get_center().y - sz.y * 0.5 + bob).floor(), sz), false)


# The village sign: a post and a painted board, its words in the game's own font so they read at any size.
func _draw_sign(ci: CanvasItem, tile: Vector2i) -> void:
	var base := Vector2((tile.x + 0.5) * T, (tile.y + 1) * T)
	ci.draw_rect(Rect2(base.x - 2 * S, base.y - 24 * S, 4 * S, 24 * S), Color("2a1f17"))
	ci.draw_rect(Rect2(base.x - 1 * S, base.y - 24 * S, 2 * S, 24 * S), Color("5a4430"))
	var board := Rect2(base.x - 28 * S, base.y - 30 * S, 56 * S, 13 * S)
	ci.draw_rect(board.grow(S), Color("1d1611"))
	ci.draw_rect(board, Color("4a3828"))
	ci.draw_rect(Rect2(board.position, Vector2(board.size.x, S)), Color("6a523a"))
	ci.draw_rect(Rect2(board.position.x, board.end.y - S, board.size.x, S), Color("33261b"))
	var font := ThemeDB.fallback_font
	ci.draw_string(font, Vector2(board.position.x, board.position.y + 9.5 * S), "WICKER COVE", HORIZONTAL_ALIGNMENT_CENTER, board.size.x, 20, Color("e6dcc4"))


# The notice board on the store's wall, with the order pinned to it while it stands.
func draw_board(ci: CanvasItem) -> void:
	var cell := Rect2(13 * T, 8 * T, T, T)
	var r := Rect2(cell.position.x + 2 * S, cell.position.y - 6 * S, 12 * S, 11 * S)
	ci.draw_rect(r.grow(S), Color("1d1611"))
	ci.draw_rect(r, Color("5a4430"))
	if town.order_open():
		ci.draw_rect(Rect2(r.position.x + 2 * S, r.position.y + 2 * S, 6 * S, 7 * S), Color("e0d6bc"))
		for k in 3:
			ci.draw_rect(Rect2(r.position.x + 3 * S, r.position.y + (4 + k * 2) * S, 4 * S, S), Color("6a6050"))
		ci.draw_rect(Rect2(r.position.x + 4 * S, r.position.y + 2 * S, S, S), Color("8a2e2a"))
	else:
		ci.draw_rect(Rect2(r.position.x + 3 * S, r.position.y + 3 * S, 5 * S, 4 * S), Color("b8ae94"))


# Fire-window light positions in world px (TownSystem puts a warm light at each).
func window_points() -> Array:
	var pts: Array = []
	for id in WINDOWS:
		var r := building_rect(id)
		for f in WINDOWS[id]:
			pts.append(r.position + r.size * (f as Vector2))
	return pts


func lamp_points() -> Array:
	var pts: Array = []
	for y in TownLayout.H:
		for x in TownLayout.W:
			if _char(x, y) == "L":
				pts.append(Vector2((x + 0.5) * T, (y + 1) * T - 40 * S))
	return pts


# --- The inn's common room -------------------------------------------------------------------------

func _ichar(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= TownLayout.IW or y >= TownLayout.IH:
		return "W"
	return str(TownLayout.INTERIOR[y][x])


func draw_inn(ci: CanvasItem, front: bool, feet: float) -> void:
	var o := Vector2(TownLayout.INT_ORIGIN) * T
	if not front:
		# The dark round the room, the floor, the north wall's face (three tiles), the side and front walls.
		ci.draw_rect(Rect2(o - Vector2(T * 6, T * 4), Vector2(TownLayout.IW + 12, TownLayout.IH + 8) * T), Color("0c0907"))
		var fl := tex("res://art/farm/fi/floor_3.png")
		for y in range(3, TownLayout.IH - 1):
			for x in range(1, TownLayout.IW - 1):
				var cell := Rect2(o + Vector2(x, y) * T, Vector2(T, T))
				if fl != null:
					ci.draw_texture_rect_region(fl, cell, Rect2((x % 2) * 16, (y % 2) * 16, 16, 16))
				else:
					ci.draw_rect(cell, Color("6e5438"))
		var wall := tex("res://art/farm/fi/wall_3.png")
		for x in range(0, TownLayout.IW):
			var cell := Rect2(o + Vector2(x, 0) * T, Vector2(T, T * 3))
			if wall != null:
				ci.draw_texture_rect_region(wall, cell, Rect2((x % 8) * 16, 0, 16, 48))
			else:
				ci.draw_rect(cell, Color("7a6a54"))
		for y in range(0, TownLayout.IH):
			ci.draw_rect(Rect2(o + Vector2(0, y) * T, Vector2(T * 0.5, T)), Color("2a1f17"))
			ci.draw_rect(Rect2(o + Vector2(TownLayout.IW - 0.5, y) * T, Vector2(T * 0.5, T)), Color("2a1f17"))
		for x in range(0, TownLayout.IW):
			if _ichar(x, TownLayout.IH - 1) == "X":
				var mat := Rect2(o + Vector2(x, TownLayout.IH - 1) * T, Vector2(T, T))
				ci.draw_rect(mat, Color("4a3a2c"))
				ci.draw_rect(mat.grow(-S * 3), Color("6a4a30"))
			else:
				ci.draw_rect(Rect2(o + Vector2(x, TownLayout.IH - 1) * T + Vector2(0, T * 0.4), Vector2(T, T * 0.6)), Color("2a1f17"))
		# Wall dressing: a shelf of crocks behind the counter, a painting, the window.
		_put(ci, "res://art/farm/fc/shelf_books.png", o + Vector2(7.2, 1.2) * T)
		_put(ci, "res://art/farm/fc/crock.png", o + Vector2(9.9, 2.25) * T)
		_put(ci, "res://art/farm/fc/jug.png", o + Vector2(10.5, 2.25) * T)
		_put(ci, "res://art/farm/fc/painting.png", o + Vector2(3.6, 0.6) * T)
		_put(ci, "res://art/farm/fi/win_frame.png", o + Vector2(11.4, 0.7) * T)
	# What stands, in row order.
	var items: Array = []
	items.append([(TownLayout.INT_ORIGIN.y + 4) * T, "hearth"])
	items.append([(TownLayout.INT_ORIGIN.y + TownLayout.EDITH.y) * T - 0.5, "edith"])
	items.append([(TownLayout.INT_ORIGIN.y + 5) * T, "counter"])
	items.append([(TownLayout.INT_ORIGIN.y + 5) * T, "barrels"])
	for c in TownLayout.CHAIRS:
		items.append([(TownLayout.INT_ORIGIN.y + c.y + 1) * T - (0.2 if c.y < 7 else 0.0), "chair", c])
	for t in TownLayout.TABLES:
		items.append([(TownLayout.INT_ORIGIN.y + t.y + 1) * T - 0.1, "table", t])
	items.sort_custom(func(a, b): return float(a[0]) < float(b[0]))
	for it in items:
		if (float(it[0]) > feet) != front:
			continue
		match str(it[1]):
			"hearth":
				_draw_hearth(ci, o)
			"edith":
				var t := tex("edith")
				var at := o + TownLayout.EDITH * T
				if t != null:
					var sz := t.get_size() * S
					ci.draw_texture_rect(t, Rect2(Vector2(at.x - sz.x * 0.5, at.y - sz.y).floor(), sz), false)
			"counter":
				_draw_counter(ci, o)
			"barrels":
				_put_foot(ci, "res://art/farm/fi/barrel.png", o + Vector2(12.5, 4.0) * T)
				_put_foot(ci, "res://art/farm/fi/barrel.png", o + Vector2(12.5, 5.0) * T)
			"chair":
				var c: Vector2i = it[2]
				_put_foot(ci, "res://art/farm/fc/chair_front.png" if c.y < 7 else "res://art/farm/fc/chair_back.png", o + Vector2(c.x + 0.5, c.y + 1.0) * T)
			"table":
				var tt: Vector2i = it[2]
				_put_foot(ci, "res://art/farm/fc/table.png", o + Vector2(tt.x + 1.5, tt.y + 1.0) * T)


func _put(ci: CanvasItem, path: String, at: Vector2) -> void:
	var t := tex(path)
	if t != null:
		ci.draw_texture_rect(t, Rect2(at.floor(), t.get_size() * S), false)


func _put_foot(ci: CanvasItem, path: String, foot: Vector2) -> void:
	var t := tex(path)
	if t != null:
		var sz := t.get_size() * S
		ci.draw_texture_rect(t, Rect2(Vector2(foot.x - sz.x * 0.5, foot.y - sz.y).floor(), sz), false)


func _draw_counter(ci: CanvasItem, o: Vector2) -> void:
	var r := Rect2(o + Vector2(6, 4) * T + Vector2(-S * 2, -S * 6), Vector2(4 * T + S * 4, T + S * 4))
	ci.draw_rect(r.grow(S), Color("1d1611"))
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, S * 6)), Color("8a6a48"))
	ci.draw_rect(Rect2(r.position + Vector2(0, S * 6), Vector2(r.size.x, r.size.y - S * 6)), Color("5a4430"))
	for k in range(1, 8):
		ci.draw_rect(Rect2(r.position.x + k * r.size.x / 8.0, r.position.y + S * 7, S, r.size.y - S * 8), Color("4a3828"))
	_put_foot(ci, "res://art/farm/fc/jug.png", r.position + Vector2(S * 10, S * 4))
	_put_foot(ci, "res://art/farm/fc/plate.png", r.position + Vector2(r.size.x - S * 16, S * 5))


func _draw_hearth(ci: CanvasItem, o: Vector2) -> void:
	var h := tex("res://art/farm/fi/hearth_3.png")
	if h == null:
		ci.draw_rect(Rect2(o + Vector2(1, 1) * T, Vector2(2, 3) * T), Color("5a5250"))
		return
	var sz := h.get_size() * S
	var at := Vector2(o.x + 2.0 * T - sz.x * 0.5, o.y + 4.0 * T - sz.y).floor()
	ci.draw_texture_rect(h, Rect2(at, sz), false)
	var fire := tex("res://art/farm/fi/fire.png")
	if fire != null:
		var frame := int(Time.get_ticks_msec() / 140) % 10
		var src := Rect2(frame * 22, 0, 22, 14)
		ci.draw_texture_rect_region(fire, Rect2(at + Vector2(6, 39) * S, src.size * S), src)


func hearth_point() -> Vector2:
	return Vector2(TownLayout.INT_ORIGIN) * T + Vector2(2.0, 3.4) * T
