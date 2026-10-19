extends Node2D

## The farm: planting, bushcrafting, the farmhouse, skills (Farming,
## Bushcrafting, Carpentry, Cleaning), inventory, gear, settings, minimap,
## the RuneScape-style action bar, the day/night clock, and a first night event.
## Placeholder art is drawn in code; no external assets yet.

const TILE_SIZE := 16
const SCALE := 3
const PX := TILE_SIZE * SCALE  # one tile in world units

# The farm is INNER_W x INNER_H tiles of walkable land, surrounded by trees.
const INNER_W := 40
const INNER_H := 24
const BORDER_X := 14
const BORDER_Y := 8
const MAP_W := INNER_W + BORDER_X * 2
const MAP_H := INNER_H + BORDER_Y * 2

# Farmhouse footprint in inner coordinates. It starts at its full final size
# in a decrepit state; repairs change its condition and unlock features.
const HOUSE_IX := 26
const HOUSE_IY := 3
const HOUSE_W := 6
const HOUSE_H := 5

# Brush piles for bushcrafting, in inner coordinates. They respawn each morning.
const BRUSH_SPOTS := [
	Vector2i(16, 3), Vector2i(22, 15), Vector2i(30, 14),
	Vector2i(8, 16), Vector2i(35, 6), Vector2i(18, 20),
]

const DAY_LENGTH := 240.0   # real seconds for the 06:00 -> 24:00 stretch
const START_HOUR := 6.0
const DUSK_HOUR := 19.0
const SLEEP_HOUR := 18.0
const EVENT_HOUR := 22.0

const MAX_STAGE := 3        # 0 = seed, 3 = ready to harvest
const STAGE_NAMES := ["Decrepit", "Boarded", "Patched", "Restored"]
# Cost to reach the next house stage, and the Carpentry level it needs.
const REPAIR_COSTS := [
	{"wood": 3, "fiber": 2, "level": 1},
	{"wood": 5, "fiber": 4, "level": 2},
	{"wood": 8, "fiber": 6, "level": 3},
]
const HOUSE_FEATURES := [
	{"stage": 1, "text": "Sleep in bed to end the day early"},
	{"stage": 2, "text": "Tidy the house for Cleaning XP"},
	{"stage": 3, "text": "A restored house softens the night"},
]
const HOUSE_WALLS := [Color("4a3a2e"), Color("6b5340"), Color("8a6a4c"), Color("b08a5e")]
const HOUSE_ROOFS := [Color("2d2620"), Color("4a3a2c"), Color("6b4b33"), Color("8c5a3c")]

const LANTERN_COST := {"wood": 2, "fiber": 2, "level": 2}  # level = Bushcrafting
const LANTERN_RADIUS_TILES := 2.5   # light ring around the player
const HOUSE_RELIEF := 0.2

const SKILLS := ["Farming", "Bushcrafting", "Carpentry", "Cleaning"]
const XP_PLANT := 5
const XP_HARVEST := 25
const XP_GATHER := 10
const XP_REPAIR := 30
const XP_TIDY := 20

const STARTING_SEEDS := 5
const MESSAGE_SECONDS := 3.0

enum Tile { TREE, GRASS, SOIL, PATH, WATER, HOUSE }

const TILE_COLORS := {
	Tile.TREE: Color("2f4f2f"),
	Tile.GRASS: Color("6a9f4b"),
	Tile.SOIL: Color("7a5234"),
	Tile.PATH: Color("c9a66b"),
	Tile.WATER: Color("3f6fa8"),
	Tile.HOUSE: Color("6b5340"),
}

const CROP_COLORS := [
	Color("8fd16b"),  # seed
	Color("4f9a3a"),  # sprout
	Color("2f7a2a"),  # growing
	Color("e8b440"),  # ready
]
const BUSH_COLOR := Color("3d6b2a")

const DAY_TINT := Color(1, 1, 1)
const NIGHT_TINT := Color("3a3f6e")

var map: Array = []
var crops := {}                    # Vector2i world tile -> growth stage
var brush := {}                    # Vector2i world tile -> true while unharvested
var clock := 0.0
var current_hour := START_HOUR
var day := 1
var skill_xp := {"Farming": 0, "Bushcrafting": 0, "Carpentry": 0, "Cleaning": 0}
var inventory := {"seeds": STARTING_SEEDS, "crops": 0}
var materials := {"wood": 0, "fiber": 0}
var has_lantern := false
var house_stage := 0
var tidied_day := 0
var open_tab := ""                 # "" when the action bar panel is closed
var event_fired_day := 0           # the day the night event last happened
var shadow_tile := Vector2i.ZERO
var message_timer := 0.0

