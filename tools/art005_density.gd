extends SceneTree

# ART-005 E1 (non-production): the density and presentation test harness. It builds one shared scene
# (art/style_tests/ART-005/e0/layout.txt, made by tools/art005_e0.py) at one art density and renders it the way a
# pixel-art presentation would, so 16, 32 and 64 art px per tile can be compared on the same 16 x 16 logical grid.
# It never loads the game: no main.gd, no save, no live farm, no project setting is changed. Not headless (it needs
# a renderer). Everything it writes goes under out=, which should be in builds/ (gitignored).
#   godot --path . -s tools/art005_density.gd -- density=32 task=stills hour=12 out=builds/review/ART-005/stills
#
# Options (any order, after "--"):
#   density=16|32|64     art px per logical tile (the grid stays 16 x 16 units)
#   art=a|ph             a: column A, the existing 16 px art (W-3/W-4 house, oak and beds, production ground,
#                        fence and farmer), only with density=16; ph (default): the formula-drawn placeholders;
#                        pl: E2-PL PixelLab trial files from pl/<density>/ where they exist, placeholders elsewhere
#                        g2: ART-005 M0 files from pl/g2/<density>/ (the complete blockout mockup, tools/art005_m0.py)
#                        where they exist, placeholders elsewhere; window lights at the sprite's window centres
#                        g3: ART-005 H1 files from pl/g3/<density>/ (the PixelLab Pro edit, tools/art005_h1.py), as g2
#                        g4: ART-005 S1 simpler-roof mockups from pl/g4/<var>/<density>/ (tools/art005_s1.py), as g2
#   var=sa|sb            g4 only: sa side gable, sb side gable with a front gable (default sa)
#                        g5: ART-005 S2 log-cabin SA and schematic stages from pl/g5/<var>/<density>/ (tools/art005_s2.py),
#                        as g4; var=log|st0|st1|st2|st3 (default log)
#   winlights=0          g2-g5: no window lights at night (the unlit, boarded stages)
#   ext=porch,dormer     g2 only: also draw these extension layers (ext_<name>_day|night.png) over the house
#   hour=12|21.5         day (sunny daylight tint) or night (production NIGHT_TINT, lantern and window lights)
#   task=stills          one PNG per res x framing (res=, framing=), plus a native-resolution PNG
#   task=walk            the walking route at a fixed step (fps=, default 50), saving a 1:1 screen crop per frame
#                        (crop=WxH, default 480x270) and a per-frame CSV of what was drawn where
#   task=probe           the clarity probe (a 1-texel and a 2-texel checker) at eight camera sub-pixel offsets
#   task=perf            real time, vsync off: frame time, draw calls, memory, for secs= seconds of walking
#   task=swing           standing still, lantern swinging, at night (fps=, frames=)
#   res=1280x720,1920x1080,...   output sizes (default 1920x1080)
#   framing=int|fill|today       int: native render, integer scale, borders where it doesn't divide (default)
#                        fill: native render, integer scale rounded to fill the screen (shows more or less world)
#                        today: no native render; the world drawn straight at the output size with today's zoom
#                        (tile = 48 px at 720p, canvas_items-like), the baseline
#   camera=smooth|snap|free  smooth (default for int/fill): world snapped to art px, the remainder applied as a
#                        whole-screen-px offset after scaling; snap: art-px steps only; free: no snapping
#                        (today always uses free, as the game does)
#   lantern=smooth|stepped   smooth: the game's LANTERN_SMOOTH radial gradient (default); stepped: LIGHTING_V2's
#                        8 bands with a Bayer dither, in art px of this density, snapped to the art grid
#   ui=screen|world|none     screen: a HUD drawn on its own output-resolution canvas; world: the same HUD inside
#                        the native world render (to show why not); none (default)
#   grain=F              the grade's film grain (default 0: off, so pixel measurements are not noise)
#   out=DIR              output folder (required)

