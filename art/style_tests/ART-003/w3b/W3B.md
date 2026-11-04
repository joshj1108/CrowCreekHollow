# ART-003 W-3 Batch B: Restored farmhouse alternative, garden, and the Batch A follow-ups

Status: for the owner's and ChatGPT's review. **Non-production.** Approved by the owner on 2026-11-03 after ChatGPT's Batch A image review (board, `f8c51f9`).
- **Not changed:** production art, `main.gd`, saves, camera, gameplay, project scaling, the live layout, `DESIGN.md`, `spritecook-assets.json`.
- **Not done:** house stages 0–2, P-1 production night lighting, Batch C.
- **Not committed:** nothing is committed or pushed yet. The uncommitted VIS-002, `.import`, `.uid`, `project.godot` and `main.tscn` changes are untouched.

Run: `tools/art003_wide.gd mode=wide layout=b art=w3b` (layout B only). Switches for the comparisons: `house=prod` (the production house in the same layout), `grass=1` or `grass=2` (lighter grass). Without `art=w3b` the tool draws Batch A and W-2 exactly as before; `make_blueprint.py OUT 1 1 w3` still writes `blueprint_wide_v1b_w3.txt` byte-identical.

## Checks
- **PixelLab:** 4,969 → 4,964 generations: **5 used of the 12-credit cap**.
  - Priced before generating: `create_image_pixflux` is 1 per image at any size up to 400×400. Pro Flash create, edit or inpaint at 192×160 is 6; `inpaint_image` is 10. Neither premium tool was used.
  - House: 4 pixflux img2img runs (2 strengths × with and without the concept palette, one seed). Garden: 1 crop strip. Reserve left unspent: 7.
- **VIS-002:** the working-tree diff, leaving out the two files this task edits (`tools/art003_wide.gd`, `make_blueprint.py`), still hashes `f52e5ae0…`. `stash@{0}` is present.
- **Saves:** slots 1–3 hash the same before and after (`builds/wip_backup/saves_before_wb.txt`, `saves_after_wb.txt`). Test slot 8's last write is still 2026-11-02.
- **Clean renders:**
  - BEFORE is a `git archive` export of HEAD `f8c51f9` (Batch A as committed, `art=w3`).
  - AFTER is the same export plus only the Batch B files: the tool, the blueprint generator, `blueprint_wide_v1b_w3b.txt`, `house_w3b.png`, `bed_w3b.png`, `crops_w3b.png`.
  - Neither has the VIS-002 work.
- **Collision:** every run logged "collision restored to the game's own check".

## Batch A follow-ups
### Oak
Kept as it is (the golden-orange Oak D canopy). No credits spent on it.

### Pond shore
- `make_blueprint.py OUT 1 1 w3b`: the north coves (row 28) and the row below move one row south. Row 28 is now grass all along the orchard's south fence (row 27).
- Kept: both coves, the north-east point, the south-west lobe, the dock notch, the dock. The generator still asserts the longest straight shore run: **3 tiles**.
- The north cove's reeds and cattails move down with it (+1 row). The lily pads stay.
- `pond.png` shows it whole at 50% and at 100% along the fence.

### Lantern post
- Layout B's porch post moves from (43, 13), on the porch-to-well leg, to (47, 13): the other side of the porch path, beside the east dressing. Its light moves with it (same energy, same falloff).
- **Walk:** the route (porch → well → oak → garden gates and cross walk → road → dock end), day and night.
  - **No leg skipped**: "route legs skipped: []" both times.
  - Batch A skipped (44, 14) after a 1.5 s stall.
  - About 25 s at 30 fps (Batch A: 26.9 s with the stall).
  - `walk_day.gif`, `walk_night.gif` (60% crops at half size, 6 fps), 12-frame grids in master 4.

### Grass A/B
- `grass=1` / `grass=2` brighten grass-coloured ground pixels by ×1.15 / ×1.30 in the bake. A pixel counts as grass where green ≥ 0.92 × red and green > 1.25 × blue. Paths, soil, bark, water and litter keep their colours.
- Unchanged: lantern energy and falloff, the R3-1 grade, the game's darkness value.
- Probe on open grass at (32, 24), tin lantern, pixels in the pool by ground:

