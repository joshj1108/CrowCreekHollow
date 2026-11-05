# ART-005 E2-PL — G1 integration analysis and 32 px farmhouse construction design (documentation only)

Task: the owner's G1 follow-up of 2026-11-04, after ChatGPT's two-sheet review (`250d9bf`). Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **proposal only. No generation was run and no credits were spent.** The only PixelLab calls were free lookups: `get_balance` (4,938 generations, USD 0, unchanged since G1) and `get_pro_flash_capabilities` price quotes. `DESIGN.md`, production art, camera, scaling, gameplay, saves, E0/E1, W-4 and VIS-002 are untouched.

Labels: **[Measured]** checked here; **[Quote]** a free PixelLab price quote taken today; **[Doc]** from PixelLab's tool documentation; **[Judgement]** my opinion, to be checked by the owner and ChatGPT; **[Unverified]** not yet tested.

The G1 sample is treated as an **architectural style study**, not a production asset (ChatGPT, `250d9bf`).

## 1. G1 is preserved

Every G1 file is committed at `911499c` and unchanged in the working tree [Measured]. A hash manifest now freezes them: `art/style_tests/ART-005/pl/G1_PRESERVED.sha256` (27 files; `sha256sum -c` passes).

| What | Where |
| --- | --- |
| Selected style board c1, and c0, c2, c3 | `pl/anchors/board_c0..3.png` |
| Original generation (unedited) | `pl/house/house_section_original.png` |
| Masked inpaint output and its mask | `pl/house/house_section_inpaint1.png`, `inpaint1_mask.png` |
| Cleaned section, day and night; cleanup diff | `pl/house/house_section_clean_day.png`, `_clean_night.png`, `cleanup_diff.png` |
| Reconstructed pseudo-layers (script-made, not authored) | `pl/house/pseudo_layers/` |
| Harness composites | `pl/32/house_day.png`, `house_night.png` |
| Prompts, seeds, settings, job and asset ids, receipts | `pl/pixellab-assets.json` |
| Scripts | `tools/art005_pl_cleanup.py`, `tools/art005_check.py`, `tools/art005_density.gd` (`art=pl`) |
| Review package | `pl/review/` |

Nothing in this task writes to those files. Any later work goes to new files (`pl/g2/...`).

## 2. Why the section does not integrate with the placeholder house

Measured on `pl/32/house_day.png` (the composite) and the cleaned section. The section was pasted at art pixels (29, 136); the changed area is x 29–187, y 136–309 of the 384×320 house [Measured].

| # | Break | Section | Placeholder / game | Cause |
| --- | --- | --- | --- | --- |
| 1 | **Roof projection** | The roof is a ~28 px band of shingles above a fascia beam: a near-front elevation of an eave. | The roof is a foreshortened top plane ~4.4 tiles tall (y ≈ 20–160), seen in 3/4. | The prompt asked for a corner, so the model drew an awning, not the bottom edge of a 3/4 roof plane. Nothing tied it to the house's roof. |
| 2 | **Course scale** | Shingle courses repeat every ≈ 11 px [Measured: row-luminance minima at y 8, 19, 30]. | Placeholder and spec §5: courses of 1/2 tile = **16 px**. | Mark scale was never constrained. The model scales marks to its canvas, not to the tile. |
| 3 | **Eave and sill height** | Eave ≈ 4.0 tiles above ground; sill ≈ 2.1 tiles. | Placeholder eave at y = 160 and wall base at y = 298 (4.3 tiles); spec sill 1.4 tiles. | The model doesn't follow pixel numbers in a prompt (G1 results §3). |
| 4 | **A gameplay feature baked in** | Porch post, deck and step at the left corner. | In the game the **covered porch is a purchased extension** (`estate_system.gd` `_draw_outside`, `porch`), drawn over the house along the porch row. The base house has steps only, centred on the door (x = 192). | The prompt asked for a porch post. The section's post lands on the placeholder door. |
| 5 | **Pixel density and texture energy** | 21 colours, single-pixel grain everywhere, orphan pixels 10.3%. | 15 colours, flat fills, ~0% orphans. | One side is finished art and the other a blockout; the board's grain (4.8% orphans) was copied faithfully. |
| 6 | **Value and hue** | Dark, warm timber wall; blue-grey slate. | Light tan wall with flat blotches; flat blue-grey roof in stepped lit/shaded thirds. | Different ramp steps chosen for the same material. |
| 7 | **Section boundary** | A hard rectangle. Its right edge is a corner post, which says "the building ends here". | The building continues. | A corner was generated as if it were a whole small building, with no joint to anything. |
| 8 | **Window light** | The window sits ~1 tile left of where the night light is placed. | Production lights sit at the window centres in `HOUSE_SPRITE_WINDOWS` (3.0, 7.0) and (8.94, 7.0) tiles. | The section was made without the game's anchor points. |

