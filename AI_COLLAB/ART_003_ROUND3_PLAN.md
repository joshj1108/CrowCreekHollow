# ART-003 Round 3 plan

Task: ART-003 Round 3, planned under ART-004. Author: Claude Code, 2026-11-02. Status: **proposed — not approved.** No step starts until the owner authorizes it.

**Progress (2026-11-02):**
- R3-0 and R3-1 are done (`art/style_tests/ART-003/ROUND3.md`). After ChatGPT's review the owner accepted the R3-1 night as the locked slice baseline.
- The owner then authorized R3-2 to R3-5 as prototype work. They are done and waiting for review (`art/style_tests/ART-003/ROUND3S.md`).
- P-1 is not approved and has not started.

**Revision 1 (2026-11-02), after ChatGPT's ART-004 review (`0121d1d`):** every Round 3 step is now non-production. The night work is a slice-only study; moving it into the game is a separate later step (P-1) that needs its own explicit approval. Permanent landmark lights are dropped from the plan. Night brightness numbers are diagnostics, not targets. A working-tree and build check is the first step.

Inputs: `AI_COLLAB/CONCEPT_FIDELITY_FEASIBILITY.md` (systems, compromises, night measurement method), `AI_COLLAB/ART_003_SCORECARD.md` (Round 2: Claude Code 54.5, ChatGPT 57.75), `ART_DIRECTION.md` (proposed), ChatGPT's Round 1 image review and ART-004 review (board), and the owner's Round 3 priorities in the ART-004 brief.

## Ground rules for the round

- **Baseline:** ART-003 Round 2 (`tools/art003_round2.gd`, commit `6debb09`) — oak A, the night preview, the 16 px grid and current camera. Round 2 keeps rendering exactly as it does now, as the rollback.
- **Non-production only.** Round 3 changes only test tools (`tools/art003_*.gd`) and `art/style_tests/ART-003/r3/`. No game script, scene, shader, production art, layout, `DESIGN.md` or `project.godot` changes. Anything that would need one stops and goes to the owner.
- **Working tree protected.** The uncommitted VIS-002 trek and lighting work stays as it is (see R3-0).
- **One variable at a time.** Lighting, art and composition are changed in separate steps and captured separately.
- **Lighting problems get lighting fixes; art problems get art.** No new art to fix a lighting gap; no gameplay change to fix an art gap.
- **No new permanent lights** (oak, well, pond or other) in any step, including the slice, unless the owner explicitly approves one after the compatibility check in feasibility system 11 (C-07).
- **Stop for review after each section** (`CLAUDE.md`), with a package per `VISUAL_REVIEW_PROTOCOL.md` and a score per `ART_REVIEW_RUBRIC.md`.

## The three highest-impact gaps, ranked

| Rank | Gap | Cause | Visual gain | Cost | Risk | Depends on |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Night reads well only in a preview; the game's own night is near black in the slice | Rendering (tint, grade) | Large: lighting *and* readability | Low, no art | Tone; trek, cave and sanity tints | R3-0 |
| 2 | Ground mostly flat grass; repetition; blocky paths | Art (variants, decals, ground cover) + slice renderer | Large by day, every screen | Moderate | Readability of items | R3-1 (judge under the studied night) |
| 3 | Oak crown clipped; no fungus or extra charms; henge-like ring | Art + composition | Medium–large on the hero screen | Moderate, 3–6 generations | Low | Generation budget |

The garden (owner priority 4) and forest depth (priority 5) are mostly composition with a few assets, so they follow once ground and lighting are settled.

## Steps (all non-production)

