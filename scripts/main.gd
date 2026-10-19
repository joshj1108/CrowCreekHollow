extends Node2D

## The farm and farmhouse: two plots, turnips and pumpkins, bushcrafting,
## fishing, skills, inventory, gear, lantern tiers, sanity and its cure, quests,
## night events, the walk-in house, the minimap, the action bar, the day clock,
## and save/load. The day runs 06:00 to 03:00. Sleep in bed to save and end the day.
## Placeholder art is drawn in code; no external assets yet.

const TILE_SIZE := 16
const SCALE := 3
const PX := TILE_SIZE * SCALE  # one tile in world units

# The farm is INNER_W x INNER_H tiles of walkable land, surrounded by trees.
const INNER_W := 40
const INNER_H := 24
const BORDER_X := 14
const BORDER_Y := 8
const MAP_W := INNER_W + BORDER_X * 2
const MAP_H := INNER_H + BORDER_Y * 2

# Farmhouse footprint in inner coordinates. It starts at its full final size
# in a decrepit state; repairs change its condition and unlock rooms.
const HOUSE_IX := 26
const HOUSE_IY := 3
const HOUSE_W := 6
const HOUSE_H := 5
const HOUSE_DOOR_IX := HOUSE_IX + 2
const HOUSE_DOOR_IY := HOUSE_IY + HOUSE_H - 1

# The first plot is open from the start. The second is overgrown until Farming 2.
const PLOT_ONE := Rect2i(4, 4, 8, 6)     # inner x, y, width, height
const PLOT_TWO := Rect2i(4, 14, 8, 6)

# The walk-in interior sits below the farm, out of view of it.
const INT_W := 14
const INT_H := 9
const INT_ORIGIN := Vector2i(0, MAP_H + 4)

# Brush piles for bushcrafting, in inner coordinates. They respawn each morning.
const BRUSH_SPOTS := [
	Vector2i(16, 3), Vector2i(22, 15), Vector2i(30, 14),
	Vector2i(2, 18), Vector2i(35, 6), Vector2i(18, 20),
]
# Extra piles that appear once Bushcrafting reaches level 3.
const THICKET_SPOTS := [Vector2i(4, 21), Vector2i(12, 21), Vector2i(26, 20)]
const THICKET_LEVEL := 3

# Time runs from 06:00 to 03:00 the next morning (hours 6 to 27).
const DAY_LENGTH := 240.0   # real seconds for a full day
const START_HOUR := 6.0
const DAY_END_HOUR := 27.0  # 03:00. Missing bed by then means collapsing.
const DUSK_HOUR := 19.0
const SLEEP_HOUR := 18.0    # the bed can be used from 18:00 onward
const EVENT_HOUR := 22.0

const MAX_STAGE := 3        # 0 = seed, 3 = ready to harvest
const STAGE_NAMES := ["Decrepit", "Boarded", "Patched", "Restored"]
# Cost to reach the next house stage, and the Carpentry level it needs.
const REPAIR_COSTS := [
	{"wood": 3, "fiber": 2, "level": 1},
	{"wood": 5, "fiber": 4, "level": 2},
	{"wood": 8, "fiber": 6, "level": 3},
]
const HOUSE_FEATURES := [
	{"stage": 1, "text": "Boarded: the walls hold, and sanity recovers faster indoors"},
	{"stage": 2, "text": "Parlor opens: tidy at the station for Cleaning XP"},
	{"stage": 3, "text": "Study opens, and a restored house softens the night"},
]
const HOUSE_WALLS := [Color("4a3a2e"), Color("6b5340"), Color("8a6a4c"), Color("b08a5e")]
const HOUSE_ROOFS := [Color("2d2620"), Color("4a3a2c"), Color("6b4b33"), Color("8c5a3c")]
const HOUSE_RELIEF := 0.2   # night darkness reduction once the house is restored

# Lantern tiers. Each entry is the next thing to build, in order.
const LANTERN_TIERS := [
	{"name": "Tin Lantern", "radius": 2.5, "wood": 2, "fiber": 2, "resin": 0, "level": 2},
	{"name": "Brass Lantern", "radius": 4.0, "wood": 4, "fiber": 4, "resin": 2, "level": 4},
	{"name": "Hollow Lantern", "radius": 6.0, "wood": 6, "fiber": 6, "resin": 4, "level": 6},
]
const LANTERN_FLICKER_TIER := 3

# Crops. Turnips are the starter crop. Pumpkins need Farming 3 and yield more.
const CROPS := {
	"turnip": {"seed": "seeds", "yield": 1, "xp": 25, "colors": ["8fd16b", "4f9a3a", "2f7a2a", "e8b440"]},
	"pumpkin": {"seed": "pumpkin_seeds", "yield": 3, "xp": 40, "colors": ["9fd27a", "d98a35", "c26a1f", "f2a13a"]},
}
const PUMPKIN_LEVEL := 3
const XP_COOK_FISH := 15
const XP_COOK_CROPS := 10
const COOK_CROP_COUNT := 2
const COOK_WOOD := 1         # wood burned per meal
const MEAL_SANITY := 8.0     # sanity restored by eating a meal

# Pack: crops, fish, and meals share the pack. Seeds have their own pouch.
const BAG_BASE := 20
const BAG_TIERS := [
	{"name": "Satchel", "slots": 10, "coins": 40, "wood": 0, "fiber": 4, "level": 1},
	{"name": "Haversack", "slots": 10, "coins": 120, "wood": 4, "fiber": 8, "level": 3},
	{"name": "Backpack", "slots": 10, "coins": 300, "wood": 8, "fiber": 12, "level": 5},
]
# Storage: the root cellar keeps crops, the cooler keeps fish from spoiling.
const CELLAR_CAP := 30
const COOLER_CAP := 10
const CELLAR_COST := {"wood": 4, "fiber": 2, "coins": 25, "level": 1}
const COOLER_COST := {"wood": 4, "fiber": 4, "coins": 40, "level": 2}
const INT_CELLAR := Vector2i(10, 5)   # interior tiles, local to the house
const INT_COOLER := Vector2i(3, 5)
# The stall sells what you carry and buys seeds. It is open 06:00 to 18:00.
const STALL_IX := 22
const STALL_IY := 9
const STALL_CLOSE_HOUR := 18.0
const SELL_CROP := 4
const SELL_FISH := 6
const SELL_MEAL := 8
const SEED_TURNIP_PRICE := 3    # per seed, sold in packs of 5
const SEED_PUMPKIN_PRICE := 10  # per seed, sold in packs of 3

# Story chapters run in order. The first unfinished one is the Current chapter.
# "story" is the narrative beat, "text" the goal, and "stat" what it reads.
const STORY := [
	{"id": "ground", "title": "Unfamiliar Ground",
		"story": "You wake at the edge of Hallowvale with a hoe and a few seeds. The farmhouse is rotting, the pond is still, and nothing here will feed you unless you put it in the ground.",
		"text": "Plant 3 seeds on the tilled soil.", "stat": "planted", "goal": 3, "reward": {"seeds": 5}},
	{"id": "first_crop", "title": "Food Takes Time",
		"story": "Seeds need days to become food. Each night they grow a stage. Come back when something is ripe, and take it.",
		"text": "Harvest one ripe crop.", "stat": "harvested", "goal": 1, "reward": {"skill": "Farming", "xp": 50}},
	{"id": "wood", "title": "Wood Before Walls",
		"story": "The brush piles around the homestead hide wood and fiber. The house will need both before it can keep the cold out.",
		"text": "Gather from 3 brush piles.", "stat": "gathered", "goal": 3, "reward": {"wood": 2, "fiber": 2}},
	{"id": "hold_door", "title": "Hold the Door",
		"story": "The walls are open to the wind. Board them up so the house can hold a night.",
		"text": "Repair the farmhouse to Boarded.", "stat": "house_stage", "goal": 1, "reward": {"wood": 2, "fiber": 2}},
	{"id": "pond", "title": "Work the Pond",
		"story": "The pond is the only other food on the land. Its fish move in the shallows. Face a sparkling spot and press Space to try for one.",
		"text": "Catch 3 fish.", "stat": "caught", "goal": 3, "reward": {"skill": "Fishing", "xp": 40}},
	{"id": "cook", "title": "A Fire and a Pan",
		"story": "Raw fish sits badly on an empty stomach. Burn a little wood under a pan and cook one of your catches into a meal.",
		"text": "Cook a meal from a fish or crops.", "stat": "cooked", "goal": 1, "reward": {"skill": "Cooking", "xp": 30}},
	{"id": "light", "title": "Light the Way",
		"story": "The night here is longer than the day, and it is not empty. A lantern keeps the dark a little further off.",
		"text": "Build a Tin Lantern.", "stat": "lantern_tier", "goal": 1, "reward": {"seeds": 3}},
	{"id": "bed", "title": "Sleep Under Your Own Roof",
		"story": "Your body can only work so long. The bed is in the bedroom. Reach it before 03:00, or the night takes you where you stand.",
		"text": "Sleep in the bed before 03:00.", "stat": "slept", "goal": 1, "reward": {"skill": "Carpentry", "xp": 40}},
	{"id": "second_plot", "title": "The Overgrown Plot",
		"story": "The second plot is choked with weeds. Clearing it takes more skill than you have yet.",
		"text": "Reach Farming level 2.", "stat": "level_Farming", "goal": 2, "reward": {"pumpkin_seeds": 3}},
	{"id": "tidy", "title": "A Clean Start",
		"story": "The house holds the dust of whoever lived here before. Patch it, then tidy it, so it begins to feel like yours.",
		"text": "Repair the house to Patched and tidy once.", "stat": "tidied", "goal": 1, "reward": {"skill": "Cleaning", "xp": 40}},
	{"id": "winter_store", "title": "Feed Yourself Through the Cold",
		"story": "One crop will not last. Harvest enough to keep a store against the long nights.",
		"text": "Harvest 10 crops.", "stat": "harvested", "goal": 10, "reward": {"skill": "Farming", "xp": 60}},
	{"id": "first_sale", "title": "Coin for Seed",
		"story": "The stall on the path buys what the land gives you. Coins buy seeds, bags, and the rooms the homestead will need. Sell five items to learn how it works.",
		"text": "Sell 5 items at the stall.", "stat": "sold", "goal": 5, "reward": {"coins": 30}},
	{"id": "pumpkin", "title": "Something Sweeter",
		"story": "Pumpkins need more skill than turnips. Reach Farming level 3 and bring one in from the field.",
		"text": "Harvest a pumpkin.", "stat": "pumpkins", "goal": 1, "reward": {"pumpkin_seeds": 2}},
	{"id": "stain", "title": "Clear the Stain",
		"story": "Something in the house has stained the air. Burn an offering of crops and open the windows.",
		"text": "Cleanse the house once.", "stat": "cleansed", "goal": 1, "reward": {"skill": "Cleaning", "xp": 40}},
	{"id": "home", "title": "A Home Worth Keeping",
		"story": "The house is not finished yet, but it could be. Restore it fully and it will hold against the dark.",
		"text": "Restore the farmhouse fully.", "stat": "house_stage", "goal": 3, "reward": {"skill": "Cleaning", "xp": 60}},
]

