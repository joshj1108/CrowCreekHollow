# CCH-PLAYABLE-001 — Full playable-build audit: findings

**Status:** audit complete, stopped for owner review (2026-11-13). No game code was changed. Nothing in the repair
roadmap has been started. Prepared by Claude Code; ChatGPT to review.

**Build audited:** working tree at `155262e` plus the owner's uncommitted sunset experiment (`LONG_DUSK`, `SUNSET_*`,
the grade's `glow`, `project.godot`, `scenes/main.tscn`), which was left untouched and is not in any audit commit.

**Companion files**
- Progression map: `AI_COLLAB/CCH_PLAYABLE_001_PROGRESSION_MAP.md`
- Evidence: `art/style_tests/CCH-PLAYABLE-001/` (`evidence/` screenshots, `play_*/log_*.txt` play logs, `logs/` test,
  probe and engine logs). Index at the end of this file.
- Tooling added under `tools/` (all read-only towards the game, all run in throwaway profiles):
  `audit_play.gd` + `audit_play.sh` (the input-driven play bot), `audit_probe.gd` + `audit_probe.sh` (progression
  probe on top of `balance_sim.gd`), `audit_state_probe.gd` (death, collapse, recovery), `audit_save_probe.gd`
  (save round trips and old saves), `audit_run_tests.sh` (every regression test in parallel).

## How it was tested, and what that does and does not prove

