# ART-003 W-4 Task B: layout parity and save preservation (plan only)

Status: **PROPOSED — NOT APPROVED.** Documentation only. Nothing in the game, its layout, its saves or `DESIGN.md` was changed. No migration was run or written.

- **Question this plan answers:** can the ART-003 homestead become the live farm without losing a gameplay system or a player's progress?
- **Short answer:** yes, with a new layout version, a tile-mapping save migration, eight small code changes, and owner decisions on five compromises (§6, §8).
  - Every live feature fits the prototype composition. The checks in §1 pass by machine.
  - The real risks are in the save:
    - Crops, decor and blight are stored by tile.
    - Today a layout change silently drops crops, brush and felled trees, and leaves decor where it was, even if that is now water or the house (§4).
- **Evidence:**
  - `art/style_tests/ART-003/parity/make_parity.py` builds the blueprint from the prototype and the live `scripts/farm_layout.gd`, then checks it. Its outputs are `parity_blueprint.txt` and `.png`, `live_layout.png`, `prototype_layout.png` and `parity_report.json`.
  - Review master: `art/style_tests/ART-003/w4/review/ART-003W4B_master.png`.
- **Coordinates:** inner farm tiles (0, 0 is the top-left walkable tile) unless marked *world*. World = inner + (`BORDER_X` 14, `BORDER_Y` 8). Saves store **world** tiles.

## 1. The 64×40 parity blueprint

Built from the prototype's layout B (`wide/blueprint_wide_v1b_w3b.txt`), the Batch C props and the W-4 gate, translated to one production key, with every live feature placed.

```
    0000000000111111111122222222223333333333444444444455555555556666
    0123456789012345678901234567890123456789012345678901234567890123
 0  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
 1  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
 2  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTG............GTTTTTT
 3  TTTTTTG...............TTTTTTTTTTTTTTTTTTTTTT..............TTTTTT
 4  TTTTTT..FFFFFFFFFFFFFFF.TTTT....G......G..................TTTTTT
 5  TTTTTT..FFFFFFFFFFFFFFF.G...............OOOOOOOOOOO.......TTTTTT
 6  TTTTKKK.FFFFFFFFFFFFFFF.................OOOOOOOOOOO.......TTTTTT
 7  TTTKKKK.FFFFFFFFFFFFFFF.................OOOOOOOOOOO..........GTT
 8  TTTKKCK.FFFFFFFFFFFFFFF.................OOOOOOOOOOO.........TTTT
 9  TTTKKP..FFFFFFFFFFFFFFF.....K.....K.....OOOOOOOOOOO.p.......TTTT
10  TTTT.PPPPPPP...........................pHHHHHHHHHHHp..........TT
11  TTTG.......................K..bbb..K...pHHHHHDHHHHHp..........TT
12  TTT...........................BBB........pp.PR..pp............TT
13  TTTT......................K...BBB...K.......PP................TT
14  TTTTT............................ppp.PPPPPPPPP................TT
15  TTTTT......................K......K.PWWPPPPPPP...............TTT
16  TTTTT.........................KPPPPPPWWPP.....................TT
17  TTTTTGXXXXXXXXXXXXXXXX.........PPPPPPPPP.....................GTT
18  TTTTT.X..............X........PPPPPPPPPP..XXXXXXXXXXXXXXXXXXXTTT
19  TTTT..X..o...o...o...X....PPPPPPPPP...PP..XPPPPPPPPPPPPPPPPPXTTT
20  TTTT..X.......p......X.PPPPPPPPP......PP..XPPPPPPPPPPPPPPPPPXTTT
21  TT....X..............PPPPPPpp..p....ppPPP.XPSSSSSSSSSSSSSSSPXTTT
22  TTT...X..............PPPP..p..........PPP.XPSSSSSSSSSSSSSSSPXTTT
23  TTTG..X..o.......o...X.FFFFFFFFFFFF....PPPPPSSSSSSSSSSSSSSSPXTTT
24  TT....X......o.......X.FFFFFFFFFFFF...PPPPPPSSSSSSSSSSSSSSSYXTTT
25  TTT...X..............X.FFFFFFFFFFFF..PPPP.XPSSSSSSSSSSSSSSSPXTTT
26  TT....X..............X.FFFFFFFFFFFF..PPP..XPSSSSSSSSSSSSSSSPXTTT
27  TTTT..XXXXXXXXXXXXPPXX.FFFFFFFFFFFF.PPP...XPSSSSSSSSSSSSSSSPXTTT
28  TTTT..............PPP..FFFFFFFFFFFFPPP....XPPPPPPPPPPPPPPPPPXTTT
29  TTG....~~~..~~~...PP..............PPPP....XPPPPPPPPPPPPPPPPPXTTT
30  TTT.~~~~~~~~~JJ~..PP.............PPP....ppXXXXXXXXPPXXXXXXXXXTTT
31  TTT~~~~~~~~~~JJ~~.PP...........PPPP.........AAA....PP.....GTTTTT
32  TT~~~~~~~~~~~JJ~~G...........PPPPPP.........AAA...PPPp..pp.TTTTT
33  TTTT~~~~~~~~.JJ.......PPPPPPPPPPPPPPP...........PPPPP......QTTTT
34  TTTT~~~~~...PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPQTTTT
35  TTTTT~~~....PPPPPPPPPPPP......TTTTT.PPPPPPPPPPPPPPPPPPPPPPPQTTTT
36  TTTTTG............TT.T.......TTTTTTT..TT..T.T.T..TT..TppT.TQTTTT
37  TTTTTTT..T..TGTT..TTGT.T.TT.GTTTTTTT.GTTTTT.T.T.GTTTTTTTTTTTTTTT
38  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
39  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
```
*(Copied from `parity/parity_blueprint.txt`, which is authoritative.)* Not shown in the grid: 8 rock spots, 7 brush spots and 1 thicket, which sit on `.` tiles as in the live layout (positions in §2). The workshop is player-placed; its default block is (53, 8) 7×6.

