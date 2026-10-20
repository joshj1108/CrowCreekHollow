extends Node2D

## Placeholder player: a simple drawn figure that walks the farm.
## main.gd sets min_pos, max_pos, and is_blocked. Trees, water, the house,
## and brush piles block movement; the player slides along walls.

const SPEED := 180.0
const FEET_OFFSET := Vector2(0, 8)
const CORNERS := [
	Vector2(-8, -6), Vector2(8, -6),
	Vector2(-8, 6), Vector2(8, 6),
]

var min_pos := Vector2.ZERO
var max_pos := Vector2.INF
var facing := Vector2.DOWN   # last cardinal direction moved; used for interaction
var is_blocked := Callable()  # Callable(Vector2 world_pos) -> bool
var paused := false           # set while the Settings menu is open


func _process(delta: float) -> void:
	if paused:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		if absf(dir.x) > absf(dir.y):
			facing = Vector2(signf(dir.x), 0)
		else:
			facing = Vector2(0, signf(dir.y))
	var step := dir * SPEED * delta
	_try_move(Vector2(step.x, 0))
	_try_move(Vector2(0, step.y))
	position = position.clamp(min_pos, max_pos)
	queue_redraw()


func _try_move(step: Vector2) -> void:
	if step == Vector2.ZERO:
		return
	var target := position + step
	if _is_free(target):
		position = target


func _is_free(p: Vector2) -> bool:
	if not is_blocked.is_valid():
		return true
	var feet := p + FEET_OFFSET
	for corner in CORNERS:
		if is_blocked.call(feet + corner):
			return false
	return true


func _draw() -> void:
	# Body and head, roughly 8×12 pixels at 3× scale.
	draw_rect(Rect2(-12, -12, 24, 30), Color("d9785a"))
	draw_circle(Vector2(0, -22), 10, Color("f2c9a0"))
	# Small dot showing the direction the player faces.
	draw_circle(facing * 18, 4, Color("fff2b0"))
