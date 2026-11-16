class_name TownSystem
extends RefCounted

# Wicker Cove, the fogbound fishing village down the hill road (CCH-WICKER-COVE-ALPHA-001). See DESIGN.md,
# "Wicker Cove (alpha)". Space at the farm's closed east gate (and again to confirm) walks you down; the road at
# the top of the village walks you home to the road inside the gate. Each way costs TownData.TRAVEL_HOURS of the
# day, with the needs that go with it; nothing is refilled or given.
#
# The village is an away place like the mine and the treks: while you are there `in_cave` is set as well, so the
# farm's layers, visitors and weather hide, and `active` tells the places that care that this is the village.
# Its map (TownLayout) and its people, shops and order (TownData) are data; TownArt draws it.
#
# Saved under `town` (see _to_save). A save is only made at home in bed, and one made away puts you at the
# homestead (SaveSystem._save_pos), so a save can never leave you in the village.
#
# Memory hooks for later (the Living Memory System is not built): `flags` records the day of the first arrival
# ("arrived"), first trade ("traded"), first delivery ("delivered"), and first word with each resident
# ("met_thomas", "met_edith"). Building repairs would add their own keys here. Nothing else reads them yet.

const FOG_TINT := Color("a8b3bb")        # the cool grey the village's light leans toward
const FOG_LEAN := 0.16                   # how far, by day
const NIGHT_FLOOR := Color(0.36, 0.39, 0.48)   # the village never goes darker than this: the fog holds the light
const INN_DAY := Color(0.96, 0.9, 0.82)
const INN_NIGHT := Color(0.62, 0.52, 0.46)
const WINDOW_COLOR := Color(1.0, 0.7, 0.38)
const CONFIRM_SECONDS := 4.0
# The farm's closed east gate, in inner farm tiles (FarmLayout: the X at column 59, rows 33-35).
const GATE_TILES := [Vector2i(59, 33), Vector2i(59, 34), Vector2i(59, 35)]
const TOP_MARGIN := 3                  # rows of forest the camera may show above the village
const HOME_IX := Vector2i(57, 35)        # where you come back: on the road inside the gate, clear of the walker spot

var m: MainGame
var art: TownArt
var active := false
var indoors := false
var front: Node2D
var fog: Node2D
var fog_rect: ColorRect
var lights: Array = []          # warm windows and lamp posts in the street
var hearth_light: PointLight2D
var confirm_until := 0.0
var gate_hint_day := -1
var late_said := -1

# Saved.
var visits := 0
var flags := {}                 # memory hooks: name -> the day it first happened
var talk_day := {}              # who -> the day they last spoke to you
var trade_day := {}             # shop -> the last day you bought or sold there
var stock_day := 0              # the day `bought` and `sold` count for
var bought := {}                # "shop:item" -> how many bought today
var sold := {}                  # shop -> how many things it has bought from you today
var orders_done := {}           # order id -> the day it was handed in


func _init(main: MainGame) -> void:
	m = main
	art = TownArt.new(self)
	art.build_terrain()


func _build() -> void:
	front = Node2D.new()
	front.z_index = 1
	front.visible = false
	front.draw.connect(_draw_front)
	m.add_child(front)
	fog = Node2D.new()
	fog.z_index = 3
	fog.visible = false
	m.add_child(fog)
	fog_rect = ColorRect.new()
	fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/town_fog.gdshader")
	fog_rect.material = mat
	fog.add_child(fog_rect)
	var windows := art.window_points()
	for p in windows + art.lamp_points():
		var light := PointLight2D.new()
		light.color = WINDOW_COLOR
		light.position = p
		light.enabled = false
		m.add_child(light)
		m._glow(light, 0.5 if windows.has(p) else 0.85)
		lights.append(light)
	hearth_light = PointLight2D.new()
	hearth_light.color = Color(1.0, 0.6, 0.28)
	hearth_light.position = art.hearth_point()
	hearth_light.enabled = false
	m.add_child(hearth_light)
	m._glow(hearth_light, 1.6)


