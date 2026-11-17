class_name NearwoodSystem
extends RefCounted

# CCH-WOODWORK-001: the Nearwood, a small cutting grove up the timber trail behind the farmhouse. See DESIGN.md,
# "Workbench, anvil and timber". It is the farm's steady source of logs: a short solo daytime walk with no walker,
# no lantern oil and nothing hunting you, a ring of marked timber trees round a clearing, and the trail home.
#
# - The way in is the gap in the trees north of the farmhouse, by the forester's sign (GATE_TILES, inner farm
#   tiles): Space there, and again to go. Each way costs TRAVEL_HOURS, with the needs that go with them.
# - It is an away place like the village: `in_cave` is set as well, so the farm's layers, visitors and weather
#   hide, and `active` tells MainGame's map, drawing and movement to ask this script.
# - Each marked tree ('o' in MAP) is felled with any hatchet (the same chopping as the farm's grove trees, so a
#   better hatchet fells it in fewer strokes) and gives LOGS logs (+1 from Forestry LOGS_BONUS_LEVEL), with the
#   farm's hardwood chance for a copper hatchet or better, and XP_FELL Forestry XP. A felled tree leaves a stump
#   and stands again REGROW_DAYS later, so the grove is never used up.
# - A trip here is not a trek: it doesn't hold the wood back (TrekSystem's trek days are untouched) and no story
#   beat waits here.
# Saved under `nearwood`: the day each tree was felled and how many trips.

var m: MainGame
const FarmArt := preload("res://scripts/farm_art.gd")

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTToTTTToTTTTTToTTTToTTTT",
	"TTTT,,,,,,,,,TTT,,,,,,,,,TTT",
	"TTT,,,,,,,,,,,,,,,,,,,,,,,TT",
	"TTTo,,,,,,,,,,,,,,,,,,,,,oTT",
	"TTT,,,,,,,,,TTTTT,,,,,,,,,TT",
	"TTTT,,,,,,,TTTTTTT,,,,,,,TTT",
	"TTTTTo,,,,TTTTTTTTT,,,,oTTTT",
	"TTTTTTT,,,,TTTTTTT,,,,TTTTTT",
	"TTTTTTTT,,,,,,,,,,,,,TTTTTTT",
	"TTTTTTTTTTp,,=====,,,TTTTTTT",
	"TTTTTTTTTTT,,,===,,TTTTTTTTT",
	"TTTTTTTTTTTTT,===TTTTTTTTTTT",
	"TTTTTTTTTTTTTT===TTTTTTTTTTT",
	"TTTTTTTTTTTTTT=E=TTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]
const W := 28
const H := 18
const ARRIVE := Vector2i(15, 14)          # on the trail, a few steps in from the way home
const SIGN_AT := Vector2i(10, 12)         # the forester's log pile and sign at the clearing's foot
# The farm side: the gap in the trees north of the farmhouse, and the sign beside it (inner farm tiles).
const GATE_TILES := [Vector2i(50, 1), Vector2i(51, 1)]
const FARM_SIGN := Vector2i(49, 2)
const HOME_IX := Vector2i(50, 2)          # where you come back: just inside the gap, facing down into the yard
const TRAVEL_HOURS := 0.25                # each way, up the trail
const OPEN_FROM := 1                      # the trail is there from the first day
const ENTER_UNTIL := 17.0                 # no setting out after this: the light goes early under the trees
const LATE_HOUR := 18.0                   # a word that it's time to head home
const LOGS := 4                           # logs a timber tree gives
const LOGS_BONUS_LEVEL := 5               # Forestry that gets one more log from each (less of the trunk wasted)
const REGROW_DAYS := 4                    # a felled tree stands again this many days later
const FOREST_SHADE := Color(0.86, 0.9, 0.84)   # the grove's light, a little greener and dimmer than the yard
const DEEP_TINT := Color(0.5, 0.55, 0.56)     # the scenery wood, darker than the marked timber, so it never reads as a target
const BLAZE := Color("e0d6b8")                 # the forester's pale blaze on a marked trunk
const CONFIRM_SECONDS := 4.0