**Production key:** every live code keeps its live meaning (`. S F P ~ H O D R A W C K X Y G B b`). New codes:

| Code | Meaning | Tile kind | Why it's new |
| --- | --- | --- | --- |
| `T` | Inner forest | `TREE`, never felled (not in `GROVE_SPOTS`) | The live inner farm has no forest; the prototype frames the farm with it |
| `o` | Orchard fruit tree | `TREE`, never felled | Decorative; see question Q-6 about the player's own apple trees |
| `J` | Dock over water | walkable (`PATH`-like); fish from its end | Replaces the prototype's `K`, which clashes with live `K` (rock) |
| `p` | Standing prop (signpost, cart, barrels, mailbox, dead tree, porch dressing, log piles) | blocks; no interaction | Batch C props block their tiles; live has no such code |
| `Q` | East gate (posts and closed leaves) | blocks; **not** `FENCE` | So the gate never "tears loose" in `_break_fences` |

Translated prototype codes:
- `r` (oak boulders) → `K`, a blocking, non-mineable rock, as in the live layout.
- `c`, `w`, `g` (cobbles, garden walks, garden gates) → `P`.
- `d` (house dressing) → `p`.
- `L` (lantern posts) → `.`. The posts were stand-ins for earned lamps, which are player decor.
- The prototype's baked garden beds (`S`) give way to plot one.

**Machine checks** (`make_parity.py`, all pass). The flood fill starts from the porch, with every brush, rock and thicket spot grown back at once:
- 1,565 tiles are reachable; 0 walkable tiles are unreachable.
- Each plot keeps its live size, holds the right soil code on every tile, and every tile is reachable.
- These are all reachable: the door under the roof's middle, the cave's entry tile, the stall front, the pedlar spot, a side of the well and of the great tree's base, the scarecrow, every grove tree, rock and brush spot, every walker spot and its step, the arrival, and the new-game start.
- The workshop default block is all grass, and its door step is reachable.
- No rock, brush or thicket spot can close a corridor. The picker refuses any spot that would.
- 8 walkable pockets the prototype drew but nobody could reach are closed to forest:
  - (61, 20–28): grass east of the garden fence;
  - (3–4, 35): the pond's west bank;
  - (54, 37): a gap in the south trees.
  Live forage and brush can spawn on any open grass, so an unreachable pocket would collect things the player can never pick up.

