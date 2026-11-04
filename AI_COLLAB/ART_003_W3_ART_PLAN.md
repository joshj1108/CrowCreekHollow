# ART-003 W-3/W-4: targeted art production plan

Status: **proposal; owner approval needed before any work.** Planning only, written 2026-11-03.
- **Not done:** no generations, no new prototype code, no captures.
- **Not changed:** production art, scripts, saves, camera, scaling and the live farm layout.
- **Not started:** P-1 production night lighting.
- **Kept:** the uncommitted VIS-002 work (stash `stash@{0}` and the working tree).
- Everything below is **NON-PRODUCTION**: it feeds the wider prototype (`tools/art003_wide.gd`) and its review sheets only. Moving any of it into the game is a separate decision, and depends on the pipeline decision C-12.

Inputs:
- ChatGPT's W-1/W-2 review (board, 2026-11-03; **60.0/100**);
- `art/style_tests/ART-003/WIDE.md`;
- `ART_003_WIDE_HOMESTEAD_PLAN.md`, sections 3 and 4;
- `DESIGN.md`, "Art style (locked)" and "Farmhouse";
- the house constants in `scripts/main.gd` and `scripts/farm_layout.gd`.

## 1. Priority order (concept-fidelity gain per unit of work)

| # | Workstream | New art | Manual work | Views it changes | Expected gain | Why this rank |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | B. Oak D canopy | 1–3 targeted edits | 1–3 h | V1, V3, V5 | High | The cheapest item, and it's in the establishing view. One sprite; no code. |
| 2 | D1. Pond shore, reeds, dock | 3–5 | 2–4 h | V4, walk | High | Fixes the clearest mismatch (flat, rectangular SpriteCook water). It bakes into the ground chunks, so it adds no draw calls. |
| 3 | A. Farmhouse, Restored stage only | 2–4 | 3–5 h | V1, V5 | High, but riskier | The largest object in the two key views. Its door, window and wall lines must line up exactly, which may take more than one try. |
| 4 | C. Garden density and crops | 3–4 | 3–5 h | V2 | Medium–high | One view only, but a whole screen. It must keep the walkways and crop readability. |
| 5 | D2. Orchard fruit trees | 1–2 | 1 h | V4 | Medium | Replaces the maple stand-ins; it shares V4 with the pond. |
| 6 | E. Arrival and transitions | 1–2 (mostly reuse) | 3–4 h of placement | V3, road, garden→pond | Medium | Mostly reuse and composition; few new assets. |
| – | A2. House stages 0–2 | 3–6 edits | 3–6 h | stage captures | – | **Only if the A alternative is approved.** Not part of this request. |
| – | Lantern on grass | none | 1 h of measurement | – | – | Investigation only (section 7); no lighting change. |

**Totals:** about 11–20 generations or edits for items 1–6, plus about 13–22 hours of manual cleanup, placement and capture. That is more than the earlier 6–12 estimate, because the house and garden are now in scope.

**Proposed batches.** Each batch stops for owner and ChatGPT review, following CLAUDE.md's one-section-at-a-time rule.
- **Batch A:** oak canopy, then pond and dock. 4–8 generations. The largest certain gain for the least risk.
- **Batch B:** the Restored house alternative, then the garden. 5–8 generations.
- **Batch C:** orchard and arrival dressing. 2–4 generations.

The reuse-only part of E (section 6) can ride along with any batch at no generation cost.

## 2. Workstream B: ancient oak (rank 1)
- **Reuse:**
  - `r3/oak_d.png` (192×192, 12×12 tiles): trunk, branching, roots and stone treatment, all kept as they are;
  - `r3/boulders.png`, `r3/fungus.png` and the charms, unchanged;
  - `r3/oak_details.png` for any leaf-cluster sampling.
- **New:** one edited `oak_d` with a fuller canopy. **Not a reroll.**
  - A mask covers only the crown area. The trunk, roots, stones and the 3–4 major limbs stay outside the mask and come through pixel-identical.
  - The prompt asks for 4–6 large, cohesive golden-orange foliage masses, with darker undersides and the concept palette's highlights, leaving gaps where the major limbs show.
- **Estimate:**
  - 1–3 PixelLab inpaint passes on the masked crown;
  - or, at no generation cost, a hand cluster pass in the PixelLab pixel workbench (2–4 h);
  - then 1 h of cleanup: the outline, and the seams where edited and kept pixels meet.
