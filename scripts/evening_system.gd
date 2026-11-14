class_name EveningSystem
extends RefCounted

# CCH-EVENING-001: the hours before dark (prototype). Three optional things for the evening, none required:
# - Evening signs: on about 2-3 evenings a week something on the farm is wrong (crows on the field fence, tracks
#   at the field gate, a cold window). Reading one says, imperfectly, what kind of thing may come tonight.
# - Tend the hearth: once an evening, with a good fire going, bank it and ready the house (a firewood and half an
#   hour). Tonight, a visitor at the house takes a little less.
# - An evening by the fire: once an evening, an hour by a lit hearth for a little comfort and sanity.
# Plus the first-week grace: the first knock left unanswered in the first week takes half.
# Every number is here, so the prototype can be tuned in one place. The signs are fixed by the day (no state), and
# the game saves only at dawn, so the evening's own flags never outlive the day; grace_used is the one that must.

const FROM := 19.0              # the evening opens (DUSK_HOUR)
const UNTIL := 22.0             # and ends when the night's visitor comes (EVENT_HOUR)

# --- Evening signs ---
const SIGN_FIRST_DAY := 2       # day 1's night is the scripted first scare
const SIGN_CHANCE := 0.56       # each evening's roll; never two evenings running, so about 0.36 a night (2.5 a week)
const SIGN_TRUE := 0.7          # how often a sign matches the kind of thing most likely to come; otherwise it misleads
const SIGN_KINDS := ["crows", "tracks", "chill"]
# What each visitor's sign would be: the field and the footsteps leave tracks, the house's visitors chill it, and
# the crows and the pond lights quieten the crows. A quiet night's sign is only ever a false one.
const SIGN_FOR := {"field": "tracks", "footsteps": "tracks", "knock": "chill", "watcher": "chill", "hollow": "chill",
	"crows": "crows", "pond": "crows", "sighting": "crows"}
# Where each sign is, in layout tiles (before the border): the field's north fence by the house path, the path into
# the field's west gate, and the wall under the farmhouse's west front window.
const SIGN_TILES := {
	"crows": [Vector2i(52, 18), Vector2i(53, 18), Vector2i(54, 18), Vector2i(55, 18)],
	"tracks": [Vector2i(40, 24), Vector2i(41, 24), Vector2i(42, 24)],
	"chill": [Vector2i(41, 11), Vector2i(42, 11), Vector2i(43, 11)],
}
const NOTICE := {
	"crows": "Crows are gathering along the field fence. None of them is calling.",
	"tracks": "There are marks on the path by the field gate that weren't there this morning.",
	"chill": "Frost is creeping across the farmhouse's front window.",
}

# --- Tend the hearth (the preparation) ---
const PREP_FIRE := 3.0          # hours of fire needed first: one firewood's worth, a fire burning well
const PREP_WOOD := 1            # firewood from the pack, banked into the fire (it burns, so it is not wasted, but
                                # firewood is scarce before the woodshed: 4 at the start, and no chopping log)
const PREP_HOURS := 0.5         # game hours it takes
const PREP_MULT := 0.75         # what a visitor at the house (the knock, the watcher, the Hollow) takes tonight
const PREP_FOR := ["knock", "watcher", "hollow"]

# --- An evening by the fire (the cozy pastime) ---
const COZY_HOURS := 1.0
const COZY_SANITY := 4.0
const COZY_WARMTH := 30.0

# --- First-week grace ---
const GRACE := true
const GRACE_DAYS := 7           # the introductory week
const GRACE_MULT := 0.5         # the first unanswered knock in it takes half
const GRACE_FOR := ["knock"]