**Gaps at gameplay level** (this is a tile plan, not art):
- The prototype's art is baked for its own layout: ground chunks, beds, the garden. Every moved feature (plots, cave, stall, grove trees) needs per-tile art in the prototype style. That is the P1 "dynamic tiles" and "crops by season" work from `art/style_tests/ART-003/wh/WH.md` §F.
- The prototype's camera margin: see Task A. Live already has a 14-tile border.

## 2. Coordinate mapping, old to proposed

| Feature | Constant / source | Live (inner tiles) | Proposed (inner tiles) | Prototype at the live tiles today | Notes |
| --- | --- | --- | --- | --- | --- |
| Farmhouse (11×7, door mid-bottom) | HOUSE_IX/IY | (19, 5) | (40, 5) | .×75, K×2 | Same 11×7 shape; door (45, 11), porch (45, 12). Interior unchanged. |
| Door / porch | HOUSE_DOOR_IX/IY (derived), PORCH_RECT | (24, 11) / (24, 12) | (45, 11) / (45, 12) | — | Derived from HOUSE_IX/IY; `PORCH_RECT` is a separate constant and must move with it. Window and porch lights follow. |
| Cellar | CELLAR_IX | (17, 7) | (38, 7) | .×1 | Two tiles west of the house, as live. |
| Plot one (open from day 1) | PLOT_ONE | (3, 19) 15×7 | (44, 21) 15×7 | .×90, X×7, o×6, T×2 | Fills the prototype's fenced garden; the 4 baked beds go. |
| Plot two (Farming 2) | PLOT_TWO | (3, 31) 15×6 | (8, 4) 15×6 | ~×40, .×28, P×12, J×6, T×4 | North-west meadow, by the cave path. |
| Plot three (Farming 9, house stage 2) | PLOT_THREE | (29, 23) 12×6 | (23, 23) 12×6 | .×54, P×18 | South of the crossroads; Batch C boulders move north. |
| Scarecrow (fixed) | terrain Y | (19, 21) | (59, 24) | .×1 | East walkway beside plot one. |
| Market stall (3×2) | STALL_IX/IY | (34, 11) | (44, 31) | .×5, K×1 | Faces the road at the arrival; back to the garden fence. |
| Pedlar | daily_happenings PEDLAR_SPOT | (37, 12) | (47, 32) | .×1 | Beside the stall, as live. |
| Well (2×2) | WELL_IX | (22, 24) | (37, 15) | .×4 | Prototype well. |
| Great tree (crow roost, 3×3) | BIG_TREE_INNER | (50, 28) | (30, 12) | P×5, .×4 | Becomes the golden oak: same b row + 3×2 base; roost perches re-fitted to the oak's art. |
| Cave mouth | terrain C (searched) | (2, 8) | (5, 8) | T×1 | Rock outcrop in the west forest edge; entry tile (5, 9) is path. |
| Workshop default / old-save fallback (7×6) | WORKSHOP_RECT + RESERVED | (39, 31) 7×6 | (53, 8) 7×6 | .×25, P×14, T×3 | Player-placed; this is only the fallback and the RESERVED block. Smokehouse, furnace, woodstore and chopping log sit at fixed offsets inside it. |
| Lake / pond | terrain ~, LAKE_FOCUS | 176 tiles, focus (53.5, 8.5) | 57 tiles + 8-tile dock, focus (9.5, 31.5) | .×116, O×33, T×19, p×4, H×4 | Smaller: shore-fishable tiles 61 → 25. Owner decision Q-4. |
| Grove trees (20, incl. willow) | GROVE_SPOTS / terrain G | 20 scattered in the meadow | 20 at the forest edge; willow at (17, 32) by the pond | P×6, T×5, .×5, X×3, b×1 | Same count, all with a reachable side. |
| Rock spots (8, mineable) | ROCK_SPOTS | 8 | 8 (spread, none in a corridor) | .×5, T×2, P×1 | Positions below. |
| Brush spots (7) and thicket (1) | BRUSH_SPOTS, THICKET_SPOTS | 7 + 1 | 7 + 1 | .×3, T×3, P×1 | Positions below. |
| Trek walker spots | trek_system WALKER_SPOT + ROUTES.spot | (19..31, 1): grove 19, 152 22, edge/mill 25, 244 28, 336 31 | (46..56, 2): grove 46, 152 48, edge/mill 51, 244 54, 336 56 | T×5 | Into the prototype's north gap above the house; return = spot + (0, 1). |
| Homestead arrival (cave/trek abort, old world saves) | HOMESTEAD_ARRIVE (formula) | (61, 20) | (57, 34) | .×1 | Becomes a layout constant: just inside the east gate on the road. |
| Night shadow's walk (start) | night_system _shadow_x/_shadow_y (formula) | (62, 16) | (61, 16) | T×1 | Formula start is forest in the prototype; becomes a layout constant. |
| New game start / layout-change fallback | main.gd:1942 (formula) | (32, 20) | (45, 13) | .×1 | Proposed: on the porch path, not the map centre. |

