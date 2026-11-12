class_name InteriorArt
extends RefCounted

# FARMHOUSE-INTERIOR-001: the farmhouse interior's layout and its standing art, drawn for the house's repair
# stage. Everything here is derived from existing state (house_stage, the bought furniture, the cooler, wear,
# the fire, the clock and the weather); nothing new is saved. The animated parts (windows, fire, candles,
# pendulum) and the lights are InteriorFX's.
#
# The house is 24 by 14 tiles, side by side so every room's back wall is the house's north wall:
#   rows 0-2   the north wall's face (three tiles: beam, plaster between timber posts, wainscot), with a window
#              in the bedroom, the hall and the wash room (parlor)
#   x 1-6      the bedroom (CCH-CONSOLIDATED-003 Phase C): the desk and its chair in the west corner, the bedside
#              cabinet, the bed under the window with its headboard against the wall, the dresser beside it, the
#              chest at the bed's foot, the braided rug before it and a reading candle stand
#   x 7        a partition with the bedroom's doorway near the bottom
#   x 8-17     the hall: the clock corner, the crockery shelf, the cooler under the window, the stone hearth
#              (x 12-14, matching the chimney on the right of the outside), the log basket, armchair and side
#              table beside it, the rug before it with a fireside chair; the dining set; the
#              pantry corner (barrel and sack, firewood once restored) by the front wall
#   x 18       a partition with doorways to the wash room (top) and the study (bottom)
#   x 19-22    the wash room (rows 3-5, open when Patched) over a wall (rows 6-9) and the study (rows 10-12,
#              open when Restored). A room not open yet is seen through the cutaway, derelict, its doorway
#              nailed shut with planks.
#   row 13     the south wall, with the door at x 12 (the middle of the house, like the door outside), and the
#              two front windows (seen from above) either side of it, where they are on the outside.

const W := 24
const H := 14
const BEDROOM := Rect2i(1, 3, 6, 10)
const HALL := Rect2i(8, 3, 10, 10)
const PARLOR := Rect2i(19, 3, 4, 3)
const STUDY := Rect2i(19, 10, 4, 3)
const DOOR_BEDROOM := Rect2i(7, 10, 1, 2)
const DOOR_PARLOR := Rect2i(18, 4, 1, 2)
const DOOR_STUDY := Rect2i(18, 11, 1, 2)

# Windows on the north wall: left tile of two, the room, and the house stage that glazes it.
const WINDOWS := [
	{"id": "bedroom", "x": 4},
	{"id": "hall", "x": 10},
	{"id": "parlor", "x": 19},
]
# The front windows in the south wall, seen from above (left tile of two).
const FRONT_WINDOWS := [5, 16]

