# ART-003 WH: whole-homestead coherence and the road-exit plan

Status: for ChatGPT's and the owner's review. **Review and planning only; nothing in the game or the prototype was changed.**

- **Not changed:** the live farm, gameplay, saves, camera, scale, `DESIGN.md`, production night lighting, `tools/art003_wide.gd`, the prototype blueprints.
- **No generation:** PixelLab 0, SpriteCook 0.
- **VIS-002:** the uncommitted work is untouched. The diff hash is still `f52e5ae0…` and `stash@{0}` is present.
- **Captures:** all from a `git archive` export of `0dc7f67` (no VIS-002), `mode=wide layout=b art=w3c grass=1` (wall A, oak D, G1, R3-1 night). 1280×720 at 3×, with the game's own camera, so this is **actual gameplay size**. 12:00 and 21:30, sunny, autumn, sanity 100.
- **Not checked:** rain, fog, winter, other house stages and nights with visitors. The captures ran in parallel, so their frame times are not valid (draw calls and lights are).

## A. The five viewpoints as one place
| View | Day | Night (R3-1) |
| --- | --- | --- |
| **V1-B core** (house, oak, well) | The strongest frame. The golden oak and blue-black roof balance well. The house, porch and pumpkins read as lived-in. | Lit windows and the porch lantern anchor it. The oak still reads as a silhouette. |
| **V5-B porch** | Porch, well and garden fence connect in one frame. The path network reads at once. | The porch pool and windows feel like the safe point. The garden beyond goes blue-grey. |
| **V3 crossroads** | The three groups read as purposeful with open grass between them. The well's cobble ring has a hard dark contour that reads like a drop shadow. | The farmer's pool and the garden lantern are the only warm points. The signpost and handcart are small but readable. |
| **V2 garden** | Rich and coherent: four beds, varied rows, corn along the north fence. This is the most finished area. | The garden lantern carries it. The beds hold their shapes. |
| **V4 orchard and pond** | The pond, dock and reeds are good. The orchard reads as small, separate trees on a lot of grass. | The pond is the brightest cool area. The apple crown stays warm even unlit. |
| **Road east end** | The mailbox and dead tree give it a threshold, but the road runs flat into a uniform conifer wall: **a dead end, not an exit**. | The forest goes almost black: the most unsettling spot on the farm, but it reads as a wall rather than a way into the dark. |

**Connection:** the path network ties porch → well → crossroads → garden → road → pond together without breaks, and every view contains at least one landmark from the next. The weak links are the orchard, which sits apart in the west, and the road's east end, which goes nowhere.

**Prototype defect at the road end** (`shots/end_day.png`, farmer at 58.4, 34.5): the camera reaches x ≈ 71.7, past the prototype's 6-tile forest margin (it ends at x = 70). Beyond that it draws plain grass, so a grey-green strip shows at the right edge. Only the prototype is affected; the live border is 14 tiles. The margin needs to be at least 8 tiles before any exit work.

## B. Inconsistencies between asset families
1. **The woodstore is also the porch firewood.** ChatGPT's recommended swap ("existing porch firewood art") is the same sprite: W-3 polish used `art/farm/woodstore.png` on two of the house's dressing tiles (`tools/art003_wide.gd`:624). So the "cabinet" problem is in three places, both house wings and V3. The swap as written would change nothing. Zero-generation options:
   - **(a)** Drop the woodstore from all three spots. Keep the chopping block and stump at V3, and put a barrel or crate on the house wings.
   - **(b)** Hand-build a low log pile (about 32×16) from the PixelLab `r3/log.png` (64×32): two or three logs cut, shortened and stacked, palette colours only. Use it in all three spots.
   - I recommend **(b)**, with (a) as the fallback if it doesn't hold up at 4×.
2. **Forest frame.** It's the production SpriteCook conifers (cool, near-black green) with red maple bushes. Inside the farm, the trees are PixelLab deciduous (the golden oak, the fruit trees). These are two tree families, and the frame is in every view.
3. **The well** is the production SpriteCook sprite. Its stone is cooler and greyer than the warm prototype palette, and its outline is lighter than the house's. It reads well but sits a step apart.
4. **The house** (wall A paint-over) has a heavier dark outline than the PixelLab props around it. The difference is acceptable at gameplay size but visible beside the well.
5. **Orchard crowns:** the golden pear, orange apple and red maple bushes sit close together in a small area, so the orchard looks scattered rather than planted. The fruit trees (48×64) are about a third of the oak's size.
6. **Crops:** the garden beds are baked prototype sprites, not per-tile crops. They match each other well, but the live game's crops are per-tile and staged (see F).

## C. The east road exit (blueprint; nothing built)
**Proposal:** the homestead's east line becomes a **farm gate** where the road meets the trees. Beyond it the road runs on through a cut avenue and bends north-east out of sight in the border.

