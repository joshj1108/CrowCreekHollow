extends "res://tools/art003_slice.gd"

# ART-003 Round 2 (non-production): the same slice, camera and player spot as Round 1 (art003_slice.gd), rebuilt
# toward the owner's concept: the new oak on a stone ring, leaf-litter patches, scattered decals, a cobbled
# landing, raised garden beds with mixed planted rows, a near/mid/far forest with haze, and a night preview.
#   godot --path . -s tools/art003_round2.gd -- out=builds/review/ART-003/r2_day.png hour=12
# Extra options: oak=a|b (default a), night=game (keep the game's night grade; default is the preview below).
#
# The night preview only changes how the night is drawn in this shot: it sets the sky tint and the colour grade
# after the game sets them each frame. The game's darkness value (used by sanity, lamps and the night events),
# the clock and every trigger are left exactly as they are.

const R2 := "res://art/style_tests/ART-003/r2/"
# A readable blue-grey night, closer to concept image 03 than NIGHT_TINT (3a3f6e) under the day grade.
const PREVIEW_NIGHT_TINT := Color("7382ae")
const PREVIEW_NIGHT_GRADE := {"saturation": 0.62, "exposure": 0.96, "contrast": 1.04, "shadow_cool": 0.08,
	"vignette": 0.75, "warmth": 0.05}

const LATE_SCRIPT := """
extends Node
var main
var tint: Color
var grade: Dictionary
func _process(_d):
	main.canvas_modulate.color = tint
	main.weather.night_tint = tint
	for k in grade:
		main.grade_mat.set_shader_parameter(k, grade[k])
"""


func _r2(name: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(R2 + name)))


# Separate sprites cut out of a sheet by their connected opaque pixels, largest first; specks are dropped.
func _pieces(name: String, min_px: int = 14) -> Array:
	var img := Image.load_from_file(ProjectSettings.globalize_path(R2 + name))
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var out := []
	for sy in h:
		for sx in w:
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
				out.append([n, ImageTexture.create_from_image(img.get_region(r))])
	out.sort_custom(func(a, b): return a[0] > b[0])
	return out.map(func(e): return e[1])


func _hash(x: float, y: float, k: int = 0) -> int:
	return absi((int(x * 97.0) * 73856093) ^ (int(y * 89.0) * 19349663) ^ (k * 83492791))