var active := false
var felled := {}               # saved: tree tile (Vector2i) -> the day it was felled
var trips := 0                 # saved: times you've walked up
var front: Node2D
var confirm_until := 0.0
var late_said := -1
var _mini: Array = []


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	front = Node2D.new()
	front.z_index = 1
	front.visible = false
	front.draw.connect(_draw_front)
	m.add_child(front)


# --- The map --------------------------------------------------------------------------------------------------

func _char(t: Vector2i) -> String:
	if t.x < 0 or t.y < 0 or t.x >= W or t.y >= H:
		return "T"
	return str(MAP[t.y][t.x])


func trees() -> Array:
	var out: Array = []
	for y in H:
		for x in W:
			if str(MAP[y][x]) == "o":
				out.append(Vector2i(x, y))
	return out


func standing(t: Vector2i) -> bool:
	return _char(t) == "o" and not felled.has(t)


func standing_count() -> int:
	var n := 0
	for t in trees():
		if standing(t):
			n += 1
	return n


# The tile kind MainGame's movement reads. A stump is open ground.
func _kind(t: Vector2i) -> int:
	match _char(t):
		",":
			return MainGame.Tile.GRASS
		"=", "E":
			return MainGame.Tile.PATH
		"o":
			return MainGame.Tile.TREE if standing(t) else MainGame.Tile.GRASS
		"p":
			return MainGame.Tile.ROCK
	return MainGame.Tile.TREE


func minimap_tiles() -> Array:
	if _mini.is_empty():
		for y in H:
			var row: Array = []
			for x in W:
				var c := _char(Vector2i(x, y))
				row.append(MainGame.Tile.GRASS if c == "," or c == "o" else (MainGame.Tile.PATH if c == "=" or c == "E" else MainGame.Tile.TREE))
			_mini.append(row)
	return _mini


func _bounds() -> void:
	m.player.min_pos = m._tile_center(1, 1)
	m.player.max_pos = m._tile_center(W - 2, H - 2)
	m.camera.limit_left = 0
	m.camera.limit_top = 0
	m.camera.limit_right = W * m.PX
	m.camera.limit_bottom = H * m.PX


func _unstick() -> void:
	m.player.position = m._tile_center(ARRIVE.x, ARRIVE.y)
	m._set_bounds()
	m._show_message("You step back onto the trail.")


# --- The farm side: the gap in the trees and its sign -------------------------------------------------------------

func blocks_farm(t: Vector2i) -> bool:
	return t - Vector2i(m.BORDER_X, m.BORDER_Y) == FARM_SIGN


func _try_gate(tile: Vector2i) -> bool:
	if active or m.inside or m.in_cave:
		return false
	var ix := tile - Vector2i(m.BORDER_X, m.BORDER_Y)
	if not GATE_TILES.has(ix) and ix != FARM_SIGN:
		return false
	if m.current_hour >= ENTER_UNTIL:
		m._show_message("The timber trail into the Nearwood. It's getting dark under the trees; it can wait for morning.")
		return true
	var now := Time.get_ticks_msec() / 1000.0
	if now > confirm_until:
		confirm_until = now + CONFIRM_SECONDS
		var axe := "" if int(m.tool_tier["hatchet"]) > 0 else " You'll want a hatchet."
		m._show_message(m._fill_controls("The timber trail into the Nearwood, where the marked trees are cut for logs. A quarter hour's walk each way. %d of %d trees standing.%s {hand} again to go." % [standing_count(), trees().size(), axe]))
		return true
	confirm_until = 0.0
	go(true)
	return true


# --- Going up and back -------------------------------------------------------------------------------------------

func go(up: bool) -> void:
	if m.transitioning:
		return
	if DisplayServer.get_name() == "headless" or m.fade_rect == null:
		if up:
			_arrive()
		else:
			_go_home()
		return
	m.transitioning = true
	m.player.paused = true
	m.card_label.add_theme_color_override("font_color", Color("e8dcc0"))
	await m._fade_to(Color(0.03, 0.05, 0.03, 1.0), 0.5, Tween.TRANS_SINE)
	if up:
		_arrive()
		await m._show_card("Up the timber trail, under the firs.", 0.3, 0.9, 0.3)
	else:
		_go_home()
		await m._show_card("Down the trail, and the farmhouse roof through the trees.", 0.3, 0.8, 0.3)
	await m._fade_to(Color(0.03, 0.05, 0.03, 0.0), 0.6, Tween.TRANS_SINE)
	m.player.paused = false
	m.transitioning = false


