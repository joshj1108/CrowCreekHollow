extends Node2D

## The farm and farmhouse: planting, bushcrafting, skills, inventory, gear,
## lantern tiers, sanity, the early homestead quests, night events, the walk-in
## house, the minimap, the action bar, the day clock, and save/load.
## The day runs 06:00 to 03:00. Sleep in bed to save and end the day.
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
# in a decrepit state; repairs change its condition and unlock rooms.
const HOUSE_IX := 26
const HOUSE_IY := 3
const HOUSE_W := 6
const HOUSE_H := 5
const HOUSE_DOOR_IX := HOUSE_IX + 2
const HOUSE_DOOR_IY := HOUSE_IY + HOUSE_H - 1

# The walk-in interior sits below the farm, out of view of it.
const INT_W := 14
const INT_H := 9
const INT_ORIGIN := Vector2i(0, MAP_H + 4)

# Brush piles for bushcrafting, in inner coordinates. They respawn each morning.
const BRUSH_SPOTS := [
	Vector2i(16, 3), Vector2i(22, 15), Vector2i(30, 14),
	Vector2i(8, 16), Vector2i(35, 6), Vector2i(18, 20),
]

# Time runs from 06:00 to 03:00 the next morning (hours 6 to 27).
const DAY_LENGTH := 240.0   # real seconds for a full day
const START_HOUR := 6.0
const DAY_END_HOUR := 27.0  # 03:00. Missing bed by then means collapsing.
const DUSK_HOUR := 19.0
const SLEEP_HOUR := 18.0    # the bed can be used from 18:00 onward
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
	{"stage": 1, "text": "Boarded: the walls hold, and sanity recovers faster indoors"},
	{"stage": 2, "text": "Parlor opens: tidy at the station for Cleaning XP"},
	{"stage": 3, "text": "Study opens, and a restored house softens the night"},
]
const HOUSE_WALLS := [Color("4a3a2e"), Color("6b5340"), Color("8a6a4c"), Color("b08a5e")]
const HOUSE_ROOFS := [Color("2d2620"), Color("4a3a2c"), Color("6b4b33"), Color("8c5a3c")]
const HOUSE_RELIEF := 0.2   # night darkness reduction once the house is restored

# Lantern tiers. Each entry is the next thing to build, in order.
const LANTERN_TIERS := [
	{"name": "Tin Lantern", "radius": 2.5, "wood": 2, "fiber": 2, "resin": 0, "level": 2},
	{"name": "Brass Lantern", "radius": 4.0, "wood": 4, "fiber": 4, "resin": 2, "level": 4},
	{"name": "Hollow Lantern", "radius": 6.0, "wood": 6, "fiber": 6, "resin": 4, "level": 6},
]
const LANTERN_FLICKER_TIER := 3

# Early homestead quests. Each reads a stat and pays out a reward once.
const QUESTS := [
	{"id": "plot", "title": "Break ground", "text": "Plant 3 seeds on the tilled soil.",
		"stat": "planted", "goal": 3, "reward": {"seeds": 5}},
	{"id": "harvest", "title": "First harvest", "text": "Harvest one ripe crop.",
		"stat": "harvested", "goal": 1, "reward": {"skill": "Farming", "xp": 50}},
	{"id": "brush", "title": "Gather from the brush", "text": "Gather from 3 brush piles.",
		"stat": "gathered", "goal": 3, "reward": {"wood": 2, "fiber": 2}},
	{"id": "patch", "title": "Patch the walls", "text": "Repair the farmhouse to Boarded.",
		"stat": "house_stage", "goal": 1, "reward": {"wood": 2, "fiber": 2}},
	{"id": "light", "title": "Light the way", "text": "Build a Tin Lantern.",
		"stat": "lantern_tier", "goal": 1, "reward": {"seeds": 3}},
	{"id": "bed", "title": "Sleep under your own roof", "text": "Sleep in the bedroom bed before 03:00.",
		"stat": "slept", "goal": 1, "reward": {"skill": "Carpentry", "xp": 40}},
	{"id": "tidy", "title": "A clean start", "text": "Repair the house to Patched and tidy it once.",
		"stat": "tidied", "goal": 1, "reward": {"skill": "Cleaning", "xp": 40}},
]

