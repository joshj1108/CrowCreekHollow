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
#   mine=DX,DY      with cave and ctile, face the ore at that offset and start working it
#   lit             diagnostic: lift the darkness (canvas tint white) just before the shot; not a gameplay view
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
#   fire=H          the hearth burning with H hours of fuel (FARMHOUSE-INTERIOR-001; 0.5 is a low fire)
#   shutters        place the window shutters and bar them tonight (the house windows show them shut)
#   clock           buy the long-case clock (its pendulum swings)
#   perf            before the shot, time 300 frames with vsync off and print "PERF" lines (mean and 95th
#                   percentile frame time, and the CPU's process time), for checking a change's cost
#   built           build the cellar, smokehouse, furnace and woodshed (the workshop goes by the farmhouse)
#   workshop=X,Y    with built, put the workshop's top-left corner on this farm tile (layout coordinates)
#   diary           find the diary in the desk and open it
#   wheel           open the section wheel (wheel=N highlights section N, counting from 0); wpad shows the controller's
#                   prompts; wcycle (with hold=) from 2.4 s closes it, opens it, steps right three times, steps back
#                   three times and closes it, 0.45 s apart, by injected key presses
#   bag             open the bag
#   debug           open the developer's world-state panel (debug builds); dweather=KIND, dtemp=F and dpause set
#                   its overrides first (CCH-CONSOLIDATED-003)
#   title           stay on the title menu instead of starting a game
#   pack            UI checks: put a mix of crops, fish, eggs, milk, a bandage and a crow charm in the pack
#   ipick=KEY       the Inventory item whose details show, e.g. ipick=pack:egg or ipick=mat:wood
#   focus=N         with tab, move the focus to the section's Nth focusable button (0 = the first tile)
#   tab=NAME        open a section, e.g. tab=Craft
#   page=N          with tab, open the section's Nth ledger tab (counting from 0)
#   fight           put a creature in front of the player and swing at it, so it is hurt
#   creatures=S     with cave: the bat, lizard and snake in a row right of the farmer (use ctile=16,19) in state S (idle, move, alert,
#                   attack, hurt, death), the game frozen with the animation at cprog=F (0-1); "live" leaves them as
#                   real foes for hold= clips (chp=N sets their HP); ckinds=A,B picks the creatures, cface=left turns
#                   them; oldfoes draws the old SpriteCook sheets (CCH-CONSOLIDATED-003 Phase E BEFORE shots)
#   fish            stand below a fishing spot and cast at it
#   visitor=ID      bring tonight's night visitor now: field, knock, quiet, crows, pond, watcher, footsteps
#                   or hollow (use with hour=22 or later)
#                   first is the scripted first night (a new game gets it anyway at 22:00); sighting is the
#                   first Hollow sighting (the night of the walk to the wood's edge)
#   prog=F          with visitor, how far its answer has come (0 to 1): the ring round a held figure's head
#   raid=KIND       bring tonight's raid now (fox, crows or barn; needs hens with built, or a coop: add hens=N)
#   hens=N          put N hens in a coop placed beside the player
#   sanity=N        set sanity (the madness tiers start under 60, 40 and 20); with madness, show each tier's sights now
#   madness         with sanity, bring a figure at the screen's edge and (under 20) a crop that isn't there
#   blight=N        the field shadow creeps N steps tonight, blighting the crops nearest it (use with crops=)
#   beat=N          with visitor=first, play its beats up to N (0-3; the figure comes at 2); with visitor=sighting,
#                   up to N (0-2: the crows go up at 0, the shape stands at the field's far edge at 1, and goes at 2)
#   happening=ID    jump to a day with this daily happening: pedlar, glint, branch, crow_gifts, mushrooms,
#                   frenzy or neighbour (it is placed, and its morning note shown)
#   decor=A,B       place decor in a row two tiles below the player (snare comes with a hare, broken is a torn fence): lamp, flowers, path, fence, bench, birdbath,
#                   weathervane, sprinkler_big or bell
#   rich            give 2000 coins and 40 of every material (no skill change), so some builds can be pressed (UI checks)
#   well=N          the well: 0 broken (a new game's), 1 repaired, 2 repaired with the cistern and hose (E3)
#   estate          build every house extension and buy every piece of furniture (with paint=ID, paper=ID)
#   feel=SOUND      play an action's sound with its burst (harvest, chop, tree_fall, hoe, ...) and pop up a gain
#   pages=N         Agnes Rook's first N torn pages are found (show them with diary)
#   steps=N         how far the field shadow has crept toward the house, 0 to 8
#   walker          jump to a day a walker waits at the farm's north edge, and stand below them
#   wday=N          with walker, the first day to look from (from 244 all three day walkers wait); wbell: the bell is
#                   hung, so from day 381 the woman in the grey shawl waits too; wedge: day 4, Old Maren waits to be
#                   walked to the wood's edge (the first trek)
#   folk=ID         a neighbour visits the farm today (mill, orchard, chapel or post) and you stand below them; use
#                   with hour= 9 to 16 (wday=N sets the day, default 60). fscene=N plays their Nth friendship scene
#                   (0-3) in the dialogue box, turned to page fpage=P; fsay shows today's line instead (fexpr=FACE)
#   ending=ID       play an ending's sequence over the farm (bell, elias or hollow): epage=N shows line N (-1 the
#                   title, past the last line the credits); use with hour= for the light behind it
#   trek=N          set out on the mill trek and stand in clearing N (0-3 marked, 0-2 dark), below its event, with the walker
#   hp=N food=N water=N warmth=N   HUD checks: set health and the body needs (e.g. hp=3 food=12 for warning states)
#   diarynew        HUD checks: the diary is found and has a page unread
#   tevent=ID      with trek, the clearing's event: tree, crows, flood, lights, cairn, fog or hollow (the day sets it otherwise)
#   tdark           with trek, take the dark trail at the fork (trek=1 is then the dark clearing, 2 the mill)
#   tsign           with trek=0, stand below the fingerpost at the fork
#   works=A,B       trail works built: waymarks, footbridge, gate_lamp, boardwalk, waystation, chapel_steps,
#                   handcart, oil_cache, post_lamps (ART-OVERHAUL-002 E2 draws them)
#   troped          with trek and tevent=flood, the rope is across the flood
#   tdog            with trek, two feral dogs stand beside you
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
#   dturn=1|-1      with diary, turn a page forward or back (djump=N: jump to section N, riffling); dprog=F holds
#                   the turn at F (0 to 1) for the shot; diarymotion=Q|O sets the page-turn setting (Quick, Off);
#                   dnew=N marks note N unread (the diary opens at it, its ribbon dotted);
#                   dcycle (with hold=) from 3.5 s, turns forward twice, back twice, jumps a section and back, 1.1 s apart
#   sound           print how loud each ambience loop is playing when the shot is taken
#   hold=S          for recording (tools/trailer.ps1): instead of a shot, run S more seconds at 30 fps and quit,
#                   with the music stopped (the trailer lays one track over every shot); out= isn't needed
#   walk=D:S,...    with hold, walk direction D (up, down, left, right, or two joined by +) for S seconds, then
#                   the next; "wait" stands still, "use" swings the tool in hand once, "hand" presses the hand action
#                   (closing any panel it opens), and "letter" puts an unread letter in the mailbox
#   quiet           with hold, keep the message line empty
#   face=DIR        turn the farmer: up, down, left or right (after tile=)
#   mail=N          N unread letters in the mailbox by the gate, so its flag is up (0: one read letter, flag down)
#   mailopen        check the mailbox (its door held open for the shot); mailpanel keeps the Mailbox panel open
#   weapon=ID       CCH-CONSOLIDATED-003 Phase D: equip this weapon (sharpened_stick, hunting_knife, copper_sword,
#                   iron_sword) and hold the weapon slot
#   slot=N          hold hotbar tool N (0 weapon, 1 axe, 2 pick, 3 hoe, ...); with hold, walk legs "use" play its action,
#                   "block:S" holds the guard for S seconds, "blow:S" lands a creature's blow from the front
#                   (a hit; "block+blow:S" guards and the blow is turned aside), "chop:S" / "mine:S" / "fish:S" run that loop for S seconds

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
	if opt.has("works"):
		for id in str(opt["works"]).split(","):
			main.trek.works[id] = true
	if opt.has("stage"):
		main.house_stage = int(opt["stage"])
		main._build_interior()
	if opt.has("rich"):
		main.money += 2000
		for k in main.materials:
			main.materials[k] = int(main.materials[k]) + 40
	if opt.has("pack"):
		# UI checks: a mixed pack (crops, fish, eggs, a bandage, a charm, firewood) so the Inventory has usable
		# and unusable items, a full stack and a part one. Counts only; no skill or price change.
		for pair in [["crops", 31], ["potatoes", 6], ["apples", 3], ["eggs", 4], ["fish", 2], ["trout", 1], ["milk", 1]]:
			main.inventory[pair[0]] = int(main.inventory[pair[0]]) + int(pair[1])
		main.inventory["bandage"] = int(main.inventory["bandage"]) + 2
		main.inventory["crow_charm"] = int(main.inventory["crow_charm"]) + 1
	if opt.has("ipick"):
		main.inventory_selected = str(opt["ipick"])
	if opt.has("well"):
		# ART-OVERHAUL-002 E3: 0 the broken well, 1 repaired, 2 repaired with the cistern and the hose.
		var w := int(opt["well"])
		main.well_repaired = w >= 1
		main.cistern_built = w >= 2
		main.hose_attached = w >= 2
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
	if opt.has("fire"):
		main.fire_hours = float(opt["fire"])
	if opt.has("clock"):
		main.estate.furniture["clock"] = true
		main._build_interior()
	if opt.has("shutters"):
		main.projects.decor[Vector2i(-50, -50)] = "shutters"   # off the map: only the count matters here
		main.projects.barred_day = main.day
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
	if opt.has("blight"):
		main.nights._blight(main.nights.shadow_steps, main.nights.shadow_steps + int(opt["blight"]))
		main.nights.shadow_steps += int(opt["blight"])
		main._update_shadow_tile()
	if opt.has("hens"):
		main.coop_built = true
		main._relocate_building("coop")
		main.hens = int(opt["hens"])
		main.animals._sync_ages()
		main._apply_storage_tiles()
	if opt.has("sanity"):
		main.sanity = float(opt["sanity"])
	# HUD checks (UI-OVERHAUL-001 Phase 3): set the meters' values, and find the diary with a page unread.
	for need in ["hp", "food", "water", "warmth"]:
		if opt.has(need):
			main.set(need, int(opt[need]) if need == "hp" else float(opt[need]))
	if opt.has("diarynew"):
		main.diary_found = true
		main.diary_new.append("story")
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
		if opt.has("troped"):
			main.trek.roped = true
		if opt.has("tdog"):
			# Two feral dogs a few tiles off, one trotting (ART-OVERHAUL-002 E2 sprite check).
			for k in 2:
				var pt := Vector2i((main.player.position / main.PX).floor()) + Vector2i(2 + k * 2, 1 - k)
				var foe: Dictionary = main.combat_sys._new_foe("dog", pt)
				foe["moving"] = k == 0
				foe["face"] = -1.0 if k == 0 else 1.0
				main.foes.append(foe)
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
		if opt.has("mine"):
			# Face the ore at this offset and start working it, as pressing the hand on it does (the progress shows).
			var dv: PackedStringArray = opt["mine"].split(",")
			main.player.facing = Vector2(int(dv[0]), int(dv[1]))
			main.farm._start_harvest("cave_ore", main._player_tile() + Vector2i(int(dv[0]), int(dv[1])))
	elif opt.has("tile"):
		var t: PackedStringArray = opt["tile"].split(",")
		main.player.position = main._tile_center(int(t[0]) + main.BORDER_X, int(t[1]) + main.BORDER_Y)
	if opt.has("face"):
		main.player.facing = {"up": Vector2.UP, "down": Vector2.DOWN, "left": Vector2.LEFT, "right": Vector2.RIGHT}.get(opt["face"], Vector2.DOWN)
	if opt.has("weapon"):
		main.equipment["hand_r"] = opt["weapon"]
		main.active_slot = 0
	if opt.has("slot"):
		main.active_slot = int(opt["slot"])
	if opt.has("mail"):
		# CCH-CONSOLIDATED-003 Phase B: N unread letters in the mailbox (0: one letter, already read), the flag set at once.
		main.desk_mail = []
		for i in maxi(1, int(opt["mail"])):
			main.mail._add_letter("Letter %d" % (i + 1), "A letter for the capture.")
		if int(opt["mail"]) == 0:
			main.desk_mail[0]["unread"] = false
		main.mail.flag = 1.0 if main.mail._flag_up() else 0.0
	if opt.has("mailopen"):
		# Check the mailbox: its door stays open for the shot; mailpanel keeps the Mailbox panel open too.
		main.mail._open_mailbox()
		main.mail.lid_left = 3600.0
		if not opt.has("mailpanel"):
			main._close_panel()
	if opt.has("decor"):
		var at: Vector2i = main._player_tile() + Vector2i(-2, 2)
		for kind in opt["decor"].split(","):
			while not main._spot_ok(at, Vector2i.ONE) and at.x < main.MAP_W - 2:
				at.x += 1
			if kind == "broken":   # a fence with its rail torn loose
				kind = "fence"
				main.projects.broken[at] = true
			main.projects.decor[at] = kind
			if kind == "snare":    # with a hare in it
				main.projects.snared[at] = "hare"
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
		if opt.has("prog"):
			main.nights.prog = float(opt["prog"])
			# The slips into the dark up to this point have happened, so the figure stays where it stands.
			var blinks := int(main.nights.BLINKS.get(opt["visitor"], 0))
			main.nights.beats = mini(blinks, int(float(opt["prog"]) * (blinks + 1)))
		await process_frame
	if opt.has("raid"):
		main.nights.raid = opt["raid"]
		main.nights.raid_tile = main.nights._raid_place(opt["raid"])
		main.nights.raid_at = main.current_hour
		main.nights._update_raid()
		await process_frame
	if opt.has("madness"):
		main.madness._spawn_figure()
		main.madness.figure_left = 10.0
		if main.madness._tier() >= 3:
			main.madness.fake_crop = main.madness._fake_spot()
			main.madness.lie_left = 10.0
			main.madness.lie_hours = 2
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
		print(main.music.describe())
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
		if opt.has("diarymotion"):
			GameSettings.page_turns = 1 if opt["diarymotion"] == "Q" else 2
		if opt.has("dnew"):
			main.diary_new.append(str(main.TIPS[int(opt["dnew"])]["id"]))
		main._find_diary()
		await process_frame
		if opt.has("dpage"):
			var at: PackedStringArray = opt["dpage"].split(",")
			main.action_bar.open_book_at(int(at[0]), int(at[1]) if at.size() > 1 else 0)
		await process_frame
		# dturn=1 or -1 turns a page forward or back, djump=N jumps to section N instead (riffled leaves), and
		# dprog=F holds the turn at F (0 to 1) for the shot. Without dprog the turn plays out (for hold= clips).
		if opt.has("dcycle"):
			_diary_cycle(main.action_bar)
		if opt.has("dturn") or opt.has("djump"):
			await process_frame
			await process_frame
			var ab: ActionBar = main.action_bar
			if opt.has("dprog"):
				ab.page_turn.hold = float(opt["dprog"])
			if opt.has("djump"):
				ab._open_book_section(int(opt["djump"]))
			else:
				ab._turn_page(int(opt["dturn"]))
			# past the snapshots' warm-up, so the shot shows the turn
			for i in 10:
				await process_frame
	if opt.has("wheel"):
		main._toggle_wheel()
		if opt["wheel"] != "1":
			main.wheel.highlight = int(opt["wheel"])
			main.wheel.ring.queue_redraw()
		if opt.has("wpad"):
			main.wheel.pad_prompts = true
			main.wheel.ring.queue_redraw()
		if opt.has("wcycle"):
			_wheel_cycle()
		# Phase 6: past the wheel's open fade (SectionWheel.fade_seconds), so the shot shows it whole.
		for i in 16:
			await process_frame
	# CCH-CONSOLIDATED-003: the developer's world-state panel (debug builds). dweather=KIND forces the weather and
	# dtemp=F the temperature through it, dpause stops the clock; debug opens the panel itself for the shot.
	if main.debug_menu != null:
		if opt.has("dweather"):
			main.debug_menu.force_weather(str(opt["dweather"]))
		if opt.has("dtemp"):
			main.debug_menu.set_temperature(float(opt["dtemp"]))
		if opt.has("dpause"):
			main.debug_menu.set_paused(true)
		if opt.has("debug"):
			main.debug_menu.open()
		for i in 4:
			await process_frame
	if opt.has("bag"):
		main._toggle_bag()
		await process_frame
		await process_frame
	if opt.has("folk"):
		# A neighbour come by the farm today (FolkSystem), and you below them; use with hour= between 9 and 16.
		var who := str(opt["folk"])
		main.day = maxi(main.day, int(opt.get("wday", 60)))
		main.trek.edge_done = true
		main.folk.visit_day = main.day
		main.folk.visitor = who
		main.folk.spot = main.folk._spot(who)
		var ft: Vector2i = main.folk.spot
		main.player.position = main._tile_center(ft.x, ft.y + 1)
		main.player.facing = Vector2.UP
		# A few frames first, so the HUD and the visitor are drawn before a scene holds the day.
		for i in 10:
			await process_frame
		if opt.has("fscene"):
			var sc: Dictionary = main.folk.SCENES[who][int(opt["fscene"])]
			main.folk.dialogue.play(sc["pages"], func() -> void: pass, "Space: next")
			for i in int(opt.get("fpage", "0")):
				main.folk.dialogue.advance()
		elif opt.has("fsay"):
			main.folk._say(who, str(opt.get("fexpr", "neutral")), str(main.folk._line(who)["t"]))
		await process_frame
		await process_frame
	if opt.has("ending"):
		# An ending's sequence (StoryAct), over the farm, at line epage.
		main.act.meeting = "won"
		main.act.davy = "home"
		main.act._play_ending(str(opt["ending"]))
		main.act.screen.jump(int(opt.get("epage", "0")))
		for i in 4:
			await process_frame
	if opt.has("tab"):
		if opt.has("page"):
			main.action_bar.ledger_tabs[opt["tab"]] = int(opt["page"])
		main._toggle_tab(opt["tab"])
		await process_frame
		await process_frame
		if opt.has("focus"):
			# Move the keyboard/pad focus to the open section's Nth button (counting from 0, in tree order:
			# a grid's tiles first, then the rows' buttons), as the D-pad would.
			var buttons: Array = main.action_bar.panel.find_children("*", "Button", true, false).filter(
				func(b: Button) -> bool: return main.action_bar._focusable(b))
			var i := int(opt["focus"])
			if i < buttons.size():
				buttons[i].grab_focus()
			for f in 3:
				await process_frame
	if opt.has("creatures"):
		await _creatures(main, opt)
	if opt.has("lit"):
		# Diagnostic only, never a gameplay view: freeze the game and lift the darkness, to judge art the lantern hides.
		main.set_process(false)
		main.canvas_modulate.color = Color.WHITE
		for i in 3:
			await process_frame
	if opt.has("hold"):
		await _hold(main, opt)
		quit()
		return
	if opt.has("perf"):
		await _perf()
	_save(opt)


