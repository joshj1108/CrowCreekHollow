# ART-003 Round 3: R3-2 to R3-5 slice refinement

Status: for ChatGPT's image-level review and the owner's decision. **Non-production.** The owner authorized R3-2 to R3-5 as prototype work on 2026-11-02, with the R3-1 night locked as the baseline.

- **Unchanged:** production scripts, scenes, shaders, art, saves, layout, camera, scale and gameplay. No lights were added.
- **P-1** (production night integration) remains **not approved** and was not started.

Baseline and method: `ROUND3.md` (R3-0 and R3-1). Plan: `AI_COLLAB/ART_003_ROUND3_PLAN.md`. Scoring: `AI_COLLAB/ART_REVIEW_RUBRIC.md`.

## How it was built and rendered
- **Tool:** `tools/art003_round3s.gd` (new). Its `mode=r3s` builds the refined slice. Every other mode and option falls through to `art003_round3.gd`, so production, Round 2 and R3-1 still render as before.
  - It reuses R3-1's locked night, region measurement, frame-time readout, forced visitor and forage, low sanity and Movie Maker walks.
  - `stage=2|3|4` builds only the steps up to that one, for the step-by-step sheet.
- **Changes to `art003_round3.gd`:** small and test-only. The measured oak can be set by a subclass; the R3-1 shade and haze apply to every mode except `r2`.
- **Renders:** from a clean checkout of `8b9c3d3`. No game file has changed since `4c47a58`, so the R3-0/R3-1 production, Round 2 and R3-1 frames are reused as they are.
  - The uncommitted VIS-002 work is untouched and in none of the images. The working-tree diff hash is unchanged (`f52e5ae0…`), and so is the snapshot stash.
- **Conditions:** the same as R3-0. 1280×720, `SCALE` 3, the new-game spot, HUD hidden, tin lantern, autumn; 12:00 and 21:30; sunny, rain, fog, sanity 8; the readability scene.
- **Measured regions:** the same fixed regions, except that the oak region follows the new oak's pixels. Oak numbers therefore cover different pixels from R3-1's.
- **Generations:** 13 PixelLab generations on the Tier 2 plan; 4,987 remain this cycle. Asset IDs, settings and rejects are in `r3/pixellab-assets.json`. Every prop shares Round 1's 32-colour concept palette and settings, and the tilesets chain from Round 1's grass and path base tiles.

## What each step changed

### R3-2 oak
- **Oak D:** `r3/oak_d.png`, 192×192 (12×12 tiles). PixelLab img2img from oak A, placed on a taller canvas so the crown has room.
  - The crown is no longer clipped. It is broad and asymmetric, with open, visible branching and selective leaf clusters. That is the "negative-space branching" ChatGPT asked for in Round 1.
  - The roots and twisted trunk are kept.
- **Rejected oaks:**
  - Oak C (stronger img2img): the crown is still cut flat.
  - Oak E (asked for a denser crown): no denser.
- **Boulders:** twelve separate, irregular mossy boulders (`r3/boulders.png`, seven shapes) scattered round the foot. Each is sorted on its own, replacing Round 2's flat, regular ring with its baked grass centre.
- **Leaves:** a drift of litter at the oak's foot.
- **Shelf fungus:** three hand-pixelled brackets on the trunk's edges (`r3/fungus.png`; no generation). The generated "fungus" came out as mushrooms.
- **Charms:** two charms hanging from the limbs (from `r3/oak_details.png`).
- **Still short of the concept:**
  - The crown's clusters read as round "puffs" rather than the concept's dense leaf masses.
  - The fungus and charms are small at game scale.
  - There are no crows and no ritual cloth.

### R3-3 ground and path
- **Path edges:** a second path set (`r3/path2_tileset`) with the same fills, mixed with Round 1's cell by cell. Edges no longer repeat in identical blocks.
- **Wear:** worn patches inside the path (`r3/wear_tileset`): darker trodden earth with stones and thin roots, placed by noise only where the path surrounds them.
- **Grass speck:** the fill no longer repeats its orange speck on a 16 px grid. Two of three plain grass cells use a copy with the speck painted out (no generation).
- **Ground cover:** ferns, tufts, clover, a mushroom cluster and a huckleberry (`r3/groundcover.png`) along the path's verges and at the bases of trees and rocks, so props don't stand on bare grass.
- **Cobbles:** only placed where grass surrounds them, which removes Round 2's grass seam against the path.
- **Rejected:** the mossy-grass set (`r3/grassvar_tileset`). Its patches drew as dark, outlined holes in the grass.
- **Still short:** grass that isn't next to anything is still a fairly flat field. Path turns are still on the grid (C-09).

