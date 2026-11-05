# ART-005 E1 — Non-production density and presentation harness: results

Task: **ART-005, stage E1**. Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **non-production test. Review requested.** Nothing in the game, `DESIGN.md`, production art, the camera, scaling, saves or night lighting was changed. PixelLab 0, SpriteCook 0, no AI generation.

Labels: **[Measured]** in this harness on this machine; **[Observed]** seen in captures; **[Estimate]** judgement; **[Unverified]** not tested here.

**Read this first:** columns B (32 px) and C (64 px) are **size-correct placeholders drawn by formula** from one design (`tools/art005_e0.py`). They exist to test framing, scaling, camera, light and cost. **They are not artwork and must not be scored as artwork.** By design they share the same pattern in tile units, so C looks like a finer-grained B: that shows what density costs, not what an artist would do with it. Column A is the existing 16 px art (W-3/W-4 house, oak and beds, production ground, fence and farmer). Column **A+** (professionally directed 16 px) is reserved in every sheet for E2.

## 1. What was built

| Piece | Path |
| --- | --- |
| Harness (Godot, isolated: never loads `main.gd`, a save or the farm) | `tools/art005_density.gd` |
| Run everything (stills, UI, probe, walk, swing, perf) | `bash tools/art005_run.sh all` → `builds/review/ART-005/` (gitignored) |
| Build the review package | `python tools/art005_report.py` → `art/style_tests/ART-005/review/` |
| Shared layout, palette, placeholders | `tools/art005_e0.py` → `art/style_tests/ART-005/e0/`, `placeholder/{16,32,64}/` |
| Frozen colour grade | `art/style_tests/ART-005/grade_head.gdshader.txt`, the committed `HEAD` grade. VIS-002's uncommitted grade edit is not used. |

`art/style_tests/ART-005/` has a `.gdignore`. The harness reads its PNGs with `Image.load_from_file`, so nothing is imported, no `.import` files are made, and nothing ships.

**How it renders** (`framing=int`, the proposed presentation):

1. The world draws into a `SubViewport` at **native resolution**: tile = D art px, view 30 × 16.875 tiles. That is 480×270 at 16 px, 960×540 at 32 px and 1920×1080 at 64 px. The viewport uses nearest filtering and `snap_2d_transforms_to_pixel`. The production `NIGHT_TINT`, lantern and window `PointLight2D`s and the frozen grade all run **inside** it.
2. That texture is drawn into an output-size viewport at a **whole-number scale k**, centred, with black borders where k doesn't divide.
3. **Smooth camera:** the world camera snaps to whole art px, the native render has a 1-px margin, and the leftover fraction is applied after scaling as a whole-**screen**-px offset.
4. **UI** goes on its own output-resolution canvas, never through the pixel viewport.

`framing=today` is the baseline: no native render, the world drawn straight at the output size with today's zoom (tile = 48 px at 720p, as `canvas_items` does) and a free camera. `framing=fill` picks the whole-number scale that fills the screen, which shows more or less world.

The same layout, camera, walk route (3.75 tiles/s, as in play), lights and grade are used for every column. Grain is off in every capture so the pixel measurements aren't noise. Day uses the sunny daylight tint, night 21:30 with `NIGHT_TINT` and the Brass Lantern radius.

## 2. Scaling: 1080p and the other sizes (item 2, 3)

**[Measured]** View size and scale per framing (the scaling matrix sheet shows 1:1 cells):

| Output | 16 px int | 32 px int | 64 px int | 16 px today | 32 px today | 64 px today |
| --- | --- | --- | --- | --- | --- | --- |
| 1280×720 | ×2, 25% border each axis | ×1, 25% border | **cannot fit**: native 1920×1080 cropped to the middle 20 × 11.25 tiles | **×3 clean** (the current game) | ×1.5 uneven | ×0.75, **texels dropped** |
| 1920×1080 | **×4 clean** | **×2 clean** | **×1 clean** | ×4.5 uneven | ×2.25 uneven | ×1.125 uneven |
| 2560×1440 | ×5, 6% border | ×2, 25% border | ×1, 25% border | ×6 clean | ×3 clean | ×1.5 uneven |
| 3840×2160 | **×8 clean** | **×4 clean** | **×2 clean** | ×9 clean | ×4.5 uneven | ×2.25 uneven |

The **fill** policy removes borders by changing how much world is visible:

| | 16 px fill | 32 px fill | 64 px fill |
| --- | --- | --- | --- |
| 720p | ×3, 26.7 × 15 tiles | ×1, **40 × 22.5 tiles** | ×1, **20 × 11.25 tiles** |
| 1440p | ×5, 32 × 18 tiles | ×3, 26.7 × 15 tiles | ×1, **40 × 22.5 tiles** |

These change what the player can see, which is gameplay. Fill is only acceptable if the owner accepts view size varying with the monitor.

**[Measured] Pixel clarity** (`e1_probe_1080p.png`). This is the width in screen px of every texel of a 1-texel checker, over eight camera sub-pixel offsets:

| | int (smooth camera) | today |
| --- | --- | --- |
| 16 px, 1080p | 100% are 4 px | 51% 4 px / 49% 5 px |
| 32 px, 1080p | 100% are 2 px | 75% 2 px / 25% 3 px |
| 64 px, 1080p | 100% are 1 px | 88% 1 px / 12% 2 px |
| 64 px, 720p | n/a (only 20 × 11.25 tiles visible) | **52% 1 px / 48% 2 px: texels lost** |
| 16 px at 720p, 1440p, 4K | 100% uniform (×2, ×5, ×8) | ≈ 99% uniform (×3, ×6, ×9 are whole) |
| 32 px, 1440p | 100% uniform (×2) | ≈ 99% uniform (×3) |

With integer framing, **every texel is the same size at every density and size tested, and the pattern never changes as the camera moves.** Today's framing is clean only where the scale happens to be whole (16 px at 720p, 1440p and 4K; 32 px at 1440p). At 1080p (the most common desktop size [Unverified]) it is uneven for every density.

## 3. Camera snapping and walking (item 4)

**[Measured]** On-screen step of the world per frame while walking at 3.75 tiles/s, 1080p (`e1_camera_steps.png`, `e1_metrics.json`):

| Case | Mean step | Spread (σ) | Notes |
| --- | --- | --- | --- |
| 16 px int **snap**, 50 fps | 4.8 px | 1.6 | alternates 4 / 8 px: **judder** (20% of frames off by ≥ 1 px) |
| 16 px int **smooth**, 50 fps | 4.8 px | 0.4 | 4 / 5 px, the least possible on whole screen px |
| 32 px int snap, 50 fps | 4.8 px | 1.0 | 4 / 6 px (40% off) |
| 64 px int snap or smooth, 50 fps | 4.8 px | 0.4 | 1 art px = 1 screen px: snap is already smooth |
| 16 px int **snap**, 144 Hz | 1.67 px | 2.0 | **251 of 431 frames don't move**, then jump 4 px: strong judder |
| 32 px int snap, 144 Hz | 1.67 px | 0.75 | 72 stalls |
| any density, int **smooth**, 144 Hz | 1.67 px | 0.47 | 1 / 2 px, even |