# Achievements are a tiered list toward 100% completion. Each one tracks a stat.
const ACHIEVEMENT_TIERS := ["Tier I: Settler", "Tier II: Homesteader", "Tier III: Keeper", "Tier IV: Hollow Hand"]
const ACHIEVEMENTS := [
	{"id": "first_seeds", "title": "First Seeds", "text": "Plant a seed.", "tier": 0, "stat": "planted", "goal": 1, "reward": {"seeds": 2}},
	{"id": "first_fruit", "title": "First Fruit", "text": "Harvest a crop.", "tier": 0, "stat": "harvested", "goal": 1, "reward": {"seeds": 2}},
	{"id": "brush_clear", "title": "Brush Clearer", "text": "Gather from 3 brush piles.", "tier": 0, "stat": "gathered", "goal": 3, "reward": {"wood": 2, "fiber": 2}},
	{"id": "first_catch", "title": "Hook and Line", "text": "Catch a fish.", "tier": 0, "stat": "caught", "goal": 1, "reward": {"seeds": 2}},
	{"id": "first_meal", "title": "Warm Meal", "text": "Cook a meal.", "tier": 0, "stat": "cooked", "goal": 1, "reward": {"seeds": 2}},
	{"id": "first_sleep", "title": "Sleeper", "text": "Sleep in your bed.", "tier": 0, "stat": "slept", "goal": 1, "reward": {"seeds": 2}},
	{"id": "tin_light", "title": "Tin Light", "text": "Build a Tin Lantern.", "tier": 0, "stat": "lantern_tier", "goal": 1, "reward": {"seeds": 2}},
	{"id": "boarded", "title": "Boarded Up", "text": "Repair the house to Boarded.", "tier": 0, "stat": "house_stage", "goal": 1, "reward": {"wood": 2, "fiber": 2}},
	{"id": "first_tidy", "title": "Tidy Hands", "text": "Tidy the house once.", "tier": 0, "stat": "tidied", "goal": 1, "reward": {"seeds": 2}},

	{"id": "ten_harvests", "title": "Ten Harvests", "text": "Harvest 10 crops.", "tier": 1, "stat": "harvested", "goal": 10, "reward": {"wood": 2, "fiber": 2}},
	{"id": "carpenter", "title": "Carpenter's Hand", "text": "Mend 6 boards.", "tier": 1, "stat": "mended", "goal": 6, "reward": {"wood": 2, "fiber": 2}},
	{"id": "good_catch", "title": "Good Catch", "text": "Catch 10 fish.", "tier": 1, "stat": "caught", "goal": 10, "reward": {"wood": 2, "fiber": 2}},
	{"id": "meal_plan", "title": "Meal Planner", "text": "Eat 5 meals.", "tier": 1, "stat": "eaten", "goal": 5, "reward": {"wood": 2, "fiber": 2}},
	{"id": "patched", "title": "Patched Up", "text": "Repair the house to Patched.", "tier": 1, "stat": "house_stage", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "brass_light", "title": "Brass Light", "text": "Build a Brass Lantern.", "tier": 1, "stat": "lantern_tier", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "farmer_2", "title": "Growing Hands", "text": "Reach Farming level 2.", "tier": 1, "stat": "level_Farming", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "bush_3", "title": "Thicket Walker", "text": "Reach Bushcrafting level 3.", "tier": 1, "stat": "level_Bushcrafting", "goal": 3, "reward": {"wood": 2, "fiber": 2}},
	{"id": "cleaner", "title": "Clean Air", "text": "Tidy the house 5 times.", "tier": 1, "stat": "tidied", "goal": 5, "reward": {"wood": 2, "fiber": 2}},

	{"id": "restored", "title": "Restored", "text": "Restore the farmhouse fully.", "tier": 2, "stat": "house_stage", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "pumpkin_grower", "title": "Pumpkin Grower", "text": "Harvest 3 pumpkins.", "tier": 2, "stat": "pumpkins", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "cleansed", "title": "Cleansed", "text": "Cleanse the house once.", "tier": 2, "stat": "cleansed", "goal": 1, "reward": {"wood": 3, "fiber": 3}},
	{"id": "fishmonger", "title": "Fishmonger", "text": "Catch 30 fish.", "tier": 2, "stat": "caught", "goal": 30, "reward": {"wood": 3, "fiber": 3}},
	{"id": "carpenter_3", "title": "Tradesman", "text": "Reach Carpentry level 3.", "tier": 2, "stat": "level_Carpentry", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "fisher_3", "title": "Patient Angler", "text": "Reach Fishing level 3.", "tier": 2, "stat": "level_Fishing", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "hollow_light", "title": "Hollow Light", "text": "Build a Hollow Lantern.", "tier": 2, "stat": "lantern_tier", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "survivor", "title": "Survivor", "text": "Sleep in your bed 10 times.", "tier": 2, "stat": "slept", "goal": 10, "reward": {"wood": 3, "fiber": 3}},
	{"id": "watcher", "title": "Field Watcher", "text": "Live through 5 nights of events.", "tier": 2, "stat": "events", "goal": 5, "reward": {"wood": 3, "fiber": 3}},

	{"id": "hundred_harvests", "title": "Full Barns", "text": "Harvest 100 crops.", "tier": 3, "stat": "harvested", "goal": 100, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "master_farmer", "title": "Master Farmer", "text": "Reach Farming level 5.", "tier": 3, "stat": "level_Farming", "goal": 5, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "master_carpenter", "title": "Master Carpenter", "text": "Reach Carpentry level 5.", "tier": 3, "stat": "level_Carpentry", "goal": 5, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "master_fisher", "title": "Master Angler", "text": "Reach Fishing level 5.", "tier": 3, "stat": "level_Fishing", "goal": 5, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "master_cook", "title": "Master Cook", "text": "Reach Cooking level 5.", "tier": 3, "stat": "level_Cooking", "goal": 5, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "feast", "title": "Feast", "text": "Eat 50 meals.", "tier": 3, "stat": "eaten", "goal": 50, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "cleansed_five", "title": "Clean Conscience", "text": "Cleanse the house 5 times.", "tier": 3, "stat": "cleansed", "goal": 5, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "lasting", "title": "Lasting", "text": "Sleep in your bed 30 times.", "tier": 3, "stat": "slept", "goal": 30, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
	{"id": "story_end", "title": "Story Complete", "text": "Finish every story chapter.", "tier": 3, "stat": "story", "goal": 15, "reward": {"seeds": 5, "pumpkin_seeds": 2}},
]

const SKILLS := ["Farming", "Bushcrafting", "Carpentry", "Cleaning", "Fishing", "Cooking"]
const XP_PLANT := 5
const XP_GATHER := 10
const XP_REPAIR := 30
const XP_TIDY := 20
const TIDY_CLEANING_BONUS := 5     # extra sanity from a tidy at Cleaning 2
const XP_MEND := 15
const MEND_WOOD := 1
const MEND_FIBER := 1
const MEND_DAILY_LIMIT := 2   # keeps Carpentry training to a few days per level
const CLEANSE_LEVEL := 3      # Cleaning level needed to cleanse the house
const CLEANSE_CROPS := 2      # crops offered per cleanse
const CLEANSE_RELIEF := 5     # sanity limit restored per cleanse
const XP_FISH := 15
const FISH_SPOT_COUNT := 3
const FISH_SPOT_MIN_LIFE := 15.0   # seconds a spot stays active before it moves
const FISH_SPOT_MAX_LIFE := 30.0
const FISH_TICK_SECONDS := 3.0     # one catch roll per tick while fishing
const FISH_BASE_CHANCE := 0.5      # chance to catch on a tick at Fishing 1
const FISH_CHANCE_PER_LEVEL := 0.03
const FISH_CHANCE_CAP := 0.9
const NO_SPOT := Vector2i(-1, -1)

const STARTING_SEEDS := 5
const MESSAGE_SECONDS := 3.0
const SANITY_MAX := 100.0
const LOW_SANITY := 30.0
const SLEEP_SANITY := 25.0
const TIDY_SANITY := 10.0
const COLLAPSE_SANITY_PENALTY := 5   # permanent cap reduction, curable with a cleanse
const SAVE_PATH := "user://hallowvale_save.json"

# Night events: picked by day so the nights vary. "shadow" says where it appears.
const NIGHT_EVENTS := [
	{"message": "Something stands at the edge of the field.", "shadow": "field", "sanity": -5},
	{"message": "Three slow knocks sound against the house wall.", "shadow": "house", "sanity": -10},
	{"message": "A figure watches from the dark beside the house.", "shadow": "house", "sanity": -15},
	{"message": "The field is quiet tonight. Too quiet.", "shadow": "none", "sanity": -3},
]

enum Tile { TREE, GRASS, SOIL, PATH, WATER, HOUSE, DOOR, FLOOR, WALL, EXIT, BED, STATION, DESK, FALLOW, STALL, CELLAR, COOLER }

const BLOCKING := [Tile.TREE, Tile.WATER, Tile.HOUSE, Tile.WALL, Tile.BED, Tile.STATION, Tile.DESK, Tile.STALL, Tile.CELLAR, Tile.COOLER]

const TILE_COLORS := {
	Tile.TREE: Color("2f4f2f"),
	Tile.GRASS: Color("6a9f4b"),
	Tile.SOIL: Color("7a5234"),
	Tile.PATH: Color("c9a66b"),
	Tile.WATER: Color("3f6fa8"),
	Tile.HOUSE: Color("6b5340"),
	Tile.DOOR: Color("24180f"),
	Tile.FLOOR: Color("5a4634"),
	Tile.WALL: Color("2a211a"),
	Tile.EXIT: Color("3a2e22"),
	Tile.BED: Color("8a4a4a"),
	Tile.STATION: Color("4f6b7a"),
	Tile.DESK: Color("6b5a2e"),
	Tile.FALLOW: Color("4d5a32"),
	Tile.STALL: Color("b5793d"),
	Tile.CELLAR: Color("4a3f5c"),
	Tile.COOLER: Color("5b8fa8"),
}

const BUSH_COLOR := Color("3d6b2a")

const DAY_TINT := Color(1, 1, 1)
const NIGHT_TINT := Color("3a3f6e")

var map: Array = []                 # farm tiles, [y][x]
var interior: Array = []            # house tiles, [y][x], local to INT_ORIGIN
var crops := {}                     # Vector2i world tile -> {"stage": int, "kind": String}
var brush := {}                     # Vector2i world tile -> true while unharvested
var pond_edges: Array = []          # water tiles with land beside them
var fish_spots: Dictionary = {}        # tile -> seconds left before the spot moves
var fishing_tile := NO_SPOT            # the spot being fished, or NO_SPOT
var fish_timer := 0.0
var fish_layer: Node2D
var plot_two_open := false
var clock := 0.0
var current_hour := START_HOUR
var day := 1
var skill_xp := {"Farming": 0, "Bushcrafting": 0, "Carpentry": 0, "Cleaning": 0, "Fishing": 0, "Cooking": 0}
var inventory := {"seeds": STARTING_SEEDS, "pumpkin_seeds": 0, "crops": 0, "fish": 0, "meals": 0}
var materials := {"wood": 0, "fiber": 0, "resin": 0}
var stats := {"planted": 0, "harvested": 0, "gathered": 0, "slept": 0, "tidied": 0,
	"fished": 0, "caught": 0, "mended": 0, "cleansed": 0, "cooked": 0, "eaten": 0,
	"pumpkins": 0, "collapses": 0, "events": 0, "sold": 0, "spoiled": 0}
var achievements_done := {}     # achievement id -> true
var quests_done := {}               # quest id -> true
var selected_seed := "turnip"
var lantern_tier := 0               # 0 = none built yet
var house_stage := 0
var tidied_day := 0
var mend_day := 0                   # the day the mend count applies to
var mends_today := 0
var cleanse_day := 0
var sanity := SANITY_MAX
var sanity_penalty := 0             # permanent cap reduction from collapsing
var inside := false                 # standing in the farmhouse interior
var open_tab := ""                  # "" when the action bar panel is closed
var event_fired_day := 0            # the day the night event last happened
var tonight_shadow := Vector2i(-1, -1)
var shadow_tile := Vector2i.ZERO    # where the field shadow sits
var message_timer := 0.0
var money := 0
var bag_tier := 0               # bag upgrades bought
var cellar_built := false
var cooler_built := false
var cellar_stock := 0          # crops in the root cellar
var cooler_stock := 0          # fish in the cooler

# Set by loading, applied once the world exists.
var saved_pos := Vector2.ZERO
var has_saved_pos := false
var saved_inside := false
var saved_panel := ""

var action_bar: ActionBar
var minimap: Minimap
var canvas_modulate: CanvasModulate
var hud_label: Label
var message_label: Label
var player    # Node2D with player.gd attached
var camera: Camera2D
var lantern_light: PointLight2D


func _ready() -> void:
	_setup_input()
	_build_map()
	_find_pond_edges()
	var loaded := _load_game()
	if not loaded:
		_respawn_brush()
	_build_interior()
	_build_world()
	_build_hud()
	_build_action_bar()
	_update_shadow_tile()
	if loaded:
		_restore_saved_state()
		_show_message("Welcome back. Day %d." % day)


func _process(delta: float) -> void:
	clock += delta
	current_hour = START_HOUR + clock / DAY_LENGTH * (DAY_END_HOUR - START_HOUR)

	if current_hour >= DAY_END_HOUR:
		_collapse()
		return

	if current_hour >= EVENT_HOUR and event_fired_day != day:
		_trigger_night_event()

	var darkness := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, current_hour)
	darkness *= 1.0 - _night_relief()
	darkness = clampf(darkness + _low_sanity_boost(), 0.0, 1.0)
	canvas_modulate.color = DAY_TINT.lerp(NIGHT_TINT, darkness)
	_update_lantern(darkness)
	_update_sanity(darkness, delta)

	_check_doors()
	_check_unlocks()
	_check_story()
	_check_achievements()
	_update_fish_spots(delta)
	_update_fishing(delta)

	var minutes := int(fmod(current_hour, 1.0) * 60.0)
	hud_label.text = "Day %d   %02d:%02d   Sanity %d/%d   Coins %d" % [
		day, int(fmod(current_hour, 24.0)), minutes, int(sanity), _sanity_max(), money]

	_handle_keys()

	# Farming and gathering pause while a panel is open.
	if Input.is_action_just_pressed("use") and open_tab == "":
		_interact()

	if open_tab != "":
		_refresh_panel()

	_update_minimap()

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""