"Prototype at the live tiles today" shows why nothing can keep its coordinates. For example, the live plot two would sit in the prototype's pond, and every walker spot is forest.

**Spot lists, live → proposed:**
- Grove (live): (39,1) (30,2) (14,7) (38,7) (32,11) (10,15) (49,16)w (45,18) (59,18) (25,21) (51,22) (46,24) (59,28) (22,29) (42,29) (34,32) (26,33) (38,37) (61,37) (17,38)
- Grove (proposed): (44,2) (57,2) (6,3) (32,4) (39,4) (24,5) (61,7) (3,11) (5,17) (61,17) (3,23) (2,29) (58,31) (17,32)w (5,36) (13,37) (20,37) (28,37) (37,37) (48,37)
- Rocks: (56,28) (31,7) (34,18) (2,2) (61,17) (26,2) (24,37) (58,20) → (34,21) (50,12) (20,18) (41,27) (15,11) (29,13) (43,17) (12,21)
- Brush: (48,20) (19,2) (29,30) (61,25) (42,2) (35,5) (43,23) → (25,30) (36,10) (11,29) (51,4) (22,12) (9,13) (55,15). Thicket: (11,7) → (18,24)
- These are a machine first pass (spread out, on reachable grass, never closing a corridor). The proposed rock (20,18) is inside the orchard fence and (43,17) is just north of the garden fence; the owner may want them hand-moved.

## 3. Inventory: hard-coded coordinates, tile codes and logic

### 3a. Tile-code collisions (the prototype's codes vs live)
| Code | Live meaning | Prototype meaning | Resolution |
| --- | --- | --- | --- |
| **`K`** | Rock, blocks (`Tile.ROCK`) | **Dock over water, walkable** | Dock → `J`. The prototype's oak boulders `r` → `K`, which is what they are. |
| **`G`** | Grove tree, felled for wood | W-4 gate leaf (prototype tool only, `Q` internally) | Gate → `Q`, never `G` or `X` |
| `S` | Plot one soil (per-tile crops) | Baked raised-bed art | Plot one replaces the beds. A bed look needs per-tile art |
| `W` | Well | Well | Same meaning, new position |
| `B` / `b` | Great tree base / walkable top row | Oak base / top row | Same meaning: the oak *is* the great tree |
| `X` | Fence; can break at night (`_break_fences`) | Fence (102 tiles vs 34) | Same meaning. More rails make a broken one harder to find (Q-7) |
| `T`, `o`, `p`, `c`, `w`, `g`, `d`, `r`, `L` | (unused) | Forest, orchard, props, paths, dressing, boulders, lamp posts | See the key in §1 |

