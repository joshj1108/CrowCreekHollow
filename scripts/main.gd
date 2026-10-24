class_name MainGame
extends Node2D

## The farm and farmhouse: two plots, turnips and pumpkins, bushcrafting,
## fishing, skills, inventory, gear, lantern tiers, sanity and its cure, quests,
## night events, the walk-in house, the minimap, the action bar, the day clock,
## and save/load. The day runs 06:00 to 03:00. Sleep in bed to save and end the day.
## Placeholder art is drawn in code; no external assets yet.

const WeatherScript := preload("res://scripts/weather.gd")  # loaded by path, so it works before the class cache is rebuilt
const FarmArt := preload("res://scripts/farm_art.gd")  # the farm's drawing: houses, trees, rocks, and the pond
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
# The third plot opens at Farming 4 once the house is Patched. It sits between the paths.
const PLOT_THREE := Rect2i(14, 14, 5, 6)
const PLOT_THREE_LEVEL := 4

# The walk-in interior sits below the farm, out of view of it.
const INT_W := 14
const INT_H := 9
const INT_ORIGIN := Vector2i(0, MAP_H + 4)
const FIREPLACE_IX := Vector2i(12, 5)            # the hearth, in the hall's north-east corner
const TABLE_TILES := [Vector2i(2, 6), Vector2i(3, 6)]
const CHAIR_TILES := [Vector2i(2, 5), Vector2i(3, 5), Vector2i(2, 7), Vector2i(3, 7)]
const RUG_RECT := Rect2i(5, 5, 6, 3)            # the hall rug, laid from the Boarded stage
const INT_WALLS := [Color("221c18"), Color("4e4236"), Color("7a6a54"), Color("9a8a6a")]
const INT_FLOORS := [Color("3e2e22"), Color("5a4430"), Color("6e5438"), Color("7f6244")]
const QUILTS := [Color("6a5a4a"), Color("3e5a80"), Color("3f6b4a"), Color("8a2e3a")]

# Brush piles for bushcrafting, in inner coordinates. They grow back once a week, as a clean-up job.
# Each one gives sticks and fiber. Brush and trees come back on a weekly cycle; rocks take a month.
const BRUSH_SPOTS := [
	Vector2i(3, 3), Vector2i(16, 2), Vector2i(34, 11), Vector2i(24, 20),
	Vector2i(6, 21), Vector2i(33, 8), Vector2i(14, 21),
]
const BRUSH_REGROW_DAYS := 7
const ROCK_REGROW_DAYS := 30
# Extra piles that appear once Bushcrafting reaches level 3.
const THICKET_SPOTS := [Vector2i(10, 21), Vector2i(23, 14), Vector2i(38, 16)]
# The porch: four tiles of boards in front of the door, starting one row below the house.
const PORCH_RECT := Rect2i(26, 8, 4, 2)
# The yard paths run from the porch and the stall down to the road. The road itself is the middle row.
const YARD_PATH := [Vector2i(28, 10), Vector2i(28, 11), Vector2i(22, 10), Vector2i(22, 11), Vector2i(12, 11)]
# The pond is an uneven lake in the south-east, centred here in inner tiles.
const LAKE_CENTRE := Vector2(33.0, 19.0)
const LAKE_RADIUS := Vector2(4.6, 3.6)
const THICKET_LEVEL := 3
# Trees on the property. Felling one with a hatchet gives wood. They grow back with the brush, once a week.
# The first five are the grove in the north-west corner. The rest frame the house, the yard, and the pond.
const GROVE_SPOTS := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1),
	Vector2i(9, 1), Vector2i(20, 1), Vector2i(38, 4), Vector2i(36, 9), Vector2i(2, 8),
	Vector2i(2, 17), Vector2i(30, 15), Vector2i(21, 21), Vector2i(17, 22),
]
# Weeping willows lean over the back fence and the pond. The bare tree at the top of the field is dead.
const WILLOW_TREES := [Vector2i(2, 17), Vector2i(30, 15)]
const DEAD_TREES := [Vector2i(20, 1)]
# The great tree: a 3 by 3 block of the field that can't be felled or used. Crows roost in its crown from dusk.
const BIG_TREE_INNER := Vector2i(21, 4)
const BIG_TREE_MESSAGE := "Too old and too thick to fell. Something moves in its branches."
const ROOST_HOUR := 20.0      # from this hour the crows come home to the great tree
const ROOST_SIZE := 4         # perches in its crown
const ROOST_ALT := 3.4        # how high the crown perches sit, in tiles
const XP_FELL := 20
# Rocks on the farm. Breaking one gives stone. A pick gives more, and from Mining 2 a small chance of copper ore.
# Some sit inside the plots: a rock must be broken before that soil can be planted.
const ROCK_SPOTS := [
	Vector2i(5, 5), Vector2i(10, 8), Vector2i(6, 16), Vector2i(10, 18), Vector2i(15, 15),
	Vector2i(18, 6), Vector2i(24, 15), Vector2i(35, 13),
]
const XP_MINE := 12
const ORE_CHANCE := 0.15
const ORE_MINING_LEVEL := 2
# A campsite is set up in the wider land from wood and fiber. It is safe from foes
# within a few tiles, and you can rest there from 18:00 like a bed.
const CAMP_COST := {"wood": 4, "fiber": 3}
const CAMP_LEVEL := 2
const CAMP_SAFE_RADIUS := 3.0
const NO_CAMP := Vector2i(-1, -1)
# Quarry rocks in Ashford, in village tiles. They yield copper ore from Mining 3,
# and iron ore from Mining 5 with a copper pick or better.
const ASHFORD_QUARRY := [Vector2i(26, 16), Vector2i(30, 18), Vector2i(34, 15), Vector2i(9, 17)]
# The world: one generated land, 768 by 912 tiles, the full size of the original map.
const WORLD_W := 768
const WORLD_H := 912
const WORLD_SEED := 20031
const ROAD_Y := 450
const PORTAL_TILE := Vector2i(352, 450)   # the stone that takes you back home
const PORTAL_ARRIVE := Vector2i(354, 450) # where you step out of the farm's portal
# false keeps play on the homestead: the east portal is off, the wider land and its
# towns are unreachable, and the Guardian of Lowmere quests are hidden.
const WORLD_ENABLED := false
# The mining cave, entered from the homestead's west edge. Its ore is copper and iron.
const CAVE_W := 40
const CAVE_H := 24
const CAVE_SEED := 61019                 # base seed; each day's cave is CAVE_SEED + day
const CAVE_START := Vector2i(3, 12)      # where you step in, just inside the exit
const CAVE_EXIT_TILE := Vector2i(2, 12)  # the mat that takes you back out
const CAVE_CREATURES := ["bat", "bat", "bat", "lizard", "lizard", "snake", "snake"]
const CAVE_MIN_CREATURE_DEPTH := 8       # creatures start at least this far from the entrance
const CAVE_IRON_DEPTH := 12              # iron ore only this far in
const LOWMERE_ORIGIN := Vector2i(380, 440)
const ASHFORD_ORIGIN := Vector2i(470, 440)
# Tool tiers. A hatchet fells trees. Hardwood needs a copper hatchet or better.
const TOOL_TIERS := {
	"hatchet": [
		{"name": "Crude hatchet", "cost": {"sticks": 2, "fiber": 2}, "skill": "Bushcrafting", "level": 1},
		{"name": "Stone hatchet", "cost": {"wood": 2, "stone": 2}, "skill": "Forestry", "level": 2},
		{"name": "Copper hatchet", "cost": {"wood": 1, "copper_bar": 2}, "skill": "Smithing", "level": 2},
		{"name": "Iron hatchet", "cost": {"wood": 1, "iron_bar": 2}, "skill": "Smithing", "level": 5},
	],
	"pick": [
		{"name": "Stone pick", "cost": {"wood": 2, "stone": 3}, "skill": "Mining", "level": 1},
		{"name": "Copper pick", "cost": {"wood": 1, "copper_bar": 2}, "skill": "Smithing", "level": 2},
		{"name": "Iron pick", "cost": {"wood": 1, "iron_bar": 2}, "skill": "Smithing", "level": 5},
	],
	# A rod adds to the chance of each catch. The bonus is added up across the tiers you own.
	"rod": [
		{"name": "Willow rod", "cost": {"sticks": 2, "fiber": 2}, "skill": "Fishing", "level": 2, "bonus": 0.10},
		{"name": "Hardwood rod", "cost": {"hardwood": 2, "fiber": 2, "resin": 1}, "skill": "Fishing", "level": 5, "bonus": 0.10},
	],
}
# A bandage is made from fiber and resin, and heals when used from the pack.
const BANDAGE := {"name": "Bandage", "heal": 25, "fiber": 2, "resin": 1, "level": 2, "xp": 8}

# Time runs from 06:00 to 03:00 the next morning (hours 6 to 27).
const DAY_LENGTH := 240.0   # real seconds for a full day

# The calendar follows the Pacific Northwest, and the first day is October 1st. Months have their usual lengths.
const MONTH_NAMES := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const MONTH_DAYS := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const START_MONTH := 9   # October, as an index into MONTH_NAMES
const START_DAY_OF_MONTH := 1
# Weather is rolled each morning. Summer is mostly sunny, winter is wet, and snow is rare.
const WEATHER_WEIGHTS := {
	"Winter": {"sunny": 3, "cloudy": 10, "drizzle": 14, "rain": 12, "downpour": 6, "fog": 5, "snow": 2},
	"Spring": {"sunny": 12, "cloudy": 12, "drizzle": 14, "rain": 10, "downpour": 3, "fog": 3, "snow": 0},
	"Summer": {"sunny": 26, "cloudy": 10, "drizzle": 2, "rain": 2, "downpour": 0, "fog": 2, "snow": 0},
	"Autumn": {"sunny": 6, "cloudy": 14, "drizzle": 16, "rain": 13, "downpour": 6, "fog": 5, "snow": 0},
}
const WEATHER_NAMES := {
	"sunny": "Sunny", "cloudy": "Overcast", "fog": "Foggy", "drizzle": "Drizzle",
	"rain": "Rain", "downpour": "Downpour", "snow": "Snow",
}
# The light over the farm for each kind of weather. Dark and grey weather is cooler.
# Dated events through the year. Each starts on its month and day and lasts `span` days.
# The effect is applied while the event is active, or once when it starts ("supper", "fair").
const SEASON_EVENTS := [
	{"id": "harvest_moon", "title": "Harvest Moon", "month": "September", "day": 22, "span": 1, "effect": "supper",
		"text": "The neighbours leave a supper on your step. Two meals go in your pack, and the evening feels warmer."},
	{"id": "first_frost", "title": "First Frost", "month": "November", "day": 10, "span": 3, "effect": "frost",
		"text": "The grass is white at dawn. The cold bites harder outside for three days, so keep your warmth up."},
	{"id": "longest_night", "title": "The Longest Night", "month": "December", "day": 21, "span": 1, "effect": "dread",
		"text": "The shortest day of the year. The dark comes early and stays late, and whatever watches the field is closer tonight."},
	{"id": "spring_thaw", "title": "Spring Thaw", "month": "March", "day": 1, "span": 2, "effect": "thaw",
		"text": "The soil is soft after the winter. Crops that were watered grow an extra stage."},
	{"id": "planting_fair", "title": "Planting Fair", "month": "April", "day": 20, "span": 1, "effect": "fair",
		"text": "The village sends five turnip seeds for the plots. Plant them while the ground is warm."},
	{"id": "all_hallows", "title": "All Hallows", "month": "October", "day": 31, "span": 1, "effect": "ward",
		"text": "Lanterns are lit along the road for the longest-feared night of the year. The dark costs less sanity tonight."},
	{"id": "winter_feast", "title": "Winter Feast", "month": "January", "day": 1, "span": 1, "effect": "feast",
		"text": "The neighbours bring a feast against the cold: two meals and a bandage go in your pack."},
	{"id": "midsummer_heat", "title": "Midsummer Heat", "month": "June", "day": 21, "span": 3, "effect": "heat",
		"text": "A dry heat settles over the valley for three days. The sky stays clear, so the crops need watering every morning."},
]

# Body needs: food and water drain through the day, and warmth changes with the temperature.
const FOOD_PER_HOUR := 2.4
const WATER_PER_HOUR := 3.0
const HOT_TEMP := 75.0           # above this, thirst grows faster
const HOT_WATER_MULT := 1.6
const COLD_TEMP := 50.0          # below this, being outdoors costs warmth
const WARMTH_LOSS := 0.35        # warmth lost per hour for each degree below COLD_TEMP
const WARMTH_OUTDOORS := 3.0     # warmth regained per hour outdoors in mild weather
const WARMTH_INDOORS := 25.0     # warmth regained per hour in a patched or restored house
const WARMTH_INDOORS_COLD := 10.0  # ... and in a decrepit or boarded one
const NEED_HARM_HOURS := 2.0     # one HP lost every this many hours while a need is empty
const POND_WATER := 40.0
const WELL_IX := Vector2i(12, 10)     # farm tile between plot one and the path, beside plot one
const WELL_CAPACITY := 40.0           # water in the tank when it refills each morning
const DRINK_WELL := 35.0
const WELL_REPAIR := {"wood": 4, "fiber": 3, "level": 2}
const HOSE_COST := {"fiber": 3, "resin": 2}
const WATER_RAIN_KINDS := ["drizzle", "rain", "downpour"]   # rain waters every crop
const SEASON_TEMP := {"Winter": 40.0, "Spring": 51.0, "Summer": 67.0, "Autumn": 54.0}
const WEATHER_TEMP := {"sunny": 6.0, "cloudy": 0.0, "fog": -2.0, "drizzle": -3.0, "rain": -4.0, "downpour": -6.0, "snow": -10.0}
const WEATHER_LIGHT := {
	"sunny": Color(1.0, 0.99, 0.96), "cloudy": Color(0.92, 0.94, 0.97), "fog": Color(0.9, 0.92, 0.94),
	"drizzle": Color(0.88, 0.91, 0.95), "rain": Color(0.88, 0.91, 0.95), "downpour": Color(0.8, 0.84, 0.9),
	"snow": Color(0.93, 0.95, 1.0),
}
const START_HOUR := 6.0
const DAY_END_HOUR := 27.0  # 03:00. Missing bed by then means collapsing.
const DUSK_HOUR := 19.0
const SLEEP_HOUR := 18.0    # the bed can be used from 18:00 onward
const BED_INTERIOR := Vector2i(2, 1)  # the bed's tile in the bedroom; you wake on the tile below it
const EVENT_HOUR := 22.0

const MAX_STAGE := 3        # 0 = seed, 3 = ready to harvest
const CROP_GROW_DAYS := {"turnip": 7, "pumpkin": 10}   # watered days from seed to ready: a week, and ten days
# What a sold crop fetches at the farm stand, and what food from it is worth.
const CROP_VALUE := {"turnip": 8, "pumpkin": 30}
const STAGE_NAMES := ["Decrepit", "Boarded", "Patched", "Restored"]
# Tips: short notes that appear one at a time as the player reaches each part of the farm.
# Each shows once, and the Settings menu keeps the ones already seen. When the condition is met, see _tip_ready.
const TIPS := [
	{"id": "well", "title": "The well", "text": "The pump by the plots is seized. Repair it from the Well panel, then attach the hose. The hose reaches every plot, so face a crop and press Space to water it. Rain waters everything."},
	{"id": "sleep", "title": "Sleeping", "text": "Walk to the bed in the bedroom and press Space from 18:00 to save and end the day. Stay up past 03:00 and you collapse, which lowers your sanity limit."},
	{"id": "chores", "title": "Keeping house", "text": "The house wears down a little each night. Tidy it and mend a board each day from the House section on the section wheel (Shift). Chores you skip add wear."},
	{"id": "repair", "title": "Repairing the farmhouse", "text": "Repair the house from the House section on the section wheel (Shift). Each stage restores it inside and out, and unlocks rooms and features."},
	{"id": "buildings", "title": "Buildings", "text": "Build the workshop, coop, and barn from the Buildings section on the section wheel (Shift). Pick a spot on open grass, press Space to place it, and B to cancel."},
	{"id": "quests", "title": "Quests", "text": "The Quests section, on the section wheel (Shift), lists what the farm asks of you. Press Details on a quest to read its story."},
	{"id": "hens", "title": "Hens", "text": "Stand beside the coop, facing it, and press Space to buy and feed hens. A grown hen that is fed lays an egg each morning. Hens are grown after a week."},
	{"id": "goats", "title": "Goats", "text": "Build the barn from the Buildings menu, then stand beside it, facing it, and press Space to buy and feed goats. A grown goat that is fed gives milk each morning. Goats are grown after ten days."},
	{"id": "cellar", "title": "Storing crops", "text": "Stand beside the root cellar and press Space to store or take crops. Nothing spoils in the cellar."},
	{"id": "smelt", "title": "Smelting and preserving", "text": "Stand beside the furnace and press Space to smelt ore into bars. The smokehouse preserves food, and the cooler keeps fish fresh."},
	{"id": "needs", "title": "Food, water, and warmth", "text": "Food and water drain through the day, and warmth drops outside on cold days. Eat from the bag (Tab), drink from the pond, and warm up in the house. Sleep to be fully warm again, but only with a fire lit: feed the hearth from the firewood store at the workshop."},
	{"id": "cave", "title": "The mine", "text": "The cave is at the west edge of the farm. Each day it lays out differently, with ore to mine and creatures to watch for."},
]
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
const HOUSE_RELIEF := 0.2
const COOP_ROOF := Color("8a4a30")
const COOP_WALL := Color("94693d")
const BARN_ROOF := Color("4a2a22")
const BARN_WALL := Color("8f3a2f")   # night darkness reduction once the house is restored

# Lantern tiers. Each entry is the next thing to build, in order.
const LANTERN_TIERS := [
	{"name": "Tin Lantern", "radius": 2.5, "wood": 2, "fiber": 2, "resin": 0, "level": 2},
	{"name": "Brass Lantern", "radius": 4.0, "wood": 4, "fiber": 4, "resin": 2, "level": 4},
	{"name": "Hollow Lantern", "radius": 6.0, "wood": 6, "fiber": 6, "resin": 4, "level": 6},
]
const LANTERN_FLICKER_TIER := 3
# How bright a lantern and a lit window glow. Kept low, so the dark still reads as dark.
const LANTERN_ENERGY := 0.5
const WINDOW_ENERGY := 0.45

# Crops. Turnips are the starter crop. Pumpkins need Farming 3 and yield more.
const CROPS := {
	"turnip": {"seed": "seeds", "yield": 1, "xp": 25, "colors": ["8fd16b", "4f9a3a", "2f7a2a", "e8b440"]},
	"pumpkin": {"seed": "pumpkin_seeds", "yield": 3, "xp": 40, "colors": ["9fd27a", "d98a35", "c26a1f", "f2a13a"]},
}
const PUMPKIN_LEVEL := 3
# A crop sells for its seed's cost spread over its yield, plus this difficulty bonus.
# Pumpkins need Farming 3 and more care, so each one sells for more than a turnip.

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
# The root cellar sits against the house's west wall, like a cellar dug in beside it.
# The workshop, with the furnace and smokehouse, stands against the east wall.
# The cooler lives inside the house. House walls are at x 26 to 32 and y 3 to 8 (local to the farm).
const CELLAR_IX := Vector2i(25, 5)
const SMOKEHOUSE_IX := Vector2i(35, 3)
const FURNACE_IX := Vector2i(33, 3)
# The workshop is a walled building against the house's east wall, with a door on its south side.
const WORKSHOP_RECT := Rect2i(32, 2, 5, 4)   # farm-local: outer walls, x 32 to 36, y 2 to 5
const WORKSHOP_DOOR := Vector2i(34, 5)
const COOP_SIZE := 2                         # the coop is a 2 by 2 building on open grass
const COOLER_INTERIOR := Vector2i(11, 6)   # in the hall, inside the house
const FURNACE_COST := {"wood": 6, "stone": 4, "coins": 80, "level": 4}
const WOODSHED_COST := {"wood": 4, "fiber": 2, "coins": 40, "level": 2}
const WOODSTORE_IX := Vector2i(33, 4)   # farm-local, inside the workshop
const CHOPLOG_IX := Vector2i(35, 4)
const WOODSTORE_CAP := 30
const FIREWOOD_PER_WOOD := 2
const FIREWOOD_HOURS := 3.0         # hours of warmth one firewood gives the hearth
const FIRE_MAX_HOURS := 12.0        # the hearth holds at most four firewood's worth
const XP_CHOP_LOG := 6
const SMELT_LEVEL := {"copper": 1, "iron": 4}
const XP_SMELT := 10
# Ammunition is fletched at the Craft panel and used up by each shot.
const AMMO := {
	"arrows": {"name": "Arrows", "yield": 5, "cost": {"wood": 1, "fiber": 1}, "skill": "Bushcrafting", "level": 2},
	"bolts": {"name": "Bolts", "yield": 3, "cost": {"hardwood": 1, "copper_bar": 1}, "skill": "Smithing", "level": 2},
}
const SHOT_SPEED := 320.0
const SHOT_LIFE := 0.9
const SMOKEHOUSE_COST := {"wood": 5, "fiber": 3, "coins": 60, "level": 3}
# Preserving turns food into goods that keep in the pack. Each method needs a skill
# level and makes one item per press at the smokehouse.
# The stall sells what you carry and buys seeds. It is open 06:00 to 18:00.
const STALL_IX := 22
const STALL_IY := 9
const STALL_CLOSE_HOUR := 18.0
const SELL_FISH := 6
const SELL_EGG := 4                 # farm stand price for an egg
const SELL_MILK := 6                # farm stand price for a jug of goat milk
const HEN_SELL := 20                # what a grown hen fetches at the coop
const GOAT_SELL := 70               # what a grown goat fetches at the barn
const HEN_MATURE_DAYS := 7          # nights before a hen is grown and starts laying: a week
const GOAT_MATURE_DAYS := 10        # nights before a goat is grown and starts giving milk: ten days
const PROPERTY_TAX := 40            # coins per quarter at the start: the base of the property value
const PROPERTY_HOUSE_GROWTH := 1.8  # each house upgrade multiplies the value (exponential)
const PROPERTY_PER_BUILDING := 0.05 # +5% for each building on the farm
const PROPERTY_PER_PLOT := 0.25     # +25% for each farm plot unlocked past the first
const PROPERTY_PER_CLEAN_NIGHT := 0.01  # +1% for each clean night in a row (every chore done)
const PROPERTY_CLEAN_NIGHTS_MAX := 20   # the clean bonus stops growing after this many nights
const TAX_MONTHS := [0, 3, 6, 9]    # January, April, July, October: the bill comes on the 1st
const TAX_GRACE_DAYS := 14          # days to pay a bill after it arrives
const TAX_FINAL_DAYS := 7           # days overdue before the final notice
const TAX_EVICT_DAYS := 14          # days overdue before the land is lost
const DESK_IX := Vector2i(4, 1)     # the desk, in the bedroom: post lands here
const SEED_TURNIP_PRICE := 3    # per seed, sold in packs of 5
const SEED_PUMPKIN_PRICE := 10  # per seed, sold in packs of 3

# The road east of the farm leads to Lowmere. It is walked in daylight only.
const VILLAGE_W := 36
const VILLAGE_H := 20
const VILLAGE_GATE := Vector2i(0, 10)
const VILLAGE_HOUSES := [Rect2i(4, 3, 5, 4), Rect2i(13, 2, 6, 4), Rect2i(8, 14, 5, 4)]
const VILLAGE_WATER := Rect2i(19, 13, 2, 2)
# Hollows gather in the clearing east of the village wood. They respawn each morning.
const HOLLOW_SPAWNS := [Vector2i(28, 9), Vector2i(31, 13), Vector2i(33, 8)]
const XP_HIT := 4
const BASE_HP := 10
const HOMESTEAD_ARRIVE := Vector2i(BORDER_X + INNER_W - 3, BORDER_Y + INNER_H / 2)
const SWING_TIME := 0.3       # seconds the swing is shown
const SWING_COOLDOWN := 0.5
const SWING_REACH := 1.5      # tiles
const SWING_ARC := 0.3        # how far off straight ahead a foe can be and still be hit
const INVULN_TIME := 0.9      # seconds of safety after a hit
# Foes roam their area and chase when you come close. Stats are per kind.
const FOES := {
	"hollow": {"hp": 6, "speed": 26.0, "chase": 52.0, "dmg": 2, "aggro": 3.0, "cool": 1.2, "color": "1a1020", "xp": 20, "drop": "fiber"},
	"stalker": {"hp": 10, "speed": 36.0, "chase": 84.0, "dmg": 3, "aggro": 4.5, "cool": 1.0, "color": "3a2a4a", "xp": 30, "drop": "resin"},
	"bat": {"hp": 4, "speed": 40.0, "chase": 70.0, "dmg": 1, "aggro": 3.5, "cool": 0.9, "color": "3a3040", "xp": 12, "drop": "fiber"},
	"lizard": {"hp": 8, "speed": 22.0, "chase": 44.0, "dmg": 2, "aggro": 3.0, "cool": 1.3, "color": "5f7a3a", "xp": 18, "drop": "resin"},
	"snake": {"hp": 6, "speed": 30.0, "chase": 56.0, "dmg": 2, "aggro": 3.5, "cool": 1.1, "color": "6a5a2a", "xp": 16, "drop": "fiber"},
}
const STALKER_SPAWNS := [Vector2i(26, 8), Vector2i(29, 12), Vector2i(31, 7)]
const ASHFORD_HOUSES := [Rect2i(5, 3, 6, 5), Rect2i(14, 13, 5, 4)]
const ASHFORD_WATER := Rect2i(22, 4, 3, 3)

# Generated towns fill the rest of the world. Each cell of the grid may hold one town.
const TOWN_SEED := 40417
const TOWN_CELL := 80
const TOWN_CHANCE := 0.75
const TOWN_KINDS := [
	{"kind": "hamlet", "w": 28, "h": 20, "weight": 5},
	{"kind": "town", "w": 40, "h": 28, "weight": 3},
	{"kind": "castle", "w": 34, "h": 26, "weight": 3},
	{"kind": "manor", "w": 20, "h": 16, "weight": 2},
]
const TOWN_START_CLEAR := Rect2i(300, 380, 280, 140)   # keeps the portal road free
const TOWN_NAME_START := ["Ash", "Brook", "Crow", "Dun", "Elm", "Fen", "Gale", "Hollow", "Iron", "Kettle", "Lark", "Mere", "Nettle", "Oak", "Pike", "Reed", "Stone", "Thorn", "Vale", "Wick", "Yew"]
const TOWN_NAME_END := ["bury", "ford", "holt", "more", "stead", "ton", "wick", "field", "hythe", "dale", "moor", "by"]
const TOWN_FIRST := ["Alder", "Bram", "Cora", "Dell", "Edda", "Frank", "Gwen", "Hal", "Ivy", "Jory", "Kit", "Lenna", "Mabel", "Nell", "Osric", "Pell", "Quinn", "Rhea", "Sol", "Tobin", "Una", "Vern", "Wat", "Yara"]
const TOWN_LAST := ["Ashby", "Brightwater", "Cole", "Dunmore", "Fairlight", "Greave", "Ingle", "Joss", "Kell", "Latch", "Marsh", "Nye", "Pryce", "Rook", "Sayer", "Teague"]
const TOWN_NPC_COLORS := ["d8d0b0", "b6e0a0", "e0c48c", "c98f5a", "a3c9e0", "e0a0b6", "c0b0e0"]
const GENERAL_BUY := {"wood": 3, "fiber": 2, "resin": 5, "stone": 4, "hardwood": 8}
const GENERAL_BUY_QTY := 10
const TOWN_ROLES := {
	"town": ["shop_general", "shop_grocer", "bank", "home", "home", "home", "home"],
	"hamlet": ["shop_general", "home", "home", "home"],
	"castle": ["bank", "home", "home"],
	"manor": ["home"],
}

const ASHFORD_NPCS := [
	{"id": "harrow", "name": "Harrow the Miller", "pos": Vector2i(12, 9), "color": "d8d0b0", "lines": [
		"The mill has stopped turning. The stones need grinding, and the millers have gone to the wood.",
		"Strange things came down the road at dusk. They move faster than anything from Lowmere.",
		"Bring me five crops and I'll grind flour. The mill will turn again.",
		"The wheel turns! Thank you, guardian. Ashford owes you more than flour.",
	]},
	{"id": "wren", "name": "Wren", "pos": Vector2i(20, 11), "color": "b6e0a0", "lines": [
		"Careful on the road. Stalkers don't wait for you to see them.",
		"They chased me all the way to the bridge. I still hear them at night.",
		"The mill is the heart of Ashford. Harrow is stubborn, but he's right.",
		"You've given us back the road. We won't forget it.",
	]},
]
# Gear you can craft with wood, fiber, and resin. Crafting equips the piece at once.
const GEAR_ITEMS := {
	"hoe": {"name": "Hoe", "slot": "hand_r", "dmg": 1, "def": 0, "level": 1, "cost": {}},
	"sharpened_stick": {"name": "Sharpened stick", "slot": "hand_r", "dmg": 2, "def": 0, "level": 2, "cost": {"wood": 2, "fiber": 1}},
	"hunting_knife": {"name": "Hunting knife", "slot": "hand_r", "dmg": 3, "def": 0, "level": 4, "cost": {"wood": 2, "resin": 2}},
	"resin_cap": {"name": "Resin cap", "slot": "head", "dmg": 0, "def": 1, "level": 2, "cost": {"resin": 2, "fiber": 2}},
	"fiber_wraps": {"name": "Fiber wraps", "slot": "wrist", "dmg": 0, "def": 1, "level": 1, "cost": {"fiber": 3}},
	"bark_wrap": {"name": "Bark wrap", "slot": "chest", "dmg": 0, "def": 2, "level": 3, "cost": {"wood": 3, "fiber": 3}},
	"bark_boots": {"name": "Bark boots", "slot": "feet", "dmg": 0, "def": 1, "level": 3, "cost": {"wood": 2, "fiber": 2}},
	"twine_collar": {"name": "Twine collar", "slot": "neck", "dmg": 0, "def": 1, "level": 2, "cost": {"fiber": 3}},
	"resin_amulet": {"name": "Resin amulet", "slot": "neck", "dmg": 0, "def": 2, "level": 5, "cost": {"resin": 3, "fiber": 2}},
	"reed_leggings": {"name": "Reed leggings", "slot": "legs", "dmg": 0, "def": 1, "level": 1, "cost": {"fiber": 4}},
	"bark_greaves": {"name": "Bark greaves", "slot": "legs", "dmg": 0, "def": 2, "level": 4, "cost": {"wood": 3, "fiber": 3}},
	"copper_helm": {"name": "Copper helm", "slot": "head", "dmg": 0, "def": 2, "level": 2, "skill": "Smithing", "cost": {"copper_bar": 3}},
	"copper_torc": {"name": "Copper torc", "slot": "neck", "dmg": 0, "def": 2, "level": 2, "skill": "Smithing", "cost": {"copper_bar": 2}},
	"copper_cuirass": {"name": "Copper cuirass", "slot": "chest", "dmg": 0, "def": 3, "level": 3, "skill": "Smithing", "cost": {"copper_bar": 4}},
	"copper_sword": {"name": "Copper sword", "slot": "hand_r", "dmg": 4, "def": 0, "level": 2, "skill": "Smithing", "cost": {"copper_bar": 3}},
	"copper_bracers": {"name": "Copper bracers", "slot": "wrist", "dmg": 0, "def": 2, "level": 2, "skill": "Smithing", "cost": {"copper_bar": 2}},
	"copper_greaves": {"name": "Copper greaves", "slot": "legs", "dmg": 0, "def": 2, "level": 3, "skill": "Smithing", "cost": {"copper_bar": 3}},
	"copper_boots": {"name": "Copper boots", "slot": "feet", "dmg": 0, "def": 2, "level": 3, "skill": "Smithing", "cost": {"copper_bar": 2}},
	"iron_helm": {"name": "Iron helm", "slot": "head", "dmg": 0, "def": 3, "level": 5, "skill": "Smithing", "cost": {"iron_bar": 3}},
	"iron_torc": {"name": "Iron torc", "slot": "neck", "dmg": 0, "def": 3, "level": 5, "skill": "Smithing", "cost": {"iron_bar": 2}},
	"iron_cuirass": {"name": "Iron cuirass", "slot": "chest", "dmg": 0, "def": 4, "level": 6, "skill": "Smithing", "cost": {"iron_bar": 4}},
	"iron_sword": {"name": "Iron sword", "slot": "hand_r", "dmg": 6, "def": 0, "level": 5, "skill": "Smithing", "cost": {"iron_bar": 4}},
	"iron_gauntlets": {"name": "Iron gauntlets", "slot": "wrist", "dmg": 0, "def": 3, "level": 5, "skill": "Smithing", "cost": {"iron_bar": 2}},
	"iron_greaves": {"name": "Iron greaves", "slot": "legs", "dmg": 0, "def": 3, "level": 6, "skill": "Smithing", "cost": {"iron_bar": 3}},
	"iron_sabatons": {"name": "Iron sabatons", "slot": "feet", "dmg": 0, "def": 3, "level": 6, "skill": "Smithing", "cost": {"iron_bar": 2}},
	"wood_shield": {"name": "Hardwood shield", "slot": "offhand", "dmg": 0, "def": 2, "level": 4, "skill": "Forestry", "cost": {"hardwood": 3, "fiber": 2}},
	"copper_shield": {"name": "Copper shield", "slot": "offhand", "dmg": 0, "def": 3, "level": 3, "skill": "Smithing", "cost": {"copper_bar": 4, "hardwood": 1}},
	"iron_shield": {"name": "Iron shield", "slot": "offhand", "dmg": 0, "def": 4, "level": 6, "skill": "Smithing", "cost": {"iron_bar": 4, "hardwood": 1}},
	"hardwood_bow": {"name": "Hardwood bow", "slot": "hand_r", "dmg": 3, "def": 0, "level": 3, "skill": "Forestry", "cost": {"hardwood": 3, "fiber": 2}, "ammo": "arrows", "cool": 0.6},
	"crossbow": {"name": "Crossbow", "slot": "hand_r", "dmg": 6, "def": 0, "level": 3, "skill": "Smithing", "cost": {"hardwood": 4, "copper_bar": 2}, "ammo": "bolts", "cool": 1.2},
}
const NPCS := [
	{"id": "mara", "name": "Mara the Reeve", "pos": Vector2i(8, 9), "color": "e0c48c", "lines": [
		"Welcome to Lowmere. Few of us still stand. Talk with the others and see how they fare.",
		"The hollow ones came out of the wood at dusk. Keep them out of the fields.",
		"Tomas has been asking after you. He's been without bread for days.",
		"You've made Lowmere a little safer. Keep walking the road by day.",
	]},
	{"id": "tomas", "name": "Tomas the Baker", "pos": Vector2i(16, 11), "color": "c98f5a", "lines": [
		"The ovens are cold and the flour is gone. If you ever have a warm meal to spare...",
		"Those things don't care that we're hungry. Keep your strength up.",
		"Bring me something cooked, and I'll see that the village eats tonight.",
		"Thank you. I've not seen a warm loaf in weeks.",
	]},
	{"id": "elsie", "name": "Elsie", "pos": Vector2i(22, 9), "color": "a3c9e0", "lines": [
		"Don't go into the wood after dark. That's where they come from.",
		"I saw one by the wood's edge. It had no face, only eyes.",
		"The clearing east of the wood is where they gather. Go slow.",
		"Papa says you're the guardian now. I'm glad it's you.",
	]},
]
const GUARDIAN_QUESTS := [
	{"id": "meet", "title": "Meet the Village",
		"story": "Lowmere is small and frightened. Its people have heard the things in the wood at night. Learn their names, and they'll trust you with their troubles.",
		"text": "Talk with the villagers. (3 conversations)", "stat": "talks", "goal": 3, "reward": {"coins": 20}},
	{"id": "first_horror", "title": "The First Horror",
		"story": "The hollow ones gather in the clearing east of the wood. Each one is hollow and slow, but they don't stop. Face one and press Space to fight it.",
		"text": "Defeat 3 hollow ones.", "stat": "defeated", "goal": 3, "reward": {"skill": "Combat", "xp": 60}},
	{"id": "bread", "title": "Bread for Tomas",
		"story": "Tomas has no flour and no fire to bake with. A cooked meal from your homestead would mean the world to him.",
		"text": "Bring a meal to Tomas.", "stat": "delivered", "goal": 1, "reward": {"coins": 40}},
	{"id": "hold_road", "title": "Hold the Road",
		"story": "The road to Lowmere is only safe while someone walks it. Keep the clearing quiet, and the village can sleep at night.",
		"text": "Defeat 10 hollow ones in total.", "stat": "defeated", "goal": 10, "reward": {"coins": 80, "pumpkin_seeds": 3}},
	{"id": "ashford", "title": "The Road East",
		"story": "Beyond the wood, the road runs on to Ashford, where the mill has stopped turning. Walk it in daylight and see what has happened there.",
		"text": "Reach Ashford.", "stat": "visited", "goal": 1, "reward": {"coins": 50}},
	{"id": "flour", "title": "Flour for the Mill",
		"story": "Harrow the miller will grind grain for anyone who brings him food for the hands that work the stones. Five crops would keep the mill turning another week.",
		"text": "Give 5 crops to Harrow.", "stat": "crops_given", "goal": 5, "reward": {"coins": 60, "pumpkin_seeds": 2}},
	{"id": "stalkers", "title": "Stalkers on the Road",
		"story": "Faster things hunt the road beyond Lowmere. They are quick and their claws are long. Only strikes will stop them.",
		"text": "Defeat 5 stalkers.", "stat": "stalkers", "goal": 5, "reward": {"skill": "Combat", "xp": 120}},
]

