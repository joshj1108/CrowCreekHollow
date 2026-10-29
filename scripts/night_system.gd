class_name NightSystem
extends RefCounted

# The nights: at 22:00 something happens on the farm, and the player chooses what to do about it. Each visitor
# is a short piece of play with light and where you stand (_play): hold a figure in your lantern's light while
# it slips away or comes at you, hold the door shut as the latch rattles, get to the crows before they peck,
# reach into the pond on the lights' swell, keep in a lamp's light while the footsteps circle. Winning costs a
# little sanity, leaves crow feathers and pushes the field shadow back. Losing, ignoring it until 01:00 or
# sleeping through it costs more, and the shadow creeps closer, blighting the crops nearest its path (_blight).
# When it reaches the house, the Hollow comes to the door. Some nights something goes for the hens or the goats
# too (the raids). Which visitors can come grows with the nights lived, so the second week is not the first.

var m: MainGame

const END_HOUR := 25.0          # 01:00: an encounter left alone resolves as ignored
const FOOTSTEPS_HOURS := 1.0    # the footsteps give an hour at most
const SHADOW_MAX := 8           # steps from the field's far edge to the house; at the last, the Hollow comes
const SHADOW_STEP := 4          # tiles the shadow moves per step
const TIER_NIGHTS := [0, 7, 14] # nights lived before each tier of visitors can come
const CHARM := {"name": "Crow charm", "feathers": 4, "sticks": 1, "level": 2, "xp": 6}
const FEATHER_TINT := "2a2632"
# How to answer each visitor, added to its messages until the player has met it HINT_UNTIL times.
const HINTS := {
	"field": "Hold it in your lantern's light until it fades; it slips away, so find it again. Without a lantern, walk right up to it.",
	"first": "Hold it in your light until it fades, or walk right up to it.",
	"knock": "Stand by the door inside and hold it shut each time the latch rattles.",
	"knock_out": "It is at your door. Hold it in your light until it goes.",
	"crows": "They drop onto your crops one at a time. Get each into your light before it pecks.",
	"pond": "Stand on the bank, face the lights and press Space as they swell brightest, three times.",
	"watcher": "Hold it in your light until it fades, but don't let it reach you: back away as it comes.",
	"footsteps": "Get inside, or stand in a lamp post's light until they pass. Don't stay in the dark.",
	"hollow": "Hold it in your light until it breaks apart, and keep out of its reach.",
	"raid": "Get there and light it before it's done. A lamp post beside the building keeps watch for you.",
}
const HINT_UNTIL := 3       # times a visitor is met before its prompts stop (seen, saved)

# The encounters (_play), in game hours (20 real seconds each), so a menu holds them as it holds the clock.
const HOLD_HOURS := {"field": 0.4, "first": 0.3, "knock": 0.3, "watcher": 0.5, "hollow": 0.9}
const BLINKS := {"field": 2, "hollow": 2}   # times a held figure slips back into the dark before it fades
const NEAR := 1.4               # tiles: how close you hold a figure with no lantern (arm's length and a step)
const LAMP_HOLD := 0.5          # a lamp post's light holds a figure on its own, at this share of your lantern
const PRESS_HOLD := 0.25        # Space at a held figure (face to face) adds this much
const STRIKE_SANITY := 3.0      # each time a visitor gets at you, before the night multipliers
const WATCH_STEP := 0.12        # the watcher and the Hollow step toward you this often while you light them
const KNOCK_FIRST := 0.15       # the latch first rattles this long after the knocks
const KNOCK_GAP := 0.3          # and again this often
const KNOCK_TIMES := 3          # rattles; held at all but one, the door is answered
const DOOR_REACH := 2.0         # tiles from where you stand on coming in that count as holding the door
const CROW_TIMES := [0.1, 0.35, 0.6]   # when each crow drops onto a crop
const CROW_PECK := 0.4          # a crow left this long pecks its crop back a stage
const PULSE_HOURS := 0.15       # the pond lights swell once this often (3 seconds)
const PULSE_TOP := 0.78         # brighter than this, reaching in is right
const PULSE_NEED := 3
const PULSE_MISSES := 3
const STEPS_CATCH := 0.7        # hours in the dark before the footsteps catch up (a Brass lantern or better slows them)
const STEPS_SAFE := 0.35        # hours in a lamp's light before they pass
const SEASON_MULT := {"Winter": 2.0, "Autumn": 1.3}   # the long dark: the nights and the dark take more
const NIGHT_CAP := 45.0         # the most one visitor takes at once, after every multiplier, so no night empties you

# Raids: from RAID_NIGHTS, a night may bring something to the coop or the barn at about RAID_HOUR. Light it with
# your lantern before RAID_HOURS pass. A lamp post lighting the spot halves the chance and scares it off at once,
# even while you sleep.
const RAID_NIGHTS := 7
const RAID_HOUR := 23.0
const RAID_HOURS := 1.0
const RAID_CHANCE := 0.12       # each night, plus RAID_WEAR at WEAR_FOX wear and RAID_SHADOW a shadow step
const RAID_WEAR := 0.12
const RAID_SHADOW := 0.02
const RAIDS := {
	"fox": {"sound": "hen", "appear": "The hens are screaming in the coop. A fox!",
		"won": "Your light catches the fox in the coop door. It bolts into the dark with nothing.",
		"lost": "A fox got into the coop and took a hen."},
	"crows": {"sound": "crow", "appear": "Crows are on the coop roof, tearing at the boards, and the hens are frantic.",
		"won": "The crows lift off the coop roof into the dark. A feather drifts down. +1 crow feather.",
		"lost": "The crows were at the coop half the night. The hens are too frightened to lay."},
	"barn": {"sound": "bleat", "appear": "The goats are crying in the barn. Something low is at the door.",
		"won": "Something low and dark slides away from the barn door as your light finds it.",
		"lost": "Something was at the barn door half the night. The goats are too frightened to give milk."},
}
const RAID_LAMP := "In the night something came to the %s, but the lamp post kept it off. There are prints in the mud."

# The shadow's blight: each step it creeps, it reaches for the BLIGHT_PER_STEP crops nearest it and sets them back
# a stage (a seedling dies), leaving a line of dead grass from the shadow to them that fades over BLIGHT_DAYS.
const BLIGHT_PER_STEP := 2
const BLIGHT_HOLLOW := 4        # crops the Hollow blights when it is left at the door
const BLIGHT_DAYS := 6

