extends "res://tools/art003_round3s.gd"

# ART-003 wider homestead, steps W-1 and W-2 (non-production): the proposed 64x40 layout
# (art/style_tests/ART-003/wide/blueprint_wide.txt) built over the farm's inner area from existing art only, with
# the game's own camera, scale, colour grade and the locked R3-1 night. Nothing in the game is changed or saved
# beyond the test slot capture.gd uses (8). Not headless (needs a renderer):
#   godot --path . -s tools/art003_wide.gd -- mode=wide view=V1 hour=21.5 out=builds/review/ART-003/wide/v1_night.png
# Options, on top of art003_round3.gd's (hour, weather, measure, masks, sanity, forage, size, frames):
#   mode=wide | production    wide builds the prototype; production shows the live farm at the same spot
#   view=V1..V5               where the farmer stands (see VIEWS); or at=X,Y in inner-farm tiles
#   layout=b                  the V1 framing variant (blueprint_wide_v1b.txt: house one row lower, oak one tile east)
#   visitor=ID@X,Y            tonight's visitor on inner tile X,Y
#   walk=route hold=S         record the walking route (ROUTE) under --write-movie --fixed-fps 30
#   art=w3                    ART-003 W-3 Batch A (layout b only): oak D's fuller canopy (w3/oak/oak_w3.png), a smaller
#                             litter drift under it, and the irregular pond (blueprint_wide_v1b_w3.txt) drawn with the
#                             PixelLab grass->water sets, shore props and a walkable dock, in place of ground_water
#   art=w3b                   ART-003 W-3 Batch B (layout b only), on top of art=w3: the pond's north shore one row south
#                             and the porch lantern post moved off the route (blueprint_wide_v1b_w3b.txt), the Restored
#                             house alternative (w3b/house/house_w3b.png), the refitted beds with every row planted
#                             (w3b/garden), north-south fence rails, a stone cross walk in the garden, porch pumpkins
#   art=w3p                   ART-003 W-3 polish (layout b only), on top of art=w3b, no new generation: the Restored
#                             house repainted (w3p/house: darker weathered walls, blue-black roof, a plank porch deck,
#                             stone treads; unlit glass and curtains by day, the Batch B lit glass at night), the
#                             porch dressed with firewood, flower pots and flowers, the beds' rows varied (clumps,
#                             gaps, tone and offset) and corn and beans recoloured to hold up at night (w3p/garden)
#   art=w3c                   ART-003 W-3 Batch C (layout b only), on top of art=w3p with wall a (D-010): a woodcutting
#                             corner and a boulder group at the V3 crossroads, a dead tree, boulders and a mailbox at the
#                             road's east end, wheel ruts along the road, grass tufts breaking the path edges, rushes
#                             thickening toward the pond, a rain barrel and compost at the garden's south-west corner,
#                             apple and pear trees (w3c/orchard) in the orchard. Props block their tiles (c_block)
#   art=w4                    ART-003 W-4 refinement (layout b only), on top of art=w3c, no generation (art in w4/):
#                             a low log pile hand-built from r3/log.png in place of the woodstore at V3 and on both
#                             house wings; orchard crown variants (apple a/b, pear a/b), windfalls and a basket; the
#                             closed east gate (x 59, rows 33-36) and a forest avenue beyond it, drawn only (collision
#                             keeps the base layout, so the gate tiles block exactly as the forest did); a 14-tile
#                             forest margin (the live border's width) instead of 6
#   art=f1                    ART-005 S2 field layout (layout b only), on top of art=w4, no generation (art in f1/,
#                             tools/art003_f1.py): the four raised beds become ground-level tilled fields on the same
#                             7x4 tiles, one planted ridge per tile row (one crop per tile, as the game plants); the
#                             garden's stone cross walk becomes a trodden dirt walk. The fields show the soil states
#                             and stages the game needs: NW ripe, NE growing, SW just planted and watered, SE half
#                             harvested. Drawn only: collision and every tile code are unchanged
#   art=f2                    ART-005 S3 polish of art=f1 (fields from f2/, tools/art003_f2.py): softer, non-parallel
#                             furrows, a more irregular field rim and patchy wet soil, crops a little more clustered.
#                             Drawn only, as f1: collision and every tile code are unchanged
#   house=g6:<var>            with art=w3b and later: the ART-005 S3 log-cabin mockup (pl/g6/<var>/32/, 32 art px per
#                             tile) drawn at half scale on the house's door anchor, so one art px is 1.5 screen px at
#                             3x, as the ART-005 harness's 720p frames; the house's dressing tiles are left bare
#   house=g7:<var>            as house=g6:, with the ART-005 P1 PixelLab edit (pl/g7/<var>/32/: p1 or raw)
#   check=reach               print the tiles the farmer can reach from the porch (flood fill over the collision check)
#                             and write them to <out>_reach.txt, then quit; walk=gate drives the farmer east along the road
#                             into the gate and prints where it stops
#   wall=a|b|c|m              with art=w3p: the house's wall variant (a warm weathered, b dark weathered, the default,
#                             c grey weathered, m the a/b midpoint)
#   house=prod                with art=w3b: keep the production house_stage_3 instead of the alternative
#   grass=1 | grass=2         a lighter prototype grass (albedo x1.15 or x1.30 on grass-coloured ground pixels, baked);
#                             lighting and the night grade are unchanged
#   probe                     with measure: also measure the tin lantern's pool circle round the farmer by day too,
#                             and save <out>_probe.png marking its pixels by ground (green grass, brown path, blue water)
#
# How it is built:
# - Ground: Round 1-3's PixelLab Wang sets on the game's dual grid (a tile on every corner where four map tiles
#   meet), drawn once into 16x16-tile chunk images (12 chunks for the inner farm, more for the margin) and shown as
#   one Sprite2D each, unlit like any sprite, so the night tint and every PointLight2D light it at run time. Nothing
#   about light or shadow is baked in. The water is the production SpriteCook dual-grid set (ground_water).
# - Everything that stands (trees, the house, the well, fences, beds, crops, props) stays its own Sprite2D, sorted
#   by its base each frame against the farmer, so walking behind and in front works.
# - The live farm is still there underneath, hidden (its own drawing and standing layers set transparent), and the
#   farmer's collision check is pointed at this layout's map for the run only (player.is_blocked); it is pointed
#   back before quitting. The game's map, layout and save are never written.

const WIDE := "res://art/style_tests/ART-003/wide/"
const GW := 64
const GH := 40
var CH := 16          # chunk size in tiles (chunk=N to try others)
var MARGIN := 6       # tiles of forest drawn round the inner farm (W-4: 14, the live border's width)
const VIEWS := {"V1": Vector2(37.5, 9.5), "V2": Vector2(49.0, 24.0), "V3": Vector2(31.0, 19.0),
	"V4": Vector2(14.0, 27.5), "V5": Vector2(45.0, 12.5)}
const VIEWS_B := {"V1": Vector2(38.5, 10.0), "V5": Vector2(45.0, 13.5)}   # the variant's house sits a row lower
# The walking route, in inner tiles: porch, well, the oak, back past the well, the garden's west gate and walkway,
# its south gate, the road, and the pond's dock.
const ROUTE := [Vector2(45.5, 12.5), Vector2(44.0, 14.0), Vector2(41.0, 15.0), Vector2(36.5, 17.6), Vector2(32.0, 17.0),
	Vector2(36.5, 17.8), Vector2(38.8, 20.0), Vector2(40.2, 23.6), Vector2(43.5, 24.2), Vector2(51.0, 24.2),
	Vector2(51.0, 29.0), Vector2(51.0, 31.2), Vector2(50.0, 33.8), Vector2(36.0, 34.2), Vector2(22.0, 34.2),
	Vector2(19.3, 32.0), Vector2(17.0, 31.5)]
# W-3's route ends on the new dock instead: along the road to its end, onto the bank and up the dock.
const ROUTE_W3_END := [Vector2(17.0, 34.6), Vector2(14.0, 34.6), Vector2(14.0, 30.7)]
const BLOCKS := "TOHDXWBrLd~o"   # codes the farmer can't walk on (K, the W-3 dock over water, is walkable)
const W3 := "res://art/style_tests/ART-003/w3/"
const W3B := "res://art/style_tests/ART-003/w3b/"
const W3P := "res://art/style_tests/ART-003/w3p/"
const W3C := "res://art/style_tests/ART-003/w3c/"
const W4 := "res://art/style_tests/ART-003/w4/"
const F1 := "res://art/style_tests/ART-003/f1/"
const GRASS_LIFT := {"1": 1.15, "2": 1.30}

