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
#   ctile=X,Y       with cave, stand on this cave tile (the exit is at 20,21)
#   tile=X,Y        stand on this farm tile (layout coordinates, before the border)
#   weather=KIND    sunny, cloudy, fog, drizzle, rain, downpour or snow
#   season=NAME     Spring, Summer, Autumn or Winter
#   hour=H          time of day, e.g. 21.5
#   frames=N        frames to run before the shot (default 90)
#   size=WxH        window size (default 1280x720), to check how the game fits other screens
#   crop=X,Y,W,H    keep only this part of the full-size screen (before scale), to look closely at the HUD
#   scale=F         shrink the saved image (default 0.5, so it's cheap to look at; 1 for full size)
#   crops=A,B       plant every stage of each crop kind in a row on the first plot, e.g. crops=turnip,corn
#   lantern=N       lantern tier 0-3 (0 = none)
#   built           build the cellar, smokehouse, furnace and woodshed
#   diary           find the diary in the desk and open it
#   wheel           open the section wheel (wheel=N highlights section N, counting from 0)
#   bag             open the bag
#   title           stay on the title menu instead of starting a game
#   tab=NAME        open a section, e.g. tab=Craft
#   fight           put a creature in front of the player and swing at it, so it is hurt
#   fish            stand below a fishing spot and cast at it
#   visitor=ID      bring tonight's night visitor now: field, knock, quiet, crows, pond, watcher, footsteps
#                   or hollow (use with hour=22 or later)
#   happening=ID    jump to a day with this daily happening: pedlar, glint, branch, crow_gifts, mushrooms,
#                   frenzy or neighbour (it is placed, and its morning note shown)
#   decor=A,B       place decor in a row two tiles below the player: lamp, flowers, path or bell
#   feel=SOUND      play an action's sound with its burst (harvest, chop, tree_fall, hoe, ...) and pop up a gain
#   pages=N         Agnes Rook's first N torn pages are found (show them with diary)
#   steps=N         how far the field shadow has crept toward the house, 0 to 8
#   sound           print how loud each ambience loop is playing when the shot is taken

func _initialize() -> void:
	var opt := {"frames": "90", "scale": "0.5"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if not opt.has("out"):
		push_error("capture.gd: out=PATH is required")
		quit(1)
		return
	# The game opens maximized; shots are taken in a 1280 by 720 window so they compare, unless size= says.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var win: PackedStringArray = opt.get("size", "1280x720").split("x")
	DisplayServer.window_set_size(Vector2i(int(win[0]), int(win[1])))
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	if opt.has("title"):
		# The title menu as the game opens, before a game is started.
		for i in int(opt["frames"]):
			await process_frame
		_save(opt)
		return
	main._on_title_start("new", 8)
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
	if opt.has("lantern"):
		main.lantern_tier = int(opt["lantern"])
		main._apply_lantern_radius()
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
	if opt.has("happening"):
		for d in range(2, 400):
			if main.happenings._pick(d).get("id", "") == opt["happening"]:
				main.day = d
				break
		main._show_message(main.happenings._start_day(true).strip_edges())
		var ht: Vector2i = main.happenings.tile
		if ht.x >= 0 and not opt.has("tile"):
			main.player.position = main._tile_center(ht.x, ht.y + 2)
	if opt.has("steps"):
		main.nights.shadow_steps = int(opt["steps"])
		main._update_shadow_tile()
	if opt.has("hour"):
		main.clock = (float(opt["hour"]) - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
	if opt.has("inside"):
		main._enter_house()
		if opt.has("itile"):
			var it: PackedStringArray = opt["itile"].split(",")
			main.player.position = main._tile_center(main.INT_ORIGIN.x + int(it[0]), main.INT_ORIGIN.y + int(it[1]))
	elif opt.has("cave"):
		main._enter_cave()
		if opt.has("ctile"):
			var ct: PackedStringArray = opt["ctile"].split(",")
			main.player.position = main._tile_center(int(ct[0]), int(ct[1]))
	elif opt.has("tile"):
		var t: PackedStringArray = opt["tile"].split(",")
		main.player.position = main._tile_center(int(t[0]) + main.BORDER_X, int(t[1]) + main.BORDER_Y)
	if opt.has("decor"):
		var at: Vector2i = main._player_tile() + Vector2i(-2, 2)
		for kind in opt["decor"].split(","):
			while not main._spot_ok(at, Vector2i.ONE) and at.x < main.MAP_W - 2:
				at.x += 1
			main.projects.decor[at] = kind
			at.x += 2
		main.projects._stamp()
	for i in int(opt["frames"]):
		await process_frame
	if opt.has("fish") and not main.fish_spots.is_empty():
		var spot: Vector2i = main.fish_spots.keys()[0]
		main.player.position = main._tile_center(spot.x, spot.y + 1)
		main.player.facing = Vector2.UP
		main.fishing._start_fishing(spot)
		await process_frame
	if opt.has("feel"):
		main.money += 12
		main.inventory["crops"] += 1
		main.progression._grant_xp("Farming", 10)
		main.play_sfx(opt["feel"])
		for i in 8:
			await process_frame
	if opt.has("visitor"):
		main.event_fired_day = main.day
		main.nights._begin(opt["visitor"])
		await process_frame
	if opt.has("fight"):
		var at: Vector2 = main.player.position + main.player.facing * main.PX
		var foe: Dictionary = main.combat_sys._new_foe("bat" if main.in_cave else "hollow", Vector2i.ZERO)
		foe["pos"] = at
		foe["home"] = at
		main.foes.append(foe)
		main.active_slot = 0
		main.equipment["hand_r"] = "sharpened_stick"
		main.swing_cool = 0.0
		main._tool_press = true
		main._swing()
		main._tool_press = false
		await process_frame
	if opt.has("sound"):
		print("ambience ", main.ambience.levels)
	if opt.has("pages"):
		for i in int(opt["pages"]):
			main.mystery.found[main.mystery.PAGES[i]["id"]] = true
	if opt.has("diary"):
		main._find_diary()
		await process_frame
		await process_frame
	if opt.has("wheel"):
		main._toggle_wheel()
		if opt["wheel"] != "1":
			main.wheel.highlight = int(opt["wheel"])
			main.wheel.ring.queue_redraw()
		await process_frame
		await process_frame
	if opt.has("bag"):
		main._toggle_bag()
		await process_frame
		await process_frame
	if opt.has("tab"):
		main._toggle_tab(opt["tab"])
		await process_frame
		await process_frame
	_save(opt)


func _save(opt: Dictionary) -> void:
	var img := root.get_texture().get_image()
	if opt.has("crop"):
		var r: PackedStringArray = opt["crop"].split(",")
		img = img.get_region(Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3])))
	var sc := float(opt["scale"])
	if sc != 1.0:
		img.resize(int(img.get_width() * sc), int(img.get_height() * sc), Image.INTERPOLATE_NEAREST)
	img.save_png("res://" + opt["out"])
	print("saved ", opt["out"])
	quit()
