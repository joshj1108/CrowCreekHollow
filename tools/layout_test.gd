extends SceneTree

# Checks the farm layout (FARM-001, the concept farm) in the real game: that everything is reachable on foot and
# that each place does what it should. Run headless, from the project folder:
#   godot --path . --headless -s tools/layout_test.gd
# It starts a new game in save slot 9 (never 1-3) and deletes that save when done. Prints PASS or FAIL per case and a
# total; the exit code is the number of failures.
#   - Reach: a flood fill over the game's own blocking from the porch reaches all four fields, the well, the stand's
#     front, the cave approach, the dock, every walker's spot, the arrival spot, the pedlar's spot, every grove and
#     orchard tree, brush and rock; nothing east of the closed gate.
#   - Walks: the farmer is driven with the move keys along the flood fill's path, porch -> fields -> road -> stand ->
#     cave approach, and must arrive.
#   - Places: the stand opens Trade at 10:00, the well opens its panel, the cave mouth enters the mining cave and
#     leaving lands on the approach, the door enters the house and leaving lands on the porch, planting on field
#     one, the fields open at Farming 2, 5 and 9 (the last once the house is Patched), a cast from the dock, a walker
#     at the gate and coming home to the road, a windfall in the autumn orchard, and chopping a grove tree.

const SLOT := 9

var m: MainGame
var started := false
var failures := 0
var path := ""
var B := Vector2i.ZERO


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	if started:
		return false
	started = true
	_main()
	return false


func _main() -> void:
	path = TitleMenu.slot_path(SLOT)
	SaveSystem.delete_save(path)
	m._on_title_start("new", SLOT)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	B = Vector2i(m.BORDER_X, m.BORDER_Y)
	for i in 5:
		await process_frame
	_reach_checks()
	await _walk_checks()
	await _place_checks()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, ("  (" + detail + ")") if detail != "" and not ok else ""])


func _w(x: int, y: int) -> Vector2i:
	return Vector2i(x, y) + B


func _walkable(t: Vector2i) -> bool:
	return m._in_bounds(t) and not m.BLOCKING.has(m._kind_at(t)) and m._kind_at(t) != m.Tile.DOOR \
		and m._kind_at(t) != m.Tile.CAVE_MOUTH and m._kind_at(t) != m.Tile.WATER


func _porch_front() -> Vector2i:
	return _w(m.HOUSE_DOOR_IX, m.HOUSE_DOOR_IY + 1)


# Every tile reachable from the porch, with the step it came from.
func _flood(from: Vector2i) -> Dictionary:
	var came := {from: from}
	var queue: Array = [from]
	while not queue.is_empty():
		var t: Vector2i = queue.pop_front()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = t + d
			if not came.has(n) and _walkable(n):
				came[n] = t
				queue.append(n)
	return came


func _beside(reach: Dictionary, t: Vector2i) -> bool:
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if reach.has(t + d):
			return true
	return false