# Props: standing art on a tile (bottom edge on the tile's bottom, centred over `tiles`), from house stage `from`
# to `to`. `block` makes the tile solid (a TABLE tile: Space does nothing there). `floor` props lie flat and are
# drawn with the floor, under everything. `on` props stand on another piece (art pixel offset `off` from where
# they would stand on the tile) and add nothing solid. An art name with a folder ("fc/...") is that file; a bare
# name is FARMHOUSE-INTERIOR-001's (fi/). CCH-CONSOLIDATED-003 Phase C: the furniture family is fc/
# (tools/cch003_furniture.py); the house's own pieces are grouped as rooms (see the plan at the top).
const PROPS := [
	# bedroom: the desk's chair, the bedside cabinet, the chest at the bed's foot, the reading stand
	{"art": "fc/chair_back", "at": Vector2i(2, 4), "from": 1, "block": true},
	{"art": "fc/bedside", "at": Vector2i(3, 3), "from": 0, "block": true},
	{"art": "chest", "at": Vector2i(5, 5), "from": 1, "block": true},
	{"art": "fc/sidetable", "at": Vector2i(1, 6), "from": 2, "block": true},
	{"art": "crates", "at": Vector2i(6, 9), "from": 0, "to": 1, "block": true},
	# hall: the log basket beside the hearth, the side table by the armchair, the fireside
	# chair facing the fire, the pantry corner by the door (barrel and sack, a crock on it, and the firewood stacked
	# where it comes in, when restored)
	{"art": "logbasket", "at": Vector2i(15, 3), "from": 1, "block": true},
	{"art": "fc/sidetable", "at": Vector2i(17, 3), "from": 1, "block": true},
	{"art": "fc/chair_back", "at": Vector2i(14, 8), "from": 2, "block": true},
	{"art": "barrel", "at": Vector2i(9, 12), "from": 0, "block": true},
	{"art": "fc/crock", "at": Vector2i(9, 12), "from": 3, "on": true, "off": Vector2(4, -20)},
	{"art": "crates", "at": Vector2i(10, 12), "from": 0, "to": 1, "block": true},
	{"art": "fc/firewood", "at": Vector2i(11, 12), "from": 3, "block": true},
	# wash room (parlor): the linen press and the washtub (the washstand is the STATION)
	{"art": "wardrobe", "at": Vector2i(22, 3), "from": 0, "block": true},
	{"art": "washtub", "at": Vector2i(21, 5), "from": 0, "block": true},
	# study: a reading chair and candle stand beside the bookshelf, books stacked in the corner
	{"art": "fc/chair_front", "at": Vector2i(21, 10), "from": 3, "block": true},
	{"art": "fc/sidetable", "at": Vector2i(22, 10), "from": 3, "block": true},
	{"art": "fc/books", "at": Vector2i(22, 12), "from": 3, "block": true},
	{"art": "crates", "at": Vector2i(21, 11), "from": 0, "to": 2, "block": true},
	# the derelict house's litter, and a floor cushion on the hearth rug once it is a home
	{"art": "debris", "at": Vector2i(4, 11), "from": 0, "to": 0, "floor": true},
	{"art": "debris", "at": Vector2i(14, 10), "from": 0, "to": 0, "floor": true},
	{"art": "debris", "at": Vector2i(20, 12), "from": 0, "to": 2, "floor": true},
	{"art": "brokenchair", "at": Vector2i(10, 11), "from": 0, "to": 0, "floor": true},
	{"art": "brokenchair", "at": Vector2i(20, 4), "from": 0, "to": 1, "floor": true},
	{"art": "debris", "at": Vector2i(16, 6), "from": 0, "to": 0, "floor": true},
	{"art": "brokenchair", "at": Vector2i(12, 8), "from": 0, "to": 0, "floor": true},
	{"art": "debris", "at": Vector2i(2, 8), "from": 0, "to": 0, "floor": true},
	{"art": "fc/cushion", "at": Vector2i(12, 6), "from": 3, "floor": true},
]
# Wall decor hung on the north wall's face: centre x in tiles, top y in art pixels from the face's top.
const WALL_DECOR := [
	{"art": "shelf", "cx": 9.0, "y": 6, "from": 1},
	{"art": "herbs", "cx": 15.5, "y": 7, "from": 1},
	# Final Polish: the study corner over the desk: a shelf of books and the ledger (Patched), the sampler beside it
	{"art": "fc/shelf_books", "cx": 1.7, "y": 16, "from": 2},
	{"art": "fc/sampler", "cx": 3.15, "y": 8, "from": 3},
	{"art": "fc/wreath", "cx": 21.6, "y": 5, "from": 3},
]
# The bedroom's braided rug (Patched) lies at the bed's foot, its top-left on this tile; the chest at the foot of the
# bed stands on its edge (Final Polish: it lay a tile lower, alone on the bare floor).
const BED_RUG_AT := Vector2i(3, 5)
const CHAIR_TUCK := 8.0   # art px the dining chairs north of the table are drawn lower, to sit at it
# Floor damage (cells of floor_dmg.png: 0 hole, 1 crack, 2 patch, 3 stain, 4 dust). A hole is patched with new
# boards at Boarded; at Patched two patches remain, darker; at Restored the boards are all finished.
const DAMAGE := [
	{"at": Vector2i(4, 9), "kind": 0}, {"at": Vector2i(15, 9), "kind": 0}, {"at": Vector2i(13, 12), "kind": 0},
	{"at": Vector2i(10, 4), "kind": 0}, {"at": Vector2i(21, 4), "kind": 0}, {"at": Vector2i(20, 11), "kind": 0},
	{"at": Vector2i(2, 12), "kind": 1}, {"at": Vector2i(16, 11), "kind": 1}, {"at": Vector2i(11, 9), "kind": 1},
	{"at": Vector2i(5, 5), "kind": 3}, {"at": Vector2i(12, 10), "kind": 3}, {"at": Vector2i(16, 6), "kind": 3},
]
# Cobwebs: face tiles (row 0) at a room's corners, and sagging strands. `room` decides when they go: the
# bedroom's and hall's at Boarded, the wash room's and study's when the room opens. Heavy wear brings the
# first two back (WEB_WEAR), until the house is tidied again.
const WEBS := [
	{"at": Vector2i(1, 0), "kind": 0, "room": 0}, {"at": Vector2i(6, 0), "kind": 1, "room": 0},
	{"at": Vector2i(8, 0), "kind": 0, "room": 0}, {"at": Vector2i(17, 0), "kind": 1, "room": 0},
	{"at": Vector2i(15, 0), "kind": 2, "room": 0},
	{"at": Vector2i(19, 0), "kind": 0, "room": 2}, {"at": Vector2i(22, 0), "kind": 1, "room": 2},
	{"at": Vector2i(19, 7), "kind": 0, "room": 3}, {"at": Vector2i(22, 7), "kind": 1, "room": 3},
]
const WEB_WEAR := 6
# How worn the furniture looks at each stage: dusty grey-brown, then cleaner.
const STAGE_TINT := [Color(0.72, 0.7, 0.68), Color(0.84, 0.82, 0.8), Color(0.95, 0.94, 0.92), Color(1, 1, 1)]
# The room's ambient light, multiplied into the canvas tint while inside: cold and grey in the derelict house,
# warmer as it is restored.
const AMBIENT := [Color(0.78, 0.82, 0.93), Color(0.84, 0.87, 0.94), Color(0.94, 0.92, 0.9), Color(1.0, 0.95, 0.88)]
# The least light in the room at night (the canvas tint's floor), before AMBIENT: moonlight through the gaps.
const NIGHT_FLOOR := [Color(0.34, 0.36, 0.46), Color(0.33, 0.34, 0.43), Color(0.3, 0.3, 0.38), Color(0.3, 0.29, 0.34)]
# Art details measured by tools/fi001_props.py (art/farm/fi/props.json).
const HEARTH_SIZE := Vector2(34, 60)
const FIREBOX := Rect2(7, 40, 20, 13)
const MANTEL_Y := 30
# The furniture family's details, measured by tools/cch003_furniture.py (art/farm/fc/props.json).
const BEDSIDE_WICK := Vector2(7, 2)
const SIDETABLE_WICK := Vector2(4, 1)
const CLOCK_SIZE := Vector2(17, 42)
const CLOCK_PIVOT := Vector2(8, 17)
const CLOCK_BOB := Vector2(8, 31)
const BED_HEADBOARD := 8     # the bed sprite's top rows: the headboard, standing against the wall's face
const BEDROOM_SIDE := Vector2i(1, 6)
const HALL_SIDE := Vector2i(17, 3)
const STUDY_SIDE := Vector2i(22, 10)
const WALL_ART_W := 128
const WIN_SIZE := Vector2(32, 30)
const WIN_TOP := 4          # art pixels down the face to the window's top

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _stage() -> int:
	return m.house_stage