- **Size and footprint:**
  - 192×192 source, shown at 3×;
  - the blocked base stays the current trunk-and-root tiles;
  - the crown overhangs, drawn over the farmer when he is behind it.
- **Dependencies:**
  - V1-B's 2-tile gap between the oak's art and the house's art must stay walkable and visible;
  - the larger crown must not cover the house's chimney or the well in V1-B.
  - Check: one V1-B capture, one V3 capture and the walking route.
- **Performance:** none. Same sprite, same size.
- **Expected impact:** directly answers "skeletal" (R3) and the concept's golden landmark. It appears in three of the five views.
- **Conflicts:**
  - The golden-orange saturation is higher than "muted, desaturated" in the locked spec (C-04 territory). Use the concept palette and check the grade.
  - Reduce the litter drift under the oak (ChatGPT: a "large orange patch") once the crown carries the colour. That is a reuse-only placement change.

## 3. Workstream D1: pond, shoreline and dock (rank 2)
- **Reuse:**
  - the PixelLab grass base tile, chained as the shore tileset's upper terrain so it meets the existing ground;
  - `r3/boulders.png` and `src/rocks.png` for shore stones;
  - `r2/decals.png` for mud.
  - `ground_water` is **dropped from the prototype**; production keeps it unchanged.
- **New:**
  1. A grass→water top-down Wang tileset, 16 px, 16 tiles (64×64), chained to the grass base tile. One generation, plus one variant tileset for edge variety mixed in the bake (as path and path2 are). The water centre has subtle ripple and depth variation.
  2. An optional water→deep-water tileset for a darker centre: 1 generation.
  3. A shore prop strip, 128×32 (eight 16×16 cells, some 16×32): reeds, cattails, lily pads (two), a shore rock, mud with reeds, and a fallen reed clump. 1 generation.
  4. A wooden dock, 32×64 (2×4 tiles): planks running onto the water, posts, a mooring post and a coiled rope. 1 generation, plus 0–1 retry.
- **Shape:**
  - The blueprint's pond outline becomes irregular: coves, a point and a notch where the dock meets the shore. **No straight run longer than 3 tiles.**
  - Reeds cluster in two or three groups at the coves, not round the whole edge.
- **Footprint:**
  - The water is blocked; only the dock tiles can be walked.
  - That uses the prototype's collision only (W-8: in memory, unsaved).
- **Dependencies:**
  - The bake needs a second Wang terrain layer (water under grass). That is a small change in `tools/art003_wide.gd` only.
  - The dock sorts by its base row, so the farmer stands on it.
- **Performance:**
  - The shoreline and water bake into the existing chunks: no extra draw calls.
  - Reeds and lily pads are baked decals, about 0 extra.
  - The dock is one sprite.
  - No animation, so no per-frame cost.
- **Expected impact:** removes the most visible style break in V4. It gives the walk a destination, and the landmark the concept shows (a dock with reeds).
- **Conflicts:**
  - Production water, fishing spots and `ground_water` are untouched.
  - Any production pond is a separate layout decision.

## 4. Workstream A: farmhouse (rank 3)

**Locked requirements, kept unless the owner approves a separate change:**
- **Footprint:** 11×7 tiles (`HOUSE_W`, `HOUSE_H`). The sprite is 12×10 tiles, **192×160**, offset −0.5 tile.
- **Door and steps:** centred at art x = 96, on the door tile (`HOUSE_DOOR_IX`).
- **Walls:** end at art y = 149 (`HOUSE_WALL_BOTTOM_TILES` 9.3125).
- **Front windows:** centred at art (48, 112) and (143, 112). The window lights and the porch light are placed from these positions.
- **Stages:** four, Decrepit → Boarded → Patched → Restored, each with the features in `DESIGN.md` (Farmhouse). The footprint never changes.