# Story chapters run in order. The first unfinished one is the Current chapter.
# "story" is the narrative beat, "text" the goal, and "stat" what it reads.
# Story chapters run in order. The first unfinished one is the Current chapter.
# "story" is the narrative beat, "text" the goal, and "stat" what it reads.
const STORY := [
	{"id": "first_crop", "title": "Food Takes Time",
		"story": "Seeds need days to become food. Each night they are watered, they grow. Turnips take a week and pumpkins ten days. Come back when something is ripe, and take it.",
		"text": "Harvest one ripe crop.",
		"prompt": "{tool:hoe} to select the hoe. Once a crop is ripe, face it and press {use} to harvest it.", "stat": "harvested", "goal": 1, "reward": {"skill": "Farming", "xp": 50}},
	{"id": "light", "title": "Light the Way",
		"story": "The night here is longer than the day, and it is not empty. A lantern keeps the dark a little further off.",
		"text": "Build a Tin Lantern.", "stat": "lantern_tier", "goal": 1, "reward": {"seeds": 3}},
	{"id": "bed", "title": "Sleep Under Your Own Roof",
		"story": "Your body can only work so long. The bed is in the bedroom. Reach it before 03:00, or the night takes you where you stand.",
		"text": "Sleep in the bed before 03:00.", "stat": "slept", "goal": 1, "reward": {"skill": "Carpentry", "xp": 40}},
	{"id": "second_plot", "title": "The Overgrown Plot",
		"story": "The second plot is choked with weeds. Clearing it takes more skill than you have yet.",
		"text": "Reach Farming level 2.", "stat": "level_Farming", "goal": 2, "reward": {"pumpkin_seeds": 3}},
	{"id": "winter_store", "title": "Feed Yourself Through the Cold",
		"story": "One crop will not last. Harvest enough to keep a store against the long nights.",
		"text": "Harvest 10 crops.", "stat": "harvested", "goal": 10, "reward": {"skill": "Farming", "xp": 60}},
	{"id": "first_sale", "title": "Coin for Seed",
		"story": "The farm stand on the path buys what the land gives you. Coins buy seeds, bags, and the rooms the homestead will need. Sell five items to learn how it works.",
		"text": "Sell 5 items at the farm stand.", "stat": "sold", "goal": 5, "reward": {"coins": 30}},
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
	{"id": "goat_keeper", "title": "Goat Keeper", "text": "Buy a goat for the barn.", "tier": 0, "stat": "goats_bought", "goal": 1, "reward": {"seeds": 2}},
	{"id": "first_drink", "title": "Cool Water", "text": "Drink from the pond or the pump.", "tier": 0, "stat": "drank", "goal": 1, "reward": {"seeds": 2}},
	{"id": "first_water", "title": "Hose Hand", "text": "Water a crop with the hose.", "tier": 0, "stat": "watered", "goal": 1, "reward": {"seeds": 2}},

	{"id": "ten_harvests", "title": "Ten Harvests", "text": "Harvest 10 crops.", "tier": 1, "stat": "harvested", "goal": 10, "reward": {"wood": 2, "fiber": 2}},
	{"id": "carpenter", "title": "Carpenter's Hand", "text": "Mend 6 boards.", "tier": 1, "stat": "mended", "goal": 6, "reward": {"wood": 2, "fiber": 2}},
	{"id": "good_catch", "title": "Good Catch", "text": "Catch 10 fish.", "tier": 1, "stat": "caught", "goal": 10, "reward": {"wood": 2, "fiber": 2}},
	{"id": "meal_plan", "title": "Meal Planner", "text": "Eat 5 meals.", "tier": 1, "stat": "eaten", "goal": 5, "reward": {"wood": 2, "fiber": 2}},
	{"id": "patched", "title": "Patched Up", "text": "Repair the house to Patched.", "tier": 1, "stat": "house_stage", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "brass_light", "title": "Brass Light", "text": "Build a Brass Lantern.", "tier": 1, "stat": "lantern_tier", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "farmer_2", "title": "Growing Hands", "text": "Reach Farming level 2.", "tier": 1, "stat": "level_Farming", "goal": 2, "reward": {"wood": 2, "fiber": 2}},
	{"id": "bush_3", "title": "Thicket Walker", "text": "Reach Bushcrafting level 3.", "tier": 1, "stat": "level_Bushcrafting", "goal": 3, "reward": {"wood": 2, "fiber": 2}},
	{"id": "cleaner", "title": "Clean Air", "text": "Tidy the house 5 times.", "tier": 1, "stat": "tidied", "goal": 5, "reward": {"wood": 2, "fiber": 2}},
	{"id": "pump_fixed", "title": "Working Pump", "text": "Repair the well pump.", "tier": 1, "stat": "pump", "goal": 1, "reward": {"wood": 2, "fiber": 2}},
	{"id": "hose_on", "title": "Garden Hose", "text": "Attach the hose to the pump.", "tier": 1, "stat": "hose", "goal": 1, "reward": {"fiber": 2}},
	{"id": "rain_days", "title": "Rain Keeps Them Green", "text": "Live through 5 rainy days.", "tier": 1, "stat": "rain_days", "goal": 5, "reward": {"wood": 2, "fiber": 2}},

	{"id": "restored", "title": "Restored", "text": "Restore the farmhouse fully.", "tier": 2, "stat": "house_stage", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "pumpkin_grower", "title": "Pumpkin Grower", "text": "Harvest 3 pumpkins.", "tier": 2, "stat": "pumpkins", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "cleansed", "title": "Cleansed", "text": "Cleanse the house once.", "tier": 2, "stat": "cleansed", "goal": 1, "reward": {"wood": 3, "fiber": 3}},
	{"id": "fishmonger", "title": "Fishmonger", "text": "Catch 30 fish.", "tier": 2, "stat": "caught", "goal": 30, "reward": {"wood": 3, "fiber": 3}},
	{"id": "carpenter_3", "title": "Tradesman", "text": "Reach Carpentry level 3.", "tier": 2, "stat": "level_Carpentry", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "fisher_3", "title": "Patient Angler", "text": "Reach Fishing level 3.", "tier": 2, "stat": "level_Fishing", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "hollow_light", "title": "Hollow Light", "text": "Build a Hollow Lantern.", "tier": 2, "stat": "lantern_tier", "goal": 3, "reward": {"wood": 3, "fiber": 3}},
	{"id": "survivor", "title": "Survivor", "text": "Sleep in your bed 10 times.", "tier": 2, "stat": "slept", "goal": 10, "reward": {"wood": 3, "fiber": 3}},
	{"id": "watcher", "title": "Field Watcher", "text": "Live through 5 nights of events.", "tier": 2, "stat": "events", "goal": 5, "reward": {"wood": 3, "fiber": 3}},
	{"id": "waterer", "title": "Tender of the Plots", "text": "Water 50 crops with the hose.", "tier": 2, "stat": "watered", "goal": 50, "reward": {"wood": 3, "fiber": 3}},
	{"id": "season_3", "title": "Turning Seasons", "text": "Live through 3 seasonal events.", "tier": 1, "stat": "events_seen", "goal": 3, "reward": {"wood": 2, "fiber": 2}},

	{"id": "season_6", "title": "A Full Year", "text": "Live through 6 seasonal events.", "tier": 3, "stat": "events_seen", "goal": 6, "reward": {"seeds": 5}},
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

const SKILLS := ["Farming", "Bushcrafting", "Carpentry", "Cleaning", "Fishing", "Cooking", "Combat", "Forestry", "Mining", "Smithing"]
const XP_PLANT := 5
const XP_GATHER := 10
const XP_REPAIR := 30
const XP_TIDY := 20
const TIDY_CLEANING_BONUS := 5     # extra sanity from a tidy at Cleaning 2
const XP_MEND := 15
const MEND_WOOD := 1
const MEND_FIBER := 1
# Upkeep: the house wears a little each night. Mending, tidying, and repairs bring it down.
const WEAR_MAX := 10
const WEAR_PER_NIGHT := 1
const WEAR_MEND := 2
const WEAR_TIDY := 1
const WEAR_REPAIR := 3
const WELL_KEPT_SANITY := 5    # sanity back for a night with every chore done
const WEAR_RUNDOWN := 6       # at this wear, rain ruins a crop overnight
const WEAR_FOX := 4           # at this wear, a fox can get into the coop
# Livestock: hens in a coop behind the house. A fed hen lays an egg each morning.
const COOP_COST := {"wood": 6, "fiber": 4, "level": 2}
const COOP_HENS_MAX := 4
const BARN_SIZE := Vector2i(3, 2)          # the barn is 3 wide and 2 deep, on open grass
const BARN_COST := {"wood": 10, "fiber": 6, "level": 4}   # the barn is for livestock, kept apart from the coop
const HEN_PRICE := 12
const HEN_FEED_CROPS := 1
const HEN_LEAVE_DAYS := 2     # unfed this many days in a row, and a hen wanders off
const BARN_GOATS_MAX := 3     # goats the barn holds
const GOAT_PRICE := 45
const GOAT_FEED_CROPS := 2    # crops per goat, once a day
const GOAT_LEAVE_DAYS := 2    # unfed this many days in a row, and a goat wanders off
const MEND_DAILY_LIMIT := 2   # keeps Carpentry training to a few days per level
const CLEANSE_LEVEL := 3      # Cleaning level needed to cleanse the house
const CLEANSE_CROPS := 2      # crops offered per cleanse
const CLEANSE_RELIEF := 5     # sanity limit restored per cleanse
const XP_FISH := 15
const FISH_SPOT_COUNT := 3
const FISH_SPOT_MIN_LIFE := 15.0   # seconds a spot stays active before it moves
const FISH_SPOT_MAX_LIFE := 30.0
const FISH_TICK_SECONDS := 3.0     # one catch roll per tick while fishing
const HARVEST_TICK_SECONDS := 1.0  # one roll per tick while chopping or mining
const CHOP_BASE_CHANCE := 0.2      # odds of felling a tree per roll, before the hatchet's tier
const MINE_BASE_CHANCE := 0.2      # odds of breaking a rock per roll, before the pick's tier
const TOOL_TIER_CHANCE := 0.15     # each tool tier adds this to the odds
const FISH_BASE_CHANCE := 0.5      # chance to catch on a tick at Fishing 1
const FISH_CHANCE_PER_LEVEL := 0.03
const FISH_CHANCE_CAP := 0.9
const NO_SPOT := Vector2i(-1, -1)

const STARTING_SEEDS := 5
const MESSAGE_SECONDS := 3.0
const SANITY_MAX := 100.0
const BOREDOM_ENABLED := false      # paused: no boredom drain while the desk games are reworked
const BOREDOM_DRAIN := 1.0          # sanity limit lost on a day with no finished desk game
const BOREDOM_MAX_LOSS := 40.0      # the most boredom can take from the limit
const SOL_PASSES := 3               # times the solitaire waste can be turned back into the deck
const DESK_SUITS := ["Hearts", "Diamonds", "Clubs", "Spades"]
const DESK_RANKS := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
const SUDOKU_BASE := [[1, 2, 3, 4], [3, 4, 1, 2], [2, 1, 4, 3], [4, 3, 2, 1]]
const LOW_SANITY := 30.0
const SLEEP_SANITY := 25.0
const TIDY_SANITY := 10.0
const COLLAPSE_SANITY_PENALTY := 5   # permanent cap reduction, curable with a cleanse
var save_slot := 1                  # which save slot this game reads and writes
var world_started := false         # false while the start screen is up
var title_menu: TitleMenu
const SETTINGS_PATH := "user://hallowvale_settings.json"
var music_on := true
var music_player: AudioStreamPlayer
var sfx_on := true                  # sound effects, remembered with the music setting
var sfx_streams: Dictionary = {}    # sound name -> AudioStreamOggVorbis
var sfx_players: Array = []         # a small pool, so overlapping sounds can play together
var sfx_next := 0
var bleat_timer := 20.0             # seconds until a goat next bleats
var thunder_day := -1               # the day thunder last rolled, so it rolls once a morning
var weather: CanvasLayer  # the dreary weather overlay
var tips_seen: Dictionary = {}     # tip id -> true, once it has been shown
var tip_queue: Array = []          # tip ids waiting their turn
var tip_showing := ""              # the tip on screen now, or ""
var tip_timer := 0.0
var tip_cooldown := 0.0
var tip_check_timer := 0.0
var tip_panel: PanelContainer
var tip_title_label: Label
var tip_body_label: Label

# Night events: picked by day so the nights vary. "shadow" says where it appears.
const NIGHT_EVENTS := [
	{"message": "Something stands at the edge of the field.", "shadow": "field", "sanity": -5},
	{"message": "Three slow knocks sound against the house wall.", "shadow": "house", "sanity": -10},
	{"message": "A figure watches from the dark beside the house.", "shadow": "house", "sanity": -15},
	{"message": "The field is quiet tonight. Too quiet.", "shadow": "none", "sanity": -3},
]

enum Tile { TREE, GRASS, SOIL, PATH, WATER, HOUSE, DOOR, FLOOR, WALL, EXIT, BED, STATION, DESK, FALLOW, STALL, CELLAR, COOLER, GATE, SMOKEHOUSE, FURNACE, PORTAL, CAMP, CAVE_MOUTH, CAVE_EXIT, ORE_COPPER, ORE_IRON, COOP, BARN, TABLE, FIREPLACE, WELL, PORCH, WOODSTORE, CHOPLOG }

const BLOCKING := [Tile.TREE, Tile.WATER, Tile.HOUSE, Tile.WALL, Tile.BED, Tile.STATION, Tile.DESK, Tile.STALL, Tile.CELLAR, Tile.COOLER, Tile.SMOKEHOUSE, Tile.FURNACE, Tile.CAMP, Tile.ORE_COPPER, Tile.ORE_IRON, Tile.COOP, Tile.BARN, Tile.TABLE, Tile.FIREPLACE, Tile.WELL, Tile.WOODSTORE, Tile.CHOPLOG]

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
	Tile.CELLAR: Color("a88ad0"),
	Tile.COOLER: Color("7fc4e0"),
	Tile.GATE: Color("8f7a4f"),
	Tile.SMOKEHOUSE: Color("9a5a3a"),
	Tile.FURNACE: Color("5c5c66"),
	Tile.WOODSTORE: Color("6b4a2e"),
	Tile.CHOPLOG: Color("5a3a22"),
	Tile.PORTAL: Color("6a4fc0"),
	Tile.CAVE_MOUTH: Color("2a2a30"),
	Tile.CAVE_EXIT: Color("a08050"),
	Tile.ORE_COPPER: Color("b87333"),
	Tile.ORE_IRON: Color("8a8f99"),
	Tile.COOP: Color("8a6a3a"),
	Tile.WELL: Color("6e6a64"),
	Tile.BARN: Color("7a2e26"),
	Tile.TABLE: Color("7a5230"),
	Tile.FIREPLACE: Color("5a5650"),
	Tile.CAMP: Color("d07a30"),
	Tile.PORCH: Color("8a6a46"),
}


const NIGHT_TINT := Color("3a3f6e")

enum Zone { HOMESTEAD, VILLAGE, ASHFORD, WILDS, TOWN }

var map: Array = []                 # farm tiles, [y][x]
var world := PackedByteArray()      # the whole land, index y * WORLD_W + x
var campsite := NO_CAMP             # the one campsite, in world tiles
var world_map_tex: Texture2D = null # the whole land as a small picture for the minimap
var towns: Array = []               # generated towns: origin, size, kind, title, npcs
var current_town := -1              # index into towns while the player is in one
var active_shop := ""               # the shop open in the Shop panel
var bank_materials := {"wood": 0, "sticks": 0, "fiber": 0, "resin": 0, "hardwood": 0, "stone": 0, "copper_ore": 0, "iron_ore": 0, "copper_bar": 0, "iron_bar": 0, "arrows": 0, "bolts": 0}
var bank_coins := 0
var in_cave := false                # standing in the mining cave
var cave: Array = []                # cave tiles, [y][x], in cave tile coordinates
var cave_spawns: Array = []         # creatures placed on each entry: {kind, tile}
var cave_mined: Dictionary = {}     # cave ore already broken today, tile -> true
var cave_mined_day := -1            # the day cave_mined belongs to; a new day brings new ore

var interior: Array = []            # house tiles, [y][x], local to INT_ORIGIN
var crops := {}                     # Vector2i world tile -> {"stage": int, "kind": String}
var brush := {}                     # Vector2i world tile -> true while unharvested
var pond_edges: Array = []          # water tiles with land beside them
var fish_spots: Dictionary = {}        # tile -> seconds left before the spot moves
var fishing_tile := NO_SPOT            # the spot being fished, or NO_SPOT
var last_walk_tile := NO_SPOT           # the tile the player stood on last frame, for the walking chapter
var harvest_tile := NO_SPOT            # the tree or rock being worked, or NO_SPOT
var harvest_kind := ""                 # "chop" or "mine" while a roll is running, else ""
var harvest_timer := 0.0
var crow_layer: Node2D                 # crows on the farm, drawn on their own layer
var crows: Array = []                  # each: pos, target, state, timer, flap, facing
var crow_perches: Array = []           # where a crow can land: the roof and the tree tops
var crow_spawn_timer := 6.0
const MAX_CROWS := 3
const CROW_SPEED := 90.0
var harvest_place := ""              # the area a roll started in, so leaving it stops the roll
var fish_timer := 0.0
var fish_layer: Node2D
var plot_two_open := false
var clock := 0.0
var current_hour := START_HOUR
var day := 1
var food := 100.0
var water := 100.0
var warmth := 100.0
var starve_timer := 0.0
var well_repaired := false
var hose_attached := false
var well_water := 0.0      # hours spent with an empty need, toward the next HP lost
var weather_kind := ""       # today's weather, rolled each morning: see WEATHER_WEIGHTS
var skill_xp := {"Farming": 0, "Bushcrafting": 0, "Carpentry": 0, "Cleaning": 0, "Fishing": 0, "Cooking": 0, "Combat": 0, "Forestry": 0, "Mining": 0, "Smithing": 0}
var inventory := {"seeds": STARTING_SEEDS, "pumpkin_seeds": 0, "crops": 0, "pumpkins": 0, "fish": 0, "eggs": 0, "milk": 0, "fish_meal": 0, "turnip_hash": 0, "smoked_fish": 0, "dried_turnip": 0, "pumpkin_soup": 0, "canned_turnip": 0, "fish_stew": 0, "fermented_turnip": 0, "hearty_stew": 0, "bandage": 0, "firewood": 4}
var materials := {"wood": 0, "sticks": 0, "fiber": 0, "resin": 0, "hardwood": 0, "stone": 0, "copper_ore": 0, "iron_ore": 0, "copper_bar": 0, "iron_bar": 0, "arrows": 0, "bolts": 0}
# The hotbar, in slot order. Slots after these are empty.
const HOTBAR_TOOLS := [
	{"id": "sword", "name": "Weapon", "icon": "sword", "tint": "6b4a3a"},
	{"id": "axe", "name": "Axe", "icon": "axe", "tint": "8a6a3a"},
	{"id": "pick", "name": "Pickaxe", "icon": "pick", "tint": "6b5a4a"},
	{"id": "hoe", "name": "Hoe", "icon": "hoe", "tint": "8a6a3a"},
	{"id": "trowel", "name": "Trowel", "icon": "trowel", "tint": "9a7a4a"},
	{"id": "hose", "name": "Watering hose", "icon": "hose", "tint": "3f6b8a"},
	{"id": "rod", "name": "Fishing pole", "icon": "rod", "tint": "6b5a3a"},
]
const TOOL_LABELS := {"sword": "weapon", "axe": "axe", "pick": "pickaxe", "hoe": "hoe", "trowel": "trowel", "hose": "watering hose", "rod": "fishing pole"}

var tool_tier := {"hatchet": 0, "pick": 0, "rod": 0}     # 0 = none; higher tiers come from TOOL_TIERS
var grove_felled := {}
var quarry := {}                                   # Ashford quarry rocks, village tile -> true
var rocks := {}                                  # world tile -> true for unbroken rocks
var brush_day := 0   # the day the brush and trees were last restored
var rock_day := 0    # the day the rocks were last restored
var stats := {"jobs": 0, "planted": 0, "harvested": 0, "gathered": 0, "slept": 0, "tidied": 0,
	"fished": 0, "caught": 0, "mended": 0, "cleansed": 0, "cooked": 0, "eaten": 0,
	"pumpkins": 0, "collapses": 0, "events": 0, "sold": 0, "spoiled": 0,
	"talks": 0, "defeated": 0, "delivered": 0, "stalkers": 0, "visited": 0, "crops_given": 0, "preserved": 0, "felled": 0, "mined": 0,
	"drank": 0, "watered": 0, "pump": 0, "hose": 0, "rain_days": 0, "events_seen": 0, "goats_bought": 0}
var achievements_done := {}     # achievement id -> true
var quests_done := {}               # quest id -> true
var selected_seed := "turnip"
var lantern_tier := 0               # 0 = none built yet
var house_stage := 0
var tidied_day := 0
var mend_day := 0                   # the day the mend count applies to
var mends_today := 0
var wear := 0                       # house upkeep, 0 to WEAR_MAX
var coop_built := false
var coop_tile := Vector2i(-1, -1)  # map tile of the coop's top-left corner, once built
var barn_built := false
var barn_tile := Vector2i(-1, -1)  # map tile of the barn's top-left corner, once built
var placing := ""                  # "coop" or "barn" while the player chooses where it goes
var placement_ghost: Node2D        # the preview of where the building would stand
var hen_layer: Node2D              # the hens, drawn on their own so they can move without redrawing the farm
var hen_pos: Array = []           # each hen's place in the coop, in tiles from its centre
var hen_goal: Array = []          # where each hen is walking to
var hen_wait: Array = []          # seconds before a hen picks its next spot
var hens := 0
var hen_ages: Array = []          # days old for each hen, kept in step with hens
# The daily job: one delivery a day, rotating through these. Turn the items in for coins and XP.
const JOBS := [
	{"id": "crops", "name": "Deliver crops", "need": {"crops": 3}, "coins": 30, "skill": "Farming", "xp": 12},
	{"id": "fish", "name": "Deliver fish", "need": {"fish": 2}, "coins": 26, "skill": "Fishing", "xp": 12},
	{"id": "wood", "name": "Deliver wood", "need": {"wood": 6}, "coins": 24, "skill": "Forestry", "xp": 12},
	{"id": "stone", "name": "Deliver stone", "need": {"stone": 4}, "coins": 22, "skill": "Mining", "xp": 12},
	{"id": "resin", "name": "Deliver resin", "need": {"resin": 3}, "coins": 20, "skill": "Bushcrafting", "xp": 12},
	{"id": "meals", "name": "Deliver meals", "need": {"fish_meal": 1, "turnip_hash": 1}, "coins": 34, "skill": "Cooking", "xp": 12},
	{"id": "preserved", "name": "Deliver preserves", "need": {"smoked_fish": 1, "dried_turnip": 1}, "coins": 40, "skill": "Cooking", "xp": 16},
]
var job_done_day := -1   # the last day the daily job was turned in

var hens_fed_day := -1              # the last day the hens were fed
var hen_unfed_days := 0
var goat_layer: Node2D              # the goats in the barn yard, drawn on their own layer
var goat_pos: Array = []
var goat_goal: Array = []
var goat_wait: Array = []
var goats := 0
var goat_ages: Array = []         # days old for each goat, kept in step with goats
var goats_fed_day := -1
var goat_unfed_days := 0
var plot_three_open := false
var clean_nights := 0               # nights in a row with every chore done
var cleanse_day := 0
var sanity := SANITY_MAX
var sanity_penalty := 0             # permanent cap reduction from collapsing
var boredom_loss := 0.0             # sanity limit lost to days without a finished desk game
var entertained_day := 0            # the last day a desk game was finished
var desk_game: Dictionary = {}      # the desk game in progress (not saved)
var inside := false                 # standing in the farmhouse interior
var open_tab := ""                  # "" when the action bar panel is closed
var bag: BagPanel                   # the grid bag in the bottom-right corner (Tab or Y)
var wheel: SectionWheel             # the section wheel (Shift or left stick click)
var quest_open := {}              # quest id -> true when its details are open (not saved)
var craft_tab := "gear"             # which Craft sub-tab shows (not saved)
var event_fired_day := 0            # the day the night event last happened
var tonight_shadow := Vector2i(-1, -1)
var shadow_tile := Vector2i.ZERO    # where the field shadow sits
var message_timer := 0.0
var money := 0
var bag_tier := 0               # bag upgrades bought
var cellar_built := false
var cooler_built := false
var smokehouse_built := false
var furnace_built := false
var woodshed_built := false
var firewood_store := 0
var tax_owed := 0                   # property tax owed, 0 when paid up
var tax_due_day := 0                # the day the oldest unpaid bill is due
var tax_stage := 0                  # 0 none sent, 1 overdue reminder sent, 2 final notice sent
var desk_mail: Array = []           # letters on the desk: {"title", "text", "unread"}
var desk_light: PointLight2D        # red light on the desk while post is unread
var fire_hours := 0.0
var shots: Array = []                 # arrows and bolts in flight, not saved
var cellar_stock := 0          # crops in the root cellar
var cooler_stock := 0          # fish in the cooler
var zone: int = Zone.HOMESTEAD
var saved_zone := 0
var hp := BASE_HP
var guardian_done := {}        # guardian quest id -> true
var foes: Array = []           # enemies in the current village, rebuilt on each visit
var swing_cool := 0.0
var swing_time := 0.0
var swing_dir := Vector2.DOWN
var invuln := 0.0
var appearance: Dictionary = Appearance.default_choices()   # the farmer's look, set in the creator
var equipment := {"hand_r": "hoe", "offhand": "", "head": "", "neck": "", "chest": "", "wrist": "", "legs": "", "feet": ""}

# Set by loading, applied once the world exists.
var saved_pos := Vector2.ZERO
var has_saved_pos := false
var saved_inside := false
var saved_panel := ""

var action_bar: ActionBar
var minimap: Minimap
var canvas_modulate: CanvasModulate
var hud_panel: PanelContainer
var hud_clock_panel: PanelContainer
var hud_day_label: Label
var hud_date_label: Label
var hud_time_label: Label
var hud_weather_label: Label
var hud_weather_icon: HudIcon
var hud_hp_label: Label
var hud_sanity_label: Label
var hud_coins_label: Label
var needs_box: HBoxContainer
var food_bar: ProgressBar
var water_bar: ProgressBar
var warmth_bar: ProgressBar
var needs_temp: Label
var message_label: Label
var player    # Node2D with player.gd attached
var camera: Camera2D
# Full-screen fade for sleeping and collapsing. While a scene plays the world is frozen.
var transitioning := false
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var card_label: Label
var shake_tw: Tween
var last_minimap_key: Array = []
var last_cam_tile := Vector2i(-99, -99)   # the tile the camera was last drawn from
var panels: PanelRows
var saver: SaveSystem
var progression: ProgressionSystem
var stall: StallSystem
var sanity_sys: SanitySystem
var firewood: FirewoodSystem
var farm: FarmSystem
var animals: AnimalSystem
var desk: DeskSystem
var lantern_light: PointLight2D
var window_lights: Array = []   # glows for the lit windows, one PointLight2D each
var porch_light: PointLight2D     # the lamp by the door, once the house is restored
var water_fx: Node2D              # the pond's shine, redrawn about 20 times a second
var water_fx_next_ms := 0            # when the shine is next due for a redraw
var perf_label: Label = null         # F3 shows frame and draw stats
var perf_shown := false
var hotbar: Hotbar = null
var active_slot := 3                 # 0-based hotbar slot; 3 is the hoe the farm starts with
var blocking := false                # held block: LT or right click, with a weapon in the weapon slot
var tree_sprites: Dictionary = {}   # "variant:seed" -> Texture2D, filled in once at start
var tree_bake_started := false
var perf_was_down := false


func _ready() -> void:
	panels = PanelRows.new(self)
	desk = DeskSystem.new(self)
	animals = AnimalSystem.new(self)
	farm = FarmSystem.new(self)
	firewood = FirewoodSystem.new(self)
	sanity_sys = SanitySystem.new(self)
	stall = StallSystem.new(self)
	progression = ProgressionSystem.new(self)
	saver = SaveSystem.new(self)
	_setup_input()
	_load_settings()
	_start_music()
	_load_sfx()
	_build_map()
	_generate_world()
	_find_pond_edges()
	save_slot = TitleMenu.active_slot
	# The start screen comes first. The world is built once the player picks Continue, New Game, or a slot.
	title_menu = TitleMenu.new()
	title_menu.settings_rows = panels._settings_rows()
	title_menu.start_requested.connect(_on_title_start)
	title_menu.quit_requested.connect(func() -> void: get_tree().quit())
	add_child(title_menu)


func _save_path() -> String:
	return TitleMenu.slot_path(save_slot)


# The lo-fi loop plays from the start screen on, and can be turned off in Settings. The choice is remembered.
func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
		if typeof(parsed) == TYPE_DICTIONARY:
			music_on = bool(parsed.get("music", true))
			sfx_on = bool(parsed.get("sfx", true))


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"music": music_on, "sfx": sfx_on}))


func _start_music() -> void:
	var stream := load("res://audio/dreary_loop.ogg") as AudioStreamOggVorbis
	stream.loop = true
	music_player = AudioStreamPlayer.new()
	music_player.stream = stream
	music_player.volume_db = -8.0
	add_child(music_player)
	_apply_music()


func _apply_music() -> void:
	if music_on and not music_player.playing:
		music_player.play()
	elif not music_on and music_player.playing:
		music_player.stop()


func _toggle_music() -> void:
	music_on = not music_on
	_save_settings()
	_apply_music()


# Sound effects are short clips in audio/sfx. A small pool plays them, so several can overlap.
const SFX_NAMES := ["step", "plant", "harvest", "water", "eat", "drink", "repair", "coin", "panel", "tick",
	"chime", "bleat", "buzz", "thunder", "door", "strike", "gather"]


func _load_sfx() -> void:
	for name in SFX_NAMES:
		var path := "res://audio/sfx/%s.ogg" % name
		if ResourceLoader.exists(path):
			sfx_streams[name] = load(path)
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)


# Plays one sound effect. A little random pitch keeps repeated sounds from sounding identical.
# Loudness in decibels for each sound. Anything not listed plays at the default.
const SFX_VOLUME := {"step": -24.0}
# Playback pitch for sounds that sound brighter than they should. Below 1.0 is warmer and softer.
const SFX_PITCH := {"step": 0.82}
const SFX_DEFAULT_VOLUME := -4.0


func play_sfx(name: String, jitter: float = 0.0) -> void:
	if not sfx_on or not sfx_streams.has(name) or sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = sfx_players[sfx_next]
	sfx_next = (sfx_next + 1) % sfx_players.size()
	p.stream = sfx_streams[name]
	p.volume_db = float(SFX_VOLUME.get(name, SFX_DEFAULT_VOLUME))
	p.pitch_scale = float(SFX_PITCH.get(name, 1.0)) + randf_range(-jitter, jitter)
	p.play()


func _toggle_sfx() -> void:
	sfx_on = not sfx_on
	_save_settings()
	if sfx_on:
		play_sfx("tick")


# Reloads the scene, which resets everything and shows the start screen. The chosen slot carries over.
func _quit_to_title() -> void:
	_close_panel()
	get_tree().call_deferred("reload_current_scene")


# Starts the world from the start screen: Continue or Load Game read the slot, New Game starts fresh.
func _on_title_start(mode: String, slot: int) -> void:
	save_slot = slot
	TitleMenu.active_slot = slot
	var loaded := mode != "new" and saver._load_game()
	if not loaded:
		_respawn_brush()
		appearance = Appearance.clean(TitleMenu.pending_appearance)
	_build_interior()
	_build_world()
	_build_hud()
	_build_fade()
	_build_bag()
	_build_wheel()
	_build_tip_panel()
	weather = WeatherScript.new()
	add_child(weather)
	if weather_kind == "":
		_roll_weather()
	_apply_weather()
	_build_action_bar()
	_build_ambience()
	_build_crows()
	_update_shadow_tile()
	if loaded:
		_restore_saved_state()
		_show_message("Welcome back. Day %d." % day)
	else:
		_show_message("A new season begins. Day 1. %s." % WEATHER_NAMES.get(weather_kind, "Overcast"))
	world_started = true
	title_menu.queue_free()
	title_menu = null