var grid: Array = []          # rows of single-character codes
var inner_origin := Vector2.ZERO
var house_tex: Texture2D
var house_at := Vector2.ZERO  # top-left of the house sprite, in inner tiles
var oak_at := Vector2.ZERO    # top-left of the oak sprite, in inner tiles
var oak_image: Image
var shade_night := 0.0
var sorted: Array = []        # [Sprite2D, base y in tiles]
var stalls: Array = []        # route legs the walker had to skip
var mainref
var c_block := {}             # W-3C: tiles its props stand on (blocked like any prop)
var sorted_once := false
var overlay := {}             # W-4: drawn-only codes (the gate and avenue); collision never reads them


func _code_base(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= GW or y >= GH:
		return "T"
	return grid[y][x]


func _code(x: int, y: int) -> String:
	if overlay.has(Vector2i(x, y)):
		return overlay[Vector2i(x, y)]
	if x < 0 or y < 0 or x >= GW or y >= GH:
		return "T"
	return grid[y][x]


func _w3() -> bool:
	return o3.get("art", "") == "w3" or _w3b()


func _w3b() -> bool:
	return o3.get("art", "") == "w3b" or _w3p()


func _w3p() -> bool:
	return o3.get("art", "") == "w3p" or _w3c()


func _w3c() -> bool:
	return o3.get("art", "") == "w3c" or _w4()


func _w4() -> bool:
	return o3.get("art", "") == "w4" or _f1()


func _f1() -> bool:
	return o3.get("art", "") == "f1" or o3.get("art", "") == "f2"


# The ground material under a map code: g grass, p path (paths, the garden floor, the porch, the dock's land end,
# round the well), w water (the pond, and the W-3 dock's tiles, which stand over water).
func _mat(c: String) -> String:
	if "PwSgRkcWG".contains(c):   # G, the W-4 gate's leaves, stand on the road
		return "p"
	if c == "~" or c == "K":
		return "w"
	return "g"


func _view() -> Vector2:
	if o3.has("at"):
		var xy := str(o3["at"]).split(",")
		return Vector2(float(xy[0]), float(xy[1]))
	var v := str(o3.get("view", "V1"))
	if o3.get("layout", "") == "b" and VIEWS_B.has(v):
		return VIEWS_B[v]
	return VIEWS.get(v, VIEWS["V1"])


func _initialize() -> void:
	o3 = _opts()
	if o3["mode"] != "wide" and o3["mode"] != "production":
		super._initialize()
		return
	var file := WIDE + ("blueprint_wide_v1b.txt" if o3.get("layout", "") == "b" else "blueprint_wide.txt")
	if _w3():
		file = WIDE + ("blueprint_wide_v1b_w3b.txt" if _w3b() else "blueprint_wide_v1b_w3.txt")
	for line in FileAccess.get_file_as_string(file).split("\n", false):
		grid.append(line)
	if _w4():
		MARGIN = 14
		_w4_layout()
	var opt := o3
	CH = int(o3.get("chunk", "16"))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = opt.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	var main = load("res://scenes/main.tscn").instantiate()
	mainref = main
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 8)
	main.weather_kind = opt["weather"]
	main._apply_weather()
	var hour := float(opt["hour"])
	var night := hour >= 18.0
	main.clock = (hour - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	main.lantern_tier = int(opt.get("lantern", "1" if night else "0"))
	main._apply_lantern_radius()
	main.player.facing = Vector2.DOWN
	for c in main.get_children():
		if c is CanvasLayer and c.layer != 0:
			c.visible = false
	px = main.PX
	inner_origin = Vector2(main.BORDER_X, main.BORDER_Y) * px
	origin = inner_origin   # so art003_round3's forage placement reads inner tiles
	main.player.position = inner_origin + _view() * px
	if opt["mode"] == "wide":
		if night:
			_night(main, opt)   # the locked R3-1 night
		shade_night = _shade_strength(night)
		_build(main, night)
		main.player.is_blocked = Callable(self, "_blocked")
		main.tree_exiting.connect(_restore)
		if o3.get("check", "") == "reach":
			_reach()
			_restore()
			quit()
			return
	await _finish(main, opt)


# --- W-4 refinement ---------------------------------------------------------------------------------------------

func _w4_tex(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W4 + path)))


# The gate and avenue, read from the approved blueprint's PROPOSED grid (wh/exit_blueprint.txt): every tile from x 59
# east that differs from CURRENT becomes a drawn-only code. The blueprint's gate posts X are kept as Q here so the
# fence code doesn't draw them as fence. Collision reads _code_base, which never sees these.
func _w4_layout() -> void:
	var lines := FileAccess.get_file_as_string("res://art/style_tests/ART-003/wh/exit_blueprint.txt").split("
")
	var cur := {}
	var section := ""
	for line in lines:
		if line.begins_with("CURRENT"):
			section = "c"
		elif line.begins_with("PROPOSED"):
			section = "p"
		elif line.begins_with("y="):
			var y := int(line.substr(2, 2))
			var row := line.substr(6)
			for i in row.length():
				var x := 46 + i
				if x < 59:
					continue
				var c := row[i]
				if section == "c":
					cur[Vector2i(x, y)] = c
				elif cur.get(Vector2i(x, y), "") != c:
					overlay[Vector2i(x, y)] = "Q" if c == "X" else c
	print("W-4 overlay tiles: ", overlay.size())


# The orchard's six trees: the four variants, each flipped or not and a step lighter or darker, so no two neighbours
# match. Same tiles, same footprint as Batch C.
const W4_TREES := {Vector2i(9, 19): ["apple_b", false, 1.0], Vector2i(13, 19): ["apple_a", true, 0.95],
	Vector2i(17, 19): ["pear_a", false, 1.0], Vector2i(9, 23): ["pear_b", true, 0.96],
	Vector2i(17, 23): ["apple_b", true, 1.04], Vector2i(13, 24): ["pear_a", true, 0.93]}


func _w4_tree(add: Callable, x: int, y: int) -> void:
	var e: Array = W4_TREES.get(Vector2i(x, y), ["apple_a", false, 1.0])
	var v: float = e[2]
	add.call(_w4_tex("orchard/%s.png" % e[0]), x + 0.5, y + 1.0, e[1], Color(v, v, v))


func _w4_dress(add: Callable) -> void:
	# The gate: capped posts on Q, plank leaves on G (the north leaf carries the latch).
	var post := _w4_tex("gate/gatepost.png")
	var leaf_n := _w4_tex("gate/gate_leaf_n.png")
	var leaf_s := _w4_tex("gate/gate_leaf_s.png")
	var spur := _w4_tex("gate/gate_spur.png")
	# A soft shadow line across the road at the leaves' foot, so they read as a barrier standing on it.
	var sh := Image.create(5, 32, false, Image.FORMAT_RGBA8)
	sh.fill(Color(0.06, 0.04, 0.03, 0.4))
	add.call(ImageTexture.create_from_image(sh), 59.65, 36.0, false, Color.WHITE)
	(sorted[sorted.size() - 1] as Array)[1] = 32.0
	for y in [32, 37]:   # the fence running on into the trees either side (drawn only; those tiles are forest)
		add.call(spur, 59.5, y + 1.0, false, Color.WHITE)
	for t in overlay:
		var c: String = overlay[t]
		if c == "Q":
			add.call(post, t.x + 0.5, t.y + 1.0, false, Color.WHITE)
		elif c == "G":
			add.call(leaf_n if _code(t.x, t.y - 1) == "Q" else leaf_s, t.x + 0.5, t.y + 1.0, false, Color.WHITE)
	# Harvest: windfalls lying flat round the trees' feet (walkable, like the lily pads), and a basket of picked fruit in
	# front of the Batch C barrel, on the barrel's own blocked tile.
	var wa := _w4_tex("orchard/windfall_apple.png")
	var wp := _w4_tex("orchard/windfall_pear.png")
	for e in [[wa, 8.4, 20.35], [wa, 9.9, 20.6], [wa, 10.3, 20.2], [wa, 12.4, 20.5], [wp, 17.9, 20.4], [wp, 16.6, 20.7],
			[wp, 8.5, 24.3], [wp, 9.8, 24.6], [wa, 16.5, 24.4], [wa, 17.8, 24.2], [wa, 18.2, 24.7], [wp, 12.6, 25.5], [wp, 13.9, 25.3]]:
		add.call(e[0], e[1], e[2], int(e[1] * 10.0) % 2 == 0, Color.WHITE)
		(sorted[sorted.size() - 1] as Array)[1] = e[2] - 2.0
	add.call(_w4_tex("orchard/basket.png"), 14.3, 20.95, false, Color.WHITE)


# check=reach: a flood fill from the porch over the farmer's collision check, tile by tile, 4-connected.
func _reach() -> void:
	var start := Vector2i(ROUTE[0].floor())
	var seen := {start: true}
	var todo := [start]
	while not todo.is_empty():
		var t: Vector2i = todo.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = t + d
			if n.x < 0 or n.y < 0 or n.x >= GW or n.y >= GH or seen.has(n):
				continue
			if _blocked(inner_origin + (Vector2(n) + Vector2(0.5, 0.5)) * px):
				continue
			seen[n] = true
			todo.append(n)
	var keys := seen.keys()
	keys.sort_custom(func(a, b): return a.y < b.y or (a.y == b.y and a.x < b.x))
	var lines := PackedStringArray()
	var east := 0
	for k in keys:
		lines.append("%d,%d" % [k.x, k.y])
		if k.x >= 59:
			east += 1
	var path := ProjectSettings.globalize_path("res://" + str(o3["out"])).get_basename() + "_reach.txt"
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("
".join(lines) + "
")
	f.close()
	var gate := []
	for y in range(33, 37):
		gate.append(_blocked(inner_origin + Vector2(59.5, y + 0.5) * px))
	print("reach: ", keys.size(), " tiles; reachable with x >= 59: ", east, "; gate tiles (59, 33..36) blocked: ", gate,
		"; overlay tiles: ", overlay.size(), "; list in ", path)


# --- W-3 Batch C ------------------------------------------------------------------------------------------------

# Ground: wheel ruts along the road (two darker lines, each a pixel off the line now and then), and grass tufts that
# creep a few pixels onto a path where it meets grass, so the path edges stop reading as even brown bands.
func _c_ground(M: Callable, put: Callable, cover: Array, x0: int, y0: int) -> void:
	for y in GH:
		for x in GW:
			if _code(x, y) != "P":
				continue
			var h := _hash(x, y, 53)
			var sides := []
			for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
				if M.call(x + d.x, y + d.y) == "g" and _code(x + d.x, y + d.y) != "T":
					sides.append(d)
			if sides.is_empty() or h % 3 != 0:
				continue
			var d: Vector2i = sides[(h >> 3) % sides.size()]
			var t: Texture2D = cover[(h >> 5) % cover.size()]
			var ti: Image = t.get_image()
			ti.convert(Image.FORMAT_RGBA8)
			var sz := ti.get_size()
			# Sit on the tile's grass side, a few pixels in from the edge.
			var ox := 4 + (h >> 7) % 6 if d.x == 0 else (16 - sz.x + 3 if d.x > 0 else -3)
			var oy := 4 + (h >> 9) % 6 if d.y == 0 else (16 - sz.y + 3 if d.y > 0 else -3)
			put.call(ti, Rect2i(Vector2i.ZERO, sz), (x - x0) * 16 + ox, (y - y0) * 16 + oy, true)
	# Ruts: the road's long east-west run (rows 34-35), where both rows are path.
	for x in range(12, 59):
		if _code(x, 34) != "P" or _code(x, 35) != "P":
			continue
		for lane in [9, 19]:   # pixels below the top of row 34
			for xx in 16:
				var wob := 1 if _hash(x * 4 + xx / 4, lane, 67) % 5 == 0 else 0
				var dot := Image.create(1, 2, false, Image.FORMAT_RGBA8)
				dot.fill(Color(0.1, 0.07, 0.04, 0.32))
				put.call(dot, Rect2i(0, 0, 1, 2), (x - x0) * 16 + xx, (34 - y0) * 16 + lane + wob, true)


func _c_tex(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W3C + path)))


