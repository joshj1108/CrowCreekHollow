extends SceneTree

# Lays the PixelLab test art and the closest SpriteCook art side by side on the farm, under the game's own
# lighting (colour grade, day or night tint), and saves a full-size screenshot. Nothing is saved or changed in
# the game; the test patch is added for the shot only. Not headless (it needs a renderer):
#   godot --path . -s tools/pixellab_compare.gd -- out=builds/review/pl_day.png hour=12
# Options: out=PATH (required), hour=H (default 12), weather=KIND (default sunny), frames=N (default 90),
# size=WxH (window size, default 1280x720; the game stretches its 1280x720 canvas to fit),
# set=density (16 px art beside 32 px art at the same world footprint, instead of PixelLab beside SpriteCook).

const PL := "res://art/style_tests/pixellab/"
const SC := "res://art/farm/"
const COLS := 10   # tiles per panel
const ROWS := 7
const GAP := 1     # tiles between the panels

# Each panel: [label, ground, ground tint, ground region, props as [file, x, base y] in 16 px-tile units].
# Art whose ground region is wider than 16 px is drawn smaller to keep one tile's footprint (32 px art at half
# size), so a 32 px tile covers the same ground as a 16 px one.
# The SpriteCook grass is drawn the way the game draws it: frame 6 of its atlas with GRASS_TINT.
var density_panels := [
	["16 px per tile", PL + "ground_moss.png", Color.WHITE, Rect2(0, 0, 16, 16), [
		[PL + "fir_a.png", 6, 64], [PL + "oak_a.png", 52, 68],
		[PL + "boulder_a.png", 14, 104], [PL + "log_a.png", 64, 104]]],
	["32 px per tile (same footprint)", PL + "x32/ground_moss_32.png", Color.WHITE, Rect2(0, 0, 32, 32), [
		[PL + "x32/fir_32.png", 6, 64], [PL + "x32/oak_32.png", 52, 68],
		[PL + "x32/boulder_32.png", 14, 104], [PL + "x32/log_32.png", 64, 104]]],
]
var panels := [
	["PixelLab", PL + "ground_moss.png", Color.WHITE, Rect2(0, 0, 16, 16), [
		[PL + "fir_a.png", 6, 64], [PL + "oak_a.png", 52, 68],
		[PL + "boulder_a.png", 14, 104], [PL + "log_a.png", 64, 104]]],
	["SpriteCook", SC + "ground_grass.png", Color(0.72, 0.8, 0.66), Rect2(32, 16, 16, 16), [
		[SC + "tree_fir_0.png", 6, 64], [SC + "tree_oak_0.png", 60, 64],
		[SC + "boulder_0.png", 22, 100], ["res://art/style_tests/outbuildings/log_0.png", 80, 100]]],
]


func _tex(path: String) -> Texture2D:
	# Loaded from the PNG directly, so the test art needs no import step.
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path)))


func _initialize() -> void:
	var opt := {"hour": "12", "weather": "sunny", "frames": "90"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = opt.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	if opt.get("set", "") == "density":
		panels = density_panels
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 8)   # the slot capture.gd uses
	main.weather_kind = opt["weather"]
	main._apply_weather()
	var hour := float(opt["hour"])
	main.clock = (hour - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	main.player.visible = false
	# Only the world and its grade stay on screen: the HUD layers go.
	for c in main.get_children():
		if c is CanvasLayer and c.layer != 0:
			c.visible = false

	var bed := Node2D.new()
	bed.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bed.scale = Vector2(main.SCALE, main.SCALE)
	bed.z_index = 1000
	var w: int = (COLS * 2 + GAP) * 16
	bed.position = main.player.position - Vector2(w, ROWS * 16) * main.SCALE / 2.0
	main.add_child(bed)
	var labels := CanvasLayer.new()
	labels.layer = 10
	main.add_child(labels)
	for p in panels.size():
		var panel: Array = panels[p]
		var ox: int = p * (COLS + GAP) * 16
		var ground := _tex(panel[1])
		var k: float = 16.0 / (panel[3] as Rect2).size.x   # 0.5 for 32 px art
		for y in ROWS:
			for x in COLS:
				var s := Sprite2D.new()
				s.texture = ground
				s.centered = false
				s.region_enabled = true
				s.region_rect = panel[3]
				s.modulate = panel[2]
				s.scale = Vector2(k, k)
				s.position = Vector2(ox + x * 16, y * 16)
				bed.add_child(s)
		for prop in panel[4]:
			var s := Sprite2D.new()
			s.texture = _tex(prop[0])
			s.centered = false
			s.scale = Vector2(k, k)
			s.position = Vector2(ox + int(prop[1]), int(prop[2]) - s.texture.get_height() * k)
			bed.add_child(s)
		var l := Label.new()
		l.text = "%s   %s" % [panel[0], "%05.2f" % hour]
		l.add_theme_font_size_override("font_size", 22)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 6)
		l.position = Vector2(640 - w * main.SCALE / 2.0 + ox * main.SCALE, 360 - ROWS * 16 * main.SCALE / 2.0 - 34)
		labels.add_child(l)

	for i in int(opt["frames"]):
		await process_frame
	var img := root.get_texture().get_image()
	var out := ProjectSettings.globalize_path("res://" + opt["out"])
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	img.save_png(out)
	print("saved ", opt["out"], " (", img.get_width(), "x", img.get_height(), ")")
	quit()