func room_open(room: int) -> bool:
	# 0 bedroom, 1 hall, 2 wash room, 3 study
	return room <= 1 or (room == 2 and _stage() >= 2) or (room == 3 and _stage() >= 3)


func _prop_shown(p: Dictionary) -> bool:
	return _stage() >= int(p.get("from", 0)) and _stage() <= int(p.get("to", 3))


# --- Layout -------------------------------------------------------------------------------------------------

# Lays out the house's tiles on m.interior (filled with WALL by the caller). The interactions keep their kinds:
# BED, DESK, STATION, COOLER, FIREPLACE, TABLE (the dining set) and EXIT.
func build() -> void:
	for r in [BEDROOM, HALL, PARLOR, STUDY]:
		m._fill_rect(r, MainGame.Tile.FLOOR)
	m._fill_rect(DOOR_BEDROOM, MainGame.Tile.FLOOR)
	if room_open(2):
		m._fill_rect(DOOR_PARLOR, MainGame.Tile.FLOOR)
	if room_open(3):
		m._fill_rect(DOOR_STUDY, MainGame.Tile.FLOOR)
	m._fill_rect(Rect2i(m.FIREPLACE_IX, Vector2i(3, 1)), MainGame.Tile.FIREPLACE)
	m._fill_rect(m.DINING_RECT, MainGame.Tile.TABLE)
	m._set_interior(m.INT_EXIT.x, m.INT_EXIT.y, MainGame.Tile.EXIT)
	if m.cooler_built:
		m._set_interior(m.COOLER_INTERIOR.x, m.COOLER_INTERIOR.y, MainGame.Tile.COOLER)
	m._fill_rect(m.BED_RECT, MainGame.Tile.BED)
	m._fill_rect(Rect2i(m.DESK_IX, Vector2i(2, 1)), MainGame.Tile.DESK)
	if room_open(2):
		m._set_interior(m.STATION_IX.x, m.STATION_IX.y, MainGame.Tile.STATION)
	for p in PROPS:
		if p.get("block", false) and _prop_shown(p):
			var at: Vector2i = p["at"]
			if m.interior[at.y][at.x] == MainGame.Tile.FLOOR:
				m.interior[at.y][at.x] = MainGame.Tile.TABLE
	# Bought furniture stands solid where it stands (never over a bed, the desk or a doorway).
	for id in m.estate.furniture:
		for t in m.estate._furniture_tiles(str(id)):
			if m.interior[t.y][t.x] == MainGame.Tile.FLOOR:
				m.interior[t.y][t.x] = MainGame.Tile.TABLE


