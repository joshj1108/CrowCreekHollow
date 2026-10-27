class_name FarmLayout
extends RefCounted

# The farm layout. Generated from the layout diagram by tools/farm_layout.py; regenerate rather than editing by hand.
# Coordinates are inner farm tiles: 0,0 is the top-left walkable tile, inside the tree border.
#
# TERRAIN codes, one character per tile:
#   . grass     S soil (plot one)     F fallow (plots two and three, cleared later)
#   P path      ~ water               R porch boards
#   H house     O roof (house top)    D door    A market stall     W well
#   C cave mouth                      K rock (blocks)    X fence (blocks)    Y scarecrow (blocks)
#   G grove tree (felled for wood)    B great tree base (3 by 3, not felled)
#   b great tree's walkable top row (grass)

const TERRAIN := [
	"................................................................",
	".......................................G........................",
	"..............................G......................~~~~.......",
	".................................................~~~~~~~~~~~....",
	".................................................~~~~~~~~~~~....",
	"...KK..............OOOOOOOOOOO................~~~~~~~~~~~~~~~...",
	"..KKKK.............OOOOOOOOOOO..............~~~~~~~~~~~~~~~~~~~.",
	"KKKKKK........G....OOOOOOOOOOO........G.....~~~~~~~~~~~~..~~~~~.",
	"KKCKKK.............OOOOOOOOOOO..............~~~~~~~~~~~~..~~~~~.",
	"KKPPK..............OOOOOOOOOOO..............~~~~~~~~~~~~..~~~~~.",
	"..PPP..............HHHHHHHHHHH................PPP~~~~~~~~~~~~...",
	"..P................HHHHHDHHHHH..G.AAA.........PPP~~~~~~~~~~~~...",
	"..P.....................RP........AAA.........PPP~~~~~~~~~~~~...",
	"..PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP~~~~~~~~~~~....",
	"...................................................~~~~~~~......",
	"..........G........................................~~~~~~~......",
	".................................................G...~~~~.......",
	"................................................................",
	"..XXXXXXXXXXXXXXXXX..........................G.............G....",
	"...SSSSSSSSSSSSSSS..............................................",
	"...SSSSSSSSSSSSSSS..............................................",
	"...SSSSSSSSSSSSSSS.Y.....G......................................",
	"...SSSSSSSSSSSSSSS.................................G............",
	"...SSSSSSSSSSSSSSS...........FFFFFFFFFFFF.......................",
	"...SSSSSSSSSSSSSSS....WW.....FFFFFFFFFFFF.....G.................",
	"...SSSSSSSSSSSSSSS....WW.....FFFFFFFFFFFF.......................",
	".............................FFFFFFFFFFFF.......................",
	".............................FFFFFFFFFFFF.......................",
	".............................FFFFFFFFFFFF.........bbb......G....",
	"......................G...................G.......BBB...........",
	"..................................................BBB...........",
	"...SSSSSSSSSSSSSSS..............................................",
	"...SSSSSSSSSSSSSSS................G.............................",
	"...SSSSSSSSSSSSSSS........G.....................................",
	"...SSSSSSSSSSSSSSS..............................................",
	"...SSSSSSSSSSSSSSS..............................................",
	"...SSSSSSSSSSSSSSS..............................................",
	"..XXXXXXXXXXXXXXXXX...................G......................G..",
	".................G..............................................",
	"................................................................",
]

const PLOT_ONE := Rect2i(3, 19, 15, 7)
const PLOT_TWO := Rect2i(3, 31, 15, 6)
const PLOT_THREE := Rect2i(29, 23, 12, 6)
const HOUSE_IX := 19
const HOUSE_IY := 5
const HOUSE_W := 11
const HOUSE_H := 7
const PORCH_RECT := Rect2i(24, 12, 1, 1)
const WELL_IX := Vector2i(22, 24)
const STALL_IX := 34
const STALL_IY := 11
const CELLAR_IX := Vector2i(17, 7)
const SMOKEHOUSE_IX := Vector2i(43, 33)
const FURNACE_IX := Vector2i(41, 33)
const WORKSHOP_RECT := Rect2i(40, 32, 5, 4)
const WORKSHOP_DOOR := Vector2i(42, 35)
const WOODSTORE_IX := Vector2i(41, 34)
const CHOPLOG_IX := Vector2i(43, 34)
const BIG_TREE_INNER := Vector2i(50, 28)
const LAKE_FOCUS := Vector2(53.5, 8.5)
const GROVE_SPOTS := [Vector2i(39, 1), Vector2i(30, 2), Vector2i(14, 7), Vector2i(38, 7), Vector2i(32, 11), Vector2i(10, 15), Vector2i(49, 16), Vector2i(45, 18), Vector2i(59, 18), Vector2i(25, 21), Vector2i(51, 22), Vector2i(46, 24), Vector2i(59, 28), Vector2i(22, 29), Vector2i(42, 29), Vector2i(34, 32), Vector2i(26, 33), Vector2i(38, 37), Vector2i(61, 37), Vector2i(17, 38)]
const WILLOW_TREES := [Vector2i(49, 16)]
const DEAD_TREES := []
const BRUSH_SPOTS := [Vector2i(48, 20), Vector2i(19, 2), Vector2i(29, 30), Vector2i(61, 25), Vector2i(42, 2), Vector2i(35, 5), Vector2i(43, 23)]
const THICKET_SPOTS := [Vector2i(11, 7)]
const ROCK_SPOTS := [Vector2i(56, 28), Vector2i(31, 7), Vector2i(34, 18), Vector2i(2, 2), Vector2i(61, 17), Vector2i(26, 2), Vector2i(24, 37), Vector2i(58, 20)]
# Farm tiles that the coop and barn must not be placed on, so they never overlap a building the player unlocks later.
const RESERVED := [Vector2i(17, 7), Vector2i(40, 32), Vector2i(40, 33), Vector2i(40, 34), Vector2i(40, 35), Vector2i(41, 32), Vector2i(41, 33), Vector2i(41, 34), Vector2i(41, 35), Vector2i(42, 32), Vector2i(42, 33), Vector2i(42, 34), Vector2i(42, 35), Vector2i(43, 32), Vector2i(43, 33), Vector2i(43, 34), Vector2i(43, 35), Vector2i(44, 32), Vector2i(44, 33), Vector2i(44, 34), Vector2i(44, 35)]
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "7f601855"
