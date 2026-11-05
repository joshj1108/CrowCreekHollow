# Visual pipeline reassessment

Task: **ART-005** (proposed). Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **assessment and experiment proposal — documents only. Nothing here is approved.** No production art, code, layout, save, camera, scale, `DESIGN.md` or night-lighting change. PixelLab 0, SpriteCook 0.

Labels: **[Observed]** read in this repo; **[Measured]** from an earlier recorded test; **[Estimate]** a judgement with no measurement behind it; **[Unverified]** general industry knowledge not checked for this document.

---

## 1. The owner's direction (2026-11-04)

The owner has confirmed the primary visual goal: **exceptional, professional-quality pixel art** across the whole playable game, at the level of cohesion, environmental detail, animation and polish associated with premium commercial pixel-art games (Eastward, Sea of Stars and Hyper Light Drifter are named as *quality* references, not art to copy).

- The approved concept paintings are **not** to be reproduced pixel for pixel. They remain mood, composition and palette guides.
- Premium high-density pixel art is the **leading candidate** for the future pipeline.
- The logical **16×16 farming and collision grid stays**.
- Source-art density, presentation scaling, texture quality, terrain transitions, sprite proportions and animation are open for reconsideration. **32 px and 64 px per logical tile are technical options, not decisions.**
- Unified, handcrafted-looking art is preferred over mixing incompatible AI-generated families.
- Consistency between characters, buildings, trees, terrain and props is a priority.
- Warm autumn days and threatening atmospheric nights are kept.
- HD-2D and illustrated 2D are **secondary** alternatives, only if the pixel-art route proves inadequate.
- **Success criterion:** a production pipeline that holds professional quality across an entire game, not ever more detailed isolated sprites.

Recorded as `DECISIONS.md` D-013. It changes the *goal* of ART-003/ART-004 scoring, not any locked rule: the locked 16 px / 3× rule in `DESIGN.md` stays in force until the owner changes it.

## 2. Where the project stands

[Observed] in the repo and on the board:

- **Production:** SpriteCook `pixel-engine-image-v1` art at 16 px, shown at 3× on a 1280×720 `canvas_items` canvas: 76 farm PNGs, 28 player sheets (idle, walk and seven tool actions × three directions), 20 UI PNGs. Much of the rest (trek, cave, interior, unbuilt buildings, fallbacks in `scripts/farm_art.gd`, 923 lines) is still drawn in code.
- **ART-003 prototype** (non-production): a mostly PixelLab homestead, hand-fitted and script-edited, scored by ChatGPT 57.75 → 72.0 over eight rounds. W-4 is built and awaiting review.
- **ART-002** [Measured]: PixelLab regenerated five assets at 32 px. At the game's real scale they read "slightly softer and busier rather than clearly better"; 32 px lands on 1.5 screen px per art pixel at 1280×720; generator variance (a different design at each size) confounded the comparison.
- **The known ceiling of the current method:**
  - Two AI families (SpriteCook and PixelLab) that do not share a palette, outline rule or cluster style (register C-12). ChatGPT and I both flagged mismatches in nearly every round (the woodstore "cabinet", the conifer frame, the gate).
  - Every generation is a new design: no reliable way to make a second asset *of the same hand*, or the same asset at another size.
  - Cleanup has been scripted pixel placement by me. It fixes defects; it does not add the cluster control, hand anti-aliasing and material rendering that distinguish professional work.
  - There is almost no hand animation: the farmer's sheets are generated, and environment motion is engine-side (lights, particles).

**Conclusion:** ART-003 shows the AI-first route can reach a coherent *prototype* (72/100). It has not shown — and I do not expect it to show — the consistency and craft the owner now asks for across a whole game.

## 3. What makes professional pixel art professional

The quality references differ a lot in density, so **resolution is not what they have in common.** [Unverified] Hyper Light Drifter, for example, is widely reported to render at a low native resolution (about 480×270) scaled up; Sea of Stars is known for dynamic lighting on pixel art; Eastward for very dense hand-painted environments and expressive animation. What they share is discipline. These are the techniques the pipeline has to deliver, roughly in order of impact:

