extends SceneTree

# Starts a new game, sets up a scene and saves a screenshot, for checking art in the game.
# Run with the Godot exe (not headless, which has no renderer):
#   godot --path . -s tools/capture.gd -- out=art/style_tests/x.png inside stage=3
# Options, any order, after "--":
#   out=PATH        where to save (relative to the project), required
#   stage=N         house repair stage 0-3
#   inside          stand in the farmhouse
#   itile=X,Y       with inside, stand on this house tile (interior coordinates)
#   cave            stand in the mining cave
#   tile=X,Y        stand on this farm tile (layout coordinates, before the border)
#   weather=KIND    sunny, cloudy, fog, drizzle, rain, downpour or snow
#   season=NAME     Spring, Summer, Autumn or Winter
#   hour=H          time of day, e.g. 21.5
#   frames=N        frames to run before the shot (default 90)
#   scale=F         shrink the saved image (default 0.5, so it's cheap to look at; 1 for full size)
#   crops=A,B       plant every stage of each crop kind in a row on the first plot, e.g. crops=turnip,corn
#   built           build the cellar, smokehouse, furnace and woodshed
#   notip           hide the tip card, even one shown after the scene is set up
#   wheel           open the section wheel

func _initialize() -> void:
	var opt := {"frames": "90", "scale": "0.5"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if not opt.has("out"):
		push_error("capture.gd: out=PATH is required")
		quit(1)
		return
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._on_title_start("new", 8)
	if main.tip_panel:
		main.tip_panel.visible = false
	if opt.has("season"):
		for d in range(1, 400):
			if main._season_of(main._calendar_date(d)["month"]) == opt["season"]:
				main.day = d
				break
	if opt.has("stage"):
		main.house_stage = int(opt["stage"])
		main._build_interior()
	if opt.has("built"):
		main.cellar_built = true
		main.smokehouse_built = true
		main.furnace_built = true
		main.woodshed_built = true
		main._apply_storage_tiles()
	if opt.has("crops"):
		# One row per kind on the first plot, stages 0 to 3 left to right, and stand just below them.
		var kinds: PackedStringArray = opt["crops"].split(",")
		var origin := Vector2i(main.PLOT_ONE.position.x + main.BORDER_X, main.PLOT_ONE.position.y + main.BORDER_Y)
		for r in kinds.size():
			for s in 4:
				main.crops[origin + Vector2i(s, r)] = {"stage": s, "kind": kinds[r], "days": 0}
		if not opt.has("tile"):
			main.player.position = main._tile_center(origin.x + 2, origin.y + kinds.size() + 1)
	if opt.has("weather"):
		main.weather_kind = opt["weather"]
		main._apply_weather()
	if opt.has("hour"):
		main.clock = (float(opt["hour"]) - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	if opt.has("inside"):
		main._enter_house()
		if opt.has("itile"):
			var it: PackedStringArray = opt["itile"].split(",")
			main.player.position = main._tile_center(main.INT_ORIGIN.x + int(it[0]), main.INT_ORIGIN.y + int(it[1]))
	elif opt.has("cave"):
		main._enter_cave()
	elif opt.has("tile"):
		var t: PackedStringArray = opt["tile"].split(",")
		main.player.position = main._tile_center(int(t[0]) + main.BORDER_X, int(t[1]) + main.BORDER_Y)
	for i in int(opt["frames"]):
		await process_frame
	if opt.has("notip") and main.tip_panel:
		main.tip_panel.visible = false
		await process_frame
	if opt.has("wheel"):
		main._toggle_wheel()
		await process_frame
		await process_frame
	var img := root.get_texture().get_image()
	var sc := float(opt["scale"])
	if sc != 1.0:
		img.resize(int(img.get_width() * sc), int(img.get_height() * sc), Image.INTERPOLATE_NEAREST)
	img.save_png("res://" + opt["out"])
	print("saved ", opt["out"])
	quit()
