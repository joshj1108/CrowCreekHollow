class_name TrekSystem
extends RefCounted

# Treks into the Rookery Wood (DESIGN.md, Groves and treks). Since Agnes Rook's bell came down nobody from the
# lane crosses the wood alone, so now and then people wait at the gap in the trees north of the house and ask
# to be walked. Each route (ROUTES) has its walker, who waits at their own spot: Space beside one picks that route.
# Old Maren to the mill (first winter), the Tull boy to the drowned orchard (spring), the vicar to the chapel on
# the hill (summer), and once, late in the second autumn after the bell is hung, a woman in a grey shawl to the
# Hollow's grove. The chapel and grove walkers also wait into the evening: set out after 18:00 for a night trek
# (double pay, double the wood's sanity drain).
# - The clearings are laid into the cave's grid (in_cave is set while trekking), so walking, collision, the
#   camera and the minimap work as they do underground. This script lays them out, draws them and runs them.
#   Layouts at FLIP and above are the same clearings mirrored left to right.
# - The walker follows your footsteps. Their nerve falls in the dark, off the trail, far from you, when your own
#   sanity is low, when the crows mob them and when feral dogs are near; it comes back in your lantern's light,
#   with a word, and with a trail ration. At 0 they bolt home and the trek is over.
# - Your lantern burns lamp oil in the wood, a flask every FLASK_SECONDS. Without oil it goes out.
# - The clock runs slower in the wood (TIME_SCALE), so a trek of a few minutes takes a few hours.
# - The trail forks at the top of the first clearing: the marked trail (a clearing longer, gentler events) or
#   the dark trail (harder events, better pay). The fingerpost reads with Bushcrafting (_can_read_sign), or
#   with the Waymarks trail work. Which arm is which changes with the day.
# - Events, one a clearing before the end, picked by the day and season (_plan): a fallen tree, the crows,
#   a flooded hollow (a rope across, or wade at a warmth cost), lights off the path, a cairn of crow skulls,
#   a fog bank (a Brass Lantern finds the way, or wait), a hollow tree with something in it, and (past the mill
#   path) feral dogs, fought with the cave's combat. The seasons change the odds, the gloom and the cold.
# - From the second clearing, the tall one walks the trees and comes for the walker. Your lantern drives it back.

var m: MainGame

const WALKER_SPOT := Vector2i(25, 1)  # inner farm tile at the north edge, above the house, where walkers wait
const FROM_DAY := 62                  # walkers come from the first winter (December 1st)
const COME_EVERY := 3                 # about one day in this many
const START_BY := 15.0                # a trek must start by 15:00; the walker gives up waiting then
const CONFIRM_SECONDS := 4.0          # press Space again within this to set out (or to wade)
const FLASK_SECONDS := 75.0           # real seconds one flask of lamp oil burns in the wood
const TIME_SCALE := 0.25              # the clock runs this fast in the wood
const GLOOM := 0.6                    # how dark the wood is by day, as a share of night
const NERVE_START := 70.0
const RATION_NERVE := 35.0
const WORD_NERVE := 10.0
const RATION_BELOW := 70.0            # the walker takes a ration when their nerve is under this
const FOLLOW_GAP := 1.3               # tiles the walker keeps behind you
const WALKER_SPEED := 2.6             # tiles a second: slower than you, so you wait for them
const FREEZE_BELOW := 25.0            # under this nerve the walker stops and won't go on without a ration
const UNFREEZE_AT := 35.0
const SANITY_DRAIN := 0.1             # sanity lost a second in the wood, twice that unlit
const FAIL_SANITY := 10.0             # sanity lost when the walker breaks and runs
const CROW_RADIUS := 3.0              # tiles around the crows' spot where they first find the walker
const CROW_WAVES := 3                 # times the crows must be driven off before they give up
const CROW_RETURN := 8.0              # seconds before driven-off crows come back
const CROW_SANITY := 3.0
const REWARD_XP := 60

# The wood learns you. Each trek you finish raises its dread by one, up to MAX_DREAD: the walker's nerve wears
# faster even in your light, the tall one comes sooner, faster and more often (from the first clearing at dread 2),
# and the crows need driving off more times. The pay rises with it.
const MAX_DREAD := 6
const DREAD_NERVE := 0.08             # extra nerve lost a second in your light, per dread
const DREAD_TALL_SPEED := 0.15        # extra tiles a second for the tall one, per dread
const DREAD_XP := 15                  # extra Bushcrafting XP on arriving, per dread
const CHOP_WOOD := 2

# The tall one: from the second clearing it walks through the trees toward the walker, faster out of your light.
# Turn and face it (Space within TALL_REACH) to drive it off. If it reaches them, their nerve breaks a long way.
const TALL_FROM := 1                  # first clearing it walks
const TALL_DELAY := 8.0               # seconds into a clearing before it first shows
const TALL_SPEED := 1.6               # tiles a second toward the walker in your light
const TALL_DARK_SPEED := 2.4          # ... and out of it
const TALL_REACH := 3.0               # tiles: Space this close drives it off
const TALL_TOUCH := 0.9               # tiles: this close and it reaches the walker
const TALL_NERVE := 30.0
const TALL_BACK := 9.0                # seconds it stays back after reaching the walker or being driven off
const TALL_SANITY := 3.0              # sanity lost driving it back with Space

# Nerve change a second. The wood always wears on them; the lantern only slows it.
const NERVE_LIT := -0.4
const NERVE_DARK := -2.0
const NERVE_OFF_TRAIL := -1.5          # while you or the walker are off the trail (grass, or the way round)
const NERVE_FAR := -3.0
const NERVE_LOW_SANITY := -1.0
const NERVE_CROWS := -5.0
const NERVE_LIGHTS := -0.8            # while the walker is near the lights off the path
const LIGHT_GRACE := 1.0              # tiles past the lantern's ring that still count as in its light

# The fork. The marked trail is a clearing longer with gentler events; the dark trail is shorter, darker and
# harder, and pays better. Event severity is scaled by _harsh(): marked 0.7, dark 1.4, the rest 1.
const SIGN_LEVEL := 3                 # Bushcrafting that reads the fingerpost (or the Waymarks trail work)
const GLOOM_DARK := 0.72              # how dark the dark trail is by day
const DARK_SANITY := 1.5              # the wood's sanity drain is this much faster there
const DARK_TALL_SPEED := 0.3          # extra tiles a second for the tall one there
const DARK_TALL_SOONER := 3.0         # seconds sooner it shows there
const DARK_XP := 30                   # extra Bushcrafting XP for arriving by the dark trail
const DARK_FEATHERS := 1

# The flooded hollow: tie a rope across, or wade (warmth, far more in winter, and the walker's nerve).
# The mill footbridge trail work makes the hollows dry (_hollows_dry).
const ROPE := {"name": "Rope", "fiber": 2, "level": 3, "xp": 6}
const ROPE_XP := 10                   # Bushcrafting XP for roping a crossing
const WADE_WARMTH := 10.0
const WADE_WINTER := 3.5              # wading costs this many times the warmth in winter
const WADE_NERVE := 10.0
# The fog bank: a Brass Lantern or better finds the way through; otherwise wait for it to thin.
const FOG_LANTERN := 2                # lantern tier
const FOG_WAIT := 18.0                # seconds after you reach it (times _harsh)
# The lights off the path: follow them for a shortcut to the way on, or be lost an hour and back at the start.
const LIGHTS_REACH := 3.5
const LIGHTS_SHORTCUT := 0.5          # chance they lead you true
const LOST_NERVE := 20.0
const LOST_SANITY := 5.0
const LOST_OIL := 30.0                # seconds of oil burned while lost
# The cairn of crow skulls: leave coins or a ration, or walk past and the walker takes it badly.
const CAIRN_COINS := 5
const CAIRN_SANITY := 6.0
const CAIRN_NERVE := 15.0
const CAIRN_SNUB := 10.0
# The hollow tree: a feather bundle, old coins, or a nest of bones. Better on the dark trail. While one of
# Agnes's pages from the wood waits on this route (Mystery._next_trek_page), it holds that instead this often.
const HOLLOW_PAGE := 0.5
const HOLLOW_FEATHERS := 3
const HOLLOW_COINS := Vector2i(6, 12)
const HOLLOW_DARK_BONUS := 2          # on the dark trail: this many more feathers, or this many times the coins
const BONES_SANITY := 4.0
const BONES_NERVE := 8.0
const EVENT_NEAR := 4.0               # tiles: coming this close to an event says what it is

# Which events each part of the route can draw (the day picks, with no repeats on a route until the pool runs
# out). Each route adds its own ("extra"). Summer dries the hollows and burns off the fog; the other seasons make
# some events likelier (SEASON_MORE counts them twice), shift the wood's gloom, and winter is cold.
const EDGE_EVENTS := ["tree", "crows", "flood", "cairn", "hollow"]
const MARKED_EVENTS := ["tree", "crows", "flood", "cairn", "hollow"]
const DARK_EVENTS := ["crows", "flood", "lights", "fog", "hollow"]
const SEASON_SKIPS := {"Summer": ["flood", "fog"]}
const SEASON_MORE := {"Spring": ["flood", "tree"], "Summer": ["crows", "hollow"], "Autumn": ["fog", "lights"], "Winter": ["dogs", "cairn"]}
const SEASON_GLOOM := {"Spring": 0.0, "Summer": -0.08, "Autumn": 0.04, "Winter": 0.06}
const WINTER_COLD := 0.06             # warmth lost a second in the wood in winter

# Feral dogs (orchard, chapel and grove routes): they wait on the trail and fight with the cave's combat
# (FOES["dog"] in main.gd). Kill them or hurry the walker past; their nerve falls while dogs are near.
const DOGS := 2                       # +1 on the dark trail, +1 in winter
const DOG_NEAR := 4.0                 # tiles from the walker
const NERVE_DOGS := -4.0

# Night treks (chapel and grove routes): set out from NIGHT_FROM. The pay doubles, and so does the wood's sanity
# drain (_night_sanity; the chapel steps trail work lifts it on the chapel route). The tall one walks faster.
const NIGHT_FROM := 18.0
const NIGHT_UNTIL := 22.0             # night walkers give up waiting then
const NIGHT_PAY := 2
const NIGHT_SANITY := 2.0
const NIGHT_TALL_SPEED := 0.3
const NIGHT_OIL := 1                  # a flask more to set out by night

# The Hollow's grove opens late in the second autumn, once the crow bell is hung, and is walked once.
const GROVE_DAY := 381                # October 15th of the second year
# The waystation hut trail work: a rest halfway on the long routes (nerve and warmth back, no oil burned).
const WAYSTATION_MIN := 5             # routes with at least this many clearings have a halfway hut

