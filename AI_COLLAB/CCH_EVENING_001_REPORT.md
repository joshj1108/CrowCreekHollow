# CCH-EVENING-001 — The Hours Before Dark: evening prototype report

**Status:** prototype built 2026-11-13, stopped for owner and ChatGPT review. Prepared by Claude Code. Nothing is
expanded past the brief. Every prototype number is a constant at the top of `scripts/evening_system.gd`.
**Built on:** `10ab9f1`. The owner's uncommitted sunset experiment (`main.gd` LONG_DUSK/SUNSET hunks,
`shaders/grade.gdshader`) is untouched and in none of these commits.
**Commit:** see the board entry (the SHA is posted there after pushing).
**Evidence:** `art/style_tests/CCH-EVENING-001/` — `review/` (two masters, three sheets, two GIFs and frame grids,
two charts), `play_*/` (play logs and screenshots), `out/tables.md` (every per-evening table), `logs/` (tests),
`work/` (sims, regression summary).

Two kinds of evidence are kept apart throughout. **Played** = the real windowed game from the title menu, every action
an injected key, mouse or Xbox button (`tools/evening_play.gd`, built on the CCH-PLAYABLE-001 bot). **Simulated** =
`tools/balance_sim.gd` (the game's own functions, no walking) and the headless tests. Neither is a human, and nothing
here says whether an evening is enjoyable.

## 1. Implementation summary

| Piece | What it does | Where |
| --- | --- | --- |
| **A. Evening signs** | On about 2.5 evenings a week, from 19:00 until the visitor: **crows** lined up on the field's north fence, **tracks** on the path into the field's west gate that come in and don't leave, or **frost** creeping on the farmhouse's west front window. A short line says so when the evening opens, if you are outside. Space at it reads it once; the crows then go. | `EveningSystem` signs, `_draw_ground`/`_draw_top` |
| **B. Tend the hearth** (preparation) | From 19:00 Space at the hearth opens a **Hearth** section: Feed the fire (ordinary fuelling), Tend the hearth for the night, An evening by the fire. Tending needs a fire of 3+ hours, costs 1 firewood (banked into the fire, so it also burns) and half an hour, once an evening. That night a visitor **at the house** (knock, watcher, Hollow) takes 75%. | `_tend`, `_night_mult`, `PanelRows._hearth_rows` |
| **C. An evening by the fire** (cozy) | In the same section: an hour by a lit fire, +4 sanity, +30 comfort, once an evening, inside only ("reading" from Patched, "mending" before). "For a little while, the house feels like a home." | `_sit` |
| **First-week grace** | The first knock left unanswered in days 1-7 takes half, once. Saved (`grace_used`). The morning line gives the cost and adds "It will not always be so gentle." | `_grace`, `NightSystem._resolve` |
| **First trek** | `EDGE_WORD_CALMS` stays **on**; tests show the edge route's word calms a frozen walker and the mill route still needs a ration. | `trek_system.gd` unchanged |

**Why a Hearth section and not one press:** the game has one hand action per tile, and every object with more than one
action already opens a section (Well, Woodstore, Coop, Barn, Cellar, Desk). Outside 19:00-22:00 the hearth is exactly
as before (Space feeds). The section also pauses the clock, which matters because the evening is one real minute (§4).

**How signs relate to the night (useful, imperfect):** the schedule is fixed by the day number (no saved state, so a
reload can't reroll it): a 0.56 roll per day, never two evenings running, none on day 1 (mean 2.48 a week over 1,400
days; 85% of 7-day windows hold 2 or 3). Which sign shows follows the visitor the night would pick at that moment
(`NightSystem._preview_id`): tracks ← field figure, footsteps; frost ← knock, watcher, Hollow; crows ← crows, pond
lights, sighting. It matches on 70% of sign evenings (`SIGN_TRUE`) and points elsewhere on the rest; a quiet night only
ever gets a false sign. The text names a kind of place ("for the crops or the water", "still somewhere on the farm",
"may come to the house... It will want a good fire"), never a visitor. Over nights 2-400: 147 sign nights (67% match),
229 dangerous nights with no sign, 11 quiet nights with a sign.

## 2. Systems reused

NightSystem (visitor pick, `_loss_mult`, `_resolve`, the crow sprite `crow_perch`), the morning report, the message
line and its notices, the hearth/firewood (`fire_hours`, `FIREWOOD_HOURS`, `_feed_fire`), the desk pastime's
time-passing pattern, comfort (`warmth`) and `SanitySystem._change_sanity`, the ledger panel (`_toggle_tab`, rows,
needs, the detail pane, menu focus and controller glyphs), the window light positions, `ProgressionSystem._bump`
counters, the save dictionary. No new art, sprite, sound, enemy, currency, bar or location; no PixelLab or SpriteCook
generation. The tracks and frost are a few code-drawn pixel rects at the 3x art grid.

## 3. Files changed

- **New:** `scripts/evening_system.gd`.
- **Game:** `scripts/main.gd` (9 small hunks: the system's construction, update, the sign before other farm presses,
  the hearth's evening branch, the Hearth tab and its three actions, the morning line), `scripts/night_system.gd`
  (`_preview_id`, `_pick(preview)`, `_loss_mult(id)`, the grace in `_resolve`, `_draw_crow_on`),
  `scripts/panel_rows.gd` (`_hearth_rows`), `scripts/save_system.gd` (the `evening` key), `scripts/action_bar.gd`
  (the tab's subtitle), `DESIGN.md` (new "Evenings" section; shutters note).
- **Tools/tests:** new `tools/evening_test.gd`, `tools/evening_play.gd` + `.sh`, `tools/evening_report.py`,
  `tools/evening_shots.sh`; `tools/capture.gd` (sign=, signsay, hearth=, morning=; guarded so it also runs on the
  previous commit), `tools/menu_test.gd` (Hearth added to the small panels), `tools/balance_sim.gd` (grace=0 control),
  `tools/playable002_test.gd` (one check now reads the last three log lines; see §9).

**Found and fixed in passing (flagged, one line, easy to revert):** `NightSystem._resolve` cleared the visitor before
`_loss_mult()` read its id, so the **barred shutters never eased an unanswered knock** (only its strikes), although
their message says "the knocking will take half". The id is now passed in. This was needed for the tended hearth to
work at all, and it changes the shutters' effect to what the game already promised. A knock with both: 37.5%.

## 4. The evening window (measured, not changed)

19:00-22:00 is three game hours = 60 real seconds on the farm. The clock was **not** changed. What makes it workable:
the Hearth section pauses the clock while you choose; reading a sign is one press; the evening by the fire jumps the
clock an hour (as a desk pastime does). In play, a sign was reached and read 10-16 game minutes after 19:00 (3-5 real seconds of walking). The real
squeeze is the other way: a player who wants to face the 22:00 visitor and has nothing left to do waits. The curious
bot waited 1.4-2.9 game hours (28-58 s) every evening, and 2.6-2.7 hours on the seven evenings with no firewood
(§6). Recommendation: no clock change now; see §11.

## 5. Gameplay findings (played)

Four styles × 14 days, plus an 8-day control. Cozy ran on the Xbox controller; the rest on keyboard and mouse.
Every run met the same signs (days 2 chill, 7 chill, 9 crows, 11 chill: 4 in 14 days) and the same visitors (fixed by
the day). Full tables: `out/tables.md`.

| Style (14 evenings) | Signs read | Hearth tended | By the fire | Faced | Slept through | Evening hours active / waiting | Sanity, morning of day 8 | day 15 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Cozy farmer (pad) | 0 (stays in) | 0 | 7 | 0 | 14 | 7.9 / 4.3 | 52 | 15 |
| Cautious survivor | 4 of 4 | 2 | 1 | 1 | 13 | 5.0 / 7.4 | 43 | 11 |
| Curious explorer | 4 of 4 | 0 | 7 | 10 | 0 | 16.3 / 30.6 | 93 | 71 |
| Minimal participant | 0 | 0 | 0 | 0 | 14 | 0 / 0.2 | 43 | 9 |
| Minimal, no grace (control, 8 days) | 0 | 0 | 0 | 0 | 8 | 0 / 0.1 | 37 | — |

What this shows, plainly:

1. **The evening has choices now.** Before (CCH-LOOP-001), the played bot was in bed by 19:15 every night and 59-79%
   of simulated evenings had no fresh choice. Now 4 of 14 evenings had a sign; the hearth offered two things on every
   evening with a fire; the styles spent their evenings visibly differently (chart_activity).
2. **Firewood decides the hearth.** Before the woodshed (about day 23-27 in the sim) firewood is the 4 you start with
   plus the odd find. Every hearth-based style ran out by day 3-5 and again by day 9; on 7 of 14 evenings each style
   had no fire at all ("The hearth is cold. Light the fire first."). The cozy farmer sat by the fire 7 times; it could
   never tend the hearth (on every third evening it had at most 1 firewood and a low fire). **This is the biggest limit
   on the prototype in the first fortnight.** No change was made to the firewood economy (out of scope); options in §11.
3. **Preparation is a real gamble.** The cautious bot read the frost on days 2 and 7 and tended the hearth both times,
   spending its last firewood each time; that night was quiet (day 2) and the pond lights (day 7), so it did nothing
   ("The banked fire burned low and steady"). On day 11 the frost was right (the watcher) and it had no firewood.
   This is the intended uncertainty, but with this little firewood it reads more like a trap than a choice.
4. **Facing the nights is still what keeps sanity up.** Curious faced 10 visitors and ended at 71; every style that
   slept through ended at 9-15. Staying in is not safe (intended), but from the second week, when the tier-1 visitors
   arrive (watcher: -34 on day 11), sleeping through every night takes sanity to the bottom in all three sleeping
   styles. The evening by the fire is worth about +4 a night (cozy 15 vs minimal 9 on day 15); it does not change that
   trend, and was not meant to.
5. **No evening activity is mandatory, and none can be farmed:** each is once an evening; a second press says so.
6. **Contextual interaction worked by real input on both devices:** Space opened the Hearth section; A on a row acted
   on the controller; with the mouse a click selects the row and its detail-pane button acts (as in every ledger
   section). Signs were reached and read with Space. No script error in any run.

Bot problems (not game bugs): walking stuck on the trail to the wood once per run, and "no tree could be reached"
on 2-3 days; the same as in CCH-PLAYABLE-001.

## 6. First-week Sanity comparison

**Played (minimal style, sleeping through as the tutorial teaches), morning sanity:**

| Morning of day | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Previous build (CCH-PLAYABLE-002 replay, keyboard) | 91 | 93 | 65 | 75 | 61 | 38 | 34 | 34 |
| This build, grace off (control) | 91 | 93 | 67 | 77 | 65 | 41 | 37 | 37 |
| This build, grace on | 91 | 93 | **84** | 95 | 73 | 49 | 43 | 41 |

The control reproduces the previous build within 3 points, so the comparison holds. The grace changes one night: the
knock on night 3 took 17 instead of 34 ("Sanity -17. It will not always be so gentle."). The next knock (night 6) took
the full 34 in both. By day 8 the grace leaves the player 6 points higher (43 vs 37): **less punishing, not trivial**:
the second week still drains a sleeper.

**Simulated (balance sim, 14 days, treks=3):** early-bed day 8: 55 with the grace vs 46 without; ignore: 50 vs 45;
engaged (faces its visitors): unchanged, it never leaves a knock alone. (`work/sim_*`.)

## 7. Rewards and costs

| Choice | Benefit | Cost | Limit |
| --- | --- | --- | --- |
| Read a sign | which kind of place may be visited tonight (right 70%) | being out after dusk (the dark's drain), a minute | once per sign |
| Tend the hearth | a house visitor takes 75% tonight (knock 34 → 26 in autumn; with shutters 13) | 1 firewood, half an hour | once an evening; ends with the night |
| An evening by the fire | +4 sanity, +30 comfort | an hour, a lit fire | once an evening |
| First-week grace | the first unanswered knock takes half | — | once, days 1-7 |
| Sleep early / face the visitor | unchanged | unchanged | — |

For scale: the day restores about 25 sanity; a desk pastime +3 a day; sleep +8; a summer night takes 9-44.

## 8. Save/load

The schedule needs no state. Saved under `evening`: `sign_read_day`, `prep_day`, `cozy_day`, `grace_used`. The game
saves only at dawn, after the night resolves, so the evening flags are for the record and `grace_used` is the one that
matters. Older saves: grace counted spent past day 7, or if a knock has already been left alone. Tests (in
`tools/evening_test.gd`): the grace survives a reload spent and unspent; tonight's sign is the same after a reload; a
new day's evening is fresh; old saves in each case. `tools/save_test.gd`: 66 PASS.

## 9. Tests and regression

| Test | Result |
| --- | --- |
| `tools/evening_test.gd` (new, headless) | **94 PASS, 0 FAIL**: scheduling (rate, windows, no two running, no fixed weekday, deterministic after reload, dangerous nights without signs, sign nights without danger), each sign (place, standable spot, read once, no visitor named, not before 19:00, gone after the visitor, not from inside), weather/season/house-stage lines, hearth (day feeds as before, evening opens the section, feeding stays ordinary, fire and firewood needed, cost, once, the easing on knock and watcher, none on the field figure, no stacking, morning lines, gone next day), the shutters fix, cozy (needs a fire, inside, evening; reward; once), grace (half, once, other visitors and faced knocks untouched, day 8+ untouched, slept-through path, morning line), saves, the first trek rule on both routes |
| Regression (`tools/audit_run_tests.sh`, 16 suites) | all 0 FAIL: save 66, menu **799** (was 785; +14 for the Hearth tab), interior 136, mail 42, debug menu 40, diary 63, wheel 87, layout 67, farmer 79, creature 74, aoh2_e2 62, aoh2_e3 208, aoh2_e5 209, aoh_cave 6, aoh_trek 7, diary_fit ok |
| `tools/playable002_test.gd` | 79 PASS after one test fix: "PLAY-09 the frozen line offers a word" read only the newest log line, and a "Tin Light" achievement notice now lands after the freeze line. It failed the same way on `10ab9f1` + only the owner's sunset hunks, and on `10ab9f1` + only these changes, so it was timing, not either change. The check now reads the last three lines |
| Story, night visitors, weather, HUD, diary, combat | covered by the suites above and the played runs (every visitor kind of the first fortnight met; the edge chapter done in every run; chapters bed, light, edge, first crop and second plot done by day 14 in all four) |

## 10. Performance

Frame time at 20:00 on the farm with each sign showing vs `10ab9f1` (same capture options, same background load):
11.2-11.4 ms after, 11.5-11.6 ms before. No measurable cost. The sign layers redraw every 6th frame.

## 11. Remaining concerns (for the owner and ChatGPT)

1. **Firewood before the woodshed** makes both hearth activities unavailable on half the first fortnight's evenings,
   and makes tending a costly gamble. Options (none built): a small daily kindling from the brush you already gather;
   splitting wood at the house before the woodshed; or tending that costs time only in the first weeks.
2. **The second week still drains a sleeper to 9-15** (tier-1 visitors from night 7). The grace only fixes the first
   week's spike, as briefed. Whether the second week should be gentler is a balance decision.
3. **The visitor wait:** a player who wants to face the 22:00 visitor and has no fire waits about a real minute. A
   clock change was not made; the cheaper fix may be another evening thing that doesn't need firewood.
4. **The crows go at once** when read (no fly-off animation; the static perch sprite is reused). Fine for a prototype.
5. **Signs only show to a player who is outside at 19:00** (the notice) or walks past; the cozy farmer never saw one.
   That is by design (staying in is a choice), but a sign seen from a window may be worth considering.
6. The tutorial still says "bed from 18:00", which skips the whole evening; unchanged here (CCH-LOOP-001 question I-2).

## 12. Commit

Pushed to `main` in logical commits; the SHAs and pinned links are on `AI_COLLAB/MESSAGE_BOARD.md`.
