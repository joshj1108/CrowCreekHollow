extends Node2D

## Placeholder player: a simple drawn figure that walks the farm.

const SPEED := 180.0

var bounds := Vector2.INF


func _process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += dir * SPEED * delta
	position = position.clamp(Vector2.ZERO, bounds)
	queue_redraw()


func _draw() -> void:
	# Body and head, roughly 8×12 pixels at 3× scale.
	draw_rect(Rect2(-12, -12, 24, 30), Color("d9785a"))
	draw_circle(Vector2(0, -22), 10, Color("f2c9a0"))
