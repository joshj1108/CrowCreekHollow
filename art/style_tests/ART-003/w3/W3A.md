# ART-003 W-3 Batch A: oak canopy, pond and dock

Status: for the owner's and ChatGPT's review. **Non-production.** The owner approved Batch A only on 2026-11-03: sections 2, 3 and 7 of `AI_COLLAB/ART_003_W3_ART_PLAN.md`.
- **Not changed:** production art (`ground_water` included), `main.gd`, saves, camera, scaling, the live layout, `DESIGN.md`, `spritecook-assets.json`.
- **Not started:** P-1, Batches B and C.
- **Not committed:** nothing is committed or pushed. The uncommitted VIS-002, `.import`, `.uid`, `project.godot` and `main.tscn` changes are untouched.

Run: `tools/art003_wide.gd mode=wide layout=b art=w3` (layout B only). Without `art=w3` the tool draws W-2 exactly as before, and the blueprint generator writes layouts A and B byte-identical to the committed files.

## W-0 checks
- **PixelLab:** the MCP tools loaded. Balance 4,987 generations before, 4,969 after: **18 used**.
  - Oak: 12 (two Pro Flash inpaints at 6 each).
  - Tilesets: 3, one of them unused. A variant I cancelled had already finished, so it was charged.
  - Shore strip and two docks: 3.
- **VIS-002:** the working-tree diff, leaving out the three files this task edits, still hashes `f52e5ae0…`. `stash@{0}` is present.
- **Saves:** slots 1–3 hash the same before and after (`builds/wip_backup/saves_before_wa.txt`, `saves_after_wa.txt`). Test slot 8's last write is 2026-11-02.
- **Clean renders:**
  - BEFORE is a `git archive` export of HEAD `e26b1b4`.
  - AFTER is the same export plus only the W-3 files: the tool, the blueprint generator, `blueprint_wide_v1b_w3.txt` and `w3/`.
  - Neither has the VIS-002 work.
- **Collision:** every run logged "collision restored to the game's own check".

## Oak D canopy (section 2)
- **Mask** (`oak/make_mask.py` → `oak/mask1.png`): the crown above row 128, minus the thick limbs. Thick limbs are brown pixels that survive a radius-2 erosion, grown back by 3 so their outlines stay.
  - Kept: the trunk, the four major limbs, the roots and the stones.
  - Regenerated: the twigs and the small leaf clumps.
- **Inpaint:** PixelLab `inpaint_image_pro_flash`, 192×192, two seeds. **Seed 501 chosen:** five to six large golden-orange masses, darker undersides, outlines, and the limbs showing between the masses. Seed 502 hid most of the limbs.
- **Cleanup** (`oak/cleanup.py`):
  - 132 seam pixels, where a kept limb met transparent canopy, closed with the oak's own outline colour.
  - A 93-pixel twig fragment that the mask had kept, now buried in the upper-left mass, repainted from the foliage round it. It is added to `oak/mask_final.png`.