# Standing props: a few deliberate groups, open grass left between them. Each blocks the tiles in its list.
func _c_props(add: Callable, kit: Array) -> void:
	var stones := _strip(R3 + "boulders.png", 12)
	var shore := _strip(W3 + "pond/shore_strip.png", 12)   # reeds, cattails, cattails, lily pads, rock, mossy rock, rushes
	var groups := [
		# V3: a woodcutting corner between the well and the oak.
		[load("res://art/farm/chopping_log.png"), 34.4, 15.0, [Vector2i(34, 14)]],
		[_w4_tex("props/logpile.png") if _w4() else load("res://art/farm/woodstore.png"), 35.5, 15.0, [Vector2i(35, 14)]],
		[load("res://art/farm/prop_stump.png"), 33.3, 15.4, [Vector2i(33, 14)]],
		# V3: a signpost and a boulder group in the grass between the fork's south-west and south branches, and a
		# handcart of sacks where the well path meets the south branch.
		[_c_tex("props/signpost.png"), 31.5, 22.0, [Vector2i(31, 21)]],
		[_c_tex("props/handcart.png"), 36.9, 22.0, [Vector2i(36, 21), Vector2i(37, 21)]],
		[stones[0], 29.6, 24.0, [Vector2i(29, 23)]],
		[stones[2], 30.6, 24.3, [Vector2i(30, 23)]],
		[stones[4 % stones.size()], 30.1, 25.0, [Vector2i(30, 24)]],
		# The arrival, where the road leaves the east forest: a dead tree and a boulder cluster either side.
		[load("res://art/farm/tree_dead_0.png"), 57.2, 33.0, [Vector2i(56, 32), Vector2i(57, 32)]],
		[stones[1], 54.3, 36.8, [Vector2i(54, 36)]],
		[stones[3 % stones.size()], 55.3, 36.9, [Vector2i(55, 36)]],
		[_c_tex("props/mailbox.png"), 53.4, 33.0, [Vector2i(53, 32)]],
		# Garden -> pond: a rain barrel at the garden's south-west corner, outside the fence.
		[kit[2], 41.4, 31.0, [Vector2i(41, 30)]],
		[_c_tex("props/compost.png"), 40.1, 31.0, [Vector2i(40, 30)]],
		# The orchard: a barrel of picked apples beside one tree.
		[_c_tex("props/apple_barrel.png"), 14.7, 20.3, [Vector2i(14, 20)]],
	]
	for g in groups:
		add.call(g[0], g[1], g[2], int(g[1] * 10.0) % 2 == 1, Color.WHITE)
		for t in g[3]:
			c_block[t] = true
	# Rushes and cattails thickening toward the pond along the strip between its east bank and the dock path
	# (walkable, as the shore props are).
	for e in [[6, 17.4, 29.8], [1, 17.5, 31.0], [6, 17.3, 32.4], [0, 20.7, 30.6], [6, 20.6, 32.0]]:
		add.call(shore[int(e[0]) % shore.size()], e[1], e[2], int(e[1] * 10.0) % 2 == 0, Color.WHITE)


# --- The prototype -------------------------------------------------------------------------------------------

func _blocked(p: Vector2) -> bool:
	var t := ((p - inner_origin) / px).floor()
	return BLOCKS.contains(_code_base(int(t.x), int(t.y))) or c_block.has(Vector2i(t))


# How far a forest tile lies inside the forest, in tiles (0 at the clearing's edge), up to 4.
func _depth(x: int, y: int) -> float:
	for r in range(1, 5):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if _code_base(x + dx, y + dy) != "T":   # W-4: the avenue doesn't thin the forest's shade round it
					return float(r - 1)
	return 4.0


func _shade_at(x: int, y: int) -> float:
	if overlay.has(Vector2i(x, y)) and x >= 60:   # W-4: the avenue darkens under the canopy as it runs east
		return 1.0 - shade_night * 0.85 * smoothstep(60.0, 71.0, float(x))
	if _code(x, y) != "T":
		return 1.0
	var d := _depth(x, y)
	if _avenue_wall(x, y):   # W-4: the wall of firs over the avenue stands on deep-forest ground
		d = maxf(d, 2.5)
	return 1.0 - shade_night * smoothstep(0.0, 3.5, d + 0.5)


# W-4: a forest tile within three rows north of the avenue (east of the gate).
func _avenue_wall(x: int, y: int) -> bool:
	if overlay.is_empty() or x < 60 or _code(x, y) != "T":
		return false
	for k in range(1, 4):
		if overlay.has(Vector2i(x, y + k)) and overlay[Vector2i(x, y + k)] != "T":
			return true
	return false


func _near(x: int, y: int, codes: String, r: int) -> bool:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if codes.contains(_code(x + dx, y + dy)):
				return true
	return false


func _region(img: Image, r: Rect2) -> Image:
	var out := img.get_region(Rect2i(r))
	out.convert(Image.FORMAT_RGBA8)
	return out


# Fixed-width cells of a strip, left to right (the W-3B crops: eight 16x32 cells).
func _cells(path: String, w: int) -> Array:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	var out := []
	for k in img.get_width() / w:
		out.append(ImageTexture.create_from_image(img.get_region(Rect2i(k * w, 0, w, img.get_height()))))
	return out