# A soft mask image over the slice (4 px per tile): strongest at the edges, none over the clearing.
func _edge_layer(color: Color, strength: float, noise_amt: float, seed_: int) -> ImageTexture:
	var noise := FastNoiseLite.new()
	noise.seed = seed_
	noise.frequency = 0.06
	var img := Image.create(W * 4, H * 4, false, Image.FORMAT_RGBA8)
	for y in H * 4:
		for x in W * 4:
			var t := Vector2(x, y) / 4.0
			var edge := minf(minf(t.x, W - t.x), minf(t.y - 1.0, H - t.y))   # tiles from the nearest edge
			var top := smoothstep(7.5, 3.0, t.y)   # the back of the forest along the top
			var a := maxf(smoothstep(5.5, 1.0, edge), top) * strength
			a *= 1.0 - noise_amt + noise_amt * (noise.get_noise_2d(x, y) * 0.5 + 0.5) * 2.0
			img.set_pixel(x, y, Color(color.r, color.g, color.b, clampf(a, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)


func _initialize() -> void:
	var opt := {"hour": "12", "weather": "sunny", "frames": "90", "oak": "a", "night": "preview"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
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
		_night(main, opt)

	px = main.PX
	origin = main.player.position - PLAYER * px
	var S: int = main.SCALE

	# Ground: grass with organic leaf-litter drifts, the winding path, and a cobbled landing by the garden gate.
	var v := _terrain()
	var noise := FastNoiseLite.new()
	noise.seed = 5
	noise.frequency = 0.17
	for y in H + 1:
		for x in W + 1:
			if v[y][x] == 2:
				v[y][x] = 0   # the garden is beds now, on grass
			if v[y][x] == 0 and noise.get_noise_2d(x, y) > 0.47:
				v[y][x] = 3
	for y in range(10, 14):
		for x in range(16, 20):
			if v[y][x] != 1 and Vector2(x, y).distance_to(Vector2(17.6, 12.0)) < 1.9:
				v[y][x] = 4
	var bed := Node2D.new()
	bed.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bed.scale = Vector2(S, S)
	bed.position = origin
	bed.z_index = 1
	main.add_child(bed)
	_ground(bed, v, "path_tileset.png", "path_tileset.json", 1)
	# Leaf-litter drifts are kept few: the set's leaves are much brighter than the grass. A tint would darken the
	# grass corners of its edge tiles too, so the drifts stay untinted.
	for layer in [[3, "litter_tileset", Color.WHITE], [4, "cobble_tileset", Color.WHITE]]:
		_ground_r2(bed, v, layer[1], layer[0], layer[2])

	# Small decals on the open ground (leaves, pebbles, twigs, mushrooms), and tufts and ferns along the path.
	# Only the small pieces: the biggest leaves read as a tile each at 3x.
	var decals := _pieces("decals.png", 10).filter(func(t): return t.get_width() <= 9 and t.get_height() <= 9)
	for y in H:
		for x in W:
			var h := _hash(x, y, 3)
			var corners := [v[y][x], v[y][x + 1], v[y + 1][x], v[y + 1][x + 1]]
			var edge: bool = corners.has(1) and not (corners[0] == 1 and corners[1] == 1 and corners[2] == 1 and corners[3] == 1)
			if (edge and h % 3 == 0) or (not corners.has(1) and h % 7 == 0):
				var t: Texture2D = decals[h % decals.size()]
				var s := Sprite2D.new()
				s.texture = t
				s.flip_h = h & 8 == 8
				s.position = Vector2(x * 16 + 2 + (h >> 4) % 12, y * 16 + 2 + (h >> 8) % 12)
				bed.add_child(s)

	var props := []   # [texture, x, base y, flip, tint]
	var fir := _tex("fir.png")
	var maple := _tex("maple.png")
	var under := _tex("undergrowth.png")
	var rocks := _tex("rocks.png")
	var far := Color(0.62, 0.7, 0.78)    # the back rows, cooler and dimmer
	var mid := Color(0.85, 0.88, 0.9)
	for x in range(-1, 32, 2):   # far: two staggered rows along the top
		if x < 18 or x > 24:
			props.append([fir, x + 0.3 * (x % 3), 3.6 + (x % 4) * 0.3, x % 4 == 1, far])
			props.append([fir, x + 1.1, 4.9 + (x % 3) * 0.3, x % 4 == 3, mid])
		if x % 6 == 1 and x > 14:
			props.append([maple, x + 0.4, 5.6, x % 12 == 1, mid])
	for y in range(3, 20, 2):   # mid: the side edges, the outer trees dimmer
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
	# Near: trees standing just below the view, their canopies over the bottom edge.
	props.append([fir, 9.6, 21.0, false, Color(0.8, 0.82, 0.85)])
	props.append([maple, 28.2, 20.4, true, Color(0.85, 0.85, 0.88)])
	props.append([fir, 30.0, 21.4, true, Color(0.8, 0.82, 0.85)])

	# The ancient oak on its ring of stones, with rocks and roots around.
	var oak := _r2("oak_%s.png" % opt["oak"])
	var ring := _r2("stone_ring.png")
	props.append([ring, 9.4, 11.4, false, Color.WHITE, 3])   # drawn flat, under the oak
	props.append([oak, 9.4, 10.9, false, Color.WHITE])
	props.append([rocks, 4.9, 11.6, false, Color.WHITE])
	props.append([rocks, 15.9, 6.4, true, Color.WHITE])
	props.append([rocks, 12.5, 16.6, true, Color.WHITE])

	# The garden: a fence along the top, two raised beds with mixed rows, lanterns by the gate.
	var fence := _tex("fence.png")
	for x in [20.0, 24.0]:
		props.append([fence, x, 12.0, false, Color.WHITE])
	props.append([fence, 27.5, 12.0, true, Color.WHITE])
	var beds := _r2("garden_bed.png")
	var plants := _pieces("crops.png", 30)
	var bw: float = beds.get_width() / 16.0
	var bh: float = beds.get_height() / 16.0
	var bi := 0
	for b in [[22.8, 12.4 + bh], [22.8, 12.8 + bh * 2.0]]:
		props.append([beds, b[0], b[1], false, Color.WHITE, 4])
		# Rows inside the bed along its furrows, one kind per row, all six crops across the two beds.
		for row in 3:
			var kind: Texture2D = plants[(bi * 3 + row) % plants.size()]
			var ry: float = b[1] - bh + 1.15 + row * 0.72
			var step := maxf(kind.get_width() / 16.0 + 0.2, 0.85)
			var x0: float = b[0] - bw / 2.0 + 0.8
			var x := x0
			while x < b[0] + bw / 2.0 - 0.6:
				props.append([kind, x, ry, _hash(x, ry) % 2 == 0, Color.WHITE])
				x += step
		bi += 1
	var lamps := [Vector2(18.2, 12.1), Vector2(14.4, 13.4)]
	var post := _tex("lantern_post.png")
	for l in lamps:
		props.append([post, l.x, l.y, false, Color.WHITE])

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
			s.z_index = p[5]   # flat pieces (the ring, the beds) lie on the ground
		else:
			s.z_index = 2 + int(p[2] * 4.0) + (200 if p[2] > PLAYER.y + 0.5 else 0)
		main.add_child(s)
	main.player.z_index = 2 + int((PLAYER.y + 0.5) * 4.0) + 1

	# Atmosphere: shade deepening the forest's interior, and a thin haze over the far rows. Both sit over the
	# back of the forest but under everything from the clearing's edge forward.
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

	if night:
		for l in lamps:
			var light := PointLight2D.new()
			main._glow(light, 4.0 * px / 128.0)
			light.color = Color("ffc070")
			light.energy = main.LANTERN_ENERGY
			light.position = origin + Vector2(l.x * px - px * 0.5, (l.y - 1.75) * px)
			main.add_child(light)

	await _finish(main, opt)


# The night as drawn in the shot: the preview by default, or the game's own with night=game.
# A node that runs after the game sets the tint each frame overrides it (Round 3 replaces this).
func _night(main, opt: Dictionary) -> void:
	if opt["night"] != "preview":
		return
	var late := Node.new()
	var gd := GDScript.new()
	gd.source_code = LATE_SCRIPT
	gd.reload()
	late.set_script(gd)
	late.set("main", main)
	late.set("tint", PREVIEW_NIGHT_TINT)
	late.set("grade", PREVIEW_NIGHT_GRADE)
	late.process_priority = 1000   # after the game sets its own tint each frame
	root.add_child(late)


# How strongly the forest interior is shaded, and how thick the haze over the far rows is (Round 3 tunes them).
func _shade_strength(night: bool) -> float:
	return 0.55 if night else 0.32


func _haze_strength(night: bool) -> float:
	return 0.22 if night else 0.14


# Runs the warm-up frames, saves the shot and quits (Round 3 adds measurements and recording).
func _finish(main, opt: Dictionary) -> void:
	for i in int(opt["frames"]):
		await process_frame
	var img := root.get_texture().get_image()
	var out := ProjectSettings.globalize_path("res://" + opt["out"])
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	img.save_png(out)
	print("saved ", opt["out"], " (", img.get_width(), "x", img.get_height(), ")")
	quit()


# Like _ground, but for a Round 2 tileset over the path layer: only cells touching the material.
func _ground_r2(bed: Node2D, v: Array, name: String, mat: int, tint: Color = Color.WHITE) -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(R2 + name + ".png"))
	img.convert(Image.FORMAT_RGBA8)
	var tex := ImageTexture.create_from_image(img)
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(R2 + name + ".json"))
	var tiles: Array = meta["tileset_data"]["tiles"]
	var grass := ""
	var best := -9.0
	for t in tiles:   # grass is the greener of the two full tiles, whatever the labels say
		var c: Dictionary = t["corners"]
		if c["NW"] == c["NE"] and c["NE"] == c["SW"] and c["SW"] == c["SE"]:
			var b: Dictionary = t["bounding_box"]
			var avg := Color(0, 0, 0)
			for yy in 16:
				for xx in 16:
					avg += img.get_pixel(int(b["x"]) + xx, int(b["y"]) + yy) / 256.0
			if avg.g - maxf(avg.r, avg.b) > best:
				best = avg.g - maxf(avg.r, avg.b)
				grass = c["NW"]
	var wang := {}
	for t in tiles:
		var c: Dictionary = t["corners"]
		var key := ""
		for k in ["NW", "NE", "SW", "SE"]:
			key += "0" if c[k] == grass else "1"
		var b: Dictionary = t["bounding_box"]
		wang[key] = Rect2(b["x"], b["y"], b["width"], b["height"])
	for y in H:
		for x in W:
			var corners := [v[y][x], v[y][x + 1], v[y + 1][x], v[y + 1][x + 1]]
			if not corners.has(mat):
				continue
			var key := ""
			for c in corners:
				key += "1" if c == mat else "0"
			var s := Sprite2D.new()
			s.texture = tex
			s.centered = false
			s.region_enabled = true
			s.region_rect = wang.get(key, wang["1111"])
			s.modulate = tint
			s.position = Vector2(x, y) * 16
			if key == "1111":
				var h := (x * 73856093) ^ (y * 19349663)
				s.flip_h = h & 1 == 1
				s.flip_v = h & 2 == 2
			bed.add_child(s)