# --- The map ---------------------------------------------------------------------------------------

func _in_room(t: Vector2i) -> bool:
	var o := TownLayout.INT_ORIGIN
	return t.x >= o.x and t.y >= o.y and t.x < o.x + TownLayout.IW and t.y < o.y + TownLayout.IH


func _char(t: Vector2i) -> String:
	if indoors:
		if not _in_room(t):
			return "W"
		var l := t - TownLayout.INT_ORIGIN
		return str(TownLayout.INTERIOR[l.y][l.x])
	if t.x < 0 or t.y < 0 or t.x >= TownLayout.W or t.y >= TownLayout.H:
		return "T"
	return str(TownLayout.TERRAIN[t.y][t.x])


# The tile kind MainGame's movement and doors read (blocking kinds are in MainGame.BLOCKING).
func _kind(t: Vector2i) -> int:
	var c := _char(t)
	if indoors:
		match c:
			".":
				return MainGame.Tile.FLOOR
			"X":
				return MainGame.Tile.EXIT
			"h":
				return MainGame.Tile.FIREPLACE
			"W":
				return MainGame.Tile.WALL
		return MainGame.Tile.TABLE
	match c:
		",", "m":
			return MainGame.Tile.GRASS
		"=", "q", "k", "E":
			return MainGame.Tile.PATH
		"D":
			return MainGame.Tile.DOOR
		"~", "b":
			return MainGame.Tile.WATER
		"T", "r":
			return MainGame.Tile.TREE
	return MainGame.Tile.HOUSE


var _mini: Array = []


# The street as Tile kinds, for the minimap (made once).
func minimap_tiles() -> Array:
	if _mini.is_empty():
		var was := indoors
		indoors = false
		for y in TownLayout.H:
			var row: Array = []
			for x in TownLayout.W:
				row.append(_kind(Vector2i(x, y)))
			_mini.append(row)
		indoors = was
	return _mini


# Settings' Unstick, in the village: back to where you came in (the inn's door mat, or the top of the road).
func _unstick() -> void:
	var at := TownLayout.INT_ORIGIN + TownLayout.INT_ENTRY if indoors else TownLayout.ARRIVE
	m.player.position = m._tile_center(at.x, at.y)
	m._set_bounds()
	m._show_message("You step back to where you came in.")


func _bounds() -> void:
	if indoors:
		var o := TownLayout.INT_ORIGIN
		m.player.min_pos = m._tile_center(o.x + 1, o.y + 3)
		m.player.max_pos = m._tile_center(o.x + TownLayout.IW - 2, o.y + TownLayout.IH - 1)
		var view := m.get_viewport_rect().size / m.camera.zoom
		var pad_x := maxf(0.0, (view.x - TownLayout.IW * m.PX) * 0.5)
		var pad_y := maxf(0.0, (view.y - TownLayout.IH * m.PX) * 0.5)
		m.camera.limit_left = int(o.x * m.PX - pad_x)
		m.camera.limit_right = int((o.x + TownLayout.IW) * m.PX + pad_x)
		m.camera.limit_top = int(o.y * m.PX - pad_y)
		m.camera.limit_bottom = int((o.y + TownLayout.IH) * m.PX + pad_y)
		return
	m.player.min_pos = m._tile_center(1, 0)
	m.player.max_pos = m._tile_center(TownLayout.W - 2, TownLayout.H - 2)
	m.camera.limit_left = 0
	# The camera looks a few rows past the top (more forest), so the road in and the sign clear the HUD's cards.
	m.camera.limit_top = -TOP_MARGIN * m.PX
	m.camera.limit_right = TownLayout.W * m.PX
	m.camera.limit_bottom = TownLayout.H * m.PX


# --- Getting there and back ------------------------------------------------------------------------

func open_today() -> bool:
	return m.day >= TownData.OPEN_FROM


