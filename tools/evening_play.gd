extends "res://tools/audit_play.gd"

# CCH-EVENING-001: plays the real game with injected input only (the CCH-PLAYABLE-001 bot, tools/audit_play.gd),
# with the evening played in one of four styles. Days run as the parent bot's: the guided first day, the chores
# and the trek when a walker waits. From 17:30 the style decides. Every action is a key, mouse or Xbox press; the
# bot reads state only to steer (where a sign or a visitor is, what the hearth's buttons say) and to log.
# It is NOT a human player, and nothing here says whether an evening is enjoyable.
#   APPDATA=<scratch> godot --path . --fixed-fps 60 --disable-vsync -s tools/evening_play.gd -- scenario=evening style=cozy days=14
# Options after "--" (besides the parent's dev=, out=, size=):
#   style=cozy|cautious|curious|minimal
#     cozy      indoors by 18:30; the evening by the fire each night it can, tends the hearth every third night;
#               bed after the hour by the fire (sleeps through the visitor)
#     cautious  looks for the evening's sign and reads it; tends the hearth when the sign points at the house,
#               otherwise an evening by the fire; stays up to face the visitor after a sign of tracks or crows
#     curious   reads every sign, never tends, faces every visitor (stays up to 22:00 each night), then bed
#     minimal   the ordinary loop as before this task: the hearth fed at 17:30, bed at 19:00, signs ignored
#   days=N      days to play (default 14)
#   grace=0     the experiment's control: the first-week grace is taken as spent before day 1 (not a player action)
# Each evening ends in one "EVE" line of JSON: the sign, what was done, the visitor and its outcome, sanity and
# comfort at 19:00 and at bed, firewood, the evening's game hours spent doing something and spent waiting.

var style := "minimal"
var eve := {}
var busy_hours := 0.0
var idle_hours := 0.0


func _sc_evening() -> void:
	style = str(opt.get("style", "minimal"))
	if not opt.has("days") or opt["days"] == "7":
		opt["days"] = "14"
	await start_new_game()
	if str(opt.get("grace", "1")) == "0":
		m.evening.grace_used = true
		note("OBS", "control run: the first-week grace is spent before day 1")
	await frames(60)
	await enter_house()
	await use_tile_kind(m.Tile.DESK, "the desk")
	await frames(60)
	await close_all()
	await leave_house()
	for d in int(opt["days"]):
		await _play_day()
		if m.day > int(opt["days"]):
			break
	note("OBS", "run over: " + state())
	note("OBS", "stats: " + JSON.stringify(m.stats))
	note("OBS", "quests done: %s" % str(m.quests_done.keys()))


# The parent's day up to the evening, then this style's evening.
func _play_day() -> void:
	var day: int = m.day
	note("OBS", "--- day %d begins: %s; weather %s; season %s" % [day, state(), m.weather_kind, m._season_today()])
	if m.inside:
		await leave_house()
	for i in 12:
		var step: Dictionary = m._guide_step()
		if step.is_empty():
			break
		var id := str(step["id"])
		if guide_seen.has(id):
			break
		guide_seen[id] = true
		match id:
			"g_walk":
				await walk(nearest(soil_tiles(true)).slice(0, 1), "the plot")
			"g_plant":
				await plant(3)
			"g_bag":
				await open_bag()
				await open_bag()
				if m._bag_open():
					await close_all()
			"g_brush":
				await gather_brush(3)
			"g_wheel":
				await open_wheel()
				await close_all()
			"g_hatchet":
				if await open_section("Craft"):
					await craft_tab("Tools")
					await press_action("craft_pick:tool:hatchet", true)
					await frames(10)
					await press("Make", true)
					await close_all()
			"g_chop":
				await chop_tree()
			"g_drink":
				await drink()
		await frames(90)
	await _chores()
	await _evening()


# Waits for an hour, counting it as time with nothing chosen to do.
func idle_until(h: float) -> void:
	var h0: float = m.current_hour
	await wait_until_hour(h)
	if m.current_hour >= 19.0:
		idle_hours += maxf(0.0, m.current_hour - maxf(h0, 19.0))


