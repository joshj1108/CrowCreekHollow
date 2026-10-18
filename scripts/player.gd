extends Node2D

## Placeholder player: a simple drawn figure that walks the farm.
## main.gd sets min_pos and max_pos to keep the player on walkable land.

const SPEED := 180.0

var min_pos := Vector2.ZERO
var max_pos := Vector2.INF
var facing := Vector2.DOWN   # last cardinal direction moved; used for interaction


func _process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		if absf(dir.x) > absf(dir.y):
			facing = Vector2(signf(dir.x), 0)
		else:
			facing = Vector2(0, signf(dir.y))
	position += dir * SPEED * delta
	position = position.clamp(min_pos, max_pos)
	queue_redraw()


func _draw() -> void:
	# Body and head, roughly 8×12 pixels at 3× scale.
	draw_rect(Rect2(-12, -12, 24, 30), Color("d9785a"))
	draw_circle(Vector2(0, -22), 10, Color("f2c9a0"))
	# Small dot showing the direction the player faces.
	draw_circle(facing * 18, 4, Color("fff2b0"))