### R3-0 — Working-tree check, matched baseline and measurement (no art)
- **Working tree:** re-run the check in feasibility "Before any implementation": confirm the VIS-002 work is still present and snapshotted, confirm the build (headless load, `save_test.gd`, `menu_test.gd`), and record the commit the slice renders from. Last result (2026-11-02): no script errors, save 0 failures, menu 0 failures.
- **Baseline:** add to the slice tool a production column (the same slice area with the game's own art and lighting), a frame-time and draw-call readout (`Performance` monitors), and the region masks and luma readout from the night measurement method. Capture concept / production / Round 2 at 12:00 and 21:30 at 1280×720.
- **Also:** check the Compatibility renderer's per-item 2D light limit in Godot 4.7.
- **Effort:** about half a day [Estimate]. **Risk:** none.

### R3-1 — Night study in the slice (priority 1; rendering only)
- **What:** refine the Round 2 night preview inside the slice tool only: night tint, night grade, forest-edge shade and haze. Optionally test moonlight on the pond as a water shader or ambient effect, provided it doesn't create a lit safe zone.
- **Not in this step:** any change to `main.gd`, `NIGHT_TINT`, `_sky_tint()` or the grade shader; any landmark light.
- **Scenarios** (as far as the slice tool can stage them): 21:30 and 23:30; rain or fog at night; low sanity (must still read colder). Note which scenarios the slice can't stage (cave, trek, interiors) — those are checked only in P-1.
- **How it is judged:** side-by-side visual review against concept 03 and Round 2; the gameplay readability checks with the farmer walking, plus a short motion clip; region luma readings as supporting diagnostics. No number passes or fails it on its own.
- **Effort:** about half a day to a day [Estimate]. **Risk:** none to the game.

### R3-2 — Oak A refinement (priority 2; art + composition)
- **What:**
  - Regenerate oak A on a 192×192 canvas (12×12 tiles) using `r2/oak_a.png` as the init image, so the design holds and the crown is no longer clipped.
  - Red shelf fungus (2–3 clusters) and 3–4 charms and bundles as **separate** small overlay sprites in one strip, placed on the oak.
  - Replace the flat ring with 6–10 separate irregular mossy boulders (one strip of variants), y-sorted, with roots between them; no baked centre.
- **Generations:** about 3–6 [Estimate]. **Blocker:** the PixelLab trial is used up and SpriteCook needs signing in again; the tool is decision 8 below. Not started until both are settled.
- **Evidence:** concept oak crop / Round 2 oak / Round 3 oak, day and the R3-1 night, at game scale and a close-up.
- **Effort:** about 1 day [Estimate]. **Risk:** low.

### R3-3 — Ground, paths and transitions (priority 3; art + slice renderer)
- **What:** 2–3 grass fill variants picked by tile hash; variant frames for path edge masks; a verge decal band along path edges; fix the cobble/path seam; a ground-cover strip (ferns, dry grass, small shrubs); one decorative worn-path overlay across grass to test whether curves read without touching the layout (C-09). Also the first test of layered 16 px detail (feasibility system 3b) on one patch.
- **Generations:** about 3–5 [Estimate].
- **Watch:** the farmer, forage and items stay readable on the busier ground; draw calls.
- **Effort:** 1–1.5 days [Estimate]. **Risk:** none to the game.

### R3-4 — Garden beds and surroundings (priority 4; composition first)
- **What:** space the beds with plank walkways; both beds in frame; 2–3 plant variants per crop; one row of corn and a bean trellis; flowers and a barrel at the fence; mossy fence posts.
- **Note:** production crops are four-stage SpriteCook strips (`crop_<kind>.png`); slice crops are ripe-only. Production would need stages for any new crop look.
- **Generations:** about 2–3 [Estimate]. **Effort:** about 1 day. **Risk:** none to the game.

### R3-5 — Forest layering and depth (priority 5; composition first)
- **What:** reuse existing firs and maples first, re-placed so edges step in and out by 1–3 tiles; R3-3 ground cover at bases; fallen mossy logs and crossing roots (1–2 generations); edge fog wisps reusing `weather_fog`; Round 2's shade and haze. Foreground canopy tips along the bottom edge, fading when the farmer walks behind them.
- **Effort:** about 1 day [Estimate]. **Risk:** foreground hiding the farmer; test with the farmer walking near the edge.

### R3-6 — Package and stop
- One master (split if the scale drops below 50%) with the columns concept / production / Round 2 / Round 3, day and night, game scale first, close-ups after; region luma and frame-time tables labelled as diagnostics; motion clips for the night walk and anything that moves.
- Re-score with the rubric. Post on the board. Stop for ChatGPT and owner review.

## After Round 3, only with separate explicit approval

### P-1 — Night integration into the game (production)
- Only if the owner accepts the R3-1 study and then separately approves integration.
- Move the accepted values into `_sky_tint()` / `NIGHT_TINT` and the night grade behind a reversible flag, off by default until accepted; leave `darkness`, sanity, lamp timing, events and the lamp ladder unchanged.
- Check farm, cave, trek, interiors, rain and fog nights, and low sanity, BEFORE (flag off) and AFTER (flag on).
- Prerequisite: the R3-0 working-tree check, re-run; it must not be mixed into the uncommitted VIS-002 work without its owner's agreement.
- Tests: `save_test.gd`, `menu_test.gd` (rubric gate 3).
- **Not authorized by approving Round 3.**

Other production work (art replacement, layout migration, scale changes, grade or outline rule changes) stays out of scope until the owner opens a task for it.

## Order, dependencies and budget

```
R3-0 ──► R3-1 (night study, slice) ─────────────┐
   └──► R3-3 (ground) ──► R3-4 (garden)         ├──► R3-6 package, stop ──► (P-1 only if separately approved)
        R3-2 (oak; needs generation budget) ────┤
        R3-5 (forest; uses R3-3 ground cover) ──┘
```

- R3-0 and R3-1 need no generations and can go out for review on their own first.
- **Generations:** about 10–16 in total for R3-2 to R3-5 [Estimate], against none left on the PixelLab trial.
- **Effort:** about 5–6 working days in all [Estimate].

## What Round 3 will not do

- Change any game script, scene, shader, `project.godot` or production art.
- Change the live farm layout, the camera, `SCALE`, the canvas or stretch, or run a scaling experiment.
- Add permanent lights of any kind.
- Change gameplay, `darkness`, lamp progression or saves.
- Change `DESIGN.md`'s locked art spec.
- Touch the uncommitted VIS-002 work.

## Decisions the owner needs to make

1. Authorize R3-0 and R3-1 (no generations needed).
2. Authorize R3-2 to R3-6, with a generation tool and budget (decision 8).
3. After R3-1's review: whether to approve P-1 (night integration) as its own task.
4. Whether to test a lifted or seasonal day grade in the slice (C-04; touches the locked palette rule and D-008 if ever adopted).
5. Whether selective outlines may be tested on ground cover and background trees in the slice (C-11).
6. Whether the layout migration is wanted at all, and if so with crop remapping (C-08) — best decided before production art.
7. Whether a scaling test plan should be written (C-02, C-03); no test runs without an approved plan.
8. The generation pipeline and budget: PixelLab plan, SpriteCook (re-sign-in) with a new concept-derived style anchor, or both (C-12).
