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
