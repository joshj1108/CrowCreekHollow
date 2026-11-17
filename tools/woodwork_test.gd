extends SceneTree

# CCH-WOODWORK-001: the timber loop end to end. Run headless from the project folder:
#   godot --path . --headless -s tools/woodwork_test.gd
# Plays in save slot 9 (deleted when done; slots 1-3 are never touched). Prints PASS or FAIL for each case and a
# total; the exit code is the number of failures. Covers: a fresh game; the workbench placed from day-1 materials;
# the crude hatchet refused away from the bench and made beside it; the timber trail both ways and the time it
# costs; felling marked trees with real harvest ticks; logs; collision in the Nearwood; hewing (counts, time, XP,
# no negative logs, the batch cap, refusing away from the bench and late at night); the anvil gating copper tools
# and metal decor; the Patched repair paid in planks and recorded once; save and load of logs, planks, stations,
# felled trees, the repair log, skills and tools; regrowth; an old save without the new keys; the day ending in
# the Nearwood; the Wicker Cove gate, the NW cave mouth and Maren's edge route still standing.

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


func _set_hour(h: float) -> void:
	m.current_hour = h
	m.clock = (h - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH


func _stand(t: Vector2i, facing: Vector2) -> void:
	m.player.position = m._tile_center(t.x, t.y)
	m.player.facing = facing


# Chops at the tile in front with real harvest ticks until it falls (or gives up). Returns the ticks taken.
func _chop_down(tile: Vector2i) -> int:
	m.active_slot = _slot("axe")
	m._tool_press = true
	m.nearwood._interact(tile)
	m._tool_press = false
	var ticks := 0
	while m.farm._is_harvesting() and ticks < 400:
		m.farm._update_harvest(m.HARVEST_TICK_SECONDS)
		ticks += 1
	return ticks


func _run() -> void:
	var w := m.woodwork
	var nw := m.nearwood
	var p := m.projects
	# --- A fresh game: the bench from day-1 materials, then the first tool ---------------------------------------
	m.day = 1
	_set_hour(8.0)
	_check("fresh: no workbench, no hatchet", not w.has_station("workbench") and int(m.tool_tier["hatchet"]) == 0)
	_check("fresh: logs and planks start empty", int(m.materials["wood"]) == 0 and int(m.materials["planks"]) == 0)
	_check("guide: the workbench step comes before the hatchet", _guide_index("g_bench") >= 0 and _guide_index("g_bench") < _guide_index("g_hatchet"))
	# Gather every brush pile, as a first morning would.
	for t in m.brush.keys():
		m.mining._gather(t)
	_check("day 1: the brush gives enough for a bench, a hatchet, a lantern and the boarding", int(m.materials["sticks"]) >= 6 and int(m.materials["fiber"]) >= 7)
	var bench := m._world_tile(46, 14)
	_check("bench: the spot is open grass", p._fits("workbench", bench))
	_check("bench: can be placed with day-1 materials", p._can_place("workbench"))
	var sticks0 := int(m.materials["sticks"])
	p._confirm("workbench", bench)
	_check("bench: placed, cost paid once", w.has_station("workbench") and int(m.materials["sticks"]) == sticks0 - 4)
	_check("bench: a second can't be placed", not p._can_place("workbench"))
	_check("bench: it blocks like a placed piece", m._is_blocked_world(m._tile_center(bench.x, bench.y)))
	_stand(bench + Vector2i(0, 3), Vector2.UP)
	_check("bench: away from it, the crude hatchet is refused", not m.crafting._can_craft_tool("hatchet"))
	m.crafting._craft_tool("hatchet")
	_check("bench: refusing takes nothing", int(m.tool_tier["hatchet"]) == 0 and int(m.materials["sticks"]) == sticks0 - 4)
	_stand(bench + Vector2i(0, 1), Vector2.UP)
	_check("bench: facing it, Space opens its panel", p._try_use(bench) and m.open_tab == "Workbench")
	m._close_panel()
	_check("bench: beside it, the crude hatchet can be made", m.crafting._can_craft_tool("hatchet"))
	m.crafting._craft_tool("hatchet")
	_check("bench: crude hatchet made (a valid non-anvil tool)", int(m.tool_tier["hatchet"]) == 1)
	_check("guide: the bench step is done", m._guide_done(m.GUIDE[_guide_index("g_bench")]))

	# --- The timber trail ----------------------------------------------------------------------------------------
	var gate := m._world_tile(nw.GATE_TILES[0].x, nw.GATE_TILES[0].y)
	_stand(m._world_tile(nw.HOME_IX.x, nw.HOME_IX.y), Vector2.UP)
	_check("trail: facing the gap picks the gate tile", m._tile_in_front() == gate)
	_check("trail: the forester's sign blocks", m._is_blocked_world(m._tile_center(m._world_tile(nw.FARM_SIGN.x, nw.FARM_SIGN.y).x, m._world_tile(nw.FARM_SIGN.x, nw.FARM_SIGN.y).y)))
	nw.confirm_until = 0.0
	_check("trail: the first press only asks", nw._try_gate(gate) and not nw.active)
	var food0 := m.food
	var money0 := m.money
	_set_hour(9.0)
	nw._try_gate(gate)
	_check("trail: the second press goes up", nw.active and m.in_cave and not m.inside)
	_check("trail: a quarter hour passes", absf(m.current_hour - 9.25) < 0.01)
	_check("trail: needs go down a little, coins untouched", m.food < food0 and m.food > food0 - 3.0 and m.money == money0)
	_check("trail: arrive on open ground", m._player_tile() == nw.ARRIVE and not m._is_blocked_world(m.player.position))
	_check("trail: not counted as a trek", not m.trek.active)
	_check("grove: 8 marked trees, all standing", nw.trees().size() == 8 and nw.standing_count() == 8)
	_check("grove: every marked tree can be reached from the arrival", _all_trees_reachable())
	_check("grove: unmarked wood blocks", m._is_blocked_world(m._tile_center(0, 0)))

	# --- Felling ------------------------------------------------------------------------------------------------
	var logs0 := int(m.materials["wood"])
	var xp0 := int(m.skill_xp["Forestry"])
	var felled := 0
	var ticks_total := 0
	var hour_in := m.current_hour
	for tree in nw.trees().slice(0, 4):
		_stand(_open_side(tree), _facing_to(tree))
		if m._tile_in_front() != tree:
			continue
		var ticks := _chop_down(tree)
		ticks_total += ticks
		if not nw.standing(tree):
			felled += 1
	_check("fell: four marked trees came down with the crude hatchet", felled == 4)
	_check("fell: each gave %d logs" % nw.LOGS, int(m.materials["wood"]) == logs0 + 4 * nw.LOGS)
	_check("fell: Forestry XP for each", int(m.skill_xp["Forestry"]) >= xp0 + 4 * m.XP_FELL)
	_check("fell: a stump is open ground", not m._is_blocked_world(m._tile_center(nw.trees()[0].x, nw.trees()[0].y)))
	_check("fell: chopping a stump gives nothing", _chop_down(nw.trees()[0]) == 0 and int(m.materials["wood"]) == logs0 + 4 * nw.LOGS)
	print("   info: %d harvest ticks (real seconds) for 4 trees with the crude hatchet" % ticks_total)
	# Home down the trail.
	var exit := Vector2i(15, 16)
	m.player.position = m._tile_center(exit.x, exit.y)
	nw._on_step()
	_check("home: back on the farm", not nw.active and not m.in_cave and m._player_tile() == m._world_tile(nw.HOME_IX.x, nw.HOME_IX.y))
	_check("home: a quarter hour each way", absf(m.current_hour - (hour_in + nw.TRAVEL_HOURS)) < 0.01)

	# --- Hewing --------------------------------------------------------------------------------------------------
	var logs := int(m.materials["wood"])
	_stand(bench + Vector2i(0, 4), Vector2.UP)
	_check("hew: refused away from the bench", w.hew(1) == 0 and int(m.materials["wood"]) == logs)
	_stand(bench + Vector2i(1, 1), Vector2.UP)
	var carp0 := int(m.skill_xp["Carpentry"])
	var h0 := m.current_hour
	_check("hew: one log", w.hew(1) == 1)
	_check("hew: one log off, two planks on", int(m.materials["wood"]) == logs - 1 and int(m.materials["planks"]) == 2)
	_check("hew: takes its time", absf(m.current_hour - h0 - w.hew_minutes() / 60.0) < 0.01)
	_check("hew: trains Carpentry", int(m.skill_xp["Carpentry"]) == carp0 + m.rewards._xp(w.XP_HEW))
	_check("hew: a batch is capped at %d" % w.HEW_BATCH, w.hew(99) == w.HEW_BATCH and int(m.materials["planks"]) == 2 + w.HEW_BATCH * 2)
	m.materials["wood"] = 0
	_check("hew: no logs, nothing happens", w.hew(1) == 0 and int(m.materials["wood"]) == 0 and int(m.materials["planks"]) == 12)
	m.materials["wood"] = 3
	_set_hour(m.DAY_END_HOUR - 0.5)
	_check("hew: refused late at night", w.hew(1) == 0 and int(m.materials["wood"]) == 3)
	_set_hour(m.DAY_END_HOUR - 1.1)
	_check("hew: near the end of the day it stops short", w.hew(5) <= 1 and m.current_hour < m.DAY_END_HOUR)
	_set_hour(10.0)
	m.materials["wood"] = 20
	w.hew(5)
	w.hew(5)

	# --- Stations: what needs the anvil -------------------------------------------------------------------------
	m.progression._grant_xp("Forestry", 400)
	m.progression._grant_xp("Smithing", 2000)
	m.materials["stone"] = 40
	m.materials["copper_bar"] = 20
	m.materials["iron_bar"] = 6
	m.crafting._craft_tool("hatchet")
	_check("stone hatchet: a workbench tool, made beside the bench", int(m.tool_tier["hatchet"]) == 2)
	_check("copper hatchet: refused at the bench (anvil only)", not m.crafting._can_craft_tool("hatchet"))
	_check("copper gear: refused at the bench (anvil only)", not m.crafting._can_craft("copper_helm"))
	_check("lamp post: can't be placed without an anvil", not p._can_place("lamp") and p.needs_anvil("lamp"))
	_check("bark gear: made at the bench", m.woodwork.station_for(m.GEAR_ITEMS["bark_wrap"]["cost"]) == "workbench")
	_check("lantern: made at the bench", m._can_advance_lantern() == (m.progression._level("Bushcrafting") >= 2 and int(m.materials["wood"]) >= 4 and int(m.materials["fiber"]) >= 3))
	var anvil := m._world_tile(48, 14)
	_check("anvil: placeable with stone, bars and planks", p._can_place("anvil"))
	var planks_before_anvil := int(m.materials["planks"])
	p._confirm("anvil", anvil)
	_check("anvil: placed, planks paid", w.has_station("anvil") and int(m.materials["planks"]) == planks_before_anvil - 4)
	_stand(anvil + Vector2i(0, 1), Vector2.UP)
	_check("anvil: Space opens its panel", p._try_use(anvil) and m.open_tab == "Anvil")
	m._close_panel()
	_check("copper hatchet: forged beside the anvil", m.crafting._can_craft_tool("hatchet"))
	m.crafting._craft_tool("hatchet")
	_check("copper hatchet: made", int(m.tool_tier["hatchet"]) == 3)
	_check("lamp post: placeable once the anvil stands", p._anvil_ok("lamp"))
	_check("copper helm: forged beside the anvil", m.crafting._can_craft("copper_helm"))
	m.crafting._craft_gear("copper_helm")
	_check("copper helm: worn", str(m.equipment["head"]) == "copper_helm")

	# --- Construction with planks --------------------------------------------------------------------------------
	m.money += 0
	m.house_stage = 1
	m.progression._grant_xp("Carpentry", 600)
	m.materials["fiber"] = 20
	var planks := int(m.materials["planks"])
	_check("patched: needs planks, not logs", int(m.REPAIR_COSTS[1].get("planks", 0)) > 0 and not m.REPAIR_COSTS[1].has("wood"))
	m.materials["planks"] = 2
	_check("patched: refused without enough planks", not m._can_repair())
	m.materials["planks"] = planks
	_check("patched: can be done with hewn planks", m._can_repair())
	m._repair_house()
	_check("patched: the house is Patched", m.house_stage == 2)
	_check("patched: the planks were spent", int(m.materials["planks"]) == planks - int(m.REPAIR_COSTS[1]["planks"]))
	_check("patched: recorded once in the repair log", w.repairs.has("house_2") and int(w.repairs["house_2"]["day"]) == m.day)
	_check("repair API: a recorded repair isn't paid twice", not w.try_repair("house_2", {"planks": 1}, "Carpentry", 1, 0.0, 0))
	var p0 := int(m.materials["planks"])
	_check("repair API: a new repair goes through once", w.try_repair("test_inn_beam", {"planks": 2, "copper_bar": 1}, "Carpentry", 3, 1.0, 10) and int(m.materials["planks"]) == p0 - 2)
	_check("repair API: and never twice", not w.try_repair("test_inn_beam", {"planks": 2}, "Carpentry", 3, 1.0, 10) and int(m.materials["planks"]) == p0 - 2)
	w.repairs.erase("test_inn_beam")

	# --- Save and load ------------------------------------------------------------------------------------------
	var snap := {"wood": int(m.materials["wood"]), "planks": int(m.materials["planks"]), "stage": m.house_stage,
		"hatchet": int(m.tool_tier["hatchet"]), "head": str(m.equipment["head"]), "carp": int(m.skill_xp["Carpentry"]),
		"forestry": int(m.skill_xp["Forestry"]), "felled": nw.felled.size(), "hewn": w.hewn}
	m.saver._save_game()
	m.materials["wood"] = 0
	m.materials["planks"] = 0
	p.decor.clear()
	nw.felled.clear()
	w.repairs.clear()
	w.hewn = 0
	m.tool_tier["hatchet"] = 0
	_check("load: loads", m.saver._load_game())
	_check("load: logs and planks come back", int(m.materials["wood"]) == snap["wood"] and int(m.materials["planks"]) == snap["planks"])
	_check("load: both stations stand where they were", str(p.decor.get(bench, "")) == "workbench" and str(p.decor.get(anvil, "")) == "anvil")
	_check("load: the house repair and its record come back", m.house_stage == snap["stage"] and w.repairs.has("house_2"))
	_check("load: tools and gear come back", int(m.tool_tier["hatchet"]) == snap["hatchet"] and str(m.equipment["head"]) == snap["head"])
	_check("load: skills come back", int(m.skill_xp["Carpentry"]) == snap["carp"] and int(m.skill_xp["Forestry"]) == snap["forestry"])
	_check("load: the Nearwood's stumps come back", nw.felled.size() == snap["felled"] and not nw.active)
	_check("load: logs hewn come back", w.hewn == snap["hewn"])

	# --- Regrowth: the grove isn't used up ----------------------------------------------------------------------
	var first: Vector2i = nw.trees()[0]
	var day_felled := int(nw.felled[first])
	m.day = day_felled + nw.REGROW_DAYS - 1
	nw._regrow()
	_check("regrow: a stump is still a stump the day before", not nw.standing(first))
	m.day = day_felled + nw.REGROW_DAYS
	_set_hour(9.0)
	nw.go(true)
	_check("regrow: %d days on, every tree stands again" % nw.REGROW_DAYS, nw.standing_count() == 8)
	var logs_before := int(m.materials["wood"])
	for tree in nw.trees():
		_stand(_open_side(tree), _facing_to(tree))
		_chop_down(tree)
	_check("repeat: a full clear with the copper hatchet", nw.standing_count() == 0 and int(m.materials["wood"]) >= logs_before + 8 * nw.LOGS)

	# --- The day ending in the Nearwood ------------------------------------------------------------------------
	m._end_day("Test.")
	_check("day end in the Nearwood: you wake at home", not nw.active and not m.in_cave)
	_set_hour(10.0)
	nw.go(true)
	m._fallen()
	_check("a fall in the Nearwood: you wake at home", not nw.active and not m.in_cave)
	_set_hour(17.5)
	_stand(m._world_tile(nw.HOME_IX.x, nw.HOME_IX.y), Vector2.UP)
	nw.confirm_until = 0.0
	nw._try_gate(gate)
	nw._try_gate(gate)
	_check("trail: shut after 17:00", not nw.active)
	m.current_hour = 10.0
	nw.go(true)
	m.saver._save_game()
	var raw := _raw(path)
	_check("save: made in the Nearwood puts you at the homestead", Vector2(raw["player_pos"][0], raw["player_pos"][1]) == m._tile_center(m.HOMESTEAD_ARRIVE.x, m.HOMESTEAD_ARRIVE.y))
	nw.go(false)

	# --- An older save, without the new keys ------------------------------------------------------------------------
	m.saver._save_game()
	raw = _raw(path)
	raw.erase("woodwork")
	raw.erase("nearwood")
	raw["materials"].erase("planks")
	raw["decor"] = []
	raw["house_stage"] = 2
	raw["save_version"] = 16
	_write(path, JSON.stringify(raw))
	_check("old save: loads", m.saver._load_game())
	_check("old save: no planks", int(m.materials["planks"]) == 0)
	_check("old save: no stations", p.decor.is_empty())
	_check("old save: every Nearwood tree standing", nw.standing_count() == 8)
	_check("old save: earlier repairs kept and recorded", m.house_stage == 2 and w.repairs.has("house_1") and w.repairs.has("house_2"))
	_check("old save: tools kept", int(m.tool_tier["hatchet"]) == 3)
	_check("old save: a bench can be built at once", p._can_place("workbench") or int(m.materials["sticks"]) < 4)
	raw["woodwork"] = {"hewn": "many", "repairs": [1, 2]}
	raw["nearwood"] = {"felled": [[1, 1, 3], "x", [6, 3, "y"]], "trips": "a"}
	raw["save_version"] = SaveSystem.SAVE_VERSION
	_write(path, JSON.stringify(raw))
	_check("bad timber data: loads safely", m.saver._load_game() and nw.felled.size() <= 1 and not nw.felled.has(Vector2i(1, 1)))

	# --- Other places still stand ------------------------------------------------------------------------------
	_check("Wicker Cove: the east gate still opens the road", TownSystem.GATE_TILES.size() == 3 and m.town.open_today() or m.day < TownData.OPEN_FROM)
	_check("NW cave: the cave mouth is still on the farm", _farm_has(MainGame.Tile.CAVE_MOUTH))
	_check("Maren: the edge route still starts on day %d" % TrekSystem.EDGE_DAY, TrekSystem.ROUTES["edge"]["from"] == TrekSystem.EDGE_DAY)
	_check("trail: doesn't touch the trek clock", not _src_has("scripts/nearwood_system.gd", "trek_last") and not _src_has("scripts/nearwood_system.gd", "trek.walked"))


func _slot(id: String) -> int:
	for i in m.HOTBAR_TOOLS.size():
		if str(m.HOTBAR_TOOLS[i]["id"]) == id:
			return i
	return -1


func _guide_index(id: String) -> int:
	for i in m.GUIDE.size():
		if str(m.GUIDE[i]["id"]) == id:
			return i
	return -1


# The open tile beside a tree to chop it from (south first).
func _open_side(tree: Vector2i) -> Vector2i:
	for d in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1)]:
		var t: Vector2i = tree + d
		if not BLOCKING_TILE(t):
			return t
	return tree