**Plan:**
- **A1 (proposed now): a Restored-stage alternative only,** made for comparison with the production house, never replacing it.
  - **Content:** weathered shingle courses, a layered roof (main gable with a cross-gable or dormer), exposed timber framing on the gable end, a stone chimney, a covered porch with posts and steps, two front windows with frames and window boxes, a dark stone foundation and a lamp by the door.
  - **Generation:**
    - PixelLab at the **exact 192×160**: never resampled, per the locked rule. 2–4 generations, using the concept crop and the concept palette as guides.
    - Then 3–5 h of hand registration in the workbench: door at x = 96, windows at their two centres, wall line at y = 149, porch steps inside the sprite's bottom edge.
    - Any candidate that can't be registered without redrawing more than about 15% of it is rejected, not forced.
  - **Landscaping:** separate sprites, so the footprint stays fixed.
    - Reuse: `garden_props_clean.png` (barrels, crates, flowers), `woodstore`, `chopping_log`, the shrubs from `undergrowth.png`.
    - New: one 128×32 strip of flower beds, shrubs and stone edging. 1 generation, counted in E.
- **Comparison:**
  - production `house_stage_3` against the alternative;
  - 1:1 close-ups, plus V1-B and V5, day and night;
  - a labelled sheet with the concept crop.
  - The prototype tool gets a `house=alt` option; production is not touched.
- **A2 (later, only if A1 is approved):**
  - Stages 0–2, derived from the approved Restored art by edits: boards, missing shingles, broken glass, sag. 3–6 edits and 3–6 h, so the silhouette stays identical across stages.
  - Production adoption would need the C-12 pipeline decision and a `DESIGN.md` change.
- **Performance:** none. One sprite, the same size; the lights stay at the same positions.
- **Expected impact:** the largest object in V1 and V5. It closes much of the concept-fidelity and consistency gap: the house is now drawn in a different family from everything around it.
- **Conflicts:**
  - **Locked spec:** `DESIGN.md` names SpriteCook `pixel-engine-image-v1` with the `house_chunky_b` anchor for sprites. A PixelLab house is a prototype-family test, not a replacement (C-12, W-3).
  - **C-06** (house dressing before or instead of a redraw) remains the cheaper fallback: if A1 is rejected, only the landscaping strip is made.
  - **Roof height:** the concept's layered roof may want more than 160 px. Raising the sprite above the footprint would change the roof layer's draw and the window constants. **Not proposed;** the alternative fits 192×160.

## 5. Workstream C: garden (rank 4)
- **Reuse:**
  - the bed layout: four 7×4 beds in a 2×2 grid, 2-tile walkways, and 2-tile gates (the W-2 fix);
  - `r2/garden_bed.png`;
  - `r3/garden_props_clean.png` (trellis, tools);
  - `src/fence.png`;
  - the production crop strips, used as a brightness reference.
- **New:**
  1. A crop strip, 128×32: eight 16×32 cells of ripe crops, at about 80% of the cell width, with leaves overlapping the row above. Corn, pole beans on stakes, pumpkin with vines, cabbage, kale, turnip tops, squash, sunflower. Ripe colours bright enough to stay above the night readability threshold. 1–2 generations.
  2. A tilled-soil Wang tileset: furrows, darker damp edges, a plank or stone bed border. It replaces the plain dirt floor of the bed interiors; the walkways become trodden straw over dirt. 1 generation.
  3. A fence and trellis strip, 128×32: north–south rail pieces (W-2 found north–south runs drew posts only), a gate with hinges, a bean-trellis arch, and a border shrub. 1 generation.
- **Density rules:**
  - Plant every bed tile.
  - Taller crops in the north rows, so they don't hide the south rows or the farmer on the walkway.
  - Border vegetation (shrubs, tall grass, flowers) only outside the fence.
  - Nothing on walkway or gate tiles.
- **Footprint:** the beds are blocked; the walkways and gates stay open. The walk route must still pass both gates.
- **Dependencies:** a second soil terrain in the prototype bake, and the crop placement in `art003_wide.gd`.
- **Performance:** the same number of crop sprites (one per bed tile), so about +0. The soil is baked.
- **Expected impact:** fixes "soil dominates, crops small, families inconsistent" in V2.
- **Conflicts:**
  - Production crops are 16×16, in four growth stages per kind. 16×32 crops, or any new kind, would need per-stage art and drawing changes in the game. **Not proposed;** prototype only.
  - The crops' brightness against the muted palette (D-008 keeps the current saturation) needs the grade checked.

## 6. Workstream D2 and E: orchard and arrival (ranks 5 and 6)