const SKILLS := ["Farming", "Bushcrafting", "Carpentry", "Cleaning", "Fishing"]
const XP_PLANT := 5
const XP_HARVEST := 25
const XP_GATHER := 10
const XP_REPAIR := 30
const XP_TIDY := 20
const XP_MEND := 15
const MEND_WOOD := 1
const MEND_FIBER := 1
const XP_FISH := 15
const FISH_SPOT_COUNT := 3
const FISH_SPOT_SECONDS := 12.0   # how often the sparkling fishing spots move

const STARTING_SEEDS := 5
const MESSAGE_SECONDS := 3.0
const SANITY_MAX := 100.0
const LOW_SANITY := 30.0
const SLEEP_SANITY := 25.0
const TIDY_SANITY := 10.0
const COLLAPSE_SANITY_PENALTY := 5   # permanent cap reduction, curable later
const SAVE_PATH := "user://hallowvale_save.json"

# Night events: picked by day so the nights vary. "shadow" says where it appears.
const NIGHT_EVENTS := [
	{"message": "Something stands at the edge of the field.", "shadow": "field", "sanity": -5},
	{"message": "Three slow knocks sound against the house wall.", "shadow": "house", "sanity": -10},
	{"message": "A figure watches from the dark beside the house.", "shadow": "house", "sanity": -15},
	{"message": "The field is quiet tonight. Too quiet.", "shadow": "none", "sanity": -3},
]

enum Tile { TREE, GRASS, SOIL, PATH, WATER, HOUSE, DOOR, FLOOR, WALL, EXIT, BED, STATION, DESK }

const BLOCKING := [Tile.TREE, Tile.WATER, Tile.HOUSE, Tile.WALL, Tile.BED, Tile.STATION, Tile.DESK]

const TILE_COLORS := {
	Tile.TREE: Color("2f4f2f"),
	Tile.GRASS: Color("6a9f4b"),
	Tile.SOIL: Color("7a5234"),
	Tile.PATH: Color("c9a66b"),
	Tile.WATER: Color("3f6fa8"),
	Tile.HOUSE: Color("6b5340"),
	Tile.DOOR: Color("24180f"),
	Tile.FLOOR: Color("5a4634"),
	Tile.WALL: Color("2a211a"),
	Tile.EXIT: Color("3a2e22"),
	Tile.BED: Color("8a4a4a"),
	Tile.STATION: Color("4f6b7a"),
	Tile.DESK: Color("6b5a2e"),
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

var map: Array = []                 # farm tiles, [y][x]
var interior: Array = []            # house tiles, [y][x], local to INT_ORIGIN
var crops := {}                     # Vector2i world tile -> growth stage
var brush := {}                     # Vector2i world tile -> true while unharvested
var clock := 0.0
var current_hour := START_HOUR
var day := 1
var skill_xp := {"Farming": 0, "Bushcrafting": 0, "Carpentry": 0, "Cleaning": 0, "Fishing": 0}
var inventory := {"seeds": STARTING_SEEDS, "crops": 0, "fish": 0}
var materials := {"wood": 0, "fiber": 0, "resin": 0}
var stats := {"planted": 0, "harvested": 0, "gathered": 0, "slept": 0, "tidied": 0, "fished": 0}
var pond_edges: Array = []          # water tiles with land beside them
var fish_spots: Array = []          # the currently sparkling spots
var fish_timer := 0.0
var fish_layer: Node2D
var quests_done := {}               # quest id -> true
var lantern_tier := 0               # 0 = none built yet
var house_stage := 0
var tidied_day := 0
var sanity := SANITY_MAX
var sanity_penalty := 0             # permanent cap reduction from collapsing
var inside := false                 # standing in the farmhouse interior
var open_tab := ""                  # "" when the action bar panel is closed
var event_fired_day := 0            # the day the night event last happened
var tonight_shadow := Vector2i(-1, -1)
var shadow_tile := Vector2i.ZERO    # where the field shadow sits
var message_timer := 0.0

var action_bar: ActionBar
var minimap: Minimap
var canvas_modulate: CanvasModulate
var hud_label: Label
var message_label: Label
var player    # Node2D with player.gd attached
var camera: Camera2D
var lantern_light: PointLight2D


func _ready() -> void:
	_setup_input()
	_build_map()
	_find_pond_edges()
	var loaded := _load_game()
	if not loaded:
		_respawn_brush()
	_build_interior()
	_build_world()
	_build_hud()
	_build_action_bar()
	_update_shadow_tile()
	if loaded:
		_show_message("Welcome back. Day %d." % day)


func _process(delta: float) -> void:
	clock += delta
	current_hour = START_HOUR + clock / DAY_LENGTH * (DAY_END_HOUR - START_HOUR)

	if current_hour >= DAY_END_HOUR:
		_collapse()
		return

	if current_hour >= EVENT_HOUR and event_fired_day != day:
		_trigger_night_event()

	var darkness := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, current_hour)
	darkness *= 1.0 - _night_relief()
	darkness = clampf(darkness + _low_sanity_boost(), 0.0, 1.0)
	canvas_modulate.color = DAY_TINT.lerp(NIGHT_TINT, darkness)
	_update_lantern(darkness)
	_update_sanity(darkness, delta)

	_check_doors()
	_check_quests()
	_update_fish_spots(delta)

	var minutes := int(fmod(current_hour, 1.0) * 60.0)
	hud_label.text = "Day %d   %02d:%02d   Sanity %d/%d" % [
		day, int(fmod(current_hour, 24.0)), minutes, int(sanity), _sanity_max()]

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

	for y in INT_H:
		for x in INT_W:
			var kind: int = interior[y][x]
			draw_rect(_tile_rect(INT_ORIGIN + Vector2i(x, y)), TILE_COLORS[kind])

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

	if tonight_shadow.x >= 0:
		var s := _tile_center(tonight_shadow.x, tonight_shadow.y)
		draw_circle(s, PX * 0.6, Color(0.02, 0.01, 0.05, 0.9))
		draw_circle(s + Vector2(-8, -6), 3, Color(0.9, 0.1, 0.1))
		draw_circle(s + Vector2(8, -6), 3, Color(0.9, 0.1, 0.1))


