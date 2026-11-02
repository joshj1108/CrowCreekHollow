extends SceneTree

# ART-003 vertical slice (non-production): a small patch of the concept-art homestead built from the PixelLab
# test art in art/style_tests/ART-003/src/, laid over the farm around the player and rendered with the game's own
# camera, colour grade, day/night tint and lantern light. Lantern posts get Godot PointLight2Ds like the player's
# lantern; nothing is baked into the art. Nothing in the game is saved or changed. Not headless (needs a renderer):
#   godot --path . -s tools/art003_slice.gd -- out=builds/review/ART-003/day.png hour=12
# Options: out=PATH (required), hour=H (default 12), weather=KIND (default sunny), lantern=N (default 1 after
# 18:00, else 0), size=WxH (default 1280x720), frames=N (default 90).

const SRC := "res://art/style_tests/ART-003/src/"
const W := 30   # slice size in tiles; the player stands near its middle (15, 9)
const H := 18
const PLAYER := Vector2(15.0, 9.5)

var px: float   # one tile in world units
var origin: Vector2


func _tex(name: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(SRC + name)))


# Terrain on the tile corners (W+1 by H+1): 0 grass, 1 path, 2 soil.
func _terrain() -> Array:
	var v := []
	for y in H + 1:
		v.append([])
		for x in W + 1:
			v[y].append(0)
	var route := [Vector2(1, 18), Vector2(5, 15.5), Vector2(9, 13.5), Vector2(13, 11.5), Vector2(15, 9.5),
		Vector2(17, 7), Vector2(19.5, 5), Vector2(21, 2.5), Vector2(21.5, 0)]
	for i in route.size() - 1:
		for s in 24:
			var p: Vector2 = route[i].lerp(route[i + 1], s / 24.0)
			for y in range(int(p.y) - 2, int(p.y) + 3):
				for x in range(int(p.x) - 2, int(p.x) + 3):
					if x >= 0 and y >= 0 and x <= W and y <= H and Vector2(x, y).distance_to(p) <= 1.15:
						v[y][x] = 1
	for y in range(12, 17):
		for x in range(19, 27):
			v[y][x] = 2
	return v


# A Wang tileset as {corner key: Rect2}, keyed "NW NE SW SE" with 1 for the terrain that is NOT grass.
# PixelLab's lower/upper labels don't always match what is drawn, so grass is whichever full tile is greener.
func _wang(sheet: Image, meta_file: String) -> Dictionary:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SRC + meta_file))
	var tiles: Array = meta["tileset_data"]["tiles"]
	var full := {}
	for t in tiles:
		var c: Dictionary = t["corners"]
		if c["NW"] == c["NE"] and c["NE"] == c["SW"] and c["SW"] == c["SE"]:
			var b: Dictionary = t["bounding_box"]
			var avg := Color(0, 0, 0)
			for y in 16:
				for x in 16:
					avg += sheet.get_pixel(int(b["x"]) + x, int(b["y"]) + y) / 256.0
			full[c["NW"]] = avg.g - avg.r
	var grass: String = "lower" if full.get("lower", 0.0) > full.get("upper", 0.0) else "upper"
	var out := {}
	for t in tiles:
		var c: Dictionary = t["corners"]
		var b: Dictionary = t["bounding_box"]
		var key := ""
		for k in ["NW", "NE", "SW", "SE"]:
			key += "0" if c[k] == grass else "1"
		out[key] = Rect2(b["x"], b["y"], b["width"], b["height"])
	return out


func _ground(bed: Node2D, v: Array, sheet_file: String, meta_file: String, mat: int) -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC + sheet_file))
	img.convert(Image.FORMAT_RGBA8)
	var tex := ImageTexture.create_from_image(img)
	var wang := _wang(img, meta_file)
	for y in H:
		for x in W:
			var corners := [v[y][x], v[y][x + 1], v[y + 1][x], v[y + 1][x + 1]]
			# The path layer covers everything; the soil layer only the cells that touch soil.
			if mat == 2 and not corners.has(2):
				continue
			var key := ""
			for c in corners:
				key += "1" if c == mat else "0"
			var s := Sprite2D.new()
			s.texture = tex
			s.centered = false
			s.region_enabled = true
			s.region_rect = wang.get(key, wang["0000"])
			s.position = Vector2(x, y) * 16
			if key == "0000" or key == "1111":   # mirror plain tiles by position to hide the repeat
				var h := (x * 73856093) ^ (y * 19349663)
				s.flip_h = h & 1 == 1
				s.flip_v = h & 2 == 2
			bed.add_child(s)