### 3b. Constants that hold coordinates
| Where | Constant | What follows it |
| --- | --- | --- |
| `farm_layout.gd` | `TERRAIN`, `VERSION` | `main._build_map`, `_is_open_grass`, `_cave_mouth_tile`, coop/barn/workshop placement, save layout check |
| `farm_layout.gd` | `PLOT_ONE/TWO/THREE` | `farm_system` (opening plots 2 and 3 rewrites map tiles), `madness_system` fake crops, `tools/capture.gd`, `tools/balance_sim.gd` `SPRINKLER_SPOTS` (inner 4–16, 20–23) |
| `farm_layout.gd` | `HOUSE_IX/IY/W/H`, `PORCH_RECT` | Door, porch, window and porch lights (`HOUSE_SPRITE_WINDOWS`), Unstick, leaving the house, night visitors at the house/door, folk anchor, `night_system` lit porch, shadow's stop |
| `farm_layout.gd` | `WELL_IX`, `STALL_IX/IY`, `CELLAR_IX`, `BIG_TREE_INNER`, `LAKE_FOCUS` | Well use; stall and folk anchor; cellar tile; roost, crows, `night_system` tree visitor, folk anchor; water shimmer focus |
| `farm_layout.gd` | `WORKSHOP_RECT`, `SMOKEHOUSE_IX`, `FURNACE_IX`, `WORKSHOP_DOOR`, `WOODSTORE_IX`, `CHOPLOG_IX`, `RESERVED` | Old-save fallback and the reserved block. Live code uses `workshop_tile` + `SMOKEHOUSE_AT`/`FURNACE_AT`/`WOODSTORE_AT`/`CHOPLOG_AT`/`WORKSHOP_DOOR_AT` offsets (`main.gd`:346–352) |
| `farm_layout.gd` | `GROVE_SPOTS`, `WILLOW_TREES`, `DEAD_TREES`, `BRUSH_SPOTS`, `THICKET_SPOTS`, `ROCK_SPOTS` | Felling (`farm_system`:219 needs the tile in `GROVE_SPOTS`), regrowth, mining, Bushcrafting |
| `main.gd`:407 | `HOMESTEAD_ARRIVE = BORDER + (INNER_W − 3, INNER_H / 2)` | Return from a cave collapse/trek abort, `_save_pos` while in the cave, old world saves (`save_system._migrate_world`) |
| `main.gd`:1942, :5287–5289 | New-game start `(INNER_W/2, INNER_H/2)`; relocation fallbacks | Start position; where a building search starts |
| `trek_system.gd`:32, 252–300 | `WALKER_SPOT (25, 1)` and five route `spot`s | Walker stands here; the player returns to spot + (0, 1) |
| `daily_happenings.gd`:13 | `PEDLAR_SPOT (37, 12)` | Pedlar; `folk_system`:481 keeps folk off it |
| `night_system.gd`:434–441, 600–602, 1039–1043 | House east side, door, `BORDER_X + INNER_W − 2`, `INNER_H/2 − 4`, house-relative clamps | Visitor stands, the shadow's walk and blight row |
| `folk_system.gd`:436–471 | Stall, great tree, door anchors; lake centroid (computed) | Where folk stand |
| `tools/save_test.gd` | (20, 14), (4, 20), (6, 21), (3, 3), (40, 20)/(41, 20) world, `WORKSHOP_OLD_IX` | Test fixtures that assume today's grass and plot tiles |
| `tools/balance_sim.gd`:62 | `SPRINKLER_SPOTS` on plot one | Balance model |
| `tools/capture.gd`:135–148, 243 | Workshop, plot one, `at=` | Captures |
| `DESIGN.md` | The farm-layout section | Must be rewritten, but only with the owner's approval (not changed here) |

### 3c. Systems that read the map rather than a constant (no constant to move, but behaviour depends on the layout)
- **Collision:** `_is_blocked_world`: `BLOCKING` kinds plus brush, rocks and blocking decor.
- **Placement:**
  - Coop (3×2), barn (5×3) and workshop (7×6) go only on `.` tiles not in `RESERVED` (`_spot_ok`, `_relocate_building`).
  - Fewer `.` tiles in the parity layout: 969 against 1,879. Plenty for three buildings, but less choice (Q-5).
- **Fishing:** `fish_spots` are on water tiles next to the shore. Shore-fishable water drops from 61 tiles to 25 (Q-4).
- **Forage:** spawns on open tiles anywhere inside the inner farm. There are fewer tiles, and they sit closer to the forest.
- **Fences:** `_break_fences` picks from every `FENCE` tile and wattle fence.
- **Water shimmer:** reads every `WATER` tile plus `LAKE_FOCUS`.
- **Minimap:** draws `map`; the cave icon comes from `_cave_mouth_tile()`.
- **Daily happenings:** the "tree"-adjacent and open-tile tests over the inner farm.