# Each visitor: its tier, where it appears, the sound and message when it comes, and what facing or
# ignoring it does. sanity values are losses; push moves the shadow back, creep moves it closer.
const VISITORS := [
	{"id": "field", "tier": 0, "where": "field", "sound": "sting",
		"appear": "Something stands at the edge of the field, facing the house.",
		"face": "It thins in your light like smoke and is gone. A black feather turns in the grass where it stood.",
		"face_sanity": 4, "feathers": 1, "push": 1,
		"ignore": "The thing at the field's edge is gone by one o'clock. It came a little closer first.",
		"ignore_sanity": 10, "creep": 1},
	{"id": "knock", "tier": 0, "where": "none", "sound": "knock",
		"appear": "Three slow knocks on the front door.",
		"face": "The knocking stops. Wet prints lead off toward the field, and a feather is caught in the latch.",
		"face_sanity": 5, "feathers": 1, "push": 1,
		"ignore": "The knocking stopped. Something walked away slowly through the crops.",
		"ignore_sanity": 12, "creep": 1},
	{"id": "quiet", "tier": 0, "where": "none", "sound": "hush",
		"appear": "The farm is quiet tonight. Too quiet.",
		"ignore": "", "ignore_sanity": 3, "creep": 0},
	{"id": "crows", "tier": 1, "where": "tree", "sound": "crow",
		"appear": "Every crow in the great tree is awake, and every one is staring at your crops.",
		"face": "The last crow bursts up off your crops into the dark, shedding feathers.",
		"face_sanity": 4, "feathers": 3, "push": 0,
		"ignore": "The crows came down in the night.",
		"ignore_sanity": 7, "creep": 0},
	{"id": "pond", "tier": 1, "where": "pond", "sound": "whisper",
		"appear": "Pale lights are drifting under the pond's surface, swelling and fading.",
		"face": "On the third swell something cold closes around your hand, then lets go of a fish.",
		"face_sanity": 5, "feathers": 0, "push": 0,
		"ignore": "The lights in the pond went out one by one.",
		"ignore_sanity": 8, "creep": 0},
	{"id": "watcher", "tier": 1, "where": "house", "sound": "sting",
		"appear": "A tall figure is watching from beside the house.",
		"face": "It is taller in the light than you thought. Then it is gone, and feathers drift down.",
		"face_sanity": 10, "feathers": 2, "push": 2,
		"ignore": "The figure by the house stood there until one o'clock. You felt it the whole time.",
		"ignore_sanity": 20, "creep": 1},
	{"id": "footsteps", "tier": 2, "where": "none", "sound": "steps_behind", "outdoors": true,
		"appear": "Footsteps behind you, matching yours. Don't look back. Get inside, or get into the light.",
		"face": "You slam the door. The footsteps stop right at the threshold.",
		"face_light": "The steps circle the light, slower and slower, and fade off into the field.",
		"face_sanity": 4, "feathers": 0, "push": 1,
		"ignore": "The footsteps caught up with you in the dark.",
		"ignore_sanity": 18, "creep": 1},
]
const HOLLOW := {"id": "hollow", "where": "door", "sound": "heartbeat",
	"appear": "The Hollow has come to your door.",
	"face": "You hold the Hollow in your light until it shrieks and comes apart into a hundred crows. The field is clear again.",
	"face_sanity": 20, "feathers": 5,
	"ignore": "The Hollow waited at the door until morning. Something in your mind gave way.",
	"ignore_sanity": 30, "limit": 5}
# The first night is always the same short scare, so a new player meets the dark, their sanity and the bed
# before the random visitors start. It plays out in beats (game hours after 22:00, about 20 seconds each):
# the farm goes quiet, steps or knocks, the figure at the field's edge, then a nudge toward the bed.
const FIRST := {"id": "first", "where": "field", "sound": "hush",
	"appear": "The crows have stopped calling. The whole farm has gone quiet.",
	"face": "It thins in your light like smoke and is gone. A black feather turns in the grass where it stood.",
	"face_sanity": 2, "feathers": 1, "push": 0,
	"ignore": "Something walked the farm in the night. There are prints at the field's edge, and they lead to the house.",
	"ignore_sanity": 3, "creep": 0}
const FIRST_BEATS := [0.0, 0.4, 0.9, 1.5]
# The first sighting of the Hollow, once (sighting_seen, saved): the night of the walk to the wood's edge, or by
# SIGHTING_BY if Maren hasn't been walked. In beats like the first night: every crow in the great tree goes up;
# the crow-black shape stands at the far edge of the field and looks at the house; then it comes apart into crows
# that pour into the great tree's roots, and leaves Agnes's page about the hollow there (Mystery._on_sighting).
# It never comes closer and never moves the field shadow; it costs about what the first night does.
const SIGHTING := {"id": "sighting", "where": "far", "sound": "crow",
	"appear": "Every crow in the great tree goes up at once, crying, and wheels over the farm in the dark.",
	"face": "You start toward it across the field. Before you are halfway it comes apart into crows, hundreds of them, that pour low over the crops and down into the roots of the great tree. Then the field is only a field.",
	"face_sanity": 2, "feathers": 0, "push": 0,
	"ignore": "It comes apart into crows, hundreds of them, that pour low over the crops and down into the roots of the great tree. Then the field is only a field.",
	"asleep": "In the night every crow in the great tree went up at once; you heard them in your sleep. At first light the grass at the field's far edge is pressed flat in a wide ring, wider than a man would leave.",
	"ignore_sanity": 2, "creep": 0}
const SIGHTING_BEATS := [0.0, 0.5, 1.3]
const SIGHTING_BY := 9

var shadow_steps := 0       # saved: how far the field shadow has crept toward the house
var last_visitor := ""      # saved: last night's visitor, so the same one doesn't come twice in a row
var visitor: Dictionary = {}    # tonight's, while it waits for an answer
var visitor_tile := Vector2i(-1, -1)
var visitor_end := END_HOUR
var first_beat := -1        # the first night's next beat while it plays out, -1 otherwise
var first_start := 0.0
var sighting_seen := false  # saved: the first Hollow sighting has played
var sight_beat := -1        # the sighting's next beat while it plays out, -1 otherwise
var sight_start := 0.0
var charmed := false        # a crow charm was used up tonight: losses are halved
var seen := {}              # saved: visitor id (and "raid") -> times met, so the prompts stop once learned
var blight := {}            # saved: tile -> the day the shadow's blight marked it
# Tonight's encounter while it plays (_play). Not saved: a save loaded mid-night has the visitor gone.
var mode := ""              # hold, door, crows, pulse, steps or sighting
var prog := 0.0             # how far the answer has come; at 1 the visitor is faced
var strikes := 0            # times it got at you: the door forced, a crow's peck, a wrong reach, a lunge
var beats := 0              # beats played: rattles, blinks
var next_at := 0.0          # game hour of the next beat
var start_hour := 0.0
var home_tile := Vector2i(-1, -1)   # where a lunging figure goes back to
var crow_at: Array = []     # the crows on the crops: tile, land (hour), state (wait, down, gone, pecked)
var dread := 0.0            # the footsteps closing in, 0 to 1
var swell := -1             # the pond swell last reached into
var last_hour := 0.0
var raid := ""              # tonight's raid while it waits: fox, crows or barn
var raid_tile := Vector2i(-1, -1)
var raid_at := 0.0
var raid_live := false
var raid_loss := ""         # eggs or milk: what the morning loses to a raid (read and cleared by _settle_day)
var layer: Node2D           # the visitors, drawn over the farm's buildings
var marks: Node2D           # the blight on the ground: over the ground and crops, under everything else
var light: PointLight2D     # a faint glow at the visitor, red for the figures, pale for the pond


func _init(main: MainGame) -> void:
	m = main


# The visitors' own layer and light, made once the farm is built.
func _build() -> void:
	layer = Node2D.new()
	layer.z_index = 20
	layer.draw.connect(_draw)
	m.add_child(layer)
	marks = Node2D.new()
	marks.draw.connect(_draw_marks)
	m.add_child(marks)
	m.move_child(marks, 0)   # straight after the farm's own drawing
	light = PointLight2D.new()
	light.texture = m._glow_texture()
	light.texture_scale = 0.9
	light.energy = 0.9
	light.enabled = false
	m.add_child(light)


