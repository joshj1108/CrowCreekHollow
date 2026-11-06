# ART-005 C3: one zero-credit roof-value comparison against C2 (non-production study)

**Status:** a study for review only. It is not production art and approves no integration.

**Answers:** the owner's C2 image-review brief, following ChatGPT's five-sheet C2 review (`09692d3`): one final, reversible roof-value variant, then a shift to whole-farm cohesion (see `ART_005_HC1_WHOLE_FARM_PLAN.md`).

**Spend:** zero. There were no PixelLab or SpriteCook calls and no purchases. The work is a deterministic Python remap (`tools/art005_c3.py`).

**Recommendation: keep C2 and end the farmhouse roof experiments.** C3's improvement is real when measured but too small to matter at normal gameplay scale (details under Result).

## What C3 is

C3 is C2 with only the roof's values changed. Nothing is redrawn.

- **Layout:** C2's shake layout is recomputed from C2's own seed, so every shake's columns and course are known exactly.
- **What moves:** inside each shake, only the face pixels and the butt catch-light pixels (ramp steps 3 and up) move. They move by one whole-shake step, taken from a broad hand-authored plane field sampled at the shake's centre. Lit catch-lights in the upper half move one step more.
- **What stays C2's exactly (the script asserts it):**
  - every joint, under-butt shadow and cast-shadow line (ramp steps 0–2);
  - every chip, split and moss pixel;
  - the chimney block, ridge, fascia, eave shadow and verges;
  - the walls, door, windows, corner timbers and foundation;
  - alpha, and the night glass.
- **Merge guard:** a shake's shift is reduced wherever the ramp ends would merge a soft joint, grain streak or under-butt row into its face. Every shake keeps as many distinct values as it had in C2.
- **Plane field (ramp steps per course, ridge to eave):** −0.45, 0.55, 0.95, 0.85, 0.45, 0.05, −0.2, −0.45, −0.7, −0.55. On top of that:
  - +0.4 of daylight left of centre on the upper half;
  - −0.25 in the chimney's lee;
  - −0.35 at the verges.
- **Palette:** C2's colours plus **one** new colour, a lighter silver step (88, 76, 65). C2's silver ramp repeated its top step, so a silvered shake could not otherwise carry a catch-light.
- **Files:** `art/style_tests/ART-005/pl/g7/c3/32/`. The existing harness modes `art=g7 var=c3` and `house=g7:c3` draw it, so no harness code changed. C1, C2, S3 Roof A and P1 were sha256-checked before and after, and all are unchanged.

**Reversible:** C3 is a separate folder. Deleting `pl/g7/c3/` removes it, and nothing references it.

## Measurements

| Roof field (sprite) | C2 | C3 |
|---|---|---|
| pixels changed | — | 8,914 (7,297 lifted, 506 deepened, 1,111 catch-light) |
| shakes lifted / deepened / kept | — | 108 / 9 / 217 |
| luma mean / SD | 45.4 / 12.1 | 47.8 / 14.8 |
| upper plane (courses 2–4) | 49.3 | **56.2** |
| lower plane (courses 7–10) | 43.7 | 43.3 |
| upper minus lower plane | 5.6 | **12.8** |
| upper plane minus ridge course | 8.3 | **15.2** |
| broad mass contrast (SD of 24×18 block means) | 4.20 | **6.17** (+47%) |
| pixel noise (mean neighbour step) | 4.74 | 5.50 (+16%) |
| luma 5th / 95th percentile | 23.8 / 64.3 | 23.8 / 68.4 |
| wall minus roof (wall median 100.6) | 55.2 | 52.8 |

The deepening barely happened: of 74 shakes the field asked to darken, only 9 could be. C2's lower faces already sit at the bottom of the usable ramp, and going lower would merge joints into faces.

**Rendered roof, C3 minus C2** (the same frames, measured inside the box where the two renders differ):

| Frame | mean luma shift | mean abs pixel change | roof-area SD, C2 → C3 |
|---|---|---|---|
| harness noon, 1080p integer | +2.4 | 2.67 | 10.7 → 13.3 |
| harness noon, real 720p | +2.3 | 2.59 | 10.5 → 12.9 |
| harness night, 1080p integer | +0.3 | 0.33 | 0.7 → 1.3 |
| harness night, real 720p | +0.3 | 0.31 | 0.7 → 1.3 |

The homestead frames could not be measured this way: falling leaves and grass differ between any two runs across the whole frame.

## Result (Claude's judgement; not reviewed by ChatGPT)

- **Sprite at 3×:** the upper slope is visibly lighter, and the ridge course separates from it. The catch-lights read a little more like daylight on the butts. The slope also looks slightly patchier, because pixel noise rose 16%.
- **Real 720p, noon:** side by side, a lighter upper band is just visible. On its own, either roof reads as the same dark plank-grey plane. A player would not notice the change.
- **1080p integer, noon:** the same as 720p, a little clearer.
- **ART-005 harness night:** no visible difference (+0.3 luma). The roof stays near-black under the unchanged night lighting.
- **W-4 homestead, noon (C2 | C3):** barely distinguishable. The difference is smaller than the run-to-run variation from leaves and grass. The roof is still the largest and darkest mass in the frame.
- **R3-1 night:** no visible difference.

**Conclusion:** one restrained value lift doesn't materially improve the farmhouse at gameplay scale. A lift large enough to read in play would brighten the whole roof, which the brief rules out, or would need a different roof value key for the whole scene. That is a scene-level question, taken up in the whole-farm plan.

**Recommendation:** keep C2 as the non-production restored-cabin candidate, archive C3 as a recorded negative result, and stop roof polishing.

## Review package (`art/style_tests/ART-005/pl/g7/c3/review/`)

Every frame was rendered in one session in the clean export `builds/review/ART-005/p1_export/` (C2 and C3 copied in; no VIS-002 working-tree change). The commands are in the header of `tools/art005_c3_review.py`.

| Master | Contents | Scale |
|---|---|---|
| `ART-005C3_master.png` | C2 \| C3 at 1080p integer, noon and harness night | 97% |
| `_master_2.png` | C2 \| C3 at real 720p, the changed-pixel map, the per-shake plan, and the change record with the rendered measurements | 84% |
| `_master_3.png` | Roof crops at 3× and the whole roof at 1:1 | 81% |
| `_master_4.png` | W-4 + F2 homestead north, noon | 65% |
| `_master_5.png` | W-4 + F2 homestead north, R3-1 night | 65% |

**Not shown:** dusk, rain, fog, winter, the trek, motion, the restoration stages, and the south homestead.

## Untouched

- Production art, layout, camera, scaling and lighting.
- Gameplay and saves.
- `DESIGN.md` and the upgrade systems.
- VIS-002, ART-003, and the S3, P1, C1 and C2 files.