| # | Technique | What it means here | Current state |
| --- | --- | --- | --- |
| T1 | **One pixel size everywhere** | Every sprite, tile, particle, light step and UI-in-world element lands on the same art-pixel grid. No "mixels" (pixels of different sizes side by side), no resampled sprites, no sub-pixel rotation. | Mostly true at 720p (3×). At 1080p, 4.5× gives uneven columns [Measured, ART-002]. Particles and light falloff are not on the art grid except `LIGHTING_V2`'s stepped falloff. |
| T2 | **Fixed native resolution, integer scale, controlled camera** | Render the world at a native size, scale by a whole number, and move the camera so the art does not shimmer or judder. | `canvas_items` stretch at a 1280×720 base; no native-resolution render target. |
| T3 | **A master palette of material ramps** | A small set of ramps (moss, bark, timber, stone, shingle, soil, water, skin, cloth, lantern-warm) with hue-shifted shadows and highlights, shared by every asset. Day/night handled by lighting, not by repainting. | No enforced palette. Each AI family brings its own. ART-003 forced a concept palette on PixelLab only. |
| T4 | **One light model** | A single key-light direction, one shadow shape language (contact shadows, cast shadow angle), consistent rim/AO treatment. | Varies by asset; some baked shadows, some none. |
| T5 | **Cluster and line discipline** | Readable clusters, no single-pixel noise, deliberate hand anti-aliasing, selective outlines (dark outer line, lighter interior lines). | Mixed; ART-001/002 reviews found noise and missing outlines in generated art. |
| T6 | **Modular kits drawn by one hand** | Terrain with full transitions and variants, building kits (walls, roofs, windows, trims) and foliage kits, so new content is assembled, not regenerated. | Five dual-grid ground sets [Observed]; buildings and trees are one-off images. |
| T7 | **Style frame first** | One finished target screen (a "style frame"/mock-up) drawn at final density before assets are cut from it. Every later asset is judged against it. | Concept paintings exist but are not at game density or on a grid. |
| T8 | **Hand animation with secondary motion** | Keyframed, hand-cleaned frames; anticipation and follow-through; secondary motion (lantern swing, coat, hair); ambient environment loops (leaves, grass, smoke, water, crows). | Generated farmer sheets; environment motion is engine-only. |
| T9 | **Lighting and atmosphere as part of the art** | Pixel-stepped light, fog layers and particles authored to the same pixel size; optionally normal-mapped sprites for dynamic light. | `LIGHTING_V2` and R3-1 night are good foundations. |
| T10 | **Process** | An art lead who owns the style guide, a review cadence, Aseprite-style source files with layers, scripted export, and automated checks. | Board reviews exist; no style owner with drawing authority; no source files (only flattened PNGs). |

T1–T3 are cheap and technical. T5–T8 are where the hours go and where AI generation is weakest.

## 4. Density and presentation: the arithmetic

The logical tile stays 16 world units. What changes is how many **art pixels** a tile has and how many **screen pixels** it covers. The pixel-cleanliness rule (T1) needs screen px per art px to be a whole number.

**Today's framing** (tile = 48 screen px at the 1280×720 base, ≈ 26.7 × 15 tiles in view):

| Output | Tile on screen | 16 px art | 32 px art | 64 px art |
| --- | --- | --- | --- | --- |
| 1280×720 | 48 px | **3×** clean | 1.5× uneven | 0.75× — art is **downsampled**, detail lost |
| 1920×1080 | 72 px | 4.5× uneven | 2.25× uneven | 1.125× uneven |
| 2560×1440 | 96 px | **6×** | **3×** | 1.5× uneven |
| 3840×2160 | 144 px | **9×** | 4.5× uneven | 2.25× uneven |

**Key finding:** with today's framing, **64 px art can never be shown pixel-clean at 1080p or below**, and at the 720p base it is literally thrown away. 64 px is only meaningful if the tile covers at least 64 screen px, which is a presentation change.

**A framing that suits all three** (tile = 64 screen px at 1920×1080, ≈ **30 × 16.9 tiles** in view, about 12% wider than today):

| Native render | Integer scale to 1080p | to 2160p | to 1440p |
| --- | --- | --- | --- |
| 16 px: 480×270 | **4×** | **8×** | 5.33× (5× with borders) |
| 32 px: 960×540 | **2×** | **4×** | 2.67× (2× with borders) |
| 64 px: 1920×1080 | **1×** | **2×** | 1.33× (1× with borders, or filtered) |