func _build(main, night: bool) -> void:
	var S: int = main.SCALE
	# Hide the live farm: main's own drawing and its standing layers, and the house, cave and roost lights.
	main.self_modulate = Color(1, 1, 1, 0)
	for l in [main.house_roof_layer, main.stall_layer, main.well_layer, main.big_tree_layer, main.tree_front_layer, main.goat_layer]:
		if l != null:
			l.modulate = Color(1, 1, 1, 0)
	for l in main.window_lights + [main.porch_light, main.cave_mouth_light, main.desk_light] + main.roost_lights:
		if l != null:
			# Hidden and moved far off-screen, so they can't take a share of the 15 lights a canvas item shows.
			(l as PointLight2D).visible = false
			(l as PointLight2D).global_position = Vector2(-1e6, -1e6)

	# --- Ground, baked into chunk images ---------------------------------------------------------------------
	var grass_ref := Color(0.27, 0.29, 0.13)
	var path_ref := Color(0.45, 0.33, 0.22)
	var path_a := _wang_set(SRC_DIR + "path_tileset", grass_ref)
	var path_b := _wang_set(R3 + "path2_tileset", grass_ref)
	var wear := _wang_set(R3 + "wear_tileset", path_ref)
	var litter := _wang_set("res://art/style_tests/ART-003/r2/litter_tileset", grass_ref)
	var ia: Image = (path_a[0] as ImageTexture).get_image()
	var ib: Image = (path_b[0] as ImageTexture).get_image()
	var iw: Image = (wear[0] as ImageTexture).get_image()
	var il: Image = (litter[0] as ImageTexture).get_image()
	for im in [ia, ib, iw, il]:
		im.convert(Image.FORMAT_RGBA8)
	var water := Image.load_from_file(ProjectSettings.globalize_path("res://art/farm/ground_water.png"))
	water.convert(Image.FORMAT_RGBA8)
	# W-3: two PixelLab grass->water sets chained to the same grass and water base tiles (brown and dark mud banks),
	# chosen in stretches by a slow noise so a whole run of shore uses one bank, not a patchwork.
	var water_a := _wang_set(W3 + "pond/water_tileset", grass_ref) if _w3() else []
	var water_b := _wang_set(W3 + "pond/water2_tileset", grass_ref) if _w3() else []
	var iwa: Image = (water_a[0] as ImageTexture).get_image() if _w3() else null
	var iwb: Image = (water_b[0] as ImageTexture).get_image() if _w3() else null
	var bnoise := FastNoiseLite.new()
	bnoise.seed = 61
	bnoise.frequency = 0.12
	# The grass fill, plain and with its repeating speck painted out (as R3-3), in four mirrorings each.
	var plain := _region(ia, path_a[1]["0000"])
	var calm := plain.duplicate() as Image
	for yy in 16:
		for xx in 16:
			var c := calm.get_pixel(xx, yy)
			if c.r > c.g * 1.25 and c.r > 0.3:
				var n := calm.get_pixel(maxi(xx - 2, 0), yy)
				if n.r > n.g * 1.25:
					n = calm.get_pixel(mini(xx + 2, 15), yy)
				calm.set_pixel(xx, yy, n)
	var dirt := _region(ia, path_a[1]["1111"])

	# Materials per map tile: g grass, p path (paths, the garden floor, the porch, the dock, round the well),
	# s worn stone (the well's ring), l leaf litter, w water.
	var mat := []
	var lnoise := FastNoiseLite.new()
	lnoise.seed = 5
	lnoise.frequency = 0.15
	var wnoise := FastNoiseLite.new()
	wnoise.seed = 29
	wnoise.frequency = 0.35
	for y in range(-MARGIN, GH + MARGIN):
		var row := []
		for x in range(-MARGIN, GW + MARGIN):
			row.append(_mat(_code(x, y)))
		mat.append(row)
	var M := func(x: int, y: int) -> String:
		if x < -MARGIN or y < -MARGIN or x >= GW + MARGIN or y >= GH + MARGIN:
			return "g"
		return mat[y + MARGIN][x + MARGIN]
	# Worn stone round the well, and worn patches where a path is wide; leaf litter in drifts under the oak and in
	# thinner patches at the forest's and the orchard's edge, not spread evenly.
	var stone := {}
	var leaves := {}
	for y in range(-MARGIN, GH + MARGIN):
		for x in range(-MARGIN, GW + MARGIN):
			var ring := true
			var open := true
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if M.call(x + dx, y + dy) != "p":
						ring = false
					if M.call(x + dx, y + dy) != "g":
						open = false
			var walk := _w3b() and not _f1() and _code(x, y) == "w" and (x == 51 or y == 24)   # W-3B: the garden's stone cross walk
			if ring and (_code(x, y) == "c" or _code(x, y) == "W" or walk or wnoise.get_noise_2d(x, y) > 0.35):
				stone[Vector2i(x, y)] = true
			elif open and ((_near(x, y, "rB", 1 if _w3() else 2) and lnoise.get_noise_2d(x, y) > (0.3 if _w3() else 0.15)) or (_near(x, y, "To", 1) and lnoise.get_noise_2d(x, y) > 0.38)):
				leaves[Vector2i(x, y)] = true

	var x0 := -MARGIN
	var y0 := -MARGIN
	var cw := ceili(float(GW + 2 * MARGIN) / CH)
	var chh := ceili(float(GH + 2 * MARGIN) / CH)
	var chunks := []
	for cy in chh:
		for cx in cw:
			chunks.append(Image.create(CH * 16, CH * 16, false, Image.FORMAT_RGBA8))
	# Draws one 16 px image at map pixel (mx, my), relative to the margin's top-left, into every chunk it touches.
	var put := func(src: Image, rect: Rect2i, mx: int, my: int, blend: bool) -> void:
		for cy in range(floori(float(my) / (CH * 16)), floori(float(my + rect.size.y - 1) / (CH * 16)) + 1):
			for cx in range(floori(float(mx) / (CH * 16)), floori(float(mx + rect.size.x - 1) / (CH * 16)) + 1):
				if cx < 0 or cy < 0 or cx >= cw or cy >= chh:
					continue
				var dst: Image = chunks[cy * cw + cx]
				var at := Vector2i(mx - cx * CH * 16, my - cy * CH * 16)
				if blend:
					dst.blend_rect(src, rect, at)
				else:
					dst.blit_rect(src, rect, at)
	var flipped := func(img: Image, h: int) -> Image:
		var o := img.duplicate() as Image
		if h & 1:
			o.flip_x()
		if h & 2:
			o.flip_y()
		return o
	# Corners: a tile on every vertex where four map tiles meet, keyed NW NE SW SE.
	for vy in range(y0 + 1, GH + MARGIN):
		for vx in range(x0 + 1, GW + MARGIN):
			var cells := [Vector2i(vx - 1, vy - 1), Vector2i(vx, vy - 1), Vector2i(vx - 1, vy), Vector2i(vx, vy)]
			var key := ""
			for c in cells:
				key += "1" if M.call(c.x, c.y) == "p" else "0"
			var mx := (vx - x0) * 16 - 8
			var my := (vy - y0) * 16 - 8
			var h := _hash(vx, vy, 19)
			if key == "0000":
				put.call(flipped.call(calm if h % 3 != 0 else plain, h >> 2), Rect2i(0, 0, 16, 16), mx, my, false)
			elif key == "1111":
				put.call(flipped.call(dirt, h >> 2), Rect2i(0, 0, 16, 16), mx, my, false)
			else:
				var use_b := _hash(vx, vy, 11) % 2 == 0
				put.call(ib if use_b else ia, Rect2i((path_b if use_b else path_a)[1][key]), mx, my, false)
			# Worn stone over path, leaf litter over grass: only where all four corners are that ground.
			var skey := ""
			var lkey := ""
			for c in cells:
				skey += "1" if stone.has(c) else "0"
				lkey += "1" if leaves.has(c) else "0"
			if key == "1111" and skey != "0000":
				put.call(iw, Rect2i(wear[1][skey]), mx, my, true)
			if key == "0000" and lkey != "0000":
				put.call(il, Rect2i(litter[1][lkey]), mx, my, true)
			# Water: the production dual-grid set, laid over the ground (transparent where not water).
			var mask := 0
			var wkey := ""
			for i in 4:
				if M.call(cells[i].x, cells[i].y) == "w":
					mask |= [1, 2, 4, 8][i]
				wkey += "1" if M.call(cells[i].x, cells[i].y) == "w" else "0"
			if _w3():
				# W-3: the PixelLab tiles are opaque (grass, bank and water in one), so they replace the corner's
				# ground; the layout keeps paths a tile clear of the water, so no corner needs path and water at once.
				if wkey != "0000":
					var use_wb := bnoise.get_noise_2d(vx, vy) > 0.0
					if wkey == "1111":
						var fill := _region(iwa, water_a[1]["1111"])
						put.call(flipped.call(fill, h >> 2), Rect2i(0, 0, 16, 16), mx, my, false)
					else:
						put.call(iwb if use_wb else iwa, Rect2i((water_b if use_wb else water_a)[1][wkey]), mx, my, false)
				continue
			var frame: int = main.DUAL_FRAME_BY_MASK[mask]
			if frame >= 0:
				put.call(water, Rect2i((frame % 4) * 16, (frame / 4) * 16, 16, 16), mx, my, true)

	# Decals and ground cover, gathered where things meet (path verges, forest edges, bases) rather than everywhere.
	var decals := _pieces("decals.png", 10).filter(func(t): return t.get_width() <= 9 and t.get_height() <= 9)
	var cover := _strip(R3 + "groundcover.png", 8)
	for y in range(y0, GH + MARGIN):
		for x in range(x0, GW + MARGIN):
			if M.call(x, y) != "g" or _code(x, y) == "T" and _depth(x, y) > 1.0:
				continue
			var h := _hash(x, y, 3)
			var edge := _near(x, y, "PwgRkcT", 1) or _near(x, y, "XrodLB", 1)
			var t: Texture2D = null
			if edge and h % 5 < 2:
				t = cover[h % cover.size()]
			elif edge and h % 5 == 2:
				t = decals[h % decals.size()]
			elif not edge and h % 23 == 0:
				t = decals[h % decals.size()]
			if t:
				var di: Image = t.get_image()
				di.convert(Image.FORMAT_RGBA8)
				put.call(di, Rect2i(Vector2i.ZERO, di.get_size()), (x - x0) * 16 + 2 + (h >> 4) % 10, (y - y0) * 16 + 2 + (h >> 8) % 10, true)

	if _w3c():
		_c_ground(M, put, cover, x0, y0)

	# W-3B: a lighter grass, as a comparison: grass-coloured ground pixels (greener than red, clearly not blue) are
	# brightened by one factor, before the forest's shade. Paths, soil, bark, water and litter keep their colours.
	var lift: float = GRASS_LIFT.get(str(o3.get("grass", "")), 1.0)
	if lift != 1.0:
		for im in chunks:
			var ci: Image = im
			for yy in ci.get_height():
				for xx in ci.get_width():
					var c := ci.get_pixel(xx, yy)
					if c.a > 0.0 and c.g >= c.r * 0.92 and c.g > c.b * 1.25:
						ci.set_pixel(xx, yy, Color(minf(c.r * lift, 1.0), minf(c.g * lift, 1.0), minf(c.b * lift, 1.0), c.a))

	# The forest's shade, as an albedo darkening by depth (the same strength as R3-1's forest shade).
	for y in range(y0, GH + MARGIN):
		for x in range(x0, GW + MARGIN):
			var f := _shade_at(x, y)
			if f >= 0.999:
				continue
			var shade := Image.create(16, 16, false, Image.FORMAT_RGBA8)
			shade.fill(Color(0.02, 0.03, 0.05, 1.0 - f))
			put.call(shade, Rect2i(0, 0, 16, 16), (x - x0) * 16, (y - y0) * 16, true)

	for cy in chh:
		for cx in cw:
			var s := Sprite2D.new()
			s.texture = ImageTexture.create_from_image(chunks[cy * cw + cx])
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.centered = false
			s.scale = Vector2(S, S)
			s.position = inner_origin + Vector2(x0 + cx * CH, y0 + cy * CH) * px
			s.z_index = 1
			main.add_child(s)

	# --- Things that stand -----------------------------------------------------------------------------------
	var fir := _tex("fir.png")
	var maple := _tex("maple.png")
	var under := _tex("undergrowth.png")
	var add := func(t: Texture2D, x: float, base: float, flip: bool, tint: Color) -> void:
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
	# Forest: a tree on about every third forest tile, firs inside, maples and undergrowth at the clearing's edge.
	for y in range(y0, GH + MARGIN):
		for x in range(x0, GW + MARGIN):
			if _code(x, y) != "T":
				continue
			var h := _hash(x, y, 41)
			var d := _depth(x, y)
			var f := _shade_at(x, y)
			var tint := Color(f, f, f) * (Color(1, 1, 1) if d < 1.0 else Color(0.85, 0.9, 0.95))
			tint.a = 1.0
			# A tall tree just south of open ground would stand in front of it: its crown covered the south road and
			# the farmer on it in the first walk. Those tiles get low undergrowth instead.
			var open_north := false
			for k in range(1, 4):
				if _code(x, y - k) != "T":
					open_north = true
			if _avenue_wall(x, y) and not open_north:   # W-4: a fir on every tile, so the avenue reads as cut through
				add.call(fir, x + 0.5 + ((h >> 3) % 5 - 2) * 0.12, y + 1.0, h & 1 == 1, tint)
			elif open_north:
				if h % 2 == 0:
					add.call(under, x + 0.5, y + 0.9, h & 4 == 4, tint)
			elif (x + 2 * y + (h % 2)) % 3 == 0:
				var t := maple if d < 1.0 and h % 3 == 0 else fir
				add.call(t, x + 0.5 + ((h >> 3) % 5 - 2) * 0.15, y + 1.0, h & 1 == 1, tint)
			elif d < 1.0 and h % 4 == 1:
				add.call(under, x + 0.5, y + 0.9, h & 2 == 2, tint)
	# The oak, its boulders, fungus and charms.
	var oak := _r3("oak_d.png")
	if _w3():
		oak = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W3 + "oak/oak_w3.png")))
	oak_image = oak.get_image()
	var bx := 0.0
	var by := 0.0
	var n := 0
	for y in GH:
		for x in GW:
			if _code(x, y) == "B":
				bx += x + 0.5
				by = maxf(by, y + 1.0)
				n += 1
	bx /= maxf(n, 1)
	var oak_base := Vector2(bx, by + 0.3)
	oak_at = oak_base - Vector2(oak.get_width() / 32.0, oak.get_height() / 16.0)
	add.call(oak, oak_base.x, oak_base.y, false, Color.WHITE)
	var stones := _strip(R3 + "boulders.png", 12)
	var fungus := _strip(R3 + "fungus.png", 4)
	var charms := _strip(R3 + "oak_details.png", 10).filter(func(t): return t.get_height() > t.get_width() * 1.4)
	var i := 0
	for y in GH:
		for x in GW:
			match _code(x, y):
				"r":
					add.call(stones[(i * 3) % stones.size()], x + 0.5, y + 0.9, i % 2 == 1, Color.WHITE)
					i += 1
				"o":   # orchard: maples standing in for fruit trees (no fruit-tree art yet); W-3C: apple and pear, alternating
					if _w4():
						_w4_tree(add, x, y)
					elif _w3c():
						add.call(_c_tex("orchard/apple_w3c.png" if ((x - 9) / 4 + (1 if y > 21 else 0)) % 2 == 0 else "orchard/pear_w3c.png"),
							x + 0.5, y + 1.0, (x + y) % 2 == 0, Color.WHITE)
					else:
						add.call(maple, x + 0.5, y + 1.0, (x + y) % 2 == 0, Color.WHITE)
				"L":
					add.call(_tex("lantern_post.png"), x + 0.5, y + 1.0, false, Color.WHITE)
	for f in [[0, 74, 134], [1, 116, 128], [2, 78, 152]]:
		var t: Texture2D = fungus[f[0] % fungus.size()]
		var p: Vector2 = oak_at + Vector2(f[1], f[2]) / 16.0
		add.call(t, p.x, oak_base.y + 0.01, false, Color.WHITE)
		(sorted[sorted.size() - 1][0] as Sprite2D).position = inner_origin + Vector2(p.x * px - t.get_width() * S / 2.0, p.y * px - t.get_height() * S)
	for c in [[0, 46, 104], [1, 150, 96]]:
		var t: Texture2D = charms[c[0] % charms.size()]
		var p: Vector2 = oak_at + Vector2(c[1], c[2] + t.get_height()) / 16.0
		add.call(t, p.x, oak_base.y + 0.01, false, Color.WHITE)
		(sorted[sorted.size() - 1][0] as Sprite2D).position = inner_origin + Vector2(p.x * px - t.get_width() * S / 2.0, p.y * px - t.get_height() * S)

	# The farmhouse: the production restored sprite, centred on the door, standing on the porch row.
	house_tex = load("res://art/farm/house_stage_3.png")
	if _w3b() and o3.get("house", "") != "prod":
		house_tex = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W3B + "house/house_w3b.png")))
		if _w3p():   # the same sprite repainted: day glass unlit, night glass lit as Batch B's
			var hp := W3P + "house/house_w3p_%s_%s.png" % [o3.get("wall", "a" if _w3c() else "b"), "night" if night else "day"]
			house_tex = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(hp)))
	var dx := 0.0
	var dy := 0.0
	for y in GH:
		for x in GW:
			if _code(x, y) == "D":
				dx = x + 0.5
				dy = y + 1.0
	var g6: String = str(o3.get("house", ""))
	if g6.begins_with("g7:"):   # ART-005 P1: the PixelLab edit (pl/g7/<var>/32/), drawn exactly as house=g6:<var>
		g6 = "g6:../g7/" + g6.substr(3)
	if g6.begins_with("g6:"):
		# ART-005 S3: the 32 px log-cabin mockup at half scale; its foundation bottom (y 298 of 320) on the door row's
		# lower edge, its door centre (x 192 of 384) on the door tile's centre
		var hp6 := "res://art/style_tests/ART-005/pl/g6/%s/32/house_%s.png" % [g6.substr(3), "night" if night else "day"]
		house_tex = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(hp6)))
		var hs := Sprite2D.new()
		hs.texture = house_tex
		hs.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hs.scale = Vector2(S, S) * 0.5
		hs.centered = false
		var base6 := dy + 22.0 / 32.0
		hs.position = inner_origin + Vector2(dx * px - 192.0 * S * 0.5, base6 * px - 320.0 * S * 0.5)
		main.add_child(hs)
		sorted.append([hs, base6])
		house_at = Vector2(dx - 6.0, base6 - 10.0)
	else:
		house_at = Vector2(dx - house_tex.get_width() / 32.0, dy - house_tex.get_height() / 16.0)
		add.call(house_tex, dx, dy, false, Color.WHITE)
	# Its dressing: firewood, a barrel, a flower pot, a crate.
	var kit := _strip(R3 + "garden_props_clean.png", 30)   # corn, trellis, barrel, crate, flower pot
	var dressing := [load("res://art/farm/woodstore.png"), kit[2], kit[4], kit[3]]
	if _w3p():   # W-3 polish: firewood against both wings, a chopping block, flower pots and barrels at the front
		var wood: Texture2D = load("res://art/farm/woodstore.png")   # the same d tiles, in reading order
		if _w4():   # W-4: the hand-built log pile on both wings
			wood = _w4_tex("props/logpile.png")
		dressing = [kit[2], wood, wood, load("res://art/farm/chopping_log.png"), kit[3], kit[2], kit[4], kit[4], kit[2]]
	i = 0
	for y in GH:
		for x in GW:
			if _code(x, y) == "d" and not g6.begins_with("g6:"):
				add.call(dressing[i % dressing.size()], x + 0.5, y + 1.0, i % 2 == 1, Color.WHITE)
				i += 1
	if _w3p() and not g6.begins_with("g6:"):   # flower clumps along the front of the footing
		var flowers := _strip(R3 + "groundcover.png", 6)
		for f in [[40.6, 7], [43.3, 6], [47.7, 7], [50.4, 6], [39.6, 7]]:
			add.call(flowers[f[1] % flowers.size()], f[0], dy + 0.15, int(f[0] * 10.0) % 2 == 0, Color.WHITE)
	if _w3b() and not g6.begins_with("g6:"):   # pumpkins either side of the porch steps, beside the dressing (art only; the tiles stay walkable)
		var pk: Texture2D = _strip(R3 + "crops_b_clean.png", 20)[-1]
		for p in [Vector2(dx - 2.3, dy + 0.95), Vector2(dx - 1.8, dy + 1.05), Vector2(dx + 2.4, dy + 1.0)]:
			add.call(pk, p.x, p.y, int(p.x * 10.0) % 2 == 0, Color.WHITE)
	# The well: the production sprite on its 2x2 footprint.
	for y in GH:
		for x in GW:
			if _code(x, y) == "W" and _code(x - 1, y) != "W" and _code(x, y - 1) != "W":
				add.call(load("res://art/farm/prop_well.png"), x + 1.0, y + 2.0, false, Color.WHITE)

	# Fences: rails where the run is horizontal, a post per tile where it runs north-south; gates left open.
	var fence_img := _tex("fence.png").get_image()
	fence_img.convert(Image.FORMAT_RGBA8)
	var post_x := 0
	for xx in fence_img.get_width():   # the first post: the first column with a tall run of pixels
		var tall := 0
		for yy in fence_img.get_height():
			if fence_img.get_pixel(xx, yy).a > 0.5:
				tall += 1
		if tall > fence_img.get_height() * 0.6:
			post_x = xx
			break
	var post := ImageTexture.create_from_image(fence_img.get_region(Rect2i(maxi(post_x - 1, 0), 0, 6, fence_img.get_height())))
	# W-3B: a north-south run gets a rail too: the top rail (rows 10..13 of the strip) turned on end, running from this
	# post's rail height up to the post one tile north, so the run reads as a fence instead of a row of posts.
	var ns_img := Image.create(6, fence_img.get_height() + 16, false, Image.FORMAT_RGBA8)
	ns_img.blit_rect(fence_img, Rect2i(maxi(post_x - 1, 0), 0, 6, fence_img.get_height()), Vector2i(0, 16))
	for yy in range(10, 30):   # the north post's top rail (row 10) down to this post's (row 26)
		for k in 4:
			var c := fence_img.get_pixel(post_x + 5 + yy % 12, 10 + k)
			if c.a > 0.5 and ns_img.get_pixel(1 + k, yy).a < 0.5:
				ns_img.set_pixel(1 + k, yy, c)
	var post_ns := ImageTexture.create_from_image(ns_img)
	var rail := []
	for k in 4:
		rail.append(ImageTexture.create_from_image(fence_img.get_region(Rect2i(k * 16, 0, 16, fence_img.get_height()))))
	for y in GH:
		for x in GW:
			if _code(x, y) != "X":
				continue
			if _code(x - 1, y) == "X" or _code(x + 1, y) == "X" or _code(x - 1, y) == "g" or _code(x + 1, y) == "g":
				add.call(rail[x % 4], x + 0.5, y + 1.0, false, Color.WHITE)
			elif _w3b() and _code(x, y - 1) == "X":
				add.call(post_ns, x + 0.5, y + 1.0, false, Color.WHITE)
			else:
				add.call(post, x + 0.5, y + 1.0, false, Color.WHITE)

	# The garden: a raised bed in each 7x4 bed, three rows of crops each. The two west beds use the PixelLab crops;
	# the two east beds the production crop strips (ripe frames), to compare how each reads.
	var bed := _r2("garden_bed.png")
	var plants := _pieces("crops.png", 30)
	var more := _strip(R3 + "crops_b_clean.png", 20)
	var prod := []
	for kind in ["pumpkin", "turnip", "corn"]:
		var strip := load("res://art/farm/crop_%s.png" % kind) as Texture2D
		prod.append(ImageTexture.create_from_image(strip.get_image().get_region(Rect2i(48, 0, 16, 16))))
	var bed_b := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W3B + "garden/bed_w3b.png"))) if _w3b() else null
	var crops_b := _cells((W3P + "garden/crops_w3p.png") if _w3p() else (W3B + "garden/crops_w3b.png"), 16) if _w3b() else []   # corn pumpkin beans cabbage kale squash turnip sunflower
	var beds := []
	for y in GH:
		for x in GW:
			if _code(x, y) == "S" and _code(x - 1, y) != "S" and _code(x, y - 1) != "S":
				beds.append(Vector2i(x, y))
	var bi := 0
	for b in beds:
		var w := 0
		while _code(b.x + w, b.y) == "S":
			w += 1
		var hgt := 0
		while _code(b.x, b.y + hgt) == "S":
			hgt += 1
		var cx: float = b.x + w / 2.0
		var base: float = b.y + hgt - 0.5
		if _f1():
			_f1_field(add, b, w, hgt, bi, crops_b)
			bi += 1
			continue
		if _w3b():
			# W-3B: the bed refitted to all 7x4 tiles, flat under its crops; every column of its three furrows planted,
			# the tall crops in the north row so they hide neither the rows behind nor the farmer on the walk.
			add.call(bed_b, cx, b.y + hgt, false, Color.WHITE)
			(sorted[sorted.size() - 1] as Array)[1] = b.y - 1.0
			var plan: Array = [[[0], [0, 7], [1]], [[2], [3], [3, 6]], [[7, 0], [6], [1, 5]], [[2], [5], [6, 3]]][bi % 4]
			for r in 3:
				var ry: float = b.y + [1.55, 2.55, 3.3][r]
				var gap := -1
				if _w3p():   # W-3 polish: one plant missing in most rows (picked or failed), never at a row's end
					gap = 1 + _hash(b.x, b.y + r, 11) % (w + 1)
					if gap >= w - 1:
						gap = -1
				for k in w:
					var kinds: Array = plan[r]
					var t: Texture2D = crops_b[kinds[(k + r) % kinds.size()]]
					var j := _hash(b.x + k, b.y + r, 7)
					if not _w3p():
						add.call(t, b.x + k + 0.5 + ((j % 5) - 2) * 0.04, ry, j % 2 == 0, Color.WHITE)
						continue
					if k == gap:
						continue
					# Mixed rows grow in clumps of two or three (AABBB) instead of alternating; each plant sits a
					# little off the line and takes one of three tones, so a row reads planted, not stamped.
					t = crops_b[kinds[((k + bi * 2) / 3 + r) % kinds.size()]] if kinds.size() > 1 else t
					var v: float = [1.0, 0.9, 1.07][j % 3]
					add.call(t, b.x + k + 0.5 + ((j % 7) - 3) * 0.05, ry + ((j / 7) % 3 - 1) * 0.08, j % 2 == 0,
						Color(v, v, v))
			bi += 1
			continue
		add.call(bed, cx, base, false, Color.WHITE)
		(sorted[sorted.size() - 1] as Array)[1] = base - 2.0   # lie flat: under the crops and anyone in the bed
		var rows: Array = [[plants[0], more[0]], [plants[2], more[3]], [plants[1], more[1]]] if b.x < 50 else [[prod[0]], [prod[1]], [prod[2]]]
		for r in 3:
			var ry: float = base - bed.get_height() / 16.0 + 1.1 + r * 0.75
			var xx: float = cx - bed.get_width() / 32.0 + 0.8
			var k := 0
			while xx < cx + bed.get_width() / 32.0 - 0.6:
				var kinds: Array = rows[r]
				var t: Texture2D = kinds[k % kinds.size()]
				add.call(t, xx, ry, _hash(xx, ry) % 2 == 0, Color.WHITE)
				xx += maxf(t.get_width() / 16.0 + 0.2, 0.85)
				k += 1
		bi += 1
	# Corn and a bean trellis along the garden's north fence, pumpkins by the west gate.
	for y in GH:
		for x in GW:
			if _code(x, y) == "w" and _code(x, y - 1) == "X" and x % 2 == 0:
				add.call(kit[0] if x < 51 else kit[1], x + 0.5, y + 0.95, x % 4 == 0, Color.WHITE)
	var pumpkin: Texture2D = more[more.size() - 1]
	for p in [Vector2(41.0, 21.0), Vector2(40.4, 25.8), Vector2(41.2, 26.4)]:
		add.call(pumpkin, p.x, p.y, int(p.x) % 2 == 0, Color.WHITE)
	# Logs and fog where the forest bites into the clearing.
	var log := _r3("log.png")
	for p in [Vector2(23.0, 5.0), Vector2(4.5, 19.0), Vector2(58.5, 32.0), Vector2(33.0, 36.3)]:
		add.call(log, p.x, p.y, int(p.x) % 2 == 0, Color.WHITE)
	# W-3: the dock on its 2x4 K tiles, lying flat under anyone on it, and the shore props: reeds and cattails in
	# three groups at the coves (north, south-west, by the dock), lily pads on the water, a rock at the east point.
	if _w3():
		var dock := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(W3 + "pond/dock.png")))
		var kx := 99
		var ky := 99
		for y in GH:
			for x in GW:
				if _code(x, y) == "K":
					kx = mini(kx, x)
					ky = mini(ky, y)
		add.call(dock, kx + 1.0, ky + 4.0, false, Color.WHITE)
		(sorted[sorted.size() - 1] as Array)[1] = ky - 1.0   # lie flat: under the farmer standing on it
		var shore := _strip(W3 + "pond/shore_strip.png", 12)   # reeds, cattails, cattails, lily pads, rock, mossy rock, rushes
		var north := 1.0 if _w3b() else 0.0   # W-3B: the north cove sits a row further south
		for e in [[1, 9.7, 28.9 + north], [0, 10.5, 29.0 + north], [6, 11.3, 28.8 + north], [2, 9.4, 34.9], [0, 10.3, 35.0], [1, 11.2, 34.8],
				[6, 8.6, 35.3], [1, 15.6, 33.9], [6, 16.4, 33.5], [5, 17.0, 32.2], [4, 2.6, 32.6]]:
			add.call(shore[int(e[0]) % shore.size()], e[1], e[2], int(e[1] * 10.0) % 2 == 0, Color.WHITE)
		for e in [[6.5, 31.6], [9.4, 30.9], [11.6, 32.7], [5.0, 33.7], [7.8, 29.9]]:
			add.call(shore[3], e[0], e[1], int(e[0] * 10.0) % 2 == 0, Color.WHITE)
			(sorted[sorted.size() - 1] as Array)[1] = e[1] - 2.0   # flat on the water
	if _w3c():
		_c_props(add, kit)
	if _w4():
		_w4_dress(add)
	var fog := load("res://art/farm/weather_fog.png") as Texture2D
	for p in [Vector2(2.0, 4.0), Vector2(57.0, 3.0), Vector2(1.0, 30.0), Vector2(55.0, 35.0), Vector2(26.0, 2.0)]:
		var s := Sprite2D.new()
		s.texture = fog
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(S, S)
		s.modulate = Color(0.8, 0.85, 0.92, 0.22 if night else 0.16)
		s.position = inner_origin + p * px
		s.z_index = 400
		main.add_child(s)

	# Lights: the lantern posts (stand-ins for earned lamps, as in the slice), and the restored house's own window
	# and porch lights, placed where the production game puts them on this sprite. No other light is added.
	if night:
		for y in GH:
			for x in GW:
				if _code(x, y) == "L":
					var light := PointLight2D.new()
					main._glow(light, 4.0 * px / 128.0)
					light.color = Color("ffc070")
					light.energy = main.LANTERN_ENERGY
					light.position = inner_origin + Vector2(x * px, (y - 0.75) * px)
					main.add_child(light)
		for wpos in main.HOUSE_SPRITE_WINDOWS:
			var light := PointLight2D.new()
			light.color = Color("ffc878")
			light.position = inner_origin + (house_at + (wpos as Vector2) + Vector2(0, main.WINDOW_SPILL)) * px
			main._glow(light, 0.9)
			light.energy = main.WINDOW_ENERGY * 1.2
			main.add_child(light)
		var porch := PointLight2D.new()
		porch.color = Color("ffd27a")
		porch.position = inner_origin + Vector2(dx, dy + 0.5) * px
		main._glow(porch, 0.6)
		porch.energy = main.WINDOW_ENERGY * 1.2
		main.add_child(porch)

	# Sorting: everything by its base, and the farmer by its feet, every frame.
	var sorter := Node.new()
	var gd := GDScript.new()
	gd.source_code = """
extends Node
var tool
func _process(_d):
	tool._sort()
"""
	gd.reload()
	sorter.set_script(gd)
	sorter.set("tool", self)
	sorter.process_priority = 900
	root.add_child(sorter)
	_sort()


