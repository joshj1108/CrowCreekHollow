extends Node2D

## Milestone 1: farm map, player, day/night clock, HUD.
## Placeholder art is drawn in code; no external assets yet.

const TILE_SIZE := 16
const SCALE := 3
const PX := TILE_SIZE * SCALE  # one tile in world units

const MAP_W := 40
const MAP_H := 24

const DAY_LENGTH := 240.0   # real seconds for the 06:00 -> 24:00 stretch
const START_HOUR := 6.0
const DUSK_HOUR := 19.0

enum Tile { GRASS, SOIL, PATH, WATER }

const TILE_COLORS := {
	Tile.GRASS: Color("6a9f4b"),
	Tile.SOIL: Color("7a5234"),
	Tile.PATH: Color("c9a66b"),
	Tile.WATER: Color("3f6fa8"),
}

const DAY_TINT := Color(1, 1, 1)
const NIGHT_TINT := Color("3a3f6e")

var map: Array = []
var clock := 0.0
var day := 1

var canvas_modulate: CanvasModulate
var hud_label: Label
var player: Node2D


func _ready() -> void:
	_setup_input()
	_build_map()
	_build_world()
	_build_hud()


func _process(delta: float) -> void:
	clock += delta
	var hour := START_HOUR + clock / DAY_LENGTH * 18.0

	if hour >= 24.0:
		day += 1
		clock = 0.0
		hour = START_HOUR

	var night := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, hour)
	canvas_modulate.color = DAY_TINT.lerp(NIGHT_TINT, night)

	var h := int(hour)
	var m := int(fmod(hour, 1.0) * 60.0)
	hud_label.text = "Day %d   %02d:%02d" % [day, h, m]


func _draw() -> void:
	for y in MAP_H:
		for x in MAP_W:
			var tile: int = map[y][x]
			draw_rect(Rect2(x * PX, y * PX, PX, PX), TILE_COLORS[tile])


func _setup_input() -> void:
	_ensure_action("move_up", [KEY_W, KEY_UP])
	_ensure_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])


func _ensure_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func _build_map() -> void:
	map = []
	var mid_y := MAP_H / 2
	var mid_x := MAP_W / 2
	for y in MAP_H:
		var row: Array = []
		for x in MAP_W:
			var t := Tile.GRASS
			if y == mid_y or x == mid_x:
				t = Tile.PATH
			if x >= 4 and x < 12 and y >= 4 and y < 10:
				t = Tile.SOIL
			if x >= MAP_W - 6 and y >= MAP_H - 6:
				t = Tile.WATER
			row.append(t)
		map.append(row)


func _build_world() -> void:
	# Tile drawing is done by this node's _draw().
	# Player and camera are created here so they sit above the map.
	var player_script := load("res://scripts/player.gd")
	player = Node2D.new()
	player.set_script(player_script)
	player.position = Vector2((MAP_W / 2) * PX + PX * 0.5, (MAP_H / 2) * PX + PX * 0.5)
	player.bounds = Vector2(MAP_W * PX, MAP_H * PX)
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

	hud_label = Label.new()
	hud_label.position = Vector2(16, 12)
	hud_label.add_theme_font_size_override("font_size", 24)
	layer.add_child(hud_label)
