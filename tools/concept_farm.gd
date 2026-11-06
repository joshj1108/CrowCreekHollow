extends "res://tools/env001_scene.gd"

# PLAYABLE FARM CONCEPT (owner task, 2026-11-06; zero generation, NON-PRODUCTION, opt-in). The ENV-001 harness
# (W-4 layout b, F2 fields, the VS16-P1 cabin, the game's camera, 3x scale and the locked R3-1 night) with:
#   - a mossy rock hillside across the empty north-west, built from the game's own hillside, cave_mouth, rock and
#     boulder sprites and the harness's forest trees, with a timber-framed cave mouth, a dark threshold, a worn
#     approach path to the oak crossroads, and a contact shadow along its foot;
#   - the farm stand (prop_stall) beside the mailbox, just inside the closed east gate on the road;
#   - the ground: ENV-001 terrain T and contact shadows S, plus low-frequency grass value clusters, ragged
#     path/grass edges and a small daytime-only warmth (no change at night: R3-1 is untouched).
# With `play` the window stays open and the farmer is yours (keyboard or pad, as in the game). The cave mouth enters
# the game's real mining cave, the stall opens the game's real Trade panel (06:00-18:00), the cabin door the real
# farmhouse; leaving the cave or the house puts you back at the concept's cave mouth or porch.
# Nothing in scripts/, art/farm/, DESIGN.md or the user's saves changes. The run uses test slot 8 only; the live
# farm map is overwritten in memory for the run so its hidden tiles can't fire under the concept.
#
# Play (from the repo root; close the window to quit):
#   godot --path . -s tools/concept_farm.gd -- play
#   godot --path . -s tools/concept_farm.gd -- play hour=21     (the R3-1 night; the forest shade is baked per start)
# Shots (one 1280x720 PNG, then quit):
#   godot --path . -s tools/concept_farm.gd -- at=12,11 hour=12 out=art/style_tests/CONCEPT/nw.png
# Options, on top of env001_scene.gd's: play, overview (whole farm, zoomed out), at=X,Y (inner tiles), hour=H, nofarmer, plain (the ENV-001 control
# ground: no T/S and none of the concept's ground passes; the hillside and stall stay).
# check=nav prints a scripted navigation test (house -> fields -> road/gate -> stall -> cave -> cave exit) and quits.

const CAVE_T := Vector2i(11, 8)        # the concept's cave-mouth tile (inner)
const STALL_T := Rect2i(54, 31, 3, 2)  # the stand's footprint
const PORCH_T := Vector2(45.5, 12.6)   # where the farmer stands after leaving the house
# The worn approach: from the cave mouth down past the hill's foot, then east above the orchard fence to the oak path.
const APPROACH := [Vector2i(11, 9), Vector2i(11, 10), Vector2i(11, 11), Vector2i(12, 11), Vector2i(12, 12),
	Vector2i(12, 13), Vector2i(13, 13), Vector2i(13, 14), Vector2i(14, 14), Vector2i(15, 14), Vector2i(16, 14),
	Vector2i(17, 14), Vector2i(18, 14), Vector2i(19, 14), Vector2i(20, 15), Vector2i(21, 15), Vector2i(22, 15),
	Vector2i(23, 15), Vector2i(24, 15), Vector2i(25, 16), Vector2i(26, 16), Vector2i(27, 16), Vector2i(28, 16),
	Vector2i(29, 16), Vector2i(29, 17), Vector2i(30, 17), Vector2i(19, 15), Vector2i(24, 16), Vector2i(12, 14)]

var concept_nodes: Array = []
var hidden_ui: Array = []
var hills: Array = []        # [centre x, base y, width in tiles] for the foot shadow
var state := "farm"          # farm, cave or house
var late_night: Node = null
var base_warmth := 0.0


func _on(k: String) -> bool:
	if o3.has("plain"):
		return false
	return k in ["terrain", "shadows"] or super._on(k)


func _opts() -> Dictionary:
	var o := super._opts()
	var given := Array(OS.get_cmdline_user_args()).map(func(a): return str(a).split("=")[0])
	var base := {"mode": "wide", "layout": "b", "grass": "1", "art": "f2", "house": "g7:c2", "cabin16": "1", "p1": "1"}
	for k in base:
		if not given.has(k):
			o[k] = base[k]
	if not o.has("at"):
		o["at"] = "%s,%s" % [PORCH_T.x, PORCH_T.y]
	if not o.has("out"):
		o["out"] = "art/style_tests/CONCEPT/shot.png"
	return o


