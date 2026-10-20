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
# The third plot opens at Farming 4 once the house is Patched. It sits between the paths.
const PLOT_THREE := Rect2i(14, 14, 5, 6)
const PLOT_THREE_LEVEL := 4

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
# A small grove of trees on the farm. Each one is felled once a day, like brush.
const GROVE_SPOTS := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
const XP_FELL := 20
# Rocks on the farm. Breaking one gives stone. A pick gives more, and from Mining 2 a small chance of copper ore.
const ROCK_SPOTS := [Vector2i(14, 6), Vector2i(17, 10), Vector2i(27, 17), Vector2i(36, 16), Vector2i(8, 22)]
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
		{"name": "Crude hatchet", "cost": {"wood": 2, "fiber": 2}, "skill": "Bushcrafting", "level": 1},
		{"name": "Stone hatchet", "cost": {"wood": 2, "stone": 2}, "skill": "Forestry", "level": 2},
		{"name": "Copper hatchet", "cost": {"wood": 1, "copper_bar": 2}, "skill": "Smithing", "level": 2},
		{"name": "Iron hatchet", "cost": {"wood": 1, "iron_bar": 2}, "skill": "Smithing", "level": 5},
	],
	"pick": [
		{"name": "Stone pick", "cost": {"wood": 2, "stone": 3}, "skill": "Mining", "level": 1},
		{"name": "Copper pick", "cost": {"wood": 1, "copper_bar": 2}, "skill": "Smithing", "level": 2},
		{"name": "Iron pick", "cost": {"wood": 1, "iron_bar": 2}, "skill": "Smithing", "level": 5},
	],
}

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
const PRESERVED_KINDS := ["smoked", "dried", "canned", "fermented"]
const PRESERVE := [
	{"id": "smoke", "kind": "smoked", "short": "Smoked", "name": "Smoke a fish", "input": "fish", "count": 1, "wood": 1, "fiber": 0, "skill": "Cooking", "level": 2, "xp": 12, "price": 11, "color": "b5703a"},
	{"id": "dry", "kind": "dried", "short": "Dried", "name": "Dry crops", "input": "crops", "count": 2, "wood": 0, "fiber": 0, "skill": "Farming", "level": 2, "xp": 10, "price": 9, "color": "d8c48a"},
	{"id": "can", "kind": "canned", "short": "Canned", "name": "Can crops", "input": "crops", "count": 2, "wood": 0, "fiber": 1, "skill": "Cooking", "level": 3, "xp": 14, "price": 10, "color": "9fb7c9"},
	{"id": "ferment", "kind": "fermented", "short": "Fermented", "name": "Ferment crops", "input": "crops", "count": 2, "wood": 1, "fiber": 0, "skill": "Cooking", "level": 4, "xp": 16, "price": 11, "color": "a6c26a"},
]
# The stall sells what you carry and buys seeds. It is open 06:00 to 18:00.
const STALL_IX := 22
const STALL_IY := 9
const STALL_CLOSE_HOUR := 18.0
const SELL_CROP := 4
const SELL_FISH := 6
const SELL_MEAL := 8
const SEED_TURNIP_PRICE := 3    # per seed, sold in packs of 5
const SEED_PUMPKIN_PRICE := 10  # per seed, sold in packs of 3

# The road east of the farm leads to Lowmere. It is walked in daylight only.
const VILLAGE_W := 36
const VILLAGE_H := 20
const VILLAGE_GATE := Vector2i(0, 10)
const VILLAGE_ARRIVE := Vector2i(2, 10)
const VILLAGE_HOUSES := [Rect2i(4, 3, 5, 4), Rect2i(13, 2, 6, 4), Rect2i(8, 14, 5, 4)]
const VILLAGE_WATER := Rect2i(19, 13, 2, 2)
# Hollows gather in the clearing east of the village wood. They respawn each morning.
const HOLLOW_SPAWNS := [Vector2i(28, 9), Vector2i(31, 13), Vector2i(33, 8)]
const XP_HIT := 4
const XP_KILL := 20
const BASE_HP := 10
const HEAL_MEAL := 4
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
const BARN_COST := {"wood": 10, "fiber": 6, "level": 4}
const BARN_EXTRA_HENS := 4                 # with a barn, the coop holds this many more hens
const HEN_PRICE := 12
const HEN_FEED_CROPS := 1
const HEN_LEAVE_DAYS := 2     # unfed this many days in a row, and a hen wanders off
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

enum Tile { TREE, GRASS, SOIL, PATH, WATER, HOUSE, DOOR, FLOOR, WALL, EXIT, BED, STATION, DESK, FALLOW, STALL, CELLAR, COOLER, GATE, SMOKEHOUSE, FURNACE, PORTAL, CAMP, CAVE_MOUTH, CAVE_EXIT, ORE_COPPER, ORE_IRON, COOP, BARN }

const BLOCKING := [Tile.TREE, Tile.WATER, Tile.HOUSE, Tile.WALL, Tile.BED, Tile.STATION, Tile.DESK, Tile.STALL, Tile.CELLAR, Tile.COOLER, Tile.SMOKEHOUSE, Tile.FURNACE, Tile.CAMP, Tile.ORE_COPPER, Tile.ORE_IRON, Tile.COOP, Tile.BARN]

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
	Tile.PORTAL: Color("6a4fc0"),
	Tile.CAVE_MOUTH: Color("2a2a30"),
	Tile.CAVE_EXIT: Color("a08050"),
	Tile.ORE_COPPER: Color("b87333"),
	Tile.ORE_IRON: Color("8a8f99"),
	Tile.COOP: Color("8a6a3a"),
	Tile.BARN: Color("7a2e26"),
	Tile.CAMP: Color("d07a30"),
}

const BUSH_COLOR := Color("3d6b2a")

const DAY_TINT := Color(1, 1, 1)
const NIGHT_TINT := Color("3a3f6e")

enum Zone { HOMESTEAD, VILLAGE, ASHFORD, WILDS, TOWN }

var map: Array = []                 # farm tiles, [y][x]
var world := PackedByteArray()      # the whole land, index y * WORLD_W + x
var campsite := NO_CAMP             # the one campsite, in world tiles
var world_map_tex: Texture2D = null # the whole land as a small picture for the minimap
var towns: Array = []               # generated towns: origin, size, kind, title, npcs
var current_town := -1              # index into towns while the player is in one
var active_shop := ""               # the shop open in the Shop panel
var bank_materials := {"wood": 0, "fiber": 0, "resin": 0, "hardwood": 0, "stone": 0, "copper_ore": 0, "iron_ore": 0, "copper_bar": 0, "iron_bar": 0, "arrows": 0, "bolts": 0}
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
var fish_timer := 0.0
var fish_layer: Node2D
var plot_two_open := false
var clock := 0.0
var current_hour := START_HOUR
var day := 1
var skill_xp := {"Farming": 0, "Bushcrafting": 0, "Carpentry": 0, "Cleaning": 0, "Fishing": 0, "Cooking": 0, "Combat": 0, "Forestry": 0, "Mining": 0, "Smithing": 0}
var inventory := {"seeds": STARTING_SEEDS, "pumpkin_seeds": 0, "crops": 0, "fish": 0, "meals": 0, "smoked": 0, "dried": 0, "canned": 0, "fermented": 0}
var materials := {"wood": 0, "fiber": 0, "resin": 0, "hardwood": 0, "stone": 0, "copper_ore": 0, "iron_ore": 0, "copper_bar": 0, "iron_bar": 0, "arrows": 0, "bolts": 0}
var tool_tier := {"hatchet": 0, "pick": 0}     # 0 = none; higher tiers come from TOOL_TIERS
var grove_felled := {}
var quarry := {}                                   # Ashford quarry rocks, village tile -> true
var rocks := {}                                  # world tile -> true for unbroken rocks
var stats := {"planted": 0, "harvested": 0, "gathered": 0, "slept": 0, "tidied": 0,
	"fished": 0, "caught": 0, "mended": 0, "cleansed": 0, "cooked": 0, "eaten": 0,
	"pumpkins": 0, "collapses": 0, "events": 0, "sold": 0, "spoiled": 0,
	"talks": 0, "defeated": 0, "delivered": 0, "stalkers": 0, "visited": 0, "crops_given": 0, "preserved": 0, "felled": 0, "mined": 0}
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
var hens_fed_day := -1              # the last day the hens were fed
var hen_unfed_days := 0
var plot_three_open := false
var cleanse_day := 0
var sanity := SANITY_MAX
var sanity_penalty := 0             # permanent cap reduction from collapsing
var inside := false                 # standing in the farmhouse interior
var open_tab := ""                  # "" when the action bar panel is closed
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
var equipment := {"hand_r": "hoe", "offhand": "", "head": "", "neck": "", "chest": "", "wrist": "", "legs": "", "feet": ""}

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
var last_minimap_key: Array = []
var last_cam_tile := Vector2i(-99, -99)   # the tile the camera was last drawn from
var lantern_light: PointLight2D