# Shows tonight's visitor, or clears it once it is answered.
func _show_visitor() -> void:
	var lit := _active() and visitor_tile.x >= 0 and str(visitor["id"]) in ["field", "first", "knock", "watcher", "hollow", "pond", "sighting"]
	light.enabled = lit
	if lit:
		# The glow sits at eye height, so the eyes and the outline around them show in the dark.
		var eyes := {"field": 0.75, "first": 0.75, "knock": 0.75, "watcher": 1.2, "hollow": 1.4, "sighting": 1.4, "pond": 0.0}
		var big := str(visitor["id"]) in ["hollow", "sighting"]
		light.position = m._tile_center(visitor_tile.x, visitor_tile.y) + Vector2(0, -m.PX * float(eyes[visitor["id"]]))
		light.color = Color(0.7, 0.9, 1.0) if visitor["id"] == "pond" else Color(1.0, 0.18, 0.12)
		light.texture_scale = 1.8 if big else 0.9
		light.energy = 1.6 if big else 0.9
	layer.queue_redraw()


func _tier() -> int:
	var tier := 0
	for i in TIER_NIGHTS.size():
		if int(m.stats["events"]) >= int(TIER_NIGHTS[i]):
			tier = i
	return tier


func _active() -> bool:
	return not visitor.is_empty()


# True while a visitor's prompts still show: until it has been met HINT_UNTIL times.
func _hinting(id: String) -> bool:
	return int(seen.get(id, 0)) < HINT_UNTIL


# 22:00: tonight's visitor arrives. force names one, for checking it (tools/capture.gd).
func _begin(force := "") -> void:
	if (force == "" and _first_night()) or force == "first":
		_begin_first()
		return
	if (force == "" and _sighting_night()) or force == "sighting":
		_begin_sighting()
		return
	m.event_fired_day = m.day
	m.stats["events"] += 1
	visitor = _pick()
	if force == "hollow":
		visitor = HOLLOW
	for v in VISITORS:
		if v["id"] == force:
			visitor = v
	visitor_end = END_HOUR if visitor["id"] != "footsteps" else m.current_hour + FOOTSTEPS_HOURS
	visitor_tile = _place(str(visitor["where"]))
	m.tonight_shadow = visitor_tile if str(visitor["where"]) in ["field", "house", "door"] else Vector2i(-1, -1)
	charmed = false
	var note := ""
	if m.sanity_sys._blessed_tonight():
		charmed = true
		note = " The vicar's blessing holds."
	elif int(m.inventory["crow_charm"]) > 0:
		m.inventory["crow_charm"] -= 1
		charmed = true
		note = " Your crow charm grows warm."
	m.ambience.night_event(str(visitor["sound"]))
	_start_play()
	var hint := "knock_out" if mode == "hold" and visitor["id"] == "knock" else str(visitor["id"])
	if _hinting(str(visitor["id"])) and HINTS.has(hint):
		note += " " + str(HINTS[hint])
	m._show_message(str(visitor["appear"]) + note)
	_show_visitor()
	_roll_raid()
	if visitor["id"] == "quiet":
		_resolve(false)


# No night has come yet: this is a new game's first, on day 1.
func _first_night() -> bool:
	return int(m.stats["events"]) == 0


# The first night's opening beat. The figure isn't placed until its beat, so it can't be faced before then.
func _begin_first() -> void:
	m.event_fired_day = m.day
	m.stats["events"] += 1
	visitor = FIRST
	visitor_end = END_HOUR
	visitor_tile = Vector2i(-1, -1)
	charmed = false
	first_start = m.current_hour
	first_beat = 1
	_start_play()
	m.ambience.night_event("hush")
	m._show_message(str(FIRST["appear"]))
	_show_visitor()


# The rest of the first night, beat by beat. It runs on the game clock, so an open menu holds it too.
func _update_first() -> void:
	while first_beat >= 0 and m.current_hour >= first_start + float(FIRST_BEATS[first_beat]):
		var beat := first_beat
		first_beat = first_beat + 1 if first_beat + 1 < FIRST_BEATS.size() else -1
		var out := not m.inside
		if beat == 1:
			if out:
				m.ambience.night_event("steps_behind")
				m._show_message("Footsteps in the grass behind you. When you turn, nobody is there.")
			else:
				m.ambience.night_event("knock")
				m._show_message("Three slow knocks on the front door. Then nothing.")
			m.sanity_sys._change_sanity(-2.0)
		elif beat == 2 and _active():
			visitor_tile = _place("field")
			home_tile = visitor_tile
			m.tonight_shadow = visitor_tile
			m.ambience.night_event("sting")
			_show_visitor()
			if out:
				m._show_message("Something stands at the edge of the field, facing the house. " + str(HINTS["first"]))
			else:
				m._show_message("Through the window: something is standing at the edge of the field, facing the house.")
		elif beat == 3:
			m.ambience.night_event("whisper")
			var text := "The dark wears at your Sanity while you're out in it. Get inside and go to bed: sleep puts it right." \
				if out else "Stay in tonight, and go to bed: the house and sleep put your Sanity right."
			if m.lantern_tier == 0:
				text += " A lantern would light the way. Build one before tomorrow night."
			m._show_message(text)


# Tonight is the first sighting: after the first night, the night of the walk to the wood's edge (or by
# SIGHTING_BY), once.
func _sighting_night() -> bool:
	return not sighting_seen and not _first_night() and (m.trek.edge_done or m.day >= SIGHTING_BY)


func _begin_sighting() -> void:
	m.event_fired_day = m.day
	m.stats["events"] += 1
	sighting_seen = true
	visitor = SIGHTING
	visitor_end = END_HOUR
	visitor_tile = Vector2i(-1, -1)
	charmed = false
	sight_start = m.current_hour
	sight_beat = 1
	_start_play()
	m.ambience.night_event("crow")
	m._show_message(str(SIGHTING["appear"]))
	_show_visitor()


# The sighting's beats: the shape at the far edge, then it comes apart into crows and leaves a page.
func _update_sighting() -> void:
	while sight_beat >= 0 and m.current_hour >= sight_start + float(SIGHTING_BEATS[sight_beat]):
		var beat := sight_beat
		sight_beat = sight_beat + 1 if sight_beat + 1 < SIGHTING_BEATS.size() else -1
		if not _active() or visitor["id"] != "sighting":
			sight_beat = -1
			return
		if beat == 1:
			visitor_tile = _place("far")
			m.tonight_shadow = visitor_tile
			m.ambience.night_event("heartbeat")
			_show_visitor()
			var seen_from := "At the far edge of the field" if not m.inside else "Through the window, at the far edge of the field,"
			m._show_message("%s stands something far bigger than the thing from your first night: taller than the door, ragged at the edges like a cloud of crows, with two red eyes. It doesn't come closer. It only looks at the house." % seen_from)
		elif beat == 2:
			_leave_sighting(false)


# The sighting ends, faced or not: it goes into the great tree's roots, and Agnes's page about the hollow there
# is left where it stood (Mystery._on_sighting), or just the message once that page is already found.
func _leave_sighting(faced: bool) -> void:
	sight_beat = -1
	var text := str(SIGHTING["face"] if faced else SIGHTING["ignore"])
	_resolve(faced, false)
	if not m.mystery._on_sighting(text):
		m._show_message(text)


