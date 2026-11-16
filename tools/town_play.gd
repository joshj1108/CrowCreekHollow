extends "res://tools/audit_play.gd"

# CCH-WICKER-COVE-ALPHA-001: one visit to Wicker Cove played with injected input only (the CCH-PLAYABLE-001 bot,
# tools/audit_play.gd): through the title menu to a new game, then to the east gate, down the road, Thomas's
# counter (his first-meeting scene, the order, a purchase), the fish market, the inn (Edith's scene, a meal to
# carry), and back up the road home. Every action is a key, mouse or Xbox press.
# Controlled setup, not play: the day is set to 2 at 09:00 (the road opens on day 2) and the pack is given
# 8 turnips and 60 coins, so the order and a purchase can be tried in one visit. That is logged as SETUP.
# It is NOT a human player. Run windowed, in a throwaway profile:
#   APPDATA=<scratch> godot --path . --fixed-fps 60 --disable-vsync -s tools/town_play.gd -- scenario=town dev=kbm out=<dir>
# Prints "TOWN-PLAY PASS" or "TOWN-PLAY FAIL n" at the end (n = the steps that did not do what they should).

var fails := 0


# The village's doors and the road home take you somewhere when stepped on, like the farm's doors.
func _warp(t: Vector2i) -> bool:
	if m.town.active:
		return m.town._char(t) in ["D", "X", "E"]
	return super._warp(t)


# Walks beside a tile that takes you elsewhere, then steps onto it and waits until it has.
func step_onto(t: Vector2i, what: String) -> bool:
	var spots := free_neighbours(t)
	if spots.is_empty() or not await walk(spots, what):
		return false
	var d: Vector2i = t - here()
	var name := ""
	for k in DIRS:
		if DIRS[k] == d:
			name = k
	var was := [m.town.active, m.town.indoors]
	dir_set(name, true)
	for i in 120:
		await process_frame
		if [m.town.active, m.town.indoors] != was or m.transitioning:
			break
	release_dirs()
	await wait_transition()
	return [m.town.active, m.town.indoors] != was


func check(what: String, ok: bool) -> void:
	note("CHECK", "%s %s" % ["ok" if ok else "FAILED", what])
	if not ok:
		fails += 1