func _ready() -> void:
	_setup_input()
	_build_map()
	_generate_world()
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
	if not in_cave and not _in_village():
		var cam := camera.get_screen_center_position()
		var cam_tile := Vector2i(floori(cam.x / PX), floori(cam.y / PX))
		if cam_tile != last_cam_tile:
			last_cam_tile = cam_tile
			queue_redraw()
	# Settings pauses the day: the clock stops, foes stand still, and only the menu responds.
	player.paused = open_tab == "Settings"
	placement_ghost.visible = placing != ""
	if placing != "":
		placement_ghost.queue_redraw()
	if player.paused:
		_handle_keys()
		_refresh_panel()
		return
	clock += delta
	_update_hens(delta)
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
	_check_guardian()
	_update_fish_spots(delta)
	_update_fishing(delta)
	_update_foes(delta)
	_update_shots(delta)
	_update_region()
	if _in_village() and current_hour >= STALL_CLOSE_HOUR and not _at_campsite():
		_go_home("Night falls. You are driven back to the homestead.")
	fish_layer.visible = zone == Zone.HOMESTEAD

	var minutes := int(fmod(current_hour, 1.0) * 60.0)
	hud_label.text = "Day %d   %02d:%02d   Sanity %d/%d   Coins %d   HP %d/%d" % [
		day, int(fmod(current_hour, 24.0)), minutes, int(sanity), _sanity_max(), money, hp, max_hp()]

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
	for y in range(fy0, fy1 + 1):
		for x in range(fx0, fx1 + 1):
			var tile: int = map[y][x]
			var cell := _tile_rect(Vector2i(x, y))
			if tile == Tile.TREE:
				_draw_tree(cell, Vector2i(x, y))
			elif tile == Tile.WALL:
				_draw_wall(cell, Vector2i(x, y))
			elif tile == Tile.COOP:
				_draw_coop_tile(cell)
			elif tile == Tile.BARN:
				_draw_barn_tile(cell)
			else:
				draw_rect(cell, TILE_COLORS[tile])
			if tile == Tile.CELLAR or tile == Tile.COOLER or tile == Tile.SMOKEHOUSE or tile == Tile.FURNACE:
				draw_rect(cell, Color(1, 1, 1, 0.8), false, 2.0)
				var label := _storage_label(tile)
				# Pinned to the visible edge, so a store at the screen's edge still shows its name.
				var label_x := maxf(cell.position.x + 2, view_left + 6)
				draw_string(ThemeDB.fallback_font, Vector2(label_x, cell.position.y + PX * 0.6), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.05, 0.03, 0.02))

	for y in INT_H:
		for x in INT_W:
			var kind: int = interior[y][x]
			var cell := _tile_rect(INT_ORIGIN + Vector2i(x, y))
			draw_rect(cell, TILE_COLORS[kind])
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
		var colors: Array = CROPS[crop["kind"]]["colors"]
		var stage: int = crop["stage"]
		var center := _tile_center(pos.x, pos.y)
		var size := PX * (0.2 + 0.2 * stage)
		draw_rect(Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), Color(colors[stage]))

	for pos in rocks:
		var rc := _tile_center(pos.x, pos.y)
		draw_circle(rc, PX * 0.3, Color("7a7a84"))
		draw_circle(rc + Vector2(-5, -4), PX * 0.08, Color("a6a6b0"))
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
	_ensure_action("craft", [KEY_C], [])
	_ensure_action("quests", [KEY_Q], [JOY_BUTTON_RIGHT_SHOULDER])
	_ensure_action("achievements", [KEY_J], [JOY_BUTTON_RIGHT_STICK])
	_ensure_action("house", [KEY_H], [JOY_BUTTON_BACK])
	_ensure_action("buildings", [KEY_U], [])
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
				if PLOT_THREE.has_point(Vector2i(ix, iy)):
					t = Tile.FALLOW   # cleared once Farming 4 and a Patched house
				if ix >= INNER_W - 6 and iy >= INNER_H - 6:
					t = Tile.WATER
				if ix >= HOUSE_IX and ix < HOUSE_IX + HOUSE_W and iy >= HOUSE_IY and iy < HOUSE_IY + HOUSE_H:
					t = Tile.HOUSE
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
	_set_interior(6, 8, Tile.EXIT)            # back out to the farm
	if cooler_built:
		_set_interior(COOLER_INTERIOR.x, COOLER_INTERIOR.y, Tile.COOLER)

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
	grove_felled.clear()
	_apply_grove()
	_fill_rocks()
	_fill_quarry()
	queue_redraw()


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
	# A full-screen root gives the HUD a screen to anchor to. It ignores the mouse.
	var hud_root := Control.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud_root)

	hud_label = _make_label(hud_root, Vector2(16, 12), 24)
	message_label = _make_label(hud_root, Vector2(16, 100), 20)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(620, 0)
	# Messages sit low on the left, clear of the farm's labels and the HUD.
	message_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	message_label.offset_left = 16
	message_label.offset_right = 656
	message_label.offset_top = -124
	message_label.offset_bottom = -24
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

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
	# A dark outline keeps the text readable over grass, the house, and the dark.
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.92))
	label.add_theme_constant_override("outline_size", 6)
	parent.add_child(label)
	return label


# Applies what loading saved: position, indoors or not, and the open panel.
func _restore_saved_state() -> void:
	_check_unlocks()
	zone = saved_zone
	if not WORLD_ENABLED:
		zone = Zone.HOMESTEAD
	hp = clampi(hp, 1, max_hp())
	if has_saved_pos:
		player.position = saved_pos
	# A save made in the wider land returns to the homestead when the world is off.
	if not WORLD_ENABLED and not _in_bounds(_player_tile()):
		player.position = _tile_center(HOMESTEAD_ARRIVE.x, HOMESTEAD_ARRIVE.y)
	if _in_village():
		_sync_region()
		_spawn_foes()
	if saved_inside:
		inside = true
	_set_bounds()
	if saved_panel != "":
		_toggle_tab(saved_panel)


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
	minimap.update_view(map, TILE_COLORS, brush.keys(), player_tile, tonight_shadow)


# --- Input and panels --------------------------------------------------------

func _handle_keys() -> void:
	if Input.is_action_just_pressed("skills"):
		_toggle_tab("Skills")
	if Input.is_action_just_pressed("inventory"):
		_toggle_tab("Inventory")
	if Input.is_action_just_pressed("gear"):
		_toggle_tab("Gear")
	if Input.is_action_just_pressed("craft"):
		_toggle_tab("Craft")
	if Input.is_action_just_pressed("quests"):
		_toggle_tab("Quests")
	if Input.is_action_just_pressed("achievements"):
		_toggle_tab("Achievements")
	if Input.is_action_just_pressed("house"):
		_toggle_tab("House")
	if Input.is_action_just_pressed("buildings"):
		_toggle_tab("Buildings")
	# Esc or Start opens Settings, or closes it if it's already open.
	if Input.is_action_just_pressed("settings"):
		_toggle_tab("Settings")
	# B closes whatever panel is open.
	if Input.is_action_just_pressed("close_panel") and open_tab != "":
		_close_panel()
	if Input.is_action_just_pressed("close_panel") and placing != "":
		_cancel_placement()


func _toggle_tab(tab: String) -> void:
	if placing != "":
		_cancel_placement()
	if open_tab == tab:
		_close_panel()
	else:
		open_tab = tab
		_refresh_panel()


func _close_panel() -> void:
	open_tab = ""
	action_bar.hide_panel()