const ROOT := "res://art/style_tests/ART-005/"
const TILE := 16.0                          # logical units per tile (the gameplay grid)
const SPEED := 60.0                         # units/s: the game's 180 px/s at SCALE 3 = 3.75 tiles/s
const NIGHT_TINT := Color("3a3f6e")         # main.gd
const DAY_TINT := Color(1.0, 0.99, 0.96)    # main.gd WEATHER_LIGHT.sunny
const LANTERN_COLOR := Color("ffd38a")
const LANTERN_ENERGY := 0.5
const LANTERN_RADIUS := 4.0                 # tiles (the Brass Lantern)
const LIGHT_BANDS := 8
const BAYER_4 := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
const VIEW_TILES := Vector2(30.0, 16.875)   # the integer framing: tile = 64 screen px at 1080p
# Column A: the existing 16 px art, by placeholder name: path, frames across.
const ART_A := {
	"house_day": ["res://art/style_tests/ART-003/w3p/house/house_w3p_a_day.png", 1],
	"house_night": ["res://art/style_tests/ART-003/w3p/house/house_w3p_a_night.png", 1],
	"oak": ["res://art/style_tests/ART-003/w3/oak/oak_w3.png", 1],
	"bed": ["res://art/style_tests/ART-003/w3b/garden/bed_w3b.png", 1],
	"fence": ["res://art/farm/fence.png", 1],
	"farmer_walk": ["res://art/player/farmer_walk_right.png", 8],
	"farmer_idle": ["res://art/player/farmer_idle_right.png", 8],
}
# Column A crops: four frames of the W-3p crop strip (16 x 32 each), standing in for the two kinds x two stages.
const A_CROPS := {"crop_a1": 0, "crop_a2": 1, "crop_b1": 4, "crop_b2": 5}

var opts := {}
var D := 16
var art := "ph"
var night := false
var framing := "int"
var cam_mode := "smooth"
var out_dir := ""
var tex_bytes := 0                          # texture memory of the art loaded, RGBA8

var layout := {}
var world_vp: SubViewport
var out_vp: SubViewport
var display: Sprite2D
var world: Node2D
var camera: Camera2D
var player: Node2D
var body: Sprite2D
var lantern: Sprite2D
var lantern_light: PointLight2D
var grade: ColorRect
var ui_screen: CanvasLayer
var ui_world: CanvasLayer
var probe: Sprite2D
var body_frames := 5
var walk_frames := []                        # frame indices of the walk cycle
var idle_frame := 0
var out_size := Vector2i(1920, 1080)
var native := Vector2i.ZERO
var k := 1                                   # integer scale
var zoom := 1.0                              # native px per logical unit
var margin := 0                              # extra native px round the world render (smooth camera)
var border := Vector2.ZERO                   # where the native image's (0,0) lands on screen, before the offset
var cam_float := Vector2.ZERO
var cam_applied := Vector2.ZERO
var disp_offset := Vector2.ZERO
var player_float := Vector2.ZERO
var cam_offset := Vector2.ZERO
var lantern_phase := 0.0
var walk_dist := 0.0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.split("=", true, 1)
		opts[kv[0]] = kv[1] if kv.size() > 1 else "1"
	D = int(opts.get("density", "16"))
	art = opts.get("art", "ph")
	night = float(opts.get("hour", "12")) >= 19.0
	framing = opts.get("framing", "int")
	cam_mode = opts.get("camera", "smooth")
	out_dir = opts.get("out", "")
	if out_dir == "" or (art == "a" and D != 16):
		push_error("art005_density: out= is required, and art=a needs density=16")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + out_dir))
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(960, 540)
	RenderingServer.set_default_clear_color(Color.BLACK)
	_run.call_deferred()


func _p(path: String) -> String:
	return ProjectSettings.globalize_path("res://" + out_dir + "/" + path)


# --- Loading ---------------------------------------------------------------------------------------------------

func _tex(name: String) -> Texture2D:
	var path := ""
	if art == "a" and ART_A.has(name):
		path = ART_A[name][0]
	elif art == "a" and (name == "house_shadow" or name == "oak_shadow" or name == "farmer_shadow" or name == "lantern" or name == "probe"):
		path = ROOT + "placeholder/16/%s.png" % name        # column A has no separate shadows or lantern
	elif art == "a" and A_CROPS.has(name):
		path = "res://art/style_tests/ART-003/w3p/garden/crops_w3p.png"
	elif art == "pl" and FileAccess.file_exists(ROOT + "pl/%d/%s.png" % [D, name]):
		path = ROOT + "pl/%d/%s.png" % [D, name]           # E2-PL: a PixelLab trial piece; others stay placeholders
	elif art == "g2" and FileAccess.file_exists(ROOT + "pl/g2/%d/%s.png" % [D, name]):
		path = ROOT + "pl/g2/%d/%s.png" % [D, name]        # M0: the blockout mockup; others stay placeholders
	elif art == "g3" and FileAccess.file_exists(ROOT + "pl/g3/%d/%s.png" % [D, name]):
		path = ROOT + "pl/g3/%d/%s.png" % [D, name]        # H1: the PixelLab Pro edit, M0 alpha; others placeholders
	elif art == "g4" and FileAccess.file_exists(ROOT + "pl/g4/%s/%d/%s.png" % [opts.get("var", "sa"), D, name]):
		path = ROOT + "pl/g4/%s/%d/%s.png" % [opts.get("var", "sa"), D, name]   # S1: the simpler-roof mockups
	elif art == "g5" and FileAccess.file_exists(ROOT + "pl/g5/%s/%d/%s.png" % [opts.get("var", "log"), D, name]):
		path = ROOT + "pl/g5/%s/%d/%s.png" % [opts.get("var", "log"), D, name]   # S2: log cabin and stage schematics
	else:
		path = ROOT + "placeholder/%d/%s.png" % [D, name]
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if art == "a" and A_CROPS.has(name):
		img = img.get_region(Rect2i(A_CROPS[name] * 16, 0, 16, 32))
	tex_bytes += img.get_width() * img.get_height() * 4
	return ImageTexture.create_from_image(img)


