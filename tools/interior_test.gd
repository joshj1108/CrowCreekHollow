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