| Method | What it is | What it is not |
| --- | --- | --- |
| **Input-driven play** (`audit_play.gd`) | The real, windowed game started from the title menu in a fresh profile. Every action is an injected key, mouse button, Xbox button, stick or trigger event; the bot never calls a game function to act. It logs every message the game shows, with the day and hour. Two full first weeks (keyboard and mouse, and controller), plus follow-up sessions continued from those saves. | Not a human. The bot knows where things are (it reads the map to steer). Discoverability is judged by me from its screenshots and the message log: what the game had told the player at that moment. It walks badly in places (see "bot limits"). |
| **Progression probe** (`audit_probe.gd`) | `balance_sim.gd` (the game's own functions, no walking) for 400 and 420 days in engaged, ignore and early-bed modes, recording the first day every chapter, page, tier, building, material, recipe, visitor and ending was reached, and what never was. | Simulated reachability only. "Reached" means the sim's strategy got there through game functions; "never" is a lead, not proof. Nothing here was played. |
| **Controlled probes** | Set-up states (`audit_state_probe.gd`: starving, a creature's blow, the 03:00 collapse, in each place) and save round trips (`audit_save_probe.gd`). | Set up, not played; each finding from them says so. |
| **Regression tests** | All 16 existing headless tests. | — |

**No cheats were used to claim progression:** no F4, no debug panel, no capture options, no edited saves. The owner's
saves were never opened by a game process: every run pointed `APPDATA` at a scratch folder, so slots 1-3 there were
empty. Old-save checks used **copies** in scratch profiles.

**Not available:** no physical controller input and no GUI automation of the desktop; controller coverage is injected
`InputEventJoypadButton` / `InputEventJoypadMotion` events (the same path the existing `menu_test.gd` uses). Rumble,
real stick drift, and how a pad feels were not tested. No human played.

---

## Executive summary

### A. Is the game currently playable?

| Level | Verdict | Basis |
| --- | --- | --- |
| **Launchable** | **Yes.** | Title menu, New Game, slot, name, Begin, Continue: worked by keyboard, mouse and controller in every session. No crash and no script error in any play session. |
| **First-session playable** | **Yes, with real onboarding gaps.** | The guided first day (8 steps), the first night's scare, the bed and chapter 1 all completed by real input on both devices. But the first minute teaches no controls (PLAY-07), control hints can name the wrong device (PLAY-06), and the daily briefing is usually overwritten before it can be read (PLAY-03). |
| **Core gameplay-loop playable** | **Mostly; one part was not completed in blind play.** | Planting, watering, bucket refill, forage, eating, drinking, gathering, crafting, chopping, house repair, chores, daily job, selling, catalog orders, the cave, combat, the guard, death and recovery all worked by real input. The first trek was completed by real input on the sixth attempt (a fresh game, day 4, sanity 67), after five failures (PLAY-09). **Not completed in blind play: a first harvest** (turnips ripen on about day 8; the played weeks ended on day 8). A new player following the tutorial's advice ends week one at sanity 2 of 100 (PLAY-02). |
| **Long-term progression playable** | **Reachable in simulation; not played.** | In the 400-day probes every homestead step (14 of 14), all three house stages, all three lantern tiers, every trek route, every material and every furniture piece were reached, on the days in the progression map. Two story chapters have real logic defects (PLAY-04, PLAY-05). |
| **Story-completable** | **Endings: yes in simulation. Chapter list: not reliably.** | All three endings were reached by the probes (Two Came Home day 399 engaged; The Line Under the Rooks day 285-288 ignore and early-bed; The Hollow Sleeps day 399 early-bed). But in the engaged run the chapter list was still stuck at chapter 15 of 17 after its ending had played, and can never finish on that save (PLAY-05). **No ending was reached by play.** |

### B. What is broken (every confirmed P0 and P1)

**P0: none confirmed.** The game launches, no crash was seen, no save was corrupted or lost in any test, and no
permanent soft lock was found.

**P1 (8):**
- **PLAY-01** Falling to empty needs while indoors leaves the farmer frozen inside furniture until 03:00; Unstick refuses.
- **PLAY-02** Sleeping through the nights, which is what the tutorial teaches, drains sanity to near zero in a week, and the game never explains it where the player will see it.
- **PLAY-03** Messages overwrite each other: the morning report is replaced about a second after waking on most days, and there is no log to re-read.
- **PLAY-04** Chapter 9 "Clear the Stain" can only be completed after the player has lost sanity limit; a careful player's chapter list stalls for about a year.
- **PLAY-05** Chapter 15 "Keeping Company" is never closed if the bell is hung before Davy's night happens; chapters 16 and 17 and Story Complete are then impossible on that save.
- **PLAY-06** Control hints follow "a controller is connected", not the device in use: a keyboard player with a pad plugged in is told RT, LB, Y and "left stick click" all through the guided first day.
- **PLAY-07** The first minute shows no controls, and the first objective needs the hand action, which has not been taught and has no prompt at the desk.
- **PLAY-08** Buying seeds (the desk's Catalog tab) is never introduced.

### C. What is missing

Nothing that the existing content needs was found to be absent: every material, recipe ingredient, tool tier, house
stage, route and ending has a working source in the game. What is missing is **explanation**, not content: the cost of
an unanswered night (PLAY-02), where seeds are bought (PLAY-08), the basic controls (PLAY-07), and a way to re-read
what the game said (PLAY-03). Two long goals were not reached by any 400-day probe (the covered porch and the second
storey, and the land deed at 12,000 coins); they are expensive, not broken (see the map).

### D. What works

See **Confirmed playable systems** below. In short: the title flow, both input devices, the guided first day, the farm
loop up to ripening, forage, needs, crafting, tools, house repair to Boarded, chores, the stand, the catalog, the
mailbox pages, the cave, combat and the guard, death in the cave, the first night, sleep and the daily save, and
saving and loading across a 400-day game and from older saves.

**P2 worth reading with them:** PLAY-09 (the first trek fails with no way out once the walker freezes, and failed five times in blind play before it was completed) and PLAY-11 (older saves raise script errors on load).

### E. What should be fixed next

See **Repair roadmap**. Critical first: PLAY-01, PLAY-05, PLAY-04 (three one-line-scale fixes that remove a stuck state
and two story dead ends), then PLAY-03 and PLAY-06.

### F. What can be deferred

Everything P3, the P2 items PLAY-12, PLAY-13, PLAY-16 and PLAY-17, the porch / second storey / deed pacing, and
the balance observations (raid frequency, PLAY-15). None of them stops an initial playable build.

---

## Findings

Severity as defined in the brief (P0 blocker, P1 major, P2 moderate, P3 polish). Complexity: S (under an hour, a few
lines), M (a focused session), L (more than one session). Status of every finding: **open, not fixed (audit only)**.

### P1 — Major

#### PLAY-01 — Falling indoors leaves the farmer stuck inside furniture
- **System:** needs, death and recovery (`scripts/main.gd` `_fallen`, line 5207; `_set_bounds`, line 6253; `_unstick`, line 5397).
- **Steps:** be inside the farmhouse with a need at zero (food, water or comfort) and health low; let health reach 0. Controlled reproduction: `tools/audit_state_probe.gd`, case "starve inside the house" (new game, `_enter_house()`, food 0, HP 1, the next needs tick).
- **Expected:** "You collapse. You wake at the homestead, shaken." and the farmer stands by the east gate, free to move, as happens outdoors, in the cave and on a trek.
- **Actual:** the same message, but `_fallen` moves the farmer to the gate without clearing `inside`; `_set_bounds` then clamps that position into the house rectangle, which lands on the dining table (interior tile 22,63). Held direction keys move the farmer 0 px in all four directions. The Pause menu's **Unstick** answers "Unstick works on the farm. Leave the house or the cave first." The farmer is released only by the 03:00 collapse (which costs sanity limit) or by quitting, which loses the day.
- **Evidence:** `logs/state_probe.log` lines "starve inside the house", "...after Unstick", "...after waiting to 03:00". Controlled probe; not reached in blind play.
- **How likely:** health is 10 and one point is lost every 2 game hours with a need empty, and health refills each morning, so it needs earlier damage (a cave fight) and then a cold or hungry evening indoors. The blind-play farmer ended a cave fight at 2 HP on day 8, so the state is within reach of a normal week-two day, most easily in winter with no fire.
- **Milestone affected:** survival; any day.
- **Proposed correction:** in `_fallen`, set `inside = false` before `_set_bounds()` (and call the same leave-house hooks `_leave_house` calls). Smallest alternative: let Unstick work whenever the farmer stands in a solid tile.
- **Complexity:** S. **Status:** open.

#### PLAY-02 — Sleeping through the nights empties sanity within a week, unexplained
- **System:** nights, sanity, onboarding (`scripts/night_system.gd`, `scripts/sanity_system.gd`).
- **Steps:** new game; follow the diary and chapter 1 ("the house is the one safe place... reach the bed"): go indoors at dusk, feed the fire, sleep at about 19:15 every night from day 2.
- **Expected:** a player doing what the tutorial says keeps a workable sanity, or is told plainly what the night costs and what to do about it.
- **Actual (blind play, both devices, identical):** morning sanity 100, 91, 93, **67, 40, 12, 2, 2** on days 1 to 8. Each visitor left unanswered took 13 to 26; three failed treks took about 13 each (see PLAY-09). From day 6 the madness effects began ("Weren't you holding the watering hose? It's the axe in your hand.", "There was a pumpkin here, ripe and heavy.") and the vicar came to bless the house. The night visitors' own hints (`NightSystem.HINTS`) only show at 22:00 to a player who is awake and outdoors; an early sleeper never sees one. The only explanation is inside the morning report, which is overwritten at once (PLAY-03), and the sanity bar has no number.
- **Probe context (simulated, not played):** early-bed mode spent 104 of 400 days under 60 sanity, 58 under 40, 17 under 20; ignore mode 124 / 51 / 27; engaged mode 15 / 2 / 0. So the system rewards facing the night, as designed; the defect is that a new player is never told.
- **Evidence:** `play_kbm/log_week.txt` and `play_pad/log_week.txt` ("slept: now day N ... sanity="); `logs/probe_*_400.log` "madness" line; `evidence/d7_morning_sanity_2.png`.
- **Milestone affected:** first week; the first trek (low sanity drains the walker's nerve, `NERVE_LOW_SANITY`).
- **Proposed correction (no balance change):** teach it. A diary page after the first unanswered night ("What the night takes": what was lost, that standing up to a visitor is the answer, and what restores sanity: tidying, pastimes, the blessing, a kept house), and keep the night's line on screen (PLAY-03). Whether the early-game cost itself should change is a balance decision for the owner; none is proposed here.
- **Complexity:** S to M (text and one trigger). **Status:** open.

#### PLAY-03 — The morning report is overwritten almost at once; no message log
- **System:** messages (`scripts/main.gd` `_show_message`, line 6305; `_end_day`, line 6150).
- **Steps:** sleep on any night after which something else fires at 06:00 (a diary tip, a torn page, a chapter).
- **Expected:** the player can read the morning report. It is the game's daily briefing and often the only place a fact appears: how the night went, which crops wilted, who is waiting at the gate, that a bill has come.
- **Actual:** one message slot, last writer wins. The report is set while the screen is black, and the first 06:00 message replaces it. Day 4, keyboard run: the report was 10 sentences (about 600 characters, ending "Old Maren is waiting at the east gate, wanting walking to the wood's edge, before three."); at 06:00 the screen showed "After the knocking, a torn page is lying on the doormat..." and at 06:01 "A new page in your diary: The mine." The same on days 3, 5 and 9. Nothing in the game lists past messages.
- **Evidence:** `evidence/d4_morning_report_replaced.png` (06:01, day 4); `play_kbm/log_week.txt` around "[D4 19:17] MSG: You sleep through the night" and the next two MSG lines.
- **Milestone affected:** every day; it is the root of PLAY-02 and weakens the tax notices (PLAY-16).
- **Proposed correction:** smallest reliable: queue messages instead of replacing (show each for its time, the morning report first), or hold the report until dismissed. Better, later: file each morning's report on a diary page ("This morning") so it can be re-read.
- **Complexity:** M. **Status:** open.

#### PLAY-04 — Chapter 9 "Clear the Stain" needs a lost sanity limit first
- **System:** story chapters, cleansing (`scripts/sanity_system.gd` `_can_cleanse`, line 122; `scripts/progression_system.gd` `_check_story`, line 42).
- **Steps:** play well: never collapse at 03:00, win or avoid the visitors that take sanity limit. Reach chapter 9.
- **Expected:** the chapter ("Cleanse the house once") can be done when its stated needs are met (Cleaning 3, 2 crops).
- **Actual:** `_can_cleanse()` also requires `sanity_penalty > 0`. With no penalty the Cleanse line reads "Not yet" and the refusal says "Cleansing needs Cleaning 3, 2 crops, and one try a day.", which does not mention the real reason. Chapters complete strictly in order, so chapters 10 to 17 wait behind it. In the engaged probe chapter 8 was done on day 21 and chapter 9 on **day 398**, with chapters 10 to 14 all completing the same morning. (Ignore: day 96; early-bed: day 93, both after losing limit.)
- **Evidence:** `logs/probe_engaged_400.log` "PROBE chapter:" line; the code lines above. Simulated and read from code; not reached in play.
- **Milestone affected:** story chapters 9 to 17 for a careful player; the Quests panel's "Current chapter" guidance for about a year.
- **Proposed correction:** allow the first cleanse with no penalty (`stats.cleansed == 0`), or let the chapter count a cleanse attempt; and make the refusal say what is missing. A progression-rule change, so the owner chooses.
- **Complexity:** S. **Status:** open.

#### PLAY-05 — Chapter 15 "Keeping Company" can be left open for good
- **System:** the second year (`scripts/story_act.gd` `_close`, line 134; `_morning`, line 145).
- **Steps:** do not walk Davy to the drowned orchard between day 265 and the second All Hallows (day 396); hang the bell.
- **Expected:** hanging the bell closes whatever beats are left ("Hanging the bell closes whatever beats are left", DESIGN.md), so the remaining chapters complete.
- **Actual:** `_close()` closes `letter, shown, orchard, knock, meeting` but not `davy`. Davy's night needs the orchard beat, so it never happened; `beats` has no `davy`; chapter 15's stat (`act_davy`) stays 0; chapters 16 (the bell) and 17 (the grove) cannot complete behind it. In the engaged probe the bell was hung on day 396, the grove walked and the ending **Two Came Home** played on day 399, and on day 401 the chapter list still stood at 14 of 17 (`ALL_CHAPTERS 14/17`, "NEVER chapter: act_davy, act_bell, act_grove"). `_morning` returns early once closed, so nothing later can set it.
- **Evidence:** `logs/probe_engaged_400.log` ("second year: beats {...}" has no davy; "NEVER chapter (3 of 17)"), and the same in `probe_engaged_420.log`. Simulated; permanent for that save.
- **Milestone affected:** Story Complete, the All Chapters achievement, chapters 15 to 17.
- **Proposed correction:** add `"davy"` to the list in `_close()` (closed quietly, -1), and run the same once on load for saves already past the bell.
- **Complexity:** S. **Status:** open.

#### PLAY-06 — Control hints name the controller whenever one is connected
- **System:** tutorial text (`scripts/main.gd` `_fill_controls`, line 3185).
- **Steps:** have any controller connected (this machine reports an "XInput Controller" and a built-in Legion controller at all times); play with keyboard and mouse.
- **Expected:** hints name the device in use, as the panel footers do (`ActionBar._pad_glyphs`, last device used).
- **Actual:** `_fill_controls` tests `Input.get_connected_joypads()`. In the keyboard run the diary read "Use the left stick to walk", "Scroll with LB and RB to select the trowel... press RT", "Press Y to open your bag", "Press a left stick click to open the section wheel", while the same screen's footer showed Esc and Shift. Messages follow suit ("Open it again with the Diary section on the section wheel" instead of naming J).
- **Evidence:** `evidence/d1_diary_controller_text_on_keyboard.png`; `play_kbm/log_week.txt` "ACT: guide step" lines and the "joypads the engine reports connected" line.
- **Milestone affected:** the whole guided first day for keyboard players with a pad attached (always, on the owner's handheld).
- **Proposed correction:** use the last-device flag the footers already keep.
- **Complexity:** S. **Status:** open.

#### PLAY-07 — The first minute teaches no controls; the first objective needs an untaught key
- **System:** onboarding (`scripts/main.gd` `_update_tips`, `_find_diary`).
- **Steps:** start a new game and do nothing.
- **Expected:** movement and the interact key are shown before they are needed.
- **Actual:** the first frame shows "A new season begins. Day 1. Sunny." and no prompt. After 6 seconds: "Your diary is in the desk drawer, in the farmhouse bedroom." (repeated every 90 s). That message does not say how to walk, how to go in (walk into the door), or that Space / A uses the desk; the desk has no prompt (only the mailbox has one). The control list exists (Pause, Controls) but nothing points to it. The diary, once found, teaches everything else well.
- **Evidence:** `evidence/d1_first_frame.png`, `evidence/d1_inside_no_prompt.png`; `play_kbm/log_start.txt` (100 s of idling: two hint lines and nothing else).
- **Milestone affected:** the first objective of the game.
- **Proposed correction:** show the two basics with the first hint ("WASD to walk. Space at the desk."), and reuse the mailbox's contextual prompt at the desk until the diary is found.
- **Complexity:** S. **Status:** open.

#### PLAY-08 — Buying seeds is never introduced
- **System:** catalog, farming loop (`scripts/desk_system.gd` `_catalog`; `TIPS`, `GUIDE`, `STORY` in `main.gd`).
- **Steps:** plant the 5 starting seeds; earn coins; look for where to spend them on seed.
- **Expected:** the game says where seeds come from.
- **Actual:** seeds are ordered from the **Catalog** tab at the desk and arrive with the morning post. No guide step, tip, chapter or panel says so. Chapter 7 says "Coins buy seeds, bags, and the rooms the homestead will need" without saying where. The word "catalog" reaches a new player only in the Hens and Goats tips (after a coop or barn) and in Maren's lamp-oil line. The farm stand only buys. The blind-play week ended with 162 coins and no seed bought until the follow-up session went to the desk on purpose (the order itself works: "You order 5 turnip seeds for 15 coins. It comes with the morning post.").
- **Evidence:** `play_kbm/log_extras.txt` (desk tabs and the order); grep of every player-facing "catalog" string, listed in the audit log.
- **Milestone affected:** the core farming loop after the first planting.
- **Proposed correction:** one diary tip when the player first holds coins or first sells ("Seeds and supplies: the catalog at the desk"), and name the desk in chapter 7's text.
- **Complexity:** S. **Status:** open.

### P2 — Moderate

#### PLAY-09 — The first trek: a frozen walker cannot be helped; five of six blind attempts failed
- **System:** treks (`scripts/trek_system.gd` `_interact`, lines 1204-1222; `FREEZE_BELOW`, `UNFREEZE_AT`).
- **Steps:** day 4 or later, Tin Lantern built; talk to Old Maren at the east gate twice; in the wood let her nerve fall under 25.
- **Expected:** a first, tutorial-sized trek that can be recovered from a mistake, or that says plainly how to turn back.
- **Actual:** she freezes with "Maren stops dead and won't take another step. \"I can't. I can't.\" Give her a trail ration." A trail ration needs eggs (a coop and hens), so a week-one player cannot have one; bread needs flour from the mill. The one remedy to hand, a word, works once per clearing and adds 10, which does not reach the 35 needed. The player then stands for about 25 game minutes while her nerve runs out, and the trek fails (-10 sanity). The message does not offer turning back. Each failure made the next attempt harder: sanity fell, and under 30 sanity her nerve drains faster.
- **Blind-play record:** five attempts, none completed. Attempts 1 to 4 (days 4 to 7, both devices) were lost to the bot leaving the trail round a fallen trunk; attempt 5 (day 8, bot corrected: trunk cleared with the hand action, "You hack a gap through the fallen trunk and help Maren over") began with sanity 4 and she froze in the second clearing at nerve 32. **Attempt 6 succeeded:** a fresh game, day 4, sanity 67, the corrected bot; her nerve was 51 entering the second clearing and she reached the stile ("That's the way to the mill...", +10 coins, the achievement To the Wood's Edge, chapter 3 done). So the trek is passable by real input at normal sanity, and was not passed at very low sanity. Confirmed by real input: the offer, the oil she gives, setting out, clearing the trunk, the tall one's glimpse, arrival and its rewards; and on the failures the freeze, the failure and a clean return to the farm in a valid state.
- **Evidence:** `play_kbm/log_week.txt` (days 4 to 7), `play_kbm/log_trek_attempt1.txt`, `play_kbm/log_trek_attempt5.txt`, `play_kbm/log_edge_4day.txt` (the success); `evidence/trek_edge_blocked_tree.png`, `evidence/trek_edge_completed_home.png`.
- **Milestone affected:** chapter 3 "To the Wood's Edge" for a player already low on sanity; chapters are sequential, so the first harvest's chapter waits behind it.
- **Proposed correction:** make the frozen line true for the first trek (say "a word, or turn back by the way you came" when no ration is held), and let the word work while frozen on the `edge` route. Tuning her nerve is balance and is not proposed.
- **Complexity:** S. **Status:** open. Rated P2, not P1, because the trek was completed once; a human playtest of this trek is still the most useful next check.

#### PLAY-10 — "Drink" answers with the fishing pole when the bank tile is a fishing spot
- **System:** pond, guided first day (`main.gd` `_interact`, the `fish_spots` branch before the water branch).
- **Steps:** guide step 8 "Walk to the pond, face the water, and press Space to drink"; face a pond tile that currently holds a fishing spot.
- **Expected:** a drink. **Actual:** "Press RT or click to use the fishing pole." (the player has no pole). The step stays open until the player tries another tile. Seen on day 1 and day 6 of the keyboard run and day 2 of the controller run.
- **Evidence:** `play_kbm/log_week.txt` "[D1 09:21] PROBLEM", `play_pad/log_week.txt` "[D2 08:40]".
- **Proposed correction:** a hand press on a fishing spot drinks (the rod already needs the tool press). **Complexity:** S. **Status:** open.

#### PLAY-11 — Older saves raise script errors on load, and their migration messages are never shown
- **System:** save migration (`scripts/save_system.gd` lines 336-342; `main.gd` `_relocate_building`, line 5587).
- **Steps:** load a save made before the farm layout changed (4 of the 9 save files on this machine, tested as copies).
- **Expected:** "The farm was redrawn since this save..." and "The coop was moved to a clear spot on the farm." are shown.
- **Actual:** the loader calls `_show_message` before the HUD exists (`_load_game` runs before `_build_hud` in `_on_title_start`): `SCRIPT ERROR: Invalid assignment of property or key 'text' ... on a base object of type 'Nil'`, one per message (1 to 4 per load). The save still loads and plays; the player is never told their crops, brush and buildings were reset or moved. In a release build the same null write is unguarded.
- **Evidence:** `logs/save_owner_copies.log`. **Proposed correction:** collect these notes and show them after the HUD is built (as "Welcome back" is). **Complexity:** S. **Status:** open.

#### PLAY-12 — The fishing pole reads "(locked)" but works; the first rod needs Fishing 2
- **System:** hotbar, fishing (`scripts/hotbar.gd` line 113; `main.gd` `_hotbar_unlocked`, `TOOL_TIERS.rod`).
- **Actual:** with no rod made the slot is greyed and named "Fishing pole (locked)", and the Willow rod needs Fishing level 2, which only fishing gives. A player reads that as a dead end. In fact selecting slot 7 and casting works with no rod ("You cast your line. Biting now: yellow perch.", controlled check; a rod only adds catch chance).
- **Evidence:** controlled check in the audit log (rod tier 0, cast starts); code lines above. The bot's real-input cast did not start because the spot had moved before it arrived, so this one is confirmed by a set-up check, not by play.
- **Proposed correction:** do not mark the bare pole locked (or say "bare hands: slower"). **Complexity:** S. **Status:** open.

#### PLAY-13 — A 03:00 collapse in the cave leaves the farmer in the cave next morning
- **System:** collapse (`main.gd` `_end_day`, `_collapse_scene`).
- **Actual:** the cards say "You don't remember the way home", the day rolls over and the save puts the farmer at the east gate, but the running game leaves them in the cave (yesterday's layout) until they walk out. Loading that save puts them at the gate. Not stuck: the exit works. (Controlled probe.)
- **Evidence:** `logs/state_probe.log` "03:00 in the cave". **Proposed correction:** `_end_day` leaves the cave as it leaves the house. **Complexity:** S. **Status:** open.

#### PLAY-14 — The chapter list has long built-in stalls
- **System:** story pacing (`STORY`, `REPAIR_COSTS`).
- **Actual (simulated):** chapter 10 "A Home Worth Keeping" needs the Restored house, which needs Carpentry 8 and Summer; the game starts on October 1st, so the earliest is about day 245. With PLAY-04 fixed, "Current chapter" would still read chapter 10 from about day 25 to day 245. The homestead steps ("Next: ...") carry the player meanwhile, so this is guidance, not a blocker.
- **Proposed correction:** none required; consider showing the homestead's next step beside the current chapter. **Complexity:** S. **Status:** open, owner's call.

#### PLAY-15 — Raids come almost every night once there are animals (observation)
- **System:** `NightSystem` raids. **Actual (simulated):** 361 raids in 400 nights in engaged mode (256 won), 377 and 379 in the other modes (none won). Reported because it will dominate how the nights feel; it is balance, and no change is proposed.
- **Evidence:** `logs/probe_*_400.log` "madness" line. **Status:** open, owner's call.

#### PLAY-16 — Unpaid tax deletes the save, and its first notice rides on the morning report
- **System:** `DeskSystem._evict`. **Actual (read from code; `save_test.gd` covers the eviction):** the first bill comes on day 93; 28 days after it (14 grace, 14 overdue) the save and its backup are deleted and the title screen says why. Three letters warn (bill, overdue, final notice), each naming the desk, and the mailbox flag stays up, so it is communicated; but each one's spoken notice is a line in the morning report (PLAY-03). In every probe the sim paid on day 93.
- **Proposed correction:** none to the rule; fixing PLAY-03 covers the notice. **Status:** open, design risk noted.

#### PLAY-17 — Tool prompts point at tools the player does not own
- **System:** `_need_tool`. **Actual (real input):** facing ore with no pick: "Select the pickaxe on the hotbar to do that." The useful line ("The copper ore is too hard for your hands. Craft a stone pick from the Craft panel.") only shows if the locked pickaxe slot is already selected. Nothing in week one says a pick is needed for the cave, or that a weapon is (the cave tip says only "creatures to watch for"; the day-5 cave held 7 creatures against 10 health).
- **Evidence:** `play_kbm/log_week.txt` "[D5 13:46]", `play_kbm/log_extras.txt`. **Proposed correction:** when the tool is not owned, say how to make it. **Complexity:** S. **Status:** open.

### P3 — Minor

- **PLAY-18** Save round trip differences that are not losses: empty cellar entries (`"parsnips": 0`) are dropped on load, and a hen delivered that morning gets its age entry on load rather than at the next sync. No state is lost. (`logs/save_roundtrip_*.log`.)
- **PLAY-19** Test tooling: four headless tests end with "N resources still in use at exit" (`debug_menu_test`, `layout_test`, `aoh2_e3_check`, `aoh2_e5_check`); `aoh_trek_check` failed its "slowest build under 50 ms" case at 53.2 ms when 16 tests ran in parallel (see "Regression tests" for the rerun alone).
- **PLAY-20** `DESIGN.md` → Endings → Sim quotes results the current build no longer gives (engaged: orchard 273, knock 290, Davy stopped 370; now the engaged sim never walks the orchard after day 265 and those beats are closed by the bell on 397). Documentation drift; it also hid PLAY-05.
- **PLAY-21** The early fiber squeeze: the 7 brush piles give 7 fiber on day 1 and regrow every 3 days; the hatchet (2), the Boarded repair (2), a daily mend (1) and the Tin Lantern (3) compete for it, so the lantern, which Maren needs on day 4, was not affordable until day 4 in both runs. Works; tight.
- **PLAY-22** Interior camera at stage 0 in rain is very dark and the desk does not read as a desk (approved art; noted only because it is the first objective, see PLAY-07).

---

## Confirmed playable systems

Tested successfully. "Input" = injected keyboard/mouse and controller events in the real windowed game; "probe" =
controlled set-up; "sim" = simulated only. Do not re-audit these unless a fix touches them.

| System | How confirmed | Notes |
| --- | --- | --- |
| Launch, title menu, New Game, slot, name, Begin | Input, both devices | Focus opens on New Game when no save exists; Continue and Load are disabled then. |
| Continue from the title menu | Input, both devices | Day-8 saves loaded ("Welcome back. Day 8."). |
| Walking, facing, doors (house in and out) | Input, both devices | Left stick and WASD. |
| Hotbar selection | Input | Number keys; LB / RB. |
| Diary: found at the desk, opened (J, or the wheel), guide pages, new-page marks | Input, both devices | `diary_test` 63 PASS. |
| Guided first day, all 8 steps | Input, both devices | Finished by about 09:25 on day 1. |
| Bag (Tab / Y), eating from a slot | Input, both devices | |
| Section wheel, opening Craft, Quests, House, Diary | Input, both devices | `wheel_test` 87 PASS. |
| Craft: crude hatchet, Tin Lantern, sharpened stick (auto-equips) | Input, both devices | |
| Planting, bucket watering, refill at the pond, rain watering | Input, both devices | "Watered from the bucket. 7 left." |
| Crop growth overnight, wilting to blight, crows pecking | Input (observed in morning reports) | Ripening and harvest: sim only (first harvest day 10-11). |
| Forage (blackberries, pears, rose hips, apples, chanterelles) | Input | |
| Drinking at the pond | Input | Except on a fishing spot (PLAY-10). |
| Brush gathering, tree felling, wood and resin | Input | |
| House repair to Boarded, mending, the daily job | Input, both devices | Ledger: click then Space, or A. Stages 2-3: sim (days 13, 245) and `interior_test` 136 PASS. |
| Homestead steps and their coin rewards | Input (step 1), sim (all 14) | |
| Farm stand: selling forage | Input, both devices | Chapter 7 counts sales but waits behind chapters 3 to 6. |
| Catalog order at the desk | Input, both devices | 5 turnip seeds for 15 coins. |
| Mailbox: torn page on day 3, prompt, panel | Input (page), `mail_test` 42 PASS | No letter arrived in week one. Bills and letters: sim (days 14, 93). |
| Hearth: feeding the fire, the fire going out, "wake chilled" | Input | |
| First night's scripted scare, achievement | Input (watched from indoors) | |
| Bed, sleep sequence, daily save, chapter 1 and 2 rewards | Input, both devices | |
| Agnes's pages 1-5 | Input | Mailbox, the stand's tin, the doormat, the cave mouth, the crows. |
| Cave: entering, leaving, creatures spawning, the lantern | Input, both devices | `aoh_cave_check` 6 PASS, `creature_test` 74 PASS. Mining ore: sim only (no pick in week one). |
| Combat: swing on the contact frame, hits, misses, kills, XP, loot | Input, both devices | 11 swings, 8 hits, 2 kills with a sharpened stick. `farmer_test` 79 PASS. |
| Guard (right click / LT) | Input, both devices | 3 blows turned in 4 tries; the fourth was not a clean test. |
| Death in the cave | Input, both devices | "You collapse. You wake at the homestead, shaken." at the gate, free to move, full health. |
| Death on the farm, in the cave, on a trek; 03:00 on the farm, indoors, on a trek | Probe | All leave a valid state; indoors death is PLAY-01, cave 03:00 is PLAY-13. |
| First trek (the wood's edge): offer, oil, setting out, clearing a trunk, the glimpse, arrival, reward, chapter 3; and failure with a clean return | Input (keyboard); the controller run only failed it | 1 success in 6 attempts (PLAY-09). Other routes: sim and `aoh_trek_check` 7 PASS. |
| Saving and loading: 24 round trips over two 400-day games | Probe (sim state) | 120 keys each, no state lost (PLAY-18). `save_test` 65 PASS. |
| Older saves: 9 files, including pre-layout and version-16 saves | Probe (copies) | All load; PLAY-11 on four. |
| Backup, temp-file and damaged-save recovery, eviction | `save_test` 65 PASS | Not re-derived. |
| Every menu by keyboard, controller and mouse | `menu_test` 785 PASS | |
| Seasons, weather kinds, the calendar | Sim | Autumn, Winter, Spring, Summer; all weather kinds seen. |
| All tool and lantern tiers, furnace, smokehouse, cellar, coop, barn, cistern, hose | Sim | Days in the progression map. |
| Furniture (6 of 6), wallpaper, paint, cellar room | Sim, `interior_test` | |
| All six trek routes, 8 of 9 trail works | Sim | |
| Folk hearts to 10 with all four walkers, their scenes | Sim | 3 to 5 of 12 requests done. |
| The second year's beats and all three endings | Sim | See PLAY-05. `menu_test` covers the ending screen's keys. |

## Not tested, and why

- **A human player.** Not available. Every usability judgement here is mine, from logs and screenshots.
- **A first harvest by real input** (turnips ripened after the played weeks), and a completed trek **on a controller** (its attempts were all made with the uncorrected bot).
- **Facing a night visitor outdoors by real input.** The first night was watched from indoors; the bot slept through the rest. Sim only.
- **Raids, fences, snares, decor, animals, cooking, the smokehouse, furnace, cellar, cooler and firewood store by real input.** None is reachable in a played week. Sim and existing tests only.
- **House stages 2 and 3, furniture and extensions by real input.** Sim, `interior_test`.
- **Seasonal transitions and saving across them by real input.** Sim round trips cover days 62, 93, 150, 246 (season changes fall between checkpoints; the state after each was compared).
- **The endings, by play.** Sim only; no ending was played.
- **Killing the process mid-save.** Not done; `save_test` covers the half-written file and backup cases.
- **Physical controller, rumble, and exported (release) builds.** Only the editor binary with `-s` scripts and the main scene was run.
- **Bot limits:** it got stuck four times on tiles it could not centre on (the stand, a tree, the trail by the trunk); it walked round the trunk until corrected; it cannot judge whether a thing is visible on screen.

## Regression tests (rerun 2026-11-12, working tree)

All 16 in parallel, each in its own profile: save 65, menu 785, interior 136, mail 42, debug_menu 39, diary 63,
wheel 87, layout 67, farmer 79, creature 74, aoh2_e2 62, aoh2_e3 208, aoh2_e5 209, aoh_cave 6, aoh_trek 6 of 7 in the
parallel run (its "slowest build under 50 ms" case read 53.2 ms under load) and **7 of 7 when rerun alone (47.2 ms)**,
diary_fit unchanged (39 pages, 7 scrolling). No script error in any.
Summary: `logs/tests_summary.txt`.

## Performance (measured: `tools/capture.gd ... perf`, vsync off, 300 frames, integrated AMD Radeon)

| Scene | 1280x720 mean / p95 ms | 960x540 mean / p95 ms | 1920x1080 mean / p95 ms |
| --- | --- | --- | --- |
| Farm, 22:30, rain, Hollow Lantern, restored house lit, crops | 3.95 / 5.26 | 4.41 / 8.00 | 8.55 / 10.66 |
| Restored house at night, fire and every candle, clock | 4.28 / 5.94 | 4.33 / 5.94 | 9.80 / 12.13 |
| Cave with three live creatures, Hollow Lantern | 5.13 / 9.92 | 3.74 / 4.73 | 9.12 / 10.90 |

Every case is under the 16.7 ms a 60 Hz frame allows. The settings offer fill-screen, 1280x720, 1600x900 and
1920x1080; 960x540 is not an offered size, but the HUD fits it (`evidence/hud_960x540.png`). One run each, so a
difference of a millisecond or two is noise. In the scratch profiles the engine printed
`ERROR: Condition "err != OK" is true (shader_gles3.cpp:802)` three times per launch from the second launch on (the
shader cache of a throwaway profile); it had no visible effect and was not checked in the owner's real profile.
Save size grew from 5.5 KB to 58 KB over a 400-day simulated game. No play session logged a script error.

---

## Repair roadmap (proposed; nothing started; each needs owner approval)

**1. Critical repairs** (small, remove a stuck state and two story dead ends)
1. PLAY-01: clear `inside` in `_fallen`. S.
2. PLAY-05: close the `davy` beat with the others, and once on load. S.
3. PLAY-04: allow the first cleanse without a lost limit; say the real reason when refused. S (owner chooses the rule).
4. PLAY-11: show old-save migration notes after the HUD exists. S.

**2. Major gameplay repairs** (onboarding and feedback)
5. PLAY-03: queue messages; keep the morning report readable. M.
6. PLAY-06: hints follow the device in use. S.
7. PLAY-07: first-minute controls and a desk prompt. S.
8. PLAY-02: a diary page on what the night takes and what restores sanity (text; no balance change). S-M.
9. PLAY-08: introduce the catalog. S.
10. PLAY-09 (P2, but it guards chapter 3): a true line and a way out when the first walker freezes; then a human playtest of the first trek. S.

**3. Quality of life**
11. PLAY-10 drink on a fishing spot. S.
12. PLAY-17 say how to make a missing tool; mention the pick and a weapon in the cave tip. S.
13. PLAY-12 the bare fishing pole is not "locked". S.
14. PLAY-13 a cave collapse wakes outside. S.

**4. Optional polish and decisions**
15. PLAY-14 chapter pacing, PLAY-15 raid frequency, PLAY-16 eviction: owner decisions, no defect.
16. PLAY-18 to PLAY-22.
17. Keep the audit tools as regression checks: `audit_state_probe.gd` should report 0 suspect after items 1 and 14, and `audit_probe.gd` should list no "NEVER chapter" for engaged after items 2 and 3.

**Deferred safely for an initial playable build:** all of group 4, items 12 to 14, the porch, second storey and deed.

## Evidence index

- `art/style_tests/CCH-PLAYABLE-001/evidence/` — the screenshots named in the findings.
- `play_kbm/log_start.txt`, `log_week.txt`, `log_extras.txt`, `log_trek_attempt1.txt`, `log_trek_attempt5.txt` (two sessions wrote to this file, so lines of both are in it), `log_edge_4day.txt` — keyboard and mouse sessions.
- `play_pad/log_week.txt`, `log_extras.txt` — controller sessions.
- `logs/tests_summary.txt`, `logs/test_*.log` — regression tests.
- `logs/probe_{engaged,ignore,earlybed}_{400,420}.log` — progression probes.
- `logs/state_probe.log` — death, collapse and recovery.
- `logs/perf.log` — frame times.
- `logs/save_roundtrip_{engaged,ignore}.log`, `logs/save_owner_copies.log` — saving and loading.
