# FARM-001 — Concept farm becomes the real farm: audit and staged plan

Stage 1 of the owner task of 2026-11-06. This is an audit only: nothing in `scripts/`, `art/farm/` or `DESIGN.md` has changed. Stopped for owner review.

## 1. How the production layout feeds the game today

`tools/farm_grid.txt` (64×40 inner tiles, one character per tile) → `tools/hand_layout.py` (reuses `tools/farm_layout.py`'s emitter) → `scripts/farm_layout.gd` (constants + `VERSION` hash) → `scripts/main.gd`.

| Consumer | Reads | Where |
| --- | --- | --- |
| Map | `FarmLayout.TERRAIN` through `TERRAIN_CODES` into `map`, inside a `BORDER_X` 14 / `BORDER_Y` 8 forest border (`MAP_W` 92 × `MAP_H` 56) | `main.gd` `_build_map` (~1758) |
| House, door, porch | `HOUSE_IX/IY/W/H`; door = `HOUSE_IX + W/2`, `HOUSE_IY + H - 1`; `PORCH_RECT` | `main.gd` 26-31, 76; `_leave_house` 5967 |
| Plots | `PLOT_ONE/TWO/THREE` as one `Rect2i` each, stamped to SOIL | `farm_system.gd` 75-95, `madness_system.gd` 133 |
| Well | `WELL_IX` (2×2 top-left) | `main.gd` 195 |
| Stall | `STALL_IX/IY` (3×2), Tile.STALL dispatch | `main.gd` 371, 3998; `folk_system.gd` 439 |
| Cave mouth | first `C` in `TERRAIN` (`_cave_mouth_tile`); hillside sprite and `_under_hillside` are relative to it; leaving puts you one tile south | `main.gd` 4812-4845, 2399-2402, 2725 |
| Trees | `GROVE_SPOTS` (fellable), `WILLOW_TREES`, `DEAD_TREES`, `BIG_TREE_INNER` | `main.gd` 81-86; `farm_system.gd` 219 |
| Clutter | `BRUSH/THICKET/ROCK_SPOTS`, `RESERVED`, `CELLAR_IX`, `WORKSHOP_RECT` | `main.gd` 69-96, 343-376, 5277-5345 |
| Trek way out | walkers wait at `TrekSystem.WALKER_SPOT` (25,1) "north of the house"; return/fallen/old-save spot `HOMESTEAD_ARRIVE` (east edge, mid-height) | `trek_system.gd` 32, 519; `main.gd` 407, 2355, 4974; `save_system.gd` 39, 605 |
| Other fixed spots | `PEDLAR_SPOT` (37,12, "beside the stall"); night shadow walks in from the east edge; folk anchors off door/stall | `daily_happenings.gd` 13; `night_system.gd` 434-441, 1039 |
| Camera / bounds | `player.min_pos/max_pos` = inner area; camera limits = `MAP_W/H` | `main.gd` 5994-5999 |
| Save | `LAYOUT_VERSION` = `FarmLayout.VERSION`; a mismatch migrates crops etc. | `save_system.gd` |

## 2. The W-4 + concept grid against it

Coordinates line up: the harness puts the W-4 grid's (0,0) on the production inner (0,0) (`inner_origin = BORDER * PX`). So `MAP_W/H`, `BORDER_*`, camera and minimap need no change. The W-4 grid simply has its own forest (`T`) inside the inner area.

| Thing | Production now | W-4 / concept |
| --- | --- | --- |
| House (roof+walls) | (19,5) 11×7, door (24,11) | (40,5) 11×7, door (45,11), porch (45,12); `d` dressing either side blocks |
| Fields | plot 1 (3,19) 15×7, plot 2 (3,31) 15×6, plot 3 fallow (29,23) 12×6 = 267 tiles | four F2 fields of 7×4 in a fenced garden: NW (44,20), NE (52,20), SW (44,25), SE (52,25) = 112 tiles; walkways `w`, fence `X`, gates `g` (42,23-24) and (50-51,30) |
| Well | (22,24) | (37,15), cobbles `c` round it |
| Great oak | (50,28) | (30,11), boulders `r` round it |
| Pond | north-east lake | south-west pond (2-16, 28-35), dock over water (13-14, 29-32) |
| Orchard | none | fenced (6-21, 17-27), six trees `o` |
| Cave mouth | (2,8) on the west edge, rocks `K` | (11,8) in the NW hillside; hill blocks set in `concept_farm.gd` `_concept_props`; 29-tile approach path |
| Stall | (34,11) beside the house | (54-56, 31-32) by the mailbox, inside the gate |
| Way out | walker at (25,1), north | closed east gate x 59, rows 33-36 (drawn-only overlay from `wh/exit_blueprint.txt`); avenue east into the border |
| Lantern post `L`, mailbox, log pile, dead tree, boulders | — | props that block (`c_block`) |

**Code clashes to fix in the new legend:** W-4 `K` is the dock (walkable), production `K` is rock; W-4 `G` (overlay) is a gate leaf, production `G` is a grove tree; W-4 `T` is forest, which production has only outside the border.

## 3. What the prototype draws that production would have to draw

The harness (`art003_wide.gd` `_build`, ~560 lines, plus `env001_scene.gd` and `concept_farm.gd`) draws:

- **Ground:** PixelLab Wang sets on a dual grid (grass, path, cobbles, garden floor), ENV-001 terrain family (T), contact shadows (S), concept grass clusters, soft path edges and hill-foot shadows. Baked into 16×16-tile chunk images over the farm plus a 14-tile margin (92×68 tiles). Water uses the production `ground_water`.
- **Forest:** a tree on forest tiles by depth, the avenue's wall of firs, and forest shade. Shade strength is baked per start hour (`shade_night`).
- **Standing sprites:** the P1 cabin (`vs16p1/cabin/house_{day,night}.png`), oak (`w3/oak`), well, fences (rails/posts), garden gates, the east gate (`w4/gate`), orchard trees (`w4/orchard`, four variants, windfalls, basket), log piles (`w4/props/logpile`), mailbox, lantern post, dead tree, boulders, rushes, dock, rain barrel, compost, porch dressing, the F2 field crops and soil states (`f2/`, drawn only), the hillside (5 × `art/farm/hillside`), `cave_mouth`, rocks and boulders, undergrowth, and `prop_stall`.
- **Light:** the R3-1 night is a **harness-only** override node (`art003_round3.gd` `_night`/`R3_SCRIPT`: tint, grade, weather dim). It is not in production. The concept's daytime warmth is also in the harness (`_tick`).

## 4. Proposed approach

Keep the production pipeline: grid → generator → `farm_layout.gd` → `main.gd`. Don't port 1,000+ lines of harness drawing. Instead:

1. **Layout:** a one-off `tools/concept_grid.py` merges the W-4 grid, the gate overlay and the concept's cave, hill blocks, stall, approach and prop blocks into a new `tools/farm_grid.txt` with a cleaned-up legend. `hand_layout.py` learns the new anchors. The generator bumps `VERSION`.
2. **Art:** a one-off exporter, `tools/concept_export.gd`, runs the concept build and writes out:
   - the baked ground chunks, a day set and a night set (fixes "shade baked at the start hour"; the two crossfade with darkness);
   - a placement list of every standing sprite (texture, position, base, flip, tint, tile).

   Only the textures it uses are copied into `art/farm/concept/`. A small `scripts/farm_scenery.gd` node shows the chunks and the sprites, sorted against the farmer as the harness does.

   Dynamic things stay drawn by `main.gd` on top: tilled/watered soil and crops (using the F2 art), brush and rocks, felled stumps, coop, barn, workshop, decor, forage, fish spots, the cave-mouth darkness and lamps. The code-drawn farm ground and hillside stay as the fallback behind a flag.
3. **Light:** port R3-1 (tint, grade, weather dim) and the daytime warmth into `main.gd`'s tint path. Keep it apart from the owner's uncommitted sunset hunks.

## 5. Stages (each its own commit on `main`, each stopping for review)

**Stage 2 — layout and logic (looks like today's code-drawn art on the new shape)**
- New grid, legend, generator and `farm_layout.gd`. `VERSION` bumped.
- Plots become lists of rects (`farm_system`, `madness_system`, `main`); see decision A.
- Dock tiles walkable; fishing from the dock and the shore.
- Orchard behaviour (decision B). The well, porch and door anchors move. The cellar is re-reserved.
- Cave at (11,8): hill tiles block and the approach is a path; `_leave_cave` lands on the approach.
- Stall at (54,31): Trade 06:00-18:00 is unchanged; `PEDLAR_SPOT` moves beside it.
- Gate: posts and leaves block; `WALKER_SPOT` moves inside the gate on the road (57,34); `HOMESTEAD_ARRIVE` moves to the road. Walker texts change from "north gate / north of the house" to the east gate.
- Grove trees: about 12 chosen forest-edge tiles (decision C). Brush, rock and thicket spots re-picked on open grass.
- A new `tools/layout_test.gd` (headless, slot 9) ports `check=nav` to the real map: porch → fields → road → stand (Trade) → cave and back → house and back, plus hoe/plant/water on each field, draw at the well, a cast from the dock, and talking to a walker at the gate. Then `save_test`, `menu_test` and `balance_sim` (engaged, ignore and earlybed in parallel).

**Stage 3 — art and drawing**
- Exporter, `art/farm/concept/`, the `farm_scenery.gd` node, F2 soil/crop art on the real plots, R3-1 and daytime warmth in production.
- Asset notes in `DESIGN.md` and `spritecook-assets.json` (the source IDs of the reused pieces; PixelLab/hand-built pieces noted as such).
- Visual review per the protocol: BEFORE = today's production, AFTER = new; day, dusk, night, rain; one master PNG.

**Stage 4 — docs and wrap-up**
- `DESIGN.md` "Farm layout", "The mining cave" and "Money and the farm stand" rewritten; "Groves and treks" walker spot.
- Board entry with SHA-pinned links once the owner authorizes the push.

The owner's uncommitted hunks in `main.gd`, `trek_system.gd`, `grade.gdshader`, `project.godot`, `main.tscn` and the `.uid` files are left out. Only my own hunks get staged (index-only patches). Tests only in slots 8-9. Zero generation.

## 6. Owner decisions (answered 2026-11-06)

- **A. Fields:** one field per unlock: NW at Farming 1 (open from the start), NE at Farming 2, SW at Farming 5, SE at Farming 9. Four plots instead of three (adds `PLOT_FOUR`; a `plot_four_open` save field; the third-plot project and its "house Patched" gate are rechecked against the new levels). The crop yield per harvest may need raising to keep the economy: measure it with `balance_sim` against today's build, then propose a number for the owner's approval.
- **B. Orchard:** autumn windfalls (apples and pears) gathered as forage. The sapling reward and `apple_tree` decor are unchanged.
- **C. Grove trees:** about 12 forest-edge trees facing the clearing, fellable, with stumps that regrow.
- **D. House:** the P1 cabin at every repair stage.

### Original options and recommendations

- **A. Field area.** The four F2 fields are 112 tiles, against 267 today: 42%, or 21% of today's starting soil if only one field opens at the start. *Recommend:* plot one = NW + NE (56, open from day 1), plot two = SW + SE (56, Farming 2), plot three = a fifth fallow field of about 10×4 inside the garden's south strip or west of the garden gate (Farming 9, as now). Then let `balance_sim` decide whether crop prices need a follow-up (as its own decision, not in this task).
- **B. Orchard.** Production has no orchard; the apple tree is a story reward (Davy's saplings, Farming 4). *Recommend:* the six old trees drop windfall apples and pears as autumn forage, gathered from the orchard floor. The sapling reward and `apple_tree` decor stay as they are.
- **C. Grove trees for Forestry.** W-4 has no free-standing grove. *Recommend:* about 12 forest-edge trees facing the clearing become fellable; a felled one shows a stump until it regrows, as now.
- **D. House stages.** Production draws four repair stages; the concept has the single P1 cabin. *Recommend:* the P1 cabin at every stage for now (the day and night versions are kept). Stage art is a later art task.
