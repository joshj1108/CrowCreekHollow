class_name FarmLayout
extends RefCounted

# The farm layout. Generated from the layout diagram by tools/farm_layout.py; regenerate rather than editing by hand.
# Coordinates are inner farm tiles: 0,0 is the top-left walkable tile, outside the tree border.
#
# TERRAIN codes, one character per tile:
#   . grass     S soil (plot one)     F fallow (plots two and three, cleared later)
#   P path      ~ water               R porch boards
#   H house     D door                A market stall     W well
#   C cave mouth                      G grove tree (felled for wood)
#   B great tree (3 by 3, not felled)

const TERRAIN := [
	"GGG.....................................",
	"GG.......G..........G...................",
	"........................................",
	"..........................HHHHHH........",
	"....SSSSSSSS.........BBB..HHHHHH......G.",
	"....SSSSSSSS.........BBB..HHHHHH........",
	"....SSSSSSSS.........BBB..HHHHHH........",
	"....SSSSSSSS..............HHDHHH........",
	"..G.SSSSSSSS..............RRRR..........",
	"....SSSSSSSS..........A...RRRR......G...",
	"............W.........P.....P...........",
	"............P.........P.....P...........",
	"CPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
	"........................................",
	"....FFFFFFFF..FFFFF.....................",
	"....FFFFFFFF..FFFFF...........G.........",
	"....FFFFFFFF..FFFFF............~~~~~....",
	"..G.FFFFFFFF..FFFFF...........~~~~~~~...",
	"....FFFFFFFF..FFFFF..........~~~~~~~~~..",
	"....FFFFFFFF..FFFFF..........~~~~~~~~~..",
	".............................~~~~~~~~~..",
	".....................G........~~~~~~~...",
	".................G..............~~~~....",
	"........................................",
]

const PLOT_ONE := Rect2i(4, 4, 8, 6)
const PLOT_TWO := Rect2i(4, 14, 8, 6)
const PLOT_THREE := Rect2i(14, 14, 5, 6)
const HOUSE_IX := 26
const HOUSE_IY := 3
const HOUSE_W := 6
const HOUSE_H := 5
const PORCH_RECT := Rect2i(26, 8, 4, 2)
const WELL_IX := Vector2i(12, 10)
const STALL_IX := 22
const STALL_IY := 9
const CELLAR_IX := Vector2i(25, 5)
const SMOKEHOUSE_IX := Vector2i(35, 3)
const FURNACE_IX := Vector2i(33, 3)
const WORKSHOP_RECT := Rect2i(32, 2, 5, 4)
const WORKSHOP_DOOR := Vector2i(34, 5)
const WOODSTORE_IX := Vector2i(33, 4)
const CHOPLOG_IX := Vector2i(35, 4)
const BIG_TREE_INNER := Vector2i(21, 4)
const LAKE_FOCUS := Vector2(33.0, 19.0)
const GROVE_SPOTS := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1),
	Vector2i(9, 1), Vector2i(20, 1), Vector2i(38, 4), Vector2i(36, 9), Vector2i(2, 8),
	Vector2i(2, 17), Vector2i(30, 15), Vector2i(21, 21), Vector2i(17, 22),
]
const WILLOW_TREES := [Vector2i(2, 17), Vector2i(30, 15)]
const DEAD_TREES := [Vector2i(20, 1)]
const BRUSH_SPOTS := [
	Vector2i(3, 3), Vector2i(16, 2), Vector2i(34, 11), Vector2i(24, 20),
	Vector2i(6, 21), Vector2i(33, 8), Vector2i(14, 21),
]
const THICKET_SPOTS := [Vector2i(10, 21), Vector2i(23, 14), Vector2i(38, 16)]
