# CCH-EVENING-002 — A House Against the Hollow: evening refinement and survival balance

**Status:** built and measured 2026-11-13; stopped for owner and ChatGPT review. Prepared by Claude Code. Nothing past
the brief was built; no broader balance change was made. Every new prototype number is a constant at the top of
`scripts/evening_system.gd`.
**Built on:** `954787f` (CCH-EVENING-001). The owner's uncommitted sunset experiment (`main.gd` LONG_DUSK/SUNSET
hunks, `shaders/grade.gdshader`) is untouched and in none of these commits.
**Evidence:** `art/style_tests/CCH-EVENING-002/` — `review/` (master PNGs, three sheets, four charts, two GIFs with
frame grids), `out/tables.md` (every simulated table), `sims/` (28 runs, JSON and printed tables), `play_*/` (played
logs and screenshots), `logs/` (tests).

Four kinds of evidence are kept apart: **Played** = the real windowed game driven by injected keyboard, mouse and Xbox
input (`tools/evening_play.gd`); **Controlled** = tests or sims that set a state the game would not reach that way
(labelled); **Simulated** = `tools/balance_sim.gd` (the game's own functions, no walking); **Interpretation** = my
reading of those. None of it is a human, and none of it says whether an evening is enjoyable.

## A. Implementation summary

| Change | What and why | Where |
| --- | --- | --- |
| **Farmhouse shelter** | A visitor **left unanswered while you are inside the farmhouse** takes 100 / 75 / 60 / 45% at Decrepit / Boarded / Patched / Restored (`SHELTER_STAGE`). Uses the existing `house_stage`; nothing new is saved. Covers the field figure, knock, quiet night, crows, pond, watcher and the Hollow's sanity loss (`SHELTER_FOR`). | `EveningSystem._house_mult` |
| **One protection calculation** | House stage × barred shutters (knock) × second storey × tended hearth, **floored at 40%** (`SHELTER_FLOOR`), replacing the three separate multipliers that sat in `NightSystem._loss_mult`. Everything else multiplies outside it, unchanged. | `EveningSystem._shelter`, `NightSystem._loss_mult(id, unattended)`, `_resolve` |
| **Morning line** | When the house eased a night: "The boarded walls kept the worst of the night outside." / "The patched walls held most of the night at bay." / "The house held. Whatever came, most of it stayed outside." No numbers. | `EveningSystem._morning_note` |
| **A Quiet Hour** | Desk › Pastimes, 19:00-22:00, inside: one hour, **+4 sanity, +15 comfort**, no fire, firewood, furniture or supplies. "Writing in the diary by candlelight" before Patched, "reading at the desk" after. | `EveningSystem._quiet`, `PanelRows._desk_rows`, `DeskSystem._desk_action` |
| **Shared evening rest** | The fire and the Quiet Hour share one rest an evening (`cozy_day`). The desk's existing daily game (+3, first a day) is untouched, so an evening's ceiling stays CCH-EVENING-001's +7; no new uncapped path. A cold hearth's row points to the Quiet Hour. | `_cozy_blocker`, `_quiet_blocker`, `_hearth_rows` |
| **Rest feedback** | After either rest the room dims to a warm half-dark for ~2 s with a line ("The logs settle. An hour goes by." / "The candle burns down a little..."), the fire and lamps still moving under it. Input and clock are held by the existing `transitioning` flag; camera and collisions untouched. Not run headless. | `MainGame._rest_scene` |
| **Clue readability** | Crows: a faint grey sheen on their upper edge (their own silhouette), and when read they lift off the fence one after another and fly off low to the west, fading (the farm's existing `crow_fly` frames, ~1.7 s, timed by frame time). Tracks: deeper prints, pale turned-earth rims, clods, a churned patch at the gate; the rims are lifted as the night tint deepens so they read after dark and in rain without glowing. Frost: no pulse; thicker rime at the pane's edges and branching lines creeping off the frame across the boards. | `EveningSystem._draw_*` |
| **Interaction cue** | Facing an unread sign shows one line on the existing message line, once an evening ("The crows on the fence haven't moved. Space to look closer."). No new HUD. | `EveningSystem._update` |
| **Onboarding** | The Sleeping tip now says there is no hurry to bed. A new diary tip, **"Evenings at home"** (from the second evening, after the diary is found): the fire and the Quiet Hour, the signs, tending the hearth, repairs making the house "a better refuge... though never a perfect one", and "Going to bed early is always allowed." Repair message and stage features say the house holds better against the night. No numbers. | `MainGame.TIPS`, `_tip_ready`, `HOUSE_FEATURES`, `_repair_house` |

**Files:** `scripts/evening_system.gd`, `night_system.gd`, `main.gd` (5 small hunks, none in the sunset lines),
`panel_rows.gd`, `desk_system.gd`, `DESIGN.md` (Evenings section). **Tools/tests:** `tools/evening_test.gd` (+72 cases),
`balance_sim.gd` (style=, shelter=, quiet=, stage=, json=), `evening_play.gd` (Quiet Hour fallback, balanced style),
`capture.gd` (rest=, flyms=, rest legs), new `evening2_sims.sh`, `evening2_shots.sh`, `evening2_report.py`.

No new art, sound, asset, panel, currency or location; no PixelLab or SpriteCook generation.

## B. Protection calculations

**Existing modifiers found on unattended night loss (before this pass):** dread event ×2, vicar's ward ×0.5, crow
charm ×0.5, crow bell ×0.75, barred shutters ×0.5 (knock), second storey ×0.9, tended hearth ×0.75 (knock, watcher,
Hollow), trek (walked today ×0.5, wood close ×1.25, Hollow asleep ×0.75), season (winter ×2, autumn ×1.3),
`NIGHT_LOSS_MULT` 2.2, then `NIGHT_CAP` 45, then the first-week grace ×0.5. The restored house's other bonuses
(`HOUSE_RELIEF`, the porch light, `SHELTER_SANITY_RATE`) change darkness and indoor regen, not night losses, so
nothing is applied twice.

**The order now (`NightSystem._resolve` → `_loss_mult(id, unattended)`):**

1. The visitor's base cost (`ignore_sanity`, or `face_sanity` if faced).
2. **Shelter group** = house stage (only unattended, only inside, only `SHELTER_FOR`) × shutters (knock) × second
   storey × tended hearth (house visitors) → **max(group, 0.40)**.
3. × the unrelated multipliers above (season, bell, charm, ward, dread, trek) × `NIGHT_LOSS_MULT`, as before.
4. `min(…, NIGHT_CAP)`.
5. First-week grace (×0.5, once, first unanswered knock in days 1-7), **after** the floor: the one onboarding
   exception that can go below it.
6. `SanitySystem._change_sanity`.

Not touched by the house: faced visitors, confrontation strikes, the footsteps (outdoors), anything while you are
outside, the scripted first night and sighting, the story act's Hollow, the Hollow's lost sanity **limit**, raids,
hunger/thirst/comfort, treks, the cave.

**Every combination, an unanswered knock in autumn (base 34.3), tested in `tools/evening_test.gd`:**

| Protection | Share | Sanity lost |
| --- | --- | --- |
| None (Decrepit) | 100% | 34.3 |
| Boarded / Patched / Restored alone | 75 / 60 / 45% | 25.7 / 20.6 / 15.4 |
| Hearth tended alone | 75% | 25.7 |
| Shutters barred alone | 50% | 17.2 |
| Boarded + hearth | 56% | 19.3 |
| Patched + hearth | 45% | 15.4 |
| Restored + hearth, Restored + shutters, all three, Boarded + shutters, hearth + shutters | **40% (floor)** | 13.7 |
| First-week grace + Boarded | 37.5% | 12.9 |
| First-week grace + everything | 20% (floor, then half; once) | 6.9 |
| Same knock, standing outside, Restored | 100% | 34.3 |

The only behaviour change to an existing combination: shutters + tended hearth was 37.5%, now 40%. Strikes during a
confrontation still get the shutters and hearth (as before) and are floored the same way, but never the house stage.
**No combination of shelter goes below 40%**; the restored house is safer, never safe.

## C. Comparative balance results (SIMULATED)

`tools/balance_sim.gd`, 400 days, treks=3, seed 1, one run per style per configuration (28 runs; `tools/evening2_sims.sh`).
**A** = CCH-EVENING-001 emulated (`shelter=1,1,1,1 quiet=0`); it matches the real `954787f` build's sim within 2
sanity on 4 of 30 days, identical on the rest. **B** = proposed. **C−** weaker `1/.85/.70/.55`, **C+** stronger
`1/.65/.50/.35` (run-time probes only; the game's constants are B). Natural progression throughout: the sim boards
the house on day 1 and patches it on day 13, restores it on day 245 (summer); the played bots boarded on day 2 and
patched on day 13, so the timing is realistic. Values are morning sanity. Full tables: `out/tables.md`.

**Average morning sanity (lowest point in brackets; mornings under 40):**

| Style | Days 1-14 A → B | Days 1-30 A → B | First winter A → B | Restored (d245+) A → B | Year A → C− / B / C+ |
| --- | --- | --- | --- | --- | --- |
| Minimal | 58 (11; 2) → **74 (44; 0)** | 50 (11; 10) → **79 (44; 0)** | 42 (0; 39, 16 <20) → **82 (31; 1)** | 90 → 96 | 75 → 89 / **91** / 93 |
| Cozy | 70 (20; 1) → **90 (54; 0)** | 74 (20; 1) → **93 (54; 0)** | 72 (12; 3) → **88 (36; 0)** | 94 → 96 | 87 → 93 / **95** / 96 |
| Cautious | 69 (16; 1) → **90 (53; 0)** | 79 (16; 1) → **94 (53; 0)** | 81 (19; 1) → **90 (42; 0)** | 97 → 99 | 92 → 95 / **96** / 97 |
| Curious | 83 (45; 0) → **87 (52; 0)** | 90 → **92** | 94 → **95** | 99 → 99.5 | 97 → 97 / **97** / 97 |
| Balanced | 79 (36; 0) → **88 (47; 0)** | 85 → **92** | 89 → **93** | 99 → 99.7 | 95 → 97 / **97** / 98 |

Night losses over the year: minimal 7,834 → 4,989 (−36%), cozy 8,217 → 5,699 (−31%), curious 4,405 → 4,298 (−2%).
Over the restored period alone: minimal −40%, cozy −24% (cozy already tends the hearth, so the floor bites).

**Controlled stage tests** (house **held** at one stage from day 1, 30 days, B; not natural progression):

| Held stage | Minimal: avg / lowest / mornings <40 / <20 | Cozy: avg / lowest |
| --- | --- | --- |
| 0 Decrepit | 48 / 8 / 8 / 2 | 72 / 30 |
| 1 Boarded | 65 / 35 / 1 / 0 | 90 / 54 |
| 2 Patched | 88 / 68 / 0 / 0 | 96 / 63 |
| 3 Restored | 92 / 76 / 0 / 0 | 97 / 66 |

Reading: **the house now carries most of a sleeper's survival.** A player who never repairs still collapses (stage 0:
8 mornings under 40, 2 under 20 in a month), and each stage is a large, visible step.

## D. Player-style results

**Played (14 evenings, injected input, B):** {PLAYED}

**Simulated, against the targets in the brief (Interpretation):**

- **Minimal participant** — target: serious consequences for ignoring danger *and failing to maintain the house*.
  Met **only when the house is neglected** (controlled stage 0). A minimal player who still repairs at the normal pace
  (the sim's minimal does every chore) is now far safer: from 50 mornings under 40 a year to 1. See F.1.
- **Cozy farmer** — target: viable without facing visitors; no routine collapse in the first fortnight. **Met**: days
  1-14 lowest 54 (was 20), no morning under 40. Its quiet hours fill the 10 of 14 early evenings with no fire.
- **Cautious survivor** — target: more resilient than a passive player. **Met** in the sim (lowest 53 vs minimal 44
  in the first fortnight; year 96 vs 91).
- **Curious explorer** — target: strongest opportunities, but not the only way. Its sanity is nearly unchanged (it
  rarely leaves a visitor alone) and it keeps the feathers, the shadow pushed back and the mystery beats. **But in the
  sim the cozy farmer now has slightly higher average sanity in days 1-30 (93 vs 92)**; exploring is no longer the best
  sanity strategy early, only an equal one. See F.2.
- **Restored farmhouse** — target: a noticeable improvement, never immune. **Met**: night losses −24 to −40% over the
  restored period; the floor holds every combination at 40%.

## E. Activity availability and idle time

| | CCH-LOOP-001 | CCH-EVENING-001 | CCH-EVENING-002 |
| --- | --- | --- | --- |
| Evenings with no fresh choice at 19:00 (sim) | 59-79% | — | — |
| Evenings with a rest possible, days 1-14 (sim, cozy/cautious/balanced) | 0 | 4 of 14 | **14 of 14** |
| Evenings with a usable hearth activity, days 1-14 (sim) | — | 4 of 14 | 4 of 14 (unchanged: firewood) |
| Cold evenings (no fire, no firewood), days 1-14 (sim) | — | 9-10 | 9-10 (the Quiet Hour fills them) |
| Choices at 19:00, average, days 1-14 (sim) | — | 1.4-1.6 | 2.4-2.6 |
| Whole year: evenings with a rest possible (sim, cozy) | — | 276 of 400 | 349 of 400 |
| Played: bed time | 19:15 | 20:3-21:2 (cozy/cautious), 22-23 (curious) | {PLAYED_BED} |
| Played: evening game hours busy / waiting (14 evenings) | — | cozy 7.9 / 4.3; curious 16.3 / 30.6 | {PLAYED_IDLE} |
| Sign evenings (fixed by day) | — | 4 in 14; 147 in 400 | unchanged |

(The Quiet Hour is open only 19:00-22:00. "Rest possible" for the minimal style, which never rests, is 333 of 400
evenings in B; the 67 gaps are most likely trek days when the sim gets home after 22:00. Not verified day by day.)

**Is the Quiet Hour a real choice or an automatic reward? Interpretation: on a cold evening it is automatic.** It costs
only an hour of an evening that is otherwise waiting, gives the same sanity as the fire, and every resting style in
the sim and in play took it every evening it could not sit by the fire. On a warm evening the fire is strictly
better (more comfort), so that is not a choice either. The real evening choices remain: whether to go out for a sign,
whether to spend firewood on tending, and whether to stay up for the visitor. Reported as a design concern (F.3), not
fixed.

**Firewood:** unchanged. Tending was possible on 3-4 of the first 14 evenings (sim) and 2 were used per style; over the
year cozy tended 247 times once the woodshed stood (about day 23-27). One firewood buys 25% off one house visitor
(a knock: about 6-9 sanity in autumn; with a Boarded house, 25.7 → 19.3), on nights it turns out to matter.

## F. Remaining concerns

1. **The proposed multipliers make a repairing sleeper nearly safe in the simulation.** The sim's minimal player
   (sleeps before every visitor, never rests, but does every chore and repairs on schedule) goes from 50 mornings
   under 40 a year (17 under 20) to 1 (0). The played runs are harsher than the sim (CCH-EVENING-001's played sleepers
   were at 9-15 by day 15 where the sim had 42-53), so the real effect is smaller than this, but the direction is
   clear: with B, neglecting the nights costs little once the house is Patched.
2. **Exploration's sanity edge is gone early.** Cozy ≈ curious in days 1-30 under B (93 vs 92). Curious keeps its other
   rewards (feathers for charms and the bell, the shadow pushed back so the Hollow doesn't come, the story beats), so
   it is still the richer way to play, but no longer the safer one.
3. **The Quiet Hour is effectively automatic** on fireless evenings (E). Its fixed +4 is a small, capped daily
   top-up, not a strategy.
4. **Firewood before the woodshed** still limits the hearth's evening on ~10 of the first 14 evenings; the Quiet Hour
   covers the rest but the tended hearth stays mostly out of reach early.
5. **Winter** is where shelter matters most (A minimal: 39 mornings under 40 in the first winter; B: 1). Winter's ×2
   season multiplier was designed against the old, unsheltered losses.
6. The sim's styles are scripts, not people: they rest and tend perfectly and do every chore.

## G. Recommendations (nothing below is implemented)

- **Multipliers: keep the shape, reduce slightly, mainly at the top.** The evidence favours something between C− and B:
  e.g. **Boarded 0.80, Patched 0.65, Restored 0.55**. Boarded/Patched at C− still met the cozy target (days 1-14
  lowest 50, no morning under 40) while leaving the minimal player some bad mornings (2 under 40 in the first
  fortnight, 5 a year); Restored at 0.55 would keep the late game from flattening. If the owner prefers to judge
  from the played fortnight alone, B is defensible there ({PLAYED_MIN}). I would not increase them.
- **Visitors:** none need adjusting for this; if anything, the winter season multiplier is the lever for keeping
  winter frightening under shelter (consider ×1.6-1.8 instead of ×2 *only if* the multipliers are reduced; otherwise
  leave it).
- **Domestic rewards:** keep the fire at +4/+30 and the Quiet Hour at +4/+15 for now. To make the Quiet Hour a choice
  rather than a top-up, a later pass could tie it to something (a page of the diary, a letter answered, Elias's
  books) instead of raising or lowering the number.
- **Firewood:** a small early adjustment is still worth making later (CCH-EVENING-001 §11): e.g. a bundle of kindling
  from the brush already gathered, or splitting wood at the house before the woodshed. Not built.
- **Explorer advantage:** if the owner wants exploration to stay the safest path early, the cheapest lever is the
  multipliers above, not new content.

## H. Tests

| Test | Result |
| --- | --- |
| `tools/evening_test.gd` (headless; +72 new cases) | **166 PASS, 0 FAIL**: every stage multiplier; each sheltered visitor; outside, faced, footsteps, the act's Hollow, strikes not sheltered; the Hollow's lost limit untouched; the cap; all 11 stacking combinations; the floor never broken (exhaustive over stages × hearth × shutters); grace + house and grace + everything; the morning lines (none at stage 0, no numbers); protection follows the saved stage after a reload; no new saved shelter state; Quiet Hour (not before 19:00 or after 22:00, inside only, no firewood, +1 h, +4 sanity, +15 comfort, once, panel closes, says so); shared rest both ways; the Hearth section shows it; the desk game still works (+3); a cold hearth points to it; a reload can't give the rest again; next day fresh; onboarding (no-hurry bed tip, the evening tip's content, no numbers, no "must", from day 2 at 19:00 with the diary); sign cue once; crows fly then go; the crow edge texture |
| Regression (`tools/audit_run_tests.sh`, 16 suites, throwaway profiles) | all **0 FAIL**: save 66, menu 799, interior 136, mail 42, debug menu 40, diary 63, wheel 87, layout 67, farmer 79, creature 74, aoh2_e2 62, aoh2_e3 208, aoh2_e5 209, aoh_cave 6, aoh_trek 7 (one timing check, 53 ms vs 50, failed while five sims ran alongside; 39 ms alone), diary_fit ok |
| `tools/playable002_test.gd` | 79 PASS |
| Played (input-driven) | {PLAYED_TESTS} |
| Owner saves | never opened: every test, sim, capture and play ran with `APPDATA` pointed at a scratch folder (slots 8/9) |

## I. Save compatibility

No new saved key. The shelter reads `house_stage` (already saved); the Quiet Hour reuses `evening.cozy_day` (already
saved) for the shared limit; `cozy_kind`, `sheltered`, `hinted_day` and the crow flight are per-session and reset on
load. Old saves (with or without the `evening` key) load as before (`save_test` 66 PASS; CCH-EVENING-001's old-save
cases still pass). Protection can't be duplicated by reloading (it is computed at resolution from the stage); the rest
can't be claimed twice (tested).

## J. Visual review

`review/CCH-EVENING-002_master.png` (and `_master_2.png`): Sheet 1 clues (BEFORE `954787f` vs AFTER, same options;
zoomed rows at full size), Sheet 2 farmhouse evenings (Hearth, cold hearth → Quiet Hour, the desk row, the rest scene,
Decrepit vs Restored for context), Sheet 3 the same knock's morning at each stage, plus the four charts. GIFs:
`crows_fly.gif`, `rest_fire.gif`. Note: the AFTER clue shots ran later on the clock than BEFORE on a loaded machine
(about 20:18 vs 20:06) and are slightly darker for it; nothing was adjusted for the screenshots.