func _draw_house() -> void:
	var origin := _world_tile(HOUSE_IX, HOUSE_IY)
	var rect := Rect2(Vector2(origin) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	var stage := house_stage

	draw_rect(rect, HOUSE_WALLS[stage])
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, PX * 1.4)), HOUSE_ROOFS[stage])

	# The door fills the bottom-middle tile of the footprint.
	var door_pos := rect.position + Vector2(2 * PX, (HOUSE_H - 1) * PX)
	draw_rect(Rect2(door_pos, Vector2(PX, PX)), Color("24180f"))

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


# --- Setup -------------------------------------------------------------------

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
	_ensure_action("quests", [KEY_Q])


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
				if ix == HOUSE_DOOR_IX and iy == HOUSE_DOOR_IY:
					t = Tile.DOOR
			row.append(t)
		map.append(row)


# The interior is a fixed layout. Rooms open up as the house is repaired.
func _build_interior() -> void:
	interior = []
	for y in INT_H:
		var row: Array = []
		for x in INT_W:
			row.append(Tile.WALL)
		interior.append(row)

	_fill_interior(1, 5, 12, 7, Tile.FLOOR)   # the hall, always open
	_set_interior(6, 8, Tile.EXIT)            # back out to the farm

	# The bedroom and its bed are open from the start.
	_fill_interior(1, 1, 4, 4, Tile.FLOOR)
	_set_interior(2, 1, Tile.BED)
	if house_stage >= 2:
		_fill_interior(9, 1, 12, 4, Tile.FLOOR)
		_set_interior(11, 1, Tile.STATION)
	if house_stage >= 3:
		_fill_interior(5, 1, 8, 4, Tile.FLOOR)
		_set_interior(6, 1, Tile.DESK)


func _fill_interior(x0: int, y0: int, x1: int, y1: int, kind: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			interior[y][x] = kind


func _set_interior(x: int, y: int, kind: int) -> void:
	interior[y][x] = kind


func _respawn_brush() -> void:
	brush.clear()
	for spot in BRUSH_SPOTS:
		brush[_world_tile(spot.x, spot.y)] = true
	queue_redraw()


func _build_world() -> void:
	# Tiles and the house are drawn by this node's _draw(). The player and
	# camera are created here so they draw above the map.
	# The fishing spots are drawn on their own layer, under the player.
	fish_layer = Node2D.new()
	fish_layer.draw.connect(_draw_fish_spots)
	add_child(fish_layer)

	player = Node2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.position = _tile_center(BORDER_X + INNER_W / 2, BORDER_Y + INNER_H / 2)
	player.is_blocked = _is_blocked_world
	add_child(player)
	_build_lantern_light()

	camera = Camera2D.new()
	camera.enabled = true
	player.add_child(camera)
	_set_bounds()

	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)


