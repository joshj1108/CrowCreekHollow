# Concept fidelity and technical feasibility

Task: ART-004 (proposed). Author: Claude Code, 2026-11-02. Status: **proposal for ChatGPT review and the owner's decision.** Nothing here is approved, and no game file, production asset, layout or locked rule was changed to write it.

**Revision 1 (2026-11-02), after ChatGPT's ART-004 review (board, commit `0121d1d`):**
- Painterly fidelity is no longer classed E. Exact reproduction and perceptual approximation are separated, and untested alternatives are marked *uncertain* (system 3, C-03).
- Night brightness numbers are now diagnostic measurements, not acceptance targets, with a stated capture and measurement method and a required visual and play-test check (system 11, "Night measurement method").
- The first night experiment is slice-only; production integration needs its own approval (system 11).
- Extra permanent landmark lights (oak, well, pond) are no longer recommended; they are an option that must first be checked against earned lamps and the horror progression (system 11, C-07).
- Field-of-view figures are labelled as uncalibrated estimates; scaling options are research options that need their own approved test plan (system 2, C-02).
- A working-tree and build check is now a prerequisite for any implementation ("Before any implementation").

This compares the owner's four approved concept images (`art/reference/concept/01`–`04`) with what the Godot game actually renders, system by system, and says what it would take to close each gap. It sits under `DESIGN.md` (D-001): where they disagree, `DESIGN.md` and the owner's recorded decisions win until the owner changes them.

Related documents:
- `ART_DIRECTION.md` — the proposed art bible this assessment feeds.
- `AI_COLLAB/ART_REVIEW_RUBRIC.md` — how prototypes are scored.
- `AI_COLLAB/ART_003_SCORECARD.md` — the score for ART-003 Round 2.
- `AI_COLLAB/ART_003_ROUND3_PLAN.md` — the next round, built from this assessment.
- Earlier evidence: `art/style_tests/ART-003/BREAKDOWN.md` (reference breakdown and gap table), `SLICE.md`, `ROUND2.md`, `art/style_tests/ART-002/FINDINGS.md` (16 px vs 32 px), `AI_COLLAB/VIS-001_audit.md` (lighting).

## How to read this

**Evidence labels.** Every claim is one of:
- **[Observed]** — seen in code, a project setting, a file, or a Godot capture already in the repo.
- **[Measured]** — a number from a capture (mean luma etc.), with its source.
- **[Estimate]** — a reasoned number not yet measured; the method is given.
- **[Judgement]** — a visual opinion. ChatGPT and the owner may disagree.

**Classes** (from the task brief):
- **A** — directly achievable with existing Godot features and assets.
- **B** — achievable with modest asset, composition or rendering work.
- **C** — achievable, but needs significant new art, engineering or performance trade-offs.
- **D** — conflicts with an approved gameplay, camera, scaling or asset rule.
- **E** — not reliably achievable in the current implementation without a substantial redesign.

A system can carry more than one class (for example "A technically, D by rule"). A class followed by **(uncertain)** means the route looks feasible but hasn't been tested; it is a hypothesis, not a finding. E is used only where a specific engine or rule limit has been identified *and* the alternatives have been tried or ruled out with evidence. At present nothing in this document meets that bar.

**Evidence used.** No new captures or prototypes were made for this document (the brief rules them out). Images consulted:
- Concepts: `01_overview.webp`, `02_autumn_homestead.webp`, `03_night_homestead.webp` (via the Round 2 master), `04_rookery_escort.webp`.
- Production game: `art/style_tests/VIS-001/review/VIS-001_master.png` (farm day 12:05, dusk, night 21:35, a trek; commit `dfd3594`).
- Prototypes: `art/style_tests/ART-003/review/round2/ART-003R2_master.png` and `_master_2.png` (concept vs Round 1 vs Round 2, day and night, close-ups).

**Known limits of this evidence.**
- The production capture and the ART-003 slice are different places on the farm; there is no matched production capture of the slice's area. Round 3 fixes that (plan step R3-0).
- The concept images are AI-generated mockups with no pixel grid, so measurements taken from them (framing, pixel size) are estimates.
- No frame-time profiling has been done for any of this. Every performance statement below is an estimate unless it says otherwise.

## Engine facts that bound everything

[Observed] in `project.godot`, `scripts/main.gd` and `shaders/grade.gdshader`:

| Setting | Value |
| --- | --- |
| Base canvas | 1280×720, `stretch/mode = canvas_items`, `aspect = expand` |
| Renderer | `gl_compatibility` (desktop and mobile) |
| Texture filter | nearest (`default_texture_filter = 0`) |
| World scale | `SCALE := 3`: a 16 px tile is 48 screen px at the base canvas |
| Tiles in view at base | 1280/48 × 720/48 ≈ **26.7 × 15** |
| Grade | saturation 0.62, exposure 0.84, contrast 1.1, warmth 0.02, shadow_cool 0.035, vignette 0.55, grain 0.025 |
| Night | `CanvasModulate` toward `NIGHT_TINT` `3a3f6e`, warm `DUSK_TINT` `dbb39e` between (`LIGHTING_V2`) |
| Lights | `PointLight2D` for the lantern, windows, porch, cave mouth, desk, roosts, visitors and placed lamps (`farm_projects.gd`); no `LightOccluder2D` anywhere |
| Ground | five 15-piece dual-grid tilesets drawn in `_draw_dual_ground` |
| Layout | `tools/farm_grid.txt` → `scripts/farm_layout.gd`; any change to the generated layout changes its version and resets every save's crops (`DESIGN.md`, Farm layout) |

[Observed] Locked rules in `DESIGN.md` → Art style (locked): chunky 16 px art, "one art pixel is always three screen pixels", whole-tile sizes, straight-on 3/4 view, **muted, desaturated palette**, **dark outlines on every sprite**, style anchor `house_chunky_b`, SpriteCook `pixel-engine-image-v1`.

[Observed] Owner decisions in `DECISIONS.md`: D-004 (straight-on square grid, not isometric), D-005 (VIS-001 lighting, approved), D-007 (keep 1080p stretch; no camera/stretch changes), D-008 (keep oak/crop saturation for now), D-009 (no farmhouse redraw before close-up comparisons).

## Summary table

