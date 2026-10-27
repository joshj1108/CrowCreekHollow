class_name Minimap
extends Control

## Small overview of the whole map: terrain, house, brush piles, the player,
## and the shadow on event nights. main.gd pushes the current state each frame.

const PX_PER_TILE := 2.0
const FRAME_RAIL := 15.0   # how far the frame's rail reaches out past the map
const FRAME_COLOR := Color("1d1611")
const BORDER_COLOR := Color("8a6a3a")
const BUSH_COLOR := Color("3d6b2a")
const SHADOW_COLOR := Color("b02a2a")
const PLAYER_COLOR := Color("fff2b0")
const GRADE_GREY := 0.45   # how far tile colours are pulled toward grey
const GRADE_DARK := 0.22
const GRADE_TINT := Color("2e3640")
const MARKER_COLOR := Color("6fb8d9")   # landmarks, when the icon art is missing
# SpriteCook icons, 16 px cells in a row: the house, the well, the cave and the farmer (the player).
const ICONS_PATH := "res://art/ui/minimap_icons.png"
const ICON := 16
enum Icon { HOUSE, WELL, CAVE, PLAYER }

var tiles: Array = []
var tile_colors: Dictionary = {}
var bushes: Array = []
var player_tile := Vector2.ZERO
var shadow := Vector2i(-1, -1)   # (-1, -1) hides the shadow
var world_texture: Texture2D = null   # the whole land, one pixel per WORLD_PX_PER_TILE tiles
var world_tiles := Vector2i.ZERO
var markers: Array = []   # landmarks on the farm map, each [tile centre, Icon]
var icons_tex: Texture2D = load(ICONS_PATH) if ResourceLoader.exists(ICONS_PATH) else null

# The whole world at 1 pixel per 4 tiles. Each pixel is a sampled tile, not an average.
const WORLD_PX_PER_TILE := 0.25


func update_view(tiles_in: Array, colors: Dictionary, bushes_in: Array, player_tile_in: Vector2, shadow_in: Vector2i, markers_in: Array = []) -> void:
	world_texture = null
	markers = markers_in
	tiles = tiles_in
	tile_colors = colors
	bushes = bushes_in
	player_tile = player_tile_in
	shadow = shadow_in
	queue_redraw()


# Shows the whole world. player_tile_in is in world tiles.
func update_world(texture: Texture2D, world_size: Vector2i, player_tile_in: Vector2) -> void:
	world_texture = texture
	world_tiles = world_size
	player_tile = player_tile_in
	tiles = []
	bushes = []
	shadow = Vector2i(-1, -1)
	queue_redraw()


func _draw() -> void:
	if world_texture != null:
		draw_rect(Rect2(Vector2.ZERO, size), FRAME_COLOR)
		draw_texture_rect(world_texture, Rect2(Vector2.ZERO, size), false)
		var k := size / Vector2(world_tiles)
		_draw_player(player_tile * k)
		_draw_frame()
		return
	var s := PX_PER_TILE
	draw_rect(Rect2(Vector2.ZERO, size), FRAME_COLOR)
	for y in tiles.size():
		var row: Array = tiles[y]
		for x in row.size():
			# Each tile is a shade lighter or darker than its neighbours, so fields and woods read as
			# texture rather than flat blocks.
			var shade := float((x * 7 + y * 13 + (x * y) % 5) % 5) * 0.025 - 0.05
			draw_rect(Rect2(x * s, y * s, s, s), _shaded(tile_colors[row[x]], shade))
	for b in bushes:
		draw_rect(Rect2(b.x * s, b.y * s, s, s), grade(BUSH_COLOR))
	if shadow.x >= 0:
		draw_rect(Rect2(shadow.x * s, shadow.y * s, s, s), SHADOW_COLOR)
	for m in markers:
		var at: Vector2 = m[0] * s
		if icons_tex != null:
			_draw_icon(at, m[1])
		else:
			draw_rect(Rect2(at - Vector2(s, s) * 0.5, Vector2(s, s)), MARKER_COLOR)
	_draw_player(player_tile * s + Vector2(s, s) * 0.5)
	_draw_frame()


func _shaded(c: Color, amount: float) -> Color:
	c = grade(c)
	return c.lightened(amount) if amount > 0.0 else c.darkened(-amount)


# The map's colours pulled toward the game's muted look: part way to grey, then a little darker and cooler,
# so the bright tile colours don't stand out against the dark wood frame.
static func grade(c: Color) -> Color:
	var grey := c.get_luminance()
	var muted := c.lerp(Color(grey, grey, grey), GRADE_GREY).darkened(GRADE_DARK)
	return muted.lerp(GRADE_TINT, 0.08)


# One icon from the strip, centred on a point and snapped to whole pixels so it stays crisp.
func _draw_icon(centre: Vector2, icon: int) -> void:
	var at := (centre - Vector2(ICON, ICON) * 0.5).round()
	draw_texture_rect_region(icons_tex, Rect2(at, Vector2(ICON, ICON)), Rect2(icon * ICON, 0, ICON, ICON))


func _draw_player(at: Vector2) -> void:
	if icons_tex != null:
		_draw_icon(at, Icon.PLAYER)
	else:
		draw_circle(at, 2.5, PLAYER_COLOR)


# The wood-and-iron frame from the UI skin, its rail just outside the map; a thin border without the art.
func _draw_frame() -> void:
	var skin_frame := UiSkin.frame()
	if skin_frame != null:
		draw_style_box(skin_frame, Rect2(Vector2.ZERO, size).grow(FRAME_RAIL))
	else:
		draw_rect(Rect2(Vector2.ZERO, size), BORDER_COLOR, false, 2.0)
