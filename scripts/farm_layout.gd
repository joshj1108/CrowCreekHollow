class_name FarmLayout
extends RefCounted

# The farm layout. Generated from tools/farm_grid.txt by tools/hand_layout.py; regenerate rather than editing by hand.
# Coordinates are inner farm tiles: 0,0 is the top-left inner tile, inside the border. Since FARM-001 this is the
# concept farm (W-4 layout b): its own forest rings the clearing inside the inner area.
#
# TERRAIN codes, one character per tile:
#   . grass     T forest (blocks)      G grove tree (blocks, felled for wood)
#   P path (cobbles, walkways, open gates)     ~ water     k dock over the water (walkable)     R porch boards
#   H house wall     O roof (walkable, drawn over the farmer)     D door     A farm stand (3 by 2)     W well (2 by 2)
#   S soil (field one)     F fallow (fields two to four, opened by Farming level)
#   C cave mouth     K hillside rock (blocks)     X fence and the closed east gate (blocks)
#   Z prop (blocks: boulders, log piles, the mailbox, the lantern post, the house's dressing)
#   o orchard tree (blocks)     B great oak base (3 by 3, not felled)     b the oak's walkable top row (grass)

const TERRAIN := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT..............GTTTTT",
	"TTTTTT................TTTTTTGTTTTTTTTTTTTTTT..............TTTTTT",
	"TTTTTTKKKKKKKKKKKKKKK...TTTT..............................TTTTTT",
	"TTTTTTKKKKKKKKKKKKKKK...................OOOOOOOOOOO.......TTTTTT",
	"TTTTTTKKKKKKKKKKKKKKK...................OOOOOOOOOOO.......TTTTTT",
	"TTTTTTKKKKKKKKKKKKKKK...................OOOOOOOOOOO...........TT",
	"TTTTTTKKKKKCKKKKKKKK....................OOOOOOOOOOO.........TTTT",
	"TTTTTTKKKKKP..KK............Z.....Z.....OOOOOOOOOOO.Z.......GTTT",
	"TTTTK...KK.P...........................ZHHHHHHHHHHHZ..........TT",
	"TTT........PP..............Z..bbb..Z...ZHHHHHDHHHHHZ..........TT",
	"TTG.........P.................BBB........ZZ.PR..ZZ............TT",
	"TTTT........PP............Z...BBB...Z.......PP.Z..............TT",
	"TTTTT.......PPPPPPPP.............ZZZ.PPPPPPPPP................TT",
	"TTTTT..............PPPPPP..Z......Z.PWWPPPPPPP...............TTT",
	"TTTTT...................PPPPPPZPPPPPPWWPP.....................GT",
	"TTTTT.XXXXXXXXXXXXXXXX.......PPPPPPPPPPP......................TT",
	"TTTTG.X..............X........PPPPPPPPPP..XXXXXXXXXXXXXXXXXXXTTT",
	"TTTT..X..o...o...o...X....PPPPPPPPP...PP..XPPPPPPPPPPPPPPPPPXTTT",
	"TTTT..X.......Z......X.PPPPPPPPP......PP..XPSSSSSSSPFFFFFFFPX.TT",
	"TT....X..............PPPPPPP...Z....ZZPPP.XPSSSSSSSPFFFFFFFPXTTT",
	"TTT...X..............PPPP.............PPPZXPSSSSSSSPFFFFFFFPXTTT",
	"TTT...X..o.......o...X.......ZZ........PPPPPSSSSSSSPFFFFFFFPX.TT",
	"TT....X......o.......X........Z.......PPPPPPPPPPPPPPPPPPPPPPXTTT",
	"TTG...X..............X...............PPPP.XPFFFFFFFPFFFFFFFPXTTT",
	"TT....X..............X...............PPP..XPFFFFFFFPFFFFFFFPX.TT",
	"TTTT..XXXXXXXXXXXXPPXX..............PPP...XPFFFFFFFPFFFFFFFPX.TT",
	"TTTT..............PPP..............PPP....XPFFFFFFFPFFFFFFFPX.TT",
	"TT.....~~~..~~~...PP..............PPPP....XPPPPPPPPPPPPPPPPPXTTT",
	"TTT.~~~~~~~~~kk~..PP.............PPP....ZZXXXXXXXXPPXXXXXXXXXTTT",
	"TTT~~~~~~~~~~kk~~.PP...........PPPP................PP.AAAZZTTTTT",
	"TT~~~~~~~~~~~kk~~............PPPPPP...............PPPZAAA..TTTTT",
	"TTTT~~~~~~~~.kk.......PPPPPPPPPPPPPPP...........PPPPP......XTTTT",
	"TTTT~~~~~...PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPXTTTT",
	"TTT..~~~....PPPPPPPPPPPP......TTTTT.PPPPPPPPPPPPPPPPPPPPPPPXTTTT",
	"TTTTT.............TT.T.......GTTTTTT..GT..T.T.T..TT..TZZT.TXTTTT",
	"TTTTTTT..T..T.GT..TT.T.T.TT..TTTTTTT..TTTTT.T.T..TTGTT.TTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTGTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

