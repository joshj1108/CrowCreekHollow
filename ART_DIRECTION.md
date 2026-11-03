# Crow Creek Hollow — Art direction (proposed)

**Status: PROPOSED — NOT APPROVED.** Task ART-004, drafted by Claude Code on 2026-11-02 for ChatGPT's review and the owner's decision.

`DESIGN.md` stays the source of truth (D-001). Its "Art style (locked)" section wins wherever this document disagrees; every such disagreement is marked **⚠ conflicts with the locked spec** below and listed in `AI_COLLAB/CONCEPT_FIDELITY_FEASIBILITY.md`. Nothing here changes the game, the camera, the scale, saves or production art. When the owner approves parts of it, they move into `DESIGN.md` and the decision goes in `AI_COLLAB/DECISIONS.md`.

Related: `AI_COLLAB/ART_REVIEW_RUBRIC.md` (scoring and gates), `AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md` (how images are handed over), `art/style_tests/ART-003/BREAKDOWN.md` (the full reading of the concept images).

## 1. The target

The owner's four concept images in `art/reference/concept/` are the visual target:

| Image | Use it for |
| --- | --- |
| `01_overview` | Day/night contrast on the homestead, the trek's mood, the house's four repair stages, the seasons, UI ideas. Footer: "Warm and inviting by day • Unsettling and oppressive by night". |
| `02_autumn_homestead` | The farm by day: layout, materials, vegetation layers, palette. |
| `03_night_homestead` | The farm by night: ambient level, warm points, the Hollow's red edge. |
| `04_rookery_escort` | The trek: old-growth forest density, the trail, lantern light, fog. |

The aim is that the playable game *resembles* these images in composition, richness, architecture, lighting and mood. It is not to copy them pixel for pixel: they are painterly mockups drawn from a higher camera than the game's. Where the game can't match them, the compromise is written down and approved, never assumed (`CONCEPT_FIDELITY_FEASIBILITY.md`, "Concept Fidelity Compromises Requiring Owner Approval").

## 2. Visual identity

- **A handmade, lived-in homestead in a Pacific Northwest autumn.** Weathered timber, moss on stone and shingle, split-rail fences, stacked firewood, barrels and lanterns on posts. Nothing new, nothing perfectly straight.
- **Ancient, twisted trees.** The great oak is the farm's centrepiece and its strangest object: broad and asymmetric, limbs you can see between the leaves, roots over dark stones, fungus, hanging charms.
- **Layered forest.** Deep blue-green firs, red and orange maples, understorey, ferns and litter. The forest wraps the clearing; its edge is irregular and bites inward.
- **Two faces.** By day, beautiful and welcoming. By night, readable blue-grey with small pools of amber light, and a forest that feels like it's watching. The horror comes from lighting, fog, silhouettes and restraint, not gore (`DESIGN.md`).
- **Readability first.** However rich the scene, the farmer, the path, crops, items, interactables and threats must read at a glance.

## 3. Camera, grid and composition

- **Fixed:** square 16×16 gameplay grid, straight-on 3/4 top-down view, the current camera and `SCALE = 3` (D-004, D-007, locked spec). No isometric, no oblique projection in play.
- The concept's higher, wider view can't be used in play (C-01, C-02). Compose for the game's camera instead:
  - **Each screen is a picture.** At about 27×15 tiles per screen, stage areas so that a landmark, a path and a forest edge share most views.
  - **Diagonals by decoration.** Paths, litter drifts, roots and fences carry the concept's diagonal flow across the square grid.
  - **Irregular edges.** No straight forest walls; trees step in and out by one to three tiles.
  - **Overlap for depth.** Canopy over paths, foreground grass and branch tips along the bottom and sides, trunks in front of fences.
  - **Frame the light.** Dark forest frame, lighter centre — by day through value, by night through ambient and light placement.
- Oblique concept-style art is welcome **outside play** (title, chapter cards, trailer), with owner approval.

## 4. Pixel art rules

Locked today (`DESIGN.md`):
- 16 px per tile, shown at 3×; one art pixel is three screen pixels; never resample.
- Sizes are whole tiles; characters 16×32; buildings and props in multiples of 16 where they can be.
- Dark outlines on every sprite. **⚠ The concept uses selective dark-brown outlines (C-11).** Proposed: full outlines on characters, interactables and anything that must read at night; selective outlines allowed on ground cover, litter and background trees. Not adopted until approved.

