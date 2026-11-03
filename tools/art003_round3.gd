extends "res://tools/art003_round2.gd"

# ART-003 Round 3, steps R3-0 and R3-1 (non-production): the Round 2 slice with a refined night, plus the
# measurements the review needs. Nothing in the game is changed or saved (slot 8, like capture.gd).
#   godot --path . -s tools/art003_round3.gd -- out=builds/review/ART-003/r3/r3_night.png hour=21.5
# Options, on top of Round 2's (hour, weather, frames, size, lantern, oak):
#   mode=r3|r2|production   r3 (default): Round 2's art under the Round 3 night. r2: Round 2 exactly as it was
#                           (its night preview). production: no slice at all, the game as it is at the same spot.
#   sanity=N                set sanity before the shot (low sanity's gloom shows below 30)
#   visitor=ID@X,Y          force tonight's visitor (watcher, field, ...) onto slice tile X,Y
#   forage=X,Y;X,Y          put today's forage (rosehips, chanterelles) on these slice tiles, as readability markers
#   measure                 save <out>.json: region luma (lantern pool, play area, oak, forest edge, frame),
#                           frame time and draw calls with vsync off, and the lights that are on
#   masks                   also save <out>_masks.png, the regions over the shot
#   hold=S walk=D:S,...     record instead of a shot (run under --write-movie --fixed-fps 30), walking as in
#                           capture.gd: D is up, down, left, right or two joined by +
#   tint=RRGGBB weather_dim=F shade=F haze=F saturation=F exposure=F contrast=F vignette=F ...   try a variant of the R3 night
#   probe=lights            no game: a light-limit test of the Compatibility renderer (see _light_probe)
#
# The Round 3 night works like the game's: the same dusk-to-night blend, the same low-sanity lean toward
# SANITY_TINT and the same loss of saturation, only with a lighter night tint and night grade. The game's darkness
# value (sanity drain, lamps, the night's events), the clock and every trigger are left exactly as they are.

# Chosen from five variants on 2026-11-02 (see art/style_tests/ART-003/ROUND3.md). Round 2's preview: tint 7382ae,
# saturation 0.62, exposure 0.96, contrast 1.04, shadow_cool 0.08, vignette 0.75, warmth 0.05.
const R3_NIGHT_TINT := Color("8592b8")
const R3_NIGHT_GRADE := {"saturation": 0.7, "exposure": 1.0, "contrast": 1.12, "shadow_cool": 0.07,
	"vignette": 0.62, "warmth": 0.06}
const R3_SHADE := 0.7    # Round 2: 0.55. A darker forest interior, so the edge stays threatening.
const R3_HAZE := 0.1     # Round 2: 0.22. The pale haze lifted the far rows; less of it keeps them dark.
# The weather overlay takes the night tint too, and rain, snow and fog take half of it (FALL_NIGHT in weather.gd).
# Under the lighter Round 3 tint, half was too little: fog wisps read as pale clouds. The weather layer gets the
# tint darkened to this share instead (1.0 = the same tint as the world, as in the game and Round 2).
const R3_WEATHER_DIM := 0.6

const R3_SCRIPT := """
extends Node
var main
var tint: Color
var grade: Dictionary
var weather_dim: float
func _process(_d):
	var lamp_dark: float = smoothstep(main.DUSK_HOUR, main.DUSK_HOUR + 2.0, main.current_hour)
	lamp_dark *= 1.0 - main.sanity_sys._night_relief()
	var gloom: float = main.sanity_sys._low_sanity_boost() / 0.25
	var sky: Color
	if lamp_dark < main.DUSK_PEAK:
		sky = main._light_tint().lerp(main.DUSK_TINT, lamp_dark / main.DUSK_PEAK)
	else:
		sky = main.DUSK_TINT.lerp(tint, (lamp_dark - main.DUSK_PEAK) / (1.0 - main.DUSK_PEAK))
	sky = sky.lerp(main.SANITY_TINT, gloom * 0.5)
	main.canvas_modulate.color = sky
	main.weather.night_tint = Color(sky.r * weather_dim, sky.g * weather_dim, sky.b * weather_dim)
	for k in grade:
		main.grade_mat.set_shader_parameter(k, grade[k])
	main.grade_mat.set_shader_parameter("saturation", grade["saturation"] * (1.0 - main.SANITY_DESAT * gloom))
"""

var o3 := {}   # this run's options


