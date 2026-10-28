class_name NightSystem
extends RefCounted

# The nights: at 22:00 something happens on the farm, and the player chooses what to do about it. Facing
# it (walking up and pressing Space, opening the door, running for the house) costs a little sanity now
# but leaves crow feathers and pushes the field shadow back. Ignoring it until 01:00, or sleeping through
# it, costs more, and the shadow creeps closer. When the shadow reaches the house, the Hollow comes to
# the door. Which visitors can come grows with the nights lived, so the second week is not the first.

var m: MainGame

const END_HOUR := 25.0          # 01:00: an encounter left alone resolves as ignored
const FOOTSTEPS_HOURS := 1.0    # the footsteps give an hour to reach the house
const SHADOW_MAX := 8           # steps from the field's far edge to the house; at the last, the Hollow comes
const SHADOW_STEP := 4          # tiles the shadow moves per step
const TIER_NIGHTS := [0, 7, 14] # nights lived before each tier of visitors can come
const CHARM := {"name": "Crow charm", "feathers": 4, "sticks": 1, "level": 2, "xp": 6}
const FEATHER_TINT := "2a2632"
# How to answer each visitor, added to its message until the player has faced a few.
const HINTS := {
	"field": "Walk up to it and press Space to face it, or leave it be.",
	"knock": "Open the door to answer it, or stay in.",
	"crows": "Shout them off from under the tree, or leave them.",
	"pond": "Reach in from the bank, or leave them.",
	"watcher": "Walk up to it to face it, or leave it be.",
	"hollow": "Face it, or wait for morning.",
}
const HINT_UNTIL := 3       # faced visitors before the hints stop

# Each visitor: its tier, where it appears, the sound and message when it comes, and what facing or
# ignoring it does. sanity values are losses; push moves the shadow back, creep moves it closer.
const VISITORS := [
	{"id": "field", "tier": 0, "where": "field", "sound": "sting",
		"appear": "Something stands at the edge of the field, facing the house.",
		"face": "You walk out to it. It folds into the dark, and a black feather turns in the grass where it stood.",
		"face_sanity": 4, "feathers": 1, "push": 1,
		"ignore": "The thing at the field's edge is gone by one o'clock. It came a little closer first.",
		"ignore_sanity": 6, "creep": 1},
	{"id": "knock", "tier": 0, "where": "none", "sound": "knock",
		"appear": "Three slow knocks on the front door.",
		"face": "You open the door. Nobody. Wet prints lead off toward the field, and a feather is caught in the latch.",
		"face_sanity": 5, "feathers": 1, "push": 1,
		"ignore": "The knocking stopped. Something walked away slowly through the crops.",
		"ignore_sanity": 8, "creep": 1},
	{"id": "quiet", "tier": 0, "where": "none", "sound": "hush",
		"appear": "The farm is quiet tonight. Too quiet.",
		"ignore": "", "ignore_sanity": 3, "creep": 0},
	{"id": "crows", "tier": 1, "where": "tree", "sound": "crow",
		"appear": "Every crow in the great tree is awake, and every one is staring at your crops.",
		"face": "You clap and shout under the branches. The crows burst up into the dark, shedding feathers.",
		"face_sanity": 6, "feathers": 3, "push": 0,
		"ignore": "The crows came down in the night.",
		"ignore_sanity": 2, "creep": 0},
	{"id": "pond", "tier": 1, "where": "pond", "sound": "whisper",
		"appear": "Pale lights are drifting under the pond's surface.",
		"face": "You reach in after the lights. Something cold closes around your hand, then lets go of a fish.",
		"face_sanity": 8, "feathers": 0, "push": 0,
		"ignore": "The lights in the pond went out one by one.",
		"ignore_sanity": 3, "creep": 0},
	{"id": "watcher", "tier": 1, "where": "house", "sound": "sting",
		"appear": "A tall figure is watching from beside the house.",
		"face": "You round the corner of the house. It is taller up close. Then it is gone, and feathers drift down.",
		"face_sanity": 12, "feathers": 2, "push": 2,
		"ignore": "The figure by the house stood there until one o'clock. You felt it the whole time.",
		"ignore_sanity": 15, "creep": 1},
	{"id": "footsteps", "tier": 2, "where": "none", "sound": "steps_behind", "outdoors": true,
		"appear": "Footsteps behind you, matching yours. Don't look back. Get inside.",
		"face": "You slam the door. The footsteps stop right at the threshold.",
		"face_sanity": 4, "feathers": 0, "push": 1,
		"ignore": "The footsteps caught up with you in the dark.",
		"ignore_sanity": 15, "creep": 1},
]
const HOLLOW := {"id": "hollow", "where": "door", "sound": "heartbeat",
	"appear": "The Hollow has come to your door.",
	"face": "You step up to the Hollow and look into it. It shrieks and comes apart into a hundred crows. The field is clear again.",
	"face_sanity": 20, "feathers": 5,
	"ignore": "The Hollow waited at the door until morning. Something in your mind gave way.",
	"ignore_sanity": 30, "limit": 5}