const PLOT_ONE := Rect2i(44, 20, 7, 4)
const PLOT_TWO := Rect2i(52, 20, 7, 4)
const PLOT_THREE := Rect2i(44, 25, 7, 4)
const PLOT_FOUR := Rect2i(52, 25, 7, 4)
const HOUSE_IX := 40
const HOUSE_IY := 5
const HOUSE_W := 11
const HOUSE_H := 7
const PORCH_RECT := Rect2i(45, 12, 1, 1)
const WELL_IX := Vector2i(37, 15)
const STALL_IX := 54
const STALL_IY := 31
const CELLAR_IX := Vector2i(38, 7)
const WORKSHOP_RECT := Rect2i(50, 12, 7, 6)
const BIG_TREE_INNER := Vector2i(30, 11)
const LAKE_FOCUS := Vector2(8.3, 31.6)
const GROVE_SPOTS := [Vector2i(58, 2), Vector2i(28, 3), Vector2i(60, 9), Vector2i(2, 12), Vector2i(62, 16), Vector2i(4, 18), Vector2i(2, 25), Vector2i(29, 36), Vector2i(38, 36), Vector2i(14, 37), Vector2i(51, 37), Vector2i(22, 38)]
const WILLOW_TREES := []
const DEAD_TREES := []
const ORCHARD_TREES := [Vector2i(9, 19), Vector2i(13, 19), Vector2i(17, 19), Vector2i(9, 23), Vector2i(17, 23), Vector2i(13, 24)]
const BRUSH_SPOTS := [Vector2i(31, 5), Vector2i(52, 6), Vector2i(24, 9), Vector2i(57, 9), Vector2i(59, 16), Vector2i(34, 26), Vector2i(25, 27)]
const THICKET_SPOTS := [Vector2i(46, 3)]
const ROCK_SPOTS := [Vector2i(35, 5), Vector2i(56, 5), Vector2i(20, 10), Vector2i(15, 11), Vector2i(9, 14), Vector2i(27, 23), Vector2i(29, 27), Vector2i(25, 31)]
# Where walkers wait for a trek (on the road inside the east gate), where you come back to, and the pedlar's cart.
const WALKER_SPOT := Vector2i(58, 34)
const ARRIVE_IX := Vector2i(55, 34)
const PEDLAR_SPOT := Vector2i(57, 33)
# Farm tiles that the coop and barn must not be placed on, so they never overlap a building the player unlocks later.
const RESERVED := [Vector2i(38, 7), Vector2i(50, 12), Vector2i(50, 13), Vector2i(50, 14), Vector2i(50, 15), Vector2i(50, 16), Vector2i(50, 17), Vector2i(51, 12), Vector2i(51, 13), Vector2i(51, 14), Vector2i(51, 15), Vector2i(51, 16), Vector2i(51, 17), Vector2i(52, 12), Vector2i(52, 13), Vector2i(52, 14), Vector2i(52, 15), Vector2i(52, 16), Vector2i(52, 17), Vector2i(53, 12), Vector2i(53, 13), Vector2i(53, 14), Vector2i(53, 15), Vector2i(53, 16), Vector2i(53, 17), Vector2i(54, 12), Vector2i(54, 13), Vector2i(54, 14), Vector2i(54, 15), Vector2i(54, 16), Vector2i(54, 17), Vector2i(55, 12), Vector2i(55, 13), Vector2i(55, 14), Vector2i(55, 15), Vector2i(55, 16), Vector2i(55, 17), Vector2i(56, 12), Vector2i(56, 13), Vector2i(56, 14), Vector2i(56, 15), Vector2i(56, 16), Vector2i(56, 17)]
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "18496244"