func _evening() -> void:
	busy_hours = 0.0
	idle_hours = 0.0
	eve = {"day": m.day, "style": style, "sign": "", "noticed": false, "read": false, "tended": false, "sat": false,
		"fed": 0, "visitor": "", "faced": "", "stayed_up": false}
	await wait_until_hour(17.5)
	await eat_from_bag()
	if style == "minimal":
		# As the CCH-LOOP-001 baseline: indoors, the hearth fed, bed at 19:00.
		await enter_house()
		await _feed_hearth(1)
		await _snapshot_at(19.0)
		await idle_until(19.0)
		await _bed()
		return
	if style == "cozy":
		await enter_house()
		await _feed_hearth(1)
		await _snapshot_at(19.0)
		await idle_until(19.02)
		await _hearth_evening(m.day % 3 == 0, true)
		await idle_until(minf(m.current_hour + 0.25, 21.5))
		await _bed()
		return
	# cautious and curious: the hearth fed at 17:30 as anyone does, then out by the house at dusk, looking for the sign.
	await enter_house()
	await _feed_hearth(1)
	await leave_house()
	await walk(free_neighbours(m._world_tile(44, 13)), "the yard before the house")
	await _snapshot_at(19.0)
	await idle_until(19.1)
	var sign: String = m.evening._showing()
	eve["sign"] = sign
	eve["noticed"] = sign != "" and m.evening.noticed_day == m.day
	if sign != "":
		await _read_sign(sign)
	if style == "cautious":
		await enter_house()
		var house_sign: bool = sign == "chill" and bool(eve["read"])
		await _hearth_evening(house_sign, not house_sign)
		var face: bool = bool(eve["read"]) and sign in ["tracks", "crows"] and m.lantern_tier > 0
		if face:
			await _face_night()
		else:
			await idle_until(minf(m.current_hour + 0.25, 21.5))
		await _bed()
		return
	# curious
	await enter_house()
	await _hearth_evening(false, true)
	await _face_night()
	await _bed()


# The sanity and comfort at the evening's start.
func _snapshot_at(h: float) -> void:
	eve["sanity_19"] = int(m.sanity)
	eve["warmth_19"] = int(m.warmth)
	eve["firewood_19"] = int(m.inventory["firewood"])
	eve["fire_19"] = snappedf(m.fire_hours, 0.1)


# Space at the hearth before 19:00 feeds it, as ever.
func _feed_hearth(times: int) -> void:
	for i in times:
		if int(m.inventory["firewood"]) <= 0 or not m.inside:
			return
		var t0: float = m.current_hour
		for t in tiles_of(m.Tile.FIREPLACE):
			if reachable(t) and await approach(t, "the hearth"):
				var f0: float = m.fire_hours
				await use()
				await frames(20)
				if m.fire_hours > f0:
					eve["fed"] = int(eve["fed"]) + 1
				break
		busy_hours += maxf(0.0, m.current_hour - maxf(t0, 19.0))


# A ledger row: with the mouse a click on the row selects it, and the action is the button in its detail pane (as
# in every ledger section); with a controller A on the row does it. done says whether the game did it.
func ledger_press(id: String, label: String, done: Callable) -> bool:
	await press_action(id, true)
	if not done.call() and not pad and m.open_tab != "":
		var b := find_button(label, true)
		if b != null and not b.disabled:
			await mouse_click(b.get_global_rect().get_center())
			await frames(10)
	return done.call()