func _perf() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for i in 60:
		await process_frame
	var frames: Array = []
	var proc := 0.0
	var last := Time.get_ticks_usec()
	for i in 300:
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	frames.sort()
	var mean := 0.0
	for f in frames:
		mean += f
	mean /= frames.size()
	print("PERF frame_ms_mean=%.2f frame_ms_p95=%.2f process_ms_mean=%.2f fps=%.0f" % [mean, frames[int(frames.size() * 0.95)], proc / 300.0, 1000.0 / mean])


# Runs the recording's seconds, walking the path in walk= first. Frames are 1/30 s under --fixed-fps 30.
func _hold(main, opt: Dictionary) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	var left := int(float(opt["hold"]) * 30.0)
	for leg in opt.get("walk", "").split(",", false):
		var part: PackedStringArray = leg.split(":")
		var frames := int(float(part[1]) * 30.0) if part.size() > 1 else 1
		if part[0] == "use":
			main._tool_press = true
			main._swing()
			main._tool_press = false
			if main._active_tool() != "sword":
				main._play_use_anim()
		if "hold_loop" in main.player:
			main.player.hold_loop = part[0] if part[0] in ["chop", "mine", "fish"] else ""
		var tokens: PackedStringArray = part[0].split("+")
		if "block" in tokens:
			Input.action_press("block")
		if part[0] == "hand":
			# The hand action on what the farmer faces; a panel it opens is shut again so the scene stays in view.
			main._interact()
			main._close_panel()
		if part[0] == "letter":
			main.mail._add_letter("A letter", "Delivered for the recording.")
		var keys: Array = []
		for d in part[0].split("+"):
			if d in ["up", "down", "left", "right"]:
				keys.append("move_" + d)
				Input.action_press("move_" + d)
		for i in mini(frames, left):
			if i == 2 and "blow" in tokens:
				_blow(main)
			await _hold_frame(main, opt)
		for k in keys:
			Input.action_release(k)
		if "block" in tokens:
			Input.action_release("block")
		left -= frames
	for i in maxi(left, 0):
		await _hold_frame(main, opt)


