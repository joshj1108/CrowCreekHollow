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
#   built           build the cellar, smokehouse, furnace and woodshed (the workshop goes by the farmhouse)
#   workshop=X,Y    with built, put the workshop's top-left corner on this farm tile (layout coordinates)
#   diary           find the diary in the desk and open it
#   wheel           open the section wheel (wheel=N highlights section N, counting from 0)
#   bag             open the bag
#   title           stay on the title menu instead of starting a game
#   tab=NAME        open a section, e.g. tab=Craft
#   page=N          with tab, open the section's Nth ledger tab (counting from 0)
#   fight           put a creature in front of the player and swing at it, so it is hurt
#   fish            stand below a fishing spot and cast at it
#   visitor=ID      bring tonight's night visitor now: field, knock, quiet, crows, pond, watcher, footsteps
#                   or hollow (use with hour=22 or later)
#                   first is the scripted first night (a new game gets it anyway at 22:00); sighting is the
#                   first Hollow sighting (the night of the walk to the wood's edge)
#   beat=N          with visitor=first, play its beats up to N (0-3; the figure comes at 2); with visitor=sighting,
#                   up to N (0-2: the crows go up at 0, the shape stands at the field's far edge at 1, and goes at 2)
#   happening=ID    jump to a day with this daily happening: pedlar, glint, branch, crow_gifts, mushrooms,
#                   frenzy or neighbour (it is placed, and its morning note shown)
#   decor=A,B       place decor in a row two tiles below the player: lamp, flowers, path, fence, bench, birdbath,
#                   weathervane, sprinkler_big or bell
#   estate          build every house extension and buy every piece of furniture (with paint=ID, paper=ID)
#   feel=SOUND      play an action's sound with its burst (harvest, chop, tree_fall, hoe, ...) and pop up a gain
#   pages=N         Agnes Rook's first N torn pages are found (show them with diary)
#   steps=N         how far the field shadow has crept toward the house, 0 to 8
#   walker          jump to a day a walker waits at the farm's north edge, and stand below them
#   wday=N          with walker, the first day to look from (from 244 all three day walkers wait); wbell: the bell is
#                   hung, so from day 381 the woman in the grey shawl waits too; wedge: day 4, Old Maren waits to be
#                   walked to the wood's edge (the first trek)
#   trek=N          set out on the mill trek and stand in clearing N (0-3 marked, 0-2 dark), below its event, with the walker
#   tevent=ID       with trek, the clearing's event: tree, crows, flood, lights, cairn, fog or hollow (the day sets it otherwise)
#   tdark           with trek, take the dark trail at the fork (trek=1 is then the dark clearing, 2 the mill)
#   tsign           with trek=0, stand below the fingerpost at the fork
#   tread           with trek, the fingerpost reads (as with the Waymarks trail work)
#   nooil           with trek, no lamp oil, so the lantern is out
#   tall            with trek, the tall one stands in the trees beside you (with troute=edge, its eyes in the
#                   second clearing's trees, staying put as on the walk to the wood's edge)
#   troute=ID       with trek, the route: mill (default), orchard, chapel, post, grove, or edge (the tutorial walk to
#                   the wood's edge: trek=0 the fallen tree, trek=1 the stile); tday=N sets the day (and season)
#   tnight          with trek, set out at 19:00 (a night trek)
#   tsearch         with trek and tevent=hollow, reach into the hollow tree (prints whether it held a page)
#   tpages=N        Agnes Rook's first N pages from the wood are found (show them with diary, with pages=N for the farm's)
#   notes           every note is written in the diary (show them with diary)
#   epilogue        the bell's and the grove's last pages are written too (show them with diary)
#   dpage=S,P       with diary, turn to section S's page P (counting from 0; the tabs top to bottom)
#   sound           print how loud each ambience loop is playing when the shot is taken
#   hold=S          for recording (tools/trailer.ps1): instead of a shot, run S more seconds at 30 fps and quit,
#                   with the music stopped (the trailer lays one track over every shot); out= isn't needed
#   walk=D:S,...    with hold, walk direction D (up, down, left, right, or two joined by +) for S seconds, then
#                   the next; "wait" stands still, and "use" swings the tool in hand once
#   quiet           with hold, keep the message line empty