# Space facing the closed east gate. Walkers waiting there are asked first (MainGame._interact tries them first).
func _try_gate(tile: Vector2i) -> bool:
	if active or m.inside or m.in_cave:
		return false
	var ix := tile - Vector2i(m.BORDER_X, m.BORDER_Y)
	if not GATE_TILES.has(ix):
		return false
	if not open_today():
		m._show_message("The east gate. The road beyond goes down the hill to Wicker Cove. Not today: there's the house to see to first.")
		return true
	if m.current_hour >= TownData.ROAD_CLOSES:
		m._show_message("The road down to Wicker Cove is steep and unlit. It can wait for morning.")
		return true
	var now := Time.get_ticks_msec() / 1000.0
	if now > confirm_until:
		confirm_until = now + CONFIRM_SECONDS
		m._show_message(m._fill_controls("The east gate, and the road down the hill to Wicker Cove: half an hour's walk each way. {hand} again to go."))
		return true
	confirm_until = 0.0
	go(true)
	return true


# Standing at the gate, facing it: a reminder of what it does, once a day.
func _update_gate_hint() -> void:
	if active or m.inside or m.in_cave or gate_hint_day == m.day or not open_today() or m.player == null:
		return
	var ix := m._player_tile() - Vector2i(m.BORDER_X, m.BORDER_Y)
	if ix.x == 58 and ix.y >= 33 and ix.y <= 35 and m.player.facing == Vector2.RIGHT:
		gate_hint_day = m.day
		m._show_message(m._fill_controls("The east gate. {hand} to take the road down to Wicker Cove."))


# Down to the village (with a short fade in a real window) or, from the village, home.
func go(to_town: bool) -> void:
	if m.transitioning:
		return
	if DisplayServer.get_name() == "headless" or m.fade_rect == null:
		if to_town:
			_arrive()
		else:
			_go_home()
		return
	m.transitioning = true
	m.player.paused = true
	m.card_label.add_theme_color_override("font_color", Color("e8dcc0"))
	await m._fade_to(Color(0.04, 0.05, 0.06, 1.0), 0.6, Tween.TRANS_SINE)
	if to_town:
		_arrive()
		await m._show_card("The road goes down through the firs, and the air turns to salt.", 0.3, 1.1, 0.3)
	else:
		_go_home()
		await m._show_card("Up the hill road, out of the fog, to the farm.", 0.3, 0.9, 0.3)
	await m._fade_to(Color(0.04, 0.05, 0.06, 0.0), 0.7, Tween.TRANS_SINE)
	m.player.paused = false
	m.transitioning = false


func _arrive() -> void:
	m.play_sfx("step", 0.03)
	m._close_panel()
	m.fishing._stop_fishing("")
	active = true
	indoors = false
	m.in_cave = true
	m.inside = false
	m.foes = []
	_pass_hours(TownData.TRAVEL_HOURS)
	visits += 1
	_restock()
	m.player.position = m._tile_center(TownLayout.ARRIVE.x, TownLayout.ARRIVE.y)
	m.player.facing = Vector2.DOWN
	m._set_bounds()
	_show(true)
	m.queue_redraw()
	if not flags.has("arrived"):
		flags["arrived"] = m.day
		m._show_message(TownData.ARRIVE_FIRST + " Wicker Cove: the store is on your right, the inn down the street, the harbour at the bottom. The road home is behind you.", true)
	else:
		m._show_message("Wicker Cove, in its fog. The road home is behind you, up the hill.")


func _go_home() -> void:
	m.play_sfx("step", 0.03)
	m._close_panel()
	if m.folk.dialogue != null:
		m.folk.dialogue.close()
	active = false
	indoors = false
	m.in_cave = false
	m.inside = false
	m.foes = []
	_pass_hours(TownData.TRAVEL_HOURS)
	var home := m._world_tile(HOME_IX.x, HOME_IX.y)
	m.player.position = m._tile_center(home.x, home.y)
	m.player.facing = Vector2.LEFT
	m._set_bounds()
	_show(false)
	m.queue_redraw()
	m._show_message("Back up the hill road, through the east gate, and home.")