# --- Drawing --------------------------------------------------------------------------------------------------

func _cell(pos: Vector2i) -> Rect2:
	return m._tile_rect(m.INT_ORIGIN + pos)


func _tex(name: String) -> Texture2D:
	return FarmSprites.tex(name if "/" in name else "fi/" + name)


func _sprite(ci: CanvasItem, art: String, at: Vector2, src := Rect2(), tint := Color.WHITE) -> void:
	var tex := _tex(art)
	if src.size == Vector2.ZERO:
		src = Rect2(Vector2.ZERO, tex.get_size())
	ci.draw_texture_rect_region(tex, Rect2(at.snapped(Vector2(m.SCALE, m.SCALE)), src.size * m.SCALE), src, tint)


# A sprite standing on a tile: centred over `tiles` tiles, bottom on the tile's bottom.
func _stand(ci: CanvasItem, pos: Vector2i, art: String, tiles := 1, tint := Color.WHITE, off := Vector2.ZERO) -> void:
	var cell := _cell(pos)
	var size := _tex(art).get_size() * m.SCALE
	_sprite(ci, art, Vector2(cell.position.x + (m.PX * tiles - size.x) * 0.5, cell.end.y - size.y) + off * m.SCALE, Rect2(), tint)


# The whole back pass: a dark surround, the floors and everything lying on them.
func draw_floor(ci: CanvasItem) -> void:
	var o := Vector2(m.INT_ORIGIN) * m.PX
	ci.draw_rect(Rect2(o - Vector2(m.PX, m.PX) * 4, Vector2(W + 8, H + 8) * m.PX), Color("0b0807"))
	var s := _stage()
	var floor_tex := _tex("floor_%d" % s)
	for y in H:
		for x in W:
			var kind: int = m.interior[y][x]
			if kind == MainGame.Tile.WALL and not _locked_door(Vector2i(x, y)):
				continue
			var pos := Vector2i(x, y)
			var cell := _cell(pos)
			ci.draw_texture_rect_region(floor_tex, cell, Rect2(posmod(x, 2) * 16, posmod(y, 2) * 16, 16, 16))
	# Damage, patches and stains.
	for d in DAMAGE:
		var kind := int(d["kind"])
		var at: Vector2i = d["at"]
		var cell := _cell(at)
		var src_kind := kind
		var tint := Color.WHITE
		if kind == 0:
			if s == 1:
				src_kind = 2
			elif s == 2:
				if (at.x + at.y) % 3 != 0:
					continue
				src_kind = 2
				tint = Color(0.82, 0.78, 0.74)
			elif s == 3:
				continue
		elif kind == 1 and s >= 2:
			continue
		elif kind == 3 and s >= 2:
			continue
		ci.draw_texture_rect_region(_tex("floor_dmg"), cell, Rect2(src_kind * 16, 0, 16, 16), tint)
	# Dust along the walls in the derelict house, and in any house left to wear.
	if s <= 1 or m.wear >= WEB_WEAR:
		for x in [2, 6, 9, 16, 20]:
			ci.draw_texture_rect_region(_tex("floor_dmg"), _cell(Vector2i(x, 3)), Rect2(64, 0, 16, 16), Color(1, 1, 1, 0.8 if s == 0 else 0.5))
	# The hearth's stone slab before the fire, sooty and cracked at first.
	_draw_hearth_slab(ci)
	# The hall rug from Boarded, the bedroom's braided rug from Patched.
	if s >= 1:
		# The hearth rug, centred on RUG_RECT (it lies within it, so it never runs under a wall or the hearth).
		var rr: Rect2i = m.RUG_RECT
		var area := Rect2(_cell(rr.position).position, Vector2(rr.size) * m.PX)
		var rug := _tex("fc/rug").get_size() * m.SCALE
		_sprite(ci, "fc/rug", area.get_center() - rug * 0.5, Rect2(), Color(1, 1, 1) if s >= 3 else Color(0.82, 0.78, 0.76))
	if s >= 2:
		_sprite(ci, "rug_bed", _cell(BED_RUG_AT).position)
	for p in PROPS:
		if p.get("floor", false) and _prop_shown(p):
			var at: Vector2i = p["at"]
			var cell := _cell(at)
			var size := _tex(str(p["art"])).get_size() * m.SCALE
			_sprite(ci, str(p["art"]), cell.get_center() - size * 0.5, Rect2(), STAGE_TINT[0] if int(p.get("from", 0)) == 0 else Color.WHITE)
	# Shadow where the floor meets a wall's face or a side wall: two art pixels, soft.
	var shade := Color(0, 0, 0, 0.32)
	for y in H:
		for x in W:
			if m.interior[y][x] == MainGame.Tile.WALL:
				continue
			var cell := _cell(Vector2i(x, y))
			if y > 0 and m.interior[y - 1][x] == MainGame.Tile.WALL:
				ci.draw_rect(Rect2(cell.position, Vector2(cell.size.x, m.SCALE * 2)), shade)
				ci.draw_rect(Rect2(cell.position + Vector2(0, m.SCALE * 2), Vector2(cell.size.x, m.SCALE * 2)), Color(0, 0, 0, 0.14))
			if x > 0 and m.interior[y][x - 1] == MainGame.Tile.WALL:
				ci.draw_rect(Rect2(cell.position, Vector2(m.SCALE * 2, cell.size.y)), Color(0, 0, 0, 0.22))
			if x < W - 1 and m.interior[y][x + 1] == MainGame.Tile.WALL:
				ci.draw_rect(Rect2(Vector2(cell.end.x - m.SCALE, cell.position.y), Vector2(m.SCALE, cell.size.y)), Color(0, 0, 0, 0.18))