func _initialize() -> void:
	var opt := {"frames": "90", "scale": "0.5"}
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=", true, 1)
		opt[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if not opt.has("out") and not opt.has("hold"):
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
		if opt.has("hold"):
			await _hold(main, opt)
			quit()
			return
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
	if opt.has("estate"):
		for id in main.estate.EXTENSIONS:
			main.estate.built[id] = true
		for id in main.estate.FURNITURE:
			main.estate.furniture[id] = true
		main.estate.paint = str(opt.get("paint", "plain"))
		main.estate.paper = str(opt.get("paper", "plain"))
		main.house_roof_drawn_stage = -1   # redraw the house with them
	if opt.has("built"):
		main.cellar_built = true
		main.smokehouse_built = true
		main.furnace_built = true
		main.woodshed_built = true
		if opt.has("workshop"):
			var w: PackedStringArray = opt["workshop"].split(",")
			main.workshop_tile = Vector2i(int(w[0]) + main.BORDER_X, int(w[1]) + main.BORDER_Y)
		else:
			main._relocate_building("workshop")
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
	if opt.has("walker") and opt.has("wedge"):
		main.day = main.trek.EDGE_DAY
		var et: Vector2i = main.trek._walker_tile("edge")
		main.player.position = main._tile_center(et.x, et.y + 2)
	elif opt.has("walker"):
		main.day = maxi(main.trek.FROM_DAY, int(opt.get("wday", main.trek.FROM_DAY)))
		main.trek.edge_done = true
		if opt.has("wbell"):
			main.projects.bell_day = 1
		while not main.trek._walker_day(main.day):
			main.day += 1
		var wt: Vector2i = main.trek._walker_tile()
		main.player.position = main._tile_center(wt.x, wt.y + 2)
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
	elif opt.has("trek"):
		main.lantern_tier = maxi(main.lantern_tier, 1)
		main.materials["lamp_oil"] = 0 if opt.has("nooil") else 3
		if opt.has("tread"):
			main.trek.works["waymarks"] = true
		if opt.has("tnight"):
			main.current_hour = 19.0
			main.clock = (19.0 - main.START_HOUR) / (main.DAY_END_HOUR - main.START_HOUR) * main.DAY_LENGTH
		if opt.has("tday"):
			main.day = int(opt["tday"])
		main.trek._start(str(opt.get("troute", "mill")))
		if opt.has("tdark"):
			main.trek.dark = true
			main.trek.route = main.trek._steps(main.trek.route_id)["dark"]
			main.trek.events = (main.trek.plan["dark"] as Array).duplicate()
		main.trek.clearing = int(opt["trek"])
		if opt.has("tevent"):
			main.trek.events[main.trek.clearing] = opt["tevent"]
		main.trek._enter_clearing()
		main.trek.oil_seconds = 0.0 if opt.has("nooil") else main.trek.FLASK_SECONDS
		main.trek.lit = not opt.has("nooil")
		var ep: Vector2i = main.trek.event_point
		if opt.has("tsign") and main.trek.sign_tile.x >= 0:
			ep = main.trek.sign_tile + Vector2i(0, -1)
		if ep.x < 0:
			var pts: Array = main.trek._spec()["points"]
			ep = Vector2i(int(pts[-2][0]), int(pts[-2][1]))
		main.player.position = main._tile_center(ep.x, ep.y + 3)
		main.trek.walker_pos = main.player.position + Vector2(0, main.PX * 1.3)
		main.trek.crumbs.assign([main.trek.walker_pos, main.player.position])
		if opt.has("tall"):
			main.trek.tall_on = true
			main.trek.tall_pos = main.player.position + Vector2(main.PX * 3.0, -main.PX * 0.5)
			main.trek.glimpse_until = 9999.0
		if opt.has("tsearch") and main.trek.side_tile.x >= 0:
			var before: int = main.mystery._count(main.mystery.TREK_PAGES)
			main.trek._search_hollow()
			print("hollow tree held a page: ", main.mystery._count(main.mystery.TREK_PAGES) > before)
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
		main.nights.first_beat = -1   # a new game's own first night may have begun during the warm-up frames
		main.nights._begin(opt["visitor"])
		if opt.has("beat"):
			# Wind the first night's start back so its beats up to this one have played.
			if opt["visitor"] == "sighting":
				main.nights.sight_start -= float(main.nights.SIGHTING_BEATS[int(opt["beat"])])
			else:
				main.nights.first_start -= float(main.nights.FIRST_BEATS[int(opt["beat"])])
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
	if opt.has("tpages"):
		for i in int(opt["tpages"]):
			main.mystery.found[main.mystery.TREK_PAGES[i]["id"]] = true
	if opt.has("notes"):
		for tip in main.TIPS:
			main.tips_seen[tip["id"]] = true
	if opt.has("epilogue"):
		main.mystery.found["bell"] = true
		main.mystery.found["grove"] = true
	if opt.has("diary"):
		main._find_diary()
		await process_frame
		if opt.has("dpage"):
			var at: PackedStringArray = opt["dpage"].split(",")
			main.action_bar.open_book_at(int(at[0]), int(at[1]) if at.size() > 1 else 0)
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
		if opt.has("page"):
			main.action_bar.ledger_tabs[opt["tab"]] = int(opt["page"])
		main._toggle_tab(opt["tab"])
		await process_frame
		await process_frame
	if opt.has("hold"):
		await _hold(main, opt)
		quit()
		return
	_save(opt)


# Runs the recording's seconds, walking the path in walk= first. Frames are 1/30 s under --fixed-fps 30.
func _hold(main, opt: Dictionary) -> void:
	if main.music_player:
		main.music_player.stop()
	var left := int(float(opt["hold"]) * 30.0)
	for leg in opt.get("walk", "").split(",", false):
		var part: PackedStringArray = leg.split(":")
		var frames := int(float(part[1]) * 30.0) if part.size() > 1 else 1
		if part[0] == "use":
			main._tool_press = true
			main._swing()
			main._tool_press = false
		var keys: Array = []
		for d in part[0].split("+"):
			if d in ["up", "down", "left", "right"]:
				keys.append("move_" + d)
				Input.action_press("move_" + d)
		for i in mini(frames, left):
			await _hold_frame(main, opt)
		for k in keys:
			Input.action_release(k)
		left -= frames
	for i in maxi(left, 0):
		await _hold_frame(main, opt)


# One recorded frame; with quiet, the message line stays empty so setup messages don't fill the shot.
func _hold_frame(main, opt: Dictionary) -> void:
	if opt.has("quiet"):
		main.message_label.text = ""
	await process_frame


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