func _sort() -> void:
	# W-4: the standing sprites never move, so they are sorted once (the margin of 14 roughly doubled their number,
	# and re-sorting all of them each frame cost about 1 ms); the farmer is sorted every frame. Earlier art= values
	# keep the per-frame loop, so their measurements stay comparable with past packages.
	if not (_w4() and sorted_once):
		for e in sorted:
			(e[0] as Sprite2D).z_index = 2 + int((e[1] + MARGIN) * 4.0)
		sorted_once = true
	var feet: Vector2 = (mainref.player.position - inner_origin) / px
	mainref.player.z_index = 2 + int((feet.y + 0.45 + MARGIN) * 4.0)


# --- Evidence -------------------------------------------------------------------------------------------------

func _finish(main, opt: Dictionary) -> void:
	if o3.has("visitor"):
		var v := str(o3["visitor"]).split("@")
		var xy := v[1].split(",")
		var t := Vector2(float(xy[0]), float(xy[1]))
		o3.erase("visitor")
		main.nights._begin(v[0])
		main.nights.visitor_tile = _world_tile_at(t)
		main.nights._show_visitor()
		main.nights.layer.z_index = 2 + int((t.y + 1.0 + MARGIN) * 4.0)
		main.message_label.text = ""
	await super._finish(main, opt)