var action_bar: ActionBar
var minimap: Minimap
var canvas_modulate: CanvasModulate
var hud_label: Label
var message_label: Label
var player    # Node2D with player.gd attached
var lantern_light: PointLight2D


func _ready() -> void:
	_setup_input()
	_build_map()
	_respawn_brush()
	_build_world()
	_build_hud()
	_build_action_bar()
	_update_shadow_tile()


func _process(delta: float) -> void:
	clock += delta
	current_hour = START_HOUR + clock / DAY_LENGTH * 18.0

	if current_hour >= 24.0:
		_end_day("Morning. Your crops grew overnight.")
		return

	if current_hour >= EVENT_HOUR and event_fired_day != day:
		event_fired_day = day
		_show_message("Something stands at the edge of the field.")
		queue_redraw()

	var darkness := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, current_hour)
	darkness *= 1.0 - _night_relief()
	canvas_modulate.color = DAY_TINT.lerp(NIGHT_TINT, darkness)
	# The lantern lights a small ring around the player, only when it's dark.
	lantern_light.enabled = has_lantern and darkness > 0.05

	hud_label.text = "Day %d   %02d:%02d" % [day, int(current_hour), int(fmod(current_hour, 1.0) * 60.0)]

	_handle_keys()

	# Farming and gathering pause while a panel is open.
	if Input.is_action_just_pressed("use") and open_tab == "":
		_interact()

	if open_tab != "":
		_refresh_panel()

	_update_minimap()

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""


func _draw() -> void:
	for y in MAP_H:
		for x in MAP_W:
			var tile: int = map[y][x]
			draw_rect(_tile_rect(Vector2i(x, y)), TILE_COLORS[tile])

	for pos in crops:
		var stage: int = crops[pos]
		var center := _tile_center(pos.x, pos.y)
		var size := PX * (0.2 + 0.2 * stage)
		draw_rect(Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), CROP_COLORS[stage])

	for pos in brush:
		var center := _tile_center(pos.x, pos.y)
		draw_circle(center, PX * 0.32, BUSH_COLOR)
		draw_circle(center + Vector2(-4, -4), PX * 0.1, Color("5d8f3e"))

	_draw_house()

	if event_fired_day == day:
		var s := _tile_center(shadow_tile.x, shadow_tile.y)
		draw_circle(s, PX * 0.6, Color(0.02, 0.01, 0.05, 0.9))
		draw_circle(s + Vector2(-8, -6), 3, Color(0.9, 0.1, 0.1))
		draw_circle(s + Vector2(8, -6), 3, Color(0.9, 0.1, 0.1))


func _draw_house() -> void:
	var origin := _world_tile(HOUSE_IX, HOUSE_IY)
	var rect := Rect2(Vector2(origin) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	var stage := house_stage

	draw_rect(rect, HOUSE_WALLS[stage])
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, PX * 1.4)), HOUSE_ROOFS[stage])

	# Door in the middle of the bottom wall.
	var door_pos := rect.position + Vector2(rect.size.x * 0.5 - PX * 0.5, rect.size.y - PX * 1.3)
	draw_rect(Rect2(door_pos, Vector2(PX, PX * 1.3)), Color("24180f"))

	# Windows on either side of the door. Boarded until the house is patched.
	for wx in [0.15, 0.7]:
		var win := Rect2(rect.position + Vector2(rect.size.x * wx, PX * 2.0), Vector2(PX * 1.2, PX * 1.2))
		draw_rect(win, Color("9bb7c4") if stage >= 2 else Color("1d1712"))
		if stage < 2:
			draw_rect(Rect2(win.position + Vector2(0, win.size.y * 0.4), Vector2(win.size.x, 4)), Color("3a2a1c"))
			draw_rect(Rect2(win.position + Vector2(0, win.size.y * 0.7), Vector2(win.size.x, 4)), Color("3a2a1c"))

	# A missing roof patch shows the house is decrepit.
	if stage == 0:
		draw_rect(Rect2(rect.end.x - PX * 2.2, rect.position.y + 6, PX * 1.4, PX * 0.9), Color("0d0a08"))


func _setup_input() -> void:
	_ensure_action("move_up", [KEY_W, KEY_UP])
	_ensure_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("use", [KEY_SPACE, KEY_ENTER])
	_ensure_action("skills", [KEY_K])
	_ensure_action("inventory", [KEY_I])
	_ensure_action("gear", [KEY_G])
	_ensure_action("house", [KEY_H])


