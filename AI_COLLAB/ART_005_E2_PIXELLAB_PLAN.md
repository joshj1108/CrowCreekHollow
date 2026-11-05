# ART-005 E2-PL — PixelLab alternative to the artist test (plan only)

Task: **ART-005, stage E2-PL — PLAN ONLY.** Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **proposal. No generation has been run and no generation has been spent.** D-013 says "further PixelLab spending" is not authorized, so this plan needs the owner's explicit approval before any call that costs generations. The artist plan (`ART_005_E2_ARTIST_TEST_PLAN.md`), E0, E1, production art, `DESIGN.md` (which still names SpriteCook), the camera, gameplay and saves are all unchanged.

Labels: **[Doc]** stated in PixelLab's own tool descriptions or docs as of 2026-11-04; **[Measured]** checked with a free PixelLab call today; **[Estimate]** my judgement, not calibrated; **[Unverified]** not checked.

## 0. Summary

- **What it is.** The same four-piece sample as the artist test (house corner, oak section, grass→path set, 8-frame walk), made with PixelLab at **32 px per tile**. Every piece is generated from **one style anchor and one forced palette**, then repaired with reference-guided editing, masked inpainting and hand cleanup. It is judged in the E1 harness at gameplay scale against the same failure gates and rubric as the artist test.
- **16 px** is an optional second phase, and partly limited by the tools (§1.3).
- **Cost.** 32 px: **about 200 generations [Estimate]**, under a **hard ceiling of 250**. With the optional 16 px phase, the hard ceiling is **350 generations in total**. That is 7% of this month's plan allowance (4,960 of 5,000 left [Measured]). **USD 0** extra: the account's credit balance is $0, and the plan buys no credits and no upgrade.
- **Gate 1 is cheap.** The anchor and the house corner come first, capped at **70 generations**. That is the same question as the artist test's G1: can this pipeline reach the bar at all?
- **Escalation is defined up front** (§7). If PixelLab fails the gates, the next step is the artist test's G1, or a hybrid where an artist draws only the anchor and the keyframes.

## 1. What PixelLab can do now (reviewed 2026-11-04)

I read the tool descriptions on the connected MCP server, the platform overview (`pixellab://docs/overview`) and PixelLab's help agent. The only calls made were free ones: balance, capability and price lookups, and the help agent.

### 1.1 Tools relevant to this test

| Need | Tool | What it does here | Cost [Doc] |
| --- | --- | --- | --- |
| Style anchor, multiple candidates | `create_image_pro` | Up to 4 **labelled** references ("outline", "material") plus one style image with selectable traits (palette, outline, detail, shading), and an exact forced `palette`. Returns a set of candidates: 64 at ≤ 32 px, 16 at 51–64 px, 4 at 86–170 px. | 10 for a square canvas of 16–32, 43–64 or 86–128 px; 15 for 33–42, 65–85 or 129–170 px. A non-square canvas is priced at submit; cancelling before completion is free. |
| One image in an anchored style | `create_image_pro_flash` | Pass the same style image on every call to keep a set consistent. Style traits are selectable. Takes a forced `palette` and `max_colors`. The style image must fit inside the canvas without resizing. | By longest side: **5** up to 96 px, **6** for 100–208 px, **9** for 212–256 px. 128×192 = 6 [Measured]. |
| Reference-guided edit | `edit_image_pro_flash` (method `reference` or `text`) | Edits at the native size, with optional palette correction to the source colours. | Same ladder: 5 / 6 / 9 |
| Batch edit of frames | `edit_image` (pro) | The same edit applied consistently to up to 16 frames (≤ 64 px), so all walk frames get one fix together. | 10 per call, whatever the frame count |
| Masked repair | `inpaint_image_pro_flash` | Pixels outside the mask stay **byte-identical**. Takes a context image so the repair matches its surroundings. | 5 / 6 / 9 by the source canvas |
| Terrain transition | `create_topdown_tileset` | A Wang **corner** tileset: 16 tiles for two terrains, with per-tile corner metadata. That is the same corner logic as the game's dual grid (`DUAL_FRAME_BY_MASK`). Pro mode takes a forced palette and a view. It has **no style-image input** [Doc, help agent]. | pro: **15** at ≤ 32 px; standard: 1 (no palette) |
| Fill variants and decals | `create_image_pro` at 32×32 | 64 candidates in one call, anchored to the style image and the palette | 10 |
| Character from our own frame | `create_character_pro_flash` with `source_image_id` | Turns an approved south frame into 8 views. Only the rotations are charged. | 32×64: 5 for the image + 1 for rotations = 6 [Measured]; 1 when the source is reused |
| Walk, template | `animate_character` `mode=template`, `walking-8-frames` | A fixed skeleton clip | 1 per direction (≤ 92 px canvas) |
| Walk, steadier identity | `animate_character` `mode=skeleton-v3` | Poses the template clip onto the character, so it moves the character rather than redrawing it each frame (beta) | 3 per direction |
| Walk from a loose frame | `animate_image_pixminimax` | Text-described motion from our cleaned first frame. Can pin the last frame. | 1 for 4–8 frames at ≤ 64 px |
| Shared palette across frames | `reduce_colors` (with `palette_image`) | Quantizes all frames together onto our palette | 0.1 |
| Grid cleanup | `correct_pixelart` | Removes strays and tightens the palette without resizing; frames are corrected together | 0.1 |
| Hand pixel work and QA | `pixelart_workbench` | Exact guarded pixel edits; `lint`, `clusters`, `measure`, `motion` (frame deltas, seam, flashes, area drift), `silhouette`, `score`, `selout`, `clean-lines`, `aa`, `repair` | **free** |
| Price checks | `get_pro_flash_capabilities` | Exact quote for a size | **free** |

