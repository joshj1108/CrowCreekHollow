# CCH-PLAYABLE-002 — Gameplay repairs: report

**Status:** repairs done and tested, stopped for owner and ChatGPT review (2026-11-13). Prepared by Claude Code.
Companion: `AI_COLLAB/CCH_LOOP_001_IDLE_TIME_AUDIT.md` (Part B, run on this repaired build).
**Build:** `main` at `cbacc9c` plus the repairs below (committed as `2a4748f`). The owner's uncommitted sunset experiment (`LONG_DUSK`, `SUNSET_*`,
the grade's `glow`, `project.godot`, `scenes/main.tscn`) was left untouched and is not in the repair commit.
**Evidence:** `art/style_tests/CCH-PLAYABLE-002/` (`logs/` tests, probes, old saves; `play_kbm/`, `play_pad/` the
input-driven replays with screenshots; `review/` the review sheets).

**Balance:** no number that sets difficulty, economy or pacing was changed, with one deliberate, flagged exception
on the first trek (PLAY-09, `EDGE_WORD_CALMS`, one constant to turn it off). Sanity, the nights, the visitors, crop
times, prices and XP are as they were.

## Summary

| ID | Issue | Result |
| --- | --- | --- |
| PLAY-01 | Falling indoors left the farmer stuck in the furniture | **Fixed.** Wakes at the gate, outdoors, free; Unstick now also works in the house. |
| PLAY-04 | Chapter 9 needed a lost sanity limit | **Fixed (approved rule).** The first cleanse counts with no limit lost; refusals name what is missing. |
| PLAY-05 | Davy's beat left open after the bell | **Fixed.** Closed with the other beats, and on load for older saves. |
| PLAY-11 | Older saves raised script errors on load | **Fixed.** Notes said while loading wait for the HUD and are shown. |
| PLAY-03 | Morning report overwritten at once | **Fixed.** Notices are held and queued; everyday lines show beneath; the diary keeps "What the day said". |
| PLAY-06 | Hints followed "a pad is connected" | **Fixed.** Hints follow the last device used (keys, mouse or pad), from the title menu on. |
| PLAY-07 | First minute taught no controls | **Fixed.** The first lines name walking and the door; the desk has a prompt. |
| PLAY-08 | Buying seeds never introduced | **Fixed.** A "Seeds and supplies" diary page, the desk prompt names the catalog, chapter 7 names the desk. |
| PLAY-02 | The night's sanity cost unexplained | **Explained, balance unchanged.** "What the night takes" page; the morning report states the cost. |
| PLAY-09 | First trek: frozen walker had no remedy | **Fixed, with one flagged tuning change** (a word calms Maren on the edge trek only). |
| PLAY-10 | Drinking answered with the fishing pole | **Fixed.** |
| PLAY-12 | Bare fishing pole read "(locked)" | **Fixed.** |
| PLAY-13 | 03:00 collapse in the cave woke in the cave | **Fixed.** |
| PLAY-17 | Prompts named tools the player doesn't own | **Fixed.** Says how to make the tool; the cave page names the pick and a weapon. |
| Porch / second storey | Legacy expansions in the progression map | **Documented, not changed** (see the last section). |

## Changes, by issue

### PLAY-01 — Falling indoors (`main.gd` `_fallen`, `_unstick`)
- `_fallen` clears `inside` before `_set_bounds()`, so the house's clamp no longer drags the gate position into the
  dining table, and then runs the house's leave hooks (`nights._on_leave_house`, `happenings._on_leave_house`) after
  the collapse line, as walking out would. The sanity cost (-10) and the full-health wake are unchanged.
- `_unstick` in the house now puts the farmer on the mat inside the door (always open floor) instead of refusing. In
  the cave it still refuses (the exit is always reachable there).
- Tests: `tools/playable002_test.gd` falls indoors with each empty need (food, water, comfort with the fire out), HP 1:
  outdoors, on open ground, walks 60 px each way, sanity -10, limit unchanged, full health; save and load after the fall
  is outdoors and free. `tools/audit_state_probe.gd` (the CCH-PLAYABLE-001 probe): **0 suspect** (was 1).