func _on_panel_action(action_id: String) -> void:
	if action_id.begins_with("preserve:"):
		_preserve(action_id.trim_prefix("preserve:"))
		return
	if action_id.begins_with("ammo:"):
		_craft_ammo(action_id.trim_prefix("ammo:"))
		return
	if action_id.begins_with("tool:"):
		_craft_tool(action_id.trim_prefix("tool:"))
		return
	if action_id.begins_with("sell:"):
		_sell(action_id.trim_prefix("sell:"))
		return
	if action_id.begins_with("smelt:"):
		_smelt(action_id.trim_prefix("smelt:"))
		return
	if action_id.begins_with("buy:"):
		_buy_material(action_id.trim_prefix("buy:"))
		return
	if action_id.begins_with("sellmat:"):
		_sell_material(action_id.trim_prefix("sellmat:"))
		return
	if action_id.begins_with("dep:") or action_id.begins_with("wd:"):
		_bank_move(action_id)
		return
	if action_id == "camp":
		_place_campsite()
		return
	if action_id == "build_furnace":
		_build_furnace()
		return
	if action_id == "build_coop" or action_id == "move_coop":
		_build_coop()
		return
	if action_id == "build_barn" or action_id == "move_barn":
		_build_barn()
		return
	if action_id == "buy_hen":
		_buy_hen()
		return
	if action_id == "feed_hens":
		_feed_hens()
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
		"Craft":
			rows = _craft_rows()
		"Quests":
			rows = _quest_rows()
		"Achievements":
			rows = _achievement_rows()
		"Trade":
			rows = _trade_rows()
		"Shop":
			rows = _general_shop_rows()
		"Bank":
			rows = _bank_rows()
		"Cellar":
			rows = _cellar_rows()
		"Cooler":
			rows = _cooler_rows()
		"Smokehouse":
			rows = _smokehouse_rows()
		"Furnace":
			rows = _furnace_rows()
		"House":
			rows = _house_rows()
		"Buildings":
			rows = _buildings_rows()
		"Settings":
			rows = _settings_rows()
	action_bar.show_panel(open_tab, rows)


func _skill_rows() -> Array:
	var rows: Array = []
	for skill in SKILLS:
		rows.append({
			"name": "%s   Lv %d" % [skill, _level(skill)],
			"value": "%d XP" % skill_xp[skill],
			"progress": _level_progress(skill),
		})
	rows.append({"note": "Farming grows crops. Bushcrafting gathers wood, fiber, and resin. Carpentry trains by mending boards and repairing the house. Cleaning tidies it. Fishing works the sparkling spots at the pond. Cooking turns catches and crops into meals. Forestry fells trees for wood and hardwood. Mining breaks rocks for stone and ore. Smithing turns ore into bars and metal gear." + (" Combat is earned guarding Lowmere." if WORLD_ENABLED else "")})
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
	rows.append({"note": "Crops, fish, meals, and preserved goods fill the pack. Seeds have their own pouch, and materials are uncapped for now."})
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
	rows.append({"section": "Meals"})
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


const CRAFT_TABS := [
	{"id": "gear", "name": "Gear"},
	{"id": "cooking", "name": "Cooking"},
	{"id": "tools", "name": "Tools"},
	{"id": "other", "name": "Other"},
]


# The Gear panel shows only what is worn and what is on the toolbelt.
func _gear_rows() -> Array:
	return [
		{"section": "Equipped"},
		{"grid": _gear_cells(), "columns": 4},
		{"name": "Crafting", "value": "gear, cooking, tools, and more", "button": "Open", "action": "open_craft", "enabled": true},
		{"section": "Toolbelt"},
		{"name": "Hoe", "value": "for tilling soil"},
		{"name": "Axe", "value": _tool_name("hatchet")},
		{"name": "Pickaxe", "value": _tool_name("pick")},
		{"note": "Axes and pickaxes are upgraded in the Craft panel, under Tools. Press C to open it."},
	]


# The Craft panel groups everything made or cooked, one sub-tab at a time.
func _craft_rows() -> Array:
	var tabs: Array = []
	for tab in CRAFT_TABS:
		tabs.append({"id": tab["id"], "name": tab["name"], "action": "craft_tab:" + str(tab["id"])})
	var rows: Array = [{"tabs": tabs, "active": craft_tab}]
	match craft_tab:
		"cooking":
			rows.append_array(_craft_cooking_rows())
		"tools":
			rows.append_array(_craft_tools_rows())
		"other":
			rows.append_array(_craft_other_rows())
		_:
			rows.append_array(_craft_gear_rows())
	return rows


func _craft_gear_rows() -> Array:
	var rows: Array = [{"section": "Craft and equip"}]
	for id in GEAR_ITEMS.keys():
		if id == "hoe":
			continue
		var item: Dictionary = GEAR_ITEMS[id]
		rows.append({
			"name": "%s  (%s)" % [item["name"], str(item["slot"]).replace("_", " ")],
			"value": "%s, %s %d" % [_price_text_items(item["cost"]), str(item.get("skill", "Bushcrafting")), int(item["level"])],
			"button": "Make",
			"action": "craft:" + str(id),
			"enabled": _can_craft(str(id)),
		})
	rows.append({"note": "Crafted gear equips at once and replaces what was worn in that slot. Armor cuts damage from foes. Weapons decide how hard you hit."})
	return rows


func _craft_cooking_rows() -> Array:
	return [
		{"section": "Cook"},
		{
			"name": "Cook a fish",
			"value": "1 fish, 1 wood: +%d Cooking XP" % XP_COOK_FISH,
			"button": "Cook",
			"action": "cook_fish",
			"enabled": _can_cook_fish(),
		},
		{
			"name": "Cook crops",
			"value": "%d crops, 1 wood: +%d Cooking XP" % [COOK_CROP_COUNT, XP_COOK_CROPS],
			"button": "Cook",
			"action": "cook_crops",
			"enabled": _can_cook_crops(),
		},
		{"note": "Eat meals from the Inventory panel. Smoking and preserving are done at the smokehouse, and smelting at the furnace."},
	]


func _craft_tools_rows() -> Array:
	var rows: Array = [{"section": "Tools"}]
	for kind in ["hatchet", "pick"]:
		var tiers: Array = TOOL_TIERS[kind]
		var have := int(tool_tier[kind])
		rows.append({"name": "Best %s" % kind, "value": _tool_name(kind)})
		if have < tiers.size():
			var tier: Dictionary = tiers[have]
			rows.append({
				"name": "Next: %s" % tier["name"],
				"value": "%s, %s %d" % [_price_text_items(tier["cost"]), tier["skill"], int(tier["level"])],
				"button": "Make",
				"action": "tool:" + kind,
				"enabled": _can_craft_tool(kind),
			})
	rows.append({"section": "Ammunition"})
	for kind in ["arrows", "bolts"]:
		var ammo: Dictionary = AMMO[kind]
		rows.append({
			"name": "%s (%d)" % [ammo["name"], int(ammo["yield"])],
			"value": "%s, %s %d. Held: %d" % [_price_text_items(ammo["cost"]), ammo["skill"], int(ammo["level"]), int(materials[kind])],
			"button": "Make",
			"action": "ammo:" + kind,
			"enabled": _can_fletch(kind),
		})
	rows.append({"note": "Tools are kept by tier rather than worn in a slot. Upgrade them one tier at a time."})
	return rows


func _craft_other_rows() -> Array:
	var rows: Array = [{"section": "Lantern"}]
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
	rows.append({"note": "The lantern hangs from the belt and lights a ring around you in the dark."})
	if _in_village():
		rows.append({"section": "Campsite"})
		rows.append({
			"name": "Set up camp here",
			"value": "%d wood, %d fiber, Bushcrafting %d. Face open ground." % [int(CAMP_COST["wood"]), int(CAMP_COST["fiber"]), CAMP_LEVEL],
			"button": "Camp",
			"action": "camp",
			"enabled": _can_camp(),
		})
		rows.append({"note": "A campsite is safe from foes. Rest there from 18:00 like a bed. It saves the game and ends the day. Setting up a new camp moves the old one."})
	return rows


func _price_text_items(cost: Dictionary) -> String:
	var parts: Array = []
	for mat in cost.keys():
		parts.append("%d %s" % [int(cost[mat]), mat])
	return ", ".join(parts) if parts.size() > 0 else "free"


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
	if WORLD_ENABLED:
		rows.append({"section": "Guardian of Lowmere"})
		var guardian_current: Variant = null
		for q in GUARDIAN_QUESTS:
			if not guardian_done.has(q["id"]):
				guardian_current = q
				break
		if guardian_current != null:
			rows.append(_quest_row(guardian_current, true))
		else:
			rows.append({"note": "Lowmere is safe for now."})
		for q in GUARDIAN_QUESTS:
			rows.append(_quest_row(q, false))
	return rows