### D2: orchard fruit trees
- **Reuse:** the orchard's fence and layout; `r2/decals.png`.
- **New:**
  - An apple tree, 48×64 (3×4 tiles): autumn leaves, red fruit, an open crown and a 1-tile trunk.
  - One crown variant (pear, or a second apple shape) so the rows don't repeat.
  - A small fallen-fruit and basket decal.
  - 1–2 generations.
- **Footprint:** the trunk tile is blocked; the crown overhangs.
- **Performance:** it replaces the maples one for one: +0.
- **Expected impact:** V4 reads as an orchard, not as generic trees.
- **Conflicts:** prototype-only autumn. Production trees would need seasonal states (winter bare) and the C-12 decision.

### E: arrival and transitions
Specific areas, each with a small number of deliberate groups. No uniform scatter: open grass stays as rest space between the groups.
- **V3, the well crossroads (the weakest view):**
  - a signpost at the fork (house / garden / orchard / road);
  - a handcart with sacks where the road path meets the well path;
  - a chopping block and split wood between the well and the oak (`chopping_log`, `woodstore`, reused).
  - Three focal groups at most.
- **The road entrance:**
  - a mailbox at the road gate (ties to the morning post that brings catalog orders);
  - wheel ruts (the `wear` tileset, reused);
  - one roadside boulder cluster (reused);
  - a single dead tree (`tree_dead_0`) as the one quiet horror note.
- **Garden → pond:**
  - a compost heap and rain barrel at the garden's south-west corner;
  - tall grass and cattails thickening towards the water, so the ground tells you the pond is near;
  - the path narrowing to the dock.
- **House → garden (the east side of V1/V5):** the house landscaping strip from section 4 (flower beds, edging), placed against the porch and the south wall only.
- **New:** one 128×48 strip (signpost, mailbox, handcart, compost heap, rain barrel, sacks) and the landscaping strip. 1–2 generations. Everything else is reuse.
- **Performance:** about 10–20 more sprites per view: well under +30 draw calls against the measured 678–808.
- **Expected impact:** fixes "thin in-between spaces" (V3 and the road) with storytelling objects rather than texture.
- **Conflicts:** no new light sources (W-7, C-07). The mailbox and signpost are decoration only, with no interaction.

## 7. Lantern on dark grass: investigation only
- **Observed (W-2):** pool 0.16–0.18 on grass, against 0.235 on the path, under the same R3-1 night.
- **Plan:**
  - Measure the lantern pool at the same spot over the prototype grass, the production grass and the path, at unchanged energy.
  - Compare against each ground tile's daytime luma.
  - Report whether the cause is the grass albedo (an art fix: lighter grass base) or the falloff (a lighting fix, which would be P-1 territory).
- **Limits:** no change to the lantern, the night or gameplay darkness. About 1 h, run with Batch A's captures.

## 8. Shared technical notes
- **Pipeline:** every new asset is PixelLab, to match the ART-003 family. Asset IDs go into a non-production list in `art/style_tests/ART-003/` (not `spritecook-assets.json`, which is the production registry), with a short `WIDE.md` note.
- **Output:** files land in `art/style_tests/ART-003/w3/`, never in `art/farm/`.
- **Locked rules kept:** 16 px per tile, whole-tile sizes, no resampling, dark outlines, straight-on 3/4 view, the camera and `SCALE` 3.
- **Prototype tool changes:**
  - extra Wang layers in the bake (water, tilled soil);
  - `house=alt`;
  - new sprite placements.
  - All of it stays in `tools/art003_wide.gd`; nothing in `main.gd`.
- **Review per batch:**
  - matching BEFORE (the W-2 images) and AFTER captures of only the affected views, day and R3-1 night;
  - performance re-measured;
  - the walk route re-run;
  - saves hashed;
  - VIS-002 diff hash checked;
  - one master PNG per `VISUAL_REVIEW_PROTOCOL.md`.
- **Credits:** to be checked (PixelLab balance) at the start of each authorized batch, and reported.

## 9. Decisions for the owner
1. Approve the priority order, or reorder it.
2. Authorize Batch A only (oak canopy, then pond and dock), or another batch.
3. House A1: a Restored-stage PixelLab alternative for comparison only. Yes or no.
4. Whether the 16×32 crop direction is worth testing, knowing production adoption would need per-stage art.
5. The lantern-on-grass measurement alongside Batch A: yes or no.