| # | System | Class | Main cause of the gap | Owner approval needed? |
| --- | --- | --- | --- | --- |
| 1 | Camera angle and composition | D (angle), B (composition) | Camera rule; concept is oblique and shows ~2× more world | Yes for any camera change; no for composing within it |
| 2 | World and tile resolution | D | 16 px grid at 3× vs an apparently wider concept frame (uncalibrated estimate) | Yes, and a separate test plan |
| 3 | Pixel density and display scaling | D (exact reproduction); B/C (uncertain) for perceptual approximation | Locked 16 px, 1280×720 canvas, uneven 1080p stretch | Yes for any scale change |
| 4 | Asset detail and texture fidelity | B / C | Asset quality and clustering more than resolution | For production use |
| 5 | Ancient oak and major trees | B | Art (canvas, details) and composition | For production use |
| 6 | Farmhouse and architecture | C (redraw), B (dressing) | Art; D-009 gate | Yes (D-009) |
| 7 | Farm layout and landmarks | D | Layout change resets crops | Yes |
| 8 | Ground, paths and transitions | B (decor layer), D (grid paths) | Tile art variety; path shape is in the layout | Yes if the grid changes |
| 9 | Vegetation layers and density | B / C | Missing assets; composition | For production use |
| 10 | Day saturation and grade | A technically, D by rule | Grade values and the locked "muted" rule | Yes |
| 11 | Night ambient and lanterns | A / B (ambient, slice-tested only), D (light count) | Rendering values; lamps are earned in play | Not for a slice study; yes for production and for any new permanent light |
| 12 | Shadows, fog, weather, depth | B (fog/haze), C (cast shadows) | Rendering and composition | Yes for occluders |
| 13 | Characters | A / B | Mostly matches; concept costume differs | For production use |
| 14 | UI | B | Different frame style; concept UI is an example | Yes for a restyle |
| 15 | Performance and stability | Unknown (estimated low risk) | Not measured | — |

## 1. Camera angle and composition

1. **Concept target.** A high, oblique three-quarter view (02, 03, 04). Building fronts face the viewer, but plots, beds and paths are seen from above at an angle: garden beds in 02 read as slanted quadrilaterals, the road at the bottom runs diagonally. The whole homestead fits one frame, wrapped in forest. Image 01's homestead panels are closer to straight-on.
2. **Current game.** [Observed] Straight-on 3/4 top-down on a square grid, camera centred on the player, about 26.7×15 tiles in view at the base canvas.
3. **Difference.** The concept looks *down and across* a whole clearing; the game looks *straight down the column* at a quarter of it. The concept's diagonals (paths, bed rows, fences) become horizontals and verticals in the game.
4. **Root cause.** The camera rule (D-004, locked art) and the square gameplay grid. Not an asset problem.
5. **Type.** Technical and compositional.
6. **Ways to close it.**
   - a. Keep the camera; compose for it: diagonal and curving paths drawn across the grid, irregular forest edges, foreground overlap, landmarks staged so two or three share a screen.
   - b. Use the concept's oblique view only for non-gameplay presentation: title screen, chapter cards, the trailer, a "map" view in the diary.
   - c. Change the gameplay projection to oblique. This would touch movement, collisions, sorting, every sprite and the save layout.
7. **Cost.** a: low to moderate, mostly layout and art direction. b: moderate (one painted or composited scene per use). c: a rebuild of the game's visual foundation.
8. **Performance.** a, b: none measurable [Estimate]. c: unknown.
9. **Risks.** a: none to saves if done with decor only; layout moves carry the crop reset (system 7). c: very high.
10. **Compromise.** Under a, the game never shows the concept's oblique ground plane. See register C-01.
11. **Recommendation.** a for gameplay, plus b where a single beauty shot is wanted.
12. **Approval.** a: no (it is composition within the current rules), except where it needs layout changes. b: yes (new presentation scope). c: yes, and not recommended.

## 2. World and tile resolution

1. **Concept target.** Image 01's footer states "16×16 tiles, 16×32 characters". The farmer in 01 is about 25 screen px wide on a 1536 px image.
2. **Current game.** [Observed] 16×16 tiles, 16×32 farmer, 3 screen px per art px at the base canvas.
3. **Difference.** [Estimate — apparent field of view, **not calibrated world geometry**] Taking the farmer's on-image width as 16 art px: in 01 the farmer is about 25 px wide on a 1536 px image (≈1.6 px per art px, so a frame about 60 tiles wide); in 04 about 40 px on 1672 px (≈2.5 px per art px, about 42 tiles). The game shows 26.7. So the concept *appears* to frame roughly 1.6× to 2.2× more world per axis.
   - **Why this is only indicative:** the concept images are painted mockups with no pixel grid and no consistent scale; characters may be drawn larger or smaller than 16 art px; the oblique camera foreshortens depth, so a horizontal estimate says little about the vertical; and the two images disagree with each other by about 40%. These numbers must not be used to size the world, set a camera zoom or choose a canvas. A real comparison needs a calibrated test inside Godot (option c below), under its own approved plan.