var m: MainGame
var sign_read_day := -1         # the evening a sign was read (saved, though the save is always at dawn)
var prep_day := -1              # the evening the hearth was tended
var cozy_day := -1              # the evening spent by the fire
var grace_used := false         # saved: the first-week grace has been spent
var guarded := false            # tonight a tended hearth eased a visitor (for the morning line)
var noticed_day := -1           # the evening the sign's notice was shown
var _has_sign: Dictionary = {}  # day -> sign or not, filled in order (no two running)
var _kind_day := -1
var _kind := ""
var force_kind := ""            # tests and captures: tonight's sign, whatever the day
var ground: Node2D              # the tracks, on the ground under the farmer
var top: Node2D                 # the crows and the frost, over the buildings


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	ground = Node2D.new()
	ground.draw.connect(_draw_ground)
	m.add_child(ground)   # like the forage's layer: over the ground's own sprites
	top = Node2D.new()
	top.z_index = 19
	top.draw.connect(_draw_top)
	m.add_child(top)


func _evening() -> bool:
	return m.current_hour >= FROM and m.current_hour < UNTIL


# --- Signs -----------------------------------------------------------------------------------------

func _base_roll(d: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([d, "evening_sign"])
	return rng.randf() < SIGN_CHANCE


# Whether evening d has a sign: fixed by the day, so a reload can't reroll it, and never two evenings running.
func _sign_day(d: int) -> bool:
	if d < SIGN_FIRST_DAY:
		return false
	if _has_sign.has(d):
		return _has_sign[d]
	var start := d
	while start > SIGN_FIRST_DAY and not _has_sign.has(start - 1):
		start -= 1
	for i in range(start, d + 1):
		var prev: bool = _has_sign.get(i - 1, false)
		_has_sign[i] = _base_roll(i) and not prev
	return _has_sign[d]


# Which sign evening d shows, given the visitor most likely tonight (vid): usually that visitor's kind, sometimes
# another. A quiet night only ever gets a false sign.
func _sign_kind(d: int, vid: String) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([d, "sign_kind"])
	var truth := str(SIGN_FOR.get(vid, ""))
	var roll := rng.randf()
	if truth != "" and roll < SIGN_TRUE:
		return truth
	var others: Array = SIGN_KINDS.filter(func(k: String) -> bool: return k != truth)
	return str(others[rng.randi() % others.size()])


# Tonight's sign, or "" if none. Worked out once an evening from the visitor the night would pick now.
func _tonight() -> String:
	if force_kind != "":
		return force_kind
	if not _sign_day(m.day):
		return ""
	if _kind_day != m.day:
		_kind_day = m.day
		_kind = _sign_kind(m.day, m.nights._preview_id())
	return _kind


# Showing: in the evening, before tonight's visitor comes, and on the farm.
func _showing() -> String:
	if not _evening() or m.event_fired_day == m.day:
		return ""
	return _tonight()


func _tiles(kind: String) -> Array:
	var out: Array = []
	for t in SIGN_TILES.get(kind, []):
		out.append(m._world_tile(t.x, t.y))
	return out


# Called each frame: the sign's notice when the evening opens, and redraws.
func _update() -> void:
	var kind := _showing()
	if kind != "" and noticed_day != m.day and not m.inside and not m.in_cave:
		noticed_day = m.day
		m._show_message(str(NOTICE[kind]) if not (kind == "chill" and m._season_today() == "Winter") else "One window of the farmhouse is frosting over faster than the others.")
	if ground != null and Engine.get_process_frames() % 6 == 0:
		ground.queue_redraw()
		top.queue_redraw()


# Space at a sign: read it, once. Returns true if the press was used.
func _try_read(tile: Vector2i) -> bool:
	var kind := _showing()
	if m.inside or m.in_cave or kind == "" or sign_read_day == m.day or not _tiles(kind).has(tile):
		return false
	sign_read_day = m.day
	if top != null:
		top.queue_redraw()   # the crows go at once
	m.progression._bump("signs_read")
	m.play_sfx("tick")
	m._show_message(_read_text(kind), true)
	return true


func _read_text(kind: String) -> String:
	var season := m._season_today()
	var wet: bool = m.weather_kind in m.WATER_RAIN_KINDS
	match kind:
		"crows":
			return "The crows have gone quiet. Every one of them faces the woods. They lift off together, low over the field, and none of them looks back. Whatever comes tonight, they think it comes for the crops or the water."
		"tracks":
			var ground_word := "snow" if m.weather_kind == "snow" else "earth"
			var rain := " The rain should have filled them by now. It hasn't." if wet else ""
			return "The %s is disturbed at the field gate, as if something stood here a long while. The tracks come in, but they don't lead away.%s Whatever made them is still somewhere on the farm." % [ground_word, rain]
		"chill":
			var pane := "The glass is cold. Colder than the evening air ought to allow." if m.house_stage >= 2 else "The boards over the window are cold. Colder than the evening air ought to allow."
			if season == "Winter":
				pane = "Every pane is frosted tonight, but this one aches to touch, and the frost is thickest on the inside." if m.house_stage >= 2 else "The boards are white with frost tonight, but these ache to touch, and the frost runs in under them."
			return pane + " Whatever comes tonight may come to the house. It will want a good fire."
	return ""


# --- Tend the hearth ---------------------------------------------------------------------------------

func _prep_blocker() -> String:
	if not m.inside:
		return "Tend the hearth from inside the house."
	if not _evening():
		return "The house is readied for the night between 19:00 and 22:00."
	if prep_day == m.day:
		return "The hearth is already tended for tonight."
	if m.fire_hours < PREP_FIRE:
		return "The fire needs to be burning well first (about %d hours of fuel). Feed it." % int(PREP_FIRE)
	if int(m.inventory["firewood"]) < PREP_WOOD:
		return "You need a firewood in your pack to bank the fire."
	return ""


func _tend() -> void:
	var why := _prep_blocker()
	if why != "":
		m._show_message(why)
		return
	m.inventory["firewood"] -= PREP_WOOD
	m.fire_hours = minf(m.FIRE_MAX_HOURS, m.fire_hours + m.FIREWOOD_HOURS * PREP_WOOD)
	prep_day = m.day
	_pass(PREP_HOURS)
	m.progression._bump("hearth_tended")
	m.play_sfx("fire_feed", 0.05)
	m._close_panel()
	m._show_message("You bank the fire with a log, set the guard, draw the curtains and drop the latch. The house is ready for the night, as ready as it can be.")


# Tonight's multiplier for visitor vid: less for a visitor at the house once the hearth is tended.
func _night_mult(vid: String) -> float:
	if prep_day == m.day and vid in PREP_FOR:
		guarded = true
		return PREP_MULT
	return 1.0


# The morning's line about a tended hearth. It says nothing of what it did, only how the night felt.
func _morning_note() -> String:
	var note := ""
	if prep_day == m.day:
		note = " The banked fire held all night, and so did the house." if guarded else " The banked fire burned low and steady through the night."
	guarded = false
	return note


# --- An evening by the fire ------------------------------------------------------------------------

func _cozy_blocker() -> String:
	if not m.inside:
		return "Sit by the hearth inside the house."
	if not _evening():
		return "An evening by the fire is for the evening, 19:00 to 22:00."
	if cozy_day == m.day:
		return "You have already spent this evening by the fire."
	if not m.firewood._fire_lit():
		return "The hearth is cold. Light the fire first."
	return ""


func _sit() -> void:
	var why := _cozy_blocker()
	if why != "":
		m._show_message(why)
		return
	cozy_day = m.day
	_pass(COZY_HOURS)
	m.warmth = minf(100.0, m.warmth + COZY_WARMTH)
	m.sanity_sys._change_sanity(COZY_SANITY)
	m.progression._bump("hearth_evenings")
	m._close_panel()
	var what := "mending by the fire" if m.house_stage < 2 else "reading by the fire"
	m._show_message("You spend an hour %s while the logs settle. For a little while, the house feels like a home. +%d sanity, warmed through." % [what, int(COZY_SANITY)])


# Time passes as if you had stood there for it, as a desk pastime does: needs drop and the fire burns down.
func _pass(hours: float) -> void:
	m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
	m.current_hour += hours
	m._update_needs(hours)


# --- First-week grace ------------------------------------------------------------------------------

# The loss after the grace, for a visitor vid left alone tonight. Spends the grace when it applies.
func _grace(vid: String, loss: float) -> float:
	if not GRACE or grace_used or m.day > GRACE_DAYS or not vid in GRACE_FOR or loss < 1.0:
		return loss
	grace_used = true
	m.progression._bump("grace_spent")
	return loss * GRACE_MULT


# --- Saving ----------------------------------------------------------------------------------------

func _save() -> Dictionary:
	return {"sign_read_day": sign_read_day, "prep_day": prep_day, "cozy_day": cozy_day, "grace_used": grace_used}


func _load(data: Variant) -> void:
	var d: Dictionary = data if data is Dictionary else {}
	sign_read_day = int(d.get("sign_read_day", -1))
	prep_day = int(d.get("prep_day", -1))
	cozy_day = int(d.get("cozy_day", -1))
	# A save from before this was added: past the first week the grace is long gone, and within it the first
	# knock may already have come, so it is taken as spent if a knock has been left alone.
	grace_used = bool(d.get("grace_used", m.day > GRACE_DAYS or int(m.stats.get("left_alone", 0)) > 0 and int(m.nights.seen.get("knock", 0)) > 0))
	guarded = false
	noticed_day = -1
	_kind_day = -1


# --- Drawing ---------------------------------------------------------------------------------------

func _draw_ground() -> void:
	if _showing() != "tracks":
		return
	var px := float(m.PX)
	var ap := m.ART_PX
	var rim := Color(0.66, 0.6, 0.5, 0.6)     # the earth pushed up round each print, pale against the path
	var ink := Color(0.07, 0.05, 0.05, 0.85)
	# Long three-toed prints walking east into the field gate, one stride a tile, and then nothing.
	var tiles := _tiles("tracks")
	for i in tiles.size():
		var c := m._tile_center(tiles[i].x, tiles[i].y)
		for side in [-1, 1]:
			var p: Vector2 = (c + Vector2(px * 0.22 * side, px * 0.2 * side)).snapped(Vector2(ap, ap))
			ground.draw_rect(Rect2(p - Vector2(ap, ap), Vector2(ap * 6, ap * 4)), rim)
			ground.draw_rect(Rect2(p, Vector2(ap * 3, ap * 2)), ink)
			for toe in 3:
				ground.draw_rect(Rect2(p + Vector2(ap * 3, ap * (toe - 1)), Vector2(ap * 2 if toe != 1 else ap * 3, ap)), ink)


func _draw_top() -> void:
	var kind := _showing()
	if kind == "crows" and sign_read_day != m.day:
		var tiles := _tiles("crows")
		for i in tiles.size():
			var c := m._tile_center(tiles[i].x, tiles[i].y)
			m.nights._draw_crow_on(top, c + Vector2(0, -m.PX * 0.45 + (i % 2) * m.ART_PX), 0.9)
	elif kind == "chill":
		_draw_frost()


# A pale rime over the west front window, spreading in from its corners.
func _draw_frost() -> void:
	if m.window_lights.is_empty():
		return
	var ap := m.ART_PX
	var spill := Vector2(0, m.PX * m.WINDOW_SPILL) if m.LIGHTING_V2 else Vector2.ZERO
	var c: Vector2 = (m.window_lights[0] as PointLight2D).position - spill
	var pulse := 0.85 + 0.15 * sin(m.current_hour * 30.0)
	# Bright enough to read through the night's tint, like the visitors' eyes; still only specks of rime.
	var rime := Color(1.25, 1.4, 1.65, 0.75 * pulse)
	for k in 70:
		var h := hash([k, "frost"])
		var x := posmod(h, 17) - 8
		var y := posmod(h >> 8, 15) - 7
		# Thick at the corners and edges, as frost grows, and thin toward the middle of the pane.
		var edge := maxf(absf(x) / 8.0, absf(y) / 7.0)
		if edge < 0.55 or (edge < 0.8 and k % 2 == 0):
			continue
		top.draw_rect(Rect2((c + Vector2(x, y) * ap).snapped(Vector2(ap, ap)), Vector2(ap, ap)), rime)
