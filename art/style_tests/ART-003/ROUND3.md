# ART-003 Round 3: R3-0 baseline and R3-1 night experiment

Status: for ChatGPT's image-level review and the owner's decision. **Non-production.** Authorized by the owner on 2026-11-02 for R3-0 and R3-1 only. No production script, scene, shader, art, save, layout, camera, scale or gameplay changed; no lights were added; no PixelLab generations; R3-2 to R3-6 and production night lighting (P-1) not started.

Plan: `AI_COLLAB/ART_003_ROUND3_PLAN.md`. Method: `AI_COLLAB/CONCEPT_FIDELITY_FEASIBILITY.md`, "Night measurement method". Scoring: `AI_COLLAB/ART_REVIEW_RUBRIC.md`.

## R3-0: baseline and technical validation

### Working tree and build
- **The VIS-002 work is protected.** The uncommitted changes (`trek_system.gd`, `main.gd`, `grade.gdshader`, `project.godot`, `scenes/main.tscn`) were never touched. The backup patch `builds/wip_backup/2026-11-02_working_tree.patch` still matches the working tree: its SHA-256 is unchanged (`f52e5ae0…`) and it reverse-applies cleanly. The snapshot stash entry matches the working tree file by file.
- **The working tree compiles.** It loads headless with no script or parse errors. `save_test.gd`: 0 failures. `menu_test.gd`: 752 PASS, 0 failures.
- **Renders come from a clean checkout of `4c47a58`** (a separate git worktree in the session's scratch folder), so the uncommitted VIS-002 lighting is in none of the images. "Production" below means that commit.
- One slip, corrected: running `git stash` in that scratch worktree added an entry to the shared stash list. It held only a copy of the Round 2 tool, and was dropped straight away. The VIS-002 snapshot entry was not affected.

### Tools (test-only)
- `tools/art003_round2.gd`: the night, the forest shade and haze, and the final capture are now methods that a subclass can override. Its own output is unchanged. Re-rendered frames differ from the original Round 2 renders by PSNR 35–37 dB, the same as two runs of the original tool differ from each other (35.7 dB), because of the film grain and the falling leaves.
- `tools/art003_round3.gd` (new) has three modes. `production` is the game with no slice at the same spot. `r2` is Round 2 exactly. `r3` is Round 2's art under the R3-1 night. It also adds forced visitors and forage, low sanity, region measurement with mask images, a frame-time readout, night walks under Movie Maker, and a light-limit probe.
- `tools/review_threeway.ps1` now draws one column per tag. Three-column calls work as before.

### Matched conditions
- 1280×720 window and base canvas, `SCALE = 3`, the camera on the farmer at the new-game spot, facing down. HUD layers hidden; the colour grade and weather layers kept.
- Autumn, day 1, tin lantern (tier 1, radius 2.5 tiles), slot 8.
- 12:00 and 21:30. 23:30 measured the same as 21:30, because darkness is already full by 21:00, so it isn't shown.
- Sunny unless stated; rain and fog use the game's own weather.
- Correction to `CONCEPT_FIDELITY_FEASIBILITY.md`: Round 2's luma numbers were taken with the HUD **hidden**, not included. The slice tools hide every CanvasLayer except layer 0.

### Measurement method
- **Regions** are fixed in screen space from the slice's layout, so every version is measured over the same pixels. Each pixel goes to the first region it falls in, in this order:
  - **Lantern pool:** the lantern's radius around the farmer.
  - **Oak:** the oak sprite's opaque pixels.
  - **Forest edge:** within 3 tiles of the slice's sides and bottom, or above slice row 6.
  - **Play area:** everything else.

  The mask images are in sheet 4. In the production column the regions mark screen areas only: the oak isn't there.
- **Luma:** Rec. 709 weights on the saved sRGB values, after the grade. For each region: mean, 10th–90th percentile, and the share of pixels above 0.12.
- **Performance:** vsync off; 240 frames after 60 to settle. Readouts: frame time, viewport render CPU/GPU time (`RenderingServer`), draw calls and objects (`Performance`).
  - Machine: AMD Radeon Graphics, Compatibility renderer, Godot 4.7.2.
  - The per-frame process-time monitor gave impossible values (hundreds of ms against 2–3 ms frames), so it is left out.
- Every number is a diagnostic. None of them is an acceptance test.

### Lighting limits in the Compatibility renderer (measured)
`tools/art003_round3.gd probe=lights`: small lights over a black-tinted screen, each one counted as drawn if its centre is lit.

| Test | Result |
| --- | --- |
| 8, 9 lights on one canvas item | all drawn |
| 16, 24, 32, 33, 40, 60 lights on one canvas item | **15 drawn**; the rest (later-created) dropped |
| 8 to 60 lights, one canvas item each | all drawn |
| 12 lights on screen + 10 off-screen, one item | all 12 drawn (off-screen lights take no share) |

- Project settings: `rendering/limits/opengl/max_lights_per_object = 8` and `max_renderable_lights = 32`. Neither matches what was measured. The binding limit was **15 lights on screen per canvas item**, and the total of 32 wasn't reached even with 60 lights.
- **Why it matters:** most of the farm (ground, crops, many props) is drawn by `main.gd`'s `_draw` onto a few canvas items. If more than 15 lights are on screen at once, the extra ones won't light that ground.
  - The game can place up to 8 lamp posts and 12 torches.
  - Add the lantern, 2 windows, the porch, the cave mouth, 4 roost lights and a visitor, and up to about 30 lights can be on the farm at once.
  - In this capture only 2 to 3 were on.
  - Whether 15 is ever exceeded on screen in real play is **untested**. Checking it needs a production test with every lamp and torch placed, which isn't part of R3-0.
  - It is one more reason not to add permanent landmark lights (C-07).
- **Night rules read lamp positions:** `night_system.gd` has `_lit_by_lamp` / `_lit_by_you`. This confirms the compatibility concern in C-07.

### Performance (measured, this machine)
Production at the start spot draws about 606 calls in 2.1–2.4 ms median per frame. The slice adds about 60–110 draw calls and 700 objects (its sprites). The R3-1 night costs the same as Round 2's, within run-to-run noise. Rain adds about 0.5–0.8 ms in every version.

| Scene | Version | Frame ms, median | p95 | Render CPU ms | Render GPU ms | Draw calls | Objects | Lights on |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Day 12:00 | Production | 2.36 | 4.68 | 0.85 | 1.19 | 606 | 1318 | 0 |
| Day 12:00 | Round 2 | 2.29 | 4.27 | 1.14 | 1.55 | 668 | 2043 | 0 |
| Day 12:00 | R3-1 | 2.53 | 4.0 | 1.11 | 1.52 | 668 | 2043 | 0 |
| Night 21:30 | Production | 2.13 | 2.9 | 0.79 | 1.32 | 606 | 1318 | 2 |
| Night 21:30 | Round 2 | 2.5 | 3.55 | 1.13 | 1.68 | 718 | 2043 | 4 |
| Night 21:30 | R3-1 | 2.4 | 3.54 | 1.1 | 1.73 | 718 | 2043 | 4 |
| Rain 21:30 | Production | 2.63 | 3.56 | 0.88 | 1.63 | 609 | 2194 | 2 |
| Rain 21:30 | Round 2 | 3.05 | 4.34 | 1.21 | 2.09 | 721 | 2917 | 4 |
| Rain 21:30 | R3-1 | 3.13 | 5.05 | 1.23 | 2.18 | 723 | 2920 | 4 |
| Fog 21:30 | Production | 2.27 | 3.83 | 0.84 | 1.48 | 610 | 1328 | 2 |
| Fog 21:30 | Round 2 | 2.6 | 3.74 | 1.19 | 1.79 | 722 | 2053 | 4 |
| Fog 21:30 | R3-1 | 2.95 | 3.92 | 1.34 | 2.2 | 728 | 2068 | 4 |
| Readability scene | Production | 2.3 | 3.19 | 0.83 | 1.47 | 612 | 1317 | 3 |
| Readability scene | Round 2 | 3.03 | 4.64 | 1.25 | 2.05 | 730 | 2040 | 5 |
| Readability scene | R3-1 | 2.85 | 4.59 | 1.22 | 1.99 | 736 | 2055 | 5 |
| Night 21:30 at 1920×1080 | R3-1 | 3.08 | 4.66 | 1.29 | 2.74 | 759 | 2070 | 4 |

## R3-1: night experiment

### What changed (slice tool only)
| | Round 2 preview | R3-1 |
| --- | --- | --- |
| Night tint | `7382ae` | `8592b8` |
| Night grade | saturation 0.62, exposure 0.96, contrast 1.04, shadow_cool 0.08, vignette 0.75, warmth 0.05 | saturation 0.70, exposure 1.00, contrast 1.12, shadow_cool 0.07, vignette 0.62, warmth 0.06 |
| Forest-interior shade | 0.55 | 0.70 |
| Haze over the far rows | 0.22 | 0.10 |
| Weather layer tint | the world tint (rain, snow and fog take half, as in the game) | the world tint darkened to 60% |
| Dusk and low sanity | overridden: the preview set one fixed tint and grade | the game's own blend: dusk tint, then night; low sanity's lean toward `SANITY_TINT` and loss of saturation, as `main.gd` does |

- **Unchanged:** `darkness`, sanity drain, lamp timing, events, the lantern and its radius, every light, the art and the layout.
- The two lantern posts are the slice's own Round 1 dressing, standing in for earned lamp posts. They aren't new lights.
- **How it was chosen:** five variants were rendered and compared by eye against concept 03 and Round 2, with the region numbers as a check. The cooler variant (tint `7e8cbc`, saturation 0.68) is shown in sheet 4 as an alternative. The aims:
  - keep the play area about as readable as Round 2;
  - darken the forest edge;
  - keep the autumn colour that concept 03 keeps at night;
  - keep the pools warm.
- **Fog fix:** under the lighter tint, fog wisps taking half the tint drew as pale, solid clouds (sheet 4, row 2). Darkening the weather layer's tint to 60% brings them back to translucent mist. In production this would need its own change in `weather.gd`, part of any P-1 proposal.

### Results (measured; diagnostics only)
| Scene | Version | Lantern pool | Play area | Oak | Forest edge | Whole frame |
| --- | --- | --- | --- | --- | --- | --- |
| Night 21:30 | Production | 0.095 (0.034–0.172; 28%) | 0.029 (0.003–0.046; 0%) | 0.031 (0.009–0.046; 0%) | 0.024 (0.002–0.042; 0%) | 0.030 (0.003–0.046; 1%) |
| Night 21:30 | Round 2 | 0.311 (0.094–0.550; 86%) | 0.126 (0.054–0.239; 40%) | 0.113 (0.024–0.225; 38%) | 0.075 (0.020–0.122; 11%) | 0.114 (0.030–0.228; 31%) |
| Night 21:30 | R3-1 | 0.325 (0.078–0.598; 84%) | 0.122 (0.036–0.259; 37%) | 0.116 (0.005–0.259; 39%) | 0.051 (0.004–0.109; 9%) | 0.104 (0.010–0.252; 29%) |
| Rain 21:30 | Production | 0.098 (0.049–0.157; 25%) | 0.046 (0.028–0.053; 1%) | 0.046 (0.033–0.053; 1%) | 0.043 (0.030–0.049; 1%) | 0.047 (0.029–0.053; 2%) |
| Rain 21:30 | Round 2 | 0.245 (0.092–0.414; 83%) | 0.104 (0.056–0.175; 25%) | 0.091 (0.038–0.154; 25%) | 0.073 (0.040–0.093; 5%) | 0.097 (0.045–0.169; 20%) |
| Rain 21:30 | R3-1 | 0.259 (0.082–0.453; 83%) | 0.099 (0.047–0.185; 25%) | 0.085 (0.030–0.159; 19%) | 0.057 (0.030–0.084; 5%) | 0.089 (0.036–0.175; 19%) |
| Fog 21:30 | Production | 0.092 (0.054–0.141; 21%) | 0.063 (0.037–0.128; 13%) | 0.049 (0.038–0.057; 1%) | 0.062 (0.037–0.127; 15%) | 0.062 (0.037–0.127; 13%) |
| Fog 21:30 | Round 2 | 0.259 (0.092–0.452; 82%) | 0.114 (0.062–0.200; 32%) | 0.098 (0.047–0.179; 24%) | 0.077 (0.045–0.137; 12%) | 0.105 (0.051–0.191; 25%) |
| Fog 21:30 | R3-1 | 0.283 (0.089–0.463; 84%) | 0.108 (0.053–0.187; 32%) | 0.099 (0.038–0.176; 33%) | 0.063 (0.038–0.120; 10%) | 0.098 (0.041–0.180; 26%) |
| Low sanity 8, 21:30 | Production | 0.123 (0.061–0.208; 45%) | 0.051 (0.012–0.073; 1%) | 0.053 (0.013–0.073; 1%) | 0.042 (0.008–0.065; 0%) | 0.051 (0.009–0.073; 3%) |
| Low sanity 8, 21:30 | Round 2 | 0.311 (0.094–0.550; 86%) | 0.126 (0.054–0.239; 41%) | 0.113 (0.021–0.228; 38%) | 0.074 (0.019–0.122; 10%) | 0.114 (0.029–0.229; 31%) |
| Low sanity 8, 21:30 | R3-1 | 0.311 (0.068–0.581; 83%) | 0.110 (0.031–0.238; 32%) | 0.109 (0.004–0.244; 38%) | 0.045 (0.004–0.102; 8%) | 0.095 (0.007–0.234; 26%) |
| Readability scene | Production | 0.095 (0.034–0.172; 28%) | 0.033 (0.003–0.050; 2%) | 0.031 (0.006–0.046; 0%) | 0.025 (0.003–0.042; 0%) | 0.032 (0.003–0.050; 2%) |
| Readability scene | Round 2 | 0.311 (0.094–0.550; 86%) | 0.130 (0.053–0.243; 44%) | 0.113 (0.021–0.228; 39%) | 0.074 (0.019–0.121; 10%) | 0.115 (0.029–0.230; 32%) |
| Readability scene | R3-1 | 0.325 (0.077–0.600; 84%) | 0.125 (0.035–0.262; 40%) | 0.119 (0.004–0.264; 40%) | 0.051 (0.004–0.109; 9%) | 0.106 (0.010–0.255; 30%) |
| Day 12:00 | Production | – | 0.255 (0.135–0.308; 93%) | 0.251 (0.107–0.308; 88%) | 0.205 (0.097–0.282; 83%) | 0.236 (0.112–0.305; 88%) |
| Day 12:00 | Round 2 | – | 0.190 (0.097–0.298; 77%) | 0.209 (0.024–0.427; 60%) | 0.138 (0.028–0.237; 56%) | 0.172 (0.044–0.303; 67%) |
| Day 12:00 | R3-1 | – | 0.190 (0.097–0.298; 77%) | 0.209 (0.024–0.419; 60%) | 0.138 (0.029–0.238; 57%) | 0.172 (0.044–0.305; 67%) |

Each cell: mean (10th–90th percentile; share above 0.12).

- **Play area:** about as bright as Round 2 (0.122 vs 0.126), and four times production (0.029).
- **Forest edge:** about a third darker than Round 2 (0.051 vs 0.075) and within the 0.07 reference.
- **Oak:** a little brighter than Round 2; the lantern pool is the brightest region, as before.
- **Concept 03** read 0.200 for its whole crop in Round 2's measurement, with more lights and a different camera. It is a reference reading, not a target.
- **Low sanity (8):**
  - Production gets *brighter* and greyer at low sanity (play area 0.029 → 0.051), because its gloom leans the very dark night tint toward the lighter `SANITY_TINT`. That is existing game behaviour, not something R3-1 introduced.
  - Under R3-1 the same rule makes the night slightly darker and greyer (play area 0.122 → 0.110; frame visibly colder and less saturated).
  - Round 2's preview ignored sanity entirely.
- **Rain and fog:** both stay readable under R3-1 and keep the forest edge dark. Fog reads as mist only with the weather fix.

### Visual assessment (judgement)
- **Against Round 2:** R3-1 keeps the oak's orange canopy and the red maples, which Round 2's bluer tint greyed out. Concept 03 also keeps those warm colours at night. The forest boundary is clearly darker, and the path and the garden rows keep their shapes. The night still reads as night: blue-grey ground, warm pools, a black forest edge.
- **Against the concept:**
  - The game frame is still far darker and plainer overall.
  - The concept has a lit house, windows, a moon, many lamps, the well and a higher camera, none of which the slice contains.
  - Fine detail at the forest edge is lost to the darker shade. The concept keeps more mid-tone detail in its trees.
- **Threat:** the watcher at the clearing edge reads at once in R3-1: its glow lights the grass and the litter. It is a little less stark than in production's near-black field. That trade-off is the owner's call.

### Walking test
`walk_r3.gif`, `walk_r2.gif` and `walk_production.gif` (75%), with frame grids at 100% in master part 3. The route is 0.6 s standing, 2.2 s down-left along the path, 3.6 s up-right past the garden to the watcher, at 30 fps under Movie Maker.
- **R3-1:** the path stays clear outside the lantern pool. The garden rows, the lantern posts, the chanterelles and the watcher are visible from several tiles away. The farmer stays readable against every background. The rosehips on dark grass are faint but findable (300% crop in sheet 3).
- **Production:** outside the 2.5-tile lantern pool almost nothing reads apart from the watcher's eyes and glow. That is the intended "oppressive" baseline.
- **Not tested in motion:** reaction time to a moving threat, or a real player's judgement. These are recordings, not play sessions.

### What this experiment can't reproduce
- **Slice contents:** the house and its window and porch light, the well, the pond and moonlight, roost lights, placed lamps and torches by progression, and the cave mouth. The slice has none of them, so their interaction with the R3-1 night is unchecked.
- **Other locations:** the cave, the Rookery Wood trek (which has its own tint built on the same values) and interiors. These can only be checked by integrating into the game (P-1).
- **Dusk (19:00–21:00):** the R3-1 node blends through the game's dusk tint, but no dusk frames were captured.
- **The slice's edge:** walking south, the slice ends after about 6 tiles and the production ground shows beyond it (part 3, frame 3 of the R3 and Round 2 walks). It is a tool artefact.
- **Framing:** the concept crops are fitted to the cell. Their camera, scale and light count differ.
- **Production column content:** the slice covers the real farm, so the production column shows different things at the same spot (the well, a plot).
- **Hardware:** performance is from one machine (AMD Radeon Graphics). Movie Maker plays wall-clock effects such as lantern sway at the machine's pace, not the game's.
- **Night 23:30:** identical to 21:30 by design (darkness is full from 21:00).

## Score (provisional self-score by the author; rubric weights)

| Dimension | Weight | R3-1 | Round 2 (self) | Evidence |
| --- | --- | --- | --- | --- |
| Concept fidelity | 25% | 5.5 | 5 | [Judgement] The autumn colour at night is closer to concept 03; the art and composition are unchanged from Round 2, with no house, well or moon. |
| Environmental richness | 20% | 5 | 5 | [Observed] The art is unchanged; the darker forest edge hides a little detail. |
| Lighting and atmosphere | 20% | 6 | 5 | [Measured] Forest edge 0.051 vs 0.075 with the play area held; fog fixed; low sanity composes. [Judgement] Readable and still threatening. No moon or landmark light, by rule. |
| Asset consistency | 15% | 6 | 6 | [Observed] Same asset family. |
| Gameplay readability | 10% | 7.5 | 7 | [Observed in recordings] Path, rows, forage and watcher read while walking; rosehips faint. Not play-tested by a person. |
| Technical quality | 10% | 7 | 6 | [Observed] Clean-checkout renders, matched regions, measured performance and light limit, sanity-aware, reversible. The weather fix would need a `weather.gd` change; the process-time metric was unusable; the slice's edge shows in the walk. |
| **Total** | | **59.25** | 54.5 | 5.5×0.25 + 5×0.20 + 6×0.20 + 6×0.15 + 7.5×0.10 + 7×0.10 |

Below the provisional 65 band. Lighting alone can't move fidelity and richness much: they depend on the art and composition steps (R3-2 to R3-5), which are not authorized. ChatGPT's independent score should be recorded beside this one.

## Recommendations (for review, not decisions)
1. **Night direction:** treat R3-1 (or its cooler variant) as the candidate night look for review. If the owner wants it in the game, P-1 needs its own approval and should include:
   - a night grade that blends with `darkness` (the game sets its grade once today);
   - the weather-tint change;
   - checks of the cave, the trek, interiors, the house lights and dusk;
   - save and menu tests.
2. **Light limit:** before any change that adds lights, test the worst case in production: every lamp and torch placed near the house at night. If more than 15 lights can be on screen at once, plan for it, for example by drawing the ground on more canvas items or capping the lights on screen.
3. **Low sanity:** decide whether production's current brightening at low sanity is intended. It runs against "colder, not brighter". This applies with or without R3-1.
4. **Next steps** stay as planned: R3-2 to R3-6 only with their own authorization and a generation budget.