func _process(delta: float) -> void:
	# F3 toggles the performance readout, even while a menu is open.
	var f3_down := Input.is_physical_key_pressed(KEY_F3)
	if f3_down and not perf_was_down:
		perf_shown = not perf_shown
		perf_label.visible = perf_shown
	perf_was_down = f3_down
	if perf_shown:
		_update_perf()
	if not world_started:
		return
	if transitioning:
		return
	if not tree_bake_started:
		tree_bake_started = true
		_bake_tree_sprites()
	if not in_cave and not _in_village():
		var cam := camera.get_screen_center_position()
		var cam_tile := Vector2i(floori(cam.x / PX), floori(cam.y / PX))
		if cam_tile != last_cam_tile:
			last_cam_tile = cam_tile
			queue_redraw()
	if weather != null:
		weather.visible = not inside and not in_cave
	# Any open menu pauses the day: the clock stops, foes stand still, and only the menu responds.
	player.paused = open_tab != "" or _bag_open() or _wheel_open()
	# The bag's corner button only shows when no section or wheel covers the farm.
	if bag != null:
		bag.toggle_button.visible = open_tab == "" and not _wheel_open()
	placement_ghost.visible = placing != ""
	if placing != "":
		placement_ghost.queue_redraw()
	if hotbar != null:
		hotbar.set_state(_hotbar_entries(), active_slot)
	player.held = _active_tool()
	player.held_item = str(equipment["hand_r"]) if _active_tool() == "sword" else ""
	player.set_loop(_loop_action())
	if player.paused:
		_handle_keys()
		_refresh_panel()
		if _bag_open():
			bag.set_items(_bag_items())
		return
	blocking = Input.is_action_pressed("block") and _active_tool() == "sword" and _has_weapon()
	player.blocking = blocking
	# Scrolling runs through the tools only; the number keys can still reach any slot.
	var slot_before := active_slot
	if Input.is_action_just_pressed("hotbar_next"):
		active_slot = posmod(active_slot + 1, HOTBAR_TOOLS.size())
	if Input.is_action_just_pressed("hotbar_prev"):
		active_slot = posmod(active_slot - 1, HOTBAR_TOOLS.size())
	for i in Hotbar.SLOT_COUNT:
		if Input.is_action_just_pressed("slot_%d" % (i + 1)):
			active_slot = i
	if active_slot != slot_before:
		progression._bump("tool_switches")
	# Walking counts each step to a neighbouring tile. Jumps such as sleeping or going inside don't count.
	var walk_tile := _player_tile()
	if last_walk_tile != NO_SPOT and walk_tile != last_walk_tile and absi(walk_tile.x - last_walk_tile.x) + absi(walk_tile.y - last_walk_tile.y) == 1:
		progression._bump("walked")
	last_walk_tile = walk_tile
	_update_tips(delta)
	clock += delta
	_update_hens(delta)
	_update_goats(delta)
	desk._update_desk_light()
	current_hour = START_HOUR + clock / DAY_LENGTH * (DAY_END_HOUR - START_HOUR)
	_update_needs(delta * (DAY_END_HOUR - START_HOUR) / DAY_LENGTH)

	if current_hour >= DAY_END_HOUR:
		_collapse()
		return

	if current_hour >= EVENT_HOUR and event_fired_day != day:
		sanity_sys._trigger_night_event()

	var darkness := smoothstep(DUSK_HOUR, DUSK_HOUR + 2.0, current_hour)
	darkness *= 1.0 - sanity_sys._night_relief()
	darkness = clampf(darkness + sanity_sys._low_sanity_boost(), 0.0, 1.0)
	canvas_modulate.color = _light_tint().lerp(NIGHT_TINT, darkness)
	_update_lantern(darkness)
	sanity_sys._update_sanity(darkness, delta)

	_check_doors()
	farm._check_unlocks()
	progression._check_story()
	progression._check_achievements()
	_check_guardian()
	_update_fish_spots(delta)
	_update_fishing(delta)
	farm._update_harvest(delta)
	_update_crows(delta)
	_update_foes(delta)
	_update_shots(delta)
	_update_region()
	if _in_village() and current_hour >= STALL_CLOSE_HOUR and not _at_campsite():
		_go_home("Night falls. You are driven back to the homestead.")
	fish_layer.visible = zone == Zone.HOMESTEAD

	var minutes := int(fmod(current_hour, 1.0) * 60.0)
	var low := food < 25.0 or water < 25.0 or warmth < 25.0
	food_bar.value = food
	water_bar.value = water
	warmth_bar.value = warmth
	for bar in [food_bar, water_bar, warmth_bar]:
		bar.modulate = Color(1.0, 0.55, 0.5) if low and bar.value < 25.0 else Color.WHITE
	needs_temp.text = "%d°F" % roundi(_temperature())
	var date := _calendar_date(day)
	var event_name := ""
	for ev in sanity_sys._active_events():
		event_name = " · %s" % ev["title"]
		break
	hud_day_label.text = "Day %d" % day
	hud_date_label.text = "%s %d · %s%s" % [MONTH_NAMES[date["month"]].substr(0, 3), date["day"], _season_of(date["month"]), event_name]
	hud_time_label.text = "%02d:%02d" % [int(fmod(current_hour, 24.0)), minutes]
	hud_weather_label.text = WEATHER_NAMES.get(weather_kind, "Overcast")
	hud_weather_icon.kind = "sun" if weather_kind == "sunny" else ("rain" if weather_kind in WATER_RAIN_KINDS else "cloud")
	hud_weather_icon.queue_redraw()
	hud_hp_label.text = "%d / %d" % [hp, max_hp()]
	hud_sanity_label.text = "%d / %d" % [int(sanity), sanity_sys._sanity_max()]
	hud_coins_label.text = "%d" % money

	_handle_keys()

	# With no panel open, a leftover focused button would take the gamepad's A press instead of
	# the farm. Dropping that focus lets A reach the use action.
	if open_tab == "" and not _bag_open() and not _wheel_open() and get_viewport().gui_get_focus_owner() != null:
		get_viewport().gui_release_focus()
	# Farming and gathering pause while a panel is open (the day is already paused above).
	# With the trowel in hand, the D-pad up and down, or Z and X, cycle the seed you plant.
	var trowel_out := open_tab == "" and not _bag_open() and not _wheel_open() and _active_tool() == "trowel"
	if player:
		player.vertical_locked = trowel_out
	if trowel_out:
		if Input.is_action_just_pressed("seed_next"):
			farm._cycle_seed(1)
		elif Input.is_action_just_pressed("seed_prev"):
			farm._cycle_seed(-1)
	var tool_pressed := Input.is_action_just_pressed("tool_use")
	var hand_pressed := Input.is_action_just_pressed("use")
	if (tool_pressed or hand_pressed) and open_tab == "" and not _bag_open() and not _wheel_open() and not _pointer_on_ui():
		_tool_press = tool_pressed
		if tool_pressed:
			_play_use_anim()
		_interact()
		_tool_press = false

	if open_tab != "":
		_refresh_panel()

	_update_minimap()
	_update_ambience()

	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""


func _draw() -> void:
	if not world_started:
		return
	if in_cave:
		_draw_cave()
		return
	if _in_village():
		_draw_world()
		return
	var view := get_viewport_rect().size / camera.zoom
	var top_left := camera.get_screen_center_position() - view * 0.5
	var view_left := top_left.x
	var fx0 := clampi(floori(top_left.x / PX) - 1, 0, MAP_W - 1)
	var fy0 := clampi(floori(top_left.y / PX) - 1, 0, MAP_H - 1)
	var fx1 := clampi(ceili((top_left.x + view.x) / PX) + 1, 0, MAP_W - 1)
	var fy1 := clampi(ceili((top_left.y + view.y) / PX) + 1, 0, MAP_H - 1)
	# Pass one: the ground, with small details. Pass two: shadows, which fall on the ground only.
	# Pass three: trees and buildings, drawn over both.
	for y in range(fy0, fy1 + 1):
		for x in range(fx0, fx1 + 1):
			var ground: int = map[y][x]
			if _is_ground(ground):
				var gcell := _tile_rect(Vector2i(x, y))
				draw_rect(gcell, _ground_color(TILE_COLORS[ground], x, y))
				_draw_ground_detail(gcell, ground, x, y)
				if grove_felled.has(Vector2i(x, y)):
					FarmArt.draw_stump(self, gcell)
	for y in range(fy0, fy1 + 1):
		for x in range(fx0, fx1 + 1):
			if map[y][x] == Tile.TREE and not _in_big_tree(Vector2i(x, y)):
				var scell := _tile_rect(Vector2i(x, y))
				draw_colored_polygon(_ellipse_at(scell.get_center() + Vector2(PX * 0.2, PX * 0.26), PX * 0.42, PX * 0.2), Color(0, 0, 0, 0.26))
	for y in range(fy0, fy1 + 1):
		for x in range(fx0, fx1 + 1):
			var tile: int = map[y][x]
			var cell := _tile_rect(Vector2i(x, y))
			if _is_ground(tile):
				continue
			if tile == Tile.TREE and _in_big_tree(Vector2i(x, y)):
				# The great tree's footprint is plain grass; its shadow and crown are drawn on top later.
				draw_rect(cell, _ground_color(TILE_COLORS[Tile.GRASS], x, y))
			elif tile == Tile.TREE:
				FarmArt.draw_tree_floor(self, cell, FarmArt.hash_int(x, y, 8))
				_draw_tree_tile(cell, x, y)
			elif tile == Tile.WALL:
				FarmArt.draw_wall_tile(self, cell, y == WORKSHOP_RECT.position.y + BORDER_Y)
			elif tile == Tile.COOP:
				FarmArt.draw_gable_tile(self, cell, Vector2i(x, y) - coop_tile, Vector2i(COOP_SIZE, COOP_SIZE), COOP_ROOF, COOP_WALL, "coop")
			elif tile == Tile.BARN:
				FarmArt.draw_gable_tile(self, cell, Vector2i(x, y) - barn_tile, _footprint("barn"), BARN_ROOF, BARN_WALL, "barn")
			elif tile == Tile.WELL:
				FarmArt.draw_well(self, cell, well_repaired)
			elif tile == Tile.CELLAR:
				FarmArt.draw_cellar(self, cell)
			elif tile == Tile.SMOKEHOUSE:
				FarmArt.draw_smokehouse(self, cell)
			elif tile == Tile.FURNACE:
				FarmArt.draw_furnace(self, cell)
			elif tile == Tile.WOODSTORE:
				FarmArt.draw_woodstore(self, cell)
			elif tile == Tile.CHOPLOG:
				FarmArt.draw_chopping_log(self, cell)
			elif tile == Tile.PORCH:
				FarmArt.draw_porch_tile(self, cell, Vector2i(x, y) - _world_tile(PORCH_RECT.position.x, PORCH_RECT.position.y), PORCH_RECT.size, house_stage)
			elif tile == Tile.STALL:
				FarmArt.draw_stall(self, cell)
			elif tile == Tile.WATER:
				FarmArt.draw_water_tile(self, cell, Vector2i(x, y), _land_mask(x, y))
			elif tile == Tile.FLOOR:
				_draw_floor_tile(cell, Vector2i(x, y))
			else:
				draw_rect(cell, TILE_COLORS[tile])
			if tile == Tile.CELLAR or tile == Tile.COOLER or tile == Tile.SMOKEHOUSE or tile == Tile.FURNACE:
				draw_rect(cell, Color(1, 1, 1, 0.8), false, 2.0)
				var label := _storage_label(tile)
				# Pinned to the visible edge, so a store at the screen's edge still shows its name.
				var label_x := maxf(cell.position.x + 2, view_left + 6)
				draw_string(ThemeDB.fallback_font, Vector2(label_x, cell.position.y + PX * 0.6), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.05, 0.03, 0.02))

	# The great tree goes last, so its crown is never painted over by the ground around it.
	_draw_big_tree()
	for y in INT_H:
		for x in INT_W:
			var kind: int = interior[y][x]
			var cell := _tile_rect(INT_ORIGIN + Vector2i(x, y))
			_draw_interior_tile(cell, Vector2i(x, y), kind)
			# Furniture is labeled in the house so it's easy to tell apart.
			if kind == Tile.BED or kind == Tile.STATION or kind == Tile.DESK:
				var furniture := "Bed" if kind == Tile.BED else ("Cleaning" if kind == Tile.STATION else "Desk")
				draw_string(ThemeDB.fallback_font, cell.position + Vector2(2, PX * 0.6), furniture, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.9, 0.78))
			# Storage is labeled so it's easy to find.
			if kind == Tile.COOLER or kind == Tile.CELLAR:
				draw_rect(cell, Color(1, 1, 1, 0.8), false, 2.0)
				var label := "Cooler" if kind == Tile.COOLER else "Cellar"
				draw_string(ThemeDB.fallback_font, cell.position + Vector2(2, PX * 0.6), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.05, 0.03, 0.02))

	for pos in crops:
		var crop: Dictionary = crops[pos]
		var stage: int = crop["stage"]
		var center := _tile_center(pos.x, pos.y)
		var watered_now := int(crop.get("watered_day", 0)) == day
		FarmArt.draw_crop(self, center, PX, str(crop["kind"]), stage, watered_now)

	for pos in rocks:
		FarmArt.draw_rock(self, _tile_center(pos.x, pos.y), PX * 0.3, FarmArt.hash_int(pos.x, pos.y, 4))
	for pos in brush:
		FarmArt.draw_brush(self, _tile_center(pos.x, pos.y), FarmArt.hash_int(pos.x, pos.y, 6))

	_draw_house()

	if tonight_shadow.x >= 0:
		var s := _tile_center(tonight_shadow.x, tonight_shadow.y)
		draw_circle(s, PX * 0.6, Color(0.02, 0.01, 0.05, 0.9))
		draw_circle(s + Vector2(-8, -6), 3, Color(0.9, 0.1, 0.1))
		draw_circle(s + Vector2(8, -6), 3, Color(0.9, 0.1, 0.1))


# Ground is the tiles drawn flat with detail on top: grass, soil, path, fallow ground, and water.
func _is_ground(tile: int) -> bool:
	return tile == Tile.GRASS or tile == Tile.SOIL or tile == Tile.PATH or tile == Tile.FALLOW


# A stable pseudo-random number for a tile, so the ground looks the same every time it is drawn.
func _tile_hash(x: int, y: int, salt: int) -> int:
	var h: int = (x * 73856093) ^ (y * 19349663) ^ (salt * 83492791)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h)


func _ground_color(base: Color, x: int, y: int) -> Color:
	var jitter := float(_tile_hash(x, y, 1) % 5 - 2) / 100.0
	return Color(base.r + jitter, base.g + jitter * 1.2, base.b + jitter * 0.6)


# Small marks on the ground: grass tufts, pebbles on the path, furrows in the soil.
func _draw_ground_detail(cell: Rect2, tile: int, x: int, y: int) -> void:
	var count := 2 + _tile_hash(x, y, 2) % 3
	for i in count:
		var h := _tile_hash(x, y, 10 + i)
		var at := cell.position + Vector2(float(h % 40) / 40.0, float((h / 40) % 40) / 40.0) * PX
		if tile == Tile.GRASS:
			var dark := Color(0.16, 0.34, 0.14, 0.6)
			var light := Color(0.78, 0.92, 0.56, 0.3)
			var tuft := dark if i % 2 == 0 else light
			draw_line(at, at + Vector2(-2, -5), tuft, 1.2)
			draw_line(at, at + Vector2(0, -6), tuft, 1.2)
			draw_line(at, at + Vector2(2, -5), tuft, 1.2)
		elif tile == Tile.PATH:
			var r := 1.2 + float(h % 3) * 0.6
			draw_circle(at, r + 0.6, Color(0.36, 0.27, 0.16, 0.5))
			draw_circle(at + Vector2(-0.5, -0.5), r, Color(0.9, 0.82, 0.62, 0.7))
		elif tile == Tile.SOIL or tile == Tile.FALLOW:
			var span := 6.0 + float(h % 5)
			draw_line(at, at + Vector2(span, 0), Color(0.3, 0.19, 0.1, 0.45), 1.4)