1440p is awkward for every option; that is normal for pixel-art games [Unverified] and is usually handled with borders or a slightly different zoom. The proposed experiment uses this framing so the three densities are compared on equal, clean terms. It is a non-production camera change only; adopting it would need the owner under D-007 and C-14.

**What each density implies for the game's sizes** (from `DESIGN.md`: farmer 16×32, farmhouse 192×160):

| | 16 px | 32 px | 64 px |
| --- | --- | --- | --- |
| Farmer frame | 16×32 | 32×64 | 64×128 |
| Farmhouse | 192×160 | 384×320 | 768×640 |
| Pixels per asset (relative) | 1× | 4× | 16× |
| Character read | iconic, silhouette-driven | expressive faces, clothing folds, clear tool poses | near-illustrated; small animation errors become very visible |
| Typical feel | chunky, classic | "high-density" premium pixel art | HD sprite art; at this size many studios move to painted, rigged or 3D-rendered pipelines [Unverified] |

My reading, to be tested rather than assumed: **32 px is the most likely sweet spot** for "premium high-density" on a 16-unit grid. It quadruples pixels, not hand-hours by four (big flat areas do not cost per pixel), keeps a farmer readable at 2× scale, and stays hand-animatable. **64 px risks crossing from pixel art into HD sprites**, where character animation cost grows with area and where the "one visible pixel" quality that defines the genre disappears at 1×. The experiment exists to check this, including the possibility that a well-directed 16 px beats both.

## 5. Production workflows

| Workflow | Description | Quality ceiling | Fit for the owner's goal |
| --- | --- | --- | --- |
| **W1. AI-first** (current) | PixelLab / SpriteCook generate; I fit and script-clean. | Prototype-coherent (ART-003: 72). Per-asset variance, no shared hand, weak animation. | **Insufficient on its own.** |
| **W2. AI-assisted, artist-finished** | AI for ideation, blockouts and variants; a pixel artist repaints every shipped asset in a layered source file against the style frame and palette. | High, if the artist owns the final pixels. AI saves time mainly on ideation and on low-value variants. | Viable. Savings on hero art and animation are small [Estimate]. |
| **W3. Artist-led, tool-supported** (recommended) | A lead pixel artist makes the style frame, palette, kits and character keyframes. AI is optional for variants or reference. I build the engine side: native-resolution rendering, camera, lighting, kit assembly, import automation, and automated QA. | Professional; limited by the artist and time. | **Best fit.** |

**When each kind of human work becomes necessary:**

- **Manual pixel editing** (by anyone): always, for every shipped asset. It is required for T5: no generator reliably produces clean clusters, deliberate anti-aliasing, a shared palette and matching outlines at the same time [Observed across ART-001 to ART-003].
- **A dedicated pixel artist:** for the style frame, the master palette, every hero asset (house stages, the oak, the farmer and the walkers), the terrain kit and all character animation. These set the standard everything else is checked against. I can place pixels exactly by script and I can check rules, but I do not draw with an artist's eye for form, and I should not be presented as one.
- **Animation tools** (Aseprite or equivalent, with onion skin, tags and layers): for every character sheet and environment loop. Generated animation (PixelLab v3, SpriteCook animate) can serve as reference timing only; frame-to-frame consistency is the hardest part of player art [Observed, ART-002].
- **A disciplined asset workflow:** layered source files kept in the repo (not only flattened PNGs), a palette file, a naming and size convention, scripted export to PNG strips, a Godot import step, and review against the style frame, not against the previous round.

**What I can contribute in W3** (technical, not artistic): the native-resolution `SubViewport` and camera, pixel-stepped lighting, a kit assembler for buildings and terrain, Aseprite-CLI export and import scripts, and **automated art checks**: palette conformance, orphan pixels, outline continuity, mixel detection, sprite-size and grid alignment, and night-readability contrast. These catch regressions at scale, which is the hard part of "the whole game", not one sprite.

## 6. Secondary alternatives (only if pixel art proves inadequate)