- **Collision-neutral:** the only tiles that change inside the farm are at x = 59, rows 33–36. They are forest (blocking) now and would become gate posts `X` and closed gate leaves `G`, which also block. The farmer reaches exactly the tiles they reach today. The walk, routes and saves are unaffected.
- **Framing:** forest is kept on rows 32 and 37, so the avenue is framed by trees. Rows 33 and 36 become grass verge. The Batch C dead tree, mailbox and boulders stay where they are, and the dead tree now marks the gate.
- **At night** the avenue runs into the forest's darkness: the road visibly leads into the dark, not into a wall.
- **No new light.** A lamp at the gate stays the earned "lamps on the post road" upgrade.
- **Camera:** with the farmer at the gate (58.4, 34.5), the 26.67×15-tile view spans x 45.1–71.7, so the bend at x ≥ 70 is just in frame and then leaves it. The prototype needs a margin of 8 or more (14 to match live); the live camera already clamps at its 14-tile border.

Tile blueprint, x 46–77, y 27–42 (`exit_blueprint.txt`, image `review/wh_exit_blueprint.png`). Key: `T` forest, `.` grass, `P` road, `X` fence post, `G` closed gate (blocks), `v` verge, `m` mailbox, `D` dead tree, `k` boulders, `S`/`w`/`g` garden. x ≥ 64 is the border.
```
CURRENT (art=w3c)                     PROPOSED (not built)
      44445555555555666666666677777777      44445555555555666666666677777777
      67890123456789012345678901234567      67890123456789012345678901234567
y=31  .....PP......TTTTTTTTTTTTTTTTTTT y=31  .....PP......TTTTTTTTTTTTTTTvvvv
y=32  ....PPPm..DD.TTTTTTTTTTTTTTTTTTT y=32  ....PPPm..DD.TTTTTTTTTTTvvvvPPPP
y=33  ..PPPPP......TTTTTTTTTTTTTTTTTTT y=33  ..PPPPP......XvvvvvvvvvvPPPPPPPP
y=34  PPPPPPPPPPPPPTTTTTTTTTTTTTTTTTTT y=34  PPPPPPPPPPPPPGPPPPPPPPPPPPPPvvvv
y=35  PPPPPPPPPPPPPTTTTTTTTTTTTTTTTTTT y=35  PPPPPPPPPPPPPGPPPPPPPPPPvvvvTTTT
y=36  T..TT..TkkT.TTTTTTTTTTTTTTTTTTTT y=36  T..TT..TkkT.TXvvvvvvvvvvTTTTTTTT
y=37  T..TTTTT.TTTTTTTTTTTTTTTTTTTTTTT y=37  T..TTTTT.TTTTTTTTTTTTTTTTTTTTTTT
```
**Alternatives, not recommended now:**
- An open gap with an invisible stop further east. This is a hidden wall.
- A walkable exit that leads somewhere, such as the lane or a market trip. This is new gameplay and needs a design decision first.

**Art needed:** a gate is a variant of the existing fence art (posts plus two leaves); it can be hand-drawn, so it needs no generation. The avenue uses the existing path and grass sets.

## D. Cozy by day, unsettling by night
- **Farmhouse, garden and pond:** cozy by day, holding.
  - At night the house windows and porch lantern make a clear refuge.
  - The garden lantern extends that refuge.
  - The pond is the brightest cool surface at night. It reads well, but it softens unease in the west. **Holding.**
- **Orchard:** pleasant by day but thin. At night it is neither cozy nor eerie: the trees just dim. The apple crown's warmth stays the same unlit. **Partly holding.**
- **Entrance:** neither cozy nor unsettling by day; it is a boundary. At night the black wall is the farm's strongest unease, but a dead end wastes it. **Not yet.** The gate-and-avenue plan is meant to fix both: by day a homely gate and mailbox, by night a road into the dark.
- **Limit:** these are still frames. The night's real unease comes from visitors, crows and sound, which these captures don't show.

## E. The three gaps with the most effect on concept fidelity
1. **The forest frame:** artwork and arrangement. A uniform conifer wall, from a different family than the trees inside, frames every view, and it is what currently ends the road. The fix is a small mixed forest-edge set (deciduous edge trees in autumn colour in front of the conifers, with irregular depth), plus the exit avenue. This would need generation, so it is an owner decision; no spend is proposed here.
2. **Orchard fullness:** manual artwork and arrangement. Fuller crowns, two tree sizes, varied fruit, windfalls under the trees, a tighter planted rhythm, and a continuous fence. All of this is manual paint-over of the Batch C trees, with no generation.
3. **Night depth:** lighting and technical. Lighting is the lowest score (ChatGPT 6.5). The night is an even blue-grey across the farm interior, and only the edges go dark. A falloff toward the forest edge (darker under the tree line, with no new lights) and window spill reaching the ground would shape it. This needs the production night (P-1) decision, so it is not proposed for building yet.