func _ellipse_at(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(20):
		var a := TAU * float(i) / 20.0
		out.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return out


# Drifting leaves, petals, and fireflies that follow the camera. Each one is on only in its season.
var leaves_fx: CPUParticles2D
var petals_fx: CPUParticles2D
var fireflies_fx: CPUParticles2D


func _build_ambience() -> void:
	var dot_gradient := Gradient.new()
	dot_gradient.set_color(0, Color(1, 1, 1, 1))
	dot_gradient.set_color(1, Color(1, 1, 1, 0))
	# Leaves are stretched soft ovals, petals are round, and fireflies are small bright dots.
	var leaf := _soft_dot(dot_gradient, 16, 8)
	var petal := _soft_dot(dot_gradient, 8, 8)
	var dot := _soft_dot(dot_gradient, 12, 12)
	leaves_fx = _make_ambience(leaf, Color(0.86, 0.5, 0.2), 2.4, 0.95, Vector2(0, 26), 26.0, 5.0)
	leaves_fx.amount = 46
	petals_fx = _make_ambience(petal, Color(1.0, 0.82, 0.88), 1.9, 0.9, Vector2(0, 14), 16.0, 4.0)
	petals_fx.amount = 40
	# Fireflies are bright dots that blink on and off as they drift.
	fireflies_fx = _make_ambience(dot, Color(0.85, 1.0, 0.45), 1.3, 1.0, Vector2.ZERO, 10.0, 6.0)
	fireflies_fx.spread = 180.0
	fireflies_fx.amount = 34
	fireflies_fx.lifetime = 6.0
	var blink := Gradient.new()
	blink.set_color(0, Color(1, 1, 1, 0.0))
	blink.add_point(0.25, Color(1, 1, 1, 1.0))
	blink.add_point(0.45, Color(1, 1, 1, 0.1))
	blink.add_point(0.7, Color(1, 1, 1, 1.0))
	blink.set_color(blink.get_point_count() - 1, Color(1, 1, 1, 0.0))
	fireflies_fx.color_ramp = blink
	_build_window_lights()
	_build_desk_light()
	water_fx = Node2D.new()
	water_fx.draw.connect(_draw_water_shimmer)
	add_child(water_fx)


func _soft_dot(gradient: Gradient, width: int, height: int) -> Texture2D:
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = width
	tex.height = height
	return tex


func _make_ambience(dot: Texture2D, color: Color, scale_px: float, alpha: float, gravity: Vector2, speed: float, life: float) -> CPUParticles2D:
	var fx := CPUParticles2D.new()
	fx.texture = dot
	fx.angle_min = 0.0
	fx.angle_max = 360.0
	fx.angular_velocity_min = -120.0
	fx.angular_velocity_max = 120.0
	fx.amount = 22
	fx.lifetime = life
	fx.emitting = false
	fx.local_coords = false
	fx.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fx.emission_rect_extents = Vector2(400, 300)
	fx.direction = Vector2(0, 1)
	fx.spread = 25.0
	fx.gravity = gravity
	fx.initial_velocity_min = speed * 0.5
	fx.initial_velocity_max = speed
	fx.scale_amount_min = scale_px * 0.7
	fx.scale_amount_max = scale_px * 1.3
	fx.color = Color(color.r, color.g, color.b, alpha)
	fx.z_index = 2
	add_child(fx)
	return fx


func _update_ambience() -> void:
	if leaves_fx == null:
		return
	var on_farm := not inside and not in_cave and not _in_village() and world_started
	var season := _season_of(_calendar_date(day)["month"])
	var view := get_viewport_rect().size / camera.zoom
	var centre := camera.get_screen_center_position()
	for fx in [leaves_fx, petals_fx, fireflies_fx]:
		fx.global_position = centre
		fx.emission_rect_extents = view * 0.5 + Vector2(60, 60)
	leaves_fx.emitting = on_farm and season == "Autumn"
	petals_fx.emitting = on_farm and season == "Spring"
	fireflies_fx.emitting = on_farm and season == "Summer" and current_hour >= DUSK_HOUR
	water_fx.visible = on_farm
	var now := Time.get_ticks_msec()
	if on_farm and now >= water_fx_next_ms:
		water_fx_next_ms = now + 50
		water_fx.queue_redraw()


func _draw_house() -> void:
	var origin := _world_tile(HOUSE_IX, HOUSE_IY)
	var rect := Rect2(Vector2(origin) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	FarmArt.draw_house(self, rect, house_stage, HOUSE_WALLS[house_stage], HOUSE_ROOFS[house_stage])


# --- Setup -------------------------------------------------------------------

func _setup_input() -> void:
	# Keyboard, with gamepad bindings alongside each action.
	_ensure_action("move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_ensure_action("move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_ensure_action("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	for move in ["move_up", "move_down", "move_left", "move_right"]:
		InputMap.action_set_deadzone(move, 0.3)
	# Space or A does everything that isn't a tool or weapon action: panels, talking, sleeping, sticks, the pond.
	_ensure_action("use", [KEY_SPACE], [JOY_BUTTON_A])
	# RT or a left click uses the tool or weapon in hand: hoe, hose, trowel, axe, pick, rod, sword, and bow.
	_ensure_action("tool_use", [], [], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_add_mouse("tool_use", MOUSE_BUTTON_LEFT)
	_ensure_action("block", [], [], [[JOY_AXIS_TRIGGER_LEFT, 1.0]])
	_add_mouse("block", MOUSE_BUTTON_RIGHT)
	# Z and X step through the seeds while the trowel is in hand, as the D-pad does on a controller.
	# The D-pad only, so the left stick never changes seeds. Z and X do the same on the keyboard.
	_ensure_action("seed_prev", [KEY_Z], [JOY_BUTTON_DPAD_UP])
	_ensure_action("seed_next", [KEY_X], [JOY_BUTTON_DPAD_DOWN])
	_ensure_action("hotbar_prev", [], [JOY_BUTTON_LEFT_SHOULDER])
	_add_mouse("hotbar_prev", MOUSE_BUTTON_WHEEL_UP)
	_ensure_action("hotbar_next", [], [JOY_BUTTON_RIGHT_SHOULDER])
	_add_mouse("hotbar_next", MOUSE_BUTTON_WHEEL_DOWN)
	for i in 10:
		_ensure_action("slot_%d" % (i + 1), [KEY_1 + i if i < 9 else KEY_0])
	# Menus move focus and press buttons through the ui_ actions, so the gamepad needs them too.
	_ensure_action("ui_up", [], [JOY_BUTTON_DPAD_UP], [[JOY_AXIS_LEFT_Y, -1.0]])
	_ensure_action("ui_down", [], [JOY_BUTTON_DPAD_DOWN], [[JOY_AXIS_LEFT_Y, 1.0]])
	_ensure_action("ui_left", [], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_ensure_action("ui_right", [], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_ensure_action("ui_accept", [], [JOY_BUTTON_A])
	_ensure_action("ui_cancel", [], [JOY_BUTTON_B])
	# Tab or Y opens the bag, which also holds the way into the Inventory.
	_ensure_action("bag", [KEY_TAB], [JOY_BUTTON_Y])
	# Shift or a click on the left stick opens the section wheel: Skills, Gear, Craft, Quests, House,
	# Buildings and Achievements.
	_ensure_action("wheel", [KEY_SHIFT], [JOY_BUTTON_LEFT_STICK])
	_ensure_action("settings", [KEY_ESCAPE], [JOY_BUTTON_START])
	_ensure_action("close_panel", [], [JOY_BUTTON_B])


# Adds keys, gamepad buttons, and stick directions to an action. Each axis entry
# is [axis, direction], where direction is -1.0 or 1.0 along that axis.
# Mouse buttons and wheel steps for an action.
func _add_mouse(action: String, button: int) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)


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


# The pond: an uneven lake. Its edge wobbles a little from tile to tile.
func _in_lake(ix: int, iy: int) -> bool:
	var dx: float = (float(ix) - LAKE_CENTRE.x) / LAKE_RADIUS.x
	var dy: float = (float(iy) - LAKE_CENTRE.y) / LAKE_RADIUS.y
	var wobble: float = float(FarmArt.hash_int(ix, iy, 9) % 100) / 100.0 * 0.3 - 0.15
	return dx * dx + dy * dy < 1.0 + wobble


# Which sides of a pond tile touch land: 1 north, 2 east, 4 south, 8 west.
func _land_mask(x: int, y: int) -> int:
	var mask := 0
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	for i in 4:
		var n: Vector2i = Vector2i(x, y) + dirs[i]
		if n.x >= 0 and n.y >= 0 and n.x < MAP_W and n.y < MAP_H and map[n.y][n.x] != Tile.WATER:
			mask |= 1 << i
	return mask


# Which tree art to draw: 0 an oak, 1 a willow, 2 a dead tree.
func _tree_variant(tile: Vector2i) -> int:
	var ix := tile - Vector2i(BORDER_X, BORDER_Y)
	if DEAD_TREES.has(ix):
		return 2
	if WILLOW_TREES.has(ix):
		return 1
	return 0


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
				if iy == INNER_H / 2 or YARD_PATH.has(Vector2i(ix, iy)):
					t = Tile.PATH
				if PLOT_ONE.has_point(Vector2i(ix, iy)):
					t = Tile.SOIL
				if PLOT_TWO.has_point(Vector2i(ix, iy)):
					t = Tile.FALLOW   # cleared once Farming reaches level 2
				if PLOT_THREE.has_point(Vector2i(ix, iy)):
					t = Tile.FALLOW   # cleared once Farming 4 and a Patched house
				if _in_lake(ix, iy):
					t = Tile.WATER
				if ix >= HOUSE_IX and ix < HOUSE_IX + HOUSE_W and iy >= HOUSE_IY and iy < HOUSE_IY + HOUSE_H:
					t = Tile.HOUSE
				if PORCH_RECT.has_point(Vector2i(ix, iy)):
					t = Tile.PORCH
				if WORLD_ENABLED and ix == INNER_W - 1 and iy == INNER_H / 2:
					t = Tile.PORTAL
				if ix == 0 and iy == INNER_H / 2:
					t = Tile.CAVE_MOUTH
				if ix == STALL_IX and iy == STALL_IY:
					t = Tile.STALL
				if ix == HOUSE_DOOR_IX and iy == HOUSE_DOOR_IY:
					t = Tile.DOOR
				if GROVE_SPOTS.has(Vector2i(ix, iy)):
					t = Tile.TREE
				if _in_big_tree(Vector2i(ix + BORDER_X, iy + BORDER_Y)):
					t = Tile.TREE
				if Vector2i(ix, iy) == WELL_IX:
					t = Tile.WELL
			row.append(t)
		map.append(row)


# The interior is a fixed layout. Rooms open up as the house is repaired.
# The cellar and workshop are farm tiles beside the house, so they show on the map.
func _apply_storage_tiles() -> void:
	if cellar_built:
		map[CELLAR_IX.y + BORDER_Y][CELLAR_IX.x + BORDER_X] = Tile.CELLAR
	if smokehouse_built or furnace_built:
		_stamp_workshop()
	if smokehouse_built:
		map[SMOKEHOUSE_IX.y + BORDER_Y][SMOKEHOUSE_IX.x + BORDER_X] = Tile.SMOKEHOUSE
	if furnace_built:
		map[FURNACE_IX.y + BORDER_Y][FURNACE_IX.x + BORDER_X] = Tile.FURNACE
	if woodshed_built:
		map[WOODSTORE_IX.y + BORDER_Y][WOODSTORE_IX.x + BORDER_X] = Tile.WOODSTORE
		map[CHOPLOG_IX.y + BORDER_Y][CHOPLOG_IX.x + BORDER_X] = Tile.CHOPLOG
	if coop_built and coop_tile.x >= 0:
		_stamp_footprint(coop_tile, _footprint("coop"), Tile.COOP)
	if barn_built and barn_tile.x >= 0:
		_stamp_footprint(barn_tile, _footprint("barn"), Tile.BARN)
	queue_redraw()


# Walls around the workshop footprint, with a floor inside and a door on the south side.
func _stamp_workshop() -> void:
	var r := WORKSHOP_RECT
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			var edge := x == r.position.x or x == r.end.x - 1 or y == r.position.y or y == r.end.y - 1
			map[y + BORDER_Y][x + BORDER_X] = Tile.WALL if edge else Tile.FLOOR
	# A plain opening. DOOR is reserved for the farmhouse, so stepping here doesn't take you indoors.
	map[WORKSHOP_DOOR.y + BORDER_Y][WORKSHOP_DOOR.x + BORDER_X] = Tile.PATH


# Sets a building's footprint, from its top-left map tile, to the given tile.
func _stamp_footprint(top: Vector2i, size: Vector2i, kind: int) -> void:
	for dy in size.y:
		for dx in size.x:
			map[top.y + dy][top.x + dx] = kind


func _build_interior() -> void:
	_apply_storage_tiles()
	interior = []
	for y in INT_H:
		var row: Array = []
		for x in INT_W:
			row.append(Tile.WALL)
		interior.append(row)

	_fill_interior(1, 5, 12, 7, Tile.FLOOR)   # the hall, always open
	_set_interior(FIREPLACE_IX.x, FIREPLACE_IX.y, Tile.FIREPLACE)
	for t in TABLE_TILES:
		_set_interior(t.x, t.y, Tile.TABLE)
	_set_interior(6, 8, Tile.EXIT)            # back out to the farm
	if cooler_built:
		_set_interior(COOLER_INTERIOR.x, COOLER_INTERIOR.y, Tile.COOLER)

	# The bedroom and its bed are open from the start.
	_fill_interior(1, 1, 4, 4, Tile.FLOOR)
	_set_interior(BED_INTERIOR.x, BED_INTERIOR.y, Tile.BED)
	if house_stage >= 2:
		_fill_interior(9, 1, 12, 4, Tile.FLOOR)
		_set_interior(11, 1, Tile.STATION)
	_set_interior(DESK_IX.x, DESK_IX.y, Tile.DESK)   # the desk is in the bedroom from the start, for the post
	if house_stage >= 3:
		_fill_interior(5, 1, 8, 4, Tile.FLOOR)


func _fill_interior(x0: int, y0: int, x1: int, y1: int, kind: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			interior[y][x] = kind


func _set_interior(x: int, y: int, kind: int) -> void:
	interior[y][x] = kind


# A new game lays out the brush, trees, and rocks in their places.
func _respawn_brush() -> void:
	_fill_brush()
	_fill_rocks()
	_fill_quarry()
	brush_day = day
	rock_day = day
	queue_redraw()


# Brush and trees grow back once a week, and rocks once a month. The quarry refills each morning.
func _regrow_wild() -> void:
	_fill_quarry()
	if day - brush_day >= BRUSH_REGROW_DAYS:
		_fill_brush()
		brush_day = day
	if day - rock_day >= ROCK_REGROW_DAYS:
		_fill_rocks(true)
		rock_day = day
	queue_redraw()


func _fill_brush() -> void:
	brush.clear()
	for spot in BRUSH_SPOTS:
		brush[_world_tile(spot.x, spot.y)] = true
	if progression._level("Bushcrafting") >= THICKET_LEVEL:
		for spot in THICKET_SPOTS:
			brush[_world_tile(spot.x, spot.y)] = true
	grove_felled.clear()
	_apply_grove()


func _build_world() -> void:
	# The fishing spots are drawn on their own layer, under the player.
	fish_layer = Node2D.new()
	fish_layer.draw.connect(_draw_fish_spots)
	add_child(fish_layer)
	placement_ghost = Node2D.new()
	placement_ghost.draw.connect(_draw_placement_ghost)
	placement_ghost.visible = false
	add_child(placement_ghost)
	hen_layer = Node2D.new()
	hen_layer.draw.connect(_draw_hen_layer)
	hen_layer.visible = false
	add_child(hen_layer)
	goat_layer = Node2D.new()
	goat_layer.draw.connect(_draw_goat_layer)
	goat_layer.visible = false
	add_child(goat_layer)

	player = Node2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.position = _tile_center(BORDER_X + INNER_W / 2, BORDER_Y + INNER_H / 2)
	player.is_blocked = _is_blocked_world
	player.stepped.connect(func() -> void: play_sfx("step", 0.03))
	add_child(player)
	player.apply_appearance(appearance)
	_build_lantern_light()

	camera = Camera2D.new()
	camera.enabled = true
	player.add_child(camera)
	_set_bounds()

	canvas_modulate = CanvasModulate.new()
	add_child(canvas_modulate)


# A soft white-to-black radial gradient. Used as the falloff for every light on the farm.
func _glow_texture() -> GradientTexture2D:
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
	return texture


# One warm light for each window, and a lamp by the door. They come on at dusk once the house has glass.
func _build_window_lights() -> void:
	var house := Rect2(Vector2(_world_tile(HOUSE_IX, HOUSE_IY)) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	var texture := _glow_texture()
	for w in FarmArt.window_rects(house):
		var light := PointLight2D.new()
		light.texture = texture
		light.color = Color("ffc878")
		light.texture_scale = 0.9
		light.position = w.get_center()
		light.enabled = false
		add_child(light)
		window_lights.append(light)
	porch_light = PointLight2D.new()
	porch_light.texture = texture
	porch_light.color = Color("ffd27a")
	porch_light.texture_scale = 0.6
	porch_light.position = Vector2(_world_tile(HOUSE_DOOR_IX, HOUSE_DOOR_IY)) * PX + Vector2(PX * 0.5, PX * 0.5)
	porch_light.enabled = false
	add_child(porch_light)


# The pond's shine, drawn every frame while on the farm.
func _draw_water_shimmer() -> void:
	if not world_started or inside or in_cave or _in_village():
		return
	var view := get_viewport_rect().size / camera.zoom
	var top_left := camera.get_screen_center_position() - view * 0.5
	var fx0 := clampi(floori(top_left.x / PX) - 1, 0, MAP_W - 1)
	var fy0 := clampi(floori(top_left.y / PX) - 1, 0, MAP_H - 1)
	var fx1 := clampi(ceili((top_left.x + view.x) / PX) + 1, 0, MAP_W - 1)
	var fy1 := clampi(ceili((top_left.y + view.y) / PX) + 1, 0, MAP_H - 1)
	var water_tiles: Array = []
	for y in range(fy0, fy1 + 1):
		for x in range(fx0, fx1 + 1):
			if map[y][x] == Tile.WATER:
				water_tiles.append(Vector2i(x, y))
	# Clear weather shows the sun by day and the moon by night. Rain sends rings across the surface.
	var sky := 0
	if weather_kind == "sunny":
		sky = 2 if current_hour >= DUSK_HOUR else 1
	var focus := Vector2(LAKE_CENTRE.x + BORDER_X, LAKE_CENTRE.y + BORDER_Y)
	FarmArt.draw_water_shimmer(water_fx, water_tiles, Time.get_ticks_msec() * 0.001, sky, weather_kind in WATER_RAIN_KINDS, focus)
	var centres: Array = []
	for pos in crops:
		if int(crops[pos].get("watered_day", 0)) == day:
			centres.append(_tile_center(pos.x, pos.y))
	FarmArt.draw_crop_shimmer(water_fx, centres, PX, Time.get_ticks_msec() * 0.001)


func _build_lantern_light() -> void:
	# A soft white-to-black radial gradient, tinted warm. Its size follows the lantern tier.
	var texture := _glow_texture()

	lantern_light = PointLight2D.new()
	lantern_light.texture = texture
	lantern_light.color = Color("ffd38a")
	lantern_light.energy = LANTERN_ENERGY
	lantern_light.enabled = false
	player.add_child(lantern_light)
	_apply_lantern_radius()


func _build_hud() -> void:
	# The colour pass sits under the HUD and menus, so only the world is graded.
	var grade_layer := CanvasLayer.new()
	grade_layer.layer = 0
	add_child(grade_layer)
	var grade := ColorRect.new()
	grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grade.material = ShaderMaterial.new()
	grade.material.shader = load("res://shaders/grade.gdshader")
	grade_layer.add_child(grade)

	var layer := CanvasLayer.new()
	add_child(layer)
	# A full-screen root gives the HUD a screen to anchor to. It ignores the mouse.
	var hud_root := Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud_root)

	perf_label = _make_label(hud_root, Vector2(16, 120), 14)
	perf_label.visible = false
	# Two compact plates. The vitals and needs sit top-left; the date, clock, weather and
	# temperature sit in a slim strip across the top middle, clear of the minimap.
	hud_panel = PanelContainer.new()
	hud_panel.position = Vector2(12, 10)
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_panel.add_theme_stylebox_override("panel", _hud_box())
	hud_root.add_child(hud_panel)
	var pad := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		pad.add_theme_constant_override(side, 8)
	hud_panel.add_child(pad)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5)
	pad.add_child(stack)

	var vitals := HBoxContainer.new()
	vitals.add_theme_constant_override("separation", 14)
	stack.add_child(vitals)
	hud_hp_label = _vital_chip(vitals, "heart")
	hud_sanity_label = _vital_chip(vitals, "moon")
	hud_coins_label = _vital_chip(vitals, "coin")

	needs_box = HBoxContainer.new()
	needs_box.add_theme_constant_override("separation", 10)
	stack.add_child(needs_box)
	food_bar = _make_need_bar("Food")
	water_bar = _make_need_bar("Water")
	warmth_bar = _make_need_bar("Warmth")

	hud_clock_panel = PanelContainer.new()
	hud_clock_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hud_clock_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hud_clock_panel.offset_top = 10
	hud_clock_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_clock_panel.add_theme_stylebox_override("panel", _hud_box())
	hud_root.add_child(hud_clock_panel)
	var clock_pad := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		clock_pad.add_theme_constant_override(side, 6)
	hud_clock_panel.add_child(clock_pad)
	var clock_row := HBoxContainer.new()
	clock_row.add_theme_constant_override("separation", 10)
	clock_row.alignment = BoxContainer.ALIGNMENT_CENTER
	clock_pad.add_child(clock_row)
	hud_day_label = _make_label(clock_row, Vector2.ZERO, 16)
	hud_day_label.add_theme_color_override("font_color", Color("f2d27a"))
	hud_date_label = _make_label(clock_row, Vector2.ZERO, 13)
	hud_date_label.add_theme_color_override("font_color", Color("e8dcc0"))
	clock_row.add_child(_hud_divider())
	hud_time_label = _make_label(clock_row, Vector2.ZERO, 16)
	clock_row.add_child(_hud_divider())
	hud_weather_icon = HudIcon.new()
	hud_weather_icon.custom_minimum_size = Vector2(16, 16)
	hud_weather_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clock_row.add_child(hud_weather_icon)
	hud_weather_label = _make_label(clock_row, Vector2.ZERO, 13)
	needs_temp = _make_label(clock_row, Vector2.ZERO, 13)
	needs_temp.add_theme_color_override("font_color", Color("9fd3e6"))

	message_label = _make_label(hud_root, Vector2(16, 100), 20)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(300, 0)
	# Messages sit low on the left, clear of the farm's labels and the HUD.
	message_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	message_label.offset_left = 16
	message_label.offset_right = 316
	message_label.offset_top = -124
	message_label.offset_bottom = -24
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	hotbar = Hotbar.new()
	hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hotbar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hotbar.offset_bottom = -14
	hotbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(hotbar)

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
	action_bar.menu_pressed.connect(_toggle_wheel)
	action_bar.action_pressed.connect(_on_panel_action)


func _make_label(parent: Node, pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	# A dark outline keeps the text readable over grass, the house, and the dark.
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.92))
	label.add_theme_constant_override("outline_size", 6)
	parent.add_child(label)
	return label


# A small labelled bar for one body need. It fills from 0 to 100.
func _make_need_bar(title: String) -> ProgressBar:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	needs_box.add_child(col)
	var name_label := _make_label(col, Vector2.ZERO, 11)
	name_label.text = title
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.custom_minimum_size = Vector2(64, 8)
	bar.add_theme_stylebox_override("background", _bar_box(Color(0.06, 0.045, 0.035, 0.95)))
	bar.add_theme_stylebox_override("fill", _bar_box(Color("c9a24a")))
	col.add_child(bar)
	return bar


# The bar's frame: dark wood with gold trim and a soft shadow.
func _hud_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.09, 0.065, 0.05, 0.9)
	box.border_color = Color("b8893f")
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.shadow_color = Color(0, 0, 0, 0.4)
	box.shadow_size = 6
	box.shadow_offset = Vector2(0, 3)
	return box


# A small gold divider between items in the clock strip.
func _hud_divider() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = Color(0.72, 0.54, 0.25, 0.5)
	rule.custom_minimum_size = Vector2(2, 14)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


# A thin gold rule that divides the rows of the info bar.
func _hud_rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = Color(0.72, 0.54, 0.25, 0.4)
	rule.custom_minimum_size = Vector2(0, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


# An icon with a value beside it, such as health or coins. Returns the value's label.
func _vital_chip(parent: Node, icon_kind: String) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	var icon := HudIcon.new()
	icon.kind = icon_kind
	icon.custom_minimum_size = Vector2(20, 20)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	return _make_label(row, Vector2.ZERO, 15)


func _bar_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(3)
	box.border_color = Color(0.05, 0.04, 0.03, 0.9)
	box.set_border_width_all(1)
	return box


# Applies what loading saved: position, indoors or not, and the open panel.
func _restore_saved_state() -> void:
	farm._check_unlocks()
	zone = saved_zone
	if not WORLD_ENABLED:
		zone = Zone.HOMESTEAD
	hp = clampi(hp, 1, max_hp())
	if has_saved_pos:
		player.position = saved_pos
	# The house interior lies outside the farm bounds, so a saved spot inside is checked against the interior.
	if saved_inside:
		if not _in_interior(_player_tile()):
			player.position = _wake_spot()
	elif not WORLD_ENABLED and not _in_bounds(_player_tile()):
		# A save made in the wider land returns to the homestead when the world is off.
		player.position = _tile_center(HOMESTEAD_ARRIVE.x, HOMESTEAD_ARRIVE.y)
	if _in_village():
		_sync_region()
		_spawn_foes()
	if saved_inside:
		inside = true
	_set_bounds()
	if saved_panel != "":
		_toggle_tab(saved_panel)


# The great tree's footprint, in map tiles, and the ground point at the foot of its trunk.
func _big_tree_origin() -> Vector2i:
	return BIG_TREE_INNER + Vector2i(BORDER_X, BORDER_Y)


func _in_big_tree(tile: Vector2i) -> bool:
	var ix := tile - _big_tree_origin()
	return ix.x >= 0 and ix.x < 3 and ix.y >= 0 and ix.y < 3


func _big_tree_base() -> Vector2:
	var origin := _big_tree_origin()
	return Vector2(origin.x * PX + PX * 1.5, origin.y * PX + PX * 2.9)


func _draw_big_tree() -> void:
	var base := _big_tree_base()
	draw_colored_polygon(_ellipse_at(base + Vector2(PX * 0.5, PX * 0.12), PX * 1.9, PX * 0.5), Color(0, 0, 0, 0.3))
	var origin := _big_tree_origin()
	FarmArt.draw_big_tree(self, base, FarmArt.hash_int(origin.x, origin.y, 5))


# A tree is drawn from its baked picture once that exists. Until then it is drawn directly.
func _draw_tree_tile(cell: Rect2, x: int, y: int) -> void:
	var variant := _tree_variant(Vector2i(x, y))
	var seed_index: int = FarmArt.hash_int(x, y, 3) % FarmArt.TREE_SEEDS
	var key := "%d:%d" % [variant, seed_index]
	if tree_sprites.has(key):
		var sprite_rect := Rect2(cell.get_center().x - FarmArt.TREE_SPRITE_W * 0.5, cell.end.y - FarmArt.TREE_SPRITE_H + 0.1 * PX, FarmArt.TREE_SPRITE_W, FarmArt.TREE_SPRITE_H)
		draw_texture_rect(tree_sprites[key], sprite_rect, false)
		return
	FarmArt.draw_tree(self, cell, FarmArt.hash_int(x, y, 3), variant)


# Draws every tree style once into a small offscreen picture, then keeps the result.
func _bake_tree_sprites() -> void:
	for variant in 3:
		for seed_index in FarmArt.TREE_SEEDS:
			var key := "%d:%d" % [variant, seed_index]
			var size_px := Vector2(FarmArt.TREE_SPRITE_W, FarmArt.TREE_SPRITE_H) * FarmArt.TREE_BAKE_SCALE
			var vp := SubViewport.new()
			vp.transparent_bg = true
			vp.size = Vector2i(ceili(size_px.x), ceili(size_px.y))
			vp.render_target_update_mode = SubViewport.UPDATE_ONCE
			add_child(vp)
			var node := Node2D.new()
			node.scale = Vector2(FarmArt.TREE_BAKE_SCALE, FarmArt.TREE_BAKE_SCALE)
			vp.add_child(node)
			var h := FarmArt.hash_int(variant, seed_index, 99)
			node.draw.connect(func() -> void: FarmArt.draw_tree(node, FarmArt.TREE_CELL, h, variant))
			# The offscreen picture is kept as a live texture, drawn once and reused.
			tree_sprites[key] = vp.get_texture()
			await get_tree().process_frame
			await get_tree().process_frame
			queue_redraw()


func _update_perf() -> void:
	var lights := 0
	for light in window_lights:
		if light.enabled:
			lights += 1
	if porch_light != null and porch_light.enabled:
		lights += 1
	if lantern_light != null and lantern_light.enabled:
		lights += 1
	perf_label.text = "FPS %d   frame %.1f ms   script %.1f ms\nphysics %.1f ms\ndraw calls %d\nprimitives %d   objects %d\nlights on %d" % [
		Performance.get_monitor(Performance.TIME_FPS),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0 + Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		lights,
	]


func _update_minimap() -> void:
	if in_cave:
		_place_minimap(Vector2(CAVE_W, CAVE_H) * Minimap.PX_PER_TILE)
		minimap.update_view(cave, TILE_COLORS, [], Vector2(_player_tile()), Vector2i(-1, -1))
		return
	if _in_village():
		# In the world the minimap shows the whole land, with the player on it.
		if world_map_tex == null:
			_build_world_minimap()
		_place_minimap(Vector2(WORLD_W, WORLD_H) * Minimap.WORLD_PX_PER_TILE)
		minimap.update_world(world_map_tex, Vector2i(WORLD_W, WORLD_H), Vector2(_player_tile()) + Vector2(0.5, 0.5))
		return
	# Indoors the minimap shows the house, since the player isn't on the farm.
	_place_minimap(Vector2(MAP_W, MAP_H) * Minimap.PX_PER_TILE)
	var player_tile: Vector2 = Vector2(HOUSE_DOOR_IX + BORDER_X, HOUSE_DOOR_IY + BORDER_Y) if inside else player.position / PX
	# Rebuilding the minimap is costly, so it only refreshes when the player changes tile,
	# or every half second for things like brush and the shadow.
	var key := [inside, Vector2i(player_tile), tonight_shadow, Engine.get_process_frames() / 30]
	if key == last_minimap_key:
		return
	last_minimap_key = key
	var well_tile := Vector2(WELL_IX.x + BORDER_X, WELL_IX.y + BORDER_Y)
	minimap.update_view(map, TILE_COLORS, brush.keys(), player_tile, tonight_shadow, [] if inside else [well_tile])


# --- Tutorial tips ----------------------------------------------------------

# Each tip has a trigger. Tips are checked once a second and queue up, then show one at a time
# while nothing else is open. A tip shows once, and its text stays in the Settings menu.
func _tip_ready(id: String) -> bool:
	match id:
		"sleep":
			return current_hour >= 17.0
		"chores", "repair", "buildings", "quests":
			return day >= 2
		"hens":
			return coop_built
		"cave":
			return day >= 3
		"smelt":
			return furnace_built or smokehouse_built
		"cellar":
			return cellar_built
		"needs":
			return current_hour >= 12.0
		"well":
			return day >= 2
		"goats":
			return barn_built
	return false


func _update_tips(delta: float) -> void:
	tip_check_timer -= delta
	if tip_check_timer <= 0.0:
		tip_check_timer = 1.0
		for tip in TIPS:
			var id: String = tip["id"]
			if not tips_seen.has(id) and not tip_queue.has(id) and id != tip_showing and _tip_ready(id):
				tip_queue.append(id)
	if tip_showing != "":
		tip_timer -= delta
		if tip_timer <= 0.0:
			_hide_tip()
		return
	tip_cooldown = maxf(tip_cooldown - delta, 0.0)
	if tip_queue.size() > 0 and tip_cooldown <= 0.0 and open_tab == "" and placing == "":
		_show_tip(str(tip_queue.pop_front()))


# Shows the current chapter as a prompt: its title, and what to do with the controls for this device.
func _show_quest_prompt() -> void:
	var current: Variant = null
	for q in STORY:
		if not quests_done.has(q["id"]):
			current = q
			break
	if current == null:
		return
	tip_showing = "quest"
	tip_timer = 30.0
	tip_title_label.text = str(current["title"])
	tip_body_label.text = _prompt_text(current)
	tip_panel.visible = true


# A chapter's prompt, with the control names filled in for a keyboard or a gamepad.
func _prompt_text(q: Dictionary) -> String:
	var text := str(q.get("prompt", q["text"]))
	var pad := not Input.get_connected_joypads().is_empty()
	text = text.replace("{move}", "the left stick" if pad else "WASD or the arrow keys")
	text = text.replace("{use}", "RT or A" if pad else "left click or Space")
	text = text.replace("{switch}", "LB and RB" if pad else "the number keys 1 to 0 or the mouse wheel")
	text = text.replace("{menus}", "Y for Skills, Back for Inventory, Start for Settings" if pad else "K Skills, I Inventory, C Craft, Q Quests")
	text = text.replace("{craft}", "the Craft section on the section wheel" if pad else "the Craft section on the section wheel (Shift)")
	text = text.replace("{inv}", "Back" if pad else "I")
	text = text.replace("{house}", "the Menu button" if pad else "H")
	for i in HOTBAR_TOOLS.size():
		var tool_id := str(HOTBAR_TOOLS[i]["id"])
		var how := "scroll with LB and RB" if pad else "press %d or scroll the mouse wheel" % ((i + 1) % 10)
		# A hint that opens the sentence gets a capital letter.
		var opening := text.begins_with("{tool:%s}" % tool_id)
		text = text.replace("{tool:%s}" % tool_id, (how.substr(0, 1).to_upper() + how.substr(1)) if opening else how)
	return text


func _show_tip(id: String) -> void:
	var tip := _tip_data(id)
	tip_showing = id
	tips_seen[id] = true
	tip_timer = 16.0
	tip_title_label.text = str(tip["title"])
	tip_body_label.text = str(tip["text"])
	tip_panel.visible = true


func _hide_tip() -> void:
	tip_showing = ""
	tip_panel.visible = false
	tip_cooldown = 1.5


func _tip_data(id: String) -> Dictionary:
	for tip in TIPS:
		if str(tip["id"]) == id:
			return tip
	return {"title": "", "text": ""}


# The card sits at the bottom of the screen, clear of the top-left messages and the minimap.
func _build_tip_panel() -> void:
	var host := message_label.get_parent() as Control
	tip_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.06, 0.04, 0.92)
	sb.border_color = Color("8a6a3a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(12)
	tip_panel.add_theme_stylebox_override("panel", sb)
	tip_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tip_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tip_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tip_panel.offset_left = -290
	tip_panel.offset_right = 290
	tip_panel.offset_top = -90
	tip_panel.offset_bottom = -90
	tip_panel.custom_minimum_size = Vector2(580, 0)
	tip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip_panel.visible = false
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	tip_panel.add_child(box)
	tip_title_label = Label.new()
	tip_title_label.add_theme_font_size_override("font_size", 18)
	tip_title_label.add_theme_color_override("font_color", Color("d8b050"))
	box.add_child(tip_title_label)
	tip_body_label = Label.new()
	tip_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	tip_body_label.custom_minimum_size = Vector2(556, 0)
	tip_body_label.add_theme_font_size_override("font_size", 15)
	tip_body_label.add_theme_color_override("font_color", Color("e8dcc0"))
	box.add_child(tip_body_label)
	var hint := Label.new()
	hint.text = "B to dismiss. Tips are kept in Settings."
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("9a8a6a"))
	box.add_child(hint)
	host.add_child(tip_panel)


# --- Input and panels --------------------------------------------------------

func _handle_keys() -> void:
	# Tab or Y opens and closes the bag.
	if Input.is_action_just_pressed("bag"):
		_toggle_bag()
	# Shift or a left stick click opens the section wheel, and closes it again.
	if Input.is_action_just_pressed("wheel"):
		_toggle_wheel()
	# Esc or Start closes whatever is open. With nothing open, it opens Settings.
	if Input.is_action_just_pressed("settings"):
		_press_back(true)
	# B dismisses a tip when nothing else is open, and otherwise closes what is open.
	if Input.is_action_just_pressed("close_panel"):
		if tip_showing != "" and open_tab == "" and placing == "" and not _bag_open() and not _wheel_open():
			_hide_tip()
		else:
			_press_back(false)


# B and Esc close the thing on top. A wheel section goes back to the wheel, and a second press closes
# the wheel. Other panels close back to the farm.
func _press_back(open_settings: bool) -> void:
	if _bag_open():
		_toggle_bag()
	elif _wheel_open():
		_close_wheel()
	elif placing != "":
		_cancel_placement()
	elif open_tab != "" and _is_wheel_section(open_tab):
		_close_panel()
		wheel.show_wheel()
		play_sfx("panel")
	elif open_tab != "":
		_close_panel()
	elif open_settings:
		_toggle_tab("Settings")


func _is_wheel_section(section_name: String) -> bool:
	for section in SectionWheel.SECTIONS:
		if str(section["name"]) == section_name:
			return true
	return false


func _toggle_tab(tab: String) -> void:
	if placing != "":
		_cancel_placement()
	if _bag_open():
		bag.hide_bag()
	if open_tab == tab:
		_close_panel()
	else:
		open_tab = tab
		progression._bump("panels_opened")
		play_sfx("panel")
		_refresh_panel()


func _close_panel() -> void:
	if open_tab != "":
		play_sfx("tick")
	open_tab = ""
	action_bar.hide_panel()


# --- The bag ------------------------------------------------------------------

func _build_bag() -> void:
	bag = BagPanel.new()
	add_child(bag)
	bag.slot_chosen.connect(_on_bag_slot)
	bag.toggle_requested.connect(_toggle_bag)
	bag.inventory_requested.connect(_on_bag_inventory)


func _bag_open() -> bool:
	return bag != null and bag.open


func _on_bag_inventory() -> void:
	_toggle_bag()
	_toggle_tab("Inventory")


# --- The section wheel --------------------------------------------------------

func _build_wheel() -> void:
	wheel = SectionWheel.new()
	add_child(wheel)
	wheel.section_chosen.connect(_on_wheel_section)


func _wheel_open() -> bool:
	return wheel != null and wheel.open


# Shift, a left stick click, or the Menu button. The wheel only opens with nothing else open.
func _toggle_wheel() -> void:
	if wheel == null:
		return
	if wheel.open:
		_close_wheel()
		return
	if open_tab != "" or _bag_open() or placing != "" or not world_started:
		return
	wheel.show_wheel()
	play_sfx("panel")


func _close_wheel() -> void:
	wheel.hide_wheel()
	play_sfx("tick")


# Choosing a section closes the wheel and shows that section alone.
func _on_wheel_section(section_name: String) -> void:
	_toggle_tab(section_name)


func _toggle_bag() -> void:
	if bag == null:
		return
	if bag.open:
		bag.hide_bag()
		play_sfx("tick")
		return
	# The bag opens only when no other menu or placement is up.
	if open_tab != "" or placing != "" or not world_started or _wheel_open():
		return
	bag.set_items(_bag_items())
	bag.show_bag()
	play_sfx("panel")


# The pack stacks in grid order. Meals, stews and bandages can be used from here; the rest show their description.
func _bag_items() -> Array:
	var out: Array = []
	for t in _inventory_tiles():
		if str(t["name"]).ends_with(" x0"):
			continue
		var action := str(t.get("action", ""))
		var usable := action.begins_with("eat_food:") or action == "use_bandage"
		var desc := str(t.get("desc", ""))
		if usable:
			desc += "\nClick or press A to use."
		out.append({"label": str(t["name"]), "usable": usable, "action": action, "desc": desc, "tint": str(t.get("tint", "8a6a3a")), "icon": str(t.get("icon", ""))})
	return out


func _on_bag_slot(index: int) -> void:
	var items := _bag_items()
	if index < 0 or index >= items.size():
		return
	var it: Dictionary = items[index]
	if bool(it["usable"]):
		_on_panel_action(str(it["action"]))
		bag.set_items(_bag_items())
	else:
		_show_message(str(it["desc"]).split("\n")[0])


func _on_panel_action(action_id: String) -> void:
	if action_id.begins_with("game_") or action_id.begins_with("sudoku_") or action_id.begins_with("sol_") or action_id == "pay_tax" or action_id == "mail_clear":
		desk._desk_action(action_id)
		return
	if action_id.begins_with("cook:"):
		stall._make_food(action_id.trim_prefix("cook:"))
		return
	if action_id.begins_with("sell_food:"):
		stall._sell_food(action_id.trim_prefix("sell_food:"))
		return
	if action_id.begins_with("ammo:"):
		_craft_ammo(action_id.trim_prefix("ammo:"))
		return
	if action_id.begins_with("tool:"):
		_craft_tool(action_id.trim_prefix("tool:"))
		return
	if action_id.begins_with("sell:"):
		stall._sell(action_id.trim_prefix("sell:"))
		return
	if action_id.begins_with("smelt:"):
		_smelt(action_id.trim_prefix("smelt:"))
		return
	if action_id.begins_with("buy:"):
		stall._buy_material(action_id.trim_prefix("buy:"))
		return
	if action_id.begins_with("sellmat:"):
		stall._sell_material(action_id.trim_prefix("sellmat:"))
		return
	if action_id.begins_with("dep:") or action_id.begins_with("wd:"):
		stall._bank_move(action_id)
		return
	if action_id == "camp":
		_place_campsite()
		return
	if action_id == "build_woodshed":
		_build_woodshed()
		return
	if action_id.begins_with("wood_take:"):
		firewood._take_firewood(int(action_id.trim_prefix("wood_take:")))
		return
	if action_id == "wood_store":
		firewood._store_firewood()
		return
	if action_id == "build_furnace":
		_build_furnace()
		return
	if action_id == "build_coop" or action_id == "move_coop":
		_build_coop()
		return
	if action_id == "unstick":
		_unstick()
		return
	if action_id == "repair_well":
		_repair_well()
		return
	if action_id == "attach_hose":
		_attach_hose()
		return
	if action_id == "drink_well":
		_drink_well()
		return
	if action_id == "toggle_music":
		_toggle_music()
		return
	if action_id == "toggle_sfx":
		_toggle_sfx()
		return
	if action_id == "quit_title":
		_quit_to_title()
		return
	if action_id == "build_barn" or action_id == "move_barn":
		_build_barn()
		return
	if action_id == "buy_hen":
		_buy_hen()
		return
	if action_id == "feed_hens":
		animals._feed_hens()
	if action_id == "sell_hen":
		animals._sell_hen()
	if action_id == "sell_goat":
		animals._sell_goat()
	if action_id == "buy_goat":
		_buy_goat()
	if action_id == "feed_goats":
		animals._feed_goats()
		return
	if action_id == "build_smokehouse":
		_build_smokehouse()
		return
	if action_id.begins_with("craft:"):
		_craft_gear(action_id.trim_prefix("craft:"))
		return
	if action_id.begins_with("quest_open:") or action_id.begins_with("quest_close:"):
		quest_open[action_id.get_slice(":", 1)] = action_id.begins_with("quest_open:")
		_refresh_panel()
		return
	if action_id.begins_with("craft_tab:"):
		craft_tab = action_id.trim_prefix("craft_tab:")
		_refresh_panel()
		return
	if action_id.begins_with("skill_pick:"):
		skill_selected = action_id.trim_prefix("skill_pick:")
		_refresh_panel()
		return
	if action_id.begins_with("gear_pick:"):
		gear_selected = action_id.trim_prefix("gear_pick:")
		_refresh_panel()
		return
	if action_id == "job":
		_do_job()
		return
	if action_id == "use_bandage":
		_use_bandage()
		return
	if action_id == "make_bandage":
		_make_bandage()
		return
	if action_id.begins_with("eat_food:"):
		stall._eat_food(action_id.trim_prefix("eat_food:"))
		return
	if action_id.begins_with("inv_pick:"):
		inventory_selected = action_id.trim_prefix("inv_pick:")
		_refresh_panel()
		return
	if action_id.begins_with("craft_pick:"):
		craft_selected = action_id.trim_prefix("craft_pick:")
		_refresh_panel()
		return
	match action_id:
		"close":
			_close_panel()
		"open_craft":
			open_tab = "Craft"
			_refresh_panel()
		"repair":
			_repair_house()
		"mend":
			_mend_house()
		"cleanse":
			sanity_sys._cleanse_house()
		"tidy":
			sanity_sys._tidy_house()
		"advance_lantern":
			_advance_lantern()
		"switch_seed":
			farm._switch_seed()
		"sell_crops":
			stall._sell("crops")
		"sell_pumpkins":
			stall._sell("pumpkins")
		"sell_fish":
			stall._sell("fish")
		"sell_eggs":
			stall._sell("eggs")
		"sell_milk":
			stall._sell("milk")
		"buy_turnip":
			farm._buy_seeds("turnip")
		"buy_pumpkin":
			farm._buy_seeds("pumpkin")
		"upgrade_bag":
			_upgrade_bag()
		"build_cellar":
			_build_storage("cellar")
		"build_cooler":
			_build_storage("cooler")
		"store_crops":
			farm._store_crops()
		"take_crops":
			farm._take_crops()
		"store_fish":
			_store_fish()
		"take_fish":
			_take_fish()


func _refresh_panel() -> void:
	# With no section open the menu frame must be hidden, not redrawn with an empty tab.
	if open_tab == "":
		action_bar.hide_panel()
		return
	var rows: Array = []
	match open_tab:
		"Skills":
			rows = panels._skill_rows()
		"Inventory":
			rows = panels._inventory_rows()
		"Gear":
			rows = panels._gear_rows()
		"Craft":
			rows = panels._craft_rows()
		"Quests":
			rows = panels._quest_rows()
		"Achievements":
			rows = panels._achievement_rows()
		"Trade":
			rows = panels._trade_rows()
		"Shop":
			rows = panels._general_shop_rows()
		"Bank":
			rows = panels._bank_rows()
		"Cellar":
			rows = panels._cellar_rows()
		"Cooler":
			rows = panels._cooler_rows()
		"Smokehouse":
			rows = panels._smokehouse_rows()
		"Furnace":
			rows = panels._furnace_rows()
		"Woodstore":
			rows = panels._woodstore_rows()
		"Desk":
			rows = panels._desk_rows()
		"House":
			rows = panels._house_rows()
		"Buildings":
			rows = panels._buildings_rows()
		"Coop":
			rows = panels._coop_rows()
		"Barn":
			rows = panels._barn_rows()
		"Well":
			rows = panels._well_rows()
		"Settings":
			rows = panels._settings_rows() + panels._tip_rows() + panels._game_rows()
	action_bar.show_panel(open_tab, rows)


# Each skill's picture, color, and what trains it.
const SKILL_INFO := {
	"Farming": {"icon": "crop", "tint": "4f6b3a", "desc": "Grows crops. Planting, watering, and harvesting all train it. Level 3 unlocks pumpkin seeds."},
	"Bushcrafting": {"icon": "fiber", "tint": "6b4a3a", "desc": "Gathers wood, fiber, and resin, and unlocks the early gear and lanterns."},
	"Carpentry": {"icon": "hammer", "tint": "8a6a3a", "desc": "Trains by mending boards and repairing the house."},
	"Cleaning": {"icon": "broom", "tint": "4a6b7a", "desc": "Tidies the house."},
	"Fishing": {"icon": "fish", "tint": "3a5a7a", "desc": "Works the sparkling spots at the pond."},
	"Cooking": {"icon": "bowl", "tint": "8a4f2a", "desc": "Turns catches and crops into meals and preserves."},
	"Combat": {"icon": "sword", "tint": "6b3a3a", "desc": "Earned by guarding Lowmere and fighting foes."},
	"Forestry": {"icon": "axe", "tint": "3f5a2a", "desc": "Fells trees for wood and hardwood."},
	"Mining": {"icon": "pick", "tint": "5a5a5a", "desc": "Breaks rocks for stone and ore."},
	"Smithing": {"icon": "anvil", "tint": "7a5a2a", "desc": "Turns ore into bars and metal gear."},
}
var skill_selected := ""   # the skill whose details show; remembered while the panel is open


func _skill_chosen(tiles: Array) -> Dictionary:
	for t in tiles:
		if str(t["key"]) == skill_selected:
			return t
	return tiles[0] if not tiles.is_empty() else {}


# The pack, seeds, and materials are a grid of picture tiles. Picking one shows its details beside the grid.
const MATERIAL_INFO := {
	"wood": {"name": "Wood", "icon": "log", "tint": "6b4a3a", "desc": "Burned for cooking and used in most early crafts."},
	"sticks": {"name": "Sticks", "icon": "sticks", "tint": "8a6a3a", "desc": "Dry sticks from the brush piles. Crude hatchets and rods are made from them."},
	"fiber": {"name": "Fiber", "icon": "fiber", "tint": "8a8a4a", "desc": "Plant fiber for wraps, leggings, and the hose."},
	"resin": {"name": "Resin", "icon": "resin", "tint": "b5703a", "desc": "Sticky sap for caps, amulets, and the hose."},
	"hardwood": {"name": "Hardwood", "icon": "log", "tint": "4a3426", "desc": "Dense wood for stronger gear and bolts."},
	"stone": {"name": "Stone", "icon": "stone", "tint": "7a7a7a", "desc": "Rough stone from the quarry and the cave."},
	"copper_ore": {"name": "Copper ore", "icon": "ore", "tint": "b87333", "desc": "Raw copper. Smelt it at the furnace."},
	"iron_ore": {"name": "Iron ore", "icon": "ore", "tint": "6b6b6b", "desc": "Raw iron. Smelt it at the furnace."},
	"copper_bar": {"name": "Copper bar", "icon": "bar", "tint": "c97f45", "desc": "Smelted copper, ready for smithing."},
	"iron_bar": {"name": "Iron bar", "icon": "bar", "tint": "8d98a6", "desc": "Smelted iron, ready for smithing."},
	"arrows": {"name": "Arrows", "icon": "arrow", "tint": "6b4a3a", "desc": "Ammunition for the bow. Each shot uses one."},
	"bolts": {"name": "Bolts", "icon": "arrow", "tint": "6b6b6b", "desc": "Ammunition for ranged weapons. Each shot uses one."},
}
var inventory_selected := ""   # the pack item whose details show; remembered while the panel is open


# One tile per stack in the pack, then the seed pouch, then the materials you hold.
func _inventory_tiles() -> Array:
	return _split_pack_tiles(_raw_inventory_tiles())


# A pack kind with more than STACK_SIZE items becomes several tiles, each holding one full or part stack.
func _split_pack_tiles(tiles: Array) -> Array:
	var out: Array = []
	for t in tiles:
		var key := str(t["key"])
		if not key.begins_with("pack:"):
			out.append(t)
			continue
		var parts := str(t["name"]).rsplit(" x", true, 1)
		var base := parts[0]
		var count := int(parts[1])
		var unit := str(t["level_text"]).split(" ", true, 1)[1]
		var left := count
		var index := 0
		while left > 0:
			var n := mini(left, STACK_SIZE)
			var tile: Dictionary = t.duplicate()
			tile["key"] = key if index == 0 else "%s:%d" % [key, index]
			tile["name"] = "%s x%d" % [base, n]
			tile["level_text"] = "%d %s" % [n, unit]
			out.append(tile)
			left -= n
			index += 1
	return out


func _raw_inventory_tiles() -> Array:
	var tiles: Array = []
	var n := 0
	for f in Foods.LIST:
		n = int(inventory[str(f["held"])])
		if n <= 0:
			continue
		var desc := "%s %s" % [str(f["desc"]), _food_stats_text(f)]
		var sells := stall._food_price(str(f["id"]))
		if sells > 0:
			desc += " Sells for %d coins." % sells
		tiles.append(_stack_tile("pack:" + str(f["id"]), str(f["name"]), str(f["icon"]), str(f["tint"]), n, "in the pack",
			desc, "eat_food:" + str(f["id"]), str(f.get("verb", "Eat"))))
	n = int(inventory["fish"])
	if n > 0:
		tiles.append(_stack_tile("pack:fish", "Fish", "fish", "6fb8d9", n, "in the pack",
			"Caught from the pond. Spoils overnight unless it is kept in the cooler. Sells for %d coins." % SELL_FISH, "", ""))
	n = int(inventory["bandage"])
	if n > 0:
		tiles.append(_stack_tile("pack:bandage", str(BANDAGE["name"]), "bandage", "e8e0d0", n, "in the pack",
			"Heals %d HP. Use it from here." % int(BANDAGE["heal"]), "use_bandage", "Use"))
	n = int(inventory["firewood"])
	if n > 0:
		tiles.append(_stack_tile("pack:firewood", "Firewood", "firewood", "9a6a3a", n, "in the pack",
			"Split logs for the hearth. Feed the fire from the hearth in the house.", "", ""))
	var turnip_ok := true
	tiles.append(_stack_tile("seed:turnip", "Turnip seeds", "seed", "a8d46f", int(inventory["seeds"]), "in the pouch",
		"Planted in tilled soil. Kept in the seed pouch.", "", ""))
	var pumpkin_ok := progression._level("Farming") >= PUMPKIN_LEVEL
	var pumpkin := _stack_tile("seed:pumpkin", "Pumpkin seeds", "pumpkin_seed", "d98a35", int(inventory["pumpkin_seeds"]), "in the pouch",
		"Larger harvest of three crops per plant. Needs Farming %d to plant." % PUMPKIN_LEVEL, "", "")
	pumpkin["enabled"] = pumpkin_ok
	pumpkin["level_ok"] = pumpkin_ok
	if not pumpkin_ok:
		pumpkin["level_text"] = "Needs Farming %d" % PUMPKIN_LEVEL
	tiles.append(pumpkin)
	for key in MATERIAL_INFO.keys():
		n = int(materials.get(key, 0))
		if n > 0:
			var info: Dictionary = MATERIAL_INFO[key]
			tiles.append(_stack_tile("mat:" + str(key), str(info["name"]), str(info["icon"]), str(info["tint"]), n, "held",
				str(info["desc"]), "", ""))
	return tiles


func _stack_tile(key: String, name: String, icon: String, tint: String, count: int, unit: String, desc: String, action: String, button: String) -> Dictionary:
	var tile := {
		"key": key, "name": "%s x%d" % [name, count], "icon": icon, "tint": tint, "desc": desc,
		"level_text": "%d %s" % [count, unit], "level_ok": true, "costs": [], "enabled": true, "action": action,
	}
	if button != "":
		tile["button"] = button
	return tile


func _inventory_chosen(tiles: Array) -> Dictionary:
	for t in tiles:
		if str(t["key"]) == inventory_selected:
			return t
	return tiles[0] if not tiles.is_empty() else {}


const CRAFT_TABS := [
	{"id": "gear", "name": "Gear"},
	{"id": "cooking", "name": "Cooking"},
	{"id": "tools", "name": "Tools"},
	{"id": "other", "name": "Other"},
]


# The Gear panel is a grid of picture tiles: each worn slot, the bag and belt, then the toolbelt.
# Picking a tile fills the detail card beside the grid.
var gear_selected := ""   # the slot or tool whose details show; remembered while the panel is open


func _gear_tiles() -> Array:
	var tiles: Array = []
	var bag_name := "Pack" if bag_tier == 0 else str(BAG_TIERS[bag_tier - 1]["name"])
	tiles.append({
		"key": "slot:back", "name": bag_name, "icon": "pack", "tint": "7a5a3a", "enabled": true,
		"desc": "Your bag. Upgrade it from the Inventory panel.", "level_text": "%d pack slots" % stall._pack_capacity(),
		"level_ok": true, "costs": [], "action": "",
	})
	tiles.append(_gear_slot_tile("head", "Head", "hat"))
	tiles.append(_gear_slot_tile("neck", "Neck", "pendant"))
	var lantern := {
		"key": "slot:belt", "name": "Belt", "icon": "lantern", "tint": "8a7a2a", "enabled": false, "level_ok": true,
		"desc": "No lantern yet. Build one in the Craft panel, under Other.", "level_text": "", "costs": [], "action": "",
	}
	if lantern_tier > 0:
		var current: Dictionary = LANTERN_TIERS[lantern_tier - 1]
		lantern["name"] = str(current["name"])
		lantern["enabled"] = true
		lantern["desc"] = "Lights a ring %.1f tiles across. It hangs from your belt." % float(current["radius"])
	tiles.append(lantern)
	tiles.append(_gear_slot_tile("offhand", "Off hand", "shield"))
	tiles.append(_gear_slot_tile("chest", "Chest", "shirt"))
	tiles.append(_gear_slot_tile("hand_r", "Main hand", "sword"))
	tiles.append(_gear_slot_tile("wrist", "Gloves", "glove"))
	tiles.append(_gear_slot_tile("legs", "Legs", "pants"))
	tiles.append(_gear_slot_tile("feet", "Feet", "boots"))
	var spots := {
		"slot:back": Vector2i(0, 1), "slot:head": Vector2i(1, 0), "slot:neck": Vector2i(1, 1),
		"slot:chest": Vector2i(1, 2), "slot:hand_r": Vector2i(0, 2), "slot:offhand": Vector2i(2, 2),
		"slot:wrist": Vector2i(0, 3), "slot:legs": Vector2i(1, 3), "slot:belt": Vector2i(2, 3), "slot:feet": Vector2i(1, 4),
	}
	for t in tiles:
		if spots.has(t["key"]):
			t["pos"] = spots[t["key"]]
	tiles.append({
		"key": "tool:hoe", "name": "Hoe", "icon": "hoe", "tint": "8a6a3a", "enabled": true,
		"desc": "Tills the soil so you can plant.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	tiles.append({
		"key": "tool:axe", "name": _tool_name("hatchet") if int(tool_tier["hatchet"]) > 0 else "Axe", "icon": "axe", "tint": TINT_TOOL, "enabled": int(tool_tier["hatchet"]) > 0,
		"desc": "Chops trees. Upgrade it in the Craft panel, under Tools.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	tiles.append({
		"key": "tool:rod", "name": _tool_name("rod") if int(tool_tier["rod"]) > 0 else "Fishing rod", "icon": "rod", "tint": TINT_TOOL,
		"enabled": int(tool_tier["rod"]) > 0, "level_ok": true, "costs": [], "action": "",
		"desc": "Adds to your catch chance when you fish. Make better rods in the Craft panel, under Tools.", "level_text": "",
	})
	tiles.append({
		"key": "tool:pick", "name": _tool_name("pick") if int(tool_tier["pick"]) > 0 else "Pickaxe", "icon": "pick", "tint": TINT_TOOL, "enabled": int(tool_tier["pick"]) > 0,
		"desc": "Breaks rocks and ore. Upgrade it in the Craft panel, under Tools.", "level_text": "", "level_ok": true, "costs": [], "action": "",
	})
	return tiles


# One worn slot: the piece in it, or a dim empty tile that points to the Craft panel.
func _gear_slot_tile(slot: String, label: String, icon: String) -> Dictionary:
	var id := str(equipment[slot])
	var tint := "4a4036"
	if id == "":
		return {
			"key": "slot:" + slot, "name": label, "icon": icon, "tint": tint, "enabled": false,
			"desc": "Nothing worn here. Craft a piece for this slot in the Craft panel.", "level_text": "Empty", "level_ok": true,
			"costs": [], "action": "open_craft", "button": "Craft",
		}
	var item: Dictionary = GEAR_ITEMS[id]
	tint = TINT_WEAPON if slot == "hand_r" or item.has("ammo") else (TINT_ACCESSORY if slot == "neck" or slot == "wrist" else TINT_ARMOR)
	var parts: Array = []
	if int(item["dmg"]) > 0:
		parts.append("Damage %d" % int(item["dmg"]))
	if int(item["def"]) > 0:
		parts.append("Armor %d" % int(item["def"]))
	var desc := ", ".join(parts) if not parts.is_empty() else "No damage or armor."
	return {
		"key": "slot:" + slot, "name": str(item["name"]), "icon": icon, "tint": tint, "enabled": true,
		"desc": desc + ".", "level_text": "Worn now", "level_ok": true, "costs": [], "action": "open_craft", "button": "Craft",
	}


func _gear_chosen(tiles: Array) -> Dictionary:
	for t in tiles:
		if str(t["key"]) == gear_selected:
			return t
	return tiles[0] if not tiles.is_empty() else {}


# The Craft panel is a grid of recipes for the chosen sub-tab. Picking a tile fills in its details below.
const TINT_WEAPON := "6b4a3a"
const TINT_ARMOR := "3f5a6b"
const TINT_ACCESSORY := "6b5a2a"
const TINT_TOOL := "4f6b3a"
const TINT_FOOD := "8a4f2a"
const TINT_LIGHT := "8a7a2a"
var craft_selected := ""     # the recipe whose details show; remembered while the panel is open


func _chosen_recipe(recipes: Array) -> Dictionary:
	for r in recipes:
		if str(r["key"]) == craft_selected:
			return r
	return recipes[0] if not recipes.is_empty() else {}


func _craft_recipes() -> Array:
	match craft_tab:
		"cooking":
			return stall._recipes_cooking()
		"tools":
			return _recipes_tools()
		"other":
			return _recipes_other()
	return _recipes_gear()


func _craft_footer() -> String:
	match craft_tab:
		"cooking":
			return "Eat meals from the Inventory panel. Smoking and preserving are done at the smokehouse, and smelting at the furnace."
		"tools":
			return "Tools are kept by tier rather than worn in a slot. Upgrade them one tier at a time."
		"other":
			return "The lantern hangs from the belt and lights a ring around you in the dark."
	return "Crafted gear equips at once and replaces what was worn in that slot. Armor cuts damage from foes. Weapons decide how hard you hit."


# One line per material: how much the recipe needs, and how much you hold.
func _cost_lines(cost: Dictionary) -> Array:
	var lines: Array = []
	for mat in cost.keys():
		var need := int(cost[mat])
		if need <= 0:
			continue
		lines.append({"label": "%d %s" % [need, str(mat).replace("_", " ")], "have": _held(str(mat)), "need": need})
	return lines


func _held(mat: String) -> int:
	if mat == "coins":
		return money
	if mat == "crops":
		return farm._crop_total()
	if materials.has(mat):
		return int(materials[mat])
	return int(inventory.get(mat, 0))


func _level_text(skill: String, level: int) -> String:
	return "Needs %s %d (you have %d)" % [skill, level, progression._level(skill)]


func _slot_icon(item: Dictionary) -> String:
	if item.has("ammo"):
		return "bow"
	match str(item["slot"]):
		"hand_r":
			return "sword"
		"offhand":
			return "shield"
		"head":
			return "hat"
		"chest":
			return "shirt"
		"legs":
			return "pants"
		"feet":
			return "boots"
		"neck":
			return "pendant"
		"wrist":
			return "bracer"
	return "sword"


func _recipes_gear() -> Array:
	var out: Array = []
	for id in GEAR_ITEMS.keys():
		if id == "hoe":
			continue
		var item: Dictionary = GEAR_ITEMS[id]
		var worn: bool = str(equipment[item["slot"]]) == str(id)
		var skill := str(item.get("skill", "Bushcrafting"))
		var level := int(item["level"])
		var parts: Array = []
		if int(item.get("dmg", 0)) > 0:
			parts.append("Damage %d" % int(item["dmg"]))
		if int(item.get("def", 0)) > 0:
			parts.append("Armor %d" % int(item["def"]))
		var desc := ", ".join(parts) if not parts.is_empty() else "No damage or armor."
		desc += ". Worn %s." % str(item["slot"]).replace("_", " ")
		if worn:
			desc = "Already worn. " + desc
		var tint := TINT_WEAPON
		if item.has("ammo"):
			tint = TINT_WEAPON
		elif str(item["slot"]) in ["head", "chest", "legs", "feet", "offhand"]:
			tint = TINT_ARMOR
		elif str(item["slot"]) in ["neck", "wrist"]:
			tint = TINT_ACCESSORY
		out.append({
			"key": "gear:" + str(id), "name": str(item["name"]), "icon": _slot_icon(item), "tint": tint,
			"desc": desc, "costs": _cost_lines(item["cost"]), "level_text": _level_text(skill, level),
			"level_ok": progression._level(skill) >= level, "enabled": _can_craft(str(id)), "action": "craft:" + str(id),
			"button": "Worn" if worn else "Make",
		})
	return out


func _recipes_tools() -> Array:
	var out: Array = []
	for kind in ["hatchet", "pick", "rod"]:
		var tiers: Array = TOOL_TIERS[kind]
		var have := int(tool_tier[kind])
		var icon := "axe" if kind == "hatchet" else ("pick" if kind == "pick" else "rod")
		if have >= tiers.size():
			out.append({
				"key": "tool:" + kind, "name": _tool_name(kind), "icon": icon, "tint": TINT_TOOL,
				"desc": "You have the best %s there is." % kind, "costs": [], "level_text": "", "level_ok": true,
				"enabled": false, "action": "", "button": "Best",
			})
			continue
		var tier: Dictionary = tiers[have]
		out.append({
			"key": "tool:" + kind, "name": str(tier["name"]), "icon": icon, "tint": TINT_TOOL,
			"desc": _tool_desc(kind, tier, have),
			"costs": _cost_lines(tier["cost"]), "level_text": _level_text(str(tier["skill"]), int(tier["level"])),
			"level_ok": progression._level(str(tier["skill"])) >= int(tier["level"]), "enabled": _can_craft_tool(kind),
			"action": "tool:" + kind, "button": "Make",
		})
	for kind in ["arrows", "bolts"]:
		var ammo: Dictionary = AMMO[kind]
		out.append({
			"key": "ammo:" + kind, "name": str(ammo["name"]), "icon": "arrow", "tint": TINT_TOOL,
			"desc": "Makes %d at a time. You hold %d." % [int(ammo["yield"]), int(materials[kind])],
			"costs": _cost_lines(ammo["cost"]), "level_text": _level_text(str(ammo["skill"]), int(ammo["level"])),
			"level_ok": progression._level(str(ammo["skill"])) >= int(ammo["level"]), "enabled": _can_fletch(kind),
			"action": "ammo:" + kind, "button": "Make",
		})
	return out


func _recipes_other() -> Array:
	var out: Array = []
	if lantern_tier < LANTERN_TIERS.size():
		var t: Dictionary = LANTERN_TIERS[lantern_tier]
		var costs: Array = [
			{"label": "%d wood" % int(t["wood"]), "have": _held("wood"), "need": int(t["wood"])},
			{"label": "%d fiber" % int(t["fiber"]), "have": _held("fiber"), "need": int(t["fiber"])},
		]
		if int(t["resin"]) > 0:
			costs.append({"label": "%d resin" % int(t["resin"]), "have": _held("resin"), "need": int(t["resin"])})
		var desc := "Lights a ring %.1f tiles across. It hangs from your belt." % float(t["radius"])
		if lantern_tier > 0:
			desc = "You have the %s. %s" % [LANTERN_TIERS[lantern_tier - 1]["name"], desc]
		out.append({
			"key": "lantern", "name": str(t["name"]), "icon": "lantern", "tint": TINT_LIGHT,
			"desc": desc, "costs": costs, "level_text": _level_text("Bushcrafting", int(t["level"])),
			"level_ok": progression._level("Bushcrafting") >= int(t["level"]), "enabled": _can_advance_lantern(),
			"action": "advance_lantern", "button": "Build" if lantern_tier == 0 else "Upgrade",
		})
	out.append(_recipes_other_bandage())
	return out


func _recipes_other_bandage() -> Dictionary:
	var costs: Array = [
		{"label": "%d fiber" % int(BANDAGE["fiber"]), "have": _held("fiber"), "need": int(BANDAGE["fiber"])},
		{"label": "%d resin" % int(BANDAGE["resin"]), "have": _held("resin"), "need": int(BANDAGE["resin"])},
	]
	return {
		"key": "bandage", "name": str(BANDAGE["name"]), "icon": "bandage", "tint": "e8e0d0",
		"desc": "Heals %d HP when used from the Inventory panel. +%d Bushcrafting XP." % [int(BANDAGE["heal"]), int(BANDAGE["xp"])],
		"costs": costs, "level_text": _level_text("Bushcrafting", int(BANDAGE["level"])),
		"level_ok": progression._level("Bushcrafting") >= int(BANDAGE["level"]), "enabled": stall._can_make_bandage(),
		"action": "make_bandage", "button": "Make",
	}


func _make_bandage() -> void:
	if not stall._can_make_bandage():
		_show_message("You need %d fiber, %d resin, and Bushcrafting %d." % [int(BANDAGE["fiber"]), int(BANDAGE["resin"]), int(BANDAGE["level"])])
		return
	materials["fiber"] -= int(BANDAGE["fiber"])
	materials["resin"] -= int(BANDAGE["resin"])
	inventory["bandage"] += 1
	progression._grant_xp("Bushcrafting", int(BANDAGE["xp"]))
	_show_message("You roll a bandage. +%d Bushcrafting XP" % int(BANDAGE["xp"]))


func _use_bandage() -> void:
	if int(inventory["bandage"]) <= 0:
		_show_message("You have no bandages.")
		return
	if hp >= max_hp():
		_show_message("You don't need a bandage right now.")
		return
	inventory["bandage"] -= 1
	hp = mini(max_hp(), hp + int(BANDAGE["heal"]))
	play_sfx("eat", 0.05)
	_show_message("You bind your wounds. HP %d/%d" % [hp, max_hp()])


# A quest is a single line: its name, and Done or its progress. Details open with a button.
# The current chapter starts open; the player's choice overrides that.
func _quest_row(q: Dictionary, expanded: bool) -> Dictionary:
	var id := str(q["id"])
	var done: bool = quests_done.has(q["id"])
	var is_open: bool = bool(quest_open.get(id, expanded))
	var shown := mini(progression._stat_value(q["stat"]), q["goal"])
	var row := {
		"name": str(q["title"]),
		"struck": done,
		"value": "Done" if done else "%d/%d" % [shown, q["goal"]],
		"button": "Hide" if is_open else "Details",
		"action": ("quest_close:" if is_open else "quest_open:") + id,
		"enabled": true,
	}
	if is_open:
		var note := "%s  Reward: %s" % [q["text"], progression._reward_text(q["reward"])]
		if expanded:
			note = "%s\n%s" % [q["story"], note]
		row["note"] = note
		row["progress"] = float(shown) / float(q["goal"])
	return row


# A standing building can be moved; one that is paid for but not yet placed gets a Place button.
func _placed_row(label: String, kind: String, tile: Vector2i, action: String) -> Dictionary:
	var placed := tile.x >= 0
	var size := _footprint(kind)
	return {
		"name": label,
		"value": ("standing, %d by %d" % [size.x, size.y]) if placed else "paid for, not yet placed",
		"button": "Move" if placed else "Place",
		"action": action,
		"enabled": true,
	}


# --- Farming ----------------------------------------------------------------


# The tool in the active hotbar slot, or "" for an empty slot.
func _active_tool() -> String:
	if active_slot < 0 or active_slot >= HOTBAR_TOOLS.size():
		return ""
	return str(HOTBAR_TOOLS[active_slot]["id"])


# The weapon slot holds whatever is in the main hand besides the hoe.
func _has_weapon() -> bool:
	var weapon := str(equipment["hand_r"])
	return weapon != "" and weapon != "hoe"


func _hotbar_unlocked(id: String) -> bool:
	match id:
		"sword":
			return _has_weapon()
		"axe":
			return int(tool_tier["hatchet"]) > 0
		"pick":
			return int(tool_tier["pick"]) > 0
		"rod":
			return int(tool_tier["rod"]) > 0
	return true


func _hotbar_entries() -> Array:
	var out: Array = []
	for i in Hotbar.SLOT_COUNT:
		if i < HOTBAR_TOOLS.size():
			var tool: Dictionary = HOTBAR_TOOLS[i].duplicate()
			tool["enabled"] = _hotbar_unlocked(str(tool["id"]))
			out.append(tool)
		else:
			out.append({})
	return out


# True when a mouse click landed on a menu control, so the click does not also act on the world.
func _pointer_on_ui() -> bool:
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_viewport().gui_get_hovered_control() != null


# Checks that the active slot holds the tool a target needs. Says what to select when it doesn't.
# True while the current press came from RT or a left click, which are the only presses that work tools.
var _tool_press := false


func _need_tool(id: String) -> bool:
	if not _tool_press:
		_show_message("Press RT or click to use the %s." % str(TOOL_LABELS.get(id, id)))
		return false
	if _active_tool() == id:
		return true
	_show_message("Select the %s on the hotbar to do that." % str(TOOL_LABELS.get(id, id)))
	return false


# The looping action while a chop, mine or fishing channel runs.
func _loop_action() -> String:
	if harvest_kind == "chop":
		return "chop"
	if harvest_kind != "":
		return "mine"
	if _is_fishing():
		return "fish"
	return ""


# The one-shot for the held tool, played each time Use is pressed. Channels already loop, so they are skipped.
func _play_use_anim() -> void:
	if farm._is_harvesting() or _is_fishing() or placing != "":
		return
	match _active_tool():
		"axe":
			player.play_act("chop", 0.6)
		"pick":
			player.play_act("mine", 0.6)
		"hoe":
			player.play_act("hoe", 0.5)
		"trowel":
			player.play_act("plant", 0.5)
		"hose":
			player.play_act("water", 0.8)
		"rod":
			player.play_act("cast", 0.8)


func _interact() -> void:
	if placing != "":
		if not _tool_press:
			_confirm_placement()
		return
	if farm._is_harvesting():
		farm._stop_harvest("You stop working.")
		return
	if in_cave:
		_interact_cave()
		return
	if _in_village():
		_interact_village()
		return
	if _is_fishing():
		_stop_fishing("You reel in your line.")
		return
	var tile := _tile_in_front()
	# Interior tiles sit outside the farm's bounds, so accept either area.
	if not _in_bounds(tile) and not _in_interior(tile):
		return

	if inside:
		if _tool_press:
			return
		match _kind_at(tile):
			Tile.BED:
				_try_sleep()
			Tile.FIREPLACE:
				firewood._feed_fire()
			Tile.STATION:
				sanity_sys._tidy_house()
			Tile.DESK:
				desk._read_desk()
			Tile.CELLAR:
				_toggle_tab("Cellar")
			Tile.COOLER:
				_toggle_tab("Cooler")
		return

	if fish_spots.has(tile):
		if _need_tool("rod"):
			_start_fishing(tile)
		return

	if rocks.has(tile):
		if _need_tool("pick"):
			_mine(tile)
		return
	if brush.has(tile):
		if not _tool_press:
			_gather(tile)
		return

	var kind: int = map[tile.y][tile.x]
	if kind == Tile.WATER:
		if not _tool_press:
			_drink_pond()
		return
	if kind == Tile.WELL:
		if not _tool_press:
			_toggle_tab("Well")
		return
	if kind == Tile.TREE and _in_big_tree(tile):
		_show_message(BIG_TREE_MESSAGE)
		return
	if kind == Tile.TREE and GROVE_SPOTS.has(tile - Vector2i(BORDER_X, BORDER_Y)):
		if _need_tool("axe"):
			firewood._chop(tile)
		return
	if kind == Tile.CHOPLOG:
		if _tool_press:
			firewood._chop_firewood()
		else:
			_show_message("Stand here with the axe and some wood, then press RT or click to split firewood.")
		return
	if kind == Tile.WOODSTORE:
		if not _tool_press:
			_toggle_tab("Woodstore")
		return
	# Panels, stores and the fallow message are hand actions. Tools work the ground and trees only.
	if _tool_press and kind != Tile.SOIL:
		return
	if kind == Tile.HOUSE:
		_toggle_tab("House")
		return
	if kind == Tile.STALL:
		stall._open_stall()
		return
	if kind == Tile.COOP:
		_toggle_tab("Coop")
		return
	if kind == Tile.BARN:
		_toggle_tab("Barn")
		return
	if kind == Tile.CELLAR:
		_toggle_tab("Cellar")
		return
	if kind == Tile.COOLER:
		_toggle_tab("Cooler")
		return
	if kind == Tile.FURNACE:
		_toggle_tab("Furnace")
		return
	if kind == Tile.SMOKEHOUSE:
		_toggle_tab("Smokehouse")
		return
	if kind == Tile.FALLOW:
		_show_message("Overgrown. Reach Farming level 2 to clear this plot.")
		return
	if kind != Tile.SOIL:
		return

	if crops.has(tile):
		if crops[tile]["stage"] >= MAX_STAGE:
			if _need_tool("hoe"):
				farm._harvest(tile)
		elif int(crops[tile].get("watered_day", 0)) == day:
			_show_message("Already watered today. It isn't ready yet.")
		elif _need_tool("hose"):
			farm._water_crop(tile)
	elif _need_tool("trowel"):
		farm._plant(tile)

	queue_redraw()


# --- Desk games ---
# Finishing a game at the desk entertains you for that day. A day without one costs a little
# of the sanity limit, down to BOREDOM_MAX_LOSS. Leaving a game unfinished does not count.


# --- Sudoku (4 by 4) ---


# --- Solitaire (one card at a time, to the four foundations) ---


func _gather(tile: Vector2i) -> void:
	play_sfx("gather", 0.05)
	brush.erase(tile)
	materials["sticks"] += 2
	materials["fiber"] += 1
	stats["gathered"] += 1
	var found := "sticks and fiber"
	if randf() < 0.34:
		materials["resin"] += 1
		found = "sticks, fiber, and resin"
	progression._grant_xp("Bushcrafting", XP_GATHER)
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
	return FISH_SPOT_COUNT + (progression._level("Fishing") - 1) / 2


func _place_key() -> String:
	if in_cave:
		return "cave"
	if inside:
		return "house"
	if _in_village():
		return "village"
	return "farm"


# Each tick rolls for the thing being worked. A better pick or hatchet raises the odds.
# Crows come in from the edge of the view, land on the roof or a tree, sit for a while, then
# hop to another perch or fly off. Each crow has a ground position and an altitude: its shadow
# sits on the ground below it and shrinks and fades as it climbs. Only the farm has them.
const CROW_FLY_ALT := 70.0
const CROW_ALT_SPEED := 60.0
var roost_perches: Array = []   # perches in the great tree's crown, each {ground, alt}
var roost_timer := 0.0          # seconds until the next crow comes home to the roost
var roost_lights: Array = []    # one red PointLight2D per roost perch

func _build_crows() -> void:
	crow_layer = Node2D.new()
	crow_layer.draw.connect(_draw_crow_layer)
	crow_layer.visible = false
	add_child(crow_layer)
	crow_perches.clear()
	var house := Rect2(Vector2(_world_tile(HOUSE_IX, HOUSE_IY)) * PX, Vector2(HOUSE_W, HOUSE_H) * PX)
	for i in 2:
		crow_perches.append({"ground": Vector2(house.position.x + house.size.x * (0.3 + 0.4 * i), house.position.y + house.size.y), "alt": PX * 2.6})
	for y in MAP_H:
		for x in MAP_W:
			if map[y][x] == Tile.TREE and not _in_big_tree(Vector2i(x, y)):
				crow_perches.append({"ground": Vector2((x + 0.5) * PX, (y + 0.8) * PX), "alt": PX * 1.5})
	# The great tree's crown: a few perches spread across the top, where the crows roost at night.
	roost_perches.clear()
	var base := _big_tree_base()
	for o in [Vector2(-0.8, 0.1), Vector2(-0.25, -0.05), Vector2(0.35, 0.12), Vector2(0.85, 0.0)]:
		roost_perches.append({"ground": base + o * PX, "alt": PX * ROOST_ALT})
	# A faint red light at each perch, lit only while a crow roosts there, so the red eyes show in the dark.
	for light in roost_lights:
		(light as Node).queue_free()
	roost_lights.clear()
	var glow := GradientTexture2D.new()
	glow.width = 64
	glow.height = 64
	glow.fill = GradientTexture2D.FILL_RADIAL
	glow.fill_from = Vector2(0.5, 0.5)
	glow.fill_to = Vector2(1.0, 0.5)
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(0, 0, 0, 0))
	glow.gradient = grad
	for rp in roost_perches:
		var light := PointLight2D.new()
		light.texture = glow
		light.color = Color(1.0, 0.2, 0.15)
		light.energy = 0.8
		light.texture_scale = 0.9
		light.enabled = false
		light.position = (rp["ground"] as Vector2) + Vector2(0, -float(rp["alt"]) - PX * 0.2)
		add_child(light)
		roost_lights.append(light)


# Each roost light is on while a crow sits or is coming in to that perch.
func _set_roost_lights() -> void:
	for i in roost_lights.size():
		var lit := false
		for c in crows:
			if c.has("slot") and int(c["slot"]) == i and str(c["state"]) != "fly_out":
				lit = true
		(roost_lights[i] as PointLight2D).enabled = lit


func _update_crows(delta: float) -> void:
	var on_farm := world_started and not inside and not in_cave and not _in_village()
	if crow_layer == null:
		return
	if not on_farm:
		crows.clear()
		crow_layer.visible = false
		_set_roost_lights()
		return
	crow_layer.visible = true
	var view := get_viewport_rect().size / camera.zoom
	var centre := camera.get_screen_center_position()
	var night := current_hour >= ROOST_HOUR
	# At night the crows come home to the great tree, one at a time. In the morning the roost flies off.
	if night and not roost_perches.is_empty():
		roost_timer -= delta
		var roosting := 0
		var taken: Array = []
		for c in crows:
			if c.has("slot") and str(c["state"]) != "fly_out":
				roosting += 1
				taken.append(int(c["slot"]))
		if roost_timer <= 0.0 and roosting < ROOST_SIZE:
			roost_timer = randf_range(3.0, 8.0)
			for i in roost_perches.size():
				if taken.has(i):
					continue
				var side := -1.0 if randf() < 0.5 else 1.0
				var start := centre + Vector2(side * (view.x * 0.5 + 40.0), randf_range(-view.y * 0.4, view.y * 0.4))
				var rp: Dictionary = roost_perches[i]
				crows.append({"ground": start, "alt": CROW_FLY_ALT, "target": rp["ground"], "target_alt": float(rp["alt"]), "state": "fly_in", "timer": 0.0, "flap": randf() * TAU, "facing": -side, "slot": i})
				break
	elif not night:
		roost_timer = 0.0
		for c in crows:
			if c.has("slot") and str(c["state"]) != "fly_out":
				var g: Vector2 = c["ground"]
				var away := 1.0 if g.x >= centre.x else -1.0
				c["state"] = "fly_out"
				c["target"] = centre + Vector2(away * (view.x * 0.5 + 80.0), -view.y * 0.5 - 60.0)
				c["target_alt"] = CROW_FLY_ALT
	crow_spawn_timer -= delta
	if not night and crow_spawn_timer <= 0.0 and crows.size() < MAX_CROWS and not crow_perches.is_empty():
		crow_spawn_timer = randf_range(10.0, 30.0)
		var side := -1.0 if randf() < 0.5 else 1.0
		var start := centre + Vector2(side * (view.x * 0.5 + 40.0), randf_range(-view.y * 0.4, view.y * 0.4))
		var perch: Dictionary = crow_perches.pick_random()
		crows.append({"ground": start, "alt": CROW_FLY_ALT, "target": perch["ground"], "target_alt": float(perch["alt"]), "state": "fly_in", "timer": 0.0, "flap": randf() * TAU, "facing": -side})
	var keep: Array = []
	for c in crows:
		var state: String = str(c["state"])
		var flying := state == "fly_in" or state == "fly_out" or state == "hop"
		c["flap"] = float(c["flap"]) + delta * (16.0 if flying else 0.0)
		var g: Vector2 = c["ground"]
		var alt := float(c["alt"])
		var gone := false
		if flying:
			var target: Vector2 = c["target"]
			var to := target - g
			var dist := to.length()
			var step := CROW_SPEED * delta
			# High while travelling, then coming down onto the perch.
			var final_alt := float(c["target_alt"])
			var goal_alt := final_alt if dist < 40.0 else CROW_FLY_ALT
			alt = move_toward(alt, goal_alt, CROW_ALT_SPEED * delta)
			if dist <= step:
				g = target
				if absf(alt - final_alt) < 1.0:
					if state == "fly_out":
						gone = true
					elif c.has("slot"):
						# Roosting crows stay put until morning, with no timer.
						c["state"] = "roost"
					else:
						c["state"] = "perched"
						c["timer"] = randf_range(8.0, 30.0)
			else:
				g += to.normalized() * step
				if absf(to.x) > 0.5:
					c["facing"] = signf(to.x)
		elif state == "perched":
			alt = move_toward(alt, float(c["target_alt"]), CROW_ALT_SPEED * delta)
			c["timer"] = float(c["timer"]) - delta
			if float(c["timer"]) <= 0.0:
				if randf() < 0.4:
					var perch: Dictionary = crow_perches.pick_random()
					c["state"] = "hop"
					c["target"] = perch["ground"]
					c["target_alt"] = float(perch["alt"])
				else:
					var away := -1.0 if float(c["facing"]) < 0.0 else 1.0
					c["state"] = "fly_out"
					c["target"] = centre + Vector2(away * (view.x * 0.5 + 80.0), -view.y * 0.5 - 60.0)
					c["target_alt"] = CROW_FLY_ALT
		c["ground"] = g
		c["alt"] = alt
		if not gone:
			keep.append(c)
	crows = keep
	_set_roost_lights()
	crow_layer.queue_redraw()


# A wing is a thin triangle, and at some flap angles its three points line up, which the triangulator
# rejects. Nudge the middle point off the line in that case.
func _wing_shape(a: Vector2, b: Vector2, c: Vector2) -> PackedVector2Array:
	for nudge in [Vector2(0, 0.6), Vector2(0.6, 0), Vector2(0, -0.6)]:
		if absf((b - a).cross(c - a)) >= 0.6:
			break
		b += nudge
	return PackedVector2Array([a, b, c])


func _draw_crow_layer() -> void:
	# Shadows first, on the ground under each crow, so they sit beneath everything else.
	for c in crows:
		var alt := float(c["alt"])
		var fade := clampf(1.0 - alt / 150.0, 0.1, 1.0)
		var w := 5.0 + alt * 0.06
		crow_layer.draw_colored_polygon(FarmArt.ellipse(c["ground"], w, w * 0.42), Color(0.02, 0.03, 0.02, 0.38 * fade))
	var ink := Color("1c1a22")
	var wing_near := Color("2e2b38")
	var wing_far := Color("16141c")
	for c in crows:
		var facing := float(c["facing"])
		var st := str(c["state"])
		var perched := st == "perched" or st == "roost"
		var p: Vector2 = (c["ground"] as Vector2) + Vector2(0, -float(c["alt"]))
		var flap := sin(float(c["flap"])) * (0.6 if st == "hop" else 1.0)
		if perched:
			crow_layer.draw_line(p + Vector2(-1.5, 3.5), p + Vector2(-1.5, 6.0), ink, 1.2)
			crow_layer.draw_line(p + Vector2(1.5, 3.5), p + Vector2(1.5, 6.0), ink, 1.2)
		var root := p + Vector2(-facing * 1.0, -1.5)
		# Far wing sits behind the body, a shade darker, so the wings read as two.
		var far_tip: Vector2
		var near_tip: Vector2
		if perched:
			# Not level with the wing root, or the wing becomes a flat sliver the triangulator rejects.
			far_tip = root + Vector2(-facing * 4.5, 1.0)
			near_tip = root + Vector2(-facing * 6.0, 1.8)
		else:
			far_tip = root + Vector2(-facing * 3.0, -2.0 + flap * 6.5)
			near_tip = root + Vector2(-facing * 6.0, -2.0 + flap * 7.5)
		crow_layer.draw_colored_polygon(_wing_shape(root + Vector2(facing * 1.5, -0.5), far_tip, root + Vector2(-facing * 1.5, 0.5)), wing_far)
		# Tail, body, head and beak.
		crow_layer.draw_colored_polygon(PackedVector2Array([p + Vector2(-facing * 4.0, -0.5), p + Vector2(-facing * 10.0, 1.5), p + Vector2(-facing * 4.0, 2.5)]), ink)
		crow_layer.draw_colored_polygon(FarmArt.ellipse(p, 6.0, 3.6), ink)
		var head := p + Vector2(facing * 4.8, -3.2)
		crow_layer.draw_circle(head, 2.8, ink)
		crow_layer.draw_colored_polygon(PackedVector2Array([head + Vector2(facing * 2.2, -0.9), head + Vector2(facing * 6.8, 0.4), head + Vector2(facing * 2.2, 1.2)]), Color("3b3428"))
		# Roosting crows, the ones that come home to the great tree, have red eyes that glow a little.
		var roost_crow: bool = c.has("slot")
		if roost_crow:
			crow_layer.draw_circle(head + Vector2(facing * 1.0, -0.6), 2.2, Color(1.0, 0.1, 0.08, 0.3))
		crow_layer.draw_circle(head + Vector2(facing * 1.0, -0.6), 0.75, Color(1.0, 0.18, 0.14) if roost_crow else Color(0.92, 0.86, 0.5))
		# Near wing in front of the body.
		crow_layer.draw_colored_polygon(_wing_shape(root + Vector2(facing * 2.0, 0.0), near_tip, root + Vector2(-facing * 2.0, 0.8)), wing_near)
		crow_layer.draw_line(root + Vector2(facing * 1.0, 0.0), near_tip.lerp(root, 0.35), Color(0.45, 0.45, 0.55, 0.45), 0.8)


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
	if not stall._pack_room(int(inventory["fish"]), 1):
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
	if not stall._pack_room(int(inventory["fish"]), 1):
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


func _rod_bonus() -> float:
	var total := 0.0
	for i in int(tool_tier["rod"]):
		total += float(TOOL_TIERS["rod"][i]["bonus"])
	return total


func _fish_roll() -> void:
	stats["fished"] += 1
	var chance := clampf(FISH_BASE_CHANCE + FISH_CHANCE_PER_LEVEL * float(progression._level("Fishing") - 1) + _rod_bonus(), 0.0, FISH_CHANCE_CAP)
	if randf() < chance:
		stats["caught"] += 1
		inventory["fish"] += 1
		progression._grant_xp("Fishing", XP_FISH)
		_show_message("You hook a fish! +%d Fishing XP" % XP_FISH)
	else:
		_show_message("Nothing yet. Keep still.")


func _need_label(key: String) -> String:
	return key.replace("_", " ")


func _spend_recipe_input(key: String, n: int) -> void:
	if key == "turnips":
		inventory["crops"] -= n
	elif materials.has(key):
		materials[key] -= n
	else:
		inventory[key] -= n


func _food_stats_text(f: Dictionary) -> String:
	return "Restores %d food, %d sanity, %d HP." % [int(Foods.food_restore(f)), int(Foods.sanity_restore(f)), Foods.hp_restore(f)]


func _can_repair_well() -> bool:
	return not well_repaired and materials["wood"] >= WELL_REPAIR["wood"] \
		and materials["fiber"] >= WELL_REPAIR["fiber"] and progression._level("Carpentry") >= WELL_REPAIR["level"]


func _repair_well() -> void:
	if not _can_repair_well():
		_show_message("The pump needs %d wood, %d fiber, and Carpentry %d to repair." % [WELL_REPAIR["wood"], WELL_REPAIR["fiber"], WELL_REPAIR["level"]])
		return
	materials["wood"] -= WELL_REPAIR["wood"]
	materials["fiber"] -= WELL_REPAIR["fiber"]
	well_repaired = true
	play_sfx("repair")
	well_water = WELL_CAPACITY
	stats["pump"] = 1
	progression._grant_xp("Carpentry", XP_REPAIR)
	_show_message("You rebuild the pump and the water comes up cold. +%d Carpentry XP" % XP_REPAIR)
	queue_redraw()


func _can_attach_hose() -> bool:
	return well_repaired and not hose_attached and materials["fiber"] >= HOSE_COST["fiber"] \
		and materials["resin"] >= HOSE_COST["resin"]


# The hose runs from the pump to every plot on the farm, so it waters any crop you face.
func _attach_hose() -> void:
	if not _can_attach_hose():
		_show_message("The hose needs %d fiber and %d resin, and the pump has to be working." % [HOSE_COST["fiber"], HOSE_COST["resin"]])
		return
	materials["fiber"] -= HOSE_COST["fiber"]
	materials["resin"] -= HOSE_COST["resin"]
	hose_attached = true
	stats["hose"] = 1
	_show_message("The hose is on. It reaches every plot, so face a crop and press Space to water it.")


func _drink_well() -> void:
	if not well_repaired:
		_show_message("The pump is seized. Repair it from this panel first.")
		return
	if water >= 100.0:
		_show_message("You're not thirsty.")
		return
	water = minf(100.0, water + DRINK_WELL)
	play_sfx("drink", 0.05)
	stats["drank"] += 1
	_show_message("Cold water from the pump. Water %d/100" % water)


# The picture stage (0 to MAX_STAGE) for a crop that has been watered this many days.
func _stage_for(kind: String, days: int) -> int:
	return mini(MAX_STAGE, days * MAX_STAGE / int(CROP_GROW_DAYS[kind]))


# What the preserve recipes take as input. "crops" means turnips or pumpkins.
func _drink_pond() -> void:
	if water >= 100.0:
		_show_message("You're not thirsty.")
		return
	water = minf(100.0, water + POND_WATER)
	play_sfx("drink", 0.05)
	stats["drank"] += 1
	_show_message("You drink from the pond. Cold and muddy, but it helps. Water %d/100" % water)


# Needs are checked each hour. While one is empty, HP drains slowly. Sleeping in bed restores warmth.
func _update_needs(dh: float) -> void:
	var temp := _temperature()
	var thirst := WATER_PER_HOUR * (HOT_WATER_MULT if temp >= HOT_TEMP else 1.0)
	food = maxf(0.0, food - FOOD_PER_HOUR * dh)
	water = maxf(0.0, water - thirst * dh)
	var was_lit := firewood._fire_lit()
	fire_hours = maxf(0.0, fire_hours - dh)
	if was_lit and not firewood._fire_lit():
		_show_message("The fire has gone out.")
	# With no fire the house is as cold as outside, so it only warms on mild days.
	if inside and firewood._fire_lit():
		var gain := WARMTH_INDOORS if house_stage >= 2 else WARMTH_INDOORS_COLD
		warmth = minf(100.0, warmth + gain * dh)
	elif temp >= COLD_TEMP:
		warmth = minf(100.0, warmth + WARMTH_OUTDOORS * dh)
	else:
		var frost := 1.6 if sanity_sys._event_active("frost") else 1.0
		warmth = maxf(0.0, warmth - (COLD_TEMP - temp) * WARMTH_LOSS * frost * dh)
	if food <= 0.0 or water <= 0.0 or warmth <= 0.0:
		starve_timer += dh
		if starve_timer >= NEED_HARM_HOURS:
			starve_timer -= NEED_HARM_HOURS
			hp -= 1
			_show_message(_empty_need_text())
			if hp <= 0:
				_fallen()
	else:
		starve_timer = 0.0


func _empty_need_text() -> String:
	if food <= 0.0:
		return "You haven't eaten in too long. You feel weaker. HP %d/%d" % [hp, max_hp()]
	if water <= 0.0:
		return "Your throat is dry. You feel weaker. HP %d/%d" % [hp, max_hp()]
	return "You're freezing, and your hands won't close. HP %d/%d" % [hp, max_hp()]


# Temperature in Fahrenheit: the season's average, a daily swing that is coldest near dawn and warmest
# in the evening, and the day's weather.
func _temperature() -> float:
	var season := _season_of(_calendar_date(day)["month"])
	var base: float = SEASON_TEMP[season]
	var swing := sin((current_hour - 12.0) / 24.0 * TAU)
	return base + 7.0 * swing + float(WEATHER_TEMP.get(weather_kind, 0.0))


# --- Achievements ------------------------------------------------------------


func _achievement_row(a: Dictionary) -> Dictionary:
	var done: bool = achievements_done.has(a["id"])
	var shown := mini(progression._stat_value(a["stat"]), a["goal"])
	return {
		"name": "%s%s" % [a["title"], "   (done)" if done else ""],
		"value": "%d/%d" % [shown, a["goal"]],
		"progress": float(shown) / float(a["goal"]),
		"note": "%s  Reward: %s" % [a["text"], progression._reward_text(a["reward"])],
	}

# --- Pack and bags -----------------------------------------------------------

# Like items stack in the pack up to STACK_SIZE to a slot. Each kind takes as many slots as its stacks need.
const STACK_SIZE := 28


func _slots_for(count: int) -> int:
	return ceili(float(maxi(0, count)) / float(STACK_SIZE))


func _can_upgrade_bag() -> bool:
	return bag_tier < BAG_TIERS.size() and _can_afford(BAG_TIERS[bag_tier])


func _upgrade_bag() -> void:
	if not _can_upgrade_bag():
		_show_message("You can't afford the next bag yet. Needs %s." % stall._price_text(BAG_TIERS[bag_tier]))
		return
	var tier: Dictionary = BAG_TIERS[bag_tier]
	_pay(tier)
	bag_tier += 1
	_show_message("You get a %s. Your pack now holds %d items." % [tier["name"], stall._pack_capacity()])


# --- Money and costs ---------------------------------------------------------

func _can_afford(cost: Dictionary) -> bool:
	if money < int(cost.get("coins", 0)):
		return false
	if progression._level("Carpentry") < int(cost.get("level", 1)):
		return false
	for key in cost.keys():
		if key == "coins" or key == "level":
			continue
		if int(materials.get(key, 0)) < int(cost[key]):
			return false
	return true


func _pay(cost: Dictionary) -> void:
	money -= int(cost.get("coins", 0))
	for key in cost.keys():
		if key == "coins" or key == "level":
			continue
		materials[key] -= int(cost[key])


# --- Stall -------------------------------------------------------------------


# --- Storage -----------------------------------------------------------------

func _build_storage(which: String) -> void:
	var cost: Dictionary = CELLAR_COST if which == "cellar" else COOLER_COST
	if not _can_afford(cost):
		_show_message("You can't build that yet. Needs %s." % stall._price_text(cost))
		return
	_pay(cost)
	if which == "cellar":
		cellar_built = true
		_show_message("The root cellar is dug beside the house. It holds %d crops." % CELLAR_CAP)
	else:
		cooler_built = true
		_show_message("The cooler is built beside the house. It keeps %d fish fresh." % COOLER_CAP)
	_build_interior()
	queue_redraw()


func _store_fish() -> void:
	var amount := mini(int(inventory["fish"]), COOLER_CAP - cooler_stock)
	if amount <= 0:
		_show_message("Nothing to store, or the cooler is full.")
		return
	inventory["fish"] -= amount
	cooler_stock += amount
	_show_message("You store %d fish in the cooler." % amount)


func _take_fish() -> void:
	var amount := mini(cooler_stock, stall._pack_free())
	if amount <= 0:
		_show_message("Your pack is full, or the cooler is empty.")
		return
	cooler_stock -= amount
	inventory["fish"] += amount
	_show_message("You take %d fish from the cooler." % amount)


# --- Trade, cellar, and cooler panels ------------------------------------------


# --- Smokehouse and preserving ---------------------------------------------

func _build_smokehouse() -> void:
	if not _can_afford(SMOKEHOUSE_COST):
		_show_message("You can't build that yet. Needs %s." % stall._price_text(SMOKEHOUSE_COST))
		return
	_pay(SMOKEHOUSE_COST)
	smokehouse_built = true
	_build_interior()
	_show_message("The smokehouse is built beside the house. Smoke fish and preserve crops there.")
	queue_redraw()


func _storage_label(tile: int) -> String:
	if tile == Tile.COOLER:
		return "Cooler"
	if tile == Tile.SMOKEHOUSE:
		return "Smoke"
	if tile == Tile.FURNACE:
		return "Furnace"
	return "Cellar"


# --- Forestry and tools -------------------------------------------------------


func _apply_grove() -> void:
	for spot in GROVE_SPOTS:
		var w := _world_tile(spot.x, spot.y)
		map[w.y][w.x] = Tile.GRASS if grove_felled.has(w) else Tile.TREE


func _felled_to_array() -> Array:
	var arr: Array = []
	for tile in grove_felled.keys():
		arr.append([tile.x, tile.y])
	return arr


func _has_materials(cost: Dictionary) -> bool:
	for key in cost.keys():
		if int(materials.get(key, 0)) < int(cost[key]):
			return false
	return true


func _tool_desc(kind: String, tier: Dictionary, have: int) -> String:
	if kind == "rod":
		var now := "You have no rod yet." if have == 0 else "You have the %s." % _tool_name("rod")
		return "%s Adds %d%% to your catch chance." % [now, int(float(tier["bonus"]) * 100.0)]
	return "Your %s is %s. This is the next tier." % [kind, _tool_name(kind)]


func _tool_name(kind: String) -> String:
	var have := int(tool_tier[kind])
	if have == 0:
		return "none"
	return str(TOOL_TIERS[kind][have - 1]["name"])


func _can_craft_tool(kind: String) -> bool:
	var have := int(tool_tier[kind])
	var tiers: Array = TOOL_TIERS[kind]
	if have >= tiers.size():
		return false
	var tier: Dictionary = tiers[have]
	if progression._level(str(tier["skill"])) < int(tier["level"]):
		return false
	return _has_materials(tier["cost"])


func _craft_tool(kind: String) -> void:
	if not _can_craft_tool(kind):
		_show_message("You need the materials and skill level for the next %s." % kind)
		return
	progression._bump("crafted")
	var tier: Dictionary = TOOL_TIERS[kind][int(tool_tier[kind])]
	for mat in tier["cost"].keys():
		materials[mat] -= int(tier["cost"][mat])
	tool_tier[kind] += 1
	progression._grant_xp(str(tier["skill"]), 10)
	_show_message("You make a %s. +10 %s XP" % [tier["name"], tier["skill"]])


# --- Mining --------------------------------------------------------------------

# A monthly refill leaves a spot empty while a crop is growing on it, so the crop is never buried.
func _fill_rocks(keep_clear: bool = false) -> void:
	rocks.clear()
	for spot in ROCK_SPOTS:
		var t := _world_tile(spot.x, spot.y)
		if keep_clear and crops.has(t):
			continue
		rocks[t] = true


func _mine(tile: Vector2i) -> void:
	# Breaking a rock keeps rolling each tick until it gives way. Moving away stops it.
	farm._start_harvest("mine", tile)
	_show_message("You start working the rock.")


func _finish_mine(tile: Vector2i) -> void:
	play_sfx("strike", 0.08)
	rocks.erase(tile)
	var pick := int(tool_tier["pick"])
	var amount := 2 if pick >= 1 else 1
	materials["stone"] += amount
	var found := "%d stone" % amount
	if pick >= 1 and progression._level("Mining") >= ORE_MINING_LEVEL and randf() < ORE_CHANCE:
		materials["copper_ore"] += 1
		found += " and copper ore"
	stats["mined"] += 1
	progression._grant_xp("Mining", XP_MINE)
	_show_message("You break the rock. +%s. +%d Mining XP" % [found, XP_MINE])
	queue_redraw()


func _tiles_to_array(tiles: Dictionary) -> Array:
	var arr: Array = []
	for tile in tiles.keys():
		arr.append([tile.x, tile.y])
	return arr


# --- Smithing -------------------------------------------------------------------


func _build_woodshed() -> void:
	if not (smokehouse_built or furnace_built):
		_show_message("Build the smokehouse or the furnace first. The workshop is where the firewood goes.")
		return
	if not _can_afford(WOODSHED_COST):
		_show_message("You can't build that yet. Needs %s." % stall._price_text(WOODSHED_COST))
		return
	_pay(WOODSHED_COST)
	woodshed_built = true
	_build_interior()
	_show_message("The firewood store and chopping log stand in the workshop. Split wood there, then feed the hearth.")
	queue_redraw()
func _build_furnace() -> void:
	if not _can_afford(FURNACE_COST):
		_show_message("You can't build that yet. Needs %s." % stall._price_text(FURNACE_COST))
		return
	_pay(FURNACE_COST)
	furnace_built = true
	_build_interior()
	_show_message("The furnace is built beside the house. Smelt ore into bars there.")
	queue_redraw()


func _can_smelt(kind: String) -> bool:
	if not furnace_built:
		return false
	if progression._level("Smithing") < int(SMELT_LEVEL[kind]):
		return false
	return int(materials[kind + "_ore"]) >= 1 and int(materials["wood"]) >= 1


func _smelt(kind: String) -> void:
	if not furnace_built:
		_show_message("Build a furnace from the House panel first.")
		return
	if not _can_smelt(kind):
		_show_message("You need %s ore, a piece of wood, and Smithing %d." % [kind, int(SMELT_LEVEL[kind])])
		return
	materials[kind + "_ore"] -= 1
	materials["wood"] -= 1
	materials[kind + "_bar"] += 1
	progression._grant_xp("Smithing", XP_SMELT)
	_show_message("You smelt a %s bar. +%d Smithing XP" % [kind, XP_SMELT])


# --- Ranged combat and ammunition ----------------------------------------------

func _can_fletch(kind: String) -> bool:
	var ammo: Dictionary = AMMO[kind]
	if progression._level(str(ammo["skill"])) < int(ammo["level"]):
		return false
	return _has_materials(ammo["cost"])


func _craft_ammo(kind: String) -> void:
	if not _can_fletch(kind):
		_show_message("You need the materials and skill level to make %s." % kind)
		return
	var ammo: Dictionary = AMMO[kind]
	for mat in ammo["cost"].keys():
		materials[mat] -= int(ammo["cost"][mat])
	materials[kind] += int(ammo["yield"])
	progression._grant_xp(str(ammo["skill"]), 6)
	_show_message("You make %d %s. +6 %s XP" % [int(ammo["yield"]), kind, ammo["skill"]])


func _fire(weapon: String) -> void:
	if swing_cool > 0.0:
		return
	var item: Dictionary = GEAR_ITEMS[weapon]
	var ammo := str(item["ammo"])
	if int(materials[ammo]) < 1:
		_show_message("You're out of %s. Make more from the Craft panel." % ammo)
		return
	materials[ammo] -= 1
	swing_cool = float(item["cool"])
	player.play_act("fire", 0.35)
	var dir: Vector2 = player.facing.normalized()
	shots.append({"pos": player.position, "vel": dir * SHOT_SPEED, "life": SHOT_LIFE, "dmg": int(item["dmg"])})
	queue_redraw()


func _update_shots(delta: float) -> void:
	if not _in_village():
		shots.clear()
		return
	if shots.is_empty():
		return
	for shot in shots.duplicate():
		var pos: Vector2 = shot["pos"] + shot["vel"] * delta
		shot["pos"] = pos
		shot["life"] = float(shot["life"]) - delta
		var hit := false
		for foe in foes.duplicate():
			var gap: Vector2 = foe["pos"] - pos
			if gap.length() < PX * 0.45:
				_shot_hits(foe, int(shot["dmg"]))
				hit = true
				break
		if hit or float(shot["life"]) <= 0.0 or _is_blocked_world(pos):
			shots.erase(shot)
	queue_redraw()


func _shot_hits(foe: Dictionary, amount: int) -> void:
	foe["hp"] = int(foe["hp"]) - amount
	foe["flash"] = 0.2
	progression._grant_xp("Combat", XP_HIT)
	if int(foe["hp"]) <= 0:
		_kill_foe(foe)
	else:
		_show_message("Your shot hits the %s for %d." % [str(foe["kind"]), amount])


# --- The Ashford quarry ------------------------------------------------------------

func _fill_quarry() -> void:
	quarry.clear()
	for spot in ASHFORD_QUARRY:
		quarry[ASHFORD_ORIGIN + spot] = true


func _quarry(tile: Vector2i) -> void:
	var pick := int(tool_tier["pick"])
	if pick < 1:
		_show_message("The quarry rock is too hard for your hands. Craft a stone pick from the Craft panel.")
		return
	farm._start_harvest("quarry", tile)
	_show_message("You start working the quarry rock.")


func _finish_quarry(tile: Vector2i) -> void:
	var pick := int(tool_tier["pick"])
	quarry.erase(tile)
	var kind := "copper_ore" if progression._level("Mining") >= 3 else "stone"
	if progression._level("Mining") >= 5 and pick >= 2 and randf() < 0.5:
		kind = "iron_ore"
	materials[kind] += 1
	stats["mined"] += 1
	progression._grant_xp("Mining", XP_MINE)
	_show_message("You work the quarry rock. +1 %s. +%d Mining XP" % [kind.replace("_", " "), XP_MINE])
	queue_redraw()


# --- The world ----------------------------------------------------------------

# Builds the whole land from a seed: forest, lakes, and open ground, then stamps
# Lowmere and Ashford in and lays the road between them and the portal.
func _generate_world() -> void:
	var forest := FastNoiseLite.new()
	forest.seed = WORLD_SEED
	forest.frequency = 0.02
	forest.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	var lakes := FastNoiseLite.new()
	lakes.seed = WORLD_SEED + 1
	lakes.frequency = 0.03
	lakes.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	world = PackedByteArray()
	world.resize(WORLD_W * WORLD_H)
	for y in WORLD_H:
		for x in WORLD_W:
			var t := Tile.GRASS
			if x < 2 or y < 2 or x >= WORLD_W - 2 or y >= WORLD_H - 2:
				t = Tile.TREE
			elif lakes.get_noise_2d(x, y) > 0.55:
				t = Tile.WATER
			elif forest.get_noise_2d(x, y) > 0.35:
				t = Tile.TREE
			world[y * WORLD_W + x] = t
	for x in range(PORTAL_TILE.x, ASHFORD_ORIGIN.x + VILLAGE_W):
		world[ROAD_Y * WORLD_W + x] = Tile.PATH
	_plan_towns()
	_stamp_village(LOWMERE_ORIGIN, _build_zone_map(VILLAGE_HOUSES, VILLAGE_WATER, 26, true))
	_stamp_village(ASHFORD_ORIGIN, _build_zone_map(ASHFORD_HOUSES, ASHFORD_WATER, 24, false))
	_layout_towns()
	world[PORTAL_TILE.y * WORLD_W + PORTAL_TILE.x] = Tile.PORTAL
	_build_world_minimap()
	_generate_cave()


# Copies a village's houses, water, gates and trees into the world. Its open ground and
# its outer edge are left as the land already is, so the town sits in the forest
# instead of inside a wall of trees. Its gates become road.
func _stamp_village(origin: Vector2i, local: Array) -> void:
	for y in VILLAGE_H:
		for x in VILLAGE_W:
			var k: int = local[y][x]
			var edge := x == 0 or y == 0 or x == VILLAGE_W - 1 or y == VILLAGE_H - 1
			if k == Tile.GATE:
				k = Tile.PATH
			elif k == Tile.GRASS or (k == Tile.TREE and edge):
				continue
			var idx := (origin.y + y) * WORLD_W + origin.x + x
			# Roads stay walkable: a building never covers a road tile.
			if world[idx] == Tile.PATH and k != Tile.PATH:
				continue
			world[idx] = k


# The whole land as a small picture for the minimap: one pixel per 4 tiles, each pixel
# showing the tile at its centre. Rebuilt when the land changes (the campsite moves).
func _build_world_minimap() -> void:
	var step := int(round(1.0 / Minimap.WORLD_PX_PER_TILE))
	var w := WORLD_W / step
	var h := WORLD_H / step
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var k: int = world[(y * step + step / 2) * WORLD_W + x * step + step / 2]
			var c: Color = TILE_COLORS[k]
			img.set_pixel(x, y, c)
	world_map_tex = ImageTexture.create_from_image(img)


# Sizes the minimap box for whichever map it is showing. Only changes when needed.
func _place_minimap(mini_size: Vector2) -> void:
	if minimap.custom_minimum_size == mini_size:
		return
	minimap.custom_minimum_size = mini_size
	minimap.offset_left = -(mini_size.x + 12.0)
	minimap.offset_right = -12.0
	minimap.offset_top = 12.0
	minimap.offset_bottom = 12.0 + mini_size.y


# --- The mining cave ---------------------------------------------------------

# Fills the cave for today: rock walls, then carved floor from a few random walks out of
# the entrance, then copper and iron ore set into the walls, then the creatures. The same
# day always gives the same cave, and the next day gives a new one.
func _generate_cave() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = CAVE_SEED + day * 7919
	cave = []
	for y in CAVE_H:
		var row: Array = []
		for x in CAVE_W:
			row.append(Tile.WALL)
		cave.append(row)
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for walker in 8:
		var p := CAVE_START
		var dir: Vector2i = dirs[rng.randi() % dirs.size()]
		for step in rng.randi_range(60, 120):
			if _cave_inside(p):
				cave[p.y][p.x] = Tile.FLOOR
			if rng.randf() < 0.3:
				dir = dirs[rng.randi() % dirs.size()]
			var nxt := p + dir
			if _cave_inside(nxt):
				p = nxt
			else:
				dir = -dir
	cave[CAVE_START.y][CAVE_START.x] = Tile.FLOOR
	cave[CAVE_EXIT_TILE.y][CAVE_EXIT_TILE.x] = Tile.CAVE_EXIT
	for y in range(1, CAVE_H - 1):
		for x in range(1, CAVE_W - 1):
			if cave[y][x] != Tile.WALL or not _touches_cave_floor(Vector2i(x, y)):
				continue
			var depth := absi(x - CAVE_START.x) + absi(y - CAVE_START.y)
			var roll := rng.randf()
			if depth >= CAVE_IRON_DEPTH and roll < 0.04:
				cave[y][x] = Tile.ORE_IRON
			elif roll < 0.09:
				cave[y][x] = Tile.ORE_COPPER
	var spots: Array = []
	for y in range(1, CAVE_H - 1):
		for x in range(1, CAVE_W - 1):
			if cave[y][x] == Tile.FLOOR and absi(x - CAVE_START.x) + absi(y - CAVE_START.y) >= CAVE_MIN_CREATURE_DEPTH:
				spots.append(Vector2i(x, y))
	cave_spawns = []
	for kind in CAVE_CREATURES:
		if spots.is_empty():
			break
		var pick: Vector2i = spots[rng.randi() % spots.size()]
		spots.erase(pick)
		cave_spawns.append({"kind": kind, "tile": pick})


func _cave_inside(t: Vector2i) -> bool:
	return t.x >= 2 and t.y >= 2 and t.x <= CAVE_W - 3 and t.y <= CAVE_H - 3


func _touches_cave_floor(t: Vector2i) -> bool:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = t + d
		if cave[n.y][n.x] == Tile.FLOOR:
			return true
	return false


func _enter_cave() -> void:
	in_cave = true
	inside = false
	_stop_fishing("")
	swing_time = 0.0
	# The cave is laid out fresh each day, so yesterday's mined ore is gone.
	if cave_mined_day != day:
		cave_mined.clear()
		cave_mined_day = day
	_generate_cave()
	for tile in cave_mined.keys():
		cave[tile.y][tile.x] = Tile.FLOOR
	player.position = _tile_center(CAVE_START.x, CAVE_START.y)
	_set_bounds()
	_spawn_foes()
	queue_redraw()
	_show_message("You step into the cave. It smells of damp stone, and something skitters in the dark.")


func _leave_cave() -> void:
	in_cave = false
	foes = []
	swing_time = 0.0
	player.position = _tile_center(BORDER_X + 1, BORDER_Y + INNER_H / 2)
	_set_bounds()
	queue_redraw()
	_show_message("You step back out into the light.")


func _interact_cave() -> void:
	var tile := _tile_in_front()
	var kind := _kind_at(tile)
	if kind == Tile.ORE_COPPER or kind == Tile.ORE_IRON:
		if _need_tool("pick"):
			_mine_cave(tile, kind)
		return
	_swing()


# Copper needs a stone pick and Mining 2. Iron needs a copper pick and Mining 5.
func _mine_cave(tile: Vector2i, kind: int) -> void:
	var iron := kind == Tile.ORE_IRON
	var need_pick := 2 if iron else 1
	var need_level := 5 if iron else 2
	var ore := "iron" if iron else "copper"
	if int(tool_tier["pick"]) < need_pick:
		_show_message("The %s ore is too hard for your hands. Craft a %s pick from the Craft panel." % [ore, "copper" if iron else "stone"])
		return
	if progression._level("Mining") < need_level:
		_show_message("You need Mining %d to work %s ore." % [need_level, ore])
		return
	farm._start_harvest("cave_ore", tile)
	_show_message("You start working the %s ore." % ore)


func _finish_cave_ore(tile: Vector2i) -> void:
	var iron := _kind_at(tile) == Tile.ORE_IRON
	var ore := "iron" if iron else "copper"
	cave[tile.y][tile.x] = Tile.FLOOR
	cave_mined[tile] = true
	materials[ore + "_ore"] += 1
	progression._grant_xp("Mining", XP_MINE)
	_show_message("You break the %s ore. +1 %s ore. +%d Mining XP" % [ore, ore, XP_MINE])
	queue_redraw()


func _draw_cave() -> void:
	var view := get_viewport_rect().size / camera.zoom
	var top_left := camera.get_screen_center_position() - view * 0.5
	var x0 := clampi(floori(top_left.x / PX) - 1, 0, CAVE_W - 1)
	var y0 := clampi(floori(top_left.y / PX) - 1, 0, CAVE_H - 1)
	var x1 := clampi(ceili((top_left.x + view.x) / PX) + 1, 0, CAVE_W - 1)
	var y1 := clampi(ceili((top_left.y + view.y) / PX) + 1, 0, CAVE_H - 1)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			draw_rect(_tile_rect(Vector2i(x, y)), TILE_COLORS[cave[y][x]])
	_draw_combat()


# Foes, arrows in flight, and the swing arc. Shared by the world and the cave.
func _draw_combat() -> void:
	for foe in foes:
		var pos: Vector2 = foe["pos"]
		var st: Dictionary = FOES[foe["kind"]]
		var body := Color(str(st["color"]))
		if float(foe["flash"]) > 0.0:
			body = Color("e8e0d0")
		draw_circle(pos, PX * 0.32, body)
		draw_circle(pos + Vector2(-5, -4), 2.5, Color(0.9, 0.1, 0.1))
		draw_circle(pos + Vector2(5, -4), 2.5, Color(0.9, 0.1, 0.1))
		var frac := float(foe["hp"]) / float(st["hp"])
		draw_rect(Rect2(pos + Vector2(-PX * 0.3, -PX * 0.5), Vector2(PX * 0.6 * frac, 3)), Color("c24a4a"))
	for shot in shots:
		var shot_pos: Vector2 = shot["pos"]
		var shot_vel: Vector2 = shot["vel"]
		draw_line(shot_pos - shot_vel.normalized() * PX * 0.5, shot_pos, Color("e8e0c0"), 2.0)
	if swing_time > 0.0:
		draw_arc(player.position, SWING_REACH * PX, swing_dir.angle() - 0.9, swing_dir.angle() + 0.9, 12, Color(1, 1, 0.8, 0.8), 3.0)


# --- Generated towns -----------------------------------------------------------

# Picks where the towns go and carves the roads between them. Runs before the villages
# are stamped. Lowmere and Ashford are hubs too, and a minimum spanning road network
# joins every hub, so the whole land is reachable from the portal.
func _plan_towns() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = TOWN_SEED
	towns = []
	current_town = -1
	var taken: Array[Rect2i] = [TOWN_START_CLEAR, Rect2i(LOWMERE_ORIGIN, Vector2i(VILLAGE_W, VILLAGE_H)), Rect2i(ASHFORD_ORIGIN, Vector2i(VILLAGE_W, VILLAGE_H))]
	var cols := ceili(float(WORLD_W) / TOWN_CELL)
	var rows := ceili(float(WORLD_H) / TOWN_CELL)
	for cy in rows:
		for cx in cols:
			if rng.randf() > TOWN_CHANCE:
				continue
			var pick: Dictionary = _pick_town_kind(rng)
			var w: int = pick["w"]
			var h: int = pick["h"]
			var x := cx * TOWN_CELL + rng.randi_range(4, TOWN_CELL - w - 4)
			var y := cy * TOWN_CELL + rng.randi_range(4, TOWN_CELL - h - 4)
			var rect := Rect2i(x, y, w, h)
			if rect.end.x > WORLD_W - 4 or rect.end.y > WORLD_H - 4:
				continue
			var clash := false
			for other in taken:
				if rect.grow(4).intersects(other):
					clash = true
					break
			if clash:
				continue
			taken.append(rect)
			towns.append({"kind": pick["kind"], "origin": Vector2i(x, y), "w": w, "h": h, "title": _town_title(rng, str(pick["kind"])), "npcs": []})
	var hubs: Array[Vector2i] = [_village_hub(LOWMERE_ORIGIN), _village_hub(ASHFORD_ORIGIN)]
	for town in towns:
		hubs.append(_town_hub(town))
	# Prim's algorithm: each new hub joins by its shortest road to the network so far.
	var n := hubs.size()
	var in_tree: Array = []
	for i in n:
		in_tree.append(i == 0)
	for step in n - 1:
		var best_d := INF
		var best_i := -1
		var best_j := -1
		for i in n:
			if not in_tree[i]:
				continue
			for j in n:
				if in_tree[j]:
					continue
				var d := float(hubs[i].distance_squared_to(hubs[j]))
				if d < best_d:
					best_d = d
					best_i = i
					best_j = j
		if best_j < 0:
			break
		in_tree[best_j] = true
		_carve_road(hubs[best_i], hubs[best_j])


func _pick_town_kind(rng: RandomNumberGenerator) -> Dictionary:
	var total := 0
	for k in TOWN_KINDS:
		total += int(k["weight"])
	var roll := rng.randi_range(1, total)
	for k in TOWN_KINDS:
		roll -= int(k["weight"])
		if roll <= 0:
			return k
	return TOWN_KINDS[0]


func _town_title(rng: RandomNumberGenerator, kind: String) -> String:
	var base: String = TOWN_NAME_START[rng.randi() % TOWN_NAME_START.size()] + TOWN_NAME_END[rng.randi() % TOWN_NAME_END.size()]
	if kind == "castle":
		return base + " Keep"
	if kind == "manor":
		return base + " Manor"
	return base


func _village_hub(origin: Vector2i) -> Vector2i:
	return origin + Vector2i(VILLAGE_W / 2, VILLAGE_GATE.y)


func _town_hub(town: Dictionary) -> Vector2i:
	var origin: Vector2i = town["origin"]
	return origin + Vector2i(int(town["w"]) / 2, int(town["h"]) / 2)


# An L-shaped road of plain path: across, then along.
func _carve_road(a: Vector2i, b: Vector2i) -> void:
	var step_x := 1 if b.x >= a.x else -1
	var x := a.x
	while x != b.x:
		world[a.y * WORLD_W + x] = Tile.PATH
		x += step_x
	var step_y := 1 if b.y >= a.y else -1
	var y := a.y
	while y != b.y:
		world[y * WORLD_W + b.x] = Tile.PATH
		y += step_y
	world[b.y * WORLD_W + b.x] = Tile.PATH


# Lays out every generated town in the world, after the villages are stamped.
func _layout_towns() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = TOWN_SEED + 1
	for i in towns.size():
		_layout_town(i, rng)


# Builds one town in a local grid, then stamps it. A cross of streets runs through the
# middle. Buildings sit in the spaces between them and never cover a road.
func _layout_town(index: int, rng: RandomNumberGenerator) -> void:
	var town: Dictionary = towns[index]
	var w: int = town["w"]
	var h: int = town["h"]
	var kind: String = town["kind"]
	var origin: Vector2i = town["origin"]
	var title: String = town["title"]
	var sx := w / 2
	var sy := h / 2
	var local: Array = []
	var occ: Array = []
	for y in h:
		var row: Array = []
		var orow: Array = []
		for x in w:
			row.append(Tile.GRASS)
			orow.append(false)
		local.append(row)
		occ.append(orow)
	for x in w:
		local[sy][x] = Tile.PATH
		occ[sy][x] = true
	for y in h:
		local[y][sx] = Tile.PATH
		occ[y][sx] = true
	var npcs: Array = []
	if kind == "castle" or kind == "manor":
		for x in w:
			local[0][x] = Tile.WALL
			occ[0][x] = true
			local[h - 1][x] = Tile.WALL
			occ[h - 1][x] = true
		for y in h:
			local[y][0] = Tile.WALL
			occ[y][0] = true
			local[y][w - 1] = Tile.WALL
			occ[y][w - 1] = true
		# The gates sit where the streets cross the wall.
		local[0][sx] = Tile.PATH
		local[h - 1][sx] = Tile.PATH
		local[sy][0] = Tile.PATH
		local[sy][w - 1] = Tile.PATH
		var keep := Rect2i(sx - 4, 3, 8, 6) if kind == "castle" else Rect2i(sx - 3, 3, 6, 5)
		_mark_block(local, occ, keep)
		var lord_door := Vector2i(keep.position.x + keep.size.x / 2, keep.end.y)
		occ[lord_door.y][lord_door.x] = true
		_add_npc(npcs, index, rng, "lord", lord_door, title)
	for role in TOWN_ROLES[kind]:
		var rect := _find_room(occ, rng, w, h)
		if rect.size == Vector2i.ZERO:
			continue
		_mark_block(local, occ, rect)
		var door := Vector2i(rect.position.x + rect.size.x / 2, rect.end.y)
		occ[door.y][door.x] = true
		_add_npc(npcs, index, rng, str(role), door, title)
	# Scattered trees on open ground, away from the streets and buildings.
	for y in h:
		for x in w:
			if local[y][x] == Tile.GRASS and not occ[y][x] and (x * 7 + y * 5 + index * 3) % 11 == 0:
				local[y][x] = Tile.TREE
	for y in h:
		for x in w:
			var idx := (origin.y + y) * WORLD_W + origin.x + x
			var k: int = local[y][x]
			if world[idx] == Tile.PATH and k != Tile.PATH:
				continue
			world[idx] = k
	town["npcs"] = npcs


func _find_room(occ: Array, rng: RandomNumberGenerator, w: int, h: int) -> Rect2i:
	for attempt in 200:
		var bw := rng.randi_range(4, 6)
		var bh := rng.randi_range(3, 5)
		var bx := rng.randi_range(2, w - bw - 2)
		var by := rng.randi_range(2, h - bh - 2)
		var rect := Rect2i(bx, by, bw, bh)
		if _room_free(occ, rect):
			return rect
	return Rect2i()


# A room fits if it and a one-tile margin (including the doorstep) are all free.
func _room_free(occ: Array, rect: Rect2i) -> bool:
	for y in range(rect.position.y - 1, rect.end.y + 2):
		for x in range(rect.position.x - 1, rect.end.x + 2):
			if occ[y][x]:
				return false
	return true


func _mark_block(local: Array, occ: Array, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			local[y][x] = Tile.HOUSE
			occ[y][x] = true


func _add_npc(npcs: Array, index: int, rng: RandomNumberGenerator, role: String, spot: Vector2i, title: String) -> void:
	var first: String = TOWN_FIRST[rng.randi() % TOWN_FIRST.size()]
	var last: String = TOWN_LAST[rng.randi() % TOWN_LAST.size()]
	var npc := {
		"id": "t%d_%d" % [index, npcs.size()],
		"pos": spot,
		"role": role,
		"color": TOWN_NPC_COLORS[rng.randi() % TOWN_NPC_COLORS.size()],
	}
	match role:
		"shop_general":
			npc["name"] = "%s the Trader" % first
			npc["shop"] = "general"
			npc["lines"] = ["Wood, fiber, stone. Name what you need.", "Fair prices, fair coin."]
		"shop_grocer":
			npc["name"] = "%s the Grocer" % first
			npc["shop"] = "grocer"
			npc["lines"] = ["Seed here, and I'll buy your crops and fish.", "Pumpkin seed needs a steady hand at Farming."]
		"bank":
			npc["name"] = "%s the Banker" % first
			npc["bank"] = true
			npc["lines"] = ["Your coins and goods are safe with us.", "Deposit what you don't need to carry."]
		"lord":
			npc["name"] = "%s of %s" % [first, title]
			npc["lines"] = ["The land is ours to keep, for now.", "Travellers are welcome, as long as they keep the peace."]
		_:
			npc["name"] = "%s %s" % [first, last]
			npc["lines"] = ["Good day, traveller.", "Keep to the road after dark.", "The forest here is quiet, but it listens.", "We have lived in %s for three generations." % title]
	npcs.append(npc)


func _town_at(tile: Vector2i) -> int:
	for i in towns.size():
		var town: Dictionary = towns[i]
		var rect := Rect2i(town["origin"], Vector2i(int(town["w"]), int(town["h"])))
		if rect.has_point(tile):
			return i
	return -1


# --- Shops and the bank ------------------------------------------------------


# --- Campsites ----------------------------------------------------------------

func _can_camp() -> bool:
	return progression._level("Bushcrafting") >= CAMP_LEVEL and _has_materials(CAMP_COST)


func _place_campsite() -> void:
	if not _in_village():
		_show_message("A campsite goes in the wider land, away from the homestead.")
		return
	var tile := _tile_in_front()
	var kind := _kind_at(tile)
	if (kind != Tile.GRASS and kind != Tile.PATH) or _npc_index(tile) != -1:
		_show_message("Face open ground to set up camp.")
		return
	if not _can_camp():
		_show_message("You need %d wood, %d fiber, and Bushcrafting %d to set up camp." % [int(CAMP_COST["wood"]), int(CAMP_COST["fiber"]), CAMP_LEVEL])
		return
	for mat in CAMP_COST.keys():
		materials[mat] -= int(CAMP_COST[mat])
	if campsite != NO_CAMP:
		world[campsite.y * WORLD_W + campsite.x] = Tile.GRASS
	campsite = tile
	_apply_campsite()
	progression._grant_xp("Bushcrafting", 15)
	saver._save_game()
	_show_message("You set up camp. Rest there from 18:00. +15 Bushcrafting XP")
	queue_redraw()


func _apply_campsite() -> void:
	if campsite != NO_CAMP:
		world[campsite.y * WORLD_W + campsite.x] = Tile.CAMP
		_build_world_minimap()


func _near_campsite(tile: Vector2i) -> bool:
	return campsite != NO_CAMP and not in_cave and Vector2(tile - campsite).length() <= CAMP_SAFE_RADIUS


func _at_campsite() -> bool:
	return _in_village() and _near_campsite(_player_tile())


# Resting at the campsite works like sleeping in the bed, but the world is kept.
func _rest_at_camp() -> void:
	if current_hour < SLEEP_HOUR:
		_show_message("You aren't tired yet. You can rest at the camp after 18:00.")
		return
	stats["slept"] += 1
	sanity_sys._change_sanity(SLEEP_SANITY)
	warmth = 100.0
	_end_day("You rest by the campsite through the night.", false)


# --- Slot grids for the pack, seed pouch, and equipment ---------------------


# Ten slots in four columns. The top row holds the back, head, neck, and belt.
# The lantern hangs from the belt, so the offhand is free for a shield.
# --- Lowmere and the road ---------------------------------------------------

# A village is a grass field with a road along row 10, a west gate to the
# previous place, and an east gate to the next one when there is one.
func _build_zone_map(houses: Array, water: Rect2i, wood_x: int, east_gate: bool) -> Array:
	var out: Array = []
	for y in VILLAGE_H:
		var row: Array = []
		for x in VILLAGE_W:
			var t := Tile.GRASS
			if x == 0 or y == 0 or y == VILLAGE_H - 1 or x == VILLAGE_W - 1:
				t = Tile.TREE
			if x >= wood_x and (x * 7 + y * 3) % 11 == 0:
				t = Tile.TREE
			if y == VILLAGE_GATE.y:
				t = Tile.PATH
			row.append(t)
		out.append(row)
	for rect in houses:
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				out[y][x] = Tile.HOUSE
	for y in range(water.position.y, water.end.y):
		for x in range(water.position.x, water.end.x):
			out[y][x] = Tile.WATER
	out[VILLAGE_GATE.y][0] = Tile.GATE
	if east_gate:
		out[VILLAGE_GATE.y][VILLAGE_W - 1] = Tile.GATE
	return out


# True in the world, outside the farm. Lowmere, Ashford, and the open land are all in the world.
func _in_village() -> bool:
	return zone != Zone.HOMESTEAD


func _region_origin() -> Vector2i:
	if zone == Zone.ASHFORD:
		return ASHFORD_ORIGIN
	if zone == Zone.VILLAGE:
		return LOWMERE_ORIGIN
	if zone == Zone.TOWN and current_town >= 0:
		var town: Dictionary = towns[current_town]
		return town["origin"]
	return Vector2i.ZERO


func _region_at(tile: Vector2i) -> int:
	if Rect2i(LOWMERE_ORIGIN, Vector2i(VILLAGE_W, VILLAGE_H)).has_point(tile):
		return Zone.VILLAGE
	if Rect2i(ASHFORD_ORIGIN, Vector2i(VILLAGE_W, VILLAGE_H)).has_point(tile):
		return Zone.ASHFORD
	if _town_at(tile) >= 0:
		return Zone.TOWN
	return Zone.WILDS


func _zone_npcs() -> Array:
	if zone == Zone.ASHFORD:
		return ASHFORD_NPCS
	if zone == Zone.VILLAGE:
		return NPCS
	if zone == Zone.TOWN and current_town >= 0:
		var town: Dictionary = towns[current_town]
		return town["npcs"]
	return []


# Sets the zone and the town from where the player stands, without announcing it.
func _sync_region() -> void:
	var tile := _player_tile()
	zone = _region_at(tile)
	current_town = _town_at(tile) if zone == Zone.TOWN else -1


func _npc_index(tile: Vector2i) -> int:
	var npcs := _zone_npcs()
	var local := tile - _region_origin()
	for i in npcs.size():
		if npcs[i]["pos"] == local:
			return i
	return -1


func max_hp() -> int:
	return BASE_HP + progression._level("Combat") - 1


func _go_home(reason: String) -> void:
	_enter_zone(Zone.HOMESTEAD, HOMESTEAD_ARRIVE, reason)


func _enter_zone(z: int, arrive: Vector2i, reason: String) -> void:
	zone = z
	in_cave = false
	_stop_fishing("")
	swing_time = 0.0
	player.position = _tile_center(arrive.x, arrive.y)
	_on_region_change()
	_set_bounds()
	queue_redraw()
	if reason != "":
		_show_message(reason)


# Runs when the player moves between the farm, the open land, and the villages.
func _on_region_change() -> void:
	if zone == Zone.ASHFORD:
		stats["visited"] += 1
	_spawn_foes()


# Keeps the region in step with where the player is walking in the world.
func _update_region() -> void:
	if not _in_village():
		return
	queue_redraw()
	var tile := _player_tile()
	var z := _region_at(tile)
	var town := _town_at(tile) if z == Zone.TOWN else -1
	if z == zone and town == current_town:
		return
	zone = z
	current_town = town
	_on_region_change()
	if zone == Zone.VILLAGE:
		_show_message("You come into Lowmere.")
	elif zone == Zone.ASHFORD:
		_show_message("You come into Ashford. Something watches from the road.")
	elif zone == Zone.TOWN and current_town >= 0:
		var title := str(towns[current_town]["title"])
		_show_message("You come into %s." % title)


# Walking the road is daylight only. At dusk the gate pushes you back.
func _refuse_gate(tile: Vector2i) -> void:
	player.position += Vector2(PX if tile.x == 0 else -PX, 0)
	_show_message("The road is dark. Walk it in daylight.")


func _interact_village() -> void:
	var idx := _npc_index(_tile_in_front())
	if idx >= 0:
		if not _tool_press:
			_talk(_zone_npcs()[idx])
		return
	if zone == Zone.ASHFORD and quarry.has(_tile_in_front()):
		if _need_tool("pick"):
			_quarry(_tile_in_front())
		return
	if campsite != NO_CAMP and _tile_in_front() == campsite:
		if not _tool_press:
			_rest_at_camp()
		return
	_swing()


func _talk(npc: Dictionary) -> void:
	stats["talks"] += 1
	var lines: Array = npc["lines"]
	if npc.has("shop"):
		active_shop = str(npc["shop"])
		open_tab = "Trade" if active_shop == "grocer" else "Shop"
		_refresh_panel()
		return
	if npc.has("bank"):
		open_tab = "Bank"
		_refresh_panel()
		return
	if npc.has("role"):
		_show_message("%s: %s" % [npc["name"], lines[int(stats["talks"]) % lines.size()]])
		return
	if npc["id"] == "tomas" and stall._first_cooked() != "" and int(stats["delivered"]) == 0:
		inventory[stall._first_cooked()] -= 1
		stats["delivered"] += 1
		_show_message("Tomas: Bread and thanks. The village eats tonight.")
		return
	if npc["id"] == "harrow" and farm._crop_total() >= 5 and int(stats["crops_given"]) < 5:
		farm._spend_crops(5)
		stats["crops_given"] += 5
		_show_message("Harrow: Five crops. The wheel will turn again.")
		return
	var stage := mini(guardian_done.size(), lines.size() - 1)
	_show_message("%s: %s" % [npc["name"], lines[stage]])


# Each tick, you swing and the hollow answers. Moving away breaks the fight.
# Losing a fight sends you home, shaken. You're back at full health by morning.
func _fallen() -> void:
	sanity_sys._change_sanity(-10.0)
	hp = max_hp()
	_go_home("You collapse in the wood. You wake at the homestead, shaken. Sanity -10.")


func _check_guardian() -> void:
	if not WORLD_ENABLED:
		return
	for q in GUARDIAN_QUESTS:
		if guardian_done.has(q["id"]):
			continue
		if progression._stat_value(q["stat"]) < q["goal"]:
			break
		guardian_done[q["id"]] = true
		progression._grant_reward(q["reward"])
		_show_message("Guardian quest complete: %s. Reward: %s" % [q["title"], progression._reward_text(q["reward"])])


func _draw_world() -> void:
	# Only the tiles the camera can see are drawn, so the full-size world stays fast.
	var view := get_viewport_rect().size / camera.zoom
	var top_left := camera.get_screen_center_position() - view * 0.5
	var x0 := clampi(floori(top_left.x / PX) - 1, 0, WORLD_W - 1)
	var y0 := clampi(floori(top_left.y / PX) - 1, 0, WORLD_H - 1)
	var x1 := clampi(ceili((top_left.x + view.x) / PX) + 1, 0, WORLD_W - 1)
	var y1 := clampi(ceili((top_left.y + view.y) / PX) + 1, 0, WORLD_H - 1)
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var world_kind: int = world[y * WORLD_W + x]
			if world_kind == Tile.TREE:
				FarmArt.draw_tree(self, _tile_rect(Vector2i(x, y)), FarmArt.hash_int(x, y, 3), 0)
			else:
				draw_rect(_tile_rect(Vector2i(x, y)), TILE_COLORS[world_kind])
	var origin := _region_origin()
	for npc in _zone_npcs():
		var c := _tile_center(origin.x + npc["pos"].x, origin.y + npc["pos"].y)
		draw_circle(c, PX * 0.3, Color(str(npc["color"])))
		# Name above each villager, using the first name only to keep it short.
		var first_name := str(npc["name"]).split(" ")[0]
		draw_string(ThemeDB.fallback_font, c + Vector2(-PX * 1.5, -PX * 0.6), first_name, HORIZONTAL_ALIGNMENT_CENTER, PX * 3, 12, Color(1, 0.97, 0.88))
	for pos in quarry:
		var qc := _tile_center(pos.x, pos.y)
		draw_circle(qc, PX * 0.3, Color("6a6a4a"))
		draw_circle(qc + Vector2(-5, -4), PX * 0.08, Color("c9b46a"))
	_draw_combat()


# --- Foes and combat ----------------------------------------------------------

func _new_foe(kind: String, tile: Vector2i) -> Dictionary:
	var center := _tile_center(tile.x, tile.y)
	return {
		"kind": kind, "pos": center, "home": center,
		"hp": int(FOES[kind]["hp"]), "cool": 0.0, "dir": Vector2.ZERO,
		"wander_t": 0.0, "flash": 0.0,
	}


func _spawn_foes() -> void:
	foes = []
	if in_cave:
		for spawn in cave_spawns:
			foes.append(_new_foe(str(spawn["kind"]), spawn["tile"]))
		queue_redraw()
		return
	var origin := _region_origin()
	if zone == Zone.VILLAGE:
		for spot in HOLLOW_SPAWNS:
			foes.append(_new_foe("hollow", origin + spot))
	elif zone == Zone.ASHFORD:
		for spot in STALKER_SPAWNS:
			foes.append(_new_foe("stalker", origin + spot))
	queue_redraw()


func _update_foes(delta: float) -> void:
	swing_cool = maxf(0.0, swing_cool - delta)
	swing_time = maxf(0.0, swing_time - delta)
	invuln = maxf(0.0, invuln - delta)
	if not (_in_village() or in_cave):
		player.modulate = Color.WHITE
		return
	player.modulate = Color(1.0, 0.55, 0.55) if invuln > 0.0 else Color.WHITE
	for foe in foes:
		var st: Dictionary = FOES[foe["kind"]]
		foe["cool"] = maxf(0.0, float(foe["cool"]) - delta)
		foe["flash"] = maxf(0.0, float(foe["flash"]) - delta)
		var pos: Vector2 = foe["pos"]
		var to_player: Vector2 = player.position - pos
		var dist := to_player.length()
		if dist < float(st["aggro"]) * PX:
			_move_foe(foe, to_player.normalized() * float(st["chase"]) * delta)
			if dist < PX * 0.6 and float(foe["cool"]) <= 0.0:
				foe["cool"] = float(st["cool"])
				_foe_attack(foe)
		else:
			foe["wander_t"] = float(foe["wander_t"]) - delta
			if float(foe["wander_t"]) <= 0.0:
				foe["wander_t"] = randf_range(1.0, 3.0)
				foe["dir"] = Vector2.from_angle(randf() * TAU) if randf() < 0.7 else Vector2.ZERO
			var wander_dir: Vector2 = foe["dir"]
			var home: Vector2 = foe["home"]
			if pos.distance_to(home) > PX * 2.5:
				wander_dir = (home - pos).normalized()
			_move_foe(foe, wander_dir * float(st["speed"]) * delta)
	queue_redraw()


# Moves one axis at a time so a foe slides along walls.
func _move_foe(foe: Dictionary, step: Vector2) -> void:
	var pos: Vector2 = foe["pos"]
	var nx := pos + Vector2(step.x, 0)
	if _foe_free(nx):
		pos = nx
	var ny := pos + Vector2(0, step.y)
	if _foe_free(ny):
		pos = ny
	foe["pos"] = pos


func _foe_free(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / PX), floori(p.y / PX))
	return not BLOCKING.has(_kind_at(t)) and _npc_index(t) == -1 and not _near_campsite(t)


func _foe_attack(foe: Dictionary) -> void:
	if _at_campsite():
		return
	if invuln > 0.0:
		return
	# A held block turns aside a blow from the front.
	if blocking and (foe["pos"] - player.position).normalized().dot(player.facing) > 0.3:
		invuln = INVULN_TIME * 0.5
		play_sfx("tick", 0.05)
		return
	var st: Dictionary = FOES[foe["kind"]]
	var dmg := maxi(1, int(st["dmg"]) - _defense())
	hp -= dmg
	invuln = INVULN_TIME
	# Knock the player back a little, if there's room.
	var away: Vector2 = (player.position - foe["pos"]).normalized()
	var np: Vector2 = player.position + away * PX * 0.5
	if not _is_blocked_world(np):
		player.position = np
	if hp <= 0:
		_fallen()
		return
	_show_message("The %s strikes you for %d. HP %d/%d" % [str(foe["kind"]).capitalize(), dmg, hp, max_hp()])


func _swing() -> void:
	if not _tool_press:
		return
	if _active_tool() != "sword":
		return
	if not _has_weapon():
		_show_message("Equip a weapon from Gear to fight.")
		return
	var weapon := str(equipment["hand_r"])
	if weapon != "" and GEAR_ITEMS[weapon].has("ammo"):
		_fire(weapon)
		return
	if swing_cool > 0.0:
		return
	swing_cool = SWING_COOLDOWN
	swing_time = SWING_TIME
	player.play_act("swing", SWING_TIME)
	swing_dir = player.facing
	var dmg := _weapon_damage()
	var combat := progression._level("Combat")
	var hit_any := false
	for foe in foes.duplicate():
		var to_foe: Vector2 = foe["pos"] - player.position
		if to_foe.length() > SWING_REACH * PX:
			continue
		if to_foe.normalized().dot(swing_dir) < SWING_ARC:
			continue
		var amount := dmg + randi_range(0, combat / 2)
		foe["hp"] = int(foe["hp"]) - amount
		foe["flash"] = 0.2
		hit_any = true
		progression._grant_xp("Combat", XP_HIT)
		if int(foe["hp"]) <= 0:
			_kill_foe(foe)
		else:
			_show_message("You hit the %s for %d." % [str(foe["kind"]), amount])
	if not hit_any:
		_show_message("You swing at empty air.")
	queue_redraw()


func _kill_foe(foe: Dictionary) -> void:
	var st: Dictionary = FOES[foe["kind"]]
	foes.erase(foe)
	stats["defeated"] += 1
	if foe["kind"] == "stalker":
		stats["stalkers"] += 1
	progression._grant_xp("Combat", int(st["xp"]))
	var note := "+%d Combat XP" % int(st["xp"])
	var drop := str(st["drop"])
	if randf() < 0.6:
		materials[drop] += 1
		note += ", 1 %s" % drop
	_show_message("The %s falls. %s" % [str(foe["kind"]), note])


func _weapon_damage() -> int:
	var item := str(equipment["hand_r"])
	if item == "":
		return 1
	return int(GEAR_ITEMS[item]["dmg"])


func _defense() -> int:
	var total := 0
	for slot in equipment.keys():
		var item := str(equipment[slot])
		if item != "":
			total += int(GEAR_ITEMS[item]["def"])
	return total


# --- Gear crafting -----------------------------------------------------------

func _can_craft(id: String) -> bool:
	var item: Dictionary = GEAR_ITEMS[id]
	if str(equipment[item["slot"]]) == id:
		return false
	if progression._level(str(item.get("skill", "Bushcrafting"))) < int(item["level"]):
		return false
	var cost: Dictionary = item["cost"]
	for mat in cost.keys():
		if int(materials[mat]) < int(cost[mat]):
			return false
	return true


func _craft_gear(id: String) -> void:
	if not _can_craft(id):
		_show_message("You don't have the materials, or Bushcrafting is too low for that.")
		return
	var item: Dictionary = GEAR_ITEMS[id]
	var cost: Dictionary = item["cost"]
	for mat in cost.keys():
		materials[mat] -= int(cost[mat])
	equipment[item["slot"]] = id
	progression._grant_xp(str(item.get("skill", "Bushcrafting")), 10)
	_show_message("You fashion a %s and equip it. +10 %s XP" % [item["name"], item.get("skill", "Bushcrafting")])


# --- Repairs and mending ----------------------------------------------------

func _can_repair() -> bool:
	if house_stage >= MAX_STAGE:
		return false
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	return materials["wood"] >= cost["wood"] \
		and materials["fiber"] >= cost["fiber"] \
		and progression._level("Carpentry") >= cost["level"]


func _repair_house() -> void:
	play_sfx("repair")
	if not _can_repair():
		_show_message("Not enough wood and fiber, or Carpentry is too low for this repair.")
		return
	var cost: Dictionary = REPAIR_COSTS[house_stage]
	materials["wood"] -= cost["wood"]
	materials["fiber"] -= cost["fiber"]
	house_stage += 1
	wear = maxi(0, wear - WEAR_REPAIR)
	farm._check_plot_three()
	progression._grant_xp("Carpentry", XP_REPAIR)
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
	wear = maxi(0, wear - WEAR_MEND)
	progression._grant_xp("Carpentry", XP_MEND)
	_show_message("You mend a board. +%d Carpentry XP" % XP_MEND)


func _footprint(kind: String) -> Vector2i:
	if kind == "barn":
		return BARN_SIZE
	return Vector2i(COOP_SIZE, COOP_SIZE)


func _is_built(kind: String) -> bool:
	return barn_built if kind == "barn" else coop_built


func _placed_tile(kind: String) -> Vector2i:
	return barn_tile if kind == "barn" else coop_tile


func _build_cost(kind: String) -> Dictionary:
	return BARN_COST if kind == "barn" else COOP_COST


# A building can be built once, from the Buildings menu.
func _can_build(kind: String) -> bool:
	if _is_built(kind):
		return false
	var cost := _build_cost(kind)
	return progression._level("Carpentry") >= int(cost["level"]) \
		and int(materials["wood"]) >= int(cost["wood"]) and int(materials["fiber"]) >= int(cost["fiber"])


# Gets you out of a bad spot: cancels any placement and walks you to the nearest open ground
# by the farmhouse door. The search starts from that door, so a building that boxed you in doesn't matter.
func _unstick() -> void:
	placing = ""
	_close_panel()
	if inside or in_cave or _in_village():
		_show_message("Unstick works on the farm. Leave the house, cave, or village first.")
		return
	var start := Vector2i(BORDER_X + HOUSE_DOOR_IX, BORDER_Y + HOUSE_DOOR_IY + 1)
	var free := _nearest_open_tile(start)
	if free.x < 0:
		_show_message("Nothing open to walk to. Try the Settings menu again after moving a building.")
		return
	player.position = _tile_center(free.x, free.y)
	_show_message("You step back onto open ground.")


# Breadth-first search over open ground (grass, path, soil, fallow) inside the farm, from a starting tile.
func _nearest_open_tile(start: Vector2i) -> Vector2i:
	var open_kinds := [Tile.GRASS, Tile.PATH, Tile.SOIL, Tile.FALLOW]
	var seen := {start: true}
	var queue: Array = [start]
	while queue.size() > 0:
		var t: Vector2i = queue.pop_front()
		if t.x >= BORDER_X and t.y >= BORDER_Y and t.x < BORDER_X + INNER_W and t.y < BORDER_Y + INNER_H:
			if map[t.y][t.x] in open_kinds and not crops.has(t) and not rocks.has(t) and not brush.has(t) and not fish_spots.has(t):
				return t
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = t + d
			if n.x < BORDER_X or n.y < BORDER_Y or n.x >= BORDER_X + INNER_W or n.y >= BORDER_Y + INNER_H:
				continue
			if seen.has(n):
				continue
			seen[n] = true
			queue.append(n)
	return Vector2i(-1, -1)


func _build_coop() -> void:
	_start_placement("coop")


func _build_barn() -> void:
	_start_placement("barn")


# Choosing a spot: the ghost follows the tile you face. Space places it, B cancels.
func _start_placement(kind: String) -> void:
	if inside or in_cave or _in_village():
		_show_message("You can only build on the farm.")
		return
	if not _is_built(kind) and not _can_build(kind):
		_show_message("A %s needs %s." % [kind, stall._price_text(_build_cost(kind))])
		return
	placing = kind
	_close_panel()
	var size := _footprint(kind)
	_show_message("Face the ground where the %s should go and press Space. It needs %d by %d open grass. B cancels." % [kind, size.x, size.y])


func _cancel_placement() -> void:
	placing = ""
	_show_message("You leave the spot empty for now.")


func _confirm_placement() -> void:
	var kind := placing
	var top := _tile_in_front()
	var size := _footprint(kind)
	if not _spot_ok(top, size):
		_show_message("There isn't room for the %s there. It needs open grass, clear of crops, rocks, and brush." % kind)
		return
	if not _is_built(kind):
		var cost := _build_cost(kind)
		materials["wood"] -= int(cost["wood"])
		materials["fiber"] -= int(cost["fiber"])
		if kind == "barn":
			barn_built = true
		else:
			coop_built = true
		progression._grant_xp("Carpentry", XP_REPAIR)
	elif _placed_tile(kind).x >= 0:
		# Moving is free: the old footprint goes back to grass first.
		_stamp_footprint(_placed_tile(kind), size, Tile.GRASS)
	if kind == "barn":
		barn_tile = top
	else:
		coop_tile = top
	placing = ""
	_apply_storage_tiles()
	if kind == "barn":
		_show_message("The barn stands here now. Livestock will be kept here when they arrive.")
	else:
		_show_message("The coop stands here now. Stand beside it, facing it, and press Space to tend the hens.")


# A spot fits when all of its tiles are open grass, clear of crops, rocks, brush, fishing spots, and you.
func _spot_ok(top: Vector2i, size: Vector2i) -> bool:
	var here := _player_tile()
	for dy in size.y:
		for dx in size.x:
			var t := top + Vector2i(dx, dy)
			if t.x < BORDER_X or t.y < BORDER_Y or t.x >= BORDER_X + INNER_W or t.y >= BORDER_Y + INNER_H:
				return false
			if map[t.y][t.x] != Tile.GRASS:
				return false
			if crops.has(t) or rocks.has(t) or brush.has(t) or fish_spots.has(t) or t == here:
				return false
	return true


func _draw_placement_ghost() -> void:
	if placing == "":
		return
	var top := _tile_in_front()
	var size := _footprint(placing)
	var fill := Color(0.2, 0.9, 0.25, 0.5) if _spot_ok(top, size) else Color(0.95, 0.2, 0.15, 0.5)
	for dy in size.y:
		for dx in size.x:
			placement_ghost.draw_rect(_tile_rect(top + Vector2i(dx, dy)), fill)


func _buy_hen() -> void:
	play_sfx("coin")
	if not animals._can_buy_hen():
		_show_message("A hen costs %d coins, and the coop holds %d." % [HEN_PRICE, COOP_HENS_MAX])
		return
	money -= HEN_PRICE
	hens += 1
	queue_redraw()
	_show_message("A hen settles into the coop.")


func _buy_goat() -> void:
	play_sfx("coin")
	if not barn_built:
		_show_message("Build the barn first.")
		return
	if goats >= BARN_GOATS_MAX:
		_show_message("The barn holds %d goats." % BARN_GOATS_MAX)
		return
	if money < GOAT_PRICE:
		_show_message("A goat costs %d coins." % GOAT_PRICE)
		return
	money -= GOAT_PRICE
	goats += 1
	stats["goats_bought"] += 1
	queue_redraw()
	_show_message("A goat trots into the barn yard.")


# The day's chores. Each is done or not. Chores left undone wear the house overnight.
func _job_today() -> Dictionary:
	return JOBS[day % JOBS.size()]


func _job_need_text(job: Dictionary) -> String:
	var parts: Array = []
	for item in job["need"].keys():
		parts.append("%d %s" % [int(job["need"][item]), str(item).replace("_", " ")])
	return ", ".join(parts)


func _can_do_job() -> bool:
	if job_done_day == day:
		return false
	var job := _job_today()
	for item in job["need"].keys():
		if _held(str(item)) < int(job["need"][item]):
			return false
	return true


func _do_job() -> void:
	if not _can_do_job():
		_show_message("You don't have what the job asks for, or you've done it today.")
		return
	var job := _job_today()
	for item in job["need"].keys():
		var n := int(job["need"][item])
		if materials.has(str(item)):
			materials[item] -= n
		else:
			inventory[item] -= n
	money += int(job["coins"])
	progression._grant_xp(str(job["skill"]), int(job["xp"]))
	job_done_day = day
	stats["jobs"] += 1
	play_sfx("coin")
	_show_message("Job done: %s. +%d coins, +%d %s XP" % [str(job["name"]).to_lower(), int(job["coins"]), int(job["xp"]), job["skill"]])


func _chore_list() -> Array:
	var chores: Array = []
	chores.append({"name": "Tidy the house", "detail": "+%d XP, once a day" % XP_TIDY, "done": tidied_day == day, "button": "Tidy", "action": "tidy", "enabled": sanity_sys._can_tidy()})
	chores.append({"name": "Mend a board", "detail": "%d wood, %d fiber, +%d XP. %d left today" % [MEND_WOOD, MEND_FIBER, XP_MEND, _mends_left()], "done": mend_day == day and mends_today > 0, "button": "Mend", "action": "mend", "enabled": _can_mend()})
	if hens > 0:
		chores.append({"name": "Feed the hens", "detail": "at the coop, %d crops" % (hens * HEN_FEED_CROPS), "done": hens_fed_day == day, "button": "", "action": "", "enabled": false})
	if goats > 0:
		chores.append({"name": "Feed the goats", "detail": "at the barn, %d crops" % (goats * GOAT_FEED_CROPS), "done": goats_fed_day == day, "button": "", "action": "", "enabled": false})
	return chores


# The date for a day number. Day 1 is October 1st, and each month uses its real length.
func _calendar_date(day_number: int) -> Dictionary:
	var m := START_MONTH
	var dom := START_DAY_OF_MONTH + day_number - 1
	while dom > MONTH_DAYS[m]:
		dom -= MONTH_DAYS[m]
		m = (m + 1) % 12
	return {"month": m, "day": dom}


# Pacific Northwest seasons: winter is December to February, spring is March to May, summer is June to August.
func _season_of(month: int) -> String:
	if month == 11 or month <= 1:
		return "Winter"
	if month <= 4:
		return "Spring"
	if month <= 7:
		return "Summer"
	return "Autumn"


# Day of the year for a month and day, counting from January 1st. Leap years are ignored.
func _day_of_year(month: int, dom: int) -> int:
	var total := 0
	for m in month:
		total += MONTH_DAYS[m]
	return total + dom - 1


# Picks the day's weather from the season's weights.
func _roll_weather() -> void:
	# Midsummer heat keeps the sky clear for its days.
	if sanity_sys._event_active("heat"):
		weather_kind = "sunny"
		_apply_weather()
		return
	var season := _season_of(_calendar_date(day)["month"])
	var weights: Dictionary = WEATHER_WEIGHTS[season]
	var total := 0
	for k in weights:
		total += int(weights[k])
	var pick := randi() % total
	for k in weights:
		pick -= int(weights[k])
		if pick < 0:
			weather_kind = str(k)
			break
	_apply_weather()


# Shows the day's weather and lights the farm to match.
func _apply_weather() -> void:
	if weather != null:
		weather.set_condition(weather_kind)
	# Rain waters every crop as it falls, so the drops and the shimmer show from the morning.
	if weather_kind in WATER_RAIN_KINDS:
		for pos in crops:
			crops[pos]["watered_day"] = day
	# A downpour sometimes brings thunder, once a morning.
	if weather_kind == "downpour" and thunder_day != day:
		thunder_day = day
		if randf() < 0.6:
			play_sfx("thunder")


func _light_tint() -> Color:
	return WEATHER_LIGHT.get(weather_kind, WEATHER_LIGHT["cloudy"])


# --- Post, property tax, and the desk light ---
# Post comes through the mail slot in the front door and lands on the desk. Unread post turns
# on a red light at the desk. The property tax comes quarterly and must be paid, or the land is lost.


func _build_desk_light() -> void:
	desk_light = PointLight2D.new()
	desk_light.texture = _glow_texture()
	desk_light.color = Color("ff2a2a")
	desk_light.texture_scale = 0.45
	desk_light.position = _tile_center(INT_ORIGIN.x + DESK_IX.x, INT_ORIGIN.y + DESK_IX.y)
	desk_light.enabled = false
	add_child(desk_light)


# --- Animal ages: young animals do not lay or give until they are grown ---


# Runs at the end of each day, before the crops grow: the house wears, hens lay or leave,
# and rain or a fox may strike. Returns a note for the morning message.
func _settle_day() -> String:
	var notes := ""
	var missed := 0
	for chore in _chore_list():
		if not bool(chore["done"]):
			missed += 1
	wear = mini(wear + WEAR_PER_NIGHT + missed, WEAR_MAX)
	clean_nights = clean_nights + 1 if missed == 0 else 0
	if missed > 0:
		notes += " %d chore%s left undone, so the house wears faster." % [missed, "" if missed == 1 else "s"]
	else:
		sanity_sys._change_sanity(WELL_KEPT_SANITY)
		notes += " The house is kept well, and you sleep easier. +%d sanity." % WELL_KEPT_SANITY
	animals._age_animals()
	if hens > 0:
		if hens_fed_day == day:
			hen_unfed_days = 0
			var room := maxi(0, stall._pack_capacity() - stall._pack_used())
			var layers := animals._grown_count(hen_ages, HEN_MATURE_DAYS)
			var eggs := mini(layers, room)
			if eggs > 0:
				inventory["eggs"] += eggs
				notes += " The hens laid %d egg%s." % [eggs, "" if eggs == 1 else "s"]
			if eggs < layers:
				notes += " Some eggs spoiled for want of pack room."
		else:
			hen_unfed_days += 1
			if hen_unfed_days >= HEN_LEAVE_DAYS:
				hens -= 1
				hen_unfed_days = 0
				notes += " A hungry hen wandered off."
	if goats > 0:
		if goats_fed_day == day:
			goat_unfed_days = 0
			var room := maxi(0, stall._pack_capacity() - stall._pack_used())
			var givers := animals._grown_count(goat_ages, GOAT_MATURE_DAYS)
			var milk := mini(givers, room)
			if milk > 0:
				inventory["milk"] += milk
				notes += " The goats gave %d milk%s." % [milk, "" if milk == 1 else "s"]
			if milk < givers:
				notes += " Some milk spoiled for want of pack room."
		else:
			goat_unfed_days += 1
			if goat_unfed_days >= GOAT_LEAVE_DAYS:
				goats -= 1
				goat_unfed_days = 0
				notes += " A hungry goat wandered off."
	if wear >= WEAR_FOX and hens > 0 and randf() < 0.5:
		hens -= 1
		notes += " A fox got into the coop and took a hen."
	animals._sync_ages()
	if wear >= WEAR_RUNDOWN and not crops.is_empty():
		var spot = crops.keys().pick_random()
		crops.erase(spot)
		notes += " Rain came through the roof and ruined a crop."
	return notes


# The spot beside the bed, where you stand when you wake.
func _wake_spot() -> Vector2:
	return _tile_center(INT_ORIGIN.x + BED_INTERIOR.x, INT_ORIGIN.y + BED_INTERIOR.y + 1)


# Sleeping only happens at the bed, from 18:00 until 03:00.
func _try_sleep() -> void:
	if transitioning:
		return
	if _in_village():
		_show_message("You can only sleep in your own bed, at the homestead.")
		return
	if current_hour < SLEEP_HOUR:
		_show_message("You aren't tired yet. The bed will be there after 18:00.")
		return
	stats["slept"] += 1
	sanity_sys._change_sanity(SLEEP_SANITY)
	if firewood._fire_lit():
		warmth = 100.0
	else:
		_show_message("The fire is out. Nothing warms the house through the night, and you wake chilled.")
	# You wake standing beside the bed, so the house is not left.
	player.position = _wake_spot()
	_sleep_scene()


# Missing the bed by 03:00 ends the day, and the sanity limit drops for good.
func _collapse() -> void:
	if transitioning:
		return
	sanity_penalty += COLLAPSE_SANITY_PENALTY
	stats["collapses"] += 1
	sanity = minf(sanity, sanity_sys._sanity_max())
	_collapse_scene()


# A slow, quiet fade: the night closes in, the day passes, and the light comes back.
func _sleep_scene() -> void:
	transitioning = true
	player.paused = true
	card_label.add_theme_color_override("font_color", Color("e8dcc0"))
	await _fade_to(Color(0.0, 0.0, 0.0, 1.0), 2.8, Tween.TRANS_SINE)
	await get_tree().create_timer(0.6).timeout
	# The day ends while the screen is dark. This saves the game.
	_end_day("You sleep through the night.", false)
	await _show_card("Night settles over the farm.", 1.6, 2.0, 1.4)
	await _show_card("Day %d. The morning is %s." % [day, str(WEATHER_NAMES.get(weather_kind, "overcast")).to_lower()], 1.4, 1.8, 1.2)
	await _fade_to(Color(0.0, 0.0, 0.0, 0.0), 3.0, Tween.TRANS_SINE)
	transitioning = false


# A violent, unnatural cut at 03:00: red flash, the ground shaking, then a long dread fade back.
func _collapse_scene() -> void:
	transitioning = true
	player.paused = true
	card_label.add_theme_color_override("font_color", Color("c9463d"))
	_shake_camera(1.1, 9.0)
	await _fade_to(Color(0.22, 0.0, 0.0, 1.0), 0.45, Tween.TRANS_QUAD)
	await get_tree().create_timer(0.9).timeout
	_end_day("You collapse before reaching your bed. Something in your mind gives way.")
	await _show_card("It is past three.", 1.4, 2.2, 1.0)
	await _show_card("Something in the dark has been keeping pace with you.", 1.8, 2.8, 1.4)
	await _show_card("You don't remember the way home.", 1.6, 2.2, 1.8)
	await _fade_to(Color(0.22, 0.0, 0.0, 0.0), 4.2, Tween.TRANS_CUBIC)
	transitioning = false


func _fade_to(colour: Color, seconds: float, trans: Tween.TransitionType) -> void:
	var tw := create_tween()
	tw.tween_property(fade_rect, "color", colour, seconds).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	await tw.finished


func _show_card(text: String, fade_in: float, hold: float, fade_out: float) -> void:
	card_label.text = text
	var tw := create_tween()
	tw.tween_property(card_label, "modulate:a", 1.0, fade_in)
	tw.tween_interval(hold)
	tw.tween_property(card_label, "modulate:a", 0.0, fade_out)
	await tw.finished


func _shake_camera(seconds: float, strength: float) -> void:
	if shake_tw != null and shake_tw.is_valid():
		shake_tw.kill()
	var tw := create_tween()
	shake_tw = tw
	for i in int(seconds / 0.05):
		tw.tween_property(camera, "offset", Vector2(randf_range(-strength, strength), randf_range(-strength, strength)), 0.05)
	tw.tween_property(camera, "offset", Vector2.ZERO, 0.08)


func _build_fade() -> void:
	fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)
	card_label = Label.new()
	card_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_label.add_theme_font_size_override("font_size", 34)
	card_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	card_label.add_theme_constant_override("outline_size", 8)
	card_label.modulate.a = 0.0
	card_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(card_label)
	player.struck.connect(_on_player_struck)


# A tool strike gives the camera a small jolt, so the impact reads.
func _on_player_struck(kind: String) -> void:
	_shake_camera(0.12, 1.6 if kind == "mine" else 1.2)


# --- Lanterns ---------------------------------------------------------------

func _can_advance_lantern() -> bool:
	if lantern_tier >= LANTERN_TIERS.size():
		return false
	var t: Dictionary = LANTERN_TIERS[lantern_tier]
	return materials["wood"] >= t["wood"] \
		and materials["fiber"] >= t["fiber"] \
		and materials["resin"] >= t["resin"] \
		and progression._level("Bushcrafting") >= t["level"]


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
		lantern_light.energy = LANTERN_ENERGY * (0.9 + 0.08 * sin(t * 9.0) + randf_range(-0.03, 0.03))
	else:
		lantern_light.energy = LANTERN_ENERGY
	# Lit windows glow once the house has glass, and the porch lamp once it is restored.
	var outdoors := not inside and not in_cave and not _in_village() and world_started
	var lit := outdoors and house_stage >= 2 and darkness > 0.1
	var glow := WINDOW_ENERGY * (0.6 + 0.4 * darkness) * (1.0 if house_stage == 3 else 0.75)
	for light in window_lights:
		light.enabled = lit
		light.energy = glow
	porch_light.enabled = outdoors and house_stage == 3 and darkness > 0.1
	porch_light.energy = glow


# --- Quests ------------------------------------------------------------------


# --- Sanity and night events ------------------------------------------------


# Ends the day and saves. Both sleeping and collapsing come through here.
func _end_day(base: String, leave_house: bool = true) -> void:
	# Resting at a campsite keeps you in the wider land. Everywhere else in the world sends you home.
	if _in_village() and not _at_campsite():
		_go_home("")
	hp = max_hp()
	if inside and leave_house:
		_leave_house()
	# Fish left in the pack spoil overnight. The cooler keeps them.
	var spoiled := int(inventory["fish"])
	inventory["fish"] = 0
	stats["spoiled"] += spoiled
	var spoil_note := (" %d fish spoiled in your pack overnight." % spoiled) if spoiled > 0 else ""
	var upkeep_note := _settle_day()
	upkeep_note += desk._boredom_check()
	# Rain waters every crop. Otherwise a crop must have been watered today to grow.
	if weather_kind in WATER_RAIN_KINDS:
		stats["rain_days"] += 1
		for pos in crops:
			crops[pos]["watered_day"] = day
	var thirsty := 0
	for pos in crops.keys():
		if int(crops[pos].get("watered_day", 0)) == day:
			var bonus := 1 if sanity_sys._event_active("thaw") else 0
			var kind := str(crops[pos]["kind"])
			crops[pos]["days"] = mini(int(crops[pos].get("days", 0)) + 1 + bonus, int(CROP_GROW_DAYS[kind]))
			crops[pos]["stage"] = _stage_for(kind, int(crops[pos]["days"]))
		elif crops[pos]["stage"] < MAX_STAGE:
			thirsty += 1
	if thirsty > 0:
		upkeep_note += " %d crop%s went thirsty and didn't grow." % [thirsty, "" if thirsty == 1 else "s"]
	# The pump refills the tank overnight.
	if well_repaired:
		well_water = WELL_CAPACITY
	day += 1
	_roll_weather()
	var event_note := sanity_sys._begin_day_events()
	clock = 0.0
	tonight_shadow = Vector2i(-1, -1)
	_regrow_wild()
	_update_shadow_tile()
	var mail_note := desk._mail_day()
	_show_message("%s Your crops grew overnight.%s%s The morning is %s.%s" % [
		base, spoil_note, upkeep_note, str(WEATHER_NAMES.get(weather_kind, "overcast")).to_lower(), event_note + mail_note])
	if desk._tax_evicts():
		desk._evict()
		return
	saver._save_game()
	queue_redraw()


func _update_shadow_tile() -> void:
	# The field shadow creeps closer to the farm each night.
	var x := BORDER_X + INNER_W - 2 - (day - 1) * 2
	x = max(x, BORDER_X + 14)
	shadow_tile = Vector2i(x, BORDER_Y + INNER_H / 2 - 4)


# --- Walking into and out of the house --------------------------------------

func _check_doors() -> void:
	var tile := _player_tile()
	var kind := _kind_at(tile)
	if in_cave:
		if kind == Tile.CAVE_EXIT:
			_leave_cave()
		return
	if not _in_village() and not inside and kind == Tile.CAVE_MOUTH:
		_enter_cave()
		return
	if _in_village():
		if kind == Tile.PORTAL and tile == PORTAL_TILE:
			_enter_zone(Zone.HOMESTEAD, HOMESTEAD_ARRIVE, "You step back through the portal to the homestead.")
		return
	if not inside and kind == Tile.DOOR:
		_enter_house()
	elif inside and kind == Tile.EXIT:
		_leave_house()
	elif not inside and WORLD_ENABLED and kind == Tile.PORTAL:
		if current_hour >= STALL_CLOSE_HOUR:
			_refuse_gate(tile)
		else:
			_enter_zone(Zone.WILDS, PORTAL_ARRIVE, "You step through the portal into the wider land.")


func _enter_house() -> void:
	play_sfx("door", 0.05)
	inside = true
	player.position = _tile_center(INT_ORIGIN.x + 6, INT_ORIGIN.y + 6)
	_set_bounds()
	_show_message("You step inside. The air is cold and smells of old wood.")


func _leave_house() -> void:
	play_sfx("door", 0.05)
	inside = false
	player.position = _tile_center(BORDER_X + HOUSE_DOOR_IX, BORDER_Y + HOUSE_DOOR_IY + 1)
	_set_bounds()


func _set_bounds() -> void:
	if in_cave:
		player.min_pos = _tile_center(1, 1)
		player.max_pos = _tile_center(CAVE_W - 2, CAVE_H - 2)
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = CAVE_W * PX
		camera.limit_bottom = CAVE_H * PX
		return
	if _in_village():
		player.min_pos = _tile_center(1, 1)
		player.max_pos = _tile_center(WORLD_W - 2, WORLD_H - 2)
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = WORLD_W * PX
		camera.limit_bottom = WORLD_H * PX
		return
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


func _brush_to_array() -> Array:
	var arr: Array = []
	for pos in brush:
		arr.append([pos.x, pos.y])
	return arr


# --- Helpers -----------------------------------------------------------------


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
	if in_cave:
		if tile.x < 0 or tile.y < 0 or tile.x >= CAVE_W or tile.y >= CAVE_H:
			return Tile.WALL
		return cave[tile.y][tile.x]
	if _in_village():
		if tile.x < 0 or tile.y < 0 or tile.x >= WORLD_W or tile.y >= WORLD_H:
			return Tile.TREE
		return world[tile.y * WORLD_W + tile.x]
	if _in_interior(tile):
		return interior[tile.y - INT_ORIGIN.y][tile.x - INT_ORIGIN.x]
	if not _in_bounds(tile):
		return Tile.TREE
	return map[tile.y][tile.x]


func _is_blocked_world(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / PX), floori(p.y / PX))
	if BLOCKING.has(_kind_at(t)):
		return true
	# Rocks are solid like the trees: the farm's rocks and the village quarry rocks. Inside the cave the
	# farm rocks' coordinates mean nothing, so they only count out on the farm.
	if _in_village():
		return _npc_index(t) != -1 or quarry.has(t)
	return not inside and (brush.has(t) or (not in_cave and rocks.has(t)))


func _world_tile(ix: int, iy: int) -> Vector2i:
	return Vector2i(ix + BORDER_X, iy + BORDER_Y)


func _tile_center(wx: int, wy: int) -> Vector2:
	return Vector2(wx * PX + PX * 0.5, wy * PX + PX * 0.5)


# Each house tile is drawn for the house's current repair stage, so the rooms improve as you fix the house.
func _draw_interior_tile(cell: Rect2, pos: Vector2i, kind: int) -> void:
	match kind:
		Tile.WALL:
			_draw_interior_wall(cell)
		Tile.FLOOR:
			_draw_interior_floor(cell, pos)
		Tile.BED:
			_draw_bed_tile(cell)
		Tile.STATION:
			_draw_station_tile(cell)
		Tile.DESK:
			_draw_desk_tile(cell)
		Tile.TABLE:
			_draw_table_tile(cell, pos)
		Tile.FIREPLACE:
			_draw_fireplace_tile(cell)
		Tile.COOLER:
			_draw_interior_cooler(cell)
		Tile.EXIT:
			_draw_doormat(cell)
		_:
			draw_rect(cell, TILE_COLORS[kind])


# Plaster walls with a faint course line and a baseboard along the bottom.
func _draw_interior_wall(cell: Rect2) -> void:
	var wall: Color = INT_WALLS[house_stage]
	draw_rect(cell, wall)
	for i in range(1, 4):
		var y := cell.position.y + cell.size.y * float(i) / 4.0
		draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0, 0, 0, 0.12), 1.0)
	draw_rect(Rect2(cell.position.x, cell.end.y - 5, cell.size.x, 5), wall.darkened(0.35))