func _arrive() -> void:
	m.play_sfx("step", 0.03)
	m._close_panel()
	m.fishing._stop_fishing("")
	_regrow()
	active = true
	m.in_cave = true
	m.inside = false
	m.foes = []
	m.woodwork.pass_hours(TRAVEL_HOURS)
	trips += 1
	m.player.position = m._tile_center(ARRIVE.x, ARRIVE.y)
	m.player.facing = Vector2.UP
	m._set_bounds()
	_show(true)
	m.queue_redraw()
	var n := standing_count()
	var axe := "" if int(m.tool_tier["hatchet"]) > 0 else " You have no hatchet: make one at the workbench first."
	if trips == 1:
		m._show_message("The Nearwood. The trees with a pale blaze cut into the bark are marked for felling; the rest are left to stand. %d marked trees standing. Face one with the axe and keep chopping. The trail home is behind you.%s" % [n, axe], true)
	else:
		m._show_message("The Nearwood. %d of %d marked trees standing. The trail home is behind you.%s" % [n, trees().size(), axe])


func _go_home() -> void:
	m.play_sfx("step", 0.03)
	m._close_panel()
	active = false
	m.in_cave = false
	m.inside = false
	m.foes = []
	m.woodwork.pass_hours(TRAVEL_HOURS)
	var home := m._world_tile(HOME_IX.x, HOME_IX.y)
	m.player.position = m._tile_center(home.x, home.y)
	m.player.facing = Vector2.DOWN
	m._set_bounds()
	_show(false)
	m.queue_redraw()
	m._show_message("Back down the timber trail to the farm. Hew the logs into planks at the workbench.")


# The day ends while away (bed, a collapse, a fall): you wake at home. Nothing else happens.
func _abort() -> void:
	if not active:
		return
	active = false
	_show(false)


func _show(on: bool) -> void:
	if front != null:
		front.visible = on


# Felled trees stand again REGROW_DAYS after they fell.
func _regrow() -> void:
	for t in felled.keys():
		if m.day - int(felled[t]) >= REGROW_DAYS:
			felled.erase(t)


func _on_step() -> void:
	if _char(m._player_tile()) == "E":
		go(false)


# --- Each frame there ---------------------------------------------------------------------------------------------

func _update(_delta: float) -> void:
	if not active:
		return
	front.queue_redraw()
	if m.current_hour >= LATE_HOUR and late_said != m.day:
		late_said = m.day
		m._show_message("The light is going under the trees. Time to take the trail home.")


func _tint(darkness: float) -> Color:
	return m._sky_tint(darkness) * FOREST_SHADE


# --- Felling --------------------------------------------------------------------------------------------------

func _interact(tile: Vector2i) -> void:
	if standing(tile):
		if m._need_tool("axe"):
			m.farm._start_harvest("log", tile)
			m._show_message("You start on the marked tree. Keep at it.")
		return
	if _char(tile) == "o":
		var left := REGROW_DAYS - (m.day - int(felled.get(tile, m.day)))
		m._show_message("A fresh stump. Another marked tree will stand here in %d %s." % [maxi(1, left), "day" if left <= 1 else "days"])
		return
	if tile == SIGN_AT:
		m._show_message("The forester's sign: \"Fell only the blazed trees. Leave the rest to stand.\" %d of %d marked trees are standing." % [standing_count(), trees().size()])
		return
	if _char(tile) == "T":
		m._show_message("Unmarked. These are left to stand; the blazed trees are for cutting.")


func chop_chance() -> float:
	return m.CHOP_BASE_CHANCE + m.TOOL_TIER_CHANCE * float(m.tool_tier["hatchet"])