Proposed craft rules (no conflict):
- **Clusters, not noise.** Readable clumps of 2–6 pixels; avoid single-pixel speckle (the ART-001 fir failed on this).
- **Light from the top left**, soft; forms shaded but no strong cast shadows by day.
- **No baked backgrounds.** No grass discs or ground under props; contact shading goes on a separate shadow pass or a transparent shadow cluster.
- **No clipped canvases.** Leave a pixel of air around every silhouette.
- **Repetition control.** Every repeating ground tile has 2–3 variants picked by tile hash; decals break the grid.
- **Dithering** only for light falloff (VIS-001's 4×4 ordered dither) and sparing texture; never as a gradient on sprites.
- **Detail budget.** Hero assets (oak, house, cave) get the most detail; ground the least; nothing out-details the hero within its screen.

## 5. Palette

**⚠ conflicts with the locked spec.** `DESIGN.md` locks a "muted, desaturated palette" and a grim, overcast grade. The concept (and this task's brief) asks for warm, vivid autumn by day (C-04). Until the owner decides, the locked rule stands; the proposal is:

- **Shared palette.** One palette for all environment art, sampled from the concept (`art/style_tests/ART-003/src/concept_palette.png`, 32 colours), so new assets agree by construction.
- **Day:** oranges, ambers and reds against deep fir green and olive grass; brown paths. Darks are brown-black, not pure black.
- **Night:** everything drops toward blue-grey; warm colour survives only at light sources; a red glow is reserved for the Hollow.
- **Seasons:** autumn warm and rich; late autumn and winter greyer and colder, so the grim mood grows with the year (proposed seasonal grade; needs testing).
- **Low sanity:** the existing cold blue-grey lean (`SANITY_TINT`, `SANITY_COLD`) must stay clearly colder than any normal day.
- **Grade before repaint.** A colour problem across the scene is fixed in the grade, not by recolouring art.

## 6. Lighting

- **Engine-driven.** All light comes from Godot: `CanvasModulate` ambient, `PointLight2D` sources, the full-screen grade. Art is drawn unlit; nothing bakes a glow into a sprite except emissive bits (window panes, lantern glass).
- **Day:** soft overhead light; trees, rocks and brush cast soft ground shadows (existing).
- **Dusk:** the warm three-colour dusk from VIS-001 (`DUSK_TINT`).
- **Night target (proposed, C-05):** readable blue-grey like the ART-003 Round 2 preview: farm mean luma about 0.11–0.15 at 1280×720, forest edges under about 0.07, the concept at 0.200 as the ceiling. Gameplay `darkness` (sanity, lamps, events) is never changed for looks.
- **Warm points:** windows, porch, lamps the player builds, the cave mouth, the lantern. Landmarks may get a faint warm rim (oak, well) so they hold at night without more lamp posts (C-07).
- **Lights land on the art grid** (stepped falloff, VIS-001); the moving lantern keeps its smooth falloff.
- **The Hollow** owns red. Nothing friendly glows red.

## 7. Atmosphere and depth

- **Fog:** slow wisps at forest edges and corners, more in autumn evenings and fog weather; never over walkable centres.
- **Distance:** far tree rows a little cooler and dimmer, with a thin haze; the forest interior darker than its edge.
- **Particles:** seasonal leaves, petals, fireflies, rain, snow (existing) stay one or two art pixels.
- **Restraint:** supernatural effects are rare and small: a red glow, eyes in the fog, a shape at the edge.

## 8. Materials

| Material | Read |
| --- | --- |
| Timber | Grey-brown, plank lines, weathered ends, darker at joints and ground contact |
| Shingle and slate | Dark blue-grey rows, moss patches, uneven edges |
| Stone | Grey with moss on top faces, dark cracks; foundations, chimneys, well, cave |
| Bark | Deep brown, vertical texture; the oak's twisted, ridged |
| Grass | Olive, varied by tile, with tufts; never a flat field |
| Path and soil | Warm brown, worn edges, pebbles; soil in furrows with plank or log bed edging |
| Leaf litter | Orange and red drifts, thickest at bases and path verges |
| Water | Dark, reflective, lily pads and reeds at the edge; moonlit at night |
| Metal and glass | Iron hardware, warm lantern glass |

## 9. Vegetation layers

Four layers on every forest edge, from the concept:
1. **Canopy:** firs and spruce (blue-green), red and orange maples, the oak.
2. **Understorey:** vine maple, huckleberry, golden shrubs.
3. **Ground cover:** sword ferns, dry grass, reeds by water.
4. **Litter:** leaves, twigs, acorns, mushrooms, mossy logs, roots.

Rule: nothing stands on bare grass — fences, rocks and buildings get plants and litter at their bases. **Density by zone** (C-10): full density on tiles the player can't walk; thinner around paths, plots and interactables; foreground layers only where the player can't go, fading when the player is behind them.

## 10. Architecture

- Weathered, irregular and lived in; stone foundations and chimneys; dark roofs with moss; porches with steps.
- **Dressed:** firewood, barrels, crates, flower beds, pumpkins, lanterns on posts — more as the house is restored, so dressing tells the restoration story.
- **Stages:** the house's four repair stages share one canvas and door position (`DESIGN.md`); any redraw waits for the D-009 comparison.
- Outbuildings (coop, barn, stall, workshop, smokehouse, cellar) share the house's materials.

## 11. Characters

- 16×32, straight-on, full dark outline, high value contrast against the ground, day and night.
- The concept's trek coat and pack are noted, not adopted (`CONCEPT_FIDELITY_FEASIBILITY.md` system 13).

## 12. UI

The SpriteCook kit (dark wood, iron, gold selection) stays. The concept's brass-and-parchment plates and the trek's lantern-oil and nerve widgets are ideas for a later UI task, not a restyle now.

## 13. Production pipeline

- **⚠ Open decision (C-12).** `DESIGN.md` and `CLAUDE.md` lock SpriteCook `pixel-engine-image-v1` with the `house_chunky_b` style anchor. ART-001 to ART-003 used PixelLab, with the concept palette, which matched the concept better but doesn't match the SpriteCook set. The owner should choose the pipeline and a style anchor (possibly a new, concept-derived one) before production art.
- Generate related pieces as one strip of cells so they match.
- Reuse and refine approved assets before generating new ones; no large speculative batches.
- Fix lighting with lighting, not with art; fix asset quality with art, not with gameplay changes.
- Record every asset ID (`spritecook-assets.json`, or `pixellab-assets.json` in the test folder).
- Prototypes live in `art/style_tests/<TASK-ID>/`; production art in `art/farm/`, `art/ui/`, `art/player/` only after owner approval.
- Every visual change goes out under `VISUAL_REVIEW_PROTOCOL.md` and is scored with `ART_REVIEW_RUBRIC.md`.
