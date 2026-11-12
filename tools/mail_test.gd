extends SceneTree

# CCH-CONSOLIDATED-003 Phase B: checks that the post is handled at the mailbox by the east gate, not at the desk.
# Run headless, from the project folder:
#   godot --path . --headless -s tools/mail_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Cases:
#   - migration: an old save's letters load with their read and unread state, a letter missing its state is kept as
#     unread, junk is dropped, pending catalog orders survive, and a save and load round trip changes nothing;
#   - the desk: no red light (no node, no variable, no code), using it opens the desk but reads no letters, and its
#     panel lists no letters;
#   - the mailbox: its tile blocks and can be faced from the road and the path, the prompt shows only while faced,
#     using it opens the Mailbox panel and reads every letter, a tool press or the house doesn't open it, read
#     letters can be cleared while unread ones stay;
#   - the flag: up while anything is unread, down once read, up again when the morning post brings a letter, and
#     the sprite's frame follows it (the door opens on use).
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

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


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


func _w(x: int, y: int) -> Vector2i:
	return Vector2i(x + m.BORDER_X, y + m.BORDER_Y)


func _stand(t: Vector2i, facing: Vector2) -> void:
	m.player.position = m._tile_center(t.x, t.y)
	m.player.facing = facing


func _states() -> Array:
	var out: Array = []
	for letter in m.desk_mail:
		out.append(bool(letter["unread"]))
	return out


func _titles(rows: Array) -> Array:
	var out: Array = []
	for row in rows:
		out.append(str(row.get("name", "")))
	return out


func _run() -> void:
	_migration()
	_desk()
	_mailbox()
	_flag()


func _migration() -> void:
	m.day = 12
	m.saver._save_game()
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	old.erase("save_version")
	old["desk_mail"] = [
		{"title": "Delivery", "text": "Your catalog order came.", "unread": true},
		{"title": "Receipt", "text": "Property tax paid.", "unread": false},
		{"title": "From the town clerk", "text": "No state saved."},
		"not a letter",
	]
	old["desk_orders"] = ["cards", "oil"]
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(old))
	f.close()
	m.desk_mail = []
	m.desk_orders = []
	_check("old save: loads", m.saver._load_game())
	_check("old save: every letter kept, junk dropped", m.desk_mail.size() == 3, "%d letters" % m.desk_mail.size())
	_check("old save: read and unread state kept", _states() == [true, false, true], str(_states()))
	_check("old save: two letters unread", m.mail._unread_count() == 2)
	_check("old save: pending catalog orders kept", m.desk_orders == ["cards", "oil"], str(m.desk_orders))
	m.saver._save_game()
	m.desk_mail = []
	_check("round trip: loads", m.saver._load_game())
	_check("round trip: letters and states unchanged", m.desk_mail.size() == 3 and _states() == [true, false, true], str(_states()))


func _desk() -> void:
	var names: Array = []
	for p in m.get_property_list():
		names.append(str(p["name"]))
	_check("desk light: no variable", not names.has("desk_light"))
	_check("desk light: no code", not m.has_method("_build_desk_light") and not m.desk.has_method("_update_desk_light"))
	# (The crows' red eyes on the roost are lights of their own, far from the house.)
	var desk_at: Vector2 = m._tile_center(m.INT_ORIGIN.x + m.DESK_IX.x, m.INT_ORIGIN.y + m.DESK_IX.y)
	var red := 0
	for c in m.get_children():
		if c is PointLight2D and (c as PointLight2D).color.r > 0.9 and (c as PointLight2D).color.g < 0.3 				and (c as PointLight2D).position.distance_to(desk_at) < m.PX * 3.0:
			red += 1
	_check("desk light: no red light at the desk", red == 0)
	_check("the desk keeps no letter code", not m.desk.has_method("_add_letter") and not m.desk.has_method("_unread_count"))
	m.diary_found = true
	m.inside = true
	m._close_panel()
	m.desk._read_desk()
	_check("the desk still opens the desk", m.open_tab == "Desk", m.open_tab)
	_check("the desk reads no letters", m.mail._unread_count() == 2)
	var titles := _titles(m.panels._desk_rows())
	_check("the desk panel lists no letters", not titles.has("Delivery") and not titles.has("Receipt") and not titles.has("Take out the read letters"))
	m._close_panel()
	# Standing at the desk and pressing the hand action reads nothing either.
	var desk_tile: Vector2i = m.INT_ORIGIN + m.DESK_IX + Vector2i.DOWN
	_stand(desk_tile, Vector2.UP)
	m._interact()
	_check("using the desk in the house opens the desk", m.open_tab == "Desk", m.open_tab)
	_check("using the desk in the house leaves the post unread", m.mail._unread_count() == 2)
	m._close_panel()
	m.inside = false