### 1.2 Integration with layered editing and Godot

- **Output is flattened PNG.** PixelLab makes no layered source. The help agent couldn't confirm whether the Aseprite extension keeps layers. **Aseprite is not installed on this machine** [Measured]. Plan: a small script splits each approved PNG into the spec's layers by palette membership. Outline = the darkest ramp step on the silhouette edge; `fx_emissive` = lantern-ramp pixels; `flat`, `shade` and `highlight` by ramp step. It writes them as separate layer PNGs plus a manifest. The owner decides whether an `.aseprite` assembly step is wanted (§9).
- **Contact shadows** are drawn as a separate layer by the E0 formula (1e2230 at alpha 96), never generated. A baked shadow in a generated sprite is a defect (§5, C4).
- **Godot:** approved files go to `art/style_tests/ART-005/pl/32/` (and `pl/16/`) under the **same file names as the placeholders**. The harness gets one additive option, `art=pl`. Its default output stays the same, which I'll check by re-running one E1 still and comparing it byte for byte. The tileset's corner metadata is mapped onto the dual-grid masks by a script that writes the composed `ground.png` the harness already loads.
- **Asset IDs** go into `art/style_tests/ART-005/pl/pixellab-assets.json`. The production registry `spritecook-assets.json` is not touched.

### 1.3 Limits that shape the plan

1. **Style transfer has no strength setting.** It is an on/off choice per trait. The help agent had no data on how well traits hold across separate calls. That is exactly what the test measures (C9, C10).
2. **The terrain tileset can't take a style image.** Its match to the anchor relies on the forced palette and the prompt alone. The fill variants and decals (style-anchored) and inpainting with context make up the gap. This is the biggest consistency risk.
3. **16 px is weak in PixelLab.** 16×16 creation is "experimental" and always passes through image-to-pixel-art. Editing and inpainting start at **32×32**, so a 16×32 farmer frame can't be repaired by AI. At 16 px the house and oak sections (64×96, 80×96) work normally; the farmer and any 16 px fixes are **hand cleanup only**.
4. **A style image must fit inside the output canvas, without resizing.** Anchors are therefore made at several native sizes: a 96×96 board for the house and oak, and a 32×32 crop for tiles and the farmer. Resizing an anchor would break the no-resampling rule.
5. **Rotated characters take a straight-on south frame** as their source. The walk is east-facing, so the east view comes from the rotation set and is cleaned by hand before it is animated.
6. **Licensing [Unverified].** Commercial-use terms for subscription output must be checked by the owner against PixelLab's Terms of Service before anything goes toward production. The artist plan's rights clause ("no AI generation in the deliverables") applies to the artist route only.

## 2. Style-reference creation method

One anchor family is made before any asset. Every later call takes it as the style source.