### PLAY-04 — Chapter 9 "Clear the Stain" (`sanity_system.gd`, `panel_rows.gd`, `STORY` text)
- **Approved rule:** the first cleanse needs no lost limit (`stats.cleansed == 0`). Every later cleanse still needs a
  lost limit, Cleaning 3, 2 crops and once a day. The cleanse gives no XP of its own; the chapter's reward (40 Cleaning
  XP, raised by the existing "more while hale" bonus) is unchanged.
- The refusal now names what is missing ("Cleansing needs Cleaning 3 and 2 crops to offer.", "You have already cleansed
  the house today.", "The house is clean. Cleansing only lifts a sanity limit you have lost."). The House panel row hides
  "Some of the limit lost" before the first cleanse and says the first cleanse clears the stain. The chapter's line
  reads "Cleanse the house once (Cleaning 3 and 2 crops, from the House panel)."
- Tests: a player with no limit lost and one with 10 lost both complete chapter 9; crops are spent; no free XP; a second
  cleanse with no limit lost is refused with its reason; once a day holds.
- Probe (400 simulated days, engaged): chapter 9 on **day 27** (was day 398).

### PLAY-05 — Davy and the last chapters (`story_act.gd`, `main.gd` `_on_title_start`)
- `_close()` closes `davy` with the other beats (-1: no diary page, no change to `davy`, so Davy's outcome and the
  endings are untouched). A loaded save that is already past the bell is closed on load, so older stuck saves recover.
- Tests: Davy found normally → chapter 15; bell hung before Davy → beat closed quietly, no Davy page, chapters 15, 16, 17
  and every chapter complete, All Chapters achievement earned; an older save past the bell with Davy open → closed on
  load, the chapter list finishes; with no bell, Davy's night still comes on day 370.
- Probes (400 days): engaged **17 of 17 chapters**, All Chapters on day 401, ending Two Came Home (day 399-400); ignore
  The Line Under the Rooks (283); early-bed The Line Under the Rooks (282) and The Hollow Sleeps (400). Every ending
  that was reached before is still reached. In ignore mode the grove was not walked within 400 days (the bell went up
  on day 397), so its last chapter was still open when the run ended; that is the run's length, not a dead end.

### PLAY-11 — Old saves (`main.gd` `_show_message`)
- `_show_message` no longer writes to a label that does not exist yet: before the HUD is built, notices wait in the
  queue and show once it is. No save format change; no migration step changed.
- Tested on **copies of all 8 save files on this machine** (`tools/playable002_oldsaves.sh`; the owner's files are
  only copied, never opened by the game; this replaces the "9 files" count of the last audit, which counted one twice):
  **no script error** (was 1-4 per old save); every migration note is queued and shown ("The farm was redrawn...",
  "The coop / barn / workshop was moved..."). Round-trip differences are only the two new keys (`morning_report`,
  `morning_report_day`) and the known player-position nudge; furniture, house stage, inventory, quests, mail, skills
  and world state survive (`logs/save_owner_copies.log`). `save_test`: PASS, 0 failures.

### PLAY-03 — Messages (`main.gd` `_show_message`, `_update_messages`; `panel_rows.gd` `_said_pages`)
- Two kinds of line, one label. **Notices** (`_show_message(text, true)`: the morning report, chapters, new diary
  pages, guide steps, achievements, a visitor's arrival, mystery pages, Davy, the collapse, migration notes, the first
  trek's freeze) are held on screen for `clamp(2 + length/40, 3, 10)` seconds before another notice may replace them,
  and wait in a queue (6 at most) meanwhile. **Everyday lines** (watering, "you step inside", tool hints) never erase a
  notice: they show beneath it, separated by a blank line, and replace only each other. When nothing is held the label
  behaves as before. The clock-based hold pauses with the game (menus, transitions).
- **Fitting the screen:** a long report (often 600-700 characters) is cut between sentences into parts of at most
  240 characters, marked "(1 of 4)", which play in order through the queue; and the message label now grows upward
  from the bottom edge. Before, a long report also ran off the bottom of the screen (seen in this pass's day-4 replay
  screenshot, fixed and re-shot: `review/after/d4_morning_report_held.png`, `..._part2.png`).
- **Re-reading:** the diary has a new section, **"What the day said"**: "This morning, day N" (the full report, saved
  with the game) and "Lately" (the last 8 notices with day and time).
- Trigger texts are unchanged; only the `true` flag was added to existing calls.
- Tests: the report stays while two watering lines and a diary-page notice arrive; the newest watering line shows
  under it; the diary notice follows after 4.1 s; both are in the diary; after a real night's sleep the report is on
  screen two seconds into the morning.

### PLAY-06 — Control hints (`main.gd` `_fill_controls`, `_pad_prompts`, `_device_words`; `action_bar.gd`)
- `_fill_controls` uses `ActionBar._pad_glyphs`, the "last device used" flag the footers already keep, instead of
  `Input.get_connected_joypads()`. A mouse click now also counts as keyboard and mouse. The title menu's device is
  carried into the game, so a pad player's first hints name buttons.
- Older message lines that hard-code "press Space" say "press A" for a pad player; "B cancels" says "Esc cancels" for
  a keyboard player. Panel notes that name Space now read "Space (A)": rewording panel text on a device change would
  rebuild the panel and steal the press that changed device (this broke 3 `menu_test` cases until changed).
- Night hints are filled too (the pond visitor's "press Space" is now `{hand}`).
- Tests: keys → "Space Tab", pad → "A Y", back to keys, a mouse click → keys. `menu_test` 785 PASS (footer prompts per device included).
- **Hardware note (observation, not a code issue):** during this session this machine's built-in controller sent
  presses by itself (Start, then A, B, X and Y together, every few seconds, recorded by a spy script while nothing was
  touched). With hints that follow the last device, such presses switch the hints to the pad, as they would the footers.
  If the owner sees pad hints while on the keyboard, this is the cause. The play bot now pins its own pad buttons to a
  separate device id and drops other pad buttons (`tools/audit_play.gd` `_isolate_hardware`), so replays are clean.

### PLAY-07 — The first minute (`main.gd`; `mail_system.gd` prompt)
- The first line: "A new season begins. Day 1. Rain. Walk with WASD or the arrow keys, and into the farmhouse door to
  go in." (the pad version names the left stick). The diary reminder (first after 8 s, then every 90 s) adds "Walk in
  at the front door with ..., face the desk and press Space."
- Facing the desk shows the mailbox's style of prompt: "Space  Open the desk drawer" until the diary is found, then
  "Space  The desk: catalog, accounts, pastimes".
- Finding the diary adds "Esc pauses the day and lists every control." (Start on a pad).
- Nothing pops up; there is no new tutorial screen.

### PLAY-08 — Seeds (`TIPS`, `_tip_ready`, `STORY` chapter 7, desk prompt)
- New diary page **"Seeds and supplies"**, from day 2 once a sale is made or the seed pouch is down to 2: where the
  Catalog is (the desk in the bedroom, the Catalog tab), that orders are paid in coins and come with the morning post,
  and where coins come from (the stand). Chapter 7 now says the coins buy "seeds and supplies from the Catalog at the
  desk in the bedroom". The Catalog stays at the desk and mail at the mailbox.

### PLAY-02 — The night and sanity (`TIPS` "night", `night_system.gd` `_resolve`)
- New diary page **"What the night takes"**, written after the first night a visitor is left alone and costs sanity
  (`stats.left_alone`, new counter). It says: something comes most nights after 22:00; left alone while you sleep it
  takes sanity (why you can wake with less) and creeps the field's shadow; facing it in the lantern's light costs far
  less and pushes the shadow back; you need not face every night, but it adds up; what restores sanity (sleep, time
  indoors, a kept house, a good meal, a desk pastime, the vicar's blessing when very low); below 40 a walker's nerve
  fails faster beside you, below 30 the farm plays tricks. No story secret is named.
- A night left alone while asleep now ends its morning-report line with the cost ("Sanity -9.").
- Balance unchanged. See "First-week replay" for whether the system is still too punishing.

### PLAY-09 — The first trek (`trek_system.gd`)
- **Warnings and choices first:** the edge offer now says "If she stops dead, a word calms her enough to go on, or walk
  back the way you came to turn home", and warns a frayed farmer ("You are frayed yourself (sanity N): beside you her
  nerve will fail faster", under 40). The freeze line offers only what is to hand: a ration or bread if held, a word on
  the edge trek, and turning home; it no longer asks for a ration the player cannot have.
- **The one tuning change (flagged):** the frozen-walker state had no feasible remedy for a week-one player (a ration
  needs eggs; a word adds 10 and is spent once per clearing, short of the 35 needed). On the **edge route only**, a word
  to a walker who has stopped dead may be said again and raises her nerve to the unfreeze level (35). Other routes still
  need a ration. It is `EDGE_WORD_CALMS` in `trek_system.gd`; set it false to restore the old behaviour. Her nerve
  rates, the freeze level, the failure cost and the other routes are unchanged.
- Tests: the edge trek freezes, the line offers a word and turning home, a word unfreezes her; on the mill route a word
  alone does not. Input-driven result: see the replay section.

### PLAY-10, PLAY-12, PLAY-13, PLAY-17
- **PLAY-10:** the hand action at a fishing spot drinks (and fills the bucket); only the tool press casts.
- **PLAY-12:** the bare pole is not marked locked (it casts; a made rod only bites better). Rod crafting is unchanged.
- **PLAY-13:** a 03:00 collapse in the cave wakes at the gate, as the save already had it.
- **PLAY-17:** with the tool not made, the prompt says how to make it ("You need a pick for that. Make a stone pick in
  the Craft section of the section wheel (Shift)."); the cave's diary page names the pick, a weapon and the guard.

## Tests

| Test | Result |
| --- | --- |
| `tools/playable002_test.gd` (new, 79 cases) | **79 PASS, 0 FAIL** |
| `tools/audit_state_probe.gd` (deaths and collapses everywhere) | **0 suspect** (was 1: indoors) |
| Regression suite (`tools/audit_run_tests.sh`, 16 tests; menu, diary, save, wheel and the focused test rerun after the last change) | save 0 failures, menu **785/785**, interior 136, mail 42, debug_menu 40, diary 63, wheel 87, layout 67, farmer 79, creature 74, aoh2_e2 62, aoh2_e3 208, aoh2_e5 209, aoh_cave 6, diary_fit unchanged. `aoh_trek_check` 6 of 7 under load (its 50 ms build-time case read 103 ms with 16 tests and 5 sims running; it is the same timing case the last audit saw flake) |
| Old saves (copies of 8 files) | loaded, no script error, migration notes shown |
| Story probes, 400 days x 3 modes (`audit_probe.gd`) | engaged 17/17 chapters; endings as before |

No script error in any test, probe or play log.

## First-week replay (input-driven)

The CCH-PLAYABLE-001 play bot (`tools/audit_play.gd`, injected keys, mouse and Xbox input only, from the title menu,
fresh throwaway profile), 8 days on each device, on this build. Same bot and strategy as the last audit, including the
trail correction made then; plus the hardware isolation above. Logs: `play_kbm/log_week.txt`, `play_pad/log_week.txt`.

| Morning of day | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Sanity, CCH-PLAYABLE-001 (keyboard) | 100 | 91 | 93 | 67 | 40 | 12 | 2 | 2 | - |
| Sanity, now (keyboard) | 100 | 91 | 93 | 65 | 75 | 61 | 38 | 34 | 34 |
| Sanity, now (controller) | 100 | 91 | 93 | 67 | 77 | 65 | 41 | 37 | 37 |

- **Onboarding, confirmed by play:** the first line names the keys or the stick per device; the diary reminder says how
  to reach the desk; the guide steps name keys on the keyboard run ("Press 5 or scroll the mouse wheel... press left
  click") and buttons on the controller run ("Scroll with LB and RB... press RT") with the same pads connected; "What
  the night takes" and "Seeds and supplies" were written on day 2; the morning report stayed on screen with the
  day's first lines under it (still showing at 06:27 on days 2-4). No script error in either run.
- **First trek:** completed on the **first attempt on both devices**, day 4 (keyboard: nerve 69 entering, 51 in the
  second clearing; she never froze), against 1 success in 6 attempts last audit. Be clear about why: the earlier failures
  were mostly the bot walking round the trunk, corrected in the last audit; this time no sanity had been lost to failed
  treks. The new "a word calms her" remedy was **not exercised in play** (no freeze happened); it is covered by the
  focused test only.
- **First harvest, by play:** yes this time (chapters "First Crop" and "A Second Plot" done by day 8 on both devices).
  Chapters done in the week: 5 (bed, light, edge, first crop, second plot).
- **Is it still too punishing? (finding for the owner; balance not changed):** yes, for a player who follows the
  sleep advice. From day 3 to day 8 sanity falls from 93 to 34-37 with every night slept through: about -9 for each
  ordinary visitor and **-34 for one knock left at the door (night 4)**. It no longer reaches 2, because the trek
  succeeded (failed treks cost 10-13 each and a walked trek eases that night). At 34-37 the player sits just under
  the walker's nerve threshold (40) and above the vicar's blessing (20), so nothing in the game lifts them back up
  unless they choose to face a night. The new page now tells them that; whether the early cost of sleeping through
  should be lower is the owner's call. Options, none implemented: halve the first week's night losses; make the first
  knock cost less until it has been met once; or let a kept house's +2 grow in the first fortnight.


## Remaining known issues

- **Panel text names Space and A together** where it hard-codes the key ("press Space (A)"); a device-aware rewrite
  needs the action bar's glyph swap to cover note text. P3.
- **Raids, raid frequency (PLAY-15), chapter pacing (PLAY-14), eviction (PLAY-16):** owner decisions, untouched.
- **PLAY-18 to PLAY-22:** untouched (P3).
- **The hardware presses** described under PLAY-06 are outside the game.
- `aoh_trek_check`'s build-time case is load-sensitive (above).

## Legacy farmhouse expansions: the covered porch and the second storey

Re-checked against the current code (2026-11-13). They are **active, purchasable content**, not dormant code:
- **Data and purchase:** `EstateSystem.EXTENSIONS` (`estate_system.gd:15-25`): porch (house Patched; 1,200 coins, 60
  wood, 40 hardwood, 40 copper bars, Carpentry 6) and second storey (house Restored, after the porch; 3,000 coins and
  more, Carpentry 8). Bought from House → Extensions (`panel_rows.gd`), action `ext:`.
- **Effects:** porch: stand demand x1.25 (`_demand_mult`), +2 sanity each morning (`_morning`); storey: +6 sanity per
  sleep (`_sleep_bonus` → `SanitySystem._sleep_gain`), night loss x0.9 (`_night_mult` → `NightSystem._loss_mult`);
  each raises the property value (tax).
- **Save:** `estate.built` ids, saved and loaded by `EstateSystem._to_save/_from_save`; `_from_save` drops unknown ids,
  so deleting either id would silently remove a purchase from old saves.
- **Achievement:** `ACH_EXTENDED` "Under a New Roof" (goal = all extensions; published).
- **Art:** overlays `art/farm/e3/ext_porch.png` and `ext_storey.png` (`FarmScenery.HOUSE_EXT`), and `_draw_outside`
  as the fallback. No collision or tile depends on them.
- **Reach:** in the 400-day probes neither is bought (the second storey came on day 481 in an earlier 730-day run).
- **Recommendation:** the plan already on record (D-015; `ART_005_S2_LOGCABIN_FIELDS.md` §3) still fits the code and
  needs no update: never delete the ids; step 1, re-dress only (stop drawing the porch roof and dormer, rename the
  storey "Attic rooms"; two strings and the drawing); step 2, only if the owner wants them off sale: hide the rows for
  non-owners, keep owners' effects, pin the achievement goal, move their value to other purchases and re-run the sims.
  Both steps need separate approval. The progression map can simply mark them "legacy, retirement planned (D-015)".
  Nothing was built, removed or redesigned.

## Commits

- `2a4748f` CCH-PLAYABLE-002: gameplay repairs, tests and evidence.
- The follow-up commit with the review master and CCH-LOOP-001 is listed on the message board.
- Not committed (owner's work in progress): the sunset experiment in `main.gd`, `grade.gdshader`, `project.godot`,
  `scenes/main.tscn`.