# The first night is always the same short scare, so a new player meets the dark, their sanity and the bed
# before the random visitors start. It plays out in beats (game hours after 22:00, about 20 seconds each):
# the farm goes quiet, steps or knocks, the figure at the field's edge, then a nudge toward the bed.
const FIRST := {"id": "first", "where": "field", "sound": "hush",
	"appear": "The crows have stopped calling. The whole farm has gone quiet.",
	"face": "You walk out to it. It folds into the dark, and a black feather turns in the grass where it stood.",
	"face_sanity": 2, "feathers": 1, "push": 0,
	"ignore": "Something walked the farm in the night. There are prints at the field's edge, and they lead to the house.",
	"ignore_sanity": 3, "creep": 0}
const FIRST_BEATS := [0.0, 0.4, 0.9, 1.5]

var shadow_steps := 0       # saved: how far the field shadow has crept toward the house
var last_visitor := ""      # saved: last night's visitor, so the same one doesn't come twice in a row
var visitor: Dictionary = {}    # tonight's, while it waits for an answer
var visitor_tile := Vector2i(-1, -1)
var visitor_end := END_HOUR
var first_beat := -1        # the first night's next beat while it plays out, -1 otherwise
var first_start := 0.0
var charmed := false        # a crow charm was used up tonight: losses are halved
var layer: Node2D           # the visitors, drawn over the farm's buildings
var light: PointLight2D     # a faint glow at the visitor, red for the figures, pale for the pond


func _init(main: MainGame) -> void:
	m = main


# The visitors' own layer and light, made once the farm is built.
func _build() -> void:
	layer = Node2D.new()
	layer.z_index = 20
	layer.draw.connect(_draw)
	m.add_child(layer)
	light = PointLight2D.new()
	light.texture = m._glow_texture()
	light.texture_scale = 0.9
	light.energy = 0.9
	light.enabled = false
	m.add_child(light)


# Shows tonight's visitor, or clears it once it is answered.
func _show_visitor() -> void:
	var lit := _active() and visitor_tile.x >= 0 and str(visitor["id"]) in ["field", "first", "watcher", "hollow", "pond"]
	light.enabled = lit
	if lit:
		# The glow sits at eye height, so the eyes and the outline around them show in the dark.
		var eyes := {"field": 0.75, "first": 0.75, "watcher": 1.2, "hollow": 1.4, "pond": 0.0}
		light.position = m._tile_center(visitor_tile.x, visitor_tile.y) + Vector2(0, -m.PX * float(eyes[visitor["id"]]))
		light.color = Color(0.7, 0.9, 1.0) if visitor["id"] == "pond" else Color(1.0, 0.18, 0.12)
		light.texture_scale = 1.8 if visitor["id"] == "hollow" else 0.9
		light.energy = 1.6 if visitor["id"] == "hollow" else 0.9
	layer.queue_redraw()


func _tier() -> int:
	var tier := 0
	for i in TIER_NIGHTS.size():
		if int(m.stats["events"]) >= int(TIER_NIGHTS[i]):
			tier = i
	return tier


func _active() -> bool:
	return not visitor.is_empty()