# Points the farmer's collision back at the game's own check (connected to main leaving the tree, on quit).
func _restore() -> void:
	if mainref != null and mainref.player != null:
		mainref.player.is_blocked = mainref._is_blocked_world
		print("collision restored to the game's own check")


# The walking route: steers toward each waypoint in turn with the move keys (8 directions), as a player would.
func _walk(main) -> void:
	if not str(o3.get("walk", "")) in ["route", "gate"]:
		await super._walk(main)
		return
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	for i in 20:
		main.message_label.text = ""
		await process_frame
	var held := {}
	var max_x := 0.0
	var route: Array = ROUTE.slice(0, 15) + ROUTE_W3_END if _w3() else ROUTE
	if str(o3["walk"]) == "gate":   # east along both road rows into the gate, then try the verges either side
		route = [Vector2(63.5, 34.5), Vector2(57.5, 35.5), Vector2(63.5, 35.5), Vector2(57.5, 33.4), Vector2(63.5, 33.4),
			Vector2(57.5, 36.5), Vector2(63.5, 36.5)]
	for target in route:
		var stuck := 0
		var best := 1e9
		while true:
			var here: Vector2 = (main.player.position - inner_origin) / px
			var d: Vector2 = target - here
			if d.length() < 0.35:
				break
			# A small dead zone (0.08 tile, 4 units), so the farmer's 30-unit feet line up with a gate before going through.
			var want := {"move_left": d.x < -0.08, "move_right": d.x > 0.08, "move_up": d.y < -0.08, "move_down": d.y > 0.08}
			for k in want:
				if want[k] and not held.get(k, false):
					Input.action_press(k)
				elif not want[k] and held.get(k, false):
					Input.action_release(k)
				held[k] = want[k]
			main.message_label.text = ""
			await process_frame
			max_x = maxf(max_x, (main.player.position.x - inner_origin.x) / px)
			if d.length() < best - 0.01:
				best = d.length()
				stuck = 0
			else:
				stuck += 1
			if stuck > 45:
				stalls.append(target)
				break
	for k in held:
		if held[k]:
			Input.action_release(k)
	print("route legs skipped: ", stalls)
	print("farmer stopped at ", snappedf((main.player.position.x - inner_origin.x) / px, 0.01), ", ",
		snappedf((main.player.position.y - inner_origin.y) / px, 0.01), " (inner tiles); furthest east: ", snappedf(max_x, 0.01))
	for i in 30:
		main.message_label.text = ""
		await process_frame