# Each clearing is a trail through dense wood, given as points [x, y, room]: room is the clearing around the
# trail there (0 keeps it to the trail itself, so a fallen tree blocks it). "event" is the point where an event
# sits, and "detour" is a faint way round it through the trees, off the trail (laid only for a fallen tree).
# "branch" is the second way on at a fork, with its fingerpost at "sign". "trail" marks the clearings past the
# fork. "dest" is where the route ends (the mill, the orchard, the chapel or the grove, drawn by route).
const CLEARINGS := [
	{"points": [[8, 22, 2], [8, 19, 2], [30, 18, 2], [33, 15, 2], [30, 12, 0], [12, 12, 1], [6, 9, 2], [9, 6, 2], [28, 6, 2], [31, 3, 2], [28, 1, 1]],
		"event": 4, "detour": [[33, 15], [37, 13], [36, 9], [26, 9], [24, 12]],
		"branch": [[9, 6, 2], [7, 3, 2], [9, 1, 1]], "sign": [13, 4]},
	{"points": [[30, 22, 2], [30, 19, 2], [8, 19, 2], [5, 16, 2], [8, 13, 0], [25, 13, 0], [32, 10, 2], [28, 7, 2], [10, 6, 2], [7, 3, 2], [10, 1, 1]],
		"event": 4, "detour": [[5, 16], [2, 13], [4, 10], [12, 10], [14, 13]], "trail": "marked"},
	{"points": [[10, 22, 2], [10, 19, 2], [27, 18, 2], [33, 15, 2], [30, 12, 0], [14, 12, 1], [7, 9, 2], [10, 5, 2], [27, 5, 2], [30, 1, 1]],
		"event": 4, "detour": [[33, 15], [37, 13], [36, 9], [26, 9], [24, 12]], "trail": "marked"},
	{"points": [[20, 22, 1], [20, 19, 1], [10, 17, 1], [8, 13, 0], [16, 10, 0], [28, 9, 1], [30, 5, 1], [22, 3, 1], [20, 1, 1]],
		"event": 3, "detour": [[10, 17], [5, 16], [3, 12], [6, 9], [14, 11]], "trail": "dark"},
	{"points": [[20, 22, 2], [20, 19, 3], [8, 17, 3], [6, 12, 3], [14, 9, 3], [24, 10, 3], [33, 9, 2], [32, 5, 2], [22, 4, 3], [20, 1, 1]],
		"event": -1, "detour": [], "dest": Rect2i(24, 1, 6, 3)},
	{"points": [[20, 22, 2], [20, 19, 2], [32, 18, 2], [34, 14, 1], [26, 12, 0], [14, 12, 0], [6, 10, 2], [8, 6, 2], [24, 5, 2], [22, 1, 1]],
		"event": 4, "detour": [[32, 16], [28, 14], [21, 14], [19, 12]], "trail": "marked"},
	{"points": [[18, 22, 1], [18, 19, 1], [30, 17, 1], [33, 13, 0], [24, 10, 0], [12, 9, 1], [8, 5, 1], [16, 3, 1], [18, 1, 1]],
		"event": 3, "detour": [[31, 17], [36, 15], [36, 11], [29, 9], [27, 10]], "trail": "dark"},
]
const FLIP := 100                     # a layout index FLIP + i is clearing i mirrored left to right
const MARKED_ROUTE := [0, 1, 2, 4]    # the mill path's clearings by the marked trail
const DARK_ROUTE := [0, 3, 4]         # ... and by the dark trail

# The routes. "spot" is where the walker waits (an inner farm tile at the north edge). "level" is the
# Bushcrafting the walker asks for, "oil" the lamp oil needed to set out by day. "feathers" and "xp" are the
# base pay on arriving (dread, the dark trail and the night add to it). "talk" is a line a clearing (the last
# line at the end), and the {w} {W} {she} {She} {her} {his} tokens in messages name the walker (see _w).
const ROUTES := {
	"mill": {"walker": "Old Maren", "short": "Maren", "she": "she", "her": "her", "his": "her", "to": "the mill",
		"from": FROM_DAY, "level": 0, "oil": 1, "xp": REWARD_XP, "feathers": 0, "spot": Vector2i(25, 1), "night": false,
		"marked": MARKED_ROUTE, "dark": DARK_ROUTE, "extra": [],
		"talk": [
			"\"My sister's at the mill. We used to cross this wood every Sunday, before.\"",
			"\"Agnes rang that bell every night. The town said it kept them awake. It kept something else awake, I think.\"",
			"\"Elias Rook cut these marks, the spring before he went. He said the trees would forget the way if we let them.\"",
			"\"They took the bell down at the mill, you know. Held the meeting right there. I voted with them. I was afraid.\""],
		"arrive": "Maren's sister opens the mill door before you knock. Maren presses a paper of seed and a black feather into your hand. \"You'll walk me again?\""},
	"orchard": {"walker": "the Tull boy", "short": "Davy", "she": "he", "her": "him", "his": "his", "to": "the drowned orchard",
		"from": 152, "level": 4, "oil": 2, "xp": 120, "feathers": 1, "spot": Vector2i(22, 1), "night": false,
		"marked": [0, 1, 5, FLIP + 2, 4], "dark": [0, 3, 6, 4], "extra": ["dogs"],
		"talk": [
			"\"Pip ran off after the wild dogs at harvest. Ma says he's gone feral with them. I'd know his bark anywhere.\"",
			"\"Elias Rook planted the orchard for Agnes. Grandad says it flooded the year she went, all at once, like the ground gave up.\"",
			"\"There's still apples on the drowned trees in autumn. Nobody picks them. Nobody's that hungry.\"",
			"\"Do you hear that? No. Never mind.\" He whistles two notes and listens.",
			"\"This is it. Pip liked it here. He used to chase the ducks off the water.\""],
		"arrive": "The drowned orchard: black water standing between the apple trees, and no ducks now. Davy whistles his two notes until his lips give out. Nothing comes. He gives you what his mother sent and says he'll look again."},
	"chapel": {"walker": "the vicar", "short": "the vicar", "she": "he", "her": "him", "his": "his", "to": "the chapel on the hill",
		"from": 244, "level": 5, "oil": 2, "xp": 200, "feathers": 2, "spot": Vector2i(28, 1), "night": true,
		"marked": [0, FLIP + 1, 5, 2, FLIP + 5, 4], "dark": [0, 3, 6, FLIP + 3, 4], "extra": ["dogs"],
		"talk": [
			"\"I hold a service at the chapel once a month, for whoever will come. Nobody comes. I go anyway.\"",
			"\"I was the one who climbed up and cut the bell down. The town voted it, but my hands did it.\"",
			"\"Agnes stood at the foot of the ladder the whole time. She didn't shout. She only said, 'You'll want it back.'\"",
			"\"I kept the clapper. I told myself it was so no one could ring it in anger. I'm not sure that was why.\"",
			"\"Some nights, from the vicarage, I hear it ringing up here. A bell with no clapper, ringing.\"",
			"\"There, the chapel. Whatever happens, don't let me stay past dark.\""],
		"arrive": "The chapel on the hill: a grey stone nave and an empty bell-cote. The vicar lets himself in with a key on a string and comes back from the vestry with flasks of lamp oil. \"For the walk home. And for next time.\""},
	"grove": {"walker": "a woman in a grey shawl", "short": "the woman", "she": "she", "her": "her", "his": "her", "to": "the Hollow's grove",
		"from": GROVE_DAY, "level": 5, "oil": 2, "xp": 300, "feathers": 5, "spot": Vector2i(19, 1), "night": true,
		"marked": [0, 1, 5, 2, FLIP + 5, FLIP + 1, 4], "dark": [0, 3, 6, FLIP + 3, FLIP + 6, 4], "extra": ["dogs"],
		"talk": [
			"She says nothing. When you look back she is watching the crows, not the path.",
			"\"You keep the farm now.\" It isn't a question.",
			"\"He walked in here one autumn. He said he could hear the bell.\"",
			"She hums two notes, like a bell that has lost its ring.",
			"\"They were afraid. I was afraid too. That's not the same as being wrong.\"",
			"\"The crows know you. That's something.\"",
			"\"Here. You can leave me here.\""],
		"arrive": "The Hollow's grove: a ring of great black trees, and inside it the ground worn into a path, round and round. The woman steps onto it and lets the grey shawl fall. Her hair is the colour of crow feathers. \"Ring it every night,\" says Agnes Rook, and walks into the trees, and the crows go up and follow her."},
}

var active := false
var route_id := "mill"          # which route (a key of ROUTES): set when you pick a walker
var night := false              # set out after NIGHT_FROM
var grove_done := false         # saved: the woman in the grey shawl has been walked to the grove
var clearing := 0               # how far along the route: an index into route and events
var route: Array = MARKED_ROUTE # the clearings walked (the fork may change it)
var dark := false               # took the dark trail at the fork
var plan := {}                  # the day's events for both trails, and which arm of the fingerpost is marked
var nerve := 100.0
var lit := true
var oil_seconds := 0.0          # left on the burning flask
var crows_found := false        # the crows have found the walker this clearing
var crows_left := 0             # times they must still be driven off
var crows_back_at := 0.0        # when driven-off crows return
var tall_pos := Vector2.ZERO
var tall_on := false
var tall_back_at := 0.0         # when the tall one shows (again)
var clearing_time := 0.0        # seconds in this clearing
var frozen := false             # the walker has stopped and won't go on
var walker_pos := Vector2.ZERO
var crumbs: Array[Vector2] = [] # your footsteps, for the walker to follow
var events: Array = []          # per clearing on the route: "", "tree", "crows", "flood", "lights", "cairn", "fog", "hollow"
var event_point := Vector2i(-1, -1)
var blocked: Array[Vector2i] = []  # the trail tiles the event blocks (the trunk, the water, the fog)
var side_tile := Vector2i(-1, -1)  # the cairn or the hollow tree beside the trail
var lights_pos := Vector2.ZERO
var sign_tile := Vector2i(-1, -1)
var event_done := false         # the event is dealt with (crossed, lifted, offered, searched, followed)
var event_near := false         # you have come up to it, and been told what it is
var fog_lift_at := -1.0
var roped := false
var sign_seen := false
var spoke := false              # had a word this clearing
var warned := false             # the walker has begged you back onto the trail this clearing
var done_day := 0               # the day a walker was taken, or turned away
var treks_done := 0             # saved: treks finished, which sets the wood's dread
var works := {}                 # trail works built, by id (waymarks, footbridge, gate_lamp, boardwalk, waystation, chapel_steps): saved, built from the Buildings section
var _confirm_until := 0.0
var _confirm_id := ""
var _flipped := {}              # mirrored layouts, by index (see _layout)
var layer: Node2D
var nerve_bar: ProgressBar
var nerve_col: Control


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	layer = Node2D.new()
	layer.draw.connect(_draw_layer)
	m.add_child(layer)


# --- The trail works and their hooks ---------------------------------------------------------------

func _has_work(id: String) -> bool:
	return bool(works.get(id, false))


# The trail works, paid for from the Buildings section, each once, from when its route opens ("route").
const WORKS := {
	"waymarks": {"name": "Waymarks", "route": "mill", "cost": {"coins": 150, "wood": 10},
		"about": "Blazes cut at every fork, so the fingerpost reads without Bushcrafting.",
		"built": "The forks are blazed: the fingerpost reads for anyone."},
	"footbridge": {"name": "The mill footbridge", "route": "mill", "cost": {"coins": 300, "wood": 12, "rope": 6},
		"about": "Planks over the hollows on the mill path, so a flood there is crossed dry.",
		"built": "The hollows on the mill path are crossed dry."},
	"gate_lamp": {"name": "A lamp at the gate", "route": "mill", "cost": {"coins": 400, "iron_bar": 2},
		"about": "A lamp hung at the gap in the trees. The lane sees it, and walkers come twice as often.",
		"built": "Walkers come two days in three."},
	"boardwalk": {"name": "The orchard boardwalk", "route": "orchard", "cost": {"coins": 700, "wood": 20, "rope": 8},
		"about": "A boardwalk over the wet ground: the orchard is one clearing shorter.",
		"built": "The orchard is a clearing shorter."},
	"waystation": {"name": "The waystation hut", "route": "chapel", "cost": {"coins": 1200, "wood": 30, "hardwood": 10},
		"about": "A hut halfway along the long routes (%d clearings or more): a half-hour rest, nerve and warmth full, no oil burned." % WAYSTATION_MIN,
		"built": "Rest halfway on the long routes."},
	"chapel_steps": {"name": "The chapel steps", "route": "chapel", "cost": {"coins": 1800, "stone": 30, "iron_bar": 4},
		"about": "Stone steps up the hill, with iron rails. The chapel by night without the doubled sanity drain.",
		"built": "The chapel by night costs no more sanity than by day."},
}


# Why a work can't be built now ("built" once it is), or "" when it can.
func _work_why(id: String) -> String:
	if _has_work(id):
		return "built"
	var w: Dictionary = WORKS[id]
	if m.day < int(ROUTES[w["route"]]["from"]):
		return "not until the way to %s opens" % ROUTES[w["route"]]["to"]
	if not m._can_afford(w["cost"]):
		return "needs %s" % m.projects._cost_list(w["cost"])
	return ""