func logs_per_tree() -> int:
	return LOGS + (1 if m.progression._level("Forestry") >= LOGS_BONUS_LEVEL else 0)


func _finish(tile: Vector2i) -> void:
	if not standing(tile):
		return
	felled[tile] = m.day
	var logs := logs_per_tree()
	m.materials["wood"] += logs
	var found := "%d logs" % logs
	if int(m.tool_tier["hatchet"]) >= 3 and randf() < m.HARDWOOD_CHANCE:
		m.materials["hardwood"] += 1
		found += ", 1 hardwood"
	m.stats["felled"] += 1
	m.play_sfx("tree_fall", 0.04)
	m.progression._grant_xp("Forestry", m.XP_FELL)
	m._show_message("The tree comes down. +%s. +%d Forestry XP. %d marked trees left standing." % [found, m.XP_FELL, standing_count()])
	m.queue_redraw()


# --- Drawing (placeholder art built from the farm's own sprites) --------------------------------------------------

func _view() -> Rect2i:
	var view := m.get_viewport_rect().size / m.camera.zoom
	var top_left := m.camera.get_screen_center_position() - view * 0.5
	return Rect2i(floori(top_left.x / m.PX) - 1, floori(top_left.y / m.PX) - 1, ceili(view.x / m.PX) + 3, ceili(view.y / m.PX) + 5)


func _draw_map() -> void:
	var r := _view()
	var ci: CanvasItem = m
	ci.draw_rect(Rect2(Vector2(r.position) * m.PX, Vector2(r.size) * m.PX), Color("1c2418"))
	for y in range(maxi(0, r.position.y), mini(H, r.end.y)):
		for x in range(maxi(0, r.position.x), mini(W, r.end.x)):
			var t := Vector2i(x, y)
			var cell: Rect2 = m._tile_rect(t)
			var c := _char(t)
			m._draw_grass(t, cell)
			if c == "=" or c == "E":
				ci.draw_rect(cell, Color(0.42, 0.34, 0.24, 0.55))
			elif c == "T":
				ci.draw_rect(cell, Color(0.02, 0.04, 0.02, 0.62))
			elif c == "o" and not standing(t):
				ci.draw_texture_rect(FarmSprites.tex("prop_stump"), cell, false)
				if m.day - int(felled[t]) >= REGROW_DAYS - 1:
					_sapling(ci, cell)
	_draw_standing(ci, r, false)


func _draw_front() -> void:
	if active:
		_draw_standing(front, _view(), true)


# Trees, the scenery wood and the sign, by row: rows south of the farmer go over them, the rest behind.
func _draw_standing(ci: CanvasItem, r: Rect2i, in_front: bool) -> void:
	var player_row := floori(m.player.position.y / m.PX)
	for y in range(maxi(0, r.position.y), mini(H, r.end.y + 2)):
		if (y > player_row) != in_front:
			continue
		for x in range(maxi(0, r.position.x - 1), mini(W, r.end.x + 1)):
			var t := Vector2i(x, y)
			var c := _char(t)
			var cell: Rect2 = m._tile_rect(t)
			if c == "T":
				_draw_wood(ci, t, cell)
			elif c == "o" and standing(t):
				ci.draw_texture_rect(FarmSprites.tex("tree_fir_%d" % (FarmArt.hash_int(x, y, 19) % int(m.TREE_KINDS["fir"]))),
					Rect2(cell.get_center().x - m.PX, cell.end.y - m.PX * 3.0, m.PX * 2.0, m.PX * 3.0), false)
				# The forester's blaze: a pale notch cut into the trunk at chest height, and a mark at its foot.
				var blaze := Rect2(cell.get_center().x - m.PX * 0.12, cell.end.y - m.PX * 0.62, m.PX * 0.24, m.PX * 0.3)
				ci.draw_rect(blaze.grow(2.0), Color("1d1611"))
				ci.draw_rect(blaze, BLAZE)
			elif c == "p":
				var pile := FarmSprites.tex("concept/w4_props_logpile")
				ci.draw_texture_rect(pile, Rect2(cell.position.x - m.PX * 0.1, cell.end.y - pile.get_height() * m.SCALE, pile.get_width() * m.SCALE, pile.get_height() * m.SCALE), false)
				var sign := FarmSprites.tex("concept/w3c_props_signpost")
				ci.draw_texture_rect(sign, Rect2(cell.end.x - m.PX * 0.35, cell.end.y - sign.get_height() * m.SCALE, sign.get_width() * m.SCALE, sign.get_height() * m.SCALE), false)