# Regions for the measurements, from this layout: the lantern pool, the oak's and the house's sprite pixels, the
# forest (forest tiles and beyond the farm), and the rest as play area. Production frames are measured over the same
# screen pixels, so there the names describe the prototype's layout, not what the live farm shows.
func _measure(main, img: Image, mask_path: String) -> Dictionary:
	var inv: Transform2D = main.get_viewport().get_canvas_transform().affine_inverse()
	var pool_r := 0.0
	if main.lantern_tier > 0 and main.lantern_light.enabled:
		pool_r = float(main.LANTERN_TIERS[main.lantern_tier - 1]["radius"]) * px
	var lantern_at: Vector2 = main.lantern_light.global_position
	if oak_image == null:
		oak_image = Image.load_from_file(ProjectSettings.globalize_path(R3 + "oak_d.png"))
		house_tex = load("res://art/farm/house_stage_3.png")
		for y in GH:
			for x in GW:
				if _code(x, y) == "D":
					house_at = Vector2(x + 0.5 - house_tex.get_width() / 32.0, y + 1.0 - house_tex.get_height() / 16.0)
				if _code(x, y) == "B" and _code(x - 1, y) != "B" and _code(x, y + 1) != "B":
					oak_at = Vector2(x + 1.5 - oak_image.get_width() / 32.0, y + 1.3 - oak_image.get_height() / 16.0)
	var house_img := house_tex.get_image()
	var names := ["lantern_pool", "oak", "house", "forest_edge", "play_area", "frame"]
	var lumas := {}
	for nm in names:
		lumas[nm] = PackedFloat32Array()
	var mask := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8) if mask_path != "" else null
	# The probe: the tin lantern's pool circle round the lantern, measured by day as well as by night, split by the
	# ground under each pixel (from this layout) and by ring (0-1, 1-2, 2-2.5 tiles out). The farmer's own sprite box
	# is left out. Production frames are measured over the same pixels, split by the prototype's ground.
	var probe_r := float(main.LANTERN_TIERS[0]["radius"]) * px if o3.has("probe") else 0.0
	var probe_img := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8) if probe_r > 0.0 else null
	var feet: Vector2 = main.player.global_position
	var probe := {}
	var colours := {"lantern_pool": Color(1, 0.75, 0.2), "oak": Color(0.9, 0.3, 0.9), "house": Color(0.95, 0.95, 0.4),
		"forest_edge": Color(0.2, 0.5, 1), "play_area": Color(0.3, 0.9, 0.3)}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			var l := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			var w: Vector2 = inv * Vector2(x + 0.5, y + 0.5)
			var t := (w - inner_origin) / px
			var region := "play_area"
			var o := Vector2i(((t - oak_at) * 16.0).floor())
			var hp := Vector2i(((t - house_at) * 16.0).floor())
			if pool_r > 0.0 and w.distance_to(lantern_at) < pool_r:
				region = "lantern_pool"
			elif o.x >= 0 and o.y >= 0 and o.x < oak_image.get_width() and o.y < oak_image.get_height() and oak_image.get_pixel(o.x, o.y).a > 0.5:
				region = "oak"
			elif hp.x >= 0 and hp.y >= 0 and hp.x < house_img.get_width() and hp.y < house_img.get_height() and house_img.get_pixel(hp.x, hp.y).a > 0.5:
				region = "house"
			elif _code(floori(t.x), floori(t.y)) == "T":
				region = "forest_edge"
			lumas[region].append(l)
			lumas["frame"].append(l)
			if probe_r > 0.0 and w.distance_to(lantern_at) < probe_r:
				var off: Vector2 = (w - feet) / px
				if absf(off.x) > 0.5 or off.y < -1.6 or off.y > 0.3:
					var g := _mat(_code(floori(t.x), floori(t.y)))
					var ring := mini(int(w.distance_to(lantern_at) / px), 2)
					for k in ["probe_" + g, "probe_%s_ring%d" % [g, ring]]:
						if not probe.has(k):
							probe[k] = PackedFloat32Array()
						probe[k].append(l)
					probe_img.set_pixel(x, y, {"g": Color(0.3, 0.8, 0.3), "p": Color(0.6, 0.4, 0.2), "w": Color(0.2, 0.4, 0.9)}[g])
			if mask:
				mask.set_pixel(x, y, c.lerp(colours[region], 0.45))
	if mask:
		mask.save_png(mask_path)
	if probe_img:
		probe_img.save_png(ProjectSettings.globalize_path("res://" + str(o3["out"])).get_basename() + "_probe.png")
		for k in probe:
			lumas[k] = probe[k]
		names = names + probe.keys()
	var out := {}
	for nm in names:
		var a: PackedFloat32Array = lumas[nm]
		if a.is_empty():
			continue
		a.sort()
		var sum := 0.0
		var lit := 0
		for v in a:
			sum += v
			if v > 0.12:
				lit += 1
		out[nm] = {"pixels": a.size(), "mean": snappedf(sum / a.size(), 0.0001),
			"p10": snappedf(a[int(a.size() * 0.1)], 0.0001), "p90": snappedf(a[int(a.size() * 0.9)], 0.0001),
			"above_0.12": snappedf(float(lit) / a.size(), 0.0001)}
	return out