func _build_work(id: String) -> void:
	var why := _work_why(id)
	var w: Dictionary = WORKS[id]
	if why != "":
		m._show_message("%s: %s." % [w["name"], why])
		return
	m._pay(w["cost"])
	works[id] = true
	m.play_sfx("repair", 0.05)
	m._show_message("%s is built. %s" % [w["name"], w["built"]])


# The fingerpost at a fork reads with Bushcrafting, or for anyone once the Waymarks are cut.
func _can_read_sign() -> bool:
	return m.progression._level("Bushcrafting") >= SIGN_LEVEL or _has_work("waymarks")


# The mill footbridge keeps the hollows on the mill path dry.
func _hollows_dry() -> bool:
	return _has_work("footbridge") and route_id == "mill"


# A lamp at the gate: walkers come twice as often (two days in COME_EVERY instead of one).
func _walker_day(d: int) -> bool:
	var k := hash([d, "walker"]) % COME_EVERY
	return k == 0 or (k == 1 and _has_work("gate_lamp"))


# The orchard boardwalk: the orchard is one clearing shorter (see _steps).
func _orchard_shorter() -> bool:
	return _has_work("boardwalk")


# The waystation hut: a rest halfway on the long routes (see _on_step).
func _rests_halfway() -> bool:
	return _has_work("waystation") and route.size() >= WAYSTATION_MIN


# How much faster the wood takes sanity by night. The chapel steps take the chapel route by night without it.
func _night_sanity() -> float:
	if route_id == "chapel" and _has_work("chapel_steps"):
		return 1.0
	return NIGHT_SANITY


# --- The walkers at the north edge --------------------------------------------------------------

# A route is open from its day; the grove only once the crow bell is hung, and only once.
func _route_open(id: String) -> bool:
	if m.day < int(ROUTES[id]["from"]):
		return false
	if id == "grove":
		return m.projects.bell_day >= 0 and not grove_done
	return true


func _waiting(id := "mill") -> bool:
	if active or done_day == m.day or not _walker_day(m.day) or not _route_open(id):
		return false
	return m.current_hour < START_BY or (bool(ROUTES[id]["night"]) and m.current_hour < NIGHT_UNTIL)


func _any_waiting() -> bool:
	for id in ROUTES:
		if _waiting(id):
			return true
	return false


func _walker_tile(id := "mill") -> Vector2i:
	var s: Vector2i = ROUTES[id]["spot"]
	return m._world_tile(s.x, s.y)


func _morning_note() -> String:
	if not _walker_day(m.day):
		return ""
	var names: Array = []
	for id in ROUTES:
		if _route_open(id):
			names.append("%s (to %s)" % [ROUTES[id]["walker"], ROUTES[id]["to"]])
	if names.is_empty():
		return ""
	var who: String = names[0] if names.size() == 1 else ", ".join(names.slice(0, -1)) + " and " + str(names[-1])
	return " %s %s waiting at the gap in the trees north of the house, wanting walking through the wood, before three." % [
		_cap(who), "is" if names.size() == 1 else "are"]


func _oil_needed(id := "mill", by_night := false) -> int:
	return int(ROUTES[id]["oil"]) + (NIGHT_OIL if by_night else 0)


# The clock's speed: slow in the wood (see main's _process).
func _time_scale() -> float:
	return TIME_SCALE if active else 1.0


func _season_on(day: int) -> String:
	return m._season_of(int(m._calendar_date(day)["month"]))


# The clearings a route walks by each trail. The orchard boardwalk drops one before the orchard.
func _steps(id: String) -> Dictionary:
	var marked: Array = (ROUTES[id]["marked"] as Array).duplicate()
	var dk: Array = (ROUTES[id]["dark"] as Array).duplicate()
	if id == "orchard" and _orchard_shorter():
		marked.remove_at(marked.size() - 2)
		dk.remove_at(dk.size() - 2)
	return {"marked": marked, "dark": dk}


# The day's events on a route, for both trails, and which arm of the fingerpost is the marked one. The
# balance sim reads it too.
func _plan(day: int, id := "mill") -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([day, "trek"]) if id == "mill" else hash([day, "trek", id])
	var season := _season_on(day)
	var skip: Array = SEASON_SKIPS.get(season, [])
	var more: Array = SEASON_MORE.get(season, [])
	var extra: Array = ROUTES[id]["extra"]
	var steps := _steps(id)
	var used: Array = []
	var edge := _draw_event(rng, EDGE_EVENTS + extra, skip, more, used)
	var marked: Array = [edge]
	for i in (steps["marked"] as Array).size() - 2:
		marked.append(_draw_event(rng, MARKED_EVENTS + extra, skip, more, used))
	marked.append("")
	var dk: Array = [edge]
	var dark_used: Array = [edge]
	for i in (steps["dark"] as Array).size() - 2:
		dk.append(_draw_event(rng, DARK_EVENTS + extra, skip, more, dark_used))
	dk.append("")
	return {"marked": marked, "dark": dk, "marked_right": rng.randi() % 2 == 0}


# One event from the pool, counting the season's likelier ones twice. No repeats until the pool runs out.
func _draw_event(rng: RandomNumberGenerator, pool: Array, skip: Array, more: Array, used: Array) -> String:
	var weighted: Array = pool.duplicate()
	for e in more:
		if e in pool:
			weighted.append(e)
	var left: Array = weighted.filter(func(e: String) -> bool: return not e in skip and not e in used)
	if left.is_empty():
		left = weighted.filter(func(e: String) -> bool: return not e in skip)
	var e: String = left[rng.randi() % left.size()]
	used.append(e)
	return e


# Space on the farm. Returns true when the press was used.
func _try_walker(tile: Vector2i) -> bool:
	if active or m.inside or m.in_cave:
		return false
	for id in ROUTES:
		if not _waiting(id):
			continue
		var w := _walker_tile(id)
		if tile == w or m._player_tile() == w + Vector2i(0, 1):
			_ask(id)
			return true
	return false


# Talking to a walker: what they ask, what you'd need, and Space again to set out with them.
func _ask(id: String) -> void:
	route_id = id
	var r: Dictionary = ROUTES[id]
	var by_night := m.current_hour >= NIGHT_FROM
	if m.progression._level("Bushcrafting") < int(r["level"]):
		m._show_message(_w("{W} looks at your boots, then at the wood. \"Do you know it that far?\" (Bushcrafting %d to walk to %s.)") % [int(r["level"]), r["to"]])
		return
	if m.current_hour >= START_BY and not by_night:
		m._show_message(_w("\"It's too late to be there by daylight. After six we could walk it by night, if you dare.\""))
		return
	if m.lantern_tier <= 0:
		m._show_message(_w("\"Not without a light.\" {W} won't go into the wood until you have a lantern."))
		return
	if int(m.materials["lamp_oil"]) < _oil_needed(id, by_night):
		m._show_message(_w("\"Have you oil for that lantern?\" You need %d lamp oil from the catalog to walk {her} to %s%s.") % [
			_oil_needed(id, by_night), r["to"], " by night" if by_night else ""])
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now > _confirm_until or _confirm_id != id:
		_confirm_until = now + CONFIRM_SECONDS
		_confirm_id = id
		var steps := _steps(id)
		var rations := int(m.inventory["trail_ration"])
		var bandages := int(m.inventory["bandage"])
		m._show_message(_w("{W} wants walking to %s through the Rookery Wood, %d or %d clearings as the trail forks.%s A flask of oil burns little more than a minute in there. You have %d lamp oil, %d trail ration%s, %d rope and %d bandage%s. Press Space again to set out.") % [
			r["to"], (steps["dark"] as Array).size(), (steps["marked"] as Array).size(),
			" By night: twice the pay, and the dark will cost you far more." if by_night else "",
			int(m.materials["lamp_oil"]), rations, "" if rations == 1 else "s", int(m.materials["rope"]),
			bandages, "" if bandages == 1 else "s"])
		return
	_start(id)


func _start(id := "mill") -> void:
	m.play_sfx("step", 0.03)
	route_id = id
	night = m.current_hour >= NIGHT_FROM
	active = true
	done_day = m.day
	clearing = 0
	nerve = NERVE_START
	oil_seconds = 0.0
	lit = true
	m.fishing._stop_fishing("")
	m.in_cave = true
	m.inside = false
	m.foes = []
	plan = _plan(m.day, id)
	dark = false
	route = _steps(id)["marked"]
	events = (plan["marked"] as Array).duplicate()
	if nerve_col != null:
		(nerve_col.get_child(0) as Label).text = "%s's nerve" % _cap(str(ROUTES[id]["short"]))
	_enter_clearing()
	var by_night := " The sky is dark already; the wood is darker." if night else ""
	if _dread() > 0:
		m._show_message(_w("You lead {w} through the gap in the trees.%s The wood is quieter than last time, as if it has been waiting. It knows you now (dread %d of %d). Press Space beside {her} for a word, or a trail ration.") % [by_night, _dread(), MAX_DREAD])
		return
	m._show_message(_w("You lead {w} through the gap in the trees.%s The light goes green, then grey. \"Stay close.\" Press Space beside {her} for a word, or to give {her} a trail ration.") % by_night)


# A message about the walker: {w} and {W} are their name, {she} {She} {her} {his} their pronouns.
func _w(text: String) -> String:
	var r: Dictionary = ROUTES[route_id]
	var short := str(r["short"])
	return text.replace("{W}", _cap(short)).replace("{w}", short).replace("{She}", _cap(str(r["she"]))) \
		.replace("{she}", str(r["she"])).replace("{her}", str(r["her"])).replace("{his}", str(r["his"]))


func _cap(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1)


func _spec() -> Dictionary:
	return _layout(int(route[clearing]))


# A clearing's layout; FLIP + i is clearing i mirrored left to right (a two-wide trail at x mirrors to 38 - x).
func _layout(i: int) -> Dictionary:
	if i < FLIP:
		return CLEARINGS[i]
	if not _flipped.has(i):
		var f: Dictionary = (CLEARINGS[i - FLIP] as Dictionary).duplicate(true)
		var w: int = m.CAVE_W
		f["points"] = (f["points"] as Array).map(func(p: Array) -> Array: return [w - 2 - int(p[0]), p[1], p[2]])
		f["detour"] = (f["detour"] as Array).map(func(p: Array) -> Array: return [w - 2 - int(p[0]), p[1]])
		_flipped[i] = f
	return _flipped[i]


# What the walker says for a word in this clearing: a line a clearing, the last one at the end.
func _talk() -> String:
	var lines: Array = ROUTES[route_id]["talk"]
	if clearing >= route.size() - 1:
		return str(lines[-1])
	return str(lines[mini(clearing, lines.size() - 2)])


func _event() -> String:
	return str(events[clearing]) if clearing < events.size() else ""


func _trail() -> String:
	return str(_spec().get("trail", ""))


# How hard the events are here: gentler on the marked trail, harder on the dark one.
func _harsh() -> float:
	match _trail():
		"marked":
			return 0.7
		"dark":
			return 1.4
	return 1.0


func _winter() -> bool:
	return _season_on(m.day) == "Winter"


func _enter_clearing() -> void:
	event_done = false
	event_near = false
	fog_lift_at = -1.0
	roped = false
	sign_seen = false
	_lay_out()
	var start: Array = _spec()["points"][0]
	_place_at(m._tile_center(int(start[0]), int(start[1]) - 2))
	crows_found = false
	crows_left = maxi(1, CROW_WAVES + _dread() / 2 + int({"marked": -1, "dark": 1}.get(_trail(), 0)))
	crows_back_at = 0.0
	tall_on = false
	tall_back_at = maxf(3.0, TALL_DELAY - _dread() - (DARK_TALL_SOONER if _trail() == "dark" else 0.0))
	clearing_time = 0.0
	frozen = false
	spoke = false
	warned = false
	m._set_bounds()
	m.queue_redraw()
	layer.queue_redraw()