func _facing_to(tree: Vector2i) -> Vector2:
	return Vector2(tree - _open_side(tree))


func BLOCKING_TILE(t: Vector2i) -> bool:
	return m._is_blocked_world(m._tile_center(t.x, t.y))


# Flood fill from the arrival over open ground: every marked tree must touch it.
func _all_trees_reachable() -> bool:
	var seen := {m.nearwood.ARRIVE: true}
	var todo: Array = [m.nearwood.ARRIVE]
	while not todo.is_empty():
		var t: Vector2i = todo.pop_back()
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var n: Vector2i = t + d
			if not seen.has(n) and n.x >= 0 and n.y >= 0 and n.x < m.nearwood.W and n.y < m.nearwood.H and not BLOCKING_TILE(n):
				seen[n] = true
				todo.append(n)
	for tree in m.nearwood.trees():
		var ok := false
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			if seen.has(tree + d):
				ok = true
		if not ok:
			print("   unreachable tree at ", tree)
			return false
	return true


func _farm_has(kind: int) -> bool:
	for row in m.map:
		if (row as Array).has(kind):
			return true
	return false


func _src_has(p: String, text: String) -> bool:
	return FileAccess.get_file_as_string("res://" + p).find(text) >= 0


func _raw(p: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _check(label: String, ok: bool) -> void:
	print("%s  %s" % ["ok  " if ok else "FAIL", label])
	if not ok:
		failures += 1
