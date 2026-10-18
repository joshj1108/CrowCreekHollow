extends Node2D

## Milestone 1: farm map, player, planting/harvest, Farming XP,
## day/night clock, a first night event, and HUD.
## Placeholder art is drawn in code; no external assets yet.

const TILE_SIZE := 16
const SCALE := 3
const PX := TILE_SIZE * SCALE  # one tile in world units

# The farm is INNER_W x INNER_H tiles of walkable land. A border of trees
# surrounds it, sized so the camera can stay centered on the player all the
# way to the walkable edge (half the 1280x720 viewport is ~13 x 7.5 tiles).
const INNER_W := 40
const INNER_H := 24
const BORDER_X := 14
const BORDER_Y := 8
const MAP_W := INNER_W + BORDER_X * 2
const MAP_H := INNER_H + BORDER_Y * 2

const DAY_LENGTH := 240.0   # real seconds for the 06:00 -> 24:00 stretch
const START_HOUR := 6.0
const DUSK_HOUR := 19.0
const EVENT_HOUR := 22.0

const MAX_STAGE := 3        # 0 = seed, 3 = ready to harvest
const FARM_XP_PER_PLANT := 5
const FARM_XP_PER_HARVEST := 25
const MESSAGE_SECONDS := 3.0

enum Tile { TREE, GRASS, SOIL, PATH, WATER }

const TILE_COLORS := {
	Tile.TREE: Color("2f4f2f"),
	Tile.GRASS: Color("6a9f4b"),
	Tile.SOIL: Color("7a5234"),
	Tile.PATH: Color("c9a66b"),
	Tile.WATER: Color("3f6fa8"),
}

const CROP_COLORS := [
	Color("8fd16b"),  # seed
	Color("4f9a3a"),  # sprout
	Color("2f7a2a"),  # growing
	Color("e8b440"),  # ready
]

const DAY_TINT := Color(1, 1, 1)
const NIGHT_TINT := Color("3a3f6e")

var map: Array = []
var crops := {}             # Vector2i tile -> growth stage (0..MAX_STAGE)
var clock := 0.0
var day := 1
var farm_xp := 0
var event_fired_day := 0    # the day the night event last happened
var shadow_tile := Vector2i.ZERO
var message_timer := 0.0
var skills_open := false

var canvas_modulate: CanvasModulate
var hud_label: Label
var skills_label: Label
var message_label: Label
var player    # Node2D with player.gd attached


func _ready() -> void:
	_setup_input()
	_build_map()
	_build_world()
	_build_hud()
	_update_shadow_tile()


func _process(delta: float) -> void:
	clock += delta
	var hour := START_HOUR + clock / DAY_LENGTH * 18.0

	if hour >= 24.0:
		_end_day()
		return

	if hour >= EVENT_HOUR and event_fired_day != day:
		event_fired_day = day
		_show_message("Something stands at the edge of the field.")
		queue_redraw()

	var night := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, hour)
	canvas_modulate.color = DAY_TINT.lerp(NIGHT_TINT, night)

	var h := int(hour)
	var m := int(fmod(hour, 1.0) * 60.0)
	hud_label.text = "Day %d   %02d:%02d" % [day, h, m]

	if Input.is_action_just_pressed("use"):
		_interact()
	if Input.is_action_just_pressed("skills"):
		skills_open = not skills_open
		_refresh_skills()

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""


func _draw() -> void:
	for y in MAP_H:
		for x in MAP_W:
			var tile: int = map[y][x]
			draw_rect(Rect2(x * PX, y * PX, PX, PX), TILE_COLORS[tile])

	for pos in crops:
		var stage: int = crops[pos]
		var center := Vector2(pos.x * PX + PX * 0.5, pos.y * PX + PX * 0.5)
		var size := PX * (0.2 + 0.2 * stage)
		draw_rect(Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), CROP_COLORS[stage])

	if event_fired_day == day:
		var s := Vector2(shadow_tile.x * PX + PX * 0.5, shadow_tile.y * PX + PX * 0.5)
		draw_circle(s, PX * 0.6, Color(0.02, 0.01, 0.05, 0.9))
		draw_circle(s + Vector2(-8, -6), 3, Color(0.9, 0.1, 0.1))
		draw_circle(s + Vector2(8, -6), 3, Color(0.9, 0.1, 0.1))


func _setup_input() -> void:
	_ensure_action("move_up", [KEY_W, KEY_UP])
	_ensure_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("use", [KEY_SPACE, KEY_ENTER])
	_ensure_action("skills", [KEY_K])


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
			row.append(t)
		map.append(row)


func _build_world() -> void:
	# Tile drawing is done by this node's _draw(). The player and camera are
	# created here so they draw above the map.
	player = Node2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.position = Vector2(
		(BORDER_X + INNER_W / 2) * PX + PX * 0.5,
		(BORDER_Y + INNER_H / 2) * PX + PX * 0.5)
	player.min_pos = Vector2(BORDER_X * PX + PX * 0.5, BORDER_Y * PX + PX * 0.5)
	player.max_pos = Vector2(
		(BORDER_X + INNER_W) * PX - PX * 0.5,
		(BORDER_Y + INNER_H) * PX - PX * 0.5)
	add_child(player)

	var camera := Camera2D.new()
	camera.enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_W * PX
	camera.limit_bottom = MAP_H * PX
	player.add_child(camera)

	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_label = _make_label(layer, Vector2(16, 12), 24)
	skills_label = _make_label(layer, Vector2(16, 60), 20)
	message_label = _make_label(layer, Vector2(16, 660), 20)


func _make_label(parent: Node, pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _interact() -> void:
	var tile := _tile_in_front()
	if not _in_bounds(tile) or map[tile.y][tile.x] != Tile.SOIL:
		return

	if crops.has(tile):
		if crops[tile] >= MAX_STAGE:
			crops.erase(tile)
			farm_xp += FARM_XP_PER_HARVEST
			_show_message("Harvested. +%d Farming XP" % FARM_XP_PER_HARVEST)
		else:
			_show_message("It isn't ready yet.")
	else:
		crops[tile] = 0
		farm_xp += FARM_XP_PER_PLANT
		_show_message("Planted a seed. +%d Farming XP" % FARM_XP_PER_PLANT)

	queue_redraw()
	_refresh_skills()


func _tile_in_front() -> Vector2i:
	var p: Vector2 = player.position + player.facing * PX * 0.6
	return Vector2i(int(floor(p.x / PX)), int(floor(p.y / PX)))


func _in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < MAP_W and tile.y < MAP_H


func _end_day() -> void:
	# Crops grow one stage overnight.
	for pos in crops.keys():
		crops[pos] = min(crops[pos] + 1, MAX_STAGE)
	day += 1
	clock = 0.0
	_update_shadow_tile()
	_show_message("Morning. Your crops grew overnight.")
	queue_redraw()


func _update_shadow_tile() -> void:
	# The shadow creeps closer to the farm each night.
	var x := BORDER_X + INNER_W - 2 - (day - 1) * 2
	x = max(x, BORDER_X + 14)
	shadow_tile = Vector2i(x, BORDER_Y + INNER_H / 2 - 4)


func _refresh_skills() -> void:
	if not skills_open:
		skills_label.text = ""
		return
	var level := 1 + farm_xp / 100
	skills_label.text = "Skills\nFarming  Lv %d  (%d XP)" % [level, farm_xp]


func _show_message(text: String) -> void:
	message_label.text = text
	message_timer = MESSAGE_SECONDS