# Wood floor with plank lines. Chairs sit on the floor and the rug covers the hall from the Boarded stage.
func _draw_interior_floor(cell: Rect2, pos: Vector2i) -> void:
	draw_rect(cell, INT_FLOORS[house_stage])
	for i in range(1, 4):
		var y := cell.position.y + cell.size.y * float(i) / 4.0
		draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0, 0, 0, 0.18), 1.0)
	var join := cell.position.x + (cell.size.x * 0.5 if (pos.x + pos.y) % 2 == 0 else cell.size.x * 0.25)
	draw_line(Vector2(join, cell.position.y), Vector2(join, cell.position.y + cell.size.y * 0.25), Color(0, 0, 0, 0.18), 1.0)
	if house_stage >= 1 and RUG_RECT.has_point(pos):
		_draw_rug_tile(cell, pos)
	if CHAIR_TILES.has(pos):
		_draw_chair(cell)


# The rug is one piece: the tiles are filled edge to edge, with a border only along its outer edge
# and a diamond pattern in each tile.
func _draw_rug_tile(cell: Rect2, pos: Vector2i) -> void:
	var base := Color("7a2e3a") if house_stage < 3 else Color("8a3a4a")
	draw_rect(cell, base)
	if pos.x == RUG_RECT.position.x or pos.x == RUG_RECT.end.x - 1 or pos.y == RUG_RECT.position.y or pos.y == RUG_RECT.end.y - 1:
		draw_rect(cell.grow(-6), base.lightened(0.25), false, 1.5)
	var c := cell.get_center()
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -8), c + Vector2(8, 0), c + Vector2(0, 8), c + Vector2(-8, 0)]), base.lightened(0.2))