| Grass | Day mean | Night mean | Ring 0–1 tile | Ring 1–2 | Ring 2–2.5 |
| --- | --- | --- | --- | --- | --- |
| Current | 0.165 | 0.135 | 0.196 | 0.148 | 0.102 |
| G1 ×1.15 | 0.188 | 0.159 | 0.234 | 0.170 | 0.124 |
| G2 ×1.30 | 0.218 | 0.187 | 0.274 | 0.201 | 0.147 |
| Production grass (W3A) | 0.293 | – | – | – | – |

- **Reading:**
  - Both lift the pool on grass in proportion, as the Batch A diagnosis predicted.
  - G2's play area at night: 0.130 against 0.104 (V1-B). That is still well below the lantern pool (0.216), and the forest stays at 0.073.
  - That night rise comes from albedo, not from any lighting change. It is the owner's call whether it is too much.
  - **By eye:** G1 keeps the autumn mood. G2 starts to read as summer green in V1-B by day. **My recommendation is G1.**

## Restored farmhouse alternative (A)
- **Init** (`house/compose_init.py` → `init.png`):
  - concept 02's house cropped and fitted into the locked 192×160 frame, with its door landing on x 96;
  - the wall band repainted by hand at the locked positions: windows centred (48, 112) and (143, 112), door, porch posts, footing ending y 149, steps.
  - A guide for PixelLab only; it is smooth-scaled and never used as a sprite.
- **Generation:**
  - four pixflux img2img runs, seed 701: strength 250 or 170, each with the concept palette and with a free palette (`house_closeups.png`, bottom rows).
  - **C chosen:** strength 170, concept palette. It has the clearest cross-gable with timber framing, a stone chimney, slate-blue courses, shed-roofed side wings, a covered porch on posts, and flower boxes.
  - A and B (250) kept a flat porch slab and orange chimneys. D's walls went pink.
- **Hand registration** (`house/register.py` → `house_w3b.png`):
  1. Up 1 px, so the footing ends at y 149 (it ended at 150).
  2. The chimney: a wooden board the generator put on top is replaced with stone carried up from the stack, a stone cap and a flue.
  3. The gable: a lit window painted into a blank board, in the front windows' own colours.
  4. A loose board hanging off the left wing is removed, and the edge outlined.
  5. The steps: three stone treads from y 150 to the bottom edge, from the generated step's colours.
  - **2,229 of 20,144 sprite pixels changed (11.1%)**, under the plan's 15% rejection line. Most of that is cleared area (the board and the old step rows): `house_w3b_diff.png`.
- **Alignment** (`house/measure.py`):

| Landmark | Locked | Production | Batch B |
| --- | --- | --- | --- |
| Sprite | 192×160 | 192×160 | 192×160 |
| Door / steps centre x | 96 | 96.0 | 96.5 |
| West window centre | (48, 112) | (49.0, 114.0) | (48.5, 111.5) |
| East window centre | (143, 112) | (145.5, 114.0) | (143.5, 112.0) |
| Wall line (last row) | 149 | 149 | 149 |
| Steps | to the bottom edge | y 150–159 | y 150–159 |
| Walls x | footprint 8..184 | 11..180 | 10..188 |

  The window, porch and spill lights use the existing constants, unchanged.
- **Visual compromises (documented, not hidden):**
  - **Side wings:** the concept's lower wings with firewood under them are shallow here: at 192 px wide the main block and the porch take the width. Firewood stays as separate dressing sprites, not wings.
  - **East edge:** the walls run to x 188, 4 px past the footprint's east edge (production ends at 180). Art only: collision is the unchanged 11×7 footprint, and the overhang sits over the east dressing tile.
  - **Porch:** shallower than the concept's (a roof on posts, no deep porch floor), because the steps must stay inside the sprite's bottom 10 rows.
  - **Wall colour:** lighter warm timber than the concept's dark weathered boards. The house measures brighter: day 0.155 → 0.222, night 0.119 → 0.198.
  - **Windows by day:** the glass is painted warm, so the windows read lit by day too. Production has curtains by day. A day or unlit variant would be a small hand edit (for production only).
  - **Roof:** the slate reads slightly green under the concept palette; the concept's is blue-black.
  - **Chimney:** off-centre right as in the concept, but with no smoke (not in scope).