func _pick() -> Dictionary:
	# The night the crow bell is hung, the Hollow comes to it one last time. Once Agnes is walked to the grove,
	# it sleeps and never comes again.
	if (shadow_steps >= SHADOW_MAX and not m.trek.grove_done) or m.projects.bell_day == m.day:
		return HOLLOW
	# In the second year, a few nights after the orchard rises, it comes with Elias's knock (StoryAct).
	if m.act._knock_tonight():
		return m.act.KNOCK
	var tier := _tier()
	var options: Array = []
	for v in VISITORS:
		if int(v["tier"]) > tier or v["id"] == last_visitor:
			continue
		if v.get("outdoors", false) and (m.inside or m.in_cave):
			continue
		if v["id"] == "pond" and m.pond_edges.is_empty():
			continue
		options.append(v)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, "night"])
	# The newest visitors are likelier, so each tier is felt when it arrives.
	var weights: Array = []
	for v in options:
		weights.append(1.0 + float(v["tier"]))
	return options[rng.rand_weighted(PackedFloat32Array(weights))]


func _place(where: String) -> Vector2i:
	match where:
		"field":
			return m.shadow_tile
		"house":
			return m._world_tile(m.HOUSE_IX + m.HOUSE_W, m.HOUSE_IY + 1)
		"door":
			return m._world_tile(m.HOUSE_DOOR_IX, m.HOUSE_DOOR_IY + 2)
		"far":
			# The field's far edge, where the shadow starts, however far it has crept since.
			return Vector2i(m.BORDER_X + m.INNER_W - 2, m.shadow_tile.y)
		"tree":
			return m._world_tile(m.BIG_TREE_INNER.x + 1, m.BIG_TREE_INNER.y + 1)
		"pond":
			return m.pond_edges[hash([m.day, "pond"]) % m.pond_edges.size()]
	return Vector2i(-1, -1)


# Each frame: tonight's encounter plays, the raid comes, and an encounter not answered in time counts as ignored.
func _update() -> void:
	_update_first()
	_update_sighting()
	var dh := clampf(m.current_hour - last_hour, 0.0, 0.25)
	last_hour = m.current_hour
	if _active():
		_play(dh)
	_update_raid()
	if _active() and m.current_hour >= visitor_end:
		_resolve(false)
	if _active() or raid_live:
		layer.queue_redraw()
	marks.visible = not m.in_cave


# --- The encounters ---------------------------------------------------------------------------

# How the visitor that just came is answered, and its counters from zero.
func _start_play() -> void:
	prog = 0.0
	strikes = 0
	beats = 0
	dread = 0.0
	swell = -1
	crow_at = []
	start_hour = m.current_hour
	last_hour = m.current_hour
	next_at = m.current_hour
	home_tile = visitor_tile
	match str(visitor.get("id", "")):
		"field", "first", "watcher", "hollow":
			mode = "hold"
		"knock":
			if m.inside:
				_door_mode()
			else:
				_hold_at_door()
		"crows":
			mode = "crows"
			_land_crows()
		"pond":
			mode = "pulse"
		"footsteps":
			mode = "steps"
		"sighting":
			mode = "sighting"
		_:
			mode = ""


func _door_mode() -> void:
	mode = "door"
	visitor_tile = Vector2i(-1, -1)
	m.tonight_shadow = Vector2i(-1, -1)
	next_at = m.current_hour + KNOCK_FIRST


# Outdoors, the knocker stands at your door, to be held in the light like the field figure.
func _hold_at_door() -> void:
	mode = "hold"
	visitor_tile = _place("door")
	home_tile = visitor_tile
	m.tonight_shadow = visitor_tile


func _play(dh: float) -> void:
	match mode:
		"hold":
			_play_hold(dh)
		"door":
			_play_door()
		"crows":
			_play_crows()
		"steps":
			_play_steps(dh)
	# The pond is played by Space presses (_reach_in); it only needs redrawing.


# Your lantern's reach in tiles, or arm's length without one.
func _reach() -> float:
	return float(m.LANTERN_TIERS[m.lantern_tier - 1]["radius"]) if m.lantern_tier > 0 else NEAR


func _tiles_to(t: Vector2i) -> float:
	return (m.player.position - m._tile_center(t.x, t.y)).length() / float(m.PX)


func _lit_by_you(t: Vector2i) -> bool:
	return t.x >= 0 and not m.inside and not m.in_cave and _tiles_to(t) <= _reach()


# A lamp post's light, or the restored house's porch lamp.
func _lit_by_lamp(t: Vector2i) -> bool:
	if t.x < 0:
		return false
	var porch := m._world_tile(m.HOUSE_DOOR_IX, m.HOUSE_DOOR_IY + 1)
	return m.projects._lit(t) or (m.house_stage >= 3 and Vector2(t - porch).length() <= 3.0)


# Something gets at you: the door forced, a crow's peck, a wrong reach, a lunge.
func _strike(text: String) -> void:
	strikes += 1
	m.sanity_sys._change_sanity(-STRIKE_SANITY * _loss_mult())
	m.ambience.night_event("sting")
	m._shake_camera(0.3, 4.0)
	m._show_message(text)


# The field figure, the watcher, the Hollow and the knocker outdoors: held in light until they fade.
func _play_hold(dh: float) -> void:
	if visitor_tile.x < 0 or m.inside or m.in_cave:
		return
	var id := str(visitor["id"])
	var you := _lit_by_you(visitor_tile)
	var rate := (1.0 if you else 0.0) + (LAMP_HOLD if _lit_by_lamp(visitor_tile) else 0.0)
	if rate <= 0.0:
		return
	prog = minf(1.0, prog + dh * rate / float(HOLD_HOURS[id]))
	# The tall ones come at you while you light them. Let one reach you and it lunges, and is back where it stood.
	if id in ["watcher", "hollow"] and you and m.current_hour >= next_at:
		next_at = m.current_hour + WATCH_STEP
		var d := m._player_tile() - visitor_tile
		if absi(d.x) >= absi(d.y):
			visitor_tile.x += signi(d.x)
		else:
			visitor_tile.y += signi(d.y)
		if _tiles_to(visitor_tile) <= 1.1:
			prog = maxf(0.0, prog - 0.3)
			visitor_tile = home_tile
			_strike("It is suddenly right in front of you, and the cold of it goes straight through you. Then it is back where it stood.")
		_show_visitor()
	# The field figure and the Hollow slip back into the dark, and have to be found again.
	var blinks := int(BLINKS.get(id, 0))
	if beats < blinks and prog >= float(beats + 1) / float(blinks + 1) and prog < 1.0:
		beats += 1
		visitor_tile = _blink_tile(id)
		home_tile = visitor_tile
		m.tonight_shadow = visitor_tile
		m.ambience.night_event("whisper")
		m._show_message("It slips back into the dark." + (" Find it again with your light." if _hinting(id) else ""))
		_show_visitor()
	if prog >= 1.0:
		_resolve(true)


# Where a held figure goes when it slips away: a few tiles on, away from you, still on the farm.
func _blink_tile(id: String) -> Vector2i:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, id, beats])
	var away := Vector2(visitor_tile - m._player_tile())
	var angle := (away.angle() if away.length() > 0.1 else rng.randf() * TAU) + rng.randf_range(-1.0, 1.0)
	var dist := rng.randf_range(2.0, 3.0) if id == "hollow" else rng.randf_range(4.0, 6.0)
	var t := visitor_tile + Vector2i(roundi(cos(angle) * dist), roundi(sin(angle) * dist))
	t.x = clampi(t.x, m.BORDER_X + 1, m.BORDER_X + m.INNER_W - 2)
	t.y = clampi(t.y, m.BORDER_Y + m.HOUSE_IY + m.HOUSE_H + 1 if id == "hollow" else m.BORDER_Y + 1, m.BORDER_Y + m.INNER_H - 2)
	return t