# The day ends (bed, a collapse, a fall) while away: you wake at home, as from a trek. No hours pass here.
func _abort() -> void:
	if not active:
		return
	active = false
	indoors = false
	_show(false)


func _pass_hours(hours: float) -> void:
	m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
	m.current_hour += hours
	m._update_needs(hours)


func _show(on: bool) -> void:
	if front != null:
		front.visible = on
		fog.visible = on and not indoors
	for l in lights:
		l.enabled = on and not indoors
	if hearth_light != null:
		hearth_light.enabled = on and indoors


# Walking onto a tile: the road home, the inn's door, the way out of the inn.
func _on_step() -> void:
	var t := m._player_tile()
	var c := _char(t)
	if not indoors and c == "E":
		go(false)
	elif not indoors and c == "D":
		_enter_inn()
	elif indoors and c == "X":
		_leave_inn()


func _enter_inn() -> void:
	m.play_sfx("door", 0.05)
	indoors = true
	var at := TownLayout.INT_ORIGIN + TownLayout.INT_ENTRY
	m.player.position = m._tile_center(at.x, at.y)
	m.player.facing = Vector2.UP
	m._set_bounds()
	_show(true)
	m.queue_redraw()
	if not flags.has("met_edith"):
		m._show_message("Warm air, woodsmoke, and the smell of stock on the stove.")


func _leave_inn() -> void:
	m.play_sfx("door", 0.05)
	indoors = false
	m.player.position = m._tile_center(TownLayout.INN_OUT.x, TownLayout.INN_OUT.y)
	m.player.facing = Vector2.DOWN
	m._set_bounds()
	_show(true)
	m.queue_redraw()


# --- Each frame while there -------------------------------------------------------------------------

func _update(_delta: float) -> void:
	if not active:
		_update_gate_hint()
		return
	m.queue_redraw()
	front.queue_redraw()
	var dark := smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour)
	for l in lights:
		l.enabled = not indoors
		l.energy = lerpf(0.22, 1.05, dark)
	if hearth_light != null:
		hearth_light.enabled = indoors
		var t := Time.get_ticks_msec() / 1000.0
		hearth_light.energy = 0.75 + 0.05 * sin(t * 4.3) + 0.03 * sin(t * 1.9 + 1.0)
	if fog.visible:
		var view := m.get_viewport_rect().size / m.camera.zoom
		var top_left := m.camera.get_screen_center_position() - view * 0.5
		fog.position = top_left.floor()
		fog_rect.size = view.ceil() + Vector2(2, 2)
		var mat := fog_rect.material as ShaderMaterial
		mat.set_shader_parameter("view_origin", fog.position)
		mat.set_shader_parameter("player_world", m.player.position)
		mat.set_shader_parameter("sea_y", 22.0 * m.PX)
	if m.current_hour >= TownData.LATE_HOUR and late_said != m.day:
		late_said = m.day
		m._show_message("The light is going. It's a steep road home up the hill.")


# The village's light: the day's sky, leaned toward the fog's grey, and never black; indoors the fire's warmth.
func _tint(darkness: float) -> Color:
	if indoors:
		return INN_DAY.lerp(INN_NIGHT, darkness)
	var c := m._sky_tint(darkness).lerp(FOG_TINT, FOG_LEAN * (1.0 - darkness * 0.5))
	return Color(maxf(c.r, NIGHT_FLOOR.r), maxf(c.g, NIGHT_FLOOR.g), maxf(c.b, NIGHT_FLOOR.b))


func _view() -> Rect2i:
	var view := m.get_viewport_rect().size / m.camera.zoom
	var top_left := m.camera.get_screen_center_position() - view * 0.5
	var x0 := floori(top_left.x / m.PX) - 1
	var y0 := floori(top_left.y / m.PX) - 1
	return Rect2i(x0, y0, ceili(view.x / m.PX) + 3, ceili(view.y / m.PX) + 3)