- **Dressing:** reuse only. The existing firewood, barrel, crate and flower pot, plus three pumpkins (`crops_b_clean`) beside the steps.

## Garden (B)
- **Beds** (`garden/make_bed.py` → `bed_w3b.png`, 112×64, no new generation):
  - the R2 bed covered 6×3 of each 7×4 bed. It is now widened and deepened to all 7×4 tiles by repeating its own middle columns and soil rows.
  - Red specks calmed to a loam brown. Three darker furrows, one per crop row.
- **Crops** (`garden/crops_gen.png` → `crops_w3b.png`, 1 credit):
  - eight 16×32 cells: corn, pumpkin, pole beans, cabbage, kale, squash, turnip, sunflower. The shared soil line under them is removed.
  - Every column of every furrow is planted: 3 rows × 7 per bed, 84 crops.
  - Tall crops (corn, beans, sunflower) in each bed's north row; low crops (pumpkin, cabbage, squash, turnip) in the south row by the walkway.
  - Kale isn't used: it came out grey.
- **Fences:** north–south runs now draw a rail between posts: the strip's top rail turned on end, built in the tool from `src/fence.png`. W-2 drew posts only. This applies to the orchard fence too.
- **Walkways:**
  - the garden's central cross (column 51 and row 24) gets the worn-stone overlay already used round the well;
  - the outer walkway stays trodden dirt.