# A quest is a single line: its name, and Done or its progress. Details open with a button.
# The current chapter starts open; the player's choice overrides that.
func _quest_row(q: Dictionary, expanded: bool) -> Dictionary:
	var id := str(q["id"])
	var done: bool = quests_done.has(q["id"])
	var is_open: bool = bool(quest_open.get(id, expanded))
	var shown := mini(_stat_value(q["stat"]), q["goal"])
	var row := {
		"name": str(q["title"]),
		"struck": done,
		"value": "Done" if done else "%d/%d" % [shown, q["goal"]],
		"button": "Hide" if is_open else "Details",
		"action": ("quest_close:" if is_open else "quest_open:") + id,
		"enabled": true,
	}
	if is_open:
		var note := "%s  Reward: %s" % [q["text"], _reward_text(q["reward"])]
		if expanded:
			note = "%s\n%s" % [q["story"], note]
		row["note"] = note
		row["progress"] = float(shown) / float(q["goal"])
	return row


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
	rows.append({"section": "Today's chores"})
	for chore in _chore_list():
		var row := {"name": chore["name"]}
		if bool(chore["done"]):
			row["value"] = "Done"
		else:
			row["value"] = str(chore["detail"])
			row["button"] = chore["button"]
			row["action"] = chore["action"]
			row["enabled"] = chore["enabled"]
		rows.append(row)
	rows.append({"note": "Each chore left undone adds 1 wear overnight. A night with every chore done brings back %d sanity." % WELL_KEPT_SANITY})
	rows.append({"section": "Upkeep"})
	rows.append({"name": "Wear", "value": "%d of %d" % [wear, WEAR_MAX], "progress": float(wear) / float(WEAR_MAX)})
	rows.append({"note": "The house wears a little each night. Mending, tidying, and repairs bring it down. At %d wear, rain ruins a crop overnight. At %d, a fox can get into the coop. A third plot opens at Farming %d once the house is Patched." % [WEAR_RUNDOWN, WEAR_FOX, PLOT_THREE_LEVEL]})
	rows.append({"section": "Livestock"})
	if not coop_built:
		rows.append({"note": "Hens live in a coop. Build one from the Buildings menu, U."})
	else:
		rows.append({
			"name": "Hens",
			"value": "%d of %d, %d coins each" % [hens, _hens_max(), HEN_PRICE],
			"button": "Buy hen",
			"action": "buy_hen",
			"enabled": _can_buy_hen(),
		})
		rows.append({
			"name": "Feed hens",
			"value": "%d crops, once a day" % (hens * HEN_FEED_CROPS),
			"button": "Feed",
			"action": "feed_hens",
			"enabled": _can_feed_hens(),
		})
		rows.append({"note": "A fed hen lays an egg each morning, kept as a meal. Two unfed days in a row and a hen wanders off."})
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
	rows.append({"section": "Storage"})
	if cellar_built:
		rows.append({"name": "Root cellar", "value": "built, holds %d crops. Stand beside it, facing it, and press Space." % CELLAR_CAP})
	else:
		rows.append({
			"name": "Build a root cellar (holds %d crops)" % CELLAR_CAP,
			"value": _price_text(CELLAR_COST),
			"button": "Build",
			"action": "build_cellar",
			"enabled": _can_afford(CELLAR_COST),
		})
	if cooler_built:
		rows.append({"name": "Cooler", "value": "built, keeps %d fish fresh. Stand beside it, facing it, and press Space." % COOLER_CAP})
	else:
		rows.append({
			"name": "Build a cooler (keeps %d fish fresh)" % COOLER_CAP,
			"value": _price_text(COOLER_COST),
			"button": "Build",
			"action": "build_cooler",
			"enabled": _can_afford(COOLER_COST),
		})
	rows.append({"note": "The workshop, the coop, and the barn are in the Buildings menu (U)."})
	rows.append({"section": "Features"})
	for feature in HOUSE_FEATURES:
		var unlocked: bool = house_stage >= feature["stage"]
		rows.append({
			"name": feature["text"],
			"value": "unlocked" if unlocked else "at %s" % STAGE_NAMES[feature["stage"]],
		})
	return rows


# The Buildings menu: the workshop, the coop, and the barn. Each one is placed on open grass.
func _buildings_rows() -> Array:
	var rows: Array = [{"section": "Workshop"}]
	if smokehouse_built:
		rows.append({"name": "Smokehouse", "value": "built. Stand beside it, facing it, and press Space to preserve food."})
	else:
		rows.append({
			"name": "Build a smokehouse (smokes and preserves food)",
			"value": _price_text(SMOKEHOUSE_COST),
			"button": "Build",
			"action": "build_smokehouse",
			"enabled": _can_afford(SMOKEHOUSE_COST),
		})
	if furnace_built:
		rows.append({"name": "Furnace", "value": "built. Stand beside it, facing it, and press Space to smelt ore."})
	else:
		rows.append({
			"name": "Build a furnace (smelts ore into bars)",
			"value": _price_text(FURNACE_COST),
			"button": "Build",
			"action": "build_furnace",
			"enabled": _can_afford(FURNACE_COST),
		})
	rows.append({"note": "The workshop is a walled building against the east wall of the house. Its door is on the south side."})
	rows.append({"section": "Coop"})
	if not coop_built:
		rows.append({
			"name": "Build a coop (holds %d hens)" % COOP_HENS_MAX,
			"value": _price_text(COOP_COST),
			"button": "Build",
			"action": "build_coop",
			"enabled": _can_build("coop"),
		})
	else:
		rows.append(_placed_row("Coop", "coop", coop_tile, "move_coop"))
	rows.append({"section": "Barn"})
	if not barn_built:
		rows.append({
			"name": "Build a barn (the coop holds %d more hens)" % BARN_EXTRA_HENS,
			"value": _price_text(BARN_COST),
			"button": "Build",
			"action": "build_barn",
			"enabled": _can_build("barn"),
		})
		if not coop_built:
			rows.append({"note": "The barn needs the coop built first."})
	else:
		rows.append(_placed_row("Barn", "barn", barn_tile, "move_barn"))
		rows.append({"note": "With the barn standing, the coop holds %d hens." % _hens_max()})
	return rows


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