func _reach_checks() -> void:
	var reach := _flood(_porch_front())
	for p in [["one", m.PLOT_ONE], ["two", m.PLOT_TWO], ["three", m.PLOT_THREE], ["four", m.PLOT_FOUR]]:
		var r: Rect2i = p[1]
		var all := true
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				all = all and reach.has(_w(x, y))
		_check("reach: every tile of field %s" % p[0], all)
	_check("reach: the well", _beside(reach, _w(m.WELL_IX.x, m.WELL_IX.y + 1)))
	_check("reach: the stand's front", reach.has(_w(m.STALL_IX + 1, m.STALL_IY + 2)))
	var cave: Vector2i = m._cave_mouth_tile()
	_check("reach: the cave approach", reach.has(cave + Vector2i.DOWN), str(cave))
	var dock := 0
	for y in m.INNER_H:
		for x in m.INNER_W:
			if FarmLayout.TERRAIN[y][x] == "k" and reach.has(_w(x, y)):
				dock += 1
	_check("reach: the whole dock", dock == 8, "%d of 8" % dock)
	var edges := 0
	for e in m.pond_edges:
		if _beside(reach, e):
			edges += 1
	_check("reach: fishing spots on the pond", edges >= 20, "%d edges" % edges)
	for id in m.trek.ROUTES:
		var w: Vector2i = m.trek._walker_tile(id)
		_check("reach: walker spot for %s" % id, reach.has(w) or _beside(reach, w), str(w - B))
	_check("reach: home from a trek", reach.has(m.HOMESTEAD_ARRIVE))
	_check("reach: the pedlar's spot", reach.has(_w(DailyHappenings.PEDLAR_SPOT.x, DailyHappenings.PEDLAR_SPOT.y)))
	for g in m.GROVE_SPOTS:
		_check("reach: grove tree %s" % str(g), m._kind_at(_w(g.x, g.y)) == m.Tile.TREE and _beside(reach, _w(g.x, g.y)))
	var orchard := 0
	for o in m.ORCHARD_TREES:
		orchard += int(_beside(reach, _w(o.x, o.y)))
	_check("reach: all six orchard trees", orchard == 6, "%d" % orchard)
	var spots := 0
	for s in m.BRUSH_SPOTS + m.ROCK_SPOTS + m.THICKET_SPOTS:
		spots += int(reach.has(_w(s.x, s.y)))
	_check("reach: brush, rock and thicket spots", spots == (m.BRUSH_SPOTS + m.ROCK_SPOTS + m.THICKET_SPOTS).size())
	var east := 0
	for t in reach:
		var ix: Vector2i = t - B
		if (ix.x >= 59 and ix.y >= 30 and ix.y <= 37) or ix.x < 0 or ix.y < 0 or ix.x >= m.INNER_W or ix.y >= m.INNER_H:
			east += 1
	_check("the east gate is closed (nothing reachable past it or the border)", east == 0, "%d tiles" % east)
	print("reach: %d tiles from the porch" % reach.size())


# --- Walking with the move keys -----------------------------------------------------------------------------

func _route(from: Vector2i, to: Vector2i) -> Array:
	var came := _flood(from)
	if not came.has(to):
		return []
	var out: Array = [to]
	while out[0] != from:
		out.push_front(came[out[0]])
	return out


func _steer(target: Vector2, max_frames := 120) -> bool:
	var held: Array = []
	var last := Vector2.INF
	var still := 0
	for i in max_frames:
		var d: Vector2 = target - m.player.position
		if d.length() < m.PX * 0.15:
			break
		for k in held:
			Input.action_release(k)
		held.clear()
		if d.x > m.PX * 0.08: held.append("move_right")
		elif d.x < -m.PX * 0.08: held.append("move_left")
		if d.y > m.PX * 0.08: held.append("move_down")
		elif d.y < -m.PX * 0.08: held.append("move_up")
		for k in held:
			Input.action_press(k)
		await process_frame
		if m.player.position.distance_to(last) < 0.01:
			still += 1
			if still > 20:
				break
		else:
			still = 0
		last = m.player.position
	for k in held:
		Input.action_release(k)
	await process_frame
	return m.player.position.distance_to(target) < m.PX * 0.3


func _walk(name: String, to: Vector2i) -> void:
	var from: Vector2i = m._player_tile()
	var route := _route(from, to)
	if route.is_empty():
		_check("walk: " + name, false, "no route from %s" % str(from - B))
		return
	var ok := true
	for t in route.slice(1):
		ok = (await _steer(m._tile_center(t.x, t.y))) and ok
		if not ok:
			break
	_check("walk: " + name, ok and m._player_tile() == to, "at %s, wanted %s" % [str(m._player_tile() - B), str(to - B)])