func _mailbox() -> void:
	var t: Vector2i = m.mail._tile()
	_check("the mailbox is at the east gate, west of the stand", t == _w(53, 32) and m._kind_at(t + Vector2i.RIGHT) == m.Tile.STALL)
	_check("the mailbox tile is the mailbox", m._kind_at(t) == m.Tile.MAILBOX)
	_check("the mailbox blocks", m.BLOCKING.has(m.Tile.MAILBOX))
	for d in [Vector2i.DOWN, Vector2i.LEFT]:
		var k: int = m._kind_at(t + d)
		_check("the mailbox can be faced from %s" % str(d), not m.BLOCKING.has(k), "kind %d" % k)
	# From the house: nothing happens.
	m.inside = true
	_stand(t + Vector2i.DOWN, Vector2.UP)
	m.mail._update(0.0)
	_check("no prompt in the house", not m.mail.prompt.visible)
	m.inside = false
	# Faced from the road below.
	_stand(t + Vector2i.DOWN, Vector2.UP)
	m.mail._update(0.0)
	_check("the prompt shows while the mailbox is faced", m.mail.prompt.visible and m.mail.prompt.text.contains("Check the mail"), m.mail.prompt.text)
	_stand(t + Vector2i.DOWN, Vector2.DOWN)
	m.mail._update(0.0)
	_check("no prompt when facing away", not m.mail.prompt.visible)
	_stand(t + Vector2i.DOWN, Vector2.UP)
	m._tool_press = true
	m._interact()
	m._tool_press = false
	_check("a tool press doesn't open the mailbox", m.open_tab == "" and m.mail._unread_count() == 2, m.open_tab)
	m._interact()
	_check("the mailbox opens the Mailbox panel", m.open_tab == "Mailbox", m.open_tab)
	_check("opening the mailbox reads every letter", m.mail._unread_count() == 0 and m.desk_mail.size() == 3)
	_check("the door opens", m.mail._lid_open())
	m.mail._update(0.0)
	_check("no prompt while the panel is open", not m.mail.prompt.visible)
	var titles := _titles(m.panels._mailbox_rows())
	_check("the Mailbox panel lists the letters", titles.has("Delivery") and titles.has("Receipt") and titles.has("From the town clerk"))
	m._close_panel()
	# From the path on its west side.
	_stand(t + Vector2i.LEFT, Vector2.RIGHT)
	m._interact()
	_check("the mailbox opens from the path to the west", m.open_tab == "Mailbox", m.open_tab)
	m.mail._add_letter("Unread one", "Kept when the read ones go.")
	m._on_panel_action("mail_clear")
	_check("clearing keeps only the unread letter", m.desk_mail.size() == 1 and str(m.desk_mail[0]["title"]) == "Unread one", str(m.desk_mail.size()))
	m._close_panel()
	m.mail._open_mailbox()
	m._close_panel()


func _flag() -> void:
	var box: Sprite2D = m.farm_scenery.mailbox if m.farm_scenery != null else null
	m.mail.lid_left = 0.0
	m.mail._update(1.0)
	_check("flag down once everything is read", not m.mail._flag_up() and m.mail.flag == 0.0)
	if box != null:
		m.farm_scenery._update_mailbox()
		_check("sprite: flag-down frame", box.frame == 0, str(box.frame))
	m.desk_orders = ["oil"]
	var note: String = m.desk._mail_day()
	_check("the morning post brings a delivery letter", m.mail._unread_count() == 1 and note.contains("catalog order"))
	m.mail._update(0.1)
	_check("the flag swings up over a moment, not at once", m.mail.flag > 0.0 and m.mail.flag < 1.0, str(m.mail.flag))
	m.mail._update(1.0)
	_check("flag up while a letter is unread", m.mail._flag_up() and m.mail.flag == 1.0)
	if box != null:
		m.farm_scenery._update_mailbox()
		_check("sprite: flag-up frame", box.frame == 2, str(box.frame))
	else:
		_check("the mailbox sprite exists", false, "no scenery mailbox")
	_stand(m.mail._tile() + Vector2i.DOWN, Vector2.UP)
	m._interact()
	if box != null:
		m.farm_scenery._update_mailbox()
		_check("sprite: the door is open while checking", box.frame == 3 or box.frame == 4, str(box.frame))
	m._close_panel()
	m.mail.lid_left = 0.0
	m.mail._update(1.0)
	_check("flag back down after reading", m.mail.flag == 0.0)
	# Saved and loaded with the flag up: still up.
	m.mail._add_letter("Saved unread", "x")
	m.saver._save_game()
	m.desk_mail = []
	m.saver._load_game()
	m.mail._update(1.0)
	_check("a saved unread letter raises the flag after loading", m.mail._flag_up() and m.mail.flag == 1.0)