func _draw_hearth_slab(ci: CanvasItem) -> void:
	var s := _stage()
	var left := _cell(m.FIREPLACE_IX + Vector2i(0, 1))
	var r := Rect2(left.position + Vector2(m.SCALE * 4, 0), Vector2(m.PX * 3 - m.SCALE * 8, m.SCALE * 7))
	var stone := Color("6a6a66").lerp(Color("2e2c2c"), 0.6 if s == 0 else (0.3 if s == 1 else 0.0))
	ci.draw_rect(r.grow(m.SCALE), Color("1d1611"))
	ci.draw_rect(r, stone)
	for k in range(1, 4):
		var x := r.position.x + r.size.x * k / 4.0
		ci.draw_rect(Rect2(Vector2(snappedf(x, m.SCALE), r.position.y), Vector2(m.SCALE, r.size.y)), stone.darkened(0.35))
	ci.draw_rect(Rect2(r.position, Vector2(r.size.x, m.SCALE)), stone.lightened(0.18))
	if s == 0:
		# spilled ash and a cracked slab
		for k in 9:
			ci.draw_rect(Rect2(r.position + Vector2(m.SCALE * (3 + k * 3 + (k % 2)), m.SCALE * (2 + k % 3)), Vector2(m.SCALE, m.SCALE)), Color("8a8580"))
		for k in 5:
			ci.draw_rect(Rect2(r.position + Vector2(r.size.x * 0.62 + m.SCALE * k, m.SCALE * (1 + k)), Vector2(m.SCALE, m.SCALE)), Color("1a1614"))


func _locked_door(pos: Vector2i) -> bool:
	return (DOOR_PARLOR.has_point(pos) and not room_open(2)) or (DOOR_STUDY.has_point(pos) and not room_open(3))


# Rows on or north of the player's are drawn behind (front false) and the rest in front, as before.
func draw_rows(ci: CanvasItem, front: bool, player_row: int) -> void:
	for y in H:
		if (y > player_row) != front:
			continue
		for x in W:
			var pos := Vector2i(x, y)
			_draw_piece(ci, pos, m.interior[y][x])
			if m.interior[y][x] == MainGame.Tile.WALL and _face_row(pos) >= 0:
				_draw_paper(ci, pos)
			m.estate._draw_furniture(ci, _cell(pos), pos)
		_draw_row_decor(ci, y)


