extends SceneTree

# FARMHOUSE-INTERIOR-001: checks the redesigned farmhouse interior through the real game. Run headless, from the
# project folder:
#   godot --path . --headless -s tools/interior_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). For each house stage it
# checks that every open floor tile is reachable from the door, that no shut room can be walked into, and that the
# bed, desk, hearth, cooler, washstand and exit can each be faced from a free tile; it presses Space at each and
# checks what happens (the fire takes firewood, the bed sleeps after 18:00, the desk and cooler open their panels,
# the washstand tidies); it buys the furniture, saves, loads and checks nothing is lost or doubled and each piece
# stands solid; it checks the window states (open, rain, frost, shut at night, the shutters, boarded and patched),
# the candles per stage and that the fire's light is on only while it burns. Prints PASS or FAIL per case and a
# total; the exit code is the number of failures. With `-- dump=PATH` it also writes each stage's tile grid and the
# tiles reachable from the door as JSON (with every piece of furniture bought), for the review's collision maps.

const SLOT := 9

var m: MainGame
var started := false
var failures := 0
var path := ""


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	path = TitleMenu.slot_path(SLOT)
	SaveSystem.delete_save(path)
	m._on_title_start("new", SLOT)
	m.set_process(false)
	_run()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


func _set_stage(s: int) -> void:
	m.house_stage = s
	m._build_interior()


func _kind(t: Vector2i) -> int:
	return m.interior[t.y][t.x]


func _free(t: Vector2i) -> bool:
	return t.x >= 0 and t.y >= 0 and t.x < m.INT_W and t.y < m.INT_H and not m.BLOCKING.has(_kind(t))


