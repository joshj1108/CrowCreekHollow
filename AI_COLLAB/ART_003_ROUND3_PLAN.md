# ART-003 Round 3 plan

Task: ART-003 Round 3, planned under ART-004. Author: Claude Code, 2026-11-02. Status: **proposed — not approved.** No step starts until the owner authorizes it; production steps need their own approval on top.

Inputs: `AI_COLLAB/CONCEPT_FIDELITY_FEASIBILITY.md` (systems and compromises), `AI_COLLAB/ART_003_SCORECARD.md` (Round 2: 54.5/100, provisional self-score), `ART_DIRECTION.md` (proposed), ChatGPT's Round 1 image review (board, 2026-11-02), and the owner's Round 3 priorities in the ART-004 brief.

## Ground rules for the round

- **Baseline:** ART-003 Round 2 (`tools/art003_round2.gd`, commit `6debb09`) — oak A, the night preview, the 16 px grid and current camera. Round 2 keeps rendering exactly as it does now, as the rollback.
- **Non-production by default:** steps marked *slice* change only test tools and `art/style_tests/ART-003/r3/`. Steps marked *production* change the game and need separate owner approval.
- **One variable at a time.** Lighting, art, layout and composition are changed in separate steps and captured separately, so each step's effect is visible on its own.
- **Lighting problems get lighting fixes; art problems get art.** No new art to fix a lighting gap; no gameplay change to fix an art gap.
- **Stop for review after each section** (`CLAUDE.md`), with a package per `VISUAL_REVIEW_PROTOCOL.md` and a score per `ART_REVIEW_RUBRIC.md`.

## The three highest-impact gaps, ranked

| Rank | Gap | Cause | Visual gain | Cost | Risk | Depends on |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Night correct only in a preview (0.114 preview vs 0.030 game) | Rendering (tint, grade) | Large: lifts lighting *and* readability | Low, no art | Tone; trek, cave and sanity tints | R3-0 |
| 2 | Ground mostly flat grass; repetition; blocky paths | Art (variants, decals, ground cover) + a renderer change | Large by day, every screen | Moderate | Readability of items | R3-1 (judge under the new night) |
| 3 | Oak crown clipped; no fungus or extra charms; henge-like ring | Art + composition | Medium–large on the hero screen | Moderate, 3–6 generations | Low | Generation budget |

The garden (owner priority 4) and forest depth (priority 5) are mostly composition with a few assets, so they follow once the shared ground and lighting are settled.

## Steps