# CCH-CONSOLIDATED-003 Phase E: the cave creatures (ckinds, default bat,lizard,snake) in a row right of the farmer, in
# one state. Still states freeze the game for the shot, the animation held at cprog (0-1): idle, move, alert,
# attack, hurt or death. "live" leaves them as real foes (for hold= clips): they notice, chase and strike as in
# play; chp=N sets their HP so a few swings kill them. cface=left turns them left.
func _creatures(main, opt: Dictionary) -> void:
	if opt.has("oldfoes"):
		CaveFoeArt.enabled = false
	var state: String = opt["creatures"]
	var kinds: PackedStringArray = opt.get("ckinds", "bat,lizard,snake").split(",")
	var prog := float(opt.get("cprog", "0.5"))
	var left: bool = opt.get("cface", "right") == "left"
	main.foes = []
	main.combat_sys.dying = []
	var base: Vector2 = main.player.position
	for i in kinds.size():
		var at: Vector2 = base + Vector2(1.4 * (i + 1) + (0.75 if state == "live" else 0.0), -0.1) * main.PX
		var foe: Dictionary = main.combat_sys._new_foe(kinds[i], Vector2i.ZERO)
		foe["pos"] = at
		foe["home"] = at
		foe["face"] = -1.0 if left else 1.0
		if opt.has("chp"):
			foe["hp"] = int(opt["chp"])
		match state:
			"move":
				foe["moving"] = true
			"alert":
				foe["alert_t"] = CaveFoeArt.ALERT_T * (1.0 - prog)
			"attack":
				foe["atk_t"] = CaveFoeArt.ATTACK_T * (1.0 - prog)
			"hurt":
				foe["flash"] = CaveFoeArt.HURT_T * (1.0 - prog)
		if state == "death":
			main.combat_sys.dying.append({"kind": kinds[i], "pos": at, "face": foe["face"], "t": CaveFoeArt.DEATH_T * prog})
		else:
			main.foes.append(foe)
	if state != "live":
		main.set_process(false)
		main.queue_redraw()
	for f in 3:
		await process_frame