## F. Production-readiness checklist (prioritized)
**P0: blockers before any production planning starts**
- [ ] **Layout parity.** The prototype is a different farm, not a reskin of the live one.
  - The live `FarmLayout` (`scripts/farm_layout.gd`) has things the prototype lacks: the cave mouth (west), the market stall, plots one, two and three (15×7, 15×6, 12×6), the scarecrow, 21 grove trees that are felled for wood, the great tree at (50, 28), the workshop, smokehouse, furnace, woodstore and chopping log (x 39–45, y 31–36), and a north-east lake.
  - The prototype instead has one 19×13 garden, an orchard, a south-west pond and the house about 21 tiles east.
  - Every one of those features needs a place in the prototype layout before migration.
- [ ] **Code clash.** `K` is a blocking rock in the live layout but a walkable dock in the prototype. Both use `W` (well) and `B` (great tree) with different positions.
- [ ] **Save migration.** A save whose `layout` doesn't match `LAYOUT_VERSION` loses its crops, brush and trees, and the player starts at the farm centre (`save_system.gd`:289–310). A new layout would wipe every player's farm unless there is a mapping (old tile → new tile for plots and crops) and a save-version step. Test it with `tools/save_test.gd` (slot 9, never slots 1–3).
- [ ] **Treks.** The walker spot is a fixed inner tile (`WALKER_SPOT := (25, 1)`, `trek_system.gd`:32). It must move to the prototype's north gap above the house (x 44–57, y 2–4), and the trek return position with it.

**P1: required before integration**
- [ ] **Asset consistency:** one tree family for the frame, the woodstore replaced (B1), the well and house outlines matched, the gate drawn.
- [ ] **Atlas batching:** the prototype ground is baked chunks. Production needs a TileMap/atlas for ground, so that tilling, watering and paths can change at run time. Pack the props into one atlas to keep draw calls near today's +0–30 budget.
- [ ] **Crops and orchard by season:** per-tile crop stages for every crop in `CROP_GROW_DAYS`, in the prototype's style. Fruit trees need spring bloom, summer green, autumn fruit and winter bare states. Garden beds can't stay baked.
- [ ] **Farmhouse stages 0–2:** only stage 3 (Restored, wall A) exists in prototype style. Stages 0–2 need ruined, patched and repaired versions that share the footprint and door tile (`HOUSE_IX/IY`, 11×7), plus the porch and interior link. Not approved.
- [ ] **Dynamic tile interaction:** tilling, watering, brush and rock regrowth, grove felling and path wear must redraw single tiles under the dual grid without rebuilding chunks.
- [ ] **Camera and y-sorting:** the scale (3×) and camera stay locked. The roof and chimney framing limit is register entry C-14. Tall sprites (the oak, house, fruit trees, gate) sort by base. Check that walking behind the oak, house and orchard still works with live collision.
- [ ] **Night lighting:** the prototype's R3-1 grade versus production's night. The decision is P-1, which is not approved. Keep the light count (6 at night). Check the sanity gloom, weather tint, the cave and treks under whichever night is chosen.

**P2: verification once integration starts**
- [ ] **Performance:** frame time and draw calls per view, by day and night, measured one capture at a time (not in parallel). Use a mid-range target, with the budget agreed first.
- [ ] **Regression:** `tools/menu_test.gd`, `tools/save_test.gd` and `tools/balance_sim.gd` (all modes), a flood-fill of walkability with no trapped tiles, and route walks from porch to dock, cave and gap.
- [ ] **Visual review:** a BEFORE/AFTER package per stage, following `VISUAL_REVIEW_PROTOCOL.md`.

## Verdict (Claude's, not a review)
**Visually:** the prototype is mature enough to plan a production transition. The core, garden and pond are coherent at gameplay size, and the remaining art gaps are bounded (forest frame, orchard, gate, woodstore).

**Technically: not yet.** The main blocker is layout parity and save migration (P0). The prototype is a new farm plan, so migration is a layout redesign plus art, not an art swap.

**Suggested next gate:**
1. The owner decides whether the prototype layout replaces the live one.
2. If it does, a layout-parity blueprint places every live feature in the prototype layout, before any art or code migration.

## Files
- `shots/`: 13 captures, each with its measure JSON.
- `review/wh_views_a.png`, `review/wh_views_b.png`: the day/night sheets.
- `review/wh_exit_blueprint.png`, `exit_blueprint.txt`, `exit_blueprint.py`: the exit blueprint.
- `review/ART-003WH_master.png` (72%) and `review/ART-003WH_master_2.png` (57%): the masters for the owner to attach.