# Indoors, the knocking: the latch rattles KNOCK_TIMES times, and each time you are by the door you hold it.
func _play_door() -> void:
	if not m.inside:
		_hold_at_door()
		_show_visitor()
		return
	if m.current_hour < next_at:
		return
	beats += 1
	next_at += KNOCK_GAP
	m.ambience.night_event("knock")
	if _at_door():
		prog = minf(1.0, prog + 1.0 / KNOCK_TIMES)
		m.play_sfx("door", 0.1)
		m._show_message("The latch lifts. You throw your weight on the door, and it pushes once, hard, and lets go. (%d of %d)" % [beats, KNOCK_TIMES])
	else:
		_strike("The latch lifts, and the door swings a hand's width open onto the dark. Then it closes again." \
			+ (" Stand by the door to hold it." if _hinting("knock") else ""))
	if beats >= KNOCK_TIMES:
		_resolve(strikes <= 1)


func _at_door() -> bool:
	var spot := m._tile_center(m.INT_ORIGIN.x + m.INT_ENTRY.x, m.INT_ORIGIN.y + m.INT_ENTRY.y)
	return m.inside and (m.player.position - spot).length() <= DOOR_REACH * float(m.PX)


# The crows drop onto the growing crops nearest the great tree, one at a time; with none, onto the grass below it.
func _land_crows() -> void:
	var tree := _place("tree")
	var targets: Array = []
	for pos in m.crops:
		if int(m.crops[pos]["stage"]) > 0:
			targets.append(pos)
	targets.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return tree.distance_squared_to(a) < tree.distance_squared_to(b))
	for off in [Vector2i(-2, 3), Vector2i(2, 3), Vector2i(0, 4)]:
		targets.append(tree + off)
	for i in CROW_TIMES.size():
		crow_at.append({"tile": targets[i], "land": start_hour + float(CROW_TIMES[i]), "state": "wait"})


func _play_crows() -> void:
	var open := 0
	for c in crow_at:
		match str(c["state"]):
			"wait":
				open += 1
				if m.current_hour >= float(c["land"]):
					c["state"] = "down"
					m.ambience.night_event("crow")
			"down":
				open += 1
				if _lit_by_you(c["tile"]) or _lit_by_lamp(c["tile"]):
					_scare(c)
				elif m.current_hour >= float(c["land"]) + CROW_PECK:
					c["state"] = "pecked"
					strikes += 1
					m.ambience.night_event("crow")
					m._show_message("A crow tears at your crop and lifts off with something in its beak." if _peck(c["tile"]) else "A crow lifts off the grass, croaking.")
	if open == 0:
		_resolve(_scared() >= 2)


func _scare(c: Dictionary) -> void:
	c["state"] = "gone"
	prog = float(_scared()) / CROW_TIMES.size()
	m.play_sfx("crow", 0.1)


func _scared() -> int:
	var n := 0
	for c in crow_at:
		if str(c["state"]) == "gone":
			n += 1
	return n


# The pond lights' swell, 0 (dim) to 1 (brightest).
func _pulse() -> float:
	return 0.5 - 0.5 * cos(TAU * (m.current_hour - start_hour) / PULSE_HOURS)


# Space at the lights: right on the swell, they gather; wrong, something cold brushes your hand.
func _reach_in() -> void:
	var n := int((m.current_hour - start_hour) / PULSE_HOURS)
	if n == swell:
		return
	swell = n
	if _pulse() >= PULSE_TOP:
		prog = minf(1.0, prog + 1.0 / PULSE_NEED)
		m.play_sfx("chime", 0.05)
		if prog < 0.999:
			m._show_message("The lights gather round your hand. (%d of %d)" % [roundi(prog * PULSE_NEED), PULSE_NEED])
	else:
		m.play_sfx("splash", 0.1)
		_strike("Too soon, or too late. Something cold brushes your fingers, and the lights shrink away." \
			+ (" Wait for them to swell brightest." if _hinting("pond") else ""))
	if prog >= 0.999:
		_resolve(true)
	elif strikes >= PULSE_MISSES:
		_resolve(false)


# The footsteps: the dark brings them closer, a lamp's light holds them off until they pass, the house ends them.
func _play_steps(dh: float) -> void:
	if m.inside:
		_resolve(true)
		return
	if _lit_by_lamp(m._player_tile()):
		prog += dh / STEPS_SAFE
		dread = maxf(0.0, dread - dh / STEPS_SAFE)
	else:
		dread += dh / STEPS_CATCH * (0.6 if m.lantern_tier >= 2 else 1.0)
	if m.current_hour >= next_at:
		next_at = m.current_hour + lerpf(0.09, 0.035, clampf(dread, 0.0, 1.0))
		m.ambience.play_side("steps_behind", lerpf(-16.0, -3.0, clampf(dread, 0.0, 1.0)))
	if prog >= 1.0:
		_resolve(true, true, "face_light")
	elif dread >= 1.0:
		_resolve(false)


# Space on the farm: at a held figure it adds to the hold, at a crow it scares it, at the pond lights it reaches
# in, at a raider it drives it off. Returns true when the press was used.
func _try_face(tile: Vector2i) -> bool:
	if raid_live and tile == raid_tile:
		_end_raid(true)
		return true
	if not _active():
		return false
	match mode:
		"hold":
			if tile == visitor_tile:
				prog = minf(1.0, prog + PRESS_HOLD)
				m.play_sfx("swing", 0.1)
				if prog >= 1.0:
					_resolve(true)
				return true
		"sighting":
			# It goes before you reach it: walking out at it ends it, faced.
			if visitor_tile.x >= 0 and tile.distance_to(visitor_tile) <= 6.0:
				_leave_sighting(true)
				return true
		"crows":
			for c in crow_at:
				if str(c["state"]) == "down" and c["tile"] == tile:
					_scare(c)
					return true
		"pulse":
			if m.map[tile.y][tile.x] == MainGame.Tile.WATER and absi(tile.x - visitor_tile.x) <= 1 and absi(tile.y - visitor_tile.y) <= 1:
				_reach_in()
				return true
	return false


# Going out while the latch rattles: the knocker is at the door, to be held in the light.
func _on_leave_house() -> void:
	if _active() and mode == "door":
		_hold_at_door()
		m._show_message("It is standing at your door." + (" " + str(HINTS["knock_out"]) if _hinting("knock") else ""))
		_show_visitor()


# Reaching the house escapes the footsteps; going in past the knocker leaves it knocking.
func _on_enter_house() -> void:
	if not _active():
		return
	if visitor["id"] == "footsteps":
		_resolve(true)
	elif visitor["id"] == "knock" and mode == "hold":
		_door_mode()
		_show_visitor()


# --- The raids --------------------------------------------------------------------------------

