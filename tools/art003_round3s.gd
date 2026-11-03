extends "res://tools/art003_round3.gd"

# ART-003 Round 3, steps R3-2 to R3-5 (non-production): the slice refined toward the concept, under the locked
# R3-1 night. The same slice, camera and player spot as Rounds 1 and 2; Round 2 still renders as it was.
#   godot --path . -s tools/art003_round3s.gd -- mode=r3s out=builds/review/ART-003/r3s/night.png hour=21.5
# mode=r3s builds the refined slice; any other mode falls through to art003_round3.gd (production, r2, r3), and every
# option there works here too (measure, masks, visitor, forage, sanity, hold/walk, weather).
#   R3-2 oak:    oak D (192x192, a full crown with open branching) on scattered mossy boulders, leaf drifts at its
#                foot, hand-pixelled shelf fungus on the trunk and two hanging charms.
#   R3-3 ground: two path tilesets mixed per cell for varied edges, worn patches inside the path, the grass
#                fill's repeating speck broken up, ground cover along the verges and at the bases of trees and rocks.
#   R3-4 garden: one raised bed with mixed rows, corn and a bean trellis, a barrel, a crate and a flower pot.
#   R3-5 forest: trees stepping in and out of the edge, fallen logs, ground cover, fog in the corners, and forest
#                beyond the slice's edges so walking doesn't run out of it.
# Options: oak3=d|e (default d); stage=2|3|4|5 builds the steps up to that one (default 5), to compare them.

const R3 := "res://art/style_tests/ART-003/r3/"
const SRC_DIR := "res://art/style_tests/ART-003/src/"


func _r3(name: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(R3 + name)))


# Like _pieces, but from any folder and in left-to-right order, as [rect x, texture].
func _strip(path: String, min_px: int = 10) -> Array:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var out := []
	for sx in w:
		for sy in h:
			if seen[sy * w + sx] or img.get_pixel(sx, sy).a < 0.5:
				continue
			var stack := [Vector2i(sx, sy)]
			seen[sy * w + sx] = 1
			var r := Rect2i(sx, sy, 1, 1)
			var n := 0
			while not stack.is_empty():
				var p: Vector2i = stack.pop_back()
				n += 1
				r = r.expand(p).expand(p + Vector2i.ONE)
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
					var q: Vector2i = p + d
					if q.x >= 0 and q.y >= 0 and q.x < w and q.y < h and not seen[q.y * w + q.x] and img.get_pixel(q.x, q.y).a >= 0.5:
						seen[q.y * w + q.x] = 1
						stack.append(q)
			if n >= min_px:
				out.append([r.position.x, ImageTexture.create_from_image(img.get_region(r))])
	out.sort_custom(func(a, b): return a[0] < b[0])
	return out.map(func(e): return e[1])


func _mean(img: Image, b: Dictionary) -> Color:
	var avg := Color(0, 0, 0, 0)
	for y in 16:
		for x in 16:
			avg += img.get_pixel(int(b["x"]) + x, int(b["y"]) + y) / 256.0
	return avg


# A Wang tileset as {corner key: Rect2}, keyed NW NE SW SE with 1 for the material laid over the base. PixelLab's
# lower/upper labels aren't reliable, so the base is whichever full tile is closest in colour to base_ref.
func _wang_set(path: String, base_ref: Color) -> Array:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path + ".png"))
	img.convert(Image.FORMAT_RGBA8)
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path + ".json"))
	var tiles: Array = meta["tileset_data"]["tiles"]
	var base := ""
	var best := 9.0
	for t in tiles:
		var c: Dictionary = t["corners"]
		if c["NW"] == c["NE"] and c["NE"] == c["SW"] and c["SW"] == c["SE"]:
			var m := _mean(img, t["bounding_box"])
			var dist := Vector3(m.r - base_ref.r, m.g - base_ref.g, m.b - base_ref.b).length()
			if dist < best:
				best = dist
				base = c["NW"]
	var wang := {}
	for t in tiles:
		var c: Dictionary = t["corners"]
		var key := ""
		for k in ["NW", "NE", "SW", "SE"]:
			key += "0" if c[k] == base else "1"
		var b: Dictionary = t["bounding_box"]
		wang[key] = Rect2(b["x"], b["y"], b["width"], b["height"])
	return [ImageTexture.create_from_image(img), wang]