- **Identity:** **0 pixels** differ from `r3/oak_d.png` outside `mask_final.png`. Rows 128–191 (trunk base, roots, stones) are identical.
- **Litter:** the drift under the oak is smaller (within 1 tile of the oak's base and boulders, noise above 0.3, was 2 tiles and 0.15). Placement only.
- **Fit in V1-B:** the crown doesn't reach the chimney or the well. The 2-tile gap to the house stays open and walkable.
- **Brightness:** the oak's region is brighter. At night 0.125 → 0.163 (32% → 52% of pixels above 0.12); by day 0.218 → 0.278.
  - It is more saturated than "muted" (C-04 territory, as the plan expected). The R3-1 grade isn't changed for it.

## Pond, shore and dock (section 3)
- **Outline** (`wide/make_blueprint.py OUT 1 1 w3` → `wide/blueprint_wide_v1b_w3.txt`):
  - water spans per row: two coves on the north shore, a point to the north-east, and a lobe running south-west;
  - a notch where the dock's land end meets the bank.
  - The generator asserts the longest straight shore run along rows and columns: **3 tiles**.
  - The road now ends one tile short of the dock instead of running into the forest. That keeps every tile corner to two ground types, since a PixelLab Wang tile holds only two.
- **Ground:**
  - two grass→water sets (`pond/water_tileset`, brown mud bank; `pond/water2_tileset`, dark bank), both chained to the ART-003 grass base tile `9ed879f8` and to one water fill (`03367f67`);
  - a slow noise picks one set per stretch of shore, so the banks vary in runs, not tile by tile;
  - the open water uses the shared fill, mirrored.
  - Baked into the existing ground chunks, so it adds no draw calls. **Production `ground_water` is untouched**; the prototype simply doesn't draw it with `art=w3`.
  - Optional water→deep-water set: **not made**. The pond is at most 15×8 tiles and reads without it.
- **Shore props** (`pond/shore_strip.png`, 7 pieces):
  - reeds, cattails and rushes in three groups: the north cove, the south-west bank, beside the dock;
  - five lily pads on the water;
  - a rock at the west edge and one at the east point.
  - The strip lacks two pieces the prompt asked for: a flowering lily pad and a fallen reed clump.
- **Dock** (`pond/dock.png` = `dock_b`, 32×64):
  - planks across, posts, a mooring post with rope;
  - on its 2×4 `K` tiles, lying flat under the farmer.
  - `K` is water underneath but walkable, in the prototype's in-memory collision only; the water tiles stay blocked.
  - `dock_a` was rejected: a plank walk about 18 px wide.
  - `dock_b` was generated without the forced concept palette. Its greys sit within the prototype's range by eye; I haven't measured it.
- **Known issue:** the two north lobes reach row 28, right under the orchard's south fence (row 27). The bank meets the fence posts with no grass strip between (see the V4 close-ups).

## Lantern on grass (section 7: measurement only, nothing changed)
Tin lantern, unchanged energy 0.5, farmer standing still, 12:00 vs 21:30 (R3-1 night). Pixels inside the 2.5-tile pool, split by the ground under them; the farmer's sprite is left out (`probe` option).

| Spot | Ground | 12:00 mean | 21:30 mean | Night / day | Ring 0–1 tile | Ring 1–2 | Ring 2–2.5 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Prototype grass (32, 24) | grass | 0.161 | 0.132 | 0.82 | 1.29 | 0.90 | 0.62 |
| Prototype road (40, 34.6) | grass verge | 0.177 | 0.126 | 0.71 | 1.22 | 0.82 | 0.61 |
| Prototype road (40, 34.6) | path | 0.223 | 0.215 | 0.96 | 1.31 | 0.97 | 0.64 |
| Production grass (30.5, 35.5) | grass | 0.293 | 0.092* | – | – | – | – |

\*Production is the game's own night, not R3-1, so its night/day ratio can't be compared. Its daytime luma is the albedo comparison.

**Reading:**
- **The falloff isn't the cause.** In the same pool, grass and path brighten by close to the same factor at each distance: 1.22 vs 1.31 at the centre, 0.82 vs 0.97, 0.61 vs 0.64 at the edge.
- **The cause is the ground's own brightness.** The pool reads weaker on grass because the prototype grass is dark: 0.16–0.18 by day, against the path's 0.22 and production grass's 0.29.
- **The grade adds a little.** The path keeps a slightly higher ratio in the middle ring, which fits R3-1's contrast (1.12) pressing the darker grass down more.
- **So:** the fix is an art one, a lighter prototype grass base. No lantern or night change is needed. Any change is for a later decision, not this batch.

## Walk route
- **Route:** W-2's route on layout B, with the end changed to follow the road to its end, step onto the bank, and walk up the dock to its far end. 26.9 s at 30 fps, day and night (`review/walk_*.gif`, 12-frame grids in master 3).
- **One leg skipped, both times:** the waypoint (44, 14) just after the porch.
  - Layout B's lantern post at (43, 13) stands on that line, so the walker stalls for 1.5 s and then goes on to the next waypoint.
  - The same skip happens on the BEFORE tree (clean HEAD, layout B). It comes from layout B and W-2's route, which was written for layout A; it isn't from W-3.
  - Every W-3 leg, including the dock, was reached.

## Measurements (diagnostics only; HUD hidden; regions from this layout)
| View | Time | Version | Lantern pool | Play area | Oak | House | Forest | Whole frame |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1-B | night | BEFORE (W-2) | 0.182 (61%) | 0.105 (26%) | 0.125 (32%) | 0.121 (37%) | 0.066 (13%) | 0.112 (30%) |
| V1-B | night | AFTER (W-3A) | 0.173 (60%) | 0.105 (26%) | 0.163 (52%) | 0.120 (37%) | 0.064 (11%) | 0.120 (34%) |
| V1-B | day | BEFORE (W-2) | – | 0.172 (70%) | 0.218 (65%) | 0.154 (62%) | 0.135 (51%) | 0.171 (66%) |
| V1-B | day | AFTER (W-3A) | – | 0.169 (68%) | 0.278 (77%) | 0.155 (62%) | 0.135 (49%) | 0.184 (67%) |
| V3 | night | BEFORE (W-2) | 0.197 (75%) | 0.106 (29%) | 0.085 (26%) | – | – | 0.110 (31%) |
| V3 | night | AFTER (W-3A) | 0.197 (75%) | 0.104 (28%) | 0.083 (26%) | – | – | 0.108 (30%) |
| V3 | day | BEFORE (W-2) | – | 0.176 (75%) | 0.158 (59%) | – | – | 0.176 (74%) |
| V3 | day | AFTER (W-3A) | – | 0.175 (74%) | 0.157 (59%) | – | – | 0.174 (74%) |
| V4 | night | BEFORE (W-2) | 0.165 (57%) | 0.093 (17%) | – | – | 0.056 (14%) | 0.094 (19%) |
| V4 | night | AFTER (W-3A) | 0.149 (50%) | 0.088 (14%) | – | – | 0.057 (14%) | 0.088 (16%) |
| V4 | day | BEFORE (W-2) | – | 0.173 (77%) | – | – | 0.116 (38%) | 0.168 (74%) |
| V4 | day | AFTER (W-3A) | – | 0.164 (72%) | – | – | 0.116 (39%) | 0.160 (69%) |
| V5 | night | BEFORE (W-2) | 0.311 (82%) | 0.102 (25%) | 0.092 (27%) | 0.125 (36%) | 0.038 (0%) | 0.115 (30%) |
| V5 | night | AFTER (W-3A) | 0.308 (83%) | 0.102 (24%) | 0.118 (41%) | 0.123 (36%) | 0.040 (0%) | 0.116 (30%) |
| V5 | day | BEFORE (W-2) | – | 0.176 (74%) | 0.171 (61%) | 0.145 (61%) | 0.111 (37%) | 0.171 (72%) |
| V5 | day | AFTER (W-3A) | – | 0.175 (74%) | 0.210 (68%) | 0.145 (61%) | 0.090 (11%) | 0.173 (72%) |

Each cell: mean luma (share of pixels above 0.12).
- **V4:** darker in the lantern pool and the play area, because the farmer's spot at (14, 27.5) now has water close below it, where W-2 had grass.
- **V5 forest by day:** lower because the bigger crown now takes the bright pixels it covers into the oak region.
- **V3 house:** a few stray edge pixels in V3, left out of the table.

| View | Time | Version | Frame ms, median | p95 | Render CPU ms | Render GPU ms | Draw calls | Objects | Lights on |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1-B | night | BEFORE | 3.03 | 3.81 | 1.05 | 1.96 | 728 | 1504 | 6 |
| V1-B | night | AFTER | 3.47 | 6.42 | 1.09 | 2.48 | 727 | 1502 | 6 |
| V1-B | day | BEFORE | 3.29 | 5.16 | 1.09 | 1.42 | 728 | 1515 | 0 |
| V1-B | day | AFTER | 2.75 | 3.95 | 1.0 | 1.35 | 729 | 1520 | 0 |
| V3 | night | BEFORE | 2.57 | 3.56 | 0.96 | 1.72 | 712 | 1442 | 6 |
| V3 | night | AFTER | 2.5 | 3.28 | 0.96 | 1.67 | 714 | 1444 | 6 |
| V3 | day | BEFORE | 2.65 | 4.97 | 1.03 | 1.37 | 707 | 1442 | 0 |
| V3 | day | AFTER | 2.48 | 3.77 | 0.95 | 1.2 | 707 | 1442 | 0 |
| V4 | night | BEFORE | 2.73 | 3.77 | 1.01 | 1.77 | 689 | 1480 | 6 |
| V4 | night | AFTER | 3.56 | 5.23 | 1.07 | 1.77 | 705 | 1497 | 6 |
| V4 | day | BEFORE | 3.81 | 7.23 | 1.21 | 1.5 | 687 | 1478 | 0 |
| V4 | day | AFTER | 2.47 | 3.25 | 0.93 | 1.25 | 703 | 1495 | 0 |
| V5 | night | BEFORE | 2.86 | 3.66 | 1.05 | 1.92 | 748 | 1609 | 6 |
| V5 | night | AFTER | 3.15 | 5.14 | 1.1 | 2.19 | 747 | 1607 | 6 |
| V5 | day | BEFORE | 2.51 | 3.29 | 1.0 | 1.31 | 736 | 1592 | 0 |
| V5 | day | AFTER | 2.61 | 3.94 | 1.09 | 1.39 | 737 | 1597 | 0 |

- **Draw calls are the stable signal:** +16 in V4 (the dock, the shore props and the lily pads), about 0 elsewhere.
- **Frame times vary by ±1 ms in either direction** between single runs of the same scene (V4 day got faster, V4 night slower), so they show no W-3 cost either way.

## Provisional self-score (rubric weights; W-2 self-score 61.75, ChatGPT 60.0)
| Dimension | Weight | W-2 | W-3A | Evidence |
| --- | --- | --- | --- | --- |
| Concept fidelity | 25% | 6.5 | 7.0 | [Observed] The oak reads as the concept's golden landmark in V1-B, V3 and V5. V4 has a real pond with reeds and a dock. The house is still the production one. |
| Environmental richness | 20% | 5.5 | 6.0 | [Observed] The pond has coves, banks, reeds, lily pads and a dock. V3 and the road are still thin; the garden is unchanged. |
| Lighting and atmosphere | 20% | 6 | 6 | [Measured] R3-1 unchanged; play-area levels hold. The lantern on grass is diagnosed (albedo), not fixed. |
| Asset consistency | 15% | 5 | 5.5 | [Observed] The water is now in the PixelLab ground family. The oak's saturation is above "muted". The house, well and crops are still SpriteCook. |
| Gameplay readability | 10% | 7.5 | 7.5 | [Observed in recordings] The dock walks end to end and the water blocks. One layout-B waypoint is skipped, the same as before. |
| Technical quality | 10% | 7.5 | 7.5 | [Measured] The oak's identity is verified pixel by pixel. The pond is baked (+0 draw calls) and the props add +16. Clean renders, saves and VIS-002 verified. |
| **Total** | | **61.75** | **64.75** | 7×0.25 + 6×0.20 + 6×0.20 + 5.5×0.15 + 7.5×0.10 + 7.5×0.10 |

Still below the provisional 65 band. The remaining gap is mostly the house (Batch B), the garden, the orchard and the in-between spaces.

## Open points for the owner
1. Keep the fuller oak's saturation, or tone the crown towards "muted" (C-04)?
2. Pull the pond's north lobes one row south, so grass shows under the orchard fence?
3. Whether the lantern finding (dark prototype grass) feeds a lighter grass base in a later batch.
4. Layout B's route skip at (43, 13): move the lantern post, or change the route? It's a prototype-only layout point.