func _build_lantern_light() -> void:
	# A soft white-to-black radial gradient, tinted warm. Its size follows the lantern tier.
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
	lantern_light.color = Color("ffd38a")
	lantern_light.energy = 1.0
	lantern_light.enabled = false
	player.add_child(lantern_light)
	_apply_lantern_radius()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_label = _make_label(layer, Vector2(16, 12), 24)
	message_label = _make_label(layer, Vector2(16, 100), 20)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(620, 0)

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
	# Indoors the minimap shows the house, since the player isn't on the farm.
	var player_tile: Vector2 = Vector2(HOUSE_DOOR_IX + BORDER_X, HOUSE_DOOR_IY + BORDER_Y) if inside else player.position / PX
	minimap.update_view(map, TILE_COLORS, brush.keys(), player_tile, tonight_shadow)


# --- Input and panels --------------------------------------------------------

func _handle_keys() -> void:
	if Input.is_action_just_pressed("skills"):
		_toggle_tab("Skills")
	if Input.is_action_just_pressed("inventory"):
		_toggle_tab("Inventory")
	if Input.is_action_just_pressed("gear"):
		_toggle_tab("Gear")
	if Input.is_action_just_pressed("quests"):
		_toggle_tab("Quests")
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
		"mend":
			_mend_house()
		"tidy":
			_tidy_house()
		"advance_lantern":
			_advance_lantern()


func _refresh_panel() -> void:
	var rows: Array = []
	match open_tab:
		"Skills":
			rows = _skill_rows()
		"Inventory":
			rows = _inventory_rows()
		"Gear":
			rows = _gear_rows()
		"Quests":
			rows = _quest_rows()
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
	rows.append({"note": "Bushcrafting gathers wood, fiber, and resin from brush piles. Carpentry trains by mending boards and repairing the house. Cleaning tidies it. Fishing works the sparkling spots at the pond."})
	return rows


func _inventory_rows() -> Array:
	return [
		{"section": "Seeds and crops"},
		{"name": "Seeds", "value": str(inventory["seeds"])},
		{"name": "Harvested crops", "value": str(inventory["crops"])},
		{"name": "Fish", "value": str(inventory["fish"])},
		{"section": "Materials"},
		{"name": "Wood", "value": str(materials["wood"])},
		{"name": "Fiber", "value": str(materials["fiber"])},
		{"name": "Resin", "value": str(materials["resin"])},
	]


func _gear_rows() -> Array:
	var rows: Array = [
		{"section": "Tools"},
		{"name": "Hoe", "value": "equipped"},
		{"section": "Lantern"},
	]
	if lantern_tier == 0:
		rows.append({"name": "Lantern", "value": "not built"})
	else:
		var current: Dictionary = LANTERN_TIERS[lantern_tier - 1]
		rows.append({"name": current["name"], "value": "light ring %.1f tiles" % current["radius"]})
	if lantern_tier < LANTERN_TIERS.size():
		var upcoming: Dictionary = LANTERN_TIERS[lantern_tier]
		rows.append({
			"name": "Next: %s" % upcoming["name"],
			"value": _cost_text(upcoming),
			"button": "Build" if lantern_tier == 0 else "Upgrade",
			"action": "advance_lantern",
			"enabled": _can_advance_lantern(),
		})
	rows.append({"note": "A lantern lights a ring around you in the dark. Each tier needs more Bushcrafting and better materials."})
	return rows


func _quest_rows() -> Array:
	var rows: Array = []
	for q in QUESTS:
		var done: bool = quests_done.has(q["id"])
		var value := _stat_value(q["stat"])
		var shown := mini(value, q["goal"])
		rows.append({
			"name": "%s%s" % [q["title"], "   (done)" if done else ""],
			"value": "%d/%d" % [shown, q["goal"]],
			"progress": float(shown) / float(q["goal"]),
		})
		rows.append({"note": "%s  Reward: %s" % [q["text"], _reward_text(q["reward"])]})
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
	rows.append({
		"name": "Mend a board",
		"value": "%d wood, %d fiber: +%d Carpentry XP" % [MEND_WOOD, MEND_FIBER, XP_MEND],
		"button": "Mend",
		"action": "mend",
		"enabled": _can_mend(),
	})
	rows.append({"section": "Rest"})
	rows.append({"note": "The bed is in the bedroom. Walk there and press Space from 18:00 to save and end the day. If you aren't in bed by 03:00 you collapse, and your sanity limit drops permanently."})
	rows.append({"name": "Sanity limit", "value": "%d of %d" % [_sanity_max(), int(SANITY_MAX)]})
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
		{"name": "Use, plant, harvest, gather, sleep", "value": "Space or Enter"},
		{"name": "Skills", "value": "K"},
		{"name": "Inventory", "value": "I"},
		{"name": "Gear", "value": "G"},
		{"name": "Quests", "value": "Q"},
		{"name": "House", "value": "H"},
		{"name": "Settings", "value": "Esc"},
		{"section": "Saving"},
		{"note": "Progress saves only when you sleep, or when you collapse at 03:00. Quitting during the day loses what happened since the last save."},
		{"note": "Sound and display options are coming later."},
	]