func _load_layout() -> void:
	var f := FileAccess.open(ROOT + "e0/layout.txt", FileAccess.READ)
	var rows: Array[String] = []
	var objs := []
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line.begins_with("#") or line == "":
			continue
		var p := line.split(" ")
		match p[0]:
			"map":
				layout["size"] = Vector2i(int(p[1]), int(p[2]))
				layout["vig"] = Vector2(float(p[4]), float(p[5]))
				layout["vsize"] = Vector2(float(p[6]), float(p[7]))
			"row":
				rows.append(p[1])
			"obj":
				objs.append([p[1], Vector2(float(p[2]), float(p[3]))])
			"route":
				var pts := []
				for i in range(1, p.size()):
					var xy := p[i].split(",")
					pts.append(Vector2(float(xy[0]), float(xy[1])))
				layout["route"] = pts
			"still":
				var xy := p[1].split(",")
				layout["still"] = Vector2(float(xy[0]), float(xy[1]))
	layout["rows"] = rows
	layout["objs"] = objs


# Logical units for a point in vignette tiles.
func _u(v: Vector2) -> Vector2:
	return (v + layout["vig"]) * TILE


# Column A's ground: the production dual-grid sets (grass, soil, path) drawn into one image at 16 px, as main.gd
# draws them (grass is the filled frame with GRASS_TINT, mirrored by tile hash).
const DUAL_FRAME_BY_MASK := [-1, 15, 8, 9, 0, 11, 14, 7, 13, 4, 1, 10, 3, 2, 5, 6]
const GRASS_TINT := Color(0.72, 0.8, 0.66)


func _ground_a() -> Texture2D:
	var size: Vector2i = layout["size"]
	var rows: Array = layout["rows"]
	var out := Image.create(size.x * 16, size.y * 16, false, Image.FORMAT_RGBA8)
	var grass := Image.load_from_file(ProjectSettings.globalize_path("res://art/farm/ground_grass.png"))
	grass.convert(Image.FORMAT_RGBA8)
	for y in size.y:
		for x in size.x:
			var h := absi(int(x * 73856093) ^ int(y * 19349663)) % 4
			var t := grass.get_region(Rect2i((6 % 4) * 16, (6 / 4) * 16, 16, 16))
			if h & 1:
				t.flip_x()
			if h & 2:
				t.flip_y()
			for py in 16:
				for px in 16:
					out.set_pixel(x * 16 + px, y * 16 + py, t.get_pixel(px, py) * GRASS_TINT)
	for layer in [["soil", "S"], ["path", "P"]]:
		var src := Image.load_from_file(ProjectSettings.globalize_path("res://art/farm/ground_%s.png" % layer[0]))
		src.convert(Image.FORMAT_RGBA8)
		for y in range(0, size.y + 1):
			for x in range(0, size.x + 1):
				var mask := 0
				if _is(rows, x - 1, y - 1, layer[1]): mask |= 1
				if _is(rows, x, y - 1, layer[1]): mask |= 2
				if _is(rows, x - 1, y, layer[1]): mask |= 4
				if _is(rows, x, y, layer[1]): mask |= 8
				var fr: int = DUAL_FRAME_BY_MASK[mask]
				if fr < 0:
					continue
				out.blend_rect(src, Rect2i((fr % 4) * 16, (fr / 4) * 16, 16, 16), Vector2i(x * 16 - 8, y * 16 - 8))
	tex_bytes += out.get_width() * out.get_height() * 4
	return ImageTexture.create_from_image(out)