# From 19:00 Space at the hearth opens its section; the bot reads the buttons and presses what its style wants.
func _hearth_evening(tend: bool, sit: bool) -> void:
	if not await enter_house():
		return
	var t0: float = m.current_hour
	for t in tiles_of(m.Tile.FIREPLACE):
		if reachable(t) and await approach(t, "the hearth"):
			await use()
			await frames(20)
			break
	if m.open_tab != "Hearth":
		note("PROBLEM", "Space at the hearth in the evening did not open the Hearth section (tab=%s)" % m.open_tab)
		return
	if eve.get("shot_hearth", false) == false and m.day <= 3:
		eve["shot_hearth"] = true
		await shot("d%d_hearth_%s" % [m.day, style])
	# Feed it if it is low and there is wood, so the hearth can be tended.
	if tend and m.fire_hours < m.evening.PREP_FIRE and int(m.inventory["firewood"]) > m.evening.PREP_WOOD:
		var f0 := m.fire_hours
		if await ledger_press("hearth_feed", "Feed", func() -> bool: return m.fire_hours > f0):
			eve["fed"] = int(eve["fed"]) + 1
	if tend:
		var w0 := int(m.inventory["firewood"])
		if await ledger_press("hearth_tend", "Tend", func() -> bool: return m.evening.prep_day == m.day):
			eve["tended"] = true
			note("ACT", "tended the hearth: firewood %d -> %d (\"%s\")" % [w0, int(m.inventory["firewood"]), m.message_label.text])
		else:
			eve["tend_blocked"] = m.evening._prep_blocker()
	if sit:
		if m.open_tab != "Hearth":
			for t in tiles_of(m.Tile.FIREPLACE):
				if reachable(t) and await approach(t, "the hearth"):
					await use()
					await frames(20)
					break
		var s0 := m.sanity
		if m.open_tab == "Hearth" and await ledger_press("hearth_sit", "Sit", func() -> bool: return m.evening.cozy_day == m.day):
			eve["sat"] = true
			eve["sit_sanity"] = snappedf(m.sanity - s0, 0.1)
			if m.day <= 4:
				await shot("d%d_by_the_fire_%s" % [m.day, style])
		else:
			eve["sit_blocked"] = m.evening._cozy_blocker()
	if m.open_tab != "":
		await close_all()
	busy_hours += maxf(0.0, m.current_hour - maxf(t0, 19.0))


func _read_sign(kind: String) -> void:
	var t0: float = m.current_hour
	if m.inside:
		await leave_house()
	for t in m.evening._tiles(kind):
		if reachable(t) and await approach(t, "the %s sign" % kind):
			await use()
			await frames(20)
			break
	eve["read"] = m.evening.sign_read_day == m.day
	if eve["read"]:
		note("ACT", "read the %s sign: \"%s\"" % [kind, m.message_label.text])
		if not shot_signs.has(kind):
			shot_signs[kind] = true
			await shot("d%d_sign_%s_read" % [m.day, kind])
	busy_hours += maxf(0.0, m.current_hour - maxf(t0, 19.0))


var shot_signs := {}


# Stays up for tonight's visitor and answers it as its prompts say: hold the door, get it into the light, reach in
# when the pond lights swell, get inside from the footsteps.
func _face_night() -> void:
	eve["stayed_up"] = true
	eve["faced_before"] = int(m.stats.get("faced", 0))
	if m.lantern_tier > 0 and m.inside:
		await idle_until(21.7)
		await leave_house()
		await walk(free_neighbours(m._world_tile(44, 13)), "the yard")
	await idle_until(22.02)
	var t0: float = m.current_hour
	var n := 0
	var shot_taken := false
	# The scripted first night plays in beats before its figure comes.
	while m.nights.first_beat >= 0 and not m.nights._active() and m.current_hour < 24.0:
		await frames(10)
	while m.nights._active() and m.current_hour < 25.2 and n < 2400 and not m.transitioning:
		n += 1
		var v: Dictionary = m.nights.visitor
		var id := str(v.get("id", ""))
		eve["visitor"] = id
		if not shot_taken and m.day <= 14:
			shot_taken = true
			await shot("d%d_night_%s_%s" % [m.day, id, style])
		match m.nights.mode:
			"door":
				var spot := m.INT_ORIGIN + m.INT_ENTRY + Vector2i(0, -1)
				if here() != spot:
					await walk([spot], "by the door")
				await frames(10)
			"hold":
				var vt: Vector2i = m.nights.visitor_tile
				if m.inside:
					await leave_house()
				elif vt.x >= 0:
					if m.nights._lit_by_you(vt) and (m.player.position - m._tile_center(vt.x, vt.y)).length() < m.PX * 1.6:
						if m._tile_in_front() == vt:
							await use()
						await frames(6)
					else:
						var spots := free_neighbours(vt)
						if not spots.is_empty():
							await walk([nearest(spots)[0]], "toward it")
							var d: Vector2i = vt - here()
							for name in DIRS:
								if DIRS[name] == d:
									await face(name)
						else:
							await frames(10)
			"crows":
				if m.inside:
					await leave_house()
				var down: Array = m.nights.crow_at.filter(func(c: Dictionary) -> bool: return str(c["state"]) == "down")
				if down.is_empty():
					await frames(10)
				else:
					var ct: Vector2i = down[0]["tile"]
					if await approach(ct, "a crow"):
						await use()
			"pulse":
				if m.inside:
					await leave_house()
				var pt: Vector2i = m.nights.visitor_tile
				var water := pt
				if m._tile_in_front() != water:
					var spots := free_neighbours(water)
					if not spots.is_empty():
						await approach(water, "the pond lights")
					else:
						await frames(10)
				elif m.nights._pulse() >= m.nights.PULSE_TOP and m.nights.swell != int(m.current_hour / m.nights.PULSE_HOURS):
					await use()
				else:
					await process_frame
			"steps":
				await enter_house()
				await frames(10)
			_:
				await frames(10)
	eve["faced"] = "yes" if int(m.stats.get("faced", 0)) > int(eve["faced_before"]) else "no"
	busy_hours += maxf(0.0, m.current_hour - t0)
	await enter_house()