func _walk_checks() -> void:
	m.clock = (9.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.player.position = m._tile_center(_porch_front().x, _porch_front().y)
	await process_frame
	await _walk("porch -> field one", _w(m.PLOT_ONE.position.x, m.PLOT_ONE.position.y - 1))
	await _walk("field one -> road by the gate", m.HOMESTEAD_ARRIVE)
	await _walk("road -> the stand's front", _w(m.STALL_IX + 1, m.STALL_IY + 2))
	await _walk("stand -> the dock's end", _w(13, 30))
	await _walk("dock -> the cave approach", m._cave_mouth_tile() + Vector2i.DOWN)
	_check("walking up to the cave approach doesn't enter the cave", not m.in_cave)


# --- Each place ---------------------------------------------------------------------------------------------

func _stand(t: Vector2i, facing: Vector2) -> void:
	m.player.position = m._tile_center(t.x, t.y)
	m.player.facing = facing


func _use(tool := "") -> void:
	if tool != "":
		for i in m.HOTBAR_TOOLS.size():
			if str(m.HOTBAR_TOOLS[i]["id"]) == tool:
				m.active_slot = i
	m._tool_press = tool != ""
	m._interact()
	m._tool_press = false


func _place_checks() -> void:
	m.clock = (10.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	await process_frame
	# The stand.
	_stand(_w(m.STALL_IX + 1, m.STALL_IY + 2), Vector2.UP)
	_check("the stand is in front of the farmer", m._kind_at(m._tile_in_front()) == m.Tile.STALL)
	_use()
	await process_frame
	_check("the stand opens Trade at 10:00", m.open_tab == "Trade", "open_tab=%s" % m.open_tab)
	m._close_panel()
	await process_frame
	# The well, from the cobbles south of it.
	_stand(_w(m.WELL_IX.x, m.WELL_IX.y + 2), Vector2.UP)
	_use()
	await process_frame
	_check("the well opens its panel", m.open_tab == "Well", "open_tab=%s" % m.open_tab)
	m._close_panel()
	await process_frame
	# The cave: a step north onto the mouth goes in; leaving lands on the approach.
	var mouth: Vector2i = m._cave_mouth_tile()
	_stand(mouth + Vector2i.DOWN, Vector2.UP)
	await _steer(m._tile_center(mouth.x, mouth.y) + Vector2(0, -m.PX * 0.2), 60)
	for i in 5:
		await process_frame
	_check("the cave mouth enters the mining cave", m.in_cave)
	if m.in_cave:
		m._leave_cave()
		await process_frame
		_check("leaving the cave lands on the approach", not m.in_cave and m._player_tile() == mouth + Vector2i.DOWN, str(m._player_tile() - B))
	# ART-OVERHAUL-001 B-5: the new cave exterior is art only. The way in is still the C tile at (11, 8): walking
	# north from (11, 9) enters the cave, and leaving puts the farmer back on (11, 9).
	_check("cave art: the mouth is still the C tile at (11, 8)", mouth == _w(11, 8) and m._kind_at(_w(11, 8)) == m.Tile.CAVE_MOUTH, str(mouth - B))
	_check("cave art: (11, 9) below it is walkable", _walkable(_w(11, 9)))
	_stand(_w(11, 9), Vector2.UP)
	await process_frame
	await _steer(m._tile_center(_w(11, 8).x, _w(11, 8).y) + Vector2(0, -m.PX * 0.2), 60)
	for i in 5:
		await process_frame
	_check("cave art: walking north from (11, 9) onto (11, 8) enters the cave", m.in_cave)
	if m.in_cave:
		m._leave_cave()
		await process_frame
		_check("cave art: leaving the cave puts the farmer back on (11, 9)", not m.in_cave and m._player_tile() == _w(11, 9), str(m._player_tile() - B))
	# The house.
	_stand(_porch_front(), Vector2.UP)
	await _steer(m._tile_center(_porch_front().x, _porch_front().y - 1), 60)
	for i in 5:
		await process_frame
	_check("the door enters the farmhouse", m.inside)
	if m.inside:
		m._leave_house()
		await process_frame
		_check("leaving the house lands on the porch", not m.inside and m._player_tile() == _porch_front(), str(m._player_tile() - B))
	# Planting on field one, from the walkway north of it.
	var soil := _w(m.PLOT_ONE.position.x + 2, m.PLOT_ONE.position.y)
	_check("field one is soil from the start", m._kind_at(soil) == m.Tile.SOIL)
	_check("fields two to four start fallow", m._kind_at(_w(m.PLOT_TWO.position.x, m.PLOT_TWO.position.y)) == m.Tile.FALLOW
		and m._kind_at(_w(m.PLOT_THREE.position.x, m.PLOT_THREE.position.y)) == m.Tile.FALLOW
		and m._kind_at(_w(m.PLOT_FOUR.position.x, m.PLOT_FOUR.position.y)) == m.Tile.FALLOW)
	_stand(soil + Vector2i.UP, Vector2.DOWN)
	var seed_key: String = m.CROPS["turnip"]["seed"]
	m.inventory[seed_key] = maxi(int(m.inventory[seed_key]), 3)
	m.selected_seed = "turnip"
	var season_ok: bool = m.farm._in_season("turnip")
	_use("trowel")
	_check("planting on field one", m.crops.has(soil) or not season_ok, "season %s" % m._season_today())
	if m.crops.has(soil):
		_use("hose")
		_check("watering on field one", int(m.crops[soil].get("watered_day", -1)) == m.day or m.message_label.text != "", m.message_label.text)
	# The fields open with Farming.
	for e in [[2, "two", m.PLOT_TWO], [5, "three", m.PLOT_THREE]]:
		while m.progression._level("Farming") < int(e[0]):
			m.progression._grant_xp("Farming", 50)
		m.farm._check_unlocks()
		var r: Rect2i = e[2]
		_check("field %s opens at Farming %d" % [e[1], e[0]], m._kind_at(_w(r.position.x, r.position.y)) == m.Tile.SOIL
			and m._kind_at(_w(r.end.x - 1, r.end.y - 1)) == m.Tile.SOIL)
	while m.progression._level("Farming") < 9:
		m.progression._grant_xp("Farming", 100)
	m.farm._check_unlocks()
	var p4 := _w(m.PLOT_FOUR.position.x, m.PLOT_FOUR.position.y)
	_check("field four waits for the house to be Patched", m._kind_at(p4) == m.Tile.FALLOW)
	m.house_stage = 2
	m.farm._check_unlocks()
	_check("field four opens at Farming 9 with the house Patched", m._kind_at(p4) == m.Tile.SOIL)
	# Fishing from the dock's end.
	var dock_end := _w(13, 30)
	var water := dock_end + Vector2i.UP
	_check("water off the dock's end", m._kind_at(water) == m.Tile.WATER and m.pond_edges.has(water))
	m.fish_spots[water] = 60.0
	_stand(dock_end, Vector2.UP)
	_use("rod")
	_check("a cast from the dock", m.fishing._is_fishing())
	m.fishing._stop_fishing("")
	# A walker at the gate, then home to the road.
	var day0: int = m.day
	m.day = m.trek.EDGE_DAY
	var w: Vector2i = m.trek._walker_tile("edge")
	_check("Maren waits at the gate on day %d" % m.trek.EDGE_DAY, m.trek._waiting("edge"))
	_stand(w + Vector2i.DOWN, Vector2.UP)
	_check("talking to the walker at the gate", m.trek._try_walker(m._tile_in_front()))
	m.trek._start("edge")
	_check("the trek starts", m.trek.active)
	m.trek._end("", false)
	_check("home from the trek on the road inside the gate", not m.trek.active and m._player_tile() == m.HOMESTEAD_ARRIVE, str(m._player_tile() - B))
	# A windfall in the autumn orchard.
	var d := 1
	while m._season_today() != "Autumn" and d < 400:
		m.day = d
		d += 1
	m.forage._new_day()
	var fall := Vector2i(-1, -1)
	for t in m.forage.spots:
		if str(m.forage.spots[t]) in ["apple", "pear"]:
			fall = t
	_check("autumn windfalls under the orchard trees", fall.x >= 0, "day %d" % m.day)
	if fall.x >= 0:
		var kind := str(m.forage.spots[fall])
		var held := "apples" if kind == "apple" else "pears"
		var had := int(m.inventory[held])
		m.player.position = m._tile_center(fall.x, fall.y) + Vector2(0, m.PX)
		m.player.facing = Vector2.UP
		_use()
		_check("picking a windfall %s" % kind, int(m.inventory[held]) == had + 1)
	m.day = day0
	# Chopping a grove tree.
	var g: Vector2i = m.GROVE_SPOTS[0]
	var gt := _w(g.x, g.y)
	var reach := _flood(m.HOMESTEAD_ARRIVE)
	for dd in [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]:
		if reach.has(gt + dd):
			_stand(gt + dd, Vector2(-dd))
			break
	m.tool_tier["hatchet"] = maxi(int(m.tool_tier["hatchet"]), 1)
	_use("axe")
	_check("chopping a grove tree", m.farm._is_harvesting(), m.message_label.text)
	m.farm._stop_harvest("")