# A creature's blow from straight in front (Phase D): the real combat code decides whether the guard turns it.
func _blow(main) -> void:
	var foe: Dictionary = main.combat_sys._new_foe("bat", Vector2i.ZERO)
	foe["pos"] = main.player.position + main.player.facing * main.PX
	main.invuln = 0.0
	main.hp = maxi(main.hp, 5)
	var keep: Vector2 = main.player.position
	main.combat_sys._foe_attack(foe)
	main.player.position = keep


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


# For a motion clip of the diary: forward, forward, back, back, a section jump and back, 1.1 s apart.
func _wheel_cycle() -> void:
	await create_timer(2.4).timeout   # past the 90 warm-up frames
	for key in [KEY_ESCAPE, KEY_SHIFT, KEY_RIGHT, KEY_RIGHT, KEY_RIGHT, KEY_LEFT, KEY_LEFT, KEY_LEFT, KEY_ESCAPE]:
		await create_timer(0.45).timeout
		for pressed in [true, false]:
			var ev := InputEventKey.new()
			ev.keycode = key
			ev.physical_keycode = key
			ev.pressed = pressed
			Input.parse_input_event(ev)
			await process_frame


func _diary_cycle(ab: ActionBar) -> void:
	var start := ab.book_section
	await create_timer(2.4).timeout   # past the 90 warm-up frames, so the clip starts on the open book
	for step in [1, 1, -1, -1, "jump", "back"]:
		await create_timer(1.1).timeout
		if str(step) == "jump":
			ab._open_book_section(mini(start + 1, ab.book_sections.size() - 1))
		elif str(step) == "back":
			ab._open_book_section(start)
		else:
			ab._turn_page(int(step))
