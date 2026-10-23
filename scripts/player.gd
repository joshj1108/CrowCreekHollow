extends Node2D

## Placeholder player: a simple drawn figure that walks the farm.
## main.gd sets min_pos, max_pos, and is_blocked. Trees, water, the house,
## and brush piles block movement; the player slides along walls.
## The figure holds the selected hotbar tool and plays its action: one-shot actions when the
## player uses a tool, and loops while a chop, mine or fishing channel runs.

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

# What the figure holds, set by main.gd each frame.
var held := ""                # hotbar tool: sword, axe, pick, hoe, trowel, hose, rod, or ""
var held_item := ""           # the gear item in the sword slot (a weapon or bow), or ""
var blocking := false         # a sword raised in guard
var loop_kind := ""           # a looping action from the world: chop, mine, fish, or ""

# A one-shot action, played when the player uses a tool or swings.
var act := ""
var act_t := 0.0
var act_dur := 0.4
var loop_t := 0.0
var loop_prev := 0.0
var act_prev := 0.0

# Small debris: wood chips, sparks, dirt and water drops. Positions are local to the figure.
var particles: Array = []

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
const WOOD := Color("8a6a3a")
const WOOD_DARK := Color("5a3e22")
const IRON := Color("9aa0aa")
const IRON_DARK := Color("5a5f68")
const HOSE := Color("3f6b8a")
const LINE := Color(0.92, 0.92, 0.9, 0.7)
const BOBBER := Color("c9463d")

# Blade colour for each sword-slot weapon.
const BLADE := {
	"sharpened_stick": Color("8a6a3a"),
	"hunting_knife": Color("b8bcc4"),
	"copper_sword": Color("c9824a"),
	"iron_sword": Color("c8ccd6"),
}

# Where in its action each strike lands, as a fraction of the action.
const STRIKE := {"chop": 0.6, "mine": 0.6, "hoe": 0.5, "plant": 0.5}
# How long one cycle of each looping action takes, in seconds.
const LOOP_PERIOD := {"chop": 0.7, "mine": 0.8, "fish": 2.4}


func _process(delta: float) -> void:
	_advance_anim(delta)
	if paused:
		if act != "" or loop_kind != "" or not particles.is_empty():
			queue_redraw()
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


# Starts a one-shot action such as a chop, a swing or a cast. It plays once, then the held pose returns.
func play_act(kind: String, dur: float) -> void:
	act = kind
	act_dur = maxf(dur, 0.05)
	act_t = 0.0
	act_prev = 0.0


# Sets the looping action (chop, mine, fish, or "" for none). Changing it restarts the cycle.
func set_loop(kind: String) -> void:
	if kind != loop_kind:
		loop_kind = kind
		loop_t = 0.0
		loop_prev = 0.0


func _advance_anim(delta: float) -> void:
	if act != "":
		act_t += delta
		var p := clampf(act_t / act_dur, 0.0, 1.0)
		if STRIKE.has(act) and act_prev < float(STRIKE[act]) and p >= float(STRIKE[act]):
			_strike(act)
		if act == "water" and randf() < 0.8:
			_spray()
		act_prev = p
		if act_t >= act_dur:
			act = ""
			act_t = 0.0
	if loop_kind != "":
		loop_t += delta
		var period := float(LOOP_PERIOD[loop_kind])
		var p := fmod(loop_t, period) / period
		if STRIKE.has(loop_kind) and loop_prev < float(STRIKE[loop_kind]) and p >= float(STRIKE[loop_kind]):
			_strike(loop_kind)
		loop_prev = p
	if not particles.is_empty():
		var alive: Array = []
		for pt in particles:
			pt["life"] = float(pt["life"]) - delta
			if float(pt["life"]) > 0.0:
				pt["p"] = (pt["p"] as Vector2) + (pt["v"] as Vector2) * delta
				pt["v"] = (pt["v"] as Vector2) + Vector2(0, 320.0) * delta
				alive.append(pt)
		particles = alive


# Debris thrown off where the tool strikes: chips from wood, sparks from stone, dirt from the soil.
func _strike(kind: String) -> void:
	var hand := _hand_pos()
	var col_a := Color("b07a48")
	var col_b := Color("e0b070")
	var n := 6
	match kind:
		"mine":
			col_a = Color("ffd27a")
			col_b = Color("fff6d0")
			n = 7
		"hoe", "plant":
			col_a = Color("6b4a2e")
			col_b = Color("8a6a3e")
			n = 5 if kind == "hoe" else 3
	for i in n:
		particles.append({
			"p": hand + Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0)),
			"v": Vector2(randf_range(-70.0, 70.0), randf_range(-120.0, -30.0)),
			"life": randf_range(0.3, 0.5),
			"col": col_a if i % 2 == 0 else col_b,
			"size": randf_range(1.5, 2.5),
		})


