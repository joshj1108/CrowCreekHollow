extends SceneTree

# CCH-PLAYABLE-002: focused checks of the gameplay repairs. Each case starts a new game in slot 9 (run it in a
# throwaway profile: APPDATA pointed at a scratch folder) and sets a state up through the game's own functions.
# These are set-up states, not played ones.
#   godot --path . --headless --fixed-fps 60 -s tools/playable002_test.gd
# Prints PASS or FAIL per case and "playable002: N failure(s)".

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


func _reload() -> void:
	m.saver._save_game()
	m.queue_free()
	await frames(3)
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child(m)
	await frames(3)
	m._on_title_start("load", 9)
	await frames(10)


func _key(k: int, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = k
	ev.keycode = k
	ev.pressed = down
	Input.parse_input_event(ev)


func _pad_button(b: int) -> void:
	for down in [true, false]:
		var ev := InputEventJoypadButton.new()
		ev.button_index = b
		ev.pressed = down
		Input.parse_input_event(ev)
		await frames(2)


func _moved() -> float:
	var start: Vector2 = m.player.position
	var best := 0.0
	for k in [KEY_D, KEY_A, KEY_S, KEY_W]:
		_key(k, true)
		await frames(20)
		_key(k, false)
		await frames(2)
		best = maxf(best, m.player.position.distance_to(start))
	return best


func _wait_transition() -> void:
	await frames(5)
	var n := 0
	while m.transitioning and n < 60 * 90:
		await process_frame
		n += 1
	await frames(30)


func _run() -> void:
	await frames(5)
	await _collapse_cases()
	await _cleanse_cases()
	await _story_cases()
	await _message_cases()
	await _control_cases()
	await _qol_cases()
	await _trek_cases()
	SaveSystem.delete_save(m._save_path())
	print("playable002: %d failure(s)" % failures)
	quit(failures)


# --- PLAY-01, PLAY-13: a fall indoors, a 03:00 collapse in the cave ------------------------------------------

func _collapse_cases() -> void:
	for need in ["food", "water", "warmth"]:
		await _new_game()
		m._enter_house()
		await frames(10)
		var limit0: float = m.sanity_sys._sanity_max()
		var sanity0: float = m.sanity
		m.set(need, 0.0)
		m.fire_hours = 0.0   # a cold house: with the fire lit, comfort would come back indoors
		m.hp = 1
		m.starve_timer = m.NEED_HARM_HOURS - 0.01
		await frames(90)
		var t: Vector2i = m._player_tile()
		check("PLAY-01 fall indoors (%s empty): woken outdoors" % need, not m.inside and m._in_bounds(t) and not m._in_interior(t), "inside=%s tile=%s" % [m.inside, t])
		check("PLAY-01 fall indoors (%s empty): on open ground" % need, not m._is_blocked_world(m.player.position + Vector2(0, 8)))
		var moved := await _moved()
		check("PLAY-01 fall indoors (%s empty): can walk" % need, moved >= 8.0, "%.0f px" % moved)
		check("PLAY-01 fall indoors (%s empty): the fall still costs sanity, not the limit" % need, m.sanity < sanity0 and is_equal_approx(m.sanity_sys._sanity_max(), limit0), "sanity %d -> %d" % [int(sanity0), int(m.sanity)])
		check("PLAY-01 fall indoors (%s empty): full health" % need, m.hp == m.max_hp())
		if need == "food":
			await _reload()
			var lt: Vector2i = m._player_tile()
			check("PLAY-01 save and load after the fall: outdoors, free", not m.inside and not m._is_blocked_world(m.player.position + Vector2(0, 8)) and m._in_bounds(lt), "tile %s inside=%s" % [lt, m.inside])
	# Unstick in the house puts the farmer at the door; on the farm it still finds open ground.
	await _new_game()
	m._enter_house()
	await frames(5)
	m.player.position = m._tile_center(m.INT_ORIGIN.x + 3, m.INT_ORIGIN.y + 3)
	m._unstick()
	await frames(5)
	check("Unstick in the house: back at the door mat", m.inside and m._player_tile() == m.INT_ORIGIN + m.INT_ENTRY)
	m._leave_house()
	await frames(5)
	m._unstick()
	await frames(5)
	check("Unstick on the farm: still works", not m._is_blocked_world(m.player.position + Vector2(0, 8)) and m.message_label.text.contains("open ground"))
	# PLAY-13: 03:00 in the cave wakes at the gate.
	await _new_game()
	m._enter_cave()
	await frames(10)
	m.clock = m.DAY_LENGTH - 0.2
	await frames(30)
	await _wait_transition()
	check("PLAY-13 03:00 in the cave: wakes on the farm", not m.in_cave and m._in_bounds(m._player_tile()) and m.foes.is_empty(), "in_cave=%s tile=%s" % [m.in_cave, m._player_tile()])
	var moved2 := await _moved()
	check("PLAY-13 03:00 in the cave: can walk", moved2 >= 8.0)


# --- PLAY-04: chapter 9 "Clear the Stain" ---------------------------------------------------------------------

func _to_chapter(id: String) -> void:
	for q in m.STORY:
		if str(q["id"]) == id:
			break
		m.quests_done[q["id"]] = true


func _cleanse_cases() -> void:
	# A careful player: no limit lost.
	await _new_game()
	_to_chapter("stain")
	m.skill_xp["Cleaning"] = m.progression._xp_for_level(m.CLEANSE_LEVEL)
	m.inventory["crops"] = 2
	m.sanity_penalty = 0
	var xp0 := int(m.skill_xp["Cleaning"])
	check("PLAY-04 no limit lost: first cleanse allowed", m.sanity_sys._can_cleanse(), m.sanity_sys._cleanse_blocker())
	m.sanity_sys._cleanse_house()
	check("PLAY-04 no limit lost: cleanse done, 2 crops spent", int(m.stats["cleansed"]) == 1 and int(m.inventory["crops"]) == 0)
	check("PLAY-04 the cleanse itself gives no skill XP", int(m.skill_xp["Cleaning"]) == xp0)
	check("PLAY-04 limit not raised above the maximum", m.sanity_sys._sanity_max() <= m.SANITY_MAX)
	m.progression._check_story()
	check("PLAY-04 chapter 9 completes", m.quests_done.has("stain"))
	check("PLAY-04 chapter 9 gives its reward XP (40, with any skill bonus)", int(m.skill_xp["Cleaning"]) >= xp0 + 40, "%d -> %d" % [xp0, int(m.skill_xp["Cleaning"])])
	m.day += 1
	m.inventory["crops"] = 2
	check("PLAY-04 later cleanse with no limit lost: refused", not m.sanity_sys._can_cleanse())
	m.sanity_sys._cleanse_house()
	check("PLAY-04 refusal says why", m.message_label.text.contains("only lifts a sanity limit you have lost"), m.message_label.text)
	# A player who has lost limit.
	await _new_game()
	_to_chapter("stain")
	m.skill_xp["Cleaning"] = m.progression._xp_for_level(m.CLEANSE_LEVEL)
	m.inventory["crops"] = 2
	m.sanity_penalty = 10
	m.sanity_sys._cleanse_house()
	check("PLAY-04 limit lost: cleanse lifts it by %d" % m.CLEANSE_RELIEF, m.sanity_penalty == 10 - m.CLEANSE_RELIEF)
	m.progression._check_story()
	check("PLAY-04 limit lost: chapter 9 completes", m.quests_done.has("stain"))
	m.inventory["crops"] = 2
	m.sanity_sys._cleanse_house()
	check("PLAY-04 once a day still holds", int(m.stats["cleansed"]) == 1 and m.message_label.text.contains("already cleansed"), m.message_label.text)
	# Missing requirements are named.
	await _new_game()
	_to_chapter("stain")
	m.sanity_sys._cleanse_house()
	check("PLAY-04 refusal names Cleaning and crops", m.message_label.text.contains("Cleaning 3") and m.message_label.text.contains("2 crops"), m.message_label.text)
	var stain_text := ""
	for q in m.STORY:
		if str(q["id"]) == "stain":
			stain_text = str(q["text"])
	check("PLAY-04 chapter text names the needs", stain_text.contains("Cleaning 3"), stain_text)


# --- PLAY-05: Davy's beat and the last chapters -----------------------------------------------------------------

func _second_year(bell_first: bool) -> void:
	_to_chapter("act_davy")
	m.day = 380
	for id in ["letter", "shown", "orchard", "knock", "meeting"]:
		m.act.beats[id] = 300
	if bell_first:
		m.projects.decor[Vector2i(m.BORDER_X + 4, m.BORDER_Y + 4)] = "bell"


func _story_cases() -> void:
	# Davy's night lived normally.
	await _new_game()
	_second_year(false)
	m.act._done("davy")
	m.act.davy = "found"
	m.progression._check_story()
	check("PLAY-05 Davy found: chapter 15 completes", m.quests_done.has("act_davy"))
	# The bell hung before Davy's night: closed by the next morning.
	await _new_game()
	_second_year(true)
	m.act._morning()
	check("PLAY-05 bell first: Davy's beat closed quietly", m.act.beats.has("davy") and int(m.act.beats["davy"]) == -1)
	check("PLAY-05 bell first: no Davy diary page", not m.act._lived("davy"))
	m.progression._check_story()
	check("PLAY-05 bell first: chapters 15 and 16 complete", m.quests_done.has("act_davy") and m.quests_done.has("act_bell"))
	m.trek.grove_done = true
	m.progression._check_story()
	check("PLAY-05 bell first: chapter 17 and every chapter complete", m.quests_done.size() == m.STORY.size(), "%d of %d" % [m.quests_done.size(), m.STORY.size()])
	m.ach._check(true)
	check("PLAY-05 the All Chapters achievement", m.achievements_done.has("ACH_ALL_CHAPTERS"))
	# An older save already past the bell, with Davy's beat left open: closed when loaded.
	await _new_game()
	_second_year(true)
	m.act.beats.erase("davy")
	m.trek.grove_done = true
	await _reload()
	check("PLAY-05 old save past the bell: Davy closed on load", m.act.beats.has("davy"))
	await frames(40)
	check("PLAY-05 old save past the bell: the chapter list finishes", m.quests_done.size() == m.STORY.size(), "%d of %d" % [m.quests_done.size(), m.STORY.size()])
	# Nothing closes before the bell: Davy's night still comes.
	await _new_game()
	_second_year(false)
	m.day = m.act.DAVY_FROM
	m.act._morning()
	check("PLAY-05 no bell: Davy's night still comes", m.act.davy_day == m.day and not m.act.beats.has("davy"))


# --- PLAY-03, PLAY-11: messages ---------------------------------------------------------------------------------

func _message_cases() -> void:
	await _new_game()
	await frames(2)
	m._show_morning_report("You sleep through the night. Your crops grew overnight. A long report about the farm.")
	m._show_message("A new page in your diary: Testing.", true)
	m._show_message("Watered from the bucket. 7 left.")
	m._show_message("Watered from the bucket. 6 left.")
	var t: String = m.message_label.text
	check("PLAY-03 the morning report stays while other lines come", t.begins_with("You sleep through the night"), t)
	check("PLAY-03 an everyday line shows under it", t.contains("6 left") and not t.contains("7 left"), t)
	check("PLAY-03 a second notice waits its turn", m.notice_queue.has("A new page in your diary: Testing."))
	var n := 0
	while m.notice_text.begins_with("You sleep") and n < 60 * 30:
		await process_frame
		n += 1
	check("PLAY-03 the next notice follows once the report was held (%.1f s)" % (n / 60.0), m.notice_text.begins_with("A new page"), m.notice_text)
	check("PLAY-03 the report was held at least 3 s", n >= 180, "%d frames" % n)
	var said: Array = m.panels._said_pages()
	check("PLAY-03 the diary keeps this morning's report", said.size() >= 1 and str(said[0]["text"]).begins_with("You sleep"))
	check("PLAY-03 the diary keeps recent notices", said.size() >= 2 and str(said[1]["text"]).contains("Testing"))
	# PLAY-11: lines said before the HUD exists wait and show.
	var g: MainGame = load("res://scenes/main.tscn").instantiate()
	g._show_message("The farm was redrawn since this save.", true)
	g._show_message("The coop was moved to a clear spot on the farm.", true)
	check("PLAY-11 notes before the HUD are kept, not lost", g.notice_queue.size() == 2)
	g.free()
	# Real sleep: the report and the 06:00 lines.
	await _new_game()
	m.clock = (19.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	await frames(5)
	m._enter_house()
	m._try_sleep()
	await _wait_transition()
	await frames(120)
	check("PLAY-03 after a night's sleep the report is on screen two seconds later", m.message_label.text.contains("Your crops grew overnight"), m.message_label.text.substr(0, 80))


# --- PLAY-06, PLAY-07, PLAY-08: controls and guidance ------------------------------------------------------------

func _control_cases() -> void:
	await _new_game()
	_key(KEY_W, true)
	await frames(2)
	_key(KEY_W, false)
	await frames(2)
	check("PLAY-06 keyboard used: hints name keys", m._fill_controls("{hand} {bag}") == "Space Tab", m._fill_controls("{hand} {bag}"))
	await _pad_button(JOY_BUTTON_X)
	check("PLAY-06 pad used: hints name buttons", m._fill_controls("{hand} {bag}") == "A Y", m._fill_controls("{hand} {bag}"))
	check("PLAY-06 pad used: old 'press Space' lines say A", m._device_words("Face it and press Space.") == "Face it and press A.")
	_key(KEY_W, true)
	await frames(2)
	_key(KEY_W, false)
	await frames(2)
	check("PLAY-06 back on the keyboard: keys again", m._fill_controls("{hand}") == "Space")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_RIGHT
	click.pressed = true
	await _pad_button(JOY_BUTTON_X)
	Input.parse_input_event(click)
	await frames(2)
	click = click.duplicate()
	click.pressed = false
	Input.parse_input_event(click)
	await frames(2)
	check("PLAY-06 a mouse click counts as keyboard and mouse", m._fill_controls("{hand}") == "Space")
	# PLAY-07: the first lines name the controls.
	await _new_game()
	var first: String = m.message_label.text
	check("PLAY-07 the first line says how to walk and go in", first.contains("WASD") and first.contains("door"), first)
	check("PLAY-07 the diary hint says how to use the desk", m._fill_controls(m.DIARY_HINT).contains("press Space"))
	m._enter_house()
	await frames(5)
	var desk := Vector2i(-1, -1)
	for y in m.INT_H:
		for x in m.INT_W:
			if m.interior[y][x] == MainGame.Tile.DESK:
				desk = Vector2i(x, y)
	check("PLAY-07 the house has a desk", desk.x >= 0)
	if desk.x >= 0:
		var stand := m.INT_ORIGIN + desk + Vector2i(0, 1)
		m.player.position = m._tile_center(stand.x, stand.y)
		m.player.facing = Vector2.UP
		await frames(5)
		check("PLAY-07 facing the desk shows a prompt", m.mail.prompt.visible and m.mail.prompt.text.contains("desk drawer"), m.mail.prompt.text)
		m._find_diary()
		m._close_panel()
		await frames(5)
		check("PLAY-08 after the diary, the desk prompt names the catalog", m.mail.prompt.visible and m.mail.prompt.text.contains("catalog"), m.mail.prompt.text)
	# PLAY-08: the seeds page.
	m.day = 2
	m.inventory["seeds"] = 1
	check("PLAY-08 the seeds page comes when seed runs low", m._tip_ready("seeds"))
	check("PLAY-08 the seeds page names the desk and Catalog", str(m._tip_data("seeds")["text"]).contains("Catalog") and str(m._tip_data("seeds")["text"]).contains("desk"))
	# PLAY-02: the night page after an unanswered visitor.
	await _new_game()
	check("PLAY-02 no night page before a night is left", not m._tip_ready("night"))
	m.day = 3
	m.event_fired_day = -1
	var note: String = m.nights._end_night()
	check("PLAY-02 a night left alone is counted", int(m.stats.get("left_alone", 0)) >= 1, note)
	check("PLAY-02 the morning says what it cost", note.contains("Sanity -"), note)
	check("PLAY-02 the night page is then ready", m._tip_ready("night"))


# --- PLAY-10, PLAY-12, PLAY-17 ------------------------------------------------------------------------------------

func _qol_cases() -> void:
	await _new_game()
	check("PLAY-12 the bare fishing pole is not locked", m._hotbar_unlocked("rod"))
	var spot := Vector2i(-1, -1)
	for t in m.fish_spots:
		if m.map[t.y][t.x] == MainGame.Tile.WATER:
			spot = t
			break
	if spot.x < 0:
		print("note: no fishing spot on water in this game; PLAY-10 not checked")
	else:
		m.water = 40.0
		# Stand beside the spot, facing it.
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var st: Vector2i = spot + d
			if m._in_bounds(st) and not m._is_blocked_world(m._tile_center(st.x, st.y)):
				m.player.position = m._tile_center(st.x, st.y)
				m.player.facing = Vector2(-d)
				break
		await frames(2)
		var w0: float = m.water
		m._tool_press = false
		m._interact()
		check("PLAY-10 the hand action at a fishing spot drinks", m.water > w0, "%d -> %d %s" % [int(w0), int(m.water), m.message_label.text])
	m.tool_tier["pick"] = 0
	m._tool_press = true
	m._need_tool("pick")
	m._tool_press = false
	check("PLAY-17 no pick: says how to make one", m.message_label.text.contains("Make a stone pick"), m.message_label.text)
	m.tool_tier["hatchet"] = 0
	m._need_tool("axe")
	check("PLAY-17 no hatchet: says how to make one", m.message_label.text.contains("crude hatchet"), m.message_label.text)
	check("PLAY-17 the cave page names the pick and a weapon", str(m._tip_data("cave")["text"]).contains("pick") and str(m._tip_data("cave")["text"]).contains("weapon"))


# --- PLAY-09: the first trek's frozen walker --------------------------------------------------------------------

func _trek_cases() -> void:
	await _new_game()
	m.day = 4
	m.lantern_tier = 1
	m.materials["lamp_oil"] = 2
	m.inventory["trail_ration"] = 0
	m.inventory["bread"] = 0
	m.trek._start("edge")
	await frames(20)
	check("PLAY-09 the edge trek starts", m.trek.active)
	if not m.trek.active:
		return
	m.trek.nerve = m.trek.FREEZE_BELOW - 1.0
	m.trek.spoke = true   # a word already used in this clearing
	await frames(3)
	check("PLAY-09 she freezes", m.trek.frozen)
	# The last few logged lines: an achievement notice (Tin Light) can land after the freeze line (CCH-EVENING-001).
	var t := ""
	for i in mini(3, m.message_log.size()):
		t += str(m.message_log[m.message_log.size() - 1 - i]["text"]) + " | "
	check("PLAY-09 the frozen line offers a word and turning back", t.contains("word") and t.contains("turn home"), t)
	check("PLAY-09 the frozen line does not ask for a ration the player lacks", not t.contains("Give her a trail ration"), t)
	m.player.position = m.trek.walker_pos + Vector2(m.PX * 0.5, 0)
	m._tool_press = false
	m.trek._interact(m._tile_in_front())
	await frames(3)
	check("PLAY-09 a word calms her enough to go on", not m.trek.frozen and m.trek.nerve >= m.trek.UNFREEZE_AT - 1.0, "nerve %d frozen %s" % [int(m.trek.nerve), m.trek.frozen])
	# Another route still needs a ration.
	m.trek._abort()
	await frames(5)
	m.trek._start("mill")
	await frames(20)
	if m.trek.active:
		m.trek.nerve = m.trek.FREEZE_BELOW - 1.0
		await frames(3)
		m.trek.spoke = false
		m.player.position = m.trek.walker_pos + Vector2(m.PX * 0.5, 0)
		m._tool_press = false
		m.trek._interact(m._tile_in_front())
		await frames(3)
		check("PLAY-09 on other routes a word alone does not unfreeze", m.trek.frozen, "nerve %d" % int(m.trek.nerve))
		m.trek._abort()
	# The low-sanity warning at the offer.
	m.sanity = 30.0
	check("PLAY-09 a frayed farmer is warned before setting out", m.trek._low_sanity_warning().contains("sanity 30"))
