class_name EveningSystem
extends RefCounted

# CCH-EVENING-001: the hours before dark (prototype). Three optional things for the evening, none required:
# - Evening signs: on about 2-3 evenings a week something on the farm is wrong (crows on the field fence, tracks
#   at the field gate, a cold window). Reading one says, imperfectly, what kind of thing may come tonight.
# - Tend the hearth: once an evening, with a good fire going, bank it and ready the house (a firewood and half an
#   hour). Tonight, a visitor at the house takes a little less.
# - An evening by the fire: once an evening, an hour by a lit hearth for a little comfort and sanity.
# Plus the first-week grace: the first knock left unanswered in the first week takes half.
# CCH-EVENING-002 adds:
# - The farmhouse as shelter: a visitor left unanswered while you are inside the house takes less as the house is
#   restored (SHELTER_STAGE). It is folded into one shelter calculation with the barred shutters, the second storey
#   and the tended hearth, floored at SHELTER_FLOOR so no house is ever safe (_shelter).
# - A quiet hour: an hour at the desk in the evening, reading or writing, with no fire needed. It shares the
#   evening's one rest with the evening by the fire (cozy_day).
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
# The line shown once when you first face an unread sign.
const LOOK := {
	"crows": "The crows on the fence haven't moved.",
	"tracks": "Something has churned up the ground here.",
	"chill": "The frost is spreading onto the boards.",
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

# --- A quiet hour (CCH-EVENING-002: the evening's rest without firewood) ---
const QUIET_HOURS := 1.0
const QUIET_SANITY := 4.0       # the same as the fire: the fire's edge is its comfort, not its sanity
const QUIET_WARMTH := 15.0
# The evening's rest is one a night: by the fire or a quiet hour, not both (cozy_day). The desk's daily game
# (+3 the first a day, HomesteadRewards) is untouched, so an evening's most is still the +7 of CCH-EVENING-001.

# --- The farmhouse as shelter (CCH-EVENING-002; prototype values) ---
# What a visitor left unanswered takes while you are inside the farmhouse, by its restoration stage:
# Decrepit, Boarded, Patched, Restored. The stage is the house's own (MainGame.house_stage); nothing else is saved.
const SHELTER_STAGE := [1.0, 0.75, 0.6, 0.45]
# The visitors the house shelters you from. Not the footsteps (they catch you outside), the first night or the
# sighting (scripted), nor the story act's Hollow (NightSystem passes those as not sheltered).
const SHELTER_FOR := ["field", "knock", "quiet", "crows", "pond", "watcher", "hollow"]
# The shelter group: house stage x barred shutters (the knock) x second storey x tended hearth (the house's
# visitors), never below this share of what the night would otherwise take. The first-week grace comes after it.
const SHELTER_FLOOR := 0.4

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
var sheltered := false          # tonight the house itself eased a visitor left alone (for the morning line)
var shelter_stage: Array = SHELTER_STAGE.duplicate()   # balance probes may override it (tools/balance_sim.gd)
var cozy_kind := ""             # tonight's rest: "fire" or "quiet" (not saved; the save is at dawn)
var hinted_day := -1            # the evening the "look closer" line was shown at a sign
var fly_s := -1.0               # seconds since the crows were read (frame time), for their flight off the fence
var _halo: Texture2D            # the perched crow's silhouette, for its moonlit edge
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
	if fly_s >= 0.0 and fly_s < 10.0:
		fly_s += m.get_process_delta_time()   # frame time, so the flight keeps its length in a slow frame or a recording
	var kind := _showing()
	if kind != "" and noticed_day != m.day and not m.inside and not m.in_cave:
		noticed_day = m.day
		m._show_message(str(NOTICE[kind]) if not (kind == "chill" and m._season_today() == "Winter") else "One window of the farmhouse is frosting over faster than the others.")
	# Facing an unread sign: one quiet line, once an evening, so an attentive player knows it can be looked at.
	if kind != "" and hinted_day != m.day and sign_read_day != m.day and not m.inside and not m.in_cave and m.player != null:
		if _tiles(kind).has(m._player_tile() + Vector2i(m.player.facing)):
			hinted_day = m.day
			m._show_message(str(LOOK[kind]) + " {hand} to look closer.")
	if ground != null and (Engine.get_process_frames() % 6 == 0 or _flying()):
		ground.queue_redraw()
		top.queue_redraw()


# Space at a sign: read it, once. Returns true if the press was used.
func _try_read(tile: Vector2i) -> bool:
	var kind := _showing()
	if m.inside or m.in_cave or kind == "" or sign_read_day == m.day or not _tiles(kind).has(tile):
		return false
	sign_read_day = m.day
	fly_s = 0.0   # the crows lift off the fence (_draw_top)
	if top != null:
		top.queue_redraw()
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
	if sheltered:
		note += [" The boarded walls kept the worst of the night outside.", " The patched walls held most of the night at bay.", " The house held. Whatever came, most of it stayed outside."][clampi(m.house_stage, 1, 3) - 1]
	sheltered = false
	return note


# --- An evening by the fire ------------------------------------------------------------------------

func _cozy_blocker() -> String:
	if not m.inside:
		return "Sit by the hearth inside the house."
	if not _evening():
		return "An evening by the fire is for the evening, 19:00 to 22:00."
	if cozy_day == m.day:
		return _rested_text()
	if not m.firewood._fire_lit():
		return "The hearth is cold. Light the fire first, or spend a quiet hour at the desk."
	return ""


func _rested_text() -> String:
	return "You have already spent this evening by the fire." if cozy_kind != "quiet" else "You have already had your quiet hour this evening."


func _sit() -> void:
	var why := _cozy_blocker()
	if why != "":
		m._show_message(why)
		return
	cozy_day = m.day
	cozy_kind = "fire"
	_pass(COZY_HOURS)
	m.warmth = minf(100.0, m.warmth + COZY_WARMTH)
	m.sanity_sys._change_sanity(COZY_SANITY)
	m.progression._bump("hearth_evenings")
	m._close_panel()
	var what := "mending by the fire" if m.house_stage < 2 else "reading by the fire"
	m._show_message("You spend an hour %s while the logs settle. For a little while, the house feels like a home. +%d sanity, warmed through." % [what, int(COZY_SANITY)])
	m._rest_scene("The logs settle. An hour goes by.")


# --- A quiet hour ----------------------------------------------------------------------------------

func _quiet_blocker() -> String:
	if not m.inside:
		return "A quiet hour is spent at the desk, inside the house."
	if not _evening():
		return "A quiet hour is for the evening, 19:00 to 22:00."
	if cozy_day == m.day:
		return _rested_text()
	return ""


func _quiet() -> void:
	var why := _quiet_blocker()
	if why != "":
		m._show_message(why)
		return
	cozy_day = m.day
	cozy_kind = "quiet"
	_pass(QUIET_HOURS)
	m.warmth = minf(100.0, m.warmth + QUIET_WARMTH)
	m.sanity_sys._change_sanity(QUIET_SANITY)
	m.progression._bump("quiet_hours")
	m._close_panel()
	var what := "writing in the diary by candlelight" if m.house_stage < 2 else "reading at the desk"
	var room := " The boards creak as the house settles." if m.house_stage < 2 else " The house is quiet around you."
	m._show_message("You spend a quiet hour %s.%s +%d sanity." % [what, room, int(QUIET_SANITY)])
	m._rest_scene("The candle burns down a little. An hour goes by.")


# --- The farmhouse as shelter ----------------------------------------------------------------------

# The house stage's own multiplier for visitor vid: only for a visitor left unanswered, only while you are inside.
func _house_mult(vid: String, unattended: bool) -> float:
	if not unattended or not m.inside or m.in_cave or not vid in SHELTER_FOR:
		return 1.0
	return float(shelter_stage[clampi(m.house_stage, 0, shelter_stage.size() - 1)])


# The one shelter calculation (NightSystem._loss_mult): the house stage, then the barred shutters, the second
# storey and the tended hearth, never below SHELTER_FLOOR. unattended: the visitor is being left alone (resolved
# unanswered); a confrontation's strikes pass false and get only the shutters, storey and hearth, as before.
func _shelter(vid: String, unattended: bool) -> float:
	var mult := _house_mult(vid, unattended)
	if vid == "knock" and m.projects._shutters_barred():
		mult *= m.projects.SHUTTER_KNOCK
	mult *= m.estate._night_mult()
	mult *= _night_mult(vid)
	return maxf(mult, SHELTER_FLOOR)


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
	sheltered = false
	cozy_kind = ""
	noticed_day = -1
	hinted_day = -1
	_kind_day = -1


# --- Drawing ---------------------------------------------------------------------------------------
# CCH-EVENING-002 made the three signs easier to read at play distance, still drawn only with the farm's own
# sprites and art-pixel rects: the crows get a thin moonlit edge and fly off when read, the tracks are deeper
# with turned earth round them and a churned patch at the gate, and the frost creeps off the pane onto the boards.

const CROW_FLIGHT_MS := 1700    # the crows' flight off the fence, from the first to lift to the last gone
const CROW_STAGGER_MS := 140    # between one crow lifting and the next


func _flying() -> bool:
	return fly_s >= 0.0 and sign_read_day == m.day and fly_s * 1000.0 < CROW_FLIGHT_MS + CROW_STAGGER_MS * 4


func _draw_ground() -> void:
	if _showing() != "tracks":
		return
	var px := float(m.PX)
	var ap := m.ART_PX
	var wet: bool = m.weather_kind in m.WATER_RAIN_KINDS
	# The earth pushed up round each print, pale and dry (the rain hasn't touched it), and the print itself dark
	# and deep. Clods thrown out to the side show something heavy pushed off here.
	# As the night's tint deepens the rims are drawn brighter (past 1.0, as the frost and the visitors' eyes are), so
	# they still read as pale earth after dark; the tint keeps them dim, so they never glow.
	var lift := lerpf(1.0, 1.7, smoothstep(m.DUSK_HOUR, m.DUSK_HOUR + 2.0, m.current_hour))
	var rim := Color(0.86 * lift, 0.76 * lift, 0.6 * lift, 0.85 if wet else 0.7)
	var ink := Color(0.04, 0.03, 0.025, 0.95)
	var clod := Color(0.2, 0.14, 0.09, 0.9)
	var tiles := _tiles("tracks")
	for i in tiles.size():
		var c := m._tile_center(tiles[i].x, tiles[i].y)
		for side in [-1, 1]:
			var p: Vector2 = (c + Vector2(px * 0.22 * side, px * 0.2 * side)).snapped(Vector2(ap, ap))
			ground.draw_rect(Rect2(p - Vector2(ap * 2, ap * 2), Vector2(ap * 8, ap * 6)), Color(rim, rim.a * 0.45))
			ground.draw_rect(Rect2(p - Vector2(ap, ap), Vector2(ap * 7, ap * 4)), rim)
			ground.draw_rect(Rect2(p, Vector2(ap * 4, ap * 2)), ink)
			for toe in 3:
				var long := 4 if toe == 1 else 3
				ground.draw_rect(Rect2(p + Vector2(ap * 4, ap * (toe - 1) * 1.5), Vector2(ap * long, ap)), ink)
			for k in 3:
				var h := hash([i, side, k, "clod"])
				ground.draw_rect(Rect2(p + Vector2(posmod(h, 9) - 2, (posmod(h >> 6, 2) * 2 - 1) * (3 + posmod(h >> 9, 2))) * ap, Vector2(ap, ap)), clod)
	# Where they end, at the gate: a patch of churned earth, as if something stood here a long while.
	var end := m._tile_center(tiles[-1].x, tiles[-1].y) + Vector2(px * 0.75, 0)
	for k in 14:
		var h := hash([k, "churn"])
		var o := Vector2(posmod(h, 11) - 5, posmod(h >> 5, 9) - 4) * ap
		var w := ap * (2 + posmod(h >> 10, 3))
		ground.draw_rect(Rect2((end + o).snapped(Vector2(ap, ap)) - Vector2(ap, 0), Vector2(w + ap * 2, ap * 2)), Color(rim, rim.a * 0.6))
		ground.draw_rect(Rect2((end + o).snapped(Vector2(ap, ap)), Vector2(w, ap)), ink)


func _draw_top() -> void:
	var kind := _showing()
	if kind == "crows":
		var tiles := _tiles("crows")
		var since := int(fly_s * 1000.0) if sign_read_day == m.day and fly_s >= 0.0 else -1
		if sign_read_day == m.day and not _flying():
			return   # flown
		for i in tiles.size():
			var c := m._tile_center(tiles[i].x, tiles[i].y)
			var foot := c + Vector2(0, -m.PX * 0.45 + (i % 2) * m.ART_PX)
			var t := -1.0 if since < 0 else float(since - i * CROW_STAGGER_MS) / float(CROW_FLIGHT_MS)
			if t <= 0.0:
				_draw_perched(foot)
			elif t < 1.0:
				_draw_flying(foot, t, i)
	elif kind == "chill":
		_draw_frost()


# A perched crow on the fence, with a one-pixel moonlit edge on its back and head so it reads against the dark
# fence and hedge behind it (the same crow sprite the night uses; the edge is its own silhouette, pale).
func _draw_perched(foot: Vector2) -> void:
	if not (m.nights.E3_ART and FarmSprites.has("crow_perch")):
		m.nights._draw_crow_on(top, foot, 0.9)
		return
	var tex := FarmSprites.tex("crow_perch")
	var s := Vector2(tex.get_width(), tex.get_height()) * 3.0
	var rect := Rect2(Vector2(foot.x - s.x * 0.5, foot.y + float(m.PX) * 0.1 - s.y), s)
	var halo := _crow_halo()
	if halo != null:
		var edge := Color(1.0, 1.0, 1.04, 0.24)   # a grey sheen on the feathers' upper edge, not a glow
		for off in [Vector2(0, -m.ART_PX), Vector2(-m.ART_PX, -m.ART_PX), Vector2(m.ART_PX, -m.ART_PX)]:
			top.draw_texture_rect(halo, Rect2(rect.position + off, rect.size), false, edge)
	top.draw_texture_rect(tex, rect, false)


# A crow off the fence: the farm's flying crow, flapping, rising and drifting off low toward the woods, fading out.
func _draw_flying(foot: Vector2, t: float, i: int) -> void:
	var px := float(m.PX)
	var p := foot + Vector2(-px * (2.6 + 0.3 * (i % 2)) * t, -px * 0.4 - px * 1.3 * t - px * 0.9 * t * t)
	var a := 1.0 - smoothstep(0.55, 1.0, t)
	if not FarmSprites.has("crow_fly"):
		m.nights._draw_crow_on(top, p, 0.9)
		return
	var frame := int(t * 14.0 + i) % 4
	var fsize := Vector2(36, 36) * 3.0 * 0.85
	top.draw_set_transform(Vector2(p.x * 2.0, 0.0), 0.0, Vector2(-1, 1))   # facing left, the way they go
	top.draw_texture_rect_region(FarmSprites.tex("crow_fly"), Rect2(p - fsize * 0.5, fsize), Rect2(frame * 36, 0, 36, 36), Color(1, 1, 1, a))
	top.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# The perched crow's silhouette in white, made once from its sprite, for the moonlit edge.
func _crow_halo() -> Texture2D:
	if _halo != null:
		return _halo
	var img: Image = FarmSprites.tex("crow_perch").get_image()
	if img == null:
		return null
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var a := img.get_pixel(x, y).a
			img.set_pixel(x, y, Color(1, 1, 1, 1.0 if a > 0.5 else 0.0))
	_halo = ImageTexture.create_from_image(img)
	return _halo


# A pale rime over the west front window, thick at the pane's edges, and then the part ordinary frost doesn't do:
# fine branching lines creeping off the frame across the boards, as if the cold came from inside the house. No
# glow and no pulse; it is only bright enough to read through the night's tint.
func _draw_frost() -> void:
	if m.window_lights.is_empty():
		return
	var ap := m.ART_PX
	var spill := Vector2(0, m.PX * m.WINDOW_SPILL) if m.LIGHTING_V2 else Vector2.ZERO
	var c: Vector2 = (m.window_lights[0] as PointLight2D).position - spill
	var rime := Color(1.1, 1.18, 1.32, 0.78)
	var thin := Color(1.1, 1.18, 1.3, 0.85)
	for k in 90:
		var h := hash([k, "frost"])
		var x := posmod(h, 17) - 8
		var y := posmod(h >> 8, 15) - 7
		var edge := maxf(absf(x) / 8.0, absf(y) / 7.0)
		if edge < 0.5 or (edge < 0.75 and k % 2 == 0):
			continue
		top.draw_rect(Rect2((c + Vector2(x, y) * ap).snapped(Vector2(ap, ap)), Vector2(ap, ap)), rime)
	# The tendrils: from the frame's corners and lower edge, a random walk out across the siding that thins as it
	# goes, with a branch now and then. Fixed by hash, so they don't flicker; they grow longer as the evening goes on.
	var grow := clampf((m.current_hour - FROM) / 1.5, 0.45, 1.0)
	var starts := [Vector2(-8, 7), Vector2(8, 7), Vector2(-8, -6), Vector2(8, -6), Vector2(-3, 7), Vector2(4, 7), Vector2(-8, 1), Vector2(8, 2)]
	for s in starts.size():
		var p: Vector2 = starts[s]
		var dir := Vector2(signf(p.x) * (1.0 if absf(p.y) < 7.0 else 0.4), 1.0 if p.y > 0 else -0.6).normalized()
		var steps := int((9 + posmod(hash([s, "len"]), 7)) * grow)
		for n in steps:
			var h := hash([s, n, "tendril"])
			p += (dir + Vector2((posmod(h, 3) - 1) * 0.7, (posmod(h >> 4, 3) - 1) * 0.7)).round()
			var fade := 1.0 - float(n) / float(steps + 2)
			# Thick where it leaves the frame, a single pixel further out.
			var wide := Vector2(ap * 2, ap) if n < steps * 0.4 else Vector2(ap, ap)
			top.draw_rect(Rect2((c + p * ap).snapped(Vector2(ap, ap)), wide), Color(thin, thin.a * fade))
			if posmod(h >> 8, 5) == 0:
				var q := p + Vector2(dir.y, -dir.x).round() * (1 if posmod(h >> 11, 2) == 0 else -1)
				top.draw_rect(Rect2((c + q * ap).snapped(Vector2(ap, ap)), Vector2(ap, ap)), Color(thin, thin.a * fade * 0.7))