# --- Farming, gathering, and the house ---------------------------------------

func _interact() -> void:
	var tile := _tile_in_front()
	# Interior tiles sit outside the farm's bounds, so accept either area.
	if not _in_bounds(tile) and not _in_interior(tile):
		return

	if inside:
		match _kind_at(tile):
			Tile.BED:
				_try_sleep()
			Tile.STATION:
				_tidy_house()
			Tile.DESK:
				_read_desk()
		return

	if fish_spots.has(tile):
		_fish(tile)
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
			stats["harvested"] += 1
			_grant_xp("Farming", XP_HARVEST)
			_show_message("Harvested a crop and kept a seed. +%d Farming XP" % XP_HARVEST)
		else:
			_show_message("It isn't ready yet.")
	elif inventory["seeds"] > 0:
		inventory["seeds"] -= 1
		crops[tile] = 0
		stats["planted"] += 1
		_grant_xp("Farming", XP_PLANT)
		_show_message("Planted a seed. +%d Farming XP" % XP_PLANT)
	else:
		_show_message("You have no seeds. Harvest a crop to get more.")

	queue_redraw()


# --- Fishing -----------------------------------------------------------------

# Water tiles that touch land. Fishing spots are picked from these.
func _find_pond_edges() -> void:
	pond_edges = []
	for y in MAP_H:
		for x in MAP_W:
			if map[y][x] != Tile.WATER:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if _in_bounds(n) and map[n.y][n.x] == Tile.GRASS:
					pond_edges.append(Vector2i(x, y))
					break


# Every FISH_SPOT_SECONDS, the sparkling spots move to new places on the pond edge.
func _update_fish_spots(delta: float) -> void:
	fish_timer -= delta
	if fish_timer <= 0.0:
		fish_timer = FISH_SPOT_SECONDS
		fish_spots.clear()
		for i in FISH_SPOT_COUNT:
			if pond_edges.is_empty():
				break
			var pick: Vector2i = pond_edges.pick_random()
			if not fish_spots.has(pick):
				fish_spots.append(pick)
		queue_redraw_fish()
	# The sparkle pulses, so the layer redraws every frame.
	queue_redraw_fish()


func queue_redraw_fish() -> void:
	if fish_layer != null:
		fish_layer.queue_redraw()


func _draw_fish_spots() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for i in fish_spots.size():
		var c := _tile_center(fish_spots[i].x, fish_spots[i].y)
		var pulse := 0.75 + 0.25 * sin(t * 5.0 + i)
		fish_layer.draw_circle(c, PX * 0.22 * pulse, Color(0.85, 0.97, 1.0, 0.3))
		var r := PX * 0.28 * pulse
		var star := Color(1.0, 1.0, 0.75, 0.95)
		fish_layer.draw_line(c + Vector2(-r, 0), c + Vector2(r, 0), star, 2.0)
		fish_layer.draw_line(c + Vector2(0, -r), c + Vector2(0, r), star, 2.0)


func _fish(tile: Vector2i) -> void:
	# Each try uses up the spot. The fish scatter or the spot goes quiet.
	fish_spots.erase(tile)
	var chance := 0.6 + 0.02 * float(_level("Fishing") - 1)
	if randf() < chance:
		inventory["fish"] += 1
		stats["fished"] += 1
		_grant_xp("Fishing", XP_FISH)
		_show_message("You land a fish. +%d Fishing XP" % XP_FISH)
	else:
		_show_message("Nothing bit. The fish scattered.")


func _read_desk() -> void:
	_show_message("A desk covered in seed catalogs and unpaid bills.")


