class_name Minimap
extends Control

## Small overview of the whole map: terrain, house, brush piles, the player,
## and the shadow on event nights. main.gd pushes the current state each frame.

const PX_PER_TILE := 3.0
const FRAME_COLOR := Color("1d1611")
const BORDER_COLOR := Color("8a6a3a")
const BUSH_COLOR := Color("3d6b2a")
const SHADOW_COLOR := Color("b02a2a")
const PLAYER_COLOR := Color("fff2b0")
const MARKER_COLOR := Color("6fb8d9")   # landmarks such as the well

var tiles: Array = []
var tile_colors: Dictionary = {}
var bushes: Array = []
var player_tile := Vector2.ZERO
var shadow := Vector2i(-1, -1)   # (-1, -1) hides the shadow
var world_texture: Texture2D = null   # the whole land, one pixel per WORLD_PX_PER_TILE tiles
var world_tiles := Vector2i.ZERO
var markers: Array = []   # landmark tiles, drawn as small blue squares on the farm map

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
		draw_circle(player_tile * k, 3.0, PLAYER_COLOR)
		draw_rect(Rect2(Vector2.ZERO, size), BORDER_COLOR, false, 2.0)
		return
	var s := PX_PER_TILE
	draw_rect(Rect2(Vector2.ZERO, size), FRAME_COLOR)
	for y in tiles.size():
		var row: Array = tiles[y]
		for x in row.size():
			draw_rect(Rect2(x * s, y * s, s, s), tile_colors[row[x]])
	for b in bushes:
		draw_rect(Rect2(b.x * s, b.y * s, s, s), BUSH_COLOR)
	if shadow.x >= 0:
		draw_rect(Rect2(shadow.x * s, shadow.y * s, s, s), SHADOW_COLOR)
	for m in markers:
		draw_rect(Rect2(m.x * s, m.y * s, s, s), MARKER_COLOR)
	draw_circle(player_tile * s + Vector2(s, s) * 0.5, 2.5, PLAYER_COLOR)
	draw_rect(Rect2(Vector2.ZERO, size), BORDER_COLOR, false, 2.0)