# Every tile reachable on foot from where you come in.
func _reach() -> Dictionary:
	var seen := {m.INT_ENTRY: true}
	var queue: Array = [m.INT_ENTRY]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = t + d
			if _free(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen


func _faceable(kind: int, reach: Dictionary) -> bool:
	for y in m.INT_H:
		for x in m.INT_W:
			if m.interior[y][x] != kind:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if reach.has(Vector2i(x, y) + d):
					return true
	return false


# Stand on an interior tile facing `dir` and press Space.
func _press(at: Vector2i, dir: Vector2) -> void:
	m.inside = true
	m.player.position = m._tile_center(m.INT_ORIGIN.x + at.x, m.INT_ORIGIN.y + at.y)
	m.player.facing = dir
	m._tool_press = false
	m._interact()


func _run() -> void:
	m.cooler_built = true
	_dump()
	for s in 4:
		_set_stage(s)
		var reach := _reach()
		var pockets: Array = []
		var trespass: Array = []
		for y in m.INT_H:
			for x in m.INT_W:
				var t := Vector2i(x, y)
				if not _free(t):
					continue
				var shut := (InteriorArt.PARLOR.has_point(t) and not m.interior_art.room_open(2)) or (InteriorArt.STUDY.has_point(t) and not m.interior_art.room_open(3))
				if shut and reach.has(t):
					trespass.append(t)
				elif not shut and not reach.has(t):
					pockets.append(t)
		_check("stage %d: every open floor tile is reachable from the door" % s, pockets.is_empty(), str(pockets))
		_check("stage %d: no shut room can be walked into" % s, trespass.is_empty(), str(trespass))
		_check("stage %d: the exit is reachable" % s, reach.has(m.INT_EXIT))
		_check("stage %d: the wake spot beside the bed is free and reachable" % s, reach.has(m.BED_INTERIOR + Vector2i(0, 1)))
		for k in [MainGame.Tile.BED, MainGame.Tile.DESK, MainGame.Tile.FIREPLACE, MainGame.Tile.COOLER]:
			_check("stage %d: %s can be faced" % [s, MainGame.Tile.keys()[k]], _faceable(k, reach))
		_check("stage %d: the washstand is there and faceable only once the wash room opens" % s,
			_faceable(MainGame.Tile.STATION, reach) == (s >= 2))

	# Pressing Space at each fixture (Restored house).
	_set_stage(3)
	m.inventory["firewood"] = 1
	m.fire_hours = 0.0
	_press(m.FIREPLACE_IX + Vector2i(1, 1), Vector2.UP)
	_check("space at the hearth feeds the fire", m.fire_hours > 0.0 and int(m.inventory["firewood"]) == 0)
	m.diary_found = true
	_press(m.DESK_IX + Vector2i(0, 1), Vector2.UP)
	_check("space at the desk opens the desk", m.open_tab == "Desk")
	m._close_panel()
	_press(m.COOLER_INTERIOR + Vector2i(0, 1), Vector2.UP)
	_check("space at the cooler opens the cooler", m.open_tab == "Cooler")
	m._close_panel()
	m.tidied_day = -1
	_press(m.STATION_IX + Vector2i(0, 1), Vector2.UP)
	_check("space at the washstand tidies the house", m.tidied_day == m.day)
	var slept: int = m.stats["slept"]
	m.clock = (20.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.current_hour = 20.0
	_press(m.BED_INTERIOR + Vector2i(0, 1), Vector2.UP)
	_check("space at the bed after 18:00 sleeps", int(m.stats["slept"]) == slept + 1)
	m.transitioning = false

	# Furniture: bought, saved, loaded: nothing lost or doubled, each piece solid on its spot.
	for id in m.estate.FURNITURE:
		m.estate.furniture[id] = true
	_set_stage(3)
	var solid := _solid_count()
	m.saver._save_game()
	m.estate.furniture = {}
	_set_stage(0)
	var loaded := m.saver._load_game()
	m._build_interior()
	_check("furniture: the save loads", loaded)
	_check("furniture: every piece is still bought after loading", m.estate.furniture.size() == m.estate.FURNITURE.size(), str(m.estate.furniture.keys()))
	_check("furniture: the house stage comes back", m.house_stage == 3)
	_check("furniture: nothing doubled (same solid tiles after loading and rebuilding twice)", _solid_count() == solid)
	m._build_interior()
	_check("furniture: rebuilding again changes nothing", _solid_count() == solid)
	for id in ["dresser", "armchair", "clock", "bookshelf"]:
		_check("furniture: the %s stands solid on its spot" % id, _kind(m.estate._furniture_spot(id)) == MainGame.Tile.TABLE)
	var reach := _reach()
	var cut: Array = []
	for y in m.INT_H:
		for x in m.INT_W:
			var t := Vector2i(x, y)
			if _free(t) and not reach.has(t):
				cut.append(t)
	_check("furniture: no walkway is blocked by the furniture", cut.is_empty(), str(cut))
	# A spot saved before the redesign that is now inside a wall or furniture puts you by the bed.
	m.saved_inside = true
	m.has_saved_pos = true
	m.saved_pos = m._tile_center(m.INT_ORIGIN.x + 6, m.INT_ORIGIN.y + 3)   # the dresser
	m._restore_saved_state()
	_check("an old saved spot inside the furniture wakes you by the bed", m._player_tile() == m.INT_ORIGIN + m.BED_INTERIOR + Vector2i(0, 1), str(m._player_tile() - m.INT_ORIGIN))

	# Windows, from the season, the weather, the hour and the stage.
	var fx: InteriorFX = m.interior_fx
	_set_stage(3)
	_window("summer noon, sunny: open, with a breeze", 244, 12.0, "sunny", func(st: Dictionary) -> bool: return st["open"] and st["breeze"] > 0.0 and not st["frost"])
	_window("spring noon, sunny: open", 183, 12.5, "sunny", func(st: Dictionary) -> bool: return st["open"])
	_window("summer noon, rain: shut, rain on the glass, curtains still", 244, 12.0, "rain", func(st: Dictionary) -> bool: return not st["open"] and st["rain"] and st["breeze"] == 0.0)
	_window("summer noon, downpour: shut", 244, 12.0, "downpour", func(st: Dictionary) -> bool: return not st["open"] and st["rain"])
	_window("winter noon: shut, frosted", 62, 12.0, "cloudy", func(st: Dictionary) -> bool: return not st["open"] and st["frost"])
	_window("summer 22:00: shut for the night", 244, 22.0, "sunny", func(st: Dictionary) -> bool: return not st["open"])
	_window("autumn noon, fog: shut, fog beyond", 20, 12.0, "fog", func(st: Dictionary) -> bool: return not st["open"] and st["fog"])
	m.projects.decor[Vector2i(-50, -50)] = "shutters"
	m.projects.barred_day = 244
	_window("shutters barred: shown shut through the glass", 244, 21.0, "sunny", func(st: Dictionary) -> bool: return st["shutters"] and not st["open"])
	m.projects.decor.erase(Vector2i(-50, -50))
	m.projects.barred_day = -1
	_set_stage(0)
	_window("Decrepit: boarded, never open", 244, 12.0, "sunny", func(st: Dictionary) -> bool: return st["stage"] == 0 and not st["open"])
	_window("Decrepit in rain: the rag curtain stirs in the draft", 244, 12.0, "rain", func(st: Dictionary) -> bool: return st["breeze"] > 0.0)
	_set_stage(1)
	_window("Boarded: one board, never open", 244, 12.0, "sunny", func(st: Dictionary) -> bool: return st["stage"] == 1 and not st["open"])

	# CCH-CONSOLIDATED-003 Phase C: the clipping audit, the bed against the wall, the sprites themselves.
	_audit()

	# Candles and the fire's light.
	var counts := []
	for s in 4:
		_set_stage(s)
		counts.append(m.interior_art.candles().size())
	_check("candles: more as the house is restored (1, 3, 6, 7)", counts == [1, 3, 6, 7], str(counts))
	_set_stage(3)
	m.inside = true
	m.current_hour = 21.0
	m.fire_hours = 0.0
	fx._process(0.016)
	_check("candles: each lit candle has its own light at night", _lit_candles(fx) == 7)
	_check("fire: no firelight while the hearth is cold", not fx.fire_light.enabled)
	m.fire_hours = 5.0
	fx._process(0.016)
	_check("fire: the hearth's light is on while it burns", fx.fire_light.enabled and fx.fire_light.energy > 0.0)
	var energies := {}
	for i in 30:
		fx._process(0.05)
		energies[snappedf(fx.fire_light.energy, 0.001)] = true
	_check("fire: its light flickers", energies.size() > 5)
	m.current_hour = 12.0
	fx._process(0.016)
	_check("candles: unlit by day", _lit_candles(fx) == 0)
	m.inside = false
	fx._process(0.016)
	_check("lights: all off outside the house", not fx.fire_light.enabled and _lit_candles(fx) == 0)


# The rooms' floors along the house (tile x ranges), for "no sprite draws through a side wall".
func _room_span(t: Vector2i) -> Vector2i:
	for r in [InteriorArt.BEDROOM, InteriorArt.HALL, InteriorArt.PARLOR, InteriorArt.STUDY]:
		if (r as Rect2i).has_point(t):
			return Vector2i((r as Rect2i).position.x, (r as Rect2i).end.x)
	return Vector2i(-1, -1)


# The top of the wall's face behind a piece: three tiles above the nearest wall row over its tile.
func _face_top(t: Vector2i) -> float:
	var y := t.y - 1
	while y >= 0 and m.interior[y][t.x] != MainGame.Tile.WALL:
		y -= 1
	return float(maxi(y - (m.INT_FACE_ROWS - 1), 0)) * 16.0


func _audit() -> void:
	var fc := FileAccess.open("res://art/farm/fc/props.json", FileAccess.READ)
	var meta: Dictionary = JSON.parse_string(fc.get_as_text())
	fc.close()
	# Every piece of the furniture family: present, the size its tool measured, pixel-art clean (alpha 0 or 255),
	# nothing wider than its footprint allows.
	var bad_art: Array = []
	for key in meta:
		var name := "fc/" + str(key)
		if not FarmSprites.has(name):
			bad_art.append(name + " missing")
			continue
		var img := FarmSprites.tex(name).get_image()
		var want: Array = meta[key]["size"]
		if img.get_width() != int(want[0]) or img.get_height() != int(want[1]):
			bad_art.append("%s is %dx%d, not %s" % [name, img.get_width(), img.get_height(), str(want)])
		var opaque := 0
		var soft := 0
		for y in img.get_height():
			for x in img.get_width():
				var a := img.get_pixel(x, y).a
				if a > 0.99:
					opaque += 1
				elif a > 0.01:
					soft += 1
		if opaque == 0 or soft > 0:
			bad_art.append("%s: %d opaque, %d half-transparent pixels" % [name, opaque, soft])
		# its content touches all four edges: cropped to the art, nothing cut off by a wrong region
		var used := img.get_used_rect()
		if used.size != img.get_size():
			bad_art.append("%s: used rect %s inside %s" % [name, str(used), str(img.get_size())])
	_check("sprites: every furniture-family frame is present, measured, pixel-clean and tightly cropped", bad_art.is_empty(), str(bad_art))
	var clock: Dictionary = meta["clock_case"]
	_check("sprites: the clock's case is the size InteriorFX swings the pendulum in",
		Vector2(clock["size"][0], clock["size"][1]) == InteriorArt.CLOCK_SIZE and Vector2(clock["pivot"][0], clock["pivot"][1]) == InteriorArt.CLOCK_PIVOT and Vector2(clock["bob"][0], clock["bob"][1]) == InteriorArt.CLOCK_BOB)
	_check("sprites: the candle wicks are where the candles are", Vector2(meta["bedside"]["wick"][0], meta["bedside"]["wick"][1]) == InteriorArt.BEDSIDE_WICK and Vector2(meta["sidetable"]["wick"][0], meta["sidetable"]["wick"][1]) == InteriorArt.SIDETABLE_WICK)
	# The legacy SpriteCook and E4 furniture is no longer what the house draws.
	for id in m.estate.FURNITURE:
		_check("sprites: the bought %s is drawn from the new family" % id, id == "feather_bed" or m.estate._furniture_art(str(id)).begins_with("fc/"), m.estate._furniture_art(str(id)))

	# Each stage, with nothing bought and with everything bought (and the cooler built).
	for bought in [false, true]:
		for id in m.estate.FURNITURE:
			if bought:
				m.estate.furniture[id] = true
			else:
				m.estate.furniture.erase(id)
		for s in 4:
			_set_stage(s)
			var tag := "stage %d, %s" % [s, "all furniture" if bought else "none bought"]
			var rects: Array = m.interior_art.standing_rects()
			var overlaps: Array = []
			var through: Array = []
			var above: Array = []
			var unsolid: Array = []
			for i in rects.size():
				var a: Dictionary = rects[i]
				var ra: Rect2 = a["rect"]
				var at: Vector2i = a["at"]
				for j in range(i + 1, rects.size()):
					var b: Dictionary = rects[j]
					var rb: Rect2 = b["rect"]
					# side by side on one row: they must not overlap (one would cut into the other)
					if int(a["row"]) == int(b["row"]) and ra.position.x < rb.end.x and rb.position.x < ra.end.x:
						overlaps.append("%s@%s / %s@%s" % [a["art"], str(at), b["art"], str(b["at"])])
				var span := _room_span(at)
				if ra.position.x < span.x * 16.0 or ra.end.x > span.y * 16.0:
					through.append("%s@%s x %d-%d, room %d-%d" % [a["art"], str(at), int(ra.position.x), int(ra.end.x), span.x * 16, span.y * 16])
				if ra.position.y < _face_top(at):
					above.append("%s@%s top %d over the face's top %d" % [a["art"], str(at), int(ra.position.y), int(_face_top(at))])
				for k in int(a["tiles"]):
					var t: Vector2i = at + Vector2i(k, 0)
					if _free(t):
						unsolid.append("%s@%s" % [a["art"], str(t)])
			_check("clipping %s: no two pieces on a row overlap" % tag, overlaps.is_empty(), str(overlaps))
			_check("clipping %s: nothing draws through a side wall or partition" % tag, through.is_empty(), str(through))
			_check("clipping %s: nothing rises above its wall's face" % tag, above.is_empty(), str(above))
			_check("collision %s: every standing piece is solid where it stands" % tag, unsolid.is_empty(), str(unsolid))
			# The bed: its headboard against the north wall, no floor between them.
			var bed: Dictionary = {}
			for r in rects:
				if str(r["art"]).begins_with("fc/bed_"):
					bed = r
			var wall_behind := true
			for k in m.BED_RECT.size.x:
				wall_behind = wall_behind and m.interior[m.BED_RECT.position.y - 1][m.BED_RECT.position.x + k] == MainGame.Tile.WALL
			var head_foot: float = (bed["rect"] as Rect2).position.y + InteriorArt.BED_HEADBOARD if not bed.is_empty() else -1.0
			var floor_top := m.BED_RECT.position.y * 16.0
			_check("bed %s: drawn once, its headboard against the wall (no gap behind it)" % tag,
				not bed.is_empty() and wall_behind and head_foot >= floor_top and head_foot <= floor_top + 2.0, "headboard foot %s, floor %s" % [head_foot, floor_top])
			_check("bed %s: the feather bed shows only once bought" % tag, (str(bed.get("art", "")) == "fc/bed_feather") == (bought and s >= 1))
			# Every candle's wick stands on a piece on its row.
			var loose: Array = []
			for c in m.interior_art.candles():
				var p: Vector2 = (c["p"] as Vector2) / m.SCALE - Vector2(m.INT_ORIGIN) * 16.0
				var on := false
				for r in rects:
					var rr: Rect2 = r["rect"]
					if int(r["row"]) == int(c["row"]) and p.x >= rr.position.x and p.x < rr.end.x and p.y >= rr.position.y - 1 and p.y < rr.end.y:
						on = true
				if not on and str(c["id"]) != "table":
					loose.append(str(c["id"]))
			_check("candles %s: each stands on its piece, on that piece's row" % tag, loose.is_empty(), str(loose))
	# The furniture is left bought, as the next checks expect.
	for id in m.estate.FURNITURE:
		m.estate.furniture[id] = true


func _dump() -> void:
	var out := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("dump="):
			out = a.substr(5)
	if out == "":
		return
	var data := {"kinds": MainGame.Tile.keys(), "stages": []}
	for id in m.estate.FURNITURE:
		m.estate.furniture[id] = true
	for s in 4:
		_set_stage(s)
		var reach := _reach()
		var rows: Array = []
		for y in m.INT_H:
			var row: Array = []
			for x in m.INT_W:
				row.append([m.interior[y][x], 1 if reach.has(Vector2i(x, y)) else 0])
			rows.append(row)
		data["stages"].append(rows)
	m.estate.furniture = {}
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()


func _solid_count() -> int:
	var n := 0
	for y in m.INT_H:
		for x in m.INT_W:
			if m.interior[y][x] == MainGame.Tile.TABLE:
				n += 1
	return n


func _lit_candles(fx: InteriorFX) -> int:
	var n := 0
	for l in fx.candle_lights.values():
		if (l as PointLight2D).enabled:
			n += 1
	return n


func _window(name: String, d: int, hour: float, kind: String, ok: Callable) -> void:
	m.day = d
	m.current_hour = hour
	m.weather_kind = kind
	var st: Dictionary = m.interior_fx.window_state()
	_check("windows: " + name, ok.call(st), str(st))