# Wallpaper (the estate's, from Patched) over the plaster only: not the beam, the posts or the wainscot.
func _draw_paper(ci: CanvasItem, pos: Vector2i) -> void:
	var c: Color = m.estate._paper_color()
	if c.a <= 0.0:
		return
	var face := _face_row(pos)
	var cell := _cell(pos)
	var top := 4.0 if face == 0 else 0.0
	var bottom := 16.0 if face == 0 else (14.0 if face == 1 else 0.0)
	if bottom <= top:
		return
	var off := posmod(pos.x * 16, 64)
	var r := Rect2(cell.position + Vector2(0, top * m.SCALE), Vector2(cell.size.x, (bottom - top) * m.SCALE))
	if off == 0:   # leave the timber post at the tile's left uncovered
		r = Rect2(r.position + Vector2(4 * m.SCALE, 0), r.size - Vector2(4 * m.SCALE, 0))
	ci.draw_rect(r, Color(c, 0.55))
	var dot := Color(c.lightened(0.45), 0.8)
	for k in 2:
		var p := cell.position + Vector2(cell.size.x * (0.3 + 0.45 * k), (top + (bottom - top) * (0.35 + 0.3 * ((k + pos.x) % 2))) * m.SCALE)
		ci.draw_rect(Rect2(p.snapped(Vector2(m.SCALE, m.SCALE)), Vector2(m.SCALE, m.SCALE)), dot)


# Which third of the wall's face this wall tile shows (0 at the top), or -1 when it shows the wall's top.
func _face_row(pos: Vector2i) -> int:
	return m._wall_face_row(pos)


func _draw_piece(ci: CanvasItem, pos: Vector2i, kind: int) -> void:
	var s := _stage()
	var tint: Color = STAGE_TINT[s]
	match kind:
		MainGame.Tile.WALL:
			_draw_wall(ci, pos)
		MainGame.Tile.BED:
			# Drawn from its foot row, so its headboard (the sprite's top rows) rises against the wall's face.
			if pos == m.BED_INTERIOR:
				_stand(ci, pos, bed_art(), m.BED_RECT.size.x)
		MainGame.Tile.DESK:
			if pos == m.DESK_IX:
				_stand(ci, pos, "fc/desk", 2, tint)
		MainGame.Tile.STATION:
			_stand(ci, pos, "fc/wash_fine" if s >= 3 else "fc/wash", 1, tint)
		MainGame.Tile.COOLER:
			_stand(ci, pos, "fc/cooler")
		MainGame.Tile.FIREPLACE:
			if pos == m.FIREPLACE_IX:
				_stand(ci, pos, "hearth_%d" % s, 3)
				if s >= 3:
					# a pewter plate stood on the mantel, between its candles
					var plate := _tex("fc/plate").get_size()
					_sprite(ci, "fc/plate", hearth_origin() + Vector2(roundf((HEARTH_SIZE.x - plate.x) * 0.5), MANTEL_Y - plate.y + 1) * m.SCALE)
		MainGame.Tile.TABLE:
			_draw_table_piece(ci, pos, tint)
	# Props standing on this tile (solid or not), and the dining set's candle.
	for p in PROPS:
		if p["at"] == pos and not p.get("floor", false) and _prop_shown(p):
			_stand(ci, pos, str(p["art"]), 1, tint, p.get("off", Vector2.ZERO))


# The bed for the stage, or the bought feather bed (from Boarded, when its room's stage is reached).
func bed_art() -> String:
	if m.estate.furniture.has("feather_bed") and _stage() >= int(m.estate.FURNITURE["feather_bed"]["stage"]):
		return "fc/bed_feather"
	return "fc/bed_%d" % _stage()


func _draw_table_piece(ci: CanvasItem, pos: Vector2i, tint: Color) -> void:
	var d: Rect2i = m.DINING_RECT
	if not d.has_point(pos):
		return
	var r := pos - d.position
	var end_seat := r.x == 0 or r.x == d.size.x - 1
	if r.y == 0 and end_seat:
		# Pulled in to the table's far edge (Final Polish: they stood a tile away); the table, drawn after, hides
		# their legs. The tiles are the dining set's either way.
		_stand(ci, pos, "fc/chair_front", 1, tint, Vector2(0, CHAIR_TUCK))
	elif r.y == 2 and r.x == 0:
		_stand(ci, pos, "fc/table", d.size.x, tint)
		if _stage() >= 3:
			# the stoneware jug beside the candle, once the house is a home
			var jug := _tex("fc/jug").get_size() * m.SCALE
			_sprite(ci, "fc/jug", table_candle() + Vector2(m.SCALE * 7, m.SCALE * 6 - jug.y))
		# A candle in a saucer in the middle of the table (InteriorFX lights it).
		var c := table_candle()
		ci.draw_rect(Rect2(c + Vector2(-2, 3) * m.SCALE, Vector2(5, 1) * m.SCALE), Color("8a8070"))
		ci.draw_rect(Rect2(c + Vector2(-1, 0) * m.SCALE, Vector2(3, 3) * m.SCALE), Color("1d1611"))
		ci.draw_rect(Rect2(c + Vector2(0, 0) * m.SCALE, Vector2(1, 3) * m.SCALE), Color("e8dcc0") if _stage() >= 1 else Color("b8ac90"))
	elif r.y == 3 and end_seat:
		_stand(ci, pos, "fc/chair_back", 1, tint)