### R3-0 — Matched baseline and measurement (slice, no art)
- **What:** add to the Round 2 tool a production column (the same slice area with the game's own art and lighting), a frame-time and draw-call readout (`Performance` monitors), and the luma measurement from ROUND2. Capture concept / production / Round 2 at 12:00 and 21:30 at 1280×720 and 1920×1080.
- **Why:** the Round 2 package lacks a matched production column (rubric gate 4), and no performance has been measured.
- **Also:** check the Compatibility renderer's per-item 2D light limit in Godot 4.7 and count how many lights can overlap the farm at once.
- **Effort:** about half a day [Estimate]. **Risk:** none.
- **Gate:** none beyond the round's authorization; its output feeds R3-1.

### R3-1 — Production-feasible night (priority 1; rendering only)
- **What:** move the Round 2 night preview into the game behind a new reversible flag (proposed name `NIGHT_V3`, off by default) in `_sky_tint()` / `NIGHT_TINT` and the night grade in `main.gd`. Add a faint warm rim light at the great oak and one at the well, and a cool moon rim on the pond (a large low-energy light or a water shader — test both).
- **Unchanged:** `darkness`, sanity, lamp timing, events, the number of earned lamps, the lantern.
- **Check across:** farm 19:30, 21:30, 23:30; rainy night; fog; low sanity (must still read colder); the cave (must not brighten); a trek clearing (its own tint builds on the same values); interiors.
- **Target:** farm mean luma 0.11–0.15, pixels above 0.12 at 25–40%, forest edges under 0.07 [proposed targets, C-05].
- **Evidence:** BEFORE (flag off) / AFTER (flag on) per scenario, plus the concept 03 crop; luma table.
- **Effort:** about 1 day including captures [Estimate]. **Risk:** low to code; the tone call is the owner's.
- **Gate:** **production — needs owner approval** (outside D-005's four items). Tests: `save_test.gd`, `menu_test.gd`; `balance_sim.gd` not needed (no timing change).

### R3-2 — Oak A refinement (priority 2; art + composition; slice)
- **What:**
  - Regenerate oak A on a 192×192 canvas (12×12 tiles) using `r2/oak_a.png` as the init image, so the design holds and the crown is no longer clipped.
  - Red shelf fungus (2–3 clusters) and 3–4 charms and bundles as **separate** small overlay sprites in one strip, placed on the oak (they can sway and be tied to story state later).
  - Replace the flat ring with 6–10 separate irregular mossy boulders (one strip of variants), y-sorted, with roots running between them; no baked centre.
- **Generations:** about 3–6 [Estimate]. **Blocker:** the PixelLab trial is used up and SpriteCook needs signing in again. Which tool to use is decision 8 below.
- **Evidence:** concept 02/03 oak crop / Round 2 oak / Round 3 oak, day and night (under R3-1's night if approved, otherwise the preview), at game scale and a close-up.
- **Effort:** about 1 day [Estimate]. **Risk:** low.

### R3-3 — Ground, paths and transitions (priority 3; art + renderer; slice)
- **What:**
  - 2–3 variants of the grass fill, picked by tile hash.
  - Variant frames for the path edge masks so turns stop stepping in identical blocks.
  - A verge decal band along path edges (tufts, pebbles, leaves); fix the cobble/path seam.
  - Ground cover strip: ferns, dry grass, small shrubs (one strip so they match).
  - Test one decorative worn-path overlay that curves across grass without touching the layout (C-09).
- **Generations:** about 3–5 [Estimate].
- **Watch:** the farmer, forage and items must stay readable on the busier ground; measure draw calls.
- **Effort:** 1–1.5 days [Estimate]. **Risk:** low in the slice. In production the renderer change sits in `_draw_dual_ground`.

### R3-4 — Garden beds and surroundings (priority 4; composition first; slice)
- **What:** space the beds with plank walkways between them; show both beds in frame; 2–3 plant variants per crop so rows stop reading as tokens; one row of corn and a bean trellis; flowers and a barrel at the fence; fence posts with moss.
- **Note:** production crops are four-stage SpriteCook strips (`crop_<kind>.png`); slice crops are ripe-only. Production would need stages for any new crop look.
- **Generations:** about 2–3 [Estimate]. **Effort:** about 1 day. **Risk:** low.

### R3-5 — Forest layering and depth (priority 5; composition first; slice)
- **What:** reuse existing firs and maples first, re-placed so edges step in and out by 1–3 tiles; add the R3-3 ground cover at bases; fallen mossy logs and crossing roots (1–2 generations); edge fog wisps reusing `weather_fog`; keep Round 2's shade and haze. Foreground canopy tips along the bottom edge, fading when the farmer walks behind them.
- **Effort:** about 1 day [Estimate]. **Risk:** foreground hiding the farmer; test with the farmer walking near the edge.

### R3-6 — Package and stop
- One master (split if the scale drops below 50%) with the columns concept / production / Round 2 / Round 3, day and night, game scale first, close-ups after; luma and frame-time tables; a GIF if the fog or swaying charms move.
- Re-score with the rubric. Post on the board. Stop for ChatGPT and owner review.

## Order, dependencies and budget

```
R3-0 ──► R3-1 (night; production approval) ──┐
   └──► R3-3 (ground) ──► R3-4 (garden)       ├──► R3-6 package, stop
        R3-2 (oak; needs generation budget) ──┤
        R3-5 (forest; uses R3-3 ground cover) ┘
```

- Sections stop for review one at a time if the owner prefers (CLAUDE.md); otherwise R3-2 to R3-5 can go out as one package after R3-1.
- **Generations:** about 10–16 in total [Estimate], against none left on the PixelLab trial.
- **Effort:** about 5–6 working days in all [Estimate].

## What Round 3 will not do

- Change the live farm layout, the camera, `SCALE`, the canvas or stretch.
- Replace production art, or edit the farmhouse (D-009).
- Change gameplay, `darkness`, lamp progression or saves.
- Change `DESIGN.md`'s locked art spec.

## Decisions the owner needs to make before or during Round 3

1. Authorize Round 3 as a slice (R3-0, R3-2 to R3-6).
2. Authorize R3-1 as a flagged production lighting change (off by default until accepted).
3. Approve the night target band (C-05) and landmark rims instead of more lamps (C-07).
4. Whether to test a lifted or seasonal day grade alongside R3-1 (C-04; touches the locked palette rule and D-008).
5. Whether selective outlines may be tested on ground cover and background trees (C-11).
6. Whether the layout migration is wanted at all, and if so with crop remapping (C-08) — decide before production art.
7. Whether an isolated scaling test should be scheduled (integer scaling at 1080p, or a 1920×1080 base at 3×) (C-02, C-03).
8. The generation pipeline and budget: PixelLab plan, SpriteCook (re-sign-in) with a new concept-derived style anchor, or both (C-12).