func _cell(bed: Node2D, tex: Texture2D, rect: Rect2, x: int, y: int, mirror: bool) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.region_enabled = true
	s.region_rect = rect
	s.position = Vector2(x, y) * 16
	if mirror:
		var h := (x * 73856093) ^ (y * 19349663)
		s.flip_h = h & 1 == 1
		s.flip_v = h & 2 == 2
	bed.add_child(s)


# Lays one material over the cells that touch it.
func _layer(bed: Node2D, v: Array, set_: Array, mat: int) -> void:
	for y in H:
		for x in W:
			var corners := [v[y][x], v[y][x + 1], v[y + 1][x], v[y + 1][x + 1]]
			if not corners.has(mat):
				continue
			var key := ""
			for c in corners:
				key += "1" if c == mat else "0"
			_cell(bed, set_[0], set_[1].get(key, set_[1]["1111"]), x, y, key == "1111")


# True where every vertex within one step is `want` (so a layer's tiles never paint over another material).
func _ringed(v: Array, x: int, y: int, want: Array) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var yy := y + dy
			var xx := x + dx
			if yy < 0 or xx < 0 or yy > H or xx > W:
				continue
			if not want.has(v[yy][xx]):
				return false
	return true


func _initialize() -> void:
	o3 = _opts()
	if o3["mode"] != "r3s":
		super._initialize()
		return
	var opt := o3
	var stage := int(opt.get("stage", "5"))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = opt.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	var main = load("res://scenes/main.tscn").instantiate()
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
	if night:
		_night(main, opt)   # the locked R3-1 night

	px = main.PX
	origin = main.player.position - PLAYER * px
	var S: int = main.SCALE
	oak_file = R3 + "oak_%s.png" % opt.get("oak3", "d")
	oak_base = Vector2(9.4, 11.2)

	# --- Ground (R3-3) ---------------------------------------------------------------------------------------
	# Vertex codes: 0 grass, 1 path, 3 leaf litter, 4 cobbles, 5 worn path.
	var v := _terrain()
	var litter := FastNoiseLite.new()
	litter.seed = 5
	litter.frequency = 0.17
	var wear := FastNoiseLite.new()
	wear.seed = 29
	wear.frequency = 0.35
	for y in H + 1:
		for x in W + 1:
			if v[y][x] == 2:
				v[y][x] = 0   # the garden is beds on grass
	var base := []   # a copy, so each layer is placed from the plain path/grass map
	for row in v:
		base.append(row.duplicate())
	for y in H + 1:
		for x in W + 1:
			if stage < 3:
				if base[y][x] == 0 and litter.get_noise_2d(x, y) > 0.47:
					v[y][x] = 3   # Round 2's drifts only
				continue
			var under_oak := Vector2((x - 9.4) / 3.4, (y - 10.8) / 1.2).length() < 1.0
			if base[y][x] == 0 and (litter.get_noise_2d(x, y) > 0.44 or under_oak) and _ringed(base, x, y, [0]):
				v[y][x] = 3
			elif base[y][x] == 1 and wear.get_noise_2d(x, y) > 0.2 and _ringed(base, x, y, [1]):
				v[y][x] = 5
	for y in range(10, 14):
		for x in range(16, 20):
			if v[y][x] == 0 and Vector2(x, y).distance_to(Vector2(17.6, 12.0)) < 1.9 and _ringed(base, x, y, [0]):
				v[y][x] = 4

	var bed := Node2D.new()
	bed.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bed.scale = Vector2(S, S)
	bed.position = origin
	bed.z_index = 1
	main.add_child(bed)
	# References for picking each set's base terrain: Round 1's own grass and path fills.
	var grass_ref := Color(0.27, 0.29, 0.13)
	var path_ref := Color(0.45, 0.33, 0.22)
	var path_a := _wang_set(SRC_DIR + "path_tileset", grass_ref)
	var path_b := _wang_set(R3 + "path2_tileset", grass_ref) if stage >= 3 else path_a
	var grass_fill: Rect2 = path_a[1]["0000"]
	# The grass fill repeats its orange speck on a 16 px grid. Two of three plain grass cells get a copy with the
	# speck painted out (each orange pixel takes its left neighbour's colour), so the specks no longer line up.
	var plain := (path_a[0] as ImageTexture).get_image().get_region(Rect2i(grass_fill))
	var calm := plain.duplicate() as Image
	for yy in 16:
		for xx in 16:
			var c := calm.get_pixel(xx, yy)
			if c.r > c.g * 1.25 and c.r > 0.3:
				var n := calm.get_pixel(maxi(xx - 2, 0), yy)
				if n.r > n.g * 1.25:
					n = calm.get_pixel(mini(xx + 2, 15), yy)
				calm.set_pixel(xx, yy, n)
	var calm_tex := ImageTexture.create_from_image(calm)
	# Grass beyond the slice, so walking to its edge doesn't show the farm underneath.
	for y in range(-8, H + 10):
		for x in range(-10, W + 10):
			if x < 0 or y < 0 or x >= W or y >= H:
				_cell(bed, path_a[0], grass_fill, x, y, true)
	# The path: each cell from one of two sets with the same fills, for edges that don't repeat.
	for y in H:
		for x in W:
			var corners := [base[y][x], base[y][x + 1], base[y + 1][x], base[y + 1][x + 1]]
			var key := ""
			for c in corners:
				key += "1" if c == 1 else "0"
			var set_: Array = path_b if _hash(x, y, 11) % 2 == 0 else path_a
			if key == "0000" or key == "1111":
				set_ = path_a
			if key == "0000" and stage >= 3 and _hash(x, y, 19) % 3 != 0:
				_cell(bed, calm_tex, Rect2(0, 0, 16, 16), x, y, true)
				continue
			_cell(bed, set_[0], set_[1].get(key, set_[1]["0000"]), x, y, key == "0000" or key == "1111")
	if stage >= 3:
		# (The mossy-grass set, grassvar_tileset, was tried and dropped: its patches drew as dark outlined holes.)
		_layer(bed, v, _wang_set(R3 + "wear_tileset", path_ref), 5)
	_layer(bed, v, _wang_set("res://art/style_tests/ART-003/r2/litter_tileset", grass_ref), 3)
	_layer(bed, v, _wang_set("res://art/style_tests/ART-003/r2/cobble_tileset", grass_ref), 4)

	# Decals: Round 2's leaves and twigs, and from R3-3 ground cover breaking up the path's edge.
	var decals := _pieces("decals.png", 10).filter(func(t): return t.get_width() <= 9 and t.get_height() <= 9)
	var cover: Array = _strip(R3 + "groundcover.png", 8) if stage >= 3 else []
	for y in H:
		for x in W:
			var h := _hash(x, y, 3)
			var corners := [base[y][x], base[y][x + 1], base[y + 1][x], base[y + 1][x + 1]]
			var edge: bool = corners.has(1) and not (corners[0] == 1 and corners[1] == 1 and corners[2] == 1 and corners[3] == 1)
			var t: Texture2D = null
			if edge and not cover.is_empty() and h % 5 < 2:
				t = cover[h % cover.size()]
			elif (edge and h % 3 == 0) or (not corners.has(1) and h % 7 == 0):
				t = decals[h % decals.size()]
			if t:
				var s := Sprite2D.new()
				s.texture = t
				s.flip_h = h & 8 == 8
				s.position = Vector2(x * 16 + 2 + (h >> 4) % 12, y * 16 + 2 + (h >> 8) % 12)
				bed.add_child(s)

	# --- Props ------------------------------------------------------------------------------------------------
	var props := []   # [texture, x, base y, flip, tint, (z)]
	var fir := _tex("fir.png")
	var maple := _tex("maple.png")
	var under := _tex("undergrowth.png")
	var rocks := _tex("rocks.png")
	var far := Color(0.62, 0.7, 0.78)
	var mid := Color(0.85, 0.88, 0.9)
	var deep := Color(0.42, 0.47, 0.55)   # the forest beyond the slice
	for x in range(-1, 32, 2):
		if x < 18 or x > 24:
			props.append([fir, x + 0.3 * (x % 3), 3.6 + (x % 4) * 0.3, x % 4 == 1, far])
			props.append([fir, x + 1.1, 4.9 + (x % 3) * 0.3, x % 4 == 3, mid])
		if x % 6 == 1 and x > 14:
			props.append([maple, x + 0.4, 5.6, x % 12 == 1, mid])
	for y in range(3, 20, 2):
		props.append([fir, 0.6 + (y % 3) * 0.6, y + 0.5, y % 4 == 1, far])
		props.append([fir, 2.4 + (y % 5) * 0.25, y + 1.4, y % 4 == 3, mid])
		props.append([fir, 28.8 - (y % 3) * 0.5, y + 0.6, y % 4 == 3, far])
		if y % 4 == 1:
			props.append([maple, 26.6, y + 1.2, y % 8 == 1, Color.WHITE])
		if y % 4 == 3 and y > 6:
			props.append([maple, 4.6 + (y % 3) * 0.3, y + 0.8, y % 8 == 3, Color.WHITE])
		props.append([under, 4.0 + (y % 5) * 0.35, y + 1.7, y % 4 == 1, Color.WHITE])
	for x in [3.0, 6.5, 13.5, 16.0, 25.5, 28.0]:
		props.append([under, x, 6.3, int(x) % 2 == 0, Color.WHITE])
	for p in [Vector2(11.4, 14.4), Vector2(19.8, 6.6), Vector2(8.2, 17.1), Vector2(2.2, 18.6)]:
		props.append([under, p.x, p.y, int(p.x) % 2 == 1, Color.WHITE])
	props.append([fir, 9.6, 21.0, false, Color(0.8, 0.82, 0.85)])
	props.append([maple, 28.2, 20.4, true, Color(0.85, 0.85, 0.88)])
	props.append([fir, 30.0, 21.4, true, Color(0.8, 0.82, 0.85)])
	props.append([rocks, 4.9, 11.6, false, Color.WHITE])
	props.append([rocks, 15.9, 6.4, true, Color.WHITE])
	props.append([rocks, 12.5, 16.6, true, Color.WHITE])

	if stage >= 5:
		# R3-5: the edge steps in and out, logs lie in the undergrowth, the forest carries on past the slice.
		for p in [Vector2(6.6, 6.9), Vector2(24.6, 6.4), Vector2(3.6, 16.6), Vector2(27.2, 17.6)]:
			props.append([fir if int(p.x) % 2 == 0 else maple, p.x, p.y, int(p.y) % 2 == 0, mid])
		var log := _r3("log.png")
		props.append([log, 5.8, 15.4, false, Color.WHITE])
		props.append([log, 24.4, 7.4, true, Color(0.9, 0.9, 0.92)])
		for x in range(-9, 40, 2):
			for y in [23.6, 25.4, 27.2]:
				props.append([fir, x + 0.4 * (int(y) % 3), y + 0.3 * (x % 3), (x + int(y)) % 4 == 1, deep])
		for y in range(-4, 26, 2):
			for x in [-1.6, -3.4, -5.2, 31.4, 33.2, 35.0]:
				props.append([fir, x + 0.3 * (y % 3), y + 0.4, (int(x) + y) % 4 == 1, deep])
	if stage >= 3 and not cover.is_empty():
		# Ground cover at the bases of trees and rocks, so nothing stands on bare grass.
		var bases := props.duplicate()
		for i in bases.size():
			var p: Array = bases[i]
			var bx: float = p[1]
			var by: float = p[2]
			if by < 0.0 or by > H + 0.5 or bx < 0.0 or bx > W:
				continue
			var h := _hash(bx, by, 7)
			props.append([cover[h % cover.size()], bx + ((h >> 3) % 5 - 2) * 0.25, by + 0.05, h & 1 == 1, Color.WHITE])

	# --- The oak (R3-2) ---------------------------------------------------------------------------------------
	var oak_tex: Texture2D
	if stage >= 2:
		oak_tex = _r3("oak_%s.png" % opt.get("oak3", "d"))
		props.append([oak_tex, oak_base.x, oak_base.y, false, Color.WHITE])
		# Scattered mossy boulders round its foot instead of the flat ring, each sorted on its own.
		var stones := _strip(R3 + "boulders.png", 12)
		var i := 0
		for a in [150, 175, 200, 228, 256, 290, 318, 345, 15, 40, 70, 112]:
			var r := deg_to_rad(float(a))
			var p := Vector2(9.4 + cos(r) * 3.7, 10.5 + sin(r) * 1.15)
			props.append([stones[(i * 3) % stones.size()], p.x, p.y, i % 2 == 1, Color.WHITE])
			i += 1
		# Shelf fungus on the trunk and charms hanging from two limbs, placed on the oak's art (canvas pixels).
		var top_left := Vector2(oak_base.x - oak_tex.get_width() / 32.0, oak_base.y - oak_tex.get_height() / 16.0)
		var fungus := _strip(R3 + "fungus.png", 4)
		var details := _strip(R3 + "oak_details.png", 10)
		var charms := details.filter(func(t): return t.get_height() > t.get_width() * 1.4)
		for f in [[0, 74, 134], [1, 116, 128], [2, 78, 152]]:
			var t: Texture2D = fungus[f[0] % fungus.size()]
			var at: Vector2 = top_left + Vector2(f[1], f[2]) / 16.0
			props.append([t, at.x, at.y, false, Color.WHITE, -1])
		for c in [[0, 46, 104], [1, 150, 96]]:
			if charms.is_empty():
				break
			var t: Texture2D = charms[c[0] % charms.size()]
			var at: Vector2 = top_left + Vector2(c[1], c[2] + t.get_height()) / 16.0
			props.append([t, at.x, at.y, false, Color.WHITE, -1])
	else:
		props.append([_r2("stone_ring.png"), 9.4, 11.4, false, Color.WHITE, 3])
		oak_tex = _r2("oak_a.png")
		props.append([oak_tex, 9.4, 10.9, false, Color.WHITE])
		oak_file = R2 + "oak_a.png"
		oak_base = Vector2(9.4, 10.9)

	# --- The garden (R3-4) ------------------------------------------------------------------------------------
	var fence := _tex("fence.png")
	for x in [20.0, 24.0]:
		props.append([fence, x, 12.0, false, Color.WHITE])
	props.append([fence, 27.5, 12.0, true, Color.WHITE])
	var beds := _r2("garden_bed.png")
	var bw: float = beds.get_width() / 16.0
	var bh: float = beds.get_height() / 16.0
	var plants := _pieces("crops.png", 30)
	if stage >= 4:
		var more := _strip(R3 + "crops_b_clean.png", 20)
		var b := Vector2(22.2, 16.0)
		props.append([beds, b.x, b.y, false, Color.WHITE, 4])
		# Three rows, one crop each, two sources mixed so the plants in a row aren't identical.
		var rows := [[plants[0], more[0]], [plants[2], more[3]], [plants[1], more[1]]]
		for row in 3:
			var ry: float = b.y - bh + 1.1 + row * 0.75
			var x: float = b.x - bw / 2.0 + 0.8
			var k := 0
			while x < b.x + bw / 2.0 - 0.6:
				var t: Texture2D = rows[row][(k + row) % 2 if _hash(x, ry, 5) % 3 == 0 else 0]
				props.append([t, x, ry + ((_hash(x, ry) % 3) - 1) / 16.0, _hash(x, ry) % 2 == 0, Color.WHITE])
				x += maxf(t.get_width() / 16.0 + 0.2, 0.85)
				k += 1
		var kit := _strip(R3 + "garden_props_clean.png", 30)   # corn, trellis, barrel, crate, flower pot
		# Corn and a bean trellis along the fence, behind the bed.
		for x in [19.8, 20.6, 21.4]:
			props.append([kit[0], x, 12.9 + (int(x * 10) % 3) * 0.05, int(x) % 2 == 0, Color.WHITE])
		props.append([kit[1], 24.2, 12.9, false, Color.WHITE])
		props.append([kit[1], 25.2, 12.95, true, Color.WHITE])
		props.append([kit[2], 19.7, 14.0, false, Color.WHITE])
		props.append([kit[3], 20.8, 14.3, false, Color.WHITE])
		props.append([kit[4], 19.3, 15.7, false, Color.WHITE])
		var pumpkin: Texture2D = more[more.size() - 1]
		for x in [19.9, 20.5, 24.9]:
			props.append([pumpkin, x, 16.9 + (int(x * 10) % 2) * 0.1, int(x * 10) % 2 == 0, Color.WHITE])
	else:
		var bi := 0
		for b in [[22.8, 12.4 + bh], [22.8, 12.8 + bh * 2.0]]:
			props.append([beds, b[0], b[1], false, Color.WHITE, 4])
			for row in 3:
				var kind: Texture2D = plants[(bi * 3 + row) % plants.size()]
				var ry: float = b[1] - bh + 1.15 + row * 0.72
				var step := maxf(kind.get_width() / 16.0 + 0.2, 0.85)
				var x: float = b[0] - bw / 2.0 + 0.8
				while x < b[0] + bw / 2.0 - 0.6:
					props.append([kind, x, ry, _hash(x, ry) % 2 == 0, Color.WHITE])
					x += step
			bi += 1
	var lamps := [Vector2(18.2, 12.1), Vector2(14.4, 13.4)]
	var post := _tex("lantern_post.png")
	for l in lamps:
		props.append([post, l.x, l.y, false, Color.WHITE])

	var oak_z := 2 + int(oak_base.y * 4.0) + (200 if oak_base.y > PLAYER.y + 0.5 else 0)
	for p in props:
		var t: Texture2D = p[0]
		var s := Sprite2D.new()
		s.texture = t
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(S, S)
		s.flip_h = p[3]
		s.modulate = p[4]
		s.centered = false
		s.position = origin + Vector2(p[1] * px - t.get_width() * S / 2.0, p[2] * px - t.get_height() * S)
		if p.size() > 5:
			s.z_index = oak_z + 1 if p[5] == -1 else p[5]   # -1: on the oak (fungus, charms)
		else:
			s.z_index = 2 + int(p[2] * 4.0) + (200 if p[2] > PLAYER.y + 0.5 else 0)
		main.add_child(s)
	main.player.z_index = 2 + int((PLAYER.y + 0.5) * 4.0) + 1

	# --- Atmosphere -------------------------------------------------------------------------------------------
	var shade := Sprite2D.new()
	shade.texture = _edge_layer(Color(0.02, 0.03, 0.05), _shade_strength(night), 0.5, 9)
	var haze := Sprite2D.new()
	haze.texture = _edge_layer(Color(0.72, 0.78, 0.86) if night else Color(0.86, 0.82, 0.74), _haze_strength(night), 0.9, 21)
	for i in 2:
		var layer: Sprite2D = [shade, haze][i]
		layer.centered = false
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		layer.scale = Vector2(px / 4.0, px / 4.0)
		layer.position = origin
		layer.z_index = 2 + int(6.0 * 4.0) + i
		main.add_child(layer)
	if stage >= 5:
		# The forest beyond the slice in shadow, and fog in the corners (the game's fog wisp, faint and still).
		var shadow := Color(0.02, 0.03, 0.05, _shade_strength(night) * 0.9)
		var outer := Rect2(origin + Vector2(-12, -10) * px, Vector2(W + 24, H + 22) * px)
		var hole := Rect2(origin, Vector2(W, H) * px)
		var mask_parent := Node2D.new()
		mask_parent.z_index = 2 + int(6.0 * 4.0)
		for r in [Rect2(outer.position, Vector2(outer.size.x, hole.position.y - outer.position.y)),
				Rect2(Vector2(outer.position.x, hole.end.y), Vector2(outer.size.x, outer.end.y - hole.end.y)),
				Rect2(Vector2(outer.position.x, hole.position.y), Vector2(hole.position.x - outer.position.x, hole.size.y)),
				Rect2(Vector2(hole.end.x, hole.position.y), Vector2(outer.end.x - hole.end.x, hole.size.y))]:
			var cr := ColorRect.new()
			cr.color = shadow
			cr.position = r.position
			cr.size = r.size
			mask_parent.add_child(cr)
		main.add_child(mask_parent)
		var fog := load("res://art/farm/weather_fog.png") as Texture2D
		if fog:
			for f in [[1.5, 3.0, false], [27.0, 2.6, true], [0.5, 16.2, true], [26.5, 16.6, false], [13.0, 2.2, false]]:
				var s := Sprite2D.new()
				s.texture = fog
				s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				s.scale = Vector2(S, S)
				s.flip_h = f[2]
				s.modulate = Color(0.8, 0.85, 0.92, 0.22 if night else 0.16)
				s.position = origin + Vector2(f[0], f[1]) * px
				s.z_index = 2 + int(6.0 * 4.0) + 2
				main.add_child(s)

	if night:
		for l in lamps:
			var light := PointLight2D.new()
			main._glow(light, 4.0 * px / 128.0)
			light.color = Color("ffc070")
			light.energy = main.LANTERN_ENERGY
			light.position = origin + Vector2(l.x * px - px * 0.5, (l.y - 1.75) * px)
			main.add_child(light)

	await _finish(main, opt)