func _feet() -> float:
	return m.player.position.y


# Drawn on the main canvas (behind the farmer).
func _draw_map() -> void:
	if indoors:
		art.draw_inn(m, false, _feet())
		return
	var r := _view()
	var clip := Rect2i(Vector2i(maxi(0, r.position.x), maxi(-TOP_MARGIN, r.position.y)), Vector2i.ZERO)
	clip.end = Vector2i(mini(TownLayout.W, r.end.x), mini(TownLayout.H, r.end.y))
	art.draw_ground(m, clip)
	art.draw_pier(m)
	art.draw_standing(m, r, false, _feet())
	art.draw_board(m)


func _draw_front() -> void:
	if not active:
		return
	if indoors:
		art.draw_inn(front, true, _feet())
		return
	art.draw_standing(front, _view(), true, _feet())


# --- Using things -------------------------------------------------------------------------------------

func _interact(tile: Vector2i) -> void:
	var c := _char(tile)
	if indoors:
		match c:
			"C", "e":
				_talk("edith")
			"h":
				m._show_message(str(TownData.LOOK["hearth"]))
			"t", "a":
				m._show_message(str(TownData.LOOK["table"]))
			"p":
				m._show_message(str(TownData.LOOK["p"]))
		return
	match c:
		"c":
			_talk("thomas")
			return
		"N":
			_open("Notice board")
			return
		"F":
			if trade_day.get("market_seen", -1) != m.day:
				trade_day["market_seen"] = m.day
				m._show_message(TownData.MARKET_SLATE)
			_open("Fish market")
			return
		"k":
			if tile.y >= TownLayout.H - 2 or _char(tile + Vector2i(0, 1)) != "k":
				m._show_message(str(TownData.LOOK["pier"]))
			return
		"H":
			var id := _building_at(tile)
			if id == "store":
				_talk("thomas")
			elif id == "market":
				_open("Fish market")
			elif id != "":
				m._show_message(str(TownData.LOOK.get(id, "")))
			return
	if TownData.LOOK.has(c) and str(TownData.LOOK[c]) != "":
		m._show_message(str(TownData.LOOK[c]))


func _building_at(t: Vector2i) -> String:
	for id in TownLayout.BUILDINGS:
		if (TownLayout.BUILDINGS[id] as Rect2i).has_point(t):
			return id
	return ""


# A resident: the first time, a short scene, then their counter; after that, straight to it with the day's word.
func _talk(who: String) -> void:
	var tab := "Store" if who == "thomas" else "The inn"
	if not flags.has("met_" + who):
		flags["met_" + who] = m.day
		talk_day[who] = m.day
		if m.folk.dialogue != null and DisplayServer.get_name() != "headless":
			m.folk.dialogue.play(TownData.MEET[who], func() -> void: _open(tab), "Space: next")
		else:
			_open(tab)
		return
	talk_day[who] = m.day
	_open(tab)


func _open(tab: String) -> void:
	if m.open_tab != tab:
		m._toggle_tab(tab)
	else:
		m._refresh_panel()


# The day's word from who: late, after an order, a callback once you've traded, the season, or the day's line.
func _line(who: String) -> String:
	if m.current_hour >= TownData.LATE_HOUR:
		return str(TownData.LATE_LINES[who])
	var shop := "store" if who == "thomas" else "inn"
	if who == "thomas" and orders_done.has("thomas_turnips") and int(orders_done["thomas_turnips"]) >= m.day - 1:
		return TownData.ORDER_DONE_LINE
	if trade_day.has(shop) and int(trade_day[shop]) < m.day and int(trade_day[shop]) >= m.day - 7 and (m.day % 3) == 0:
		return str(TownData.CALLBACK_LINES[who])
	var season := m._season_today()
	if (m.day % 4) == 1 and TownData.SEASON_LINES[who].has(season):
		return str(TownData.SEASON_LINES[who][season])
	var lines: Array = TownData.LINES[who]
	return str(lines[m.day % lines.size()])