func _initialize() -> void:
	var opt := {"hour": "12", "weather": "sunny", "frames": "90"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = opt.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 8)   # the slot capture.gd uses
	main.weather_kind = opt["weather"]
	main._apply_weather()
	var hour := float(opt["hour"])
	main.clock = (hour - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	main.lantern_tier = int(opt.get("lantern", "1" if hour >= 18.0 else "0"))
	main._apply_lantern_radius()
	main.player.facing = Vector2.DOWN
	for c in main.get_children():
		if c is CanvasLayer and c.layer != 0:
			c.visible = false

	px = main.PX
	origin = main.player.position - PLAYER * px
	var bed := Node2D.new()   # the ground, under everything
	bed.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bed.scale = Vector2(main.SCALE, main.SCALE)
	bed.position = origin
	bed.z_index = 1
	main.add_child(bed)
	var v := _terrain()
	_ground(bed, v, "path_tileset.png", "path_tileset.json", 1)
	_ground(bed, v, "soil_tileset.png", "soil_tileset.json", 2)

	# Props: [file, x, base y] in tiles (x is the sprite's centre, base y its bottom edge), optional flip.
	# Props whose base is south of the player draw over them; the rest under, as the game sorts its trees.
	var props := []
	for x in range(-1, 32, 2):   # the forest's back rows along the top, in two staggered rows
		if x < 18 or x > 24:   # the path leaves the clearing through a gap
			props.append(["fir.png", x + 0.3 * (x % 3), 3.6 + (x % 4) * 0.3, x % 4 == 1])
			props.append(["fir.png", x + 1.1, 4.9 + (x % 3) * 0.3, x % 4 == 3])
		if x % 6 == 1 and x > 14:
			props.append(["maple.png", x + 0.4, 5.6, x % 12 == 1])
	for y in range(3, 20, 2):   # dense edges down both sides, staggered so no column repeats
		props.append(["fir.png", 0.6 + (y % 3) * 0.6, y + 0.5, y % 4 == 1])
		props.append(["fir.png", 2.4 + (y % 5) * 0.25, y + 1.4, y % 4 == 3])
		props.append(["fir.png", 28.8 - (y % 3) * 0.5, y + 0.6, y % 4 == 3])
		if y % 4 == 1:
			props.append(["maple.png", 26.6, y + 1.2, y % 8 == 1])
		if y % 4 == 3 and y > 6:
			props.append(["maple.png", 4.6 + (y % 3) * 0.3, y + 0.8, y % 8 == 3])
		props.append(["undergrowth.png", 4.0 + (y % 5) * 0.35, y + 1.7, y % 4 == 1])
	for x in [3.0, 6.5, 13.5, 16.0, 25.5, 28.0]:   # undergrowth fronting the back rows
		props.append(["undergrowth.png", x, 6.3, int(x) % 2 == 0])
	for p in [Vector2(11.4, 14.4), Vector2(17.7, 9.2), Vector2(19.8, 6.6), Vector2(8.2, 17.1),
			Vector2(16.5, 15.5), Vector2(2.2, 18.6), Vector2(27.5, 18.6)]:   # along the path and the near edge
		props.append(["undergrowth.png", p.x, p.y, int(p.x) % 2 == 1])
	props.append(["oak.png", 10.5, 10.6, false])     # the ancient oak, base south-west of the player
	props.append(["rocks.png", 5.6, 10.8, false])
	props.append(["rocks.png", 15.6, 6.2, true])
	props.append(["undergrowth.png", 6.5, 15.8, false])
	props.append(["rocks.png", 12.5, 16.6, true])
	for x in [19.5, 23.5]:   # the garden: fence along the top, crops on the soil, lanterns at the corners
		props.append(["fence.png", x + 0.5, 12.0, false])
	props.append(["fence.png", 27.0, 12.0, true])
	for y in [14.0, 16.2]:
		for x in [21.0, 24.0]:
			props.append(["crops.png", x, y, int(x + y) % 2 == 0])
	var lamps := [Vector2(18.2, 12.1), Vector2(14.4, 13.4)]
	for l in lamps:
		props.append(["lantern_post.png", l.x, l.y, false])

	var textures := {}
	for p in props:
		if not textures.has(p[0]):
			textures[p[0]] = _tex(p[0])
		var t: Texture2D = textures[p[0]]
		var s := Sprite2D.new()
		s.texture = t
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(main.SCALE, main.SCALE)
		s.flip_h = p[3]
		s.centered = false
		s.position = origin + Vector2(p[1] * px - t.get_width() * main.SCALE / 2.0, p[2] * px - t.get_height() * main.SCALE)
		# Sorted by base: south of the player over them, north under, and among themselves by base.
		s.z_index = 2 + int(p[2] * 4.0) + (200 if p[2] > PLAYER.y + 0.5 else 0)
		main.add_child(s)
	main.player.z_index = 2 + int((PLAYER.y + 0.5) * 4.0) + 1

	# The lantern posts' light, made like the player's lantern so the engine lights the night, not the art.
	if hour >= 18.0:
		for l in lamps:
			var light := PointLight2D.new()
			main._glow(light, 4.0 * px / 128.0)   # a four-tile glow, built the way the game builds its lights
			light.color = Color("ffc070")
			light.energy = main.LANTERN_ENERGY
			light.position = origin + Vector2(l.x * px - px * 0.5, (l.y - 1.75) * px)   # the lantern hangs left
			main.add_child(light)

	for i in int(opt["frames"]):
		await process_frame
	var img := root.get_texture().get_image()
	var out := ProjectSettings.globalize_path("res://" + opt["out"])
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	img.save_png(out)
	print("saved ", opt["out"], " (", img.get_width(), "x", img.get_height(), ")")
	quit()