func _opts() -> Dictionary:
	var opt := {"hour": "12", "weather": "sunny", "frames": "90", "oak": "a", "night": "preview", "mode": "r3"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	return opt


func _initialize() -> void:
	o3 = _opts()
	if o3.get("probe", "") == "lights":
		await _light_probe()
		return
	if o3["mode"] != "production":
		super._initialize()
		return
	# The game as it is, at the same spot, time and weather, with no slice laid over it.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = o3.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 8)
	main.weather_kind = o3["weather"]
	main._apply_weather()
	var hour := float(o3["hour"])
	main.clock = (hour - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	main.lantern_tier = int(o3.get("lantern", "1" if hour >= 18.0 else "0"))
	main._apply_lantern_radius()
	main.player.facing = Vector2.DOWN
	for c in main.get_children():
		if c is CanvasLayer and c.layer != 0:
			c.visible = false
	px = main.PX
	origin = main.player.position - PLAYER * px
	await _finish(main, o3)


func _night(main, opt: Dictionary) -> void:
	if o3["mode"] == "r2":
		super._night(main, opt)
		return
	var late := Node.new()
	var gd := GDScript.new()
	gd.source_code = R3_SCRIPT
	gd.reload()
	late.set_script(gd)
	late.set("main", main)
	# Variants for tuning: tint=RRGGBB and any grade key (saturation=, exposure=, contrast=, ...) on the command line.
	var grade := R3_NIGHT_GRADE.duplicate()
	for k in grade:
		if o3.has(k):
			grade[k] = float(o3[k])
	late.set("tint", Color(o3["tint"]) if o3.has("tint") else R3_NIGHT_TINT)
	late.set("grade", grade)
	late.set("weather_dim", float(o3.get("weather_dim", R3_WEATHER_DIM)))
	late.process_priority = 1000   # after the game sets its own tint each frame
	root.add_child(late)


func _shade_strength(night: bool) -> float:
	return float(o3.get("shade", R3_SHADE)) if night and o3["mode"] == "r3" else super._shade_strength(night)


func _haze_strength(night: bool) -> float:
	return float(o3.get("haze", R3_HAZE)) if night and o3["mode"] == "r3" else super._haze_strength(night)


# Slice tile (x, y) to the farm's world tile under it.
func _world_tile_at(t: Vector2) -> Vector2i:
	var w := origin + t * px
	return Vector2i(floori(w.x / px), floori(w.y / px))


func _finish(main, opt: Dictionary) -> void:
	if o3.has("sanity"):
		main.sanity = float(o3["sanity"])
	if o3.has("forage"):
		main.forage.spots.clear()
		var kinds := ["rosehips", "chanterelles"]
		var i := 0
		for p in str(o3["forage"]).split(";"):
			var xy := p.split(",")
			main.forage.spots[_world_tile_at(Vector2(float(xy[0]), float(xy[1])))] = kinds[i % kinds.size()]
			i += 1
		main.forage.layer.z_index = 2   # over the slice's ground, under its props
		main.forage.layer.queue_redraw()
	if o3.has("visitor"):
		var v := str(o3["visitor"]).split("@")
		var xy := v[1].split(",")
		var t := Vector2(float(xy[0]), float(xy[1]))
		main.nights._begin(v[0])
		main.nights.visitor_tile = _world_tile_at(t)
		main.nights._show_visitor()
		# Sorted with the slice's props at its tile, as the trees are.
		main.nights.layer.z_index = 2 + int((t.y + 1.0) * 4.0) + (200 if t.y + 1.0 > PLAYER.y + 0.5 else 0)
		main.message_label.text = ""

	if o3.has("hold"):
		await _walk(main)
		quit()
		return
	for i in int(opt["frames"]):
		await process_frame
	if o3.has("visitor") or o3.has("forage"):
		main.message_label.text = ""
	var img := root.get_texture().get_image()
	var out := ProjectSettings.globalize_path("res://" + opt["out"])
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	img.save_png(out)
	print("saved ", opt["out"], " (", img.get_width(), "x", img.get_height(), ")")
	if o3.has("measure"):
		var report := {"mode": o3["mode"], "hour": o3["hour"], "weather": o3["weather"],
			"sanity": main.sanity, "size": [img.get_width(), img.get_height()]}
		report["regions"] = _measure(main, img, out.get_basename() + "_masks.png" if o3.has("masks") else "")
		report["lights"] = _lights_on(main)
		report["perf"] = await _perf()
		var f := FileAccess.open(out.get_basename() + ".json", FileAccess.WRITE)
		f.store_string(JSON.stringify(report, "  "))
		f.close()
		print("measured ", out.get_basename() + ".json")
	quit()


# Walks the legs in walk= under --fixed-fps 30, as capture.gd's hold does.
func _walk(main) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	var left := int(float(o3["hold"]) * 30.0)
	for leg in str(o3.get("walk", "")).split(",", false):
		var part: PackedStringArray = leg.split(":")
		var frames := int(float(part[1]) * 30.0) if part.size() > 1 else 1
		var keys: Array = []
		for d in part[0].split("+"):
			if d in ["up", "down", "left", "right"]:
				keys.append("move_" + d)
				Input.action_press("move_" + d)
		for i in mini(frames, left):
			main.message_label.text = ""
			await process_frame
		for k in keys:
			Input.action_release(k)
		left -= frames
	for i in maxi(left, 0):
		main.message_label.text = ""
		await process_frame


# Luma per region of the shot. Regions come from the slice's layout in screen space, so every mode (production
# included) is measured over the same pixels. Each pixel goes to the first region it falls in: the lantern pool
# (the lantern's radius around the farmer), the oak (its sprite's opaque pixels), the forest edge (within three
# tiles of the slice's sides and bottom, or in its back rows above y = 6), else the play area.
# Luma is Rec. 709 on the saved sRGB values, after the grade.
func _measure(main, img: Image, mask_path: String) -> Dictionary:
	var inv: Transform2D = main.get_viewport().get_canvas_transform().affine_inverse()
	var pool_r := 0.0
	if main.lantern_tier > 0 and main.lantern_light.enabled:
		pool_r = float(main.LANTERN_TIERS[main.lantern_tier - 1]["radius"]) * px
	var lantern_at: Vector2 = main.lantern_light.global_position
	var oak := Image.load_from_file(ProjectSettings.globalize_path(R2 + "oak_%s.png" % o3["oak"]))
	var S: float = main.SCALE
	var oak_pos := origin + Vector2(9.4 * px - oak.get_width() * S / 2.0, 10.9 * px - oak.get_height() * S)
	var names := ["lantern_pool", "oak", "forest_edge", "play_area", "frame"]
	var lumas := {}
	for n in names:
		lumas[n] = PackedFloat32Array()
	var mask := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8) if mask_path != "" else null
	var colours := {"lantern_pool": Color(1, 0.75, 0.2), "oak": Color(0.9, 0.3, 0.9), "forest_edge": Color(0.2, 0.5, 1),
		"play_area": Color(0.3, 0.9, 0.3)}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			var l := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			var w: Vector2 = inv * Vector2(x + 0.5, y + 0.5)
			var t := (w - origin) / px
			var region := "play_area"
			var o := Vector2i(((w - oak_pos) / S).floor())
			var edge := minf(minf(t.x, W - t.x), H - t.y)
			if pool_r > 0.0 and w.distance_to(lantern_at) < pool_r:
				region = "lantern_pool"
			elif o.x >= 0 and o.y >= 0 and o.x < oak.get_width() and o.y < oak.get_height() and oak.get_pixel(o.x, o.y).a > 0.5:
				region = "oak"
			elif edge < 3.0 or t.y < 6.0:
				region = "forest_edge"
			lumas[region].append(l)
			lumas["frame"].append(l)
			if mask:
				mask.set_pixel(x, y, c.lerp(colours[region], 0.45))
	if mask:
		mask.save_png(mask_path)
	var out := {}
	for n in names:
		var a: PackedFloat32Array = lumas[n]
		if a.is_empty():
			continue
		a.sort()
		var sum := 0.0
		var lit := 0
		for v in a:
			sum += v
			if v > 0.12:
				lit += 1
		out[n] = {"pixels": a.size(), "mean": snappedf(sum / a.size(), 0.0001),
			"p10": snappedf(a[int(a.size() * 0.1)], 0.0001), "p90": snappedf(a[int(a.size() * 0.9)], 0.0001),
			"above_0.12": snappedf(float(lit) / a.size(), 0.0001)}
	return out


# Every PointLight2D that is on, by colour and reach, to count how many can overlap the farm at once.
func _lights_on(main) -> Array:
	var out := []
	for n in main.find_children("*", "PointLight2D", true, false):
		var l := n as PointLight2D
		if l.enabled and l.is_visible_in_tree():
			var reach := 0.0
			if l.texture:
				reach = l.texture.get_width() * l.texture_scale * 0.5 / px
			out.append({"at_tiles": [snappedf(l.global_position.x / px, 0.1), snappedf(l.global_position.y / px, 0.1)],
				"colour": l.color.to_html(false), "energy": l.energy, "reach_tiles": snappedf(reach, 0.1)})
	return out


# Frame cost with vsync off over 240 frames, after 60 to settle, on this machine.
func _perf() -> Dictionary:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var vp := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	for i in 60:
		await process_frame
	var times := PackedFloat32Array()
	var cpu := 0.0
	var gpu := 0.0
	var draws := 0.0
	var objects := 0.0
	var prims := 0.0
	var proc := 0.0
	var last := Time.get_ticks_usec()
	for i in 240:
		await process_frame
		var now := Time.get_ticks_usec()
		times.append((now - last) / 1000.0)
		last = now
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(vp)
		gpu += RenderingServer.viewport_get_measured_render_time_gpu(vp)
		draws += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		objects += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	times.sort()
	var n := float(times.size())
	var mean := 0.0
	for t in times:
		mean += t / n
	return {"adapter": RenderingServer.get_video_adapter_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"frame_ms_mean": snappedf(mean, 0.01), "frame_ms_median": snappedf(times[int(n * 0.5)], 0.01),
		"frame_ms_p95": snappedf(times[int(n * 0.95)], 0.01), "render_cpu_ms": snappedf(cpu / n, 0.01),
		"render_gpu_ms": snappedf(gpu / n, 0.01), "process_ms": snappedf(proc / n, 0.01),
		"draw_calls": roundi(draws / n), "objects": roundi(objects / n), "primitives": roundi(prims / n)}


# How many 2D lights the Compatibility renderer draws, and where it stops. A black-tinted screen holds n small
# lights (n=, default 16) in a grid, over one big white rect (items=one, a single canvas item, like the farm's
# ground drawn by main.gd) or over one small white rect each (items=many). A light that is drawn makes a bright
# spot; the spots are counted at each light's centre. Saves <out>.png and <out>.json.
func _light_probe() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var n := int(o3.get("n", "16"))
	var one: bool = o3.get("items", "one") == "one"
	var scene := Node2D.new()
	root.add_child(scene)
	var cm := CanvasModulate.new()
	cm.color = Color(0.1, 0.1, 0.1)
	scene.add_child(cm)
	if one:
		var big := ColorRect.new()
		big.color = Color.WHITE
		big.position = Vector2(10, 10)
		big.size = Vector2(1260, 700)
		scene.add_child(big)
	var grad := GradientTexture2D.new()
	grad.width = 40
	grad.height = 40
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(1.0, 0.5)
	var g := Gradient.new()
	g.set_color(0, Color.WHITE)
	g.set_color(1, Color(1, 1, 1, 0))
	grad.gradient = g
	# offscreen=K adds K more lights first, beyond the right edge but still over the big rect (which then runs on
	# off-screen, as the farm's ground does), to see whether lights outside the view use up the item's share.
	var off := int(o3.get("offscreen", "0"))
	if one and off > 0:
		scene.get_child(1).size.x = 4000.0
	for i in off:
		var l := PointLight2D.new()
		l.texture = grad
		l.position = Vector2(2000 + (i % 10) * 125, 50 + (i / 10) * 110)
		scene.add_child(l)
	var cols := 10
	var centres := []
	for i in n:
		var c := Vector2(70 + (i % cols) * 125, 50 + (i / cols) * 110)
		centres.append(c)
		if not one:
			var small := ColorRect.new()
			small.color = Color.WHITE
			small.position = c - Vector2(40, 40)
			small.size = Vector2(80, 80)
			scene.add_child(small)
		var l := PointLight2D.new()
		l.texture = grad
		l.position = c
		l.energy = 1.0
		scene.add_child(l)
	for i in 30:
		await process_frame
	var img := root.get_texture().get_image()
	var lit := 0
	var dark := []
	for i in centres.size():
		if img.get_pixelv(Vector2i(centres[i])).r > 0.5:
			lit += 1
		else:
			dark.append(i)
	var settings := {}
	for p in ProjectSettings.get_property_list():
		var name: String = p["name"]
		if name.begins_with("rendering/limits/opengl") or (name.begins_with("rendering/") and "light" in name and "2d" in name):
			settings[name] = ProjectSettings.get_setting(name)
	var out := ProjectSettings.globalize_path("res://" + o3["out"])
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	img.save_png(out)
	var report := {"renderer": RenderingServer.get_current_rendering_method(), "adapter": RenderingServer.get_video_adapter_name(),
		"version": Engine.get_version_info()["string"], "lights": n, "items": "one" if one else "many",
		"offscreen": off, "lit": lit, "unlit_indices": dark, "settings": settings}
	var f := FileAccess.open(out.get_basename() + ".json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()
	print(JSON.stringify(report))
	quit()