# 22:00: whether something comes for the animals tonight, fixed by the day.
func _roll_raid() -> void:
	raid = ""
	raid_live = false
	if int(m.stats["events"]) < RAID_NIGHTS:
		return
	var kinds: Array = []
	if m.hens > 0 and m.coop_built and m.coop_tile.x >= 0:
		kinds.append_array(["fox", "crows"])
	if m.goats > 0 and m.barn_built and m.barn_tile.x >= 0:
		kinds.append("barn")
	if kinds.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, "raid"])
	var kind: String = kinds[rng.randi() % kinds.size()]
	var tile := _raid_place(kind)
	var chance := RAID_CHANCE + (RAID_WEAR if m.wear >= m.WEAR_FOX else 0.0) + RAID_SHADOW * shadow_steps
	if m.projects._lit(tile):
		chance *= 0.5
	if rng.randf() >= chance:
		return
	raid = kind
	raid_tile = tile
	raid_at = RAID_HOUR + rng.randf() * 0.5


# In front of the coop's door or the barn's; the crows sit on the coop's roof above it.
func _raid_place(kind: String) -> Vector2i:
	if kind == "barn":
		var size := m._footprint("barn")
		return m.barn_tile + Vector2i(size.x / 2, size.y)
	var coop := m._footprint("coop")
	return m.coop_tile + Vector2i(coop.x / 2, coop.y if kind == "fox" else coop.y - 1)


func _update_raid() -> void:
	if raid == "":
		return
	if not raid_live:
		if m.current_hour < raid_at:
			return
		raid_live = true
		var r: Dictionary = RAIDS[raid]
		m.ambience.night_event(str(r["sound"]))
		if m.projects._lit(raid_tile):
			m._show_message(RAID_LAMP % ("barn" if raid == "barn" else "coop"))
			_end_raid(true, false, true)
			return
		var text := str(r["appear"])
		if m.inside:
			text = "From the house you hear it: " + text.substr(0, 1).to_lower() + text.substr(1)
		if _hinting("raid"):
			text += " " + str(HINTS["raid"])
		m._show_message(text)
		layer.queue_redraw()
		return
	if _lit_by_you(raid_tile):
		_end_raid(true)
	elif m.current_hour >= raid_at + RAID_HOURS:
		_end_raid(false)


# The raid ends. Lost, the fox takes a hen, the crows cost the morning's eggs, and the thing at the barn the
# morning's milk (and a goat, once the house is run down). All of it can be won back from the catalog.
func _end_raid(won: bool, show := true, by_lamp := false) -> String:
	var kind := raid
	var r: Dictionary = RAIDS[kind]
	raid = ""
	raid_live = false
	seen["raid"] = int(seen.get("raid", 0)) + 1
	var text := RAID_LAMP % ("barn" if kind == "barn" else "coop") if by_lamp else str(r["won" if won else "lost"])
	if won:
		if not by_lamp:
			m.progression._bump("raids_won")
		if kind == "crows" and not by_lamp:
			m.materials["feathers"] += 1
	else:
		match kind:
			"fox":
				if m.hens > 0:
					m.progression._bump("animals_lost")
				m.hens = maxi(0, m.hens - 1)
			"crows":
				raid_loss = "eggs"
			"barn":
				raid_loss = "milk"
				if m.wear >= m.WEAR_FOX and m.goats > 0:
					m.goats -= 1
					m.progression._bump("animals_lost")
					text += " One of the goats broke out and is gone."
		m.animals._sync_ages()
	if show:
		m._show_message(text)
	layer.queue_redraw()
	return text


# --- The end of the night ---------------------------------------------------------------------

# Bed (or a collapse) ends the night. A visitor still waiting counts as ignored, and its note joins the
# morning message. Going to bed before 22:00 doesn't dodge it: tonight's visitor comes to a sleeping house.
# A raid still to come happens too, and is lost, unless a lamp post lights the spot.
func _end_night() -> String:
	first_beat = -1
	sight_beat = -1
	var note := ""
	if _active():
		note = " " + _resolve(false, false)
	elif m.event_fired_day != m.day:
		var first := _first_night()
		var sighting := not first and _sighting_night()
		m.event_fired_day = m.day
		m.stats["events"] += 1
		visitor = FIRST if first else (SIGHTING if sighting else _pick())
		if sighting:
			sighting_seen = true
		charmed = m.sanity_sys._blessed_tonight()
		if not charmed and int(m.inventory["crow_charm"]) > 0:
			m.inventory["crow_charm"] -= 1
			charmed = true
		_roll_raid()
		mode = ""
		crow_at = []
		note = " " + _resolve(false, false)
	if raid != "":
		var lamp := m.projects._lit(raid_tile)
		note += " " + _end_raid(lamp, false, lamp)
	return note


# Everything that scales what a night takes from your sanity.
func _loss_mult() -> float:
	var mult := (2.0 if m.sanity_sys._event_active("dread") else 1.0) * (0.5 if m.sanity_sys._event_active("ward") else 1.0)
	mult *= 0.5 if charmed else 1.0
	mult *= m.projects._night_mult()   # the crow bell
	mult *= m.estate._night_mult()     # the second storey
	mult *= m.trek._night_mult()       # walked someone today, the wood come close, or the Hollow asleep
	mult *= _season_mult()
	return mult * m.NIGHT_LOSS_MULT


# The long dark: winter nights, and autumn's a little, take more.
func _season_mult() -> float:
	return float(SEASON_MULT.get(m._season_today(), 1.0))


# key names the message to show instead of face or ignore (the footsteps outlasted in a lamp's light).
func _resolve(faced: bool, show := true, key := "") -> String:
	var v := visitor
	visitor = {}
	last_visitor = str(v["id"])
	seen[last_visitor] = int(seen.get(last_visitor, 0)) + 1
	m.mystery._on_visitor(str(v["id"]), faced)
	if v["id"] == "hollow":
		m.act._on_hollow(faced, v)
	m.tonight_shadow = Vector2i(-1, -1)
	_show_visitor()
	var text := str(v[key] if key != "" else (v["face"] if faced else v["ignore"]))
	# Slept through, the sighting is only what you find in the morning.
	if not show and not faced and v.has("asleep"):
		text = str(v["asleep"])
	var loss := minf(float(v["face_sanity"] if faced else v["ignore_sanity"]) * _loss_mult(), NIGHT_CAP)
	m.sanity_sys._change_sanity(-loss)
	var before := shadow_steps
	if faced:
		m.stats["faced"] += 1
		m.progression._bump("faced_" + last_visitor)   # each kind faced, for the achievements
		var feathers := int(v.get("feathers", 0))
		if v["id"] == "crows" and not crow_at.is_empty():
			feathers = _scared()
		if v["id"] == "pond":
			if m.stall._pack_room(int(m.inventory["fish"]), 2):
				m.inventory["fish"] += 2
				text += " Two fish."
			else:
				feathers = 2
				text += " Your pack is full, so it leaves feathers instead."
		m.materials["feathers"] += feathers
		if feathers > 0:
			text += " +%d crow feather%s." % [feathers, "" if feathers == 1 else "s"]
		if v["id"] == "hollow":
			shadow_steps = 0
		else:
			shadow_steps = maxi(0, shadow_steps - int(v.get("push", 0)))
	else:
		if v["id"] == "crows":
			text += " " + _crows_left()
		if v["id"] == "hollow":
			m.sanity_penalty += int(v["limit"])
			m.sanity = minf(m.sanity, m.sanity_sys._sanity_max())
			shadow_steps = SHADOW_MAX / 2
			var hit := _blight_crops(BLIGHT_HOLLOW, _place("door"))
			if hit > 0:
				text += " Where it stood, the grass is dead in a line to your crops, and %d of them have wilted." % hit
		else:
			# While the crow bell stands, the shadow stops a step short of the house.
			shadow_steps = mini(SHADOW_MAX - (1 if m.projects._has_bell() else 0), shadow_steps + int(v.get("creep", 0)))
	# While the wood is close it pushes the shadow a step nearer every night, whatever the visitor.
	if m.trek._wood_close() and v["id"] != "hollow":
		shadow_steps = mini(SHADOW_MAX - (1 if m.projects._has_bell() else 0), shadow_steps + 1)
	# Once the Hollow sleeps, the field has no shadow.
	if m.trek.grove_done:
		shadow_steps = 0
	if shadow_steps > before:
		text += _blight(before, shadow_steps)
	mode = ""
	crow_at = []
	if show and text != "":
		m._show_message(text)
	return text


