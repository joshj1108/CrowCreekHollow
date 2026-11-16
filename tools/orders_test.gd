extends SceneTree

# CCH-CORE-LOOP-003: the food changes and Wicker Cove's repeatable notices. Run headless from the project folder:
#   godot --path . --headless -s tools/orders_test.gd
# Plays in save slot 9 (deleted when done; slots 1-3 are never touched). Prints ok or FAIL for each case and a
# total; the exit code is the number of failures. DIRECT STATE tests: the game's own functions are called with set
# state (no walking, no input). Covers: turnip hash and fish stew through StallSystem._make_food; the first order's
# any-crop bug; the board staying empty until the first order is in; each notice kind (what it asks, its coins over
# the stand); taking on, handing in, refusing short, paying once, declining without penalty; the week's rotation and
# expiry; determinism across save/load; old saves; the panel's action strings; Thomas's line after a real delivery.

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


func _set_day(d: int) -> void:
	m.day = d
	m.current_hour = 10.0


func _run() -> void:
	var t := m.town
	_set_day(2)
	# --- Food ------------------------------------------------------------------------------------
	m.inventory["crops"] = 3
	m.materials["wood"] = 10
	var hash0 := int(m.inventory["turnip_hash"])
	m.stall._make_food("turnip_hash")
	_check("food: turnip hash takes one turnip and one wood", int(m.inventory["crops"]) == 2 and int(m.materials["wood"]) == 9 and int(m.inventory["turnip_hash"]) == hash0 + 1)
	var hash_f := Foods.find("turnip_hash")
	_check("food: turnip hash restores as much Hunger as the raw turnip, and warms", Foods.food_restore(hash_f) >= Foods.food_restore(Foods.find("turnip")) and int(hash_f["effect"]["warm"]) == 10)
	m.warmth = 50.0
	m.food = 40.0
	m.stall._eat_food("turnip_hash")
	_check("food: eating it fills Hunger and warmth", is_equal_approx(m.food, 40.0 + Foods.food_restore(hash_f)) and m.warmth >= 59.9)
	m.skill_xp["Cooking"] = m.progression._xp_for_level(3)
	m.inventory["crops"] = 1
	m.inventory["fish"] = 1
	m.stall._make_food("fish_stew")
	_check("food: fish stew takes a fish and one turnip", int(m.inventory["fish_stew"]) >= 1 and int(m.inventory["crops"]) == 0 and int(m.inventory["fish"]) == 0)
	var stew_in := Foods.food_restore(Foods.find("perch")) + Foods.food_restore(Foods.find("turnip"))
	_check("food: fish stew restores more than its raw fish and turnip", Foods.food_restore(Foods.find("fish_stew")) > stew_in)
	m.skill_xp["Cooking"] = 0
	m.inventory["fish_stew"] = 0

	# --- The first order: turnips only -----------------------------------------------------------
	_check("board: empty until the first order is in", not t.notices_up() or t.order_open())
	t._refresh_board()
	_check("board: no repeat notices before the turnips", t.board.is_empty())
	m.inventory["crops"] = 0
	m.inventory["kale"] = 6
	var coins := m.money
	_check("first order: six kale are not six turnips (the old any-crop bug)", not t.deliver("thomas_turnips") and int(m.inventory["crops"]) == 0 and int(m.inventory["kale"]) == 6 and m.money == coins)
	m.inventory["crops"] = 7
	_check("first order: six turnips pay 70", t.deliver("thomas_turnips") and int(m.inventory["crops"]) == 1 and int(m.inventory["kale"]) == 6 and m.money == coins + 70)
	_check("first order: still only once", not t.deliver("thomas_turnips") and m.money == coins + 70)
	m.inventory["kale"] = 0

	# --- Notices go up ---------------------------------------------------------------------------
	t._refresh_board()
	_check("board: three notices once the turnips are in", t.board.size() == 3 and t.notices_up())
	var ok := true
	for kind in TownData.ORDER_KINDS:
		var e: Dictionary = t.board[kind]
		var stand := int(e["n"]) * t._stand_price(str(e["food"]))
		ok = ok and int(e["coins"]) > stand and int(e["coins"]) <= int(ceil(stand * 1.7)) and t._option_ok(str(e["food"]))
		print("      notice %s: %s for %d coins (stand %d)" % [kind, t._notice_want(e), int(e["coins"]), stand])
	_check("board: each pays over the stand, at most ~1.7x, and can be filled now", ok)
	_check("board: no impossible early asks (no hens, goats, smokehouse or Cooking 3 yet)",
		["egg", "milk", "smoked_fish", "fish_stew"].all(func(f: String) -> bool: return not TownData.ORDER_KINDS.any(func(k: String) -> bool: return str(t.board[k]["food"]) == f)))
	var before := t.board.duplicate(true)
	t._refresh_board()
	_check("board: looking again changes nothing", t.board == before)

	# --- Taking on and handing in ----------------------------------------------------------------
	_check("deliver: an untaken notice can't be handed in", not t.deliver_notice("produce"))
	m._on_panel_action("town:accept|produce")
	_check("accept: by the panel's action string", bool(t.board["produce"]["taken"]))
	_check("accept: not twice", not t.accept("produce"))
	var p: Dictionary = t.board["produce"]
	var key := str(p["key"])
	var n := int(p["n"])
	_give(key, n - 1)
	coins = m.money
	_check("deliver: one short is refused, nothing taken", not t.deliver_notice("produce") and m._held(key) == n - 1 and m.money == coins and t.board.has("produce"))
	_give(key, n + 2)
	m._on_panel_action("town:deliver|produce")
	_check("deliver: the lot is taken and paid, by the panel's action string", m._held(key) == 2 and m.money == coins + int(p["coins"]) and not t.board.has("produce"))
	_check("deliver: a memory record and flag for the delivery", t.history.size() == 1 and str(t.history[0]["kind"]) == "produce" and int(t.history[0]["coins"]) == int(p["coins"]) and int(t.flags.get("order_produce", -1)) == 2)
	coins = m.money
	_check("deliver: never twice", not t.deliver_notice("produce") and m.money == coins and m._held(key) == 2)
	t._refresh_board()
	_check("rotation: no new produce notice the same week", not t.board.has("produce"))
	var line := t._line("thomas")
	_check("thomas: his line is the newest delivery's, naming it", line == str(TownData.REPEAT_DONE_LINES["produce"]) % str(t.history[0]["label"]))
	_set_day(5)
	_check("thomas: no delivery line days later", t._line("thomas") != str(TownData.REPEAT_DONE_LINES["produce"]) % str(t.history[0]["label"]))

	# Any fish, a group: spent cheapest first, never below zero.
	t.accept("household")
	var h: Dictionary = t.board["household"]
	if str(h["food"]) == "any_fish":
		m.inventory["fish"] = 1
		m.inventory["trout"] = 1
		m.inventory["bluegill"] = 2
		_check("deliver: any fish, cheapest first", t.deliver_notice("household") and int(m.inventory["bluegill"]) == 0 and int(m.inventory["fish"]) == 0 and int(m.inventory["trout"]) == 1)
	else:
		_check("deliver: household notice (%s)" % str(h["food"]), false)
	ok = true
	for k in m.inventory:
		if typeof(m.inventory[k]) == TYPE_INT and int(m.inventory[k]) < 0:
			ok = false
	_check("pack: nothing below zero", ok)

	# Prepared food, made at the fire.
	var pr: Dictionary = t.board["prepared"]
	t.accept("prepared")
	var made := 0
	for i in int(pr["n"]):
		m.inventory["crops"] = 2
		m.inventory["fish"] = 1
		m.materials["wood"] = 5
		var had := m._held(str(pr["key"]))
		m.stall._make_food(str(pr["food"]))
		made += m._held(str(pr["key"])) - had
	coins = m.money
	_check("prepared: cooked at the fire and handed in", made == int(pr["n"]) and t.deliver_notice("prepared") and m.money == coins + int(pr["coins"]))

	# --- Declining -------------------------------------------------------------------------------
	_set_day(8)   # week 1
	t._refresh_board()
	_check("rotation: a new week puts up all three again", t.board.size() == 3)
	_check("rotation: the produce ask is picked by the week, not reused blindly", t.board.has("produce"))
	coins = m.money
	var san := m.sanity
	m._on_panel_action("town:decline|prepared")
	t._refresh_board()
	_check("decline: no coins, sanity or anything lost; gone until next week", m.money == coins and is_equal_approx(m.sanity, san) and not t.board.has("prepared"))
	_set_day(10)
	t._refresh_board()
	_check("decline: no re-roll the same week", not t.board.has("prepared"))

	# --- Expiry: untaken notices come down at the week's turn; taken ones stay -------------------
	t.accept("household")
	var taken: Dictionary = t.board["household"].duplicate()
	_set_day(15)  # week 2
	t._refresh_board()
	_check("expiry: a taken notice is kept past the week", t.board.has("household") and int(t.board["household"]["week"]) == int(taken["week"]))
	_check("expiry: an untaken one is replaced by this week's", t.board.has("produce") and int(t.board["produce"]["week"]) == 2)
	_check("expiry: the declined kind is back the next week", t.board.has("prepared"))

	# --- Save and load ---------------------------------------------------------------------------
	m.current_hour = 21.0
	var board := t.board.duplicate(true)
	var hist := t.history.duplicate(true)
	var money := m.money
	m.saver._save_game()
	t.board = {}
	t.history = []
	t.slot_week = {}
	m.money = 0
	_check("load: loads", m.saver._load_game())
	_check("load: notices, taken state and history come back", t.board == board and t.history == hist and m.money == money)
	t._refresh_board()
	_check("load: no re-roll after loading", t.board == board)
	var e2: Dictionary = t.board["household"]
	_give(str(e2["key"]), int(e2["n"]))
	coins = m.money
	_check("load: a taken notice still hands in once", t.deliver_notice("household") and m.money == coins + int(e2["coins"]) and not t.deliver_notice("household"))

	# An older save (the alpha's town data, turnips done, no board): keeps the turnips, gets notices.
	var raw := _raw(path)
	raw["town"] = {"visits": 3, "flags": {"arrived": 2, "delivered": 4}, "orders_done": {"thomas_turnips": 4}}
	_write(path, JSON.stringify(raw))
	_check("alpha save: loads", m.saver._load_game())
	_check("alpha save: the turnip order stays done", t.orders_done.has("thomas_turnips") and not t.order_open() and not t.deliver("thomas_turnips"))
	t._refresh_board()
	_check("alpha save: the board fills", t.board.size() >= 2 and t.history.is_empty())
	# An alpha save with the turnips still open: no notices yet.
	raw["town"] = {"visits": 1, "flags": {"arrived": 2}, "orders_done": {}}
	_write(path, JSON.stringify(raw))
	m.saver._load_game()
	t._refresh_board()
	_check("alpha save, turnips open: the order stands, no notices", t.order_open() and t.board.is_empty())
	# Malformed notices are dropped, not trusted.
	raw["town"] = {"orders_done": {"thomas_turnips": 4}, "board": {"produce": {"food": "gold", "n": 5, "coins": 999}, "bogus": {}, "household": {"food": "egg", "n": -3, "coins": 10}},
		"slot_week": {"produce": "x"}, "history": [1, {"kind": "nope"}]}
	_write(path, JSON.stringify(raw))
	_check("bad notice data: loads and drops it", m.saver._load_game() and not t.board.has("bogus") and t.history.is_empty()
		and (not t.board.has("produce") or str(t.board["produce"]["food"]) != "gold"))

	# --- Rows the panels build -------------------------------------------------------------------
	t._refresh_board()
	var rows := t._rows("Notice board")
	var acts := rows.filter(func(r: Dictionary) -> bool: return str(r.get("action", "")).begins_with("town:"))
	_check("panel: the board offers Take it and Decline for open notices", acts.any(func(r: Dictionary) -> bool: return str(r["action"]).begins_with("town:accept|")) and acts.any(func(r: Dictionary) -> bool: return str(r["action"]).begins_with("town:decline|")))
	t.accept("produce")
	rows = t._rows("Store")
	_check("panel: Thomas's counter offers Hand in for a taken notice", rows.any(func(r: Dictionary) -> bool: return str(r.get("action", "")) == "town:deliver|produce"))


func _give(key: String, n: int) -> void:
	if key == "turnips":
		m.inventory["crops"] = n
	elif key == "any_fish":
		for k in Foods.group("any_fish"):
			m.inventory[k] = 0
		m.inventory["fish"] = n
	elif m.materials.has(key):
		m.materials[key] = n
	else:
		m.inventory[key] = n


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