4. **Root cause.** The game's 3× world scale on a 1280×720 canvas. The tile size itself matches.
5. **Type.** Technical (scale), with a large compositional effect: half the concept's richness is that so many landmarks share one view.
6. **Ways to close it.** b and c are **research options only**, not proposals to change the game; neither is a pending decision. Running either, even as an experiment, needs a separate test plan approved by the owner (D-007; this task's brief).
   - a. Keep 3×. Make each screen-sized area a complete composition (system 1a).
   - b. A 2× world scale (`SCALE = 2`): about 40×22.5 tiles in view. This is a camera/zoom change: it shows more of the farm at once (a gameplay change to what the player can see, including night threats) and makes every sprite two-thirds the size on screen.
   - c. A larger base canvas (for example 1920×1080 at 3×): about 40×22.5 tiles at 1080p, 3 px per art px, pixel-clean. It changes how much is visible in the same way as b, and every UI layout at the 1280×720 base would need checking.
7. **Cost.** a: none beyond composition. b, c: small code changes [Observed: `SCALE` is one constant and the canvas is a project setting], but a large review of UI, camera bounds, the minimap, capture tools, night visibility and trek pacing [Estimate: several days of testing].
8. **Performance.** b, c draw about 2.25× as many tiles and props per frame [Estimate, by area]. Likely fine on desktop; unmeasured.
9. **Risks.** b, c change what the player sees in the dark and how far threats are visible; sanity and the night's horror are tuned around the current view. Saves are unaffected.
10. **Compromise.** Under a, the game shows about a quarter to a half of the area the concept frames. See C-02.
11. **Recommendation.** a now. Whether wide framing matters enough to research is the owner's call; if it does, the first step is writing a test plan (isolated build or slice, matched captures, what is measured, how it is rolled back), not running a test.
12. **Approval.** b and c need an approved test plan before any experiment, and a separate approval before any change to the game (D-007).

## 3. Pixel density and display scaling

1. **Concept target.** Painterly pixel art: soft clusters, dense micro-detail (leaf by leaf, individual stones), on no consistent pixel grid.
2. **Current game.** [Observed] Chunky 16 px art at exactly 3× at 1280×720. At 1920×1080 the `canvas_items` stretch makes it 4.5 screen px per art px, so columns alternate 4 and 5 px (ART-002 FINDINGS).
3. **Difference.** The concept appears to carry more visible detail per screen area [Estimate, uncalibrated: the ≈1.6–2.5 vs 3 screen px per art px ratio from system 2 suggests roughly 1.5–3.5× more art pixels per area]. Its pixels are not all the same size.
4. **Root cause.** The locked "chunky 16 px, one art pixel is three screen pixels" rule, and the concept's own lack of a grid.
5. **Type.** Technical and artistic.

   **Exact reproduction vs perceptual approximation.**
   - *Exact reproduction* means matching the concept's image-space micro-detail pixel for pixel: soft, gridless gradients, sub-tile leaves and stones, mixed pixel sizes. With nearest filtering on a fixed 16 px grid at 3×, the game cannot show detail smaller than one art pixel or pixels of mixed sizes. That is a direct consequence of the locked rule and the filter, so exact reproduction is class **D** (it conflicts with the locked pixel scale), not a question of effort.
   - *Perceptual approximation* means that at normal play distance a viewer reads the same richness: dense litter, layered foliage, mossy materials, soft light. That is what matters to the player, and it has **not been tested** with art made for the purpose. Round 2 moved toward it at 16 px (litter, decals, layered forest), but its assets were first-pass. So it is classed **B/C (uncertain)**: plausible, unproven.
   - Earlier drafts classed the painterly finish E. That overstated it: no isolated test of the alternatives below has been run.
6. **Ways to close it** (all uncertain until tested).
   - a. Stay at 16 px; raise *perceived* richness with better clustering, more layered props, decals and lighting. ChatGPT's Round 1 review says the gap is "a composition/shape/lighting problem before a blanket 32px conversion". Untested at production quality.
   - b. Layered 16 px art: several overlapping sprites per object (canopy masses, separate leaf clumps, moss caps, litter over bases) so fine structure comes from layering rather than resolution. Untested.
   - c. 32 px source art for a few hero props on a 2560×1440 base canvas, so 32 px lands on exactly 3 px (ART-002's prerequisite test). Needs an approved test plan (scale change).
   - d. Integer-scaled viewport (`stretch/scale_mode = integer`) so 1080p shows a clean 4× or 3× with borders, removing the 4.5× unevenness without new art. Needs an approved test plan (D-007).
7. **Cost.** a, b: art and composition time. c: a canvas test, then a full art redo if adopted (ART-002: 76 farm PNGs, 56 player sheets). d: a settings test and a UI check.
8. **Performance.** a, b: more draw calls for decals, layers and props [Estimate: low]. c: 4× texture memory per asset, more fill [Estimate: fine on desktop]. d: none.
9. **Risks.** c contradicts the locked style and doubles asset cost. d changes the visible area at 1080p (D-007).
10. **Compromise.** Exact reproduction is given up (D). How much of the *perceived* richness 16 px can recover is an open question until a and b are tried in the slice. See C-03.
11. **Recommendation.** Test a and b in the slice first: they need no rule change. Treat c and d as research options; if the owner wants them, write a test plan for approval. Keep c parked unless a hero prop fails at 16 px after a fair try.
12. **Approval.** c and d: an approved test plan, then a decision (D-007, locked rule). a and b in the slice: no.

## 4. Asset detail and texture fidelity

1. **Concept target.** Every surface has material: shingles, plank grain, mossy stone, bark, leaf litter, wet soil.
2. **Current game.** [Observed in VIS-001 master] The production farm is mostly flat dark-green grass with sparse clutter (1 tile in 11), simple paths, and a house with clean planks. Round 2 [Observed] adds litter drifts, decals, cobbles and beds in the slice only.
3. **Difference.** Large by day. The production farm reads as empty ground with objects on it, where the concept is covered surface to surface.
4. **Root cause.** Mostly asset coverage and variety (too few tile variants, no decal layer in production, no material passes), not resolution [Judgement, supported by Round 2: adding decals and litter at 16 px visibly closed part of the gap in the same frame].
5. **Type.** Artistic, plus a little rendering (a decal/scatter layer).
6. **Ways to close it.** Grass variants picked by hash; a decal layer (leaves, twigs, pebbles, acorns) drawn under props; material passes on hero assets (moss on roofs and stone, bark texture). All at 16 px.
7. **Cost.** Moderate: 10–20 new small assets [Estimate] and a scatter function.
8. **Performance.** A few hundred extra `draw_texture_rect` calls in view [Estimate, from ~400 visible tiles]. Low, but measure (system 15).
9. **Risks.** Busy ground can hide crops, items, forage and the farmer. Keep the walkable path and interactables high-contrast (ART_DIRECTION.md, Readability).
10. **Compromise.** None needed beyond density at 16 px (C-03).
11. **Recommendation.** B: ground decals and variants first, because they lift every screen.
12. **Approval.** Not for slice work; yes for production art.

## 5. Ancient oak and major tree silhouettes

1. **Concept target.** The largest object on the farm (about as wide as the house), a broad asymmetric crown on gnarled horizontal limbs with gaps showing, a twisted trunk, a mass of roots over a ring of dark stones, red shelf fungus, hanging charms and bundles. At night it keeps an orange rim.
2. **Current game.** [Observed] Production: `prop_great_tree.png`, 128×128, drawn 8×8 tiles over a 3×3 blocking base, with canopy depth sorting (`_update_big_tree_depth`). Round 2: oak A, 192×144 (12×9 tiles), sprawling and branched, one charm, no fungus, crown clipped flat by the canvas top; a 160×64 stone ring that reads as a regular henge with a baked grass centre.
3. **Difference.** Oak A is close in silhouette and branching [Judgement]. It is missing the crown's top, fungus, the extra charms and the irregular stones; the ring's regularity is the biggest remaining mismatch.
4. **Root cause.** Art: the generation canvas was too short and the details weren't asked for. Composition: the ring was made as one flat sprite.
5. **Type.** Artistic and compositional. No technical limit: the engine already draws an over-size tree with a small collision base and depth sorting.
6. **Ways to close it.**
   - a. Regenerate oak A on a 192×192 canvas (12×12 tiles) from oak A itself as the init image, so the design holds and the crown has room.
   - b. Draw fungus and charms as separate small overlay sprites placed on the oak, so they can sway and be added or removed with story state.
   - c. Replace the flat ring with 6–10 separate irregular mossy boulders, each y-sorted, so the farmer can stand between them.
7. **Cost.** 3–6 generations plus cleanup [Estimate].
8. **Performance.** One larger texture and a dozen small sprites [Estimate: negligible].
9. **Risks.** A 12×12-tile canopy covers more of the farm; the existing walk-behind rule handles it. Blocking stays the 3×3 base. In production, the great tree's art size isn't part of the save; its *position* is in the layout (system 7).
10. **Compromise.** Silhouette detail at 16 px is coarser than the concept's (C-03), but the shape language can match.
11. **Recommendation.** a + b + c in Round 3 (plan step R3-2).
12. **Approval.** No for the slice; yes for production and for any move of the live tree.

## 6. Farmhouse and other architecture

1. **Concept target.** A cross-gabled timber house with a dark slate roof, stone chimney with smoke, lit windows, porch with steps, flower beds, pumpkins, barrels and stacked firewood; barn, coop and stall built in the same weathered vocabulary.
2. **Current game.** [Observed] SpriteCook house in four repair stages, 192×160, plain gable, clean straight-on front. Coop, barn, stall, workshop and outbuildings are SpriteCook sprites.
3. **Difference.** The concept's houses are more ornamented, more irregular and more "lived in"; the restoration stages in 01 (Abandoned → Restored) map well onto the game's four stages [Judgement].
4. **Root cause.** Mostly set dressing around the house, plus the house art's own simplicity.
5. **Type.** Artistic.
6. **Ways to close it.**
   - a. Dressing only: firewood stacks, barrels, flower beds, pumpkins, a chimney smoke particle, all as separate props around the existing house. Stage-aware (more as the house is restored).
   - b. Redraw the house stages with the concept's cross-gable and porch, keeping the 192×160 canvas and door alignment.
7. **Cost.** a: 6–10 props [Estimate]. b: four matched stage images, which were hard last time (the Boarded stage came out 11 px narrower; DESIGN.md).
8. **Performance.** Negligible.
9. **Risks.** b: door and step alignment with the collision footprint; consistency across four stages.
10. **Compromise.** If only a is done, the house silhouette stays simpler than the concept's. See C-06.
11. **Recommendation.** a first. b only after the D-009 close-up comparison the owner already asked for.
12. **Approval.** Yes for b (D-009). a: yes for production.

## 7. Farm layout and landmark placement

1. **Concept target.** A wheel of areas around a central oak (02): cave top-left, oak top-centre, house top-right, coop left, orchard centre-left, well at the centre, garden right, pond and dock lower-left, stall lower-right on a road.
2. **Current game.** [Observed] House top-centre, pond top-right, great tree lower-right, plots left, well centre, stall by the house (`BREAKDOWN.md` §2). `layout_blueprint.txt` proposes the concept's arrangement on the same 64×40 grid.
3. **Difference.** Most landmarks are in different places. The orchard, dock and road don't exist.
4. **Root cause.** The live layout predates the concept.
5. **Type.** Compositional, with a save consequence.
6. **Ways to close it.**
   - a. Migrate to the blueprint. [Observed] The layout version changes, so every save's crops, brush and felled trees reset and the player starts at the farm centre; money, skills, tools and animals are kept.
   - b. Migrate with a remapping step that moves planted crops plot-to-plot instead of resetting them (new save-migration code).
   - c. Keep the layout; borrow the concept's *composition* locally: dress each existing area to look like its concept counterpart.
7. **Cost.** a: a grid edit and testing [Estimate: 1–2 days with save, menu and balance tests]. b: a + migration code and tests [Estimate: +1–2 days]. c: art time only.
8. **Performance.** None.
9. **Risks.** a resets crops in real saves (slots 1–3 belong to the owner). b reduces that but adds migration risk. Both change walk distances and chore routes, which affects the balance sim's chore times.
10. **Compromise.** c gives up the concept's map-level composition. See C-08.
11. **Recommendation.** Decide this **before** heavy production art, because many assets (paths, beds, oak ring) are placed by the layout. If migrating, prefer b.
12. **Approval.** Yes, in its own task (ChatGPT's review: "No approval for layout migration").

## 8. Ground textures, paths and transitions

1. **Concept target.** Olive grass under drifts of orange leaves; brown paths that wind with soft, worn, irregular edges, grass creeping in; cobbles around the well; raised edges at the pond.
2. **Current game.** [Observed] Production: dual-grid grass, path, soil, fallow and water, one frame per mask; straight grid paths. Round 2: litter drifts, decals, a cobble landing; the base grass still repeats its speck; path edges still step in blocks; a grass seam where cobbles meet path.
3. **Difference.** Repetition, blockiness, and straight paths.
4. **Root cause.** One frame per dual-grid mask (no variants), and paths stored in the gameplay grid.
5. **Type.** Artistic and technical (renderer picks only one frame per mask).
6. **Ways to close it.**
   - a. Two or three variants per dual-grid mask, chosen by tile hash (renderer change in `_draw_dual_ground`; tileset art).
   - b. Path verges: a decal band along path edges (grass tufts, leaves, pebbles) that breaks the stepped outline without changing tiles.
   - c. A decorative "worn path" overlay drawn over grass where the grid has none, giving curves without touching the layout. It is walkable anyway (grass is walkable).
   - d. Change path tiles in `farm_grid.txt` for real curves (layout change, system 7).
7. **Cost.** a: 2–3× the ground tile art plus a small renderer change [Estimate]. b, c: decal art and a placement list. d: see system 7.
8. **Performance.** Same draw count for a; more for b and c [Estimate: low].
9. **Risks.** c can blur where the "real" path is, which matters for the trek and for the dog/visitor logic that uses path tiles; on the farm, path tiles have no rule weight beyond drawing and walkability [to verify in code before production].
10. **Compromise.** Grid paths stay grid paths under the decor; edges soften but turns are still 90° or stepped diagonals. See C-09.
11. **Recommendation.** a + b now (plan R3-3); c in the slice to test whether curves read; d only with the layout task.
12. **Approval.** No for the slice; yes for production; yes for d.

## 9. Vegetation layering and environmental density

1. **Concept target.** Four layers: canopy (firs, red and orange maples, the oak), understorey (vine maple, huckleberry, gold shrubs), ground cover (sword ferns, dry grass, reeds), litter. Plants crowd every base. In 04: mossy logs with fungus, roots across the path, puddles, a waterfall.
2. **Current game.** [Observed] Production: a fixed band of SpriteCook trees, thin inside, a few brush and thicket piles. Round 2: near/mid/far firs and maples, undergrowth clumps, rocks, a shade layer and haze; no logs, roots or separate ferns.
3. **Difference.** Missing understorey and ground cover in production; Round 2 still thinner than the concept and its undergrowth clump repeats.
4. **Root cause.** Missing assets and placement; no foreground layer over the player in production borders.
5. **Type.** Artistic and compositional.
6. **Ways to close it.** New small plant assets (ferns, shrubs, reeds, logs, roots) in strips so they match; placement by hash on non-walkable border tiles; a foreground row (canopy tips, tall grass) drawn over the player along the bottom and side edges; y-sorting already exists for trees.
7. **Cost.** 10–15 assets [Estimate], placement code.
8. **Performance.** More sprites in view at borders [Estimate: low; measure].
9. **Risks.** Foreground over the player at the screen edge can hide the farmer, forage and threats. Keep foreground to tiles the player can't reach, and fade it when the player is behind (as the oak canopy does).
10. **Compromise.** Density near walkable tiles must stay lower than the concept's so items and the farmer stay readable. See C-10.
11. **Recommendation.** Do composition first with existing assets (re-tinted, re-placed), then add the few assets the composition proves it needs (plan R3-5).
12. **Approval.** No for the slice; yes for production.

## 10. Daytime saturation and colour grading

1. **Concept target.** Warm, vivid autumn: oranges, ambers, reds against deep fir green and olive grass. Image 01's footer: "Warm and inviting by day".
2. **Current game.** [Observed] Grade saturation 0.62, exposure 0.84, heavy vignette; `GRASS_TINT` darkens grass further. `DESIGN.md` describes the intent as "a grim, overcast mood".
3. **Difference.** [Judgement, VIS-001 and Round 2 masters] The game's day is brown-green and dim; the concept's is bright and warm. Round 2's day is closer only because its art is warmer.
4. **Root cause.** The grade values and the locked rule "Muted, desaturated palette". The art itself can carry more colour than the grade lets through.
5. **Type.** Technical values (A) set by an artistic rule (D).
6. **Ways to close it.**
   - a. Lift the grade toward the concept (for example saturation 0.62→0.8, exposure 0.84→0.95, lighter vignette) [values are starting guesses to test, not recommendations].
   - b. A seasonal grade: warmer and richer in autumn, greyer in late autumn and winter, so the "grim" mood is earned by season and story rather than always on.
   - c. Keep the grade; recolour art warmer.
7. **Cost.** a, b: a few uniforms and a capture set. c: art time, and it fights the grade.
8. **Performance.** None.
9. **Risks.** The low-sanity cold tint (`SANITY_COLD`, `SANITY_TINT`) is built on the grade; it must still read as colder. The HUD isn't graded, so no UI risk.
10. **Compromise.** If the owner keeps "muted, desaturated", the game's day will stay visibly less vivid than the concept. See C-04.
11. **Recommendation.** Test a and b as a matched capture comparison (grade only, art unchanged), as SLICE.md and ChatGPT both proposed. This is the cheapest large day-time change.
12. **Approval.** Yes: it changes the locked palette rule and D-008's "do not recolor now".

## 11. Nighttime ambient illumination and lantern lighting

1. **Concept target.** Image 03: the whole scene drops to blue-grey but stays readable; warm light survives only at sources (windows, a lantern on every post, the cave mouth, the farmer's lantern), moonlight on water, an orange rim on the oak, a red glow at the edge for the Hollow. Image 01: "Unsettling and oppressive by night".
2. **Current game.** [Observed] `NIGHT_TINT` `3a3f6e` with the VIS-001 stepped lights. Round 2 preview: sky tint `7382ae` and a softer grade, set only in the slice tool.
3. **Difference.** [Measured, ROUND2.md, 1280×720, whole frame of the slice capture including the HUD; one frame per render] mean luma: concept 03 crop 0.200; Round 1 night 0.030; Round 2 art at game night 0.030; Round 2 preview 0.114. Pixels above luma 0.12: 69% / 5% / 4% / 31%. Forest-edge columns in the preview: 0.058.
   - **Caveat:** these are diagnostic readings of single, unmatched frames. The concept crop and the slice show different scenes with different numbers and positions of lights; the game frames include the HUD; the lantern pool alone moves the mean. They show the *direction and rough size* of the gap, not a target to hit.
4. **Root cause.** Rendering values (tint, grade) — not art. Round 2 showed new art doesn't change the game-night reading (0.030 either way). Separately, the concept's *number* of lights is far above the game's: placed lamps are earned through homestead projects.
5. **Type.** Technical (A/B) for ambient, but only demonstrated in the slice so far; gameplay (D) for the number of lights.
6. **Ways to close it.**
   - a. **Slice study first:** tune the night tint and grade in the slice tool only (as Round 2's preview does), check it against the method below, and present it for review. No game file changes.
   - b. **Production integration, later and separately:** move the accepted treatment into `_sky_tint()` / `NIGHT_TINT` and the night grade behind a flag, leaving `darkness` (sanity, lamps, events) untouched. Needs its own owner approval after a is reviewed.
   - c. Moonlight on the pond, as a water shader or a light, *tested in the slice*.
   - d. Landmark lights at the oak or well. **Not recommended at present.** A permanent light adds a safe, warm spot the player didn't earn, which works against earned lamps (DESIGN.md, Homestead projects) and the night's rising threat. Before even a slice test, check: which lamps the player has by which day; whether any night rule reads light or lamp positions (visitors, sanity relief, the field shadow); and how a landmark light changes early nights versus late ones. Consider non-light alternatives first: value contrast in the art, a cool moon rim from the ambient, emissive fungus or charms that read as eerie rather than safe.
   - e. More lamp posts from the start, as in 03 (changes the homestead project ladder). Gameplay change.
7. **Cost.** a: the slice tool already does it; captures across scenarios [Estimate: half a day]. b: small code plus a full scenario sweep [Estimate: 1 day]. c: small. d: design check first. e: design work.
8. **Performance.** a, b: none. c, d: one to a few more lights each. [To verify] The Compatibility renderer limits how many 2D lights can touch one canvas item, and much of the farm is drawn by `main.gd`'s own `_draw` onto few canvas items. Before adding lights, check the limit and its project setting in Godot 4.7 and count the lights that can overlap the farm at once (lantern, windows, porch, lamps, visitors).
9. **Risks.** A brighter night can weaken the horror. The preview kept forest edges dark on purpose. The trek has its own tint built on the same values; the cave and interiors must not brighten. Extra permanent lights undercut earned lamps (d).
10. **Compromise.** The preview reads darker than the concept. Matching the concept's brightness would need its many lights, which conflicts with earned lamps. See C-05 and C-07.
11. **Recommendation.** a in Round 3 (slice only), judged visually and by the play checks below, with the luma readings as supporting diagnostics. c in the slice if it doesn't add a safe zone. b only after a is reviewed and the owner approves integration. d and e not without the owner's explicit approval and the compatibility check above. This is the brief's priority 1 and is pure rendering, so no new art.
12. **Approval.** a and c in the slice: within Round 3's authorization. b: separate explicit owner approval (outside D-005's four approved items). d, e: explicit owner approval after the compatibility check.

### Night measurement method (diagnostic, not an acceptance test)

Numbers support the visual review; they never pass or fail a night on their own. Optimising a frame's average brightness is not the goal.

- **Matched capture.** Same slice, tile, player position, hour (21:30, and 23:30), weather, season, lantern tier, house stage and placed lamps in every render compared. Capture at 1280×720, HUD hidden or masked. Record the commit, flag and tint/grade values.
- **Regions, measured separately** (fixed masks drawn once on the slice and reused every round):
  1. *Lantern pool* — a circle of the lantern's radius around the farmer.
  2. *Play area* — walkable tiles outside the lantern pool (path, open ground, garden).
  3. *Landmark* — the oak's sprite bounds.
  4. *Forest edge* — non-walkable border tiles.
  5. *Whole frame* — for continuity with Round 2's numbers only.
- **Measures per region.** Mean luma (Rec. 709 weights, after the grade); 10th and 90th percentile luma; share of pixels above 0.12. Report the concept only as a *reference reading* of a crop with similar content (oak, path, garden, forest edge) and say what differs (lights, camera, scale).
- **Expected relationships, provisional** (to be revisited after the first visual review): play area clearly above Round 1's game night; forest edge darker than the play area; lantern pool clearly brightest; landmark legible against the forest. Earlier figures (play-area mean about 0.11–0.15, forest edge under about 0.07) are a starting point to compare against, not targets.
- **Visual assessment (required).** Concept / Round 2 / proposal side by side at game scale, judged for mood (still threatening?), depth, warm points and colour, by ChatGPT and the owner.
- **Gameplay readability checks (required, in the slice with the farmer moving):**
  - Walk the path from one edge of the slice to the other without the lantern pool and without leaving the path.
  - Pick out the garden rows, a forage item and a dropped item outside the lantern pool.
  - See a night visitor or the field shadow at the forest edge, and judge whether it still startles.
  - Confirm low sanity still reads colder than a normal night, and the cave and trek don't brighten.
  - Record a short motion clip (`review_motion.ps1`) for the walk.

## 12. Shadows, fog, weather and atmospheric depth

1. **Concept target.** Fog in the corners and between far trees (02, 04); soft contact shading under objects; no strong cast shadows by day; deep dark forest interiors (04).
2. **Current game.** [Observed] Soft ground shadows under trees, rocks and brush; fog wisps (`weather_fog`) as weather only; clouds as passing shadows; no occluders. Round 2 adds a shade layer over the forest interior and a thin haze over far rows.
3. **Difference.** No standing fog in normal weather; forest depth is flat in production.
4. **Root cause.** Rendering and composition.
5. **Type.** Technical and compositional.
6. **Ways to close it.**
   - a. Edge fog: a few slow fog sprites anchored to forest edges (reusing `weather_fog`), always on in autumn evenings, stronger in fog weather.
   - b. Distance shade and haze at forest borders, as Round 2's shade layer (a darkened, cooler tint on far tree rows).
   - c. `LightOccluder2D` cast shadows from the lantern. Gives dramatic night shadows but needs occluder polygons per prop, and VIS-001 left occluder shadows unapproved.
7. **Cost.** a, b: small. c: large (polygons for every prop) and more fill per light [Estimate].
8. **Performance.** a, b: low. c: noticeable with several lights [Estimate; Compatibility renderer shadows are costlier].
9. **Risks.** Fog can hide interactables and threats; keep it off walkable centres.
10. **Compromise.** No cast shadows, matching the concept's soft daytime look. None needed.
11. **Recommendation.** a + b (plan R3-5). Leave c parked.
12. **Approval.** Production: yes. c: yes.

## 13. Character proportions and animation readability

1. **Concept target.** 16×32 characters (01 footer). In 04 the farmer wears a coat, wide hat and pack and carries a lantern; Maren is a stooped elder with a shawl and cane.
2. **Current game.** [Observed] SpriteCook farmer, 16×32, straw hat, rust shirt, blue overalls, 8-frame cycles and tool sheets; the trek escort is in the game.
3. **Difference.** Proportions match. Costume differs (straw hat and overalls vs trek coat). The concept's characters have softer, painterly shading.
4. **Root cause.** Art direction choice, not technical.
5. **Type.** Artistic.
6. **Ways to close it.** Keep the farmer; optionally a trek outfit later. Keep the farmer's outline and value contrast high so they read on the richer ground.
7. **Cost.** A new outfit means redoing every sheet (56 player sheets) [Observed count, ART-002].
8. **Performance.** None.
9. **Risks.** Animation consistency is the hardest part of player art (ART-002).
10. **Compromise.** None proposed. The concept costume is noted, not adopted.
11. **Recommendation.** No change. Add a readability check for the farmer on every new ground set (rubric).
12. **Approval.** Yes for any outfit change.

## 14. UI consistency with the concept

1. **Concept target.** Image 01 "Key UI & Systems (Example)": brass-framed clock and coin plates, three thin bars with icons, a wooden hotbar with item icons. Image 04: a lantern-oil meter with a brass lantern, an escort portrait with nerve diamonds, a three-slot quick bar. Parchment banners.
2. **Current game.** [Observed] One SpriteCook kit: dark wood frames, iron corner brackets, gold selected edge; meters as kit bars.
3. **Difference.** Similar materials (wood, metal); the concept uses more brass and parchment, rounder plates and larger icons.
4. **Root cause.** Art direction; the concept labels its UI an example.
5. **Type.** Artistic.
6. **Ways to close it.** Leave the kit; borrow the concept's lantern-oil and nerve widgets for the trek HUD when that is next touched; brass accents in the kit.
7. **Cost.** Moderate for a kit revision; `menu_test.gd` covers regressions.
8. **Performance.** None.
9. **Risks.** UI readability and controller focus (menu tests).
10. **Compromise.** None required.
11. **Recommendation.** Out of scope for Round 3. Note for a future UI task.
12. **Approval.** Yes for any restyle.

## 15. Performance and rendering stability

1. **Concept target.** n/a — the concept is a still.
2. **Current game.** [Observed] Compatibility renderer, CPU particles kept small, most of the farm drawn in `_draw` with `draw_texture_rect`. No profiling numbers are recorded in the repo for the farm at night.
3. **Difference.** Unknown: nothing has been measured.
4. **Root cause.** n/a.
5. **Type.** Technical.
6. **Plan.** Add frame-time and draw-call capture to the Round 3 slice tool (`Performance.get_monitor` for FPS, process time, draw calls and objects), and record numbers before and after each Round 3 step at 1280×720 and 1920×1080. Check the per-item 2D light limit before adding lights.
7. **Cost.** Small.
8. **Expected implications.** [Estimate] Decals and vegetation: a few hundred more draws per frame, low. Extra lights: depends on the light limit and overlap. Shaders: one more full-screen pass at most.
9. **Risks.** Unmeasured claims; Round 3 must not state performance results it didn't measure.
10. **Compromise.** None yet.
11. **Recommendation.** Measure first (plan R3-0).
12. **Approval.** No.

---

## Concept Fidelity Compromises Requiring Owner Approval

Every entry is **PROPOSED — NOT APPROVED** until the owner approves it, and is recorded in `DECISIONS.md` when they do. Existing implementation choices are listed here too; they are not treated as already-approved artistic compromises.

### C-01 — Straight-on camera instead of the concept's oblique view
- **Concept:** a high oblique view; ground planes, beds and roads seen at an angle.
- **Game would show:** straight-on 3/4; beds and plots as rectangles, paths on the grid.
- **Why exact translation is hard:** the square gameplay grid, sorting, collisions and every sprite assume straight-on (D-004).
- **Quality lost:** the sense of looking across a whole valley; diagonal energy in the composition.
- **Constraint:** D-004, locked art (straight-on), gameplay grid.
- **Alternatives:** compose within the camera (diagonal decor, curving overlays); oblique views for title/menus/trailer only; a full projection change (not recommended).
- **Effort and risk:** low for composition; very high for a projection change.
- **Recommendation:** keep the camera; use oblique art only for presentation.
- **Status:** PROPOSED — NOT APPROVED.

### C-02 — Less world per screen than the concept frames
- **Concept:** appears to frame about 42–60 tiles across [Estimate from character widths; uncalibrated, not world geometry].
- **Game would show:** about 26.7×15 tiles at the base canvas.
- **Why hard:** `SCALE = 3` at 1280×720; a wider view changes what the player sees (D-007).
- **Quality lost:** several landmarks sharing a view; the "whole homestead" feeling in play.
- **Constraint:** D-007, locked 3× rule.
- **Alternatives:** compose each screen as a vignette. Research options only, each needing an approved test plan before any experiment: a 1920×1080 base at 3×; a 2× scale; integer scaling.
- **Effort and risk:** low / moderate per test; the gameplay risk is night visibility.
- **Recommendation:** compose for 3× now. If wide framing matters to the owner, the next step is a test plan for approval, not a test.
- **Status:** PROPOSED — NOT APPROVED.

### C-03 — Chunky 16 px clusters instead of painterly micro-detail
- **Concept:** painterly, gridless detail: individual leaves, stones, shingles.
- **Game would show:** 16 px art at 3×; detail carried by clusters, layering and decals.
- **Why hard:** exact reproduction of gridless, sub-pixel detail conflicts with the locked 16 px rule and nearest filtering (D). Whether a *perceptual* approximation can get close is untested (uncertain), not impossible.
- **Quality lost:** certainly the concept's exact image-space micro-detail and mixed pixel sizes. Possibly some fine texture and silhouette nuance at play distance — unknown until layered 16 px art is tried.
- **Constraint:** locked art style; display scale (ART-002).
- **Alternatives:** better 16 px clusters and layering, tested in the slice (uncertain); 32 px hero art on a 2560×1440 canvas (research option, needs a test plan); integer scaling to remove the 4.5× unevenness at 1080p (research option, needs a test plan).
- **Effort and risk:** low–moderate / high / low.
- **Recommendation:** accept that exact reproduction isn't the goal; test layered 16 px approximation in the slice before deciding how much is lost.
- **Status:** PROPOSED — NOT APPROVED.

### C-04 — Daytime colour under the "muted, desaturated" rule
- **Concept:** warm, vivid autumn by day.
- **Game would show (if the rule stays):** brown-green, dim day, saturation 0.62, exposure 0.84.
- **Why hard:** not technically hard; it's a rule.
- **Quality lost:** the "warm and inviting by day" contrast with night, which the concept's footer states as the tone.
- **Constraint:** locked palette rule; D-008.
- **Alternatives:** lift the grade; a seasonal grade; recolour art under the current grade.
- **Effort and risk:** low; risk to the low-sanity tint, which must still read colder.
- **Recommendation:** run a grade-only matched comparison, then decide whether to relax the rule for autumn days.
- **Status:** PROPOSED — NOT APPROVED.

### C-05 — Night darker than the concept
- **Concept:** readable blue-grey night (a whole-crop diagnostic reading of 03 gave mean luma 0.200; unmatched to any game frame).
- **Game would show:** something like the Round 2 preview, which reads darker than the concept. Its exact level is to be settled visually and by play checks, with region measurements as diagnostics (system 11, "Night measurement method").
- **Why hard:** the concept is lit by many more lights; brighter ambient alone washes out the horror.
- **Quality lost:** some mid-ground visibility at night.
- **Constraint:** horror tone (DESIGN.md Pillars, Sanity), earned lamps.
- **Alternatives:** brighten with ambient only (risks flat, unthreatening nights); add lamps (C-07); stay near the preview.
- **Effort and risk:** low effort; tone risk either way.
- **Recommendation:** stay near the preview in a slice study; recover points of interest with value contrast and moonlight before considering any new light.
- **Status:** PROPOSED — NOT APPROVED.

### C-06 — House dressing before (or instead of) a house redraw
- **Concept:** cross-gabled, ornamented farmhouse with a stone chimney and smoke.
- **Game would show:** today's plain-gable house, dressed with props; the silhouette stays simpler.
- **Why hard:** four matched repair stages on one canvas with a fixed door; D-009.
- **Quality lost:** the concept's roofline and porch silhouette.
- **Constraint:** D-009; stage consistency.
- **Alternatives:** dressing only; redraw all four stages after the close-up comparison.
- **Effort and risk:** low / high.
- **Recommendation:** dressing now; redraw decision after D-009's comparison.
- **Status:** PROPOSED — NOT APPROVED.

### C-07 — Lamp posts earned in play, not everywhere from day one
- **Concept:** a lantern post on every corner of the night farm.
- **Game would show:** only the lamps the player has built, plus house, porch and cave lights.
- **Why hard:** lamps are part of the homestead project ladder and of how the night gets safer.
- **Quality lost:** early-game nights have fewer warm points than image 03.
- **Constraint:** gameplay progression (DESIGN.md, Homestead projects).
- **Alternatives:** keep earned lamps; fixed lights at landmarks (oak, well, pond) from the start; start with more lamps (changes progression).
- **Effort and risk:** low effort; the second and third options carry progression and horror risk: an unearned warm spot is a safe zone the night's threat has to work around.
- **Recommendation:** keep earned lamps only. No permanent landmark lights unless the owner explicitly approves them after a compatibility check (lamp progression by day, night rules that read lights or lamp positions, early vs late nights). Try non-light ways to keep landmarks legible first.
- **Status:** PROPOSED — NOT APPROVED.

### C-08 — Keeping the current farm layout
- **Concept:** a wheel around a central oak with an orchard, dock and road.
- **Game would show (if kept):** today's layout, dressed to look like the concept area by area.
- **Why hard:** a layout change resets every save's crops.
- **Quality lost:** the concept's map-level composition and the road and orchard.
- **Constraint:** save compatibility; balance (walk distances).
- **Alternatives:** keep; migrate with a crop reset; migrate with crop remapping.
- **Effort and risk:** none / moderate with save impact / moderate–high engineering.
- **Recommendation:** decide before production art; if migrating, remap crops.
- **Status:** PROPOSED — NOT APPROVED.

### C-09 — Grid paths softened by decor instead of true curves
- **Concept:** winding paths with organic edges.
- **Game would show:** grid paths with variant edges, verge decals and optional decorative worn-path overlays.
- **Why hard:** paths live in the gameplay grid; changing them is a layout change.
- **Quality lost:** smooth curves; turns stay stepped.
- **Constraint:** layout versioning (C-08).
- **Alternatives:** decor only; decorative overlays; real grid curves with the layout task.
- **Effort and risk:** low / low / see C-08.
- **Recommendation:** decor and overlays now; real curves only with a layout migration.
- **Status:** PROPOSED — NOT APPROVED.

### C-10 — Lower vegetation density near walkable tiles
- **Concept:** plants crowd every base; foreground layers overlap the view.
- **Game would show:** concept density on non-walkable borders, thinner near paths, plots and interactables; foreground only where the player can't go.
- **Why hard:** readability of the farmer, crops, forage, items and threats.
- **Quality lost:** some lushness in the play area.
- **Constraint:** gameplay readability.
- **Alternatives:** full density with fade-on-overlap; thinner density; density by zone.
- **Effort and risk:** low–moderate; readability risk for full density.
- **Recommendation:** density by zone, with fade-on-overlap at the edges.
- **Status:** PROPOSED — NOT APPROVED.

### C-11 — Outlines: "dark outlines on every sprite" vs the concept's selective outlines
- **Concept:** dark-brown, selective outlines; many shapes defined by value alone.
- **Game would show (if the rule stays):** a bold dark outline on every sprite.
- **Why hard:** a rule, and a readability tool: ART-001 found outlines are what keep sprites readable at night.
- **Quality lost:** the concept's softer, more painterly read.
- **Constraint:** locked art rule; night readability.
- **Alternatives:** keep full outlines; selective outlines for ground cover and background trees only, full outlines on interactables and characters; selective everywhere.
- **Effort and risk:** none / moderate (art direction per asset class) / night-readability risk.
- **Recommendation:** the middle option, tested in the slice.
- **Status:** PROPOSED — NOT APPROVED.

### C-12 — Mixed asset sources
- **Concept:** one consistent painterly style.
- **Game would show:** SpriteCook production art (anchored on `house_chunky_b`) next to PixelLab prototypes (anchored on the concept palette) until one pipeline is chosen.
- **Why hard:** the locked rule names SpriteCook and its style anchor; the ART-003 family came from PixelLab; the two don't match (ART-001).
- **Quality lost:** consistency, if mixed.
- **Constraint:** locked generation rule; CLAUDE.md sprite pipeline.
- **Alternatives:** stay SpriteCook with a new concept-derived style anchor; move to PixelLab for environment art; mix by asset class with a shared palette.
- **Effort and risk:** each needs a fair test of the other tool's best tier (ART-001 tested only PixelLab's cheapest).
- **Recommendation:** decide the pipeline and the style anchor before production art.
- **Status:** PROPOSED — NOT APPROVED.

### C-13 — Trek forest density (image 04)
- **Concept:** a dense, layered old-growth trail with roots, logs, puddles, a waterfall and fog.
- **Game would show:** today's trek clearings laid into the cave grid, darker and sparser.
- **Why hard:** not assessed in ART-003; the trek has its own tint, lighting and layout code.
- **Quality lost:** most of image 04's richness.
- **Constraint:** none locked; scope.
- **Alternatives:** reuse the farm's Round 3 vegetation set in a trek slice; leave for a later task.
- **Effort and risk:** moderate; separate task.
- **Recommendation:** a separate trek study after the farm set settles.
- **Status:** PROPOSED — NOT APPROVED.

---

## Consistency check against DESIGN.md and owner decisions

Contradictions found (the owner decides each; none is resolved here):

1. **Palette.** The brief's "warm, vivid autumn" and the concept contradict `DESIGN.md`'s locked "muted, desaturated palette" and "grim, overcast mood" (C-04).
2. **Outlines.** The concept's selective outlines contradict "dark outlines on every sprite" (C-11).
3. **Pixel scale.** The concept's ≈1.6–2.5 screen px per art px contradicts "one art pixel is always three screen pixels"; and at 1080p the game already breaks it (4.5×) under D-007 (C-02, C-03).
4. **Generation pipeline.** The brief says "Use PixelLab only when new artwork is genuinely required", while `DESIGN.md` and `CLAUDE.md` name SpriteCook `pixel-engine-image-v1` with the `house_chunky_b` anchor. ART-003 used PixelLab with a concept palette. The locked anchor itself predates the concept and may not match it (C-12).
5. **Light count.** The concept's lamp-on-every-post night conflicts with earned lamps (C-07).
6. **Layout.** The concept's layout conflicts with the live layout and its save behaviour (C-08).
7. **Root-level art bible.** A new `ART_DIRECTION.md` could compete with `DESIGN.md` as source of truth (D-001). It is written as subordinate and proposed until the owner says otherwise.

Assumptions and unsupported claims to flag:
- Framing and pixel-size estimates come from character widths in AI images that have no true grid. They are apparent field of view, not calibrated geometry.
- Night luma figures are single-frame, unmatched diagnostics.
- "Perceptual approximation at 16 px" is untested either way.
- The Compatibility renderer's per-item 2D light limit is from general Godot knowledge and must be checked in 4.7 before relying on it.
- Performance statements are estimates; nothing was profiled.
- Round 2 directions (oak A, the night preview) are the owner's stated preferences in this task's brief. ChatGPT reviewed the Round 2 master sheets at image level when the owner attached them in conversation; its independent score (57.75/100) is recorded on the board in its ART-004 entry (commit `0121d1d`).
- The concept's species and plant names (huckleberry, vine maple, sword fern) are read from the images, not stated by the owner.

## Before any implementation

Checked 2026-11-02 on `main` at `0121d1d` plus the uncommitted working tree:

- **Uncommitted work present:** `scripts/trek_system.gd` (+127 lines, the VIS-002 trek work, including the earlier one-line type fix at the `var t: Vector2i` loop), `scripts/main.gd` (+28/−10), `shaders/grade.gdshader` (+3), `project.godot`, `scenes/main.tscn`, and `.uid`/`.import` churn. None of it belongs to ART-004, and none of it was changed.
- **Protected, without touching the working tree:** a snapshot stash entry (`ART-004 snapshot: uncommitted VIS-002 trek/lighting work`, made with `git stash create` + `git stash store`, so the files stay as they are) and a patch file, `builds/wip_backup/2026-11-02_working_tree.patch` (gitignored; SHA-256 `f52e5ae0…2f45e72f`).
- **Build status of the working tree:** Godot loads it headless with no script or parse errors. `tools/save_test.gd`: 0 failures. `tools/menu_test.gd`: 752 PASS lines, 0 failures. Logs in `builds/wip_backup/`. `balance_sim.gd` and visual captures were not run.
- **Rule for future implementation:** re-run this check first. Production changes must not be built on top of, mixed into, or discard the uncommitted VIS-002 work; whoever owns it decides whether to commit it first. A slice tool that is rendered from a clean checkout (as Rounds 1–2 were) must say which commit it used.