func _settings_rows() -> Array:
	return [
		{"section": "Controls"},
		{"name": "Move", "value": "WASD or arrow keys"},
		{"name": "Use, plant, harvest, gather, sleep", "value": "Space or Enter"},
		{"name": "Skills", "value": "K"},
		{"name": "Inventory", "value": "I"},
		{"name": "Gear", "value": "G"},
		{"name": "Craft", "value": "C"},
		{"name": "Quests", "value": "Q"},
		{"name": "Achievements", "value": "J"},
		{"name": "House", "value": "H"},
		{"name": "Buildings", "value": "U"},
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
		{"note": "On a gamepad, open Craft with the Open button on the Gear panel."},
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


# Opens the third plot once Farming reaches level 4 and the house is at least Patched.
func _check_plot_three() -> void:
	if plot_three_open or _level("Farming") < PLOT_THREE_LEVEL or house_stage < 2:
		return
	plot_three_open = true
	for y in range(PLOT_THREE.position.y, PLOT_THREE.end.y):
		for x in range(PLOT_THREE.position.x, PLOT_THREE.end.x):
			map[y + BORDER_Y][x + BORDER_X] = Tile.SOIL
	queue_redraw()


# Opens the second plot once Farming reaches level 2. It stays open afterward.
func _check_unlocks() -> void:
	_check_plot_three()
	if plot_two_open or _level("Farming") < 2:
		return
	plot_two_open = true
	for y in range(PLOT_TWO.position.y, PLOT_TWO.end.y):
		for x in range(PLOT_TWO.position.x, PLOT_TWO.end.x):
			map[y + BORDER_Y][x + BORDER_X] = Tile.SOIL
	queue_redraw()


func _interact() -> void:
	if placing != "":
		_confirm_placement()
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

	if rocks.has(tile):
		_mine(tile)
		return
	if brush.has(tile):
		_gather(tile)
		return

	var kind: int = map[tile.y][tile.x]
	if kind == Tile.TREE and GROVE_SPOTS.has(tile - Vector2i(BORDER_X, BORDER_Y)):
		_chop(tile)
		return
	if kind == Tile.HOUSE:
		_toggle_tab("House")
		return
	if kind == Tile.STALL:
		_open_stall()
		return
	if kind == Tile.COOP:
		_feed_hens()
		return
	if kind == Tile.BARN:
		_show_message("The barn stands here. With it, the coop holds %d hens." % _hens_max())
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
	hp = mini(max_hp(), hp + HEAL_MEAL)
	_show_message("You eat a warm meal. Your mind steadies. HP %d/%d" % [hp, max_hp()])


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
	var used := int(inventory["crops"]) + int(inventory["fish"]) + int(inventory["meals"])
	for kind in PRESERVED_KINDS:
		used += int(inventory[kind])
	return used


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
	if money < int(cost.get("coins", 0)):
		return false
	if _level("Carpentry") < int(cost.get("level", 1)):
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


func _price_text(cost: Dictionary) -> String:
	var parts: Array = []
	if int(cost.get("coins", 0)) > 0:
		parts.append("%d coins" % int(cost["coins"]))
	for key in cost.keys():
		if key == "coins" or key == "level" or int(cost[key]) <= 0:
			continue
		parts.append("%d %s" % [int(cost[key]), key])
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
	for entry in PRESERVE:
		if entry["kind"] == kind:
			price = int(entry["price"])
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
		_show_message("The root cellar is dug beside the house. It holds %d crops." % CELLAR_CAP)
	else:
		cooler_built = true
		_show_message("The cooler is built beside the house. It keeps %d fish fresh." % COOLER_CAP)
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
		] + _preserved_sell_rows() + [
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


# --- Smokehouse and preserving ---------------------------------------------

func _build_smokehouse() -> void:
	if not _can_afford(SMOKEHOUSE_COST):
		_show_message("You can't build that yet. Needs %s." % _price_text(SMOKEHOUSE_COST))
		return
	_pay(SMOKEHOUSE_COST)
	smokehouse_built = true
	_build_interior()
	_show_message("The smokehouse is built beside the house. Smoke fish and preserve crops there.")
	queue_redraw()


func _can_preserve(entry: Dictionary) -> bool:
	if not smokehouse_built:
		return false
	if _level(str(entry["skill"])) < int(entry["level"]):
		return false
	if int(inventory[entry["input"]]) < int(entry["count"]):
		return false
	if int(materials["wood"]) < int(entry["wood"]):
		return false
	return int(materials["fiber"]) >= int(entry["fiber"])


func _preserve(id: String) -> void:
	if not smokehouse_built:
		_show_message("Build a smokehouse from the House panel first.")
		return
	var entry: Dictionary = {}
	for e in PRESERVE:
		if e["id"] == id:
			entry = e
	if entry.is_empty():
		return
	if not _can_preserve(entry):
		_show_message("You need %d %s, the materials, and %s %d." % [int(entry["count"]), entry["input"], entry["skill"], int(entry["level"])])
		return
	inventory[entry["input"]] -= int(entry["count"])
	materials["wood"] -= int(entry["wood"])
	materials["fiber"] -= int(entry["fiber"])
	inventory[entry["kind"]] += 1
	stats["preserved"] += 1
	_grant_xp(str(entry["skill"]), int(entry["xp"]))
	_show_message("You make a %s. +%d %s XP" % [str(entry["short"]).to_lower(), int(entry["xp"]), entry["skill"]])


func _smokehouse_rows() -> Array:
	var rows: Array = [
		{"section": "Smokehouse"},
		{"note": "Preserved goods keep in your pack, so nothing spoils. Stand beside the smokehouse, facing it, and press Space to open this panel."},
	]
	for entry in PRESERVE:
		var needs: Array = ["%d %s" % [int(entry["count"]), entry["input"]]]
		if int(entry["wood"]) > 0:
			needs.append("%d wood" % int(entry["wood"]))
		if int(entry["fiber"]) > 0:
			needs.append("%d fiber" % int(entry["fiber"]))
		rows.append({
			"name": "%s (%s)" % [entry["name"], ", ".join(needs)],
			"value": "%s %d, +%d XP, sells %d" % [entry["skill"], int(entry["level"]), int(entry["xp"]), int(entry["price"])],
			"button": "Make",
			"action": "preserve:" + str(entry["id"]),
			"enabled": _can_preserve(entry),
		})
	rows.append({
		"name": "Held",
		"value": "smoked %d, dried %d, canned %d, fermented %d" % [int(inventory["smoked"]), int(inventory["dried"]), int(inventory["canned"]), int(inventory["fermented"])],
	})
	return rows


func _preserved_sell_rows() -> Array:
	var rows: Array = []
	for entry in PRESERVE:
		var held := int(inventory[entry["kind"]])
		if held <= 0:
			continue
		rows.append({
			"name": "%s (%d each)" % [entry["short"], int(entry["price"])],
			"value": "%d held" % held,
			"button": "Sell all",
			"action": "sell:" + str(entry["kind"]),
			"enabled": true,
		})
	return rows


func _storage_label(tile: int) -> String:
	if tile == Tile.COOLER:
		return "Cooler"
	if tile == Tile.SMOKEHOUSE:
		return "Smoke"
	if tile == Tile.FURNACE:
		return "Furnace"
	return "Cellar"


# --- Forestry and tools -------------------------------------------------------

func _chop(tile: Vector2i) -> void:
	if int(tool_tier["hatchet"]) < 1:
		_show_message("You need a hatchet. Craft a crude one from the Craft panel.")
		return
	grove_felled[tile] = true
	_apply_grove()
	materials["wood"] += 3
	var found := "3 wood"
	if int(tool_tier["hatchet"]) >= 3:
		materials["hardwood"] += 2
		found += ", 2 hardwood"
	stats["felled"] += 1
	_grant_xp("Forestry", XP_FELL)
	_show_message("You fell the tree. +%s. +%d Forestry XP" % [found, XP_FELL])
	queue_redraw()


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
	if _level(str(tier["skill"])) < int(tier["level"]):
		return false
	return _has_materials(tier["cost"])


func _craft_tool(kind: String) -> void:
	if not _can_craft_tool(kind):
		_show_message("You need the materials and skill level for the next %s." % kind)
		return
	var tier: Dictionary = TOOL_TIERS[kind][int(tool_tier[kind])]
	for mat in tier["cost"].keys():
		materials[mat] -= int(tier["cost"][mat])
	tool_tier[kind] += 1
	_grant_xp(str(tier["skill"]), 10)
	_show_message("You make a %s. +10 %s XP" % [tier["name"], tier["skill"]])


# --- Mining --------------------------------------------------------------------

func _fill_rocks() -> void:
	rocks.clear()
	for spot in ROCK_SPOTS:
		rocks[_world_tile(spot.x, spot.y)] = true


func _mine(tile: Vector2i) -> void:
	rocks.erase(tile)
	var pick := int(tool_tier["pick"])
	var amount := 2 if pick >= 1 else 1
	materials["stone"] += amount
	var found := "%d stone" % amount
	if pick >= 1 and _level("Mining") >= ORE_MINING_LEVEL and randf() < ORE_CHANCE:
		materials["copper_ore"] += 1
		found += " and copper ore"
	stats["mined"] += 1
	_grant_xp("Mining", XP_MINE)
	_show_message("You break the rock. +%s. +%d Mining XP" % [found, XP_MINE])
	queue_redraw()


func _tiles_to_array(tiles: Dictionary) -> Array:
	var arr: Array = []
	for tile in tiles.keys():
		arr.append([tile.x, tile.y])
	return arr


# --- Smithing -------------------------------------------------------------------

func _build_furnace() -> void:
	if not _can_afford(FURNACE_COST):
		_show_message("You can't build that yet. Needs %s." % _price_text(FURNACE_COST))
		return
	_pay(FURNACE_COST)
	furnace_built = true
	_build_interior()
	_show_message("The furnace is built beside the house. Smelt ore into bars there.")
	queue_redraw()


func _can_smelt(kind: String) -> bool:
	if not furnace_built:
		return false
	if _level("Smithing") < int(SMELT_LEVEL[kind]):
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
	_grant_xp("Smithing", XP_SMELT)
	_show_message("You smelt a %s bar. +%d Smithing XP" % [kind, XP_SMELT])


func _furnace_rows() -> Array:
	var rows: Array = [
		{"section": "Furnace"},
		{"note": "Smelting turns ore into bars, with wood as fuel. Bars make metal tools and gear. Stand beside the furnace, facing it, and press Space to open this panel."},
	]
	for kind in ["copper", "iron"]:
		rows.append({
			"name": "Smelt a %s bar (1 %s ore, 1 wood)" % [kind, kind],
			"value": "Smithing %d, +%d XP. Held: %d ore, %d bars" % [int(SMELT_LEVEL[kind]), XP_SMELT, int(materials[kind + "_ore"]), int(materials[kind + "_bar"])],
			"button": "Smelt",
			"action": "smelt:" + kind,
			"enabled": _can_smelt(kind),
		})
	return rows


# --- Ranged combat and ammunition ----------------------------------------------

func _can_fletch(kind: String) -> bool:
	var ammo: Dictionary = AMMO[kind]
	if _level(str(ammo["skill"])) < int(ammo["level"]):
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
	_grant_xp(str(ammo["skill"]), 6)
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
	_grant_xp("Combat", XP_HIT)
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
	quarry.erase(tile)
	var kind := "copper_ore" if _level("Mining") >= 3 else "stone"
	if _level("Mining") >= 5 and pick >= 2 and randf() < 0.5:
		kind = "iron_ore"
	materials[kind] += 1
	stats["mined"] += 1
	_grant_xp("Mining", XP_MINE)
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
	if _level("Mining") < need_level:
		_show_message("You need Mining %d to work %s ore." % [need_level, ore])
		return
	cave[tile.y][tile.x] = Tile.FLOOR
	cave_mined[tile] = true
	materials[ore + "_ore"] += 1
	_grant_xp("Mining", XP_MINE)
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


# Where a save puts you: in the cave, the save records the homestead instead.
func _save_pos() -> Array:
	if in_cave:
		var home := _tile_center(HOMESTEAD_ARRIVE.x, HOMESTEAD_ARRIVE.y)
		return [home.x, home.y]
	return [player.position.x, player.position.y]


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

func _general_shop_rows() -> Array:
	var rows: Array = [
		{"section": "Purse"},
		{"name": "Coins", "value": str(money)},
		{"section": "Buy materials (%d at a time)" % GENERAL_BUY_QTY},
	]
	for key in GENERAL_BUY.keys():
		var price := int(GENERAL_BUY[key])
		rows.append({
			"name": "%s (%d each)" % [str(key).capitalize(), price],
			"value": "%d held" % int(materials[key]),
			"button": "Buy %d" % GENERAL_BUY_QTY,
			"action": "buy:%s" % key,
			"enabled": money >= price * GENERAL_BUY_QTY,
		})
	rows.append({"section": "Sell materials (half price)"})
	for key in GENERAL_BUY.keys():
		var sell := maxi(1, int(GENERAL_BUY[key]) / 2)
		rows.append({
			"name": "%s (%d each)" % [str(key).capitalize(), sell],
			"value": "%d held" % int(materials[key]),
			"button": "Sell all",
			"action": "sellmat:%s" % key,
			"enabled": int(materials[key]) > 0,
		})
	return rows


func _buy_material(key: String) -> void:
	if not GENERAL_BUY.has(key):
		return
	var price := int(GENERAL_BUY[key]) * GENERAL_BUY_QTY
	if money < price:
		_show_message("That costs %d coins. You have %d." % [price, money])
		return
	money -= price
	materials[key] += GENERAL_BUY_QTY
	_show_message("You buy %d %s for %d coins." % [GENERAL_BUY_QTY, key, price])


func _sell_material(key: String) -> void:
	if not GENERAL_BUY.has(key):
		return
	var count := int(materials[key])
	if count <= 0:
		_show_message("You have none of that to sell.")
		return
	var price := maxi(1, int(GENERAL_BUY[key]) / 2)
	materials[key] = 0
	money += count * price
	_show_message("Sold %d %s for %d coins." % [count, key, count * price])


func _bank_rows() -> Array:
	var rows: Array = [
		{"section": "Coins"},
		{"name": "Held", "value": str(money), "button": "Bank all", "action": "dep:coins", "enabled": money > 0},
		{"name": "Banked", "value": str(bank_coins), "button": "Take all", "action": "wd:coins", "enabled": bank_coins > 0},
		{"section": "Goods"},
	]
	for key in bank_materials.keys():
		var held := int(materials[key])
		var banked := int(bank_materials[key])
		if held == 0 and banked == 0:
			continue
		rows.append({"name": "%s: held" % str(key).capitalize(), "value": str(held), "button": "Bank all", "action": "dep:%s" % key, "enabled": held > 0})
		rows.append({"name": "%s: banked" % str(key).capitalize(), "value": str(banked), "button": "Take all", "action": "wd:%s" % key, "enabled": banked > 0})
	if rows.size() == 4:
		rows.append({"note": "Nothing to bank yet. Goods you deposit are kept safe here, even if you lose them in the wild."})
	return rows


func _bank_move(action_id: String) -> void:
	var deposit := action_id.begins_with("dep:")
	var key := action_id.trim_prefix("dep:") if deposit else action_id.trim_prefix("wd:")
	if key == "coins":
		if deposit:
			bank_coins += money
			_show_message("You bank %d coins." % money)
			money = 0
		else:
			money += bank_coins
			_show_message("You take %d coins from the bank." % bank_coins)
			bank_coins = 0
		return
	if not bank_materials.has(key):
		return
	if deposit:
		bank_materials[key] += int(materials[key])
		materials[key] = 0
	else:
		materials[key] += int(bank_materials[key])
		bank_materials[key] = 0


# --- Campsites ----------------------------------------------------------------

func _can_camp() -> bool:
	return _level("Bushcrafting") >= CAMP_LEVEL and _has_materials(CAMP_COST)


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
	_grant_xp("Bushcrafting", 15)
	_save_game()
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
	_change_sanity(SLEEP_SANITY)
	_end_day("You rest by the campsite through the night.", false)


# --- Slot grids for the pack, seed pouch, and equipment ---------------------

func _pack_cells() -> Array:
	var cells: Array = []
	for i in int(inventory["crops"]):
		cells.append({"color": "8fd16b", "label": "Crop", "tip": "Harvested crop"})
	for i in int(inventory["fish"]):
		cells.append({"color": "6fb8d9", "label": "Fish", "tip": "Fish. Spoils overnight unless stored in the cooler."})
	for i in int(inventory["meals"]):
		cells.append({"color": "e0a050", "label": "Meal", "tip": "Cooked meal. Eat it for sanity."})
	for entry in PRESERVE:
		for _i in int(inventory[entry["kind"]]):
			cells.append({"color": entry["color"], "label": entry["short"], "tip": "%s. Keeps in the pack." % entry["short"]})
	while cells.size() < _pack_capacity():
		cells.append({"empty": true, "tip": "Empty slot"})
	return cells


func _seed_cells() -> Array:
	return [
		{"color": "a8d46f", "label": "Turnip", "count": str(inventory["seeds"]), "tip": "Turnip seeds. Kept in the seed pouch."},
		{"color": "d98a35", "label": "Pumpkin", "count": str(inventory["pumpkin_seeds"]), "tip": "Pumpkin seeds. Farming %d to plant." % PUMPKIN_LEVEL},
	]


# Ten slots in four columns. The top row holds the back, head, neck, and belt.
# The lantern hangs from the belt, so the offhand is free for a shield.
func _gear_cells() -> Array:
	var bag_name := "Pack" if bag_tier == 0 else str(BAG_TIERS[bag_tier - 1]["name"])
	var lantern: Dictionary = {"empty": true, "label": "Belt", "tip": "Belt: no lantern built yet"}
	if lantern_tier > 0:
		var current: Dictionary = LANTERN_TIERS[lantern_tier - 1]
		lantern = {"color": "ffd38a", "label": current["name"], "tip": "Belt: %s, ring %.1f tiles" % [current["name"], current["radius"]]}
	return [
		{"color": "7a5a3a", "label": bag_name, "tip": "Back: %s, %d pack slots" % [bag_name, _pack_capacity()]},
		_slot_cell("head", "Head"),
		_slot_cell("neck", "Neck"),
		lantern,
		_slot_cell("offhand", "Off hand"),
		_slot_cell("chest", "Chest"),
		_slot_cell("hand_r", "Main hand"),
		_slot_cell("wrist", "Wrist"),
		_slot_cell("legs", "Legs"),
		_slot_cell("feet", "Feet"),
	]


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
	return BASE_HP + _level("Combat") - 1


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
		_talk(_zone_npcs()[idx])
		return
	if zone == Zone.ASHFORD and quarry.has(_tile_in_front()):
		_quarry(_tile_in_front())
		return
	if campsite != NO_CAMP and _tile_in_front() == campsite:
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
	if npc["id"] == "tomas" and int(inventory["meals"]) > 0 and int(stats["delivered"]) == 0:
		inventory["meals"] -= 1
		stats["delivered"] += 1
		_show_message("Tomas: Bread and thanks. The village eats tonight.")
		return
	if npc["id"] == "harrow" and int(inventory["crops"]) >= 5 and int(stats["crops_given"]) < 5:
		inventory["crops"] -= 5
		stats["crops_given"] += 5
		_show_message("Harrow: Five crops. The wheel will turn again.")
		return
	var stage := mini(guardian_done.size(), lines.size() - 1)
	_show_message("%s: %s" % [npc["name"], lines[stage]])


# Each tick, you swing and the hollow answers. Moving away breaks the fight.
# Losing a fight sends you home, shaken. You're back at full health by morning.
func _fallen() -> void:
	_change_sanity(-10.0)
	hp = max_hp()
	_go_home("You collapse in the wood. You wake at the homestead, shaken. Sanity -10.")


func _check_guardian() -> void:
	if not WORLD_ENABLED:
		return
	for q in GUARDIAN_QUESTS:
		if guardian_done.has(q["id"]):
			continue
		if _stat_value(q["stat"]) < q["goal"]:
			break
		guardian_done[q["id"]] = true
		_grant_reward(q["reward"])
		_show_message("Guardian quest complete: %s. Reward: %s" % [q["title"], _reward_text(q["reward"])])


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
				_draw_tree(_tile_rect(Vector2i(x, y)), Vector2i(x, y))
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
	var weapon := str(equipment["hand_r"])
	if weapon != "" and GEAR_ITEMS[weapon].has("ammo"):
		_fire(weapon)
		return
	if swing_cool > 0.0:
		return
	swing_cool = SWING_COOLDOWN
	swing_time = SWING_TIME
	swing_dir = player.facing
	var dmg := _weapon_damage()
	var combat := _level("Combat")
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
		_grant_xp("Combat", XP_HIT)
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
	_grant_xp("Combat", int(st["xp"]))
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
	if _level(str(item.get("skill", "Bushcrafting"))) < int(item["level"]):
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
	_grant_xp(str(item.get("skill", "Bushcrafting")), 10)
	_show_message("You fashion a %s and equip it. +10 %s XP" % [item["name"], item.get("skill", "Bushcrafting")])


func _slot_cell(slot: String, label: String) -> Dictionary:
	var id := str(equipment[slot])
	if id == "":
		return {"empty": true, "label": label, "tip": "%s: empty" % label}
	var item: Dictionary = GEAR_ITEMS[id]
	var color := "8a8f96" if slot == "hand_r" else "9c8362"
	return {
		"color": color, "label": item["name"],
		"tip": "%s: %s. Damage %d, defense %d" % [label, item["name"], int(item["dmg"]), int(item["def"])],
	}


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
	wear = maxi(0, wear - WEAR_REPAIR)
	_check_plot_three()
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
	wear = maxi(0, wear - WEAR_MEND)
	_grant_xp("Carpentry", XP_MEND)
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


# A building can be built once, from the Buildings menu. A barn needs the coop first.
func _can_build(kind: String) -> bool:
	if _is_built(kind) or (kind == "barn" and not coop_built):
		return false
	var cost := _build_cost(kind)
	return _level("Carpentry") >= int(cost["level"]) \
		and int(materials["wood"]) >= int(cost["wood"]) and int(materials["fiber"]) >= int(cost["fiber"])


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
		if kind == "barn" and not coop_built:
			_show_message("A barn needs the coop built first.")
		else:
			_show_message("A %s needs %s." % [kind, _price_text(_build_cost(kind))])
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
		_grant_xp("Carpentry", XP_REPAIR)
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
		_show_message("The barn stands here now. With it, the coop holds %d hens." % _hens_max())
	else:
		_show_message("The coop stands here now. Stand beside it, facing it, and press Space to feed the hens.")


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


# The coop holds COOP_HENS_MAX hens, and a barn makes room for BARN_EXTRA_HENS more.
func _hens_max() -> int:
	return COOP_HENS_MAX + (BARN_EXTRA_HENS if barn_built else 0)


func _can_buy_hen() -> bool:
	return coop_built and hens < _hens_max() and money >= HEN_PRICE


func _buy_hen() -> void:
	if not _can_buy_hen():
		_show_message("A hen costs %d coins, and the coop holds %d." % [HEN_PRICE, _hens_max()])
		return
	money -= HEN_PRICE
	hens += 1
	queue_redraw()
	_show_message("A hen settles into the coop.")


func _can_feed_hens() -> bool:
	return hens > 0 and hens_fed_day != day and int(inventory["crops"]) >= hens * HEN_FEED_CROPS


func _feed_hens() -> void:
	if hens > 0 and hens_fed_day == day:
		_show_message("The hens are fed for today.")
		return
	if not _can_feed_hens():
		_show_message("The hens need %d crops." % (hens * HEN_FEED_CROPS))
		return
	inventory["crops"] -= hens * HEN_FEED_CROPS
	hens_fed_day = day
	_show_message("You feed the hens.")


# The day's chores. Each is done or not. Chores left undone wear the house overnight.
func _chore_list() -> Array:
	var chores: Array = []
	chores.append({"name": "Tidy the house", "detail": "+%d XP, once a day" % XP_TIDY, "done": tidied_day == day, "button": "Tidy", "action": "tidy", "enabled": _can_tidy()})
	chores.append({"name": "Mend a board", "detail": "%d wood, %d fiber, +%d XP. %d left today" % [MEND_WOOD, MEND_FIBER, XP_MEND, _mends_left()], "done": mend_day == day and mends_today > 0, "button": "Mend", "action": "mend", "enabled": _can_mend()})
	if hens > 0:
		chores.append({"name": "Feed the hens", "detail": "%d crops" % (hens * HEN_FEED_CROPS), "done": hens_fed_day == day, "button": "Feed", "action": "feed_hens", "enabled": _can_feed_hens()})
	return chores


# Runs at the end of each day, before the crops grow: the house wears, hens lay or leave,
# and rain or a fox may strike. Returns a note for the morning message.
func _settle_day() -> String:
	var notes := ""
	var missed := 0
	for chore in _chore_list():
		if not bool(chore["done"]):
			missed += 1
	wear = mini(wear + WEAR_PER_NIGHT + missed, WEAR_MAX)
	if missed > 0:
		notes += " %d chore%s left undone, so the house wears faster." % [missed, "" if missed == 1 else "s"]
	else:
		_change_sanity(WELL_KEPT_SANITY)
		notes += " The house is kept well, and you sleep easier. +%d sanity." % WELL_KEPT_SANITY
	if hens > 0:
		if hens_fed_day == day:
			hen_unfed_days = 0
			var room := maxi(0, _pack_capacity() - _pack_used())
			var eggs := mini(hens, room)
			if eggs > 0:
				inventory["meals"] += eggs
				notes += " The hens laid %d egg%s." % [eggs, "" if eggs == 1 else "s"]
			if eggs < hens:
				notes += " Some eggs spoiled for want of pack room."
		else:
			hen_unfed_days += 1
			if hen_unfed_days >= HEN_LEAVE_DAYS:
				hens -= 1
				hen_unfed_days = 0
				notes += " A hungry hen wandered off."
	if wear >= WEAR_FOX and hens > 0 and randf() < 0.5:
		hens -= 1
		notes += " A fox got into the coop and took a hen."
	if wear >= WEAR_RUNDOWN and not crops.is_empty():
		var spot = crops.keys().pick_random()
		crops.erase(spot)
		notes += " Rain came through the roof and ruined a crop."
	return notes


# Sleeping only happens at the bed, from 18:00 until 03:00.
func _try_sleep() -> void:
	if _in_village():
		_show_message("You can only sleep in your own bed, at the homestead.")
		return
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
	wear = maxi(0, wear - WEAR_TIDY)
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
	for pos in crops.keys():
		crops[pos]["stage"] = min(crops[pos]["stage"] + 1, MAX_STAGE)
	day += 1
	clock = 0.0
	tonight_shadow = Vector2i(-1, -1)
	_respawn_brush()
	_update_shadow_tile()
	_show_message("%s Your crops grew overnight.%s%s" % [base, spoil_note, upkeep_note])
	_save_game()
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
	inside = true
	player.position = _tile_center(INT_ORIGIN.x + 6, INT_ORIGIN.y + 6)
	_set_bounds()
	_show_message("You step inside. The air is cold and smells of old wood.")


func _leave_house() -> void:
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

func _save_game() -> void:
	var data := {
		"day": day,
		"skill_xp": skill_xp,
		"inventory": inventory,
		"materials": materials,
		"stats": stats,
		"quests_done": quests_done,
		"zone": zone,
		"world_version": 1,
		"campsite": [campsite.x, campsite.y],
		"hp": hp,
		"guardian_done": guardian_done,
		"equipment": equipment,
		"money": money,
		"bag_tier": bag_tier,
		"cellar_built": cellar_built,
		"cooler_built": cooler_built,
		"cellar_stock": cellar_stock,
		"cooler_stock": cooler_stock,
		"smokehouse_built": smokehouse_built,
		"furnace_built": furnace_built,
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
		"player_pos": _save_pos(),
		"inside": inside,
		"open_tab": open_tab,
		"crops": _crops_to_array(),
		"brush": _brush_to_array(),
		"felled": _felled_to_array(),
		"rocks": _tiles_to_array(rocks),
		"quarry": _tiles_to_array(quarry),
		"tool_tier": tool_tier,
		"bank_materials": bank_materials,
		"bank_coins": bank_coins,
		"cave_mined": _tiles_to_array(cave_mined),
		"cave_mined_day": cave_mined_day,
		"wear": wear,
		"coop_built": coop_built,
		"coop_x": coop_tile.x,
		"coop_y": coop_tile.y,
		"barn_built": barn_built,
		"barn_x": barn_tile.x,
		"barn_y": barn_tile.y,
		"hens": hens,
		"hens_fed_day": hens_fed_day,
		"hen_unfed_days": hen_unfed_days,
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
	_merge_ints(bank_materials, data.get("bank_materials"))
	bank_coins = int(data.get("bank_coins", 0))
	bag_tier = int(data.get("bag_tier", 0))
	cellar_built = bool(data.get("cellar_built", false))
	cooler_built = bool(data.get("cooler_built", false))
	cellar_stock = int(data.get("cellar_stock", 0))
	cooler_stock = int(data.get("cooler_stock", 0))
	smokehouse_built = bool(data.get("smokehouse_built", false))
	furnace_built = bool(data.get("furnace_built", false))
	saved_zone = int(data.get("zone", 0)) if int(data.get("world_version", 0)) >= 1 else 0
	var saved_camp: Variant = data.get("campsite", null)
	if typeof(saved_camp) == TYPE_ARRAY and saved_camp.size() == 2:
		campsite = Vector2i(int(saved_camp[0]), int(saved_camp[1]))
		_apply_campsite()
	hp = int(data.get("hp", BASE_HP))
	guardian_done = data.get("guardian_done", {})
	var saved_eq: Variant = data.get("equipment", {})
	if typeof(saved_eq) == TYPE_DICTIONARY:
		for slot in equipment.keys():
			if saved_eq.has(slot):
				equipment[slot] = str(saved_eq[slot])
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
	for g in data.get("felled", []):
		grove_felled[Vector2i(int(g[0]), int(g[1]))] = true
	_apply_grove()
	_merge_ints(tool_tier, data.get("tool_tier"))
	if data.has("rocks"):
		rocks.clear()
		for r in data["rocks"]:
			rocks[Vector2i(int(r[0]), int(r[1]))] = true
	else:
		_fill_rocks()
	cave_mined_day = int(data.get("cave_mined_day", -1))
	wear = int(data.get("wear", 0))
	coop_built = bool(data.get("coop_built", false))
	coop_tile = Vector2i(int(data.get("coop_x", -1)), int(data.get("coop_y", -1)))
	barn_built = bool(data.get("barn_built", false))
	barn_tile = Vector2i(int(data.get("barn_x", -1)), int(data.get("barn_y", -1)))
	hens = int(data.get("hens", 0))
	hens_fed_day = int(data.get("hens_fed_day", -1))
	hen_unfed_days = int(data.get("hen_unfed_days", 0))
	if data.has("cave_mined"):
		cave_mined.clear()
		for c in data["cave_mined"]:
			cave_mined[Vector2i(int(c[0]), int(c[1]))] = true
	if data.has("quarry"):
		quarry.clear()
		for q in data["quarry"]:
			quarry[Vector2i(int(q[0]), int(q[1]))] = true
	else:
		_fill_quarry()
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

# Each level costs more XP than the last. Reaching level L takes 50 * (L - 1) * L XP in total:
# level 2 at 100, level 3 at 300, level 4 at 600, level 5 at 1000, level 6 at 1500.
func _level(skill: String) -> int:
	var xp := int(skill_xp[skill])
	var n := int(floor((-1.0 + sqrt(1.0 + 4.0 * float(xp) / 50.0)) / 2.0))
	return n + 1


# The XP needed to reach a level, counted from the start.
func _xp_for_level(level: int) -> int:
	return 50 * (level - 1) * level


# How far through the current level the skill is, from 0.0 to 1.0.
func _level_progress(skill: String) -> float:
	var level := _level(skill)
	var start := _xp_for_level(level)
	var span := _xp_for_level(level + 1) - start
	return clampf(float(int(skill_xp[skill]) - start) / float(span), 0.0, 1.0)


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
	if _in_village():
		return _npc_index(t) != -1
	return not inside and brush.has(t)


func _world_tile(ix: int, iy: int) -> Vector2i:
	return Vector2i(ix + BORDER_X, iy + BORDER_Y)


func _tile_center(wx: int, wy: int) -> Vector2:
	return Vector2(wx * PX + PX * 0.5, wy * PX + PX * 0.5)


# Timber walls with plank lines. The top row of the workshop is its roof.
func _draw_wall(cell: Rect2, pos: Vector2i) -> void:
	var roof := pos.y == WORKSHOP_RECT.position.y + BORDER_Y
	draw_rect(cell, Color("4f3622") if roof else Color("6b4c33"))
	if not roof:
		for i in range(1, 4):
			var y := cell.position.y + cell.size.y * float(i) / 4.0
			draw_line(Vector2(cell.position.x, y), Vector2(cell.end.x, y), Color(0.16, 0.11, 0.07, 0.55), 1.0)
	else:
		draw_line(Vector2(cell.position.x, cell.end.y - 2), Vector2(cell.end.x, cell.end.y - 2), Color(0.1, 0.07, 0.05, 0.7), 2.0)


# A coop tile: a wooden floor with a sloped roof band along the top.
func _draw_coop_tile(cell: Rect2) -> void:
	draw_rect(cell, Color("7a5230"))
	draw_rect(cell.grow(-5), Color("94693d"))
	draw_rect(Rect2(cell.position, Vector2(cell.size.x, cell.size.y * 0.24)), Color("5a2e1c"))


# A barn tile: red boards with pale trim lines, and a ridge along the top.
func _draw_barn_tile(cell: Rect2) -> void:
	draw_rect(cell, Color("7a2e26"))
	draw_rect(cell.grow(-4), Color("8f3a2f"))
	for i in 3:
		var x := cell.position.x + cell.size.x * (0.25 + 0.25 * i)
		draw_line(Vector2(x, cell.position.y + 3), Vector2(x, cell.end.y - 3), Color(0.85, 0.8, 0.7, 0.35), 1.5)
	draw_rect(Rect2(cell.position, Vector2(cell.size.x, cell.size.y * 0.2)), Color("4a1a16"))


# The hens are drawn on their own layer, from where each one currently stands in the coop.
func _draw_hen_layer() -> void:
	var center := Vector2(coop_tile.x + COOP_SIZE * 0.5, coop_tile.y + COOP_SIZE * 0.5) * PX
	for i in hen_pos.size():
		var c: Vector2 = center + hen_pos[i] * PX
		hen_layer.draw_circle(c, PX * 0.16, Color("f4efe0"))
		hen_layer.draw_circle(c + Vector2(PX * 0.14, 0.0), PX * 0.05, Color("d9a040"))


# Each hen wanders inside the coop: it walks to a spot, pauses, then picks another.
func _update_hens(delta: float) -> void:
	hen_layer.visible = coop_built and coop_tile.x >= 0 and hens > 0
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


func _draw_tree(cell: Rect2, pos: Vector2i) -> void:
	draw_rect(cell, Color("17281a"))
	var h: int = absi((pos.x * 73856093) ^ (pos.y * 19349663))
	var shades := [Color("2c5630"), Color("36643a"), Color("24472a"), Color("3d6e3f")]
	var c := cell.position + cell.size * 0.5
	for i in 3:
		var ox := float((h >> (i * 4)) % 7 - 3) * PX * 0.06
		var oy := float((h >> (i * 4 + 2)) % 7 - 3) * PX * 0.06
		draw_circle(c + Vector2(ox, oy), PX * (0.34 + 0.05 * float(i)), shades[(h >> (i * 3)) % shades.size()])
	# A little light on the upper left of the canopy.
	draw_circle(c + Vector2(-PX * 0.12, -PX * 0.14), PX * 0.1, Color(0.62, 0.78, 0.46, 0.22))


func _tile_rect(t: Vector2i) -> Rect2:
	return Rect2(t.x * PX, t.y * PX, PX, PX)