# Left alone, the crows set back the crops they were on; unanswered before they came down (or slept through),
# up to three growing crops.
func _crows_left() -> String:
	var hit := 0
	if crow_at.is_empty():
		for pos in m.crops.keys():
			if hit >= CROW_TIMES.size():
				break
			if int(m.crops[pos]["stage"]) > 0 and _peck(pos):
				hit += 1
	else:
		for c in crow_at:
			if str(c["state"]) in ["wait", "down"] and _peck(c["tile"]):
				hit += 1
		for c in crow_at:
			if str(c["state"]) == "pecked" and m.crops.has(c["tile"]):
				hit += 1
	if hit == 0:
		return "They found nothing worth taking."
	return "%d crop%s pecked back a stage." % [hit, "" if hit == 1 else "s"]


# Sets a growing crop back a stage. Growth days go back to the start of the lower stage too, or the next watered
# night undoes it. Returns false when there is no growing crop there.
func _peck(pos: Vector2i) -> bool:
	if not m.crops.has(pos) or int(m.crops[pos]["stage"]) <= 0:
		return false
	var stage := int(m.crops[pos]["stage"]) - 1
	m.crops[pos]["stage"] = stage
	m.crops[pos]["days"] = ceili(float(stage * int(m.CROP_GROW_DAYS[str(m.crops[pos]["kind"])])) / m.MAX_STAGE)
	return true


# --- The field shadow and its blight ------------------------------------------------------------

# The shadow's place for the coming night: it starts at the far east of the field and steps toward the house.
func _shadow_x() -> int:
	return _shadow_x_at(shadow_steps)


func _shadow_x_at(steps: int) -> int:
	return maxi(m.BORDER_X + m.INNER_W - 2 - steps * SHADOW_STEP, m.BORDER_X + m.HOUSE_IX + m.HOUSE_W + 1)


func _shadow_y() -> int:
	return m.BORDER_Y + m.INNER_H / 2 - 4


# The shadow crept from one step to another: the grass it crossed dies, and it reaches for the nearest crops.
func _blight(from: int, to: int) -> String:
	var hit := 0
	for s in range(from + 1, to + 1):
		var x := _shadow_x_at(s)
		for dx in SHADOW_STEP + 1:
			for dy in [-1, 0, 1]:
				_mark(Vector2i(x + dx, _shadow_y() + dy))
		hit += _blight_crops(BLIGHT_PER_STEP, Vector2i(x, _shadow_y()))
	marks.queue_redraw()
	if hit == 0:
		return " The shadow came closer, and the grass it crossed is dead."
	return " The shadow came closer in the night. A line of dead grass runs from it to your crops, and %d of them have wilted back." % hit


# The n crops nearest a tile wilt back a stage (a seedling dies), with a line of dead grass to each.
func _blight_crops(n: int, from: Vector2i) -> int:
	var near: Array = m.crops.keys()
	near.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return from.distance_squared_to(a) < from.distance_squared_to(b))
	var hit := 0
	for pos in near:
		if hit >= n:
			break
		var steps := maxi(absi(pos.x - from.x), absi(pos.y - from.y))
		for i in steps + 1:
			_mark(Vector2i(from) + Vector2i((Vector2(pos - from) * float(i) / float(maxi(1, steps))).round()))
		if not _peck(pos):
			m.crops.erase(pos)
		hit += 1
	m.stats["blighted"] = int(m.stats.get("blighted", 0)) + hit   # Only a Field (AchievementSystem)
	marks.queue_redraw()
	return hit


func _mark(t: Vector2i) -> void:
	if m._in_bounds(t) and m.map[t.y][t.x] in [MainGame.Tile.GRASS, MainGame.Tile.SOIL, MainGame.Tile.FALLOW, MainGame.Tile.PATH]:
		blight[t] = m.day


# Each morning the oldest blight fades away.
func _morning() -> void:
	for t in blight.keys():
		if m.day - int(blight[t]) >= BLIGHT_DAYS:
			blight.erase(t)
	marks.queue_redraw()


# --- Drawing ------------------------------------------------------------------------------------

# The blight: a grey-brown wash, dead blades and black specks, fading as it ages.
func _draw_marks() -> void:
	var px := float(m.PX)
	for t in blight:
		var a := clampf(1.0 - float(m.day - int(blight[t])) / BLIGHT_DAYS, 0.2, 1.0)
		var c := m._tile_center(t.x, t.y)
		marks.draw_rect(Rect2(c - Vector2(px, px) * 0.46, Vector2(px, px) * 0.92), Color(0.13, 0.11, 0.1, 0.42 * a))
		var h := hash(t)
		for k in 4:
			var p := c + Vector2(float((h >> (k * 4)) % 13) - 6.0, float((h >> (k * 4 + 2)) % 13) - 6.0) * px / 16.0
			marks.draw_line(p, p + Vector2(float(k % 3) - 1.0, -3.0) * px / 16.0, Color(0.36, 0.31, 0.22, 0.85 * a), 2.0)
			marks.draw_rect(Rect2(p + Vector2(4, 2), Vector2(3, 3)), Color(0.04, 0.03, 0.04, 0.7 * a))