## 4. Save preservation

### 4a. What a save holds by position (`save_system.gd`)
| Key | Holds | On a layout change today (`layout` ≠ `LAYOUT_VERSION`) |
| --- | --- | --- |
| `player_pos` | world pixels | Ignored; the player starts at the map centre. **Silent move** |
| `crops` | world tile → kind, stage, days, watered | **Dropped** (message: "Plantings, brush and felled trees were reset") |
| `brush`, `felled` | world tiles | **Dropped**, refilled from the new spots |
| `rocks` | world tiles | **Dropped**, refilled |
| `coop_x/y`, `barn_x/y`, `workshop_x/y` | world tiles | Relocated to the nearest fit (`_relocate_building`). Contents are kept |
| `decor` | world tile → kind (lamps, flowers, gravel paths, apple trees, sprinklers, wattle fence, bench, birdbath, weathervane, torches, snares, scarecrows, shutters, bell) | **Kept at the old tiles.** It can end up in the new pond, house or forest. **Silent corruption** |
| `snared` | world tile → catch | **Kept at the old tiles** |
| `broken_fences` | world tiles | **Kept**; they may no longer be fence tiles |
| `night_blight` | world tile → day | **Kept** (crop tiles), though its crops are gone |
| `forage` | world tile → kind (today only) | Kept for the rest of the day |
| `cave_mined` | cave tiles | Unaffected (separate map) |
| `inside`, interior state, `house_stage`, inventory, money, skills, stores, animals, quests, treks, story, estate | not positional | Unaffected |

Plot opening (`plot_two_open`, `plot_three_open`) is recomputed from level and house stage, so it carries over.

**Conclusion:** a straight swap of `farm_layout.gd` would silently erase every planted crop, reset brush and felled trees, move the player, and strand every decor item. Today's code has no mapping step. This must never ship without §5.

### 4b. The mapping (proposed)
Old world tile → new world tile, per kind:
- **Crops:** mapped plot to plot by offset within the rect: `new = NEW_PLOT.position + (old − OLD_PLOT.position)`. Plots keep their sizes, so this is 1:1. Crops on soil a player tilled outside the plots (if any) go into free tiles of the nearest plot by kind, or into the cellar as harvested goods if no tile is free. Nothing is dropped silently.
- **Sprinklers** (decor on plots): the same plot-offset mapping as crops.
- **Other decor:**
  - Decor inside a known area moves with it: the house surround, porch, stall front and well ring.
  - Free-standing decor (lamps, benches, flowers, torches, wattle fence, gravel paths, apple trees, scarecrows, birdbath, weathervane, snares) goes to the nearest legal tile under the same rule the game uses to place it. It stays clear of crops and buildings and must not cut a corridor (re-run the §1 flood fill).
  - Anything that can't be placed comes back to the inventory as its item, or as its build cost. Each case is listed in a one-time message.
  - **Gravel paths** (up to 400) need a decision: re-lay them by relative position, or refund the stone (Q-8).
- **Coop, barn, workshop:** the existing `_relocate_building`, seeded from a mapped position rather than the old one, so a building near the house stays near the house.
- **Brush, rocks, felled grove trees:** state carries over by index. Spot *i* in the old list → spot *i* in the new list, keeping "cleared on day N" and "felled on day N", so regrowth timers survive.
- **Player position:**
  - Indoors → unchanged.
  - Outdoors → mapped by feature. Near the house → the same offset from the new door. Otherwise → the new arrival.
  - Never the map centre without a message.
- **Broken fences:** count kept. They re-break on equivalent new fence tiles, or the count is cleared with a note.
- **Night blight:** follows its crops through the crop mapping.
- **Snares:** follow decor.
- **Forage:** dropped for the day; it respawns tomorrow.

### 4c. Versioning
- Bump `FarmLayout.VERSION`. Keep the **old** `TERRAIN` and anchor constants in a frozen `farm_layout_v1.gd`, used only by the migrator.
- `save_system._migrate` gets a layout step:
  - Its input is `layout == "61ea46f7"`. It runs only when a save's `layout` is that known old version. An unknown layout keeps today's reset behaviour, with the message.
  - It writes `layout_migrated_from: "61ea46f7"` and a per-kind report (`moved`, `refunded`, `dropped: 0`).