**What this means [Judgement].** Only #5 and #6 come from the placeholder being simple. #1, #2, #3, #4, #7 and #8 would break the join to *any* house, including a finished one, because the section was generated from a prompt with no geometry. This is the same failure that held ART-003 back: attractive standalone pieces with no shared construction. More generation in the same way would repeat it. The fix is to fix the geometry *before* generation and let the model only render materials onto it.

## 3. Proposed construction method for the 32 px farmhouse

### 3.1 The constraints that cannot move

From the game (`scripts/farm_layout.gd`, `main.gd` around line 2577, `DESIGN.md` "Farm layout" and "Farmhouse"), scaled to 32 art px per tile:

| Item | Value (art px at 32 px/tile) | Source |
| --- | --- | --- |
| Canvas | 384 × 320 (12 × 10 tiles) | `HOUSE_SPRITE_TILES` |
| Footprint (blocks the player) | 11 tiles wide, x 16–368; walls are the bottom two footprint rows | `HOUSE_W = 11`, `HOUSE_SPRITE_OFFSET_X = -0.5` |
| Overhang allowance | ≤ 16 px each side (x 0–16, 368–384), roof only | the 12-vs-11 tile margin |
| Wall base | y = 298 | `HOUSE_WALL_BOTTOM_TILES = 9.3125` |
| Eave line | y = 160 (facade 138 px, 4.3 tiles) | placeholder and production stage art. Spec §6 says "about 5"; the game's 4.3 wins because code depends on it. |
| Door | 38 × 74 opening, centred x = 192, bottom on y = 298 | spec §6; door tile = middle of the footprint |
| Steps | centred x = 192, y 298–320 | "steps sit on the door tile" |
| Windows | 45 × 45, centres (96, 224) and (286, 224); sill ≈ 1.6 tiles | `HOUSE_SPRITE_WINDOWS` (keeps the production night lights where they are) |
| Kept clear for extensions | porch row (y ≥ 298 except steps); dormer zone x 96–288, y ≈ 96 on the roof | `_draw_outside` (porch, second storey, cellar doors on the west wall) |
| Repair stages | 4 (Decrepit, Boarded, Patched, Restored) on the same canvas, door and steps aligned | `DESIGN.md` "Farmhouse" |

### 3.2 Method: a measured blockout, materials rendered onto it