### R3-4 garden
- **Bed:** one raised bed fully in frame, where Round 2's second bed sat mostly off-screen.
- **Rows:** three rows, each mixing two sources of the same kind of crop (`r2/crops.png` and `r3/crops_b_clean.png`) with small offsets, so a row isn't one repeated token.
- **Along the fence:** corn and a bean trellis.
- **By the gate:** a barrel, a crate of pumpkins, a flower pot and loose pumpkins (`r3/garden_props_clean.png`).
- **Clean-up:** the generated crops and props had baked ground strips and discs, which were cut off in clean copies.
- **Still short:**
  - The crops are small and dark next to the concept's bright beds of purple cabbage and pumpkins.
  - There's one bed, not a fenced grid of beds with walkways. The slice has no room for one at the current layout.
  - The trellis reads weakly.

### R3-5 forest layering and depth
- **Stepped edge:** four trees step into the clearing.
- **Logs:** fallen mossy logs (`r3/log.png`, regenerated lying horizontally; the first was diagonal).
- **Fog:** faint fog wisps in the corners, using the game's `weather_fog`, still.
- **Beyond the slice:** forest and shade, so walking south no longer shows the farm underneath (the R3-1 walk did).
- **Still short:**
  - The far forest is still one tree design repeated.
  - The shade over the area beyond the slice ends in a visible straight edge (walk frame 3).
  - The fog is very faint and doesn't move in stills.
  - Foreground canopy over the player was not added.

## Measurements (diagnostics only)
| Scene | Version | Lantern pool | Play area | Oak | Forest edge | Whole frame |
| --- | --- | --- | --- | --- | --- | --- |
| Night 21:30 | Production | 0.095 (0.034–0.172; 28%) | 0.029 (0.003–0.046; 0%) | 0.031 (0.009–0.046; 0%) | 0.024 (0.002–0.042; 0%) | 0.030 (0.003–0.046; 1%) |
| Night 21:30 | R3-1 baseline | 0.325 (0.078–0.598; 84%) | 0.122 (0.036–0.259; 37%) | 0.116 (0.005–0.259; 39%) | 0.051 (0.004–0.109; 9%) | 0.104 (0.010–0.252; 29%) |
| Night 21:30 | R3 slice | 0.343 (0.088–0.631; 85%) | 0.127 (0.037–0.260; 39%) | 0.121 (0.004–0.279; 33%) | 0.053 (0.004–0.109; 9%) | 0.108 (0.011–0.257; 28%) |
| Rain 21:30 | Production | 0.098 (0.049–0.157; 25%) | 0.046 (0.028–0.053; 1%) | 0.046 (0.033–0.053; 1%) | 0.043 (0.030–0.049; 1%) | 0.047 (0.029–0.053; 2%) |
| Rain 21:30 | R3-1 baseline | 0.259 (0.082–0.453; 83%) | 0.099 (0.047–0.185; 25%) | 0.085 (0.030–0.159; 19%) | 0.057 (0.030–0.084; 5%) | 0.089 (0.036–0.175; 19%) |
| Rain 21:30 | R3 slice | 0.266 (0.089–0.463; 84%) | 0.103 (0.048–0.186; 26%) | 0.090 (0.028–0.177; 23%) | 0.059 (0.031–0.087; 6%) | 0.092 (0.036–0.180; 21%) |
| Fog 21:30 | Production | 0.092 (0.054–0.141; 21%) | 0.063 (0.037–0.128; 13%) | 0.049 (0.038–0.057; 1%) | 0.062 (0.037–0.127; 15%) | 0.062 (0.037–0.127; 13%) |
| Fog 21:30 | R3-1 baseline | 0.283 (0.089–0.463; 84%) | 0.108 (0.053–0.187; 32%) | 0.099 (0.038–0.176; 33%) | 0.063 (0.038–0.120; 10%) | 0.098 (0.041–0.180; 26%) |
| Fog 21:30 | R3 slice | 0.244 (0.094–0.419; 84%) | 0.097 (0.052–0.166; 23%) | 0.102 (0.037–0.174; 36%) | 0.063 (0.038–0.106; 9%) | 0.091 (0.041–0.165; 22%) |
| Low sanity 8 | Production | 0.123 (0.061–0.208; 45%) | 0.051 (0.012–0.073; 1%) | 0.053 (0.013–0.073; 1%) | 0.042 (0.008–0.065; 0%) | 0.051 (0.009–0.073; 3%) |
| Low sanity 8 | R3-1 baseline | 0.311 (0.068–0.581; 83%) | 0.110 (0.031–0.238; 32%) | 0.109 (0.004–0.244; 38%) | 0.045 (0.004–0.102; 8%) | 0.095 (0.007–0.234; 26%) |
| Low sanity 8 | R3 slice | 0.326 (0.079–0.599; 84%) | 0.116 (0.031–0.241; 34%) | 0.107 (0.005–0.244; 31%) | 0.047 (0.004–0.101; 8%) | 0.098 (0.010–0.236; 26%) |
| Readability scene | Production | 0.095 (0.034–0.172; 28%) | 0.033 (0.003–0.050; 2%) | 0.031 (0.006–0.046; 0%) | 0.025 (0.003–0.042; 0%) | 0.032 (0.003–0.050; 2%) |
| Readability scene | R3-1 baseline | 0.325 (0.077–0.600; 84%) | 0.125 (0.035–0.262; 40%) | 0.119 (0.004–0.264; 40%) | 0.051 (0.004–0.109; 9%) | 0.106 (0.010–0.255; 30%) |
| Readability scene | R3 slice | 0.341 (0.089–0.620; 85%) | 0.131 (0.037–0.264; 42%) | 0.119 (0.004–0.273; 33%) | 0.053 (0.004–0.108; 9%) | 0.109 (0.011–0.257; 30%) |
| Day 12:00 | Production | – | 0.255 (0.135–0.308; 93%) | 0.251 (0.107–0.308; 88%) | 0.205 (0.097–0.282; 83%) | 0.236 (0.112–0.305; 88%) |
| Day 12:00 | R3-1 baseline | – | 0.190 (0.097–0.298; 77%) | 0.209 (0.024–0.419; 60%) | 0.138 (0.029–0.238; 57%) | 0.172 (0.044–0.305; 67%) |
| Day 12:00 | R3 slice | – | 0.197 (0.099–0.317; 78%) | 0.211 (0.021–0.455; 65%) | 0.141 (0.032–0.236; 59%) | 0.176 (0.049–0.316; 69%) |