func _build(main, night: bool) -> void:
	# The approach path is real path in the layout, so the ground is drawn with the harness's own path sets.
	for t in APPROACH:
		var row: String = grid[t.y]
		if row[t.x] == ".":
			grid[t.y] = row.substr(0, t.x) + "P" + row.substr(t.x + 1)
	var before := {}
	for c in main.get_children():
		before[c] = true
	super._build(main, night)
	_concept_props(main, night)
	sorted_once = false
	_sort()
	for c in main.get_children():
		if not before.has(c):
			concept_nodes.append(c)


# --- The hillside, the cave and the stand ----------------------------------------------------------------------

func _put(main, t: Texture2D, x: float, base: float, flip: bool, tint: Color) -> Sprite2D:
	var S: int = main.SCALE
	var s := Sprite2D.new()
	s.texture = t
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(S, S)
	s.flip_h = flip
	s.modulate = tint
	s.centered = false
	s.position = inner_origin + Vector2(x * px - t.get_width() * S / 2.0, base * px - t.get_height() * S)
	main.add_child(s)
	sorted.append([s, base])
	return s


func _block_rect(x0: int, y0: int, x1: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if Vector2i(x, y) != CAVE_T:
				c_block[Vector2i(x, y)] = true


func _concept_props(main, night: bool) -> void:
	var hill: Texture2D = load("res://art/farm/hillside.png")
	var mouth: Texture2D = load("res://art/farm/cave_mouth.png")
	var rocks := [load("res://art/farm/rock_0.png"), load("res://art/farm/rock_1.png"), load("res://art/farm/rock_2.png")]
	var bould := [load("res://art/farm/boulder_0.png"), load("res://art/farm/boulder_1.png"), load("res://art/farm/boulder_2.png")]
	var maple := _tex("maple.png")
	var fir := _tex("fir.png")
	var under := _tex("undergrowth.png")
	var dim := Color(0.66, 0.68, 0.7) if night else Color(0.86, 0.87, 0.85)
	# Back ridge first: two mounds set into the forest, darker (further and shaded), with trees standing on them.
	_put(main, fir, 5.0, 4.4, false, Color(0.8, 0.82, 0.82))
	_put(main, hill, 7.0, 6.2, true, dim)
	_put(main, hill, 18.2, 5.6, false, dim)
	_put(main, maple, 15.0, 3.6, true, Color(0.92, 0.9, 0.88))
	_put(main, fir, 21.4, 4.6, false, Color(0.85, 0.86, 0.86))
	_put(main, maple, 8.6, 3.2, false, Color(0.9, 0.88, 0.86))
	# The front: the main mound behind the mouth (the game's own pairing: hill one tile right of the doorway, its
	# foot four art pixels below the sill), with a lower shoulder on each side.
	# At night the rock sits a step darker than the open ground, so the hill reads as a dark mass round the black door.
	var nd := 0.8 if night else 1.0
	_put(main, hill, 12.0, 9.25, false, Color(nd, nd, nd))
	_put(main, hill, 7.4, 9.6, true, Color(0.95, 0.95, 0.94) * nd)
	_put(main, hill, 16.9, 8.9, true, Color(0.97, 0.97, 0.96) * nd)
	_put(main, mouth, 11.5, 9.25, false, Color(nd, nd, nd))
	hills = [[12.0, 9.25, 6.0], [7.4, 9.6, 6.0], [16.9, 8.9, 6.0], [7.0, 6.2, 6.0], [18.2, 5.6, 6.0]]
	# Fallen stone and brush at the foot, kept off the approach.
	for e in [[rocks[0], 8.6, 10.1], [bould[1], 9.4, 10.3], [rocks[2], 14.6, 9.9], [bould[0], 15.5, 10.0],
			[rocks[1], 19.6, 9.2], [bould[2], 4.6, 10.4], [rocks[0], 13.7, 9.5]]:
		_put(main, e[0], e[1], e[2], int(e[1] * 10.0) % 2 == 0, Color.WHITE)
	for e in [[under, 5.6, 10.6], [under, 20.6, 9.6], [under, 16.8, 10.1]]:
		_put(main, e[0], e[1], e[2], int(e[1] * 10.0) % 2 == 1, Color.WHITE)
	# Collision: the hill masses block; the doorway tile and the approach stay open.
	_block_rect(4, 4, 20, 7)
	_block_rect(5, 8, 10, 9)
	_block_rect(13, 8, 19, 8)
	_block_rect(10, 8, 10, 8)
	_block_rect(12, 8, 12, 8)
	for t in [Vector2i(8, 10), Vector2i(9, 10), Vector2i(14, 9), Vector2i(15, 9), Vector2i(19, 8), Vector2i(4, 10)]:
		c_block[t] = true
	for t in APPROACH:
		c_block.erase(t)

	# The stand: beside the mailbox, on the grass between the road and the field fence, facing the road. The dead
	# tree that stood on that spot moves one step into the forest edge.
	for e in sorted:
		var s: Sprite2D = e[0]
		if s.texture != null and s.texture.resource_path.ends_with("tree_dead_0.png"):
			s.position += Vector2(1.0 * px, -1.0 * px)
			e[1] = 32.0
	c_block.erase(Vector2i(56, 32))
	c_block.erase(Vector2i(57, 32))
	c_block[Vector2i(57, 31)] = true
	c_block[Vector2i(58, 31)] = true
	_put(main, load("res://art/farm/prop_stall.png"), STALL_T.position.x + 1.5, STALL_T.end.y + 0.0, false, Color.WHITE)
	for y in range(STALL_T.position.y, STALL_T.end.y):
		for x in range(STALL_T.position.x, STALL_T.end.x):
			c_block[Vector2i(x, y)] = true
	print("concept: hillside, cave mouth at ", CAVE_T, ", stall at ", STALL_T)


# The cabin door is a step trigger in the game (walk onto it to go in); W-4 drew it as wall.
func _blocked(p: Vector2) -> bool:
	var t := ((p - inner_origin) / px).floor()
	if _code_base(int(t.x), int(t.y)) == "D":
		return false
	return super._blocked(p)


# --- The ground (runs inside ENV-001's pass, before the chunks are written back) ---------------------------------

func _env_shadows(main, night: bool) -> void:
	super._env_shadows(main, night)
	_grass_clusters()
	_soft_edges()
	_hill_shadow(night)


func _bxy(x: float, y: float) -> Vector2i:
	return Vector2i(int((x + MARGIN) * 16.0), int((y + MARGIN) * 16.0))


func _chash(x: int, y: int) -> float:
	var h := (x * 73856093) ^ (y * 19349663)
	h = (h ^ (h >> 13)) * 1274126177
	return float((h >> 8) & 0xffff) / 65535.0


func _pathish(c: Color) -> bool:
	return c.a > 0.0 and c.r > c.g * 1.05 and c.r > c.b * 1.15


# Grass value in broad, ragged-edged clusters (three steps, a few tiles across), quieter in the calm zones.
func _grass_clusters() -> void:
	var n := FastNoiseLite.new()
	n.seed = 1106
	n.frequency = 0.0065
	n.fractal_octaves = 2
	var a := _bxy(0, 0)
	var b := _bxy(GW, GH)
	for by in range(a.y, b.y):
		for bx in range(a.x, b.x):
			var c := big.get_pixel(bx, by)
			if not _greenish(c):
				continue
			var tx := bx / 16 - MARGIN
			var ty := by / 16 - MARGIN
			if _code(tx, ty) == "T":
				continue
			var v := n.get_noise_2d(bx, by) * 2.2 + (_chash(bx, by) - 0.5) * 0.35
			var step := 0.0
			if v > 0.38:
				step = 1.0
			elif v < -0.38:
				step = -1.0
			if step == 0.0:
				continue
			var k := 0.05 if _calm(tx, ty) else 0.085
			var m := 1.0 + step * k
			big.set_pixel(bx, by, Color(c.r * m * (1.02 if step > 0 else 0.97), c.g * m, c.b * m * (0.96 if step > 0 else 1.03), c.a))


# Breaks the dual-grid's clean path outline: a pixel or two of grass creeping onto the path and of dirt worn into
# the grass, by a hash, so edges read trodden rather than cut.
func _soft_edges() -> void:
	var a := _bxy(0, 0)
	var b := _bxy(GW, GH)
	for pass_i in 2:
		var src := big.duplicate() as Image
		var p := 0.34 if pass_i == 0 else 0.16
		for by in range(a.y + 1, b.y - 1):
			for bx in range(a.x + 1, b.x - 1):
				var c := src.get_pixel(bx, by)
				var g := _greenish(c)
				var d := _pathish(c)
				if not g and not d:
					continue
				var other := Color(0, 0, 0, 0)
				for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nc := src.get_pixel(bx + o.x, by + o.y)
					if (g and _pathish(nc)) or (d and _greenish(nc)):
						other = nc
						break
				if other.a == 0.0 or _chash(bx + pass_i * 7, by) > p:
					continue
				var tx := bx / 16 - MARGIN
				var ty := by / 16 - MARGIN
				if _code(tx, ty) in ["~", "o", "W", "c"]:
					continue
				big.set_pixel(bx, by, other.darkened(0.06) if g else other)


# A soft, dithered contact shadow along each mound's foot, and a dark worn patch on the cave's threshold.
func _hill_shadow(night: bool) -> void:
	var strength := 0.55 if night else 0.7
	var spots: Array = []
	for h in hills:
		spots.append([h[0], h[1] - 0.25, h[2] * 0.5 + 0.4, 0.95, strength])
	spots.append([11.5, 9.15, 1.15, 0.55, 0.55])
	for s in spots:
		var a := _bxy(s[0] - s[2] - 0.2, s[1] - s[3] - 0.2)
		var b := _bxy(s[0] + s[2] + 0.2, s[1] + s[3] + 0.2)
		for by in range(a.y, b.y):
			for bx in range(a.x, b.x):
				var dx: float = (bx / 16.0 - MARGIN - s[0]) / s[2]
				var dy: float = (by / 16.0 - MARGIN - s[1]) / s[3]
				var r := sqrt(dx * dx + dy * dy)
				if r >= 1.0:
					continue
				var w := 1.0 - smoothstep(0.35, 1.0, r)
				if _chash(bx, by) > w * 1.15:   # dithered falloff, no smooth airbrush
					continue
				var c := big.get_pixel(bx, by)
				var m: float = s[4]
				big.set_pixel(bx, by, Color(c.r * m, c.g * m * 1.01, c.b * m * 1.06, c.a))


# --- Play mode and the checks ------------------------------------------------------------------------------------

func _finish(main, opt: Dictionary) -> void:
	_concept_map(main)
	if o3.has("play") or o3.get("check", "") == "nav":
		for c in main.get_children():
			if c is CanvasLayer and c.layer != 0 and not c.visible:
				hidden_ui.append(c)
		_watcher(main)
		if o3.has("play"):
			for c in hidden_ui:
				c.visible = true
			main._show_message("Concept farm: the cave is up the worn path to the north-west, the stand by the mailbox at the gate.")
			print("concept: play mode; close the window to quit")
			return
		await _nav_test(main)
		quit()
		return
	if o3.has("overview"):   # the whole farm in one 1280x720 frame (DOWNSCALED: about 1.1 screen px per art px)
		main.player.position = inner_origin + Vector2(GW / 2.0, GH / 2.0 + 0.5) * px
		main.player.visible = false
		var cam: Camera2D = main.camera
		for k in ["limit_left", "limit_top"]:
			cam.set(k, -100000)
		for k in ["limit_right", "limit_bottom"]:
			cam.set(k, 100000)
		cam.position_smoothing_enabled = false
		cam.zoom = Vector2.ONE * float(o3.get("zoom", "0.37"))
	await super._finish(main, opt)


# The live farm's tiles sit hidden under the concept; for the run they're replaced in memory so nothing hidden fires
# (its door, cave mouth, stall, water). Only the concept's own door, cave mouth, stall, well and water act.
func _concept_map(main) -> void:
	main.brush.clear()
	main.rocks.clear()
	for y in GH:
		for x in GW:
			var w: Vector2i = main._world_tile(x, y)
			if not main._in_bounds(w):
				continue
			var k: int = main.Tile.GRASS
			match _code_base(x, y):
				"D": k = main.Tile.DOOR
				"H": k = main.Tile.HOUSE
				"~": k = main.Tile.WATER
				"W": k = main.Tile.WELL
				"T": k = main.Tile.TREE
			main.map[w.y][w.x] = k
	var cm: Vector2i = main._world_tile(CAVE_T.x, CAVE_T.y)
	main.map[cm.y][cm.x] = main.Tile.CAVE_MOUTH
	for y in range(STALL_T.position.y, STALL_T.end.y):
		for x in range(STALL_T.position.x, STALL_T.end.x):
			var w: Vector2i = main._world_tile(x, y)
			main.map[w.y][w.x] = main.Tile.STALL


func _watcher(main) -> void:
	base_warmth = float(main.grade_mat.get_shader_parameter("warmth")) if main.grade_mat.get_shader_parameter("warmth") != null else 0.0
	for n in root.get_children():
		if n.get_script() != null and n.get("weather_dim") != null:
			late_night = n
	var w := Node.new()
	var gd := GDScript.new()
	gd.source_code = "extends Node\nvar tool\nfunc _process(_d):\n\ttool._tick()\n"
	gd.reload()
	w.set_script(gd)
	w.set("tool", self)
	w.process_priority = 1100   # after the game and the R3-1 night have set the tint
	root.add_child(w)


func _tick() -> void:
	var main = mainref
	if main == null or not is_instance_valid(main):
		return
	var now := "cave" if main.in_cave else ("house" if main.inside else "farm")
	if now != state:
		var was := state
		state = now
		var on_farm := now == "farm"
		for c in concept_nodes:
			if is_instance_valid(c):
				c.visible = on_farm
		main.self_modulate = Color(1, 1, 1, 0) if on_farm else Color.WHITE
		main.player.is_blocked = Callable(self, "_blocked") if on_farm else main._is_blocked_world
		if late_night != null:
			late_night.set_process(on_farm)
		if on_farm:
			var to: Vector2 = Vector2(CAVE_T.x + 0.5, CAVE_T.y + 1.6) if was == "cave" else PORCH_T
			main.player.position = inner_origin + to * px
		print("concept: ", was, " -> ", now, " at ", ((main.player.position - inner_origin) / px).snapped(Vector2(0.1, 0.1)) if on_farm else main._player_tile())
	if state == "cave" and not main.trek.active:
		main.canvas_modulate.color = main.CAVE_TINT
	# A little daytime warmth on the farm only, gone by dusk; the R3-1 night sets its own grade and tint after.
	if state == "farm":
		var day: float = smoothstep(7.0, 9.0, main.current_hour) * (1.0 - smoothstep(16.5, main.DUSK_HOUR, main.current_hour))
		if day > 0.0:
			var c: Color = main.canvas_modulate.color
			main.canvas_modulate.color = Color(c.r, c.g * (1.0 - 0.015 * day), c.b * (1.0 - 0.06 * day), c.a)
			main.grade_mat.set_shader_parameter("warmth", base_warmth + 0.03 * day)
	if main.current_hour >= main.DUSK_HOUR and late_night == null and not o3.has("check"):
		_night(main, o3)
		for n in root.get_children():
			if n.get_script() != null and n.get("weather_dim") != null:
				late_night = n


# check=nav: drives the farmer with the move keys along the owner's route and reports each leg, then tries the stall
# and the cave and comes back out. Prints PASS or FAIL per step.
func _nav_test(main) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	for i in 10:
		await process_frame
	var fails := 0
	var legs := [
		["porch -> fields gate", [Vector2(45.5, 13.6), Vector2(44.5, 14.5), Vector2(40.5, 17.5), Vector2(39.5, 21.0), Vector2(40.5, 23.5), Vector2(43.5, 23.5)]],
		["fields -> road", [Vector2(40.5, 23.5), Vector2(38.5, 27.0), Vector2(36.5, 31.0), Vector2(36.5, 34.5)]],
		["road -> gate", [Vector2(48.0, 34.5), Vector2(57.5, 34.5), Vector2(58.5, 34.5)]],
		["gate -> stall front", [Vector2(55.5, 34.0), Vector2(55.5, 33.3)]],
		["road -> oak crossroads", [Vector2(50.0, 34.5), Vector2(36.0, 34.5), Vector2(34.5, 30.0), Vector2(37.0, 26.0), Vector2(38.5, 22.0), Vector2(36.0, 18.0), Vector2(32.0, 17.5)]],
		["crossroads -> cave approach", [Vector2(30.5, 17.5), Vector2(29.5, 16.5), Vector2(25.0, 16.5), Vector2(20.5, 15.5), Vector2(16.0, 14.5), Vector2(13.0, 14.0), Vector2(12.5, 12.0), Vector2(11.5, 10.5), Vector2(11.5, 9.6)]],
	]
	for leg in legs:
		var ok := true
		for wp in leg[1]:
			ok = (await _steer(main, wp)) and ok
		var at: Vector2 = (main.player.position - inner_origin) / px
		var goal: Vector2 = leg[1][leg[1].size() - 1]
		var pass_ := at.distance_to(goal) < 0.6
		if leg[0] == "gate -> stall front":
			await _steer(main, Vector2(55.5, 32.0), 40)   # walk up into the stand, as a player does
			at = (main.player.position - inner_origin) / px
		fails += 0 if pass_ else 1
		print("%s  %s  (at %.1f,%.1f, wanted %.1f,%.1f)" % ["PASS" if pass_ else "FAIL", leg[0], at.x, at.y, goal.x, goal.y])
		if leg[0] == "gate -> stall front":
			main.clock = (10.0 - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
			main.player.facing = Vector2.UP
			var k: int = main._kind_at(main._tile_in_front())
			var st: bool = k == main.Tile.STALL
			fails += 0 if st else 1
			print("%s  stall in front of the farmer (kind %d)" % ["PASS" if st else "FAIL", k])
			main._interact()   # the game's own Space/A dispatch
			await process_frame
			var tr: bool = main.open_tab == "Trade"
			fails += 0 if tr else 1
			print("%s  interact opens the game's Trade panel (open_tab=%s)" % ["PASS" if tr else "FAIL", main.open_tab])
			main._close_panel()
			await process_frame
	# A step north onto the mouth: the game's own door check takes the farmer into the cave.
	await _steer(main, Vector2(11.5, 8.5))
	for i in 10:
		await process_frame
	var in_ok: bool = main.in_cave
	fails += 0 if in_ok else 1
	print("%s  cave entered (in_cave=%s, cave tile %s)" % ["PASS" if in_ok else "FAIL", main.in_cave, main._player_tile()])
	if in_ok:
		main._leave_cave()
		for i in 10:
			await process_frame
		var at: Vector2 = (main.player.position - inner_origin) / px
		var out_ok: bool = not main.in_cave and at.distance_to(Vector2(11.5, 9.6)) < 0.5 and main.player.is_blocked == Callable(self, "_blocked")
		fails += 0 if out_ok else 1
		print("%s  cave left onto the concept approach (at %.1f,%.1f)" % ["PASS" if out_ok else "FAIL", at.x, at.y])
	# Hill collision: walking north from beside the mouth must stop at the rock.
	main.player.position = inner_origin + Vector2(14.5, 10.6) * px
	await _steer(main, Vector2(14.5, 6.0), 60)
	var hy: float = ((main.player.position - inner_origin) / px).y
	var hill_ok := hy > 8.9
	fails += 0 if hill_ok else 1
	print("%s  hillside blocks (stopped at y %.2f)" % ["PASS" if hill_ok else "FAIL", hy])
	# The house door and back to the porch.
	main.player.position = inner_origin + Vector2(45.5, 13.0) * px
	await _steer(main, Vector2(45.5, 11.5), 60)
	for i in 5:
		await process_frame
	var house_ok: bool = main.inside
	print("%s  farmhouse entered" % ("PASS" if house_ok else "FAIL"))
	fails += 0 if house_ok else 1
	if house_ok:
		main._leave_house()
		for i in 5:
			await process_frame
		var at: Vector2 = (main.player.position - inner_origin) / px
		var back := at.distance_to(PORCH_T) < 0.5
		fails += 0 if back else 1
		print("%s  house left onto the concept porch (at %.1f,%.1f)" % ["PASS" if back else "FAIL", at.x, at.y])
	print("nav check: %d failure(s)" % fails)


# Holds the move keys toward a waypoint (8 directions) until there or stuck. Returns whether it arrived.
func _steer(main, wp: Vector2, max_frames := 400) -> bool:
	var held: Array = []
	var last := Vector2.INF
	var still := 0
	for i in max_frames:
		var at: Vector2 = (main.player.position - inner_origin) / px
		var d := wp - at
		if d.length() < 0.25:
			break
		for k in held:
			Input.action_release(k)
		held.clear()
		if d.x > 0.15: held.append("move_right")
		elif d.x < -0.15: held.append("move_left")
		if d.y > 0.15: held.append("move_down")
		elif d.y < -0.15: held.append("move_up")
		for k in held:
			Input.action_press(k)
		await process_frame
		main.message_label.text = ""
		if at.distance_to(last) < 0.002:
			still += 1
			if still > 20:
				break
		else:
			still = 0
		last = at
	for k in held:
		Input.action_release(k)
	await process_frame
	return ((main.player.position - inner_origin) / px).distance_to(wp) < 0.3