func _place_at(p: Vector2) -> void:
	m.player.position = p
	walker_pos = p + Vector2(0, m.PX)
	crumbs = [walker_pos, p]


# Lays the clearing into the cave grid: dense wood, the trail and the room around it, the event, the exits.
func _lay_out() -> void:
	var spec := _spec()
	var ev := _event()
	var T := MainGame.Tile
	m.foes = []
	m.cave = []
	for y in m.CAVE_H:
		var row: Array = []
		for x in m.CAVE_W:
			row.append(T.TREE)
		m.cave.append(row)
	var pts: Array = spec["points"]
	if ev == "tree" and spec["detour"].size() > 1:
		for i in spec["detour"].size() - 1:
			_carve(Vector2(spec["detour"][i][0], spec["detour"][i][1]), Vector2(spec["detour"][i + 1][0], spec["detour"][i + 1][1]), 0, false)
	_carve_points(pts)
	if spec.has("branch"):
		_carve_points(spec["branch"])
	if spec.has("dest"):
		var r: Rect2i = spec["dest"]
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				m.cave[y][x] = T.HOUSE
	# The way back at the bottom, the way on at the top (two at a fork), two tiles each.
	var first: Array = pts[0]
	var ends: Array = [pts[-1]]
	if spec.has("branch"):
		ends.append(spec["branch"][-1])
	for dx in 2:
		m.cave[int(first[1])][int(first[0]) + dx] = T.EXIT
		for last in ends:
			m.cave[int(last[1])][int(last[0]) + dx] = T.CAVE_EXIT
	sign_tile = Vector2i(-1, -1)
	if spec.has("sign"):
		sign_tile = Vector2i(int(spec["sign"][0]), int(spec["sign"][1]))
		m.cave[sign_tile.y][sign_tile.x] = T.ROCK
	event_point = Vector2i(-1, -1)
	blocked = []
	side_tile = Vector2i(-1, -1)
	var e := int(spec["event"])
	if e < 0 or ev == "":
		return
	event_point = Vector2i(int(pts[e][0]), int(pts[e][1]))
	match ev:
		"tree", "flood", "fog":
			# Everything open around the narrow stretch, so nothing slips past at the edges.
			for y in range(event_point.y - 1, event_point.y + 2):
				for x in range(event_point.x - 2, event_point.x + 4):
					if m.cave[y][x] in [T.PATH, T.GRASS]:
						blocked.append(Vector2i(x, y))
			# The footbridge keeps the hollow dry; a Brass Lantern finds the way through the fog.
			event_done = (ev == "flood" and _hollows_dry()) or (ev == "fog" and m.lantern_tier >= FOG_LANTERN)
			if not event_done:
				for t in blocked:
					m.cave[t.y][t.x] = T.FENCE
		"cairn", "hollow":
			side_tile = _find_side()
			m.cave[side_tile.y][side_tile.x] = T.ROCK
		"lights":
			var dir := Vector2(_find_side() - event_point)
			lights_pos = m._tile_center(event_point.x, event_point.y) + dir * 2.6 * m.PX
		"dogs":
			# They wait on the open ground at the event, spread along the trail.
			var n := DOGS + (1 if _trail() == "dark" else 0) + (1 if _winter() else 0)
			for o in [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(1, -1), Vector2i(1, 1), Vector2i(3, 0), Vector2i(-1, 0)]:
				var t: Vector2i = event_point + o
				if m.foes.size() < n and _inner(t) and m.cave[t.y][t.x] in [T.PATH, T.GRASS]:
					m.foes.append(m.combat_sys._new_foe("dog", t))


func _carve_points(pts: Array) -> void:
	for i in pts.size() - 1:
		var room := mini(int(pts[i][2]), int(pts[i + 1][2]))
		_carve(Vector2(pts[i][0], pts[i][1]), Vector2(pts[i + 1][0], pts[i + 1][1]), room, true)


# A tree tile right beside the trail at the event, for the cairn or the hollow tree.
func _find_side() -> Vector2i:
	for o in [Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		var t: Vector2i = event_point + o
		if _inner(t) and m.cave[t.y][t.x] == MainGame.Tile.TREE:
			return t
	return event_point + Vector2i(0, -1)


# Carves a line from a to b: a two-wide trail (or a faint one-wide way through the trees) with room around it.
func _carve(a: Vector2, b: Vector2, room: int, trail: bool) -> void:
	var T := MainGame.Tile
	var steps := maxi(1, int(maxf(absf(b.x - a.x), absf(b.y - a.y)) * 2.0))
	for s in steps + 1:
		var p := a.lerp(b, float(s) / steps)
		var c := Vector2i(roundi(p.x), roundi(p.y))
		var r: int = room + (absi(hash([c.x, c.y])) % 2 if room > 0 else 0)
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 2):
				var t := c + Vector2i(dx, dy)
				if _inner(t) and Vector2(dx, dy).length() <= float(r) + 0.5 and m.cave[t.y][t.x] == T.TREE:
					m.cave[t.y][t.x] = T.GRASS
		# Two wide either way, so a diagonal stretch never narrows to a corner you can.t pass.
		for dx in 2:
			var t := c + Vector2i(dx, 0)
			if _inner(t):
				# The way round is marked FALLOW: it draws as grass, but it is off the trail, in the dark.
				m.cave[t.y][t.x] = T.PATH if trail else T.FALLOW


func _inner(t: Vector2i) -> bool:
	return t.x >= 1 and t.y >= 1 and t.x < m.CAVE_W - 1 and t.y < m.CAVE_H - 1


# --- While trekking -------------------------------------------------------------------------------

func _update(delta: float) -> void:
	if nerve_col != null:
		nerve_col.visible = active
	if not active:
		layer.visible = _any_waiting() and not m.inside and not m.in_cave and not m._in_village()
		if layer.visible:
			layer.queue_redraw()
		return
	if not m.in_cave:
		# Felled by the dogs: _fallen has already sent you home.
		active = false
		m.foes = []
		if nerve_col != null:
			nerve_col.visible = false
		return
	layer.visible = true
	clearing_time += delta
	_burn(delta)
	_follow(delta)
	_crows(delta)
	_tall(delta)
	_near_things()
	var px := float(m.PX)
	var dist := walker_pos.distance_to(m.player.position) / px
	var rate := NERVE_LIT - DREAD_NERVE * _dread() if lit and dist <= _light_radius() + LIGHT_GRACE else NERVE_DARK
	var wt := Vector2i(floori(walker_pos.x / px), floori(walker_pos.y / px))
	# Cutting across the grass, or taking the way round, frightens them: the trail is the only safe ground.
	if not _on_trail(wt) or not _on_trail(m._player_tile()):
		rate += NERVE_OFF_TRAIL
		if not warned and clearing_time > 1.0:
			warned = true
			m._show_message(_w("\"Stay on the path!\" {W} hangs back, {his} eyes on the trees. Off the trail {his} nerve goes."))
	if dist > 6.0:
		rate += NERVE_FAR
	if m.sanity < 40.0:
		rate += NERVE_LOW_SANITY
	if _crows_mobbing():
		rate += NERVE_CROWS
	if _event() == "lights" and not event_done and walker_pos.distance_to(lights_pos) <= 6.0 * px:
		rate += NERVE_LIGHTS
	if _dogs_near():
		rate += NERVE_DOGS
	nerve = clampf(nerve + rate * delta, 0.0, 100.0)
	m.sanity_sys._change_sanity(-SANITY_DRAIN * (1.0 if lit else 2.0) * (DARK_SANITY if _trail() == "dark" else 1.0) * (_night_sanity() if night else 1.0) * delta)
	if _winter():
		m.warmth = maxf(0.0, m.warmth - WINTER_COLD * delta)
	if nerve_bar != null:
		nerve_bar.value = nerve
	if not frozen and nerve < FREEZE_BELOW:
		frozen = true
		m._show_message(_w("{W} stops dead and won't take another step. \"I can't. I can't.\" Give {her} a trail ration."))
	if frozen and nerve >= UNFREEZE_AT:
		frozen = false
	if nerve <= 0.0:
		m.sanity_sys._change_sanity(-FAIL_SANITY)
		_end(_w("{W} breaks and runs, screaming, back the way you came. You find {her} at the farm's edge, white and shaking. The trek is over. -%d sanity.") % int(FAIL_SANITY), false)
		return
	layer.queue_redraw()


# Coming up to the fingerpost or an event says what it is; the fog starts thinning once you reach it; walking
# on past the cairn without leaving anything shakes the walker.
func _near_things() -> void:
	var px := float(m.PX)
	if sign_tile.x >= 0 and not sign_seen and m.player.position.distance_to(m._tile_center(sign_tile.x, sign_tile.y)) <= EVENT_NEAR * px:
		sign_seen = true
		m._show_message("The trail forks at an old fingerpost, one arm left and one right. Space to read it.")
	var ev := _event()
	if event_point.x < 0 or ev in ["", "tree", "crows"]:
		return
	var at := m._tile_center(event_point.x, event_point.y)
	if not event_near and m.player.position.distance_to(at) <= EVENT_NEAR * px:
		event_near = true
		match ev:
			"flood":
				if event_done:
					m._show_message("The trail dips into a hollow, dry under the footbridge.")
				else:
					m._show_message("The trail drops into a hollow full of black water. Space at its edge to cross: a rope across, or wade it.")
			"fog":
				if event_done:
					m._show_message("A fog bank lies across the trail, but the brass lantern burns a way through it.")
				else:
					fog_lift_at = clearing_time + FOG_WAIT * _harsh()
					m._show_message("A fog bank lies across the trail, so thick your lantern lights only the fog. Only a brighter lantern would find the way. Wait for it to thin.")
			"cairn":
				m._show_message("Beside the trail, a cairn of crow skulls, the beaks all turned to the path. Space to leave something, or walk on.")
			"hollow":
				m._show_message("An old tree beside the trail is hollow, and something pale is inside. Space to reach in.")
			"lights":
				m._show_message("Pale lights bob in the trees off the path, like lanterns, and wait for you. Space near them to follow, or keep to the trail.")
			"dogs":
				m._show_message(_w("Dogs on the trail ahead, thin and silent, watching {w}. Fight them off with a weapon, or hurry {her} past while they're on you."))
	if ev == "dogs" and not event_done and not m.foes.any(func(f: Dictionary) -> bool: return f["kind"] == "dog"):
		event_done = true
		m._show_message(_w("The last of the dogs slinks off into the trees. {W} lets out a long breath."))
	if ev == "fog" and not event_done and fog_lift_at >= 0.0 and clearing_time >= fog_lift_at:
		event_done = true
		_unblock()
		m._show_message("The fog thins and draws back into the trees. The trail is there, where it always was.")
	if ev == "cairn" and event_near and not event_done and walker_pos.distance_to(m._tile_center(side_tile.x, side_tile.y)) > 6.0 * px:
		event_done = true
		nerve = maxf(0.0, nerve - CAIRN_SNUB * _harsh())
		m._show_message(_w("{W} looks back at the cairn until it's out of sight. \"We should have left something.\""))


func _on_trail(t: Vector2i) -> bool:
	return m._kind_at(t) in [MainGame.Tile.PATH, MainGame.Tile.FENCE, MainGame.Tile.EXIT, MainGame.Tile.CAVE_EXIT]


func _light_radius() -> float:
	return float(m.LANTERN_TIERS[maxi(0, m.lantern_tier - 1)]["radius"])


# The lantern burns a flask every FLASK_SECONDS, and you refill it as it gutters, while you have oil.
func _burn(delta: float) -> void:
	if not lit:
		return
	oil_seconds -= delta
	if oil_seconds > 0.0:
		return
	if int(m.materials["lamp_oil"]) > 0:
		m.materials["lamp_oil"] -= 1
		oil_seconds = FLASK_SECONDS
		if clearing_time > 1.0:
			m._show_message("The lantern gutters. You refill it. %d lamp oil left." % int(m.materials["lamp_oil"]))
	else:
		lit = false
		m._show_message(_w("Your lantern gutters and goes out. The wood closes in. {W} grips your sleeve."))