# The figures and the lights in the pond. Eyes use colours past 1.0, so they stay bright under the night tint.
func _draw() -> void:
	var ci := layer
	var px := float(m.PX)
	if raid_live and raid_tile.x >= 0:
		_draw_raider(m._tile_center(raid_tile.x, raid_tile.y))
	if not _active():
		return
	if mode == "crows":
		for c in crow_at:
			if str(c["state"]) == "down":
				var t: Vector2i = c["tile"]
				_draw_crow(m._tile_center(t.x, t.y) + Vector2(0, -px * 0.1), 1.0)
		return
	if mode == "steps" and not m.inside:
		# Pale wet prints circle you, closer as the footsteps gain.
		var r := lerpf(4.0, 1.1, clampf(dread, 0.0, 1.0)) * px
		var spin := m.current_hour * 40.0
		for k in 6:
			var a := spin + TAU * float(k) / 6.0
			var p: Vector2 = m.player.position + Vector2(cos(a), sin(a) * 0.7) * r
			ci.draw_circle(p, 3.0, Color(1.3, 1.4, 1.7, 0.35 + 0.5 * dread))
			ci.draw_circle(p + Vector2(4, -5).rotated(a), 2.0, Color(1.3, 1.4, 1.7, 0.35 + 0.5 * dread))
		return
	if visitor_tile.x < 0:
		return
	var s := m._tile_center(visitor_tile.x, visitor_tile.y)
	var head := 0.75
	match str(visitor["id"]):
		"field", "first", "watcher", "knock":
			var tall := 1.6 if visitor["id"] == "watcher" else 1.0
			head = 0.78 * tall
			ci.draw_colored_polygon(PackedVector2Array([s + Vector2(-px * 0.35, px * 0.4), s + Vector2(px * 0.35, px * 0.4), s + Vector2(px * 0.2, -px * 0.7 * tall), s + Vector2(-px * 0.2, -px * 0.7 * tall)]), Color(0.02, 0.01, 0.05, 0.92))
			ci.draw_circle(s + Vector2(0, -px * 0.75 * tall), px * 0.26, Color(0.02, 0.01, 0.05, 0.92))
			ci.draw_circle(s + Vector2(-5, -px * 0.78 * tall), 2.5, Color(3.0, 0.3, 0.2))
			ci.draw_circle(s + Vector2(5, -px * 0.78 * tall), 2.5, Color(3.0, 0.3, 0.2))
		"hollow", "sighting":
			# Twice the farmer's height, ragged at the edges like a cloud of crows.
			head = 1.4
			for k in 7:
				var a := TAU * float(k) / 7.0
				ci.draw_circle(s + Vector2(cos(a) * px * 0.45, -px * 0.9 + sin(a) * px * 0.9), px * 0.42, Color(0.02, 0.01, 0.04, 0.9))
			ci.draw_circle(s + Vector2(-7, -px * 1.4), 3.5, Color(3.0, 0.3, 0.2))
			ci.draw_circle(s + Vector2(7, -px * 1.4), 3.5, Color(3.0, 0.3, 0.2))
		"pond":
			# The lights swell and fade; brightest is the moment to reach in.
			var b := _pulse()
			for k in 3:
				var off := Vector2(sin(k * 2.1), cos(k * 1.7)) * px * (0.3 - 0.12 * b)
				ci.draw_circle(s + off, px * (0.1 + 0.03 * k + 0.08 * b), Color(1.6, 1.9, 2.0, 0.3 + 0.6 * b))
			if b >= PULSE_TOP:
				ci.draw_arc(s, px * 0.6, 0.0, TAU, 24, Color(1.6, 1.9, 2.0, 0.5), 2.0)
	# How far the hold has come: a pale ring filling round its head.
	if mode == "hold" and prog > 0.0:
		var c := s + Vector2(0, -px * head)
		ci.draw_arc(c, px * 0.5, -PI / 2.0, -PI / 2.0 + TAU * prog, 32, Color(2.0, 1.7, 0.9, 0.85), 3.0)
	elif mode == "pulse" and prog > 0.0:
		for k in roundi(prog * PULSE_NEED):
			ci.draw_circle(s + Vector2(-8 + 8 * k, -px * 0.7), 3.0, Color(1.6, 1.9, 2.0, 0.9))


# A crow, black with a bright eye, standing on its tile.
func _draw_crow(p: Vector2, size: float) -> void:
	var ci := layer
	var px := float(m.PX) * size
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-px * 0.3, 0), p + Vector2(px * 0.15, -px * 0.22), p + Vector2(px * 0.28, 0), p + Vector2(0, px * 0.1)]), Color(0.03, 0.02, 0.05, 0.95))
	ci.draw_circle(p + Vector2(px * 0.2, -px * 0.22), px * 0.11, Color(0.03, 0.02, 0.05, 0.95))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(px * 0.29, -px * 0.25), p + Vector2(px * 0.42, -px * 0.2), p + Vector2(px * 0.29, -px * 0.17)]), Color(0.25, 0.22, 0.2))
	ci.draw_circle(p + Vector2(px * 0.23, -px * 0.25), 1.6, Color(2.4, 2.2, 1.6))


# Tonight's raider: the fox low and russet, the crows on the coop roof, something low and dark at the barn.
func _draw_raider(p: Vector2) -> void:
	var ci := layer
	var px := float(m.PX)
	match raid:
		"fox":
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-px * 0.35, px * 0.1), p + Vector2(px * 0.25, px * 0.05), p + Vector2(px * 0.3, -px * 0.12), p + Vector2(-px * 0.3, -px * 0.1)]), Color(0.55, 0.26, 0.12))
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(px * 0.22, -px * 0.08), p + Vector2(px * 0.45, -px * 0.05), p + Vector2(px * 0.3, -px * 0.3)]), Color(0.6, 0.3, 0.14))
			ci.draw_line(p + Vector2(-px * 0.33, -px * 0.02), p + Vector2(-px * 0.6, -px * 0.2), Color(0.6, 0.3, 0.14), 5.0)
			ci.draw_circle(p + Vector2(-px * 0.62, -px * 0.22), 2.5, Color(0.9, 0.85, 0.75))
			ci.draw_circle(p + Vector2(px * 0.34, -px * 0.14), 1.8, Color(2.6, 2.2, 0.6))
		"crows":
			for k in 3:
				_draw_crow(p + Vector2(-px * 0.6 + px * 0.6 * k, -px * 0.9 - px * 0.1 * (k % 2)), 0.9)
		"barn":
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-px * 0.45, px * 0.15), p + Vector2(px * 0.45, px * 0.15), p + Vector2(px * 0.35, -px * 0.2), p + Vector2(-px * 0.35, -px * 0.25)]), Color(0.03, 0.02, 0.04, 0.92))
			ci.draw_circle(p + Vector2(px * 0.12, -px * 0.12), 2.0, Color(2.8, 0.4, 0.2))
			ci.draw_circle(p + Vector2(px * 0.26, -px * 0.12), 2.0, Color(2.8, 0.4, 0.2))


# --- The crow charm: crow feathers made into something useful -------------------------------------

func _can_make_charm() -> bool:
	return m.progression._level("Bushcrafting") >= int(CHARM["level"]) \
		and int(m.materials["feathers"]) >= int(CHARM["feathers"]) and int(m.materials["sticks"]) >= int(CHARM["sticks"])


func _charm_recipe() -> Dictionary:
	var costs: Array = [
		{"label": "%d crow feathers" % int(CHARM["feathers"]), "have": m._held("feathers"), "need": int(CHARM["feathers"])},
		{"label": "%d stick" % int(CHARM["sticks"]), "have": m._held("sticks"), "need": int(CHARM["sticks"])},
	]
	return {
		"key": "crow_charm", "name": str(CHARM["name"]), "icon": "pendant", "tint": FEATHER_TINT,
		"desc": "Feathers bound on a twig. Carried at 22:00, it is used up and halves what the night takes from your sanity. +%d Bushcrafting XP." % int(CHARM["xp"]),
		"costs": costs, "level_text": m._level_text("Bushcrafting", int(CHARM["level"])),
		"level_ok": m.progression._level("Bushcrafting") >= int(CHARM["level"]), "enabled": _can_make_charm(),
		"action": "make_charm", "button": "Make",
	}


func _make_charm() -> void:
	if not _can_make_charm():
		m._show_message("A crow charm needs %d crow feathers, %d stick and Bushcrafting %d." % [int(CHARM["feathers"]), int(CHARM["sticks"]), int(CHARM["level"])])
		return
	m.materials["feathers"] -= int(CHARM["feathers"])
	m.materials["sticks"] -= int(CHARM["sticks"])
	m.inventory["crow_charm"] += 1
	m.progression._grant_xp("Bushcrafting", int(CHARM["xp"]))
	m.play_sfx("craft", 0.05)
	m._show_message("You bind the feathers into a charm. It feels warmer than it should. +%d Bushcrafting XP" % int(CHARM["xp"]))