| Scene | Version | Frame ms, median | p95 | Render CPU ms | Render GPU ms | Draw calls | Objects | Lights on |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Day 12:00 | Production | 2.36 | 4.68 | 0.85 | 1.19 | 606 | 1318 | 0 |
| Day 12:00 | R3-1 baseline | 2.53 | 4.0 | 1.11 | 1.52 | 668 | 2043 | 0 |
| Day 12:00 | R3 slice | 3.01 | 3.92 | 1.56 | 1.65 | 1047 | 2179 | 0 |
| Night 21:30 | Production | 2.13 | 2.9 | 0.79 | 1.32 | 606 | 1318 | 2 |
| Night 21:30 | R3-1 baseline | 2.4 | 3.54 | 1.1 | 1.73 | 718 | 2043 | 4 |
| Night 21:30 | R3 slice | 3.41 | 4.95 | 1.72 | 2.26 | 1084 | 2179 | 4 |
| Rain 21:30 | Production | 2.63 | 3.56 | 0.88 | 1.63 | 609 | 2194 | 2 |
| Rain 21:30 | R3-1 baseline | 3.13 | 5.05 | 1.23 | 2.18 | 723 | 2920 | 4 |
| Rain 21:30 | R3 slice | 3.67 | 4.91 | 1.7 | 2.45 | 1089 | 3049 | 4 |
| Readability scene | Production | 2.3 | 3.19 | 0.83 | 1.47 | 612 | 1317 | 3 |
| Readability scene | R3-1 baseline | 2.85 | 4.59 | 1.22 | 1.99 | 736 | 2055 | 5 |
| Readability scene | R3 slice | 3.22 | 5.45 | 1.67 | 2.18 | 1092 | 2178 | 5 |
| Night 21:30 at 1920×1080 | R3-1 baseline | 3.08 | 4.66 | 1.29 | 2.74 | 759 | 2070 | 4 |
| Night 21:30 at 1920×1080 | R3 slice | 3.57 | 4.82 | 1.82 | 2.8 | 1112 | 2207 | 4 |

Each cell: mean (10th–90th percentile; share above 0.12).