# The crows find the walker at their spot, then follow her in waves until driven off CROW_WAVES times.
func _crows(_delta: float) -> void:
	if _event() != "crows" or crows_left <= 0 or event_point.x < 0 or crows_found:
		return
	if walker_pos.distance_to(m._tile_center(event_point.x, event_point.y)) <= CROW_RADIUS * m.PX:
		crows_found = true
		crows_back_at = clearing_time
		m.play_sfx("crow", 0.05)
		m._show_message(_w("The crows come down out of the trees onto {w}, all at once. Drive them off: Space beside {her}."))


# The tall one walks the trees toward the walker. Near your light it backs away; if it reaches them, it is gone
# again for a while and their nerve is badly shaken.
func _tall(delta: float) -> void:
	if clearing < (0 if _dread() >= 2 else TALL_FROM):
		return
	var px := float(m.PX)
	if not tall_on:
		if clearing_time < tall_back_at:
			return
		tall_on = true
		tall_pos = _tall_spawn()
		m.play_sfx("snap_far", 0.05)
		m._show_message("Something tall is standing in the trees. It wasn't there a moment ago.")
	var in_light: bool = lit and m.player.position.distance_to(tall_pos) <= _light_radius() * px
	var speed := (TALL_SPEED if in_light else TALL_DARK_SPEED) + DREAD_TALL_SPEED * _dread() + (DARK_TALL_SPEED if _trail() == "dark" else 0.0) + (NIGHT_TALL_SPEED if night else 0.0)
	tall_pos = tall_pos.move_toward(walker_pos, speed * px * delta)
	if tall_pos.distance_to(walker_pos) <= TALL_TOUCH * px:
		nerve = maxf(0.0, nerve - TALL_NERVE)
		tall_on = false
		tall_back_at = clearing_time + _tall_back()
		m.play_sfx("screech", 0.05)
		m._show_message(_w("A long grey hand touches {w}'s shoulder from the dark. {She} screams. When you turn, nothing is there."))
	elif tall_pos.distance_to(m.player.position) > 16.0 * px:
		tall_on = false
		tall_back_at = clearing_time + TALL_BACK * 0.5


# A tree tile well away from you both, toward the walker's side of the wood.
func _tall_spawn() -> Vector2:
	var px := float(m.PX)
	var best := walker_pos + Vector2(8.0 * px, 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, clearing, int(clearing_time)])
	for i in 40:
		var t := Vector2i(rng.randi_range(1, m.CAVE_W - 2), rng.randi_range(1, m.CAVE_H - 2))
		var p := m._tile_center(t.x, t.y)
		var d := p.distance_to(walker_pos) / px
		if m.cave[t.y][t.x] == MainGame.Tile.TREE and d >= 7.0 and d <= 11.0 and p.distance_to(m.player.position) > 6.0 * px:
			return p
	return best


# The walker keeps a little behind you, along the way you walked, so they never cut through the trees.
func _follow(delta: float) -> void:
	var px := float(m.PX)
	if crumbs.is_empty() or crumbs[-1].distance_to(m.player.position) > px * 0.25:
		crumbs.append(m.player.position)
	var gap := FOLLOW_GAP * px
	while crumbs.size() > 2 and crumbs[1].distance_to(m.player.position) > gap and crumbs[0].distance_to(walker_pos) < px * 0.2:
		crumbs.pop_front()
	var target := crumbs[0]
	if frozen or walker_pos.distance_to(m.player.position) <= gap:
		return
	var speed := px * WALKER_SPEED * delta
	walker_pos = walker_pos.move_toward(target, speed)
	if walker_pos.distance_to(target) < 1.0 and crumbs.size() > 1:
		crumbs.pop_front()


func _crows_mobbing() -> bool:
	return _event() == "crows" and crows_found and crows_left > 0 and clearing_time >= crows_back_at


func _dogs_near() -> bool:
	for f in m.foes:
		if f["kind"] == "dog" and (f["pos"] as Vector2).distance_to(walker_pos) <= DOG_NEAR * m.PX:
			return true
	return false


# Space while trekking.
func _interact(tile: Vector2i) -> void:
	# A swing with the sword is for the dogs, wherever you stand.
	if m._tool_press and m._active_tool() == "sword":
		m._swing()
		return
	var px := float(m.PX)
	var kind := m._kind_at(tile)
	if kind == MainGame.Tile.FENCE:
		_blocked_by()
		return
	if kind == MainGame.Tile.ROCK:
		if tile == sign_tile:
			_read_sign()
		elif tile == side_tile and _event() == "cairn":
			_offer()
		elif tile == side_tile and _event() == "hollow":
			_search_hollow()
		return
	if _crows_mobbing() and m.player.position.distance_to(walker_pos) <= 2.5 * px:
		crows_left -= 1
		crows_back_at = clearing_time + CROW_RETURN
		m.sanity_sys._change_sanity(-CROW_SANITY)
		m.materials["feathers"] += 1
		m.play_sfx("strike", 0.05)
		if crows_left > 0:
			m._show_message(_w("You beat the crows off {w}. They wheel up into the branches, screaming, and wait. -%d sanity, +1 crow feather.") % int(CROW_SANITY))
		else:
			m._show_message("You drive the crows off a last time, and they give up and go. -%d sanity, +1 crow feather." % int(CROW_SANITY))
		layer.queue_redraw()
		return
	if tall_on and m.player.position.distance_to(tall_pos) <= TALL_REACH * px:
		tall_on = false
		tall_back_at = clearing_time + _tall_back()
		m.sanity_sys._change_sanity(-TALL_SANITY)
		m._show_message("You lift the lantern at it and it is simply gone, as if it had never been there. -%d sanity." % int(TALL_SANITY))
		return
	if _event() == "lights" and not event_done and m.player.position.distance_to(lights_pos) <= LIGHTS_REACH * px:
		_follow_lights()
		return
	if m.player.position.distance_to(walker_pos) <= px * 1.6:
		if (nerve < RATION_BELOW or frozen) and int(m.inventory["trail_ration"]) > 0:
			m.inventory["trail_ration"] -= 1
			nerve = minf(100.0, nerve + RATION_NERVE)
			m._show_message(_w("You hand {w} a trail ration. {She} eats it slowly, and {his} hands stop shaking. Nerve +%d.") % int(RATION_NERVE))
		elif not spoke:
			spoke = true
			nerve = minf(100.0, nerve + WORD_NERVE)
			m._show_message(_talk())
		else:
			m._show_message("\"I'm all right. Keep going.\"" if nerve >= 50.0 else _w("\"Is it much further?\" {She} is pale."))
		return
	m._swing()


# Space at what blocks the trail: the fallen trunk, the water in the hollow, or the fog.
func _blocked_by() -> void:
	match _event():
		"tree":
			if int(m.tool_tier["hatchet"]) < 1:
				m._show_message(_w("The trunk is too thick to climb with {w}. You need a hatchet to cut through, or find a way round."))
				return
			_unblock()
			m.materials["wood"] += CHOP_WOOD
			m.progression._grant_xp("Forestry", m.XP_GATHER)
			m.play_sfx("tree_fall", 0.04)
			m._show_message(_w("You hack a gap through the fallen trunk and help {w} over. +%d wood, +%d Forestry XP.") % [CHOP_WOOD, m.XP_GATHER])
		"flood":
			_cross_flood()
		"fog":
			m._show_message("You can't see a step into it. Wait for the fog to thin, about %d seconds more." % maxi(1, ceili(fog_lift_at - clearing_time)))


func _unblock() -> void:
	for t in blocked:
		if m.cave[t.y][t.x] == MainGame.Tile.FENCE:
			m.cave[t.y][t.x] = MainGame.Tile.PATH
	m.queue_redraw()


# A rope tied across the hollow takes you both over dry. Without one you wade, with Maren on your back.
func _cross_flood() -> void:
	if int(m.materials["rope"]) > 0:
		m.materials["rope"] -= 1
		roped = true
		event_done = true
		_unblock()
		m.progression._grant_xp("Bushcrafting", ROPE_XP)
		m.play_sfx("cloth", 0.04)
		m._show_message(_w("You tie a rope from a root to a trunk across the hollow, and {w} crosses holding it, dry-shod. -1 rope, +%d Bushcrafting XP.") % ROPE_XP)
		return
	var cost := _wade_warmth()
	var nerve_cost := WADE_NERVE * _harsh()
	var now := Time.get_ticks_msec() / 1000.0
	if now > _confirm_until:
		_confirm_until = now + CONFIRM_SECONDS
		m._show_message(_w("You have no rope to tie across. Wade it, with {w} on your back? The water is %s: -%d warmth, and {she} hates it. Space again to wade.") % [
			"freezing" if _winter() else "cold", int(cost)])
		return
	m.warmth = maxf(0.0, m.warmth - cost)
	nerve = maxf(0.0, nerve - nerve_cost)
	event_done = true
	_unblock()
	m.play_sfx("water", 0.04)
	m._show_message(_w("You wade the hollow to the waist with {w} on your back, and set {her} down on the far side, shaking. -%d warmth, nerve -%d.") % [int(cost), int(nerve_cost)])


func _wade_warmth() -> float:
	return WADE_WARMTH * _harsh() * (WADE_WINTER if _winter() else 1.0)


# The fingerpost at the fork. Readable, it says which arm is the marked trail.
func _read_sign() -> void:
	if not _can_read_sign():
		m._show_message("An old fingerpost, one arm left and one right. Whatever was cut into them has worn almost away. (Bushcrafting %d would make out what's left.)" % SIGN_LEVEL)
		return
	var marked := "right" if bool(plan["marked_right"]) else "left"
	var other := "left" if marked == "right" else "right"
	m._show_message("The %s arm is cut with a lantern: the marked trail to %s, a clearing longer but kinder. The %s arm has only a crow: the dark trail, shorter and harder, though they say the wood gives more to those who take it." % [marked, ROUTES[route_id]["to"], other])


# The cairn of crow skulls: a few coins or a ration left on it settles you both.
func _offer() -> void:
	if event_done:
		m._show_message("The skulls watch you go by.")
		return
	var gift := ""
	if m.money >= CAIRN_COINS:
		m.money -= CAIRN_COINS
		gift = "%d coins" % CAIRN_COINS
	elif int(m.inventory["trail_ration"]) > 0:
		m.inventory["trail_ration"] -= 1
		gift = "a trail ration"
	else:
		m._show_message("You have nothing to leave: not %d coins, not a ration." % CAIRN_COINS)
		return
	event_done = true
	m.sanity_sys._change_sanity(CAIRN_SANITY)
	nerve = minf(100.0, nerve + CAIRN_NERVE)
	m.play_sfx("coin", 0.04)
	m._show_message(_w("You leave %s on the cairn. {W} touches one skull, the way you'd touch a gravestone, and walks on easier. Nerve +%d, +%d sanity.") % [gift, int(CAIRN_NERVE), int(CAIRN_SANITY)])


