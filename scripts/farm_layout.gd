class_name FarmLayout
extends RefCounted

# The farm layout. Generated from the layout diagram by tools/farm_layout.py; regenerate rather than editing by hand.
# Coordinates are inner farm tiles: 0,0 is the top-left walkable tile, inside the tree border.
#
# TERRAIN codes, one character per tile:
#   . grass     S soil (plot one)     F fallow (plots two and three, cleared later)
#   P path      ~ water               R porch boards
#   H house     D door                A market stall     W well
#   C cave mouth                      K rock (blocks)    X fence (blocks)
#   G grove tree (felled for wood)    B great tree (3 by 3, not felled)

const TERRAIN := [
	"........................................",
	"...................G............~~~.....",
	".............................~~~~~~~~...",
	"...KK.......HHHHHH.........~~~~~~~~~~~..",
	"..KKKK...G..HHHHHH......G.~~~~~~~~~~~~~.",
	"KKKKKK......HHHHHH........~~~~~~~~..~~~.",
	"KKCKKK......HHHHHH........~~~~~~~~..~~~.",
	"KKPPKXXX...XHHDHHHX.A......PP~~~~~~~~~..",
	"..PPP......X..RP..XXXXXXXX.PP~~~~~~~~~..",
	"...PPPPPPPPPPPPPPPPPPPPPPPP..~~~~~~~~...",
	".XXX.......XXX.................~~~~~....",
	"..SSSSSSSSSSSX..............G...~~~.....",
	"..SSSSSSSSSSS.....XXX...XXX...........G.",
	"..SSSSSSSSSSS.XXXXFFFFFFFF......G.......",
	"..SSSSSSSSSSS..W..FFFFFFFF..............",
	"..SSSSSSSSSSS.XXXXFFFFFFFF..............",
	".XXX.......XXX....FFFFFFFF..............",
	".XXX.......XXX....XXX...XXX....BBB...G..",
	"..SSSSSSSSSSS..............G...BBB......",
	"..SSSSSSSSSSS........G.........BBB......",
	"..SSSSSSSSSSS...G.......................",
	"..SSSSSSSSSSS...........................",
	".XXX.......XXX..........G.............G.",
	"........................................",
]

const PLOT_ONE := Rect2i(2, 11, 11, 5)
const PLOT_TWO := Rect2i(2, 18, 11, 4)
const PLOT_THREE := Rect2i(18, 13, 8, 4)
const HOUSE_IX := 12
const HOUSE_IY := 3
const HOUSE_W := 6
const HOUSE_H := 5
const PORCH_RECT := Rect2i(14, 8, 1, 1)
const WELL_IX := Vector2i(15, 14)
const STALL_IX := 20
const STALL_IY := 7
const CELLAR_IX := Vector2i(10, 5)
const SMOKEHOUSE_IX := Vector2i(28, 20)
const FURNACE_IX := Vector2i(26, 20)
const WORKSHOP_RECT := Rect2i(25, 19, 5, 4)
const WORKSHOP_DOOR := Vector2i(27, 22)
const WOODSTORE_IX := Vector2i(26, 21)
const CHOPLOG_IX := Vector2i(28, 21)
const BIG_TREE_INNER := Vector2i(31, 17)
const LAKE_FOCUS := Vector2(32.6, 5.6)
const GROVE_SPOTS := [Vector2i(19, 1), Vector2i(9, 4), Vector2i(24, 4), Vector2i(28, 11), Vector2i(38, 12), Vector2i(32, 13), Vector2i(37, 17), Vector2i(27, 18), Vector2i(21, 19), Vector2i(16, 20), Vector2i(24, 22), Vector2i(38, 22)]
const WILLOW_TREES := [Vector2i(24, 4), Vector2i(28, 11), Vector2i(32, 13)]
const DEAD_TREES := []
const BRUSH_SPOTS := [Vector2i(30, 12), Vector2i(12, 1), Vector2i(18, 18), Vector2i(38, 15), Vector2i(26, 1), Vector2i(22, 3), Vector2i(27, 14)]
const THICKET_SPOTS := [Vector2i(7, 4)]
const ROCK_SPOTS := [Vector2i(35, 17), Vector2i(19, 5), Vector2i(21, 11), Vector2i(1, 1), Vector2i(38, 10), Vector2i(16, 1), Vector2i(15, 22), Vector2i(36, 12)]
# Farm tiles that the coop and barn must not be placed on, so they never overlap a building the player unlocks later.
const RESERVED := [Vector2i(10, 5), Vector2i(25, 19), Vector2i(26, 19), Vector2i(27, 19), Vector2i(28, 19), Vector2i(29, 19), Vector2i(25, 20), Vector2i(26, 20), Vector2i(27, 20), Vector2i(28, 20), Vector2i(29, 20), Vector2i(25, 21), Vector2i(26, 21), Vector2i(27, 21), Vector2i(28, 21), Vector2i(29, 21), Vector2i(25, 22), Vector2i(26, 22), Vector2i(27, 22), Vector2i(28, 22), Vector2i(29, 22)]
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "1946c922"