# --- ART-005 S2: ground-level fields (art=f1) ------------------------------------------------------------------

# One field on the bed's own 7x4 tiles: the flat soil image (3 px margin round the tiles), then one crop per tile in
# each of the four tile rows, as the game plants. NW ripe (the W-3p crops in clumps), NE growing (production strips,
# stages 1-2), SW just planted and watered (stage 0 on two rows), SE half harvested (two ripe rows, two bare).
func _f1_field(add: Callable, b: Vector2i, w: int, hgt: int, bi: int, crops_b: Array) -> void:
	var names := ["field_dry_a", "field_dry_b", "field_wet_c", "field_dry_d"]
	var fdir: String = F1 if o3.get("art", "") == "f1" else "res://art/style_tests/ART-003/f2/"
	var tex := ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(fdir + names[bi % 4] + ".png")))
	var f2: bool = o3.get("art", "") == "f2"
	add.call(tex, b.x + w / 2.0, b.y + hgt + 3.0 / 16.0, false, Color.WHITE)
	(sorted[sorted.size() - 1] as Array)[1] = b.y - 1.0   # flat: under the crops and the farmer
	var strips := {}
	for kind in ["pumpkin", "turnip", "corn"]:
		strips[kind] = (load("res://art/farm/crop_%s.png" % kind) as Texture2D).get_image()
	var frame := func(kind: String, st: int) -> Texture2D:
		return ImageTexture.create_from_image((strips[kind] as Image).get_region(Rect2i(st * 16, 0, 16, 16)))
	# w3p cells: corn pumpkin beans cabbage kale squash turnip sunflower
	var ripe_rows: Array = [[0], [2], [5, 1], [3, 4]]
	for r in hgt:
		var ry: float = b.y + r + 0.8
		for k in w:
			var j := _hash(b.x + k, b.y + r, 13)
			var t: Texture2D = null
			var dx := ((j % 5) - 2) * 0.03
			if f2:   # S3: plants pull into loose pairs and threes, and sit a little off the ridge line
				dx = (0.09 if k % 3 == 0 else (-0.07 if k % 3 == 2 else 0.0)) + ((j % 5) - 2) * 0.025
			match bi % 4:
				0:
					if j % 9 == 0 and k > 0 and k < w - 1:
						continue   # one picked or failed plant here and there
					var kinds: Array = ripe_rows[r]
					t = crops_b[kinds[(k / 3) % kinds.size()]]
				1:
					var kind: String = ["corn", "pumpkin", "turnip", "turnip"][r]
					t = frame.call(kind, 1 + int(k % 3 == 1 or j % 4 == 0))
				2:
					if r >= 2:
						continue
					t = frame.call(["turnip", "pumpkin"][r], 0)
				3:
					if r >= 2:
						continue
					if k > 4:
						continue   # harvested from the east end
					t = crops_b[[6, 3][r]]
			var v: float = [1.0, 0.92, 1.05][j % 3]
			add.call(t, b.x + k + 0.5 + dx, ry + (((j >> 3) % 3) - 1) * 0.04 if f2 else ry, j % 2 == 0, Color(v, v, v))