| Option | What it is | Why it is secondary here |
| --- | --- | --- |
| **HD-2D hybrid** | Pixel sprites in a lit 3D scene (depth of field, real shadows, bloom). | Needs the Forward+ renderer and 3D scenes, not the current `gl_compatibility` 2D pipeline; changes the camera (D-004) and the whole tech stack; strong look but a different game to build. |
| **Illustrated 2D** | Painted, non-pixel sprites and backgrounds at screen resolution. | Closest to the concept paintings, but loses the pixel identity the owner chose; needs a painter and a different animation approach (rigging or frame painting). |

I would only reopen these if the experiment shows 32 px and 64 px both fail on cost or animation while 16 px fails on richness.

## 7. Proposed experiment: ART-005 density comparison

**Purpose.** Compare existing 16 px art with professionally directed 32 px and 64 px art on one identical scene, in Godot, day and night, still and moving, with the effort recorded, so the owner can choose a density, a presentation and a production model on evidence.

### 7.1 Controls (identical across columns)

- **Scene:** one 30 × 17-tile vignette laid out on the 16-unit grid, built from the ART-003 V1-B composition (house, oak, well) with a small garden added. One layout file shared by all columns. Collision is not exercised; nothing touches the live farm.
  - one farmhouse (the restored stage, wall A palette family, porch and windows);
  - one ancient oak (crown, trunk, roots, leaf litter);
  - a path from the porch with grass → path and grass → soil transitions, and edge wear;
  - a small garden: four beds, a fence run, two crops at two growth stages;
  - the player with a lantern at the same tile, facing down, plus a short walk.
- **Framing:** tile = 64 screen px at 1920×1080 (30 × 16.9 tiles), each column rendered at its native resolution and scaled by a whole number (section 4). A second strip shows each column at **today's** framing (1280×720 `canvas_items`) so the owner sees what adopting it without a presentation change would look like.
- **Conditions:** 12:00 day and the accepted R3-1 night at 21:30, with the same grade, `CanvasModulate`, `LIGHTING_V2` and lantern/window lights. Dusk optional.
- **Camera:** the same position and the same scripted walk in every column.
- **Palette rules** (written once, before any drawing, in an `ART-005/STYLE.md`):
  - one master palette of material ramps (T3), each ramp 4–6 colours with hue-shifted shadows; the same ramps at every density;
  - key light from the upper left, one contact-shadow shape, one cast-shadow angle;
  - outline rule: dark selective outline on outer silhouettes, no black interior lines; the same outline *colour logic* at every density, with line width 1 art px (so it thins on screen at higher density, which is part of what is being judged);
  - value budget for night: the farmer, path and interactables must keep a minimum contrast against the ground under R3-1 night (measured).
- **One design, three renderings:** a single design sheet (silhouettes, proportions, materials, details) is drawn first. Each density is then **drawn natively** to that sheet, not resampled, so differences come from density and not from a generator rolling new designs (the ART-002 confound).

### 7.2 Columns

| Column | Content | Source |
| --- | --- | --- |
| **A. Existing 16 px** | ART-003 W-4 baseline art (house C, golden oak, G1, garden, current farmer) unchanged | Already in the repo; 0 new art |
| **A+. Directed 16 px** (recommended addition) | The same design sheet drawn at 16 px to the new style rules | New |
| **B. Directed 32 px** | Same, at 32 px per tile | New |
| **C. Directed 64 px** | Same, at 64 px per tile | New |

Without **A+**, any gain in B or C mixes two causes: better direction and more pixels. A+ separates them for about 10–15% of the experiment's art hours (section 8) [Estimate]. I recommend it, but it is the owner's choice.

### 7.3 Who makes the art (owner decision; no PixelLab spending assumed)

| Option | How | Cost | What the result can show |
| --- | --- | --- | --- |
| **M1. One professional pixel artist** (recommended) | Commission the design sheet, palette and A+/B/C from one artist, with Aseprite source files and an hours log. | Hours below; the owner obtains quotes. | A real professional quality bar and real effort numbers. |
| **M2. Claude-authored, zero spend** | I build each column by scripted pixel placement (as with the W-4 log pile), optionally with PixelLab's free `pixelart_workbench` editing tools (no generation credits, if the owner counts them as allowed). | Session time only. | A **technical** comparison (scaling, camera, lighting, performance, the framing) and a rough density feel. **It would not show professional pixel art**, and should not be judged as if it did. |
| **M3. AI blockout + artist finish** | Generate blockouts, then an artist repaints. | Needs a separate PixelLab/SpriteCook budget **and** artist time. | Measures how much AI actually saves under W2. |