func _bed() -> void:
	eve["sanity_bed"] = int(m.sanity)
	eve["warmth_bed"] = int(m.warmth)
	eve["bed_at"] = snappedf(m.current_hour, 0.01)
	eve["firewood_bed"] = int(m.inventory["firewood"])
	eve["busy_h"] = snappedf(busy_hours, 0.01)
	eve["idle_h"] = snappedf(idle_hours, 0.01)
	var faced0 := int(m.stats.get("faced", 0))
	var left0 := int(m.stats.get("left_alone", 0))
	var day0: int = m.day
	eve["sign_tonight"] = m.evening._tonight()   # whether or not this style went to look
	await sleep_in_bed()
	eve["morning_sanity"] = int(m.sanity)
	eve["night"] = m.nights.last_visitor
	eve["night_faced"] = int(m.stats.get("faced", 0)) > faced0 or str(eve.get("faced", "")) == "yes"
	eve["night_left_alone"] = int(m.stats.get("left_alone", 0)) > left0
	eve["grace_used"] = m.evening.grace_used
	eve.erase("shot_hearth")
	if m.day > day0:
		note("EVE", JSON.stringify(eve))


# At a small window the Craft section's tabs show icons only, so a click on the tab's name finds nothing; the bot
# clicks the tab's button where it is drawn instead.
func craft_tab(name: String) -> void:
	var want := name.to_lower()
	for i in 6:
		if str(m.craft_tab) == want:
			return
		if pad:
			await tap_pad(JOY_BUTTON_RIGHT_SHOULDER)
		elif not await press(name, true):
			await press_action("craft_tab:" + want, true)   # the tab's own button, clicked where it is drawn
		await frames(10)
	if str(m.craft_tab) != want:
		note("PROBLEM", "the Craft tab %s could not be opened (on %s)" % [name, str(m.craft_tab)])


# The UI lays out in the project's 1280x720 and is scaled to the window, so at a smaller window (size=640x360,
# which keeps five bots running at once) a button's rect must be put into window pixels before it is clicked.
func _to_window(p: Vector2) -> Vector2:
	return root.get_final_transform() * p


func mouse_move(p: Vector2) -> void:
	var w := _to_window(p)
	var ev := InputEventMouseMotion.new()
	ev.position = w
	ev.global_position = w
	Input.parse_input_event(ev)
	await frames(2)


func mouse_click(p: Vector2, button := MOUSE_BUTTON_LEFT, hold := 3) -> void:
	await mouse_move(p)
	var w := _to_window(p)
	for down in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = button
		ev.position = w
		ev.global_position = w
		ev.pressed = down
		Input.parse_input_event(ev)
		await frames(hold)