func _is(rows: Array, x: int, y: int, c: String) -> bool:
	if y < 0 or y >= rows.size() or x < 0 or x >= rows[0].length():
		return false
	return rows[y][x] == c


# --- The scene -------------------------------------------------------------------------------------------------

func _sprite(tex: Texture2D, at: Vector2, frames := 1, density := -1) -> Sprite2D:
	# A sprite whose bottom centre sits on `at` (logical units), shown at 1 texel = 16/density units.
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	var dd := float(D if density < 0 else density)
	var fw := tex.get_width() / frames
	if frames > 1:
		s.region_enabled = true
		s.region_rect = Rect2(0, 0, fw, tex.get_height())
	s.offset = Vector2(-fw * 0.5, -tex.get_height())
	s.scale = Vector2.ONE * (TILE / dd)
	s.position = at
	return s


func _build_world() -> void:
	world = Node2D.new()
	var dens := 16 if art == "a" else D
	var ground := Sprite2D.new()
	ground.texture = _ground_a() if art == "a" else _tex("ground")
	ground.centered = false
	ground.scale = Vector2.ONE * (TILE / dens)
	ground.z_index = -2
	world.add_child(ground)
	var shadows := Node2D.new()
	shadows.z_index = -1
	world.add_child(shadows)
	var sorted := Node2D.new()
	sorted.y_sort_enabled = true
	world.add_child(sorted)
	for o in layout["objs"]:
		var name: String = o[0]
		var at := _u(o[1])
		var tname := name
		if name == "house":
			tname = "house_night" if night else "house_day"
		sorted.add_child(_sprite(_tex(tname), at, 1, dens))
		if name == "house" and art == "g2":
			for e in String(opts.get("ext", "")).split(",", false):
				var et := _tex("ext_%s_%s" % [e, "night" if night else "day"])
				# extension layers share the house's top-left; a taller layer (the porch) hangs below its anchor
				var es := _sprite(et, at + Vector2(0, (et.get_height() - 320) * TILE / D), 1, dens)
				es.z_index = 1
				sorted.add_child(es)
		if name == "house" or name == "oak":
			shadows.add_child(_sprite(_tex(name + "_shadow"), at, 1, 16 if art == "a" else D))
	# the farmer: body, its shadow, and a lantern that swings on its own
	player = Node2D.new()
	sorted.add_child(player)
	var fsh := _sprite(_tex("farmer_shadow"), Vector2.ZERO, 1, 16 if art == "a" else D)
	fsh.z_index = -1
	fsh.z_as_relative = false
	player.add_child(fsh)
	if art == "a":
		body = _sprite(_tex("farmer_walk"), Vector2.ZERO, 8, 16)
		body_frames = 8
		walk_frames = [0, 1, 2, 3, 4, 5, 6, 7]
	else:
		body = _sprite(_tex("farmer"), Vector2.ZERO, 5, D)
		body_frames = 5
		walk_frames = [1, 2, 3, 4]
	player.add_child(body)
	lantern = Sprite2D.new()
	lantern.texture = _tex("lantern")
	lantern.centered = false
	var ld := 16 if art == "a" else D
	lantern.offset = Vector2(-lantern.texture.get_width() * 0.5, 0)
	lantern.scale = Vector2.ONE * (TILE / ld)
	player.add_child(lantern)
	# the clarity probe: one tile on the grass south of the lane
	probe = _sprite(_tex("probe"), _u(Vector2(15.5, 15.0)), 1, 16 if art == "a" else D)
	probe.visible = opts.get("task", "stills") == "probe"
	world.add_child(probe)
	# lights
	if night:
		lantern_light = PointLight2D.new()
		lantern_light.color = LANTERN_COLOR
		lantern_light.energy = LANTERN_ENERGY
		_light_texture(lantern_light, LANTERN_RADIUS, opts.get("lantern", "smooth") == "stepped")
		world.add_child(lantern_light)
		# the two front windows of the house image (12 x 10 tiles, bottom centre on its anchor), one tile below
		var house_at := Vector2.ZERO
		for o in layout["objs"]:
			if o[0] == "house":
				house_at = o[1]
		# g2: the exact window centres, HOUSE_SPRITE_WINDOWS (3.0, 7.0) and (8.94, 7.0) of the 12 x 10 sprite
		var wins := [Vector2(-3.0, -3.0), Vector2(2.94, -3.0)] if (art == "g2" or art == "g3" or art == "g4" or art == "g5") else [Vector2(-3.1, -2.8), Vector2(3.1, -2.8)]
		for wo in (wins if str(opts.get("winlights", "1")) != "0" else []):
			var w := PointLight2D.new()
			w.color = LANTERN_COLOR
			w.energy = LANTERN_ENERGY
			_light_texture(w, 2.0, false)
			w.position = _u(house_at) + wo * TILE
			world.add_child(w)


