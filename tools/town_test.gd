extends SceneTree

# CCH-WICKER-COVE-ALPHA-001: a smoke test of Wicker Cove. Run headless from the project folder:
#   godot --path . --headless -s tools/town_test.gd
# Plays in save slot 9 (deleted when done; slots 1-3 are never touched). Prints PASS or FAIL for each case and a
# total; the exit code is the number of failures. Covers the gate and the road (both ways, three times over),
# the time each way costs, collision and doors, both residents, buying (and refusing), selling, the order (once
# only), the panel's action strings, saving and loading, an old save without the village, and a day ending away.

const SLOT := 9

var m: MainGame
var started := false
var failures := 0
var path := ""


func _initialize() -> void:
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)


func _process(_delta: float) -> bool:
	if started:
		return true
	started = true
	path = TitleMenu.slot_path(SLOT)
	SaveSystem.delete_save(path)
	m._on_title_start("new", SLOT)
	m.set_process(false)
	_run()
	SaveSystem.delete_save(path)
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
	return true


func _gate_tile() -> Vector2i:
	return m._world_tile(59, 35)


func _stand_at_gate() -> void:
	var t := m._world_tile(58, 35)
	m.player.position = m._tile_center(t.x, t.y)
	m.player.facing = Vector2.RIGHT