func _draw_chair(cell: Rect2) -> void:
	draw_rect(Rect2(cell.position.x + 12, cell.position.y + 16, 24, 20), Color("6b4a2e"))
	draw_rect(Rect2(cell.position.x + 12, cell.position.y + 8, 24, 7), Color("4e3420"))
	draw_rect(Rect2(cell.position.x + 14, cell.position.y + 36, 4, 6), Color("3a2414"))
	draw_rect(Rect2(cell.position.x + 30, cell.position.y + 36, 4, 6), Color("3a2414"))


# A table across two tiles: a plank top, with a plate and a candle on the left half.
func _draw_table_tile(cell: Rect2, pos: Vector2i) -> void:
	var top := Rect2(cell.position + Vector2(0, 8), Vector2(cell.size.x, cell.size.y - 16))
	draw_rect(top, Color("7a5230"))
	draw_rect(Rect2(top.position.x, top.position.y, top.size.x, 3), Color("9a6a40"))
	draw_rect(Rect2(top.position.x, top.end.y - 3, top.size.x, 3), Color("5a3a22"))
	if pos == TABLE_TILES[0]:
		draw_circle(cell.position + Vector2(cell.size.x * 0.45, cell.size.y * 0.5), 6.0, Color("e8dcc0"))
		draw_circle(cell.position + Vector2(cell.size.x * 0.45, cell.size.y * 0.5), 3.5, Color("d8c8a8"))
		draw_rect(Rect2(cell.position.x + cell.size.x * 0.75, cell.position.y + cell.size.y * 0.3, 4, 10), Color("e8dcc0"))
		draw_circle(Vector2(cell.position.x + cell.size.x * 0.75 + 2, cell.position.y + cell.size.y * 0.3 - 2), 2.5, Color("ffd27a"))