func _light_texture(light: PointLight2D, radius_tiles: float, stepped: bool) -> void:
	if not stepped:
		var g := Gradient.new()
		g.set_color(0, Color.WHITE)
		g.set_color(1, Color.BLACK)
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 256
		t.height = 256
		light.texture = t
		light.texture_scale = radius_tiles * TILE * 2.0 / 256.0
		return
	# LIGHTING_V2's stepped falloff, one cell per art px of this density
	var cells := int(radius_tiles * 2.0 * D)
	var img := Image.create(cells, cells, false, Image.FORMAT_RGBA8)
	var half := cells * 0.5
	for cy in cells:
		for cx in cells:
			var d := Vector2(cx + 0.5 - half, cy + 0.5 - half).length() / half
			var dither: float = (BAYER_4[(cy % 4) * 4 + cx % 4] + 0.5) / 16.0
			var v := floorf(clampf(1.0 - d, 0.0, 1.0) * LIGHT_BANDS + dither) / LIGHT_BANDS
			img.set_pixel(cx, cy, Color(v, v, v))
	light.texture = ImageTexture.create_from_image(img)
	light.texture_scale = TILE / D


# --- Presentation ----------------------------------------------------------------------------------------------

func _setup_view(res: Vector2i) -> void:
	out_size = res
	var vt := VIEW_TILES
	if framing == "today":
		k = 1
		zoom = 3.0 * res.y / 720.0
		native = res
		margin = 0
	else:
		var n0 := Vector2(vt.x * D, round(vt.y * D))
		if framing == "fill":
			k = maxi(1, roundi(res.y / n0.y))
			native = Vector2i(ceili(float(res.x) / k), ceili(float(res.y) / k))
		else:
			k = maxi(1, mini(floori(res.x / n0.x), floori(res.y / n0.y)))
			native = Vector2i(n0)
		zoom = D / TILE
		margin = 1 if cam_mode == "smooth" else 0
	var free := framing == "today" or cam_mode == "free"
	world_vp.size = native + Vector2i(2, 2) * margin
	world_vp.snap_2d_transforms_to_pixel = not free
	world_vp.snap_2d_vertices_to_pixel = not free
	camera.zoom = Vector2(zoom, zoom)
	out_vp.size = res
	border = ((Vector2(res) - Vector2(native) * k) * 0.5).floor()
	display.scale = Vector2(k, k)
	if ui_screen != null:
		_layout_ui(ui_screen, Vector2(res), 1.0)
	if ui_world != null:
		_layout_ui(ui_world, Vector2(native), float(native.y) / res.y)


func _update_camera() -> void:
	cam_float = player_float + cam_offset
	var free := framing == "today" or cam_mode == "free"
	if free:
		cam_applied = cam_float
		player.position = player_float
	else:
		cam_applied = (cam_float * zoom).round() / zoom
		player.position = (player_float * zoom).round() / zoom
	camera.position = cam_applied
	var off := Vector2.ZERO
	if not free and cam_mode == "smooth":
		off = (-(cam_float - cam_applied) * zoom * k).round() - Vector2(margin, margin) * k
	disp_offset = off
	display.position = border + off
	# the lantern: hand height, swinging; on the art grid unless the camera is free
	var amp := 0.06 if walk_dist <= 0.0 else 0.12
	var sw := Vector2(sin(lantern_phase) * amp, absf(cos(lantern_phase)) * amp * 0.25) * TILE
	var lp := Vector2(0.3, -0.78) * TILE + sw
	if not free:
		lp = (lp * zoom).round() / zoom
	lantern.position = lp
	if lantern_light != null:
		var at := player.position + lp + Vector2(0, 0.28 * TILE)
		if opts.get("lantern", "smooth") == "stepped":
			at = (at * D / TILE).round() * TILE / D
		lantern_light.position = at


func _set_body_frame(walking: bool) -> void:
	var f := 0
	if walking:
		f = walk_frames[int(walk_dist / (0.375 * TILE)) % walk_frames.size()]
	else:
		f = 0
	var fw := body.texture.get_width() / body_frames
	body.region_rect = Rect2(f * fw, 0, fw, body.texture.get_height())


