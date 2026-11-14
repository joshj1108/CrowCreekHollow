extends SceneTree

# CCH-EVENING-001: focused checks of the evening prototype (EveningSystem) and the first-week grace. Each case starts
# a new game in slot 9 (run it in a throwaway profile: APPDATA pointed at a scratch folder) and sets a state up
# through the game's own functions. These are set-up states, not played ones.
#   godot --path . --headless --fixed-fps 60 -s tools/evening_test.gd
# Prints PASS or FAIL per case, a few INFO lines (the schedule's numbers) and "evening: N failure(s)".

var m: MainGame
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, ("  (" + detail + ")") if detail != "" else ""])


func _new_game() -> void:
	if m != null:
		m.queue_free()
		await frames(3)
	TitleMenu.pending_name = "probe"
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("new", 9)
	await frames(10)


func _reload(save := true) -> void:
	if save:
		m.saver._save_game()
	m.queue_free()
	await frames(3)
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("load", 9)
	await frames(10)


func _set_hour(h: float) -> void:
	m.clock = (h - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.current_hour = h


# Anything said lately: the everyday line, the notice, or the last logged lines.
func _said() -> String:
	var t: String = m.chatter_text + "\n" + m.notice_text
	for i in mini(3, m.message_log.size()):
		t += "\n" + str(m.message_log[m.message_log.size() - 1 - i]["text"])
	return t


# Stand on the farm south of tile t (world), facing it.
func _face(t: Vector2i, from := Vector2i.DOWN) -> void:
	m.player.position = m._tile_center(t.x + from.x, t.y + from.y)
	m.player.facing = Vector2(-from)


# Stand in the house below the hearth, facing it.
func _at_hearth() -> void:
	if not m.inside:
		m._enter_house()
		await frames(2)
	var t := m.INT_ORIGIN + m.FIREPLACE_IX + Vector2i(1, 1)
	m.player.position = m._tile_center(t.x, t.y)
	m.player.facing = Vector2.UP
	m._tool_press = false


func _run() -> void:
	await _schedule_cases()
	await _sign_cases()
	await _hearth_cases()
	await _cozy_cases()
	await _grace_cases()
	await _save_cases()
	await _trek_rule_cases()
	print("evening: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)


# --- Scheduling ---------------------------------------------------------------------------------------------------

func _schedule_cases() -> void:
	await _new_game()
	var ev := m.evening
	var days := 1400
	var sign := []
	for d in range(1, days + 1):
		sign.append(ev._sign_day(d))
	var total := sign.count(true)
	var twice := 0
	for i in range(1, sign.size()):
		if sign[i] and sign[i - 1]:
			twice += 1
	# Every 7-day stretch, sliding, from day 2.
	var per_week := {}
	var in_band := 0
	var windows := 0
	for start in range(1, days - 7):
		var n := 0
		for k in 7:
			n += 1 if sign[start + k] else 0
		per_week[n] = int(per_week.get(n, 0)) + 1
		windows += 1
		in_band += 1 if n >= 2 and n <= 3 else 0
	var rate := float(total) / float(days - 1) * 7.0
	print("INFO  sign evenings: %d of %d (%.2f a week); 7-day windows by count %s; %d%% of windows hold 2-3" % [total, days - 1, rate, str(per_week), roundi(100.0 * in_band / windows)])
	check("schedule: about 2-3 sign evenings a week on average", rate >= 2.0 and rate <= 3.0, "%.2f" % rate)
	check("schedule: most weeks hold 2 or 3", float(in_band) / windows >= 0.55, "%d%%" % roundi(100.0 * in_band / windows))
	check("schedule: never two sign evenings running", twice == 0, str(twice))
	check("schedule: day 1 (the first night) has no sign", not sign[0])
	# Not a weekly pattern: the weekday a sign falls on is spread.
	var by_weekday := [0, 0, 0, 0, 0, 0, 0]
	for i in sign.size():
		if sign[i]:
			by_weekday[i % 7] += 1
	check("schedule: no fixed weekday", by_weekday.min() > total / 7 * 0.7 and by_weekday.max() < total / 7 * 1.3, str(by_weekday))
	# Fixed by the day: a fresh system (a reload) and a cold cache, in any order of asking, agree.
	var fresh := EveningSystem.new(m)
	var same := true
	for d in [300, 5, 77, 2, 1200, 76, 78]:
		same = same and fresh._sign_day(d) == sign[d - 1]
	check("schedule: deterministic after a reload, whatever order the days are asked", same)
	# Signs against tonight's visitor, walked through the nights as the game picks them.
	m.nights.last_visitor = ""
	var nights := 0
	var dangerous_unsigned := 0
	var quiet_signed := 0
	var plain := 0
	var signed := 0
	var matched := 0
	for d in range(2, 401):
		m.day = d
		m.stats["events"] = d - 1
		m.nights.sighting_seen = true
		var vid: String = m.nights._preview_id()
		var has := ev._sign_day(d)
		nights += 1
		if has:
			signed += 1
			var kind := ev._sign_kind(d, vid)
			if str(ev.SIGN_FOR.get(vid, "")) == kind:
				matched += 1
			if vid == "quiet":
				quiet_signed += 1
		else:
			if vid != "quiet":
				dangerous_unsigned += 1
			else:
				plain += 1
		m.nights.last_visitor = vid
	print("INFO  nights 2-400: %d signed (%d match tonight's visitor's kind), %d dangerous with no sign, %d quiet with a sign, %d quiet with none" % [signed, matched, dangerous_unsigned, quiet_signed, plain])
	check("schedule: dangerous nights without a sign happen", dangerous_unsigned > 50)
	check("schedule: sign nights with nothing dangerous happen", quiet_signed > 3)
	check("schedule: ordinary nights without a sign happen", plain > 10)
	var share := float(matched) / maxf(1.0, signed - quiet_signed)
	check("schedule: a sign usually, not always, matches", share > 0.55 and share < 0.9, "%d%%" % roundi(share * 100.0))


# --- Signs --------------------------------------------------------------------------------------------------------

func _sign_cases() -> void:
	await _new_game()
	var ev := m.evening
	m.day = 5
	m.event_fired_day = 4
	m.weather_kind = "cloudy"
	for kind in ["crows", "tracks", "chill"]:
		ev.force_kind = kind
		ev.sign_read_day = -1
		var tile: Vector2i = ev._tiles(kind)[-1]
		_set_hour(17.5)
		check("%s: not shown before 19:00" % kind, ev._showing() == "")
		_set_hour(20.0)
		check("%s: shown in the evening" % kind, ev._showing() == kind)
		# The tracks are on the path, walked up to along it from the west.
		_face(tile, Vector2i.LEFT if kind == "tracks" else Vector2i.DOWN)
		var kind_at: int = m._kind_at(tile)
		var want := {"crows": MainGame.Tile.FENCE, "tracks": MainGame.Tile.PATH, "chill": MainGame.Tile.HOUSE}
		check("%s: stands on the farm where it should" % kind, kind_at == int(want[kind]), "tile kind %d" % kind_at)
		var standing: int = m._kind_at(m._player_tile())
		check("%s: there is room to stand and look at it" % kind, not standing in m.BLOCKING, "standing kind %d" % standing)
		var before := int(m.stats.get("signs_read", 0))
		m.chatter_text = ""
		m._tool_press = false
		m._interact()
		await frames(2)
		check("%s: Space reads it" % kind, int(m.stats.get("signs_read", 0)) == before + 1 and ev.sign_read_day == m.day)
		var text := _said()
		var expect := {"crows": "faces the woods", "tracks": "don't lead away", "chill": "Colder than the evening air"}
		check("%s: says what it is" % kind, text.contains(str(expect[kind])), text.left(120))
		var named := false
		for word in ["knock", "watcher", "figure", "footsteps", "pond light", "Hollow", "tall "]:
			named = named or ev._read_text(kind).contains(word)
		check("%s: never names tonight's visitor" % kind, not named)
		m._interact()
		await frames(2)
		check("%s: a second look gives nothing more" % kind, int(m.stats.get("signs_read", 0)) == before + 1)
	# Weather and season.
	ev.force_kind = "tracks"
	m.weather_kind = "rain"
	check("tracks: rain is noticed", ev._read_text("tracks").contains("rain should have filled"))
	m.weather_kind = "snow"
	check("tracks: in snow", ev._read_text("tracks").contains("The snow is disturbed"))
	m.weather_kind = "cloudy"
	m.house_stage = 2
	var autumn := ev._read_text("chill")
	check("chill: glass once the house has it", autumn.contains("The glass is cold"))
	m.house_stage = 0
	check("chill: boards before then", ev._read_text("chill").contains("boards"))
	# Winter: frost on every pane is normal, so the sign says this one is colder than the rest.
	var start_day := m.day
	for d in range(1, 400):
		m.day = d
		if m._season_today() == "Winter":
			break
	m.house_stage = 2
	check("chill: in winter it doesn't pretend frost is strange", ev._read_text("chill").contains("Every pane is frosted"))
	m.day = start_day
	# Gone once the night's visitor has come; never read from inside; the crows go once read.
	ev.force_kind = "crows"
	ev.sign_read_day = -1
	_set_hour(20.0)
	m.event_fired_day = m.day
	check("signs: gone once the visitor has come", ev._showing() == "")
	m.event_fired_day = m.day - 1
	m._enter_house()
	await frames(2)
	check("signs: not read from inside the house", not ev._try_read(ev._tiles("crows")[0]))
	m._leave_house()
	await frames(2)
	# A day with no sign, none shown.
	ev.force_kind = ""
	var none_day := 2
	while ev._sign_day(none_day):
		none_day += 1
	m.day = none_day
	m.event_fired_day = none_day - 1
	check("signs: an evening with none shows none", ev._showing() == "")
	# The notice line, once, outdoors.
	var sign_day := 2
	while not ev._sign_day(sign_day):
		sign_day += 1
	m.day = sign_day
	m.event_fired_day = sign_day - 1
	ev.noticed_day = -1
	ev._kind_day = -1
	_set_hour(19.2)
	ev._update()
	var noticed := ev.noticed_day == m.day
	ev._update()
	check("signs: a short notice when the evening opens, once", noticed)


# --- Tend the hearth ----------------------------------------------------------------------------------------------

func _hearth_cases() -> void:
	await _new_game()
	var ev := m.evening
	m.day = 10
	ev.grace_used = true
	m.event_fired_day = 9
	m.inventory["firewood"] = 3
	m.fire_hours = 2.0
	await _at_hearth()
	# Outside the evening the hearth is fed with one press, as before.
	_set_hour(15.0)
	m._interact()
	await frames(2)
	check("hearth: by day Space feeds the fire as before", m.fire_hours >= 4.9 and m.open_tab == "" and int(m.inventory["firewood"]) == 2)
	# In the evening it opens the Hearth section.
	_set_hour(19.5)
	m._interact()
	await frames(3)
	check("hearth: in the evening Space opens the Hearth section", m.open_tab == "Hearth")
	var rows: Array = m.panels._hearth_rows()
	var actions := rows.map(func(r: Dictionary) -> String: return str(r.get("action", "")))
	check("hearth: it offers feeding, tending and an evening by the fire", "hearth_feed" in actions and "hearth_tend" in actions and "hearth_sit" in actions)
	# Ordinary feeding from it doesn't tend.
	var fire0 := m.fire_hours
	m._on_panel_action("hearth_feed")
	await frames(2)
	check("hearth: feeding from the section is ordinary fuelling", m.fire_hours > fire0 and ev.prep_day != m.day and m.open_tab == "Hearth")
	# Needs a good fire.
	m.fire_hours = 2.0
	check("hearth: a low fire can't be tended", ev._prep_blocker().contains("burning well"))
	m.fire_hours = 8.0
	m.inventory["firewood"] = 0
	check("hearth: it costs a firewood from the pack", ev._prep_blocker().contains("firewood"))
	m.inventory["firewood"] = 2
	_set_hour(18.5)
	check("hearth: not before 19:00", ev._prep_blocker() != "")
	_set_hour(19.5)
	var hour0 := m.current_hour
	m.fire_hours = 4.0
	m._on_panel_action("hearth_tend")
	await frames(2)
	check("hearth: tended once, for a firewood and half an hour", ev.prep_day == m.day and int(m.inventory["firewood"]) == 1 and absf(m.current_hour - hour0 - ev.PREP_HOURS) < 0.05, "wood %d hour %.2f" % [int(m.inventory["firewood"]), m.current_hour])
	check("hearth: the banked log burns, so the fire lasts the night", m.fire_hours >= 4.0 + m.FIREWOOD_HOURS - ev.PREP_HOURS - 0.1, "%.1f h" % m.fire_hours)
	check("hearth: the panel closes and says what was done", m.open_tab == "" and _said().contains("bank the fire"))
	m._on_panel_action("hearth_tend")
	await frames(2)
	check("hearth: once an evening", int(m.inventory["firewood"]) == 1 and ev._prep_blocker().contains("already"))
	# The effect: a visitor at the house takes PREP_MULT; others are untouched; it doesn't stack.
	var knock := await _night_loss("knock", true)
	var knock_plain := await _night_loss("knock", false)
	check("hearth: an unanswered knock takes less on a tended night", absf(knock / knock_plain - ev.PREP_MULT) < 0.02, "%.1f vs %.1f" % [knock, knock_plain])
	var watcher := await _night_loss("watcher", true)
	var watcher_plain := await _night_loss("watcher", false)
	# The watcher left alone is over NIGHT_CAP in autumn, so the easing comes off the uncapped figure.
	check("hearth: the watcher by the house too", watcher < watcher_plain, "%.1f vs %.1f" % [watcher, watcher_plain])
	var field := await _night_loss("field", true)
	var field_plain := await _night_loss("field", false)
	check("hearth: the field figure is not eased", absf(field - field_plain) < 0.01)
	ev.prep_day = m.day
	check("hearth: never more than the one easing", ev._night_mult("knock") == ev.PREP_MULT and ev._night_mult("knock") == ev.PREP_MULT)
	# The barred shutters (an existing preparation) now ease an unanswered knock as their message says; they
	# did only its strikes before, because the night read the visitor after clearing it.
	m.projects.decor[Vector2i(-50, -50)] = "shutters"
	m.projects.barred_day = m.day
	var barred := await _night_loss("knock", false)
	check("shutters: barred, an unanswered knock takes half (fixed in passing)", absf(barred / knock_plain - m.projects.SHUTTER_KNOCK) < 0.02, "%.1f vs %.1f" % [barred, knock_plain])
	var both := await _night_loss("knock", true)
	check("shutters and the tended hearth together", absf(both / knock_plain - m.projects.SHUTTER_KNOCK * ev.PREP_MULT) < 0.02, "%.1f" % both)
	m.projects.decor.erase(Vector2i(-50, -50))
	m.projects.barred_day = -1
	var faced := await _night_loss("knock", true, true)
	var faced_plain := await _night_loss("knock", false, true)
	check("hearth: facing the knock still costs something", faced > 0.0 and faced < faced_plain)
	# The morning: a line, and the effect ends with the night.
	ev.prep_day = m.day
	ev.guarded = true
	check("hearth: the morning says so without the mechanics", ev._morning_note().contains("held all night") and not ev._morning_note().contains("%"))
	ev.prep_day = m.day
	ev.guarded = false
	check("hearth: a night it wasn't needed says only that it burned", ev._morning_note().contains("burned low"))
	m._leave_house()
	ev.prep_day = m.day
	m.sanity = 100.0
	m._end_day("Test.", false)
	await frames(2)
	check("hearth: gone the next day", ev._night_mult("knock") == 1.0 and not ev._prep_blocker().contains("already"))


# Sanity a visitor takes tonight, prepared (the hearth tended) or not.
func _night_loss(id: String, prepared: bool, faced := false) -> float:
	var ev := m.evening
	ev.prep_day = m.day if prepared else -1
	m.sanity = 100.0
	m.sanity_penalty = 0
	m.event_fired_day = m.day - 1
	m.nights.visitor = {}
	m.nights.charmed = false
	m.nights._begin(id)
	m.nights.charmed = false
	m.nights._resolve(faced, false)
	await frames(1)
	return 100.0 - m.sanity


# --- An evening by the fire ---------------------------------------------------------------------------------------

func _cozy_cases() -> void:
	await _new_game()
	var ev := m.evening
	m.day = 10
	m.event_fired_day = 9
	await _at_hearth()
	m.fire_hours = 0.0
	_set_hour(20.0)
	check("cozy: not with the hearth cold", ev._cozy_blocker().contains("cold"))
	m.fire_hours = 5.0
	m.sanity = 50.0
	m.warmth = 40.0
	var hour0 := m.current_hour
	m._on_panel_action("hearth_sit")
	await frames(2)
	check("cozy: an hour by the fire", absf(m.current_hour - hour0 - ev.COZY_HOURS) < 0.05)
	check("cozy: a little sanity", absf(m.sanity - 50.0 - ev.COZY_SANITY) < 0.6, "%.1f" % m.sanity)
	check("cozy: and warmth", m.warmth >= 40.0 + ev.COZY_WARMTH - 1.0)
	check("cozy: says so", _said().contains("feels like a home"))
	var s1 := m.sanity
	for i in 5:
		m._on_panel_action("hearth_sit")
	await frames(2)
	check("cozy: once an evening, no farming it", absf(m.sanity - s1) < 0.01 and ev._cozy_blocker().contains("already"))
	m._leave_house()
	await frames(2)
	check("cozy: only in the house", ev._cozy_blocker().contains("inside"))
	m._enter_house()
	_set_hour(23.0)
	check("cozy: only in the evening", ev._cozy_blocker().contains("evening"))
	m.day += 1
	_set_hour(20.0)
	check("cozy: there again the next evening", ev._cozy_blocker() == "")
	# What a week of it can give, against what the nights take: at most COZY_SANITY a day.
	print("INFO  cozy: +%d sanity and +%d comfort once an evening, for an hour (a desk pastime gives +%d a day)" % [int(ev.COZY_SANITY), int(ev.COZY_WARMTH), int(m.rewards.PASTIME_SANITY)])


# --- The first-week grace ----------------------------------------------------------------------------------------

func _grace_cases() -> void:
	await _new_game()
	var ev := m.evening
	m.day = 4
	check("grace: unspent in a new game", not ev.grace_used)
	ev.grace_used = true
	var full := await _night_loss("knock", false)
	ev.grace_used = false
	var first := await _night_loss("knock", false)
	check("grace: the first unanswered knock in the first week takes half", absf(first / full - ev.GRACE_MULT) < 0.02, "%.1f of %.1f" % [first, full])
	check("grace: and is spent", ev.grace_used)
	check("grace: not cancelled, only eased", first >= 1.0)
	var text: String = m.chatter_text + str(m.message_log.back()["text"] if not m.message_log.is_empty() else "")
	var second := await _night_loss("knock", false)
	check("grace: the second knock takes the full amount", absf(second - full) < 0.01)
	# Only knocks, only left alone.
	await _new_game()
	ev = m.evening
	m.day = 3
	var field := await _night_loss("field", false)
	check("grace: other visitors keep their cost", not ev.grace_used and field > 0.0)
	var faced := await _night_loss("knock", false, true)
	check("grace: a faced knock doesn't use it", not ev.grace_used and faced > 0.0)
	# The morning report says what it cost, and that it won't always be so.
	m.nights._begin("knock")
	var note: String = m.nights._resolve(false, false)
	check("grace: the morning report gives the cost", note.contains("Sanity -") and note.contains("not always be so gentle"), note)
	# After the first week, no grace.
	await _new_game()
	ev = m.evening
	m.day = ev.GRACE_DAYS + 1
	ev.grace_used = true
	var late_full := await _night_loss("knock", false)
	ev.grace_used = false
	var late := await _night_loss("knock", false)
	check("grace: from day %d knocks keep their cost" % (ev.GRACE_DAYS + 1), absf(late - late_full) < 0.01 and not ev.grace_used)
	# Asleep: through the bed's own path (the night settled at _end_day).
	await _new_game()
	ev = m.evening
	m.day = 4
	m.stats["events"] = 3
	m.nights.sighting_seen = true
	m.nights.last_visitor = "field"
	var found := false
	for dd in range(2, ev.GRACE_DAYS + 1):
		for lv in ["field", "quiet", ""]:
			if not found:
				m.day = dd
				m.nights.last_visitor = lv
				found = m.nights._pick().get("id", "") == "knock"
	if m.nights._pick().get("id", "") == "knock":
		m.sanity = 100.0
		m.event_fired_day = m.day - 1
		m._end_day("Test.", false)
		await frames(2)
		check("grace: applied when slept through, at the bed", ev.grace_used and m.sanity > 100.0 - 34.0 + 1.0, "sanity %.1f" % m.sanity)
	else:
		print("INFO  grace: no knock reachable on day 4 for the bed path; covered by the direct cases")


# --- Saving -------------------------------------------------------------------------------------------------------

func _save_cases() -> void:
	await _new_game()
	var ev := m.evening
	# The save is made at dawn; whatever is saved comes back.
	ev.grace_used = true
	ev.prep_day = m.day
	ev.cozy_day = m.day
	ev.sign_read_day = m.day
	var d := m.day
	await _reload()
	ev = m.evening
	check("save: the grace stays spent across a reload", ev.grace_used)
	check("save: the evening's flags come back", ev.prep_day == d and ev.cozy_day == d and ev.sign_read_day == d)
	# The night's flags can't be used twice: they belong to their own day.
	m.day = d + 1
	check("save: a new day's evening is fresh", ev._night_mult("knock") == 1.0 and ev.cozy_day != m.day)
	# The grace unspent survives a reload unspent (it can't be reset, and isn't lost either).
	await _new_game()
	await _reload()
	check("save: an unspent grace stays unspent", not m.evening.grace_used)
	# The sign is the same after a reload.
	var day := 2
	while not m.evening._sign_day(day):
		day += 1
	m.day = day
	m.event_fired_day = day - 1
	_set_hour(20.0)
	var kind := m.evening._tonight()
	m.saver._save_game()
	await _reload(false)
	m.event_fired_day = m.day - 1
	_set_hour(20.0)
	check("save: tonight's sign is the same after a reload", m.day == day and m.evening._tonight() == kind, "%s / %s" % [kind, m.evening._tonight()])
	# Saves from before this: no "evening" key.
	var data := {"stats": {"left_alone": 0}}
	m.day = 3
	m.nights.seen = {}
	m.evening._load(null)
	check("old saves: in the first week, with no knock left alone, the grace is still there", not m.evening.grace_used)
	m.stats["left_alone"] = 1
	m.nights.seen = {"knock": 1}
	m.evening._load(null)
	check("old saves: in the first week, after a knock was left alone, it is spent", m.evening.grace_used)
	m.stats["left_alone"] = 0
	m.nights.seen = {}
	m.day = 20
	m.evening._load(null)
	check("old saves: past the first week it is spent", m.evening.grace_used)


# --- The first trek's rule stays as decided -----------------------------------------------------------------------

func _trek_rule_cases() -> void:
	check("first trek: EDGE_WORD_CALMS is on", TrekSystem.EDGE_WORD_CALMS)
	await _new_game()
	m.day = 4
	m.lantern_tier = 1
	m.materials["lamp_oil"] = 2
	m.inventory["trail_ration"] = 0
	m.inventory["bread"] = 0
	for route in ["edge", "mill"]:
		m.trek._start(route)
		await frames(20)
		if not m.trek.active:
			check("first trek: %s starts" % route, false)
			continue
		m.trek.nerve = m.trek.FREEZE_BELOW - 1.0
		m.trek.spoke = true
		await frames(3)
		m.player.position = m.trek.walker_pos + Vector2(m.PX * 0.5, 0)
		m._tool_press = false
		m.trek._interact(m._tile_in_front())
		await frames(3)
		if route == "edge":
			check("first trek: on the edge a word calms her", not m.trek.frozen)
		else:
			check("first trek: on later routes a word alone does not", m.trek.frozen)
		m.trek._abort()
		await frames(5)