func _ensure_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func _build_map() -> void:
	map = []
	for y in MAP_H:
		var row: Array = []
		for x in MAP_W:
			var ix := x - BORDER_X
			var iy := y - BORDER_Y
			var t := Tile.TREE
			if ix >= 0 and ix < INNER_W and iy >= 0 and iy < INNER_H:
				t = Tile.GRASS
				if iy == INNER_H / 2 or ix == INNER_W / 2:
					t = Tile.PATH
				if ix >= 4 and ix < 12 and iy >= 4 and iy < 10:
					t = Tile.SOIL
				if ix >= INNER_W - 6 and iy >= INNER_H - 6:
					t = Tile.WATER
				if ix >= HOUSE_IX and ix < HOUSE_IX + HOUSE_W and iy >= HOUSE_IY and iy < HOUSE_IY + HOUSE_H:
					t = Tile.HOUSE
			row.append(t)
		map.append(row)


func _respawn_brush() -> void:
	brush.clear()
	for spot in BRUSH_SPOTS:
		brush[_world_tile(spot.x, spot.y)] = true
	queue_redraw()


func _build_world() -> void:
	# Tiles and the house are drawn by this node's _draw(). The player and
	# camera are created here so they draw above the map.
	player = Node2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.position = _tile_center(BORDER_X + INNER_W / 2, BORDER_Y + INNER_H / 2)
	player.min_pos = _tile_center(BORDER_X, BORDER_Y)
	player.max_pos = _tile_center(BORDER_X + INNER_W - 1, BORDER_Y + INNER_H - 1)
	player.is_blocked = _is_blocked_world
	add_child(player)
	_build_lantern_light()

	var camera := Camera2D.new()
	camera.enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_W * PX
	camera.limit_bottom = MAP_H * PX
	player.add_child(camera)

	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)


func _build_lantern_light() -> void:
	# A soft white-to-black radial gradient, tinted warm and scaled to the ring radius.
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color.BLACK)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256

	lantern_light = PointLight2D.new()
	lantern_light.texture = texture
	lantern_light.texture_scale = LANTERN_RADIUS_TILES * PX / 128.0
	lantern_light.color = Color("ffd38a")
	lantern_light.energy = 1.0
	lantern_light.enabled = false
	player.add_child(lantern_light)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_label = _make_label(layer, Vector2(16, 12), 24)
	message_label = _make_label(layer, Vector2(16, 100), 20)

	minimap = Minimap.new()
	var mini_size := Vector2(MAP_W, MAP_H) * Minimap.PX_PER_TILE
	minimap.custom_minimum_size = mini_size
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_left = -(mini_size.x + 12.0)
	minimap.offset_right = -12.0
	minimap.offset_top = 12.0
	minimap.offset_bottom = 12.0 + mini_size.y
	layer.add_child(minimap)


func _build_action_bar() -> void:
	action_bar = ActionBar.new()
	add_child(action_bar)
	action_bar.tab_pressed.connect(_toggle_tab)
	action_bar.action_pressed.connect(_on_panel_action)


