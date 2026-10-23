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
var paused := false           # set while any menu is open
var walk_t := 0.0             # advances while walking, drives the stride
var moving := false
var step_timer := 0.0         # seconds walked since the last footstep
signal stepped                # emitted once per footstep, so the game can play a sound

const SKIN := Color("f2c9a0")
const SKIN_SHADE := Color("d9a27c")
const HAIR := Color("5a3a22")
const STRAW := Color("d8b050")
const STRAW_SHADE := Color("9a7a30")
const BAND := Color("7a3a22")
const SHIRT := Color("c8553d")
const SHIRT_SHADE := Color("9a3a2a")
const OVERALLS := Color("3d5a80")
const OVERALLS_SHADE := Color("2a3f5c")
const PANTS := Color("3d5a80")
const BOOTS := Color("3a2418")
const BELT := Color("4a2e1a")
const BUCKLE := Color("e0c060")
const EYE := Color("2a1f16")
const CHEEK := Color(0.9, 0.45, 0.4, 0.45)


func _process(delta: float) -> void:
	if paused:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	moving = dir != Vector2.ZERO
	if moving:
		walk_t += delta * 11.0
		step_timer += delta
		if step_timer >= 0.32:
			step_timer = 0.0
			stepped.emit()
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
	# A walk cycle: the legs and arms swing in opposition, and the body rises and falls with each step.
	var stride := sin(walk_t) if moving else 0.0
	var bob := -absf(stride) * 1.2
	# The shadow stays on the ground while the body bobs above it.
	draw_colored_polygon(_ellipse(Vector2(0, 17), 11.0, 4.0), Color(0, 0, 0, 0.3))
	if facing == Vector2.LEFT or facing == Vector2.RIGHT:
		_draw_side(bob, stride)
	else:
		_draw_front_back(bob)


# The figure seen from the front or the back: both arms and legs, a wide body, and the face or hair.
func _draw_front_back(bob: float) -> void:
	var stride := sin(walk_t) if moving else 0.0
	_draw_leg(Vector2(-4.5, 6.0 + bob), stride * 2.5)
	_draw_leg(Vector2(4.5, 6.0 + bob), -stride * 2.5)
	_draw_arm(Vector2(-11.0, -4.0 + bob), -stride * 2.0)
	_draw_arm(Vector2(11.0, -4.0 + bob), stride * 2.0)
	# Shirt, then overalls over it, with straps and a belt with a buckle.
	draw_rect(Rect2(-8, -8 + bob, 16, 16), SHIRT)
	draw_rect(Rect2(-8, -8 + bob, 16, 2), SHIRT_SHADE)
	draw_rect(Rect2(-5, -4 + bob, 10, 12), OVERALLS)
	draw_rect(Rect2(-5, -4 + bob, 10, 1), OVERALLS_SHADE)
	draw_rect(Rect2(-5, -8 + bob, 2, 5), OVERALLS)
	draw_rect(Rect2(3, -8 + bob, 2, 5), OVERALLS)
	draw_rect(Rect2(-8, 4 + bob, 16, 2), BELT)
	draw_rect(Rect2(-1, 4 + bob, 2, 2), BUCKLE)
	draw_rect(Rect2(-3, -11 + bob, 6, 4), SKIN_SHADE)
	_draw_head(bob)


# The figure seen from the side, facing left or right. The far arm and leg sit behind the body in shade,
# the near ones in front, and the boots point the way the player faces.
func _draw_side(bob: float, stride: float) -> void:
	var side := signf(facing.x)
	# Far leg and arm, drawn first so the body covers them.
	_draw_side_leg(-side * 1.5, 6.0 + bob, -stride * 2.5, OVERALLS_SHADE, side)
	_draw_side_arm(Vector2(-side * 1.0, -4.0 + bob), stride * 2.0, SHIRT_SHADE)
	# Shirt and overalls, narrower in profile.
	draw_rect(Rect2(-5, -8 + bob, 10, 16), SHIRT)
	draw_rect(Rect2(-5, -8 + bob, 10, 2), SHIRT_SHADE)
	draw_rect(Rect2(-4, -4 + bob, 8, 12), OVERALLS)
	draw_rect(Rect2(-4, -4 + bob, 8, 1), OVERALLS_SHADE)
	draw_rect(Rect2(-5, 4 + bob, 10, 2), BELT)
	draw_rect(Rect2(2 if side > 0 else -3, 4 + bob, 2, 2), BUCKLE)
	# Near leg and arm, in front of the body.
	_draw_side_leg(side * 1.5, 6.0 + bob, stride * 2.5, PANTS, side)
	_draw_side_arm(Vector2(side * 2.0, -4.0 + bob), -stride * 2.0, SHIRT)
	_draw_side_head(bob, side)