func _gather(tile: Vector2i) -> void:
	brush.erase(tile)
	materials["wood"] += 1
	materials["fiber"] += 1
	stats["gathered"] += 1
	var found := "wood and fiber"
	if randf() < 0.34:
		materials["resin"] += 1
		found = "wood, fiber, and resin"
	_grant_xp("Bushcrafting", XP_GATHER)
	_show_message("Gathered %s from the brush. +%d Bushcrafting XP" % [found, XP_GATHER])
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
	_build_interior()
	_show_message("Repaired. The farmhouse is now %s. +%d Carpentry XP" % [STAGE_NAMES[house_stage], XP_REPAIR])
	queue_redraw()


# Mending boards is repeatable Carpentry training, so the house can progress
# without waiting on quest rewards.
func _can_mend() -> bool:
	return materials["wood"] >= MEND_WOOD and materials["fiber"] >= MEND_FIBER


func _mend_house() -> void:
	if not _can_mend():
		_show_message("You need %d wood and %d fiber to mend a board." % [MEND_WOOD, MEND_FIBER])
		return
	materials["wood"] -= MEND_WOOD
	materials["fiber"] -= MEND_FIBER
	_grant_xp("Carpentry", XP_MEND)
	_show_message("You mend a board. +%d Carpentry XP" % XP_MEND)


# Sleeping only happens at the bed, from 18:00 until 03:00.
func _try_sleep() -> void:
	if current_hour < SLEEP_HOUR:
		_show_message("You aren't tired yet. The bed will be there after 18:00.")
		return
	stats["slept"] += 1
	_change_sanity(SLEEP_SANITY)
	# Sleeping keeps you in bed, so the house is not left.
	_end_day("You sleep through the night.", false)


# Missing the bed by 03:00 ends the day, and the sanity limit drops for good.
func _collapse() -> void:
	sanity_penalty += COLLAPSE_SANITY_PENALTY
	sanity = minf(sanity, _sanity_max())
	_end_day("You collapse before reaching your bed. Something in your mind gives way.")


func _can_tidy() -> bool:
	return house_stage >= 2 and tidied_day != day


func _tidy_house() -> void:
	if not _can_tidy():
		_show_message("The house is already tidy for today.")
		return
	tidied_day = day
	stats["tidied"] += 1
	_grant_xp("Cleaning", XP_TIDY)
	_change_sanity(TIDY_SANITY)
	_show_message("You tidy the house. The air feels a little lighter. +%d Cleaning XP" % XP_TIDY)


func _can_advance_lantern() -> bool:
	if lantern_tier >= LANTERN_TIERS.size():
		return false
	var t: Dictionary = LANTERN_TIERS[lantern_tier]
	return materials["wood"] >= t["wood"] \
		and materials["fiber"] >= t["fiber"] \
		and materials["resin"] >= t["resin"] \
		and _level("Bushcrafting") >= t["level"]


func _advance_lantern() -> void:
	if not _can_advance_lantern():
		_show_message("You need %s for the next lantern." % _cost_text(LANTERN_TIERS[lantern_tier]))
		return
	var t: Dictionary = LANTERN_TIERS[lantern_tier]
	materials["wood"] -= t["wood"]
	materials["fiber"] -= t["fiber"]
	materials["resin"] -= t["resin"]
	lantern_tier += 1
	_apply_lantern_radius()
	_show_message("You build a %s. Its light reaches %.1f tiles." % [t["name"], t["radius"]])


func _apply_lantern_radius() -> void:
	if lantern_tier == 0:
		return
	var radius: float = LANTERN_TIERS[lantern_tier - 1]["radius"]
	lantern_light.texture_scale = radius * PX / 128.0


func _update_lantern(darkness: float) -> void:
	lantern_light.enabled = lantern_tier > 0 and darkness > 0.05
	if lantern_tier >= LANTERN_FLICKER_TIER:
		var t := Time.get_ticks_msec() / 1000.0
		lantern_light.energy = 0.9 + 0.08 * sin(t * 9.0) + randf_range(-0.03, 0.03)
	else:
		lantern_light.energy = 1.0


func _night_relief() -> float:
	# The restored house dims the night overall. The lantern lights a ring instead.
	var relief := 0.0
	if house_stage >= 3:
		relief += HOUSE_RELIEF
	return minf(relief, 0.9)


# --- Quests ------------------------------------------------------------------

func _stat_value(stat: String) -> int:
	match stat:
		"house_stage":
			return house_stage
		"lantern_tier":
			return lantern_tier
	return int(stats.get(stat, 0))


func _check_quests() -> void:
	for q in QUESTS:
		if quests_done.has(q["id"]):
			continue
		if _stat_value(q["stat"]) >= q["goal"]:
			quests_done[q["id"]] = true
			_grant_reward(q["reward"])
			_show_message("Quest complete: %s. Reward: %s" % [q["title"], _reward_text(q["reward"])])