- `SAVE_VERSION` 16 → 17. The migration runs once, on load, before `_restore_saved_state`.

## 5. Migration, rollback, backups and tests

### 5a. Backups
- **Before the migration writes:** copy the untouched file to `hallowvale_save_N.pre_layout_v2.json` beside it. Write it once and never overwrite it.
- **The existing safety stays:** `.bak` and temp-file rotation (`write_save`).
- **Rollback:** a settings-menu action (or a documented manual step) that restores the `.pre_layout_v2.json` copy, for players on a build that still reads layout v1. Saves made after migrating can't go backwards. Say so in the patch note.

### 5b. Tests (disposable fixtures only; never slots 1–3)
- New `tools/layout_migration_test.gd`, headless, using **slot 9 only**, same pattern as `save_test.gd`.
- Fixtures are JSON files built by the test from the code. They are never copies of the user's saves.

| Fixture | Asserts after load |
| --- | --- |
| Day-40 farm: every plot tile planted (mixed kinds and stages), 10 sprinklers | Every crop present at its mapped tile with the same kind, stage, days and watered day; sprinklers on mapped tiles |
| All 14 decor kinds at their max counts, some on tiles that become water/house/forest | Every item placed or refunded; none on a blocking tile; flood fill from the porch still reaches every walkable tile |
| Coop, barn and workshop at the live default spots and at odd spots | All three placed, no overlap, contents unchanged |
| Brush cleared and grove felled on known days | Regrowth days kept per index |
| Player outdoors by the house; in the cave; in a trek; inside the house | Positions as §4b; trek/cave return lands on the new arrival or walker step |
| Blight, snares, broken fences, today's forage | Follow their owners or are cleared with the report |
| A save already on the new layout | Unchanged (idempotent) |
| An unknown layout string | Today's reset behaviour plus message; no crash |
| A damaged file | Recovers from `.bak` as today; migration runs on the recovered data |
| The pre-migration backup | Exists, byte-identical to the input, never rewritten on a second load |

Also: `save_test.gd` and `menu_test.gd` stay at 0 failures. `balance_sim.gd` runs all three modes for 400 days on both layouts (Q-4, Q-5). Slots 1–3 are hashed before and after every run.

## 6. Risk matrix