# 22:00: tonight's visitor arrives. force names one, for checking it (tools/capture.gd).
func _begin(force := "") -> void:
	if (force == "" and _first_night()) or force == "first":
		_begin_first()
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
	if int(m.inventory["crow_charm"]) > 0:
		m.inventory["crow_charm"] -= 1
		charmed = true
		note = " Your crow charm grows warm."
	m.ambience.night_event(str(visitor["sound"]))
	if int(m.stats["faced"]) < HINT_UNTIL and HINTS.has(visitor["id"]):
		note += " " + str(HINTS[visitor["id"]])
	m._show_message(str(visitor["appear"]) + note)
	_show_visitor()
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
			m.tonight_shadow = visitor_tile
			m.ambience.night_event("sting")
			_show_visitor()
			if out:
				m._show_message("Something stands at the edge of the field, facing the house. " + str(HINTS["field"]))
			else:
				m._show_message("Through the window: something is standing at the edge of the field, facing the house.")
		elif beat == 3:
			m.ambience.night_event("whisper")
			var text := "The dark wears at your Sanity while you're out in it. Get inside and go to bed: sleep puts it right." 				if out else "Stay in tonight, and go to bed: the house and sleep put your Sanity right."
			if m.lantern_tier == 0:
				text += " A lantern would light the way. Build one before tomorrow night."
			m._show_message(text)


func _pick() -> Dictionary:
	# The night the crow bell is hung, the Hollow comes to it one last time. Once Agnes is walked to the grove,
	# it sleeps and never comes again.
	if (shadow_steps >= SHADOW_MAX and not m.trek.grove_done) or m.projects.bell_day == m.day:
		return HOLLOW
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
		"tree":
			return m._world_tile(m.BIG_TREE_INNER.x + 1, m.BIG_TREE_INNER.y + 1)
		"pond":
			return m.pond_edges[hash([m.day, "pond"]) % m.pond_edges.size()]
	return Vector2i(-1, -1)


# Each frame: an encounter not answered in time counts as ignored.
func _update() -> void:
	_update_first()
	if _active() and m.current_hour >= visitor_end:
		_resolve(false)


# Space on the farm: walking up to a visitor faces it. Returns true when the press was used.
func _try_face(tile: Vector2i) -> bool:
	if not _active():
		return false
	var hit := false
	match str(visitor["id"]):
		"field", "first", "watcher", "hollow":
			hit = tile == visitor_tile
		"crows":
			hit = m._in_big_tree(tile)
		"pond":
			hit = m.map[tile.y][tile.x] == MainGame.Tile.WATER and absi(tile.x - visitor_tile.x) <= 1 and absi(tile.y - visitor_tile.y) <= 1
	if hit:
		_resolve(true)
	return hit


# Opening the front door answers the knocking.
func _on_leave_house() -> void:
	if _active() and visitor["id"] == "knock":
		_resolve(true)


# Reaching the house escapes the footsteps.
func _on_enter_house() -> void:
	if _active() and visitor["id"] == "footsteps":
		_resolve(true)


# Bed (or a collapse) ends the night. A visitor still waiting counts as ignored, and its note joins the
# morning message. Going to bed before 22:00 doesn't dodge it: tonight's visitor comes to a sleeping house.
func _end_night() -> String:
	first_beat = -1
	if not _active():
		if m.event_fired_day == m.day:
			return ""
		var first := _first_night()
		m.event_fired_day = m.day
		m.stats["events"] += 1
		visitor = FIRST if first else _pick()
		charmed = false
		if int(m.inventory["crow_charm"]) > 0:
			m.inventory["crow_charm"] -= 1
			charmed = true
	return " " + _resolve(false, false)