func _build_ui(native_canvas: bool) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 20
	var bar := HBoxContainer.new()
	bar.name = "bar"
	var slot_tex: Texture2D = load("res://art/ui/slot.png")
	for i in 8:
		var t := TextureRect.new()
		t.texture = slot_tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		bar.add_child(t)
	layer.add_child(bar)
	var label := Label.new()
	label.name = "label"
	label.text = "Day 12  ·  21:30  ·  Autumn  —  Brass Lantern" if night else "Day 12  ·  12:00  ·  Autumn"
	label.add_theme_color_override("font_color", Color("f0e6d2"))
	label.add_theme_color_override("font_outline_color", Color("1a1410"))
	layer.add_child(label)
	return layer


func _layout_ui(layer: CanvasLayer, size: Vector2, s: float) -> void:
	var slot := roundf(80.0 * size.y / 1080.0 / maxf(s, 0.001) * s)
	var bar: HBoxContainer = layer.get_node("bar")
	for c in bar.get_children():
		c.custom_minimum_size = Vector2(slot, slot)
	bar.add_theme_constant_override("separation", int(slot * 0.08))
	bar.size = Vector2(slot * 8 + slot * 0.08 * 7, slot)
	bar.position = Vector2((size.x - bar.size.x) * 0.5, size.y - slot * 1.25)
	var label: Label = layer.get_node("label")
	label.add_theme_font_size_override("font_size", maxi(6, roundi(28.0 * size.y / 1080.0)))
	label.add_theme_constant_override("outline_size", maxi(1, roundi(4.0 * size.y / 1080.0)))
	label.position = Vector2(size.x * 0.03, size.y * 0.03)


func _build_viewports() -> void:
	world_vp = SubViewport.new()
	world_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	world_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	world_vp.transparent_bg = false
	world_vp.add_child(world)
	camera = Camera2D.new()
	world_vp.add_child(camera)
	var cm := CanvasModulate.new()
	cm.color = NIGHT_TINT if night else DAY_TINT
	world_vp.add_child(cm)
	# the colour grade as committed at HEAD (frozen copy; VIS-002's uncommitted grade edits are not used)
	var gl := CanvasLayer.new()
	gl.layer = 10
	grade = ColorRect.new()
	grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sh := Shader.new()
	sh.code = FileAccess.get_file_as_string(ROOT + "grade_head.gdshader.txt")
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("grain", float(opts.get("grain", "0")))
	grade.material = mat
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gl.add_child(grade)
	world_vp.add_child(gl)
	if opts.get("ui", "none") == "world":
		ui_world = _build_ui(true)
		world_vp.add_child(ui_world)
	out_vp = SubViewport.new()
	out_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	out_vp.transparent_bg = false
	out_vp.add_child(world_vp)
	display = Sprite2D.new()
	display.texture = world_vp.get_texture()
	display.centered = false
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	out_vp.add_child(display)
	if opts.get("ui", "none") == "screen":
		ui_screen = _build_ui(false)
		out_vp.add_child(ui_screen)
	root.add_child(out_vp)
	var preview := TextureRect.new()
	preview.texture = out_vp.get_texture()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(preview)


func _frames(n: int) -> void:
	for i in n:
		await RenderingServer.frame_post_draw


func _res_list() -> Array:
	var out := []
	for r in opts.get("res", "1920x1080").split(","):
		var p: PackedStringArray = r.split("x")
		out.append(Vector2i(int(p[0]), int(p[1])))
	return out


func _tag() -> String:
	return "%s%d_%s_%s" % ["A" if art == "a" else ("L" if art == "pl" else ("G" if art == "g2" else ("H" if art == "g3" else ("S" + str(opts.get("var", "sa")).to_upper() if art == "g4" else ("V" + str(opts.get("var", "log")).to_upper() if art == "g5" else "P"))))), D, "night" if night else "day", framing]


# --- Tasks -----------------------------------------------------------------------------------------------------

func _run() -> void:
	_load_layout()
	_build_world()
	_build_viewports()
	var still: Vector2 = layout["still"]
	var vs: Vector2 = layout["vsize"]
	cam_offset = Vector2(0.0, (vs.y * 0.5 - still.y) * TILE)
	player_float = _u(still)
	_set_body_frame(false)
	var task: String = opts.get("task", "stills")
	match task:
		"stills":
			await _task_stills()
		"probe":
			await _task_probe()
		"walk":
			await _task_walk()
		"swing":
			await _task_swing()
		"perf":
			await _task_perf()
	quit()