| # | Risk | Likelihood | Impact | Mitigation | Owner decision? |
| --- | --- | --- | --- | --- | --- |
| R1 | Crops silently erased on load (today's behaviour) | Certain without §4 | Severe | Crop plot-offset mapping and the fixture test | No (required) |
| R2 | Decor stranded on water, house or forest (today's behaviour) | Certain without §4 | High | Nearest-legal placement or refund | Q-8 for gravel paths |
| R3 | `K` read as a rock where a dock should be, or the reverse | High if codes are merged by hand | High (dock blocks, or rocks walkable) | One production key; dock = `J`; a code-table unit check | No |
| R4 | Gate tile counted as a fence (breaks at night, can be "mended") | Medium | Low–medium | `Q` is its own code | No |
| R5 | Pond smaller: 57 water tiles vs 176; shore fishing 25 vs 61 | Certain | Medium (fishing, drinking water, visitors at the water) | Enlarge the pond west and south, or accept | **Q-4** |
| R6 | Open grass down 48% (969 vs 1,879) | Certain | Medium (forage, building spots, brush) | Balance sim; widen the clearing into the inner forest | **Q-5** |
| R7 | Fences up from 34 tiles to 102 | Certain | Low (a broken rail is harder to find) | Exclude orchard/garden rails from `_break_fences`, or accept | **Q-7** |
| R8 | The prototype's art is baked for its layout | Certain | High (moved features have no art) | P1 per-tile art in the prototype style before the switch | Owner approves art scope |
| R9 | Trek walkers stand in forest (live spots) | Certain without the move | High (trek unreachable) | Spots into the north gap; trek tests | No |
| R10 | `HOMESTEAD_ARRIVE` and the shadow start are formulas | Certain | Medium (land in forest) | Layout constants | No |
| R11 | Night P-1 isn't decided | Open | Medium | Keep the live night until P-1 | Owner (separate) |
| R12 | Per-frame sorting of hundreds of sprites (found in Task A: ~1 ms with the 14-tile margin) | Certain if the tool's approach is copied | Medium | Godot y-sort or sort-on-change in production | No |
| R13 | `DESIGN.md` describes the old layout | Certain | Low | Rewrite with owner approval in the same phase | Owner |
| R14 | Player-planted apple trees (decor) vs the orchard's `o` trees | Medium | Low–medium | Keep both: `o` decorative, the player's trees harvestable | **Q-6** |
| R15 | Players who never update past the old build | Low | Low | The pre-layout backup and the version guard | No |

## 7. Phased production transition (each phase small, reversible, with a gate)
| Phase | Change | Gate to pass | Rollback point |
| --- | --- | --- | --- |
| L0 | This plan; owner answers §8 | Owner + ChatGPT review | n/a |
| L1 | Code reads layout constants instead of formulas (`HOMESTEAD_ARRIVE`, shadow start, new-game start, walker spots into `FarmLayout`). **Same values as today**: no visible change | save/menu tests 0 failures; balance sim identical to the baseline (same seed) | Revert the commit |
| L2 | The production key: add `T`, `o`, `J`, `p`, `Q` to `TERRAIN_CODES` (unused by the live grid) and a code-table check | Same | Revert |
| L3 | `layout_migration_test.gd` and the migrator against a **dummy** v2 layout (live layout shifted by a known offset) | All fixtures pass; slots 1–3 hashes unchanged | Revert; no player affected (no build ships) |
| L4 | Per-tile art in the prototype style for the moved features (plots, cave, stall, grove trees, gate), behind the existing `FARM_SPRITES` fallbacks | Visual review per `VISUAL_REVIEW_PROTOCOL.md` | Fallback art |
| L5 | The parity layout as `farm_layout.gd` v2, with `farm_layout_v1.gd` frozen; migrator on | Fixtures + flood fill + the walk/trek/cave routes + the balance sim (3 modes × 400 days) + menu/save tests + a performance budget | Ship nothing; the v1 layout stays the default |
| L6 | Playtest build with a dev toggle (v1/v2) on the owner's copy of a save (a copy, never slots 1–3 in place) | Owner plays | Toggle back to v1 |
| L7 | Release with the pre-layout backup and the patch note | — | The restore action |

Night P-1, farmhouse stages 0–2 and camera changes stay outside all of these phases unless approved separately.

## 8. Questions to answer before the farm layout can change
1. **Q-1. Replace or keep:** is the prototype layout meant to replace the live farm (WH decision 4)? Everything above assumes yes.
2. **Q-2. Plot one in the garden:** may plot one fill the fenced garden, losing the 4-bed look until per-tile art gives it back? Or do you want the plots split into beds (a gameplay change: four 7×4 beds = 112 tiles against 105)?
3. **Q-3. North-west plots:** plot two in the north-west meadow by the cave, and plot three south of the crossroads: acceptable, or do you prefer them nearer the house?
4. **Q-4. Pond size:** accept 57 water tiles (shore fishing 61 → 25), or enlarge it (about +40 tiles south-west, into today's forest)?
5. **Q-5. Open grass:** accept 48% less open grass, or push the inner forest back 2–3 tiles on the west and south?
6. **Q-6. Orchard trees:** decorative, or harvestable? Harvestable is new gameplay and not in this plan. How do the player's own apple trees fit beside them?
7. **Q-7. Fences that break at night:** should orchard and garden fences count?
8. **Q-8. Decor that can't be placed:** refund it, and are gravel paths re-laid or refunded?
9. **Q-9. Arrival:** the east gate as the arrival point (the farm's front door), even though the gate stays closed?
10. **Q-10. Rollback promise:** how long do we keep `farm_layout_v1.gd` and the pre-layout backups?
11. **Q-11. `DESIGN.md`:** when may its layout section be rewritten (phase L5)?

**Not proposed:** any change to the camera, scale, night (P-1), farmhouse stages 0–2, travel through the gate, or new gameplay.
