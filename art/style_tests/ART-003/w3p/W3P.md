# ART-003 W-3 polish: farmhouse, garden and grass (targeted, non-generative)

Status: for the owner's and ChatGPT's review. **Non-production.** Approved by the owner on 2026-11-03 after ChatGPT's Batch B image review (board, `77aa098`), which recommended these directions (owner confirmed all six):
1. Candidate C stays the preferred non-production house.
2. G1 is the preferred prototype grass.
3. The four-bed garden and the new crops stay.
4. The corrected pond shore stays.
5. R3-1 night stays unchanged.
6. Batch C and production integration are deferred.

- **Not changed:** production art, `main.gd`, gameplay, saves, the live farm layout, camera, scale, `DESIGN.md`, `spritecook-assets.json`, the R3-1 grade, lantern energy, the game's darkness value.
- **Not done:** house stages 0–2, P-1 night integration, Batch C, G2.
- **PixelLab:** **0 credits** used. Everything here is a palette remap, hand edits or a re-arrangement of existing art.
- **Committed and pushed** at the owner's request, before ChatGPT's review; the links are on the board. The uncommitted VIS-002, `.import`, `.uid`, `project.godot` and `main.tscn` changes are left out.

Run: `tools/art003_wide.gd mode=wide layout=b art=w3p` (on top of `art=w3b`). Switches: `wall=a|b|c` (the house's wall variant, default b), `grass=1` (G1). `art=w3b` and older modes draw exactly as before.

## Checks
- **VIS-002:** the working-tree diff, leaving out `tools/art003_wide.gd` and `make_blueprint.py`, still hashes `f52e5ae0…`. `stash@{0}` is present.
- **Saves:** slots 1–3 match `builds/wip_backup/saves_after_wb.txt`. Only test slot 8 was written (18:18, by these renders).
- **Clean renders:**
  - BEFORE is a `git archive` export of HEAD `77aa098` (Batch B as reviewed, `art=w3b`).
  - AFTER is the same export plus the edited tool and `w3p/`.
  - Neither has the VIS-002 work.
- **Settings:** 1280×720; 12:00 and 21:30; sunny; autumn; sanity 100; the same camera positions as Batch B.

## Farmhouse (`house/polish.py`)
Candidate C (`w3b/house/house_w3b.png`) is repainted. Its 33-colour palette is remapped colour by colour within regions; nothing is resampled.

- **Walls:** the board family is darkened, and each board segment gets one of four tones, with sparse dark grain, so the siding reads worn rather than printed. Three variants:
  - **a**, warm weathered: ×0.74;
  - **b**, dark weathered: ×0.62, **chosen**;
  - **c**, grey weathered: half saturation, ×0.70.
- **Roof:** the slate colours above the eave are remapped to a blue-black ramp, `(36,40,52)` to `(88,94,108)`, with 14% darker worn shingles.
  - The purple flecks `(90,58,106)` and the olive flecks are gone.
  - The neutral and warm greys that read green beside the teal are now blue.
  - The chimney stone is unchanged.
- **Windows:**
  - **By day:** the glass is unlit, a dark blue-grey with a sky-reflection band, with curtains at the outer edges of each front window. The gable window has glass only.
  - **At night:** the glass stays Batch B's lit glass, and the tool swaps sprites by time.
  - The window, porch and spill lights use the same constants and positions as before.
- **Porch:**
  - A plank deck runs between and just past the posts (x 62–128, y 140–145), three boards deep, with a dark front edge (y 146).
  - Batch B's flat landing below it (x 82–111, y 147–149) is now stone, copied from the footing's own pattern.
- **Steps:** three stone treads (a pale top row, mid-grey risers with joints) replace the tan and warm-grey treads.
- **Dressing,** all existing art, on the same `d` tiles: woodstore firewood against both wings, a chopping block, barrels, a crate, two flower pots at the front, and five groundcover flower clumps along the footing. The three porch pumpkins are kept.
- **Kept exactly:** 192×160, silhouette, door x 96.5, windows (48.5, 111.5) and (143.5, 112.0), wall line y 149, steps y 150–159, collision footprint, light positions.
- **Changed pixels:** 62.9% by day and 58.0% by night, against Batch B's 11.1% of hand registration. This is far over the old 15% rejection line, but that line was for reshaping. Here almost every change is a colour swap, and the only reshaped areas are the deck, the landing and the treads.

| Region (mean luma, share > 0.12) | Batch B | Polish |
| --- | --- | --- |
| House, V1-B day | 0.222 (71%) | 0.141 (49%) |
| House, V1-B night | 0.199 (49%) | 0.146 (34%) |
| House, V5 day | 0.235 (72%) | 0.146 (52%) |
| House, V5 night | 0.216 (55%) | 0.165 (39%) |
| Production house, V1-B day / night (Batch B record) | 0.153 / 0.122 | – |

The house is now close to the production house's brightness by day (0.141 against 0.153). At night it is a little brighter than production (0.146 against 0.122), because the lit glass is kept.

## Garden
- **Rows** (the tool, `art=w3p`):
  - Mixed rows grow in clumps of two or three (AABBB) instead of strict ABAB.
  - Most rows have one plant missing (picked or failed), never at a row's end.
  - Each plant takes one of three tones (×0.9, ×1.0, ×1.07) and sits up to ±0.15 tile off the line and ±0.08 tile off the row.
  - Each single-crop row stays one crop, so the families still read row by row.
- **Night contrast** (`garden/night_contrast.py` → `crops_w3p.png`):
  - The corn and pole-bean cells change colour only: their leaf greens step up one to two values, and the bean pole turns from dark brown to weathered grey wood.
  - 218 pixels change. The other six cells are untouched.
- **Kept:** the four 7×4 beds, the walkways, the gates, the stone cross walk, the fence rails, and collision (beds block; walkways and gates don't).

| V2, inside the corn and bean cells (mean, p90, share > 0.12) | Batch B | Polish |
| --- | --- | --- |
| Beans, night | 0.103, 0.166, 26% | 0.129, 0.242, 48% |
| Corn, night | 0.140, 0.288, 44% | 0.147, 0.302, 49% |
| Beans, day | 0.192, 0.287, 76% | 0.224, 0.378, 83% |
| Corn, day | 0.220, 0.410, 80% | 0.229, 0.417, 79% |

- **Reading:**
  - The beans gain the most: their poles now read at night.
  - The corn gains less. Its cells are mostly soil and the gold tassels it already had, so its leaves are only a small part of each cell.
  - By day the beans are slightly lighter but stay below the sunflowers and squash.

## Grass: current vs G1 (+15%), on the polish art
The same camera, season, hours, R3-1 night, lantern energy and darkness value. Only grass-coloured ground albedo differs.

| View | Time | Current: play area | G1: play area | Current: lantern pool | G1: lantern pool | Current: forest | G1: forest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V1-B | day | 0.168 (68%) | 0.185 (81%) | – | – | 0.134 (48%) | 0.142 (56%) |
| V1-B | night | 0.105 (25%) | 0.117 (32%) | 0.162 (56%) | 0.178 (66%) | 0.065 (12%) | 0.069 (12%) |
| V5 | night | 0.102 (25%) | 0.113 (34%) | 0.309 (82%) | 0.324 (86%) | 0.036 (0%) | 0.047 (0%) |
| V2 | night | 0.114 (36%) | 0.119 (38%) | 0.196 (65%) | 0.196 (65%) | 0.052 (12%) | 0.055 (13%) |

- **Reading:**
  - G1 lifts the play area about 10% at night and the lantern pool on grass in proportion. The forest edge stays at or below 0.069 outside V5's 0.047.
  - By eye it keeps the autumn mood.
  - **G1 remains my recommendation.**
- **V1-B night's lantern pool:** 0.180 in Batch B, 0.162 with the polish. That is not a lighting change: the pool circle at V1-B overlaps the house's wall, which is now darker.

## Walking route (polish + G1)
- The route: porch → well → oak → garden west gate and cross walk → south gate → road → dock end, day and night.
- **No legs skipped either time:** "route legs skipped: []".
- 759 frames at 30 fps (about 25 s) each time.
- `review/walk_day.gif`, `walk_night.gif` (60% crops at half size, 6 fps) and 12-frame grids in master 4.

## Performance (frame ms median / p95, draw calls, objects; lights on unchanged: 0 by day, 6 at night)
| View | Time | Batch B | Polish |
| --- | --- | --- | --- |
| V1-B | day | 3.21 / 4.18, 732, 1524 | 3.18 / 4.48, 729, 1514 |
| V1-B | night | 3.05 / 4.41, 737, 1525 | 3.03 / 4.07, 735, 1515 |
| V5 | day | 2.82 / 4.08, 741, 1620 | 2.90 / 4.28, 757, 1629 |
| V5 | night | 3.25 / 5.23, 751, 1627 | 3.10 / 4.18, 765, 1631 |
| V2 | day | 3.01 / 3.97, 808, 1516 | 3.04 / 4.47, 824, 1495 |
| V2 | night | 3.05 / 3.79, 826, 1508 | 2.92 / 4.04, 845, 1502 |

- **Draw calls:** +14 to +19 in V2 and V5. The per-plant tone is a different `modulate` per sprite, which breaks batching. V2 has fewer sprites (the gaps), but more calls.
- **V1-B:** −3 to −2. The V5 frame also takes in the porch's new flower clumps.
- **Frame times:** within the ±1 ms run-to-run noise.
- **Production:** baking the three tones into the crop sheet would remove the extra calls.

## Asset consistency
- **The house:** now uses the concept's dark-timber, blue-black palette, close to the oak's, ground's and props' PixelLab family. Its generator outline is still slightly heavier than the props'.
- **The crops:** corn and beans now sit nearer the other crops' value range.
- **SpriteCook pieces left:**
  - the well;
  - the woodstore, the porch firewood shelf: used on 2 of the 9 dressing tiles, against 3 in Batch B, so it is now the dressing's firewood;
  - the chopping block, also SpriteCook production art.
- **Sizes:** unchanged: house 192×160, crops 128×32, bed 112×64; every placement whole-pixel at 3×.

## Provisional self-score (rubric weights; Batch B: self 67.75, ChatGPT 68.25, kept separate)
| Dimension | Weight | W-3B self | Polish self | Evidence |
| --- | --- | --- | --- | --- |
| Concept fidelity | 25% | 7.5 | 8.0 | [Observed] Dark weathered walls, blue-black roof, unlit day windows, a porch deck and stone treads bring V1-B and V5 nearer the concept. The wings are still shallow. |
| Environmental richness | 20% | 6.5 | 7.0 | [Observed] Porch firewood, flower pots and flowers; rows with clumps, gaps and tone. V3 and the road are still thin. |
| Lighting and atmosphere | 20% | 6.0 | 6.0 | [Measured] R3-1 unchanged by design. The house is no longer lit by day, and its night glow is kept. |
| Asset consistency | 15% | 6.0 | 6.5 | [Observed] The house palette joins the concept family. The well, woodstore and chopping block are still SpriteCook, and the house's outline is heavier. |
| Gameplay readability | 10% | 7.5 | 8.0 | [Measured] Beans at night: share above 0.12 from 26% to 48%. The full route with no skip; collision unchanged. |
| Technical quality | 10% | 7.5 | 7.5 | [Measured] 0 credits; landmarks unchanged; +14 to +19 draw calls from per-plant tone; saves and VIS-002 verified. |
| **Total** | | **67.75** | **71.25** | 8×0.25 + 7×0.20 + 6×0.20 + 6.5×0.15 + 8×0.10 + 7.5×0.10 |

## Review package (`review/`)
- **Master 1,** `ART-003WP_master.png` (sheets at 61%): `house_views.png` (concept | Batch B | polish, V1-B and V5, day and night) and `house_closeups.png` (sprites at 3x with landmarks, the a/b/c variants, V5 at 100%).
- **Master 2,** `ART-003WP_master_2.png` (69%): `garden_views.png` (V2 day and night, three-way) and `garden_closeups.png` (V2 at 100%, crop cells at 4x).
- **Master 3,** `ART-003WP_master_3.png` (55%): `grass.png`, current vs G1.
- **Master 4,** `ART-003WP_master_4.png` (100%): `walk_day_frames.png`, `walk_night_frames.png`; the GIFs alongside.

## Open points for the owner
1. **Wall variant:** b (my pick), a, or c.
2. **The porch deck and stone treads:** keep as drawn, or ask for a deeper porch.
3. **The garden's variation:** enough, or too much (gaps and tone).
4. **Baking the crop tones:** do it before any production pass, to drop the extra draw calls.
5. **Commit and push:** authorize the commit and push of this package.
6. **Batch C:** whether to proceed.