func _draw_side_leg(x: float, top: float, lift: float, color: Color, side: float) -> void:
	draw_rect(Rect2(x - 2.5, top + lift * 0.3, 5, 9), color)
	# The boot reaches forward, in the direction of travel.
	var boot_x := x - 2.5 if side > 0 else x - 4.5
	draw_rect(Rect2(boot_x, top + 8 + lift * 0.3, 7, 4), BOOTS)


func _draw_side_arm(shoulder: Vector2, swing: float, color: Color) -> void:
	draw_rect(Rect2(shoulder.x - 2, shoulder.y + swing * 0.5, 4, 10), color)
	draw_circle(Vector2(shoulder.x, shoulder.y + 11 + swing * 0.5), 2.4, SKIN)


# The head in profile: the face on the side you're walking toward, hair over the back, and a hat brim that
# sticks out in front.
func _draw_side_head(bob: float, side: float) -> void:
	var c := Vector2(0, -19 + bob)
	draw_circle(c + Vector2(0, 1), 7.5, SKIN)
	# Hair covers the back of the head and runs down behind the ear.
	draw_colored_polygon(_ellipse(c + Vector2(-side * 2.2, -1.0), 6.6, 7.4), HAIR)
	draw_colored_polygon(_ellipse(c + Vector2(-side * 3.6, 2.5), 3.2, 3.6), HAIR)
	draw_circle(c + Vector2(side * 3.5, 0), 1.4, EYE)
	draw_circle(c + Vector2(side * 4.0, 3.0), 1.5, CHEEK)
	# Hat: the brim sticks out further toward the face.
	draw_colored_polygon(_ellipse(c + Vector2(side * 1.5, -6.5), 13.0, 3.5), STRAW)
	draw_colored_polygon(_ellipse(c + Vector2(side * 1.5, -6.5), 13.0, 3.5).slice(8, 16), STRAW_SHADE)
	draw_rect(Rect2(c.x - 6 + side, c.y - 16, 13, 10), STRAW)
	draw_rect(Rect2(c.x - 6 + side, c.y - 9, 13, 2), BAND)


func _draw_leg(hip: Vector2, lift: float) -> void:
	draw_rect(Rect2(hip.x - 2.5, hip.y + lift * 0.3, 5, 9), PANTS)
	draw_rect(Rect2(hip.x - 3.5, hip.y + 8 + lift * 0.3, 7, 4), BOOTS)


func _draw_arm(shoulder: Vector2, swing: float) -> void:
	draw_rect(Rect2(shoulder.x - 2, shoulder.y + swing * 0.5, 4, 10), SHIRT)
	draw_rect(Rect2(shoulder.x - 2, shoulder.y + swing * 0.5 + 8, 4, 2), SHIRT_SHADE)
	draw_circle(Vector2(shoulder.x, shoulder.y + 11 + swing * 0.5), 2.4, SKIN)


# The head: hair behind, the face when you're facing the viewer or to the side, a straw hat with a band on top.
func _draw_head(bob: float) -> void:
	var c := Vector2(0, -19 + bob)
	draw_circle(c + Vector2(0, -1), 9.2, HAIR)
	if facing != Vector2.UP:
		draw_circle(c + Vector2(0, 1), 7.5, SKIN)
		if facing == Vector2.DOWN:
			draw_circle(c + Vector2(-4.5, 3), 1.6, CHEEK)
			draw_circle(c + Vector2(4.5, 3), 1.6, CHEEK)
			draw_circle(c + Vector2(-3, 0), 1.4, EYE)
			draw_circle(c + Vector2(3, 0), 1.4, EYE)
			draw_line(c + Vector2(-1.5, 4.5), c + Vector2(1.5, 4.5), EYE, 1.0)
		elif facing == Vector2.LEFT:
			draw_circle(c + Vector2(-3.5, 0), 1.4, EYE)
		elif facing == Vector2.RIGHT:
			draw_circle(c + Vector2(3.5, 0), 1.4, EYE)
	# Hat: a wide brim, a crown, and a band.
	draw_colored_polygon(_ellipse(c + Vector2(0, -6.5), 13.0, 3.5), STRAW)
	draw_colored_polygon(_ellipse(c + Vector2(0, -6.5), 13.0, 3.5).slice(8, 16), STRAW_SHADE)
	draw_rect(Rect2(c.x - 7, c.y - 16, 14, 10), STRAW)
	draw_rect(Rect2(c.x - 7, c.y - 9, 14, 2), BAND)


func _ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 16:
		var angle := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return pts