# --- Shops ------------------------------------------------------------------------------------------

const TABS := ["Store", "Fish market", "The inn", "Notice board"]


func _shop_for_tab(tab: String) -> String:
	for id in TownData.SHOPS:
		if str(TownData.SHOPS[id]["tab"]) == tab:
			return id
	return ""


func _restock() -> void:
	if stock_day != m.day:
		stock_day = m.day
		bought = {}
		sold = {}


func _item(shop: String, item: String) -> Dictionary:
	for s in TownData.SHOPS[shop]["sells"]:
		if str(s["item"]) == item:
			return s
	return {}


func _stock_left(shop: String, s: Dictionary) -> int:
	_restock()
	return maxi(0, int(s["stock"]) - int(bought.get(shop + ":" + str(s["item"]), 0)))


func _held_item(s: Dictionary) -> int:
	return int(m.materials.get(str(s["item"]), 0)) if bool(s.get("mat", false)) else int(m.inventory.get(str(s["item"]), 0))


# How many of s you could buy now: stock, coins, and room in the pack for things that go in it.
func _can_buy(shop: String, s: Dictionary) -> int:
	var n := mini(_stock_left(shop, s), m.money / maxi(1, int(s["price"])))
	if not bool(s.get("mat", false)) and str(s["item"]) != "seeds":
		while n > 0 and not m.stall._pack_room(_held_item(s), n):
			n -= 1
	return maxi(0, n)


func _buys_food(shop: String, f: Dictionary) -> bool:
	return (TownData.SHOPS[shop]["buys"] as Array).has(str(f["kind"])) and m.stall._food_price(str(f["id"])) > 0


func _sell_left(shop: String) -> int:
	_restock()
	return maxi(0, int(TownData.SHOPS[shop]["buys_max"]) - int(sold.get(shop, 0)))


func order_open() -> bool:
	for o in TownData.ORDERS:
		if not orders_done.has(str(o["id"])):
			return true
	return false


# "6 turnips": what an order wants, in words.
func _want_text(o: Dictionary) -> String:
	var parts: Array = []
	for key in o["want"]:
		var n := int(o["want"][key])
		var label: String = m.folk._label(str(key))
		parts.append("%d %s%s" % [n, label, "s" if n > 1 and not label.ends_with("s") else ""])
	return ", ".join(parts)


func _order(id: String) -> Dictionary:
	for o in TownData.ORDERS:
		if str(o["id"]) == id:
			return o
	return {}