# The hollow tree: a feather bundle, old coins, or a nest of small bones. The dark trail's trees hold more.
func _search_hollow() -> void:
	if event_done:
		m._show_message("The hollow is empty now.")
		return
	event_done = true
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, "hollow", clearing])
	var page: String = m.mystery._next_trek_page(route_id)
	if page != "" and rng.randf() < HOLLOW_PAGE:
		m.mystery._find_trek_page(page)
		return
	var roll := rng.randf()
	var more := _trail() == "dark"
	if roll < 0.4:
		var n := HOLLOW_FEATHERS + (HOLLOW_DARK_BONUS if more else 0)
		m.materials["feathers"] += n
		m.play_sfx("gather", 0.04)
		m._show_message("Inside, a bundle of crow feathers bound with flax, the way Agnes bound hers. +%d crow feathers." % n)
	elif roll < 0.8:
		var c := rng.randi_range(HOLLOW_COINS.x, HOLLOW_COINS.y) * (HOLLOW_DARK_BONUS if more else 1)
		m.money += c
		m.play_sfx("coin", 0.04)
		m._show_message("Inside, a rotted purse of old coins, the town's mark worn off them. +%d coins." % c)
	else:
		m.sanity_sys._change_sanity(-BONES_SANITY)
		nerve = maxf(0.0, nerve - BONES_NERVE)
		m.play_sfx("snap_far", 0.04)
		m._show_message("Your hand closes on a nest of small bones, picked clean and still warm. Something lives in there. -%d sanity, nerve -%d." % [int(BONES_SANITY), int(BONES_NERVE)])


# The lights off the path: they lead you true to the way on, or lose you for an hour and leave you back at
# the start of the clearing.
func _follow_lights() -> void:
	event_done = true
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, "lights", clearing])
	var pts: Array = _spec()["points"]
	if rng.randf() < LIGHTS_SHORTCUT:
		var near: Array = pts[-2]
		_place_at(m._tile_center(int(near[0]), int(near[1])))
		m._show_message(_w("You follow the lights off the path, {w} clinging to your sleeve. They lead you through the trees by a way you'd never have found, and go out. The way on is just ahead."))
	else:
		_pass_hours(1.0)
		nerve = maxf(0.0, nerve - LOST_NERVE)
		m.sanity_sys._change_sanity(-LOST_SANITY)
		oil_seconds -= LOST_OIL
		_place_at(m._tile_center(int(pts[0][0]), int(pts[0][1]) - 2))
		m._show_message(_w("The lights go out all at once, and you are deep in the trees with no path. It's an hour before you find the trail again, back where the clearing began. {W} hasn't said a word. Nerve -%d, -%d sanity.") % [int(LOST_NERVE), int(LOST_SANITY)])
	layer.queue_redraw()


# Stepping on the way on, or the way back.
func _on_step(kind: int) -> void:
	if kind == MainGame.Tile.EXIT:
		_end(_w("You turn back. {W} follows you out of the wood without a word, and goes home."), false)
		return
	if kind != MainGame.Tile.CAVE_EXIT:
		return
	if walker_pos.distance_to(m.player.position) > float(m.PX) * 4.0:
		m._show_message(_w("You can't leave {w} behind. Wait for {her}."))
		return
	var at_fork := _spec().has("branch")
	if at_fork:
		# The branch is the left arm. The day decides whether the marked trail goes left or right.
		var on_branch := absi(m._player_tile().x - int(_spec()["branch"][-1][0])) <= 2
		dark = on_branch == bool(plan["marked_right"])
		route = _steps(route_id)["dark" if dark else "marked"]
		var first: String = events[0]
		events = (plan["dark"] if dark else plan["marked"]).duplicate()
		events[0] = first
	clearing += 1
	if clearing >= route.size():
		_arrive()
		return
	_enter_clearing()
	if _rests_halfway() and clearing == route.size() / 2:
		# The waystation hut: a fire, a bench, and a door that shuts. Half an hour's rest costs no oil.
		nerve = 100.0
		m.warmth = 100.0
		_pass_hours(0.5)
		m._show_message(_w("Halfway, the waystation hut: a fire laid ready, a bench and a door that shuts. You rest half an hour with the lantern out. {W} is steady again, and you are warm."))
	elif at_fork and dark:
		m._show_message(_w("No marks on these trees, and the trail is narrow. The wood presses in, and the light is worse. {W} says nothing at all."))
	elif at_fork:
		m._show_message(_w("Pale blazes cut into the trunks mark the way. {W} breathes easier. \"This is the old way. Elias kept it.\""))
	else:
		m._show_message("The trail goes on through the trees." if lit else "The trail goes on, darker now.")


# The walker pays in kind: each route its own gifts (some by season), feathers, the fiber gathered on the way and
# Bushcrafting XP. The dark trail and the dread add to it, and a night trek doubles it all.
func _arrive() -> void:
	var r: Dictionary = ROUTES[route_id]
	var d := _dread()
	var pay := NIGHT_PAY if night else 1
	var feathers := (int(r["feathers"]) + 1 + d / 2 + (DARK_FEATHERS if dark else 0)) * pay
	var xp := (int(r["xp"]) + DREAD_XP * d + (DARK_XP if dark else 0)) * pay
	var fiber := route.size() * pay   # brush gathered along the trail
	var gifts: Array = _gifts(pay)
	m.materials["feathers"] += feathers
	m.materials["fiber"] += fiber
	m.progression._grant_xp("Bushcrafting", xp)
	treks_done += 1
	if route_id == "grove":
		grove_done = true
	m.play_sfx("chime", 0.03)
	gifts.append("+%d crow feather%s" % [feathers, "" if feathers == 1 else "s"])
	gifts.append("+%d fiber gathered on the way" % fiber)
	gifts.append("+%d Bushcrafting XP%s" % [xp, " (more for the dark trail)" if dark else ""])
	_end("%s %s.%s You walk home alone by the short way, quickly." % [
		r["arrive"], ", ".join(gifts), " Twice the pay, for walking by night." if night else ""], true)


# The route's own gifts, given now, as text for the message.
func _gifts(pay: int) -> Array:
	var season := _season_on(m.day)
	var out: Array = []
	match route_id:
		"mill":
			m.inventory["seeds"] += 4 * pay
			out.append("+%d turnip seeds" % (4 * pay))
		"orchard":
			m.materials["hardwood"] += 2 * pay
			out.append("+%d hardwood (old applewood)" % (2 * pay))
			if season == "Summer":
				m.materials["flax"] += 2 * pay
				out.append("+%d wild flax from the orchard's edge" % (2 * pay))
		"chapel":
			m.materials["lamp_oil"] += 2 * pay
			out.append("+%d lamp oil" % (2 * pay))
			if season == "Spring":
				m.materials["storm_oak"] += pay
				out.append("+%d storm oak from the split tree in the churchyard" % pay)
			# The old bell's clapper, once: the crow bell can't be hung without it.
			if int(m.materials["bell_clapper"]) == 0 and not m.projects._has_bell():
				m.materials["bell_clapper"] = 1
				out.append("the old bell's clapper in an altar cloth (\"She said we'd want it back. Hang it in yours.\")")
	return out


# How much the wood has learned you: 0 on the first trek, up to MAX_DREAD.
func _dread() -> int:
	return mini(treks_done, MAX_DREAD)


func _tall_back() -> float:
	return maxf(5.0, TALL_BACK - 0.5 * _dread())


func _pass_hours(hours: float) -> void:
	m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
	m.current_hour += hours
	m._update_needs(hours)


# Ends a trek and puts you back at the gap in the trees. Walking home from the mill takes an hour.
func _end(text: String, arrived: bool) -> void:
	active = false
	m.in_cave = false
	m.foes = []
	var out := _walker_tile(route_id) + Vector2i(0, 1)
	m.player.position = m._tile_center(out.x, out.y)
	m._set_bounds()
	if arrived:
		_pass_hours(1.0)
	if nerve_col != null:
		nerve_col.visible = false
	m.queue_redraw()
	layer.queue_redraw()
	if text != "":
		m._show_message(text)


# The day ends (bed or a collapse) while in the wood: the trek is simply over.
func _abort() -> void:
	if active:
		_end("", false)


# --- Rope (Craft, Other) -----------------------------------------------------------------------------

func _can_make_rope() -> bool:
	return m.progression._level("Bushcrafting") >= int(ROPE["level"]) and int(m.materials["fiber"]) >= int(ROPE["fiber"])


func _rope_recipe() -> Dictionary:
	var costs: Array = [{"label": "%d fiber" % int(ROPE["fiber"]), "have": m._held("fiber"), "need": int(ROPE["fiber"])}]
	return {
		"key": "rope", "name": str(ROPE["name"]), "icon": "fiber", "tint": "b89a68",
		"desc": "Tied across a flooded hollow on a trek, it takes the walker over dry. +%d Bushcrafting XP." % int(ROPE["xp"]),
		"costs": costs, "level_text": m._level_text("Bushcrafting", int(ROPE["level"])),
		"level_ok": m.progression._level("Bushcrafting") >= int(ROPE["level"]), "enabled": _can_make_rope(),
		"action": "make_rope", "button": "Make",
	}


func _make_rope() -> void:
	if not _can_make_rope():
		m._show_message("You need %d fiber and Bushcrafting %d." % [int(ROPE["fiber"]), int(ROPE["level"])])
		return
	m.materials["fiber"] -= int(ROPE["fiber"])
	m.materials["rope"] += 1
	m.progression._grant_xp("Bushcrafting", int(ROPE["xp"]))
	m.play_sfx("cloth")
	m._show_message("You twist a length of rope. +%d Bushcrafting XP" % int(ROPE["xp"]))


# --- Light and drawing ------------------------------------------------------------------------------

func _tint(darkness: float) -> Color:
	var gloom: float = (GLOOM_DARK if _trail() == "dark" else GLOOM) + float(SEASON_GLOOM.get(_season_on(m.day), 0.0))
	return m._light_tint().lerp(m.NIGHT_TINT, maxf(darkness, gloom))


func _lantern_on() -> bool:
	return lit


# The clearing, drawn on the main canvas: grass and the trail on the dual grid, the water in a hollow, the
# trees (blazed on the marked trail), the logs, the fingerpost, the cairn, the hollow tree, the mill, the fog.
func _draw_map() -> void:
	var view := m.get_viewport_rect().size / m.camera.zoom
	var top_left := m.camera.get_screen_center_position() - view * 0.5
	var x0 := clampi(floori(top_left.x / m.PX) - 1, 0, m.CAVE_W - 1)
	var y0 := clampi(floori(top_left.y / m.PX) - 1, 0, m.CAVE_H - 1)
	var x1 := clampi(ceili((top_left.x + view.x) / m.PX) + 1, 0, m.CAVE_W - 1)
	var y1 := clampi(ceili((top_left.y + view.y) / m.PX) + 2, 0, m.CAVE_H - 1)
	var T := MainGame.Tile
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			m._draw_grass(Vector2i(x, y), m._tile_rect(Vector2i(x, y)))
	var path_tex := FarmSprites.tex("ground_path")
	for y in range(y0, y1 + 2):
		for x in range(x0, x1 + 2):
			var mask := 0
			if _is_trail(x - 1, y - 1):
				mask |= 1
			if _is_trail(x, y - 1):
				mask |= 2
			if _is_trail(x - 1, y):
				mask |= 4
			if _is_trail(x, y):
				mask |= 8
			var frame: int = m.DUAL_FRAME_BY_MASK[mask]
			if frame >= 0 and path_tex != null:
				m.draw_texture_rect_region(path_tex, Rect2((Vector2(x, y) - Vector2(0.5, 0.5)) * m.PX, Vector2(m.PX, m.PX)), m._ground_frame_rect(frame))
	var ev := _event()
	if ev == "flood":
		_draw_hollow_water()
	var spec := _spec()
	if spec.has("dest"):
		_draw_dest(spec["dest"])
	var blaze := _trail() == "marked"
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var kind: int = m.cave[y][x]
			var cell := m._tile_rect(Vector2i(x, y))
			if kind == T.FENCE and ev == "tree":
				_draw_log(cell)
			elif kind == T.TREE:
				m._draw_tree_tile(cell, x + 7, y + 3)
				if blaze and absi(hash([x, y, "blaze"])) % 3 == 0 and _beside_trail(x, y):
					m.draw_rect(Rect2(cell.position + cell.size * Vector2(0.42, 0.55), cell.size * Vector2(0.16, 0.2)), Color("d8d0c0"))
			elif kind == T.ROCK:
				if Vector2i(x, y) == sign_tile:
					_draw_sign(cell)
				elif ev == "cairn":
					_draw_cairn(cell)
				elif ev == "hollow":
					m._draw_tree_tile(cell, x + 7, y + 3)
					_draw_hole(cell)
	if ev == "flood" and roped:
		var a := m._tile_center(blocked[0].x, blocked[0].y) if not blocked.is_empty() else Vector2.ZERO
		var b := m._tile_center(blocked[-1].x, blocked[-1].y) if not blocked.is_empty() else Vector2.ZERO
		m.draw_line(a + Vector2(-m.PX * 0.6, -m.PX * 0.6), b + Vector2(m.PX * 0.6, m.PX * 0.3), Color("1d1611"), 4.0)
		m.draw_line(a + Vector2(-m.PX * 0.6, -m.PX * 0.6), b + Vector2(m.PX * 0.6, m.PX * 0.3), Color("b89a68"), 2.0)
	if ev == "fog":
		_draw_fog()