1. **Blockout (free, scripted).** A flat-colour 384×320 drawing generated by a script from the table above: roof plane, ridge, chimney, fascia band, wall, corner posts, door, two windows, foundation, steps. Each region is one flat palette colour per plane (lit, front, shaded). The script also writes the region masks and an anchor file (door, windows, eave, wall base, footprint). Every number is exact, so drift (#3, #8) cannot happen in the blockout.
2. **One projection rule.** Straight-on 3/4. Roof: one foreshortened plane from the ridge to the eave, shingle courses every **16 px**, the left half +1 ramp step, the right half −1 (spec §4); the eave band (fascia + under-eave shadow) is **12 px**, owned by the roof. Walls: front face at the ramp's middle step, darker band under the eave. No side walls (straight-on view), so the corners are posts, not visible planes. No diagonal or isometric shapes anywhere.
3. **One light.** Upper left, spec §4. The blockout's plane colours already encode it, so the renderer inherits it rather than choosing it.
4. **Mark-scale table (the unified density).** Applies to every module and every later asset:

   | Material | Mark | Size |
   | --- | --- | --- |
   | Shingle | course | 16 px, top texel lit, bottom texel shadow |
   | Timber plank | plank | 12 px tall; grain marks ≥ 3 px long along the plank |
   | Fieldstone | block | 10–16 px, 2 px mortar, chipped corners ≥ 2 px |
   | Trim, posts | width | 6–8 px, left lit, right shaded |
   | Glass | pane | 4 panes; 2 px mullions; 2×2 glint |
   | Any material | cluster | **≥ 2×2 px**; single-pixel marks only as deliberate glints; orphan pixels ≤ 6% |

5. **Rendered whole, not in pieces.** On the owner's Tier 2 plan, `edit_image` takes the whole 384 × 320 canvas (§6), so the house is rendered in one call and has no seams. If it ever has to be split (the Pro Flash fallback, §6 C-w), each boundary goes on a real joint that "owns" the seam: the eave band (roof/wall), the door frame (left/right wall), the chimney (left/right roof), with repair masks over the joint band ±8 px.
6. **Rendering.** The blockout is rendered by `edit_image` (pro) in reference mode (reference = the style anchor, §7 M1) with the instruction "render the materials, keep every edge and line in place". Then masked inpaints only where something is wrong. Pixels outside each mask stay byte-identical [Doc; Measured in G1].
7. **Restored first, then the other stages by masked decay.** The three earlier stages are made from the Restored art by masked inpaint (boarded windows, missing shingles, sagging eave), so geometry, door and steps are identical in all four by construction.
8. **Separate layers, exported per spec §10.** `house_day.png` (glass in the water ramp, never lit); `house_emissive.png` (glass and the Restored door lamp in the lantern ramp, same canvas, everything else transparent); `house_shadow.png` (1e2230 at alpha 96, drawn by script, never generated). Night is the engine tint plus the emissive layer. No night repaint.
9. **Collision is not touched.** The footprint, door tile and walkable roof rows stay as they are. The art is checked against them by an overlay script (§7 gate H1), not the other way round.

### 3.3 Why this answers each break in §2

#1 and #2: the projection and course size are in the blockout and the rule, not the prompt. #3 and #8: positions are exact pixels. #4: no porch in the base house; the extension zones stay clear. #5 and #6: one anchor and the mark-scale table for the whole house. #7: no free-standing pieces, and the house is rendered in one call, so there are no seams between pieces.

## 4. Same-hand test 2: the well (challenges the anchor, not the house)

A second attractive house corner would prove nothing. The test must stress the places where an anchor usually fails.

- **Asset:** the farm well at 32 px: 2 × 3 tiles → **64 × 96** art px; stone ring, timber posts, a small shingle roof, a bucket.
- **Why it challenges the anchor:**
  1. **Small canvas.** Models scale their marks to the canvas. If the anchor really holds, the shingle course stays 16 px, the plank 12 px and the stones 10–16 px on a canvas a sixth the size of the house's.
  2. **Curved form.** The stone ring is a cylinder. The light model has to wrap round it (lit left, shaded right), not just repeat a flat texture.
  3. **Shared materials, different object.** Stone, timber and shingle must use the same ramp steps as the house.
- **Same method as the house:** blockout by script, one reference edit, at most one repair inpaint.
- **Measured pass criteria:**
  - mark sizes within ±1 px of the table in §3.2;
  - per-material ramp-step histograms within a fixed distance of the house's (script, Jensen-Shannon distance ≤ 0.15 [proposed threshold]);
  - orphan pixels ≤ 6%, palette 100%, no partial alpha, no resampling;
  - **blind patch match:** 12 crops of 32 × 32 (6 house, 6 well) plus 6 decoys (G1 boards c0/c2/c3, ART-003 W-4 house, two placeholder crops), shuffled and unlabelled. ChatGPT and the owner group them by "same hand". Pass: ≥ 5 of 6 well crops grouped with the house and ≤ 1 decoy in the group.
- **Cost [Quote]:** reference edit 64 × 96 = **5**; one repair inpaint 64 × 96 = **5**. Expected 5–10, **cap 15**.

## 5. Visual-production plan so the oak, terrain and character coexist with the house

The same three things apply to every asset: a script blockout with exact geometry, the mark-scale table, and the shared anchor. On top of that, the scene needs a **texture-energy hierarchy**, so the house doesn't become the noisiest thing on screen (ChatGPT noted the risk of over-busy detail at 1:1).

| Layer | Texture energy | Contrast role | Value check (E0 `value_budget.json`) |
| --- | --- | --- | --- |
| Terrain (grass, path, soil) | **Lowest:** 3 value clusters, tufts 4–6 px, orphans ≤ 3% | Background; separations by value step, not detail | path/grass ΔL 22, soil/grass 7 |
| Buildings, oak | **Medium:** marks per §3.2, orphans ≤ 6% | Mid-ground; separated from grass by the stone foundation and the contact shadow | timber wall/grass is only ΔL 7.5 by day, 1.9 at night, so the **foundation and shadow layers are mandatory**, not optional |
| Character | **Lowest texture, highest silhouette contrast:** big flat cloth planes, no grain | Must stay the strongest local read | outline/path ΔL 40 |

| Asset | Geometry and method | Cluster and shading targets | Expected cost [Quote/Doc], not requested now |
| --- | --- | --- | --- |
| **Oak** 384 × 384 (12 × 12 tiles) | Same method as the house: a scripted blockout of leaf-mass ellipses, trunk and root flare, rendered whole by one `edit_image` reference edit (384² is within Tier 2's 512 px) | leaf masses ≈ 11 px (1/3 tile), rim scallops 4–6 px, bark grooves every 3–4 px, crown underside −1 step, sky gaps; shadow by script | edit 25 (384² is above the 341² band) + 2–3 repairs × 6 → **37–43, cap 50** |
| **Terrain** grass → path, dual grid | `create_topdown_tileset` pro for the 16-piece corner logic (it takes no style image [Doc]), then each fill brought to the anchor by reference edit at 32 × 32 | 3 grass values, no single-pixel speckle, 1/16-tile shade lip on the lower material, ≥ 3 fills | tileset 15 + 4 fill edits × 5 → **35, cap 45** |
| **Character** 32 × 64 | South frame from a scripted silhouette blockout (proportions spec §6), reference edit; rotations and the walk only after this gate | 2-tone skin, cloth folds one per limb, 1-px outline matching the house's outline colour | edit 5 + rotations ≈ 1 → **6, cap 12** (the walk is a separate phase) |

## 6. Whole-building generation, modular generation, inpainting or manual assembly

**Correction (owner, 2026-11-05):** the account is on **Tier 2 (Pixel Artisan)**, which allows images, edits and inpaints **up to 512 × 512**. The 256 × 256 limit I first reported is real but applies **only to the Pro Flash tools** (`*_pro_flash`). The other tools take the whole 384 × 320 house in one call [Doc, PixelLab tool descriptions read 2026-11-05]:

| Tool | Max canvas | Cost at 384 × 320 | What it can do with the blockout |
| --- | --- | --- | --- |
| `edit_image` (pro) | inputs up to 512 × 512 | **15 or 25** (10 up to 256², 15 up to 341², 25 above; a non-square canvas is measured at its own aspect ratio, so the band is only exact from a receipt) | Text edit or **reference edit** of the blockout ("composition preserved" [Doc]). One reference image (the anchor) |
| `inpaint_image` (pro) | 512 × 512 (above 256 needs Tier 2) | **15 or 25**, set by the whole canvas, not the mask | Repairs with the whole house as context; outside the mask stays pixel-identical |
| `create_image_pro` | about a quarter megapixel (5:4 up to 576 × 464) | **15 or 25**; 1 candidate at this size | Style image, up to 4 labelled references (the blockout could be one: "exact layout") and a forced palette, but no init image, so geometry is only guided |
| `create_image_pixflux` | 400 × 400 area | **1** | img2img from the blockout (`init_image_strength`: 300 subtle, 150 a real edit), forced palette from an image, no style image |
| Pro Flash create / edit / inpaint | **256 × 256** | not possible whole; 5 / 6 / 9 by longest side for pieces [Quote: 96² = 5, 192 × 160 = 6, 256 × 160 = 9, 256² = 9] | Small repairs on crops |

The "15 or 25" can be settled without spending: a job is charged only when it finishes, and `cancel_job` before then is free [Doc]. That is still a submit, so it waits for the owner's approval.

| Route | How | Cost for one house stage | Strengths | Weaknesses |
| --- | --- | --- | --- | --- |
| **A. Whole-building creation** | `create_image_pro` 384 × 320, style image = anchor, blockout as a labelled "layout" reference, palette forced | 15–25 per try | One composition, one hand, no seams | Geometry is only guided by a reference; G1 showed the model drifts from numbers. **[Unverified]** whether a labelled layout reference holds positions to ±2 px. **Second choice.** |
| **B. Modular generation** | Generate pieces separately (roof strip, wall bay, corner post, window, door, foundation, chimney, steps), then assemble | ≈ 9 pieces × 5–6 = **≈ 50**, plus tiling repairs 3 × 6 → **50–70** | Reusable for other buildings | Each call drifts in scale and value; edges don't tile; seams everywhere; repetition is visible. Closest to what held ART-003 back. **Not recommended.** |
| **C. Blockout + one whole-house reference edit + masked repairs (recommended)** | §3.2: the whole 384 × 320 blockout in one `edit_image` reference edit; small repairs by `inpaint_image_pro_flash` on crops ≤ 256 px (6 each), anything larger by `inpaint_image` on the whole canvas | edit 25 (15 if the aspect band applies) + 2–3 small repairs × 6 = 12–18 → **expected 37–43**; one whole-canvas repair (25) is the reserve → **cap 50** (a second full edit needs approval) | One call for the whole house, so **no seams between pieces**; geometry, collision, windows and stages fixed by the blockout; repairs leave everything else byte-identical | **[Unverified]** whether `edit_image` keeps the blockout's edges, hence the cheap pixflux pilot first (§7 H0). `edit_image` takes no forced palette, so a free palette snap follows, as in G1 |
| **C-w. Windowed Pro Flash (fallback)** | 4 windows of 192 × 160 by `edit_image_pro_flash`, seams on architectural joints (§3.2 step 5) | 4 × 6 + ≤ 3 seam inpaints × 6 + one redo 6 → **30–36, cap 48** | Cheaper per call | Four calls means seams to hide. Only if the whole-house edit fails |
| **D. Manual assembly from G1 pixels** | Tile G1 swatches (stone, planks, window) onto the blockout by script; draw the missing roof plane, door and chimney by hand | **0** | Free; tests the construction method and the scene composition before any spend (ChatGPT asked for a mockup first) | G1 has no 3/4 roof plane, door or chimney and its courses are 11 px, so those parts are hand-drawn; G1's grain comes with it; my hand pixel work is not at the premium bar [Judgement]. **A mockup, not a production route.** |

**Recommendation [Judgement]: D as a free mockup first, then C.** Before C, a free hand-finish of the anchor (§7 step M1), because a noisy anchor gives a noisy family (G1 results §5), and a 1–3 generation pixflux pilot to see whether img2img holds the blockout's geometry at all.

## 7. Revised, narrow quality gate (proposed)

Each step needs the owner's approval and a new generation cap; the 8 generations left from the G1 allowance are not enough and are not to be spent automatically.

| Step | What | Cost | Gate |
| --- | --- | --- | --- |
| **M0** | Blockout script and the D mockup in the E1 harness, day and night | 0 | ChatGPT and the owner confirm the geometry, roof projection, scale and the coexistence of house, oak, ground and farmer as a composition |
| **M1** | Anchor v2: a hand-finished copy of c1 (`pl/g2/anchor_v2.png`; c1 itself stays frozen) with the grain consolidated into ≥ 2×2 clusters and every swatch at the §3.2 mark sizes. Minutes and pixels changed logged | 0 | Orphans ≤ 3%; mark sizes ±1 px |
| **H0** | Geometry pilot: `create_image_pixflux` img2img over the whole 384 × 320 blockout (palette forced from `e0/palette.png`, `init_image_strength` 300), up to 3 tries | 1–3 | **Stop rule:** if any blockout edge (eave, chimney, ridge, door, windows) moves by more than 2 px at every strength tried, img2img does not hold geometry; report before H1 |
| **H1** | The whole house in one `edit_image` (pro) reference edit (reference = anchor v2), then repairs (§6 C); free scripted cleanup; emissive and shadow layers | 25 + 12–18 | **Gate H1** below. A second full edit needs the owner's approval |
| **T2** | The well (§4) | 5–10 | §4 criteria |
| | **Total** | **expected 43–56, cap 70** | |

**Gate H1: the house is judged in the actual scene and against itself, not against the placeholder.**

Measured (script, pass/fail):
1. **Geometry:** footprint edges, door opening, window centres, eave line and wall base each within ±1 px of the blockout's anchor file; nothing opaque outside the footprint plus the 16 px roof overhang; no art in the porch row except the steps; the dormer zone is plain shingle.
2. **Mark scale:** shingle course period 16 ± 1 px across the whole roof; planks 12 ± 1 px across the whole wall, measured separately in each window.
3. **Repairs and joints:** across the edge of every repair mask (and every seam, if the windowed fallback is used), the luminance and hue step is no larger than between two neighbouring areas of the same material (ratio ≤ 1.5 [proposed threshold]).
4. **Format:** palette 100%, no partial alpha, no resampling, orphans ≤ 6% (G1 had 10.3%).
5. **Night:** the production light positions (unchanged) fall inside the emissive glass; the day file has no lantern-ramp pixels.
6. **Finish effort:** hand cleanup changes ≤ 15% of opaque pixels and takes ≤ 2 hours. More than that means the tool only saved the layout, and the artist-anchor route (E2 plan §7, X1) is cheaper.

Visual, in real scenes (owner and ChatGPT):
7. In the E1 harness at 32 px, `framing=int`, 1080p 1:1 and 720p whole frame, day 12:00 and night 21:30: **no reviewer can point to a seam** without the overlay.
8. The house reads as **one building drawn by one hand**, with the roof, walls and foundation at one density.
9. The texture-energy hierarchy holds: the house is not noisier than its neighbours, and the farmer stays the strongest local read.
10. Because the oak, ground and farmer are still placeholders, the verdict is on the house's own coherence and the spec, **not** on "better than the placeholder". A full-scene coherence verdict waits until the oak and terrain are made by the same method (§5).

Outcomes: **pass** (go on to the oak, terrain and character plan, with a new cap); **revise** (one targeted repair round within the cap); **stop** (the hybrid route: an artist makes the anchor and possibly the house blockout's finish).

## 8. Not done in this task

No generation, no credit spending, no full E2-PL, no production art, no animation, no 16 px comparison, no mockup. `DESIGN.md`, production assets, camera, scaling, gameplay and saves are unchanged. E0/E1, W-4, VIS-002 and the G1 files are untouched. PixelLab's commercial-use terms are still to be checked by the owner.

**Side note for later, out of scope:** in the production game the second-storey dormer (`_draw_outside`, x 25–75% of the sprite, y 30%) overlaps the chimney's position in the current house art. Any new house should keep the chimney outside that zone.