# The bed: a wooden frame and headboard, a sheet, and a quilt that gets better with each stage.
func _draw_bed_tile(cell: Rect2) -> void:
	draw_rect(cell, Color("4e3420"))
	draw_rect(Rect2(cell.position.x, cell.position.y, cell.size.x, 6), Color("3a2414"))
	var mattress := Rect2(cell.position + Vector2(4, 9), cell.size - Vector2(8, 13))
	draw_rect(mattress, Color("e8dcc0"))
	var quilt := Rect2(mattress.position + Vector2(0, mattress.size.y * 0.3), Vector2(mattress.size.x, mattress.size.y * 0.7))
	draw_rect(quilt, QUILTS[house_stage])
	draw_rect(Rect2(quilt.position.x, quilt.position.y, quilt.size.x, 2), QUILTS[house_stage].lightened(0.25))
	draw_rect(Rect2(mattress.position + Vector2(5, 3), Vector2(mattress.size.x - 10, mattress.size.y * 0.22)), Color("f2ecdc"))
	if house_stage == 0:
		# A darned patch on the threadbare quilt.
		draw_rect(Rect2(quilt.position + Vector2(6, 6), Vector2(8, 6)), Color("5a4a3a"))
	if house_stage == 3:
		# Stitched dots across the fine quilt.
		for i in 3:
			var sx := quilt.position.x + quilt.size.x * (0.25 + 0.25 * i)
			draw_circle(Vector2(sx, quilt.position.y + quilt.size.y * 0.5), 1.5, Color("e0c060"))
			draw_circle(Vector2(sx, quilt.position.y + quilt.size.y * 0.8), 1.5, Color("e0c060"))