func _grant_reward(reward: Dictionary) -> void:
	if reward.has("seeds"):
		inventory["seeds"] += reward["seeds"]
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			materials[mat] += reward[mat]
	if reward.has("xp"):
		_grant_xp(reward["skill"], reward["xp"])


func _reward_text(reward: Dictionary) -> String:
	var parts: Array = []
	if reward.has("seeds"):
		parts.append("%d seeds" % reward["seeds"])
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			parts.append("%d %s" % [reward[mat], mat])
	if reward.has("xp"):
		parts.append("%d %s XP" % [reward["xp"], reward["skill"]])
	return ", ".join(parts)


# --- Sanity and night events ------------------------------------------------

func _sanity_max() -> float:
	return SANITY_MAX - sanity_penalty


func _change_sanity(amount: float) -> void:
	sanity = clampf(sanity + amount, 0.0, _sanity_max())


func _update_sanity(darkness: float, delta: float) -> void:
	var rate := 0.02                 # slow recovery outdoors in daylight
	if inside:
		rate = 0.1 + (0.05 if house_stage >= 1 else 0.0)   # the house is shelter
	elif darkness > 0.5:
		rate = -0.05                 # the dark wears on you
	_change_sanity(rate * delta)


func _low_sanity_boost() -> float:
	# Low sanity makes everything darker, a visible warning.
	return maxf(0.0, (LOW_SANITY - sanity) / LOW_SANITY) * 0.25


func _trigger_night_event() -> void:
	event_fired_day = day
	var ev: Dictionary = NIGHT_EVENTS[(day * 3) % NIGHT_EVENTS.size()]
	match ev["shadow"]:
		"field":
			tonight_shadow = shadow_tile
		"house":
			tonight_shadow = _world_tile(HOUSE_IX + HOUSE_W, HOUSE_IY + 1)
		_:
			tonight_shadow = Vector2i(-1, -1)
	_change_sanity(ev["sanity"])
	_show_message(ev["message"])
	queue_redraw()


# Ends the day and saves. Both sleeping and collapsing come through here.
func _end_day(base: String, leave_house: bool = true) -> void:
	if inside and leave_house:
		_leave_house()
	for pos in crops.keys():
		crops[pos] = min(crops[pos] + 1, MAX_STAGE)
	day += 1
	clock = 0.0
	tonight_shadow = Vector2i(-1, -1)
	_respawn_brush()
	_update_shadow_tile()
	_show_message("%s Your crops grew overnight." % base)
	_save_game()
	queue_redraw()


func _update_shadow_tile() -> void:
	# The field shadow creeps closer to the farm each night.
	var x := BORDER_X + INNER_W - 2 - (day - 1) * 2
	x = max(x, BORDER_X + 14)
	shadow_tile = Vector2i(x, BORDER_Y + INNER_H / 2 - 4)


# --- Walking into and out of the house --------------------------------------

func _check_doors() -> void:
	var kind := _kind_at(_player_tile())
	if not inside and kind == Tile.DOOR:
		_enter_house()
	elif inside and kind == Tile.EXIT:
		_leave_house()


func _enter_house() -> void:
	inside = true
	player.position = _tile_center(INT_ORIGIN.x + 6, INT_ORIGIN.y + 6)
	_set_bounds()
	_show_message("You step inside. The air is cold and smells of old wood.")


func _leave_house() -> void:
	inside = false
	player.position = _tile_center(BORDER_X + HOUSE_DOOR_IX, BORDER_Y + HOUSE_DOOR_IY + 1)
	_set_bounds()


func _set_bounds() -> void:
	if inside:
		player.min_pos = _tile_center(INT_ORIGIN.x + 1, INT_ORIGIN.y + 1)
		# The bottom row holds the exit mat, so the player's clamp must reach it.
		player.max_pos = _tile_center(INT_ORIGIN.x + INT_W - 2, INT_ORIGIN.y + INT_H - 1)
		camera.limit_left = INT_ORIGIN.x * PX
		camera.limit_top = INT_ORIGIN.y * PX
		camera.limit_right = (INT_ORIGIN.x + INT_W) * PX
		camera.limit_bottom = (INT_ORIGIN.y + INT_H) * PX
	else:
		player.min_pos = _tile_center(BORDER_X, BORDER_Y)
		player.max_pos = _tile_center(BORDER_X + INNER_W - 1, BORDER_Y + INNER_H - 1)
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = MAP_W * PX
		camera.limit_bottom = MAP_H * PX


