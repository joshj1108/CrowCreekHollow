extends SceneTree

# Checks the cave's PixelLab art (ART-OVERHAUL-001 Stage C, CAVE_ART_V2) headless, in slot 9:
#   godot --path . --headless -s tools/aoh_cave_check.gd -- days=60
# For each day's cave: how long the picture takes to build, that every cell found a tile, that nothing stood on
# the rock reaches more than FRONT_REACH art px onto the floor, that nothing hung or set at a face's foot sits
# over a walkable tile (beyond the face's own 5 px foot), and that no dressing sits on or beside ore. Then it
# breaks a copper and an iron node through the game's own _finish_cave_ore and checks the picture follows.
# Prints PASS or FAIL per case.
var fails := 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		fails += 1
	print(("PASS " if ok else "FAIL ") + what)


func _initialize() -> void:
	var opt := {"days": "60"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m._on_title_start("new", 9)
	var art := CaveArt.new()
	_check(art.ok, "cave art loads (%d tiles, %d sets)" % [art.tiles.size(), art.sets])
	var worst := 0
	var bad_front := 0
	var bad_back := 0
	var by_ore := 0
	for d in range(1, int(opt["days"]) + 1):
		m.day = d
		m._generate_cave()
		var t0 := Time.get_ticks_usec()
		art._refresh(m)
		worst = maxi(worst, Time.get_ticks_usec() - t0)
		var walk := func(x: int, y: int) -> bool:
			if x < 0 or y < 0 or x >= m.CAVE_W or y >= m.CAVE_H:
				return false
			return not [m.Tile.WALL, m.Tile.ORE_COPPER, m.Tile.ORE_IRON].has(m.cave[y][x])
		for it in art._front:
			var src: Rect2 = it[0]
			var at: Vector2 = it[1]
			var base_tile := Vector2i(floori((at.x + src.size.x * 0.5) / 16.0), floori((at.y + src.size.y - 1) / 16.0))
			var reach := base_tile.y * 16 - at.y
			if walk.call(base_tile.x, base_tile.y) or reach > art.FRONT_REACH:
				bad_front += 1
		for it in art._back:
			var src: Rect2 = it[0]
			var at: Vector2 = it[1]
			var tile := Vector2i(floori((at.x + src.size.x * 0.5) / 16.0), floori(at.y / 16.0))
			# judge by the piece's anchor: hung pieces by their top, foot pieces and ferns by their base
			var low: bool = src in art.kinds.get("fern", []) or src in art.kinds.get("foot", [])
			if low:
				tile.y = floori((at.y + src.size.y - 4) / 16.0)
			if walk.call(tile.x, tile.y):
				bad_back += 1
				if bad_back < 6:
					print("  on floor: ", src, " at ", at, " tile ", tile, " low ", low)
			var below := at.y + src.size.y - (tile.y + 1) * 16
			if below > (3 if low else 5):
				bad_back += 1
				if bad_back < 6:
					print("  over the floor by ", below, ": ", src, " tile ", tile)
	_check(worst < 60000, "slowest picture build %.1f ms (under 60)" % (worst / 1000.0))
	_check(bad_front == 0, "front pieces stand on rock and reach at most %d px onto the floor (%d bad)" % [art.FRONT_REACH, bad_front])
	_check(bad_back == 0, "hung and ore pieces sit on rock tiles (%d bad)" % bad_back)
	# Mining: break one copper and one iron node; the picture must lose that ore piece and the cell becomes floor.
	m.day = 1
	m._enter_cave()
	for kind in [m.Tile.ORE_COPPER, m.Tile.ORE_IRON]:
		var found := Vector2i(-1, -1)
		for y in m.CAVE_H:
			for x in m.CAVE_W:
				if m.cave[y][x] == kind and found.x < 0:
					found = Vector2i(x, y)
		if found.x < 0:
			_check(false, "day 1 has ore of kind %d" % kind)
			continue
		art._refresh(m)
		var before := art._back.size()
		m.mining._finish_cave_ore(found)
		art._refresh(m)
		var still := false
		for it in art._back:
			var at: Vector2 = it[1]
			if Rect2(found.x * 16, found.y * 16, 16, 16).has_point(at + it[0].size * 0.5):
				still = true
		_check(m.cave[found.y][found.x] == m.Tile.FLOOR and not still and art._back.size() < before,
				"mined %s at %s: floor, its ore piece gone" % ["copper" if kind == m.Tile.ORE_COPPER else "iron", found])
	print("aoh_cave_check: %d failures" % fails)
	quit(1 if fails > 0 else 0)