# The cleansing station: a washstand with a basin of water, a folded cloth, and a bar of soap.
# Restored, it gets brass fittings, a mirror, and a candle.
func _draw_station_tile(cell: Rect2) -> void:
	draw_rect(cell, Color("5a4632"))
	draw_rect(cell.grow(-3), Color("6b5440"))
	draw_line(Vector2(cell.get_center().x, cell.position.y + 6), Vector2(cell.get_center().x, cell.end.y - 6), Color("3e2e20"), 2.0)
	var basin := cell.position + Vector2(cell.size.x * 0.5, cell.size.y * 0.42)
	draw_circle(basin, cell.size.x * 0.3, Color("ece8dc") if house_stage >= 2 else Color("a09a8a"))
	draw_circle(basin, cell.size.x * 0.22, Color("5a8ab0"))
	draw_circle(basin + Vector2(-3, -2), 2.0, Color(1, 1, 1, 0.5))
	draw_rect(Rect2(cell.position.x + 6, cell.end.y - 13, 10, 6), Color("e8dcc0"))
	draw_rect(Rect2(cell.end.x - 16, cell.end.y - 12, 10, 5), Color("c8a0d0"))
	if house_stage == 3:
		draw_rect(Rect2(cell.position.x + 4, cell.position.y + 4, 3, 3), Color("c8a040"))
		draw_rect(Rect2(cell.end.x - 9, cell.position.y + 6, 4, 9), Color("f2ecdc"))
		draw_circle(Vector2(cell.end.x - 7, cell.position.y + 4), 2.5, Color("ffd27a"))


# The desk: a wooden top with papers, an inkwell, and a lamp.
func _draw_desk_tile(cell: Rect2) -> void:
	draw_rect(cell, Color("4e3420"))
	draw_rect(cell.grow(-4), Color("7f5a36"))
	draw_rect(Rect2(cell.position + Vector2(8, 10), Vector2(16, 13)), Color("ece4cc"))
	for i in 3:
		draw_line(Vector2(cell.position.x + 10, cell.position.y + 14 + i * 3), Vector2(cell.position.x + 22, cell.position.y + 14 + i * 3), Color("9a8a6a"), 1.0)
	draw_circle(cell.position + Vector2(cell.size.x * 0.72, cell.size.y * 0.4), 3.0, Color("1a1a24"))
	draw_circle(cell.position + Vector2(cell.size.x * 0.72, cell.size.y * 0.7), 4.0, Color(1.0, 0.8, 0.4, 0.25))
	draw_circle(cell.position + Vector2(cell.size.x * 0.72, cell.size.y * 0.7), 2.5, Color("ffd27a"))


# The hearth: stone that gets cleaner with each stage. Decrepit is cracked and cold, Boarded has ash,
# Patched has a fire, and Restored has a wooden mantel with candles and a warm glow.
func _draw_fireplace_tile(cell: Rect2) -> void:
	var stone: Color = [Color("4a4640"), Color("5e5a52"), Color("6e6a62"), Color("7a7468")][house_stage]
	draw_rect(cell, stone)
	for i in range(1, 4):
		var y := cell.position.y + cell.size.y * float(i) / 4.0
		draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0, 0, 0, 0.25), 1.0)
	var box := Rect2(cell.position + Vector2(8, 14), cell.size - Vector2(16, 20))
	draw_rect(box, Color("1a0f0a"))
	if house_stage >= 2 and firewood._fire_lit():
		draw_colored_polygon(PackedVector2Array([
			box.position + Vector2(4, box.size.y),
			box.position + Vector2(box.size.x * 0.5, box.size.y * 0.2),
			box.position + Vector2(box.size.x - 4, box.size.y),
		]), Color("e0601e"))
		draw_colored_polygon(PackedVector2Array([
			box.position + Vector2(box.size.x * 0.3, box.size.y),
			box.position + Vector2(box.size.x * 0.5, box.size.y * 0.5),
			box.position + Vector2(box.size.x * 0.7, box.size.y),
		]), Color("ffd060"))
	else:
		draw_rect(Rect2(box.position.x, box.end.y - 4, box.size.x, 4), Color("3a3430"))
	if house_stage == 0:
		draw_line(Vector2(cell.position.x + 4, cell.position.y + 10), Vector2(cell.position.x + 14, cell.position.y + 22), Color("2a2622"), 1.5)
		draw_line(cell.position + Vector2(cell.size.x - 4, 4), cell.position + Vector2(cell.size.x - 12, 14), Color(0.8, 0.8, 0.8, 0.4), 1.0)
	if house_stage == 3:
		draw_rect(Rect2(cell.position.x - 2, cell.position.y, cell.size.x + 4, 9), Color("5a3a22"))
		draw_rect(Rect2(cell.position.x - 2, cell.position.y + 9, cell.size.x + 4, 2), Color("3a2414"))
		draw_rect(Rect2(cell.position.x + 6, cell.position.y - 3, 3, 6), Color("f2ecdc"))
		draw_rect(Rect2(cell.end.x - 10, cell.position.y - 3, 3, 6), Color("f2ecdc"))
		draw_circle(cell.get_center(), cell.size.x * 0.9, Color(1.0, 0.7, 0.3, 0.08))


func _draw_interior_cooler(cell: Rect2) -> void:
	draw_rect(cell, Color("8e9ca4"))
	draw_rect(cell.grow(-4), Color("aab8c0"))
	for i in 3:
		draw_circle(cell.position + Vector2(10 + i * 12, 10), 2.0, Color(1, 1, 1, 0.8))
	draw_rect(Rect2(cell.end.x - 10, cell.position.y + cell.size.y * 0.5, 4, 8), Color("4a5258"))


# The doormat by the front door: a woven mat with a border.
func _draw_doormat(cell: Rect2) -> void:
	draw_rect(cell, INT_FLOORS[house_stage])
	draw_rect(cell.grow(-5), Color("8a6a3a"))
	draw_rect(cell.grow(-9), Color("6a4e2a"), false, 2.0)


# Workshop floor: planks running across the tile, with the ends staggered so the boards don't line up.
func _draw_floor_tile(cell: Rect2, tile: Vector2i) -> void:
	draw_rect(cell, TILE_COLORS[Tile.FLOOR])
	for i in range(1, 4):
		var y := cell.position.y + cell.size.y * float(i) / 4.0
		draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0.1, 0.07, 0.04, 0.6), 1.0)
	var join := cell.position.x + (cell.size.x * 0.5 if (tile.x + tile.y) % 2 == 0 else cell.size.x * 0.25)
	draw_line(Vector2(join, cell.position.y), Vector2(join, cell.position.y + cell.size.y * 0.25), Color(0.1, 0.07, 0.04, 0.6), 1.0)
	draw_line(Vector2(join, cell.position.y + cell.size.y * 0.5), Vector2(join, cell.position.y + cell.size.y * 0.75), Color(0.1, 0.07, 0.04, 0.6), 1.0)


# The hens are drawn on their own layer, from where each one currently stands in the coop.
func _draw_hen_layer() -> void:
	var center := Vector2(coop_tile.x + COOP_SIZE * 0.5, coop_tile.y + COOP_SIZE * 0.5) * PX
	for i in hen_pos.size():
		var c: Vector2 = center + hen_pos[i] * PX
		hen_layer.draw_circle(c, PX * 0.16, Color("f4efe0"))
		hen_layer.draw_circle(c + Vector2(PX * 0.14, 0.0), PX * 0.05, Color("d9a040"))


# Each hen wanders inside the coop: it walks to a spot, pauses, then picks another.
func _update_hens(delta: float) -> void:
	# The animals live on the farm, so they stay hidden in the cave, the house, and the village.
	var on_farm := not inside and not in_cave and not _in_village()
	hen_layer.visible = on_farm and coop_built and coop_tile.x >= 0 and hens > 0
	if not hen_layer.visible:
		return
	while hen_pos.size() < hens:
		var start := Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
		hen_pos.append(start)
		hen_goal.append(start)
		hen_wait.append(randf_range(0.0, 2.0))
	while hen_pos.size() > hens:
		hen_pos.pop_back()
		hen_goal.pop_back()
		hen_wait.pop_back()
	for i in hens:
		hen_wait[i] = float(hen_wait[i]) - delta
		var pos: Vector2 = hen_pos[i]
		if float(hen_wait[i]) <= 0.0 and pos.distance_to(hen_goal[i]) < 0.02:
			hen_goal[i] = Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
			hen_wait[i] = randf_range(1.0, 3.5)
		hen_pos[i] = pos.move_toward(hen_goal[i], 0.45 * delta)
	hen_layer.queue_redraw()


# The goats are drawn on their own layer, from where each one stands in the yard below the barn.
func _draw_goat_layer() -> void:
	var center := Vector2(barn_tile.x + BARN_SIZE.x * 0.5, barn_tile.y + BARN_SIZE.y + 0.9) * PX
	for i in goat_pos.size():
		var c: Vector2 = center + goat_pos[i] * PX
		var body := Color("efe6d2")
		goat_layer.draw_colored_polygon(_goat_ellipse(c + Vector2(0, -PX * 0.05), PX * 0.3, PX * 0.19), body)
		goat_layer.draw_circle(c + Vector2(PX * 0.28, -PX * 0.22), PX * 0.13, body)
		goat_layer.draw_circle(c + Vector2(PX * 0.36, -PX * 0.28), PX * 0.03, Color("2a1f16"))
		goat_layer.draw_line(c + Vector2(PX * 0.22, -PX * 0.32), c + Vector2(PX * 0.12, -PX * 0.42), Color("b8a888"), 2.0)
		for leg in [-0.18, 0.12]:
			goat_layer.draw_rect(Rect2(c.x + leg * PX - 1.5, c.y + PX * 0.1, 3, PX * 0.22), Color("b8a888"))


func _goat_ellipse(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 14:
		var angle := TAU * float(i) / 14.0
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	return pts


# Goats wander a little in front of the barn, pausing between steps.
func _update_goats(delta: float) -> void:
	var goats_on_farm := not inside and not in_cave and not _in_village()
	goat_layer.visible = goats_on_farm and barn_built and barn_tile.x >= 0 and goats > 0
	if not goat_layer.visible:
		return
	bleat_timer -= delta
	if bleat_timer <= 0.0:
		play_sfx("bleat", 0.1)
		bleat_timer = randf_range(18.0, 45.0)
	while goat_pos.size() < goats:
		var start := Vector2(randf_range(-1.1, 1.1), randf_range(-0.2, 0.6))
		goat_pos.append(start)
		goat_goal.append(start)
		goat_wait.append(randf_range(0.0, 2.0))
	while goat_pos.size() > goats:
		goat_pos.pop_back()
		goat_goal.pop_back()
		goat_wait.pop_back()
	for i in goats:
		goat_wait[i] = float(goat_wait[i]) - delta
		var pos: Vector2 = goat_pos[i]
		if float(goat_wait[i]) <= 0.0 and pos.distance_to(goat_goal[i]) < 0.02:
			goat_goal[i] = Vector2(randf_range(-1.1, 1.1), randf_range(-0.2, 0.6))
			goat_wait[i] = randf_range(1.5, 4.0)
		goat_pos[i] = pos.move_toward(goat_goal[i], 0.3 * delta)
	_separate_goats()
	goat_layer.queue_redraw()


# Goats keep a little room between them, so two never stand on the same spot.
# Vertical distance counts double, since the goats are seen from above at an angle.
const GOAT_SPACE := 0.5

func _separate_goats() -> void:
	for i in goat_pos.size():
		for j in range(i + 1, goat_pos.size()):
			var a: Vector2 = goat_pos[i]
			var b: Vector2 = goat_pos[j]
			var d: Vector2 = b - a
			var scaled := Vector2(d.x, d.y * 2.0)
			var dist := scaled.length()
			if dist >= GOAT_SPACE:
				continue
			var dir := Vector2(1.0, 0.0) if dist < 0.0001 else scaled / dist
			var push := dir * (GOAT_SPACE - dist) * 0.5
			goat_pos[i] = a - Vector2(push.x, push.y * 0.5)
			goat_pos[j] = b + Vector2(push.x, push.y * 0.5)


func _tile_rect(t: Vector2i) -> Rect2:
	return Rect2(t.x * PX, t.y * PX, PX, PX)