- **The R3-1 night holds.** At 21:30 the play area reads 0.127 against R3-1's 0.122, and the forest edge 0.053 against 0.051. The new art didn't brighten or darken the locked night in any condition.
- **Frame cost** (this machine, AMD Radeon Graphics):
  - About 380 more draw calls than R3-1 (1,084 vs 718 at night), mostly the ground cover, the boulders, the forest beyond the slice and the extra path cells.
  - Frame time median 3.0–3.4 ms against 2.4–2.5 ms.
  - Still far inside a 16.7 ms frame, but the cost grows with prop count. A production version would need batching (fewer canvas items) rather than one sprite per piece.

## Readability (recordings, not play sessions)
- **Night walk** (`walk_r3s.gif`, frame grid in master part 4): the path, the lantern pool, the garden rows and the corn, the chanterelles and the watcher all read from several tiles away. The farmer stays clear against the busier ground.
- **Day walk** (`walk_r3s_day.gif`): same result.
- **Rosehips** on dark grass are still faint (300% crop in master part 3).
- **Watcher (watch item):** it reads at once in the clearing, as it did in R3-1, with its red glow on the grass. The refined art neither hides it nor adds to it. Whether it is *too* easy to read stays the owner's call. The R3-1 night is the main reason it's visible at all; in production it shows only as eyes and a glow.

## Watch items carried forward
- **No new permanent lights.** None were added; the two lantern posts are Round 1's slice dressing.
- **Light limit:** 15 on-screen lights per canvas item in the Compatibility renderer (R3-0). The slice uses at most 5. It remains a risk for production integration.
- **Low sanity:** production's night gets brighter at low sanity. This is documented, not changed.
- **P-1:** not approved and not started.

## Limitations
- **The slice is still a 30×18 patch.** It has no house, well, pond, moon, cave or trek, so the concept's architecture and water can't be compared.
- **Concept crops** are fitted to the cells; their camera, scale and light count differ.
- **The oak's measured region** is different pixels from R3-1's.
- **Static views:** fog wisps and charms don't move in the slice.
- **Performance** is from one machine. Lantern sway in recordings runs on the wall clock.

## Score (provisional self-score by the author; rubric weights)

| Dimension | Weight | R3 slice | R3-1 (self) | R3-1 (ChatGPT) | Evidence |
| --- | --- | --- | --- | --- | --- |
| Concept fidelity | 25% | 6 | 5.5 | 6.0 | [Judgement] The oak's silhouette, scattered stones, garden dressing and stepped forest are closer to concept 02. Crown puffs, small dark crops, one bed, and no house or well remain. |
| Environmental richness | 20% | 6 | 5 | 5.0 | [Observed] Ground cover at every base, varied path edges and wear, the grass grid broken, corn, barrel, crate, logs. Open grass in the middle right is still plain. |
| Lighting and atmosphere | 20% | 6 | 6 | 6.5 | [Measured] The R3-1 night is unchanged (play 0.127, edge 0.053). Corner fog is faint. No change to lighting by design. |
| Asset consistency | 15% | 6 | 6 | 6.0 | [Judgement] One palette, but the hand-pixelled fungus is flatter than the generated art, and the bright corn stands out against darker crops. |
| Gameplay readability | 10% | 7.5 | 7.5 | 7.5 | [Observed in recordings] Path, farmer, rows, forage and watcher read while walking; rosehips faint. |
| Technical quality | 10% | 7 | 7 | 7.0 | [Observed] Clean-checkout renders, the night locked, rejects documented, baked ground removed. About 380 more draw calls; a hard shadow edge beyond the slice. |
| **Total** | | **62.5** | 59.25 | 61.5 | 6×0.25 + 6×0.20 + 6×0.20 + 6×0.15 + 7.5×0.10 + 7×0.10 |

Still below the provisional 65 band. The remaining gap is mostly the concept's things the slice doesn't contain (house, well, pond, a full garden grid), crown density, and crop colour. Several of these depend on decisions outside this scope: the layout (C-08), the day grade (C-04) and outlines (C-11).

## Suggested next steps (for review, not decisions)
1. **Crown density:** try a hand-guided pass on oak D (PixelLab inpaint or workbench edits on the crown) rather than more img2img rolls, which stopped improving.
2. **Garden:** a brighter, larger crop set, and a 2×2 bed grid with walkways. That needs a bigger slice area, or a separate garden slice.
3. **The rest of the concept:** a slice containing the house, the well or the pond would test the parts of the concept this patch can't. It needs owner scope.
4. **Production (P-1 or art migration):** batch the ground cover and the stones into fewer canvas items before any of this moves toward the game.