# The unmarked wood, kept apart from the marked timber so it never reads as something to cut: darker, mostly oaks
# and dead trees, thinned to every other tile deep in, and only low undergrowth on a tile whose crown would hang
# over the clearing (open ground within two tiles above it).
func _draw_wood(ci: CanvasItem, t: Vector2i, cell: Rect2) -> void:
	var over_open := false
	for dy in [1, 2]:
		for dx in [-1, 0, 1]:
			if _char(t + Vector2i(dx, -dy)) != "T":
				over_open = true
	if over_open:
		ci.draw_texture_rect(FarmSprites.tex("thicket_0"), cell, false, DEEP_TINT)
		return
	var edge := false
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1)]:
		if _char(t + d) != "T":
			edge = true
	if not edge and (t.x + t.y) % 2 == 1:
		return
	var kind: String = ["oak", "dead", "oak", "fir", "oak", "dead"][FarmArt.hash_int(t.x, t.y, 31) % 6]
	var n: int = int(m.TREE_KINDS[kind])
	var nudge := float(FarmArt.hash_int(t.x, t.y, 13) % 7 - 3) * m.SCALE
	ci.draw_texture_rect(FarmSprites.tex("tree_%s_%d" % [kind, FarmArt.hash_int(t.x, t.y, 19) % n]),
		Rect2(cell.get_center().x - m.PX + nudge, cell.end.y - m.PX * 3.0, m.PX * 2.0, m.PX * 3.0), false, DEEP_TINT)


func _sapling(ci: CanvasItem, cell: Rect2) -> void:
	var foot := Vector2(cell.get_center().x + m.PX * 0.22, cell.end.y - m.PX * 0.2)
	ci.draw_line(foot, foot + Vector2(0, -m.PX * 0.4), Color("1d1611"), 4.0)
	ci.draw_line(foot, foot + Vector2(0, -m.PX * 0.4), Color("5a7a3a"), 2.0)


# On the farm: the forester's sign by the gap in the trees, drawn on the decor layer.
func draw_farm(layer: CanvasItem) -> void:
	if m.in_cave or m.inside:
		return
	var t := m._world_tile(FARM_SIGN.x, FARM_SIGN.y)
	var cell: Rect2 = m._tile_rect(t)
	var sign := FarmSprites.tex("concept/w3c_props_signpost")
	var s := Vector2(sign.get_width(), sign.get_height()) * m.SCALE
	layer.draw_texture_rect(sign, Rect2(Vector2(cell.get_center().x - s.x * 0.5, cell.end.y - s.y), s), false)
	var trail := m._tile_rect(m._world_tile(GATE_TILES[0].x, GATE_TILES[0].y + 1))
	layer.draw_rect(Rect2(trail.position + Vector2(0, m.PX * 0.55), Vector2(m.PX * 2.0, m.PX * 0.45)), Color(0.42, 0.34, 0.24, 0.45))


# --- Saving ---------------------------------------------------------------------------------------------------------

func _to_save() -> Dictionary:
	var f: Array = []
	for t in felled:
		f.append([t.x, t.y, int(felled[t])])
	return {"felled": f, "trips": trips}


# An older save has never been up the trail: every tree stands.
func _from_save(d: Variant) -> void:
	active = false
	felled = {}
	trips = 0
	if typeof(d) != TYPE_DICTIONARY:
		return
	trips = int(d.get("trips", 0))
	var f: Variant = d.get("felled", [])
	if typeof(f) == TYPE_ARRAY:
		for e in f:
			if typeof(e) == TYPE_ARRAY and e.size() >= 3:
				var t := Vector2i(int(e[0]), int(e[1]))
				if _char(t) == "o":
					felled[t] = int(e[2])
