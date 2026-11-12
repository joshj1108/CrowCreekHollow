class_name CaveFoeArt
extends RefCounted

# CCH-CONSOLIDATED-003 Phase E: the cave creatures' PixelLab sprites (art/farm/cave_foes/<kind>_<state>.png, built by
# tools/cch003_creatures.py). Each sheet is a strip of CELL x CELL frames facing right; the lizard and snake mirror
# to face left, the bat faces the viewer (as before). Everything here is display only: which state shows is read
# from the foe's own fields (moving, flash) and three display timers set by the combat code (alert_t when a foe
# first notices you, atk_t when its contact attack fires, and the dying list after a kill). Nothing here changes a
# foe's speed, aggro, attack timing, damage, position or drops.

const KINDS := ["bat", "lizard", "snake"]
const STATES := ["idle", "move", "alert", "attack", "hurt", "death"]
const CELL := 32
const FEET := 30           # the row a standing creature's lowest pixel sits on in every cell
const LOOP_FPS := {"idle": 5.0, "move": 10.0}
const ALERT_T := 0.45      # seconds the alert pose shows after a foe notices you (it already calls out then)
const ATTACK_T := 0.4      # seconds the strike shows; it starts on the frame the blow lands (0.9 s is the shortest cooldown)
const HURT_T := 0.2        # the hit flash's length in main.gd's _swing: the flinch plays inside it
const DEATH_T := 0.6       # the fall plays over this, then the body lies still and fades
const FADE_T := 0.5

# Frames per sheet, filled in by tools/cch003_creatures.py.
const FRAMES := {
	"bat": {"idle": 4, "move": 6, "alert": 4, "attack": 6, "hurt": 4, "death": 6},
	"lizard": {"idle": 4, "move": 6, "alert": 4, "attack": 6, "hurt": 4, "death": 6},
	"snake": {"idle": 4, "move": 6, "alert": 4, "attack": 6, "hurt": 4, "death": 6},
}


# Review only (tools/capture.gd oldfoes): false draws the old SpriteCook sheets through the old code, for BEFORE shots.
static var enabled := true


static func has_art(kind: String) -> bool:
	return enabled and KINDS.has(kind) and FarmSprites.has("cave_foes/%s_idle" % kind)


# The state and frame a live foe shows now. Precedence: hurt (the hit flash), attack, alert, move, idle.
static func pick(foe: Dictionary, now: float) -> Array:
	var kind := str(foe["kind"])
	var flash := float(foe.get("flash", 0.0))
	if flash > 0.0:
		return ["hurt", _one_shot(kind, "hurt", 1.0 - flash / HURT_T)]
	var atk := float(foe.get("atk_t", 0.0))
	if atk > 0.0:
		return ["attack", _one_shot(kind, "attack", 1.0 - atk / ATTACK_T)]
	var alert := float(foe.get("alert_t", 0.0))
	if alert > 0.0:
		return ["alert", _one_shot(kind, "alert", 1.0 - alert / ALERT_T)]
	# A bat is always on the wing: it hovers when it isn't going anywhere.
	var state := "move" if bool(foe.get("moving", false)) else "idle"
	var n: int = FRAMES[kind][state]
	# Each foe is offset by its position so a group doesn't step in time.
	var f := (int(now * float(LOOP_FPS[state])) + int(absf(float(foe["home"].x)) / 7.0)) % n
	return [state, f]


static func _one_shot(kind: String, state: String, t: float) -> int:
	var n: int = FRAMES[kind][state]
	return clampi(int(clampf(t, 0.0, 0.999) * n), 0, n - 1)


# Whether a kind turns to face left (the bat faces the viewer and never flips, as its old sheet didn't).
static func flips(kind: String) -> bool:
	return kind != "bat"


# Draws one creature frame standing on pos (the foe's position), in the canvas item ci.
static func draw(ci: CanvasItem, kind: String, state: String, frame: int, pos: Vector2, face_left: bool, tint: Color) -> void:
	var tex := FarmSprites.tex("cave_foes/%s_%s" % [kind, state])
	if tex == null:
		return
	var s := float(MainGame.SCALE)
	var size := Vector2(CELL, CELL) * s
	# Row FEET sits where the old 20 px sheets' bottom row sat: 0.3 tiles below the foe's position.
	var top_left := pos - Vector2(size.x * 0.5, (FEET + 1) * s - MainGame.PX * 0.3)
	if face_left and flips(kind):
		ci.draw_set_transform(Vector2(pos.x * 2.0, 0.0), 0.0, Vector2(-1, 1))
	ci.draw_texture_rect_region(tex, Rect2(top_left, size), Rect2(frame * CELL, 0, CELL, CELL), tint)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# A body after a kill: the fall, then it lies still and fades (combat_system.gd drops it after DEATH_T + FADE_T).
static func draw_dying(ci: CanvasItem, d: Dictionary) -> void:
	var kind := str(d["kind"])
	var t := float(d["t"])
	var f := _one_shot(kind, "death", t / DEATH_T)
	var a := 1.0 - clampf((t - DEATH_T) / FADE_T, 0.0, 1.0)
	draw(ci, kind, "death", f, d["pos"], float(d.get("face", 1.0)) < 0.0, Color(1, 1, 1, a))