func _is_trail(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= m.CAVE_W or y >= m.CAVE_H:
		return false
	return m.cave[y][x] in [MainGame.Tile.PATH, MainGame.Tile.FENCE, MainGame.Tile.EXIT, MainGame.Tile.CAVE_EXIT]


func _beside_trail(x: int, y: int) -> bool:
	return _is_trail(x - 1, y) or _is_trail(x + 1, y) or _is_trail(x, y + 1)


func _draw_log(cell: Rect2) -> void:
	var ink := Color("1d1611")
	var r := Rect2(cell.position + Vector2(0, cell.size.y * 0.25), Vector2(cell.size.x, cell.size.y * 0.5))
	m.draw_rect(r.grow(2.0), ink)
	m.draw_rect(r, Color("6a4a32"))
	m.draw_line(r.position + Vector2(0, r.size.y * 0.35), r.position + Vector2(r.size.x, r.size.y * 0.35), Color("8a6a48"), 2.0)


# The hollow's water over the blocked stretch of trail (or, under the footbridge, a dry bed with planks).
func _draw_hollow_water() -> void:
	if blocked.is_empty():
		return
	var px := float(m.PX)
	var r := Rect2(Vector2(blocked[0]) * px, Vector2.ZERO)
	for t in blocked:
		r = r.expand(Vector2(t) * px).expand(Vector2(t + Vector2i.ONE) * px)
	r = r.grow(px * 0.3)
	var ink := Color("1d1611")
	if _hollows_dry():
		m.draw_rect(r, Color("5a4a3a"))
		for k in int(r.size.x / (px * 0.34)):
			var x := r.position.x + k * px * 0.34
			m.draw_rect(Rect2(Vector2(x, r.position.y + px * 0.2), Vector2(px * 0.28, r.size.y - px * 0.4)).grow(1.0), ink)
			m.draw_rect(Rect2(Vector2(x, r.position.y + px * 0.2), Vector2(px * 0.28, r.size.y - px * 0.4)), Color("8a6a48"))
		return
	m.draw_rect(r.grow(2.0), ink)
	m.draw_rect(r, Color("2c4450"))
	var t := Time.get_ticks_msec() / 1000.0
	for k in 6:
		var y := r.position.y + r.size.y * (0.2 + 0.13 * k)
		var x := r.position.x + fposmod(t * 6.0 + k * 23.0, r.size.x * 0.6)
		m.draw_line(Vector2(x, y), Vector2(x + px * 0.5, y), Color("6a8a90"), 2.0)
	for side in [r.position.x + px * 0.2, r.end.x - px * 0.2]:
		for k in 3:
			var reed := Vector2(side + (k - 1) * px * 0.12, r.position.y + px * 0.1)
			m.draw_line(reed, reed + Vector2(0, -px * 0.45), Color("4a5a30"), 2.0)


# The fog bank: soft pale billows over the event, thick while it blocks the trail, thin once it has lifted or
# when the brass lantern burns through it.
func _draw_fog() -> void:
	var px := float(m.PX)
	var a := 0.85 if not event_done else (0.3 if m.lantern_tier >= FOG_LANTERN and fog_lift_at < 0.0 else 0.0)
	if fog_lift_at >= 0.0 and event_done:
		a = clampf(0.85 - (clearing_time - fog_lift_at) * 0.3, 0.0, 0.85)
	if a <= 0.0:
		return
	var c := m._tile_center(event_point.x, event_point.y) + Vector2(px * 0.5, 0)
	var t := Time.get_ticks_msec() / 1000.0
	for k in 14:
		var ang := TAU * k / 14.0
		var p := c + Vector2(cos(ang + t * 0.1) * px * (1.2 + (k % 3)), sin(ang) * px * (0.7 + (k % 2)))
		m.draw_circle(p, px * (1.1 + 0.2 * sin(t + k)), Color(0.78, 0.8, 0.8, a * 0.45))
	m.draw_circle(c, px * 1.6, Color(0.82, 0.84, 0.84, a * 0.6))


# The fingerpost: a post and two arms. The carvings only show once you can read them.
func _draw_sign(cell: Rect2) -> void:
	var ink := Color("1d1611")
	var wood := Color("6a4a32")
	var px := cell.size.x
	var post := Rect2(cell.position + Vector2(px * 0.44, px * 0.2), Vector2(px * 0.12, px * 0.8))
	m.draw_rect(post.grow(2.0), ink)
	m.draw_rect(post, wood)
	for side in [-1.0, 1.0]:
		var arm := Rect2(cell.position + Vector2(px * (0.5 if side > 0 else 0.05), px * 0.25), Vector2(px * 0.45, px * 0.18))
		m.draw_rect(arm.grow(2.0), ink)
		m.draw_rect(arm, Color("7a5a3e"))
		if _can_read_sign() and not plan.is_empty():
			var marked: bool = (side > 0) == bool(plan["marked_right"])
			var mid := arm.get_center()
			if marked:
				m.draw_circle(mid, px * 0.06, Color("e8c070"))
			else:
				m.draw_line(mid + Vector2(-px * 0.08, -px * 0.04), mid + Vector2(0, px * 0.04), ink, 2.0)
				m.draw_line(mid + Vector2(0, px * 0.04), mid + Vector2(px * 0.08, -px * 0.04), ink, 2.0)


# The cairn: a heap of small pale crow skulls, dark eyes and beaks.
func _draw_cairn(cell: Rect2) -> void:
	var ink := Color("1d1611")
	var px := cell.size.x
	var base := cell.position + Vector2(px * 0.5, px * 0.8)
	var spots := [Vector2(-0.25, 0), Vector2(0, 0), Vector2(0.25, 0), Vector2(-0.12, -0.2), Vector2(0.12, -0.2), Vector2(0, -0.4)]
	for s in spots:
		var p: Vector2 = base + s * px
		m.draw_circle(p, px * 0.13, ink)
		m.draw_circle(p, px * 0.11, Color("d8d0c0"))
		m.draw_circle(p + Vector2(-px * 0.04, -px * 0.01), px * 0.025, ink)
		m.draw_line(p + Vector2(px * 0.05, px * 0.02), p + Vector2(px * 0.12, px * 0.06), Color("3a3440"), 2.0)
	if event_done and side_tile.x >= 0:
		m.draw_circle(base + Vector2(0, px * 0.12), px * 0.06, Color("e8c070"))


# The hollow tree's hole, low on the trunk, with something pale in it until it's searched.
func _draw_hole(cell: Rect2) -> void:
	var px := cell.size.x
	var c := cell.position + Vector2(px * 0.5, px * 0.7)
	m.draw_circle(c, px * 0.17, Color("1d1611"))
	m.draw_circle(c, px * 0.13, Color("0c0a08"))
	if not event_done:
		m.draw_circle(c + Vector2(0, px * 0.03), px * 0.05, Color("b8b0a0"))


# Where the route ends, drawn over the blocking tiles at the top of the last clearing.
func _draw_dest(r: Rect2i) -> void:
	match route_id:
		"orchard":
			_draw_orchard(r)
		"chapel":
			_draw_chapel(r)
		"grove":
			_draw_grove(r)
		_:
			_draw_mill(r)


# The drowned orchard: black water standing between bare apple trees, a few red apples still on them.
func _draw_orchard(r: Rect2i) -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	var area := Rect2(Vector2(r.position) * px, Vector2(r.size) * px).grow(px * 0.3)
	m.draw_rect(area.grow(2.0), ink)
	m.draw_rect(area, Color("22343c"))
	var t := Time.get_ticks_msec() / 1000.0
	for k in 5:
		var y := area.position.y + area.size.y * (0.25 + 0.15 * k)
		var x := area.position.x + fposmod(t * 4.0 + k * 31.0, area.size.x * 0.7)
		m.draw_line(Vector2(x, y), Vector2(x + px * 0.5, y), Color("4a6a70"), 2.0)
	for k in 3:
		var base := area.position + Vector2(area.size.x * (0.2 + 0.3 * k), area.size.y * (0.75 - 0.2 * (k % 2)))
		m.draw_line(base, base + Vector2(0, -px * 1.3), ink, 7.0)
		m.draw_line(base, base + Vector2(0, -px * 1.3), Color("4a3a2e"), 4.0)
		for side in [-1.0, 1.0]:
			var fork := base + Vector2(0, -px * 1.0)
			var tip := fork + Vector2(side * px * 0.6, -px * 0.5)
			m.draw_line(fork, tip, ink, 4.0)
			m.draw_line(fork, tip, Color("4a3a2e"), 2.0)
			m.draw_circle(tip + Vector2(0, px * 0.12), px * 0.08, Color("8a2a20"))
		m.draw_line(base + Vector2(-px * 0.3, 0), base + Vector2(px * 0.3, 0), Color("4a6a70"), 2.0)


# The chapel on the hill: a grey stone nave with a steep roof, a lit window, and an empty bell-cote.
func _draw_chapel(r: Rect2i) -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	var base := Vector2(r.position) * px
	var w := r.size.x * px
	var h := r.size.y * px
	var nave := Rect2(base + Vector2(w * 0.1, h * 0.35), Vector2(w * 0.8, h * 0.65))
	m.draw_rect(nave.grow(2.0), ink)
	m.draw_rect(nave, Color("7a7a78"))
	for k in 4:
		m.draw_line(nave.position + Vector2(0, nave.size.y * (0.25 + 0.25 * k)), nave.position + Vector2(nave.size.x, nave.size.y * (0.25 + 0.25 * k)), Color("6a6a68"), 1.0)
	var roof := PackedVector2Array([base + Vector2(w * 0.05, h * 0.37), base + Vector2(w * 0.5, -h * 0.05), base + Vector2(w * 0.95, h * 0.37)])
	m.draw_colored_polygon(roof, Color("3a3438"))
	m.draw_polyline(roof, ink, 2.0)
	var cote := Rect2(base + Vector2(w * 0.44, -h * 0.4), Vector2(w * 0.12, h * 0.38))
	m.draw_rect(cote.grow(2.0), ink)
	m.draw_rect(cote, Color("7a7a78"))
	m.draw_rect(Rect2(cote.position + Vector2(cote.size.x * 0.25, cote.size.y * 0.2), cote.size * Vector2(0.5, 0.4)), Color("141018"))
	m.draw_rect(Rect2(base + Vector2(w * 0.45, h * 0.68), Vector2(w * 0.1, h * 0.32)), Color("2a2018"))
	for wx in [0.22, 0.7]:
		m.draw_rect(Rect2(base + Vector2(w * wx, h * 0.5), Vector2(px * 0.3, px * 0.5)), Color("e8c070") if night else Color("3a4450"))


# The Hollow's grove: a ring of great black trunks round a path worn into the ground.
func _draw_grove(r: Rect2i) -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	var c := (Vector2(r.position) + Vector2(r.size) * 0.5) * px
	m.draw_circle(c, px * 1.4, Color("3a3428"))
	m.draw_circle(c, px * 0.9, Color("2a2a20"))
	for k in 7:
		var a := TAU * k / 7.0 - PI * 0.5
		var p := c + Vector2(cos(a) * px * 2.6, sin(a) * px * 1.3)
		m.draw_line(p + Vector2(0, px * 0.4), p + Vector2(0, -px * 1.6), ink, 12.0)
		m.draw_line(p + Vector2(0, px * 0.4), p + Vector2(0, -px * 1.6), Color("1a1814"), 8.0)
	for k in 5:
		var a := Time.get_ticks_msec() / 1500.0 + TAU * k / 5.0
		var p := c + Vector2(cos(a) * px * 1.8, sin(a) * px * 0.7 - px * 1.6)
		m.draw_line(p + Vector2(-px * 0.2, 0), p, Color("141018"), 3.0)
		m.draw_line(p, p + Vector2(px * 0.2, 0), Color("141018"), 3.0)


# The mill: a stone ground floor, a boarded upper floor, a steep roof, and its wheel on the east side.
func _draw_mill(r: Rect2i) -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	var base := Vector2(r.position) * px
	var w := r.size.x * px
	var h := r.size.y * px
	m.draw_rect(Rect2(base + Vector2(0, h * 0.25), Vector2(w * 0.8, h * 0.75)).grow(2.0), ink)
	m.draw_rect(Rect2(base + Vector2(0, h * 0.6), Vector2(w * 0.8, h * 0.4)), Color("7a7570"))
	m.draw_rect(Rect2(base + Vector2(0, h * 0.25), Vector2(w * 0.8, h * 0.35)), Color("6a4a32"))
	var roof := PackedVector2Array([base + Vector2(-px * 0.3, h * 0.27), base + Vector2(w * 0.4, -h * 0.15), base + Vector2(w * 0.8 + px * 0.3, h * 0.27)])
	m.draw_colored_polygon(roof, Color("3a2c26"))
	m.draw_polyline(roof, ink, 2.0)
	m.draw_rect(Rect2(base + Vector2(w * 0.3, h * 0.72), Vector2(px * 0.8, h * 0.28)), Color("2a2018"))
	m.draw_rect(Rect2(base + Vector2(w * 0.12, h * 0.36), Vector2(px * 0.6, px * 0.5)), Color("e8c070"))
	var hub := base + Vector2(w * 0.9, h * 0.62)
	m.draw_circle(hub, px * 1.1, ink)
	m.draw_circle(hub, px * 1.0, Color("5a4030"))
	m.draw_circle(hub, px * 0.7, Color("2a3a3a"))
	for k in 8:
		var a := TAU * k / 8.0 + Time.get_ticks_msec() / 2000.0
		m.draw_line(hub, hub + Vector2(cos(a), sin(a)) * px * 1.0, Color("8a6a48"), 3.0)


# The walker, the crows and the lights off the path: on their own layer above the ground.
func _draw_layer() -> void:
	var px := float(m.PX)
	if not active:
		for id in ROUTES:
			if _waiting(id):
				var w := _walker_tile(id)
				_draw_walker(m._tile_center(w.x, w.y) + Vector2(0, px * 0.42), 0.0, id)
		return
	var shake := 0.0 if nerve > 30.0 else sin(Time.get_ticks_msec() / 40.0) * 1.5
	_draw_walker(walker_pos + Vector2(0, px * 0.42), shake, route_id)
	for foe in m.foes:
		if foe["kind"] == "dog":
			_draw_dog(foe)
	if tall_on:
		_draw_tall(tall_pos + Vector2(0, px * 0.42))
	var t := Time.get_ticks_msec() / 1000.0
	if _event() == "lights" and not event_done:
		for k in 3:
			var p := lights_pos + Vector2(sin(t * 0.7 + k * 2.1) * px * 0.9, cos(t * 0.9 + k * 1.7) * px * 0.5 - px * 0.6)
			layer.draw_circle(p, px * 0.32, Color(0.75, 0.9, 0.8, 0.18))
			layer.draw_circle(p, px * 0.12, Color(0.85, 1.0, 0.9, 0.9))
	if _event() == "crows" and crows_left > 0 and event_point.x >= 0 and (not crows_found or _crows_mobbing()):
		var centre := m._tile_center(event_point.x, event_point.y)
		if _crows_mobbing():
			centre = walker_pos + Vector2(0, -px * 0.6)
		for k in 7:
			var a := t * (1.6 + 0.2 * k) + TAU * k / 7.0
			var p := centre + Vector2(cos(a) * px * (0.8 + 0.15 * k), sin(a) * px * 0.5 - px * 0.3)
			var flap := sin(t * 12.0 + k) * px * 0.12
			m_line(p + Vector2(-px * 0.22, -flap), p, 3.0)
			m_line(p, p + Vector2(px * 0.22, -flap), 3.0)


func m_line(a: Vector2, b: Vector2, width: float) -> void:
	layer.draw_line(a, b, Color("141018"), width)


# The tall one: a thin dark shape twice the farmer's height, its eyes faintly red. Out of your light, only the
# eyes show.
func _draw_tall(f: Vector2) -> void:
	var px := float(m.PX)
	var lit_here: bool = lit and m.player.position.distance_to(f) <= _light_radius() * px
	var body := Color("3a3440") if lit_here else Color(0.1, 0.09, 0.12, 0.6)
	var ink := Color(0.02, 0.02, 0.03, 0.95 if lit_here else 0.5)
	var torso := Rect2(f + Vector2(-px * 0.18, -px * 2.6), Vector2(px * 0.36, px * 2.6))
	layer.draw_rect(torso.grow(2.0), ink)
	layer.draw_rect(torso, body)
	for side in [-1.0, 1.0]:
		layer.draw_line(f + Vector2(side * px * 0.18, -px * 2.2), f + Vector2(side * px * 0.5, -px * 0.8), ink, 6.0)
		layer.draw_line(f + Vector2(side * px * 0.18, -px * 2.2), f + Vector2(side * px * 0.5, -px * 0.8), body, 3.0)
	if lit_here:
		layer.draw_circle(f + Vector2(0, -px * 2.38), px * 0.16, Color("b8b0a8"))
	for dx in [-0.08, 0.08]:
		var eye := f + Vector2(px * dx, -px * 2.4)
		layer.draw_circle(eye, 7.0, Color(0.9, 0.1, 0.05, 0.25))
		layer.draw_circle(eye, 3.0, Color(1.0, 0.2, 0.1, 0.95))


# The walkers, at the farmer's scale. Old Maren: a small bent figure in a grey shawl and a dark skirt, with a stick.
func _draw_walker(f: Vector2, shake: float, id := "mill") -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	f.x += shake
	match id:
		"orchard":
			# The Tull boy: short, a brown jacket, a red scarf and a flat cap.
			_box(Rect2(f + Vector2(-px * 0.18, -px * 0.4), Vector2(px * 0.36, px * 0.4)), Color("3a3a48"))
			_box(Rect2(f + Vector2(-px * 0.22, -px * 0.8), Vector2(px * 0.44, px * 0.42)), Color("6a4a32"))
			layer.draw_rect(Rect2(f + Vector2(-px * 0.2, -px * 0.82), Vector2(px * 0.4, px * 0.1)), Color("9a3028"))
			layer.draw_circle(f + Vector2(0, -px * 0.98), px * 0.19, ink)
			layer.draw_circle(f + Vector2(0, -px * 0.98), px * 0.16, Color("e0c8b0"))
			_box(Rect2(f + Vector2(-px * 0.2, -px * 1.16), Vector2(px * 0.44, px * 0.1)), Color("4a4038"))
			return
		"chapel":
			# The vicar: tall and thin in a black coat with a white collar, a wide black hat.
			_box(Rect2(f + Vector2(-px * 0.22, -px * 1.05), Vector2(px * 0.44, px * 1.05)), Color("201c22"))
			layer.draw_rect(Rect2(f + Vector2(-px * 0.08, -px * 1.05), Vector2(px * 0.16, px * 0.07)), Color("e8e4dc"))
			layer.draw_circle(f + Vector2(0, -px * 1.22), px * 0.19, ink)
			layer.draw_circle(f + Vector2(0, -px * 1.22), px * 0.16, Color("dcc4ac"))
			_box(Rect2(f + Vector2(-px * 0.3, -px * 1.4), Vector2(px * 0.6, px * 0.07)), Color("201c22"))
			_box(Rect2(f + Vector2(-px * 0.15, -px * 1.58), Vector2(px * 0.3, px * 0.18)), Color("201c22"))
			return
		"grove":
			# The woman in the grey shawl: tall, the shawl drawn over her head, her face in its shadow.
			_box(Rect2(f + Vector2(-px * 0.24, -px * 0.6), Vector2(px * 0.48, px * 0.6)), Color("2a2430"))
			_box(Rect2(f + Vector2(-px * 0.28, -px * 1.3), Vector2(px * 0.56, px * 0.75)), Color("7a7a80"))
			layer.draw_circle(f + Vector2(0, -px * 1.2), px * 0.13, Color("141018"))
			return
	_box(Rect2(f + Vector2(-px * 0.22, -px * 0.45), Vector2(px * 0.44, px * 0.45)), Color("3a3040"))
	_box(Rect2(f + Vector2(-px * 0.26, -px * 0.95), Vector2(px * 0.52, px * 0.55)), Color("8a8a90"))
	layer.draw_circle(f + Vector2(0, -px * 1.1), px * 0.2, ink)
	layer.draw_circle(f + Vector2(0, -px * 1.1), px * 0.17, Color("e0c8b0"))
	layer.draw_circle(f + Vector2(0, -px * 1.2), px * 0.15, Color("c8c8c8"))
	layer.draw_line(f + Vector2(px * 0.32, -px * 0.8), f + Vector2(px * 0.38, 0), ink, 4.0)
	layer.draw_line(f + Vector2(px * 0.32, -px * 0.8), f + Vector2(px * 0.38, 0), Color("8a6a48"), 2.0)


# A feral dog: a lean dark body low to the ground, four legs, a pointed head and a hanging tail, pale eyes.
func _draw_dog(foe: Dictionary) -> void:
	var px := float(m.PX)
	var f: Vector2 = foe["pos"] + Vector2(0, px * 0.35)
	var s := float(foe.get("face", 1.0))
	var ink := Color("1d1611")
	var body := Color("e8e0d0") if float(foe["flash"]) > 0.0 else Color("4a3a2e")
	var trot := sin(Time.get_ticks_msec() / 70.0) * px * 0.06 if bool(foe.get("moving", false)) else 0.0
	for k in 4:
		var lx: float = [-0.24, -0.1, 0.12, 0.26][k] * s
		var step := trot if k % 2 == 0 else -trot
		layer.draw_line(f + Vector2(lx * px, -px * 0.24), f + Vector2(lx * px + step, 0), ink, 4.0)
	layer.draw_line(f + Vector2(-px * 0.3 * s, -px * 0.38), f + Vector2(-px * 0.5 * s, -px * 0.2), ink, 4.0)
	_box(Rect2(f + Vector2(-px * 0.32, -px * 0.46), Vector2(px * 0.64, px * 0.22)), body)
	var head := f + Vector2(px * 0.36 * s, -px * 0.52)
	layer.draw_line(head + Vector2(-px * 0.04 * s, -px * 0.08), head + Vector2(-px * 0.02 * s, -px * 0.24), ink, 4.0)
	layer.draw_circle(head, px * 0.15, ink)
	layer.draw_circle(head, px * 0.12, body)
	layer.draw_line(head + Vector2(px * 0.08 * s, px * 0.02), head + Vector2(px * 0.24 * s, px * 0.07), ink, 6.0)
	layer.draw_circle(head + Vector2(px * 0.05 * s, -px * 0.03), 2.0, Color(0.9, 0.78, 0.4))


func _box(r: Rect2, col: Color) -> void:
	layer.draw_rect(r.grow(2.0), Color("1d1611"))
	layer.draw_rect(r, col)