# Panel rows for one of the village's tabs (MainGame._refresh_panel).
func _rows(tab: String) -> Array:
	var rows: Array = [{"tab": tab}]
	if tab == "Notice board":
		rows.append({"section": "Pinned to the board"})
		for o in TownData.ORDERS:
			var done := orders_done.has(str(o["id"]))
			rows.append({"name": str(o["title"]), "status": "Done" if done else "Open", "status_kind": "done" if done else "ok",
				"value": "Handed in" if done else "Wants %s" % _want_text(o), "about": str(o["board"])})
		rows.append({"note": "Hand an order in at Thomas's counter, all at once. Older notices have been taken down; the pins are still there."})
		return rows
	var shop := _shop_for_tab(tab)
	var spec: Dictionary = TownData.SHOPS[shop]
	var who := str(spec["who"])
	# The resident's word is the first entry, so it is what the detail page shows when the counter opens (a
	# ledger's plain notes sit below its entries, out of sight).
	if who != "":
		rows.append({"section": str(TownData.PEOPLE[who]["where"]).capitalize()})
		rows.append({"name": str(TownData.PEOPLE[who]["name"]), "about": _line(who)})
	else:
		rows.append({"section": "Nobody at the stall"})
		rows.append({"name": "The slate", "about": TownData.MARKET_SLATE})
	if shop == "store":
		for o in TownData.ORDERS:
			if orders_done.has(str(o["id"])):
				continue
			var ok := m.folk._has_wants(o)
			rows.append({"section": "The order on the board"})
			rows.append({"name": str(o["title"]), "value": "Wants %s, all at once" % _want_text(o),
				"about": str(o["board"]), "status": "Ready" if ok else "Not yet", "status_kind": "ok" if ok else "short",
				"needs": [{"text": _want_text(o), "ok": ok}],
				"button": "Hand in", "action": "town:deliver|" + str(o["id"]), "enabled": ok})
	rows.append({"section": "Buy"})
	for s in spec["sells"]:
		var left := _stock_left(shop, s)
		var can := _can_buy(shop, s)
		var price := int(s["price"])
		var why := ""
		if left <= 0:
			why = "Sold out today; more tomorrow."
		elif m.money < price:
			why = "You need %d coins." % price
		elif can <= 0:
			why = "No room in your pack."
		var row := {"name": "%s (%d coins)" % [str(s["name"]), price], "value": "%d left today, %d held" % [left, _held_item(s)],
			"about": str(s["about"]) + ("" if why == "" else " " + why),
			"status": "%d coins" % price, "status_kind": "ok" if can > 0 else "short",
			"needs": [{"text": "%d coins" % price, "have": m.money, "ok": m.money >= price}],
			"button": "Buy", "action": "town:buy|%s|%s" % [shop, str(s["item"])], "enabled": can > 0}
		if can > 0:
			var values: Array = []
			for n in range(1, can + 1):
				values.append(n * price)
			row["amount_max"] = can
			row["amount_id"] = "town_buy:%s:%s" % [shop, str(s["item"])]
			row["amount_values"] = values
			row["amount_unit"] = "coins"
		rows.append(row)
	if int(spec["buys_max"]) > 0:
		var left := _sell_left(shop)
		rows.append({"section": "Sell %s (takes %d more today)" % [str(spec["buys_name"]), left]})
		var any := false
		for f in Foods.LIST:
			if not _buys_food(shop, f):
				continue
			var held := int(m.inventory.get(str(f["held"]), 0))
			if held <= 0:
				continue
			any = true
			var price: int = m.stall._food_price(str(f["id"]))
			var n := mini(held, left)
			var row := {"name": "%s (%d each)" % [str(f["name"]), price], "value": "%d held" % held,
				"about": "Paid at the farm stand's full price. This counter takes %d more today." % left,
				"button": "Sell", "action": "town:sell|%s|%s" % [shop, str(f["id"])], "enabled": n > 0}
			if n > 0:
				var values: Array = []
				for k in range(1, n + 1):
					values.append(k * price)
				row["amount_max"] = n
				row["amount_id"] = "town_sell:%s:%s" % [shop, str(f["id"])]
				row["amount_values"] = values
				row["amount_unit"] = "coins"
			rows.append(row)
		if not any:
			rows.append({"name": "Nothing to sell", "value": "Bring %s in your pack." % str(spec["buys_name"])})
	rows.append({"section": "Purse"})
	rows.append({"name": "Coins", "value": str(m.money)})
	return rows


# A panel button: "buy|shop|item", "sell|shop|food_id" or "deliver|order_id", with ":N" for an amount.
func _action(action: String) -> void:
	var amount := -1
	if action.get_slice_count(":") > 1:
		amount = int(action.get_slice(":", 1))
		action = action.get_slice(":", 0)
	var parts := action.split("|")
	match parts[0]:
		"buy":
			if parts.size() == 3:
				buy(parts[1], parts[2], maxi(1, amount))
		"sell":
			if parts.size() == 3:
				sell(parts[1], parts[2], amount)
		"deliver":
			if parts.size() == 2:
				deliver(parts[1])


