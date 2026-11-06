# ART-OVERHAUL-001 — Stage A: art audit, standards and production plan

Task: **ART-OVERHAUL-001** (cave, treks and environmental cohesion), authorized by the owner on 2026-11-06.
Owner: Claude Code. Reviewers: ChatGPT, then the owner. This file is **Stage A** only: the audit, the
technical standards every new asset must meet, and the plan for Stages B–E. No art or code was changed for it.

Labels: **[Code]** read from the source; **[Measured]** checked here; **[Observed]** seen in the BEFORE captures;
**[Plan]** proposed.

## 1. What the owner asked for, and what stays fixed

- Close the gap between the in-game cave and treks and the concept art. PixelLab is now a production tool, with
  no instruction to save generations. Existing art stays where it already meets the bar.
- **Fixed:** every mechanic listed in section 6 of the brief (mining, trek generation and events, collision,
  transitions, saves, lighting rules, sanity, story). The art is drawn over the same tiles. Anything that would
  change a blocking tile, a coordinate or a save is flagged before it is built (section 8).

## 2. The technical art standard (what every new asset must meet)

| Rule | Value | Source |
| --- | --- | --- |
| Tile | 16×16 art px, drawn at 3× (`SCALE = 3`, `PX = 48` screen px) | [Code] `main.gd`, DESIGN "Art" |
| Pixel density | **1 art px = 3 screen px everywhere.** No sprite is drawn at another scale; no resampling | [Code] every `draw_texture_rect` uses art size × 3 |
| Filtering | Nearest; textures imported lossless, no mipmaps | [Code] project default, `.import` files |
| View | Straight-on 3/4 top-down: ground seen from above, vertical faces (cliffs, walls, trunks) seen from the front, light from the upper left | DESIGN "Art style (locked)" |
| Scale anchor | The farmer is 16×32 (two tiles tall). A doorway the player walks into is at least 2 tiles wide and 2 tall | [Code] `art/player/` |
| Palette | Muted, desaturated; dark (not black) outlines from each material's darkest step; the colour grade (`shaders/grade.gdshader`) and night tint are applied on top, so **no lighting is baked into sprites** beyond form shading | DESIGN "Graphics and atmosphere" |
| Transparency | Sprites on full transparency; **no partial alpha** (shadows are separate decals, stepped or ordered-dithered) | ART-005 spec C3, C4 |
| Terrain | Dual-grid corner tiles: a 4×4 sheet of 16 px frames read through `DUAL_FRAME_BY_MASK`. PixelLab's Wang corner tilesets map onto this directly | [Code] `_ground_frame_rect`, ART-005 E2-PL §1.1 |
| Y-sort | Farm pieces (in `art/farm/concept/scenery.json`) carry a base row `b`; they draw behind the farmer while the farmer is south of the base and in front once the base is `FRONT_MARGIN` (0.45 tiles) below the feet | [Code] `farm_scenery.gd` |
| Day/night | Farm pieces carry a day modulate `m` and a night modulate `mn`; the cave is `CAVE_TINT` (#050508, black without a lantern); treks use `trek._tint(darkness)` with `GLOOM`. Lights are `PointLight2D` | [Code] |
| Collision | The tile map alone (`FarmLayout.TERRAIN` on the farm, `cave[][]` in the cave and on treks). Art never blocks | [Code] `farm_scenery.gd` header |
| Registry | Every generated asset is recorded with its id, prompt, seed and settings. PixelLab assets go in a new `pixellab-assets.json` (SpriteCook's stay in `spritecook-assets.json`) | CLAUDE.md, [Plan] |
| Sources | Each finished asset keeps its unedited PixelLab output, the cleanup script that produced the game file, and any masks, under `art/style_tests/ART-OVERHAUL-001/<stage>/` | [Plan] |

## 3. Audit: the north-west cave exterior

**How it is built [Code].** The doorway is the `C` tile at inner (11,8). Row 8 of `FarmLayout.TERRAIN` is
`TTTTTTKKKKKCKKKKKKKK`: firs in columns 0–5, hillside rock (`K`, blocking) in 6–19, the doorway at 11. Stepping
north onto it calls `_enter_cave()`; leaving puts you on (11,9). What you see is `scenery.json`, made by
`tools/farm001r_art.py`:

- five copies of `hillside.png` (96×80) at columns 7–18, rows 5–9, tinted;
- `cave_mouth_natural.png`, **64×48** (4×3 tiles), at (11,9);
- `hill_foot.png` (326×186), a moss-and-leaf fringe drawn flat under everything;
- 16 copies of two ferns along the foot.

**Findings.**

1. **The mouth is still the original 64×48 doorway** recoloured to stone. At the game's zoom it reads as a
   door-sized hole stamped on a mound, not a cave in a hill [Observed]. The 64×48 size has no gameplay
   meaning: collision is the `K` row and the one `C` tile. **The picture can grow freely above and beside
   the doorway** as long as the opening's dark centre stays over column 11 and the art's foot stays on row 8 or
   above (section 6, B-4).
2. **Five identical hillside mounds** side by side read as repetition, and their outlines are rounded heaps
   rather than rock strata. There is no cliff face, overhang or recess [Observed].
3. **Depth:** the dark inside the mouth is a flat fill. Nothing overlaps it (no lip in front, no roots across
   it), so it doesn't recede [Observed].
4. **The foot:** the fern row is evenly spaced; the fringe helps but is one flat layer [Observed].
5. **Night:** the pieces take the night modulate only; nothing marks the mouth at night except the black
   fill. That is acceptable, and it suits "hesitate before entering", but the opening should still read as an
   opening by lantern light [Observed].

## 4. Audit: the cave interior

**How it is built [Code].** A 40×24 grid laid out fresh each day by eight random walks from (20,20)
(`_generate_cave`), with ore set into walls that touch the floor, creatures at least 8 tiles in, and a
two-tile exit at (20,21)–(21,21). `_draw_cave_sprites` draws:

- the floor: the **filled frame of `cave_floor.png`** (64×64 dual-grid sheet) on every tile, mirrored by
  position to hide repetition;
- the walls: `cave_wall.png` on the dual grid, darkened by `CAVE_WALL_TINT` (0.55, 0.55, 0.6) because it was
  "close in tone to the floor";
- ore: one 16 px cell each for copper and iron (`cave_ore.png`, 32×16);
- the exit: `cave_exit.png`, 32×32 steps, flipped to climb south.

Lighting: `CAVE_TINT` black, the lantern's ring boosted by `CAVE_LANTERN_BOOST`, and a faint cool
`cave_mouth_light` by day at the exit.

**Findings.**

1. **The walls are flat ground tiles, not walls.** The dual grid lays rock as a top-down terrain patch with no
   south-facing face, so tunnels read as dark carpet on grey carpet rather than passages cut into rock. This is
   the single biggest gap [Code, Observed].
2. **The floor is one 16 px pattern mirrored**, so the repetition shows across a lit ring [Observed].
3. **The tint is a workaround** for walls that don't separate from the floor by form.
   In play only the lantern ring (about 3 tiles) is ever visible, so every tile inside it carries the scene.
   The BEFORE shots show grey speckle with darker grey blocks [Observed].
4. **Ore** is a single small speck pattern per metal; copper and iron are distinguishable mainly by hue.
   It works, but it doesn't read as a vein in a rock face.
5. **The exit** is a staircase in a different stone from the exterior [Observed].
6. **The interior and exterior don't share a stone.** The hill outside is warm grey-brown with moss; the walls
   inside are cool blue-grey.

## 5. Audit: the trek scenes

**How they are built [Code].** Each clearing is laid into the cave's 40×24 grid (`trek_system.gd`,
`CLEARINGS` as trail points, room carved round them). Routes: `edge`, `mill` (marked and dark trails), `orchard`,
`chapel`, `post` (also the chapel), `grove`. `_draw_map` draws:

- grass with the farm's **old** `_draw_grass` (`ground_grass.png`), not the concept farm's ground;
- the trail on the dual grid from `ground_path.png`;
- trees: **as committed (`6305fc2`)**, `m._draw_tree_tile`, the old round code-drawn crowns.

The working tree also carries an **uncommitted VIS-002 preview** (`DEPTH_PREVIEW = true`, about 127 lines in
`trek_system.gd`, plus a sunset glow in `main.gd` and `grade.gdshader`). It is stashed as `stash@{0}` and
commented "preview, not production". It adds:
- the 32×48 SpriteCook `tree_fir/dead/oak_*.png`, tinted darker by depth from the open ground, with roots at
  the edge;
- forest-floor details from **`art/style_tests/VIS-002/forest_floor_strip.png`**, a production path into a
  test folder;
- two drifting `weather_fog` layers.

**The preview has a visible defect:** pale lavender tile-sized squares scattered over the trees and grass on
every route, by day. The committed treks don't have them [Observed, sheet row 4 against row 3].

Also drawn by `_draw_map`, in both versions:
- **every event and destination in code shapes:** the fallen log (`_draw_log`, two rectangles), flooded hollow,
  rope, fingerpost, crow-skull cairn, hollow tree, fog bank, stile, the mill with its wheel, the orchard,
  chapel and grove.

**Findings.**

1. **Two forests.** The farm's forest is the concept's `src_fir.png` and `src_maple.png`. The committed treks
   use code-drawn blob trees, and the preview uses the older 32×48 SpriteCook trees. Either way, walking out of
   the east gate changes art family [Code, Observed].
2. **The ground is the pre-FARM-001 grass**, uniform green, so the wild wood looks tidier than the farm.
3. **Events and destinations are code rectangles** at a different level of finish from everything around
   them. The mill, chapel, orchard and grove are the routes' payoffs and currently the weakest pictures.
4. **The trail edge is one hard dual-grid line**, with no roots, leaf drift or worn verge.
5. **All routes look alike.** Only the events and destinations differ. Each route has a narrative identity
   (section 7, D) that the ground and trees could carry.
6. **A production scene depends on `art/style_tests/`.** This gets fixed in Stage D by moving the strip (or its
   replacement) into `art/farm/`.

## 6. Plan: Stage B — the north-west cave exterior

**Goal:** a cave set into a real hillside: layered rock strata and cliff sections, a recessed mouth that
falls to black, an overhanging mossy lip with hanging roots, rubble and undergrowth at the foot, and a natural
join to the clearing. It should be recognisable as the way in, and a little unwelcoming.

**B-1 Palette and anchor (free plus about 10 generations).**
- Extract a palette from the FARM-001R farm: hillside, boulders, firs, ground chunks and fringe.
- Make one style board with `create_image_pro` (cliff strata, mossy edge, root, fern, rubble, cave dark), with
  the palette forced, the FARM-001R boulders and hillside as labelled references, and the owner's cave concept
  sheet as a "composition and mood" reference.
- Clean it in `pixelart_workbench`.

**B-2 Assets, all at 16 px tile density, separated so they layer and sort.**

| Asset | Size (art px) | Tool | Drawn |
| --- | --- | --- | --- |
| Cliff back: the hill's rock face and strata, columns ~5–19 | ~240×112, in 2–3 overlapping sections | `create_image_pro` (style board, palette); inpaint the joins | behind, base row 8 |
| Mouth: recessed opening, overhang, inner dark steps falling away | 96×80 (6×5 tiles) | `create_image_pro_flash` + inpaint | behind, base row 8, its dark centre on column 11 |
| Lip overlay: mossy brow, hanging roots and vines | ~96×32 | `inpaint` on the mouth, cut out as its own layer | over the mouth |
| Cliff-foot transition: soil, moss, leaf drift, small roots | 3–4 pieces, ~64×24 | `create_image_pro` 64-candidate sheet | flat, under props |
| Rubble and rocks: 6–8 boulders, rubble, pebbles | 16–32 px cells | `create_image_pro` (64 candidates per call) | sorted, on `K` tiles or as flat decals |
| Undergrowth: ferns, brambles, vines, leaf litter | 16–32 px cells | as above | sorted or flat |
| Threshold shadow | ~64×24 decal, stepped or ordered dither, no partial alpha | hand-made by script | flat, row 9 |
| Night | no new art: the existing night modulate. A darker "throat" value on the mouth's inner steps so the lantern shows depth | — | — |

**B-3 Integration.**
- A new script `tools/aoh_cave_ext.py` writes the pieces to `art/farm/cave_ext/` and their placements to
  `art/farm/cave_ext/pieces.json`.
- `farm_scenery.gd` gets a flag `CAVE_EXT_V2`. On, it skips the `scenery.json` entries tagged as the old cave
  (the five hillsides, the mouth, the fringe and the ferns) and draws the new list. Off, it is the FARM-001R
  picture, which gives a clean BEFORE.
- `main.gd` already leaves `Tile.CAVE_MOUTH` to FarmScenery under `CONCEPT_ART`, so it needs no change.

**B-4 Gameplay guardrails.**
- Collision, the `C` tile, `_enter_cave()`, `_leave_cave()` and the minimap icon stay as they are.
- No opaque art covers a walkable tile south of row 8 except flat ground decals and low ferns that sort
  correctly.
- The doorway must stay the darkest, most central shape in the composition, and the action-bar marker must
  still show on it.

**B-5 Checks.**
- `layout_test`, `save_test` and `menu_test`.
- A targeted check in `layout_test`: walk north from (11,9) onto (11,8) and confirm `in_cave`, then leave and
  confirm the farmer is back on (11,9).
- Captures, BEFORE and AFTER: day 12:00, dusk 19:30, night 21:30 with a lantern, and rain. Each from the
  gameplay view at (11,10), plus a full-size close crop of the mouth.
- The master PNG goes in `art/style_tests/ART-OVERHAUL-001/B/review/`.

**B budget:** about 80–150 generations, with a soft cap of 200.

## 7. Plan: Stages C, D and E

### C — The cave interior (one session)

- **Walls with faces.** A PixelLab pro top-down tileset with raised walls (`transition_size` 0.5 or 1.0):
  damp cave floor below, rough rock above. It uses the exterior's palette and stone, so inside and outside
  are one geology.
  - The 25-tile layout's wall-continuation tiles map onto the dual grid by an explicit table, checked by a
    script that renders every mask.
  - `CAVE_WALL_TINT` goes once the walls separate by form.
- **Floor:** 4–6 floor variants and decals (wet stone, pebbles, a drip puddle, root tips from above, old
  timber), scattered by `FarmSprites.variant`.
- **Ore:** 2–3 variants each of copper and iron, set into the new wall face. Iron stays clearly darker and
  rust-flecked; copper green-orange. No crystals.
- **Exit:** steps in the same stone as the exterior, with the existing faint daylight.
- **Code:** `_draw_cave_sprites` only, behind `CAVE_ART_V2`. `_generate_cave`, ore odds, creature spawns,
  mining and saves are untouched.
- **Checks:**
  - captures entering, a corridor, a deep dead end with iron, and pitch black without a lantern;
  - mine one copper and one iron node in `save_test`'s slot 9;
  - `save_test`, `menu_test`, and a 40-day `balance_sim` run to confirm nothing changed in the numbers.
- **C budget:** about 100–180, soft cap 250.

### D — Trek environments (two or three sessions; the largest stage)

**Shared wilderness library first.**
- One ground tileset: forest floor with a worn dirt trail, from PixelLab pro at 16 px.
- 6–8 floor decals, replacing the VIS-002 strip and moving out of `style_tests/`.
- Undergrowth along the trail verge.
- Trees from the **same family as the farm's** `src_fir` and `src_maple`, plus gnarled old trees and dead
  snags.
- Stumps, logs and rocks.

**Then each route's identity, mapped from the four concept directions onto the existing routes:**

| Concept direction | Where it goes (existing content only) |
| --- | --- |
| Misty Forest Trail | `edge` and the `mill` marked trail: firs, leaf drift, roots, mushrooms, low fog (the existing fog layers) |
| Creek Crossing | the **flood** event (the hollow's water, banks, reeds, wet stones, the roped crossing) and the mill's stream and footbridge dressing |
| Overgrown Pasture | the **orchard** route (the drowned orchard): broken fencing, a collapsed shed, tall grass and brambles, gone-wild fruit trees |
| Moonlit Hollow | the **dark trail** and the **grove** route: ancient trees, twisted roots, stone remnants, a darker tint (already `GLOOM_DARK`) |
| (shared) | `chapel` and `post`: misty trail climbing to stone walls and the chapel |

**Code-drawn events and destinations become sprites** at the same positions and sizes: the fallen log, the
fingerpost, the cairn, the hollow tree, the stile, the mill with an animated wheel, the chapel, the orchard
and the grove stones.
- `CLEARINGS`, events, blocking, timings and pay are untouched.
- Each route is checked with `capture.gd trek=N troute=…` (and `tdark`, `tall`), plus a full walk of the mill
  route in a headless check that reaches the destination and returns home.

**D budget:** about 300–500, soft cap 650.

### E — Cohesion and optimization (one session)

- Side-by-side sheet of farm, cave mouth, cave interior and two treks at gameplay scale. Fix outliers in
  scale, outline weight, palette and light direction.
- Performance:
  - draw calls and frame time from `Performance` monitors, through a new `perf` option in `capture.gd`;
  - texture memory before and after;
  - frame time on the trek with the most trees.
- If needed, batch the new textures into atlases.

**Total PixelLab use [Plan]:** about 500–850 generations against the 4,888 left this cycle (resets
2026-12-03), USD 0. No credits will be bought without asking.

## 8. Needs from the owner (none blocks Stage B)

1. **The cave and trek concept sheets aren't in the repository.** `art/reference/concept/` holds only the
   four sheets from 2026-11-01 (overview, autumn and night homestead, the Rookery escort). Please add the
   ChatGPT cave and trek sheets there.
   - Stage B uses them as labelled "composition and mood" references in PixelLab: art direction only,
     never sliced into tiles.
   - Without them, Stage B works from the brief's description and the existing sheets.
2. **Pipeline note.** `CLAUDE.md` and `DESIGN.md` still name SpriteCook as the sprite tool, and the SpriteCook
   connector currently needs signing in again (`/mcp`). I'll record PixelLab as an approved production tool
   in `DESIGN.md` with its own registry. Please say if `CLAUDE.md` should change too.
3. **The uncommitted VIS-002 preview** (trek depth, plus a sunset glow in `main.gd` and `grade.gdshader`) has
   sat in the working tree since before ART-004, and every capture includes it.
   - The trek parts are superseded by Stage D.
   - **Proposal:** Stage B starts by setting it aside as a stash (it is already saved as `stash@{0}`), so
     every BEFORE/AFTER is the committed game.
   - Stage D reuses its ideas (depth tint, edge shadow, fog layers) on the new art, without the pale-square
     defect.
   - The sunset glow is a separate lighting question; it stays parked unless the owner revives it.
   - **I won't discard it without your yes.**
4. **Licensing.** PixelLab's Terms of Service govern commercial use of subscription output (flagged in
   ART-005 E2-PL §1.3). The owner's production authorization is taken as acceptance; please confirm.

## 9. Order of work and reporting

Each stage runs in its own fresh session, keeping usage low, and ends with:
- a review package under `art/style_tests/ART-OVERHAUL-001/<stage>/review/`;
- a commit and push;
- a board entry giving what changed, the PixelLab assets, what's unchanged, the commits, the tests,
  the images and the known issues.

No stage is called approved until ChatGPT's review is on the board and the owner accepts it.