1. **Palette (free).** Upload `e0/palette.png` and pass the 52 hex colours as `palette` (`palette_name: "Crow Creek Hollow master"`) on every call that accepts one. The forced palette makes every output pixel a palette colour [Doc]. The validator then checks the in-palette rate at 100%.
2. **Style board (10–20 generations).** `create_image_pro`, 96×96, forced palette, **4 candidates per call**, prompt written from spec §§3–5: a 3×3 grid of 32 px material swatches (shingle, plank wall with corner post, foundation stone, bark, oak leaf mass, grass with tufts, packed path with pebbles, the edge of a lit window, the farmer's coat cloth); selective 1-px outline, key light from the upper left, clusters of at least 2 px, no dithered gradients. Labelled references: `e0/design_sheet.png` crops ("light model and ramp order", "outline rule"). At most 2 calls.
3. **Cleanup (free).** Pick one board. Repair it in `pixelart_workbench` (`lint`, `clean-lines`, `selout`, `repair`) until it passes the validator's palette, alpha and orphan checks and shows the light direction clearly.
4. **Anchor set (free).** From the approved board, cut native crops: a 96×96 **board** (house, oak), a 64×64 crop (fixes), and a 32×32 **material tile** and a 32×32 **cloth and skin swatch** (tiles, farmer). Crops only, never resized.
5. **Second anchor.** Once the house corner passes Gate 1, it becomes a labelled reference ("same outline, light and material rendering") for the oak and the farmer, next to the board. A finished asset ties the family together better than a swatch.
6. **At 16 px**, a separate 48×48 board is made the same way (10 generations). Nothing is downscaled.

Every anchor and its asset ID go in `pl/anchors/`, with the prompt, seed and settings recorded.

## 3. Tool-by-tool workflow and expected generations (32 px)

Each phase lists its calls, the most it may spend, and a stop rule. Cleanup in the workbench is free and is always tried before another paid call.

| Phase | Piece | Calls | Expected | Cap |
| --- | --- | --- | --- | --- |
| P0 | Setup | upload palette and design-sheet crops, price quotes, `list_images` | 0 | 0 |
| P1 | Style anchor | `create_image_pro` 96×96 ×1–2 (10 each); workbench cleanup | 10–20 | 20 |
| P2 | **S1 house corner** (≈ 128×192: eave and shingles, one window, plank wall, corner post, foundation, porch step) | `create_image_pro_flash` 128×192, style = board, palette forced, 3 seeds (6 each); `inpaint_image_pro_flash` fixes ×2–3 (6); night window: `inpaint_image_pro_flash` on the window mask, "lit from inside, lantern ramp, mullions" ×1–2 (6); `correct_pixelart` (0.1) | 36–48 | 50 |
| **Gate 1** | review P1 + P2 in the harness, day and night | — | — | **P1 + P2 ≤ 70** |
| P3 | **S2 oak section** (≈ 160×192: lower crown edge, trunk, root flare, leaf litter) | `create_image_pro` 160×192, style = board, references = house ("outline, light"), 4 candidates (priced at submit, expected 10–15) ×1–2; `inpaint_image_pro_flash` for the crown scallops and roots ×2–3 (6) | 22–48 | 50 |
| P4 | **S3 grass → path** (16-piece corner set + 2 grass and 2 path fills + 3 decals) | `create_topdown_tileset` pro, 32 px, high top-down, transition 0, forced palette, meandering edge (`boundary_amplitude` about 0.15) ×1–2 (15); fills and decals: `create_image_pro` 32×32, style = material tile, 64 candidates ×2 (10); repair any piece that misses the anchor with `inpaint_image_pro_flash` on a 64×64 2×2 tile context ×0–2 (5) | 35–50 | 55 |
| P5 | **S4 walk** (farmer facing right: 8-frame walk with lantern lag, 1 idle frame; 32×64) | south design `create_image_pro_flash` 32×64, style = cloth swatch, reference house ×2 (5); `create_character_pro_flash` from that image (rotations ≈ 1); clean the east view by hand; three walk methods once each: template `walking-8-frames` (1), skeleton-v3 (3), `animate_image_pixminimax` from the cleaned east frame with "lantern swings 1–2 frames behind the hand" (1); re-roll the best ×1 (1–3); batch `edit_image` on the 8 chosen frames ×1 (10); idle `breathing-idle` (1); `reduce_colors` with the palette (0.1) | 15–30 | 45 |
| | **32 px total** | | **≈ 120–200** | **hard 250** (sum of caps 220 + 30 reserve for one re-roll anywhere, released only with a note on the board) |
| P6 (optional) | 16 px directed comparison: 48×48 board (10); house 64×96 (5 ×2 + inpaint 5 ×2); oak 80×96 (5 ×2 + inpaint 5 ×2); tileset 16 px pro (15); farmer 16×32 via `create_character_pro_flash` (6) and template walk (1); **hand cleanup only** for 16 px fixes | ≈ 70–90 | **hard 100** |
| | **Grand total** | | | **hard 350**, USD 0 |

Rules that apply to every phase:

- **Never generate a piece without the anchor.** No unrelated or unanchored call. The only text-only call is the board in P1.
- **Prefer repair to re-roll.** Order: workbench (free) → inpaint with a mask (keeps the rest byte-identical) → reference edit → a new seed, only if the composition itself is wrong.
- **The balance is checked and recorded** before and after each phase. Each job's receipt is logged with its generation cost in `pl/pixellab-assets.json`.
- **A phase stops at its cap.** I report on the board and continue only with the owner's approval. Cancelling a job before it finishes costs nothing [Doc], so a mispriced job is cancelled.
- **Hand cleanup time is logged per piece** (minutes in the workbench), the PixelLab equivalent of the artist's time log, for the extrapolation in §6.

## 4. Order and gates

| Gate | After | Question | Stop if |
| --- | --- | --- | --- |
| **G1** | P1 + P2 (≤ 70) | Does the house corner pass every failure gate (§5) and reach the bar in the harness, day and night? | It fails a gate after 2 repair rounds, or the owner and ChatGPT judge it clearly short of the bar |
| **G2** | P5 | Does the walk pass the animation tests (A1–A7)? Animation decides the whole-game cost. | Every method fails A3 or A4 after one repair round |
| **G3** | P3 + P4 | Does the family hold together (C9, C10)? | The blind same-hand test fails |
| **G4** | All | Rubric and extrapolation (§6); owner decision | — |
| G5 (optional) | P6 | Is directed 16 px close enough to 32 px to justify its lower cost? | — |

The walk (P5) comes before the oak and the terrain because animation was the weakest point in ART-001 and drives the cost. This matches the artist plan's order.

## 5. Acceptance tests

Every test is run on the **approved** PNG, at its own size, and then in the E1 harness (`density=32 art=pl`, integer framing, smooth camera, 1080p and 720p, day 12:00 and night 21:30).

### 5.1 Per-asset failure gates (validator, spec §11, already scripted in `tools/art005_check.py`)

| ID | Test | Pass |
| --- | --- | --- |
| C1 | Opaque pixels in the master palette, exact | 100% |
| C2 | Colours per asset | ≤ 24 (farmer ≤ 20) |
| C3 | Partial alpha on sprites | 0% |
| C4 | No baked ground shadow (the bottom rows contain no 1e2230-like skirt); the shadow is its own layer | review + `measure` |
| C5 | Orphan pixels | ≤ 0.5% |
| C6 | Dark outline on the silhouette (props, farmer) | ≥ 85%, from the material's darkest step, ink only against light ground |
| C7 | Grid: not resampled; width and height multiples of 16 | yes |

### 5.2 Family consistency

| ID | Test | Pass |
| --- | --- | --- |
| C8 | **Light direction.** Along the silhouette, pixels facing up or left average at least 1 ramp step lighter than those facing down or right. A small proposed addition to the validator. | every asset |
| C9 | **Cluster scale.** The median same-colour cluster size of each material (workbench `clusters`) is within 1.5× across the four assets: grass in the tileset vs grass at the oak's foot, timber in the house vs path pebbles vs the farmer's coat. | all pairs |
| C10 | **Blind same-hand test.** The owner and ChatGPT see the four pieces plus one decoy (an unanchored PixelLab call already in the gallery, or W-3 art). They name the decoy and agree that the other four read as one hand. | both |
| C11 | **Perspective and proportions** (spec §6): straight-on 3/4, eave and sill lines level, no isometric diagonals; farmer 1.85 ± 0.1 tiles tall; head ≈ 0.42 tile; door clearance ≥ 0.3 tile; window sill ≈ 1.4 tiles; oak trunk 1.4 ± 0.2 tiles | `measure` |
| C12 | **Night readability:** the spec §9 value budget under the production night tint, measured in the harness | as E1 |
| C13 | **Tileset:** a random 12×8 dual-grid mask shows no seams; edge wander ±0.2 tile; ≥ 3 fill variants; no distinctive feature repeats within 3 tiles in view; the path's shade lip is on the lower-right edge | harness still + review |

### 5.3 Animation

| ID | Test | Pass |
| --- | --- | --- |
| A1 | 8 walk frames + 1 idle, one canvas, feet on the bottom row in the contact frames | exact |
| A2 | **Identity:** one shared palette (`reduce_colors` on all frames together); area drift ≤ 5% (workbench `motion`); hat-top height constant ±1 art px apart from the deliberate bob | yes |
| A3 | **No foot sliding:** at 3.75 tiles/s and 10–12 fps, the planted foot moves ≤ 1 art px against the ground in the harness walk | yes |
| A4 | **No shimmer:** workbench `motion` reports 0 flashes; outline continuity in every frame; the loop seam (frame 8 → 1) is no larger than the biggest frame-to-frame change | yes |
| A5 | **Secondary motion:** the lantern's swing peaks 1–2 frames after the hand's (centroid phase); the coat hem moves | yes |
| A6 | **In context:** the harness walk GIF at 50 fps and the 144 Hz step record, day and night with the lantern; owner and ChatGPT review | no visible pop or judder |
| A7 | **Repair budget:** hand-changed pixels ≤ 30% of opaque pixels per frame. More than that means hand animation, not AI-assisted animation. | yes |

### 5.4 Quality against the premium bar

The trial rubric from the artist plan §7.2 (craft 20, cohesion 20, lighting 15, motion 15, readability 10, mood 10, scalability 10), scored only after every failure gate passes. It is judged from harness 1:1 crops at 1080p.

Benchmark screenshots of commercial games are **not added to the repo** (they're copyrighted). The owner compares against them privately. The review records the score and the reasons only.

## 6. Whole-game extrapolation

From the measured generations and cleanup minutes per piece, scaled to the counts in ART-005 §8 (76 farm PNGs, 28 player sheets of 8 frames, 20 UI PNGs, plus trek, cave, interior and walkers): generations per tile-area of S1 and S2, per terrain kit (S3) and per animation frame (S4). The result is a range in **months of plan allowance** and **hours of cleanup**, set beside the artist estimate (42–74 h for the test alone, unverified rates).

## 7. When a professional artist is genuinely needed

Any one of these sends the test to escalation. They are judged at the gates, not after the whole budget is spent.

| # | Trigger | Escalation |
| --- | --- | --- |
| X1 | No anchor board passes cleanup after 2 calls (P1) | An artist draws **only the style board and design sheet** (a few hours [Estimate]). PixelLab then repeats P2 from that anchor. |
| X2 | Any failure gate (C1–C7, C11, C12) still fails after 2 repair rounds on one asset | The artist test's G1 (house corner at 16 and 32 px) |
| X3 | Hand-repaired pixels > 30% of an asset (A7, or the same measure on a still) | The tool is not saving work. Artist for that asset class |
| X4 | All three walk methods fail A3 or A4 after one repair round | **Animation by an artist** (keyframes or the whole cycle); PixelLab stays for environment art |
| X5 | The blind same-hand test (C10) fails | An artist as **style lead**: anchors, keyframes and review of PixelLab output |
| X6 | Rubric: overall < 7/10, or craft, cohesion or motion < 6, by the owner and ChatGPT | Hybrid or the artist route, chosen by the owner |
| X7 | Extrapolation: more generations than about 2 months of the plan, or cleanup hours above half the artist's estimate for the same scope | The artist route is cheaper in practice |

The possible outcomes, for the owner to choose at G4:

1. **PixelLab pipeline:** the anchor family, the repair workflow and the validator become the working method (still outside `DESIGN.md` until the owner changes it).
2. **Hybrid:** an artist makes the anchor, keyframes and reviews; PixelLab makes variants and in-betweens; I clean up and validate.
3. **Artist-led:** the existing E2 artist plan from G1, using what this test learned about the spec.

## 8. What stays untouched

E0 and E1 files and results; `ART_005_E2_ARTIST_TEST_PLAN.md`; production art, `DESIGN.md`, `spritecook-assets.json`, `main.gd`, the camera, scaling, night lighting, saves and slots 1–3; VIS-002 and W-4 work; the uncommitted `.import`, `.uid`, `project.godot`, `main.tscn`, `trek_system.gd` and grade changes. All output goes to `art/style_tests/ART-005/pl/`. The harness gets one additive `art=pl` option, with a check that its default output is unchanged.

## 9. Owner decisions needed before any generation

1. Lift D-013's "no further PixelLab spending" **for this test only**, with the hard ceilings: **250 generations for 32 px**, **350 including the optional 16 px phase**, **USD 0** (no credits and no plan change).
2. Approve the scope: S1–S4 at 32 px; the 16 px phase (P6) yes, no, or decide at G4.
3. Approve stopping at **G1 (≤ 70 generations)** for review, as recommended, or running P1–P5 straight through with stops only at caps.
4. Layered sources: accept the scripted layer split (PNG layers plus a manifest), or install Aseprite (a paid tool) for `.aseprite` assembly.
5. Check PixelLab's commercial-use terms before any of this art goes toward production.
6. Confirm the escalation triggers (§7) and that the artist plan stays on hold, not cancelled, during this test.
