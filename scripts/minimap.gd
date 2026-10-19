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

var tiles: Array = []
var tile_colors: Dictionary = {}
var bushes: Array = []
var player_tile := Vector2.ZERO
var shadow := Vector2i(-1, -1)   # (-1, -1) hides the shadow


func update_view(tiles_in: Array, colors: Dictionary, bushes_in: Array, player_tile_in: Vector2, shadow_in: Vector2i) -> void:
	tiles = tiles_in
	tile_colors = colors
	bushes = bushes_in
	player_tile = player_tile_in
	shadow = shadow_in
	queue_redraw()


func _draw() -> void:
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
	draw_circle(player_tile * s + Vector2(s, s) * 0.5, 2.5, PLAYER_COLOR)
	draw_rect(Rect2(Vector2.ZERO, size), BORDER_COLOR, false, 2.0)