func _resolve(faced: bool, show := true) -> String:
	var v := visitor
	visitor = {}
	last_visitor = str(v["id"])
	m.mystery._on_visitor(str(v["id"]), faced)
	m.tonight_shadow = Vector2i(-1, -1)
	_show_visitor()
	var text := str(v["face"] if faced else v["ignore"])
	var loss := float(v["face_sanity"] if faced else v["ignore_sanity"])
	loss *= (2.0 if m.sanity_sys._event_active("dread") else 1.0) * (0.5 if m.sanity_sys._event_active("ward") else 1.0)
	loss *= 0.5 if charmed else 1.0
	loss *= m.projects._night_mult()   # the crow bell
	loss *= m.estate._night_mult()     # the second storey
	loss *= m.trek._night_mult()       # walked someone today, the wood come close, or the Hollow asleep
	loss *= m.NIGHT_LOSS_MULT
	m.sanity_sys._change_sanity(-loss)
	if faced:
		m.stats["faced"] += 1
		var feathers := int(v.get("feathers", 0))
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
			text += " " + _crows_peck()
		if v["id"] == "hollow":
			m.sanity_penalty += int(v["limit"])
			m.sanity = minf(m.sanity, m.sanity_sys._sanity_max())
			shadow_steps = SHADOW_MAX / 2
		else:
			# While the crow bell stands, the shadow stops a step short of the house.
			shadow_steps = mini(SHADOW_MAX - (1 if m.projects._has_bell() else 0), shadow_steps + int(v.get("creep", 0)))
	# While the wood is close it pushes the shadow a step nearer every night, whatever the visitor.
	if m.trek._wood_close() and v["id"] != "hollow":
		shadow_steps = mini(SHADOW_MAX - (1 if m.projects._has_bell() else 0), shadow_steps + 1)
	# Once the Hollow sleeps, the field has no shadow.
	if m.trek.grove_done:
		shadow_steps = 0
	if show and text != "":
		m._show_message(text)
	return text


# Left alone, the crows set back up to three growing crops by a stage.
func _crows_peck() -> String:
	var hit := 0
	for pos in m.crops:
		if hit >= 3:
			break
		if int(m.crops[pos]["stage"]) > 0:
			# Growth days go back to the start of the lower stage too, or the next watered night undoes it.
			var stage := int(m.crops[pos]["stage"]) - 1
			m.crops[pos]["stage"] = stage
			m.crops[pos]["days"] = ceili(float(stage * int(m.CROP_GROW_DAYS[str(m.crops[pos]["kind"])])) / m.MAX_STAGE)
			hit += 1
	if hit == 0:
		return "They found nothing worth taking."
	return "%d crop%s pecked back a stage." % [hit, "" if hit == 1 else "s"]


# The shadow's place for the coming night: it starts at the far east of the field and steps toward the house.
func _shadow_x() -> int:
	return maxi(m.BORDER_X + m.INNER_W - 2 - shadow_steps * SHADOW_STEP, m.BORDER_X + m.HOUSE_IX + m.HOUSE_W + 1)


# The figures and the lights in the pond. Eyes use colours past 1.0, so they stay bright under the night tint.
func _draw() -> void:
	if not _active() or visitor_tile.x < 0:
		return
	var ci := layer
	var s := m._tile_center(visitor_tile.x, visitor_tile.y)
	var px := float(m.PX)
	match str(visitor["id"]):
		"field", "first", "watcher":
			var tall := 1.6 if visitor["id"] == "watcher" else 1.0
			ci.draw_colored_polygon(PackedVector2Array([s + Vector2(-px * 0.35, px * 0.4), s + Vector2(px * 0.35, px * 0.4), s + Vector2(px * 0.2, -px * 0.7 * tall), s + Vector2(-px * 0.2, -px * 0.7 * tall)]), Color(0.02, 0.01, 0.05, 0.92))
			ci.draw_circle(s + Vector2(0, -px * 0.75 * tall), px * 0.26, Color(0.02, 0.01, 0.05, 0.92))
			ci.draw_circle(s + Vector2(-5, -px * 0.78 * tall), 2.5, Color(3.0, 0.3, 0.2))
			ci.draw_circle(s + Vector2(5, -px * 0.78 * tall), 2.5, Color(3.0, 0.3, 0.2))
		"hollow":
			# Twice the farmer's height, ragged at the edges like a cloud of crows.
			for k in 7:
				var a := TAU * float(k) / 7.0
				ci.draw_circle(s + Vector2(cos(a) * px * 0.45, -px * 0.9 + sin(a) * px * 0.9), px * 0.42, Color(0.02, 0.01, 0.04, 0.9))
			ci.draw_circle(s + Vector2(-7, -px * 1.4), 3.5, Color(3.0, 0.3, 0.2))
			ci.draw_circle(s + Vector2(7, -px * 1.4), 3.5, Color(3.0, 0.3, 0.2))
		"pond":
			for k in 3:
				var off := Vector2(sin(k * 2.1), cos(k * 1.7)) * px * 0.3
				ci.draw_circle(s + off, px * (0.12 + 0.03 * k), Color(1.6, 1.9, 2.0, 0.6))


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