func _task_stills() -> void:
	for res in _res_list():
		_setup_view(res)
		_update_camera()
		await _frames(4)
		var tag := "%s_%dp" % [_tag(), res.y]
		if opts.get("ui", "none") != "none":
			tag += "_ui" + opts["ui"]
		out_vp.get_texture().get_image().save_png(_p(tag + ".png"))
		if framing != "today" and opts.get("native", "1") == "1":
			world_vp.get_texture().get_image().save_png(_p(tag + "_native.png"))
		print("ART005 still %s k=%d native=%s tiles=%.2fx%.2f border=%s" % [tag, k, native,
			native.x / zoom / TILE, native.y / zoom / TILE, border])


func _task_probe() -> void:
	var res: Vector2i = _res_list()[0]
	_setup_view(res)
	var steps := 8
	var csv := FileAccess.open(_p("%s_%dp_%s_probe.csv" % [_tag(), res.y, cam_mode]), FileAccess.WRITE)
	csv.store_line("step,cam_dx_units,x,y,w,h")
	var base := player_float
	for i in steps:
		# the camera moves by 1/8 of a native-16 px each step: sub-pixel for every density
		player_float = base + Vector2(i * 0.125, 0.0)
		_update_camera()
		await _frames(3)
		var img := out_vp.get_texture().get_image()
		var p := (probe.position - cam_applied) * zoom * k + Vector2(native) * 0.5 * k + display.position + Vector2(margin, margin) * k
		var tile := TILE * zoom * k
		var r := Rect2i(Vector2i(p - Vector2(tile * 0.5, tile) - Vector2(4, 4)), Vector2i(int(tile) + 8, int(tile) + 8))
		r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		img.get_region(r).save_png(_p("%s_%dp_%s_probe_%d.png" % [_tag(), res.y, cam_mode, i]))
		csv.store_line("%d,%.3f,%d,%d,%d,%d" % [i, i * 0.125, r.position.x, r.position.y, r.size.x, r.size.y])
	print("ART005 probe done")


func _route_step(dist: float) -> Dictionary:
	var pts: Array = layout["route"]
	var left := dist
	for i in range(pts.size() - 1):
		var a := _u(pts[i])
		var b := _u(pts[i + 1])
		var l := a.distance_to(b)
		if left <= l:
			return {"pos": a + (b - a) * (left / l), "done": false}
		left -= l
	return {"pos": _u(pts[pts.size() - 1]), "done": true}


# A screen crop of the given size centred on the farmer (the camera sits above the farmer, so the matched
# vignette is framed; the offset is constant because the camera follows the farmer).
func _player_crop(res: Vector2i, crop: Vector2i) -> Rect2i:
	var c := Vector2(res) * 0.5 + (-cam_offset + Vector2(0, -TILE)) * zoom * k
	return Rect2i(Vector2i(c) - crop / 2, crop).intersection(Rect2i(Vector2i.ZERO, res))


func _task_walk() -> void:
	var res: Vector2i = _res_list()[0]
	_setup_view(res)
	var fps := float(opts.get("fps", "50"))
	var dt := 1.0 / fps
	var cw: PackedStringArray = str(opts.get("crop", "480x270")).split("x")
	var crop := Vector2i(int(cw[0]), int(cw[1]))
	var skip := int(opts.get("skip", "0"))
	var count := int(opts.get("frames", "150"))
	var tag := "%s_%dp_%s_walk%d" % [_tag(), res.y, cam_mode, int(fps)]
	if opts.get("lantern", "smooth") == "stepped":
		tag += "_stepped"
	DirAccess.make_dir_recursive_absolute(_p(tag))
	var csv := FileAccess.open(_p(tag + ".csv"), FileAccess.WRITE)
	csv.store_line("frame,player_x,player_y,cam_float_x,cam_applied_x,disp_off_x,world_screen_x,player_screen_x,lantern_x")
	var ref := _u(Vector2(17.0, 10.5))      # a fixed world point (the house's base), for the world's screen motion
	for f in skip + count:
		walk_dist = f * dt * SPEED
		var st := _route_step(walk_dist)
		player_float = st["pos"]
		lantern_phase = f * dt * TAU * 1.6
		_set_body_frame(true)
		_update_camera()
		await _frames(1)
		if f < skip:
			continue
		var sx := func(p: Vector2) -> float:
			return (p.x - cam_applied.x) * zoom * k + native.x * 0.5 * k + display.position.x + margin * k
		csv.store_line("%d,%.4f,%.4f,%.4f,%.4f,%.1f,%.3f,%.3f,%.3f" % [f - skip, player_float.x, player_float.y,
			cam_float.x, cam_applied.x, disp_offset.x, sx.call(ref), sx.call(player.position), lantern.position.x])
		var img := out_vp.get_texture().get_image()
		img.get_region(_player_crop(res, crop)).save_png(_p("%s/f_%04d.png" % [tag, f - skip]))
	print("ART005 walk %s frames=%d" % [tag, count])