# The dining candle's wick, world position.
func table_candle() -> Vector2:
	var d: Rect2i = m.DINING_RECT
	var cell := _cell(d.position + Vector2i(1, 2))
	return (cell.get_center() + Vector2(0, -m.PX * 0.55)).snapped(Vector2(m.SCALE, m.SCALE))


func _draw_wall(ci: CanvasItem, pos: Vector2i) -> void:
	var cell := _cell(pos)
	var s := _stage()
	if _locked_door(pos):
		var first := DOOR_PARLOR.position if DOOR_PARLOR.has_point(pos) else DOOR_STUDY.position
		if pos == first:
			_sprite(ci, "barricade", cell.position, Rect2(), STAGE_TINT[s])
		return
	var face := _face_row(pos)
	if face < 0:
		ci.draw_texture_rect(_tex("wall_top"), cell, false, Color(1, 1, 1).lerp(Color(1.25, 1.18, 1.1), s / 3.0))
		for side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
			var n: Vector2i = pos + side
			if n.x < 0 or n.x >= W or n.y < 0 or m.interior[n.y][n.x] == MainGame.Tile.WALL:
				continue
			var rim := Rect2(cell.position, Vector2(m.SCALE, cell.size.y)) if side.x < 0 else (
				Rect2(Vector2(cell.end.x - m.SCALE, cell.position.y), Vector2(m.SCALE, cell.size.y)) if side.x > 0 else
				Rect2(cell.position, Vector2(cell.size.x, m.SCALE)))
			ci.draw_rect(rim, Color("5a4634"))
		return
	var off := posmod(pos.x * 16, WALL_ART_W)
	ci.draw_texture_rect_region(_tex("wall_%d" % s), cell, Rect2(off, face * 16, 16, 16))


# After a row's tiles: what hangs on the walls whose face ends on this row (so the row below doesn't cover it).
func _draw_row_decor(ci: CanvasItem, y: int) -> void:
	var s := _stage()
	var face_top := _cell(Vector2i(0, y - 2)).position.y   # the face's top, for a wall ending on this row
	if y == 2:
		for d in WALL_DECOR:
			if s < int(d.get("from", 0)):
				continue
			var tex := _tex(str(d["art"]))
			var x := float(m.INT_ORIGIN.x + float(d["cx"])) * m.PX - tex.get_size().x * m.SCALE * 0.5
			_sprite(ci, str(d["art"]), Vector2(x, face_top + int(d["y"]) * m.SCALE))
	for w in WEBS:
		var at: Vector2i = w["at"]
		if at.y + 2 != y or not _web_shown(int(w["room"])):
			continue
		var cell := _cell(at)
		var kind := int(w["kind"])
		var src := Rect2(kind * 16, 0, 24 if kind == 2 else 16, 16)
		var x := cell.position.x if kind != 1 else cell.end.x - 16 * m.SCALE
		_sprite(ci, "web", Vector2(x, cell.position.y + 4 * m.SCALE), src)


func _web_shown(room: int) -> bool:
	var s := _stage()
	if room <= 1:
		return s == 0 or (s <= 1 and room == 0 and m.wear >= 3) or (s <= 2 and m.wear >= WEB_WEAR)
	return not room_open(room)


# --- Where InteriorFX draws -------------------------------------------------------------------------------------

func window_rect(x: int) -> Rect2:
	var cell := _cell(Vector2i(x, 0))
	return Rect2(cell.position + Vector2(0, WIN_TOP * m.SCALE), WIN_SIZE * m.SCALE)


func hearth_origin() -> Vector2:
	var cell := _cell(m.FIREPLACE_IX)
	var size := HEARTH_SIZE * m.SCALE
	return Vector2(cell.position.x + (m.PX * 3 - size.x) * 0.5, cell.end.y - size.y).snapped(Vector2(m.SCALE, m.SCALE))


func bedside_wick() -> Vector2:
	return _stand_origin(Vector2i(3, 3), "fc/bedside") + BEDSIDE_WICK * m.SCALE


func sidetable_wick(pos: Vector2i) -> Vector2:
	return _stand_origin(pos, "fc/sidetable") + SIDETABLE_WICK * m.SCALE


func _stand_origin(pos: Vector2i, art: String) -> Vector2:
	var cell := _cell(pos)
	var size := _tex(art).get_size() * m.SCALE
	return Vector2(cell.position.x + (m.PX - size.x) * 0.5, cell.end.y - size.y).snapped(Vector2(m.SCALE, m.SCALE))