func _make_label(parent: Node, pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _update_minimap() -> void:
	var shadow := shadow_tile if event_fired_day == day else Vector2i(-1, -1)
	minimap.update_view(map, TILE_COLORS, brush.keys(), player.position / PX, shadow)


# --- Input and panels --------------------------------------------------------

func _handle_keys() -> void:
	if Input.is_action_just_pressed("skills"):
		_toggle_tab("Skills")
	if Input.is_action_just_pressed("inventory"):
		_toggle_tab("Inventory")
	if Input.is_action_just_pressed("gear"):
		_toggle_tab("Gear")
	if Input.is_action_just_pressed("house"):
		_toggle_tab("House")
	# Esc opens Settings, or closes it if it's already open.
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_tab("Settings")


func _toggle_tab(tab: String) -> void:
	if open_tab == tab:
		_close_panel()
	else:
		open_tab = tab
		_refresh_panel()


func _close_panel() -> void:
	open_tab = ""
	action_bar.hide_panel()


func _on_panel_action(action_id: String) -> void:
	match action_id:
		"close":
			_close_panel()
		"repair":
			_repair_house()
		"sleep":
			_sleep()
		"tidy":
			_tidy_house()
		"craft_lantern":
			_craft_lantern()


func _refresh_panel() -> void:
	var rows: Array = []
	match open_tab:
		"Skills":
			rows = _skill_rows()
		"Inventory":
			rows = _inventory_rows()
		"Gear":
			rows = _gear_rows()
		"House":
			rows = _house_rows()
		"Settings":
			rows = _settings_rows()
	action_bar.show_panel(open_tab, rows)


func _skill_rows() -> Array:
	var rows: Array = []
	for skill in SKILLS:
		rows.append({
			"name": "%s   Lv %d" % [skill, _level(skill)],
			"value": "%d XP" % skill_xp[skill],
			"progress": float(skill_xp[skill] % 100) / 100.0,
		})
	rows.append({"note": "Bushcrafting gathers wood and fiber from brush piles. Carpentry repairs the house. Cleaning tidies it."})
	return rows


func _inventory_rows() -> Array:
	return [
		{"section": "Seeds and crops"},
		{"name": "Seeds", "value": str(inventory["seeds"])},
		{"name": "Harvested crops", "value": str(inventory["crops"])},
		{"section": "Materials"},
		{"name": "Wood", "value": str(materials["wood"])},
		{"name": "Fiber", "value": str(materials["fiber"])},
	]


func _gear_rows() -> Array:
	var rows: Array = [
		{"section": "Tools"},
		{"name": "Hoe", "value": "equipped"},
	]
	if has_lantern:
		rows.append({"name": "Lantern", "value": "owned"})
	else:
		rows.append({
			"name": "Lantern",
			"value": _cost_text(LANTERN_COST),
			"button": "Craft",
			"action": "craft_lantern",
			"enabled": _can_craft_lantern(),
		})
	rows.append({"note": "A lantern softens the night. Bushcrafting teaches you how to build one."})
	return rows


func _house_rows() -> Array:
	var rows: Array = [
		{"section": "Condition"},
		{"name": "Farmhouse", "value": STAGE_NAMES[house_stage]},
	]
	if house_stage < MAX_STAGE:
		var cost: Dictionary = REPAIR_COSTS[house_stage]
		rows.append({
			"name": "Repair to %s" % STAGE_NAMES[house_stage + 1],
			"value": "%d wood, %d fiber, Carpentry %d" % [cost["wood"], cost["fiber"], cost["level"]],
			"button": "Repair",
			"action": "repair",
			"enabled": _can_repair(),
		})
	rows.append({"section": "Actions"})
	rows.append({
		"name": "Sleep",
		"value": "from %02d:00" % int(SLEEP_HOUR),
		"button": "Sleep",
		"action": "sleep",
		"enabled": _can_sleep(),
	})
	rows.append({
		"name": "Tidy",
		"value": "once a day",
		"button": "Tidy",
		"action": "tidy",
		"enabled": _can_tidy(),
	})
	rows.append({"section": "Features"})
	for feature in HOUSE_FEATURES:
		var unlocked: bool = house_stage >= feature["stage"]
		rows.append({
			"name": feature["text"],
			"value": "unlocked" if unlocked else "at %s" % STAGE_NAMES[feature["stage"]],
		})
	return rows


func _settings_rows() -> Array:
	return [
		{"section": "Controls"},
		{"name": "Move", "value": "WASD or arrow keys"},
		{"name": "Use, plant, harvest, gather", "value": "Space or Enter"},
		{"name": "Skills", "value": "K"},
		{"name": "Inventory", "value": "I"},
		{"name": "Gear", "value": "G"},
		{"name": "House", "value": "H"},
		{"name": "Settings", "value": "Esc"},
		{"note": "Sound and display options are coming later."},
	]


# --- Farming, gathering, and the house ---------------------------------------

func _interact() -> void:
	var tile := _tile_in_front()
	if not _in_bounds(tile):
		return

	if brush.has(tile):
		_gather(tile)
		return

	var kind: int = map[tile.y][tile.x]
	if kind == Tile.HOUSE:
		_toggle_tab("House")
		return
	if kind != Tile.SOIL:
		return

	if crops.has(tile):
		if crops[tile] >= MAX_STAGE:
			crops.erase(tile)
			inventory["crops"] += 1
			inventory["seeds"] += 1
			_grant_xp("Farming", XP_HARVEST)
			_show_message("Harvested a crop and kept a seed. +%d Farming XP" % XP_HARVEST)
		else:
			_show_message("It isn't ready yet.")
	elif inventory["seeds"] > 0:
		inventory["seeds"] -= 1
		crops[tile] = 0
		_grant_xp("Farming", XP_PLANT)
		_show_message("Planted a seed. +%d Farming XP" % XP_PLANT)
	else:
		_show_message("You have no seeds. Harvest a crop to get more.")

	queue_redraw()


func _gather(tile: Vector2i) -> void:
	brush.erase(tile)
	materials["wood"] += 1
	materials["fiber"] += 1
	_grant_xp("Bushcrafting", XP_GATHER)
	_show_message("Gathered wood and fiber from the brush. +%d Bushcrafting XP" % XP_GATHER)
	queue_redraw()


func _can_repair() -> bool:
	if house_stage >= MAX_STAGE:
		return false
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	return materials["wood"] >= cost["wood"] \
		and materials["fiber"] >= cost["fiber"] \
		and _level("Carpentry") >= cost["level"]


func _repair_house() -> void:
	if not _can_repair():
		_show_message("Not enough wood and fiber, or Carpentry is too low for this repair.")
		return
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	materials["wood"] -= cost["wood"]
	materials["fiber"] -= cost["fiber"]
	house_stage += 1
	_grant_xp("Carpentry", XP_REPAIR)
	_show_message("Repaired. The farmhouse is now %s. +%d Carpentry XP" % [STAGE_NAMES[house_stage], XP_REPAIR])
	queue_redraw()


func _can_sleep() -> bool:
	return house_stage >= 1 and current_hour >= SLEEP_HOUR


func _sleep() -> void:
	if not _can_sleep():
		_show_message("You can sleep once the house is boarded and it's evening.")
		return
	_end_day("You sleep through the night. Your crops grew overnight.")


func _can_tidy() -> bool:
	return house_stage >= 2 and tidied_day != day


func _tidy_house() -> void:
	if not _can_tidy():
		_show_message("The house is already tidy for today.")
		return
	tidied_day = day
	_grant_xp("Cleaning", XP_TIDY)
	_show_message("You tidy the house. The air feels a little lighter. +%d Cleaning XP" % XP_TIDY)


func _can_craft_lantern() -> bool:
	return not has_lantern \
		and materials["wood"] >= LANTERN_COST["wood"] \
		and materials["fiber"] >= LANTERN_COST["fiber"] \
		and _level("Bushcrafting") >= LANTERN_COST["level"]


func _craft_lantern() -> void:
	if not _can_craft_lantern():
		_show_message("You need %s to craft a lantern." % _cost_text(LANTERN_COST))
		return
	materials["wood"] -= LANTERN_COST["wood"]
	materials["fiber"] -= LANTERN_COST["fiber"]
	has_lantern = true
	_show_message("You craft a lantern. A ring of light now follows you through the dark.")


func _night_relief() -> float:
	# Only the house dims the night overall. The lantern lights a ring instead.
	var relief := 0.0
	if house_stage >= 3:
		relief += HOUSE_RELIEF
	return minf(relief, 0.9)


func _end_day(message: String) -> void:
	# Crops grow one stage overnight and brush piles come back.
	for pos in crops.keys():
		crops[pos] = min(crops[pos] + 1, MAX_STAGE)
	day += 1
	clock = 0.0
	_respawn_brush()
	_update_shadow_tile()
	_show_message(message)
	queue_redraw()


func _update_shadow_tile() -> void:
	# The shadow creeps closer to the farm each night.
	var x := BORDER_X + INNER_W - 2 - (day - 1) * 2
	x = max(x, BORDER_X + 14)
	shadow_tile = Vector2i(x, BORDER_Y + INNER_H / 2 - 4)


# --- Helpers -----------------------------------------------------------------

func _level(skill: String) -> int:
	return 1 + int(skill_xp[skill]) / 100


func _grant_xp(skill: String, amount: int) -> void:
	skill_xp[skill] += amount


func _cost_text(cost: Dictionary) -> String:
	return "%d wood, %d fiber, Bushcrafting %d" % [cost["wood"], cost["fiber"], cost["level"]]


func _show_message(text: String) -> void:
	message_label.text = text
	message_timer = MESSAGE_SECONDS


func _tile_in_front() -> Vector2i:
	var p: Vector2 = player.position + player.facing * PX * 0.6
	return Vector2i(floori(p.x / PX), floori(p.y / PX))


func _in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < MAP_W and tile.y < MAP_H


func _is_blocked_world(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / PX), floori(p.y / PX))
	if not _in_bounds(t):
		return true
	var kind: int = map[t.y][t.x]
	if kind == Tile.TREE or kind == Tile.WATER or kind == Tile.HOUSE:
		return true
	return brush.has(t)


func _world_tile(ix: int, iy: int) -> Vector2i:
	return Vector2i(ix + BORDER_X, iy + BORDER_Y)


func _tile_center(wx: int, wy: int) -> Vector2:
	return Vector2(wx * PX + PX * 0.5, wy * PX + PX * 0.5)


func _tile_rect(t: Vector2i) -> Rect2:
	return Rect2(t.x * PX, t.y * PX, PX, PX)