# Water drops from the hose nozzle while watering.
func _spray() -> void:
	var nozzle := _hand_pos()
	var side_view := facing.x != 0.0
	var v := Vector2(facing.x * 80.0, randf_range(10.0, 50.0)) if side_view else Vector2(randf_range(-12.0, 12.0), randf_range(40.0, 70.0))
	particles.append({
		"p": nozzle + (Vector2(facing.x * 4.0, 2.0) if side_view else Vector2(0, 6.0)),
		"v": v,
		"life": randf_range(0.25, 0.4),
		"col": Color("8fc4e8"),
		"size": 1.5,
	})


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
	var bob := _bob()
	# The shadow stays on the ground while the body bobs above it.
	draw_colored_polygon(_ellipse(Vector2(0, 17), 11.0, 4.0), Color(0, 0, 0, 0.3))
	if facing == Vector2.LEFT or facing == Vector2.RIGHT:
		_draw_side(bob, stride)
	else:
		_draw_front_back(bob)
	for pt in particles:
		var s := float(pt["size"])
		draw_rect(Rect2((pt["p"] as Vector2) - Vector2(s, s) * 0.5, Vector2(s, s)), pt["col"])


# The figure seen from the front or the back: both arms and legs, a wide body, and the face or hair.
# The arm on the working side is drawn last, so the held tool shows over the body.
func _draw_front_back(bob: float) -> void:
	var stride := sin(walk_t) if moving else 0.0
	_draw_leg(Vector2(-4.5, 6.0 + bob), stride * 2.5)
	_draw_leg(Vector2(4.5, 6.0 + bob), -stride * 2.5)
	_draw_arm(Vector2(-11.0, -4.0 + bob), -stride * 2.0)
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
	_draw_working_arm(bob, false)


# The figure seen from the side, facing left or right. The far arm and leg sit behind the body in shade,
# the near leg in front, and the boots point the way the player faces.
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
	# Near leg, in front of the body.
	_draw_side_leg(side * 1.5, 6.0 + bob, stride * 2.5, PANTS, side)
	_draw_side_head(bob, side)
	_draw_working_arm(bob, true)


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


# --- The working arm and the held tool --------------------------------------

# The vertical bob of the body: the walk bounce, plus the crouch while planting.
func _bob() -> float:
	var stride := sin(walk_t) if moving else 0.0
	return -absf(stride) * 1.2 + _crouch()


func _crouch() -> float:
	if act == "plant":
		return 3.0 * sin(PI * clampf(act_t / act_dur, 0.0, 1.0))
	return 0.0


# The working arm's shoulder, in local coordinates.
func _shoulder(bob: float, side_view: bool) -> Vector2:
	if side_view:
		return Vector2(signf(facing.x) * 2.0, -4.0 + bob)
	return Vector2(11.0, -4.0 + bob)


# Where the hand sits relative to the shoulder for the arm angle a (0 = straight down, positive = forward).
func _hand_offset(a: float, side_view: bool) -> Vector2:
	if side_view:
		return Vector2(signf(facing.x) * sin(a) * 11.0, cos(a) * 11.0)
	return Vector2(sin(a) * 2.5, cos(a) * 11.0)


func _hand_pos() -> Vector2:
	var side_view := facing.x != 0.0
	return _shoulder(_bob(), side_view) + _hand_offset(_arm_angle(), side_view)


# Which action the figure is doing right now: a one-shot, a loop, a raised guard, or idle.
func _kind() -> String:
	if act != "":
		return act
	if loop_kind != "":
		return loop_kind
	if blocking and held == "sword":
		return "block"
	return "idle"


# Phase of the current action (x, 0 to 1 across one cycle) and the seconds into it (y).
func _phase() -> Vector2:
	if act != "":
		return Vector2(clampf(act_t / act_dur, 0.0, 1.0), act_t)
	if loop_kind != "":
		var period := float(LOOP_PERIOD[loop_kind])
		return Vector2(fmod(loop_t, period) / period, loop_t)
	return Vector2(0.0, walk_t)


func _ease(x: float) -> float:
	var c := clampf(x, 0.0, 1.0)
	return c * c * (3.0 - 2.0 * c)


# The arm angle for the current action. 0 is straight down, PI/2 forward, PI overhead.
func _arm_angle() -> float:
	var k := _kind()
	var ph := _phase()
	var p := ph.x
	var t := ph.y
	match k:
		"swing":
			return lerpf(-2.1, 1.5, _ease(p))
		"chop", "mine":
			var st := float(STRIKE[k])
			if p < st:
				return lerpf(0.1, 2.9, _ease(p / st))
			return lerpf(2.9, 0.25, _ease((p - st) / (1.0 - st)))
		"hoe":
			if p < 0.5:
				return lerpf(0.35, -1.5, _ease(p / 0.5))
			return lerpf(-1.5, 1.0, _ease((p - 0.5) / 0.5))
		"plant":
			return 0.6
		"water":
			return 1.2 + 0.06 * sin(t * 26.0)
		"cast":
			if p < 0.4:
				return lerpf(0.5, -1.4, _ease(p / 0.4))
			return lerpf(-1.4, 1.2, _ease((p - 0.4) / 0.6))
		"fish":
			return 1.0 + 0.05 * sin(t * 3.0)
		"fire":
			return 1.45
		"block":
			return 1.9
	return 0.25 + (sin(walk_t) * 0.2 if moving else 0.0)