func _draw() -> void:
	for y in MAP_H:
		for x in MAP_W:
			var tile: int = map[y][x]
			draw_rect(_tile_rect(Vector2i(x, y)), TILE_COLORS[tile])

	for y in INT_H:
		for x in INT_W:
			var kind: int = interior[y][x]
			draw_rect(_tile_rect(INT_ORIGIN + Vector2i(x, y)), TILE_COLORS[kind])

	for pos in crops:
		var crop: Dictionary = crops[pos]
		var colors: Array = CROPS[crop["kind"]]["colors"]
		var stage: int = crop["stage"]
		var center := _tile_center(pos.x, pos.y)
		var size := PX * (0.2 + 0.2 * stage)
		draw_rect(Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), Color(colors[stage]))

	for pos in brush:
		var center := _tile_center(pos.x, pos.y)
		draw_circle(center, PX * 0.32, BUSH_COLOR)
		draw_circle(center + Vector2(-4, -4), PX * 0.1, Color("5d8f3e"))

	_draw_house()

	if tonight_shadow.x >= 0:
		var s := _tile_center(tonight_shadow.x, tonight_shadow.y)
		draw_circle(s, PX * 0.6, Color(0.02, 0.01, 0.05, 0.9))
		draw_circle(s + Vector2(-8, -6), 3, Color(0.9, 0.1, 0.1))
		draw_circle(s + Vector2(8, -6), 3, Color(0.9, 0.1, 0.1))


func _draw_house() -> void:
	var origin := _world_tile(HOUSE_IX, HOUSE_IY)
	var rect := Rect2(Vector2(origin) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	var stage := house_stage

	draw_rect(rect, HOUSE_WALLS[stage])
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, PX * 1.4)), HOUSE_ROOFS[stage])

	# The door fills the bottom-middle tile of the footprint.
	var door_pos := rect.position + Vector2(2 * PX, (HOUSE_H - 1) * PX)
	draw_rect(Rect2(door_pos, Vector2(PX, PX)), Color("24180f"))

	# Windows on either side of the door. Boarded until the house is patched.
	for wx in [0.15, 0.7]:
		var win := Rect2(rect.position + Vector2(rect.size.x * wx, PX * 2.0), Vector2(PX * 1.2, PX * 1.2))
		draw_rect(win, Color("9bb7c4") if stage >= 2 else Color("1d1712"))
		if stage < 2:
			draw_rect(Rect2(win.position + Vector2(0, win.size.y * 0.4), Vector2(win.size.x, 4)), Color("3a2a1c"))
			draw_rect(Rect2(win.position + Vector2(0, win.size.y * 0.7), Vector2(win.size.x, 4)), Color("3a2a1c"))

	# A missing roof patch shows the house is decrepit.
	if stage == 0:
		draw_rect(Rect2(rect.end.x - PX * 2.2, rect.position.y + 6, PX * 1.4, PX * 0.9), Color("0d0a08"))


# --- Setup -------------------------------------------------------------------