# --- Save and load ----------------------------------------------------------

func _save_game() -> void:
	var data := {
		"day": day,
		"skill_xp": skill_xp,
		"inventory": inventory,
		"materials": materials,
		"stats": stats,
		"quests_done": quests_done,
		"lantern_tier": lantern_tier,
		"house_stage": house_stage,
		"tidied_day": tidied_day,
		"event_fired_day": event_fired_day,
		"sanity": sanity,
		"sanity_penalty": sanity_penalty,
		"crops": _crops_to_array(),
		"brush": _brush_to_array(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed

	day = int(data.get("day", 1))
	_merge_ints(skill_xp, data.get("skill_xp"))
	_merge_ints(inventory, data.get("inventory"))
	_merge_ints(materials, data.get("materials"))
	_merge_ints(stats, data.get("stats"))
	quests_done = data.get("quests_done", {})
	lantern_tier = int(data.get("lantern_tier", 0))
	house_stage = int(data.get("house_stage", 0))
	tidied_day = int(data.get("tidied_day", 0))
	event_fired_day = int(data.get("event_fired_day", 0))
	sanity_penalty = int(data.get("sanity_penalty", 0))
	sanity = float(data.get("sanity", SANITY_MAX))

	crops.clear()
	for c in data.get("crops", []):
		crops[Vector2i(int(c["x"]), int(c["y"]))] = int(c["stage"])
	brush.clear()
	for b in data.get("brush", []):
		brush[Vector2i(int(b[0]), int(b[1]))] = true
	return true


func _merge_ints(target: Dictionary, saved: Variant) -> void:
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for key in target.keys():
		if saved.has(key):
			target[key] = int(saved[key])


func _crops_to_array() -> Array:
	var arr: Array = []
	for pos in crops:
		arr.append({"x": pos.x, "y": pos.y, "stage": crops[pos]})
	return arr


func _brush_to_array() -> Array:
	var arr: Array = []
	for pos in brush:
		arr.append([pos.x, pos.y])
	return arr


# --- Helpers -----------------------------------------------------------------

func _level(skill: String) -> int:
	return 1 + int(skill_xp[skill]) / 100


func _grant_xp(skill: String, amount: int) -> void:
	skill_xp[skill] += amount


func _cost_text(cost: Dictionary) -> String:
	var parts := ["%d wood" % cost["wood"], "%d fiber" % cost["fiber"]]
	if cost.get("resin", 0) > 0:
		parts.append("%d resin" % cost["resin"])
	parts.append("Bushcrafting %d" % cost["level"])
	return ", ".join(parts)


func _show_message(text: String) -> void:
	message_label.text = text
	message_timer = MESSAGE_SECONDS + text.length() / 30.0


func _tile_in_front() -> Vector2i:
	var p: Vector2 = player.position + player.facing * PX * 0.6
	return Vector2i(floori(p.x / PX), floori(p.y / PX))


func _player_tile() -> Vector2i:
	return Vector2i(floori(player.position.x / PX), floori(player.position.y / PX))


func _in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < MAP_W and tile.y < MAP_H


func _in_interior(tile: Vector2i) -> bool:
	return tile.x >= INT_ORIGIN.x and tile.x < INT_ORIGIN.x + INT_W \
		and tile.y >= INT_ORIGIN.y and tile.y < INT_ORIGIN.y + INT_H


# The tile kind at a world tile: the interior if it's inside the house, else the farm.
func _kind_at(tile: Vector2i) -> int:
	if _in_interior(tile):
		return interior[tile.y - INT_ORIGIN.y][tile.x - INT_ORIGIN.x]
	if not _in_bounds(tile):
		return Tile.TREE
	return map[tile.y][tile.x]


func _is_blocked_world(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / PX), floori(p.y / PX))
	if BLOCKING.has(_kind_at(t)):
		return true
	return not inside and brush.has(t)


func _world_tile(ix: int, iy: int) -> Vector2i:
	return Vector2i(ix + BORDER_X, iy + BORDER_Y)


func _tile_center(wx: int, wy: int) -> Vector2:
	return Vector2(wx * PX + PX * 0.5, wy * PX + PX * 0.5)


func _tile_rect(t: Vector2i) -> Rect2:
	return Rect2(t.x * PX, t.y * PX, PX, PX)