# The tool's own angle. A raised sword points up and forward; everything else follows the arm.
func _tool_angle() -> float:
	if _kind() == "block":
		return 2.5
	return _arm_angle()


func _tool_dir(t: float, side_view: bool) -> Vector2:
	if side_view:
		return Vector2(signf(facing.x) * sin(t), cos(t))
	return Vector2(sin(t) * 0.3, cos(t)).normalized()


# The arm on the working side, then the tool in the hand.
func _draw_working_arm(bob: float, side_view: bool) -> void:
	var shoulder := _shoulder(bob, side_view)
	var hand := shoulder + _hand_offset(_arm_angle(), side_view)
	draw_line(shoulder, hand, SHIRT, 4.0)
	draw_circle(hand, 2.4, SKIN)
	_draw_tool(hand, side_view)


func _draw_tool(hand: Vector2, side_view: bool) -> void:
	if held == "":
		return
	var dir := _tool_dir(_tool_angle(), side_view)
	var perp := Vector2(-dir.y, dir.x)
	match held:
		"sword":
			_draw_blade(hand, dir, perp)
		"axe":
			_draw_stick(hand, dir, 15.0)
			var tip := hand + dir * 15.0
			draw_colored_polygon(PackedVector2Array([tip - dir * 3.0 + perp * 4.0, tip + dir * 2.0 + perp * 1.0, tip + dir * 2.0 - perp * 1.0, tip - dir * 3.0 - perp * 4.0]), IRON)
			draw_line(tip - dir * 3.0 + perp * 4.0, tip + dir * 2.0 + perp * 1.0, IRON_DARK, 1.0)
		"pick":
			_draw_stick(hand, dir, 15.0)
			var tip := hand + dir * 15.0
			draw_line(tip - perp * 6.0, tip + perp * 6.0, IRON, 2.2)
			draw_circle(tip, 1.3, IRON_DARK)
		"hoe":
			_draw_stick(hand, dir, 18.0)
			var tip := hand + dir * 18.0
			draw_colored_polygon(PackedVector2Array([tip - perp * 5.0, tip + perp * 5.0, tip + perp * 5.0 + dir * 4.0, tip - perp * 5.0 + dir * 4.0]), IRON)
		"trowel":
			_draw_stick(hand, dir, 5.0)
			var tip := hand + dir * 5.0
			draw_colored_polygon(PackedVector2Array([tip, tip + perp * 2.5 + dir * 4.0, tip + dir * 6.0, tip - perp * 2.5 + dir * 4.0]), IRON)
		"hose":
			draw_arc(hand, 4.0, 0.0, TAU, 12, HOSE, 2.0)
			draw_line(hand + Vector2(0, 4.0), hand + Vector2(-signf(facing.x) * 3.0 if side_view else 0.0, 12.0), HOSE, 1.5)
		"rod":
			_draw_stick(hand, dir, 26.0)
			draw_circle(hand, 2.0, IRON_DARK)
			if loop_kind == "fish" or act == "cast":
				var end := hand + dir * 26.0 + Vector2(0, 16.0)
				draw_line(hand + dir * 26.0, end, LINE, 0.6)
				draw_circle(end, 1.6, BOBBER)


func _draw_stick(hand: Vector2, dir: Vector2, length: float) -> void:
	draw_line(hand, hand + dir * length, WOOD, 2.2)
	draw_line(hand, hand + dir * length * 0.5, WOOD_DARK, 0.6)


# The sword slot: the weapon in the main hand, or a bow or crossbow when it is a ranged weapon.
func _draw_blade(hand: Vector2, dir: Vector2, perp: Vector2) -> void:
	if held_item == "":
		return
	if held_item == "crossbow":
		draw_line(hand, hand + dir * 12.0, WOOD, 2.2)
		draw_line(hand + dir * 10.0 - perp * 6.0, hand + dir * 10.0 + perp * 6.0, WOOD_DARK, 2.0)
		return
	if held_item.find("bow") != -1:
		var center := hand + dir * 5.0
		var ang := dir.angle()
		draw_arc(center, 9.0, ang - 1.1, ang + 1.1, 8, WOOD, 2.0)
		draw_line(center + Vector2.from_angle(ang - 1.1) * 9.0, center + Vector2.from_angle(ang + 1.1) * 9.0, LINE, 0.6)
		return
	var steel: Color = BLADE.get(held_item, Color("b8c0c8"))
	var base := hand + dir * 2.0
	draw_line(hand, base, WOOD_DARK, 2.4)
	if held_item == "sharpened_stick":
		draw_line(base, base + dir * 14.0, steel, 2.0)
		return
	var length := 8.0 if held_item == "hunting_knife" else 15.0
	var tip := base + dir * length
	draw_colored_polygon(PackedVector2Array([base + perp * 1.6, tip, base - perp * 1.6]), steel)
	draw_line(base - perp * 3.5, base + perp * 3.5, IRON_DARK, 1.6)


func _ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 16:
		var angle := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return pts