func _sc_town() -> void:
	await start_new_game()
	await frames(60)
	close_all()
	m.day = 2
	m.current_hour = 9.0
	m.clock = (9.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	if opt.has("weather"):   # weather=KIND pins the day's weather (it is random per new game), for comparisons
		m.weather_kind = str(opt["weather"])
	m.inventory["crops"] = 8
	m.money = 60
	note("SETUP", "day 2, 09:00, 8 turnips and 60 coins in the pack")
	if m.inside:
		await leave_house()
	# To the gate: the tile inside it on the road, facing east.
	var spot := m._world_tile(58, 35)
	check("walked to the east gate", await walk([spot], "the east gate"))
	await face("right")
	await shot("gate")
	await use()
	check("the gate asks first", not m.town.active)
	await use()
	await wait_transition()
	check("down the road to Wicker Cove", m.town.active and here() == TownLayout.ARRIVE)
	await shot("arrive")
	# Thomas.
	check("reached Thomas's counter", await approach(Vector2i(14, 8), "the store counter"))
	await use()
	for i in 8:
		if not m.folk._in_scene():
			break
		if i < 2:
			await shot("thomas_scene_%d" % i)
		await use()
	await frames(20)
	check("Thomas's scene leads to his store", m.open_tab == "Store" and m.town.flags.has("met_thomas"))
	var coins := m.money
	check("handed in the turnip order", await ledger_do("town:deliver|thomas_turnips") and m.money == coins + 70 and int(m.inventory["crops"]) == 2)
	coins = m.money
	var oil := int(m.materials["lamp_oil"])
	await ledger_do("town:buy|store|lamp_oil")
	check("bought lamp oil", int(m.materials["lamp_oil"]) == oil + 1 and m.money == coins - 9)
	await shot("store")
	close_all()
	await frames(10)
	# The fish market.
	check("reached the fish market", await approach(Vector2i(10, 20), "the fish counter"))
	await use()
	await frames(10)
	check("the fish market opens", m.open_tab == "Fish market")
	await shot("market")
	close_all()
	await frames(10)
	# The inn.
	var door := TownLayout.INN_DOOR
	check("walked into the inn", await step_onto(door, "the inn door") and m.town.indoors)
	await frames(20)
	var counter := TownLayout.INT_ORIGIN + Vector2i(7, 4)
	check("reached Edith's counter", await approach(counter, "the inn counter"))
	await use()
	for i in 8:
		if not m.folk._in_scene():
			break
		if i < 1:
			await shot("edith_scene_%d" % i)
		await use()
	await frames(20)
	check("Edith's scene leads to the inn's counter", m.open_tab == "The inn" and m.town.flags.has("met_edith"))
	coins = m.money
	var stew := int(m.inventory["fish_stew"])
	await ledger_do("town:buy|inn|fish_stew")
	check("bought a pot of stew", int(m.inventory["fish_stew"]) == stew + 1 and m.money == coins - 17)
	await shot("inn")
	close_all()
	await frames(10)
	var out := TownLayout.INT_ORIGIN + TownLayout.INT_EXIT
	check("out of the inn", await step_onto(out, "the inn's way out") and not m.town.indoors)
	# Home.
	var hour := m.current_hour
	check("walked up the road", await step_onto(Vector2i(19, 0), "the road home"))
	check("home inside the east gate", not m.town.active and not m.in_cave and here() == m._world_tile(TownSystem.HOME_IX.x, TownSystem.HOME_IX.y))
	check("half an hour for the walk back", m.current_hour >= hour + 0.5)
	await shot("home")
	note("OBS", "end " + state())
	print("TOWN-PLAY %s" % ("PASS" if fails == 0 else "FAIL %d" % fails))


# CCH-CORE-LOOP-003: the repeatable notices, played with injected input. Controlled setup (logged as SETUP): day 2,
# 09:00, 14 turnips, 3 perch, 1 wood short of nothing, 40 coins. Down the road; Thomas's scene and the turnip order
# at his counter; the notice board by its own tile (Space / A facing it): take the produce and household notices,
# decline the prepared one; back to the counter to hand both in; Thomas's word about the delivery; home.
#   ... -s tools/town_play.gd -- scenario=orders dev=kbm out=<dir>     (dev=pad for an Xbox controller)
func _sc_orders() -> void:
	await start_new_game()
	await frames(60)
	close_all()
	m.day = 2
	m.current_hour = 9.0
	m.clock = (9.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	if opt.has("weather"):   # weather=KIND pins the day's weather (it is random per new game), for comparisons
		m.weather_kind = str(opt["weather"])
	m.inventory["crops"] = 14
	m.inventory["fish"] = 3
	m.money = 40
	note("SETUP", "day 2, 09:00, 14 turnips, 3 perch and 40 coins in the pack")
	if m.inside:
		await leave_house()
	check("walked to the east gate", await walk([m._world_tile(58, 35)], "the east gate"))
	await face("right")
	await use()
	await use()
	await wait_transition()
	check("down the road to Wicker Cove", m.town.active)
	check("reached Thomas's counter", await approach(Vector2i(14, 8), "the store counter"))
	await use()
	for i in 8:
		if not m.folk._in_scene():
			break
		await use()
	await frames(20)
	var coins := m.money
	check("handed in the turnip order", await ledger_do("town:deliver|thomas_turnips") and m.money == coins + 70 and int(m.inventory["crops"]) == 8)
	close_all()
	await frames(10)
	check("reached the notice board", await approach(Vector2i(13, 8), "the notice board"))
	await use()
	await frames(15)
	check("the notice board opens by its tile", m.open_tab == "Notice board")
	var b: Dictionary = m.town.board
	note("OBS", "notices: " + ", ".join(TownData.ORDER_KINDS.map(func(k): return "%s=%s for %d" % [k, m.town._notice_want(b[k]), int(b[k]["coins"])] if b.has(k) else k + "=none")))
	check("three notices are up", b.size() == 3)
	await shot("board_open")
	check("took the produce notice", await ledger_do("town:accept|produce") and bool(m.town.board["produce"]["taken"]))
	check("took the household notice", await ledger_do("town:accept|household") and bool(m.town.board["household"]["taken"]))
	coins = m.money
	check("declined the prepared notice, nothing lost", await ledger_do("town:decline|prepared") and not m.town.board.has("prepared") and m.money == coins)
	await shot("board_taken")
	close_all()
	await frames(10)
	check("back at Thomas's counter", await approach(Vector2i(14, 8), "the store counter"))
	await use()
	await frames(15)
	check("the counter opens", m.open_tab == "Store")
	await shot("counter_taken")
	var p: Dictionary = m.town.board["produce"].duplicate()
	var h: Dictionary = m.town.board["household"].duplicate()
	coins = m.money
	var crops := int(m.inventory["crops"])
	check("handed in the produce notice", await ledger_do("town:deliver|produce") and m.money == coins + int(p["coins"]) and int(m.inventory["crops"]) == crops - int(p["n"]))
	await shot("delivered_produce")
	coins = m.money
	check("handed in the household notice", await ledger_do("town:deliver|household") and m.money == coins + int(h["coins"]) and m._held("any_fish") == 0)
	check("the counter offers no second payment", m.town.board.is_empty() or not m.town.board.has("produce"))
	close_all()
	await frames(10)
	await use()   # reopen the counter: the detail page shows Thomas's word first
	await frames(15)
	check("Thomas speaks of the delivery", m.town._line("thomas").find(str(m.town.history[-1]["label"])) >= 0)
	await shot("thomas_after")
	close_all()
	await frames(10)
	check("walked up the road", await step_onto(Vector2i(19, 0), "the road home"))
	check("home inside the east gate", not m.town.active)
	note("OBS", "end " + state() + " history=" + str(m.town.history))
	print("TOWN-PLAY %s" % ("PASS" if fails == 0 else "FAIL %d" % fails))