func _task_swing() -> void:
	var res: Vector2i = _res_list()[0]
	_setup_view(res)
	var fps := float(opts.get("fps", "50"))
	var count := int(opts.get("frames", "100"))
	var cw: PackedStringArray = str(opts.get("crop", "480x270")).split("x")
	var crop := Vector2i(int(cw[0]), int(cw[1]))
	var tag := "%s_%dp_%s_swing" % [_tag(), res.y, cam_mode]
	if opts.get("lantern", "smooth") == "stepped":
		tag += "_stepped"
	DirAccess.make_dir_recursive_absolute(_p(tag))
	for f in count:
		lantern_phase = f / fps * TAU * 1.6
		_update_camera()
		await _frames(1)
		var img := out_vp.get_texture().get_image()
		img.get_region(_player_crop(res, crop)).save_png(_p("%s/f_%04d.png" % [tag, f]))
	print("ART005 swing %s" % tag)


func _task_perf() -> void:
	var res: Vector2i = _res_list()[0]
	_setup_view(res)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var wvp := world_vp.get_viewport_rid()
	var ovp := out_vp.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(wvp, true)
	RenderingServer.viewport_set_measure_render_time(ovp, true)
	var secs := float(opts.get("secs", "8"))
	var warm := 120
	var times := PackedFloat64Array()
	var gpu_w := 0.0
	var gpu_o := 0.0
	var cpu_w := 0.0
	var draws := 0
	var n := 0
	var t0 := Time.get_ticks_usec()
	var last := t0
	var f := 0
	while true:
		walk_dist = fmod((Time.get_ticks_usec() - t0) / 1e6 * SPEED, 18.0 * TILE)
		player_float = _route_step(walk_dist)["pos"]
		lantern_phase = (Time.get_ticks_usec() - t0) / 1e6 * TAU * 1.6
		_set_body_frame(true)
		_update_camera()
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		f += 1
		if f > warm:
			times.append((now - last) / 1000.0)
			gpu_w += RenderingServer.viewport_get_measured_render_time_gpu(wvp)
			gpu_o += RenderingServer.viewport_get_measured_render_time_gpu(ovp)
			cpu_w += RenderingServer.viewport_get_measured_render_time_cpu(wvp) + RenderingServer.viewport_get_measured_render_time_cpu(ovp)
			draws = maxi(draws, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
			n += 1
		last = now
		if n > 0 and (now - t0) / 1e6 > secs:
			break
	var sorted_t := Array(times)
	sorted_t.sort()
	var mean := 0.0
	for t in times:
		mean += t
	mean /= maxi(1, times.size())
	var line := {
		"tag": "%s_%dp_%s" % [_tag(), res.y, cam_mode], "frames": n, "mean_ms": snappedf(mean, 0.001),
		"p50_ms": snappedf(sorted_t[sorted_t.size() / 2], 0.001), "p95_ms": snappedf(sorted_t[int(sorted_t.size() * 0.95)], 0.001),
		"p99_ms": snappedf(sorted_t[int(sorted_t.size() * 0.99)], 0.001),
		"gpu_world_ms": snappedf(gpu_w / n, 0.001), "gpu_output_ms": snappedf(gpu_o / n, 0.001),
		"cpu_render_ms": snappedf(cpu_w / n, 0.001), "draw_calls": draws,
		"texture_mem_mb": snappedf(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0, 0.01),
		"video_mem_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.01),
		"art_rgba_mb": snappedf(tex_bytes / 1048576.0, 0.01), "native": "%dx%d" % [world_vp.size.x, world_vp.size.y],
		"scale": k, "adapter": RenderingServer.get_video_adapter_name(),
		"api": RenderingServer.get_video_adapter_api_version(),
		"method": str(ProjectSettings.get_setting("rendering/renderer/rendering_method")),
		"godot": Engine.get_version_info()["string"],
	}
	var f2 := FileAccess.open(_p(line["tag"] + "_perf.json"), FileAccess.WRITE)
	f2.store_string(JSON.stringify(line))
	print("ART005 perf ", JSON.stringify(line))
