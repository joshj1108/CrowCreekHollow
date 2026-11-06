extends SceneTree

# Checks the treks' PixelLab art (ART-OVERHAUL-001 Stage D, TrekSystem.TREK_ART_V2) headless, in slot 9:
#   godot --path . --headless -s tools/aoh_trek_check.gd
# Every route, both trails, every clearing on them and every event that can sit there (and the flood with the
# footbridge built) is laid out by the game's own _start and _enter_clearing. For each it checks that the art
# builds (and how long that takes), that building it leaves the blocking grid exactly as laid out, that every
# wood tile got a tree or undergrowth, that no tree or undergrowth reaches more than PATH_REACH art px over the
# trail, an exit or an event's tiles (or OPEN_REACH over open ground), and that the event and destination pieces
# keep off the trail outside their own tiles. Prints PASS or FAIL per case.
var fails := 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		fails += 1
	print(("PASS " if ok else "FAIL ") + what)


func _overlap(m, r: Rect2, own: Array, reach_path: int, reach_open: int) -> String:
	var Tl = m.Tile
	for ty in range(floori(r.position.y / 16), floori((r.end.y - 1) / 16) + 1):
		for tx in range(floori(r.position.x / 16), floori((r.end.x - 1) / 16) + 1):
			if tx < 0 or ty < 0 or tx >= m.CAVE_W or ty >= m.CAVE_H or own.has(Vector2i(tx, ty)):
				continue
			var k: int = m.cave[ty][tx]
			var reach := 999
			if k in [Tl.PATH, Tl.EXIT, Tl.CAVE_EXIT, Tl.FENCE]:
				reach = reach_path
			elif k in [Tl.GRASS, Tl.FALLOW]:
				reach = reach_open
			var o := r.intersection(Rect2(tx * 16, ty * 16, 16, 16))
			if o.size.x > reach and o.size.y > reach:
				return "%d,%d" % [tx, ty]
	return ""


func _initialize() -> void:
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._on_title_start("new", 9)
	var trek = m.trek
	var art := TrekArt.new()
	_check(art.ok, "trek art loads (%d pieces, %d kinds)" % [art.pieces.size(), art.kinds.size()])
	var cases := 0
	var worst := 0
	var grid_changed := 0
	var unplaced := 0
	var wood := 0
	var bad_up: Array = []
	var bad_event: Array = []
	var tall_event := 0
	for id in trek.ROUTES:
		for trail in ["marked", "dark"]:
			var steps: Array = trek.ROUTES[id][trail]
			for c in steps.size():
				for ev in ["", "tree", "flood", "flood_dry", "cairn", "hollow", "fog", "lights", "crows"]:
					m.day = maxi(int(trek.ROUTES[id]["from"]), 1)
					trek.works = {"footbridge": true} if ev == "flood_dry" else {}
					trek._start(id)
					trek.dark = trail == "dark"
					trek.route = steps
					trek.events = []
					for k in steps.size():
						trek.events.append("")
					trek.clearing = c
					trek.events[c] = "flood" if ev == "flood_dry" else ev
					trek._enter_clearing()
					if ev != "" and trek._spec()["event"] < 0:
						continue
					cases += 1
					var before: int = m.cave.hash()
					var t0 := Time.get_ticks_usec()
					art.refresh(m, trek)
					worst = maxi(worst, Time.get_ticks_usec() - t0)
					if m.cave.hash() != before:
						grid_changed += 1
					unplaced += art.unplaced
					wood += art._shade.size()
					var where := "%s %s clearing %d (layout %d) %s" % [id, trail, c, steps[c], ev]
					for u in art._upright:
						var r := Rect2(u[1], art.pieces[u[0]].size)
						if not art.fits(m, r):
							bad_up.append(where)
							break
					for e in art._event_items(m, trek, trek._spec(), trek._event()):
						var r: Rect2 = e[2]
						var own: Array = []
						if e[3] == "log":
							own = trek.blocked
						var hit := _overlap(m, r, own, art.PATH_REACH, 999 if e[3] in ["hollowtree", "sign", "cairn"] else art.OPEN_REACH)
						if hit != "":
							bad_event.append("%s: %s over %s" % [where, e[3], hit])
						if e[3] == "hollowtree" and _overlap(m, r, [], 999, art.OPEN_REACH) != "":
							tall_event += 1
	print("cases: %d, wood tiles: %d" % [cases, wood])
	_check(cases > 100, "every route, trail, clearing and event laid out (%d)" % cases)
	_check(worst < 50000, "slowest build %.1f ms (under 50)" % (worst / 1000.0))
	_check(grid_changed == 0, "the blocking grid is unchanged by the art (%d changed)" % grid_changed)
	_check(unplaced == 0, "every wood tile has a tree or undergrowth (%d bare)" % unplaced)
	_check(bad_up.is_empty(), "no tree or undergrowth hides the trail or open ground (%d clearings)%s" % [bad_up.size(), "" if bad_up.is_empty() else ": " + str(bad_up.slice(0, 4))])
	_check(bad_event.is_empty(), "event and destination pieces keep off the trail (%d)%s" % [bad_event.size(), "" if bad_event.is_empty() else ": " + str(bad_event.slice(0, 6))])
	print("note: the hollow tree reaches over open ground above it in %d cases (it stands beside the trail, as before)" % tall_event)
	trek.active = false
	print("trek check: %d failure(s)" % fails)
	quit(1 if fails > 0 else 0)