A sensible order is **M2 first for the engine side only** (E1 below, columns drawn as flat placeholders of the right size), then **M1 for the art**. That way artist money is spent only once the presentation is proven.

### 7.4 Stages and gates

| Stage | Work | Spend | Gate |
| --- | --- | --- | --- |
| **E0** | `ART-005/STYLE.md`: master palette, light model, outline rule, night value budget, the design sheet brief, the scene layout file, and the artist brief. | 0 | Owner + ChatGPT approve the rules and choose M1/M2/M3 and whether A+ is in. |
| **E1** | Godot harness `tools/art005_density.gd` (non-production, like `art003_wide.gd`): native-resolution `SubViewport` per column, integer scaling, the shared layout, lighting and grade, pixel-snapped camera with a sub-pixel final offset, the walk, capture and perf logging. Column A uses real art; A+/B/C use size-correct placeholders. | 0 | Proves framing, camera smoothness and lighting at each density before art exists. Review of motion GIFs. |
| **E2** | Art for A+/B/C per the chosen option, delivered as layered sources + PNGs into `art/style_tests/ART-005/`. | Per option | Mid-point check on the 32 px house and oak before the rest. |
| **E3** | Integration into the harness; captures, GIFs, perf, effort log, scored review package per `VISUAL_REVIEW_PROTOCOL.md`. | 0 | Owner decides density, presentation and production model. |

### 7.5 Review package (E3)

Following `VISUAL_REVIEW_PROTOCOL.md`, in `art/style_tests/ART-005/review/`:

- Master 1: the four columns side by side, day and night, at the chosen framing.
- Master 2: the same at today's framing (shows the non-integer cases).
- Master 3: 1:1 screen-pixel crops of the house corner, oak crown, a terrain transition, a garden bed and the farmer with lantern, per column.
- GIFs and frame strips: the walk (camera motion, shimmer, judder) and the lantern swing at night, per column.
- A table: hours per asset per column (from the artist's log or mine), file sizes, texture memory, frame time and draw calls at 1080p.
- Scoring with the rubric adjusted as in 7.6.

### 7.6 How to judge it

The ART-004 rubric weights *concept fidelity* at 25%, which the owner has now de-prioritised. For ART-005 I propose (for approval) a temporary weighting:

| Dimension | Weight |
| --- | --- |
| Craft quality (clusters, anti-aliasing, materials, T5) | 20% |
| Cohesion across characters, buildings, trees, terrain, props | 20% |
| Lighting and atmosphere, day warmth and night threat | 15% |
| Motion (animation, shimmer, camera judder) | 15% |
| Gameplay readability, day and night | 10% |
| Mood fidelity to the concept (not pixel fidelity) | 10% |
| **Scalability**: effort per asset × the game's asset count | 10% |

Scalability is in the score because the success criterion is a whole game, not one frame.

## 8. Effort estimates

[Estimate, uncalibrated] Hours for one experienced pixel artist working in Aseprite, including cleanup and one revision. No artist time has been measured on this project; these are planning ranges to compare with quotes. Sizes follow `DESIGN.md` (house 12×10 tiles, farmer 1×2 tiles); the oak is about 5×6 tiles.

| Asset | 16 px (A+) | 32 px (B) | 64 px (C) |
| --- | --- | --- | --- |
| Design sheet, palette, style rules (shared, once) | 8–14 | — | — |
| Farmhouse (restored stage) | 6–10 | 16–28 | 45–80 |
| Ancient oak | 4–6 | 10–16 | 28–45 |
| Terrain: grass, path, soil; two transition sets; 3 variants; 6 decals | 6–10 | 14–24 | 35–60 |
| Garden: beds, fence, 2 crops × 2 stages | 4–7 | 10–16 | 25–40 |
| Farmer with lantern: idle (4) + walk (8) × 3 directions = 36 frames | 8–14 | 20–35 | 60–110 |
| Ambient motion: leaf sway, chimney smoke, lantern swing | 2–4 | 4–8 | 10–20 |
| **Column total** (excluding the shared sheet) | **30–51** | **74–127** | **203–355** |

- **Engine work (me):** E1 harness, 1–2 sessions; E3 integration and package, about 1 session per column. Little of it changes with density.
- **Whole-game extrapolation** [Estimate, rough]: relative to directed 16 px, a full game at **32 px costs about 2–2.5×**, and at **64 px about 5–7×**, with character animation the largest single share (the farmer's 28 sheets, five walkers, animals, the shadow, portraits). Asset counts that bound this today: 76 farm PNGs, 28 player sheets, 20 UI PNGs, plus the trek, cave, interior and everything still drawn in code. The experiment's asset set is a small fraction of that; its main value is the measured hours per asset and per animation frame.
- **Animation dominates at higher density.** Environment art scales sub-linearly with pixel count (big surfaces, reusable kits); character frames scale close to linearly with area, because every frame must be cleaned [Estimate].

## 9. Technical feasibility and performance risks

| Risk | 16 px | 32 px | 64 px | Notes and mitigation |
| --- | --- | --- | --- | --- |
| Pixel-clean presentation | Clean at 720p today; needs native render for 1080p | Needs the native-render change | Needs it, and a tile ≥ 64 screen px | All three are clean under the section 4 framing. |
| Camera judder vs shimmer | 480×270 native snaps in 4-screen-px steps: visible judder at walking speed | 2-px steps | 1-px steps, smooth | Standard fix: snap the world to art pixels and apply the remainder as a sub-pixel offset when scaling up [Unverified technique, to be tested in E1]. |
| Light falloff | `LIGHTING_V2` steps sit on the art grid naturally at low native res | Needs quantised light textures to match the art | Smooth falloff looks off-style unless stepped | Light textures authored per density; test in E1. |
| Texture memory | Small | 4× | 16×: the house alone ≈ 1.9 MB RGBA vs ≈ 0.12 MB | Fine on desktop; a baked 64×40 ground at 64 px is 4096×2560 (≈ 40 MB RGBA) and must be split into chunks. |
| Texture size limits | — | — | Atlases above 4096 px risk failure on Compatibility/web | Chunked ground, per-object sheets. |
| Post-process cost | Grade shader runs on 480×270 if moved into the native viewport (cheaper than today) | 960×540 | 1920×1080 | Today the grade runs at screen size anyway; only 64 px stays at that cost. |
| Draw calls | Unchanged | Unchanged | Unchanged | Same object count; y-sort, not per-frame script sorting [Measured, W-4]. |
| Repo size and import time | Small | Moderate | Large: layered sources and big sheets | Consider Git LFS for sources if 64 px is chosen. |
| Code impact if adopted | The native `SubViewport` refactor is needed for clean 1080p at any density | Same, plus `SCALE`, sheet frame sizes, `FarmSprites`, the dual-grid atlas (16 px frames), the minimap and the capture/review tools | Same as 32 px | `main.gd` assumes `TILE_SIZE 16` and `SCALE 3` [Observed]; the logical grid, collision, saves and layout do not change. UI stays on its own screen-resolution canvas. |
| Gameplay and saves | None | None | None | The logical grid is unchanged in every option. |
| Code-drawn fallbacks | Match | Look coarse beside 32 px art | Look very coarse | Either redraw or retire them as art lands. |

The experiment itself touches none of this in production: it is one new tool script and test art.

## 10. Owner decisions needed

1. Approve this assessment as the basis for ART-005, and the record of the direction as D-013.
2. Approve stage **E0** (style rules and briefs, documents only).
3. Choose the art source: **M1** (artist), **M2** (zero spend, technical only) or **M3** (AI + artist, needs a budget). My recommendation: M2 for E1's engine test, M1 for the art.
4. Include column **A+** (directed 16 px)? Recommended.
5. Accept the experiment framing (tile = 64 screen px at 1080p, ≈ 30 × 16.9 tiles) as a **non-production** test, with today's framing shown alongside.
6. Approve the temporary ART-005 scoring weights (7.6) or keep the ART-004 rubric.

## 11. Preserved

Not touched by this document or the proposed experiment: the live game, gameplay, saves (slots 1–3), the farm layout, camera and scale, `DESIGN.md` and its locked rules, the ART-003 prototype and its W-4 work and review history, the layout-parity plan, VIS-002 work in progress, and all production art. Nothing here is implemented. Stopped for owner and ChatGPT review.