- **Snap-to-art-px alone is not acceptable at 16 px and doubtful at 32 px**, especially on high-refresh displays. **Snap plus the screen-px remainder (smooth) fixes it at every density.** It is cheap: one offset per frame.
- **Trade-off [Measured]:** with the smooth camera the world moves evenly, but the farmer (on the world's art grid) wobbles against the screen by up to one art px. That's 4 screen px at 16 px, 2 at 32 px and 0 at 64 px. It is visible in `e1_walk_camera_modes.gif` as a faint sawtooth on the farmer. Options for E3: accept it (common in pixel-art games [Unverified]), draw the player on the screen-px offset (keeps pixel size but leaves the world grid by under one art px), or slow camera follow. This is a decision about how it feels, not a defect.
- Today's framing moves evenly (5.4 px a frame) but **the texels change width as it moves** (section 2), and that shimmer is what makes higher-density art look soft or busy at today's scale.

## 4. Lantern, falloff and night grading (item 5)

- **[Observed]** Rendering the lights inside the native viewport puts the **smooth** lantern falloff on the art-px grid automatically: at 16 px the pool steps in 4-screen-px blocks, at 32 px in 2. `LIGHTING_V2` needed a special texture to get this today.
- **[Measured]** Standing still with the lantern swinging, pixels changed per frame in a 320×180 crop:

| | smooth falloff | stepped (`LIGHTING_V2` bands + Bayer dither) |
| --- | --- | --- |
| A 16 px | 0.08% | 5.2% (peak 41%) |
| B 32 px | 0.07% | 18.1% (peak 47%) |
| C 64 px | 0.06% | 24.0% (peak 47%) |

  The stepped dither travels with the light, so it **reshuffles the lit ground every time the lantern moves**, and the more pixels a tile has, the worse it gets. This confirms the owner's VIS-001 choice of `LANTERN_SMOOTH` and extends it: in a native-resolution presentation, **the smooth gradient is already on the art grid**. Banding, if wanted, should be world-anchored (a shader), not a moving dither texture.
- **[Observed]** The production night tint and grade carry over unchanged. The grade's vignette and grain run at native resolution, so grain would be art-px sized: chunky at 16 px. Grain should move to the output canvas or be retuned per density before any adoption.
- **[Observed]** At night the lantern pool is faint against `NIGHT_TINT` at every density (energy 0.5). This is today's tuning, not a density effect.

## 5. Terrain crispness (item 6)

- **[Observed]** In `e1_crops_1to1_*`, integer framing keeps every terrain texel square at all densities. At today's 1080p framing the 16 px ground shows doubled columns and rows (4/5 px), the 32 px ground mixes 2/3 px, and the 64 px ground mixes 1/2 px. The irregular columns read as softness or "busyness" in the 32 px and 64 px columns, which matches ART-002's finding that 32 px art looked "softer and busier".
- **[Observed]** The dual-grid ground and the organic-edge placeholder ground both stay seamless in the native render: no gaps or bleeding at any scale. The 64 px ground for this map is 3200×1600 (under the 4096 limit). A whole farm at 64 px will need chunks (section 7).

## 6. UI apart from the world (item 7)

**[Observed]** `e1_ui_separation.png`: the same HUD, a font plus the production `slot.png`, drawn on the output canvas is crisp at 1080p and 4K regardless of art density. Drawn **inside** the 480×270 world render, the text becomes blocky and the slots lose their detail. Inside the world it also picks up the world's colour grade and vignette. **The UI must stay on its own screen-resolution layer.** The current game already draws its UI above the world. Any adoption keeps that and only moves the world into the native viewport.

## 7. GPU, frame time and memory (item 8)

**[Measured]** Godot 4.7.2, `gl_compatibility`, OpenGL 3.3, AMD Radeon integrated graphics. Night scene: three lights, the grade, y-sorted sprites, walking. vsync off, about 8 s each after 120 warm-up frames.

| Case | Native | Mean frame | p95 | GPU: world | GPU: output | Draw calls | Texture mem | Art (RGBA) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A 16 int 1080p | 482×272 | 0.77 ms | 1.03 | 0.13 ms | 0.16 ms | 26 | 38 MB | 1.9 MB |
| B 32 int 1080p | 962×542 | 1.04 ms | 1.42 | 0.36 ms | 0.19 ms | 26 | 50 MB | 7.3 MB |
| C 64 int 1080p | 1922×1082 | 1.96 ms | 2.34 | 1.24 ms | 0.22 ms | 26 | 99 MB | 29.2 MB |
| A 16 today 1080p | 1920×1080 | 1.86 ms | 2.21 | 1.16 ms | 0.21 ms | 26 | 62 MB | 1.9 MB |
| A 16 int 4K | 482×272 | 1.29 ms | 1.65 | 0.13 ms | 0.60 ms | 26 | 85 MB | 1.9 MB |
| B 32 int 4K | 962×542 | 1.59 ms | 1.99 | 0.37 ms | 0.64 ms | 26 | 97 MB | 7.3 MB |
| C 64 int 4K | 1922×1082 | 2.43 ms | 2.83 | 1.23 ms | 0.65 ms | 26 | 146 MB | 29.2 MB |
| A 16 today 4K | 3840×2160 | 5.39 ms | 5.96 | 4.11 ms | 0.70 ms | 26 | 189 MB | 1.9 MB |

- **The native render is cheaper than today's framing**, because the world, lights and grade are drawn at native size and then scaled once. At 4K: 1.3 ms (16 px) vs 5.4 ms today. Even 64 px at 1080p costs about the same as today's 1080p.
- **Draw calls don't change with density** (26 in this scene).
- **Memory is the real density cost:** art RGBA 1.9 → 7.3 → 29.2 MB for this one scene (4× and 16×). "Texture mem" also includes the render targets. The 64 px ground alone is 19.5 MB. [Estimate] The production farm (about 92 × 68 tiles with borders) at 64 px needs about 100 MB of ground in at least six 4096-px chunks, against about 6 MB at 16 px. That is manageable on desktop but a real constraint for web or Steam Deck-class memory, and for repo size.
- This is one small scene on one machine. The whole game has more sprites, lights and particles, so the absolute numbers are a floor. The **ratios** are what carry over.

## 8. Renderer compatibility (item 9)

**[Measured] Works on the current `gl_compatibility` renderer, in this harness:** `SubViewport` native render with nearest filtering; `snap_2d_transforms_to_pixel` and `snap_2d_vertices_to_pixel`; `CanvasModulate` and `PointLight2D` inside a `SubViewport`; the grade's `hint_screen_texture` inside a `SubViewport`; y-sort; viewport GPU timers (`viewport_get_measured_render_time_gpu` returns real values); 4K output targets.

**Not tested [Unverified]:** live window resizing and fullscreen switching (the harness renders fixed offscreen sizes; an adoption needs a resize handler that re-picks k), web export, other GPU vendors, Steam Deck, and Godot's built-in `stretch/scale_mode = integer`. That setting gives integer scaling with stretch mode `viewport`, but it puts the UI through the same low-resolution viewport, which section 6 rules out. The custom `SubViewport` route tested here keeps the UI separate and allows the smooth-camera remainder. **Nothing found requires leaving the Compatibility renderer.**

## 9. What this means (for the owner's decision, not a decision)

1. **A native-resolution, integer-scaled presentation is technically sound** on the current renderer. It is crisp at every density, cheaper than today's framing, and smooth to walk in with the remainder offset. It is the foundation any professional pixel-art route needs, **including staying at 16 px**: today's 1080p framing (×4.5) is uneven for the existing art too.
2. **Tile = 64 screen px at 1080p** is clean for all three densities at 1080p and 4K. 1440p and 720p need borders or a different view size for 32 px and 64 px. 16 px is the most forgiving: ×2 to ×8 with small borders, and ×3 at 720p is exactly today's view.
3. **64 px cannot be shown pixel-clean at 720p at all**, costs 16× the texture memory, and per E0 §6 costs the most per animation frame. Unless E2 shows a compelling advantage, it fails ChatGPT's proposed cost gate. The harness supports it if the owner wants it kept open.
4. **32 px is technically comfortable** (×2 at 1080p, ×4 at 4K, 4× memory, smooth motion). It remains the most likely "premium high-density" candidate. Whether it beats a **directed 16 px (A+)** is an art question that only E2 can answer.
5. The stepped lantern dither should not be carried into a native-resolution presentation (section 4).

## 10. Limits of this test

- Placeholders can't show what an artist does with extra pixels, and they make B and C look closer than real art would. **No art-quality conclusion should be drawn from B or C.**
- One machine (integrated AMD GPU), one small scene, a scripted walk at fixed steps. Motion GIFs are 50 fps captures of fixed steps, not real-time play.
- The motion and probe numbers come from the transforms and captures the harness applied. Free-camera screen positions are only computed from floats, not measured, so they are left out of the motion table.
- The column A farmer has no lantern art. The 16 px placeholder lantern is drawn in its hand, and the 16 px placeholder contact shadows are used under the A house, oak and farmer. Column A uses four frames of the W-3p crop strip for the crops, and the window lights sit at the placeholder house's window positions.

## 11. Review package

In `art/style_tests/ART-005/review/` (with `.gdignore`):

- **Masters** (attach to ChatGPT, in order): `ART-005E1_master.png` (1:1 crops, day), `_master_2` (1:1 crops, night), `_master_3` (scaling matrix and clarity probe), `_master_4` (four columns, day and night), `_master_5` (camera steps, lantern swing), `_master_6` (walk strips), `_master_7` (E0 design sheet, composition, UI).
- **Sheets:** `e1_density_{day,night}_1080p.png`, `e1_crops_1to1_{day,night}_1080p.png`, `e1_scaling_matrix.png`, `e1_probe_1080p.png`, `e1_camera_steps.png`, `e1_ui_separation.png`.
- **Motion:** `e1_walk_day_int.gif`, `e1_walk_day_today.gif`, `e1_walk_camera_modes.gif`, `e1_walk_night_lantern.gif`, `e1_lantern_smooth_vs_stepped.gif`, `e1_lantern_swing.gif`, each with a `_frames.png` strip.
- **Numbers:** `e1_metrics.json` (probe, walk, swing, perf).
- **Proposed spec and E2 plan:** `AI_COLLAB/ART_005_STYLE_SPEC.md`, `AI_COLLAB/ART_005_E2_ARTIST_TEST_PLAN.md`.