# The candles, each lit from dusk while it stands: world position of the wick, and `row`, the house row of the
# piece it stands on (tools/interior_test.gd checks each wick is on that piece). Every candle stands on a piece that is there at that stage (the bedside cabinet from Decrepit, the
# hall's side table from Boarded, the bedroom's stand from Patched, the study's from Restored).
func candles() -> Array:
	var s := _stage()
	var d: Rect2i = m.DINING_RECT
	var out: Array = [{"p": table_candle(), "id": "table", "row": d.position.y + 2}]
	if s >= 1:
		out.append({"p": bedside_wick(), "id": "bedside", "row": 3})
		out.append({"p": sidetable_wick(HALL_SIDE), "id": "side", "row": HALL_SIDE.y})
	if s >= 2:
		out.append({"p": sidetable_wick(BEDROOM_SIDE), "id": "bedroom_side", "row": BEDROOM_SIDE.y})
		var h := hearth_origin()
		out.append({"p": h + Vector2(5, MANTEL_Y - 4) * m.SCALE, "id": "mantel_l", "stick": true, "row": m.FIREPLACE_IX.y})
		out.append({"p": h + Vector2(HEARTH_SIZE.x - 6, MANTEL_Y - 4) * m.SCALE, "id": "mantel_r", "stick": true, "row": m.FIREPLACE_IX.y})
	if s >= 3:
		out.append({"p": sidetable_wick(STUDY_SIDE), "id": "study", "row": STUDY_SIDE.y})
	return out


# --- The clipping audit's view of the layout (tools/interior_test.gd) -----------------------------------------

# Every standing sprite drawn at the current stage with what is bought: its art, its tile row, and its rectangle
# in art pixels from the house's top-left (x along the house, y down from the top of the north wall's face).
func standing_rects() -> Array:
	var out: Array = []
	var s := _stage()
	var dr: Rect2i = m.DINING_RECT
	for y in H:
		for x in W:
			var pos := Vector2i(x, y)
			match m.interior[y][x]:
				MainGame.Tile.BED:
					if pos == m.BED_INTERIOR:
						out.append(_rect_of(pos, bed_art(), m.BED_RECT.size.x))
				MainGame.Tile.DESK:
					if pos == m.DESK_IX:
						out.append(_rect_of(pos, "fc/desk", 2))
				MainGame.Tile.STATION:
					out.append(_rect_of(pos, "fc/wash_fine" if s >= 3 else "fc/wash", 1))
				MainGame.Tile.COOLER:
					out.append(_rect_of(pos, "fc/cooler", 1))
				MainGame.Tile.FIREPLACE:
					if pos == m.FIREPLACE_IX:
						out.append(_rect_of(pos, "hearth_%d" % s, 3))
			if dr.has_point(pos):
				var r := pos - dr.position
				var end_seat := r.x == 0 or r.x == dr.size.x - 1
				if r.y == 0 and end_seat:
					var chair := _rect_of(pos, "fc/chair_front", 1)
					chair["rect"] = (chair["rect"] as Rect2).grow_individual(0, -CHAIR_TUCK, 0, CHAIR_TUCK)
					out.append(chair)
				elif r.y == 2 and r.x == 0:
					out.append(_rect_of(pos, "fc/table", dr.size.x))
				elif r.y == 3 and end_seat:
					out.append(_rect_of(pos, "fc/chair_back", 1))
			for p in PROPS:
				if p["at"] == pos and not p.get("floor", false) and not p.get("on", false) and _prop_shown(p):
					out.append(_rect_of(pos, str(p["art"]), 1))
	for id in m.estate.furniture:
		var f: Dictionary = m.estate.FURNITURE[id]
		if id in ["painting", "feather_bed"] or s < int(f["stage"]):
			continue
		out.append(_rect_of(f["spot"], m.estate._furniture_art(str(id)), int(m.estate.E4_TILES.get(id, 1))))
	return out


# A standing sprite's rectangle as _stand draws it (the art pixel grid; the screen snaps to the same grid).
func _rect_of(pos: Vector2i, art: String, tiles: int) -> Dictionary:
	var size := _tex(art).get_size()
	var x := pos.x * 16.0 + (16.0 * tiles - size.x) * 0.5
	var y := (pos.y + 1) * 16.0 - size.y
	return {"art": art, "row": pos.y, "at": pos, "tiles": tiles, "rect": Rect2(Vector2(roundf(x), y), size)}