func _setup_input() -> void:
	# Keyboard, with gamepad bindings alongside each action.
	_ensure_action("move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_ensure_action("move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_ensure_action("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	for move in ["move_up", "move_down", "move_left", "move_right"]:
		InputMap.action_set_deadzone(move, 0.3)
	_ensure_action("use", [KEY_SPACE, KEY_ENTER], [JOY_BUTTON_A])
	_ensure_action("skills", [KEY_K], [JOY_BUTTON_Y])
	_ensure_action("inventory", [KEY_I], [JOY_BUTTON_X])
	_ensure_action("gear", [KEY_G], [JOY_BUTTON_LEFT_SHOULDER])
	_ensure_action("quests", [KEY_Q], [JOY_BUTTON_RIGHT_SHOULDER])
	_ensure_action("achievements", [KEY_J], [JOY_BUTTON_RIGHT_STICK])
	_ensure_action("house", [KEY_H], [JOY_BUTTON_BACK])
	_ensure_action("settings", [KEY_ESCAPE], [JOY_BUTTON_START])
	_ensure_action("close_panel", [], [JOY_BUTTON_B])


# Adds keys, gamepad buttons, and stick directions to an action. Each axis entry
# is [axis, direction], where direction is -1.0 or 1.0 along that axis.
func _ensure_action(action: String, keys: Array, buttons: Array = [], axes: Array = []) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in buttons:
		var pad := InputEventJoypadButton.new()
		pad.button_index = b
		InputMap.action_add_event(action, pad)
	for entry in axes:
		var motion := InputEventJoypadMotion.new()
		motion.axis = entry[0]
		motion.axis_value = entry[1]
		InputMap.action_add_event(action, motion)


func _build_map() -> void:
	map = []
	for y in MAP_H:
		var row: Array = []
		for x in MAP_W:
			var ix := x - BORDER_X
			var iy := y - BORDER_Y
			var t := Tile.TREE
			if ix >= 0 and ix < INNER_W and iy >= 0 and iy < INNER_H:
				t = Tile.GRASS
				if iy == INNER_H / 2 or ix == INNER_W / 2:
					t = Tile.PATH
				if PLOT_ONE.has_point(Vector2i(ix, iy)):
					t = Tile.SOIL
				if PLOT_TWO.has_point(Vector2i(ix, iy)):
					t = Tile.FALLOW   # cleared once Farming reaches level 2
				if ix >= INNER_W - 6 and iy >= INNER_H - 6:
					t = Tile.WATER
				if ix >= HOUSE_IX and ix < HOUSE_IX + HOUSE_W and iy >= HOUSE_IY and iy < HOUSE_IY + HOUSE_H:
					t = Tile.HOUSE
				if ix == STALL_IX and iy == STALL_IY:
					t = Tile.STALL
				if ix == HOUSE_DOOR_IX and iy == HOUSE_DOOR_IY:
					t = Tile.DOOR
			row.append(t)
		map.append(row)


# The interior is a fixed layout. Rooms open up as the house is repaired.
func _build_interior() -> void:
	interior = []
	for y in INT_H:
		var row: Array = []
		for x in INT_W:
			row.append(Tile.WALL)
		interior.append(row)

	_fill_interior(1, 5, 12, 7, Tile.FLOOR)   # the hall, always open
	_set_interior(6, 8, Tile.EXIT)            # back out to the farm
	if cooler_built:
		_set_interior(INT_COOLER.x, INT_COOLER.y, Tile.COOLER)
	if cellar_built:
		_set_interior(INT_CELLAR.x, INT_CELLAR.y, Tile.CELLAR)

	# The bedroom and its bed are open from the start.
	_fill_interior(1, 1, 4, 4, Tile.FLOOR)
	_set_interior(2, 1, Tile.BED)
	if house_stage >= 2:
		_fill_interior(9, 1, 12, 4, Tile.FLOOR)
		_set_interior(11, 1, Tile.STATION)
	if house_stage >= 3:
		_fill_interior(5, 1, 8, 4, Tile.FLOOR)
		_set_interior(6, 1, Tile.DESK)


func _fill_interior(x0: int, y0: int, x1: int, y1: int, kind: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			interior[y][x] = kind


func _set_interior(x: int, y: int, kind: int) -> void:
	interior[y][x] = kind


func _respawn_brush() -> void:
	brush.clear()
	for spot in BRUSH_SPOTS:
		brush[_world_tile(spot.x, spot.y)] = true
	if _level("Bushcrafting") >= THICKET_LEVEL:
		for spot in THICKET_SPOTS:
			brush[_world_tile(spot.x, spot.y)] = true
	queue_redraw()


func _build_world() -> void:
	# The fishing spots are drawn on their own layer, under the player.
	fish_layer = Node2D.new()
	fish_layer.draw.connect(_draw_fish_spots)
	add_child(fish_layer)

	player = Node2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.position = _tile_center(BORDER_X + INNER_W / 2, BORDER_Y + INNER_H / 2)
	player.is_blocked = _is_blocked_world
	add_child(player)
	_build_lantern_light()

	camera = Camera2D.new()
	camera.enabled = true
	player.add_child(camera)
	_set_bounds()

	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)


func _build_lantern_light() -> void:
	# A soft white-to-black radial gradient, tinted warm. Its size follows the lantern tier.
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color.BLACK)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256

	lantern_light = PointLight2D.new()
	lantern_light.texture = texture
	lantern_light.color = Color("ffd38a")
	lantern_light.energy = 1.0
	lantern_light.enabled = false
	player.add_child(lantern_light)
	_apply_lantern_radius()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_label = _make_label(layer, Vector2(16, 12), 24)
	message_label = _make_label(layer, Vector2(16, 100), 20)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(620, 0)

	minimap = Minimap.new()
	var mini_size := Vector2(MAP_W, MAP_H) * Minimap.PX_PER_TILE
	minimap.custom_minimum_size = mini_size
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_left = -(mini_size.x + 12.0)
	minimap.offset_right = -12.0
	minimap.offset_top = 12.0
	minimap.offset_bottom = 12.0 + mini_size.y
	layer.add_child(minimap)


func _build_action_bar() -> void:
	action_bar = ActionBar.new()
	add_child(action_bar)
	action_bar.tab_pressed.connect(_toggle_tab)
	action_bar.action_pressed.connect(_on_panel_action)


func _make_label(parent: Node, pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


# Applies what loading saved: position, indoors or not, and the open panel.
func _restore_saved_state() -> void:
	_check_unlocks()
	if has_saved_pos:
		player.position = saved_pos
	if saved_inside:
		inside = true
	_set_bounds()
	if saved_panel != "":
		_toggle_tab(saved_panel)


func _update_minimap() -> void:
	# Indoors the minimap shows the house, since the player isn't on the farm.
	var player_tile: Vector2 = Vector2(HOUSE_DOOR_IX + BORDER_X, HOUSE_DOOR_IY + BORDER_Y) if inside else player.position / PX
	minimap.update_view(map, TILE_COLORS, brush.keys(), player_tile, tonight_shadow)


# --- Input and panels --------------------------------------------------------

func _handle_keys() -> void:
	if Input.is_action_just_pressed("skills"):
		_toggle_tab("Skills")
	if Input.is_action_just_pressed("inventory"):
		_toggle_tab("Inventory")
	if Input.is_action_just_pressed("gear"):
		_toggle_tab("Gear")
	if Input.is_action_just_pressed("quests"):
		_toggle_tab("Quests")
	if Input.is_action_just_pressed("achievements"):
		_toggle_tab("Achievements")
	if Input.is_action_just_pressed("house"):
		_toggle_tab("House")
	# Esc or Start opens Settings, or closes it if it's already open.
	if Input.is_action_just_pressed("settings"):
		_toggle_tab("Settings")
	# B closes whatever panel is open.
	if Input.is_action_just_pressed("close_panel") and open_tab != "":
		_close_panel()


func _toggle_tab(tab: String) -> void:
	if open_tab == tab:
		_close_panel()
	else:
		open_tab = tab
		_refresh_panel()


func _close_panel() -> void:
	open_tab = ""
	action_bar.hide_panel()


func _on_panel_action(action_id: String) -> void:
	match action_id:
		"close":
			_close_panel()
		"repair":
			_repair_house()
		"mend":
			_mend_house()
		"cleanse":
			_cleanse_house()
		"tidy":
			_tidy_house()
		"advance_lantern":
			_advance_lantern()
		"switch_seed":
			_switch_seed()
		"cook_fish":
			_cook_fish()
		"cook_crops":
			_cook_crops()
		"eat_meal":
			_eat_meal()
		"sell_crops":
			_sell("crops")
		"sell_fish":
			_sell("fish")
		"sell_meals":
			_sell("meals")
		"buy_turnip":
			_buy_seeds("turnip")
		"buy_pumpkin":
			_buy_seeds("pumpkin")
		"upgrade_bag":
			_upgrade_bag()
		"build_cellar":
			_build_storage("cellar")
		"build_cooler":
			_build_storage("cooler")
		"store_crops":
			_store_crops()
		"take_crops":
			_take_crops()
		"store_fish":
			_store_fish()
		"take_fish":
			_take_fish()


func _refresh_panel() -> void:
	var rows: Array = []
	match open_tab:
		"Skills":
			rows = _skill_rows()
		"Inventory":
			rows = _inventory_rows()
		"Gear":
			rows = _gear_rows()
		"Quests":
			rows = _quest_rows()
		"Achievements":
			rows = _achievement_rows()
		"Trade":
			rows = _trade_rows()
		"Cellar":
			rows = _cellar_rows()
		"Cooler":
			rows = _cooler_rows()
		"House":
			rows = _house_rows()
		"Settings":
			rows = _settings_rows()
	action_bar.show_panel(open_tab, rows)


func _skill_rows() -> Array:
	var rows: Array = []
	for skill in SKILLS:
		rows.append({
			"name": "%s   Lv %d" % [skill, _level(skill)],
			"value": "%d XP" % skill_xp[skill],
			"progress": float(skill_xp[skill] % 100) / 100.0,
		})
	rows.append({"note": "Farming grows crops. Bushcrafting gathers wood, fiber, and resin. Carpentry trains by mending boards and repairing the house. Cleaning tidies it. Fishing works the sparkling spots at the pond. Cooking turns catches and crops into meals."})
	return rows


func _inventory_rows() -> Array:
	var rows: Array = [
		{"section": "Pack"},
		{"name": "Coins", "value": str(money)},
		{"grid": _pack_cells(), "columns": 5},
		{
			"name": "Pack space",
			"value": "%d/%d" % [_pack_used(), _pack_capacity()],
			"progress": float(_pack_used()) / float(_pack_capacity()),
		},
	]
	if bag_tier < BAG_TIERS.size():
		var tier: Dictionary = BAG_TIERS[bag_tier]
		rows.append({
			"name": "Next bag: %s (+%d slots)" % [tier["name"], tier["slots"]],
			"value": _price_text(tier),
			"button": "Upgrade",
			"action": "upgrade_bag",
			"enabled": _can_upgrade_bag(),
		})
	rows.append({"note": "Crops, fish, and meals fill the pack. Seeds have their own pouch, and materials are uncapped for now."})
	rows.append({"section": "Seed pouch"})
	rows.append({"grid": _seed_cells(), "columns": 5})
	rows.append({"section": "Planting"})
	rows.append({"name": "Planting with", "value": _seed_label(selected_seed)})
	if _level("Farming") >= PUMPKIN_LEVEL:
		rows.append({
			"name": "Switch seed",
			"value": "Turnip or Pumpkin",
			"button": "Switch",
			"action": "switch_seed",
			"enabled": true,
		})
	rows.append({"section": "Cooking"})
	rows.append({
		"name": "Cook a fish",
		"value": "1 fish, 1 wood: +%d Cooking XP" % XP_COOK_FISH,
		"button": "Cook",
		"action": "cook_fish",
		"enabled": _can_cook_fish(),
	})
	rows.append({
		"name": "Cook crops",
		"value": "%d crops, 1 wood: +%d Cooking XP" % [COOK_CROP_COUNT, XP_COOK_CROPS],
		"button": "Cook",
		"action": "cook_crops",
		"enabled": _can_cook_crops(),
	})
	rows.append({
		"name": "Eat a meal",
		"value": "%d ready, +%d sanity" % [int(inventory["meals"]), int(MEAL_SANITY)],
		"button": "Eat",
		"action": "eat_meal",
		"enabled": int(inventory["meals"]) > 0,
	})
	rows.append({"section": "Materials"})
	rows.append({"name": "Wood", "value": str(materials["wood"])})
	rows.append({"name": "Fiber", "value": str(materials["fiber"])})
	rows.append({"name": "Resin", "value": str(materials["resin"])})
	return rows


func _gear_rows() -> Array:
	var rows: Array = [
		{"section": "Equipped"},
		{"grid": _gear_cells(), "columns": 3},
		{"section": "Lantern"},
	]
	if lantern_tier == 0:
		rows.append({"name": "Lantern", "value": "not built"})
	else:
		var current: Dictionary = LANTERN_TIERS[lantern_tier - 1]
		rows.append({"name": current["name"], "value": "light ring %.1f tiles" % current["radius"]})
	if lantern_tier < LANTERN_TIERS.size():
		var upcoming: Dictionary = LANTERN_TIERS[lantern_tier]
		rows.append({
			"name": "Next: %s" % upcoming["name"],
			"value": _cost_text(upcoming),
			"button": "Build" if lantern_tier == 0 else "Upgrade",
			"action": "advance_lantern",
			"enabled": _can_advance_lantern(),
		})
	rows.append({"note": "A lantern lights a ring around you in the dark. Each tier needs more Bushcrafting and better materials."})
	return rows


func _quest_rows() -> Array:
	var rows: Array = []
	var current: Variant = null
	for q in STORY:
		if not quests_done.has(q["id"]):
			current = q
			break
	if current != null:
		rows.append({"section": "Current chapter"})
		rows.append(_quest_row(current, true))
	else:
		rows.append({"note": "You have reached the end of the story for now. More chapters are coming."})
	rows.append({"section": "Chapters"})
	for q in STORY:
		rows.append(_quest_row(q, false))
	return rows


func _quest_row(q: Dictionary, expanded: bool) -> Dictionary:
	var done: bool = quests_done.has(q["id"])
	var shown := mini(_stat_value(q["stat"]), q["goal"])
	var note := "%s  Reward: %s" % [q["text"], _reward_text(q["reward"])]
	if expanded:
		note = "%s\n%s" % [q["story"], note]
	return {
		"name": "%s%s" % [q["title"], "   (done)" if done else ""],
		"value": "%d/%d" % [shown, q["goal"]],
		"progress": float(shown) / float(q["goal"]),
		"note": note,
	}





func _house_rows() -> Array:
	var rows: Array = [
		{"section": "Condition"},
		{"name": "Farmhouse", "value": STAGE_NAMES[house_stage]},
	]
	if house_stage < MAX_STAGE:
		var cost: Dictionary = REPAIR_COSTS[house_stage]
		rows.append({
			"name": "Repair to %s" % STAGE_NAMES[house_stage + 1],
			"value": "%d wood, %d fiber, Carpentry %d" % [cost["wood"], cost["fiber"], cost["level"]],
			"button": "Repair",
			"action": "repair",
			"enabled": _can_repair(),
		})
	rows.append({
		"name": "Mend a board",
		"value": "%d wood, %d fiber: +%d XP (%d left today)" % [MEND_WOOD, MEND_FIBER, XP_MEND, _mends_left()],
		"button": "Mend",
		"action": "mend",
		"enabled": _can_mend(),
	})
	rows.append({"section": "Rest"})
	rows.append({"note": "The bed is in the bedroom. Walk there and press Space from 18:00 to save and end the day. If you aren't in bed by 03:00 you collapse, and your sanity limit drops permanently."})
	rows.append({"name": "Sanity limit", "value": "%d of %d" % [_sanity_max(), int(SANITY_MAX)]})
	rows.append({
		"name": "Cleanse the house",
		"value": "%d crops, Cleaning %d, once a day: +%d limit" % [CLEANSE_CROPS, CLEANSE_LEVEL, CLEANSE_RELIEF],
		"button": "Cleanse",
		"action": "cleanse",
		"enabled": _can_cleanse(),
	})
	rows.append({
		"name": "Tidy",
		"value": "once a day",
		"button": "Tidy",
		"action": "tidy",
		"enabled": _can_tidy(),
	})
	rows.append({"section": "Storage"})
	if cellar_built:
		rows.append({"name": "Root cellar", "value": "built, holds %d crops" % CELLAR_CAP})
	else:
		rows.append({
			"name": "Build a root cellar (holds %d crops)" % CELLAR_CAP,
			"value": _price_text(CELLAR_COST),
			"button": "Build",
			"action": "build_cellar",
			"enabled": _can_afford(CELLAR_COST),
		})
	if cooler_built:
		rows.append({"name": "Cooler", "value": "built, keeps %d fish fresh" % COOLER_CAP})
	else:
		rows.append({
			"name": "Build a cooler (keeps %d fish fresh)" % COOLER_CAP,
			"value": _price_text(COOLER_COST),
			"button": "Build",
			"action": "build_cooler",
			"enabled": _can_afford(COOLER_COST),
		})
	rows.append({"section": "Features"})
	for feature in HOUSE_FEATURES:
		var unlocked: bool = house_stage >= feature["stage"]
		rows.append({
			"name": feature["text"],
			"value": "unlocked" if unlocked else "at %s" % STAGE_NAMES[feature["stage"]],
		})
	return rows


func _settings_rows() -> Array:
	return [
		{"section": "Controls"},
		{"name": "Move", "value": "WASD or arrow keys"},
		{"name": "Use, plant, harvest, gather, sleep", "value": "Space or Enter"},
		{"name": "Skills", "value": "K"},
		{"name": "Inventory", "value": "I"},
		{"name": "Gear", "value": "G"},
		{"name": "Quests", "value": "Q"},
		{"name": "Achievements", "value": "J"},
		{"name": "House", "value": "H"},
		{"name": "Settings", "value": "Esc"},
		{"section": "Gamepad"},
		{"name": "Move", "value": "Left stick or D-pad"},
		{"name": "Use, plant, harvest, gather, sleep", "value": "A"},
		{"name": "Close panel", "value": "B"},
		{"name": "Skills / Inventory", "value": "Y / X"},
		{"name": "Gear / Quests", "value": "Left / Right bumper"},
		{"name": "Achievements", "value": "Right stick click"},
		{"name": "House", "value": "Back / View"},
		{"name": "Settings", "value": "Start"},
		{"note": "While a panel is open, the D-pad or left stick moves between its buttons, and A presses the highlighted one."},
		{"section": "Saving"},
		{"note": "Progress saves only when you sleep, or when you collapse at 03:00. The save includes your position and open panel."},
		{"note": "Sound and display options are coming later."},
	]


# --- Farming ----------------------------------------------------------------

func _seed_label(kind: String) -> String:
	return "Pumpkin" if kind == "pumpkin" else "Turnip"


func _switch_seed() -> void:
	selected_seed = "turnip" if selected_seed == "pumpkin" else "pumpkin"
	_show_message("You'll plant %s seeds now." % _seed_label(selected_seed).to_lower())


# Opens the second plot once Farming reaches level 2. It stays open afterward.
func _check_unlocks() -> void:
	if plot_two_open or _level("Farming") < 2:
		return
	plot_two_open = true
	for y in range(PLOT_TWO.position.y, PLOT_TWO.end.y):
		for x in range(PLOT_TWO.position.x, PLOT_TWO.end.x):
			map[y + BORDER_Y][x + BORDER_X] = Tile.SOIL
	queue_redraw()


func _interact() -> void:
	if _is_fishing():
		_stop_fishing("You reel in your line.")
		return
	var tile := _tile_in_front()
	# Interior tiles sit outside the farm's bounds, so accept either area.
	if not _in_bounds(tile) and not _in_interior(tile):
		return

	if inside:
		match _kind_at(tile):
			Tile.BED:
				_try_sleep()
			Tile.STATION:
				_tidy_house()
			Tile.DESK:
				_read_desk()
			Tile.CELLAR:
				_toggle_tab("Cellar")
			Tile.COOLER:
				_toggle_tab("Cooler")
		return

	if fish_spots.has(tile):
		_start_fishing(tile)
		return

	if brush.has(tile):
		_gather(tile)
		return

	var kind: int = map[tile.y][tile.x]
	if kind == Tile.HOUSE:
		_toggle_tab("House")
		return
	if kind == Tile.STALL:
		_open_stall()
		return
	if kind == Tile.FALLOW:
		_show_message("Overgrown. Reach Farming level 2 to clear this plot.")
		return
	if kind != Tile.SOIL:
		return

	if crops.has(tile):
		if crops[tile]["stage"] >= MAX_STAGE:
			_harvest(tile)
		else:
			_show_message("It isn't ready yet.")
	else:
		_plant(tile)

	queue_redraw()


func _plant(tile: Vector2i) -> void:
	var kind := selected_seed
	if kind == "pumpkin" and _level("Farming") < PUMPKIN_LEVEL:
		kind = "turnip"
	var seed_key: String = CROPS[kind]["seed"]
	if inventory[seed_key] <= 0:
		_show_message("You're out of %s seeds." % _seed_label(kind).to_lower())
		return
	inventory[seed_key] -= 1
	crops[tile] = {"stage": 0, "kind": kind}
	stats["planted"] += 1
	_grant_xp("Farming", XP_PLANT)
	_show_message("Planted %s. +%d Farming XP" % [_seed_label(kind).to_lower(), XP_PLANT])


func _harvest(tile: Vector2i) -> void:
	var kind: String = crops[tile]["kind"]
	var yield_count: int = CROPS[kind]["yield"]
	# Harvests go to the pack only. Storing in the cellar is up to the player.
	if _pack_free() < yield_count:
		_show_message("Your pack is full. Store crops in the root cellar, or sell them.")
		return
	inventory["crops"] += yield_count
	crops.erase(tile)
	stats["harvested"] += 1
	if kind == "pumpkin":
		stats["pumpkins"] += 1
		inventory["pumpkin_seeds"] += 1
	else:
		inventory["seeds"] += 1
	var xp: int = CROPS[kind]["xp"]
	_grant_xp("Farming", xp)
	_show_message("Harvested %s for %d crops. +%d Farming XP" % [_seed_label(kind).to_lower(), yield_count, xp])


func _read_desk() -> void:
	_show_message("A desk covered in seed catalogs and unpaid bills.")


func _gather(tile: Vector2i) -> void:
	brush.erase(tile)
	materials["wood"] += 1
	materials["fiber"] += 1
	stats["gathered"] += 1
	var found := "wood and fiber"
	if randf() < 0.34:
		materials["resin"] += 1
		found = "wood, fiber, and resin"
	_grant_xp("Bushcrafting", XP_GATHER)
	_show_message("Gathered %s from the brush. +%d Bushcrafting XP" % [found, XP_GATHER])
	queue_redraw()


# --- Fishing ----------------------------------------------------------------

# Water tiles that touch land. Fishing spots are picked from these.
func _find_pond_edges() -> void:
	pond_edges = []
	for y in MAP_H:
		for x in MAP_W:
			if map[y][x] != Tile.WATER:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if _in_bounds(n) and map[n.y][n.x] == Tile.GRASS:
					pond_edges.append(Vector2i(x, y))
					break


# Fishing level 3 and up adds spots: one more at 3, another at 5.
func _fish_spot_count() -> int:
	return FISH_SPOT_COUNT + (_level("Fishing") - 1) / 2


func _update_fish_spots(delta: float) -> void:
	# Each spot runs down its life. When it goes quiet, it moves to a new place.
	for tile in fish_spots.keys():
		fish_spots[tile] -= delta
		if fish_spots[tile] <= 0.0:
			fish_spots.erase(tile)
			if tile == fishing_tile:
				_stop_fishing("The fish have moved on from your spot.")
	# Refill up to the count for the current Fishing level.
	while fish_spots.size() < _fish_spot_count() and _spawn_fish_spot():
		pass
	# The sparkle pulses and fades, so the layer redraws every frame.
	if fish_layer != null:
		fish_layer.queue_redraw()


func _spawn_fish_spot() -> bool:
	var options: Array = []
	for edge in pond_edges:
		if not fish_spots.has(edge):
			options.append(edge)
	if options.is_empty():
		return false
	var pick: Vector2i = options.pick_random()
	fish_spots[pick] = randf_range(FISH_SPOT_MIN_LIFE, FISH_SPOT_MAX_LIFE)
	return true


func _is_fishing() -> bool:
	return fishing_tile != NO_SPOT


func _start_fishing(tile: Vector2i) -> void:
	if _pack_free() < 1:
		_show_message("Your pack is full. Store fish in the cooler, or sell or cook them first.")
		return
	fishing_tile = tile
	fish_timer = FISH_TICK_SECONDS
	_show_message("You cast your line. Stay put and keep fishing.")


func _stop_fishing(reason: String) -> void:
	fishing_tile = NO_SPOT
	if reason != "":
		_show_message(reason)


# While fishing, roll for a catch every tick. Moving, going inside, or
# opening a panel reels the line in.
func _update_fishing(delta: float) -> void:
	if not _is_fishing():
		return
	var moved := Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
	if moved or inside or open_tab != "" or _tile_in_front() != fishing_tile:
		_stop_fishing("You reel in your line.")
		return
	fish_timer -= delta
	if fish_timer > 0.0:
		return
	fish_timer = FISH_TICK_SECONDS
	if _pack_free() < 1:
		_stop_fishing("Your pack is full. Store fish in the cooler, or sell or cook them.")
		return
	_fish_roll()


func _draw_fish_spots() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var i := 0
	for tile in fish_spots:
		var c := _tile_center(tile.x, tile.y)
		# Spots fade out over their last four seconds before they move.
		var fade := clampf(float(fish_spots[tile]) / 4.0, 0.0, 1.0)
		var pulse := 0.75 + 0.25 * sin(t * 5.0 + i)
		fish_layer.draw_circle(c, PX * 0.22 * pulse, Color(0.85, 0.97, 1.0, 0.3 * fade))
		var r := PX * 0.28 * pulse
		var star := Color(1.0, 1.0, 0.75, 0.95 * fade)
		fish_layer.draw_line(c + Vector2(-r, 0), c + Vector2(r, 0), star, 2.0)
		fish_layer.draw_line(c + Vector2(0, -r), c + Vector2(0, r), star, 2.0)
		if tile == fishing_tile:
			fish_layer.draw_arc(c, PX * 0.45, 0.0, TAU, 24, Color(0.7, 0.9, 1.0, 0.8), 2.0)
		i += 1


func _fish_roll() -> void:
	stats["fished"] += 1
	var chance := clampf(FISH_BASE_CHANCE + FISH_CHANCE_PER_LEVEL * float(_level("Fishing") - 1), 0.0, FISH_CHANCE_CAP)
	if randf() < chance:
		stats["caught"] += 1
		inventory["fish"] += 1
		_grant_xp("Fishing", XP_FISH)
		_show_message("You hook a fish! +%d Fishing XP" % XP_FISH)
	else:
		_show_message("Nothing yet. Keep still.")


# --- Cooking -----------------------------------------------------------------

func _can_cook_fish() -> bool:
	return int(inventory["fish"]) > 0 and int(materials["wood"]) >= COOK_WOOD


func _cook_fish() -> void:
	if not _can_cook_fish():
		_show_message("You need a fish and a piece of wood to cook.")
		return
	inventory["fish"] -= 1
	materials["wood"] -= COOK_WOOD
	inventory["meals"] += 1
	stats["cooked"] += 1
	_grant_xp("Cooking", XP_COOK_FISH)
	_show_message("You cook the fish over a small fire. +%d Cooking XP" % XP_COOK_FISH)


func _can_cook_crops() -> bool:
	return int(inventory["crops"]) >= COOK_CROP_COUNT and int(materials["wood"]) >= COOK_WOOD


func _cook_crops() -> void:
	if not _can_cook_crops():
		_show_message("You need %d crops and a piece of wood to cook." % COOK_CROP_COUNT)
		return
	inventory["crops"] -= COOK_CROP_COUNT
	materials["wood"] -= COOK_WOOD
	inventory["meals"] += 1
	stats["cooked"] += 1
	_grant_xp("Cooking", XP_COOK_CROPS)
	_show_message("You stew the crops into a meal. +%d Cooking XP" % XP_COOK_CROPS)


func _eat_meal() -> void:
	if int(inventory["meals"]) <= 0:
		_show_message("You have nothing to eat.")
		return
	inventory["meals"] -= 1
	stats["eaten"] += 1
	_change_sanity(MEAL_SANITY)
	_show_message("You eat a warm meal. Your mind steadies a little.")


# --- Achievements ------------------------------------------------------------

func _achievement_rows() -> Array:
	var total := ACHIEVEMENTS.size()
	var done_count := achievements_done.size()
	var rows: Array = [
		{"section": "Completion"},
		{
			"name": "Achievements",
			"value": "%d/%d  (%d%%)" % [done_count, total, int(100.0 * done_count / total)],
			"progress": float(done_count) / float(total),
		},
	]
	if done_count == total:
		rows.append({"note": "Every achievement earned. Hallowvale has nothing left to teach you."})
	for tier in ACHIEVEMENT_TIERS.size():
		var in_tier: Array = []
		for a in ACHIEVEMENTS:
			if a["tier"] == tier:
				in_tier.append(a)
		var tier_done := 0
		for a in in_tier:
			if achievements_done.has(a["id"]):
				tier_done += 1
		rows.append({"section": "%s   %d/%d" % [ACHIEVEMENT_TIERS[tier], tier_done, in_tier.size()]})
		for a in in_tier:
			rows.append(_achievement_row(a))
	return rows


func _achievement_row(a: Dictionary) -> Dictionary:
	var done: bool = achievements_done.has(a["id"])
	var shown := mini(_stat_value(a["stat"]), a["goal"])
	return {
		"name": "%s%s" % [a["title"], "   (done)" if done else ""],
		"value": "%d/%d" % [shown, a["goal"]],
		"progress": float(shown) / float(a["goal"]),
		"note": "%s  Reward: %s" % [a["text"], _reward_text(a["reward"])],
	}

# --- Pack and bags -----------------------------------------------------------

func _pack_used() -> int:
	return int(inventory["crops"]) + int(inventory["fish"]) + int(inventory["meals"])


func _pack_capacity() -> int:
	var cap := BAG_BASE
	for i in bag_tier:
		cap += int(BAG_TIERS[i]["slots"])
	return cap


func _pack_free() -> int:
	return _pack_capacity() - _pack_used()


func _can_upgrade_bag() -> bool:
	return bag_tier < BAG_TIERS.size() and _can_afford(BAG_TIERS[bag_tier])


func _upgrade_bag() -> void:
	if not _can_upgrade_bag():
		_show_message("You can't afford the next bag yet. Needs %s." % _price_text(BAG_TIERS[bag_tier]))
		return
	var tier: Dictionary = BAG_TIERS[bag_tier]
	_pay(tier)
	bag_tier += 1
	_show_message("You get a %s. Your pack now holds %d items." % [tier["name"], _pack_capacity()])


# --- Money and costs ---------------------------------------------------------

func _can_afford(cost: Dictionary) -> bool:
	return money >= int(cost.get("coins", 0)) \
		and int(materials["wood"]) >= int(cost.get("wood", 0)) \
		and int(materials["fiber"]) >= int(cost.get("fiber", 0)) \
		and _level("Carpentry") >= int(cost.get("level", 1))


func _pay(cost: Dictionary) -> void:
	money -= int(cost.get("coins", 0))
	materials["wood"] -= int(cost.get("wood", 0))
	materials["fiber"] -= int(cost.get("fiber", 0))


func _price_text(cost: Dictionary) -> String:
	var parts: Array = []
	if int(cost.get("coins", 0)) > 0:
		parts.append("%d coins" % int(cost["coins"]))
	if int(cost.get("wood", 0)) > 0:
		parts.append("%d wood" % int(cost["wood"]))
	if int(cost.get("fiber", 0)) > 0:
		parts.append("%d fiber" % int(cost["fiber"]))
	parts.append("Carpentry %d" % int(cost.get("level", 1)))
	return ", ".join(parts)


# --- Stall -------------------------------------------------------------------

func _open_stall() -> void:
	if current_hour >= STALL_CLOSE_HOUR:
		_show_message("The stall is shut for the night. It opens at 06:00.")
		return
	_toggle_tab("Trade")


func _sell(kind: String) -> void:
	var count := int(inventory[kind])
	if count <= 0:
		_show_message("You have nothing to sell.")
		return
	var price := SELL_CROP
	if kind == "fish":
		price = SELL_FISH
	elif kind == "meals":
		price = SELL_MEAL
	inventory[kind] = 0
	money += count * price
	stats["sold"] += count
	_show_message("Sold %d for %d coins." % [count, count * price])


func _buy_seeds(kind: String) -> void:
	if kind == "pumpkin":
		if _level("Farming") < PUMPKIN_LEVEL:
			_show_message("Pumpkin seeds need Farming level %d." % PUMPKIN_LEVEL)
			return
		var pumpkin_total := SEED_PUMPKIN_PRICE * 3
		if money < pumpkin_total:
			_show_message("Three pumpkin seeds cost %d coins." % pumpkin_total)
			return
		money -= pumpkin_total
		inventory["pumpkin_seeds"] += 3
		_show_message("You buy 3 pumpkin seeds for %d coins." % pumpkin_total)
		return
	var turnip_total := SEED_TURNIP_PRICE * 5
	if money < turnip_total:
		_show_message("Five turnip seeds cost %d coins." % turnip_total)
		return
	money -= turnip_total
	inventory["seeds"] += 5
	_show_message("You buy 5 turnip seeds for %d coins." % turnip_total)


# --- Storage -----------------------------------------------------------------

func _build_storage(which: String) -> void:
	var cost: Dictionary = CELLAR_COST if which == "cellar" else COOLER_COST
	if not _can_afford(cost):
		_show_message("You can't build that yet. Needs %s." % _price_text(cost))
		return
	_pay(cost)
	if which == "cellar":
		cellar_built = true
		_show_message("The root cellar is dug. It holds %d crops." % CELLAR_CAP)
	else:
		cooler_built = true
		_show_message("The cooler is built. It keeps %d fish fresh." % COOLER_CAP)
	_build_interior()
	queue_redraw()


func _store_crops() -> void:
	var amount := mini(int(inventory["crops"]), CELLAR_CAP - cellar_stock)
	if amount <= 0:
		_show_message("Nothing to store, or the cellar is full.")
		return
	inventory["crops"] -= amount
	cellar_stock += amount
	_show_message("You store %d crops in the cellar." % amount)


func _take_crops() -> void:
	var amount := mini(cellar_stock, _pack_free())
	if amount <= 0:
		_show_message("Your pack is full, or the cellar is empty.")
		return
	cellar_stock -= amount
	inventory["crops"] += amount
	_show_message("You take %d crops from the cellar." % amount)


func _store_fish() -> void:
	var amount := mini(int(inventory["fish"]), COOLER_CAP - cooler_stock)
	if amount <= 0:
		_show_message("Nothing to store, or the cooler is full.")
		return
	inventory["fish"] -= amount
	cooler_stock += amount
	_show_message("You store %d fish in the cooler." % amount)


func _take_fish() -> void:
	var amount := mini(cooler_stock, _pack_free())
	if amount <= 0:
		_show_message("Your pack is full, or the cooler is empty.")
		return
	cooler_stock -= amount
	inventory["fish"] += amount
	_show_message("You take %d fish from the cooler." % amount)


# --- Trade, cellar, and cooler panels ------------------------------------------

func _trade_rows() -> Array:
	var turnip_pack := SEED_TURNIP_PRICE * 5
	var pumpkin_pack := SEED_PUMPKIN_PRICE * 3
	return [
		{"section": "Purse"},
		{"name": "Coins", "value": str(money)},
		{"section": "Sell from your pack"},
		{
			"name": "Crops (%d each)" % SELL_CROP,
			"value": "%d held" % int(inventory["crops"]),
			"button": "Sell all",
			"action": "sell_crops",
			"enabled": int(inventory["crops"]) > 0,
		},
		{
			"name": "Fish (%d each)" % SELL_FISH,
			"value": "%d held" % int(inventory["fish"]),
			"button": "Sell all",
			"action": "sell_fish",
			"enabled": int(inventory["fish"]) > 0,
		},
		{
			"name": "Meals (%d each)" % SELL_MEAL,
			"value": "%d held" % int(inventory["meals"]),
			"button": "Sell all",
			"action": "sell_meals",
			"enabled": int(inventory["meals"]) > 0,
		},
		{"section": "Buy seeds"},
		{
			"name": "Turnip seeds (%d each)" % SEED_TURNIP_PRICE,
			"value": "5 for %d coins" % turnip_pack,
			"button": "Buy 5",
			"action": "buy_turnip",
			"enabled": money >= turnip_pack,
		},
		{
			"name": "Pumpkin seeds (%d each)" % SEED_PUMPKIN_PRICE,
			"value": "3 for %d coins, Farming %d" % [pumpkin_pack, PUMPKIN_LEVEL],
			"button": "Buy 3",
			"action": "buy_pumpkin",
			"enabled": _level("Farming") >= PUMPKIN_LEVEL and money >= pumpkin_pack,
		},
		{"note": "The stall is open from 06:00 to 18:00. It only buys what you carry, so take crops or fish out of storage first."},
	]


func _cellar_rows() -> Array:
	return [
		{"section": "Root cellar"},
		{
			"name": "Crops stored",
			"value": "%d/%d" % [cellar_stock, CELLAR_CAP],
			"progress": float(cellar_stock) / float(CELLAR_CAP),
		},
		{
			"name": "Store crops from your pack",
			"value": "%d in pack" % int(inventory["crops"]),
			"button": "Store",
			"action": "store_crops",
			"enabled": int(inventory["crops"]) > 0 and cellar_stock < CELLAR_CAP,
		},
		{
			"name": "Take crops into your pack",
			"value": "%d free slots" % _pack_free(),
			"button": "Take",
			"action": "take_crops",
			"enabled": cellar_stock > 0 and _pack_free() > 0,
		},
		{"note": "Crops keep here. Nothing spoils in the cellar."},
	]


func _cooler_rows() -> Array:
	return [
		{"section": "Cooler"},
		{
			"name": "Fish stored",
			"value": "%d/%d" % [cooler_stock, COOLER_CAP],
			"progress": float(cooler_stock) / float(COOLER_CAP),
		},
		{
			"name": "Store fish from your pack",
			"value": "%d in pack" % int(inventory["fish"]),
			"button": "Store",
			"action": "store_fish",
			"enabled": int(inventory["fish"]) > 0 and cooler_stock < COOLER_CAP,
		},
		{
			"name": "Take fish into your pack",
			"value": "%d free slots" % _pack_free(),
			"button": "Take",
			"action": "take_fish",
			"enabled": cooler_stock > 0 and _pack_free() > 0,
		},
		{"note": "Fish in your pack spoil overnight. Fish kept here do not."},
	]


# --- Slot grids for the pack, seed pouch, and equipment ---------------------

func _pack_cells() -> Array:
	var cells: Array = []
	for i in int(inventory["crops"]):
		cells.append({"color": "8fd16b", "label": "Crop", "tip": "Harvested crop"})
	for i in int(inventory["fish"]):
		cells.append({"color": "6fb8d9", "label": "Fish", "tip": "Fish. Spoils overnight unless stored in the cooler."})
	for i in int(inventory["meals"]):
		cells.append({"color": "e0a050", "label": "Meal", "tip": "Cooked meal. Eat it for sanity."})
	while cells.size() < _pack_capacity():
		cells.append({"empty": true, "tip": "Empty slot"})
	return cells


func _seed_cells() -> Array:
	return [
		{"color": "a8d46f", "label": "Turnip", "count": str(inventory["seeds"]), "tip": "Turnip seeds. Kept in the seed pouch."},
		{"color": "d98a35", "label": "Pumpkin", "count": str(inventory["pumpkin_seeds"]), "tip": "Pumpkin seeds. Farming %d to plant." % PUMPKIN_LEVEL},
	]


# Nine slots in three rows: back, head, neck / left hand, chest, right hand /
# wrist, legs, feet. The bag sits in Back, the lantern in the left hand, and
# the hoe in the right hand. The rest are locked until they have items.
func _gear_cells() -> Array:
	var bag_name := "Pack" if bag_tier == 0 else str(BAG_TIERS[bag_tier - 1]["name"])
	var lantern: Dictionary = {"empty": true, "label": "Left hand", "tip": "Left hand: no lantern built yet"}
	if lantern_tier > 0:
		var current: Dictionary = LANTERN_TIERS[lantern_tier - 1]
		lantern = {"color": "ffd38a", "label": current["name"], "tip": "Left hand: %s, ring %.1f tiles" % [current["name"], current["radius"]]}
	return [
		{"color": "7a5a3a", "label": bag_name, "tip": "Back: %s, %d pack slots" % [bag_name, _pack_capacity()]},
		{"locked": true, "label": "Head", "tip": "Not available yet"},
		{"locked": true, "label": "Neck", "tip": "Not available yet"},
		lantern,
		{"locked": true, "label": "Chest", "tip": "Not available yet"},
		{"color": "8a8f96", "label": "Hoe", "tip": "Right hand: hoe, equipped"},
		{"locked": true, "label": "Wrist", "tip": "Not available yet"},
		{"locked": true, "label": "Legs", "tip": "Not available yet"},
		{"locked": true, "label": "Feet", "tip": "Not available yet"},
	]


# --- Repairs and mending ----------------------------------------------------

func _can_repair() -> bool:
	if house_stage >= MAX_STAGE:
		return false
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	return materials["wood"] >= cost["wood"] \
		and materials["fiber"] >= cost["fiber"] \
		and _level("Carpentry") >= cost["level"]


func _repair_house() -> void:
	if not _can_repair():
		_show_message("Not enough wood and fiber, or Carpentry is too low for this repair.")
		return
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	materials["wood"] -= cost["wood"]
	materials["fiber"] -= cost["fiber"]
	house_stage += 1
	_grant_xp("Carpentry", XP_REPAIR)
	_build_interior()
	_show_message("Repaired. The farmhouse is now %s. +%d Carpentry XP" % [STAGE_NAMES[house_stage], XP_REPAIR])
	queue_redraw()


func _mends_left() -> int:
	var used := mends_today if mend_day == day else 0
	return MEND_DAILY_LIMIT - used


func _can_mend() -> bool:
	return _mends_left() > 0 and materials["wood"] >= MEND_WOOD and materials["fiber"] >= MEND_FIBER


# Mending boards is repeatable Carpentry training, capped per day so the house
# can't be finished in one day.
func _mend_house() -> void:
	if _mends_left() <= 0:
		_show_message("You've mended all you can today. Come back tomorrow.")
		return
	if not _can_mend():
		_show_message("You need %d wood and %d fiber to mend a board." % [MEND_WOOD, MEND_FIBER])
		return
	if mend_day != day:
		mend_day = day
		mends_today = 0
	mends_today += 1
	materials["wood"] -= MEND_WOOD
	materials["fiber"] -= MEND_FIBER
	stats["mended"] += 1
	_grant_xp("Carpentry", XP_MEND)
	_show_message("You mend a board. +%d Carpentry XP" % XP_MEND)


# Sleeping only happens at the bed, from 18:00 until 03:00.
func _try_sleep() -> void:
	if current_hour < SLEEP_HOUR:
		_show_message("You aren't tired yet. The bed will be there after 18:00.")
		return
	stats["slept"] += 1
	_change_sanity(SLEEP_SANITY)
	# Sleeping keeps you in bed, so the house is not left.
	_end_day("You sleep through the night.", false)


# Missing the bed by 03:00 ends the day, and the sanity limit drops for good.
func _collapse() -> void:
	sanity_penalty += COLLAPSE_SANITY_PENALTY
	stats["collapses"] += 1
	sanity = minf(sanity, _sanity_max())
	_end_day("You collapse before reaching your bed. Something in your mind gives way.")


func _can_tidy() -> bool:
	return house_stage >= 2 and tidied_day != day


func _tidy_house() -> void:
	if not _can_tidy():
		_show_message("The house is already tidy for today.")
		return
	tidied_day = day
	stats["tidied"] += 1
	_grant_xp("Cleaning", XP_TIDY)
	var bonus := TIDY_CLEANING_BONUS if _level("Cleaning") >= 2 else 0
	_change_sanity(TIDY_SANITY + bonus)
	_show_message("You tidy the house. The air feels a little lighter. +%d Cleaning XP" % XP_TIDY)


# Cleansing offers crops to the house to lift the permanent sanity penalty.
func _can_cleanse() -> bool:
	return sanity_penalty > 0 and cleanse_day != day \
		and _level("Cleaning") >= CLEANSE_LEVEL \
		and inventory["crops"] >= CLEANSE_CROPS


func _cleanse_house() -> void:
	if not _can_cleanse():
		_show_message("Cleansing needs Cleaning %d, %d crops, and one try a day." % [CLEANSE_LEVEL, CLEANSE_CROPS])
		return
	inventory["crops"] -= CLEANSE_CROPS
	cleanse_day = day
	sanity_penalty = maxi(0, sanity_penalty - CLEANSE_RELIEF)
	sanity = minf(sanity, _sanity_max())
	stats["cleansed"] += 1
	_show_message("You burn the offering and open the windows. Your limit recovers by %d." % CLEANSE_RELIEF)


# --- Lanterns ---------------------------------------------------------------

func _can_advance_lantern() -> bool:
	if lantern_tier >= LANTERN_TIERS.size():
		return false
	var t: Dictionary = LANTERN_TIERS[lantern_tier]
	return materials["wood"] >= t["wood"] \
		and materials["fiber"] >= t["fiber"] \
		and materials["resin"] >= t["resin"] \
		and _level("Bushcrafting") >= t["level"]


func _advance_lantern() -> void:
	if not _can_advance_lantern():
		_show_message("You need %s for the next lantern." % _cost_text(LANTERN_TIERS[lantern_tier]))
		return
	var t: Dictionary = LANTERN_TIERS[lantern_tier]
	materials["wood"] -= t["wood"]
	materials["fiber"] -= t["fiber"]
	materials["resin"] -= t["resin"]
	lantern_tier += 1
	_apply_lantern_radius()
	_show_message("You build a %s. Its light reaches %.1f tiles." % [t["name"], t["radius"]])


func _apply_lantern_radius() -> void:
	if lantern_tier == 0:
		return
	var radius: float = LANTERN_TIERS[lantern_tier - 1]["radius"]
	lantern_light.texture_scale = radius * PX / 128.0


func _update_lantern(darkness: float) -> void:
	lantern_light.enabled = lantern_tier > 0 and darkness > 0.05
	if lantern_tier >= LANTERN_FLICKER_TIER:
		var t := Time.get_ticks_msec() / 1000.0
		lantern_light.energy = 0.9 + 0.08 * sin(t * 9.0) + randf_range(-0.03, 0.03)
	else:
		lantern_light.energy = 1.0


func _night_relief() -> float:
	# The restored house dims the night overall. The lantern lights a ring instead.
	var relief := 0.0
	if house_stage >= 3:
		relief += HOUSE_RELIEF
	return minf(relief, 0.9)


# --- Quests ------------------------------------------------------------------

func _stat_value(stat: String) -> int:
	match stat:
		"house_stage":
			return house_stage
		"lantern_tier":
			return lantern_tier
		"story":
			return quests_done.size()
	if stat.begins_with("level_"):
		return _level(stat.trim_prefix("level_"))
	return int(stats.get(stat, 0))


# Story chapters run in order, so only the first unfinished one can complete.
func _check_story() -> void:
	for q in STORY:
		if quests_done.has(q["id"]):
			continue
		if _stat_value(q["stat"]) < q["goal"]:
			break
		quests_done[q["id"]] = true
		_grant_reward(q["reward"])
		_show_message("Chapter complete: %s. Reward: %s" % [q["title"], _reward_text(q["reward"])])


func _check_achievements() -> void:
	for a in ACHIEVEMENTS:
		if achievements_done.has(a["id"]):
			continue
		if _stat_value(a["stat"]) >= a["goal"]:
			achievements_done[a["id"]] = true
			_grant_reward(a["reward"])
			_show_message("Achievement: %s. Reward: %s" % [a["title"], _reward_text(a["reward"])])


func _grant_reward(reward: Dictionary) -> void:
	if reward.has("seeds"):
		inventory["seeds"] += reward["seeds"]
	if reward.has("pumpkin_seeds"):
		inventory["pumpkin_seeds"] += reward["pumpkin_seeds"]
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			materials[mat] += reward[mat]
	if reward.has("coins"):
		money += reward["coins"]
	if reward.has("xp"):
		_grant_xp(reward["skill"], reward["xp"])


func _reward_text(reward: Dictionary) -> String:
	var parts: Array = []
	if reward.has("seeds"):
		parts.append("%d turnip seeds" % reward["seeds"])
	if reward.has("pumpkin_seeds"):
		parts.append("%d pumpkin seeds" % reward["pumpkin_seeds"])
	for mat in ["wood", "fiber", "resin"]:
		if reward.has(mat):
			parts.append("%d %s" % [reward[mat], mat])
	if reward.has("coins"):
		parts.append("%d coins" % reward["coins"])
	if reward.has("xp"):
		parts.append("%d %s XP" % [reward["xp"], reward["skill"]])
	return ", ".join(parts)


# --- Sanity and night events ------------------------------------------------

func _sanity_max() -> float:
	return SANITY_MAX - sanity_penalty


func _change_sanity(amount: float) -> void:
	sanity = clampf(sanity + amount, 0.0, _sanity_max())


func _update_sanity(darkness: float, delta: float) -> void:
	var rate := 0.02                 # slow recovery outdoors in daylight
	if inside:
		rate = 0.1 + (0.05 if house_stage >= 1 else 0.0)   # the house is shelter
	elif darkness > 0.5:
		rate = -0.05                 # the dark wears on you
	_change_sanity(rate * delta)


func _low_sanity_boost() -> float:
	# Low sanity makes everything darker, a visible warning.
	return maxf(0.0, (LOW_SANITY - sanity) / LOW_SANITY) * 0.25


func _trigger_night_event() -> void:
	event_fired_day = day
	stats["events"] += 1
	var ev: Dictionary = NIGHT_EVENTS[(day * 3) % NIGHT_EVENTS.size()]
	match ev["shadow"]:
		"field":
			tonight_shadow = shadow_tile
		"house":
			tonight_shadow = _world_tile(HOUSE_IX + HOUSE_W, HOUSE_IY + 1)
		_:
			tonight_shadow = Vector2i(-1, -1)
	_change_sanity(ev["sanity"])
	_show_message(ev["message"])
	queue_redraw()


# Ends the day and saves. Both sleeping and collapsing come through here.
func _end_day(base: String, leave_house: bool = true) -> void:
	if inside and leave_house:
		_leave_house()
	# Fish left in the pack spoil overnight. The cooler keeps them.
	var spoiled := int(inventory["fish"])
	inventory["fish"] = 0
	stats["spoiled"] += spoiled
	var spoil_note := (" %d fish spoiled in your pack overnight." % spoiled) if spoiled > 0 else ""
	for pos in crops.keys():
		crops[pos]["stage"] = min(crops[pos]["stage"] + 1, MAX_STAGE)
	day += 1
	clock = 0.0
	tonight_shadow = Vector2i(-1, -1)
	_respawn_brush()
	_update_shadow_tile()
	_show_message("%s Your crops grew overnight.%s" % [base, spoil_note])
	_save_game()
	queue_redraw()


func _update_shadow_tile() -> void:
	# The field shadow creeps closer to the farm each night.
	var x := BORDER_X + INNER_W - 2 - (day - 1) * 2
	x = max(x, BORDER_X + 14)
	shadow_tile = Vector2i(x, BORDER_Y + INNER_H / 2 - 4)


# --- Walking into and out of the house --------------------------------------

func _check_doors() -> void:
	var kind := _kind_at(_player_tile())
	if not inside and kind == Tile.DOOR:
		_enter_house()
	elif inside and kind == Tile.EXIT:
		_leave_house()


func _enter_house() -> void:
	inside = true
	player.position = _tile_center(INT_ORIGIN.x + 6, INT_ORIGIN.y + 6)
	_set_bounds()
	_show_message("You step inside. The air is cold and smells of old wood.")


func _leave_house() -> void:
	inside = false
	player.position = _tile_center(BORDER_X + HOUSE_DOOR_IX, BORDER_Y + HOUSE_DOOR_IY + 1)
	_set_bounds()


func _set_bounds() -> void:
	if inside:
		player.min_pos = _tile_center(INT_ORIGIN.x + 1, INT_ORIGIN.y + 1)
		# The bottom row holds the exit mat, so the player's clamp must reach it.
		player.max_pos = _tile_center(INT_ORIGIN.x + INT_W - 2, INT_ORIGIN.y + INT_H - 1)
		camera.limit_left = INT_ORIGIN.x * PX
		camera.limit_top = INT_ORIGIN.y * PX
		camera.limit_right = (INT_ORIGIN.x + INT_W) * PX
		camera.limit_bottom = (INT_ORIGIN.y + INT_H) * PX
	else:
		player.min_pos = _tile_center(BORDER_X, BORDER_Y)
		player.max_pos = _tile_center(BORDER_X + INNER_W - 1, BORDER_Y + INNER_H - 1)
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = MAP_W * PX
		camera.limit_bottom = MAP_H * PX


# --- Save and load ----------------------------------------------------------

func _save_game() -> void:
	var data := {
		"day": day,
		"skill_xp": skill_xp,
		"inventory": inventory,
		"materials": materials,
		"stats": stats,
		"quests_done": quests_done,
		"money": money,
		"bag_tier": bag_tier,
		"cellar_built": cellar_built,
		"cooler_built": cooler_built,
		"cellar_stock": cellar_stock,
		"cooler_stock": cooler_stock,
		"achievements_done": achievements_done,
		"story_version": 2,
		"selected_seed": selected_seed,
		"lantern_tier": lantern_tier,
		"house_stage": house_stage,
		"tidied_day": tidied_day,
		"mend_day": mend_day,
		"mends_today": mends_today,
		"cleanse_day": cleanse_day,
		"event_fired_day": event_fired_day,
		"sanity": sanity,
		"sanity_penalty": sanity_penalty,
		"player_pos": [player.position.x, player.position.y],
		"inside": inside,
		"open_tab": open_tab,
		"crops": _crops_to_array(),
		"brush": _brush_to_array(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed

	day = int(data.get("day", 1))
	_merge_ints(skill_xp, data.get("skill_xp"))
	_merge_ints(inventory, data.get("inventory"))
	_merge_ints(materials, data.get("materials"))
	_merge_ints(stats, data.get("stats"))
	# Saves before version 2 used the old quest list, so their progress is reset.
	# Stat-based achievements re-check from saved stats on the next frame.
	var story_v := int(data.get("story_version", 1))
	quests_done = data.get("quests_done", {}) if story_v >= 2 else {}
	achievements_done = data.get("achievements_done", {}) if story_v >= 2 else {}
	selected_seed = str(data.get("selected_seed", "turnip"))
	lantern_tier = int(data.get("lantern_tier", 0))
	house_stage = int(data.get("house_stage", 0))
	tidied_day = int(data.get("tidied_day", 0))
	mend_day = int(data.get("mend_day", 0))
	mends_today = int(data.get("mends_today", 0))
	cleanse_day = int(data.get("cleanse_day", 0))
	money = int(data.get("money", 0))
	bag_tier = int(data.get("bag_tier", 0))
	cellar_built = bool(data.get("cellar_built", false))
	cooler_built = bool(data.get("cooler_built", false))
	cellar_stock = int(data.get("cellar_stock", 0))
	cooler_stock = int(data.get("cooler_stock", 0))
	event_fired_day = int(data.get("event_fired_day", 0))
	sanity_penalty = int(data.get("sanity_penalty", 0))
	sanity = float(data.get("sanity", SANITY_MAX))
	saved_inside = bool(data.get("inside", false))
	saved_panel = str(data.get("open_tab", ""))
	var pos: Variant = data.get("player_pos", null)
	if typeof(pos) == TYPE_ARRAY and pos.size() == 2:
		saved_pos = Vector2(float(pos[0]), float(pos[1]))
		has_saved_pos = true

	# Rebuild the interior so the saved house stage shows the right rooms.
	# Crops and brush are restored here, after the map exists.
	crops.clear()
	for c in data.get("crops", []):
		var kind := str(c.get("kind", "turnip"))
		crops[Vector2i(int(c["x"]), int(c["y"]))] = {"stage": int(c["stage"]), "kind": kind}
	brush.clear()
	for b in data.get("brush", []):
		brush[Vector2i(int(b[0]), int(b[1]))] = true
	return true


func _merge_ints(target: Dictionary, saved: Variant) -> void:
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for key in target.keys():
		if saved.has(key):
			target[key] = int(saved[key])


func _crops_to_array() -> Array:
	var arr: Array = []
	for pos in crops:
		var crop: Dictionary = crops[pos]
		arr.append({"x": pos.x, "y": pos.y, "stage": crop["stage"], "kind": crop["kind"]})
	return arr


func _brush_to_array() -> Array:
	var arr: Array = []
	for pos in brush:
		arr.append([pos.x, pos.y])
	return arr


# --- Helpers -----------------------------------------------------------------

func _level(skill: String) -> int:
	return 1 + int(skill_xp[skill]) / 100


func _grant_xp(skill: String, amount: int) -> void:
	skill_xp[skill] += amount


func _cost_text(cost: Dictionary) -> String:
	var parts := ["%d wood" % cost["wood"], "%d fiber" % cost["fiber"]]
	if cost.get("resin", 0) > 0:
		parts.append("%d resin" % cost["resin"])
	parts.append("Bushcrafting %d" % cost["level"])
	return ", ".join(parts)


func _show_message(text: String) -> void:
	message_label.text = text
	message_timer = MESSAGE_SECONDS + text.length() / 30.0


func _tile_in_front() -> Vector2i:
	var p: Vector2 = player.position + player.facing * PX * 0.6
	return Vector2i(floori(p.x / PX), floori(p.y / PX))


func _player_tile() -> Vector2i:
	return Vector2i(floori(player.position.x / PX), floori(player.position.y / PX))


func _in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < MAP_W and tile.y < MAP_H


func _in_interior(tile: Vector2i) -> bool:
	return tile.x >= INT_ORIGIN.x and tile.x < INT_ORIGIN.x + INT_W \
		and tile.y >= INT_ORIGIN.y and tile.y < INT_ORIGIN.y + INT_H


# The tile kind at a world tile: the interior if it's inside the house, else the farm.
func _kind_at(tile: Vector2i) -> int:
	if _in_interior(tile):
		return interior[tile.y - INT_ORIGIN.y][tile.x - INT_ORIGIN.x]
	if not _in_bounds(tile):
		return Tile.TREE
	return map[tile.y][tile.x]


func _is_blocked_world(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / PX), floori(p.y / PX))
	if BLOCKING.has(_kind_at(t)):
		return true
	return not inside and brush.has(t)


func _world_tile(ix: int, iy: int) -> Vector2i:
	return Vector2i(ix + BORDER_X, iy + BORDER_Y)


func _tile_center(wx: int, wy: int) -> Vector2:
	return Vector2(wx * PX + PX * 0.5, wy * PX + PX * 0.5)


func _tile_rect(t: Vector2i) -> Rect2:
	return Rect2(t.x * PX, t.y * PX, PX, PX)