# Buys n of item at shop. Every limit is checked again here, so no button state can make it go wrong.
# Returns how many were bought.
func buy(shop: String, item: String, n: int) -> int:
	if not TownData.SHOPS.has(shop):
		return 0
	var s := _item(shop, item)
	if s.is_empty() or n <= 0:
		return 0
	var price := int(s["price"])
	if m.money < price:
		m._show_message("That's %d coins, and you have %d." % [price, m.money])
		return 0
	if _stock_left(shop, s) <= 0:
		m._show_message("None left today. More tomorrow.")
		return 0
	var can := mini(n, _can_buy(shop, s))
	if can <= 0:
		m._show_message("No room in your pack for that.")
		return 0
	m.money -= can * price
	if bool(s.get("mat", false)):
		m.materials[item] = int(m.materials.get(item, 0)) + can
	else:
		m.inventory[item] = int(m.inventory.get(item, 0)) + can
	bought[shop + ":" + item] = int(bought.get(shop + ":" + item, 0)) + can
	_traded(shop)
	m.play_sfx("coin")
	m._show_message("Bought %d %s for %d coins." % [can, str(s["name"]).to_lower(), can * price])
	return can


# Sells n (or as many as it takes, -1) of a food at shop, at the stand's full price. Returns the coins paid.
func sell(shop: String, food_id: String, n: int) -> int:
	if not TownData.SHOPS.has(shop):
		return 0
	var f := Foods.find(food_id)
	if f.is_empty() or not _buys_food(shop, f):
		return 0
	var key := str(f["held"])
	var held := int(m.inventory.get(key, 0))
	var left := _sell_left(shop)
	var count := mini(held, left) if n < 0 else mini(n, mini(held, left))
	if count <= 0:
		m._show_message("Nothing to sell." if held <= 0 else "They've taken all they can use today.")
		return 0
	var coins: int = count * m.stall._food_price(food_id)
	m.inventory[key] = held - count
	m.money += coins
	m.stats["sold"] = int(m.stats.get("sold", 0)) + count
	sold[shop] = int(sold.get(shop, 0)) + count
	_traded(shop)
	m.play_sfx("coin")
	m._show_message("Sold %d %s for %d coins." % [count, str(f["name"]).to_lower(), coins])
	return coins


func _traded(shop: String) -> void:
	trade_day[shop] = m.day
	if not flags.has("traded"):
		flags["traded"] = m.day


# Hands in an order, all at once. Only once: a done order stays done.
func deliver(id: String) -> bool:
	var o := _order(id)
	if o.is_empty() or orders_done.has(id):
		return false
	if not m.folk._has_wants(o):
		m._show_message("Not yet: it wants %s, all at once." % _want_text(o))
		return false
	for key in o["want"]:
		m.folk._take(str(key), int(o["want"][key]))
	orders_done[id] = m.day
	var got: String = m.folk._give_reward(o["reward"])
	if not flags.has("delivered"):
		flags["delivered"] = m.day
	m.play_sfx("coin", 0.03)
	m._show_message("%s %s" % [str(o["thanks"]), got], true)
	return true


# --- Saving -----------------------------------------------------------------------------------------

func _to_save() -> Dictionary:
	return {"visits": visits, "flags": flags, "talk_day": talk_day, "trade_day": trade_day, "stock_day": stock_day,
		"bought": bought, "sold": sold, "orders_done": orders_done}


# An older save has no village: everything starts fresh, and nobody has met you.
func _from_save(d: Variant) -> void:
	active = false
	indoors = false
	visits = 0
	flags = {}
	talk_day = {}
	trade_day = {}
	stock_day = 0
	bought = {}
	sold = {}
	orders_done = {}
	if typeof(d) != TYPE_DICTIONARY:
		return
	visits = maxi(0, int(d.get("visits", 0)))
	stock_day = int(d.get("stock_day", 0))
	for key in ["flags", "talk_day", "trade_day", "bought", "sold", "orders_done"]:
		var src: Variant = d.get(key, {})
		if typeof(src) == TYPE_DICTIONARY:
			var dst: Dictionary = get(key)
			for k in src:
				dst[str(k)] = maxi(0, int(src[k]))