- **Kept:** the two-tile gates, the walkways, collision (beds block, walkways and gates don't), the corn and trellis along the north fence, the pumpkins by the west gate. The walk passes both gates and the cross walk.
- **At night:** pumpkins, squash and cabbage keep their shapes in the lantern pool. Beans and corn go dark. The lantern pool's share above 0.12 in V2 drops 76% → 63%, because more of the pool now falls on crops and bed frames than on bare path.

## Measurements (diagnostics only; HUD hidden; regions from this layout)
Each cell: mean luma (share of pixels above 0.12).

| View | Time | Version | Lantern pool | Play area | Oak | House | Forest | Whole frame |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1-B | day | Batch A | – | 0.168 (68%) | 0.276 (77%) | 0.155 (62%) | 0.133 (49%) | 0.183 (67%) |
| V1-B | day | Batch B | – | 0.168 (68%) | 0.277 (77%) | 0.222 (71%) | 0.136 (51%) | 0.197 (69%) |
| V1-B | day | Batch B, production house | – | 0.169 (68%) | 0.278 (77%) | 0.153 (62%) | 0.135 (50%) | 0.184 (67%) |
| V1-B | day | Batch B + G1 | – | 0.186 (81%) | 0.276 (77%) | 0.222 (71%) | 0.143 (58%) | 0.207 (77%) |
| V1-B | day | Batch B + G2 | – | 0.204 (89%) | 0.281 (77%) | 0.222 (71%) | 0.149 (61%) | 0.218 (81%) |
| V1-B | night | Batch A | 0.177 (60%) | 0.106 (26%) | 0.161 (52%) | 0.119 (36%) | 0.064 (12%) | 0.120 (33%) |
| V1-B | night | Batch B | 0.179 (60%) | 0.104 (25%) | 0.163 (53%) | 0.198 (49%) | 0.065 (12%) | 0.134 (35%) |
| V1-B | night | Batch B, production house | 0.169 (58%) | 0.105 (25%) | 0.164 (53%) | 0.122 (38%) | 0.065 (13%) | 0.120 (34%) |
| V1-B | night | Batch B + G1 | 0.196 (71%) | 0.117 (32%) | 0.164 (53%) | 0.198 (49%) | 0.070 (13%) | 0.141 (40%) |
| V1-B | night | Batch B + G2 | 0.216 (78%) | 0.130 (41%) | 0.160 (52%) | 0.199 (49%) | 0.073 (13%) | 0.148 (45%) |
| V5 | day | Batch A | – | 0.175 (74%) | 0.206 (69%) | 0.144 (61%) | 0.098 (18%) | 0.172 (72%) |
| V5 | day | Batch B | – | 0.174 (73%) | 0.208 (68%) | 0.241 (70%) | 0.091 (13%) | 0.186 (72%) |
| V5 | day | Batch B, production house | – | 0.174 (73%) | 0.207 (68%) | 0.145 (62%) | 0.083 (8%) | 0.172 (71%) |
| V5 | night | Batch A | 0.308 (82%) | 0.102 (24%) | 0.109 (39%) | 0.123 (36%) | 0.037 (0%) | 0.115 (30%) |
| V5 | night | Batch B | 0.308 (83%) | 0.101 (24%) | 0.117 (41%) | 0.216 (57%) | 0.039 (0%) | 0.129 (33%) |
| V5 | night | Batch B, production house | 0.304 (84%) | 0.101 (24%) | 0.117 (41%) | 0.122 (36%) | 0.037 (0%) | 0.115 (30%) |
| V2 | day | Batch A | – | 0.196 (79%) | – | – | 0.109 (36%) | 0.193 (78%) |
| V2 | day | Batch B | – | 0.190 (76%) | – | – | 0.108 (36%) | 0.187 (74%) |
| V2 | day | Batch B + G1 | – | 0.196 (81%) | – | – | 0.112 (38%) | 0.193 (79%) |
| V2 | day | Batch B + G2 | – | 0.203 (85%) | – | – | 0.115 (39%) | 0.200 (83%) |
| V2 | night | Batch A | 0.202 (76%) | 0.117 (40%) | – | – | 0.052 (12%) | 0.118 (41%) |
| V2 | night | Batch B | 0.196 (63%) | 0.113 (34%) | – | – | 0.052 (12%) | 0.114 (35%) |
| V2 | night | Batch B + G1 | 0.195 (63%) | 0.117 (36%) | – | – | 0.054 (13%) | 0.118 (37%) |
| V2 | night | Batch B + G2 | 0.196 (62%) | 0.122 (41%) | – | – | 0.056 (14%) | 0.124 (41%) |
| V4 | day | Batch A | – | 0.165 (72%) | – | – | 0.116 (39%) | 0.160 (69%) |
| V4 | day | Batch B | – | 0.166 (72%) | – | – | 0.115 (39%) | 0.161 (69%) |
| V4 | night | Batch A | 0.148 (50%) | 0.088 (14%) | – | – | 0.057 (14%) | 0.088 (16%) |
| V4 | night | Batch B | 0.160 (54%) | 0.088 (14%) | – | – | 0.057 (14%) | 0.089 (16%) |

| View | Time | Version | Frame ms, median | p95 | Render CPU ms | Render GPU ms | Draw calls | Objects | Lights on |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1-B | day | Batch A | 3.34 | 4.53 | 1.05 | 1.36 | 721 | 1491 | 0 |
| V1-B | day | Batch B | 2.87 | 4.69 | 1.1 | 1.46 | 726 | 1509 | 0 |
| V1-B | night | Batch A | 2.89 | 3.84 | 1.03 | 1.94 | 734 | 1521 | 6 |
| V1-B | night | Batch B | 2.99 | 4.38 | 1.05 | 2.03 | 737 | 1525 | 6 |
| V5 | day | Batch A | 2.79 | 4.6 | 1.1 | 1.45 | 739 | 1603 | 0 |
| V5 | day | Batch B | 2.92 | 4.24 | 1.02 | 1.35 | 741 | 1614 | 0 |
| V5 | night | Batch A | 3.35 | 4.46 | 1.1 | 2.21 | 747 | 1606 | 6 |
| V5 | night | Batch B | 2.99 | 4.21 | 1.06 | 2.04 | 752 | 1628 | 6 |
| V2 | day | Batch A | 3.12 | 5.17 | 1.13 | 1.35 | 795 | 1478 | 0 |
| V2 | day | Batch B | 3.01 | 3.96 | 1.07 | 1.35 | 803 | 1501 | 0 |
| V2 | night | Batch A | 3.37 | 4.28 | 1.13 | 2.12 | 807 | 1469 | 6 |
| V2 | night | Batch B | 2.98 | 4.1 | 1.11 | 1.92 | 826 | 1508 | 6 |
| V4 | day | Batch A | 2.84 | 3.68 | 0.97 | 1.3 | 703 | 1495 | 0 |
| V4 | day | Batch B | 2.75 | 3.83 | 1.06 | 1.37 | 704 | 1495 | 0 |
| V4 | night | Batch A | 2.75 | 3.7 | 1.05 | 1.81 | 705 | 1497 | 6 |
| V4 | night | Batch B | 2.82 | 4.04 | 0.99 | 1.78 | 704 | 1495 | 6 |

- **Draw calls:** +8 to +19 in V2 (the planted beds, a sprite per crop) and +2 to +5 in V1-B and V5 (the porch pumpkins and the fence rails). About 0 in V4.
- **Frame times:** within the ±1 ms run-to-run noise found in Batch A.
- **Grass lift:** a one-time pixel loop over the baked chunks at load (its time wasn't measured). Nothing per frame: the draw calls and frame times of G1 and G2 match Batch B's.
- **The house:** the same size; the same three lights at the same positions.

## Asset consistency
- **The house and crops** are now PixelLab, generated with the ART-003 concept palette, like the oak, ground and props. That leaves the well and the firewood store as the SpriteCook objects in V1-B and V5.
- **The house's outline** is the generator's black single-colour outline. It is slightly heavier than the selective outlines of the props round it.
- **Source sizes:** house 192×160; crops 128×32 (eight 16×32 cells); bed 112×64. Every placement is whole-pixel at 3×, and nothing is resampled. The init image and the concept crops are reference only.

## Provisional self-score (rubric weights; Batch A: self 64.75, ChatGPT 64.25)
| Dimension | Weight | W-3A | W-3B | Evidence |
| --- | --- | --- | --- | --- |
| Concept fidelity | 25% | 7.0 | 7.5 | [Observed] V1-B and V5 now show the concept's cross-gabled, timber-framed house with a stone chimney and covered porch. V2 has full beds in rows. The wings and porch are shallower, and the walls lighter. |
| Environmental richness | 20% | 6.0 | 6.5 | [Observed] Every furrow planted, porch pumpkins, fence rails, the stone cross walk. V3 and the road are still thin. |
| Lighting and atmosphere | 20% | 6 | 6 | [Measured] R3-1 unchanged. The house is brighter at night (0.198 vs 0.122), partly because its windows are painted lit. The grass A/B is offered, not adopted. |
| Asset consistency | 15% | 5.5 | 6.0 | [Observed] The house and crops join the PixelLab family. The well is still SpriteCook; the house's outline is heavier; the windows are lit by day. |
| Gameplay readability | 10% | 7.5 | 7.5 | [Recorded] The full route with no skip. Beds block and walkways stay open. Beans and corn go dark at night. |
| Technical quality | 10% | 7.5 | 7.5 | [Measured] Landmarks within 0.5 px, 11.1% hand-edited, +0–19 draw calls, 5 of 12 credits. Saves and VIS-002 verified. |
| **Total** | | **64.75** | **67.75** | 7.5×0.25 + 6.5×0.20 + 6×0.20 + 6×0.15 + 7.5×0.10 + 7.5×0.10 |

## Open points for the owner
1. The Batch B house as the prototype's Restored candidate: keep it, or ask for changes (darker walls, unlit day windows, deeper wings). Not a production replacement.
2. Grass: G1 (my recommendation), G2, or keep the current one in later batches.
3. The garden's crop mix (beans and corn read dark at night).
4. Authorize the commit and push of this package.