func _run() -> void:
	var t := m.town
	# --- The gate -------------------------------------------------------------------------------
	m.day = 1
	m.current_hour = 9.0
	_stand_at_gate()
	_check("gate: the walker is asked before the gate (MainGame._interact order)", _walker_first())
	_check("gate: facing it from the road picks the gate tile", m._tile_in_front() == _gate_tile())
	_check("gate: the gate still blocks on the farm", m._is_blocked_world(m._tile_center(_gate_tile().x, _gate_tile().y)))
	_check("gate: day 1 keeps you home", t._try_gate(_gate_tile()) and not t.active)
	m.day = 2
	m.clock = (9.0 - m.START_HOUR) / (m.DAY_END_HOUR - m.START_HOUR) * m.DAY_LENGTH
	m.current_hour = 9.0
	t.confirm_until = 0.0
	_check("gate: first press only asks", t._try_gate(_gate_tile()) and not t.active)
	var food0 := m.food
	var money0 := m.money
	var inv0 := m.inventory.duplicate()
	t._try_gate(_gate_tile())
	_check("travel: second press goes down", t.active and m.in_cave and not m.inside and not t.indoors)
	_check("travel: arrive at the top of the road", m._player_tile() == TownLayout.ARRIVE)
	_check("travel: half an hour passes", absf(m.current_hour - 9.5) < 0.01)
	_check("travel: needs go down, nothing is refilled", m.food < food0 and m.food > food0 - 5.0)
	_check("travel: coins and pack untouched", m.money == money0 and m.inventory == inv0)
	_check("travel: first arrival recorded", int(t.flags.get("arrived", -1)) == 2 and t.visits == 1)
	_check("map: arrival tile is open road", not m._is_blocked_world(m.player.position))
	_check("map: the store counter is solid", m._is_blocked_world(m._tile_center(14, 8)))
	_check("map: the sea is solid", m._is_blocked_world(m._tile_center(10, 26)))
	_check("map: the pier is walkable to its end", _walkable_line(Vector2i(19, 21), Vector2i(19, 28)))
	_check("map: the road runs from the arrival to the quay", _walkable_line(Vector2i(19, 1), Vector2i(19, 21)))
	_check("map: the inn's lane reaches its door", _walkable_line(Vector2i(21, 18), Vector2i(29, 18)))
	_check("map: the fish counter is reached from the quay", not m._is_blocked_world(m._tile_center(10, 21)))
	_check("map: every building rectangle is solid", _buildings_solid())
	_check("camera: limits are the village", m.camera.limit_right == TownLayout.W * m.PX and m.camera.limit_bottom == TownLayout.H * m.PX)
	_check("layers: the village's front layer, fog and lights are on", t.front.visible and t.fog.visible and t.lights.size() > 5 and (t.lights[0] as PointLight2D).enabled)

	# --- The inn --------------------------------------------------------------------------------
	m.player.position = m._tile_center(TownLayout.INN_DOOR.x, TownLayout.INN_DOOR.y)
	m._check_doors()
	var entry := TownLayout.INT_ORIGIN + TownLayout.INT_ENTRY
	_check("inn: the door takes you in", t.indoors and m._player_tile() == entry)
	_check("inn: inside, the room's floor is open", not m._is_blocked_world(m.player.position))
	m.player.facing = Vector2.UP
	m.player.position = m._tile_center(entry.x + 2, TownLayout.INT_ORIGIN.y + 5)
	m._interact()
	_check("inn: Edith's counter opens the inn", m.open_tab == "The inn" and t.flags.has("met_edith"))
	m._close_panel()
	m.player.position = m._tile_center(TownLayout.INT_ORIGIN.x + TownLayout.INT_EXIT.x, TownLayout.INT_ORIGIN.y + TownLayout.INT_EXIT.y)
	m._check_doors()
	_check("inn: the mat takes you out to the lane", not t.indoors and m._player_tile() == TownLayout.INN_OUT)

	# --- Thomas, buying -------------------------------------------------------------------------
	m.player.position = m._tile_center(14, 9)
	m.player.facing = Vector2.UP
	m._interact()
	_check("store: Thomas's counter opens the store", m.open_tab == "Store" and t.flags.has("met_thomas"))
	_check("store: rows build", t._rows("Store").size() > 6)
	m.money = 100
	var oil0 := int(m.materials["lamp_oil"])
	_check("buy: two flasks of oil", t.buy("store", "lamp_oil", 2) == 2 and int(m.materials["lamp_oil"]) == oil0 + 2 and m.money == 82)
	_check("buy: only the day's stock is sold", t.buy("store", "lamp_oil", 5) == 1 and m.money == 73)
	_check("buy: sold out until tomorrow", t.buy("store", "lamp_oil", 1) == 0 and m.money == 73)
	m.money = 3
	var band0 := int(m.inventory["bandage"])
	_check("buy: refused without the coins", t.buy("store", "bandage", 1) == 0 and m.money == 3 and int(m.inventory["bandage"]) == band0)
	m.money = 50
	_check("buy: coins limit how many", t.buy("store", "bandage", 9) == 2 and m.money == 26)
	m.money = 40
	var rope0 := int(m.materials["rope"])
	m._on_panel_action("town:buy|store|rope:2")
	_check("panel: an action string with an amount", int(m.materials["rope"]) == rope0 + 2 and m.money == 26)
	_check("buy: unknown item or shop does nothing", t.buy("store", "gold", 1) == 0 and t.buy("bank", "rope", 1) == 0 and m.money == 26)
	# A full pack takes nothing more that goes in the pack.
	var saved_hash := int(m.inventory["turnip_hash"])
	m.inventory["turnip_hash"] = m.stall._pack_capacity() * m.STACK_SIZE
	m.money = 200
	_check("buy: no room in the pack, nothing bought", t.buy("store", "trail_ration", 1) == 0 and m.money == 200)
	m.inventory["turnip_hash"] = saved_hash

	# --- Selling ----------------------------------------------------------------------------------
	m.inventory["crops"] = 20
	m.money = 0
	var turnip := m.stall._food_price("turnip")
	_check("sell: the store takes 12 a day", t.sell("store", "turnip", 15) == 12 * turnip and int(m.inventory["crops"]) == 8)
	_check("sell: then no more today", t.sell("store", "turnip", 1) == 0 and int(m.inventory["crops"]) == 8)
	_check("sell: the store won't buy fish", t.sell("store", "perch", 1) == 0)
	m.inventory["fish"] = 3
	_check("sell: the fish market buys fish", t.sell("market", "perch", -1) == 3 * m.stall._food_price("perch") and int(m.inventory["fish"]) == 0)
	_check("sell: nothing held, nothing paid", t.sell("market", "perch", 1) == 0)
	_check("hooks: first trade recorded", int(t.flags.get("traded", -1)) == 2)

	# --- The order ----------------------------------------------------------------------------------
	m.inventory["crops"] = 5
	var coins := m.money
	_check("order: five turnips aren't six", not t.deliver("thomas_turnips") and int(m.inventory["crops"]) == 5 and m.money == coins)
	m.inventory["crops"] = 8
	_check("order: six are handed in, all at once", t.deliver("thomas_turnips") and int(m.inventory["crops"]) == 2 and m.money == coins + 70)
	m.inventory["crops"] = 20
	_check("order: only once", not t.deliver("thomas_turnips") and int(m.inventory["crops"]) == 20 and m.money == coins + 70)
	_check("order: the board shows it done", not t.order_open() and int(t.flags.get("delivered", -1)) == 2)

	# --- Home, and the road again --------------------------------------------------------------
	var hour := m.current_hour
	m.player.position = m._tile_center(19, 1)
	m.player.facing = Vector2.UP
	m.player.position = m._tile_center(19, 0)
	m._check_doors()
	var home := m._world_tile(TownSystem.HOME_IX.x, TownSystem.HOME_IX.y)
	_check("home: the road at the top takes you home", not t.active and not m.in_cave and m._player_tile() == home)
	_check("home: half an hour back up", absf(m.current_hour - hour - 0.5) < 0.01)
	_check("home: the farm's bounds again", m.camera.limit_right == m.MAP_W * m.PX)
	_check("home: back inside the east gate, on open road", not m._is_blocked_world(m.player.position))
	var ok := true
	for i in 3:
		m.current_hour = 10.0
		t.go(true)
		var a := m._player_tile()
		t.go(false)
		ok = ok and a == TownLayout.ARRIVE and m._player_tile() == home and not t.active and not m.in_cave
	_check("travel: three round trips land in the same places", ok)
	m.current_hour = 20.5
	t.confirm_until = 0.0
	_stand_at_gate()
	t._try_gate(_gate_tile())
	t._try_gate(_gate_tile())
	_check("gate: shut after dark", not t.active)

	# --- Saving ---------------------------------------------------------------------------------
	m.current_hour = 10.0
	t.go(true)
	m.saver._save_game()
	var raw := _raw(path)
	_check("save: made in the village puts you at the homestead", Vector2(raw["player_pos"][0], raw["player_pos"][1]) == m._tile_center(m.HOMESTEAD_ARRIVE.x, m.HOMESTEAD_ARRIVE.y))
	_check("save: records the village", typeof(raw.get("town")) == TYPE_DICTIONARY and int(raw["town"]["visits"]) == t.visits)
	t.go(false)
	var visits := t.visits
	var money := m.money
	var crops := int(m.inventory["crops"])
	m.saver._save_game()
	t.visits = 0
	t.orders_done = {}
	t.flags = {}
	m.money = 1
	m.inventory["crops"] = 0
	_check("load: loads", m.saver._load_game())
	_check("load: the village comes back", t.visits == visits and t.orders_done.has("thomas_turnips") and t.flags.has("met_thomas") and not t.active)
	_check("load: coins and pack come back", m.money == money and int(m.inventory["crops"]) == crops)
	_check("load: no order paid twice", not t.deliver("thomas_turnips") and m.money == money)
	# An older save, from before the village: no `town`, version 16.
	raw = _raw(path)
	raw.erase("town")
	raw["save_version"] = 16
	_write(path, JSON.stringify(raw))
	_check("old save: loads", m.saver._load_game())
	_check("old save: nobody has met you, the order stands", t.visits == 0 and t.flags.is_empty() and t.order_open())
	_check("old save: lifted to this version", int(SaveSystem.read_save(path).get("save_version", 0)) == SaveSystem.SAVE_VERSION)
	# Garbage in the village's key: ignored, safe defaults.
	raw["town"] = {"visits": "lots", "flags": [1, 2], "orders_done": {"thomas_turnips": "x"}}
	raw["save_version"] = SaveSystem.SAVE_VERSION
	_write(path, JSON.stringify(raw))
	_check("bad village data: loads", m.saver._load_game() and t.flags.is_empty())

	# --- The day ending away ---------------------------------------------------------------------
	m.current_hour = 10.0
	t.go(true)
	m._end_day("Test.")
	_check("day end in the village: you wake at the homestead", not t.active and not m.in_cave and m._player_tile() == m.HOMESTEAD_ARRIVE)
	m.current_hour = 10.0
	t.go(true)
	m._fallen()
	_check("a fall in the village: you wake at the homestead", not t.active and not m.in_cave)
	_check("stock: a new day restocks", t._stock_left("store", t._item("store", "lamp_oil")) == 3)


func _walker_first() -> bool:
	var src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var a := src.find("trek._try_walker(tile)")
	var b := src.find("town._try_gate(tile)")
	return a > 0 and b > a


func _walkable_line(a: Vector2i, b: Vector2i) -> bool:
	var d := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
	var p := a
	while true:
		if m._is_blocked_world(m._tile_center(p.x, p.y)):
			print("   blocked at ", p)
			return false
		if p == b:
			return true
		p += d
	return false


func _buildings_solid() -> bool:
	for id in TownLayout.BUILDINGS:
		var r: Rect2i = TownLayout.BUILDINGS[id]
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var c := str(TownLayout.TERRAIN[y][x])
				if c != "D" and not m._is_blocked_world(m._tile_center(x, y)):
					print("   open at ", Vector2i(x, y), " in ", id)
					return false
	return true


func _raw(p: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write(p: String, text: String) -> void:
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func _check(label: String, ok: bool) -> void:
	print("%s  %s" % ["ok  " if ok else "FAIL", label])
	if not ok:
		failures += 1
